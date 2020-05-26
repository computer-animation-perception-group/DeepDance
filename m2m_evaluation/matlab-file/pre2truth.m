feature_type = 'dk';

if strcmp(feature_type, 'cmu')
    ignore_dim_path = 'F:\CAPG\mm_lzj\code\motion_generation\log\capg-50\2017-12-15-18-10-03\save\ignore_dim.csv';
    data_mean_path =  'F:\CAPG\mm_lzj\code\motion_generation\log\capg-50\2017-12-15-18-10-03\save\data_mean.csv';
    data_std_path = 'F:\CAPG\mm_lzj\code\motion_generation\log\capg-50\2017-12-15-18-10-03\save\data_std.csv';
    load('cmu_retarget_skel.mat');
elseif strcmp(feature_type, 'dk')
    ignore_dim_path = 'F:\CAPG\mm_lzj\code\motion_generation\log\capg-50\2018-01-08-22-34-20\save\ignore_dim.csv';
    data_mean_path =  'F:\CAPG\mm_lzj\code\motion_generation\log\capg-50\2018-01-08-22-34-20\save\data_mean.csv';
    data_std_path = 'F:\CAPG\mm_lzj\code\motion_generation\log\capg-50\2018-01-08-22-34-20\save\data_std.csv';
    load('cmu_retarget_skel.mat');
elseif strcmp(feature_type, 'h36m')
    ignore_dim_path = 'F:\CAPG\mm_lzj\code\motion_generation\log\capg-50\2017-12-29-21-05-55\save\ignore_dim.csv';
    data_mean_path =  'F:\CAPG\mm_lzj\code\motion_generation\log\capg-50\2017-12-29-21-05-55\save\data_mean.csv';
    data_std_path = 'F:\CAPG\mm_lzj\code\motion_generation\log\capg-50\2017-12-29-21-05-55\save\data_std.csv';
    load('h36m_skel.mat');
end  


net_data_dir = 'F:\CAPG\mm_lzj\code\motion_generation\log\capg-50\';
time_str = '2018-01-08-22-29-45\';
fore_len = 0;
frame_rate = 1/10;
epoch_str = '139\';
file_name = '3.csv';
net_data_path = [net_data_dir, time_str, 'forecast\' ,epoch_str, file_name];
% net_data_path = 'F:\CAPG\mm_lzj\code\motion_generation\srnn\log\2017-12-27-15-48-26\check\y\3.csv';
true_data_path = [net_data_dir, time_str, 'save\true-y\', file_name];
% net_data_path = true_data_path
res_dir = [net_data_dir, 'bvh\'];
res_dir = 'C:\Users\JohnsonLai\Desktop\01_15\srnn\';
res_path = [res_dir, time_str(1:end-1), '_', file_name];
if strfind(net_data_path, 'true-y')
    res_path = [res_dir, time_str(1:end-1), '_', 'true_' file_name];
end
if ~exist(res_dir, 'dir')
    mkdir(res_dir)
end
data_mean = dlmread(data_mean_path);
data_std = dlmread(data_std_path);
ignore_dim = dlmread(ignore_dim_path);
data_mean = data_mean';
data_std = data_std';
ignore_dim = ignore_dim';

fea_dim = size(data_mean, 2);
net_data = dlmread(net_data_path);
if strcmp(feature_type, 'h36m')
    cor_data = zeros(size(net_data, 1), 54);
    cor_data(:, 1:6) = net_data(:, 1:6);
    cor_data(:, 7:14) = net_data(:, 47:54);
    cor_data(:, 15:22) = net_data(:, 39:46);
    cor_data(:, 23:34) = net_data(:, 7:18);
    cor_data(:, 35:44) = net_data(:, 19:28);
    cor_data(:, 45:54) = net_data(:, 29:38);
net_data = cor_data;
end

data_len = size(net_data, 1);
norm_data = zeros(data_len, fea_dim);
data_mean = repmat(data_mean, data_len, 1);
data_std = repmat(data_std, data_len, 1);
count = 1;
for i = 1 : fea_dim
    if sum(ismember(ignore_dim, i-1)) <= 0   
        if strfind(net_data_path, 'true-y')
            norm_data(:, i) = net_data(:, i);
        else
            norm_data(:, i) = net_data(:, count);
        end
        % disp(count);
        count = count+1;
    end
end

% unnormalize data
unnorm_data = norm_data .* data_std + data_mean;
if fore_len > 0 && isempty(strfind(net_data_path, 'true-y'))
    unnorm_data = unnorm_data(end-fore_len+1:end, :);
end
% unnorm_data = unnorm_data(1:20, :);
exp2bvh(skel, unnorm_data, frame_rate, res_path);
