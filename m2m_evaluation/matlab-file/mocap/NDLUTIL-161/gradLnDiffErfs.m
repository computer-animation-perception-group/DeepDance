function [dlnPart, m] = gradLnDiffErfs(x1, x2, fact1, fact2),

% GRADLNDIFFERFS Compute the gradient of the log difference of two erfs.
%
%	Description:
%	
%	


%	Copyright (c) 2007 Antti Honkela
% 	gradLnDiffErfs.m CVS version 1.1
% 	gradLnDiffErfs.m SVN version 22
% 	last update 2007-12-18T12:39:23.000000Z

m = min(x1.^2, x2.^2);
dlnPart = 2/sqrt(pi) * (exp(-x1.^2 + m) .* fact1 ...
			- exp(-x2.^2 + m) .* fact2);
