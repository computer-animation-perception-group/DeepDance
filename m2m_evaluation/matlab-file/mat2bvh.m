function mat2bvh(mot_mat, header_path, des_path, frameRate)
% Write motion data to bvh file
if nargin < 4
  frameRate = 1/60;
end
des_dir = fileparts(des_path);
if ~exist(des_dir, 'dir')
    mkdir(des_dir);
end

if exist(des_path, 'file')
    delete(des_path);
end

mot_len = size(mot_mat, 1);
sh_id = fopen(header_path);
dh_id = fopen(des_path, 'w+');
header_rows = numel(textread(header_path,'%1c%*[^\n]'));
for i = 1 : header_rows
    hline = fgetl(sh_id);
    fprintf(dh_id, '%s\n', hline);
end
fprintf(dh_id, '%s\n', ['Frames: ', num2str(mot_len)]);
fprintf(dh_id, '%s%.6f\n', 'Frame Time: ', frameRate);
fclose(sh_id);
fclose(dh_id);

dlmwrite(des_path, mot_mat, '-append', 'delimiter', ' ', 'newline', 'unix', 'precision', '%.6f');
