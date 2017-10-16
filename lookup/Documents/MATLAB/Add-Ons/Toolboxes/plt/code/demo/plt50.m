% plt50.m ------------------------------------------------------------------
%
% This script is an expansion of the simple plt5.m example to demonstrate
% additional features of plt
%
% Note that two plots appear in this figure. There are two methods that you
% can use with plt to create figures containing multiple plots. The first
% is to use the subplot parameter to create multiple plots with a single
% call to plt. (This is demonstrated by the subplt.m, subplt8.m, subplt16.m,
% subplt20.m, pub.m, pub2.m, pltmap.m, and weight.m programming examples).
% The second method (which is used here as well as in the pub3.m example)
% is to use a separate call to plt for each plot. The first plot (upper) is
% created by a call to plt that is quite similar to the one used in the simple
% plt5.m example. plt creates the figure window as usual and then creates the
% upper plot inside the new figure. Both a left and right hand axis are used
% for this plot. We are free to put as many traces as we want on either the
% left or right hand side, although in this example we put all the traces
% of this plot on the left hand axis except for the last one (trace "Tr40")
% which is put on the right hand axis (and is also drawn with a thicker trace).
% The two major differences between this (first) call to plt and the plt call
% used in plt5.m are:
%
% 1.) The number of traces has been expanded from 5 to 40. Without additional
% action, this would create a TraceID box (legend) containing 40 trace names
% in a single column. However this would not work well or look good to cram
% such a long list into the small space available. To solve that problem the
% the TIDcolumn parameter has been used to create a TraceID box with two columns.
% The 'TIDcolumn',20 included in the plt argument list actually specifies the
% number of items to put in the second column, which in this example means
% that both columns will contain 20 items.
%
% 2.) The 'xy' parameter is included to specify the location of the plot within
% the figure window. This wasn't needed before (in plt5.m) since the plot
% was automatically sized to fill the entire figure window. But now we want
% to create the plot in only a portion of the window to leave room for a
% second plot to be created. The object ID (-3) in the first row indicates
% that this position is to be used for both the left and right axis and
% also that all the cursor object positions should be positioned relative to
% these axes. (ID 0 also refers to both left & right axes but does not cause
% the other cursor objects to be repositioned as well). Although plt makes
% its best guess for the positions of the TraceID and Menu boxes often you
% will want to reposition them with the xy parameter to make best use of the
% available space. The 2nd row of the xy matrix repositions the TraceID box.
% The last row repositions the Yaxis label which otherwise would have been
% covered up by the TraceID box. Note that you don't need to figure out the
% numbers in the xy matrix since they will be reported to you as you adjust
% the positions of the screen objects with the mouse. (See the description
% of the xy parameter in the "Axis Properties" section of the help file.)
%
% Following the first call to plt which displays the first 40 traces, a second
% call to plt is used to display the remaining 10 traces in a plot below the
% first one. As before we use the 'xy' parameter to get the plot to fit in the
% remaining open space of the figure. As with the first plot, we also include
% both the left and right hand axis. We were again free to put as many of these
% traces as desired on either side, but we choose to put only trace 5 on the
% right hand axis with all the remaining traces on the left axis. The most
% important difference between the first and second plt calls is that in the
% second call we include the 'Fig',gcf in the parameter list. (gcf stands for
% "get current figure handle"). This tells plt not to open a new figure for
% the plot as usual, but rather to put the plot in the specified figure. The
% 'Fig' parameter must be either at the beginning or at the end of the plt
% parameter list. (All other plt parameters may be placed anywhere in the
% parameter list). You may notice that the xy parameter for this plot includes
% an imaginary component in the last element of the axis position. The reason
% for this is that since the sizes of the cursor objects are relative to the
% plot size. This sometimes makes the cursor objects too small when the plot
% is a small fraction of the figure size. To fix this problem, one can enter
% a minimum width or height in the imaginary component of the width and/or
% height values.
%
% A few other features of the first (upper plot) are worth pointing out:
% 
% 1.)With so many traces, the ability to use the legend (i.e. the TraceID box)
% to selectively enable or disable individual traces becomes even more
% compelling. Although the traces and the legend are color coded, it's
% difficult to distinguish every trace based on color, so clicking on a
% legend item is often useful to uniquely identify a trace.
%
% 2.) The 'Pos' parameter is used to increase the figure area about 30%
% from the default of 700x525 pixels to 830x550. This gives room to fit
% both plots into the figure area without overcrowding.
%
% 3.) The 'HelpFileR' parameter is used to specify which help file will appear
% when you right click on the Help tag in the menu box. Normally the file
% specified will contain help for the currently running script. In this case
% prin.pdf is just used as an example and in fact has nothing to do with plt50.
%
% 4.) The use of the 'closeReq' parameter is shown, although in this case the
% function specified merely displays a message. Look at the gui2.m and wfall.m
% demos to see examples of a somewhat more sophisticated close request functions.
%
% 5.) In situations like this with so many traces on the plot it can be difficult
% to find the cursor. The line following the first call to plt solves this
% problem increasing the cursor size from 8 to 20 as well as by changing the
% cursor shape from a plus sign to an asterisk.

% ----- Author: ----- Paul Mennen
% ----- Email:  ----- paul@mennen.org

% Create the upper plot --------------------------------------------------------
t  = (0:399)/400;  u = 1-t;                        % x-axis data
y1 = 8.3 - 1.4*exp(-6*t).*sin(70*t);               % prototype for traces  1-10
y2 = 2 * t .* cos(15*u.^3) + 6;                    % prototype for traces 11-20
y3 = 5 - 2*exp(-1.4*t).*sin(30*t.^5);              % prototype for traces 21-30
y4 = u .* sin(20*u.^3) + 3;                        % prototype for traces 31-40
w = ones(10,1);  s = 5.3*(t-.5);                   % expand 4 traces into 40
v = repmat((10-cumsum(w))*(sqrt(16-s.*s)-3)/6,4,1);
y = [y1(w,:);y2(w,:);y3(w,:);y4(w,:)] + v;         % Trace data (40 x 400 matrix)
y(end,:) = sum(y);                    % The last trace is the sum of the first 39

creq    = 'disp("The plt50 figure window has been closed");';
xy      = [-3  .14 .467 .79 .52;      % reposition left & right axes
           -1  .01 .61  .10 .38;      % reposition TraceID box
          303 -.04 .17    0  0];      % reposition Yaxis label

h1 = plt(t,y,'pos',[830 830],'TraceID',prin('{Tr%2d!row}',1:40),...
        'YlimR',[200 300],'xy',xy,'Options','-F -G I','TIDcolumn',20,...
        'FigBKc',121212,'HelpFileR','prin.pdf','CloseReq',creq);

set(findobj(gcf,'markersize',8),'markersize',20,'marker','*'); % Make cursor bigger

% Create the lower plot --------------------------------------------------------
y5 = (y1+y2+y3+y4)/2 - 10;         % prototype for traces 1-10
yy = y5(w,:) + v(1:10,:);          % expand 1 trace into 10
yy(5,:) = 8.6*fliplr(yy(5,:))-3;   % flip the 5th trace around (left to right)

xy = [-3 .14 .063 .79 .335+.53i; -1 .01 .21 .06 .18]; % plot and TraceID positions

h2 = plt(30*t,8.5*yy-1,'Right',5,'xy',xy,'Options','-H I','YlimR',[0 200],'Fig',gcf);

set([h1(end) h2(5)],'linewidth',5); % Make two of the traces thicker
