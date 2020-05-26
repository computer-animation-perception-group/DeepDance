model_path=./training_results/models/gudianwu/cnn-erd_14_model.ckpt.meta
CUDA_VISIBLE_DEVICES=0 \
python3 generate_dance.py \
     --rnn_keep_list 0.95 0.9 1.0\
     --kernel_size 1 3 \
     --stride 1 2\
     --act_type lrelu \
     --seg_len 90 \
     --seq_shift 1 \
     --gen_hop 90 \
     --model_path ${model_path%.*} \
     --mot_scale 100. \
     --norm_way zscore \
     --mus_ebd_dim 72 \
     --has_random_seed False \
     --add_info ./training_results/motions/