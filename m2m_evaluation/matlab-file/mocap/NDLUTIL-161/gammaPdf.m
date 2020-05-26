function [p, lnp] = gammaPdf(x, a, b)

% GAMMAPDF PDF for the Gamma distribution.
%
%	Description:
%
%	[P, LNP] = GAMMAPDF(X, A, B) computes the pdf of the gamma
%	distribution.
%	 Returns:
%	  P - probability of the gamma distribution.
%	  LNP - log of the probability.
%	 Arguments:
%	  X - locations where the PDF is to be computed.
%	  A - shape parameter of the gamma distribution.
%	  B - rate parameter of the gamma distribuion (inverse scale).
%	
%
%	See also
%	% SEEALSO CUMGAMMA


%	Copyright (c) 2008 Neil D. Lawrence
% 	gammaPdf.m SVN version 23
% 	last update 2008-07-11T15:19:45.000000Z


lnp = a*log(b) - gammaln(a) + (a-1)*log(x) - b*x;
p = exp(lnp);