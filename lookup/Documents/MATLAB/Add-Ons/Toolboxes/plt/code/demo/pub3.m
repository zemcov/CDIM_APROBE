% pub3.m ------------------------------------------------------------
%
% As with the previous two demos (pub & pub2) multiple plots are created
% in a single figure, however a different mechanism is used. In pub/pub2
% the subplot parameter is used, which has the advantage of creating
% multiple plots with a single call to plt. This program uses the 'Fig'
% parameter instead, and each plot is created with a separate call to plt.
% This provides some advantages over the subplot method, such as allowing
% each plot to include a traceID box as well as a right hand axis. Also
% the position of the plots are completely general and don't demand fixed
% column widths as with subplots. (Note that the positions of the four
% plots in this example would have been difficult to create using subplots.)
% In this example, the cursors were disabled ('Nocursor' option) since the
% main goal was a uncluttered publication quality result, but if they cursors
% were left enabled, they would have the full generality and all the plt
% options of single plot graphs (unlike the restricted set of subplot options).
% On the other hand, as the number of plots required on the figure increases,
% the restrictions of the subplots are advantageous in that they allow
% a more compact plot spacing.
%
% The traceID box is enabled for each plot in this example, primarily as
% a legend, but it can also be used to enable or disable any trace on the figure.
%
% Note that the 2nd trace of each plot (with traceID "samp") actually consists
% of 12 superimposed traces. (This is done by delineating each of the 12
% traces with a NaN element so that a line is not drawn from the end of each
% trace to the beginning of the next.) This could have been done by using a
% separate trace for each of the twelve "samp" traces, each with their own
% traceID, but that would have made the legend unnecessarily large and cumbersome.
% The blue trace is the average of the 12 superimposed traces and the red trace
% (markers only) is the standard deviation of those same 12 traces.

% The xy parameter contains the positions and sizes of each of the four plots.
% Note that a -3 is inserted in front of each of these positions. The -3 indicates
% that this position refers to both the left and right axes and also indicates
% that the traceID box (and the cursor controls if they were enabled) are to be
% positioned relative to the positons given for the left and right axes. This is
% described in the description of the xy parameter in the Axis Properties section
% of the help file.

% ----- Author: ----- Paul Mennen
% ----- Email:  ----- paul@mennen.org

pts = 30;  reps = 12;  x = 1:pts;  t= x/pts;  % generate some fake data
x = x + 1980;  s = repmat([x NaN],1,reps)';  s = s(:);
y = [14*exp(-2*t).*sin(20*t)+1;       15*t.*cos(5*pi*(1-t).^3);
     20*exp(-1.4*t).*sin(10*pi*t.^5); humps(t)/5-9] + 9;

tid = {'] mean' ' samp' ' std'};  trc = [0 0 5; 5 5 5; 7 0 0]/10; % common plt parameters
lbl = {'metric tons' 'pressure (N/m^2)' 'Ionization (PPM)' 'Contamination (PPB)'};

a = {'Pos',[1170 750],x,4,s,6,x,8,'xy',10,'LabelY',12,'right',3,'TraceID',tid,...
     'Colordef',0,'TraceC',trc,'Linewidth',{3 1 1},'LabelX','Year',...
     'LabelYR','standard deviation','<Fontsize',16,'<.Fontweight','bold',...
     'Styles','--o','Options','Hide Nocur Linesmooth Ticks -All'};

xy = [07 07 35 40;    53 07 43 40;                  % positions (lower plots)
      08 57 43 40;    61 57 35 40] / 100;           % positions (upper plots)
xy = [-3*ones(4,1) xy];                             % -3 selects left & right axes
Nrep = NaN*zeros(reps,1);

for k=1:4                                           % create four plots
  z = 8*rand(reps,pts) + repmat(y(k,:),reps,1);     % z and w contain the data for this plot
  w = [z Nrep]';  w = w(:)';
  a(4:2:12) = {mean(z)  w  std(z)  xy(k,:) lbl{k}}; % replace parameters 4,6,8,10,12
  plt(a{:});                                        % 1st time thru, plt creates the figure
  a(1:2) = {'Fig' gcf};                             % after that, plt uses the existing figure
end;

set(gcf,'vis','on');                                % Make the figure visible

