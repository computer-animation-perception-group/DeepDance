% convert cmu bvh data to xyz data.
clc;
src_dir = 'F:/CAPG/mm_lzj/code/retarget_bvh/cmu/retarget/120hz/bvh/';
res_dir = 'F:/CAPG/mm_lzj/code/retarget_bvh/cmu/retarget/120hz/xyz/';
list_bvh = dir([src_dir, '/*.bvh']);

if ~exist(res_dir, 'dir')
    mkdir(res_dir);
end

for i = 1 : 2
    src_path = [src_dir, list_bvh(i).name];
    [~, fname, ext] = fileparts(src_path);     
    res_path = [res_dir, fname, '.csv'];
    fprintf('Loading %d/%d bvh: %s\n', i, length(list_bvh), src_path);
    [src_skel, src_chls, src_len] = bvhReadFile(src_path);
    src_skel.tree(1).offset = [0, 0, 0];
    fprintf('Loading done.\n');
    bvh_len = size(src_chls, 1);
    joint_num = length(src_skel.tree);
    xyz_data = zeros(bvh_len, joint_num * 3);
    fprintf('xyz data size:(%d %d). Converting bvh to xyz...\n', bvh_len, length(src_skel.tree)*3);
    for j = 1 : bvh_len
        xyz = bvh2xyz(src_skel, src_chls(j, :));
        xyz = reshape(xyz', 1, joint_num * 3);
        xyz_data(j, :) = xyz;
    end
    dlmwrite(res_path, xyz_data, 'delimiter', ',', 'newline', 'unix', 'precision', '%.9f');
    fprintf('Success, save:%s\n\n', res_path);
end
