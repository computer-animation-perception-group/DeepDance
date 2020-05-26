import os
import json
import numpy as np


class CAPGConfig(object):
    """capg config"""
    def __init__(self, seg_len):
        self.mot_data_dir = './dataset/motion_feature/exp/'
        self.mus_data_dir = './dataset/music_feature/librosa/'
        self.json_dir = './dataset/fold_json/'
        self.all_json_path = os.path.join(self.json_dir, 'all-f4', 'fold_0', 'train_list.json')
        self.hidden_size = 512
        self.mot_hidden_size = 1024

        self.is_save_model = True
        self.is_load_model = False
        self.save_epoch = 0
        self.test_epoch = 5
        self.gen_hop = 10
        self.seq_shift = 1  # 15 for beat
        self.use_mus_rnn = True
        self.mus_rnn_layers = 1
        self.max_max_epoch = 15
        self.is_reg = False
        self.reg_scale = 5e-4
        self.rnn_keep_prob = 1

        self.is_shuffle = True
        self.has_random_seed = False

        self.is_align = True
        self.mus_delay = 0  # 1 for beat
        self.mot_ignore_dims = [18, 19, 20, 33, 34, 35, 48, 49, 50, 60, 61, 62, 72, 73, 74]
        self.mot_dim = 60

        self.is_z_score = True
        self.is_all_norm = False
        self.mus_dim = 201
        self.mus_kernel_size = 51
        self.batch_size = 32
        self.num_steps = seg_len
        self.test_num_steps = seg_len
        self.max_epoch = 20
        self.lr_decay = 1
        self.max_grad_norm = 25
        self.val_data_len = 150

        self.rnn_layers = 3
        self.mot_rnn_layers = 2

        self.info = "gan_gt"
        self.val_batch_size = 1
        self.test_batch_size = 1
        self.is_use_pre_mot = False

        self.use_noise = False
        self.noise_schedule = ['2:0.05', '6:0.1', '12:0.2', '16:0.3', '22:0.5', '30:0.8', '36:1.0']
        self.start_idx = 1

    def save_config(self, path):
        config_dict = dict()
        for name, value in vars(self).items():
            if isinstance(value, list):
                value = np.asarray(value).tolist()
            config_dict[name] = value
        json.dump(config_dict, open(path, 'w'), indent=4, sort_keys=True)


def get_config(seg_len):
    config = CAPGConfig(seg_len)
    return config
