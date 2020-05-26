function zeroAxes(axesHandle, tickRatio, fontSize, fontName)

% ZEROAXES A function to move the axes crossing point to the origin.
%
%	Description:
%
%	ZEROAXES(AXESHANDLE, TICKRATIO, FONTSIZE, FONTNAME) moves the
%	crossing point of the axes to the origin.
%	 Arguments:
%	  AXESHANDLE - the handle of the axes to zero.
%	  TICKRATIO - the ratio of the axis length to the tick length
%	   (default 0.025).
%	  FONTSIZE - the font size for the axes (default 14).
%	  FONTNAME - the name of the font for the axes (default 'times').
%	
%
%	See also
%	PLOT


%	Copyright (c) 2005 Neil D. Lawrence
% 	zeroAxes.m CVS version 1.4
% 	zeroAxes.m SVN version 22
% 	last update 2007-11-03T14:26:08.000000Z

if nargin < 4
  fontName = [];
  if nargin < 3
    fontSize = [];
    if nargin < 2
      tickRatio = [];
      if nargin < 1
        axesHandle = [];
      end
    end
  end
end
if isempty(fontName)
  fontName = 'times';
end
if isempty(fontSize)
  fontSize = 14;
end
if isempty(tickRatio)
  tickRatio = 0.025;
end
if isempty(axesHandle)
  axesHandle = [];
end
axis off
xlim = get(axesHandle, 'xlim');
ylim = get(axesHandle, 'ylim');
xTickLength = (xlim(2) - xlim(1))*tickRatio;
yTickLength = (ylim(2) - ylim(1))*tickRatio;

xtick = get(axesHandle, 'xtick');
ytick = get(axesHandle, 'ytick');
xaxYpos = 0;
if ylim(1) > 0
  xaxYpos = ylim(1);
elseif ylim(2) < 0
  xaxYpos = ylim(2);
end
line([xlim(1) xlim(2)], [xaxYpos xaxYpos])
for i = 1:length(xtick)
  if xtick(i) == 0
    if any(ytick == 0)
      continue
    end
  end
  line([xtick(i) xtick(i)], xaxYpos+[0 -yTickLength]);
  textHandle = text(xtick(i), xaxYpos-4*yTickLength, num2str(xtick(i)));
  set(textHandle, 'fontsize', fontSize, 'fontname', fontName, ...
		  'horizontalalignment', 'center');
end

yaxXpos = 0;
if xlim(1) > 0
  yaxXpos = xlim(1);
  set(axesHandle, 'xlim', [xlim(1) - xTickLength xlim(2)]);
elseif xlim(2) < 0
  yaxXpos = xlim(2);
  set(axesHandle, 'xlim', [xlim(1) + xTickLength xlim(2)]);
end
line([yaxXpos  yaxXpos], [ylim(1) ylim(2)])
for i = 1:length(ytick)
  if ytick(i) == 0
    if any(xtick ==  0)
      t = 0:pi/24:2*pi;
      xCirc = xTickLength*sin(t);
      yCirc = yTickLength*cos(t);
      line(xCirc', yCirc');
      continue
    end
  end
  line(yaxXpos-[0 xTickLength], [ytick(i) ytick(i)]);
  textHandle = text(yaxXpos - 1.1*xTickLength, ytick(i),  num2str(ytick(i)));
  set(textHandle, 'fontsize', fontSize, 'fontname', fontName, ...
		  'horizontalalignment', 'right');

end




