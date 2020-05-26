function y = cumGaussian(x)

% CUMGAUSSIAN Cumulative distribution for Gaussian.
%
%	Description:
%
%	P = CUMGAUSSIAN(X) computes the cumulative Gaussian distribution.
%	 Returns:
%	  P - output probability.
%	 Arguments:
%	  X - input value.
%	
%
%	See also
%	LNCUMGAUSSIAN, LNDIFFCUMGAUSSIAN, ERF


%	Copyright (c) 2004 Neil D. Lawrence
% 	cumGaussian.m CVS version 1.2
% 	cumGaussian.m SVN version 22
% 	last update 2007-11-03T14:25:21.000000Z

y = 0.5*(1+erf(sqrt(2)/2*x));
