fname = 'gudianwu.csv';
src_path = ['..\training_results\motions\gudianwu\', fname];
load('cmu_retarget_skel.mat');
frame_rate = 0.03;
src_chls = dlmread(src_path);
max_length = 5000;
if size(src_chls, 1) > max_length
    src_chls = src_chls(1:max_length, :);
end
dance_length = min(size(src_chls, 1), max_length);
global md
global fs
[mus, fss] = audioread(['..\dataset\music_feature\librosa\samples\', strrep(fname, '.csv', '.wav')]);
md = mus(1:int32((dance_length/30-1.5)*fss), :);
fs = fss;
exp2bvh(skel, src_chls, frame_rate);