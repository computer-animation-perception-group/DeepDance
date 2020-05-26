clear;
src_path = 'F:/CAPG/mm_lzj/code/retarget_bvh/cmu/retarget/xyz_data/13_18.csv';
load('cmu_exp_skel.mat');
xyz_data = dlmread(src_path);
xyzPlayData(exp_skel, xyz_data, 1./120);