function quat_data = bvh2quat(bvh_data)

% quat_data = bvh2quat(bvh_data), for capg skel

bvh_len = size(bvh_data, 1);
quat_data = zeros(bvh_len, 79);
for r = 1 : bvh_len
    bvh_line = bvh_data(r, :);
    quat_data(r, 1:3) = bvh_line(1:3);
    col = 4;
    for j = 4 : 3 : 58
        zr = deg2rad(bvh_line(j));
        xr = deg2rad(bvh_line(j+1));
        yr = deg2rad(bvh_line(j+2));
        q = angle2quat(zr, xr, yr, 'ZXY');
        quat_data(r, col: col+3) = q;
        col = col + 4;
    end
end

end
