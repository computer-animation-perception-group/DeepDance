function H = centeringMatrix(dim)

% CENTERINGMATRIX returns the centering matrix for the given dimensionality.
%
%	Description:
%
%	H = CENTERINGMATRIX(DIM) returns the centering matrix for the given
%	dimensionality.
%	 Returns:
%	  H - the centering matrix for the given dimensionality.
%	 Arguments:
%	  DIM - the dimensionality of the centering matrix.
%	
%
%	See also
%	EYE


%	Copyright (c) 2008 Neil D. Lawrence
% 	centeringMatrix.m CVS version 1.1
% 	centeringMatrix.m SVN version 22
% 	last update 2008-01-10T15:50:21.000000Z

H = -repmat(1./dim, dim, dim) + speye(dim);