function [columnNames, data] = tableRead(fileName, separator)

% TABLEREAD Read in data which has column titles in the first line and separated values in each other line.
%
%	Description:
%
%	[COLUMNNAMES, DATA] = TABLEREAD(FILENAME, SEPARATOR) reads in data
%	from a file that has column titles in the first line and separated
%	values in every other line.
%	 Returns:
%	  COLUMNNAMES - the names of the columns taken from the first line.
%	  DATA - the data, taken from the remaining lines.
%	 Arguments:
%	  FILENAME - file name in which the data is stored.
%	  SEPARATOR - separator between the columns (default ',').
%	
%
%	See also
%	FOPEN, FGETL


%	Copyright (c) 2004 Neil D. Lawrence
% 	tableRead.m CVS version 1.2
% 	tableRead.m SVN version 22
% 	last update 2007-11-03T14:26:16.000000Z

if nargin < 2
  separator = ',';
end

fid = fopen(fileName);
i = 0;
while 1
  i = i + 1;
  lin=fgetl(fid);
  if ~ischar(lin), break, end
end
numLines = i;

fid = fopen(fileName);
lin = fgetl(fid);
columnNames = stringSplit(lin, separator);
numCol = length(columnNames);
i = 0;
data = zeros(numLines - 1, numCol);
while 1
  i = i+1;
  lin=fgetl(fid);
  if ~ischar(lin), break, end
  split = stringSplit(lin, separator);
  if length(split) ~= numCol
    error(['Error at line ' num2str(i) ' of file ' fileName ': wrong ' ...
                        'number of columns'])
  end
  for j = 1:length(split);
    data(i, j) = num2str(split{j});
  end
end
fclose(fid);