% subplt20.m ----------------------------------------------------------
%
% The default subplot "linked" mode (demonstrated by the previous 3 subplot
% examples) makes sense when the columns share a common x-axis. However
% in this example the plots do not share a common axis, so the "independent"
% subplot mode is more appropriate. We tell plt to use the independent
% mode by putting an "i" after the first number of the subplot argument
% (Note the "32i" in the subplot argument of this example).
%
% The only thing now shared between the columns is space for displaying
% the cursor values. For example, the x and y edit boxes below the first
% column display the cursor values for the plot that you last clicked on
% in that column. The color of these edit boxes changes to match the color
% of the trace that you clicked on so you can tell at a glance which plot
% the cursor values refer to.
%
% One advantage of the independent mode is that we can fit more plots into
% a given space. We could probably display these 20 plots using the linked
% mode as well, but the figure window would have to be very large since
% in the linked mode a separate y-axis cursor edit box is included for
% every axis.
%
% As with the previous subplot examples, there are more traces than axes
% (21 traces and 20 axes). That means the first plot (lower left) gets
% 2 traces and a traceID box is added to allow you to select which one
% to display (or both).
%
% In this example all 21 traces contain the same number of points (301).
% However this was just done for the convenience of the code generating
% the fake data to display. Each of the 21 traces could include a different
% number of points and the script would work equally as well.
%
% As you experiment with these plots, be aware of the concept of the
% "current cursor" (or "current plot" if you prefer) which is important
% since there are 16 different cursors visible. The current cursor is the
% cursor belonging to the last plot that you clicked on. When you click on
% one of the five menu box tags (LinX, LinY, Mark, Zout, XY<->) the
% appropriate menu box operation will only be applied to the current cursor.
% Likewise for the up/down arrow buttons (peak/valley finder) as well as
% the "circle" button which toggles whether markers are positioned over
% the trace data values.  The only exception is the Delta button
% (delta cursor). This always operates on the main plot (lower left)
% regardless of which cursor is current.

% ----- Author: ----- Paul Mennen
% ----- Email:  ----- paul@mennen.org

x = 0:2:600;  t = x/600;  z = (x-400)/30;  s = t*30; % Generate some fake data
v = 1:2:11;  w = 1:11;  r = (-1).^(0:5)./(v.^2);
sweep    = 2 - 4*exp(-1.4*t).*sin(10*pi*t.^5);
bell2    = pi + (exp(-((x-200)/30).^2) - exp(-z.^2))/.012;
square   = (4./v)*sin(4*pi*v'*t);    saw     = (2./w)*sin(4*pi*w'*(t+pi));
triangle = 3*r*sin(4*pi*v'*t);       sin1x   = 8.5*sin(1./(2*t+.1));
serp     = 18*z ./ (1 + z.^2);       poly3   = 24*t.^3 - 30*t.^2 + 8*t;
sqserp   = square + serp + 10;       cost3   = 2.5*t .* cos(5*pi*(1-t).^3) + 1.3;
trserp   = triangle + serp - 2;      sawserp = saw + serp + 1;
sweep1x  = sin1x + 2*sweep - 4;      sweep2x = cost3 + sweep - 1;
sweep3x  = bell2/20 + sweep - 2;     tribell = bell2/20 + 1.2*triangle;
cosp3    = cost3 - poly3;            serp1x  = .14 * (serp + sin1x + 12);
trsel4   = trserp + tribell + 12;    tripoly = triangle - 4*poly3;

n5i = [32i 17 17 17 17]; % 5 plots per column. Bottom plot twice as tall as the rest.
n5  = abs(n5i);          % The "i" after the 32 signifies "independent" cursor mode
c   = -25.98;            % 25% of width for each column. Decrease column separation by 2%
c2  = -25.97;            % 25% of width for each column. Decrease column separation by 3%

plt(t,square,   t,sweep3x, x,saw,    s,bell2,    t,sweep,   s,humps(t), ...
    z,trsel4,   t,sin1x,   s,serp,   x,cost3,    s,triangle, ...
    s,sqserp,   s,trserp,  z,poly3,  t,sawserp,  s,sweep1x,  ...
    x,sweep2x,  t,cosp3,   x,serp1x, x,tribell,  s,tripoly,  ...
    'SubPlot',[n5i c2 n5 c n5 c n5 c],'Options','I',...
    'pos',[820 580],'TraceID',{'square' 'sweep3x'},'FigBKc',[0 5 0],...
    'LabelX',{'Seconds' '\muMeters' 'kilo \Omega' 'Hertz'},'LabelY',...
   {'main'    'sawtooth' 'bell2'  'sweep'   'humps'     ...
    'trsel4'  'sin1x'    'serp'   'cost3'   'triangle'  ...
    'sqserp'  'trserp'   'poly3'  'sawserp' 'sweep1x'   ...
    'sweep2x' 'cosp3 '   'serp1x' 'tribell' 'tripoly'});
