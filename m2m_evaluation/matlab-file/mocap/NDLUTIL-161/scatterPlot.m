function [ax, data] = scatterPlot(X, YLbls, markerSize);

% SCATTERPLOT 2-D scatter plot of labelled points.
%
%	Description:
%
%	[AX, DATA] = SCATTERPLOT(X, LBLS, MARKERSIZE) plots a 2-D scatter
%	plot of labelled points.
%	 Returns:
%	  AX - the axis handle of the plot.
%	  DATA - the handles of the data points.
%	 Arguments:
%	  X - x points to plot.
%	  LBLS - the labels to plot.
%	  MARKERSIZE - the size of the markers to use.
%	
%
%	See also
%	PLOT, GETSYMBOLS


%	Copyright (c) 2005 Neil D. Lawrence
% 	scatterPlot.m CVS version 1.2
% 	scatterPlot.m SVN version 22
% 	last update 2007-11-03T14:26:18.000000Z

if isempty(YLbls)
  symbol = [];
else
  symbol = getSymbols(size(YLbls,2));
end

% Create the plot for the data
clf
ax = axes('position', [0.05 0.05 0.9 0.9]);
hold on

data = twoDPlot(X, YLbls, symbol);
for i = 1:2
  minX = min(X(:, i));
  maxX = max(X(:, i));
  xSpan = maxX - minX;
  xLim{i}(1) = minX - 0.1*xSpan;
  xLim{i}(2) = maxX + 0.1*xSpan;
end
if nargin>2
  for i = 1:length(data)
    set(data(i), 'markersize', markerSize);
  end
end
set(ax, 'xLim', xLim{1});
set(ax, 'yLim', xLim{2});

set(ax, 'fontname', 'arial');
set(ax, 'fontsize', 20);

function returnVal = twoDPlot(X, label, symbol)

% GPLVMTWODPLOT Helper function for plotting the labels in 2-D.

returnVal = [];

if ~isempty(label)
  for i = 1:size(X, 1)
    labelNo = find(label(i, :));
    try 
      returnVal = [returnVal; plot(X(i, 1), X(i, 2), symbol{labelNo})];
    catch
      if strcmp(lasterr, 'Index exceeds matrix dimensions.')
	error(['Only ' num2str(length(symbol)) ' labels supported (it''s easy to add more!)'])
      end
    end
  end
else
  returnVal = plot(X(:, 1), X(:, 2), 'rx');
end