% subplt.m ----------------------------------------------------------
%
% The 'SubPlot' argument is used to create 3 axes. plt puts a single
% trace on each axes except for the main (lower) axis which gets
% all the remaining traces. In this case, since there are 5 traces
% defined, the main axis has 3 traces. Note that the traces are
% assigned to the axes from the bottom up so that the last trace
% (serp) appears on the upper most axis.
%
% The 'LabelY' argument defines the y-axis labels for all three axes,
% again from the bottom up. You can also define the y-axis label for
% the right hand main axis, by tacking it onto the end of the LabelY
% array (as done here)
%
% The 'Right',2 argument is used to specify that the 2nd trace of
% the main axis should be put on the right hand axis. If this argument
% was omitted, plt would still have known that a right hand axis was
% desired (because of the extra y-label in the LabelY array) however
% it would have put trace 3 on the right hand axis. (By default, the
% last trace goes on the right axis).
%
% The Linewidth and LineStyle arguments define line characteristics
% for all 5 traces. The TraceMK parameter enables the traceID box to
% show the line characteristics and the xy parameter widens the
% traceID box and moves the plotting axis to make room for this.
%
% Note that all three plots have their own cursor supporting almost
% all the cursor features. The exceptions are delta cursors, the xview
% slider, and the multi-cursor mode. These modes will still be active
% but they apply only the the main (lower) axis.
%
% Only a single x-axis edit box is needed since plt keeps the
% cursors of all three axes aligned. Also note that if you zoom or
% pan any of the 3 plots, the other two plots will adjust their x-axis
% limits to agree.
%
% A brief description of this example is added to the screen using the
% HelpText parameter. As you will see in the other demo programs, the
% help text is usually removed when you start using the program, but
% in this case the help text is left in place since it doesn't interfere
% with the plot area or controls. (However you can toggle the help text
% on or off by right clicking on the Help tag in the menu box.)
%
% ----- Author: ----- Paul Mennen
% ----- Email:  ----- paul@mennen.org

x = 0:600;   t = x/600;  z = (x-400)/30;
v = 1:2:11;  w = 1:11;   r = (-1).^(0:5)./(v.^2);
square   = (4./v)*sin(4*pi*v'*t);
sawtooth = (60./w)*sin(4*pi*w'*(t+pi));
triangle = 2*r*sin(4*pi*v'*t);
serp     = 18*z ./ (1 + z.^2);
sweep    = 2 - 4*exp(-1.4*t).*sin(10*pi*t.^5);
p        = [-1 .005 .430 .110 .110];  % TraceID box position
htxt = {'This example shows how to use the "SubPlot"' ...
        'parameter to put several graphs into one figure.' ...
        .63-.13i 'Fontsize' 9};
plt(x,[square; sawtooth; triangle; sweep; serp],'Right',2,...
   'GRIDc',[1 1 -1]/4,'GRIDstyle',':','LabelX','seconds',...
   'LabelY',{'Fourier Series' 'Sweep' 'Serp' 'Sawtooth'},...
   'Pos',[775 575],'SubPlot',[50 30 20],'FigBKc',[10 5 10],...
   'Linewidth',{1 3 3 1 3},'LineStyle',{'-' '-' ':' '-' '--'},...
   'TraceID',{'Square' 'Saw' 'Tri'},'TraceMK',[.65 .95],...
   'xy',p,'ColorFile','','HelpText',htxt);
