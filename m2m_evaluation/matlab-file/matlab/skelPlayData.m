function bvh_root = skelPlayData(skelStruct, channels, frameLength, videoname)

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
  frameLength = 1/120;
end
clf

handle = skelVisualise(channels(1, :), skelStruct);


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
bvh_root = zeros(size(channels, 1), 1);
for i = 1:size(channels, 1)
  Y = skel2xyz(skelStruct, channels(i, :));
  minY1 = min([Y(:, 1); minY1]);
  minY2 = min([Y(:, 2); minY2]);
  minY3 = min([Y(:, 3); minY3]);
  maxY1 = max([Y(:, 1); maxY1]);
  maxY2 = max([Y(:, 2); maxY2]);
  maxY3 = max([Y(:, 3); maxY3]);
  % sunguofei 2019-8-5 fix min height in bvh
  min_height = min(Y(:, 2));
  bvh_root(i, 1) = Y(1,2) - min_height;
  %%%%%%%%%%%%%%%%
  % sunguofei 2019-5-23 fix lim to (-50, 450)
  minY2 = -150; maxY2 = 450;
  minY1 = -400; maxY1 = 400;
  minY3 = -400; maxY3 = 400;
  %%%%%%%%%%%%%%%%
end
xlim = [minY1 maxY1];
ylim = [minY3 maxY3];
zlim = [minY2 maxY2];
set(gca, 'xlim', xlim, ...
         'ylim', ylim, ...
         'zlim', zlim);
set(gcf, 'Position', [50, 50, 1200, 900]);
%set(gcf, 'Position', [50, 50, 800, 600]);
set(gcf,'color','white');
%%%%%%%%%%%%%
% sunguofei 2019.6.24 remove figure lines
set(gca, 'Visible', 'off');
% sunguofei 2019.5.24 set figure view
view(0, 0);
% sunguofei 2019.5.24 write to video
% if nargin == 4
%     writeobj = VideoWriter(videoname, 'MPEG-4');
%     writeobj.FrameRate = 30;
%     open(writeobj);
% end
%%%%%%%%%%%%%

%play music
global md
global fs
sound(md, fs);

% Play the motion
for j = 1:size(channels, 1)
  pause(frameLength)
%   if mod(j, 1) == 0
%       save_dir = 'F:\CAPG\mm_lzj\code\network\plot_fig\fig5\';
%       if ~exist(save_dir, 'dir')
%           mkdir(save_dir);
%       end
%       % savefig([save_dir, int2str(j), '.fig']);
%       axis off;
%       grid off;
%       saveas(gcf,[save_dir, int2str(j), '.png']);
%   end
  skelModify(handle, channels(j, :), skelStruct);
  % sunguofei 2019.5.24 write to video
  if nargin == 4
      frame = getframe(gca);
      img = frame.cdata(200:735, 200:932-200, :);
      imwrite(img, [videoname, int2str(j), '.jpg']);
      %writeVideo(writeobj, img);
  end
end
% if nargin == 4
%     close(writeobj);
% end
