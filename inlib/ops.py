import tensorflow as tf
from tensorflow.python.layers import pooling
import tensorflow.contrib as tf_contrib


def weight(shape, stddev=0.02, name='weight', trainable=True):
    dtype = tf.float32
    var = tf.get_variable(name, shape, dtype, initializer=tf.random_normal_initializer(0.0, stddev, dtype=dtype),
                          trainable=trainable)
    return var


def bias(dim, bias_start=0.0, name='bias', trainable=True):
    dtype = tf.float32
    var = tf.get_variable(name, dim, dtype, initializer=tf.constant_initializer(value=bias_start, dtype=dtype),
                          trainable=trainable)

    return var


def xelu(value, name='relu', activate_type='relu', para=0.2):
    with tf.variable_scope(name):
        if activate_type == 'relu':
            # relu
            return tf.nn.relu(value)
        elif activate_type == 'lrelu':
            # leaky relu
            return tf.maximum(value, value * para)
        else:
            return value


def pool2D(value, k_h=3, k_w=3, strides=[1, 2, 2, 1], name='max_pool', padding='VALID'):
    kernel_size = [1, k_h, k_w, 1]
    with tf.variable_scope(name + '_2d'):
        if name == 'max_pool':
            # max pooling
            return tf.nn.max_pool(value, kernel_size, strides, padding)
        elif name == 'avg_pool':
            # average pooling
            return tf.nn.avg_pool(value, kernel_size, strides, padding)
        else:
            # default: max pooling
            return tf.nn.max_pool(value, kernel_size, strides, padding)


def pool1D(value, ksize=3, strides=[1, 2, 1], name='max_pool', padding='VALID'):
    kernel_size = [1, ksize, 1]
    with tf.variable_scope(name + '_1d'):
        if name == 'max_pool':
            # max pooling
            return pooling.max_pooling1d(value, kernel_size, strides, padding)
        elif name == 'avg_pool':
            # average pooling
            return pooling.average_pooling1d(value, kernel_size, strides, padding)
        else:
            # default: max pooling
            return pooling.max_pooling1d(value, kernel_size, strides, padding)


def fc(value, output_num, name='fc', with_weight=False, with_bias=True):
    input_shape = value.get_shape().as_list()
    with tf.variable_scope(name):
        weights = weight([input_shape[1], output_num])
        output = tf.matmul(value, weights)
        if with_bias:
            biases = bias(output_num)
            output = output + biases
        if with_weight:
            if with_bias:
                return output, weights, biases
            else:
                return output, weights
        else:
            return output


def conv1d(value, output_num, ksize=3, strides=[1, 1, 1], name='conv', padding='SAME', with_weight=False,
           with_bias=True):
    with tf.variable_scope(name + '_1d'):
        weights = weight([ksize, value.get_shape[-1], output_num])
        conv = tf.nn.conv1d(value, weights, strides, padding, use_cudnn_on_gpu=True)
        if with_bias:
            biases = bias(output_num)
            conv = tf.reshape(tf.nn.bias_add(conv, biases), conv.get_shape())
        if with_weight:
            if with_bias:
                return conv, weights, biases
            else:
                return conv, weights
        else:
            return conv


def conv2d(value, output_num, k_h=3, k_w=3, strides=[1, 1, 1, 1], name='conv', padding='SAME', with_weight=False,
           with_bias=True):
    with tf.variable_scope(name + '_2d'):
        weights = weight([k_h, k_w, value.get_shape()[-1], output_num])
        conv = tf.nn.conv2d(value, weights, strides, padding, use_cudnn_on_gpu=True)
        if with_bias:
            biases = bias(output_num)
            conv = tf.reshape(tf.nn.bias_add(conv, biases), conv.get_shape())
        if with_weight:
            if with_bias:
                return conv, weights, biases
            else:
                return conv, weights
        else:
            return conv


def bn(x, is_training, scope='bn'):
    return tf.layers.batch_normalization(x,
                                         axis=-1,
                                         training=is_training,
                                         name=scope)
