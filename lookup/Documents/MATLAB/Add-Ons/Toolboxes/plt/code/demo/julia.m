% julia.m -------------------------------------------------------------------------
%
% The intent of this example is to demonstrate the generality of the image
% pseudo object by including two of these objects in a single figure, and to
% demonstrate the use of the 'Fig' parameter as well as several other
% graphical programming techniques. You would be right to be skeptical that
% the world needs another Julia set grapher given that it would not be
% difficult to find hundreds of such programs designed for this same task.
% So my goal was to take advantage of the power of the plt plotting package
% to show how fun it can be to explore Julia sets and to make this application
% more compelling than any similar application out there. I'll let you be the
% judge how well I have met this challenge.
%
% Julia set images are traditionally generated with the repeated application of
% the equation z = z^2 + c  (z and c are complex). This application also allows
% exponents other than 2 (called the generalized Julia set). The color of the
% image is determined by the number of iterations it takes for the magnitude of
% z to grow larger than some fixed value (2.0 for this program). The Mandelbrot
% set uses the same equation and the same color assignment method, but differs
% in how the equation is initialized.
%
% Some very basic instructions appear in the figure when the application starts
% but this help text disappears as soon as you click anywhere in the plot region.
% For a more complete description of this application, click on the Help tag in
% the menu box (near the lower left corner of the left hand image), or follow the
% link included in "Programming Examples" section of the help file.

% ----- Author: ----- Paul Mennen
% ----- Email:  ----- paul@mennen.org

function julia(in1)
  VerString = 'Ver 01Jan17';
  x = [-2 0.57];  y = [-1.20 1.20];   % axis limits for Mandelbrot set
  v = version;  v = sscanf(v(1:3),'%f');
  if v<8.4  yi = .67i; else  yi = .59i; end;
  if v<7  dp = 10; else dp = 50; end; % matlab v6 runs slower (main loop), so use smaller depth
  xy = {[ -3 .093 .110 .395 .84+yi;   -2 .010 .010 .034 .130];  %  left plot positions
        [ -3 .593 .110 .395 .84+yi;   -2 .530 .030 .032 .110;   % right plot positions
          231 .103 .044 .083 .030;    229 .398 .044 .083 .030;
          230 .103 .007 .083 .030;    228 .398 .007 .083 .030;
          208 .603 .044 .083 .030;    206 .898 .044 .083 .030;
          207 .603 .007 .083 .030;    205 .898 .007 .083 .030]};
  p = {[.200 .010 .04 .023]; [.345 .96 .03 .025]; [.459 .96 .03 .025]; [.035 .159 .03 .025];
       [.035 .193 .03 .025]; [.163 .96 .05 .028]; [.220 .96 .05 .028]};   % control positions
  lbl = {{'+ ',[.01 .058],'fontw','bold'} {'i  ',[.008 .057],'fontw','bold'}};
  p1 = 'pos';  p2 = [1150 660];  opt = {'T-X-Y-G' 'T-X-Y-F-H'};
  for n=1:2                                    % create left/right plots
    pltinit(p1,p2,0,0,'xlim',x,'ylim',y,'LabelY','','FigBKc',121216,'xy',xy{n},'EnaPre',[0 0],...
        'AxisCB',{@frac n},'MotionZoom',{@zom n},'MotionZup',{@syn n},'Options',opt{n},...
        'MoveCB','plt helptext;','HelpFile','plt.chm::pltfiles/Programming with plt/julia.htm');
    S(n).ax = gca;  S(n).cid = get(gca,'user');  setappdata(gca,'lim',[x y]); 
    S(n).mag = text(.41,-.105,'','units','norm','color',[.8 .8 0],'buttond',{@mag n},'user',0);
    cb = {@frac n};  h = plt('cursor',-n,'obj');  S(n).cex = h(3:6);  S(n).box = h(11);
    p1 = 'Fig'; p2 = gcf;  q = [(n-1)/2 0 0 0]; % 0.5 offset between left/right images
    S(n).chk = uicontrol('units','norm','pos',p{1}+q,'style','CheckBox','str','Sync','Enable','ina',...
                'buttond',{@syn n},'BackGr',[4 4 5]/60,'ForeGr',[4 4 5]/6,'Value',1);
    S(n).pix = plt('edit',p{2}+q, 1,'callbk',cb,'label','Pixels~/bit ');
    S(n).ups = plt('edit',p{3}+q,10,'label','Updates/s~ec');
    S(n).dep = plt('edit',p{4}+q,dp,'callbk',cb,'label','De~pth');
    S(n).exp = plt('edit',p{5}+q, 2,'callbk',cb,'label','Ex~p');
    S(n).cr  = plt('edit',p{6}+q, 0,'callbk',cb,'label',lbl{1},'format','%.4g','incr',.01,'fontsize',10,'enable',-1);
    S(n).ci  = plt('edit',p{7}+q, 0,'callbk',cb,'label',lbl{2},'format','%.4g','incr',.01,'fontsize',10,'enable',-1);
    S(n).pop = plt('pop', p{7},{''},'callbk',{@frac -n});
  end;
  text(-.23,-.115,VerString,'units','norm','color',[.3 .3 .3],'fontsize',8);
  set(findobj(gcf,'str','y'),'user',['%12w'; '%12w']);        % change cursor format strings
  set(findobj(gcf,'style','push'),'vis','off');               % we don't need peak/valley buttons
  set(gcf,'pos',figpos([1400 660]));                          % if wide screen, make the figure wider
  S(1).toc = 1e-9;  set(gcf,'user',S);  pop(1);  pop(2);      % initialize popup choices 
  tic; frac(1); frac(2);                                      % measure time for 48 iterations
  S(1).toc = toc/2; set(gcf,'user',S);                        % save timing information
  plt('HelpText','on',...
    {'The essential mouse action you need for' 'this application is the "Double Click & Drag"' ...
     'which opens a zoom box allowing you'     'to see the Julia sets in more detail.' ...
     '(An alternative is the single'           'click & drag while holding' ...
     'down the shift key.)' -1.25+.99i         'color' 'white' 'fontsize' 13 -2i ...
     'For more complete help with'             'this application, click on the' ...
     'Help tag near the lower left'            'corner of the figure window' -1.25+.17i});

function y0 = terp(x,y,x0);           % linear interpolation
  y0 = interp1(x,y,x0,'linear','extrap');

function pop(n)
  S = get(gcf,'user'); S = S(n);  ex = plt('edit',S.exp);  p = [.062+(n-1)/2 .545 .1 .43];
  if ex==2 % define 14 Julia set constants (more extensive for traditional squared equation)
    c = [.284+ .01i    0.90  1.25 50;  -.12 - .77i   1.40  1.18 50;    -1           1.70 0.85 20;
         .258          1.00  1.20 50;   -.79 + .15i  1.70  0.95 50;   -0.7 - .38i   1.70 1.00 40;
         -.4 + .6i     1.50  1.11 50;  -0.73 + .18i  1.70  1.00 50;   -.39 - .59i   1.50 1.10 20;
         -.62 + .43i   1.60  1.00 50;  -1.48         1.90  0.60 25;   -.6           1.55 1.00 50;
         -.16 + 1.04i  1.90  1.50 15;  1i            1.50  1.35 12];
  else    % define 4 Julia set constants for other exponents
    p = p + [0 1 0 -1]*.22; % reduce the height of the popup menu
    c = [.284 + terp(2:8,[1 70.6 74 70 63.4 69 78]*.01i,ex)                         1.2  1.25 50;
         -.12 + terp(2:8,[77 100 80 70 81 81 76]*.01i,ex)                           1.35 1.27 50;
         round(1e6*exp(1i*pi/(ex-1)))/1e6 ...
         terp(2:5,[1.7 1.3 1.15 1.15],ex)  terp(2:5,[.85 1.35 1.18 1.18],ex)                  20;
         terp(2:8,[258 389 476 538 585 622 655]/1000,ex)                            1.20 1.20 50];
  end;
  set(S.chk,'user',c); if plt('pop',S.pop) > length(c)+1 plt('pop',S.pop,'index',2); end;
  plt('pop',S.pop,'pos',p,'choices',prin('Mandelbrot ~; {c = %j5w!col}',c(:,1)));

function syn(n,a,b) % MotionZup and sync checkbox callbacks
  if nargin>2       % here for sync checkbox
    n = b;  mouse = get(gcf,'SelectionT');
    if mouse(1)=='n' set(gcbo,'value',1-get(gcbo,'value')); return; end;
  end;
  S = get(gcf,'user'); m = 3-n;  T = S(m);  S = S(n);   bx = S.box;
  if nargin<3 & ~get(S.chk,'value') return; end;
  if strcmp(get(bx,'vis'),'on') x=get(bx,'x'); y=get(bx,'y'); x=x(1:2); y=y(2:3);
  else                          x = get(S.ax,'xlim');  y = get(S.ax,'ylim');
  end;
  setappdata(T.ax,'lim',getappdata(S.ax,'lim'));
  plt('edit',T.exp,'val',plt('edit',S.exp));
  plt('pop',T.pop,'index',plt('pop',S.pop));  set(T.pop,'str',get(S.pop,'str'));
  e = plt('edit',S.cr,'get','enable');  plt('edit',T.cr,'enable',e,'val',plt('edit',S.cr));
  plt('edit',T.ci,'enable',e,'val',plt('edit',S.ci));  plt('cursor',T.cid,'xylim',[x y]);

function zom(n,lim) % MotionZoom callback
  S = get(gcf,'user'); m = 3-n;  T = S(m); S = S(n); if ~get(S.chk,'value') return; end;
  if length(get(T.mag,'str')) % if 1st time, copy data from source image to target image
    if strcmp(get(T.box,'vis'),'on') plt('cursor',T.cid,'restore'); end; % box off
    imgS = findobj(S.ax,'type','image');  imgT = findobj(T.ax,'type','image');
    props = {'Cdata' 'X' 'Y'};  set(imgT,props,get(imgS,props));  set(T.mag,'str','');
  end;
  set(T.ax,'xlim',lim(1:2),'ylim',lim(3:4));

function mag(a,b,n) % callback for magnitude text object
  S = get(gcf,'user'); S = S(n);  ax = S.ax;  mouse = get(gcf,'SelectionT');
  if strcmp(get(S.box,'vis'),'on') plt('cursor',S.cid,'restore'); end; % box off
  if mouse(1)=='n' x = get(ax,'xlim'); y = get(ax,'ylim');  % here for left click
                   x = mean(x) + 5*diff(x)*[-1 1];   y = mean(y) + 5*diff(y)*[-1 1];
  else             x = getappdata(ax,'lim'); y=x(3:4); x=x(1:2); % here for right click
  end;
  plt('cursor',S.cid,'xylim',[x y]);

function frac(n)   % draw the fractal -----------------------------------------------
  S = get(gcf,'user');  dt = S(1).toc;  S = S(abs(n));  f = plt('pop',S.pop)-1;
  mag = S.mag;  ax = S.ax;  img = findobj(ax,'type','image');
  ex = plt('edit',S.exp);  exl = [getappdata(gcf,'ex') 0];  exl = ex ~= exl(1);
  if n < 0 | exl
    if exl pop(abs(n)); f = plt('pop',S.pop)-1; end;
    setappdata(gcf,'ex',ex); u = get(S.chk,'user');
    if f  c = u(f,1);  set(S.pop,'str','Julia set constant:');
          xy = u(f,[2 2 3 3]) .* [-1 1 -1 1];    dp = u(f,4);  e = 1;
    else  c = 0;  dp = 50;  e = -1;  x = [-2 -1 -.5 1.5 2:7];
          xy = terp(x,  [22 22 23 7.4 12 13.5 12  10 12 12],ex);
          xy = [terp(x,-[22 22 22 3   20  8  13.5 10 12 12],ex) ...
                terp(x, [22 22 15 3.5 5.7 8  9.3  10 12 12],ex) -xy xy]/10;
    end;
    plt('cursor',S.cid,'xyLim',xy);  setappdata(ax,'lim',xy);
    plt('edit',S.cr,'enable',e,'val',real(c));    plt('edit',S.ci,'enable',e,'val',imag(c));
    if n<0 if strcmp(get(S.box,'vis'),'on') plt('cursor',S.cid,'restore'); end; % box off
              plt('edit',S.dep,'val',dp);  n = -n;
    end;
  else  xy = [get(ax,'xlim') get(ax,'ylim')];
  end;
  if f c = complex(plt('edit',S.cr),plt('edit',S.ci)); else c = 0; end;
  mg=getappdata(ax,'lim');  mg = diff(mg(1:2))*diff(mg(3:4)) / (diff(xy(1:2))*diff(xy(3:4))); % magnification
  exi = get(S.mag,'user') + 1; % exit when this value changes (avoid unneeded recursion)
  set(mag,'str',prin('Magnification: %5w',mg),'user',exi);
  axx = get(ax,'Xlabel');  pix = plt('edit',S.pix);  set(S.cex,'backgr',[.12 .12 .16]);
  md = pix^2 * round(48 / (dt * .93 * plt('edit',S.ups)));  r = get(gcf,'pos').*get(ax,'pos')/pix;
  x = linspace(xy(1),xy(2),r(3));  y = linspace(xy(3),xy(4),r(4));
  set(getappdata(ax,'Lhandles'),'x',x,'y',x);
  if mg>1e5 set(ax,'xTickLabel',[],'yTickLabel',[]); else set(ax,'xTickLabelMode','auto','yTickLabelMode','auto'); end;
  iter = round(plt('edit',S.dep) * mg^.1003433);   % double # iterations when magnification=1000
  [wx wy] = meshgrid(x,y);  w = complex(wx,wy);  z = (abs(w)>2) * iter;  uxy = 0;  k = md;
  if c==0 c = w;  end;                             % for Mandelbrot
  for i = 2:iter
    if get(mag,'user') > exi return; end;          % abort the loop if axis limits changed again
    w = w.^ex + c;   z(abs(w)>2 & ~z) = iter-i+1;  k = k-1;
    if ~k | i==iter if uxy plt('image',img,'z',z); % already set x,y so just set z
                    elseif length(img) plt('image',img,'xyz',x,y,z); uxy = 1;
                    else   img = plt('image',n,x,y,z,{'Cbar' 'Edge' 'Mid'}); % create image object
                           plt('image',img,'Edge',0);  % map complete range to color map
                    end;
                    set(axx,'str',sprintf('%d iterations',i));  k=md;  drawnow;
    end;
  end;
  set(S.cex,'vis','on','backgr',[1 .2 .2],{'str'},prin('{%12w!col}',xy));  plt helptext;
