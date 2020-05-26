function [v, signs] = lnDiffErfs(x1, x2),

% LNDIFFERFS Helper function for computing the log of difference
%
%	Description:
%	of two erfs.
%
%	[V, S] = LNDIFFERFS(X1, X2) computes the log of the difference of
%	two erfs in a numerically stable manner.
%	 Returns:
%	  V - log(abs(erf(x1) - erf(x2)))
%	  S - sign(erf(x1) - erf(x2))
%	 Arguments:
%	  X1 - argument of the positive erf
%	  X2 - argument of the negative erf
%
%	V = LNDIFFERFS(X1, X2) computes the log of the difference of two
%	erfs in a numerically stable manner.
%	 Returns:
%	  V - log(erf(x1) - erf(x2))     (Can be complex)
%	 Arguments:
%	  X1 - argument of the positive erf
%	  X2 - argument of the negative erf
%	
%
%	See also
%	GRADLNDIFFERFS


%	Copyright (c) 2007, 2008 Antti Honkela
% 	lnDiffErfs.m CVS version 1.1
% 	lnDiffErfs.m SVN version 336
% 	last update 2009-04-22T21:30:32.000000Z

x1 = real(x1);
x2 = real(x2);

v = zeros(max(size(x1), size(x2)));

if numel(x1) == 1,
  x1 = x1 * ones(size(x2));
end

if numel(x2) == 1,
  x2 = x2 * ones(size(x1));
end

signs = sign(x1 - x2);
I = signs == -1;
swap = x1(I);
x1(I) = x2(I);
x2(I) = swap;

% Case 1: arguments of different signs, no problems with loss of accuracy
I1 = sign(x1) ~= sign(x2);
% Case 2: both arguments are positive
I2 = (x1 > 0) & (x1 > x2) & ~I1;
% Case 3: both arguments are negative
I3 = ~I1 & ~I2;

warnState = warning('query', 'MATLAB:log:logOfZero');
warning('off', 'MATLAB:log:logOfZero');
v(I1) = log( erf(x1(I1)) - erf(x2(I1)) );
v(I2) = log(erfcx(  x2(I2)) ...
	    - erfcx(x1(I2)) .* exp(x2(I2).^2 - x1(I2).^2)) ...
	- x2(I2).^2;
v(I3) = log(erfcx(  -x1(I3)) ...
	    - erfcx(-x2(I3)) .* exp(x1(I3).^2 - x2(I3).^2)) ...
	- x1(I3).^2;
warning(warnState.state, 'MATLAB:log:logOfZero');

if nargout < 2,
  v(I) = v(I) + pi*1i;
end
