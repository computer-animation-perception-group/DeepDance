clear;
load('capg_skel.mat');
src_dir = 'F:/CAPG/mm_lzj/code/retarget_bvh/cmu/retarget/move_hip/';
res_dir = 'F:/CAPG/mm_lzj/code/retarget_bvh/cmu/retarget/capg_header/';
list_bvh = dir([src_dir, '/*.bvh']);

if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

for i = 1 : length(list_bvh)
    src_path = [src_dir, list_bvh(i).name];
    [~, fname, ext] = fileparts(src_path);     
    res_path = [res_dir, fname, '.bvh'];
    fprintf('Loading %d/%d bvh: %s\n', i, length(list_bvh), src_path);
    [src_skel, src_chls, src_len] = bvhReadFile(src_path);
    bvhWriteFile(res_path, capg_skel, src_chls, 1/120);
    fprintf('Success, save:%s\n\n', res_path);
end