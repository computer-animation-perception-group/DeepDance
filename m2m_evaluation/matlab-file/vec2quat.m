function q = vec2quat(u, v)
% from u to v
% reference: 
% 1. https://stackoverflow.com/questions/1171849/...
% finding-quaternion-representing-the-rotation-from-one-vector-to-another
% 2. http://lolengine.net/blog/2014/02/24/quaternion-from-two-vectors-final

k_cos = dot(u, v);
k = sqrt(norm(u)^2 * norm(v)^2) ;
if k_cos / k < -0.99
    xyz = 0;
    if abs(u(1)) > abs(u(3))
        w = [-u(2), u(1), 0];
    else
        w = [0, -u(3), u(2)];
    end
elseif k_cos / k > 0.99
    xyz = 1;
    w = [0, 0, 0];
else
    xyz = k_cos + k;
    w = cross(u, v);
end
q = [xyz, w];
q = quatnormalize(q);