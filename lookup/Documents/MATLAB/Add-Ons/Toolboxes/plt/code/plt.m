% plt.m:   An alternative to plot & plotyy
% Author:  Paul Mennen (paul@mennen.org)
%          Copyright (c) 2017, Paul Mennen

function [Ret1,Ret2] = plt(varargin);

global Hhcpy;

Ret1 = 0;
Narg = nargin;
Mver = version;  Mver = sscanf(Mver(1:3),'%f');
MverE = (Mver<8.4);

if ~Narg
  eval('evalin(''base'',''pltdef'','''')');
  w = plt('select','base','who');
  n = length(w);  b = zeros(1,n);
  options = [];
  wstruct = {}; ws=0;
  TraceIDlength = 7;
  for k=1:n
    a = plt('select','base',w{k});
    if length(w{k})>5 & findstr(w{k},'pltopt') options = [options a]; end;
    if strcmp(w{k},'TraceIDlen') TraceIDlength = a;  end;
    if isnumeric(a) & length(a)>3 b(k)=1;
    elseif isstruct(a) & numel(a)==1
      f = fieldnames(a);
      for fn=1:length(f)
        g = getfield(a,f{fn});
        if isnumeric(g) & length(g)>3 ws=ws+1; wstruct{ws} = [w{k} '.' f{fn}]; end;
      end;
    end;
  end;
  w = [w(logical(b)); wstruct'];  nov = length(w);
  if nov<2 disp('Not enough vectors to plot'); return; end;
  spix = get(0,'screenp');
  fontsz = (196-spix)/10;
  spix = spix/80 - .2;
  vspace = round(20 * spix);
  hspace = round(200 * spix);
  set(0,'unit','pix');  ssz = get(0,'screensize');
  nc = fix((ssz(4)-110)/(vspace+.2));
  nov1 = nov+3;  nc = ceil(nov1/nc);
  nr = ceil(nov1/nc);
  wid = nc*hspace+20; hei = nr*vspace+55;
  fig = figure('menu','none','numberT','off','back','off','name','PLT select','color','black','Invert','on',...
               'pos',figpos([inf inf wid hei]));
  axes('xlim',[0 nc],'ylim',[0 nr+1]-.5,'pos',[.02/nc 0 1 1],...
       'color','black','xcol','black','ycol','black');
  hb = hei-25;
  set([uicontrol('str','Plot',    'pos',[ 25 hb 40 21],'call','plt select plot;');
       uicontrol('str','CloseAll','pos',[ 80 hb 60 21],'call','plt close;');
       uicontrol('str','Help',    'pos',[155 hb 40 21],'call','plt help;');
      ],'unit','nor','fontsi',fontsz);
  text(.05,nr-2.2,{'Right click on desired x vectors';
                   'Left click on desired y vectors';
                   'Double click for right hand axis'},...
                   'fonta','ita','fontsi',9,'color',[0 1 .5]);
  txt = zeros(nov,1); sz1=txt; sz2=txt; len=txt; nvec=txt; sxy=txt; yright=txt;
  y=nr-3; x=0;
  for k=1:nov
    y = y-1;  if y<0 y=nr-1; x=x+1;  end;
    sz = size(plt('select','base',w{k}));
    sz1(k)  = sz(1);
    sz2(k)  = sz(2);
    len(k)  = max(sz);
    nvec(k) = min(sz);
    txt(k) = text(x,y,' ');
    set(txt(k),'buttond',['plt(''select'',' int2str(k) ');']);
  end;
  set(fig,'user',[txt sz1 sz2 len nvec sxy yright]);
  setappdata(fig,'w',w);
  setappdata(fig,'opt',options);
  setappdata(fig,'IDlen',TraceIDlength);
  plt select text;
  return;
end;

y1 = varargin{1}; 
if length(y1)==1 & ishandle(y1)
  y2 = varargin{2};
  if isempty(y2) | ~isnumeric(y2)
    hcback = y1;
    varargin(1:2)=[]; Narg=Narg-2;
    y1 = varargin{1};
  end;
end;
if ~ischar(y1)  y1='none'; end;
y1 = lower(y1); y1s = sum(y1);
if y1s==632 & y1(1)~='r' y1s=0; end;
switch y1s
case 640
  v2 = varargin{2};
  if isnumeric(v2) | v2(1) ~= 'b'
      w = getappdata(gcf,'w');  e = get(gcf,'user');
      len = e(:,4); sxy = e(:,6); nov = length(len);
      xk = []; for k=1:nov if sxy(k)<0 xk = [xk k]; end; end;
  end;
  switch sum(v2)
    case 411, Ret1 = eval(['evalin(''base'',''' varargin{3} ''');']);
    case 453,
      lnxk = length(xk);
      for k=1:nov
        s = w{k};  if length(s)>20 s=s(1:20); end;
        s = strrep(s,'_','\_');
        s = [s '  (' int2str(e(k,2)) ',' int2str(e(k,3)) ')'];
        if sxy(k) s = [s ' \leftarrow ']; s2 = int2str(abs(sxy(k)));  end;
        c = [1 1 1];
        if lnxk
          if lnxk==1 s2 = ''; end;
          if ~sxy(k)
            if ~length(find(len(xk)==len(k))) c = .5*c; end;
          elseif sxy(k)<0                 c = [.9 .3 .3]; s = [s 'x' s2];
          else
            if e(k,7)               c = [ 1 .6 .2]; s = [s 'y' s2 'R'];
                      else                c = [ 1  1  0]; s = [s 'y' s2];
                      end;
          end;
        else if e(k,5) ~= 1 c = .5*c; end;
        end;
        if c(3)==.5 | c(3)==1 bold = 'norm'; else bold = 'bold';  end;
        set(e(k,1),'color',c,'fontw',bold,'str',s);
      end;
    case 447
      if ~max(sxy) return; end;
      options       = getappdata(gcf,'opt');
      TraceIDlength = getappdata(gcf,'IDlen');
      opt = [];
      for k=1:length(options)
        t = options{k};
        if   isnumeric(t) v = num2str(t);
             if length(t)>1
               q = v;  v = '[';
               for j=1:size(q,1) v = [v q(j,:) ';']; end;
               v = [v ']'];
             end;
        else v = ['''''' t ''''''];
        end;
        opt = [opt v ','];
      end;
      if length(xk)==1 x = w{find(sxy<0)}; else x = 'X axis'; end;
      right = [];
      ny = 0;
      nvL = 0; nvR = 0;
      func = ['plt(''''LabelX'''',''''' x ''''','];
      id = '''''TraceID'''',[''''';
      for k=1:nov
        if sxy(k)>0
          nvec = e(k,5);
          x = w{find(sxy==-sxy(k))};  y = w{k};
          s2 = strrep(y,'_','\_');
          ss = strrep(y,'_','');
          nn = TraceIDlength - (nvec>1);  s = [];
          if length(ss) > nn
            sp = findstr(ss,'.');
            if length(sp)
              nn1 = min(sp-1,floor((nn-1)/2));
              nn2 = min(nn-nn1-1,length(ss)-sp);
              nn1 = nn - nn2 - 1;
              ss = ss([1:nn1-1 sp-1:sp+nn2-1 end]);
            else
              ss = [ss(1:nn-1) ss(end)];
            end;
          end;
          while length(ss)<nn ss = [ss ' ']; end;
          st = ss;
          for v = 1:nvec
            if nvec>1 ss=[st '0'+mod(v,10)]; end;
            s = [s ss ''''';'''''];
          end;
          if e(k,7) right = [right ny+(1:nvec)]; s2R=s2; nvR=nvR+1; else s2L=s2; nvL=nvL+1; end;
          ny = ny + nvec;
          func = [func x ',' y ','];
          id = [id s];
        end;
      end;
      if nvL==1 func = [func '''''LabelY'''','''''  s2L ''''',']; end;
      if nvR==1 func = [func '''''LabelYr'''',''''' s2R ''''',']; end;
      if nvR>0  func = [func '''''Right'''',' prin('[{%d }]',right) ',']; end;
      if ny>1 func = [func id(1:end-3) '],']; end;
      func = [func opt '''''+'''',2);'];
      plt('select','base',func);
    otherwise,
      click = sum(get(gcf,'SelectionT'));  sk = sxy(v2);
      if click==321 | ~length(xk)
        if sk>=0
             if e(v2,5)==1 e(v2,6) = min(sxy)-1; end;
        else e(v2,6) = 0;
             e(find(sxy==-sk),6)=0;
        end;
      elseif sk>=0
        if click==434 & sk sk = 0; end;
        xki = sort(-sxy(xk(find(len(xk)==len(v2)))));
        if length(xki)
          if sk m = find(xki==sk)+1;
                if m>length(xki) sk=0; e(v2,7)=0; else sk=xki(m);  end;
          else  sk = xki(1);
          end;
          e(v2,6) = sk;
          if click==434 & sk e(v2,7)=1; end;
        end;
      end;
      set(gcf,'user',e);
      plt('select','text');
  end;

case 756
    x = varargin{2};
    m=0;  nv=x;
    if ~x Ret1=''; Ret2=1; return; end;
    while nv>900  m=m+1;  nv=.001*nv; end;
    while nv<.9   m=m-1;  nv=1000*nv; end;
    if (m==1 & x<10000) | (m==-1 & x>=.1 ) m=0; nv=x; end;
    Ret2 = nv/x;
    if     m>5  Ret1 = Pftoa('%4w',1/Ret2);
    elseif m<-6 Ret1 = Pftoa('%5w',1/Ret2);
    else        qs=reshape('Atto FemtoPico Nano MicroMilli     Kilo Mega Giga Tera Peta ',5,12)';
                Ret1 = deblank(qs(m+7,:));
    end;
    if length(Ret1) Ret1 = [Ret1 '-']; end;

case 759
  c = datevec(varargin{2});
  if isempty(c) | isnan(c(1)) Ret1 = []; return; end;
  frac = sprintf('%4.3f',mod(c(6),1));
  c(6) = floor(c(6));
  if strcmp(frac,'1.000')
    if c(6)==59 frac = '0.999'; else c(6) = c(6)+1;  end;
  end;
  if Mver < 7
       if Narg<3 fmt=0; else fmt=varargin{3}; end;
       Ret1 = [datestr(datenum(c),fmt) frac(2:end)];
       if strcmp(Ret1(7:9),'-20') Ret1(8:9) = []; end;
  else
       if Narg<3 fmt = 'dd-mmm-yy HH:MM:SS';
       else      fmt = varargin{3};
       end;
       Ret1 = datestr(datenum(c),fmt);
       p = findstr(':',Ret1);
       if length(p) ~= 2 return; end;
       p = p(2);
       Ret1 = [Ret1(1:p+2) frac(2:end) Ret1(p+3:end)];
  end;

case 425
  if Narg==1        f = '';
  elseif sum(get(gcf,'SelectionT'))==321 f = get(gcbo,'tag');
  else              f = get(gcbo,'user');
  end;
  tp = '';
  if exist('tp')
    if length(f)
      if isempty(findstr(f,'.')) eval(f); return; end;
      dd = findstr(f,'::');
      if length(dd) tp=f(dd:end); f=f(1:dd-1); end;
      if isempty(findstr(f,filesep))
        f = feval('which',f);
      end;
      if ~exist(f) f = ''; end;
    end;
    if isempty(f)
      fc = feval('which','plt.chm'); nc=length(fc);
      fh = feval('which','plt.htm'); nh=length(fh);
      if (nc+nh)==0
         na = get(gcf,'name');
         fc = feval('which',[na '.chm']);  nc=length(fc);
         fh = feval('which',[na '.htm']);  nh=length(fh);
         if ~nh fh = feval('which',[na '.pdf']);  nh=length(fh); end;
         if (nc+nh)==0 disp(['No plt or ' na ' help files were found']); return; end;
      end;
      if ispc if nc f=fc; else f=fh; end;
      else    if nh f=fh; else f=fc; end;
      end;
    end;
    if ispc & strcmpi(f(end-2:end),'chm')
         dos(['hh ' f tp ' &']);
    else feval('web',['file:///' f ],'-browser');
    end;
  else
    if isempty(f) f = 'plt.chm'; end;
    if isempty(findstr(f,filesep)) f = fullfile(fileparts(GetExe),f); end;
    if ~exist(f) return; end;
    if strcmpi(f(end-2:end),'chm') dos(['hh ' f ' &']); else ibrowse(f); end;
  end;

case 878
  if Narg>1 a = varargin{2}; else a = 'off'; end;
  s = getappdata(gca,'helptext'); n = length(s);
  if ~n & Narg<3
    e = findobj(gcf,'type','axes','tag','click')';
    for k=e  s=getappdata(k,'helptext'); n=length(s);
             if n axes(k); break; end;
    end;
    if ~n return; end;
  end;
  ht = findobj(gca,'user',355/113);
  if a(1)=='t' Ret1 = ht; return; end;
  if a(1)=='g' Ret1 = s; return; end;
  if a(2)=='f' | length(ht) delete(ht); return; end;
  if Narg>2
    if n plt('helptext'); end;
    s = varargin{3};  n = length(s);
    setappdata(gca,'helptext',s);
    if a(1)=='s' return; end;
  end;
  if ~n return; end;
  if ~iscell(s) s = {s}; n=1; end;
  a = find(~cellfun('isreal',s));
  if length(a) a = [a n+1];
  else         s = [s {.03+.96i}];  a = n+[1 2];
  end;
  p = 1;  btn = get(gca,'buttond');  props = {};
  for k=1:2:length(a)
    p1 = a(k);  p2 = a(k+1);  pos = s{p1};  props = [props s(p1+1:p2-1)];
    h = text(real(pos),imag(pos),s(p:p1-1),'unit','nor','fontsize',12,...
             'color',[1 .6 0],'vert','top','user',355/113,'buttond',btn);
    for m=1:2:length(props) set(h,props(m),props(m+1)); end;
    if p2<length(s) & imag(s{p2})>0 props = {}; end;
    p = p2+1;
  end;

case 515
  h = varargin{2};
  if ischar(h)
    img = findobj(gcf,'tag',['img' h]);
    cmd = varargin{3};
    switch lower(cmd(1))
    case 'i',
      [xy k] = plt('cursor',0,'get');
      xcur = real(xy);  ycur = imag(xy);
      z = get(img,'Cdata');  y = get(img,'y');
      [v m] = min(abs(y-ycur));
      plt('cursor',0,'updateN',k,xcur,y(m));
      set(findobj(gca,'tag','zstr'),'str',prin('Z = %6w',z(m,k)));
      ob = plt('cursor',0,'obj');  set(ob([4 6]),'vis','off');
    case 's'
      zstat = get(img,'user');
      r = findobj(gcf,'tag',['edge' h]);
      if length(r) r = plt('slider',r); else r=0; end;
      if ~r clim = zstat(3:4);  if ~diff(clim) clim = clim + [-1 1]; end;
      else
        r = r*zstat(2); if isnan(r) | r==0 r = .01; end;
        m = findobj(gcf,'tag',['mid' h]);
        if length(m) m = plt('slider',m); else m=0; end;
        m = m*zstat(2) + zstat(1);  if isnan(m) m=0; end;
        clim = m + [-r r];
      end;
      set(get(img,'parent'),'Clim',clim);
    case 'c'
      if MverE c = findobj(gcf,'tag','cbar');
      else     c = findobj(gcf,'buttond',['plt image ' h ' cbar;']);
      end;
      if isempty(c) return; end;
      if nargin>3 u = varargin{4}; if ischar(u) u = s2d(u); end;
      else        u = get(c(1),'user') + 2*(sum(get(gcf,'SelectionT'))==649) - 1;
      end;
      n = '';
      if exist('n') u = mod(u,10); else u = mod(u,5); end;
      u = mod(u,10);  set(c,'user',u);
      switch(u)
        case 0,  s = 'jet';
        case 1,  n = 'Rainbow';
                 t = 0.04761904739229; t2 = t/2;  
                 a = ones(1,22);  b = ones(1,21);  d = t2:t:1;
                 s = [[0*b;d;b] [d;b;1-t2:-t:0] [a;1:-t:0; 0*a]]';
        case 2,  n = 'Sometric';
                 s = [0 4 0; 5 7 3; 10 9 0; 8 6 10; 5 2 1; 10 10 9];
                 s = round(interp1(linspace(1,64,6),s*100,1:64))/1000;
        case 3,  n = 'Seismic';
                 t = ones(1,22);  b = 0*t; w = (0:21)/22;  s = [b w 1]; f = fliplr(w);
                 b = [f b];  s = [s t f; s b; w t 1 b]';  s = s((1:64)+12,:);
        case 4,  s = 'gray';
        case 5,  s = 'colorcube';
        case 6,  s = 'lines';
        case 7,  s = 'hot';
        case 8,  s = 'cool';
        case 9,  s = 'winter';
      end;
      if isempty(n) n=s; end;
      colormap(get(img,'par'),s);  if ~MverE colormap(get(c,'par'),s); end;
      for k=1:length(c)
        t = findobj(get(c(k),'parent'),'type','text');
        set(t,'str',n);
      end;
    case 'v'
      ax = get(img,'par');
      if sum(get(gcf,'SelectionT'))==649 ilim = getappdata(ax,'ilim');
      else         xl = get(ax,'xlim');  yl = get(ax,'ylim');
                   ilim = .15*[1 -1]; ilim = [xl+diff(xl)*ilim  yl+diff(yl)*ilim];
      end;
      plt('cursor',get(ax,'user'),'xylim',ilim);
    end;
    return;
  end;
  x = varargin{3};  vn = length(varargin);
  if ischar(x)
    c=x; zstat=[]; x=varargin{4}; xx=[];
    imgS = get(h,'tag'); imgS=imgS(4:end);
    gn = 5;
    while length(c)
      c = lower(c);
      switch c
        case 'x'  , set(h,'x',x);                  xx = x;
        case 'y'  , set(h,'y',x);
        case 'z'  , set(h,'Cdata',x);              zstat = x(:);
        case 'xy' , y = varargin{gn};  gn=gn+1;
                    set(h,'x',x,'y',y);            xx = x;
        case 'xz' , y = varargin{gn};  gn=gn+1;
                    set(h,'x',x,'Cdata',y);        zstat = y(:);  xx = x;
        case 'yz' , y = varargin{gn};  gn=gn+1;
                    set(h,'y',x,'Cdata',y);        zstat = y(:);
        case 'xyz', y = varargin{gn};  z = varargin{gn+1};  gn=gn+2;
                    set(h,'x',x,'y',y,'Cdata',z);  zstat = z(:);  xx = x;
        case {'edge' 'mid'},  plt('slider',findobj(gcf,'tag',[c imgS]),'set',x);
        case {'xlim' 'ylim'}, set(get(h,'par'),c,x);
      end;
      if vn>=gn c=varargin{gn}; x=varargin{gn+1}; gn=gn+2; else c=[]; end;
    end;
    if length(xx) set(findobj(gcf,'tag','imgLine'),'x',xx,'y',xx*NaN); end;
    if length(zstat) zstat(isnan(zstat)) = [];
                     zstat = [mean(zstat) std(zstat) min(zstat) max(zstat)];
                     set(h,'user',zstat);
                     plt('image',imgS,'slider');
    end;
  else
    y = varargin{4};  z = varargin{5};  w = 1;
    if nargin>5 opt = varargin{6}; n = length(opt); else n = 0; end;
    pc = [];  pm = [];  pe = [];  pg = [];  pv = [];  cmap = 0;
    ax = getappdata(gcf,'axis');   ax = ax(h);  set(ax,'box','off');
    ah = get(ax,'pos'); al = ah(1);  ab = ah(2);  aw = ah(3);  ah = ah(4);
    l = getappdata(ax,'Lhandles');  fh = get(gcf,'pos');  fw = fh(3);  fh = fh(4);
    if length(l)<1 disp('Error, image axis must contain at least one trace'); return; end;
    while n >= w
      cas = opt{w};  w=w+1;
      if n >= w & ~ischar(opt{w})  v=opt{w};  w=w+1;  else v=[]; end;
      switch lower(cas(1))
        case 'c',  if length(v) pc = v;
                   else pc = [al-59/fw  ab+.5273*ah  18/fw  .3669*ah];
                   end;
                   cmap = cas(end)-'0';  cmap = cmap * (cmap>=0 & cmap<=9); 
        case 'm',  if length(v) pm = v;
                   else pm = [al-94/fw  ab+.18*ah  17/fw  .293*ah];
                   end;
        case 'e',  if length(v) pe = v;
                   else pe = [al-59/fw  ab+.18*ah  17/fw  .293*ah]; end;
        case 'g',  if length(v) pg = v;
                   else pg = [al+aw-94/fw  5.6/fh  48/fw  20/fh];
                   end;
                   gON = cas(1)=='G';
        case 'v',  if length(v) pv = v;
                   else pv = [al+aw-41/fw  8/fh  48/fw  15/fh];
                   end;
      end;
    end;
    zstat = z(:);  zstat(isnan(zstat)) = [];
    zstat = [mean(zstat) std(zstat) min(zstat) max(zstat)];
    set(l(1),'x',x,'y',x*NaN,'tag','imgLine');
    b = axes;
    img = imagesc(x,y,z);
    if MverE ht='on'; else ht='off'; end;
    imgN = getappdata(gcf,'imgN');  if isempty(imgN) imgN = 1; else imgN = imgN+1; end;
    setappdata(gcf,'imgN',imgN);
    imgS = sprintf('%d',imgN);  imgP = ['plt image ' imgS ' '];  axb = get(ax,'buttond');
    set(img,'parent',ax,'buttond',axb,'user',zstat,'tag',['img' imgS]);
    delete(b);
    ilim = [x([1 end]) y([1 end])];
    setappdata(ax,'ilim',ilim);
    set(ax,'xlim',ilim(1:2),'ylim',ilim(3:4));
    grd = plt('grid',ax);
    uistack(grd,'top');
    if MverE set(grd,'erase','xor');
    else     set(grd,'linestyle',':','color',[.4 .4 .4]);
             uistack(findobj(ax,'color',[1 1 .51]),'top');
    end;
    if length(pv) uicontrol('style','text','string','view all','unit','nor','pos',pv,...
                             'ena','inact','buttond',[imgP 'view;']);
    end;
    if length(pg)
      set(grd,'tag','       ','vis',char('of'+[0 8*gON]));
      uicontrol('sty','checkbox','user',grd,...
        'string','grid','value',gON,'unit','nor','pos',pg,'callback',...
        'set(get(gcbo,''user''),''vis'',char(''of''+[0 8*get(gcbo,''value'')]));');
    end;
    setappdata(ax,'offline',1);
    axes(ax); text(.26,-.06,'','unit','nor','fontsize',12,'color',[.3 1 .3],'tag','zstr');
    k = round(length(x)/2);
    ob = plt('cursor',-h,'obj');  s = [imgP 'Icur; ' get(ob(6),'user')];
    plt('cursor',-h,'moveCB',s);
    plt('cursor',-h,'updateN',k,x(k),mean(get(ax,'ylim')));
    if length(pc)
      c = axes('pos',pc);
      image(transpose(63:-1:0),'buttond',[imgP 'cbar;'],'tag','cbar');
      text(.475,1.023,'','unit','nor','rot',90,'color','white');
      set(c,'vis','off');  axes(ax);
    end;
    imgPS = [imgP 'slider;'];
    if length(pm) hm = plt('slider',pm,[0 -1 1], 'mid', imgPS,1,'4'); end;
    if length(pe) he = plt('slider',pe,[1 0 2.5],'edge',imgPS,1,'3'); end;
    set(hm,'tag',['mid' imgS]);  set(he,'tag',['edge' imgS]);
    plt('image',imgS,'cbar',cmap);
    plt('image',imgS,'slider');
    ERAS = 'eras';  em = 'norm';
    if ~MverE ERAS = 'pi';  em = 'v';  elseif Mver<7 em = 'xor'; end;
    mk = findobj(ax,'marker','+','vis','on');
    set(mk,'MarkerSize',16,'Marker','*',ERAS,em,'buttond',axb);
    uistack(mk,'top');
    Ret1 = img;
  end;

case 335

  k = 2; b = varargin;  a1 = b{2};  nvar = length(b);
  if nvar==2 b = [b {'get'}];  nvar = nvar+1; end;
  if isnumeric(a1) & ~ischar(b{3})
     a1 = 'pos'; b = [b(1) {a1} b(2) {'choices'} b(3:nvar)]; nvar = nvar+2;
  end;
  if ischar(a1)
       g  = gca;
       bk = [0 .3 .4];
       a = axes('vis','of','XtickLabel',' ','YtickLabel',' ','TickLen',[0 0]','color',bk,'xcol',bk,'ycol',bk);
       pd = {a     ''       1      ''      99    [.1 1 .9]     1      []   'none'   -1   0 };
       Ret1 = text(0,0,'','units','data','user',pd,'interp','none','color',[1 1 .4]);
       setappdata(gcf,'pop',[getappdata(gcf,'pop') Ret1]);
       setappdata(Ret1,'ty','pop');  setappdata(a,'ty','pop');
       set(Ret1,'buttond',{@plt 'pop' Ret1 'open'});
       set(a,'user',Ret1);
       axes(g);
  else n = length(a1);  Ret1 = a1;
       if n==1 k=k+1; pd=get(Ret1,'user'); a=pd{1};
       else    argn = b{3};  argv = b{4};  s = size(argv,1);
               if s for k=1:n plt('pop',Ret1(k),argn,argv(min(k,s),:)); end;
               else for k=1:n plt('pop',Ret1(k),argn,[]); end;
               end;
               return;
       end;
  end;
  nvar = length(b);  ofs = [];  cb = 0;
  while k <= nvar
    argn  = lower(b{k}); k=k+1;
    if k>nvar argv=''; else  argv = b{k}; k=k+1; end;
    switch sum(argn)
    case {338,885},
                    switch length(argv)
                      case 1, fp=get(a,'pos'); argv=[fp(1:3) argv];
                      case 2, fp=get(a,'pos'); argv=[fp(1:2) argv];
                    end;
                    if argv(1)<0 argv(1)=-argv(1); pd{5}=0; end;
                    if argv(2)<0 argv(2)=-argv(2); pd{11}=1; edg(Ret1,pd{6}); end;
                    if max(argv)>1 u='pixels'; else u='normal'; end;
                    set(a,'units',u,'pos',argv);
    case 734,  if isnumeric(argv)
                      if sum(mod(argv,1)) fm = '{%5w!row}'; else fm = '{%d!row}'; end;
                      argv = prin(fm,argv);
                    end;
                    pd{2} = argv;
    case 434,
                    if pd{7}<1 return; end;
                    mv = get(Ret1,'buttond');
                    if iscell(mv) mv = mv{2}(1); else mv = mv(5); end;
                    mv = (mv=='m');
                    if xor(sum(get(gcf,'SelectionT'))==649,pd{11}) & ~(sum(get(gcf,'SelectionT'))==434) | mv
                      uh = findobj(pd{8},'vis','on');
                      setappdata(Ret1,'Uhide',uh);
                      set([Ret1; uh],'vis','of');  ch = pd{2};  n = length(ch);
                      set(a,'vis','on');  axes(a);
                      s = {@plt 'pop' Ret1 'index'};  w = get(gcf,'pos');
                      p = get(a,'pos');  p = p(3);  if p<1 p = p*w(3); end;
                      p = 5/p;
                      for m=1:n 
                        ht = text(p,n+.5-m,ch{m},'units','data');
                        set(ht,'interp',pd{9},'color',pd{6},'buttond',[s {-m}]);
                        if m==pd{3} set(ht,'fontw','bol'); end;
                      end;
                      cr = get(a,'color');  z = zeros(1,n-1);
                      x = [z;z+1;z];  z = [z;z;z+NaN];   y = 1:n-1;  y = [y;y;y];
                      line('z',z(:),'y',y(:),'x',x(:),'color',cr-.2+.4*(cr<.5),'user',w);
                    else
                      g = gcf;  setappdata(g,'bdown',1);
                      set(g,'WindowButtonUp','setappdata(gcf,''bdown'',0);');
                      n = length(pd{2});  v = pd{3};
                      [rpt p] = getREPEAT;
                      while ishandle(g) & getappdata(g,'bdown')
                        if v==n v=1; else v=v+1; end;
                        plt('pop',Ret1,'index',-v);
                        if rpt < 0 break; end;
                        q=p; while q>0 & ishandle(g) & getappdata(g,'bdown') pause(.01); q=q-.01; end;
                        p = rpt;
                      end;
                    end;
                    return;
    case 410,     if isempty(argv) argv = 0; end;
                    z = find(argv==0);
                    if length(z) argv(z) = findobj(gcf,'user','grid'); end;
                    pd{8} = argv;
    case 647,   pd{5} = argv;
    case 759,  pd{6} = argv;
    case 748,  set(a,'color',argv,'xcol',argv,'ycol',argv);
    case 658,   pd{9} = argv;  set(Ret1,'interp',argv);
    case 443,     pd{11} = 1;  if isempty(argv) argv = 'none'; elseif length(argv)==1 argv = pd{6}; end;
                    edg(Ret1,argv);
    case 536,    w = abs(argv);  pd{3} = w;   v = get(a,'vis');
                    if v(2)=='n'
                      set(a,'vis','of');  ch = get(a,'child'); li = findobj(ch,'type','line');
                      dp = sum(abs(get(li,'user') - get(gcf,'pos')));
                      if dp>0 & dp<20
                        pd{11} = 1 - pd{11};
                        disp('swap toggled');
                      end; 
                      ch(find(ch==Ret1)) = [];  ch(find(ch==pd{10})) = [];
                      li = getappdata(Ret1,'li');  if ishandle(li) ch(find(ch==li)) = []; end;
                      delete(ch);
                      uh = getappdata(Ret1,'Uhide');
                      set([Ret1; uh],'vis','on');
                      ch = gcf;
                      if Mver < 7.5
                        set(ch,'Share','off');
                        set(ch,'Share','on');
                      end;
                    end;
                    cb = (argv<0);
    case 617,   pd{4} = argv;  set(Ret1,'user',pd);
    case 320,      switch sum(argv)
                      case 663,  Ret1 = get(Ret1,'str');
                      case 437,      Ret1 = pd{1};
                      case 734,   Ret1 = pd{2};
                      case {536,0}, Ret1 = pd{3};
                      case 617,    Ret1 = pd{4};
                      case 647,    Ret1 = pd{5};
                      case 759,   Ret1 = pd{6};
                      case 615,    Ret1 = pd{7};
                      case 410,      Ret1 = pd{8};
                      case 658,    Ret1 = pd{9};
                      case 512,     Ret1 = pd{10};
                      case 443,      Ret1 = pd{11};
                      otherwise,       Ret1 = pd;
                    end;
                    return;
    case 615,   pd{7} = argv;  set(Ret1,'user',pd);  vs = char('on' - [0 8]*(argv<0));  set(Ret1,'vis',vs);
                                      if ishandle(pd{10}) set(pd{10},'vis',vs); end;
    case {512 633},
                    if ischar(argv) argv = {argv ''}; end;
                    s = argv{1};
                    q = argv{2};
                    if isempty(q)
                      if sum(argn)==512 q = -5;
                      else  q = (16 + pd{11}*(6 - 3*MverE)) * 1i;
                      end;
                    end;
                    q = [real(q) imag(q)];
                    if ~q(2) & q(1)<0 hz = 'right'; else hz = 'left'; end;
                    t = text(0,0,s,'units','data','horiz',hz,'color',[.6 .6 .8],'par',a,'user',q);
                    pd{10} = t;
                    j=3;  while length(argv)>j set(t,argv{j},argv{j+1}); j=j+2; end;
    otherwise,      set(Ret1,argn,argv);
    end;
  end;
  c = pd{2};  n = length(c);  f = pd{5};  i = pd{3};  s = c{i};
  if length(f)<2 f=[.08 f]; end;
  if f(2)==99 f(2)=n; end;
  set(a,'ylim',[0 n]);
  set(Ret1,'pos',f,'str',s,'user',pd);
  edg(Ret1);
  p = get(a,'pos');
  t = pd{10};
  if ishandle(t)
    e = p(3:4);
    if p(1)<1  r = get(gcf,'pos'); e = e .* r(3:4); end;
    q = get(t,'user')./e;  q(2)=q(2)*n;
    set(t,'pos',f+q);
  end;
  p(4) = p(4)/n;
  setappdata(Ret1,'ppos',p - [([0 .3]-f) .4 .4] .* p([3 4 3 4]));
  if cb evalRep(pd{4},{'@STR',s,'@IDX',int2str(i)}); end;

case 422
if MverE  ERAS = 'eras';  ERAXOR = 'xor';  ERANOR = 'norm';
else      ERAS = 'pi';    ERAXOR = 'v';    ERANOR = 'v';
end;
if y1(1) == 'g'
  if Narg==1 ax = gca;
  else       ax = varargin{2};  if ax==0 ax = gca; end;
  end;
  if Narg<3 Action='update'; else  Action = varargin{3};  end;
  Action = sum(Action);
  if Action == 436
    if Narg<4 grdclr = [.13 .13 .13]; else grdclr = varargin{4}; end;
    if Narg<5 erMode = ERAXOR;  else erMode = varargin{5}; end;
    if Narg<6 sty = '-';        else sty    = varargin{6}; end;
    f = findobj(ax,'type','line');
    if length(f) f=get(f(1),'buttond'); end;
    Ret1 = line('color',grdclr,'tag','SkipCur','buttond',f,'linest',sty,'user','grid',ERAS,erMode);
    set(Ret1,'par',ax);
    setappdata(Ret1,'clr',grdclr);
    Action = 221;
    if Narg >= 7 set(Ret1,varargin{7},varargin{8}); end;
    if Narg >= 9 set(Ret1,varargin{9},varargin{10}); end;
    set(ax,'child',flipud(get(ax,'child')));
  else  Ret1 = findobj(ax,'user','grid');
        if length(Ret1) ~= 1 return; end;
        z = get(Ret1,'z');   e = length(z);
        if e e = z(1) | e>=2; end;
  end;

  switch Action
  case 643, if e Action=221; end;
                fixMark;
  case 642, if e Action=315; else Action=221; end;
  end;

  switch Action
  case 221,  z = 1;  l = [get(ax,'xlim') get(ax,'ylim')];
             s = get(ax,'Xscale');  t = 1;
             if s(2)=='o' &  l(2)/l(1)<getappdata(gcf,'logTR')
               t = get(ax,'XtickLabel'); if iscell(t) t = [t{:}]; else t = t(:)'; end;
               t = length(findstr(t,'.'));
             end;
             if t  xt = [l(1) get(ax,'XTICK') l(2)]; n=length(xt);
                   if xt(2) <= xt(1)   xt = xt(2:n); n=n-1; end;
                   if xt(n) <= xt(n-1) n=n-1;  xt = xt(1:n); end;
             else  xt = logTicks(l(1:2));  n = length(xt);
             end;
             s = get(ax,'Yscale');  t = 1;
             if s(2)=='o' & l(4)/l(3)<getappdata(gcf,'logTR')
               t = get(ax,'YtickLabel'); if iscell(t) t = [t{:}]; else t = t(:)'; end;
               t = length(findstr(t,'.'));
             end;
             if t  yt = [l(3) get(ax,'YTICK') l(4)]; m=length(yt);
                   if yt(2) <= yt(1)   yt = yt(2:m); m=m-1; end;
                   if yt(m) <= yt(m-1) m=m-1;  yt = yt(1:m); end;
             else  yt = logTicks(l(3:4));  m = length(yt);
             end;
             t = m + n - 4;
             if t s = ones(3,1);  y = [1 m m];  x = [1 n n];  n=n-1;  m=m-1;
                  z = [0;0;NaN] * ones(1,t);           z=z(:);
                  y = [s*yt(2:m)  yt(y)'*ones(1,n-1)]; y=y(:);
                  x = [xt(x)'*ones(1,m-1) s*xt(2:n)];  x=x(:);
             else x = 0;  y = 0;  z = 0;
             end;
             tlen = [ 0   0  ];
  case 315, tlen = [.01 .025]; x=0; y=0; z=0;
  otherwise, return;
  end;
  set(Ret1,'z',z,'y',y,'x',x);  set(ax,'TickLen',tlen);
else

  k = 2; b = varargin;  a0 = b(1); a1 = b{2};  nvar = length(b);
  if nvar==2 b = [b {'get'}];  nvar = nvar+1; end;
  if isnumeric(a1) & isnumeric(b{3})
     if     max(a1)<4      a0 = {'edit' 'units' 'norm'};
     elseif length(a1)==2  a0 = {'edit' 'units' 'pix'};
     end;
     a1 = 'pos';  b = [a0 {a1} b(2) {'value'} b(3:nvar)];
     nvar = length(b);
  end;
  if ischar(a1)
       ui = 0;
       for z = 2:2:nvar  d = b{z};
                         if lower(d(1))=='p' ui = length(b{z+1}); break; end;
       end;
       if ~ui disp('You must specify a position for the edit pseudo object'); return; end;
       ui = (ui==4);

       pd = { 1  -1e99 1e99     ''      1    1     1  '%6w'  -1   ''    ''  };

       c = get(gcf,'color')/2;  f = [1 1 .4];  if sum(c)>1.5 f = 1-f; end;
       if ui ut='uic'; Ret1 = uicontrol('style','text','fontsi',9,'ena','inact','foregr',f,'backgr',c);
       else  ut='txt'; Ret1 = text(0,0,'1','horiz','cent','color',f);
       end;
       setappdata(gcf,ut,[getappdata(gcf,ut) Ret1]);
       setappdata(Ret1,'ty','edi');
       set(Ret1,'user',pd,'buttond',{@plt 'edit' Ret1 'click' 0});
  else n = length(a1);  Ret1 = a1;
       if n==1 k = k + 1;   pd = get(Ret1,'user');
       else    argn = b{3};  argv = b{4};  s = size(argv,1);
               if s for k=1:n plt('edit',Ret1(k),argn,argv(min(k,s),:)); end;
               else for k=1:n plt('edit',Ret1(k),argn,[]); end;
               end;
               return;
       end;
  end;
  ui = get(Ret1,'type');  ui = (ui(1) == 'u');
  if ui cp = 'foregr'; gc = gcf;   nun = 'pix';
  else  cp = 'color';    gc = gca;   nun = 'data';
  end;
  while k <= nvar
    argn  = lower(b{k}); sargn = sum(argn); k=k+1;
    if k>nvar argv=''; else  argv = b{k}; k=k+1; end;
    switch sargn
    case 518,
      if argv
        c = get(gcf,'CurrentChar');
        if ~length(c) c=666;  end;
        if argv==2 c=27; end;
        t = get(Ret1,'str');   u = get(Ret1,cp);
        p = findstr(t,'_');  n = length(t);
        done = 0;            eeval = 0;
        switch abs(c)
        case 666,
        case 8,    if p>1 t(p-1)=[]; end;
        case 127,  if p==n t='_'; else t(p+1)=[];  end;
        case 28,   if p>1 t(p)=t(p-1); t(p-1)='_'; end;
        case 29,   if p<n t(p)=t(p+1); t(p+1)='_'; end;
        case 27,   done = 1;  t = pd{10};
        case 13,   done = 1;
                   t(p) = [];
                   if pd{7}
                     tt=t;  t = 'error';
                     try, s = eval(tt);
                        if pd{7}==-1 | pd{7}==length(s)
                          if length(s)==1
                            if isreal(s)
                                 s = max(min(s,pd{3}),pd{2});
                                 t = ['  ' Pftoa(pd{8},s) '  '];
                            else pd{6} = imag(s);
                                 t = pd{10};
                            end;
                          else  t = ['[' num2str(s) ']'];
                          end;
                          if isreal(s)  pd{1} = s;  eeval = 1; end;
                        end;
                     end;
                   else pd{1}=0; eeval=1;
                   end;
        otherwise, t = strrep(t,'_',[c '_']);
        end;
        set(Ret1,'str',t);
        if done
          set(Ret1,'user',pd,cp,u([3 1 2]))
          if ~ui set(Ret1,ERAS,ERANOR,'interp',pd{11}); end;
          set(gcf,'keypress',' ');
          if eeval setappdata(gcf,'OBJ',Ret1);  evalRep(pd{4},{'@VAL' t '@OBJ' 'plt("misc",3)'}); end;
        end;
      else
        kp = get(gcf,'keypress');
        if iscell(kp) & length(kp)==5 & kp{4}(1)=='c'
           kp{5}=2;  plt(kp{2:end}); return;
        end;
        if pd{5}<1 return; end;
        c = sum(get(gcf,'SelectionT'));
        if c ~= 321
          v = pd{1}; w = pd{6};
          if pd{7}==1 & w
            cp = get(gc,'currentp'); cp = cp(1,1);
            rp = get(Ret1,'pos');  un = get(Ret1,'unit');
            if un(1) ~= nun(1)
              set(Ret1,'units',nun);
              rp2 = rp;  rp = get(Ret1,'pos');
              set(Ret1,'units',un,'pos',rp2);
            end;
            cp = cp > rp(1) + ui*rp(3)/2;
            cp = 2*cp - 1;
            [rpt p] = getREPEAT(0);
            setappdata(gcf,'bdown',1);
            set(gcf,'WindowButtonUp','setappdata(gcf,''bdown'',0);');
            m = 0;
            while getappdata(gcf,'bdown')
              if w<0 vf = (1 - w/100)^cp;
                     if v v = v*vf;
                     else v = vf-1;
                     end;
              else   v = v + w*cp;
              end;
              if     v>pd{3} if m break; else v=pd{2}; end;
              elseif v<pd{2} if m break; else v=pd{3}; end;
              end;
              m = 1;  pd{1} = v;  s = ['  ' Pftoa(pd{8},v) '  '];
              set(Ret1,'str',s,'user',pd);
              setappdata(gcf,'OBJ',Ret1); evalRep(pd{4},{'@VAL' s '@OBJ' 'plt("misc",3)'});
              if rpt < 0 break; end;
              q=p; while q>0 & getappdata(gcf,'bdown') pause(.01); q=q-.01; end;
              p = rpt;
            end;
            return;
          else c=321;
          end;
        end;
        if c==321
          t = get(Ret1,'str');
          if ~strcmp(t,'error') pd{10} = t; end;
          t = deblank(t);  while(t(1)==' ') t(1)=[]; end;
          oldc = get(Ret1,cp);
          if ~ui pd{11} = get(Ret1,'interp'); set(Ret1,'interp','none',ERAS,ERAXOR); end;
          set(Ret1,'str',[t '_'],cp,oldc([2 3 1]),'user',pd);
          set(gcf,'keypress',{@plt 'edit' Ret1 'click' 1});
        end;
      end;
    case 320,    switch sum(lower(argv))
                  case {0,541}, Ret1 = pd{1};
                  case 650,    Ret1 = [pd{2:3}];
                  case 617,    Ret1 = pd{4};
                  case 615,    Ret1 = pd{5};
                  case 428,      Ret1 = pd{6};
                  case 642,    Ret1 = pd{7};
                  case 649,    Ret1 = pd{8};
                  case 512,     Ret1 = pd{9};
                  otherwise,       Ret1 = pd(1:9);
                  end;
    case {541,323,650},
                  if     length(argv)==3  pd(2:3) = {argv(2) argv(3)};
                  elseif length(argv)==2  pd(2:3) = {argv(1) argv(2)}; set(Ret1,'user',pd);  return;
                  end;
                  pd{1}  = argv(1);  s = ['  ' Pftoa(pd{8},argv(1)) '  '];
                  set(Ret1,'str',s,'user',pd);
                  if sargn==541 setappdata(gcf,'OBJ',Ret1); evalRep(pd{4},{'@VAL',s,'@OBJ','plt("misc",3)'}); end;
    case 617, pd{4} = argv;  set(Ret1,'user',pd);
    case 428,   pd{6}   = argv;  set(Ret1,'user',pd);
    case 642, pd{7}    = argv;  set(Ret1,'user',pd);
    case 615, pd{5}    = argv;  set(Ret1,'user',pd);  vs = char('on' - [0 8]*(argv<0));  set(Ret1,'vis',vs);
                                       if ishandle(pd{9}) set(pd{9},'vis',vs); end;
    case 649, if     isnumeric(argv) argv = sprintf('%%%dw',argv);
                  elseif length(argv)<2  argv = ['%' argv 'w']; end;
                  pd{8}    = argv;  set(Ret1,'user',pd);
    case 512,  if isnumeric(argv)
                       m = argv;  argv = getappdata(m,'argv');
                  else m = 0;
                  end;
                  if ischar(argv) argv = {argv ''}; end;
                  p = get(Ret1,'pos');  u = get(Ret1,'units');  hz = 'right';
                  s = argv{1};  q = argv{2};
                  if ui
                    r = length(s);   tl = findstr(s,'~');
                    if length(tl)  tl = tl(end);  s(tl) = [];  r = tl-1; end;
                    r = round(22 + 6.5*r);
                    if u(1)=='n' sz=get(gcf,'pos'); r=r/sz(3); end;
                    switch length(q)
                    case 0, q = [p(1)-r p(2) r p(4)];
                    case 1, q = [p(1)-q p(2) q p(4)];
                    case 2, w = q(1);  if ~w w = r; end;
                            xo = real(q(2));  yo = imag(q(2));
                            q = [p(1)+xo-w p(2)+yo w p(4)];
                            if ~xo  q(1) = p(1)+(p(3)-w)/2;  hz = 'cent';  end;
                    case 4, hz='cent';
                    end;
                    if m set(m,'pos',q); return; end;
                    a = uicontrol('sty','text','str',s,'units',u,'pos',q,'foregr',[.6 .6 .8],'backgr',get(Ret1,'backgr'),...
                             'horiz',hz,'fontsi',9,'buttond',get(Ret1,'buttond'),'ena','inact','user',Ret1,'tag','E');
                  else
                    p = p(1:2);
                    switch length(q)
                    case 0, r = pd{8};  t = length(get(Ret1,'str')) - 4;
                            r = max([t length(Pftoa(r,pd{2})) length(Pftoa(r,pd{3}))]);
                            r = 5 + r*4;
                            if u(1)=='n' sz=get(gcf,'pos'); r=r/sz(3); end;
                            q = p - [r 0];
                    case 1, xo=real(q); yo=imag(q); q=p+[xo yo];
                            if ~xo hz='cent'; end;
                    case {2,3}, hz='cent';
                    end;
                    if m set(m,'pos',q); return; end;
                    a = text(q(1),q(2),s,'units',u,'horiz',hz,'color',[.6 .6 .8],...
                             'buttond',get(Ret1,'buttond'),'user',q(1:2)-p);
                  end;
                  j=3;  while length(argv)>j set(a,argv{j},argv{j+1}); j=j+2; end;
                  pd{9} = a;  set(Ret1,'user',pd);
                  setappdata(a,'argv',argv(1:2));
    otherwise,    set(Ret1,argn,argv);
                  a = pd{9};
                  if ishandle(a) & argn(1)=='p' plt('edit',Ret1,'label',a); end;
    end;
  end;
end;

case 643
  Hin = varargin{2};
  if length(Hin)>1
     if Narg>2  In2 = varargin{3}; else In2 = 100;   end;
     if Narg>3  In3 = varargin{4}; else In3 = '';    end;
     if Narg>4  In4 = varargin{5}; else In4 = '';    end;
     In5 = 1;  In6 = '%2w %6w %3w';  In7 = [.75 .75 .75; 0 1 1];
     for k=6:8
       if Narg<k break; end;
       v = varargin{k};
       if isnumeric(v)
          if length(v)<3 In5 = v; else In7 = v; end;
       else In6 = v;
       end;
     end;
     if isempty(In2)                      In2 = 100; end;
     if length(In2)==1                    In2 = [0 In2]; end;
     if length(In2)==2 | length(In2)==4   In2 = [mean(In2(1:2)) In2]; end;
     if length(In2)==3                    In2 = [In2 -1e99 1e99]; end;
     if length(In7(:,1))<3                In7 = [In7; 0 0 0; 0 0 0]; end; 
     if ischar(In6) & length(In6(:,1))==1
        d = find(In6 == ' ');
        if length(d)<2 In6 = ['%2w ' In6 ' %3w'];  d = find(In6 == ' '); end;
        In6 = {In6(1:d(1)-1) In6(d(1)+1:d(2)-1) In6(d(2)+1:end)};
     end;
     if iscell(In6)
       for k=1:3  d=In6{k}; if length(d)<2 In6{k} = ['%' d 'w']; end; end;
       In6 = char(In6);
     end;
     hs = zeros(1,8);
     hs(2)  = uicontrol('sty','text','str',In3,'horiz','cent');  if isempty(In3) set(hs(2),'vis','off'); end;
     Ret1       = hs(2);        cb = {@plt 'slider' Ret1};
     hs(4) = uicontrol('sty','text','str','a','user',In6,'horiz','left');
     hs(5) = uicontrol('sty','text','str','a','user',In4,'horiz','right');
     hs(3)  = uicontrol('sty','slid','user',In2(1),'call',[cb {'CBslide'}]);
     hs(6)  = uicontrol('sty','edit','backg',In7(2,:),'foreg',In7(4,:),'user',In2(4:5),'horiz','cent','call',[cb {'CBedit'}]);
     set(hs(2:5),'backg',In7(1,:),'foreg',In7(3,:));
     In5 = [In5 10];  hs([7 8]) = In5(1:2);
     if hs(7)==5 & In2(4)<0 In2(4) = 1e-99; end;
     set(hs(2),'user',hs);
     plt('slider',Ret1,'set','minmax',In2(2:5),In2(1));
     plt('slider',Ret1,'set','pos',Hin);
     if length(Hin)==3
       setappdata(gcf,'sli',[getappdata(gcf,'sli') hs(2:6)]);
     end;
     return;
  end;

  hs   = get(Hin,'user');
  fmat = get(hs(4),'user');

  if nargin>2 Action = varargin{3}; else Action = 'get'; end;
  if Narg>3  In1 = varargin{4};  else In1 = ''; end;
  if Narg>4  In2 = varargin{5};  else In2 = []; end;
  if Narg>5  In3 = varargin{6};  else In3 = []; end;

  switch sum(lower(Action))
  case 726
     oldval = get(hs(3),'user');    newval = get(hs(3),'Val');  sval = [];
     smax   = get(hs(3),'max');   smin   = get(hs(3),'min');
     dv = newval-oldval;  sdv = sign(dv);
     switch hs(7)
     case 4,
        v = hs(8)*round(newval/hs(8));
        if v==oldval v = v + hs(8)*sdv; end;
        newval = v;
     case 2,
        v = round(newval);
        if v==oldval v = v + sdv; end;
        newval = v;
     case 5, sval = newval; newval = exp(sval);
     case 3,
        if newval >= get(hs(3),'user')-eps  newval=2^nextpow2(newval);
        else                                  newval=2^nextpow2(newval/2);
        end;
     case 6,
        pdv = abs(dv)/(smax-smin);
        if     pdv < .02   newval = oldval + hs(8)*sdv;
        elseif pdv < .11   newval = oldval + hs(8)*sdv*10;
        end;
        newval = hs(8)*round(newval/hs(8));
     end;
     if isempty(sval)
       if newval<smin newval = smin; elseif newval>smax newval = smax; end;
       sval = newval;
     end;
     set(hs(6),'str',Pftoa(fmat(2,:),newval));
     set(hs(3),'Val',sval,'user',newval);
     evalRep(get(hs(5),'user'),{'@VAL',sprintf('%g',newval)});

  case 619
     newval = s2d(get(hs(6),'str'));    sval = [];
     minmax = get(hs(6),'user');
     if isempty(newval)
         set(hs(6),'str',Pftoa(fmat(2,:),get(hs(3),'Val')));
     else
        switch hs(7)
        case 2,  newval = round(newval);
        case 3,  newval = 2 ^ nextpow2(newval/1.414);
        case 4, newval=hs(8)*round(newval/hs(8));
        case 5,     newval = min(max(newval,minmax(1)),minmax(2));
                       sval = log(newval);
        end;
        newval = min(max(newval,minmax(1)),minmax(2));
        Ret1 = newval;
        set(hs(6),'str',Pftoa(fmat(2,:),newval));
        if isempty(sval) sval = newval; end;
        sval = max(min(get(hs(3),'max'),sval),get(hs(3),'min'));
        if hs(7)==5 newval = exp(sval); end;
        set(hs(3),'Val',sval,'user',newval);
        evalRep(get(hs(5),'user'),{'@VAL',sprintf('%g',newval)});
     end;

  case 320
     switch sum(In1)
     case 750,         Ret1 = sum(get(hs(2),'vis')) == 221;
     case 308,             Ret1 = sum(get(hs(2),'ena')) == 221;
     case 315,             Ret1 = hs(2:6);
     case {338 885}, Ret1 = get(hs(2),'pos');  Ret1 = Ret1(1:3);
     otherwise              Ret1 = get(hs(3),'user');
     end;
  case 332
     if isnumeric(In1) set(hs(6),'str',num2str(In1));
                       Ret1 = plt('slider',Hin,'CBedit');
     elseif Narg>3  varargin(3)=[];  plt(varargin{:});
     end;
  case 541
     set(hs(6),'str',num2str(In1));
     Ret1 = plt('slider',Hin,'CBedit');
  case 323
     set(hs(6),'str',num2str(In1));
     sv = get(hs(5),'user');  set(hs(5),'user','');
     Ret1 = plt('slider',Hin,'CBedit');
     set(hs(5),'user',sv);
  case 559,  set(hs(2:6),'vis','on')
                if isempty(get(hs(2),'str')) set(hs(2),'vis','of'); end;
  case 653, set(hs(2:6),'vis','of');
  case 623, set(hs([3 6]),'ena','of');
  case 529,  set(hs([3 6]),'ena','on');
  case {338 885},
     ob = hs(2:6);
     if ~iscell(In1)
       len2 = length(In1);
       switch len2
         case 8,     In1 = {In1(1:4) In1(5:8)};
         case {4,5}, wid = 8+6*length(get(ob(1),'str')); dx = 2;  dy = 4;
                     if max(In1)<3 w=get(gcf,'pos'); wid=wid/w(3); dx=dx/w(3); dy=dy/w(4); end;
                     if len2==5 wid = In1(5); end;
                     if In1(4)>In1(3) pl = [In1(1)-(wid-In1(3))/2 In1(2)+In1(4)+dy wid 4*dy];
                        else          pl = [In1(1)-wid-2*dx In1(2) wid In1(4)];
                     end;
                     In1 = {In1(1:4) pl};
       end;
     end;
     if iscell(In1)
       if length(In1)==2
         ps = In1{1}; pl = In1{2};
         if ps(4)>ps(3) pe = [pl(1) ps*[0;2;0;1]-pl*[0;1;0;1]-dx pl(3) pl(4)+dx];
         else           pe = [ps*[2;0;1;0]-pl*[1;0;1;0] pl(2:4)];
         end;
         In1 = {pl; ps; []; []; pe};
       end;  
       ie = find(cellfun('isempty',In1))';
       if max(In1{2})>3
             for k=ie In1{k}=[-99 9 9 9]; end;  set(ob,'unit','pix',{'pos'},In1);
       else  for k=ie In1{k}=[2 2 .1 .1]; end;  set(ob,'unit','nor',{'pos'},In1);
       end;
     else
       a = (get(0,'screenp')-96)/10;
       p = get(gcf,'pos');  w = p(3);  h = p(4);
       if length(In1<3) In1 = [In1 120]; end;
       lmax = 7 + 7*fix(s2d(fmat(3,2:(length(deblank(fmat(3,:)))-1))));
       lmin = 7 + 7*fix(s2d(fmat(1,2:(length(deblank(fmat(1,:)))-1))));
       if isnan(lmax) lmax = 28; end;
       if isnan(lmin) lmin = 14; end;
       h0=a+17;  h1=16+a/2;  h2=17-a-1;  h3=a+17;  h5=h3+2;
       if In1(1)>=1
         if In1(3)<1 In1(3) = In1(3)*w; end;
         In1(3) = max(In1(3),65);
         ya = In1(2) - h0;
         set(ob,'unit','pix',{'pos'},...
                {[In1(1:3) h1];
                 [In1(1),In1(2)-33,In1(3),h2];
                 [In1(1),ya,lmin,h3];
                 [In1(3)+In1(1)-lmax,ya,lmax,h3];
                 [In1(1)+lmin,ya-1,In1(3)-(lmin+lmax),h5]});
       else
         if In1(3)>=1 In1(3) = In1(3)/w; end;
         In1(3) = max(In1(3),65/w);
         h1=h1/h; h2=h2/h; h3=h3/h; h5=h5/h; ya = In1(2)-h0/h;  lmin=lmin/w;  lmax=lmax/w;
         set(ob,'unit','nor',{'pos'},...
                {[In1(1:3) h1];
                 [In1(1),In1(2)-33/h,In1(3),h2];
                 [In1(1),ya,lmin,h3];
                 [In1(3)+In1(1)-lmax,ya,lmax,h3];
                 [In1(1)+lmin,ya-1/w,In1(3)-(lmin+lmax),h5]});
        end;
      end;
  case 421
     hs(7) = In1(1);
     if length(In1)>1 hs(8) = In1(2); end;
     set(hs(2),'user',hs);
     Ret1 = plt('slider',Hin,'CBedit');
  case 650
     lg = hs(7)==5;
     if lg mn=1e-99; else mn=-1e+99; end;
     if length(In1)<4 In1 = [In1 mn 1e99]; end;
     set(hs(5),'str',[Pftoa(fmat(3,:),In1(2)) ' ']);
     set(hs(4),'str',[' ' Pftoa(fmat(1,:),In1(1))]);
     set(hs(6),'user',In1(3:4));
     if isempty(In2) v = s2d(get(hs(6),'str'));
     else            v = In2;
     end;
     v = min(max(v,In1(3)),In1(4));
     set(hs(6),'str',Pftoa(fmat(2,:),v));
     m1 = In1(1);  m2 = In1(2);
     if lg m1=log(m1); m2=log(m2); v=log(v); end;
     set(hs(3),'min',m1,'max',m2,'Val',min(max(m1,v),m2));
     Ret1 = s2d(get(hs(6),'str'));
  case 512,  set(hs(2),'str',In1);
                if isempty(In1) set(hs(2),'vis','of'); end;
  otherwise disp(sprintf('Invalid Action in plt(''slider''), Action=%s',Action));
  end;

case 436
  Action = varargin{2};
  if Narg > 2  In1 = varargin{3};
               if Narg > 3  In2 = varargin{4}; end;
  end;
  switch sum(Action)
  case 436
     Hhcpy(12)= In1;
     if Narg ==4  renderer = In2; else renderer = '-painters';  end;
     Hhcpy(1)=figure('menu','none','numberT','off','back','off','resize','off','pos',auxLoc(350,105),'color',[0,.4,.4],'name','Hardcopy','tag',get(gcf,'tag'));
     foobar = 0;
     if exist('foobar')
          cpath = feval('which','plt.m');
     else cpath = GetExe;
     end;
     filen = [fileparts(cpath) filesep 'pltHcpy.mat'];
     if exist(filen) load(filen);
     else
       z = [0 0];  t = z+1;  w = [0 1];
       pS1=[z;w;[2 1];w;t;w;t;z;t;w;w];
       pS2 = 'temp.bmp';
     end;
     Hhcpy(3)   = uicontrol('sty','pop','str',['Win Meta|Bit Map|HPGL|LaserJet IIp|Post Script|Encaps PS|Windows'],...
                             'call','plt hcpy ModePUcb;');
     Hhcpy(5)  = uicontrol('sty','radio','str','color','call','plt hcpy rbg1 C;');
     Hhcpy(4)     = uicontrol('sty','radio','str','B&W','call','plt hcpy rbg1 BW;');
     Hhcpy(6) = uicontrol('sty','radio','str','Clip Board','call','plt hcpy rbg2 cb;');
     Hhcpy(8)    = uicontrol('sty','radio','str','Device','call','plt hcpy rbg2 dev;');
     Hhcpy(7)   = uicontrol('sty','radio','str','File','call','plt hcpy rbg2 file;');
     Hhcpy(11) = uicontrol('sty','text','str',pS2,'horiz','left');
     Hhcpy(10)  = uicontrol('sty','text','str', 'Path/File:','horiz','left');
     Hhcpy(9)  = uicontrol('str','Print','call','plt hcpy print;','user',renderer);
     Hhcpy(2)   = uicontrol('str','Select File','call','plt hcpy OpenPBcb;');
     cncl            = uicontrol('str','Cancel','call','close(gcf)');
     h1 = Hhcpy([3 5 4 6 8 7]);
     h2 = Hhcpy([11 10]);
     h3 = [Hhcpy([9 2]) cncl];
     set(h1,{'Val'},{pS1(3,1); pS1(5,1); pS1(4,1); pS1(6,1); pS1(8,1); pS1(7,1)});
     set([h1 h2],'backg',[.8,.8,.9],'foreg','black');
     set([h1 h2 h3],{'pos'},{[115 80 100 15]; [ 10 85 65 15]; [10 70  65 15]; [245 85 95 15];
                           [245 55  95 15]; [245 70 95 15]; [10 35 330 15]; [ 10 50 65 15];
                           [110  5  55 20]; [ 10  5 85 20]; [180 5  55 20]});
     for i=1+1:12-1
       if pS1(i,2)==1  set(Hhcpy(i),'ena','on'); else set(Hhcpy(i),'ena','of'); end;
     end;
     if get(Hhcpy(8),'Val') set(Hhcpy(2),'str','Select Dev');
     else                       set(Hhcpy(2),'str','Select File');
     end;
  case 364
     switch sum(In1)
     case 67,  set(Hhcpy(5),'Val',1); set(Hhcpy(4),'Val',0);
     case 153, set(Hhcpy(4),'Val',1);    set(Hhcpy(5),'Val',0);
     end;
  case 365
     switch sum(In1)
     case 319,  set(Hhcpy(6),'Val',0);  set(Hhcpy(7),'Val',0);
                 set(Hhcpy(9),'ena','on'); set(Hhcpy(11),'ena','of');
                 set(Hhcpy(8),'Val',1);      set(Hhcpy(2),'str','Select Dev','ena','on');
     case 197,   set(Hhcpy(6),'Val',1);   set(Hhcpy(7),'Val',0);
                 set(Hhcpy(9),'ena','on'); set(Hhcpy(11),'ena','of');
                 set(Hhcpy(8),'Val',0);     set(Hhcpy(2),'ena','of');
     case 416, set(Hhcpy(6),'Val',0);  set(Hhcpy(7),'Val',1);
                 set(Hhcpy(8),'Val',0);     set(Hhcpy(2),'str','Select File','ena','on');
                 fileN = get(Hhcpy(11),'str');
                 if length(fileN)<5 fileN='none'; set(Hhcpy(11),'str',fileN); end;
                 if strcmp(fileN(1:4),'none') set(Hhcpy(9),'ena','of'); end;
                 set(Hhcpy(11),'ena','on');
     end;
  case 751
     s = get(Hhcpy(3),'Val');
     en = [1 1 0 1 1; 1 1 0 1 0; 1 1 0 1 1; 1 1 0 0 1; 0 1 0 1 1; 0 1 0 1 1; 0 0 1 1 1];
     va = [0 1 0 1 0; 0 1 0 1 0; 0 1 0 0 1; 0 1 0 0 1; 0 1 0 1 0; 0 1 0 1 0; 0 0 1 1 0];
     ext= ['wmf';     'bmp';     'hgl';     'jet';     'ps ';     'eps';     'xxx']; ext=ext(s,:);
     if s==7  set(Hhcpy(2),'str','Select Dev', 'ena','on'); set(Hhcpy(11),'ena','of');
     else     set(Hhcpy(2),'str','Select File','ena','on'); set(Hhcpy(11),'ena','on');
              fileN = get(Hhcpy(11),'str');  lf = length(fileN);
              if lf < 5 fileN='none'; set(Hhcpy(11),'str',fileN); end;
              d = findstr('.',fileN);
              if length(d) set(Hhcpy(11),'str',[fileN(1:d(end)) ext]);
              else         set(Hhcpy(11),'str',[fileN '.' ext]);
              end;
     end;
     ena = {'off' 'on'};
     set(Hhcpy(6),'ena',ena{1+en(s,1)},'Val',va(s,1));
     set(Hhcpy(7),  'ena',ena{1+en(s,2)},'Val',va(s,2));
     set(Hhcpy(8),   'ena',ena{1+en(s,3)},'Val',va(s,3));
     set(Hhcpy(5), 'ena',ena{1+en(s,4)},'Val',va(s,4));
     set(Hhcpy(4),    'ena',ena{1+en(s,5)},'Val',va(s,5));
  case 745
     if strcmp('Select File',get(Hhcpy(2),'str'))
        ext=['wmf';'bmp';'hgl';'jet';'ps ';'eps';'xxx']; ext=ext(get(Hhcpy(3),'Val'),:);
        [fileN,pathN]= uiputfile(['*.',ext],'Open (new) File');
        if fileN
           fi = fileN;
           if isempty(findstr('.',fi)) fi = [fi '.' ext]; end;
           set(Hhcpy(11),'str',[pathN fi]);  set(Hhcpy(9),'ena','on');
        end;
     elseif strcmp('Select Dev',get(Hhcpy(2),'str')) print -dsetup
     else   disp('Invalid OpenPBcb string');
     end;
  case 557
     invertStr= get(Hhcpy(12),'invert');
     set(Hhcpy(12),'invert','off');
     figure(Hhcpy(12)); drawnow;
     PrintMode = get(Hhcpy(3),'Val');
     colorFlg  = get(Hhcpy(5),'Val');
     printStr = sprintf('print -f%d',Hhcpy(12));
     renderer = get(Hhcpy(9),'user');
     options={[' ' renderer ' -dmeta '];' -dbitmap ';' -dhpgl ';' -dljet2p '};
     if colorFlg options = [options; {' -dpsc ';' -depsc ';' -dwinc '}];
     else        options = [options; {' -dps ' ;' -deps  ';' -dwin  '}];
     end;
     printStr=[printStr options{PrintMode,:} ' '];
     if get(Hhcpy(7),'Val')==1
        PathFilen = get(Hhcpy(11),'str');  printStr=[printStr '''' PathFilen ''''];
     end;
     printStr = [printStr ' -noui'];  axh = [];  axh = findobj(Hhcpy(12),'type','axes');  nax = length(axh);
     if ~colorFlg
        figC=get(Hhcpy(12),'color');
        axChild = [];   axCol = zeros(nax,3);  axSpcl = zeros(nax,1);
        for i=1:nax
           x = get(axh(i),'color');
           if strcmp('none',x) axSpcl(i) = 1; else axCol(i,:)  = x; end;
           axChild = [axChild; get(axh(i),'child')];
           xCol(i,:) = get(axh(i),'xcol');  yCol(i,:) = get(axh(i),'ycol');
           tCol(i,:) = get(get(axh(i),'title'),'color');
           if xCol(i,:) == figC  axSpcl(i) = axSpcl(i) + 2; end;
        end;
        naxChild = length(axChild);
        for i=1:naxChild
           if sum(get(axChild(i),'type'))==528   kidCol(i,:) = get(axChild(i),'facecolor');
                                                    set(axChild(i),'facecolor',[.25 .25 .25]);
           else kidCol(i,:) = get(axChild(i),'color'); set(axChild(i),'color','black');
           end;
        end;
        set(Hhcpy(12),'color','white');
        for i= 1:nax
           if axSpcl(i)==1 | axSpcl(i)==3
           else set(axh(i),'color','white');
           end;
           if axSpcl(i)>=2 set(axh(i),'xcol','white','ycol','white' );
           else            set(axh(i),'xcol','black','ycol','black' );
           end;
        end;
        for i=1:nax
           if get(get(axh(i),'title'),'color')==figC set(get(axh(i),'title'),'color','white');
           else                                    set(get(axh(i),'title'),'color','black');
           end;
           if axSpcl(i) >=2
                set(get(axh(i),'xlab'),'color','white'); set(get(axh(i),'ylab'),'color','white');
           else set(get(axh(i),'xlab'),'color','black'); set(get(axh(i),'ylab'),'color','black');
           end;
        end;
     end;
     set(Hhcpy(1),'pointer','watch'); drawnow; pause(1);
     if PrintMode == 2
        set(Hhcpy(1),'vis','of');
        refresh
        eval(printStr);
        set(Hhcpy(1),'vis','on');
     else  drawnow discard;  eval(printStr);
     end;
     if ~colorFlg & (PrintMode ~=4 | PrintMode ~=7)
        set(Hhcpy(12),'color',figC);
        for i=1:nax
           if ~rem(axSpcl(i),2) set(axh(i),'color',axCol(i,:)); end;
           set(axh(i),'xcol',xCol(i,:)); set(axh(i),'ycol',yCol(i,:));
           set(get(axh(i),'title'),'color',tCol(i,:));
        end;
        for i=1:naxChild
           if sum(get(axChild(i),'type'))==528 set(axChild(i),'facecolor',kidCol(i,:));
           else                                   set(axChild(i),'color',kidCol(i,:));
           end;
        end;
        if PrintMode==2 drawnow; else drawnow discard; end;
     end;
     pS1=zeros(12-1,2);
     for i=1+1:12-1
        pS1(i,1) = get(Hhcpy(i),'Val');
        if sum(get(Hhcpy(i),'ena'))==221 pS1(i,2)=1; end;
     end;
     pS2=get(Hhcpy(11),'str');
     foobar = 0;
     if exist('foobar')
          cpath = feval('which','plt.m');
     else cpath = GetExe;
     end;
     save([fileparts(cpath) filesep 'pltHcpy.mat'],'pS1','pS2');
     close(Hhcpy(1));
     set(Hhcpy(12),'invert',invertStr);
     clear Hhcpy
  otherwise disp([Action ' invalid Action in plt(hcpy)']);
  end;

case 670

    Action = 'update';  CurID = -1;
    if MverE  ERAS = 'eras';  ERAXOR = 'xor';  ERANOR = 'norm';
    else      ERAS = 'pi';    ERAXOR = 'v';    ERANOR = 'v';
    end;
    In1 = '';  In2 = '';  In3 = '';  In4 = '';  In5 = '';
    In6 = '';  In7 = '';  In8 = '';  In9 = '';
    if Narg > 1
       CurID = varargin{2};
       if Narg > 2
          Action = varargin{3};
          if Narg > 3
            In1 = varargin{4};
            if Narg > 4
              In2 = varargin{5};
              if Narg > 5
                In3 = varargin{6};  if iscell(In3) In3 = char(In3); end;
                if Narg > 6
                  In4 = varargin{7};
                  if Narg > 7
                    In5 = varargin{8};
                    if Narg > 8
                      In6 = varargin{9};  if iscell(In6) In6 = char(In6); end;
                      if Narg > 9
                        In7 = varargin{10};
                        if Narg > 10
                          In8 = varargin{11};
                          if Narg > 11 In9 = varargin{12}; end;
                        end;
                     end;
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
    end;
    CurMain = getappdata(0,'CurMain');
    sact = sum(lower(Action));
    if sact ~= 436
      if ischar(CurID) CurID = sscanf(CurID,'%d'); end;
      if ~CurID CurID = getappdata(gcf,'cidP');
      elseif CurID<0 tmp = getappdata(gcf,'cid');  CurID = -CurID;
                     if CurID>length(tmp) return; else CurID = tmp(CurID); end;
      end;
      if CurID > length(CurMain) disp('invalid cursorID'); return; end;
      Hc = get(CurMain(CurID),'user');
      if isempty(Hc) disp('invalid cursor ID'); return; end;
      setappdata(gcf,'cidP',CurID);
      ax = Hc(14);  ax2 = Hc(15);
      if isempty(get(ax2,'par')) ax2 = []; end;
      axlink = 0;
      if ishandle(ax2)
           if sum(get(ax2,'vis')) == 315  ax2=[];
           else axlink = [get(get(ax2,'ylab'),'str') '  '];
                axlink = axlink(1)~=92 | axlink(2) ~= 'd';
           end;
      end;
      hix = Hc(4);  hiy = Hc(6);
      misc = get(hix,'user');
      actv = misc(4);
      iact = 15 + actv;
      ix   = misc(1);
      hact = Hc(iact);
      lh = get(hact,'user');
      lk = lh{1};
      Ret1 = hact;  Ret2 = lk;
      if ~ishandle(hact) return; end;
      xylim = [get(ax,'xlim') get(ax,'ylim')];
      xyli = xylim;
      if get(hact,'par')==ax2 xyli(3:4) = get(ax2,'ylim'); end;
      DualCur = getappdata(ax,'DualCur');
    end;
    Narg2=Narg;
    switch sact
    case 436
      if MverE Hc = zeros(1,15);
      else     Hc = gobjects(1,15);
      end;
      ax = CurID(1);
      DualCur = getappdata(ax,'DualCur');
      if isempty(DualCur) DualCur = 0;  setappdata(ax,'DualCur',0); end;
      Hc(14) = ax;
      if length(CurID)==2  ax2 = CurID(2);  ax2a = ax2; else ax2 = [];  ax2a = 0; end;
      Hc(15) = ax2a;
      hf = get(ax,'par');
      if isempty(In7) vis='on'; else vis=In7; end;
      Cn = length(CurMain);
      f = find(~CurMain);
      if length(f) CurID = f(1);
      else CurMain = [CurMain 0]; CurID = Cn+1;
      end;
      if CurID>200 disp('Warning: Clear actions missing for 200 cursor inits'); end;
      Ret1 = CurID;
      setappdata(gcf,'cidP',CurID);
      CurIDstr  = {@plt 'cursor' CurID};
      if getappdata(gcf,'indep') CurIDstr0 = {@plt 'cursor' 0}; else CurIDstr0 = CurIDstr; end;
      hLines = getappdata(ax,'Lhandles');
      skp = get(hLines,'tag');
      if ~iscell(skp) skp = {skp}; end;
      hLines = hLines(cellfun('length',skp) ~= 7);
      axes(ax);
      set(gcf,'vis','of');
      if isempty(In2) In2 = [.7 .7 .7; 0 0 0; 1 1 .51; 1 0 0; 0 0 0]; end;
      trk = ~sum(In2(2,:));
      if length(hLines)
         In2n = length(In2(:,1));
         clines = length(hLines);
         cli4 = clines + 4;
         if In2n < cli4
           In2 = In2(min(1:cli4,In2n*ones(1,cli4)),:);
         end;
         In4n = length(In4);
         if In4n<clines
           In4 = In4(min(1:clines,In4n*ones(1,clines)));
         end;
         In2n     = length(In2(:,1));
         objColor = In2(5:In2n,:);
         tact = 0;
         if length(ax2) hLines2 = findobj(ax2,'type','line');
         else           hLines2 = 0;
         end;
         if MverE  Hc = [Hc zeros(1,clines)];
         else      Hc = [Hc gobjects(1,clines)];
         end;
         for i=1:clines
            hi = hLines(i);
            xy = [get(hi,'x'); get(hi,'y')];
            if sum(objColor(i,:)) curColor = objColor(i,:);
            else                  curColor = get(hi,'color');
            end;
            Hc(15+i)=line('x',xy(1,1),'y',xy(2,1),ERAS,ERAXOR,'color',curColor,'linestyle','none',...
                            'clipping','on','vis',vis,'user',{hi trk});
            set(Hc(15+i),'marker',In4(i),'MarkerSize',In5);
            set(hi,'buttond',[CurIDstr {'lineCB' i}]);
            if ~tact & (sum(get(hi,'vis'))==221) tact = i; end;
            if length(find(hi==hLines2)) set(Hc(15+i),'par',ax2); end;
         end;
      else disp('no lines to attach cursors to')
      end;
      if max(max(In1))>2 unitt = 'Pixels'; else unitt = 'Normal'; end;
      fontsz = (196-get(0,'screenpix'))/10;
      for i=2:3
        if i==2  cbStr  = 'x'; else cbStr  = 'y'; end;
        cbStr= [CurIDstr {'scaleAxis' cbStr}];
        if isempty(In3) In3 = ['x';'y']; end;
        Hc(i) = uicontrol(hf,'Style','text','fontsi',fontsz,'vis',vis,'str',deblank(In3(i-2+1,:)),...
                'Units',unitt,'pos',In1(i-1,:),'backg',In2(1,:),'horiz','cent','buttond',cbStr,'ena','inact');
      end;
      bd1 = 'plt click EDIT '; bd2 = {'1;' '6 1;' '2;' '6 3;'};
      for i=4:7
        cbStr  = [CurIDstr {'editCB' i-4}];
        bdStr  = [bd1 bd2{i-4+1}];
        Hc(i) = uicontrol(hf,'Style','edit','fontsi',fontsz,'vis',vis,'str',' ','Units',unitt,'pos',In1(i-1,:),...
            'foreg',[0 0 0],'horiz','left','call',cbStr,'buttond',bdStr,'tag',sprintf('%d',CurID));
      end;
      set(Hc([5 7]),'vis','of');
      hix = Hc(4);  hiy = Hc(6);
      ih = [8 9 10 11];  c = [173 175 79 68];
      cbs = {{'peakval' 0} {'peakval' 1} {'mlsCB' ''} {'markCB' ''}};
      cbk = CurIDstr0;
      for k = 1:4
        m = ih(k);    pt = In1(m-1,:);
        if pt(1)<0 break; end;
        if k==4 cbk = CurIDstr; end;
        Hc(m) = uicontrol(hf,'Units',unitt,'pos',In1(m-1,:),'vis',vis,'horiz','cent',...
                  'str',char(c(k)),'fontname','symbol','fontw','bol','call',[cbk cbs{k}]);
      end;
      if k==1
        if MverE  Hc(8:11) = -1;
        else      Hc(8:11) = gobjects;
        end;
      else
        set(Hc(8), 'ui',uicontextmenu('call',[cbk {'peakval' 2}]));
        set(Hc(9),'ui',uicontextmenu('call',[cbk {'peakval' 3}]));
        set(Hc(10),'ui',uicontextmenu('call','plt misc rstyle;'));
        set(Hc(11),'fontsi',12,'ui',uicontextmenu('call','plt misc rdelta;'));
        setappdata(gcf,'peak',-inf); setappdata(gcf,'vall',inf);
      end;
      Hc(13) = line('x',[],'y',[],ERAS,ERAXOR,'color',In2(4,:),'vis','of');
      set(Hc(13),'marker','+','MarkerSize',5*In5,'tag','DeltaC');
      if isempty(In6) In6 = ['%7w';'%7w']; end;
      set(Hc(3),'user',In6);
      if length(In1(:,1)) >= 11
        uicontrol(hf,'style','slider','Units',unitt,'pos',In1(11,:),...
             'backg',[.3 .3 .3],'Min',0,'Max',1000,'Val',500,'user',500,...
             'vis',vis,'call',[CurIDstr {'xslider'}],'tag','xslider');
      end;
      set(get(ax,'xlab'),'buttond',[CurIDstr {'xincr'}]);
      i = [CurIDstr {'axisCB'}];
      Hc(12) = line('x',[],'y',[],ERAS,ERAXOR,'vis','of','color',In2(3,:),'buttond',i);
      set([hf ax],'buttond',i);
      if isempty(In8) monoFlag = -1; else monoFlag = In8; end;
      set(Hc(5),'user',In9);
      misc = zeros(1,8);
      if length(ax2) set(ax2,'buttond',[CurIDstr {'AxisCBr'}]); end;
      misc(5) = monoFlag;
      misc(4) = max(1,tact);
      set(hix,'user',misc);
      set(Hc(7),'user',''); setappdata(Hc(7),'CB2','');
      set(Hc(2),'user',Hc);
      CurMain(CurID) = Hc(2);
      setappdata(0,'CurMain',CurMain);

    case 536
      p0 = getappdata(get(ax,'xlab'),'OldCur');
      sc = get(ax,'yscale');  liny = sc(2)=='i';
      if ischar(In1)
          aPt = get(ax2,'currentp');  cy = aPt(1,2);
          y = get(ax2,'ylim');
          if liny  y = y + p0(2) - cy;
          else     y = y * p0(2) / cy;
          end;
          set(ax2,'ylim',y);
      else
        aPt = get(ax,'currentp');
        cx = aPt(1,1);  cy = aPt(1,2);
        if In1<1 x = xylim(1:2);
                 sc = get(ax,'xscale');
                 if sc(2)=='i' x = x + p0(1) - cx;
                 else          x = x * p0(1) / cx;
                 end;
                 if length(ax2) axb = [ax ax2]; else axb = ax; end;
                 set(axb,'xlim',x);
        end;
        if In1   y = xylim(3:4);
                 if liny  yi = p0(2) - cy;  y = y + yi;
                 else     yi = p0(2) / cy;  y = y * yi;
                 end;
                 set(ax,'ylim',y);
                 if axlink
                   yr = get(ax2,'ylim');
                   if liny  yr = yr + yi * diff(yr)/diff(y);
                   else     yr = yr * (yr(2)/yr(1))^(log(yi)/log(y(2)/y(1)));
                   end;
                   set(ax2,'ylim',yr);
                 end;
        end;
      end;
      plt('grid',ax);
      fixMark;
    case 670
      p0 = getappdata(get(ax,'xlab'),'OldCur');
      if ischar(In1)
          aPt = get(ax2,'currentp');
          y = get(ax2,'ylim');  y0 = y(1);  y1 = y(2);
          cy = aPt(1,2)-y0;  if ~cy cy=1e-06; end;
          set(ax2,'ylim',[y0 y0 + abs((p0(2)-y0)*(y1-y0)/cy)]);
      else
        aPt = get(ax,'currentp');
        if In1<1 x0 = xylim(1);  x1 = xylim(2);
                 cx = aPt(1,1)-x0;  if ~cx cx=1e-06; end;
                 if length(ax2) axb = [ax ax2]; else axb = ax; end;
                 set(axb,'xlim',[x0 x0 + abs((p0(1)-x0)*(x1-x0)/cx)]);
        end;
        if In1   y0 = xylim(3);  y1 = xylim(4);  dy = y1-y0;
                 cy = aPt(1,2)-y0;  if ~cy cy=1e-06; end;
                 cy = dy/cy;  p2 = p0(2)-y0;
                 set(ax,'ylim',[y0 y0 + abs(p2*cy)]);
                 if axlink
                    sc = get(ax,'yscale');
                    if sc(2)=='i'
                       y = get(ax2,'ylim');  y0 = y(1);  y1 = y(2);
                       p2 = (y1-y0) * p2 / dy;
                       set(ax2,'ylim',[y0 y0 + abs(p2*cy)]);
                    else
                       yr = get(ax2,'ylim');  yr0 = yr(1);  yr1 = yr(2);
                       aPt = get(ax2,'currentp');
                       cy = aPt(1,2)-yr0;  if ~cy cy=1e-06; end;
                       p0 = yr0 * exp(log(p0(2)/y0) * log(yr1/yr0) / log(y1/y0));
                       set(ax2,'ylim',[yr0 yr0 + abs((p0-yr0)*(yr1-yr0)/cy)]);
                     end;
                 end;
        end;
      end;
      plt('grid',ax);
      fixMark;
    case 662
      expbx = Hc(12);  set(hact,'vis','of');
      if DualCur set(Hc(15+DualCur),'vis','of'); end;
      aPt  = get(ax,'currentp');
      xCur = max(xylim(1),min(xylim(2),aPt(1,1)));  yCur = max(xylim(3),min(xylim(4),aPt(1,2)));
      aPt   = get(expbx,'user');
      xOld  = aPt(1);  yOld  = aPt(2);
      if sum(get(ax,'yscale')) == 322
            dxyOk = abs(log(xylim(3)/xylim(4))) < 50 * abs(log(yOld/yCur));
      else  dxyOk = diff(xylim(3:4)) < 50 * abs(yOld-yCur);
      end;
      if dxyOk
         if sum(get(ax,'xscale')) == 322
               dxyOk = abs(log((.0001*xylim(2)+xylim(1))/xylim(2))) < 50 * abs(log(xOld/xCur));
         else  dxyOk = diff(xylim(1:2)) < 50 * abs(xOld-xCur);
         end;
      end;
      if dxyOk
          set(expbx,'x',[xOld xCur xCur xOld xOld],'y',[yOld yOld yCur yCur yOld]);
          f2 = get(Hc(3),'user');  f1 = f2(1,:);  f2 = f2(2,:);
          if sum(get(expbx,'vis')) == 315
             set(hix,'str',Pftoa(f1,xOld));  set(hiy,'str',Pftoa(f2,yOld));
             set(expbx,'vis','on');  set(Hc(4:7),'ena','on');
             set2(Hc(11),'ena','of');
          end;
          bf = {'backg'; 'foreg'};  
          set(Hc([5 7]),{'str'},prin([f1 ' ~; ' f2],xCur,yCur),bf,get(hix,bf),'vis','on');
      end;
      mZoom([xOld xCur yOld yCur]);
    case 712
      aPt  = get(ax,'currentp');  new = complex(aPt(1,1),aPt(1,2));
      expbx = Hc(12);   xy = get(expbx,'user');  old = xy(1);
      xy = xy(2:end) + new - old;  x = real(xy);  y = imag(xy);
      set(expbx,'x',x,'y',y);
      f2 = get(Hc(3),'user');  f1 = f2(1,:);  f2 = f2(2,:); s = ' ~; ';
      set(Hc(4:7),{'str'},prin([f1 s f1 s f2 s f2],x(1:2),y(2:3))); 
      mZoom([x(1:2) y(2:3)]);
    case {634, 621},
      if sact==634 & Narg2>3 & ~isnumeric(In1) set(Hc(5),'user',In1); return; end;
      b = get(hact,'buttond'); if length(b) & ischar(b) eval(b); return; end;
      clkType = sum(get(gcf,'SelectionT'));
      expbx = Hc(12);
      boxVis = sum(get(expbx,'vis'));
      aPt  = get(ax,'currentp');  cx = aPt(1,1);  cy  = aPt(1,2);
      xCur = max(xylim(1),min(xylim(2),cx));
      yCur = max(xylim(3),min(xylim(4),cy));
      dxy = diff(xylim);
      smv = '';
      StopMotion = 'set(gcf,''WindowButtonMotionFcn'','''',''WindowButtonUpFcn'','''');';
      CurIDstr = {@plt 'cursor' CurID};
      if (boxVis==315) & ~misc(7) & ~misc(8)
         if     cx<xylim(1) | cx>xylim(2)   dragy =  1;
         elseif cy<xylim(3) | cy>xylim(4)   dragy =  0;
         else                               dragy = -1;
         end;
         switch clkType
         case 649
            ovt = 0;
            if sact==634
               Narg2 = 4;
               if sum(get(lk,'vis')) ~= 221
                  for i=15+1:length(Hc)
                      lh = get(Hc(i),'user');  lk = lh{1};
                      if sum(get(lk,'vis')) == 221 break; end;
                  end;
                  actv = i-15;
               end;
               In1 = actv;
               if length(ax2)
                 ylm = get(ax2,'ylim');  dylm = diff(ylm);
                 cvert = (cy - xylim(3)) / dxy(3);
                 mdst = 1e+99;
                 idst = 0;
                 for i=15+1:length(Hc)
                   if get(Hc(i),'par') ~= ax2 continue; end;
                   lh = get(Hc(i),'user'); lk = lh{1};
                   if sum(get(lk,'vis')) == 315 continue; end;
                   x = get(lk,'x'); y = get(lk,'y');
                   if length(x)>999 | all(diff(x)>0)
                     [toss,j] = min(abs(xCur-x));
                     dvert = (y(j) - ylm(1)) / dylm;
                     acv = abs(cvert-dvert);
                   else
                     acv = min(abs((x-xCur)/dxy(1)) + abs((y-ylm(1))/dylm - cvert));
                   end;
                   if acv < mdst  idst = i;  mdst = acv; end;
                 end;
                 if mdst < .02
                   ovt = 1;
                   ii = idst-15;
                   if ii ~= DualCur In1 = ii; end;
                 end;
               end;
            end;
            lh = get(Hc(15+In1),'user'); lk = lh{1};
            x = get(lk,'x'); y = get(lk,'y');
            if Narg2==4
               setappdata(gcf,'peak',-inf); setappdata(gcf,'vall',inf);
               if misc(5)==-1
                  df = diff(x);
                  monoFlag = all(df>0) | all(df<0);
               else monoFlag = misc(5);
               end;
            else monoFlag=In2;
            end;
            if monoFlag [junk,imin] = min(abs(xCur-x));
            elseif get(lk,'par')==ax2
                  ylm = get(ax2,'ylim');  dylm = diff(ylm);
                  cvert = (cy - xylim(3)) / dxy(3);
                  [toss,imin] = min(abs((x-xCur)/dxy(1)) + abs((y-ylm(1))/dylm - cvert));
            else  [toss,imin] = min(abs((x-xCur)/dxy(1)) + abs(yCur-y)/dxy(3));
            end;
            actv = In1;  misc(4) = actv;
            iact = 15 + actv;
            hact = Hc(iact);
            set(hix,'user',misc);
            if length(getappdata(gca,'offline')) yimin = yCur;
            else                                 yimin = y(imin);
            end;
            plt('cursor',CurID,'update',imin,x(imin),yimin);
            if (sact==621) | ovt
              if Narg2==4
                smv = [CurIDstr {'lineCB' In1 monoFlag 0}];
              end;
            else setappdata(get(ax,'xlab'),'OldCur',[cx cy xylim]);
                 StopMotion = [CurIDstr {'svHist'}];
                 smv = [CurIDstr {'panAX' dragy}];
            end;
         case 321
            setappdata(get(ax,'xlab'),'OldCur',[cx cy xylim]);
            StopMotion = [CurIDstr {'svHist'}];
            smv = [CurIDstr {'zoomAX' dragy}];
         otherwise,
            set(expbx,'user',[xCur yCur]);
            StopMotion = [CurIDstr {'expSwap'}];
            smv = [CurIDstr {'expbox'}];
         end;
      elseif (boxVis==221) | misc(7) | misc(8)
        if clkType==649
              cxy   = complex(cx,cy);  xyl13 = complex(xylim(1),xylim(3));  dxy13 = complex(dxy(1),dxy(3));
              cor5  = complex(get(expbx,'x'),get(expbx,'y'));
              cor = cor5(1:4);
              corn = divc(cor-xyl13,dxy13);
              edgn = (corn + corn([2 3 4 1]))/2;
              curn = divc(cxy-xyl13,dxy13);
              [cdst ci] = min(abs(curn-corn));
              [edst ei] = min(abs(curn-edgn));
              edst = edst/2;  dst = min(edst,cdst);
              StopMotion = [CurIDstr {'expSwap'}];
              if dst > .02 plt('cursor',CurID,'scale','new2');
              elseif dst==cdst
                   c = cor(mod(ci+1,4)+1); set(expbx,'user',[real(c) imag(c)]);
                   smv = [CurIDstr {'expbox'}];
              else set(expbx,'user',[cxy cor5]);  smv = [CurIDstr {'expbox2'}];
              end;
        else  plt('cursor',CurID,'restore');
        end;
        misc([7 8]) = 0;  set(hix,'user',misc);
      end;
      if length(smv) set(gcf,'WindowButtonMotionFcn',smv,'WindowButtonUpFcn',StopMotion); end;
    case 748
      CurIDstr = {@plt 'cursor' CurID};
      aPt  = get(ax2,'currentp');  setappdata(get(ax,'xlab'),'OldCur',[aPt(1,1) aPt(1,2)]);
      if sum(get(gcf,'SelectionT'))==321 smv = [CurIDstr {'zoomAX' 'R'}];
      else          smv = [CurIDstr {'panAX'  'R'}];
      end;
      set(gcf,'WindowButtonMotionFcn',smv,'WindowButtonUpFcn','set(gcf,''WindowButtonMotionFcn'','''',''WindowButtonUpFcn'','''');');
    case 619
      s = get(Hc(4:7),'str');
      fmt = get(Hc(3),'user');
      for k=0:3
        ss = s{k+1};
        if k==In1 x = str2num(ss); j = 4+k;
                  if length(x) set(Hc(j),'str',Pftoa(fmt(1+(k>1),:),x));
                  else         set(Hc(j),'str','invalid');  setappdata(gcf,'newtxt',ss);  return;
                  end;
        else      x = str2double(ss);
        end;
        w(k+1) = x;
      end;
      if sum(get(Hc(12),'vis'))==221 | misc(7) | misc(8) 
         set(Hc(12),'x',w([1 2 2 1 1]),'y',w([3 3 4 4 3]));
         mZoom(w);
         plt('cursor',CurID,'expSwap');
      else
        if getappdata(gcf,'indep')>0
           ci = getappdata(Hc(4+In1),'indep');
           if length(ci)
              CurID = ci;
              if CurID > length(CurMain) disp('invalid cursorID'); return; end;
              Hc = get(CurMain(CurID),'user');
              if isempty(Hc) disp('invalid cursor ID'); return; end;
              setappdata(gcf,'cidP',CurID);
              ax = Hc(14);  ax2 = Hc(15);
              if isempty(get(ax2,'par')) ax2 = []; end;
              hix = Hc(4);  hiy = Hc(6);
              misc = get(hix,'user');
              actv = misc(4);
              iact = 15 + actv;
              hact = Hc(iact);
              lh = get(hact,'user');
              lk = lh{1};
              xyli = [get(ax,'xlim') get(ax,'ylim')];
              if get(hact,'par')==ax2 xyli(3:4) = get(ax2,'ylim'); end;
           end;
        end;
        xd = get(lk,'x');  yd = get(lk,'y');
        editd = length(get(hact,'buttond'));
        switch In1
          case 0, if editd set(hact,'x',w(1)); plt click EDIT 5 0; return; end;
                  [q ix] = min(abs(xd-w(1)));
          case 2, if editd set(hact,'y',w(3)); plt click EDIT 5 0; return; end;
                  [q ix] = min(abs(yd-w(3)));
          otherwise, return;
        end;
        xv = xd(ix);  yv = yd(ix);
        if xv<xyli(1) | xv>xyli(2) plt('cursor',CurID,'xlim',xv+[-.5 .5].*diff(xyli(1:2))); end;
        if yv<xyli(3) | yv>xyli(4) plt('cursor',CurID,'ylim',yv+[-.5 .5].*diff(xyli(3:4))); end;
        plt('cursor',CurID,'update',ix);
      end;
    case 776
      set(gcf,'WindowButtonMotionFcn','','WindowButtonUpFcn','');
      expbx = Hc(12);
      x = get(expbx,'x'); if length(x)<5 return; end; y = get(expbx,'y');
      if x(2)<x(1) x = x([2 1 1 2 2]);  set(expbx,'x',x);  s = get(Hc(5),'str');
                   set(Hc(5),'str',get(Hc(4),'str'));  set(Hc(4),'str',s);
      end;
      if y(3)<y(2) y = y([3 3 2 2 3]);  set(expbx,'y',y);  s = get(Hc(7),'str');
                   set(Hc(7),'str',get(Hc(6),'str'));  set(Hc(6),'str',s);
      end;
      a = getappdata(gca,'MotionZup');
      if length(a)
        b = [x(1:2) y(2:3)];
        if ischar(a)     feval(a,b);
        elseif iscell(a) a = [a {b}]; feval(a{:})
        else             a = {a b};   feval(a{:});
        end;
      end;
    case 673
      set(gcf,'WindowButtonMotionFcn','','WindowButtonUpFcn','');
      p0 = getappdata(get(ax,'xlab'),'OldCur');
      if any(xylim - p0(3:6))
        set(Hc(12),'x',[xylim(1:2) 0 0 0],...
                        'y',[xylim(3) 0 xylim(4) 0 0]);
        set(ax,'xlim',p0(3:4),'ylim',p0(5:6));
        plt('cursor',CurID,'scale','new',0,0);
      end;
    case {643 747 753}
      set(Hc(15+1:end),'vis','of');
      if ischar(In1) In1 = sscanf(In1,'%d'); end;
      if isempty(In1) | ~In1 In1 = ix; end;
      if sum(get(lk,'vis')) == 315
        for i=15+1:length(Hc)
          lh = get(Hc(i),'user'); lk = lh{1};
          if sum(get(lk,'vis')) == 221 break; end;
        end;
        actv = i-15; misc(4) = actv;
        iact = 15 + actv;
        hact = Hc(iact);
        if ~ishandle(hact) return; end;
      end;
      if sum(get(lk,'vis')) == 315 return; end;
      if isempty(In2)
        x = get(lk,'x');  y = get(lk,'y');  n = length(x);
        if ~n return; end;
        if In1>n | In1<=0
           [toss,In1] = min(abs(mean(xyli(1:2))-x));
         end;  
        In2 = x(In1);  In3 = y(In1);
      end;
      a = get(hact,'par');
      if length(getappdata(a,'subTr')) evalQ(get(Hc(5),'user')); return; end;
      if a == ax  xyl = xylim;  else xyl = xyli; end;
      xlim = xyl(1:2);  ylim = xyl(3:4);
      xd = 1.01 * (In2-xlim);  yd = 1.01 * (In3-ylim);
      if xd(1)<=0 xlim = xlim + xd(1); elseif xd(2)>=0 xlim = xlim+xd(2); end;
      if yd(1)<=0 ylim = ylim + yd(1); elseif yd(2)>=0 ylim = ylim+yd(2); end;
      if ~isequal(xyl,[xlim ylim]) ...
           & sact==643 ...
           & isempty(getappdata(a,'hold'))
         setlim(a,'xlim',xlim); setlim(a,'ylim',ylim);
         if a==ax plt('grid',ax); end;
         evalQ(get(Hc(5),'user'));
      end;
      set(hact,'y',In3,'x',In2,'vis','on');
      multi = getappdata(ax,'multi');
      if length(multi)
        Lha = getappdata(ax,'Lhandles'); n = length(Lha);
        for k = 1:n  yd = get(Lha(k),'y'); yd = yd(min(In1,length(yd)));
                     set(multi(k),'pos',[In2 yd],'str',prin(get(multi(k),'tag'),yd));
                     set(multi(k+n),'x',In2,'y',yd);
        end;
        set(multi(end),'x',[In2 In2]);
      end;
      bf = {'backg' 'foreg'};
      fmt = get(Hc(3),'user');
      lc = get(lk,'color');
      fr = repmat(max(lc.*[.9 1 .5])<=.5,1,3);
      set([hix hiy],{'str'},{Pftoa(fmt(1,:),In2); Pftoa(fmt(2,:),In3)},bf,{lc fr});
      dmode = sum(get(Hc(13),'vis'))==221;
      if dmode
         dxy = {Pftoa(fmt(1,:),In2-get(Hc(13),'x')); Pftoa(fmt(2,:),In3-get(Hc(13),'y'))};
         set(Hc([5 7]),{'str'},dxy,bf,get(hix,bf),'vis','on');
      end;
      if DualCur
        if DualCur>0 dact=15+DualCur; ow=0;
        else dact = iact-DualCur;
             ow = (dact > length(Hc));
             if ow dact=iact+DualCur; end;
        end;
        Hcd = Hc(dact);
        dh = get(Hcd,'user'); dk = dh{1};
        if sum(get(dk,'vis')) == 221
          xy = [get(dk,'x'); get(dk,'y')];
          misc(6) = xy(2,In1);
          xylen = length(xy(1,:)); if ix>xylen ix=xylen; end;
          yd = xy(2,In1);
          a = get(Hcd,'par'); b = get(a,'YaxisLoc');
          if b(1)=='r' b = get(a,'ylim'); yd = max(b(1),min(b(2),yd)); end;
          set(Hcd,'x', max(xyli(1),min(xyli(2),xy(1,In1))),'y',yd,'vis','on');
          if ~dmode set(Hc(5),'vis','of');
                    s = Pftoa(fmt(2,:),xy(2,In1));
                    if ow t = s;  s = get(Hc(6),'str'); set(Hc(6),'str',t); end;
                    dc = get(dk,'color');
                    fr = repmat(max(dc.*[.9 1 .5])<=.5,1,3);
                    set(Hc(7),bf,{dc fr},'str',s,'vis','on');
          end;
        end;
      end;
      misc([1 2 3]) = [In1 In2 In3];  set(hix,'user',misc);
      s = getappdata(Hc(7),'CB2');  evalQ(s);
      sx = getappdata(ax,'xstr');  sy = getappdata(ax,'ystr');  s = [sx sy];
      rep1 = {'@XVAL','real(@XY)',...
              '@YVAL','imag(@XY)',...
              '@XY',  'plt("cursor",@CID,"get")',...
              '@IDX', 'plt2nd({"cursor",@CID,"get"})',...
              '@LNUM','plt("cursor",@CID,"getActive")',...
              '@HAND','plt2nd({"cursor",@CID,"getActive"})',...
              '@XU'  ,'plt("misc",1)',...
              '@YU'  ,'plt("misc",2)',...
              '@CID', sprintf('%d',CurID)};
      for k=1:length(s)
        set(s(k),'str',evalRep2(getappdata(s(k),'evl'),rep1));
      end;
      if length(getappdata(ax,'moveCBext')) | length(find(ax==findobj(gcf,'type','axes')))
        s = get(Hc(7),'user');
        if length(s) & sact~=753
          evalRep(s,rep1);
        end;
      end;
    case 520
      expHis = get(hiy,'user');
      if isempty(expHis) expHis = [xylim 1]; end;
      lExp   = length(expHis(:,1));
      curExp = find(expHis(:,5)==1);
      skip   = [];   In1S = sum(In1);  new2r = (In1S==380);
      switch In1S
      case {330 380}
         xy = Hc(12);  xy = [get(xy,'x') get(xy,'y')];
         expLim = [sort(xy(1:2)) sort(xy([6 8])) 1];
         if isequal(xylim,expLim(1:4))
            if length(curExp) expHis(curExp,5)=1; end;
         else
            if length(curExp)
               expHis(curExp,5)=0;
               if max(curExp,lExp) < 4
                  expHis = [expHis; expLim];
               else
                  if curExp==4  expHis(2:4,:)=[expHis(3:4,:); expLim];
                  elseif curExp >= 1  expHis(curExp+1,:)=expLim;
                  end;
               end;
            else
               if lExp < 4  expHis = [expHis; expLim];
               else               expHis = [expHis(lExp-1,:); expLim];
               end;
            end;
         end;
         autoScale=0;
      case 319
          if sum(get(gcf,'SelectionT'))==321 autoScale=1;
          else
            if isempty(curExp) curExp = lExp;
            else               expHis(curExp,5)=0;  curExp = curExp-1;
            end;
            if curExp  autoScale=0;  expLim=expHis(curExp,:); expHis(curExp,5)=1;
            else       autoScale=1;
            end;
          end;
      case 441
          switch sum(In2)
          case 120,    autoScale=2;
          case 121,    autoScale=3;
          case 429, autoScale=1;
          otherwise, disp([In2 ' is not a valid action in plt(cursor,CurID,scale,auto,In2)']);
          end;
      otherwise, disp([In1 ' is not a valid action in plt(cursor,CurID,scale,In1)']);
      end;
      if autoScale == 0
          setlim(ax,'xlim',sort(expLim(1:2)));
          setlim(ax,'ylim',sort(expLim(3:4)));
          wii = 0;
      else
         numLines=length(Hc)-15;  minx=+inf;  maxx=-inf;
         temp = zeros(numLines,2);  lineList = [];   wii = 1;
         for i=1:numLines
            hLine=get(Hc(15+i),'user');
            if sum(get(hLine{1},'vis')) == 221
               xdata = get(hLine{1},'x');
               minx  = min(minx,min(xdata));
               maxx  = max(maxx,max(xdata));
               if wii ydata = get(hLine{1},'y'); end;
               lineList = [i lineList];  wii = 0;
            end;
         end;

         if wii msgbox('Possible autoscale without any visible lines','Warning','warn','modal');
         else
            for i=1:numLines
              k = Hc(15+i);
              tx = get(k,'x');  ty = get(k,'y');
              temp(i,:) = [tx(1) ty(1)];
              set(k,'x',xdata(1),'y',ydata(1));
            end;
            skip = findobj(ax,'tag','SkipCur','vis','on'); set(skip,'vis','of');
            switch autoScale
            case 1,  set(ax,'YlimM','auto');
                         expLim = [minx maxx get(ax,'ylim') 1];
                         setlim(ax,'xlim',expLim(1:2));
            case 2, expLim = [minx maxx get(ax,'ylim') 1];
                         setlim(ax,'xlim',expLim(1:2));
            case 3,
               misc=get(hix,'user');
               if ismember(actv,lineList)
                  ydata = get(lk,'y');
                  ymax = max(ydata);  ymin = min(ydata);  dy = 0.25*(ymax-ymin);
                  ymin = ymin - dy;   ymax = ymax + dy;
                  if ymin ~= ymax  set(ax,'YlimM','man'); set(ax,'ylim',[ymin ymax]); drawnow;
                  else             set(ax,'YlimM','auto');  drawnow;
                  end;
               else set(ax,'YlimM','man'); drawnow; set(ax,'YlimM','auto');
               end;
               expLim = [xylim 1];
            end;
            for i=1:numLines set(Hc(15+i),'x',temp(i,1),'y',temp(i,2)); end;
         end;
      end;
      if ~wii
         if length(ax2) setlim(ax2,'xlim',expLim(1:2)); end;
         set(hiy,'user',expHis);
         if axlink & Narg<6
           yr = get(ax2,'ylim');
          setlim(ax2,'ylim',yr(1) + (get(ax,'ylim') - xylim(3)) * diff(yr) / (xylim(4)-xylim(3)));
         end;
         if new2r plt('cursor',CurID,'restore'); end;
         axes(ax); evalQ(get(Hc(5),'user'));
      end;
      set(ax,'YlimM','man');
      set(skip,'vis','on');
      plt('grid',ax);
      xView = getappdata(ax,'xView');
      if length(xView) set(xView{1},'x',get(ax,'xlim')); end;
    case 548,
      lx = length(get(lk,'x'));
      ty = sum(get(gcf,'SelectionT'));
      if ty==434 & getappdata(gcbo,'ty')==321 ty = 321; end;
      [rpt p] = getREPEAT;
      setappdata(gcf,'bdown',1);
      set(gcf,'WindowButtonUp','setappdata(gcf,''bdown'',0);');
      while getappdata(gcf,'bdown')
        if ty==321 ix = max(ix-1,1);
        else        ix = min(ix+1,lx);
        end;
        setappdata(gcbo,'ty',ty);
        plt('cursor',CurID,'update',ix);
        if rpt < 0 break; end;
        pause(p);  p = rpt;
      end;
    case 763,
      x = get(lk,'x');   y = get(lk,'y'); lx = length(x);
      xlim = xylim(1:2);   ylim = xylim(3:4);  dxlim = diff(xlim);
      v = get(gcbo,'Val');  x1 = min(x);  x2 = max(x);   xrange = x2 - x1;
      if xrange/dxlim < 2
        dx = round(v - 500);
        if abs(dx)==10 pmove = .01; else pmove = .05; end;
        ix = max(min(lx,ix + sign(dx)*round(lx*pmove)),1);
        x = x(ix);  xd = 1.01 * (x-xlim);
        if xd(1)<0 xlim = xlim + xd(1); elseif xd(2)>0 xlim = xlim+xd(2); end;
        v = 500;
      else
        dx = v - get(gcbo,'user');
        switch round(abs(dx))
          case 10,   xlim = xlim + sign(dx)*dxlim/10;
          case 100,  xlim = xlim + sign(dx)*dxlim;
          otherwise, xlim = x1 + xrange*v/1000 + dxlim*[-.5 .5];
        end;
        if     xlim(1)<x1  xlim = [x1 x1+dxlim] - dxlim/50;
        elseif xlim(2)>x2  xlim = [x2-dxlim x2] + dxlim/50;
        end;
        xlc = mean(xlim);
        v = 1000*(xlc-x1)/xrange;
        v = max(min(v,1000),0);
        [dmy ix] = min(abs(xlc-x));
      end;
      set(gcbo,'Val',v,'user',v);
      y = y(ix);  yd = 1.01 * (y-ylim);
      if yd(1)<0 ylim = ylim + yd(1); elseif yd(2)>0 ylim = ylim+yd(2); end;
      if sum(xylim - [xlim ylim])
         set(ax,'xlim',xlim,'ylim',ylim);
         if length(ax2) set(ax2,'xlim',xlim); end;
         plt('grid',ax);
         evalQ(get(Hc(5),'user'));
      end;
      plt('cursor',CurID,'update',ix);
    case 740
      if ischar(In1) In1 = s2i(In1); end;
      switch In1
        case 2, In1=0; setappdata(gcf,'peak',-inf);
        case 3, In1=1; setappdata(gcf,'vall',inf);
      end;
      y = get(lk,'y'); x = get(lk,'x');
      xx = find(x <= xylim(2) & x >= xylim(1));
      if isempty(xx) x = xylim(1); xx = 1:length(x); disp('You must select a line for the min/max finder'); end;
      y = y(xx);  ly = length(y);
      if In1
         ix=find(y < [y(2:ly) inf] & ...
                 y < [inf  y(1:ly-1)] & ...
                 y > getappdata(gcf,'vall'));
         if isempty(ix)
              [y ix] = min(y);
         else [y i]  = min(y(ix));
              ix = ix(i);
         end;
         setappdata(gcf,'vall',y);
      else
         ix=find(y > [y(2:ly) -inf] & ...
                 y > [-inf y(1:ly-1)] & ...
                 y < getappdata(gcf,'peak'));
         if isempty(ix)
              [y ix] = max(y);
         else [y i] = max(y(ix));
              ix = ix(i);
         end;
         setappdata(gcf,'peak',y);
      end;
      ix = ix + xx(1) - 1;
      plt('cursor',CurID,'update',ix);
    case 772
      fmt = get(Hc(3),'user');
      set(hiy,'str',Pftoa(fmt(2,:),misc(3)));
      set(hix,'str',Pftoa(fmt(1,:),misc(2)));
      set(Hc(12),'vis','of');
      if sum(get(Hc(13),'vis')) == 315
         set(Hc([5 7]),'vis','of','str','');
      end;
      set(hact,'y',max(xyli(3),min(xyli(4),misc(3))),...
               'x',max(xyli(1),min(xyli(2),misc(2))));
      set(Hc([2:3]),'ena','inact');  set2(Hc(11),'ena','on');
    case 529
        l = getappdata(ax,'Lhandles');
        MRK ='marker';  STY = 'linest';
        k = getappdata(ax,'mls');
        if isempty(k) k=1;
                      setappdata(ax,'mrk',get(l,MRK));
                      setappdata(ax,'sty',get(l,STY));
        end;
        mrk = 'o';  sty = getappdata(ax,'sty');
        switch k
          case 1, sty = 'none';
          case 3, mrk = getappdata(ax,'mrk'); k = 0;
                    
        end;
        setappdata(ax,'mls',k+1);
        if iscell(mrk) MRK = {MRK}; end;
        if iscell(sty) STY = {STY}; end;
        set(l,MRK,mrk,STY,sty);
    case 624
      set(Hc(11),'backg',1-get(Hc(11),'backg'));
      if sum(get(Hc(13),'vis')) == 315
            setappdata(ax,'DualCsv',DualCur);
            setappdata(ax,'DualCur',0);
            set(Hc(13),'vis','on','par',get(hact,'par'),'user',actv,...
                'x',get(hact,'x'),'y',get(hact,'y'));
      else  set(Hc([13 5 7]),'vis','of');
            set(lk,'vis','of'); drawnow; set(lk,'vis','on');
            DualCur = getappdata(ax,'DualCsv');
            if DualCur setappdata(ax,'DualCur',DualCur); end;
      end;
    case 557
      fg = get(hix,'par');
      a = findobj(fg,'user','TraceID')';
      if length(a)>1 for k=a if getappdata(k,'cid')==CurID a=k; break; end; end; end;
      a = flipud(findobj(a,'type','text'));
      if length(a)<actv  d = 'Yval';
      else d = deblank(get(a(actv),'str'));
      end;
      b = findobj(fg,'buttond','plt click RMS;')';
      if length(b)>1 for k=b if get(k,'user')==ax b=k; break; end; end; end;
      set(b,{'str','color'},{d,get(hact,'color')});
      bx = getappdata(fg,'bx');
      if length(bx) & ishandle(bx)
        ha = get(get(bx,'par'),'pos');  ha=ha(4);
        nb = round(.03839*ha - 2.27);
        s = get(bx,'user');  t = s{2}; s = s{1};
        d = d(1:min(9,length(d))); f = findstr(d,t);
        if isempty(f) v=''; else v = [blanks(f(1)-1) repmat('v',1,length(d))]; end;
        set(bx,'str',[s(1:ix-1) {t v} s(ix:end)],'Value',ix+1);
        drawnow;
        set(bx,'ListboxTop',max(1,ix-nb));
      end;
    case 315
      Ret1 = [Hc(2:13) hact];
    case 320
      if Narg2==4 if ~isnumeric(In1) disp('Error: plt(''cursor'',cid,''get'',arg) arg must be numeric'); return; end;
                  lineNum = In1;
      else        lineNum = actv;
      end;
      k = Hc(15+lineNum);
      Ret1 = complex(get(k,'x'),get(k,'y'));
      Ret2 = ix;
    case 956
      Ret1 = actv;
      Ret2 = lk;
      if Narg>3 & sum(get(Ret2,'vis'))==315
        Ret1 = 0;
      end;  
    case 657
      expHis = get(hiy,'user');
      if isempty(expHis)
         Ret1  = [[xylim 1]; [zeros(3,4), -ones(3,1)]];
      else aa = 4 - length(expHis(:,1));
           Ret1 = [ expHis; [ zeros(aa,4), -ones(aa,1) ] ];
      end;
      if length(ax2) Ret1 = [Ret1; [get(ax2,'xlim') get(ax2,'ylim') 2]];
      else           Ret1 = [Ret1; [zeros(1,4) -1]];
      end;
    case 653
       h = Hc([2:11 15+1:end])';
       h = [h(ishandle(h)); ...
            findobj(gcf,'tag','xstr'); ...
            findobj(gcf,'tag','ystr'); ...
            findobj(gcf,'buttond','plt click RMS;'); ...
            findobj(gcf,'tag','xslider')];
       h = findobj(h,'vis','on');
       set(h,'vis','of');
       setappdata(Hc(2),'hid',h);
    case 559, set(getappdata(Hc(2),'hid'),'vis','on');
    case 985
       for i=2:11 if ishandle(Hc(i)) set(Hc(i),'pos',In1(i-1,:)); end; end;
    case 423,     set(Hc(2),'str',In1);
    case 424,     set(Hc(3),'str',In1);
    case 636,   if length(In1) & ischar(In1) & In1(1)==';'
                       setappdata(ax,'moveCBext',1);  In1(1) = [];
                    end;
                    set(Hc(7),'user',In1);
    case 686,  setappdata(Hc(7),'CB2',In1);
    case {563,443,442},
      oldEh = get(hiy,'user');
      expHis = oldEh;
      if length(expHis)
          curExp = find(expHis(:,5)==1);
          if length(curExp) expHis(curExp,5)=0; end;
      end;
      switch sact
        case 563, xyl = In1;  expHis(1,:) = [xyl 1];
        case 443
           if length(oldEh)  expHis(1,:) = [xylim(1:2) In1,1];  xyl = [xylim(1:2) In1];
           else              expHis=[];                         xyl = [xylim(1:2) In1];
           end;
        case 442
           if length(oldEh)  expHis(1,:) = [In1 xylim(3:4) 1]; xyl = [In1 xylim(3:4)];
           else              expHis=[];                        xyl = [In1 xylim(3:4)];
           end
      end;
      xyll = sort(xyl(1:2));  if diff(xyll) set(ax,'xlim',xyll); end;
      xyll = sort(xyl(3:4));  if diff(xyll) set(ax,'ylim',xyll); end;
      set(hiy,'user',expHis);
      if length(ax2)
         if Narg2==6 xy = In3; else  xy = get(ax2,'ylim'); end;
         set(ax2,'xlim',xyl(1:2),'ylim',xy);
         set(hix,'user',misc);
      end;
      plt('grid',ax);
      if Action(end-2)=='l' evalQ(get(Hc(5),'user')); end;
    case 540,
      setappdata(gcf,'peak',-inf); setappdata(gcf,'vall',inf);
    case 993,
      if length(In1(1,:)) < 5
         plt('cursor',CurID,'xyLim',In2);
      elseif isequal(size(In1),[5 5])
        expHis = [];
        for i=1:5
          if i<=4
            if In1(i,5) >= 0
              expHis=[expHis; In1(i,:)];
              if In1(i,5) == 1
                 xylim = In1(i,1:4);
                 set(ax,'xlim',In1(i,1:2),'ylim',In1(i,3:4));
                 plt('grid',ax);
              end;
            end
          else
            if In1(i,5)==2 set(ax2,'xlim',In1(i,1:2),'ylim',In1(i,3:4)); end;
          end;
        end;
        set(hiy,'user',expHis);
      else disp('error in plt(cursor,CurId,set,exRestore,xxx), xxx is wrong shape');
      end;
    case 968
      if In1
        misc(4) = In1;
        set(hix,'user',misc);
      end;
      if isempty(In2) In2 = -1; end;
      plt('cursor',CurID,'update',In2);
    case 519
      hcl = Hc([2:13 15+1:end]);
      delete(hcl(find(ishandle(hcl))));
      CurMain(CurID) = 0;
      if ~sum(CurMain) CurMain = []; end;
      setappdata(0,'CurMain',CurMain);
    case 957
      ofs = strcmp(In1,'y');
      switch sum(get(gcf,'SelectionT'))
      case 649,
         if misc(7+ofs)
            plt('cursor',CurID,'scale','new');  misc(7)=0;  misc(8)=0;  set(hix,'user',misc);
         else
            fmty = get(Hc(3),'user');  fmtx = fmty(1,:);  fmty = fmty(2,:);
            c = {'backg' 'foreg'};  clr = get(hix,c);
            set(Hc(4), 'str',Pftoa(fmtx,xylim(1)),'ena','on');
            set(Hc(5),'str',Pftoa(fmtx,xylim(2)),'ena','on',c,clr,'vis','on');
            set(Hc(6), 'str',Pftoa(fmty,xylim(3)),'ena','on');
            set(Hc(7),'str',Pftoa(fmty,xylim(4)),'ena','on',c,clr,'vis','on');
            misc(7+ofs)=1;
            if ~misc(7) | ~misc(8)
               set(Hc(12),'x',xylim([1 2 2 1 1]),'y',xylim([3 3 4 4 3]),'vis','on');
               plt('cursor',CurID,'ZoomOut',0.2);
            end;
            set(hix,'user',misc);
         end;
      case 321, plt('cursor',CurID,'scale','auto',In1);
      end;
    case 797
      if Narg<4  d = [-.2 .2]; e = [.5 2];
      else       d = varargin{4}/2; e = 10^d;  d = [-d d];  e = [1/e e];
      end;
      xl = xylim(1:2);   yl = xylim(3:4);   dr = 'o';
      clk = sum(get(gcf,'SelectionT'));
      if clk==321 | (clk==434 & getappdata(ax,'dir')=='i')
        d = d(2); d = d/(1+2*d); d = [d -d]; e = 1./e; dr = 'i';
      end;
      xs = get(ax,'Xscale');  ys = get(ax,'Yscale');
      if xs(2)=='i' xl = xl + diff(xl)*d;
      else          xl = e.*xl;  if diff(xl)<=0 xl = xl./e; end;
      end;
      if ys(2)=='i' yl = yl + diff(yl)*d;
      else          yl = e.*yl;  if diff(yl)<=0 yl = yl./e; end;
      end;
      set(ax,'xlim',xl,'ylim',yl);
      if ishandle(ax2)
        set(ax2,'xlim',xl);
        axl = get(get(ax2,'ylab'),'str');
        if axl(1)~=92 | axl(2) ~= 'd';
          yl = get(ax2,'ylim');
          if ys(2)=='i' yl = yl + diff(yl)*d;
          else          yl = e.*yl;  if diff(yl)<=0 yl = yl./e; end;
          end;
          set(ax2,'ylim',yl);
        end;
      end;
      plt('grid',ax);
      setappdata(ax,'dir',dr);
      axes(ax); evalQ(get(Hc(5),'user'));
      xView = getappdata(ax,'xView');
      if length(xView) set(xView{1},'x',get(findobj(gcf,'tag','click'),'xlim')); end;
    case 427
      if sum(get(gcf,'SelectionT'))==321 plt('xright','mark','0',CurID); return; end;
      axes(ax);  x = get(hact,'x'); y = get(hact,'y');  p = get(hact,'par');
      if p ~= ax
        rlim = xyli(3:4);
        ylim = xylim(3:4);
        y = ylim(1) + diff(ylim) * (y - rlim(1)) / diff(rlim);
      end;
      l = line(x,y,'marker','s');
      t = text(x,y,['   (' get(hix,'str') ', ' get(hiy,'str') ')'],'units','data',...
               'fontsi',get(p,'fontsi'),'user',l,'buttond','plt misc marker;');
      set([t l],'color',get(hact,'color'),'tag','mark');
      if p ~= ax set(l,'tag','markR','user',{t ax p ylim rlim}); end;
    case 770
      if sum(get(gcf,'SelectionT'))==321 plt('hcpy','init',gcf);
      else
        hl = [findobj(gcf,'str','LinY'); findobj(gcf,'str','LogY')]';
        for j=hl  b = get(j,'buttond');
                  if iscell(b) & length(b)>2 & b{3}==CurID break; end;
        end;
        if strcmp(get(ax,'Yscale'),'log')
             sc='linear'; st='LinY';
        else sc='log';    st='LogY';
             if xylim(3)<=0 set(ax,'ylim',abs(xylim(4))*[.001 1]); end;
             if ishandle(ax2)
               y = get(ax2,'ylim'); if y(1)<=0 set(ax2,'ylim',abs(y(2))*[.001 1]); end;
               end;
        end;
        set([ax ax2],'Yscale',sc);  set(j,'str',st);
      end;
    case 769
      if sum(get(gcf,'SelectionT'))==321
        h = getappdata(ax,'Lhandles');
        x = get(h,'x'); y = get(h,'y');
        if length(h)>1 set(h,{'x'},y,{'y'},x);
        else           set(h,'x',y,'y',x);
        end;
        a = ax;
        for k = 1:2
          if k>1 a=ax2; if ~ishandle(a) continue; end; end;          
          set(a,'xlim',get(a,'ylim'),'ylim',get(a,'xlim'));
          x = get(a,'xlab');  y = get(a,'ylab');
          sx = get(x,'str'); set(x,'str',get(y,'str')); set(y,'str',sx);
        end;
        plt('grid',ax);
      else
        hl = [findobj(gcf,'str','LinX'); findobj(gcf,'str','LogX')]';
        for j=hl  b = get(j,'buttond');
                  if iscell(b) & length(b)>2 & b{3}==CurID break; end;
        end;
        p = get(ax,'pos');  p = p(1);
        if getappdata(gcf,'indep') < 0
          a = getappdata(gcf,'axis');
          axe = [];
          for k = a
            q = get(k,'pos');
            if p == q(1) axe = [axe k]; end;
          end;
        else axe = [ax ax2];
        end;
        if strcmp(get(ax,'Xscale'),'log')
             sc='linear'; st='LinX';
        else sc='log';    st='LogX';
             if xylim(1)<=0 set(axe,'xlim',abs(xylim(2))*[.001 1]); end;
        end;
        set(axe,'Xscale',sc); set(j,'str',st);
        if isempty(ax2) ax2 = 0; end;
        for k = axe if k ~= ax2 plt('grid',k); end; end;
      end;

    otherwise disp([Action ' is not a valid action in plt(cursor)']);
    end;

case 849
  switch s2i(varargin{2})
  case 0,
     p = gcbo;  e = getappdata(p,'edt');
     m = getappdata(e,'m'); obj = m{4}(1);
     c = get(p,'str');   v = get(p,'Val');  prop = deblank(c(v,:));
     f = getappdata(e,'f');  if length(f) close(f); end;
     if strcmp(prop,'Delete') & ishandle(obj) delete(obj); end;
     if ishandle(obj)
       s = get(obj,prop);
       if isnumeric(s)
          if length(s)==3 & max(s)<=1 & min(s)>=0 s = ctriple(s);
          else                                    s = num2str(s);
          end;
       end;
       set(e,'str',s);
     else set(e,'str','Deleted');
     end;
  case 1,
     e = gcbo;  p = getappdata(e,'pop');
     m = getappdata(e,'m'); obj = m{4};
     c = get(p,'str'); v = get(p,'Val');   prop = deblank(c(v,:));
     s = get(e,'str'); f = get(e,'user');
     if sum(get(gcf,'SelectionT'))==321 if strcmp(prop,'Color') plt('ColorPick'); end;
                   return;
     end;
     switch prop
     case 'Delete',
       if strcmpi(s,'all')
         if length(c(:,1))==9 c='line'; else c='text'; end;
         delete(findobj(get(get(e,'par'),'user'),'type',c,'tag','mark'));
       end;
     case 'Color',  plt('ColorPick');
     case {'Xdata','Ydata','Zdata'},
                s = str2num(s);  n = length(s); xy = char('X' + (prop(1)=='X'));
                for k=1:length(obj)
                  if strcmp(get(obj(k),'type'),'line') & length(get(obj(k),xy))==n set(obj(k),prop,s); end;
                end;
     otherwise, if isnumeric(get(obj(1),prop)) s = str2num(s); end;
                if size(get(p,'str'),1)<11 obj = findobj(obj,'type','line'); end;
                set(obj,prop,s);
     end;
   case 2,
     p = gcbo;  e = getappdata(p,'edt');  v = get(p,'Val');  f = get(e,'user');
     h = get(p,'user');  h = h{v};  h1 = h(1);
     pr = {'color' 'color' {'xcol' 'ycol'} 'ycol' 'color' 'color' 'color' 'linest'};
     pr = pr{v};
     if iscell(pr) s = get(h1,pr{1}); else s = get(h1,pr); end;
     if ischar(s) s = [s getappdata(h1,'er')];
     else         s = ctriple(s);
     end;
     set(e,'str',s);
     f = getappdata(e,'f');  if length(f) close(f); end;
     s = get(p,'str');
     setappdata(e,'m',{'str',e,pr,h,deblank(s(v,:))});
  case 3,
     s = get(gcbo,'str');
     v = get(getappdata(gcbo,'pop'),'Val');
     if v==8
       er = s(end);
       if length(s)>1
         if er=='n' s(end)=[]; elseif er=='x'; s(end)=[]; else er='x'; end;
       end;
       gr = findobj(get(gcf,'user'),'user','grid'); gr = gr(1);
       setappdata(gr,'er',er);  set(gr,'linest',s);
     else plt ColorPick;
     end;
  end;

case 428,
  in2 = varargin{2};
  if isnumeric(in2)
    switch in2
      case 1, Ret1 = get(findobj(gcf,'tag','xstr'),'user');
      case 2, Ret1 = get(findobj(gcf,'tag','ystr'),'user');
      case 3, Ret1 = getappdata(gcf,'OBJ');
      case 4, Ret1 = getappdata(gcf,'OBJ2');
      case 5, Ret1 = getappdata(gcf,'OBJ');
              a = getappdata(gcf,'Lhandles'); Ret1 = find(a==Ret1);
    end;
    return;
  end;
  switch sum(in2)
    case 675
      if length(findobj(gcf,'tag','DeltaC','vis','on'))
        delete([findobj(gcf,'tag','mark'); findobj(gcf,'tag','markR')]);
        h = findobj(gcf,'str','D');  c = get(h(end),'callb');
        feval(c{1},c{2:end});
      else h = findobj(gcf,'str','O'); h = h(end);
           u = 1-get(h,'user');  set(h,'user',u);
           set(getappdata(gcf,'Lhandles'),'LineSmooth',char('of'+[0 8*u]));
      end;
    case 636
      if length(findobj(gcf,'tag','DeltaC','vis','on'))
         h = findobj(gcf,'str','D');  c = get(h(end),'callb');
         feval(c{1},c{2:end}); plt move res;
      else plt move;
      end;
    case 435
      cid = varargin{3};
      hc = plt('cursor',cid,'obj');
      c = get(hc(13),'color');
      for h = hc(3:2:5)
        s = get(h,'str');
        hh = findobj(gcf,'pos',get(h,'pos'));
        set(hh,'str',s,'backg',c);
        setappdata(hh(1),'indep',cid);
      end;
    case 548,
      fs = get(gcf,'pos');  fs = fs(3:4);
      aPt = get(gcf,'currentp');
      switch Narg
      case 2
        t = gcbo;  ax = getappdata(gcf,'axis');   m = 1;
        if strcmp(get(t,'user'),'grid') t=ax(1); end;
        if     any(t == findobj(gcf,'user','TraceID')) k=-1;
        elseif any(t == findobj(gcf,'tag', 'MenuBox')) k=-2;
        else
          if Mver<7 k=find(~(ax-t)); else k=find(ax==t); end;
          if isempty(k)
             ty = {' xy' 'uic' 'pop' 'axi'};
             id = [  0    200   100   50  ];
             for m=2:4
               tw = ty{m}; k = getappdata(gcf,tw);
               if Mver<7 k=find(~(k-t)); else k=find(k==t); end;
               k = k + id(m);
               if length(k) break; end;
             end;
          end;
        end;
        feval('assignin','base','hhh',t);
        if sum(get(gcf,'SelectionT'))==434 feval('inspect',t); return; end;
        if m==3 ev=getappdata(t,'CBsv'); feval(ev{:});
                t = get(t,'par');
        elseif strcmp(get(t,'tag'),'E') t=get(t,'user');
        end;
        p = get(t,'pos');   r = get(t,'type');
        if r(3)=='p' | (r(3)=='c' & strcmp(get(t,'style'),'frame')) ...
                     | (r(1)=='a' & strcmp(get(t,'tag'),  'frame'))
           ch = {};
           r = p(1:2);  r = [r -r-p(3:4)];
           m = getappdata(gcf,'sli');  w = getappdata(gcf,'pop');  np = length(w);
           m = [w getappdata(gcf,'axi') getappdata(gcf,'uic') m(1:5:end)];
           for j=1:length(m)
             if j<= np q = getappdata(m(j),'ppos'); w = get(get(m(j),'par'),'pos');
             else      q = get(m(j),'pos');           w = q;
             end;
             s = q(1:2);  s = [s -s-q(3:4)];
             if all(s>r) ch = [ch {{m(j) w}}]; end;
           end;
           setappdata(t,'inside',ch);
        end;
        u = get(t,'units');  if u(1)=='n' aPt = aPt ./ fs; end;
        setappdata(gcf,'Dxy',{p aPt t k m});
        set(gcf,'WindowButtonMotionFcn','plt misc tidmv 0;',...
                'WindowButtonUpFcn',    'plt misc tidmv 0 0;');
      case 3
        s = getappdata(gcf,'Dxy'); t = s{3};
        u = get(t,'units');  u = u(1)=='n';
        if u  aPt = aPt ./ fs; end;
        r = getappdata(gcf,'snap');  r = r + 1e4*(r==0);
        if ~u  r = r ./ fs; end;
        rr = [r r];  r = [0 0 1./r];
        aPt = aPt-s{2}; s = s{1};
        if sum(get(gcf,'SelectionT'))==649
          aPt = [aPt 0 0];
          ch = getappdata(t,'inside');  cn = length(ch);
          for k = 1:cn
            h = ch{k}{1}; p = max(r,round((ch{k}{2}+aPt).*rr) ./ rr);
            ty = getappdata(h,'ty');
            switch ty(1)
              case 's', plt('slider',h,'set','pos',p);
              case 'p', plt('pop',h,'pos',p);
              otherwise set(h,'pos',p);
            end;
          end;
        else
          aPt = [0 0 aPt];
        end;
        s = s + aPt;
        s = max(r,round(s.*rr) ./ rr);
        tn = getappdata(t,'ty');
        if tn(1)=='e' plt('edit',t,'pos',s); else set(t,'pos',s); end;
      case 4
        set(gcf,'WindowButtonMotionFcn','','WindowButtonUpFcn','');
        s = getappdata(gcf,'Dxy');  t = s{3};  u = get(t,'units');
        p = get(t,'pos');  ty = getappdata(t,'ty');
        r = get(t,'type');
        if ty(1)=='p'    h = get(t,'user'); r = get(h,'str');
                         plt('pop',h,'index',plt('pop',h));
        elseif r(3)=='c' r = get(t,'str');
                         if iscell(r) r = r{1}; end;
        end;
        if u(1)=='n' a = strrep(prin('{ %0.3f}',p),'0.','.');
        else         a = prin('{ %4d}',round(p));
        end;
        prin(1,'%s: %3d %s;  %% %s\n',ty,s{4},a,r);
      end;
    case 579,
      switch Narg
      case 2
        t = gcbo;  ax = get(t,'par');  aPt = get(ax,'currentp');  aPt = aPt(1,1:2);
        tu = get(t,'units');
        set(t,'units','data');
        k = getappdata(gcf,'txt');  k = find(k==t);
        k = k+300;
        setappdata(gcf,'Dxy',{get(t,'pos') aPt t k tu});
        feval('assignin','base','hhh',t);
        if sum(get(gcf,'SelectionT'))==434 feval('inspect',t); return; end;
        set(gcf,'WindowButtonMotionFcn','plt misc txtmv 0;',...
                'WindowButtonUpFcn',    'plt misc txtmv 0 0;');
      case 3
        s = getappdata(gcf,'Dxy');
        t = s{3};  tp = s{1};  ax = get(t,'par');  aPt = get(ax,'currentp');

        set(t,'pos',tp(1:2)+aPt(1,1:2)-s{2});
      case 4
        set(gcf,'WindowButtonMotionFcn','','WindowButtonUpFcn','');
        s = getappdata(gcf,'Dxy'); t = s{3};
        set(t,'units',s{5}); p = get(t,'pos');
        ty = getappdata(t,'ty');     r = get(t,'str');  if iscell(r) r=r{1}; end;
        prin(1,'%s: %3d    %6V  %6V   ;  %% %s\n',ty,s{4},p(1:2),r);
        if ty(1)=='e' plt('edit',t,'pos',p); end;
      end;
    case 555,
      fs = get(gcf,'pos');  fs = fs(3:4);
      aPt = get(gcf,'currentp');
      switch Narg
      case 2
        w = getappdata(gcf,'sli');
        t = gcbo;
        k = 1 + 5*floor((find(w==t)+399)/5);
        if isempty(k) disp('slimv error'); return; end;
        t = w(k-400);
        feval('assignin','base','hhh',t);
        if sum(get(gcf,'SelectionT'))==434 feval('inspect',gcbo); return; end;
        u = get(t,'units');  if u(1)=='n' aPt = aPt ./ fs; end;
        setappdata(gcf,'Dxy',{get(t,'pos') aPt t k});
        set(gcf,'WindowButtonMotionFcn','plt misc slimv 0;',...
                'WindowButtonUpFcn',    'plt misc slimv 0 0;');
      case 3
        s = getappdata(gcf,'Dxy');  t = s{3};
        u = get(t,'units');  u = u(1)=='n';
        if u  aPt = aPt ./ fs; end;
        aPt = aPt-s{2}; s = s{1}(1:3);
        if sum(get(gcf,'SelectionT'))==649 s = s + [aPt 0];
        else                  s = max([0 0 .01],s+[0 0 aPt(1)]);
        end;
        r = getappdata(gcf,'snap');  r = r + 1e4*(r==0);
        if ~u q = get(gcf,'pos');  r = r ./ q(3:4); end;
        rr = [r r(1)];  r = [0 0 1/r(1)];
        s = max(r,round(s.*rr) ./ rr);
        plt('slider',t,'set','pos',s);
      case 4
        set(gcf,'WindowButtonMotionFcn','','WindowButtonUpFcn','');
        s = getappdata(gcf,'Dxy');  t = s{3};  u = get(t,'units');
        p = get(t,'pos');  r = get(t,'str');
        if u(1)=='n' disp(strrep(prin('sli: %3d { %0.3f}     ;  %% %s',s{4},p(1:3),r),'0.','.'));
        else         disp(prin('sli: %3d { %4d}     ;  %% %s',s{4},round(p(1:3)),r));
        end;
      end;
    case 642
      t = gco;
      aPt  = get(get(t,'par'),'currentp');
      if Narg==2
        switch sum(get(gcf,'SelectionT'))
        case 649
          setappdata(t,'Dxy',get(t,'pos')-aPt(1,:));
          set(gcf,'WindowButtonMotionFcn','plt misc marker 0;','WindowButtonUpFcn','set(gcf,''WindowButtonMotionFcn'','''',''WindowButtonUpFcn'','''');');
        case 321
          callp = 'plt MarkEdit 0;';
          calle = 'plt MarkEdit 1;';
          figure('menu','none','numberT','off','back','off','resize','off','pos',auxLoc(302,85),'color',[0,.4,.4],'name','Edit Marker','tag',get(gcf,'tag'),...
                         'closereq','plt click mark 4;');
          ed1 = uicontrol('sty','edit','pos',[8 5 130 22],'fontw','bol','call',calle,'buttond',calle);
          pu1 = 'Delete|Color|LineStyle|LineWidth|Marker|MarkerSize|Xdata|Ydata|Zdata';
          pu1 = uicontrol('sty','pop','str',pu1,'pos',[8 35 130 20],'call',callp,'Val',5);
          uicontrol('sty','text','str', 'Marker properties:','pos',[8 64 130 17]);
          ed2 = uicontrol('sty','edit','pos',[145 5 150 22],'fontw','bol','call',calle,'buttond',calle);
          pu2 = uicontrol('sty','pop','str','Delete|Color|FontAngle|FontName|FontSize|FontWeight|HorizontalAlign|Position|Rotation|String|VerticalAlign',...
                      'pos',[145 35 150 20],'call',callp,'Val',10);
          uicontrol('sty','text','str', 'String properties:','pos',[145 64 150 17]);
          set([ed1 ed2 pu1 pu2],'backg',[.8,.8,.9],'foreg','black');
          l = get(t,'user');
          setappdata(ed1,'pop',pu1); setappdata(pu1,'edt',ed1); setappdata(pu1,'obj',l);
          setappdata(ed2,'pop',pu2); setappdata(pu2,'edt',ed2); setappdata(pu2,'obj',t);
          setappdata(ed1,'m',{'str',ed1,'color',l,'Marker color'});
          setappdata(ed2,'m',{'str',ed2,'color',t,'String color'});
          if ishandle(l) l=get(l,'marker'); else l='Deleted'; end;
          if ishandle(t) t=get(t,'str');      else t='Deleted'; end;
          set(ed1,'str',l);  set(ed2,'str',t);
        end;
      else  dxy = aPt(1,:) + getappdata(t,'Dxy'); set(t,'pos',dxy(1:2));
      end;
    case 660,   aid = findobj(gcf,'user','TraceID');
                    if length(aid)
                       uistack(aid,'top');
                    end;
    case 534,
      a = getappdata(gcf,'ucreq');
      if length(a) evalQ(a); end;
      for cid=getappdata(gcf,'cid')
         plt('cursor',cid,'clear');
      end; 
      for fk = findobj('type','fig','tag',get(gcf,'tag'))';
        if fk ~= gcf
          a = getappdata(fk,'ucreq');
          if length(a) evalQ(a); end;
          for cid=getappdata(fk,'cid')
            plt('cursor',cid,'clear');
          end; 
          delete(fk);
        end;
      end;
      closereq;
  end;

case 966
  m = getappdata(gcbo,'m');
  if isempty(m) m = getappdata(get(gcbo,'par'),'m'); end;
  if iscell(m) hq=m; m=gcbo;
  elseif ishandle(m) hq = getappdata(m,'m');
  end;
  if Narg>1 ccf = varargin{2}; else ccf = ''; end;
  if strcmp(ccf,'C')
    for k=2:2:length(hq)
      h = hq{k};
      for j = 1:length(h) setappdata(h(j),'f',[]); end;
    end;
    setappdata(m,'f',[]);
    closereq;
    return;
  end;
  t = 0; cb = '';  f = getappdata(m,'f');
  if isempty(f)
    hb = [];  for k=2:2:length(hq) hb = [hb hq{k}]; end;
    if length(find(m==hb))
          b=m;
    else  b=hb(1); hb=[hb m];
    end;
    ed = 0;
    switch get(b,'type')
      case 'uicontrol', c = get(b,'backg');  t = get(b,'str');  ed = strcmp(get(b,'sty'),'edit');
      case 'text',      c = get(b,'color');  t = get(b,'str');
      case 'patch',     c = get(b,'facecolor');
      otherwise,        c = get(b,'color');
    end;
    if ed             c = [str2num(t) 0 0 0];   c = min(max(c(1:3),0),1);
    elseif ischar(t)  t = str2num(t);  if length(t)==3 & min(t)>=0 & max(t)<=1 c=t; ed=1; end;
    end;
    if Narg<3 & ed & sum(get(gcf,'SelectionT'))==649 & b==m
      t = ctriple(c);
      for k=2:2:length(hq)
        p = hq{k-1};  h = hq{k};
        if ~iscell(p) p = {p}; end;
        for j=1:length(p)
          q = p{j}; if strcmp(q(1:3),'str') set(h,q,t); else set(h,q,c); end;
        end;
      end;
      if length(ccf)>1 eval(ccf); end;
      return;
    end;
    f = figure('menu','none','numberT','off','back','off','pos',auxLoc(302,205,3),'color',[0,.4,.4],'name','Color Pick',...
               'tag',get(gcf,'tag'),'double','off','closereq','plt ColorPick C;');
    setappdata(f,'ccf',ccf);
    cb = 'plt ColorPick;';  s1 = [0 100 0 100];  d = round(c*100);
    p1 = [.02 .20 110];  p2 = [0 .29 0];
    s = [plt('slider',p1+2*p2,[d(1) s1],'Red (%)'  ,cb,2) ...
         plt('slider',p1+p2,  [d(2) s1],'Green (%)',cb,2) ...
         plt('slider',p1,     [d(3) s1],'Blue (%)' ,cb,2)];
    obj = plt('slider',s(1),'get','obj');  set(obj(5),'backg',[1 1 0]);
    ax = axes('xlim',[.8 12.15],'ylim',[.8 15.4],'color',[0 0 0],'xcol',[0,.4,.4],'ycol',[0,.4,.4],'XtickLabel',' ','YtickLabel',' ','TickLen',[0 0]',...
              'unit','nor','pos',[.408 .02 .57 .96]);
    if ischar(hq{end})
      text(-3.4,14.7,hq{end},'horiz','center','color',[1 .7 .8]);
    end;
    setappdata(f,'m',m);  setappdata(ax,'m',m);
    ph = zeros(11,11);
    for row = 1:11
      for col = 1:11
        ph(row,col) = patch(col+[0 1 1 0],row+[0 0 1 1],[0 0 0],'buttond',cb);
      end;
    end;
    c = d/100;
    pat = patch([1 12 12 1],12+[.5 .5 3 3],c,'buttond',cb);  setappdata(pat,'m',m);
    setappdata(f,'h',{c s pat ph ax});
    for k=1:length(hb) setappdata(hb(k),'f',f); setappdata(hb(k),'m',hq); end;
  end;
  h = getappdata(f,'h');
  p = get(gcbo,'par');
  s = h{2};
  if length(cb) k=1;
  else
    if strcmp(get(gcbo,'type'),'patch') & isempty(cb)
      if gcbo==h{3} c = h{1}; else c = get(gcbo,'facecolor'); end;
      for k=1:3
        obj = plt('slider',s(k),'get','obj');
        bk = get(obj(5),'backg');
        if bk(1) break; end;
      end;
    else
      y = strcmp(get(gcbo,'sty'),'edit');
      if y & isequal(get(gcbo,'user'),[0 100]) y=0; end;
      if y  c = [str2num(get(gcbo,'str')) 0 0 0];  c = min(max(c(1:3),0),1);
      else  c = get(h{3},'facecolor');
      end;
      d = round(100*c);
      k = 0;
      for j=1:3
        z = plt('slider',s(j));   obj = plt('slider',s(j),'get','obj');
        if z~=d(j) & ~k bk = [1 1 0];  k = j;  if ~y d(k)=z; end;
        else            bk = [0 1 1];
        end;
        set(obj(5),'backg',bk);
      end;
      if ~k set(obj(5),'backg',[1 1 0]); return; end;
      c = d/100;
    end;
  end;
  set(h{3},'facecolor',c);
  d = round(c*100);
  for j=1:3  plt('slider',s(j),'set','val',d(j)); end;
  ph = h{4};  phc = [0 0 0];  phc(k) = d(k)/10;  v = mod(k,3)+1;  w = mod(v,3)+1;
  for row = 0:10
    phc(v) = row;
    for col = 0:10
      phc(w) = col;  set(ph(row+1,col+1),'FaceColor',phc/10);
    end;
  end;
  t = ctriple(c);
  for k=2:2:length(hq)
    p = hq{k-1};  h = hq{k};
    if ~iscell(p) p = {p}; end;
    for j=1:length(p)
      q = p{j}; if strcmp(q(1:3),'str') set(h,q,t); else set(h,q,c); end;
    end;
  end;
  ccf = getappdata(f,'ccf');
  if length(ccf)>1 eval(ccf); end;

case 434
  if Narg<2 [fi pth] = uigetfile('plt.plt','Select plt figure to open');
            if isnumeric(fi) return; end;
            fi = [pth fi];
  else      fi = varargin{2};
  end;
  ydat = [];
  feval('load',fi,'-mat');
  if isempty(ydat)
    p = find(fi=='.');
    if length(p) f = [fi(1:p(end)) 'mat']; end;
    dos(['copy ' fi ' ' f ' > NUL:']);
    load(f); delete(f);
  end;
  xdat = [xdat'; ydat'];
  plt(xdat{:},params{:});

case 431
  if Narg<2 [fi pth] = uiputfile('plt.plt','Save plt figure as');
            if isnumeric(fi) return; end;
            fi = [pth fi];
  else      fi = varargin{2};
  end;
  AX    = findobj(gcf,'tag','click');
  CurID = get(AX,'user');
  AX2   = findobj(gcf,'YAxisLoc','right','user',CurID);
    lh = getappdata(gcf,'Lhandles');
    xdat = get(lh,'x');  ydat = get(lh,'y');
    xlm =  get(AX,'xlim');   ylm =  get(AX,'ylim');
    xymult = getappdata(gcf,'xymult');
    if xymult(1) ~= 1
       mult = 1/xymult(1);
       for k = 1:length(xdat) xdat{k} = mult * xdat{k}; end;
       xlm = xlm * mult;
    end;
    ym = 1;
    for k = 1:length(ydat)
      mult = xymult(k+1);
      if mult ~= 1  
         mult = 1/mult;
         if ym ylm=ylm*mult; ym=0;  end;
         ydat{k} = mult * ydat{k};
      end;
    end;
    v = get(lh,'vis');  v = [v{:}];  
    params = [getappdata(gcf,'params') { ...
             'pos'        get(gcf,'pos') ...
             'DIStrace' v(find(v=='o')+1)=='f' ...
             'xlim'       xlm ...
             'ylim'       ylm     }];
    if length(AX2) params = [params {'YlimR' get(AX2,'ylim')}]; end;
    ver = '01Jan17';
    save(fi,'xdat','ydat','params','ver');

case 518
  y2    = varargin{2};
  AX    = findobj(gcf,'tag','click');
  if MverE  ERAS = 'eras';  ERAXOR = 'xor';  ERANOR = 'norm';
  else      ERAS = 'pi';    ERAXOR = 'v';    ERANOR = 'v';
  end;

  if length(AX)>1
    if ~ischar(y2)
         AX = get(y2(1),'par');
         yal = get(AX,'YAxisLoc');
         if yal(1)=='r' AX = findobj(gcf,'YAxisLoc','left','user',get(AX,'user')); end;
    end;
  end;
  CurMain = getappdata(0,'CurMain');  CurID = 0;
  if length(AX)==1
    CurID = get(AX,'user');
    AX2   = findobj(gcf,'YAxisLoc','right','user',CurID);
    AXrl  = [AX AX2];
    if isempty(AX2) AX2 = -1; end;
    Hc = get(CurMain(CurID),'user');
  end;
  if ischar(y2)
    switch sum(y2)

    case 430
      h = get(AX2,'ylab');  s = get(h,'str');
      if s(1)==92 & s(2)=='d'  s = s(6:end-5);
      else                             s = ['\div ' s ' \div'];
      end;
      set(h,'str',s);

    case 427
      if Narg>2 in3 = s2i(varargin{3}); else in3 = -1; end;
      switch in3
        case 3,
          cFIGbk = get(gcf,'color');
          cPLTbk = get(AX,'color');
          if isstr(cPLTbk) cPLTbk = get(AX2,'color'); end;
          cXYax  = get(AX,'xcol');
          cXYlbl = get(get(AX,'xlab'),'color');
          cDELTA = findobj(gcf,'tag','DeltaC'); cDELTA = get(cDELTA(1),'color');
          cTRACE = get(getappdata(gcf,'Lhandles'),'color');
          cTRACE = reshape([cTRACE{:}],3,length(cTRACE))';
          cFile = findobj(gcf,'style','push','str','D');  cFile  = get(cFile(end),'tag');
          gr = findobj(gcf,'user','grid');  gr = gr(1);        cGRID  = getappdata(gr,'clr');
          GridSty = get(gr,'linest');                  GridEr = get(gr,ERAS);
          if isempty(cFile) [cFile pth] = uiputfile('*.mat','Select file for saving colors');
                            cFile = [pth cFile];
          end;
          if sum(cFile)
             save(cFile,'cFIGbk','cPLTbk','cXYax','cXYlbl','cDELTA','cTRACE');
             msgbox(['This program will now use colors saved in file ' cFile],'modal');
          else disp('No file was selected'); end;
          return;
        case 4,
          close(findobj('name','Color Pick')); 
          g = s2i(get(gcf,'tag'));  g = findobj('type','fig','Number',g);
          gr = findobj(g,'user','grid');
          if length(gr)
            gr = gr(1);
            er = getappdata(gr,'er'); if isempty(er) closereq; return; end;
            setappdata(gr,'er',[]);
            if er=='n' er=ERANOR; else er=ERAXOR; end;
            c = get(gr,'color');
            setappdata(gr,'clr',c);
            ax = getappdata(g,'axis');  axr=ax(end);  r = get(axr,'YAxisLoc');
            if r(1)=='r'
              vis = get(axr,'vis');
             if vis(2)=='n' gx = get(g,'color'); else gx = get(axr,'color'); end;
              c = bitxor(round(255*c),round(255*gx))/255;
            end;
            set(gr,'color',c,ERAS,er);
          end;
          closereq;
          return;
      end;
      g = gcf;
      mb = findobj(g,'tag','MenuBox')';
      callc = 'plt MarkEdit 3;';
      if in3==2
        figure('menu','none','numberT','off','back','off','resize','off','pos',auxLoc(302,60),'color',[0,.4,.4],'name','Edit figure colors','tag',get(gcf,'tag'),...
                      'closereq','plt click mark 4;');
        ps = 'Figure background|Plot background|Axis color|Axis color (right)|Axis labels|Delta cursor|Grid color|Grid style';
        pu = uicontrol('sty','pop','str',ps,'pos',[80 35 140 20],'call','plt MarkEdit 2;');
        ed = uicontrol('sty','edit','pos', [80  5 140 22],'fontw','bol','call',callc,'buttond',callc);
        gr = findobj(g,'user','grid');  gr = gr(1);
        er = get(gr,ERAS);  setappdata(gr,'er',er(1));
        set(gr,ERAS,ERANOR);
        set(gr,'color',getappdata(gr,'clr'));
        set([ed pu],'backg',[.8,.8,.9],'foreg','black');
        setappdata(ed,'m',{'str',ed,'color',[g mb],'Figure background'});
        setappdata(ed,'pop',pu); setappdata(pu,'edt',ed); setappdata(pu,'obj',[]);
        set(ed,'str',ctriple(get(g,'color')));
        ax = getappdata(g,'axis');  a = ax(1);  ar = ax(end);
        if isstr(get(a,'color')) ap=ar; else ap=a; end;
        lb = [get(a,'xlab') get(a,'ylab') get(mb,'child')'];
        dc = findobj(g,'tag','DeltaC');
        set(pu,'user',{[g mb];
                     ap;
                     a;
                     ar;
                     lb;
                     dc(1)
                     gr
                     gr
                    });
        return;
      end;
      sb = 0;
      if Narg>3
        CurID = varargin{4};
        [lm lh] = plt('cursor',CurID,'getActive');
        if length(AX)>1
          AX  = get(lh,'par');
          Hc = get(CurMain(CurID),'user');
        else
          lhs = getappdata(gcf,'Lhandles');
          ln = find(lhs == lh);
          nl = length(getappdata(AX,'Lhandles'));
          if ln > nl
            Hc = get(CurMain(CurID),'user');
            sb = ln-1;
          end;
        end;
      end;
      if length(AX)>1 AX=AX(1); CurID = get(AX,'user'); Hc = get(CurMain(CurID),'user'); end;
      hix = Hc(4);
      misc = get(hix,'user');
      actv = misc(4);
      iact = 15 + actv;
      hact = Hc(iact);
      if sum(get(gcf,'SelectionT'))==321 | Narg>2
        tx = [];  hb = [];  tid = [];
        if sb h=[]; else h = findobj(gcf,'user','TraceID')'; end;
        if length(h)>1 for j=h if CurID == getappdata(j,'cid') h=j; break; end; end; end; 
        if length(h) h = flipud(get(h,'child'));
                     tx = findobj(h,'type','text');  tid = tx(actv);
                     h = findobj(h,'type','line');
                     bt = get(h,'button');
                     if iscell(bt)
                       hb = h(find(cellfun('length',bt)));
                       if length(hb)>=actv tid = [tid hb(actv)]; end;
                     end;
        end;
        c = hact;
        h = get(c,'user'); h = h{1};
        if in3>0 alll = in3;
        else  alll = get(Hc(13),'vis');
              if alll(2)=='n'
                 h = findobj(gcf,'str','D');  h = get(h(end),'callb');
                 evalQ(h); plt click mark 1;
                 return;
              end;
              alll = 0;
        end;
        if alll
          c = [];  h = [];  a = [];
          for i=15+1:length(Hc)
            lh = get(Hc(i),'user');
            c = [c Hc(i)];  h = [h lh{1}];
          end;
          tid = [tx; hb]';
          fname = 'Edit all lines';
        else
          if length(tid) tx=tid(1); a=[];
          else a=get(h,'par'); tx=get(a,'ylab'); tid=tx;
          end;
          fname = sprintf('Edit Line %d (%s)',actv+sb,deblank(get(tx,'str')));
        end;
        callp = 'plt MarkEdit 0;';
        calle = 'plt MarkEdit 1;';
        figure('menu','none','numberT','off','back','off','resize','off','pos',auxLoc(302,85),'color',[0,.4,.4],'name',fname,'tag',get(gcf,'tag'),...
               'closereq','plt click mark 4;');
        props = 'Color|LineStyle|LineWidth|Marker|MarkerSize|Xdata|Ydata|Zdata';
        ed1 = uicontrol('sty','edit','pos',[8 5 130 22],'fontw','bol','call',calle,'buttond',calle);
        pu1 = uicontrol('sty','pop','str',props,'pos',[8 35 130 20],'call',callp);
        uicontrol('sty','text','str', 'Line properties:','pos',[8 64 130 17]);
        ed2 = uicontrol('sty','edit','pos',[145 5 150 22],'fontw','bol','call',calle,'buttond',calle);
        pu2 = uicontrol('sty','pop','str',props,'pos',[145 35 150 20],'call',callp,'Val',5);
        uicontrol('sty','text','str', 'Cursor properties:','pos',[145 64 150 17]);
        set([ed1 ed2 pu1 pu2],'backg',[.8,.8,.9],'foreg','black');
        setappdata(ed1,'pop',pu1); setappdata(pu1,'edt',ed1); setappdata(pu1,'obj',h);
        setappdata(ed2,'pop',pu2); setappdata(pu2,'edt',ed2); setappdata(pu2,'obj',c);
        setappdata(ed1,'m',{'str',ed1,'color',[h tid],'ycolor',a,'Line color'});
        setappdata(ed2,'m',{'str',ed2,'color',c,'Cursor color'});
        set(ed1,'str',ctriple(get(h(1),'color')));
        set(ed2,'str',get(c(1),'MarkerSize'));
        r = get(AX,'YAxisLoc');
        if r(1)=='r' AX = findobj('type','axes','pos',get(AX,'pos')); AX=AX(1); end;
        axes(AX);
      end;
    case 653
      ax = getappdata(gcf,'axis');  n = length(ax);  axr = []; axl = [];
      for k=ax  r = get(k,'YAxisLoc');
                if r(1)=='r' axr = [axr k]; else axl = [axl k]; end;
      end;
      if sum(get(gcf,'SelectionT'))==321
        r = get(ax(n),'YAxisLoc');
        if length(axr) era=ERAXOR; else era=ERANOR; end;
        for k = axl
          g = findobj(k,'user','grid');
          if isempty(g) | isempty(deblank(get(g,'tag'))) continue; end;
          c = getappdata(g,'clr');  st = get(g,'linest'); 
          inv = c(1) > .5;
          if st(1)=='-'  c = 2*c;  if inv c=c-1; end;  c=max(min(c,1),0); cc=c; er=ERANOR; sty=':';
          else           c = c/2;  if inv c=c+.5; end; c=max(min(c,1),0); cc=c; er=era;    sty='-';
          end;
          if MverE & length(axr)
            p = get(k,'pos');  mainA=0;
            for j=axr if all(get(j,'pos')==p) mainA=1; break; end; end;
            if mainA
              vis = get(j,'vis');
              if vis(2)=='n' gx = get(gcf,'color'); else gx = get(j,'color'); end;
              c = bitxor(round(255*c),round(255*gx))/255;
            end;
          end;
          setappdata(g,'clr',cc);
          set(g,'linest',sty,'color',c,ERAS,er);
        end;
      else
        for k=axl
          g = findobj(k,'user','grid');
          if isempty(g) | isempty(deblank(get(g,'tag'))) continue; end;
          plt('grid',k,'toggle');
        end;            
      end;
    case 668
      if sum(get(gcf,'SelectionT'))==321
        cf = gcf;
        l = getappdata(cf,'Lhandles');
        if isempty(l) disp('No data to display'); return; end;
        tn = get(flipud(findobj(findobj(gcf,'user','TraceID'),'type','text')),'str');
        a = getappdata(gcf,'axis');
        if length(a)>1
           a = get(a,'ylab');
           for k = 2:length(a) a{k} = get(a{k},'str'); end;
           tn = [tn; a(2:end)];
        end;
        t = ' index';
        x = [];
        d = [];
        n = 0;
        nc = 0;
        np = 0;
        for k = 1:length(l)
          if strcmp(get(l(k),'vis'),'off') continue; end;
          xx = get(l(k),'x');  nn = length(xx);  ix = [1 min(nn,2) max(1,nn-1) nn]; xxi = xx(ix);
          if nn~=np | ~isequalNaN(x(ix),xxi(:))
            np = nn;  x = xx;
            sz = size(x);   if sz(1)==1 x = transpose(x); end;
            ex = [];
            if     nn>n  d = [d; NaN+ones(nn-n,nc)];  n = nn;
            elseif nn<n  ex = NaN+ones(n-nn,1);
            end;
            d = [d [x; ex]];  t = [t '     X    '];  nc=nc+1;
          end;
          y = get(l(k),'y');  sz = size(y); if sz(1)==1 y = transpose(y); end;
          d = [d [y; ex]];  nc=nc+1;
          if length(tn)>=k
            s = tn{k};
            if length(s)>=9 s = [' ' s(1:9)];
            else m = 9-length(s);  mf = floor(m/2);
                 s = [blanks(1+m-mf) s blanks(mf)];
            end;
            t = [t s];
          end;
        end;
        s = {}; clr = get(cf,'color');
        w = 70*nc + 80;
        sz = get(0,'screens');  p = get(cf,'pos');
        if p(3)<1 p = p .* sz([1 2 1 2]); end;
        x1 = p(1) + p(3) + 12;  wa = sz(3) - x1;
        if p(1) > wa  x1 = 5;  wa = p(1)-5; end;
        y1 = p(2);  ha = p(4);
        if wa > w
          if x1==5 x1=wa-w-7; end; wa=w;
        else
          Y1 = p(2) + p(4) + 35;  Ha=sz(4)-Y1-80;
          if p(2) > Ha+80  Y1=59; Ha=p(2)-94; end;
          if (Ha>400) | ((Ha>200) & (sz(4)>w))
            ha = Ha; y1 = Y1; x2 = sz(4)-20; wa = min(x2,w);
            x1 = x2-wa;  x1 = x1 - min(x1,x2-p(1)-p(3));
          elseif wa<210 wa = min(w,sz(4)-10); x1=5;
          end;
        end;
        pos = [x1 y1 wa ha];
        foobar = 0;   fnt = 'Courier';
        if exist('foobar')
          fnt = feval('listfonts'); fnt = [fnt{:}];
          if     length(findstr(fnt,'Consolas'))       fnt = 'Lucida Sans Typewriter';
          elseif length(findstr(fnt,'Lucida Console')) fnt = 'Lucida Console';
          end;
        end;
        for k = 1:n  s = [s {[sprintf('%5d  ',k) strrep(prin('%8V  ',d(k,:)),'NaN','   ')]}]; end;
        f = figure('menu','none','numberT','off','back','off','name',get(cf,'name'),'pos',pos,'color',clr,'tag',get(gcf,'tag'));
        bx = uicontrol('style','listbox','pos',[1 1 wa ha-30],...
        'foreg',[1 1 0],'backg',[0 0 0],'user',{s t},'FontName',fnt);
        fs = uicontrol('sty','pop','str',prin('{fontsize: %d!row}',4:18),'Val',6,'pos',[wa-100 ha-19 85 16],...
          'call','set(findobj(gcf,''sty'',''l''),''fontsize'',3+get(gcbo,''value''));');
        sv = uicontrol('str','save','user',bx,'pos',[15 ha-25 50 20],'call',...;
           '[f p]=uiputfile(''pltData.txt''); s=get(get(gcbo,''user''),''user''); t=s{2}; s=s{1}; prin(-[p f],''%s\n'',t,s{:});');
        set([bx fs sv],'unit','nor');
        setappdata(cf,'bx',bx);
        figure(cf);  plt('cursor',CurID,'MVcur');
      else
        f = get(gcf,'menu');
        if   f(1)=='f' delete(findobj(gcf,'type','uimenu')); set(gcf,'menu','none');
        else set(gcf,'menu','fig');
             v = get(0,'ShowHidden');
             set(0,'ShowHidden','on');
             a = findobj(gcf,'label','&File');
             uimenu(a,'Label','p&lt  save','separator','on','call','plt save;');
             uimenu(a,'Label','pl&t  open','call','plt open;');
             c = get(a,'child');
             set(a,'child',c([4:end-3 1:3 end-2:end]));
             a = findobj(gcf,'label','&Help');
             if length(a)
               uimenu(a,'Label','p&lt help','separator','on','call','plt help;');
               c = get(a,'child'); set(a,'child',c([2:end 1]));
               set(c(end),'separator','on');
             end;
             set(0,'ShowHidden',v);
             m = uimenu('label','&plt');
             cb1 = 'a=getappdata(gcf,"axis"); a=a(1); if getappdata(a,"DualCur") b=0; ';
             cb2 = 'set(findobj(gcf,"buttond","plt click EDIT 6 3;"),"vis","of"); ';
             cb3 = 'else b=plt("cursor",get(a,"user"),"getActive",0); end; setappdata(a,"DualCur",b);';
             cb = {'plt click mark 0;' ...
                   'plt click mark 1;' ...
                   'plt click mark 2;' ...
                   'plt click mark 3;' ...
                   'set(gcf,"SelectionT","alt"); plt click TGLmenu;' ...
                   'set(gcf,"SelectionT","alt"); plt cursor 0 TGLlogx;' ...
                   'plt("hcpy","init",gcf);' ...
                   'plt hidecur;' ...
                   'h=findobj(gcf,"str","O"); eval(get(get(h(end),"ui"),"callb"));' ...
                   'delete([findobj(gcf,"tag","mark"); findobj(gcf,"tag","markR")]);' ...
                   [cb1 cb2 cb3] ...
                   'plt move;' ...
                   'plt move res;' };
             lb = {'<1>&Edit line (<2>e<3>) <4>Rclick Mark<5>' ...
                   '<1>Edit &all lines (<2>a<3>) <4>Delta+Rclick Mark<5>' ...
                   '<1>Edit &figure colors (<2>f<3>) <4>Rclick Properties in Ypopup<5>' ...
                   '<1>&Save figure colors (<2>s<3>)' ...
                   '<1>&Cursor Data Window (<2>c<3>)  <4>Rclick Menu<5>' ...
                   '<1>S&wap X/Y axes (<2>w<3>) <4>Rclick LinX<5>' ...
                   '<1>&Hardcopy (<2>h<3>) <4>Rclick LinY<5>' ...
                   '<1>H&ide/Show cursor controls (<2>i<3>)  <4>Rclick Yaxis label<5>' ...
                   '<1>&Toggle line smoothing (<2>t<3>)  <4>Rclick "o"<5>' ...
                   '<1>&Delete cursor annotations (<2>d<3>)  <4>Delta+Rclick "o"<5>' ...
                   '<1>Set d&ual cursor (<2>u<3>)' ...
                   '<1>Toggle &Reposition mode (<2>r<3>)  <4>Rclick Delta<5>'...
                   '<1>Reposition &Grid size (<2>g<3>) <4>Delta+Rclick Delta<5>' };
             sp = {'of' 'of' 'of' 'of' 'on' 'of' 'of' 'of' 'of' 'of' 'of' 'on' 'of'};
             rp = {'<1>' '<html>' '<2>' '<u>' '<3>' '</u>' '<4>' '<font color="blue"><i>' '<5>' ''};
             v = version;
             if v(1)=='6' rp = {'<1>' '' '<2>' '' '<3>' '' '<4>' '[' '<5>' ']'}; end;
             for k=1:length(cb)
               s = lb{k};
               for j=1:2:length(rp) s = strrep(s,rp{j},rp{j+1}); end;
               uimenu(m,'label',s,'call',strrep(cb{k},'"',''''),'sep',sp{k});
             end;
        end;
      end;

    case 242
      p = findobj(gcf,'buttond','plt click RMS;')';
      if length(p)>1 for pp=p if pp==gcbo p = pp; break; end; end;
                     AX = get(p,'user');  CurID = get(AX,'user');
                     Hc = get(CurMain(CurID),'user');
      end;
      misc = get(Hc(4),'user');
      lH = get(Hc(15+misc(4)),'user');
      hix = Hc(4);  hiy = Hc(6);  hix2 = Hc(5);  hiy2 = Hc(7);
      x = get(lH{1},'x');  y = get(lH{1},'y');
      xlim = get(Hc(14),'xlim');
      xx = find(x >= xlim(1)  &  x <= xlim(2));
      y = y(xx); y = y(~isnan(y)); ly = length(y);
      ps = get(p,'str');
      switch sum(ps)
        case 286,  s = 'RMS'; r = Pftoa('%7w',sqrt(sum(y.^2)/ly));
        case 242,  s = 'y/x';
                    xr = s2d(get(hix,'str'));
                    r = getappdata(p,'idcur');
                    r = Pftoa('%7w',s2d(r{2})/xr);
                    if sum(get(hiy2,'vis'))==221 & sum(get(hix2,'vis'))==221
                       xr = str2num(get(hix2,'str'));
                       set(hiy2,'str',s2d(get(hiy2,'str'))/xr);
                    end;
        case 288,  s = '\surdx^2+y^2';
                    xr = s2d(get(hix,'str'));
                    q = getappdata(p,'idcur');
                    r = Pftoa('%7w',abs(xr + s2d(q{2})*1j));
                    if sum(get(hiy2,'vis'))==221 & sum(get(hix2,'vis'))==221
                       xr = str2num(get(hix2,'str'));
                       set(hiy2,'str',abs(xr + s2d(q{3})*1j));
                    end;
        case 1110, r = getappdata(p,'idcur');  s = r{1}; set(hiy2,'str',r{3});  r = r{2};
        otherwise,  nwt = getappdata(gcf,'newtxt');
                    if sum(get(gcf,'SelectionT'))==321 & length(nwt)
                         setappdata(gcf,'newtxt',[]);
                         set(findobj(findobj(gcf,'user','TraceID'),'str',ps),'str',nwt);
                         set(p,'str',nwt); set(hiy,'str','');
                         return;
                    else setappdata(p,'idcur',{ps get(hiy,'str') get(hiy2,'str')});
                         s = 'Avg';
                         r = Pftoa('%7w',sum(y)/ly);
                    end;
      end;
      set(p,'str',s); set(hiy,'str',r);

    case 294
      in3 = varargin{3} - '0';
      a = getappdata(gcf,'Dedit');
      if isempty(a) return; end;
      cid = a{1};   Hc = get(CurMain(cid),'user');
      cid2 = get(gcbo,'tag');  Hd = [];
      if length(cid2) cid2 = s2d(cid2);
                      if length(cid2) & cid2>0 & cid2<=length(CurMain)
                         hd = CurMain(cid2);
                         if ishandle(hd) Hd = get(hd,'user');  end;
                      end;
      end;
      switch in3
      case 1,
        if length(Hd) & sum(get(Hd(12),'vis'))==221
          plt click EDIT 6 0;
          return;
        end;
        if ishandle(a{3}) & length(get(a{3},'buttond')) return; end;
        misc = get(Hc(4),'user');
        hact = Hc(15 + misc(4));
        a{9} = misc(1);
        m = get(hact,'marker'); a{4} = m(1)+0;
        ix = a{2};
        if a{3}~=hact  a{3} = hact;  a{7} = 0;
                       if ix<4 ix=ix+6; a{2}=ix; end;
        end;
        setappdata(gcf,'Dedit',a);
        b = 'plt click EDIT 3;';
        if ix<4 fc = get(hact,'color'); else fc = 'auto'; end;
        mk = 'd>^d>^d>^';  lw = '111222111';  msz = getappdata(gcf,'EditCur');
        set(hact,'marker',mk(ix),'markerface',fc,'markersize',msz,'linewidth',lw(ix)-'0','buttond',b);
      case 2,
        if length(Hd) & sum(get(Hd(12),'vis'))==221
          plt click EDIT 6 2;
          return;
        end;
        hd = [findobj(gcf,'style','edit','vis','on'); findobj(gcf,'user','grid')];
        set(hd,'vis','of');
        gc = findobj(hd,'buttond','plt click EDIT 2;');
        if length(gc)>1 gc = gco; end;
        fd = find(hd==gc);
        if length(fd) hd(fd) = [];  hd = [gc; hd]; end;
        hpop = getappdata(gcf,'epopup');
        setappdata(hpop,'EdHide',hd);
        pe = get(gc,'pos');  pa = get(hpop,'par');
        set(pa,'pos',[pe(1) .01 .13 .45]);
        set(gcf,'SelectionT','normal');
        evalQ(get(hpop,'buttond'));
        set(findobj(pa,'str','Cancel'),'color',[0 0 0],'fontw','bol');
      case 3, set(gcf,'WindowButtonMotionFcn','plt click EDIT 4;',...
                      'WindowButtonUpFcn',['set(gcf,''WindowButtonMotionFcn'','''',''WindowButtonUpFcn'','''');' ' plt click EDIT 5;']);
      case 4,
        i = mod(a{2},3);
        fmt = get(Hc(3),'user');
        y = get(get(a{3},'par'),'currentp'); x=y(1,1); y=y(1,2);
        if i~=2 set(a{3},'y',y); set(Hc(6),'str',Pftoa(fmt(2,:),y)); end;
        if i~=0 set(a{3},'x',x); set(findobj(gcf,'sty','edit','str',get(Hc(4),'str')),...
                                                'str',Pftoa(fmt(1,:),x));
        end;
        m = getappdata(gca,'MotionEdit'); if length(m) feval(m,a); end;
      case 5,
        ix = a{2};  hact = a{3};
        lh = get(hact,'user');  lk = lh{1};
        x = get(lk,'x');  y = get(lk,'y');   i = a{9};
        x1 = get(hact,'x');  y1 = get(hact,'y');
        if     ix<4 ilast = a{7};
                    x0 = x(ilast);  y0 = y(ilast);
                    inc = 1 - 2*(ilast>i);  steps = max(1,abs(ilast-i));
                    dx = (x1-x0)/steps; dy = (y1-y0)/steps;
                    for k = ilast:inc:i x(k)=x0; y(k)=y0; x0=x0+dx; y0=y0+dy; end;
        elseif ix<7 ylim = get(Hc(14),'ylim');
                    if y1<ylim(1) x(i) = [];  y(i) = [];
                    else          x = [x(1:i) x1 x(i+1:end)];
                                  y = [y(1:i) y1 y(i+1:end)];  i=i+1;
                    end;
        else        x(i)=x1; y(i)=y1;
        end;
        set(lk,'x',x,'y',y); setappdata(gcf,'NewData',i);
        if (Narg==4 & mod(a{2},3)==1) | sum(get(gcf,'SelectionT'))==321
          return;
        end;
        a{7} = i;  a{8} = hact;  setappdata(gcf,'Dedit',a);
        set(a{3},'marker',char(a{4}),'markerface','auto','markersize',a{5},'linewidth',a{6},'buttond','');
        plt('cursor',cid,'update',i);
      case 6,
        in4 = varargin{4} - '0';
        e = zeros(1,4);  e(in4+1) = 1;
        h = Hd(4:7);  v = get(h,'str');
        v=[v v]'; v(2,:)={' '}; v=sscanf([v{:}],'%f')';
        limy = Hd(14);
        limx = get(limy,'xlim');  limy = get(limy,'ylim');
        mnxy = [diff(limx)/300 diff(limy)/300];
        lim = [limx limy];  spd = mnxy/100;
        p = get(0,'PointerLoc');
        r = get(gcbo,'pos');  r = r(1) + [0 r(3)];
        if r(1)<1 fp = get(gcf,'pos');  r = r*fp(3); end;
        q = get(gcf,'currentp');
        if min(abs(q(1) - r)) < 5 e=1+0*e; end;
        f = gcf;  setappdata(f,'bdown',1);
        set(f,'WindowButtonUp','setappdata(gcf,''bdown'',0);');
        while getappdata(f,'bdown')
          q = spd .* (get(0,'PointerLoc')-p);
          if e(1) v(1) = min(max(v(1)+q(1),lim(1)),v(2)-mnxy(1)); set(h(1),'str',Pftoa('%7w',v(1))); end;
          if e(2) v(2) = max(min(v(2)+q(1),lim(2)),v(1)+mnxy(1)); set(h(2),'str',Pftoa('%7w',v(2))); end;
          if e(3) v(3) = min(max(v(3)+q(2),lim(3)),v(4)-mnxy(2)); set(h(3),'str',Pftoa('%7w',v(3))); end;
          if e(4) v(4) = max(min(v(4)+q(2),lim(4)),v(3)+mnxy(2)); set(h(4),'str',Pftoa('%7w',v(4))); end;
          set(Hd(12),'x',v([1 2 2 1 1]),'y',v([3 3 4 4 3]));
          mZoom(v); pause(.02);
        end;
      end;

    case 511
      hpop = getappdata(gcf,'epopup');
      hd = getappdata(hpop,'EdHide');
      set(hpop,'vis','of');  set(hd,'vis','on');
      if nargin==2 ix = plt('pop',hpop);
                   cb = get(hd(1),'call');
                   if ~iscell(cb) return; end;
                   CurID = cb{3};
      else         ix = varargin{3};
                   if ischar(ix) ix = s2i(ix); end;
                   CurID = get(gcbo,'tag');
                   if length(CurID) CurID = s2d(CurID);
                   else CurID = get(gca,'user');
                        if isempty(CurID) | ~isnumeric(CurID) | mod(CurID,1)
                          CurID = getappdata(gcf,'cid');  CurID = CurID(1);
                        end;
                   end;
      end;
      [ac AX] = plt('cursor',CurID,'getActive');
      AX = get(AX,'par');  r = get(AX,'YaxisLoc');
      if r(1)=='r' AX = findobj('type','axes','pos',get(AX,'pos')); AX=AX(1); end;
      Hc = get(CurMain(CurID),'user');
      AX2   = findobj(gcf,'YAxisLoc','right','user',CurID);
      AXrl  = [AX AX2];
      if isempty(AX2) AX2 = -1; end;
      a = getappdata(gcf,'Dedit'); a3 = a{3};
      switch ix
      case 1,
         if sum(get(gcf,'SelectionT'))==649 plt('click','mark','-1',CurID);
         else         plt click mark 2;
         end;
      case 2,
         multi = getappdata(AX,'multi');
         if length(multi) delete(multi); setappdata(AX,'multi',[]);
                          if sum(get(gcf,'SelectionT'))==649 return; end;
         end;
         Lha = getappdata(AX,'Lhandles'); Lhav = get(Lha,'vis');
         n = length(Lha);  cL = get(Lha,'color');
         c = (get(Lha(1),'color') + get(Lha(min(n,4)),'color'))/2;
         nn = zeros(1,n);  nnn = [nn; nn];  par = get(Lha,'par');
         tx = text(nn,nn,'');
         x = get(Lha(ac),'x');  if length(x)<3 return; end;  x12 = x([1 2 end]);
         for k=1:n
           x = get(Lha(k),'x');
           if length(x)<3 | ~all(x([1 2 end])==x12) Lhav{k} = 'off'; end;
         end;
         pr1 = {'par'};  cl1 = {'color'};  vl1 = {'vis'};
         if n<2 pr1 = pr1{1};  cl1 = cl1{1};  vl1 = vl1{1}; end;
         set(tx,pr1,par,'unit','data',cl1,cL,'tag','  %7w',vl1,Lhav); 
         mr = line(nnn,nnn,'color',c,'marker','o');
         set(mr,pr1,par,vl1,Lhav);
         vl = line([0 0],1e9*[-1 1],'color',c,'linest',':','par',AX);
         mc = [tx; mr; vl];  set(mc,'buttond',get(AX,'buttond'));
         p = getappdata(gcf,'mcProps');
         for k = 1:2:length(p)
           prop = p{k};  prp = prop(2:end); val = p{k+1};
           switch prop(1)
             case '|',  set(vl,prp,val);
             case '+',  if iscell(val) prp  = {prp};  end; set(mr,prp,val);
             otherwise, if iscell(val) prop = {prop}; end; set(tx,prop,val);
           end;
         end;
         setappdata(AX,'multi',mc);  plt('cursor',CurID,'update');
      case 3,
         xView = getappdata(AX,'xView');
         if nargin<4
           if length(xView) l = xView{1};  delete([l get(l,'par')]);
                            set(AXrl,'pos',xView{2});
                            setappdata(AX,'xView',[]);
                            return;
           end;
           numLines=length(Hc)-15;
           minx=+inf;  maxx=-inf;
           for i=1:numLines hLine = get(Hc(15+i),'user');
                            x = get(hLine{1},'x');
                            minx  = min(minx,min(x));
                            maxx  = max(maxx,max(x));
           end;
           p = get(AX,'pos');  g = get(gcf,'pos');  g = g(4);
           c1 = get(gcf,'color');  c2 = get(AXrl(end),'color');  d = c2 > 0.5;
           p2 = p - [0 0 0 20/g];  set(AXrl,'pos',p2);
           vs = 30 - 20*isempty(get(get(AX,'title'),'str'));
           p3 = p2 + [0 p2(4)+vs/g 0 12/g-p2(4)];
           lx = get(AX,'xlim');  dlx = mean(lx) + diff(lx)*[-1 1]./16;
           v = axes('pos',p3,'xlim',[minx maxx],'ylim',[1 3],'color',c2,'xcol',c2,'ycol',c1,'XtickLabel',' ','YtickLabel',' ','TickLen',[0 0]','buttond','plt click Yedit 3 0;');
           l = line(lx,[2 2],'color',c2 + .33*(~d - d),'linewidth',16,'buttond','plt click Yedit 3 1;','user',dlx);
           set([v l],'tag',sprintf('%d',CurID));
           if ~MverE set(v,'clippingStyle','rectangle'); end;
           r = getappdata(gcf,'xvProps');
           for k = 1:2:length(r)
             prop = r{k};  val = r{k+1};
             if prop(1) == '+'  prop(1)='';  if isempty(prop) prop='pos'; val = val+p3; end;
                                set(v,prop,val);
             else               set(l,prop,val);
             end;
           end;
           setappdata(AX,'xView',{l p 0});
           axes(AX);
         else
           l = xView{1};  v = get(l,'par');  x = get(v,'currentp');  x = x(1,1);  lx = get(l,'x');
           v4 = varargin{4}-'0';  if v4==1 & sum(get(gcf,'SelectionT'))==321 v4=0; end;
           switch v4
             case 0,
                     lx((x>mean(lx))+1) = x;  x = lx;
                     set(gcf,'WindowButtonMotionFcn','plt click Yedit 3 2;','WindowButtonUpFcn','set(gcf,''WindowButtonMotionFcn'','''',''WindowButtonUpFcn'','''');','tag',get(v,'tag'));
             case 1,
                     if sum(get(gcf,'SelectionT'))==434 x = get(v,'xlim');
                                 if lx(1)>x(1) | lx(2)<x(2) set(l,'user',lx); else x = get(l,'user'); end;
                     else xView{3} = x-lx(1);  setappdata(AX,'xView',xView); x=lx;
                          set(gcf,'WindowButtonMotionFcn','plt click Yedit 3 3;','WindowButtonUpFcn','set(gcf,''WindowButtonMotionFcn'','''',''WindowButtonUpFcn'','''');','tag',get(v,'tag'));
                     end;
             case 2, lx((x>mean(lx))+1) = x;  x = sort(lx);
             case 3, x = x-xView{3};  x = [x x+diff(lx)];
           end;
           set(l,'x',x);  set(AXrl,'xlim',x);
           axes(AX); evalQ(get(Hc(5),'user'));
         end;
      case 4,
        if ishandle(a3)
          set(a3,'marker',char(a{4}),'markerface','auto','markersize',a{5},'linewidth',a{6},'buttond','');
        end;
      otherwise,
        b = 'plt click EDIT 3;';
        if ishandle(a3) & strcmp(b,get(a3,'buttond')) plt click EDIT 5; end;
        ix = ix - 4;
        Hc = get(CurMain(CurID),'user');  misc = get(Hc(4),'user');
        hact = Hc(15 + misc(4));
        if ix<4 & hact~=a{8}
          ix=ix+6;
        end;
        m = get(hact,'marker'); m = m(1)+0;
        i = misc(1);
        setappdata(gcf,'Dedit',{CurID ix hact m get(hact,'markersize') get(hact,'linewidth') a{7} a{8} i});
        if ix<4 fc = get(hact,'color'); else fc = 'auto'; end;
        mk = 'd>^d>^d>^';  lw = '111222111';  msz = getappdata(gcf,'EditCur');
        set(hact,'marker',mk(ix),'markerface',fc,'markersize',msz,'linewidth',lw(ix)-'0','buttond',b);
      end;
    end;
    plt('grid',AX);
  else y8 = y2;  j = y8(2);
       clkType = sum(get(gcf,'SelectionT'));
       p = {'color'; 'marker'; 'linest'; 'linewidth'}; q = {[0 .3 .3] 'none' '-' 9};
       if clkType==649 | Narg>2
          k = y8(1);  s = get(k,'vis'); s = s(2)=='n';
          if s set(k,'vis','of'); else set(k,'vis','on'); end;
          if ishandle(j) & length(get(j,'par'))
            mk = getappdata(j,'mk');
            if s   set(j,'fonta','ita','fontw','nor'); set(mk,p,q);
            else   set(j,'fonta','nor','fontw','bol'); set(mk,p,get(k,p));
            end;
          end;
       else
          for k = findobj(get(j,'par'),'type','text')'
            t = get(k,'buttond');
            if iscell(t) & length(t{end})==2
              t = t{end}(1);
              mk = getappdata(k,'mk');
              if clkType==434 | k==j  set(t(1),'vis','on');  set(k,'fonta','nor','fontw','bol');  set(mk,p,get(t,p));
              else                      set(t(1),'vis','of');  set(k,'fonta','ita','fontw','nor');  set(mk,p,q);
              end;
            end;
          end;
       end;
       DualCur = getappdata(AX,'DualCur');
       Lh = getappdata(AX,'Lhandles');
       ls = findobj(Lh,'par',AX);
       v = 'off';
       for k=1:length(ls)
         if strcmp(get(ls(k),'vis'),'on') v = 'on';  break; end;
       end;
       set(get(AX,'ylab'),'vis',v);
       if ishandle(AX2)
         ls = findobj(Lh,'par',AX2);
         v = 'off';  leftC = get(AX2,'color');  gridXOR = leftC;
         for k=1:length(ls)
           if strcmp(get(ls(k),'vis'),'on')
             v = 'on';  leftC = 'none';  gridXOR = get(gcf,'color');
             set(AX2,'xlim',get(AX,'xlim'));
             break;
           end;
         end;
         set(AX2,'vis',v);  set(AX,'color',leftC);
         gridH = findobj(AX,'user','grid');
         if length(gridH)==1
           er = get(gridH,ERAS);
           if er(1)=='x'
             set(gridH,'color',bitxor(round(255*getappdata(gridH,'clr')),round(255*gridXOR))/255);
           end;
         end;
       end;
       TIDback = [];
       if Narg<3 & ishandle(j) TIDback = getappdata(get(j,'par'),'TIDcback'); end;
       if length(TIDback)
          setappdata(gcf,'OBJ',y2(1));  setappdata(gcf,'OBJ2',y2(2));
          evalRep(TIDback,{'@LINE' 'plt("misc",3)' '@TID' 'plt("misc",4)' '@IDX' 'plt("misc",5)'});
       end;
       axes(AX);
  end;

case 740,
  tx = [];  a = findobj(gcf,'tag','MenuBox')';
  for k=a tx = [tx get(k,'child')']; end;
  cid = getappdata(gcf,'cid');  nc = length(cid);
  if length(getappdata(gcf,'hidecur'))
        setappdata(gcf,'hidecur',[]);   set([a tx],'vis','on');  vis = 'visON';
  else  setappdata(gcf,'hidecur',0);    set([a tx],'vis','of');  vis = 'visOFF';
  end;
  for k=cid plt('cursor',k,vis); end;

case 449,
  h = getappdata(gcf,'Lhandles');  n = length(h);
  q = 3-cellfun('length',get(h,'vis'));
  if Narg<2 Ret1 = find(q'); return; end;
  v = zeros(n,1);  w=v;  e = varargin{2};
  if ischar(e) & length(e) v=v+1;  else v(e)=1; end;
  v = find(xor(v,q));
  t = findobj(gcf,'user','TraceID');
  if length(t)
    t = [flipud(findobj(t,'type','text')); w];
  end;
  for k=1:length(v) plt('click',[h(v(k)) t(v(k))],0); end;

case 439,
  if Narg==1
     if isempty(getappdata(gcf,'mv')) plt move init; end;
     if getappdata(gcf,'mv') plt move off; else plt move on; end;
     return;
  end;
  ui = getappdata(gcf,'uic');  Nui = length(ui);
  si = getappdata(gcf,'sli');  Nsi = length(si);
  ax = getappdata(gcf,'axi');  Nax = length(ax);
  tx = getappdata(gcf,'txt');  Ntx = length(tx);
  pp = getappdata(gcf,'pop');  Npp = length(pp);
  v = varargin{2};
  if ~ischar(v)
    for k=1:length(v)
      t = v(k);
      switch get(t,'type')
        case 'uicontrol', ui = [ui t]; setappdata(gcf,'uic',ui);
        case 'text',      tx = [tx t]; setappdata(gcf,'txt',tx);
        case 'axes',      ax = [ax t]; setappdata(gcf,'axi',ax);
      end;
    end;
    return;
  end;
  v = sum(v);
  switch v
  case 330
    f = gcf;
    if isempty(getappdata(f,'mv')) plt move init; end;
    r = getappdata(f,'snap');
    figure('menu','none','numberT','off','back','off','resize','off','pos',auxLoc(270,60),'color',[0,.4,.4],'name','SnapTo resolution','user',gcf,'tag',get(gcf,'tag'));
    plt('slider',[.035 .64],[r(1) 0 200 0 10000],'No. of X grid points',...
      'g = get(gcf,"user"); r = getappdata(g,"snap"); setappdata(g,"snap",[@VAL r(2)])',2);
    plt('slider',[.525 .64],[r(2) 0 200 0 10000],'No. of Y grid points',...
      'g = get(gcf,"user"); r = getappdata(g,"snap"); setappdata(g,"snap",[r(1) @VAL])',2);
    figure(f);
    return;
  case 436
    if isempty(getappdata(gcf,'snap')) setappdata(gcf,'snap',[100 100]); end;

    t = findobj(gcf,'type','text');
    for k=1:length(t);
      if isempty(getappdata(t(k),'ty')) tx = [tx t(k)]; setappdata(t(k),'ty','txt'); end;
    end;
    setappdata(gcf,'txt',tx)

    for k=1:Nsi setappdata(si(k),'ty','sli'); end;
    t = findobj(gcf,'type','uicontrol');
    for k=1:length(t)
      if isempty(getappdata(t(k),'ty')) ui = [ui t(k)]; setappdata(t(k),'ty','uic'); end;
    end;
    t = findobj(gcf,'type','uipanel');  r = findobj(gcf,'type','uitable');
    ui = [ui t' r'];
    for k=1:length(t) setappdata(t(k),'ty','uip'); end;
    for k=1:length(r) setappdata(r(k),'ty','uit'); end;
    setappdata(gcf,'uic',ui);

    t = findobj(gcf,'type','axes');
    for k=1:length(t)
      if isempty(getappdata(t(k),'ty')) ax = [ax t(k)]; setappdata(t(k),'ty','axi');
      end;
    end;
    setappdata(gcf,'axi',ax);
    setappdata(gcf,'mv',0);
    return;
  end;
  uip = {'buttond' 'ena'};
  if v==221
    if isempty(getappdata(gcf,'mv')) plt move init; end;
    setappdata(gcf,'mv',1);
    for k=1:Nui if sum(getappdata(ui(k),'ty'))==334
                  setappdata(ui(k),'CBsv',get(ui(k),'buttond'));
                  set(ui(k),'buttond','plt misc tidmv;');
                else
                  setappdata(ui(k),'CBsv',get(ui(k),uip));
                  set(ui(k),'ena','of','buttond','plt misc tidmv;');
                end;
    end;
    for k=1:Nsi setappdata(si(k),'CBsv',get(si(k),uip));
                set(si(k),'ena','of','buttond','plt misc slimv;');
                setappdata(si(k),'ty','sli');
    end;
    for k=1:Nax setappdata(ax(k),'CBsv',get(ax(k),'buttond'));
                set(ax(k),'buttond','plt misc tidmv;');
    end;
    for k=1:Ntx setappdata(tx(k),'CBsv',get(tx(k),'buttond'));
                set(tx(k),'buttond','plt misc txtmv;');
    end;
    for k=1:Npp setappdata(pp(k),'CBsv',get(pp(k),'buttond'));
                set(pp(k),'buttond','plt misc tidmv;');
    end;
    setappdata(gcf,'CBsv',get(gcf,'buttond'));  set(gcf,'buttond','');
    gr = findobj(gcf,'user','grid');
    if length(gr) gr=gr(end); setappdata(gr,'CBsv',get(gr,'buttond')); set(gr,'buttond','plt misc tidmv;'); end;
    set(findobj(gcf,'str','D','fontn','symbol'),'str',char(222));
  else
    set(findobj(gcf,'str',char(222),'fontn','symbol'),'str','D');
    setappdata(gcf,'mv',0);
    for k=1:Nui if sum(getappdata(ui(k),'ty'))==334
                     set(ui(k),'buttond',getappdata(ui(k),'CBsv'));
                else set(ui(k),uip,getappdata(ui(k),'CBsv'));
                end;
    end;
    for k=1:Nsi set(si(k),uip,     getappdata(si(k),'CBsv')); end;
    for k=1:Nax set(ax(k),'buttond',   getappdata(ax(k),'CBsv')); end;
    for k=1:Ntx set(tx(k),'buttond',   getappdata(tx(k),'CBsv')); end;
    for k=1:Npp set(pp(k),'buttond',   getappdata(pp(k),'CBsv')); end;
    set(gcf,'buttond',getappdata(gcf,'CBsv'));
    gr = findobj(gcf,'user','grid');
    if length(gr) gr=gr(end); set(gr,'buttond',getappdata(gr,'CBsv')); end;
  end;

case 534,   for f = findobj('type','fig')'
                   b = get(f,'buttond');
                   if iscell(b) & length(b)>3 & sum(lower(b{4}))==634
                     set(f,'closereq','closereq'); close(f);
                   end;
               end;
               setappdata(0,'CurMain',[]);
case 632,  set(flipud(findobj(findobj(gcf,'user','TraceID'),'type','text')),{'str'},varargin{2}(:));
case 641,  set(gcf,'SelectionT','alt');    plt('cursor',varargin{2:end});
case 526,   set(gcf,'SelectionT','normal'); plt('cursor',varargin{2:end});
case 662,  set(gcf,'SelectionT','alt');    plt('click',varargin{2:end});
case 547,   set(gcf,'SelectionT','normal'); plt('click',varargin{2:end});
case 774, Ret1 = '01Jan17'; Ret2 = 0;

otherwise, [Ret1 Ret2] = pltinit(varargin{:});
end;

function t = logTicks(lim)
  a = lim(1);  b = lim(2);
  if a<=0 | b<=0  t=lim; return; end;
  ex = floor(log10(a));  p = 10^ex;
  d = floor(a/p);  t = d*p;
  while 1
    d = d+1;
    if d>9 d=1; ex=ex+1;  p=p*10; end;
    v = d*p;   t = [t v];
    if v>=b break; end;
  end;

function setlim(ax,prop,lim);
  if lim(1) <= 0 | lim(2) <= 0
    s = get(ax,[prop(1) 'scale']);
    if s(2) == 'o' lim = abs(lim(2))*[0.001 1]; end;
  end;
  set(ax,prop,lim);

function mZoom(xy)
  a = getappdata(gca,'MotionZoom');
  if length(a)
    x = sort(xy(1:2));  y = sort(xy(3:4));
    if diff(x) & diff(y)
      b = [x y];
      if ischar(a)     feval(a,b);
      elseif iscell(a) a = [a {b}]; feval(a{:})
      else             a = {a b};   feval(a{:});
      end;
    end;
  end;

function fixMark()
  markR = findobj(gcf,'tag','markR')';
  if isempty(markR) return; end;
  for l = markR
    u = get(l,'user');
    t = u{1};  ax = u{2};  axr = u{3};  ylim = u{4};  rlim = u{5};
    if ishandle(t) p = get(t,'pos');  else p = [0 0]; end;
    y = [get(l,'y') p(2)];
    y = rlim(1) + diff(rlim) * (y - ylim(1)) / diff(ylim);
    rlim = get(axr,'ylim');   ylim = get(ax,'ylim');
    y = ylim(1) + diff(ylim) * (y - rlim(1)) / diff(rlim);
    set(l,'y',y(1),'user',[u(1:3) {ylim rlim}]);
    if ishandle(t) p(2) = y(2);  set(t,'pos',p); end;
  end;

function edg(txt,clr)
  v6 = version;  v6 = (v6(1)=='6');
  if nargin>1
    if v6 if strcmp(clr,'none') return; end;
          a = get(txt,'par');
          setappdata(txt,'li',line(0,0,'par',a,'color',clr,'clip','off'));
    else  set(txt,'edge',clr);
    end;
  elseif v6  li = getappdata(txt,'li');
             if ishandle(li)
               e = get(txt,'extent');  x=e(1); y=e(2); x2=x+e(3); y2=y+e(4)*1.1;
               set(li,'x',[x x2 x2 x x],'y',[y y y2 y2 y]);
             end;
  end;

function v = auxLoc(w,h,au)
     f = findobj('type','fig','tag',get(gcf,'tag'));  nfig = length(f);
     if nargin==3
       area = 0;
       for k=1:nfig
         p = get(f(k),'pos'); p = prod(p(3:4)); if p>area area=p; gf=f(k); end;
       end;
     else gf=gcf; au=0;
     end;
     set(0,'unit','pix');  sz = get(0,'screens');
     szw = sz(3) - w - 4;
     ppos  = get(gf,'pos');
     if ppos(4)<1 sp = sz(3:4); ppos = ppos .* [sp sp]; end;
     x = min(ppos(1)+ppos(3)+9,szw) + au;
     y = ppos(2) + ppos(4) - h - 30*(nfig-1);
     v = [x y w h];

function c = divc(a,b)
  c = complex(real(a)/real(b),imag(a)/imag(b));

function r2 = plt2nd(v)
  [r1 r2] = plt(v{:});

function evalQ(a)
  if ischar(a)     a = strrep(a,'"','''');
                   eval(a);
  elseif iscell(a) feval(a{:});
  else             feval(a);
  end;

function evalRep(a,rep)
  if ischar(a)     for k=1:2:length(rep) a = strrep(a,rep{k},rep{k+1}); end;
                   a = strrep(a,'"','''');
                   eval(a);
  elseif iscell(a) feval(a{:});
  else             feval(a);
  end;

function r = evalRep2(a,rep)
  if ischar(a)     for k=1:2:length(rep) a = strrep(a,rep{k},rep{k+1}); end;
                   a = strrep(a,'"','''');
                   r = eval(a);
  elseif iscell(a) r = feval(a{:});
  else             r = feval(a);
  end;

function [rpt,p] = getREPEAT(e)
  rpt = getappdata(gcbo,'repeat');
  if nargin & isempty(rpt)
     b = get(gcbo,'buttond');
     if iscell(b) & length(b)>2 rpt = getappdata(b{3},'repeat'); end;
  end;
  if length(rpt)>1 p = rpt(2); else p = .4; end;
  if length(rpt) rpt = rpt(1);
  else           rpt = .03;
  end;

function s = ctriple(val)
  s = strrep(prin(' {%3w!  }',val),' 0.','.');
  if s(1)==' ' s = s(2:end); end;

function set2(h,varargin)
  set(h(ishandle(h)),varargin{:});

function b = isequalNaN(x,y)
  x(isnan(x)) = 123456789;
  y(isnan(y)) = 123456789;
  b = isequal(x,y);

function v = s2d(s)
   v = sscanf(s,'%f');

function v = s2i(s)
   v = sscanf(s,'%d');
