 clear;
src_dir = 'F:\CAPG\mm_lzj\code\retarget_bvh\cmu\retarget\30hz\bvh\';
res_dir = 'F:\CAPG\mm_lzj\code\retarget_bvh\cmu\retarget\30hz\quat\';
list_bvh = dir([src_dir, '/*.bvh']);

if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

for i = 600 : length(list_bvh)
    src_path = [src_dir, list_bvh(i).name];
    [~, fname, ext] = fileparts(src_path);     
    res_path = [res_dir, fname, '.csv'];
    fprintf('Loading %d/%d bvh: %s\n', i, length(list_bvh), src_path);
    [src_skel, src_chls, src_len] = bvhReadFile(src_path);
    src_skel.tree(1).offset = [0, 0, 0];
    fprintf('Loading done.\n');
    quat_chls = bvh2quat(src_chls);
    dlmwrite(res_path, quat_chls, 'delimiter', ',', 'newline', 'unix', 'precision', '%4.7f');
    fprintf('Success, save:%s\n\n', res_path);
end
