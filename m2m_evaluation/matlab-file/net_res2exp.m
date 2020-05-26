ignore_dim_path = 'F:\CAPG\mm_lzj\code\motion_generation\log\capg-50\2017-12-15-18-10-03\save\ignore_dim.csv';
data_mean_path =  'F:\CAPG\mm_lzj\code\motion_generation\log\capg-50\2017-12-15-18-10-03\save\data_mean.csv';
data_std_path = 'F:\CAPG\mm_lzj\code\motion_generation\log\capg-50\2017-12-15-18-10-03\save\data_std.csv';

% ignore_dim_path = 'F:\CAPG\mm_lzj\code\motion_generation\srnn\log\2017-12-27-15-48-26\save\ignore_dim.csv';
% data_mean_path =  'F:\CAPG\mm_lzj\code\motion_generation\srnn\log\2017-12-27-15-48-26\save\data_mean.csv';
% data_std_path = 'F:\CAPG\mm_lzj\code\motion_generation\srnn\log\2017-12-27-15-48-26\save\data_std.csv';

net_data_dir = 'F:\CAPG\mm_lzj\code\motion_generation\log\capg-50\';
time_str = '2018-01-08-22-35-21\';
fore_len = 0;
% 2017-12-31-20-53-50 % 10-1
% 2017-12-31-20-54-37 % 10-3
% 2017-12-31-20-56-07 % 10-5
% 2017-12-29-23-25-43 % 20-10

% 2017-12-26-21-44-44
epoch_str = '199\';
file_name = '2.csv';
net_data_path = [net_data_dir, time_str, 'forecast\' ,epoch_str, file_name];
% net_data_path = 'F:\CAPG\mm_lzj\code\motion_generation\srnn\log\2017-12-27-15-48-26\check\y\200.csv';
net_data_path = [net_data_dir, time_str, 'save\true-y\', file_name];
res_dir = [net_data_dir, time_str, 'exp\', epoch_str];
res_path = [res_dir, file_name];
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
data_len = size(net_data, 1);
norm_data = zeros(data_len, fea_dim);

data_mean = repmat(data_mean, data_len, 1);
data_std = repmat(data_std, data_len, 1);
count = 1;
for i = 1 : fea_dim
    if sum(ismember(ignore_dim, i-1)) <= 0
        if strfind(net_data_path, 'forecast')
            norm_data(:, i) = net_data(:, count);
        elseif strfind(net_data_path, 'true-y')
            norm_data(:, i) = net_data(:, i);
        end
        % disp(count);
        count = count+1;
    end
end

% unnormalize data
unnorm_data = norm_data .* data_std + data_mean;
if fore_len > 0 && strfind(net_data_path, 'true-y') == 0
    unnorm_data = unnorm_data(end-fore_len+1:end, :);
end
dlmwrite(res_path, unnorm_data, 'delimiter', ',', 'newline', 'unix', 'precision', '%4.7f');
cmu_exp2bvh(res_path, 1/2);


