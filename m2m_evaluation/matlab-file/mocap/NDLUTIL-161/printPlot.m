function printPlot(fileName, directory, directoryHtml) 

% PRINTPLOT Print a plot to eps and png files.
%
%	Description:
%
%	PRINTPLOT(FILENAME, DIRECTORY, DIRECTORYPNG) prints a plot to the
%	specified file name and directory.
%	 Arguments:
%	  FILENAME - the base name of the file to use.
%	  DIRECTORY - the directory to place the eps files in.
%	  DIRECTORYPNG - the directory to place png the file in.
%	
%
%	See also
%	PREPAREPLOT


%	Copyright (c) 2008 Neil D. Lawrence
% 	printPlot.m SVN version 336
% 	last update 2009-02-27T22:41:37.000000Z
  
if nargin < 2 
  directory = '.';
end
if nargin < 3
  png = false;
else
  png = true;
end
fprintf('Printing eps plot ...\n');
print('-depsc', [directory filesep fileName])
cmap = colormap;
if png
  fprintf('Printing png plot ...\n');
  % make smaller for PNG plot.
  pos = get(gcf, 'paperposition');
  origpos = pos;
  pos(3) = pos(3)/2;
  pos(4) = pos(4)/2;
  set(gcf, 'paperposition', pos);
  fontsize = get(gca, 'fontsize');
  set(gca, 'fontsize', fontsize/2);
  lineWidth = get(gca, 'lineWidth');
  set(gca, 'lineWidth', lineWidth*2);
  print('-dpng', [directoryHtml filesep fileName]);
  set(gcf, 'paperposition', origpos);
  set(gca, 'fontsize', fontsize);
  set(gca, 'lineWidth', lineWidth);
end

fprintf('Printing black and white eps plot ...\n');
colormap gray
print('-deps', [directory filesep fileName 'NoColour'])
colormap(cmap);