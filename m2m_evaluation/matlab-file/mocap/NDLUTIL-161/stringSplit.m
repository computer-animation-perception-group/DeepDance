function parts = stringSplit(string, separator)

% STRINGSPLIT Return separate parts of a string.
%
%	Description:
%
%	PARTS = STRINGSPLIT(STRING, SEPARATOR) return separate parts of a
%	string split by a given separator.
%	 Returns:
%	  PARTS - cell array of the string split into parts.
%	 Arguments:
%	  STRING - the string to be split into parts.
%	  SEPARATOR - the character used to split the string (default, ',').
%	
%
%	See also
%	TOKENISE


%	Copyright (c) 2005 Neil D. Lawrence
% 	stringSplit.m CVS version 1.3
% 	stringSplit.m SVN version 22
% 	last update 2007-11-03T14:25:20.000000Z

if nargin < 2
  separator = ',';
end

parts = tokenise(string, separator);