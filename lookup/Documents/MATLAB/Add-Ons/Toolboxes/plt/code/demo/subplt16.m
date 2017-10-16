% subplt16.m ----------------------------------------------------------
%
% This short script again is a slight complication from the previous
% example (supblt8). Not only do we double the number of axes but we
% take advantage of all the features of the subplot argument by
% varying the number of plots in each column as well as adjusting
% the vertical and horizontal spacings.
%
% Note that the whole number parts of the subplot argument specifies
% the plot widths and heights where as the fractional parts specifies
% the horizontal and vertical spacing between the plots.
%
% So for example the "99.04" near the end of the subplot argument (for
% the rightmost plot) means that this plot should occupy 99% of the
% available height. The fractional part means that the space below the
% graph should be increased by 4 percent of the height of the available
% plotting area.
%
% Also remember that the negative numbers in the subplot argument are
% used to break up the plots into columns. So for example, the "-25.96"
% value tells plt that the first column should contain four plots
% (because it follows four positive numbers). The whole number part (25)
% means that the first column should use up 25% of the available plotting
% width. The fractional part (.96) means that we want to reduce the
% default spacing to the left of this column by 4% of the plotting width.
% (The default spacing results in a comfortable easy-on-the-eyes layout,
% but sometimes we want a tighter layout so we can have bigger plots.)
% For a more complete description of the subplot argument, refer
% to the "Programming with plt "section of the help file and the
% "Axis properties" subsection.
%
% As in the previous example, the cursors for the various plots in each
% column are linked to each other, but are not linked in any way to the
% cursors of the other columns. So for example if you move the cursor
% in the "tribell" plot (top of column 2) all the cursors of the four
% plots below it will also move so that they all point to the same x
% position. Also if you pan or zoom the x-axis of the tribell plot, the
% x-axis of the four plots below it will also be zoomed or panned so that
% the x limits remain the same for the entire column. This is what we
% call the subplot "linked" mode. The unlinked (or "independent") mode
% is demonstrated in the next example program (subplt20).

% ----- Author: ----- Paul Mennen
% ----- Email:  ----- paul@mennen.org

x = 0:600;  t = x/600;  z = (x-400)/30;  s = t*12;  % Generate some fake data
v = 1:2:11;  w = 1:11;  r = (-1).^(0:5)./(v.^2);
sweep    = 2 - 4*exp(-1.4*t).*sin(10*pi*t.^5);
bell2    = pi + (exp(-((x-200)/30).^2) - exp(-z.^2))/.012;
square   = (4./v)*sin(4*pi*v'*t);    saw     = (2./w)*sin(4*pi*w'*(t+pi));
triangle = 3*r*sin(4*pi*v'*t);       sin1x   = 8.5*sin(1./(2*t+.1));
serp     = 18*z ./ (1 + z.^2);       poly3   = 24*t.^3 - 30*t.^2 + 8*t + 1;
cost3    = t .* cos(5*pi*(1-t).^3);  sqserp  = 4*square + 4*serp + 40;
trserp   = triangle + serp - 2;      sawserp = saw + serp + 1;
sweep1x  = sin1x + 2*sweep - 4;      sweep2x = 5*cost3 + sweep/2 + 2.5;
sweep3x  = bell2/20 + sweep - 2;     tribell = bell2/20 + triangle;

n4  = [25 25 25 25];       % 4 plots per column - equal heights
n5  = [20 20 20 20 20];    % 5 plots per column - equal heights
n6  = [17 17 17 17 16 16]; % 6 plots per column - equal heights (approx)

plt(t,square, t,sweep3x,  t,saw,    t,triangle, t,sweep,   ...
    s,bell2,  s,humps(t), s,sin1x,  s,serp,     s,tribell, ...
    x,cost3,  x,sqserp,   x,trserp, x,sawserp,  x,sweep1x,  x,sweep2x,  s*4,poly3,...
    'SubPlot',[n4 -25.96 n5 -30.96 n6 -36.96 99.04 -11.95], ...
    'Pos',[1380 600],'TraceID',{'square wave' 'sweep 3x'},...
    'LabelX',{'Seconds' '\muMeters' 'kilo \Omega' 'Hertz'},'LabelY',...
   {'main'   'sawtooth' 'triangle' 'sweep'   'bell2' ...
    'humps'  'sin1x'    'serp'     'tribell' 'cost3' ...
    'sqserp' 'trserp'   'sawserp'  'sweep1x' 'sweep2x' 'poly3'}, ...
    'FigBKc',[7 0 0],'Options','+Z+M+G+F I');

w = get(0,'screensize');
w = w(3)-15;                    % get screen width
p = get(gcf,'pos');             % get figure position
if p(3) > w                     % shrink the figure if it's
   p(3) = w;  set(gcf,'pos',p); % wider than the screen
end;
