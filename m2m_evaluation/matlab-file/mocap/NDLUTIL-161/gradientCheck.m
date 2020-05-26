function gradientCheck(params, objectiveFunction, gradientFunction, varargin)

% GRADIENTCHECK Check gradients of objective function.
%
%	Description:
%
%	GRADIENTCHECK(PARAMS, OBJECTIVEFUNCTION, GRADIENTFUNCTION, ...)
%	checks the supplied gradient function and the supplied objective
%	function to ensure that the numerical gradients (as computed with
%	the objective function) match the analytically computed gradients.
%	 Arguments:
%	  PARAMS - the parameters at which the gradients will be checked.
%	  OBJECTIVEFUNCTION - function handle for the objective function.
%	  GRADIENTFUNCTION - function handle for the objective function.
%	  ... - additional arguments that are passed to the objective and
%	   gradient functions (after the parameter vector which is always
%	   assumed to be the first argument passed).
%	
%
%	See also
%	MODELOBJECTIVE, MODELGRADIENT, MODELCREATE


%	Copyright (c) 2005, 2006 Neil D. Lawrence
% 	gradientCheck.m CVS version 1.3
% 	gradientCheck.m SVN version 22
% 	last update 2007-11-03T14:26:20.000000Z


if isstr(objectiveFunction)
  objectiveFunction = str2func(objectiveFunction);
end
if isstr(gradientFunction)
  gradientFunction = str2func(gradientFunction);
end
L = 0;
change = 1e-6;
origParams = params;
for i = 1:length(params)
  params(i) = origParams(i) + change;
  Lplus = objectiveFunction(params, varargin{:});
  params(i) = origParams(i) - change;
  Lminus = objectiveFunction(params, varargin{:});
  diff(i) = (Lplus - Lminus)/(2*change);
  params(i) = origParams(i);
end

anal = gradientFunction(origParams, varargin{:});

delta = anal -diff;
if max(abs(delta./max([abs(anal) ones(size(anal))], [], 2)))<1e-4
  fprintf('Gradient Check Passed.\n');
else
  fprintf('Gradient Check Failed.\n');
  fprintf('       \t\t\tAnaly\t\t\tDiffs\t\t\tDelta\n', i, anal(i), diff(i), delta(i));

  for i = 1:length(params)
    if(abs(delta(i)/max([abs(anal(i)) 1]))>=1e-4)
      fprintf('Param %d:\t\t%6.4e\t\t%6.4e\t\t%6.4e\n', i, anal(i), diff(i), delta(i));
    end
  end
end