function y = invCumGaussian(x)

% INVCUMGAUSSIAN Computes inverse of the cumulative Gaussian.
%
%	Description:
%
%	Y = INVCUMGAUSSIAN(X) computes the inverse of the cumulative
%	Gaussian.
%	 Returns:
%	  Y - the inverse of the cumulative Gaussian.
%	 Arguments:
%	  X - value between 0 and 1 to map onto the real line.
%	
%
%	See also
%	CUMGAUSSIAN, ERFINV


%	Copyright (c) 2005 Neil D. Lawrence
% 	invCumGaussian.m CVS version 1.3
% 	invCumGaussian.m SVN version 22
% 	last update 2008-04-01T11:00:23.000000Z

y = erfinv(x*2 - 1)*2/sqrt(2);