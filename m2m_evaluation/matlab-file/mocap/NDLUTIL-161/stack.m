function x = stack(X)

% STACK Return column stacked vector of given matrix.
%
%	Description:
%
%	X = STACK(X) returns a column stacked vector of a given matrix. This
%	is useful if you wish to stack a column vector from a matrix
%	returned by another function (i.e. you can't apply the colon
%	operator directly).
%	 Returns:
%	  X - stacked column vector from the matrix.
%	 Arguments:
%	  X - the matrix to be stacked.
%	
%
%	See also
%	COLON


%	Copyright (c) 2004 Neil D. Lawrence
% 	stack.m CVS version 1.2
% 	stack.m SVN version 22
% 	last update 2007-11-03T14:25:20.000000Z


x = X(:);