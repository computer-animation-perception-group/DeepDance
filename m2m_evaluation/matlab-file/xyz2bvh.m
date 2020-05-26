% function xyz2bvh(skel, channels)
% Incorrect
clear;
load('cmu_exp_skel.mat');
src_path = 'F:/CAPG/mm_lzj/code/retarget_bvh/cmu/retarget/120hz/xyz/01_02.csv';
des_path = 'F:/CAPG/mm_lzj/code/retarget_bvh/cmu/test_res/xyz2bvh/test_1.bvh';

if ~exist(fileparts(des_path), 'dir')
    mkdir(fileparts(des_path));
end

xyz_mat = dlmread(src_path);
skel = exp_skel;
% for i = 1 : length(skel.tree)
%     skel.tree(i).channels = {'Xposition', 'Yposition', 'Zposition'};
%     skel.tree(i).rotInd = [];
%     skel.tree(i).posInd = [(i-1)*3+1, (i-1)*3+2, (i-1)*3+3];
% end
%% 
bvh_data = zeros(size(xyz_mat, 1), 60);
fprintf('Converting to euler...\n');
for i = 1: size(xyz_mat, 1)   
    bvh_data(i, :) = xyz2euler(skel, xyz_mat(i, :));
end
fprintf('Converting success, Writing...\n');
%% 
bvhWriteFile(des_path, skel, bvh_data, 1/120);
fprintf('Writing success, Playing...\n');
%% 
bvh_buffer = bvh_data;
% bvh_buffer = bvh_data(1293, :);
% bvh_buffer(:, 4:12) = [0, 0, 180, 0, 0, 0, 30.3822854545896,38.0166559114061,9.68409549846094];
bvhPlayData(skel, bvh_buffer, 1/120);


