import tensorflow as tf
import tensorflow.contrib as tf_contrib


def data_type():
    return tf.float32


class BaseModel(object):
    """The Base model."""
    def __init__(self, train_type, config):
        if train_type == 0:
            print("---init training graph---")
            is_training = True
        elif train_type == 1:
            print('---init validate graph---')
            is_training = False
        else:
            print("---init test graph---")
            is_training = False

        self.is_training = is_training
        config.is_training = is_training
        self.mot_dim = config.mot_dim
        self.mus_ebd_dim = config.mus_ebd_dim
        self.batch_size = config.batch_size
        self.num_steps = config.num_steps
        self.input_x = tf.placeholder(shape=[self.batch_size, self.num_steps, None],
                                       dtype=data_type(), name="input_x")
        # mot_input
        self.input_y = tf.placeholder(shape=[self.batch_size, self.num_steps, self.mot_dim],
                                       dtype=data_type(), name="input_y")

        self.init_step_mot = tf.placeholder(data_type(), [self.batch_size, self.mot_dim], name="init_step_mot")
        self.tf_mask = tf.placeholder(shape=[self.num_steps], dtype=tf.bool, name='tf_mask')

        mot_predictions, mus_ebd_outputs, mot_state, mus_state = \
            self._build_mot_rnn_graph(mus_inputs=self.input_x,
                                      config=config,
                                      train_type=train_type)

        self.mot_final_state = mot_state
        self.mus_final_state = mus_state
        self.mot_predictions = mot_predictions
        self.mot_truth = self.input_y
        self.mus_ebd_outputs = mus_ebd_outputs

    def _build_mus_graph(self, time_step, mus_cell, mus_state, inputs, config, is_training):
        print("mus_graph")
        # outputs = []
        with tf.variable_scope("mus_rnn"):
            fc_weights = tf.get_variable('fc', [config.hidden_size, self.mus_ebd_dim],
                                         initializer=tf.truncated_normal_initializer())
            fc_biases = tf.get_variable('bias', [self.mus_ebd_dim],
                                        initializer=tf.zeros_initializer())
            if time_step > 0:
                tf.get_variable_scope().reuse_variables()

            mus_input = self._build_mus_conv_graph(inputs, config, is_training)
            (cell_output, mus_state) = mus_cell(mus_input, mus_state)
            # outputs.append(cell_output)
            output = tf.reshape(cell_output, [-1, config.hidden_size])
            fc_output = tf.nn.xw_plus_b(output, fc_weights, fc_biases)

        return fc_output, mus_state

    @staticmethod
    def _get_lstm_cell(rnn_layer_idx, hidden_size, config, is_training):
        lstm_cell = tf_contrib.rnn.BasicLSTMCell(
            hidden_size, forget_bias=0.0, state_is_tuple=True,
            reuse=tf.get_variable_scope().reuse)
        print('rnn_layer: ', rnn_layer_idx, config.rnn_keep_list[rnn_layer_idx])
        if is_training and config.rnn_keep_list[rnn_layer_idx] < 1:
            lstm_cell = tf_contrib.rnn.DropoutWrapper(lstm_cell,
                                                      output_keep_prob=config.rnn_keep_list[rnn_layer_idx])
        return lstm_cell

    def _build_mot_rnn_graph(self, mus_inputs, config, train_type):
        if train_type == 0:
            is_training = True
        else:
            is_training = False

        rnn_layer_idx = 0
        mus_cell = tf_contrib.rnn.MultiRNNCell(
            [self._get_lstm_cell(i, config.hidden_size, config, is_training)
             for i in range(rnn_layer_idx, rnn_layer_idx + config.mus_rnn_layers)], state_is_tuple=True)

        rnn_layer_idx += config.mus_rnn_layers
        mot_cell = tf_contrib.rnn.MultiRNNCell(
            [self._get_lstm_cell(i, config.mot_hidden_size, config, is_training)
             for i in range(rnn_layer_idx, rnn_layer_idx + config.mot_rnn_layers)], state_is_tuple=True)

        self.mot_initial_state = mot_cell.zero_state(config.batch_size, data_type())
        mot_state = self.mot_initial_state

        self.mus_initial_state = mus_cell.zero_state(config.batch_size, data_type())
        mus_state = self.mus_initial_state

        last_step_mot = self.init_step_mot
        outputs = []
        mus_ebd_outputs = []

        with tf.variable_scope("generator/mot_rnn"):

            for time_step in range(self.num_steps):
                if time_step > 0:
                    tf.get_variable_scope().reuse_variables()
                    # last_step_mot = tf.cond(tf.equal(self.tf_mask[time_step], tf.constant(True)),
                    #                         lambda: self.input_y[:, time_step-1, :],
                    #                         lambda: self.last_step_mot)
                    last_step_mot = self.last_step_mot

                mus_input = mus_inputs[:, time_step, :]
                print("mot_rnn: ", time_step)
                if not config.use_mus_rnn:
                    with tf.variable_scope("mus_rnn"):
                        mus_fea = self._build_mus_conv_graph(mus_input, config, is_training)
                else:
                    mus_fea, mus_state = self._build_mus_graph(time_step, mus_cell,
                                                               mus_state, mus_input, config, is_training)
                mot_input = last_step_mot
                mot_input = tf.reshape(mot_input, [-1, self.mot_dim])
                # mus_fea = tf.zeros(tf.shape(mus_fea))
                all_input = tf.concat([mus_fea, mot_input], 1, name='mus_mot_input')

                # fc1
                fc1_weights = tf.get_variable('fc1', [self.mus_ebd_dim + self.mot_dim, 500], dtype=data_type())
                fc1_biases = tf.get_variable('bias1', [500], dtype=data_type())
                fc1_linear = tf.nn.xw_plus_b(all_input, fc1_weights, fc1_biases, name='fc1_linear')
                fc1_relu = tf.nn.relu(fc1_linear, name='fc1_relu')

                # fc2
                fc2_weights = tf.get_variable('fc2', [500, 500], dtype=data_type())
                fc2_biases = tf.get_variable('bias2', [500], dtype=data_type())
                fc2_linear = tf.nn.xw_plus_b(fc1_relu, fc2_weights, fc2_biases, name='fc2_linear')

                (cell_output, mot_state) = mot_cell(fc2_linear, mot_state)
                output = tf.reshape(cell_output, [-1, config.mot_hidden_size])

                # fc3
                fc3_weights = tf.get_variable('fc3', [config.mot_hidden_size, 500], dtype=data_type())
                fc3_biases = tf.get_variable('bias3', [500], dtype=data_type())
                fc3_linear = tf.nn.xw_plus_b(output, fc3_weights, fc3_biases, name='fc3_linear')
                fc3_relu = tf.nn.relu(fc3_linear, name='fc3_relu')

                fc4_weights = tf.get_variable('fc4', [500, 100], dtype=data_type())
                fc4_biases = tf.get_variable('bias4', [100], dtype=data_type())
                fc4_linear = tf.nn.xw_plus_b(fc3_relu, fc4_weights, fc4_biases, name='fc4_linear')
                fc4_relu = tf.nn.relu(fc4_linear, name='fc4_relu')

                fc5_weights = tf.get_variable('fc5', [100, self.mot_dim], dtype=data_type())
                fc5_biases = tf.get_variable('bias5', [self.mot_dim], dtype=data_type())
                fc5_linear = tf.nn.xw_plus_b(fc4_relu, fc5_weights, fc5_biases, name='fc5_linear')
                self.last_step_mot = fc5_linear

                outputs.append(fc5_linear)
                mus_ebd_outputs.append(mus_fea)

        outputs = tf.reshape(tf.concat(outputs, 1), [self.batch_size, self.num_steps, self.mot_dim])
        mus_ebd_outputs = tf.reshape(tf.concat(mus_ebd_outputs, 1), [self.batch_size, self.num_steps, self.mus_ebd_dim])

        return outputs, mus_ebd_outputs, mot_state, mus_state

    @staticmethod
    def _mus_conv(inputs, kernel_shape, bias_shape, is_training):
        conv_weights = tf.get_variable('conv', kernel_shape,
                                       initializer=tf.truncated_normal_initializer())
        # tf.summary.histogram("conv weights", conv_weights)
        conv_biases = tf.get_variable('bias', bias_shape,
                                      initializer=tf.zeros_initializer())
        conv = tf.nn.conv2d(inputs,
                            conv_weights,
                            strides=[1, 1, 1, 1],
                            padding='VALID')
        bias = tf.nn.bias_add(conv, conv_biases)
        norm = tf.layers.batch_normalization(bias, axis=3,
                                             training=is_training)

        elu = tf.nn.elu(norm)
        return elu

    def _build_mus_conv_graph(self, inputs, config, is_training):
        """Build music graph"""

        print("mus_conv_graph")
        mus_dim = config.mus_dim
        mus_input = tf.reshape(inputs, [-1, mus_dim, 5, 1])

        with tf.variable_scope('conv1'):
            elu1 = self._mus_conv(mus_input,
                                  kernel_shape=[mus_dim, 2, 1, 64],
                                  bias_shape=[64],
                                  is_training=is_training)
        with tf.variable_scope('conv2'):
            elu2 = self._mus_conv(elu1,
                                  kernel_shape=[1, 2, 64, 128],
                                  bias_shape=[128],
                                  is_training=is_training)

        with tf.variable_scope('conv3'):
            elu3 = self._mus_conv(elu2,
                                  kernel_shape=[1, 2, 128, 256],
                                  bias_shape=[256],
                                  is_training=is_training)

        with tf.variable_scope('conv4'):
            elu4 = self._mus_conv(elu3,
                                  kernel_shape=[1, 2, 256, 512],
                                  bias_shape=[512],
                                  is_training=is_training)
            mus_conv_output = tf.reshape(elu4, [-1, 512])
        return mus_conv_output
