function hessianCheck(params, objectiveFunction, hessianFunction, varargin)

% HESSIANCHECK Check Hessian of objective function.
%
%	Description:
%
%	HESSIANCHECK(PARAMS, OBJECTIVEFUNCTION, HESSIANFUNCTION, ...) checks
%	the supplied Hessian function and the supplied objective function to
%	ensure that the numerical Hessian (as computed with the objective
%	function) match the analytically computed Hessian.
%	 Arguments:
%	  PARAMS - the parameters at which the Hessian will be checked.
%	  OBJECTIVEFUNCTION - function handle for the objective function.
%	  HESSIANFUNCTION - function handle for the objective function.
%	  ... - additional arguments that are passed to the objective and
%	   Hessian functions (after the parameter vector which is always
%	   assumed to be the first argument passed).
%	
%
%	See also
%	MODELOBJECTIVE, MODELHESSIAN, MODELCREATE


%	Copyright (c) 2005, 2006 Neil D. Lawrence
% 	hessianCheck.m CVS version 1.1
% 	hessianCheck.m SVN version 22
% 	last update 2007-11-03T14:26:20.000000Z

if isstr(objectiveFunction)
  objectiveFunction = str2func(objectiveFunction);
end
if isstr(hessianFunction)
  hessianFunction = str2func(hessianFunction);
end
L = 0;
change = 1e-4;
origParams = params;
for i = 1:length(params)
  for j = 1:length(params)
    if i == j
      params(i) = origParams(i) - 2*change;
      LminusMinus = objectiveFunction(params, varargin{:});
      params(i) = origParams(i) + 2*change;
      LplusPlus = objectiveFunction(params, varargin{:});
      params(i) = origParams(i);
      Lother = objectiveFunction(params, varargin{:});
      diffH(i, j) = (LminusMinus -2*Lother + LplusPlus)...
              /(4*change*change);
    else
      params(i) = origParams(i) - change;
      params(j) = origParams(j) - change;
      LminusMinus = objectiveFunction(params, varargin{:});
      params(i) = origParams(i) - change;
      params(j) = origParams(j) + change;
      LminusPlus = objectiveFunction(params, varargin{:});
      params(i) = origParams(i) + change;
      params(j) = origParams(j) - change;    
      LplusMinus = objectiveFunction(params, varargin{:});
      params(i) = origParams(i) + change;
      params(j) = origParams(j) + change;    
      LplusPlus = objectiveFunction(params, varargin{:});
      diffH(i, j) = (LminusMinus - LminusPlus - LplusMinus + LplusPlus)...
              /(4*change*change);
    end
    params(i) = origParams(i);
    params(j) = origParams(j);
  end
end

H = hessianFunction(origParams, varargin{:});

delta = H -diffH;
if max(abs(delta./max(max([abs(H) ones(size(H))], [], 2))))<1e-4
  fprintf('Hessian Check Passed.\n');
else
  fprintf('Hessian Check Failed.\n');
  fprintf('       \t\t\tAnaly\t\t\tDiffs\t\t\tDelta\n');
  
  for i = 1:length(params)
    for j = 1:length(params)
      if(abs(delta(i, j)/max([abs(H(i, j)) 1]))>=1e-4)
        fprintf('Param %d, %d:\t\t%6.4e\t\t%6.4e\t\t%6.4e\n', i, j, H(i,j), ...
                diffH(i,j), delta(i, j));
      end
    end
  end
end