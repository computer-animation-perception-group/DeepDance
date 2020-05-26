import argparse
import copy
import json
import os
import time
from collections import OrderedDict

import numpy as np
from model.base_model import *

import m2m_config as cfg
from utils import reader as rd

def generate_motion(session, model, data_info, gen_str, test_config, hop,
                    time_dir=None, use_pre_mot=True):
    """Run the model on the given data"""
    fetches = {
        "prediction": model.mot_predictions,
        "last_step_mot": model.last_step_mot,
        "mot_final_state": model.mot_final_state,
        "mus_final_state": model.mus_final_state,
    }
    print(model.last_step_mot.get_shape())

    step = 0
    num_steps = test_config.num_steps
    pre_mot = []
    mus_data = data_info[gen_str][0]

    seq_keys = list(mus_data.keys())
    seq_keys.sort()
    mus_delay = test_config.mus_delay

    for file_name in seq_keys:
        predictions = []
        mus_file_data = mus_data[file_name]
        test_len = mus_file_data.shape[1]+mus_delay
        test_num = int((test_len - 1 - num_steps) / hop + 1)

        mot_state = session.run(model.mot_initial_state)
        mus_state = session.run(model.mus_initial_state)

        for t in range(test_num):
            batch_x = mus_file_data[:, t * hop + 1 - mus_delay: t * hop + num_steps + 1 - mus_delay, :]

            feed_dict = dict()
            if use_pre_mot:
                for i, (c, h) in enumerate(model.mot_initial_state):
                    feed_dict[c] = mot_state[i].c
                    feed_dict[h] = mot_state[i].h

                for i, (c, h) in enumerate(model.mus_initial_state):
                    feed_dict[c] = mus_state[i].c
                    feed_dict[h] = mus_state[i].h

            if t > 0 and use_pre_mot:
                last_step_mot = copy.deepcopy(pre_mot)
            else:
                last_step_mot = np.zeros([1, 60], np.float)

            feed_dict[model.init_step_mot] = last_step_mot
            feed_dict[model.input_x] = batch_x
            feed_dict[model.tf_mask] = [False] * test_config.num_steps

            vals = session.run(fetches, feed_dict)

            prediction = vals["prediction"]
            mot_state = vals["mot_final_state"]
            mus_state = vals["mus_final_state"]
            pre_mot = vals["last_step_mot"]


            step += 1
            prediction = np.reshape(prediction, [test_config.num_steps, test_config.mot_dim])
            predictions.append(prediction)

        test_pred_path = os.path.join(time_dir, file_name + ".csv")
        print(test_pred_path)
        if len(predictions):
            predictions = np.concatenate(predictions, 0)
            rd.save_predict_data(predictions, test_pred_path, data_info,
                                    test_config.norm_way, test_config.mot_ignore_dims,
                                    test_config.mot_scale)

def run_main(config, data_info):

    with tf.Graph().as_default():
        with tf.name_scope("Test"):
            with tf.variable_scope("Model", reuse=None):
                test_model = BaseModel(config=config,
                                      train_type=2)

        # allowing gpu memory growth
        gpu_config = tf.ConfigProto()
        saver = tf.train.Saver(max_to_keep=20)
        gpu_config.gpu_options.allow_growth = True

        with tf.Session(config=gpu_config) as session:
            saver.restore(session, config.model_path)
            # start queue
            coord = tf.train.Coordinator()
            tf.train.start_queue_runners(sess=session, coord=coord)

            dance_genre = config.model_path[26: config.model_path.rfind('/')]
            time_dir = os.path.join(config.save_dir, dance_genre)
            os.makedirs(time_dir)
            start_time = time.time()
            generate_motion(session, test_model,
                            data_info, 'test', config, hop=config.num_steps,
                            time_dir=time_dir, use_pre_mot=True)

            time_info = "Generating complete. Elapsed Time : {}\n".format(time.time()-start_time)
            print(time_info)

            coord.request_stop()
            coord.join()


def main(_):
    seg_len = args.seg_len
    test_config = cfg.get_config(seg_len)
    cfg_list = []
    care_list = ['add_info', 'mse_rate', 'dis_rate', 'dis_learning_rate',
                    'reg_scale', 'rnn_keep_list', 'is_reg', 'cond_axis']
    # 'is_reg', 'reg_scale','rnn_keep_list'
    for k, v in sorted(vars(args).items()):
        print(k, v)
        setattr(test_config, k, v)
    test_config.test_json_path = "./sample_list.json"
    test_config.save_dir = './training_results/motions'
    test_config.batch_size = 1
    data_info = rd.run_all_inference(test_config)
    test_config.mot_data_info = data_info['mot']
    run_main(test_config, data_info)


if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument('--add_info', type=str, default='')
    parser.add_argument('--model_path', type=str, help='model_path')
    parser.add_argument('--rnn_keep_list', nargs='+', type=float, help='rnn_keep_probability list, [1.0, 1.0, 1.0]')
    parser.add_argument('--has_random_seed', type=lambda x: (str(x).lower() == 'true'), help='')
    parser.add_argument('--norm_way', type=str, help='zscore, maxmin, no')
    parser.add_argument('--seq_shift', type=int, help='seq_shift')
    parser.add_argument('--seg_len', type=int, help='segment length')
    parser.add_argument('--gen_hop', type=int, help='gen_hop')
    parser.add_argument('--mot_scale', type=float, help='motion scale')
    parser.add_argument('--act_type', type=str, default='lrelu')
    parser.add_argument('--kernel_size', nargs='+', type=int)
    parser.add_argument('--stride', nargs='+', type=int)
    parser.add_argument('--mus_ebd_dim', type=int)
    parser.add_argument('--is_all_norm', type=lambda x: (str(x).lower() == 'true'), default=False)

    args = parser.parse_args()

    tf.app.run()
