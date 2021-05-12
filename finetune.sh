gpu=3
dis_type='DisSegGraph'
loss_mode='gan'
pre_dir='./output/pretrain/all-f4'
fold_idx=0
seg_len=90
loss_arr=(1.0 0.1 0.1)
mus_ebd_dim=72
dis_name='time_cond_cnn'
kernel_size=(1 3)
stride=(1 2)
cond_axis=1
model_path=$pre_dir/model/cnn-erd_19_model.ckpt.meta
CUDA_VISIBLE_DEVICES=$gpu \
    python3 train_gan.py --learning_rate 1e-4 \
        --dis_learning_rate 2e-5 \
        --mse_rate 1 \
        --dis_rate 0.01 \
        --loss_mode $loss_mode \
        --is_load_model True \
        --is_reg True \
        --reg_scale 5e-5 \
        --rnn_keep_list 0.95 0.9 1.0\
        --dis_type $dis_type \
        --dis_name $dis_name \
        --loss_rate_list ${loss_arr[0]} ${loss_arr[1]} ${loss_arr[2]}\
        --kernel_size ${kernel_size[0]} ${kernel_size[1]} \
        --stride ${stride[0]} ${stride[1]}\
        --act_type lrelu \
        --optimizer Adam \
        --cond_axis $cond_axis \
        --seg_list $seg_len \
        --seq_shift 1 \
        --gen_hop $seg_len \
        --fold_list $fold_idx \
        --type_list gudianwu chaoxianzu daizu weizu cyprus groovenet hiphop salsa \
        --model_path ${model_path%.*} \
        --max_max_epoch 15 \
        --save_data_epoch 5 \
        --save_model_epoch 5 \
        --is_save_train False \
        --mot_scale 100. \
        --norm_way zscore \
        --teacher_forcing_ratio 0. \
        --tf_decay 1. \
        --batch_size 128 \
        --mus_ebd_dim $mus_ebd_dim \
        --has_random_seed False \
        --is_all_norm True \
        --add_info './output/finetune'