% normalize motion using max-min normlization
function res_bvh = quat2bvh(norm_data, is_unnorm)

   blen = size(norm_data, 1);
if is_unnorm == true
    info_path = 'F:/CAPG/mm_lzj/code/motion_feature/stft/info.csv';
 
    info = dlmread(info_path);
    max_fea = info(1, :);
    min_fea = info(2, :);
    max_fea = repmat(max_fea, blen, 1);
    min_fea = repmat(min_fea, blen, 1);
    max_min = (max_fea - min_fea);
    max_min(max_min == 0) = 1e-9;
    unnorm_data = (norm_data + 0.9)/1.8 .* max_min + min_fea;
else
    unnorm_data = norm_data;
end

res_bvh = zeros(blen, 60);
for r = 1 : blen
    bvh_line = unnorm_data(r, :);
    res_bvh(r, 1:3) = bvh_line(1:3);
    col = 4;
    for j = 4 : 4 : 79 
        q = bvh_line(j:j+3);
        [zr, xr, yr] = quat2angle(q, 'ZXY');
        zr = rad2deg(zr);
        xr = rad2deg(xr);
        yr = rad2deg(yr);
        res_bvh(r, col: col+2) = [zr, xr, yr];
        col = col + 3;
    end
end
