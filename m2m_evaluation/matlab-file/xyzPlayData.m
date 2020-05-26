function xyzPlayData(skelStruct, channels, frameRate)

% SKELPLAYDATA Play skel motion capture data.
% FORMAT 
% DESC plays channels from a motion capture skeleton and channels.
% ARG skel : the skeleton for the motion.
% ARG channels : the channels for the motion.
% ARG frameLength : the framelength for the motion.
%
% COPYRIGHT : Neil D. Lawrence, 2006
%
% SEEALSO : bvhPlayData, acclaimPlayData

% MOCAP

if nargin < 3
  frameRate = 1/120;
end
clf

handle = xyzVisualise(channels(1, :), skelStruct);


% Get the limits of the motion.
xlim = get(gca, 'xlim');
minY1 = xlim(1);
maxY1 = xlim(2);
ylim = get(gca, 'ylim');
minY3 = ylim(1);
maxY3 = ylim(2);
zlim = get(gca, 'zlim');
minY2 = zlim(1);
maxY2 = zlim(2);
for i = 1:size(channels, 1)
  Y = channels(i, :);
  W = Y(1 : 3 :size(channels, 2));
  H = Y(2 : 3 :size(channels, 2));
  L = Y(3 : 3 :size(channels, 2));
  minY1 = min([min(W); minY1]);
  minY2 = min([min(H); minY2]);
  minY3 = min([min(L); minY3]);
  maxY1 = max([max(W); maxY1]);
  maxY2 = max([max(H); maxY2]);
  maxY3 = max([max(L); maxY3]);
end
xlim = [minY1 maxY1];
ylim = [minY3 maxY3];
zlim = [minY2 maxY2];
set(gca, 'xlim', xlim, ...
         'ylim', ylim, ...
         'zlim', zlim);


% Play the motion
for j = 1:size(channels, 1)
  pause(frameRate)
  xyzModify(handle, channels(j, :), skelStruct);
end