
function euler = xyz2euler(skel, channels)
% Incorrect for joint which beyond [-180, 180]
euler = [];
for i = 1:length(skel.tree)  
  xpos = channels((i-1) * 3 + 1);
  ypos = channels((i-1) * 3 + 2);
  zpos = channels((i-1) * 3 + 3);
  xyzStruct(i) = struct('rotation', []); 
  % 'Site', not store info
  if isempty(skel.tree(i).children)
      continue;
  end
  if ~skel.tree(i).parent
      euler = [euler, xpos, ypos, zpos];
  end
  
  childIdx = skel.tree(i).children(1);
  if length(skel.tree(i).children) > 1
      childIdx = skel.tree(i).children(2);
%       xyzStruct(i).rotation = [1, 0, 0, 0];
%       deg = [0, 0, 0];
%       euler = [euler, deg];
%       continue;
  end
  thisPos= channels((i-1) * 3 + 1: (i-1) * 3 + 3);
  childPos =channels((childIdx-1) * 3 + 1 : (childIdx-1) * 3 + 3);
  childOffset = skel.tree(childIdx).offset;
  thisRotation = vec2quat(childOffset, childPos - thisPos);
%   if strcmp('LowerBack', skel.tree(i).name)
%       thisRotation = [0, 0, 1, 0];
%   end
  % fprintf('name: %s, euler:%f %f %f %f\n', skel.tree(i).name, thisRotation);
  xyzStruct(i).rotation = thisRotation;
  if skel.tree(i).parent
      thisRotation = quatdivide(thisRotation, xyzStruct(skel.tree(i).parent).rotation);
  end
  [e1, e2, e3] = quat2angle(thisRotation, skel.tree(i).order);
  deg = rad2deg([e1, e2, e3]);
  % fprintf('name: %s, euler:%f %f %f\n', skel.tree(i).name, deg);
  euler = [euler, deg];
end


