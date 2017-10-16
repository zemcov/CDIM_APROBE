% subplt8.m ----------------------------------------------------------
%
% This script shows a slight expansion of the ideas found in subplt.m
% by increasing the number of axes from 3 to 8. The axes are arranged
% in two columns which allows the use of two different x axes
% (one for each column).
%
% Note that the four axes on the left are synchronized with each other
% as well as the four on the right, but the left and right halves
% are independent of each other and have different x axis limits and units.
%
% There are 11 traces defined in the plt argument list but only 8 axes
% are specified. The extra 3 traces go to the main plot (lower left). This
% means that the first 4 traces are on the main plot and the remaining
% 7 traces are assigned to the other 7 subplots.
%
% Although the black background used in most of the example programs makes
% it easier to distinguish the trace colors, some people prefer a white
% background and this script shows how to do that by using the 'ColorDef'
% parameter to select Matlab's default color scheme. Matlab's default
% trace color order only includes six colors and this may not be long
% enough or ordered ideally for a particular graph. The 'ColorDef'
% parameter may be used to set the trace colors as desired.
% If (as in this example) the ColorDef parameter is a color specification
% (3 columns of numbers between zero and one) this color spec is used
% instead of matlab's current trace color order default. The first line of
% this script defines this color order using matlab's traditional style.
% The 2nd line defines the exact same color sequence using an alternate
% style allowed by plt which you may also use if you find that more
% convenient than the traditional style. There's a special case (not used here)
% for the first entry in this color array. If it's [.99 .99 .99]
% (or 999999 in the alternate style) then the remaining colors are
% appended to the matlab default color trace order. This may be convenient
% if for example you just want to add a few colors to the end of the list
% instead of merely replacing the whole color trace sequence.
%
% One advantage of the white background is that it is easier to publish
% a screen capture since the colors will not need to be inverted. Remember
% that for publishing you can reduce the clutter of the capture by
% temporarily removing all the cursors and their associated controls and
% readouts. You do this by right clicking on the y-axis label of the lower
% left plot ("main"). Right click a second time to re-enable the cursors.

% ----- Author: ----- Paul Mennen
% ----- Email:  ----- paul@mennen.org

TraceC = [0 0 1;  0 .5 0; 1 0 0;  .75 .75 0; 0 .75 .75; .75 0 .75; .25 .25 .25; 0 .5 .5];
TraceC = [000001; 005000; 010000; 757500;    007575;    750075;    252525;      005050];
%         Blue    Green   Red     Yellow     Cyan       Purple     Gray         Dk. Cyan

x = 0:600;  t = x/600;  z = (x-400)/30;  t2 = t*12; % Generate some fake data
v = 1:2:11;  w = 1:11;  r = (-1).^(0:5)./(v.^2);
serp     = 18*z ./ (1 + z.^2);        sweep = 2-4*exp(-1.4*t).*sin(10*pi*t.^5);
triangle = r*sin(4*pi*v'*t);          poly3 = 24*t.^3 - 30*t.^2 + 8*t;
square   = (4./v)*sin(4*pi*v'*t);     saw   = (0.6./w)*sin(4*pi*w'*(t+pi));
cost3    = t .* cos(5*pi*(1-t).^3);   bell2 = 85*(exp(-((x-200)/30).^2)-exp(-z.^2));
sweep3x  = bell2/20 + sweep - 2.5;    sin1x = 8.5*sin(1./(2*t+.1));

plt(x,[sweep3x; square; saw; triangle; sweep; serp; humps(t)],...
    t2,[sin1x; bell2; poly3; cost3],'ColorDef',TraceC,...
   'SubPlot',[40 20 20 20 -50 20 20 20 40],'LabelX',{'seconds' '\mumeters'},...
   'TraceID',{'sweep3x' 'square' 'saw' 'triangle'},...
   'LabelY',{'main' 'sweep' 'serp' 'humps' 'sin1x' 'bell2' 'poly3' 'cost3'});
