% h3.6m
% h36m_path = 'F:/CAPG/mm_lzj/dataset/h3.6m/original_h36m/Training_Data/Subject_S1/S1/MyPoseFeatures/D3_Angles/Directions 1.cdf';
% load('h36m_skel.mat');
% src_chls = cell2mat(cdfread(h36m_path));
% [channels_in_local_coordinates,exp_skel,R0,T0] = changeCoordinateSpace(skel, src_chls);

%% cmu
% src_path =  'F:/CAPG/mm_lzj/code/retarget_bvh/cmu/retarget/move_hip/01_01.bvh';
% R0 = [1,0,0;0,1,0;0,0,1];
% T0 = bvh(1, 1:3);
% [src_skel, src_chls, src_len] = bvhReadFile(src_path);
% [channels_in_local_coordinates,exp_skel,R0,T0] = changeCoordinateSpace(src_skel, src_chls);

%% 
clear;
src_dir = 'F:/CAPG/mm_lzj/code/retarget_bvh/cmu/retarget/move_hip/';
res_dir = 'F:/CAPG/mm_lzj/code/retarget_bvh/cmu/retarget/exp_data/';
list_bvh = dir([src_dir, '/*.bvh']);

if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

for i = 1 : length(list_bvh)
    src_path = [src_dir, list_bvh(i).name];
    [~, fname, ext] = fileparts(src_path);     
    res_path = [res_dir, fname, '.csv'];
    fprintf('Loading %d/%d bvh: %s\n', i, length(list_bvh), src_path);
    [src_skel, src_chls, src_len] = bvhReadFile(src_path);
    src_skel.tree(1).offset = [0, 0, 0];
    fprintf('Loading done.\n');
    bvh_len = size(src_chls, 1);
    joint_num = length(src_skel.tree);
    fprintf('data size:(%d %d). Converting bvh to exponential map...\n', bvh_len, length(src_skel.tree)*3 + 3);
    [exp_chls,exp_skel,R0,T0] = changeCoordinateSpace(src_skel, src_chls);
    dlmwrite(res_path, exp_chls, 'delimiter', ',', 'newline', 'unix', 'precision', '%4.7f');
    fprintf('Success, save:%s\n\n', res_path);
end
