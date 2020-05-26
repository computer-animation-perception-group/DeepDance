% H3.6m/dataParser/playGenerateMotion.m
% getExpmapFromSkeleton(getSkeleton) -> playVideo -> revertCoordinateSpace ->
% expPlayData2 -> expVisualise -> exp2xyz
clear;
R0 = [1,0,0;0,1,0;0,0,1];
T0 = [49.985066666700000,95.302933333300000,-92.372266666700000];
load('cmu_exp_skel.mat');
src_path = 'F:/CAPG/mm_lzj/code/retarget_bvh/cmu/retarget/exp_data/01_01.csv';
exp_chls = dlmread(src_path);
recon = revertCoordinateSpace(exp_chls, R0, T0);
% rec_xzy = exp2xyz(exp_skel, recon(1, :));
% expPlayData(exp_skel, recon);


