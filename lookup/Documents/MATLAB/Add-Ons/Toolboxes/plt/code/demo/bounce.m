% bounce.m -----------------------------------------------------------
%
% - This function displays many of markers with random shapes and
%   colors starting at the plot origin and then randomly walking
%   around bouncing off the walls. Click on the "Walk/Stop" button
%   to start and stop the motion.
% - plt creates 513 line objects. All but the last line object are for
%   displaying the markers (each marker displayed is actually a line
%   object containing just a single point). You can control how many of
%   these markers are visible and in motion. The last line object is
%   used to display the arrows representing the velocity of each marker
% - The popup control on the left controls the size of the velocity arrows.
%   This popup was created using the "super button" mode which means you
%   just click on the popup to advance to the next larger size. After
%   "large" it will wrap around to "none" (which inhibits the display
%   of the velocity arrows). If you want to actually open the pop menu
%   to observe your choices, simply right click on the popup. As with
%   the other controls, you may modify the control even while it is walking.
% - The input argument determines how long the display will run. If no
%   input argument is provided, it will do 50 display updates before stopping.
%   bounce(0) will run forever (or until you press "Stop").
% - While the display is walking, the number of updates per second
%   is computed and displayed in the figure title bar.
%   Even while the display is walking, you can change the number of
%   markers that are visible and moving. (The slider below the plot).
%   It initializes to 128 markers when the program starts.
% - The slider on the left controls the walking speed. This isn't the
%   update rate (which actually proceeds as fast as possible), but it
%   actually controls how far each marker moves between each display update.
% - Shows how to set line properties using cell arrays.
% - Shows how plt can avoid its 99 trace limit by disabling TraceIDs.
% - Demonstrates how to create moving displays by changing the trace
%   x/y data values inside a while loop.

% ----- Author: ----- Paul Mennen
% ----- Email:  ----- paul@mennen.org

function bounce(steps)         % steps specifies the # of display iterations on startup
  if ~nargin steps = 50; end;  % If steps not specified, the default is 50 steps
                               % to run forever, call with steps=0
  mx = 512;                    % maximum number of markers
  colors  = {'red';'green';'blue';'yellow';'magenta';'none'}; % marker colors
  markers = {'o';'>';'<';'^';'v';'x';'+';'square';'diamond'}; % marker styles
  S.L = plt(0,zeros(1,mx),'TraceID',[],'LabelX','','LabelY','',...
       'Options','Ticks-X-Y','Xlim',[-1 1],'Ylim',[-1 1],...
       'TraceC',[.2 .6 1],'XYaxc',[.3 .3 .3],'markersize',10,...
       'MarkerFaceColor',colors(ceil(6*rand(1,mx))),...   % random face color
       'MarkerEdgeColor',colors(ceil(5*rand(1,mx))),...   % random edge color
       'Marker',         markers(ceil(9*rand(1,mx))),...  % random marker type
        0,0);                                             % velocity arrows
  set(S.L(end),'color',[1 1 1]/5);                        % set velocity arrow color
  S.S = plt('slider',[.03 .50 .025 .35],[30 1 200],'speed','',2);
  S.N = plt('slider',[.40 .01 .21 .034],[128 10 mx 2 mx],'#points','',2);
  S.A = plt('pop',[.005 -.2 .08 .18],{' none ' '  tiny  ' ' small ' 'medium' ' large '},...
           'LabelY','Arrows','Index',2);
  S.B =uicontrol('string','Walk','units','norm','pos',[.015 .94 .06 .04],'callback',@walk);
  set(gcf,'user',S,'tag','bounce');
  if ~ishandle(S.B) return; end; % in case it was closed during pause
  walk(steps-1)                  % start it going
% end function bounce

function walk(steps,arg2)                    % Walk button callback ---------
  if nargin>1 steps=-1; end;                 % go forever if it's a callback
  S = get(gcf,'user');
  if get(S.B,'user') set(S.B,'user',0,'string','Walk'); return;
  else               set(S.B,'user',1,'string','STOP');
  end;                                       % toggle walk/stop button
  mx = length(S.L)-1;                        % max number of markers
  w = complex(rand(mx,1),rand(mx,1))-.5-.5i; % random marker velocities
  p = [];  v = [];  l = [];  c = 0;  tic;
  while steps & ishandle(S.B) & get(S.B,'user') % while walking do ...
    steps = steps-1;  c = c+1;                  % count update steps
    n = plt('slider',S.N);                      % get number of markers
    if length(l)~=n  l = S.L(1:n);  w(1:length(v)) = v;  v = w(1:n);
                     set(S.L,'vis','off'); set(l,'vis','on');
                     px = get(l,'x');  py = get(l,'y');  p = complex([px{:}],[py{:}])';
    end;
    p = p + plt('slider',S.S)*v/1000;                       % update positions
    set(l,{'x'},num2cell(real(p)),{'y'},num2cell(imag(p))); % move markers
    a = plt('pop',S.A);                                     % get arrow size
    if a>1 q = Pquiv(p,a*v/5);                              % here if arrows are on
           set(S.L(end),'x',real(q),'y',imag(q),'vis','on');
    else   set(S.L(end),'vis','off');                       % here if arrows are off
    end;
    xout = 2 * (abs(real(p)) > 1);                 % negate Vx if x out of bounds
    yout = 2 * (abs(imag(p)) > 1);                 % negate Vy if y out of bounds
    v = v - complex(xout.*real(v), yout.*imag(v)); % new velocities
    if ~mod(c,50)                                  % show update rate every 50 steps
      ups = sprintf('bounce: %.2f updates/sec',c/toc);
      if ~strcmp(get(gcf,'tag'),'bounce') return; end; % don't update wrong figure
      set(gcf,'name',ups);                         % put it in the title bar
    end;
    drawnow;
  end;  % end while
  if ishandle(S.B) set(S.B,'user',0,'string','Walk'); end;
% end function walk
