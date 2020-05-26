base_dir = 'F:\CAPG\mm_lzj\code\motion_generation\log\capg-50\';
time_dir = '2018-01-09-18-58-29\';
train_loss_path = [base_dir, time_dir, 'save\train_loss.txt'];
validate_loss_path = [base_dir, time_dir, 'save\validate_loss.txt'];
test_loss_path = [base_dir, time_dir, 'save\test_loss.txt'];

train_loss = read_json(train_loss_path);
val_loss = read_json(validate_loss_path);
test_loss = read_json(test_loss_path);
train_x = 1 : length(train_loss); 
val_x = 1 : length(train_loss);
test_x = 1: 1: length(train_loss);
test_loss = test_loss(test_x);

plot(train_x, train_loss, '-r', val_x, val_loss, '-g', test_x, test_loss, '-b');
xlabel('Epoch');
ylabel('Loss');
legend('train-loss','validate-loss', 'forecast-loss');
ylim([0, 0.5]);

%% 
plot( test_x, test_loss, '-b');
xlabel('Epoch');
ylabel('Loss');
legend('forecast-loss');