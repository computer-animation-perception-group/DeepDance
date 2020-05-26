function y = negLogLogit(x)

% NEGLOGLOGIT Function which returns the negative log of the logistic function.
%
%	Description:
%
%	Y = NEGLOGLOGIT(X) computes the negative log of the logistic
%	(sigmoid) function, which is also the integral of the sigmoid
%	function.
%	 Returns:
%	  Y - the negative log of the logistic.
%	 Arguments:
%	  X - input locations.
%	
%
%	See also
%	SIGMOID


%	Copyright (c) 2006 Neil D. Lawrence
% 	negLogLogit.m CVS version 1.1
% 	negLogLogit.m SVN version 22
% 	last update 2007-11-03T14:25:20.000000Z

y = log(1+exp(x));