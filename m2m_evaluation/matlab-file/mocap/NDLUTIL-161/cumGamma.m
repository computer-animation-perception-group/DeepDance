function y = cumGamma(x, a, b)

% CUMGAMMA Cumulative distribution for gamma.
%
%	Description:
%
%	P = CUMGAMMA(X) computes the cumulative gamma distribution.
%	 Returns:
%	  P - output probability.
%	 Arguments:
%	  X - input value.
%	
%
%	See also
%	GAMMAINC, GAMMA


%	Copyright (c) 2008 Neil D. Lawrence
% 	cumGamma.m SVN version 22
% 	last update 2008-06-27T13:16:15.000000Z

y = gammainc(x*b, a);
