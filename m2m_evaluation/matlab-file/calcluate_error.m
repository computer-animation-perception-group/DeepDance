ignore_dim_path = 'F:\CAPG\mm_lzj\code\motion_generation\log\capg-50\2017-12-15-18-10-03\save\ignore_dim.csv';
data_mean_path =  'F:\CAPG\mm_lzj\code\motion_generation\log\capg-50\2017-12-15-18-10-03\save\data_mean.csv';
data_std_path = 'F:\CAPG\mm_lzj\code\motion_generation\log\capg-50\2017-12-15-18-10-03\save\data_std.csv';

true_y_dir = 'F:\CAPG\mm_lzj\code\motion_generation\log\capg-50\2017-12-20-10-07-36\save\true-y\';
forecast_dir = 'F:\CAPG\mm_lzj\code\motion_generation\log\capg-50\2017-12-21-15-09-26\forecast\';

list_epoch = dir(forecast_dir);
list_epoch = list_epoch(~ismember({list_epoch.name}, {'.', '..'}));
ignore_dim = dlmread(ignore_dim_path);
ignore_dim = ignore_dim + 1;
use_dim = 1:75;
use_dim = use_dim(~ismember(use_dim, ignore_dim));

epoch_error = [];
for i = 1 : length(list_epoch)
    epoch_dir = [forecast_dir, list_epoch(i).name, '\'];
    list_csv = dir([epoch_dir, '*.csv']);
    error = 0;
    for j = 1 : length(list_csv)
        csv_name = list_csv(j).name;
        fprintf('epoch: %d / %d csv_name: %s\n', i, length(list_epoch), csv_name);
        true_data = dlmread([true_y_dir, csv_name]);
        true_data = true_data(:, use_dim);
        true_len = size(true_data, 1);
        forecast_data = dlmread([epoch_dir, csv_name]);
        forecast_data = forecast_data(end-true_len+1:end, :);
        error = power(true_data - forecast_data, 2);
        error = mean(mean(error));
    end
    epoch_error = [epoch_error, error];
end
