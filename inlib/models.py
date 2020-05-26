import numpy as np
from .ops import *
import tensorflow.contrib as tf_contrib


def convolution(value, output_num, kernel_size=[3, 3], strides=[1, 1], name='conv', padding='SAME',
                activate_type='relu'):
    x = conv2d(value, output_num, kernel_size[0], kernel_size[1], [1, strides[0], strides[1], 1], name, padding)
    if activate_type == 'relu':
        x = xelu(x, 'relu_' + name, activate_type)
    else:
        x = xelu(x, 'lrelu_' + name, activate_type)
    return x


class vgg19:
    def __init__(self, model_path):
        self.data_dict = np.load(model_path).item()
        print('load vgg19 weight complete.')

    def get_feature(self, x, reuse=False):
        self.channels = x.get_shape()[-1]
        with tf.variable_scope('vgg19') as scope:
            if reuse:
                scope.reuse_variables()
            # conv1
            self.conv1_1 = convolution(x, 64, [3, 3], [1, 1], name='conv1_1')
            self.conv1_2 = convolution(self.conv1_1, 64, [3, 3], [1, 1], name='conv1_2')
            self.conv1_2 = pool2D(self.conv1_2, 2, 2, name='max_pool1')

            # conv2
            self.conv2_1 = convolution(self.conv1_2, 128, [3, 3], [1, 1], name='conv2_1')
            self.conv2_2 = convolution(self.conv2_1, 128, [3, 3], [1, 1], name='conv2_2')
            self.conv2_2 = pool2D(self.conv2_2, 2, 2, name='max_pool2')

            # conv3
            self.conv3_1 = convolution(self.conv2_2, 256, [3, 3], [1, 1], name='conv3_1')
            self.conv3_2 = convolution(self.conv3_1, 256, [3, 3], [1, 1], name='conv3_2')
            self.conv3_3 = convolution(self.conv3_2, 256, [3, 3], [1, 1], name='conv3_3')
            self.conv3_4 = convolution(self.conv3_3, 256, [3, 3], [1, 1], name='conv3_4')
            self.conv3_4 = pool2D(self.conv3_4, 2, 2, name='max_pool3')

            # conv4
            self.conv4_1 = convolution(self.conv3_4, 512, [3, 3], [1, 1], name='conv4_1')
            self.conv4_2 = convolution(self.conv4_1, 512, [3, 3], [1, 1], name='conv4_2')
            self.conv4_3 = convolution(self.conv4_2, 512, [3, 3], [1, 1], name='conv4_3')
            self.conv4_4 = convolution(self.conv4_3, 512, [3, 3], [1, 1], name='conv4_4')
            self.conv4_4 = pool2D(self.conv3_4, 2, 2, name='max_pool4')

            # conv5
            self.conv5_1 = convolution(self.conv4_4, 512, [3, 3], [1, 1], name='conv5_1')
            self.conv5_2 = convolution(self.conv5_1, 512, [3, 3], [1, 1], name='conv5_2')
            self.conv5_3 = convolution(self.conv5_2, 512, [3, 3], [1, 1], name='conv5_3')
            self.conv5_4 = convolution(self.conv5_3, 512, [3, 3], [1, 1], name='conv5_4')

            # flatten
            self.feature5_4 = tf.reshape(self.conv5_4, [x.get_shape()[0], -1], name='feature5_4')

            return self.feature5_4

    def load_weights(self, sess):
        vars = tf.trainable_variables(scope='vgg19')
        loaded_vars = [var for var in vars if 'conv' in var.name]
        keys = sorted(self.data_dict)
        for i in range(len(keys)):
            print(loaded_vars[i * 2], keys[i] + '_weight')
            sess.run(loaded_vars[i * 2].assign(self.data_dict[keys[i]][0]))
            print(loaded_vars[i * 2 + 1], keys[i] + '_bias')
            sess.run(loaded_vars[i * 2 + 1].assign(self.data_dict[keys[i]][1]))


def mlp(x, dim_list, name='mlp', reuse=False):
    # dim_list=[[output_num1, activation1],...,[output_numk, activationk]]
    with tf.variable_scope(name) as scope:
        if reuse:
            scope.reuse_variables()
        outputs = [x]
        for i in range(len(dim_list)):
            out = fc(outputs[-1], dim_list[i][0], name='fc' + str(i + 1))
            if i < len(dim_list) - 1:
                out = xelu(out, name=dim_list[i][1] + str(i + 1), activate_type=dim_list[i][1])
            outputs.append(out)
        return outputs[-1]


def cnn(x, conv_list, fc_list, name='cnn', is_training=True, reuse=False):
    # conv_list=[[output_num1, kernels1, strides1, padding1, activation1],
    #             ...[output_numk, kernelsk, stridesk, paddingk, activationk]]
    # fc_list=[[output_num1, activation1],...,[output_numk,activationk]
    with tf.variable_scope(name) as scope:
        if reuse:
            scope.reuse_variables()
        outputs = [x]
        for i in range(len(conv_list)):
            out = convolution(outputs[-1], conv_list[i][0], conv_list[i][1], conv_list[i][2], name='conv' + str(i + 1),
                              padding=conv_list[i][3], activate_type=conv_list[i][4])
            if 'bn' in conv_list[-1]:
                out = bn(out, is_training, scope='bn'+str(i+1))
            outputs.append(out)
        # print('outputs: ', outputs[-1])
        outputs.append(tf.reshape(outputs[-1], [int(x.get_shape()[0]), -1]))
        for i in range(len(fc_list)):
            out = fc(outputs[-1], fc_list[i][0], name='fc' + str(i + 1))
            if i < len(fc_list) - 1:
                out = xelu(out, name=fc_list[i][1] + str(i + 1), activate_type=fc_list[i][1])
            outputs.append(out)
        return outputs[-1]
