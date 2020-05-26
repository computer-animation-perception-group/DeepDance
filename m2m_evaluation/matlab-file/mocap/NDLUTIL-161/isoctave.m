function answer = isoctave

% ISOCTAVE Returns true if the software running is Octave.
%
%	Description:
%
%	ANSWER = ISOCTAVE tests if the software is octave or not.
%	 Returns:
%	  ANSWER - true if the software is octave.


%	Copyright (c) 2008 Neil D. Lawrence
% 	isoctave.m SVN version 22
% 	last update 2008-05-11T07:08:04.000000Z
  
try 
  v = OCTAVE_VERSION;
  answer = true;
catch
  answer = false;
  return
end