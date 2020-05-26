function t = traceProduct(A, B)

% TRACEPRODUCT Returns the trace of the product of two matrices.
%
%	Description:
%
%	T = TRACEPRODUCT(A, B) returns the trace of the product of two
%	matrices, tr(A*B).
%	 Returns:
%	  T - the trace of the product.
%	 Arguments:
%	  A - the first matrix in the product.
%	  B - the second matrix in the product.
%	
%
%	See also
%	TRACE


%	Copyright (c) 2004 Neil D. Lawrence
% 	traceProduct.m CVS version 1.2
% 	traceProduct.m SVN version 22
% 	last update 2007-11-03T14:26:10.000000Z

t = sum(sum(A.*B'));