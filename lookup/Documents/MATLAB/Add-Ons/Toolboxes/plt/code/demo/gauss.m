% gauss.m ----------------------------------------------------------------
%
% This example script plots the sums of several uniform random variables.
% - Shows the advantage of passing plot data in cell arrays
%   when the traces contain different number of data points.
% - Shows how the line zData can be used to save an alternative data set
%   which in this example is the error terms instead of the actual
%   correlations. A checkbox allows you to tell the plot to show the
%   alternative data set. The label for the checkbox is rotated 90 degrees
%   so that it can fit in the small space to the left of the plot.
% - Note the use of the 'FigName' and 'TraceID' arguments.
% - Note the appearance of the greek letter in the x-axis label.
% - Uses the 'COLORdef' argument to select Matlab's default plotting
%   colors (which typically use a white background for the plotting area)
% - The 'Options' argument enables the x-axis cursor slider (which appears
%   just below the peak/valley finder buttons), enables the menu bar at
%   the top of the figure window, adds the Print tag to the menu box, and
%   lastly removes the LinX/LogX and LinY/LogY selectors from the menu box.
% - Uses the 'DIStrace' argument so that gauss.m starts off with some
%   traces disabled.
% - Shows an example of the use of the 'MotionZoom' parameter. To see what
%   it does, create a zoom box by holding both mouse buttons down and
%   draging the mouse in the plot window.
% - The zoom window plot also demonstrates an easy way to copy the trace
%   data from one plot to another (in this case from the main plot to the
%   zoom plot).
% - The first trace is displayed using markers only to distinguish the true
%   Gaussian curve.
% - Demonstrates the use of the 'HelpText' parameter to initialize a GUI
%   with user help information that is cleared when the user begins to
%   use the application. In this case the MoveCB parameter is used to
%   cause the help text to be removed when you click on the plot. The help
%   text is also removed if you click on the checkbox. If you want the help
%   text to reappear, simply right click on the help tag in the MenuBox.

% ----- Author: ----- Paul Mennen
% ----- Email:  ----- paul@mennen.org

function gauss(xyLim)

mxN = 2:10;                                  % sum from 2 up to 10 uniform distributions
traceID = prin('Gauss ~, {Sum%2d!row}',mxN); % The 1st trace is the true Gaussian curve
if ~nargin                   % Initialize gauss window section ------------
  dis = [zeros(1,7) 1 1 1];  % initially show the first 7 traces
  sz = 100;                  % size of each uniform distribution
  u = ones(1,sz);            % uniform distribution
  y = u;                     % y will be composite distribution
  xx = {};  yy = {};         % xx/yy holds the data for all the convolutions (2-10)
  dy = {};                   % dy holds the errors between the convolutions & the gaussian
  for n = mxN
    y = conv(y,u);           % convolve with next uniform distribution
    m = length(y);  mean = (m+1)/2;  y = y/max(y);
    sigma = sz * sqrt(n/12);
    x = ((1:m) - mean) / sigma;           % change units to sigma (zero mean)
    xx = [xx {x}];  yy = [yy {y}];        % append data for the next convolution
    g = exp(-(x.^2)/2); dy = [dy; {y-g}]; % append the data for the next error trace
  end;
  x = x(1:10:end);  g = g(1:10:end);                 % markers for trace 1 at every 10th point
  xx = [{x} xx];  yy = [{g} yy];  dy = [{0*x}; dy];  % append the 1st trace (true gaussian)
  htxt = {'Try opening a zoom box by' 'dragging the mouse with both' 'mouse buttons down.' ...
          '' 'Observe that a new window' 'appears showing the' 'contents of the zoom box.' ...
          '' 'This is accomplished' 'by using plt''s' '"MotionZoom"' 'parameter.' ...
          .03+.98i 'color' [.5 0 0]};
  L = plt(xx,yy,'FigName','Sum of uniform distributions','DIStrace',dis,'COLORdef','default',...
      'pos',[0 inf 600 600 21],'LabelX','Standard deviation (\sigma)','LabelY','',...
      'TraceID',traceID,'MotionZoom','gauss','HelpText',htxt,'MoveCB','plt helptext;',...
      'xlim',[-4 3.7],'ylim',[-.05 1.15],'Options','Slider Menu +Print -X -Y');
  set(L(1),'Linestyle','none','Marker','o');   % markers distinguish the true gaussian trace
  set(L,{'z'},dy);                             % save error terms in the Zdata
  uicontrol('Style','CheckBox','Units','Norm','Pos',[.03 .40 .03 .04],...
            'BackGround',get(gcf,'Color'),'Callback','gauss(0)');
  text(-.12,.4,'Plot errors only','units','norm','Rotation',90); % Label for checkbox

elseif length(xyLim)<4  % checkbox callback function ----------------------------------------
  L = getappdata(gcf,'Lhandles');   a = get(L(1),'parent');  % get line & axis handles
  yli = {[-.05 1.05] [-.09 .075]};   plt helptext;           % turn help text off
  y = get(L,'y');  set(L,{'y'},get(L,'z'),{'z'},y);          % swap the y & z data
  set(a,'ylim',yli{get(gcbo,'value')+1});  plt('grid',a);    % set y axis limits
else             % zoom box motion function ------------------------------------------
  zoomFig = 'Gauss Zoom Window'; g = gcf;  f = findobj('name',zoomFig);
  if isempty(f) % create the zoom window if it doesn't already exist
     h = getappdata(gcf,'Lhandles');    % get x/y vectors for all 10 traces into 1 cell array
     vis = get(h,'vis'); xy = [get(h,'x') get(h,'y')]';
     dis = strrep(strrep([vis{:}],'off','1'),'on','0')-'0'; % traces to disable
     p = get(gcf,'pos');                     % position of main figure
     p = p + [p(3)+10 0 0 21];  p(3) = 425i; % position of zoom figure
     L = plt(xy{:},'TraceID',traceID,'LabelX','','LabelY','',...
         'Options','-All','DIStrace',dis,'FigName',zoomFig,'Pos',p,...
         'xy',[1 .223 .097 .748 .890; -1 .004 .630 .123 .362]);
     set(L(1),'Linestyle','none','Marker','o');  f = gcf;
     % next line needed only for matlab verion 7 (solves recursion bug)
     a = findobj(f,'type','axes');  if length(a)==5 delete(a(5)); end;
  end;
  plt('cursor',get(getappdata(f,'axis'),'user'),'xylim',xyLim);
  figure(g);                            % restore focus to main window
end;  
