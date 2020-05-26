function exp2bvh(skel, exp_chls, frame_rate, des_path)

% src_path = 'F:/CAPG/mm_lzj/code/retarget_bvh/cmu/retarget/exp_data/03_01.csv';
% des_path = 'F:/CAPG/mm_lzj/code/retarget_bvh/cmu/test_res/exp2bvh/test.bvh';

R0 = [1,0,0;0,1,0;0,0,1];
T0 = [0, 0, 0];

% exp_chls = dlmread(src_path);
% exp_chls = exp_chls(1:end, 6:end);
%%% sunguofei 2019-5 fix root rotation
exp_chls(:,4) = 0;
exp_chls(:,6) = 0;
%exp_chls(:,1:3) = exp_chls(:,1:3)/2.0;
exp_chls(:,1:3) = 0;
rec_chls = revertCoordinateSpace(exp_chls, R0, T0);
% rec_chls = exp_chls;
bvh_mat = zeros(size(rec_chls, 1), ...
    size(exp2euler(skel, rec_chls(1, :)), 2));
% fprintf('%s, converting to bvh...\n', src_path);

for i = 1 : size(rec_chls)
    bvh_mat(i, :) = exp2euler(skel, rec_chls(i, :));
end
% bvh_mat(:, 4) = 0;
% bvh_mat(:, 5) = 0;
%bvh_mat(:, 1:3) = bvh_mat(:, 1:3)/2.0;
%bvh_mat(:, 1:6) = 0;
% y = bvh_mat(:,6);
% [len,~] = size(y);
% for i = 3:len
%     if y(i)-y(i-1)>=180
%         y(i:len)=y(i:len)-360;
%     else
%         if y(i)-y(i-1)<=-180
%             y(i:len)=y(i:len)+360;
%         end
%     end
% end
% figure
% plot(y);
% hold on
% figure

if nargin == 4
    skelPlayData(skel, bvh_mat, frame_rate, des_path);
else
    skelPlayData(skel, bvh_mat, frame_rate);
end

% if nargin == 2
%     frame_rate = 1.0/30;
%     skelPlayData(skel, bvh_mat, frame_rate);
% elseif nargin == 3
%     skelPlayData(skel, bvh_mat, frame_rate);
% elseif nargin == 4
%     bvh_root = skelPlayData(skel, bvh_mat, 0.03);
%     bvh_mat(:,2) = bvh_root;
%     fprintf('Saving:%s\n', des_path);
%     bvhWriteFile(des_path, skel, bvh_mat, 1.0/30);
%     fprintf('Success!\n');
%     % fprintf('Playing...\n');
%     bvhPlayFile(des_path);
% end

