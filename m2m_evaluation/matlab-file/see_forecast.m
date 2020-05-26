net_data_dir = 'F:\CAPG\mm_lzj\code\motion_generation\log\capg-50\';
time_str = '2018-01-11-19-37-18\';
fore_len = 0;
frame_rate = 1/30;
epoch_str = '199\';
file_name = '549.csv';
res_dir = 'C:\Users\JohnsonLai\Desktop\01_15\srnn\';
res_path = [res_dir, time_str(1:end-1), '_', file_name];
% 100 300 301
src_path = [net_data_dir, time_str, 'forecast\' ,epoch_str, file_name];
src_path = 'F:\CAPG\mm_lzj\code\music2motion\log\2018-03-03-09-33-40\train\train_predictions_40.csv';
load('cmu_retarget_skel.mat');
exp_chls = dlmread(src_path);
exp_chls = exp_chls(1:500, :);
% if fore_len > 0
%     exp_chls = exp_chls(end-fore_len:end, :);
% end
exp2bvh(skel, exp_chls, frame_rate);