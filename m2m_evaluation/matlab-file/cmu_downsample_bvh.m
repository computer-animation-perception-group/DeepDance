clear;
src_dir = 'F:/CAPG/mm_lzj/code/retarget_bvh/cmu/retarget/capg_header/';
bvh_res_dir = 'F:/CAPG/mm_lzj/code/retarget_bvh/cmu/retarget/30hz/bvh/';
exp_res_dir = 'F:/CAPG/mm_lzj/code/retarget_bvh/cmu/retarget/30hz/exp/';
list_bvh = dir([src_dir, '/*.bvh']);

if ~exist(bvh_res_dir, 'dir')
    mkdir(bvh_res_dir);
end

if ~exist(exp_res_dir, 'dir')
    mkdir(exp_res_dir);
end

for i = 1 : length(list_bvh)
    src_path = [src_dir, list_bvh(i).name];
    [~, fname, ext] = fileparts(src_path);     
    exp_res_path = [exp_res_dir, fname, '.csv'];
    bvh_res_path = [bvh_res_dir, fname, '.bvh'];
    fprintf('Loading %d/%d bvh: %s\n', i, length(list_bvh), src_path);
    [src_skel, src_chls, src_len] = bvhReadFile(src_path);
    
    src_chls = src_chls( 1:4:end, :);
    bvhWriteFile(bvh_res_path, src_skel, src_chls, 1/30);
    fprintf('---Bvh save:%s\n\n', bvh_res_path);
    
    src_skel.tree(1).offset = [0, 0, 0];
    fprintf('Loading done.\n');
    bvh_len = size(src_chls, 1);
    joint_num = length(src_skel.tree);
    fprintf('data size:(%d %d). Converting bvh to exponential map...\n', bvh_len, length(src_skel.tree)*3 + 3);
    [exp_chls,exp_skel,R0,T0] = changeCoordinateSpace(src_skel, src_chls);
    dlmwrite(exp_res_path, exp_chls, 'delimiter', ',', 'newline', 'unix', 'precision', '%4.7f');
    fprintf('---Success, exp save:%s\n\n', exp_res_path);
end