% return a vector of eluer degree (in degrees)
function euler = exp2euler(skel, channels)
euler = [];
for j = 1 : length(skel.tree)
    if isempty(skel.tree(j).rotInd) 
        continue;
    end
    if skel.tree(j).posInd
        euler = [euler, channels(skel.tree(j).posInd)];
    end
    exp = channels(skel.tree(j).expmapInd);
    rot = expmap2rotmat(exp);
    [e1, e2, e3] = dcm2angle(rot, skel.tree(j).order);
    eul = [e1, e2, e3];
    % eul = RotMat2Euler(rot);
    eul = rad2deg(eul);
    euler = [euler, eul];
end