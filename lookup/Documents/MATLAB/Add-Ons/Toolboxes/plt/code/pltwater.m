% pltwater.m: A general purpose 3D surface (waterfall) display routine
% --------------------------------------------------------------------
%
% Calling sequence: pltwater(z,'Param1',Value1,'Param2',Value2)
%                   All arguments are optional except for z which
%                   is a matrix containing the surface data
%
% Note that the arguments are arranged in Param/Value pairs, however
% you may omit the Value part of the pair, in which case the default
% value of 1 is used.
%
% pltwater recognizes the following 13 Param/Value pairs (case insensitive):
%
% 'go',1      : The animation begins immediately as if you had pressed the start button.
% 'go'        : The same as above (since an omitted value is assumed to be one).
% 'run'       : The same as above. Note that all the sliders and check boxes mentioned
%               below may be adjusted even when the display is running (animation).
% 'invert'    : The surface is displayed upside down.
% 'transpose' : The surface is rotated by 90 degrees (x/y swapped).
% 'delay',v   : A pause of v milliseconds occurs between display updates. Whatever
%               value (v) is supplied, it may be changed later using the slider.
% 'nT',v      : Determines how many traces will be visible initially. Later you
%               may change the number of visible traces using the slider. If the
%               nT parameter is not included, 40 traces will be used (initially).
% 'skip',v    : Initially v records (rows of z) are skipped between each record access.
%               (e.g. if v=1 only every other record is used.) This value may be
%               modified using the slider.
% 'dx',v      : Successive traces of the waterfall display are displaced by v pixels
%               to the right which adds a visual perspective. (No perspective is
%               percieved if v is zero.) This value may be modified with the slider.
% 'dy',v      : Successive traces of the waterfall display are displaced in the vertical
%               direction by v percent of the Zaxis limits. This value may be modified
%               using the slider.
% 'x',v       : Specifies the x values corresponding to each column of z.
%               If this parameter is not supplied, the value 1:size(z,2) is used.
% 'y',v       : Specifies the y values corresponding to each row of z.
%               If this parameter is not supplied, the value 1:size(z,1) is used.
% 'smooth',v  : Line smoothing is a line property in most versions of matlab (although
%               it is not supported in R2014b or later). If this parameter is not included
%               then line smoothing is enabled when the display is running (animating)
%               and is disabled otherwise. That behavior may be modified as follows:
%               'smooth', 1: Line smoothing is always enabled
%               'smooth',-1: Line smoothing is always disabled
%               'smooth', 0: The default line smoothing mode as described above.
%               If you are using a version of Matlab that doesn't support line smoothing,
%               pltwater will not enable line smoothing mode regardless of the setting
%               of this parameter.
%
% If a parameter is included in the pltwater argument list that is not one of the
% above 13 choices, then this parameter along with its corresponding value are
% passed onto plt. The most common plt parameters used in the pltwater argument list are:
%
% 'TraceC'   'CursorC'    'FigBKc'  'LabelX'  'LabelY'   'Title'
% 'FigName'  'Linewidth'  'Pos'     'xy'      'HelpText'

%
% ----- Author: ----- Paul Mennen
% ----- Email:  ----- paul@mennen.org

function pltwater(varargin)
  if ~nargin
     fg = getappdata(0,'gSV');
     if isempty(fg) disp('Usage: pltwater(z,''Param1'',''Value1'',''Param2'',''Value2'',...)');
                    return;
     end;
     rmappdata(0,'gSV');
     S = get(fg,'user');         % here for close request function
     plt('pop',S.go,'index',1);  % stop on attempted close
     set([S.bx S.ups],'user',0);
     if S.Vsmooth==0 set(S.tr,'LineSmoothing','off'); end;
     return;
  end;
  z = varargin{1};    % first argument is always the data to plot
  if length(z)==1     % Cursor callback ------------------------------------
    S = get(gcf,'user');    if ~isstruct(S) return; end;
    cid = varargin{2};
    xy = plt('cursor',cid,'get');
    [tn hl] = plt('cursor',cid,'getActive');
    h  = plt('cursor',cid,'obj');
    set(h(3),'str',Pftoa('%7w',real(xy)-(tn-1)*S.ddx));
    set(h(5),'str',Pftoa('%7w',imag(xy)-get(hl,'user')));
    nT = plt('slider',S.nt);  skip = plt('slider',S.skip) + 1;
    i = get(S.ln,'user') - skip*(nT-tn+1);  if i<1 i = i+S.rec; end;
    set(S.ycur,'str',Pftoa('%7w',S.y(i)));
    return;
  end;
  go=0;  Vinv=0; Vtrn=0; Vdly=0;   Vnt=40; Vskp=0; Vdx=5; Vdy=5; Vsmooth=0;
  Vx=[]; Vy=[];  Vxy=[];
  if exist('go') args = dbstack; args = args(min(2,end)).name; else args = 'pltwater'; end;
  args = {'TraceC' [0 1 0] 'FigName' args 'FigBKc' 141414 ...
          'TraceID' '' 'Pos' [1000 720] 'LabelY' 'Z axis' 'CursorC' [1 1 0] ...
          'HelpFileR','pltwater(1)'};
  k = 2;              % process the rest of the arguments
  while k <= nargin   % continue as long as there are more arguments to process
    a = varargin{k};  k = k+1;                                  % get Param
    if k <= nargin    v = varargin{k}; val=v;                   % get Value if it is there
                      if ischar(val) val=1; else k = k+1; end;  % Value missing. Assume 1 (default)
    else              val = 1;                                  % Value missing. Assume 1 (default)
    end;
    switch lower(a)
      case {'go','run'},  go      = val;
      case 'invert',      Vinv    = val;
      case 'transpose',   Vtrn    = val;
      case 'delay',       Vdly    = val;
      case 'nt',          Vnt     = val;
      case 'skip',        Vskp    = val;
      case 'dx',          Vdx     = val;
      case 'dy',          Vdy     = val;
      case 'x',           Vx      = val;
      case 'y',           Vy      = val;
      case 'xy',          Vxy     = val;
      case 'smooth',      Vsmooth = val;  %  0: Turns smoothing on only when running
                                          %  1: Turns smoothing on all the time
                                          % -1: Leaves smoothing off all the time
      otherwise, args = [args {a v}];  if ischar(v) k=k+1; end;
    end;
  end;        % end while

  S.z    = z;
  S.sz   = size(z,2);                        % length of each trace (x-axis)
  S.rec  = size(z,1);                        % number of data records (y-axis)
  S.zlim = [min(z(:)) max(z(:))];            % z axis scaling
  if isempty(Vx) Vx = 1:S.sz;  end; S.x = Vx;
  if isempty(Vy) Vy = 1:S.rec; end; S.y = Vy;
  if length(Vx)~=S.sz  disp('x vector must be the same length as a row of z'); return; end;
  if length(Vy)~=S.rec disp('y vector must be the same length as a column of z'); return; end;
  w = repmat(zeros(S.sz,1),1,100);           % define 100 traces
  opt = 'Ticks -X -Y';
  if Vsmooth==1 opt = [opt 'Linesmooth']; end;
  p = [  1 .173 .120 .815 .86;  302 .47  -.1   0   0;  % main plot, x-axis label
        -2 .007 .090 .042 .17;                         % menubox
       210 .165 .005 .02  .03;  208 .19 .005 .07 .03;  % x cursor label/value
       209 .765 .005 .02  .03;  206 .79 .005 .07 .03]; % y cursor label/value
  if length(Vxy)
    if length(Vxy)==4 Vxy = [1 Vxy]; end;
    p = [p; Vxy];
  end;
  S.tr = pltinit(w,w,'xy',p,'Options',opt,'moveCB','pltwater(0,@CID)',args{:});
  set(findobj(gcf,'markersize',8),'marker','o');
  set(findobj(gcf,'str','Yval'),'vis','off');
  set(findobj(gcf,'str','y'),'str','z');
  h = plt('cursor',get(gca,'user'),'obj');     % get cursor objects
  pp = {'units','pos','sty','backgr','foregr','fontsize','ena'};
  S.ycur = uicontrol;  p = get(h(3),pp);  p{2}(1) = p{2}(1)+.11;  set(S.ycur,pp,p);
  S.ylbl = uicontrol;  p = get(h(1),pp);  p{2}(1) = p{2}(1)+.11;
  set(S.ylbl,pp,p,'str','y','buttond',@start3);
  set(h(1),'buttond',get(get(gca,'xlabel'),'buttond'));
  % disable linesmooth toggling if the property doesn't exist
  if ~exist('isprop') | ~isprop(S.tr(1),'LineSmoothing') Vsmooth = -1; end;
  S.Vsmooth = Vsmooth;
  S.ax = gca;  c = [1 1 1]/20;
  S.bx = axes('pos',[.173 .055 .785 .024],'ylim',[-1 1],'color',c,'xcolor',c,...
              'ycolor',c,'XtickLabel',' ','YtickLabel',' ','TickLen',[0 0]);
  S.t1 = text(0,0,'','color',[0 1 0],'horiz','right','user',1);
  S.t2 = text(0,0,'','color',[1 0 0]);
  S.ln = line(0,0,'color',[1 1 1]/3,'linewidth',16,'user',1);
  set([S.bx S.t1 S.t2 S.ln],'buttond',@start2);
  axes(S.ax);
  p = [92 84 76 40 32]/100; p = num2cell([.01+0*p; p]',2); % slider xy positions
  q = [6 19 7.1 3]/100;  q = {q; q-[0 .04 0 0]};
  S.go   = plt('pop',[.04 -.868 .1 .1],{' start ' ' stop '},'index',go+1,'callbk',@start);
  S.dly  = plt('slider',p{1},[Vdly 0 999],'delay (ms)','',2);
  S.nt   = plt('slider',p{2},[Vnt  3 100 1 100],'# of traces',@start,2);
  S.skip = plt('slider',p{3},[Vskp 0 20],'skip records',@start,2);
  S.dx   = plt('slider',p{4},[Vdx  0 20 0 99],'Delta X',@start,2);
  S.dy   = plt('slider',p{5},[Vdy  0 40 0 99],'Delta Y',@start,2);
  S.ups  = text(.86,-.115,'','units','norm','color',[.6 .6 .6],'fontsize',9,'user',0);
  S.inv  = uicontrol('str','invert','val',Vinv,'user',Vinv);  % user data shadows value
  S.trn  = uicontrol('str','transpose','val',Vtrn);           % user data shadows value
  setappdata(S.go,'repeat',-1);         % disable buttondown repeat
  set([S.inv S.trn],'sty','check','user',0,'units','norm','callback',@start,{'pos'},q);
  set(S.tr,'z',zeros(1,S.sz)+NaN);      % initialize z data
  set(S.tr(1),'user',0);                % initialize count (# of plot updates)
  set(gcf,'user',S);
  start;                                % initialize the plot
  plt helptext on;  % show help text
  a = get(gca,'pos');
  text(.334,a(4)/17-.112,'<-------------------- Y axis -------------------->',...
       'units','norm','color',[1 .6 0],'user',355/113);
% end function pltwater

function start2(a,b)
  set(gcf,'WindowButtonMotionFcn',@start,...
          'WindowButtonUpFcn','set(gcf,''WindowButtonMotionFcn'','''');');
  start;

function start3(a,b)                             % y cursor label callback -----------------
  rpt = getappdata(gcf,'repeat');                % get custom repeat rate
  if length(rpt)>1 p=rpt(2); else p = .4;  end;  % 2nd element is repeat delay (default = .4 sec)
  if length(rpt) rpt=rpt(1); else rpt=.02; end;  % 1st element is repeat rate (default = 50Hz)
  setappdata(gcf,'bdown',1);
  set(gcf,'WindowButtonUp','setappdata(gcf,''bdown'',0);');
  while getappdata(gcf,'bdown') % loop until user lets go of mouse
    start;                      % advance once
    pause(p);  p = rpt;         % repeat rate
  end;

function start(a,b) % start/stop button callback ----------------------------
  S = get(gcf,'user');
  go = plt('pop',S.go);  nT = plt('slider',S.nt);  rn = get(S.ups,'user');
  if go<2 & rn
    set(S.bx,'user',0);
    if S.Vsmooth==0 set(S.tr,'LineSmoothing','off'); end;
    return;
  end;
  j = get(S.t1,'user');    skip = plt('slider',S.skip) + 1;  cbo = gcbo;
  if isempty(cbo) cbo = 0; end;
  if ismember(cbo,[gcf S.ln S.bx S.t1])
    i = get(S.bx,'currentp');  i = max(1,min(round(i(1,1)),S.rec));
    b = round((i - j)/skip);
    if plt('pop',S.go) < 2  &  b >= 0  & b <= nT  nT = b;
    else set(S.ln,'user',i);
    end;
  elseif cbo == S.inv set(S.ln,'user',j);
  elseif cbo == S.ylbl nT = 1;
  end;
  set(S.bx,'user',nT);                               % use bx user as loop counter
  if rn return; end;
  sz = S.sz;  x = S.x;  y = S.y;  f = zeros(1,5);
  dz = diff(S.zlim);
  alter = -1;  m = 0;  wcount = 0;  tic;
  inv=get(S.inv,'user'); trn=get(S.trn,'user');
  set(findobj(gcf,'marker','o','vis','on'),'x',NaN); % hide cursor
  set([S.ups S.t2],'user',1);                        % indicate running, enable run loop
  plt helptext;                                      % remove help text
  if go==2 & S.Vsmooth==0 set(S.tr,'LineSmoothing','on'); end;
  gSV = gcf;   setappdata(0,'gSV',gSV);              % save for the new close request function
  setappdata(gSV,'gSV',get(gcf,'CloseReq'));         % save the close request function
  set(gSV,'CloseReq','pltwater;');                   % stop on attempted close
  while plt('pop',S.go) > 1 | get(S.bx,'user')  % loop until stop button
                                       % clicked, counter expired, or figure close button hit
    set(S.bx,'user',max(get(S.bx,'user')-1,0)); % do first nT loops even if stopped
    set(S.tr(1),'user',get(S.tr(1),'user')+1);  % increment count (# of updates)
    skip   = plt('slider',S.skip) + 1;          % record increment
    nTmax  = floor(S.rec/skip);
    nT     = plt('slider',S.nt);                % number of traces
    dx     = plt('slider',S.dx);                % horizontal steps
    dy     = plt('slider',S.dy)*dz/1000;        % vertical steps (in tenths of a percent)
    dlySec = plt('slider',S.dly)/1000;          % delay in seconds
    if nT>nTmax nT=nTmax; plt('slider',S.nt,'set',nTmax); end;
    nT1 = nT-1;
    if get(S.inv,'val') ~= inv
      S.z = -S.z; S.zlim = -fliplr(S.zlim);
      inv=1-inv; set(S.inv,'user',inv); set(gcf,'user',S);
    end;
    if get(S.trn,'val')~=trn
      S.z = transpose(S.z);  sz = S.rec;  S.rec = S.sz;  S.sz = sz;
      x = S.y;  y = S.x;  S.x = x;  S.y = y;
      w = zeros(1,sz);                        % clear out traces
      set(S.tr,'x',w,'y',w,'z',w+NaN);
      set(S.ln,'user',1);                     % start at the beginning
      trn=1-trn; set(S.trn,'user',trn);
    end;
    alt = dx + dy + nT + inv + trn;           % was the # of Traces, or the
    if alt ~= alter;                          % Delta X/Y sliders moved?
      alter = alt;                            % yes, modify the axis limits
      ylow = ones(1,sz) * S.zlim(1);
      dxi = dx * max(1,floor(sz/500));
      edx = (x(end)-x(1))/(sz-1); ddx = dxi*edx;  S.ddx = ddx;
      set(S.ax,'xlim',x(1)+[-ddx sz*edx+nT*ddx],'ylim',...
          mean(S.zlim) + dz*.51*[-1 1] + [0 nT*dy]);
      set(S.bx,'xlim',[1 S.rec]);
      for k=1:nT set(S.tr(k),'x',x); x=x+ddx; end;  % set new x data
      set(S.tr(k+1:100),'z',zeros(1,S.sz)+NaN);     % hide traces not in use
      set(gcf,'user',S);
    end;
    yc = ylow;  yk = 0;                        % hidden line removal comparison vector
    for k=1:nT1                                % draw all but the last trace
       z = get(S.tr(k+1),'z');                 % get the data from the trace above
       ym = max(yc,z);                         % stay above the trace in front
       yc = ym(dxi+1:end) - dy;                % slide comparison vector to the left
       yc = [yc ylow(1:sz-length(yc))];        % and pad to size sz
       set(S.tr(k),'y',ym+yk,'z',z,'user',yk); % save unclipped data in z axis
       yk = yk + dy;
    end;
    i = get(S.ln,'user');  j = i-nT1*skip;  ji = [j i];  e = f(1:2);
    if j<1 j=j+S.rec; ji = [j S.rec NaN 1 i]; e = f; end;
    set(S.ln,'x',ji,'y',e);                    % indicate which portion of the data is visible
    z = S.z(i,:);   yy = max(yc,z) + yk;
    set(S.tr(nT),'y',yy,'z',z,'user',yk);      % draw last trace
    set(S.t1,'str',prin('%4w ',y(j)),'pos',[j -.1],'user',j);
    set(S.t2,'str',prin(' %4w',y(i)),'pos',[i -.1]);
    i = i+skip; if i>S.rec i=i-S.rec; end;     % advance to next data record (circular)
    set(S.ln,'user',i);
    m=m+1; if ~mod(m,10) set(S.ups,'string',sprintf('%.2f updates/sec',m/toc)); end;
    pause(dlySec); drawnow;                    % delay the selected amount
  end;  % end while plt('pop')
  set(gSV,'CloseReq',getappdata(gSV,'gSV'));   % restore original close request function
  if isempty(getappdata(0,'gSV'))
    v = version;  v = str2num(v(1:3));         % the close crashes under R2009a, so to be careful
    if v<7 | v>= 8.4 close(gSV);  end;         % use it only with verion 6 or with R2014b or later
    return;
  end;
  rmappdata(0,'gSV');
  set(S.ups,'user',0);                         % indicate that the loop has stopped
  plt('cursor');                               % update cursor
% end function start
