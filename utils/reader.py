import os
import json
import copy
import pandas as pd
import numpy as np
import m2m_config as cfg


# config = cfg.get_config()


def get_normalize_info(input_data):
    data_mean = np.mean(input_data, axis=0)
    data_std = np.std(input_data, axis=0)
    return data_mean, data_std


def load_data(data_dir, json_path, mot_scale):
    all_data = []
    seq_data = dict()
    with open(json_path, 'r') as f:
        list_csv = json.load(f)
    for i, csv_name in enumerate(list_csv):
        csv_no_ext_name = os.path.splitext(os.path.basename(csv_name))[0]
        print(i, csv_no_ext_name)
        csv_path = os.path.join(data_dir, csv_name)
        csv_data = pd.read_csv(csv_path, header=None, dtype=np.float32).values
        csv_data[:, :3] = csv_data[:, :3] / mot_scale
        seq_data[csv_no_ext_name] = csv_data
        if 0 == len(all_data):
            all_data = copy.deepcopy(csv_data)
        else:
            all_data = np.append(all_data, csv_data, axis=0)

    return seq_data, all_data


def load_tv_data(data_dir, train_json_path, val_json_path, num_steps=150):
    all_data = []
    val_all_data = []
    seq_data = dict()
    val_seq_data = dict()

    with open(train_json_path, 'r') as trf:
        train_list = json.load(trf)

    with open(val_json_path, 'r') as vf:
        val_list = json.load(vf)

    for i, file_name in enumerate(train_list):
        base_name = os.path.splitext(os.path.basename(file_name))[0]
        print(i, base_name)
        [mus_type, mus_idx, mus_sub_idx] = base_name.split('.')
        file_path = os.path.join(data_dir, file_name)
        file_data = pd.read_csv(file_path, header=None, dtype=np.float32).as_matrix()
        train_data = file_data
        val_data = []
        for j, val_sub_idx in enumerate(val_list[mus_type][mus_idx]):
            if mus_sub_idx == val_sub_idx and j == 0:
                val_data = file_data[-num_steps:, :]
                train_data = file_data[:-num_steps, :]
            elif mus_sub_idx == val_sub_idx and j == 1:
                val_data = file_data[:num_steps, :]
                train_data = file_data[num_steps:, :]

        seq_data[base_name] = train_data
        if len(val_data) > 0:
            val_seq_data[file_name] = val_data

        if 0 == len(all_data):
            all_data = copy.deepcopy(train_data)
        else:
            all_data = np.append(all_data, train_data, axis=0)

        if 0 == len(val_all_data):
            val_all_data = copy.deepcopy(val_data)
        elif len(val_data) > 0:
            val_all_data = np.append(val_all_data, val_data, axis=0)

    return seq_data, all_data, val_seq_data, val_all_data


def load_trip_data(data_dir, train_json_path, val_json_path, val_rate):
    all_data = []
    val_all_data = []
    seq_data = dict()
    val_seq_data = dict()

    with open(train_json_path, 'r') as trf:
        train_list = json.load(trf)

    with open(val_json_path, 'r') as vf:
        val_list = json.load(vf)

    for i, file_name in enumerate(train_list):
        base_name = os.path.splitext(os.path.basename(file_name))[0]
        print(i, base_name)
        file_path = os.path.join(data_dir, file_name)
        file_data = pd.read_csv(file_path, header=None, dtype=np.float32).as_matrix()
        train_data = file_data
        val_data = []
        val_len = val_rate * file_data.shape[0]

        if file_name in val_list:
            val_data = file_data[-val_len:, :]
            train_data = file_data[:-val_len, :]

        seq_data[base_name] = train_data
        if len(val_data) > 0:
            val_seq_data[file_name] = val_data

        if 0 == len(all_data):
            all_data = copy.deepcopy(train_data)
        else:
            all_data = np.append(all_data, train_data, axis=0)

        if 0 == len(val_all_data):
            val_all_data = copy.deepcopy(val_data)
        elif len(val_data) > 0:
            val_all_data = np.append(val_all_data, val_data, axis=0)

    return seq_data, all_data, val_seq_data, val_all_data


def sample_seq(mus_seq, mus_data_max, mus_data_min, mot_seq, mot_data_max, mot_data_min,
               mot_data_mean, mot_data_std, config):

    wlen = config.num_steps
    hop = config.seq_shift
    is_z_score = config.is_z_score
    start_idx = config.start_idx
    mus_dim = config.mus_dim
    ignore_dims = config.mot_ignore_dims
    mus_delay = config.mus_delay

    mus_x = []
    mot_x = []
    mot_y = []
    ns = 0  # N sequence

    seq_keys = list(mus_seq.keys())
    seq_keys.sort()
    # loop each action sequence, i.e. each file
    for k in seq_keys:
        print("sample_seq: ", k)
        mus_seq_data = mus_seq[k]
        mot_seq_data = mot_seq[k]
        start = start_idx
        end = start + wlen
        seq_len = min(mot_seq_data.shape[0], mus_seq_data.shape[0]+mus_delay)
        while end <= seq_len:
            mus_x.append(mus_seq_data[start-mus_delay:end-mus_delay, :])
            mot_x.append(mot_seq_data[start-1:end-1, :])
            mot_y.append(mot_seq_data[start:end, :])
            ns += 1
            start += hop
            end += hop

    # initialize tensors
    mus_nd = mus_x[0].shape[1]
    mot_nd = mot_x[0].shape[1]
    mus_x_tensor = np.zeros((wlen, ns, mus_nd), dtype=np.float32)
    mot_x_tensor = np.zeros((wlen, ns, mot_nd), dtype=np.float32)
    mot_y_tensor = np.zeros((wlen, ns, mot_nd), dtype=np.float32)

    count = 0
    for _mus_x, _mot_x, _mot_y in zip(mus_x, mot_x, mot_y):
        mus_x_tensor[:, count, :] = _mus_x
        mot_x_tensor[:, count, :] = _mot_x
        mot_y_tensor[:, count, :] = _mot_y
        count += 1

    mus_x_tensor = norm_mus(mus_x_tensor, mus_data_max, mus_data_min, mus_dim)
    if is_z_score:
        mot_x_tensor = norm_mot_std(mot_x_tensor, mot_data_mean, mot_data_std, ignore_dims)
        mot_y_tensor = norm_mot_std(mot_y_tensor, mot_data_mean, mot_data_std, ignore_dims)
    else:
        mot_x_tensor = norm_mot(mot_x_tensor, mot_data_max, mot_data_min, ignore_dims)
        mot_y_tensor = norm_mot(mot_y_tensor, mot_data_max, mot_data_min, ignore_dims)

    return mus_x_tensor, mot_x_tensor, mot_y_tensor


def sample_seq_idx(mus_seq, mot_seq, config):
    wlen = config.num_steps
    hop = config.seq_shift
    start_idx = config.start_idx
    mus_delay = config.mus_delay

    mus_x = []
    mot_x = []
    mot_y = []
    ns = 0  # N sequence

    seq_keys = list(mus_seq.keys())
    seq_keys.sort()
    # loop each action sequence, i.e. each file
    for k in seq_keys:
        print("sample_seq: ", k)
        mus_seq_data = mus_seq[k]
        mot_seq_data = mot_seq[k]
        start = start_idx
        end = start + wlen
        seq_len = min(mot_seq_data.shape[0], mus_seq_data.shape[0]+mus_delay)
        while end <= seq_len:
            mus_x.append([k, start - mus_delay, end - mus_delay])
            mot_x.append([k, start-1, end-1])
            mot_y.append([k, start, end])
            ns += 1
            start += hop
            end += hop
    return mus_x, mot_x, mot_y


def get_seq_tensor(mus_seq, mus_data_max, mus_data_min, mot_seq, mot_data_max, mot_data_min,
                   mot_data_mean, mot_data_std, config):

    norm_way = config.norm_way
    mus_dim = config.mus_dim
    ignore_dims = config.mot_ignore_dims
    # mot_scale = config.mot_scale

    mus_seq_tensor = dict()
    mot_seq_tensor = dict()

    seq_keys = list(mus_seq.keys())
    seq_keys.sort()
    # loop each action sequence, i.e. each file
    for k in seq_keys:
        print("sample_seq: ", k)
        mus_seq_data = mus_seq[k]
        mus_seq_data = np.reshape(mus_seq_data, [1, mus_seq_data.shape[0], mus_seq_data.shape[1]])
        mus_seq_tensor[k] = norm_mus(mus_seq_data, mus_data_max, mus_data_min, mus_dim)

        if mot_seq is not None:
            mot_seq_data = mot_seq[k]
            # mot_seq_data[:, :3] = mot_seq_data[:, :3] / mot_scale
            mot_seq_data = np.reshape(mot_seq_data, [1, mot_seq_data.shape[0], mot_seq_data.shape[1]])

            if norm_way == 'zscore':
                mot_seq_tensor[k] = norm_mot_std(mot_seq_data, mot_data_mean, mot_data_std, ignore_dims)
            elif norm_way == 'maxmin':
                mot_seq_tensor[k] = norm_mot(mot_seq_data, mot_data_max, mot_data_min, ignore_dims)
            else:
                mot_seq_tensor[k] = get_useful_dim(mot_seq_data, ignore_dims)
        else:
            mot_seq_tensor = None

    return mus_seq_tensor, mot_seq_tensor


def get_init_frame(mot_data, batch_size, num_steps):
    data_len = int(mot_data.shape[0])
    batch_len = data_len // batch_size
    mot_data = mot_data[0: batch_size * batch_len, :]
    mot_data = np.reshape(mot_data, [batch_size, batch_len, -1])
    init_mot = mot_data[0: batch_size, 0 * num_steps, :]
    print("init_mot shape: ", init_mot.shape)
    return init_mot


def save_data_info(data_mean, data_std, save_dir):
    data_mean_path = os.path.join(save_dir, 'data_mean.csv')
    pd.DataFrame(data_mean).to_csv(data_mean_path, index=False, header=False)

    data_std_path = os.path.join(save_dir, 'data_std.csv')
    pd.DataFrame(data_std).to_csv(data_std_path, index=False, header=False)

def save_data_info_2(data, save_dir):
    pd.DataFrame(data).to_csv(save_dir, index=False, header=False)

def get_useful_dim(input_data, ignore_dims):
    [_, _, nd] = input_data.shape
    useful_list = []
    for i in range(nd):
        if i not in ignore_dims:
            useful_list.append(i)

    return input_data[:, :, useful_list]


def unnorm_data(norm_data, data_mean, data_std, ignore_dims):
    sl = norm_data.shape[0]
    nd = data_mean.shape[0]

    org_data = np.zeros((sl, nd), dtype=np.float32)
    use_dimensions = []
    for i in range(nd):
        if i in ignore_dims:
            continue
        use_dimensions.append(i)
    use_dimensions = np.array(use_dimensions)
    org_data[:, use_dimensions] = norm_data

    std_mat = data_std.reshape((1, nd))
    std_mat = np.repeat(std_mat, sl, axis=0)
    mean_mat = data_mean.reshape((1, nd))
    mean_mat = np.repeat(mean_mat, sl, axis=0)
    org_data = np.multiply(org_data, std_mat) + mean_mat
    return org_data


def add_ignore_dims(input_data, ignore_dims):
    sl = input_data.shape[0]
    nd = input_data.shape[1] + len(ignore_dims)
    org_data = np.zeros((sl, nd), dtype=np.float32)
    use_dimensions = []
    for i in range(nd):
        if i in ignore_dims:
            continue
        use_dimensions.append(i)
    use_dimensions = np.array(use_dimensions)
    org_data[:, use_dimensions] = input_data

    return org_data


def save_predict_data(input_data, save_path, data_info, norm_way, ignore_dims, mot_scale=1.0):
    save_dir = os.path.dirname(save_path)
    if not os.path.exists(save_dir):
        os.makedirs(save_dir)

    data_max = data_info['mot'][0]
    data_min = data_info['mot'][1]
    data_mean = data_info['mot'][2]
    data_std = data_info['mot'][3]

    if norm_way == 'zscore':
        input_data = unnorm_data(input_data, data_mean, data_std, ignore_dims)
    elif norm_way == 'maxmin':
        input_data = unnorm_mot(input_data, data_max, data_min, ignore_dims)
    else:
        input_data = add_ignore_dims(input_data, ignore_dims)

    input_data[:, :3] = input_data[:, :3] * mot_scale

    input_data_frame = pd.DataFrame(input_data)
    input_data_frame.to_csv(save_path, index=False, header=False)


def save_mus_data(input_data, data_info, mus_dim, save_path):
    data_max = data_info['mus'][0]
    data_min = data_info['mus'][1]
    input_data = unnorm_mus(input_data, data_max, data_min, mus_dim)
    input_data_frame = pd.DataFrame(input_data)
    input_data_frame.to_csv(save_path, index=False, header=False)


def norm_mot(seq_data, data_max, data_min, ignore_dims):
    [sl, nb, nd] = seq_data.shape
    data_max = data_max.reshape((1, 1, nd))
    data_max = np.repeat(data_max, sl, axis=0)
    data_max = np.repeat(data_max, nb, axis=1)

    data_min = data_min.reshape((1, 1, nd))
    data_min = np.repeat(data_min, sl, axis=0)
    data_min = np.repeat(data_min, nb, axis=1)

    eps = 1e-12
    norm_data = np.divide((seq_data - data_min), (data_max - data_min) + eps)
    norm_data = np.multiply(norm_data, 1.8)
    norm_data = np.subtract(norm_data, 0.9)

    return get_useful_dim(norm_data, ignore_dims)


def norm_mot_std(input_tensor, data_mean, data_std, ignore_dims, eps=1e-12):
    mean_tensor = data_mean.reshape((1, 1, input_tensor.shape[2]))
    mean_tensor = np.repeat(mean_tensor, input_tensor.shape[0], axis=0)
    mean_tensor = np.repeat(mean_tensor, input_tensor.shape[1], axis=1)
    data_std = np.add(data_std, eps)
    std_tensor = np.reshape(data_std, [1, 1, input_tensor.shape[2]])
    std_tensor = np.repeat(std_tensor, input_tensor.shape[0], axis=0)
    std_tensor = np.repeat(std_tensor, input_tensor.shape[1], axis=1)
    norm_tensor = np.divide((input_tensor - mean_tensor), std_tensor)

    return get_useful_dim(norm_tensor, ignore_dims)


def norm_mus(seq_data, data_max, data_min, mus_dim):
    [sl, nb, nd] = seq_data.shape
    seq_data = np.reshape(seq_data, [sl, nb, mus_dim, 5])

    data_max = data_max.reshape((1, 1, mus_dim, 1))
    data_max = np.repeat(data_max, sl, axis=0)
    data_max = np.repeat(data_max, nb, axis=1)
    data_max = np.repeat(data_max, 5, axis=3)

    data_min = data_min.reshape((1, 1, mus_dim, 1))
    data_min = np.repeat(data_min, sl, axis=0)
    data_min = np.repeat(data_min, nb, axis=1)
    data_min = np.repeat(data_min, 5, axis=3)

    eps = 1e-12
    norm_data = np.divide((seq_data - data_min), (data_max - data_min) + eps)
    norm_data = np.multiply(norm_data, 0.8)
    norm_data = np.add(norm_data, 0.1)
    norm_data = np.reshape(norm_data, [sl, nb, nd])

    return norm_data


def unnorm_mus(norm_tensor, data_max, data_min, mus_dim):
    [sl, nd] = norm_tensor.shape
    norm_tensor = np.reshape(norm_tensor, [sl, mus_dim, 5])
    data_max = data_max.reshape((1, mus_dim, 1))
    data_max = np.repeat(data_max, sl, axis=0)
    data_max = np.repeat(data_max, 5, axis=2)

    data_min = data_min.reshape((1, mus_dim, 1))
    data_min = np.repeat(data_min, sl, axis=0)
    data_min = np.repeat(data_min, 5, axis=2)

    unnorm_tensor = np.subtract(norm_tensor, 0.1)
    unnorm_tensor = np.divide(unnorm_tensor, 0.8)
    unnorm_tensor = np.multiply(unnorm_tensor, (data_max - data_min)) + data_min

    unnorm_tensor = np.reshape(unnorm_tensor, [sl, nd])

    return unnorm_tensor


def unnorm_mot(norm_tensor, data_max, data_min, ignore_dims):
    sl = norm_tensor.shape[0]
    nd = data_max.shape[0]

    data_max = data_max.reshape((1, nd))
    data_max = np.repeat(data_max, sl, axis=0)
    data_min = data_min.reshape((1, nd))
    data_min = np.repeat(data_min, sl, axis=0)

    org_tensor = np.zeros((sl, nd), dtype=np.float32)
    use_dimensions = []
    for i in range(nd):
        if i in ignore_dims:
            continue
        use_dimensions.append(i)
    use_dimensions = np.array(use_dimensions)
    org_tensor[:, use_dimensions] = norm_tensor

    unnorm_tensor = np.add(org_tensor, 0.9)
    unnorm_tensor = np.divide(unnorm_tensor, 1.8)
    unnorm_tensor = np.multiply(unnorm_tensor, (data_max - data_min)) + data_min

    return unnorm_tensor


def add_noise(x, noise=1e-5):
    """
    :param x:
    :param noise: np.random.normal, mean = 0, sigma = noise
    :return:
    """
    rng = np.random.RandomState(1234567890)
    [sl, ns, nd] = x.shape

    # sl * ns samples are drawn
    binomial_prob = rng.binomial(1, 0.5, size=(sl, ns, 1))
    noise_to_add = rng.normal(scale=noise, size=x.shape)
    noise_sample = np.repeat(binomial_prob, nd, axis=2) * noise_to_add
    x += noise_sample

    return x


def normalize_info(input_data, full_skel=True, eps=1e-4):
    """
    :param input_data:
    :param full_skel:
    :param eps: 1e-4 default
    :return: data_mean, data_std, ignore_dimensions, new_idx
    """
    data_mean = np.mean(input_data, axis=0)
    data_std = np.std(input_data, axis=0)
    ignore_dimensions = []
    if not full_skel:
        ignore_dimensions = [0, 1, 2, 3, 4, 5]

    ignore_dimensions.extend(list(np.where(data_std < eps)[0]))
    # not_ignore_dims = cfg.get_config().not_ignore_dim  # left_arm
    # for not_ignore_dim in not_ignore_dims:
    #     ignore_dimensions.remove(not_ignore_dim)
    # print('ignore_dimensions: ', ignore_dimensions)

    new_idx = []
    count = 0
    for i in range(input_data.shape[1]):
        if i in ignore_dimensions:
            new_idx.append(-1)
        else:
            new_idx.append(count)
            count += 1

    return data_mean, data_std, ignore_dimensions, np.array(new_idx)


def run_all_inference(config):
    mot_scale = config.mot_scale

    print('--Loading music data..')
    [test_mus_seq, test_mus_all] = load_data(config.mus_data_dir, config.test_json_path, mot_scale)

    is_features_exists = True
    if not is_features_exists:
        print('--Loading all norm motion info data..')
        [_, mot_all_data] = load_data(config.mot_data_dir, config.all_json_path, mot_scale)
        [_, mus_all_data] = load_data(config.mus_data_dir, config.all_json_path, mot_scale)

        mus_all_len = mus_all_data.shape[0]
        mus_all_data = np.reshape(mus_all_data, [mus_all_len, config.mus_dim, 5])
        mus_all_data = mus_all_data.swapaxes(1, 2)
        mus_all_data = np.reshape(mus_all_data, [mus_all_len*5, config.mus_dim])
        mus_data_max = np.max(mus_all_data, axis=0)
        mus_data_min = np.min(mus_all_data, axis=0)

        mot_data_max = np.max(mot_all_data, axis=0)
        mot_data_min = np.min(mot_all_data, axis=0)

        [mot_data_mean, mot_data_std, ignore_dimensions, new_idx] = normalize_info(mot_all_data)

        # write statistic features for next use.
        save_data_info_2(mot_data_mean, './statistic_features/mot_data_mean.csv')
        save_data_info_2(mot_data_std, './statistic_features/mot_data_std.csv')
        save_data_info_2(mot_data_max, './statistic_features/mot_data_max.csv')
        save_data_info_2(mot_data_min, './statistic_features/mot_data_min.csv')
        save_data_info_2(mus_data_max, './statistic_features/mus_data_max.csv')
        save_data_info_2(mus_data_min, './statistic_features/mus_data_min.csv')
        save_data_info_2(ignore_dimensions, './statistic_features/ignore_dimensions.csv')
        save_data_info_2(new_idx, './statistic_features/new_idx.csv')
        
    else:
        print('--using precomputed statistic features..')
        mot_data_max = pd.read_csv('./statistic_features/mot_data_max.csv', header=None).to_numpy()
        mot_data_min = pd.read_csv('./statistic_features/mot_data_min.csv', header=None).to_numpy()
        mot_data_mean = pd.read_csv('./statistic_features/mot_data_mean.csv', header=None).to_numpy()
        mot_data_std = pd.read_csv('./statistic_features/mot_data_std.csv', header=None).to_numpy()
        mus_data_max = pd.read_csv('./statistic_features/mus_data_max.csv', header=None).to_numpy()
        mus_data_min = pd.read_csv('./statistic_features/mus_data_min.csv', header=None).to_numpy()
        ignore_dimensions = pd.read_csv('./statistic_features/ignore_dimensions.csv', header=None).to_numpy()
        new_idx = pd.read_csv('./statistic_features/new_idx.csv', header=None).to_numpy()

    test_mus_seq_tensor, test_mot_seq_tensor = \
        get_seq_tensor(test_mus_seq, mus_data_max, mus_data_min,
                    None, mot_data_max, mot_data_min,
                    mot_data_mean, mot_data_std, config)

    data_info = dict()
    data_info['ignore_dimensions'] = ignore_dimensions
    data_info['new_idx'] = new_idx
    data_info['mus'] = [mus_data_max, mus_data_min]
    data_info['mot'] = [mot_data_max, mot_data_min, mot_data_mean, mot_data_std]
    data_info['test'] = [test_mus_seq_tensor, test_mot_seq_tensor]

    return data_info


def capg_seq_generator(epoch, train_type, data_info, config):
    if train_type == 0:
        mus_data = data_info['train'][0]
        mot_data = data_info['train'][1]
        mus_idx = data_info['train'][2]
        mot_x_idx = data_info['train'][3]
        mot_y_idx = data_info['train'][4]
        batch_size = config.batch_size
    else:
        mus_data = data_info['val'][0]
        mot_data = data_info['val'][1]
        mus_idx = data_info['val'][2]
        mot_x_idx = data_info['val'][3]
        mot_y_idx = data_info['val'][4]
        batch_size = config.batch_size

    std = 1e-12

    if train_type == 0 and config.use_noise:
        noise_schedule = config.noise_schedule
        for j in range(len(noise_schedule)):
            if epoch >= int(noise_schedule[j].split(':')[0]):
                std = float(noise_schedule[j].split(':')[1])

    epoch_size = int(np.floor(len(mot_x_idx) / batch_size))

    if config.is_shuffle and train_type == 0:
        if config.has_random_seed:
            np.random.seed(1234567890)
        shuffle_list = list(np.random.permutation(len(mot_x_idx)))
        mus_idx = [mus_idx[i] for i in shuffle_list]
        mot_x_idx = [mot_x_idx[i] for i in shuffle_list]
        mot_y_idx = [mot_y_idx[i] for i in shuffle_list]

    for i in range(epoch_size):
        x = []
        y = []
        f = []
        for j in range(batch_size):
            file_name = mus_idx[i*batch_size+j][0]
            x_start = mus_idx[i*batch_size+j][1]
            x_end = mus_idx[i*batch_size+j][2]

            y_start = mot_y_idx[i*batch_size+j][1]
            y_end = mot_y_idx[i*batch_size+j][2]

            f_start = mot_x_idx[i*batch_size+j][1]

            x_seq = mus_data[file_name][0, x_start:x_end, :]
            y_seq = copy.deepcopy(mot_data[file_name][0, y_start:y_end, :])
            f_seq = copy.deepcopy(mot_data[file_name][0, f_start, :])
            x.append(x_seq)
            y.append(y_seq)
            f.append(f_seq)

        x = np.stack(x, axis=0)
        y = np.stack(y, axis=0)
        f = np.stack(f, axis=0)

        yield x, y, f
