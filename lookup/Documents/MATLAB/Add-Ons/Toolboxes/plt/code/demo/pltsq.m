% pltsq.m -------------------------------------------------------------
%
% pltsq approximates a square wave by adding up the first five odd
% harmonics of a sine wave. The plot displays successive sums of these
% harmonics which approximates a square wave more closely as more harmonics
% are added together. The key point however (and the reason this demo was
% created) is that the amplitudes of these sine waves and sums are continually
% varied (periodically between plus and minus one) to produce a "real-time"
% moving display. plt is well suited to creating real-time displays, but there
% are a few concepts to learn and this demo is an excellent starting point.
% - Demonstrates how you can add GUI controls to the plt window - typically
%   something you will need to do when creating plt based applications.
% - 5 pseudo popup controls are added to the figure to the left of the plot
%   including one "super-button" to start and stop the plotting.
% - The main display loop is only 6 lines long (lines 96-101) and runs as fast
%   as possible (i.e. with no intentional pauses.) Once every second an
%   additional 10 lines of code is run (lines 85-94) to check for new user
%   input and to report on the display update rate. This additional code could
%   be run every for every display update, but that would needlessly slow down
%   the update rate.
% - A text object appears below the plot which displays "updates/second" - 
%   a good measure of computational & graphics performance. The update rate
%   is smoothed by averaging the last 4 seconds of data.
%   The color of this text object is toggled every time it is refreshed so that
%   you can tell the speed is being recomputed even if the result is the same.
% - The 'xy' argument is used to make room for the pseudo popups as well as for
%   the wider than usual TraceIDs.
% - The position coordinates for the checkbox and the five popups are grouped in
%   a single array (lines 59-61) which makes it easy to update these coordinates
%   with the plt move function. For details on how the plt move function, refer
%   to the gui1 & gui2 examples.
% - Normalized units are used here for the uicontrols. The "plt move function
%   also handles pixel units which is better if you don't
%   want the objects to change size when the figure window is resized.
% - The cursor callback parameter ('moveCB') and the plt('rename') call are
%   used to provide simultaneous cursor readouts for all 5 traces in the
%   TraceID box. This is an unusual use of the TraceID box, but it serves as an
%   alternative to the "multiCursor" option when you prefer less clutter inside
%   the plot axis. Updating the TraceID box for every display update would slow
%   the display, so normally the cursor is not updated after every display update.
%   However if you want the cursor to be updated on every display, check th box
%   labeled "Live cursor".
% - The 'Options' argument is used to turn off grid lines and to remove the
%   x and y-axis Log selectors from the menu box.
% - You can use the Erasemode popup to explore the effect of the erasemode line
%   property on drawing speed. (The erasemode property is no longer supported in
%   Matlab version R2014b or later, so pltsq.m checks the Matlab version and
%   disables the popup appropriately.) You can also effect the drawing speed
%   by varying the number of points per plot from a low of 25 points to a
%   high of 51200 points (32 cylces times 1600 points per cycle). 

% ----- Author: ----- Paul Mennen
% ----- Email:  ----- paul@mennen.org

function pltsq(go)                      % pltsq(0) or with no arguments, starts stopped
  if ~nargin go=0; end; go = ~~go;      % pltsq(1) or pltsq('run') starts running
  S.tr = plt(0,[0 0 0 0 0],'Options','Ticks/-Xlog-Ylog I',...
    'xy',[0 .184 .093 .797 .89; -1 .01 .81 .13 .18],'moveCB',@curCB,...
    'Xlim',[0 4*pi],'Ylim',[-1.05,1.05],'LabelX','Cycles','LabelY','' );
  p = [.05 .67 .10 .1; .01 .20 .10 .4;   % positions: start button & speed popup
       .01 .22 .10 .3; .01 .14 .10 .3;   % positions: cycles and # of Points popups
       .01 .16 .12 .2; .01 .68 .11 .04]; % positions: eraseMode popup, Live cursor checkbox
  S.go  = plt('pop',p(1,:),{'start' 'stop'},'callbk',{@gCB 0},'swap',0);
  S.spd = plt('pop',p(2,:),2.^(0:10),'labely','Speed','index',6);
  S.cyc = plt('pop',p(3,:),2.^(0:5),'callbk',@gCB,'labely','Cycles');
  S.pts = plt('pop',p(4,:),25*2.^(0:6),'callbk',@gCB,'labely','Points/cycle','index',3);
  S.era = plt('pop',p(5,:),{'normal' 'background' 'xor' 'none'},'labely','EraseMode','index',2);
  S.cur = uicontrol('units','norm','pos',p(6,:),'style','checkbox','str','Live cursor','user',1);
  S.ups = text(.13,-.07,'','units','norm','fontsize',13,'user',0);
  set(gcf,'user',S);  gCB;               % save graphics handles & initialize plot
  plt('pop',S.go,'index',-go-1);         % start running if go is 1
% end function pltsq

function gCB(in1)                                 % callback function for all controls
  S = get(gcf,'user'); m = get(S.ups,'user');     % m is the last used phase
  if strcmp(get(gcbo,'str'),'start') return; end; % we just hit "stop". Nothing more to do.
  if ~nargin set(S.cur,'user',1);                 % indicate that we should reposition the cursor 
             if plt('pop',S.go)>1 return; end;    % already running; no futher action needed.
  end;
  g = gcf;  creqSV = get(g,'CloseReq');           % save the close request function
  set(g,'CloseReq','delete(findobj(''str'',''Live cursor''));');
  er=version;  er=str2num(er(1:3))<8.4;           % erase mode used with R2014a & earlier
  b=0;  c=0;  n=0;  Pts=0;  tic;
  while ishandle(S.cur) & (plt('pop',S.go)>1 | ~c)
    if ~mod(n,200)                                % after every two hundred updates
      live = get(S.cur,'value');                               % true for live cursor
      Pts = str2num(get(S.pts,'string'));                      % Points per cycle
      speed=2^plt('pop',S.spd)/1e4; Ncyc=2^plt('pop',S.cyc)/2; % phase rate of change & # of cycles
      x = [0:1/Pts:Ncyc]; set(S.tr,'x',x,'y',0*x+1.02);        % initialize x axis values
      plt('cursor',-1,'xlim',[0 Ncyc]);                        % adjust x axis limits
      y = zeros(5,length(x)); v=y(1,:); c=1;  b=1-b;           % toggle color
      for k=1:5 v=v+sin(2*pi*c*x)/c;  c=c+2; y(k,:)=v; end;    % compute all 5 harmonics
      if er set(S.tr,'Erase',get(S.era,'String')); end;        % set trace erase mode
      set(S.ups,'color',[b 1 .5],'string',sprintf('%.2f updates/sec',n/toc));
    end;
    a = cos(speed*m);  m=m+1;  n=n+1;             % update amplitude, phase & speed counter
    for k=1:5 set(S.tr(k),'y',a*y(k,:)); end;     % update trace values
    if get(S.cur,'user') set(S.cur,'user',0);     % if Pts or Ncyc has changed, then
                         plt cleft -1 peakval 2;  % move the cursor to the highest peak
    end;
    if live plt cursor; end; drawnow; t=toc;      % update cursor if live
  end;
  set(g,'CloseReq',creqSV); set(S.ups,'user',m);  % restore CloseReq function & save current phase
% end function gCB

function curCB(a,b)                               % cursor callback
  S = get(gcf,'user');  if isempty(S) return; end;
  [xy m] = plt('cursor',0,'get');                 % get cursor index (m)
  for k=1:5 v = get(S.tr(k),'y'); y(k)=v(m); end; % get y value for each trace
  t = 'Fund %5v ~, + 3rd %5v ~, + 5th %5v ~, + 7th %5v ~, + 9th %5v';
  plt('rename',prin(t,y));
% end function curCB
