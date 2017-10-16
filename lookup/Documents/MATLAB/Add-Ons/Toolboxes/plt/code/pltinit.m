% pltinit.m:  An alternative to plot & plotyy
% Author:     Paul Mennen (paul@mennen.org)
%             Copyright (c) 2017, Paul Mennen

function [Ret1,Ret2] = pltinit(varargin);

Ret1 = 0;
Ret2 = 0;
Narg = nargin;
Mver = version;  Mver = sscanf(Mver(1:3),'%f');
MverE = (Mver<8.4);
if MverE  ERAS = 'eras';  ERAXOR = 'xor';  ERANOR = 'norm';
else      ERAS = 'pi';    ERAXOR = 'v';    ERANOR = 'v';
end;

dTRACE  = [0  1  0;   1  0  1;   0  1  1;   1  0  0;   0  0  1;
           1  1  1;   1  1  0;   1 .5 .5;  .5 .5  1;   1 .5  0;
           1  0 .5;  .5  0  1;   0 .5  1;   0  1 .5;   1  1 .5; 1 .5  1];
cTrace = zeros(99,3);  br = [1 .66 .444 .8 .533 .355 .75];
k = 1;  j = 1;
for m=1:99  cTRACE(m,:) = dTRACE(k,:) * br(j);
               if k==16 k=1; j=j+1; else k=k+1; end;
end;

cTRACE  = [0  1  0;   1  0  1;   0  1  1;   1  0  0;  .2 .6  1;
           1  1  1;   1 .6 .2;  .3 .3  1;   1 .2 .6;  .2  1 .6;
          .8  1 .5;  .6 .2  1;   1  1  0;   0 .5  0;  .5  0 .5;
           0 .6 .6;   0  0 .9;   0 .3 .3;  .5  0  0;  .3 .3  0;
          .7 .2 .2;  .2 .7 .2;  .3 .3 .3;  .4 .4 .7;   0 .6 .3;
          .8 .5 .5;  .4 .6 .3;  .5 .5  0;  .7 .7 .2;  .5 .5 .5;
          .7 .2 .7;   1 .4 .4;  .4  1 .4;  .4 .9  0;  .5 .1 .3;
          .3  0 .8;   0  0 .5;  .5 .5  1;   0 .3 .8;  .7 .2  0];
for k=41:99 cTRACE = [cTRACE; .74 * cTRACE(k-40,:)]; end;

posFIG  = 0;
AXISp   = [];
o4      = ones(1,4);
idPOS   = o4;
axisPOS = o4;
cFIGbk  = [.25 .15 .15];
cPLTbk  = [ 0   0   0 ];
cTID    = [];
cXYax   = [ 1   1   1 ];
cXYlbl  = [.7  .8  .95];
CURcDEF = [ 1   1  .50];
cCURSOR = CURcDEF;
cDELTA  = [ 1   0   0 ];
cPLTbk2 = [];
cFIGbk2 = [];
cTRACE2 = [];
cDELTA2 = [];
cXYlbl2 = [];
cDEFAULT = cTRACE;
Grid = 'on';
cGRIDs  = 0;
GridSt  = 0;
GridSty = '-';
cGRID = [.13 .13 .13];
cDEF    = 0;
LabelX = 'X axis';
LabelY = 'Y axis (Left)';
LabelYr = 'Y axis (Right)';
Title = '';
Xlim   = 'default';
Ylim   = 'default';
YlimR  = 'default';
Xscale = 'linear'; Xsc = 'LinX';
Yscale = 'linear'; Ysc = 'LinY';
Mbar = 0;
Xslide = 0;
LineSmooth = 0;
FigShow = 1;
HelpFile = '';
HelpFileR = '';
cFile = '#';
ENApre = [1 1];
ENAcur = ones(1,99);
DIStrace = 0;
Style  = 0;
Marker = 0;
AXr = 0;
Right = [];
DualCur = 0;
TIDcback = '';
TIDcolumn = 0;
MenuBox = [1 1 1 1 0 1 1 1 1];
npch = zeros(1,99);
TRACEid = reshape(sprintf('Line%2d',1:99),6,99)';
TRACEmk = 0;
Xstring = '';
Ystring = '';
moveCB = '';
axisCB = '';
ucreq = '';
axLink = 1;
SubPlot = [];
SubTrace = [];
NoCursor = 0;
xViewOpt = 0;
multiCurOpt = 0;
aLp = {}; aLv = {};
aRp = {}; aRv = {};
lLp = {}; lLv = {};
lRp = {}; lRv = {};
lXp = {}; lXv = {};
TIp = {}; TIv = {};
posPEAK = [.0071  .0441  .0250  .0343];
posVALY = [.0071  .0060  .0250  .0343];
posDEL  = [.0350  .0441  .0280  .0343];
posM    = [.0350  .0060  .0280  .0343];
posSLDR = [.0071  .0080  .1250  .0200];
posBox  = [.0070  .0870  .0580  .0000];

addSlots = 0;
if exist('addSlots')
     MLalive = 1;
     dbs = feval('dbstack');
     n = length(dbs);  FigName = '';
     if n  a = stripp(dbs(1).name);
           if ~strcmp(a,'pltinit') FigName = a;
           elseif n>1 a = stripp(dbs(2).name);
                      if ~strcmp(a,'plt') FigName = a;
                      elseif n>2 FigName = stripp(dbs(3).name);
                      end;
           end;
     end;
     if isempty(FigName) FigName = 'plt'; addSlots = 1; end;
else MLalive = 0;
     GetExee = GetExe;
     FigName = getappdata(0,'FigName');
     if length(FigName) setappdata(0,'FigName',[]);
     else               [temp FigName] = fileparts(GetExee);
     end;
end;

fontsz = (196-get(0,'screenpix'))/10;
a1 = varargin{1};  exFig = ischar(a1);
if exFig exFig = (sum(lower(a1)) == 310); end;
if exFig FIG = varargin{2};
elseif nargin>3
  a1 = varargin{end-1}; exFig = ischar(a1);
  if exFig exFig = (sum(lower(a1)) == 310); end;
  if exFig FIG = varargin{end}; end;
end;
if exFig figure(FIG);  set(FIG,'vis','of');
         posFIG = get(FIG,'pos')*1i;
else     FIG = figure('menu','none','numberT','off','back','off','vis','of');
end;
if MverE  FIGt = FIG;
          posAX   = [.1429  .0933  .8329  .8819];
else      posAX   = [.1429  .1033  .8329  .8719];
          FIGt = get(FIG,'number');                  
end;
set(FIG,'PaperPositionMode','auto','invert','off','PaperOrient','land',...
        'PaperUnits','norm','DoubleBuf','on','Invert','on');
if Mver<7 figure(FIG); end;
AX = axes('unit','nor','fontsi',fontsz,'tag','click');

Ret1 = [];  nt = 0;
kparam = [];
k = 1;
pp = 1;
while k<=Narg
  y  = varargin{k};  k=k+1;
  if ischar(y)
    if k>Narg
       disp('Error using ==> plt.  Not enough input arguments.');
       disp('For help on using plt, type "help plt"');
       eval('plt help;');
       return;
    end;
    kparam = [kparam k-1 k];
    y = lower(y);  yy = varargin{k};   k=k+1;
    pfx = zeros(1,6);
    while length(y)>1
      b = findstr(y(1),'+-<>.^');
      if isempty(b) break; end;
      pfx(b) = 1;  y(1) = [];
    end;
    switch sum(y)
      case 546,     Title    = yy;
      case 442,      Xlim     = yy;
      case 443,      Ylim     = yy;
      case 557,     if y(1)=='y'  YlimR = yy;  AXr = 1; else cXYax = yy; end;
      case 632,    LabelX   = yy;
      case 633,    LabelY   = yy;
      case 747,   LabelYr  = yy;  if length(yy) AXr = 1; end;
      case 542,     Right    = yy;  if length(yy) AXr = 1; end;
      case 752,   DualCur  = yy;
      case 727,   FigName  = yy;
      case 640,    cPLTbk   = ctrip(yy); cPLTbk2 = cPLTbk;
      case 614,    cFIGbk   = ctrip(yy); cFIGbk2 = cFIGbk;
      case 626,    cTRACE   = ctrip(yy); cTRACE2 = cTRACE;
      case 621,    cDELTA   = ctrip(yy); cDELTA2 = cDELTA;
      case 654,    cXYlbl   = ctrip(yy); cXYlbl2 = cXYlbl;
      case 769,   cCURSOR  = ctrip(yy);
      case 420,      cTID     = yy;
      case 521,     yy = ctrip(yy);  if any(yy<0) GridEr = ERANOR; else GridEr = ERAXOR; end;
                       cGRID    = abs(yy);  cGRIDs = 1;
      case 983, GridSty = yy;        GridSt = 1;
      case 676,    if iscell(yy) Style = char(yy);   else Style = yy;   end;
      case 757,   if iscell(yy) Marker = char(yy);  else Marker = yy;  end;
      case 732,   if iscell(yy) TRACEid = char(yy); else TRACEid = yy; end;
      case 743,   if length(yy)==1 & yy  yy = [yy (yy+.9)/2 .9]; end;
                       TRACEmk = yy;
      case 638,    ENAcur   = yy;
      case 847,  DIStrace = yy;
      case {338 885}, posFIG = yy;
      case 241,        [rw cl] = size(yy);
                       if rw==1 & cl==4 AXISp = [0 yy];
                       elseif cl~=5 disp('Warning: xy parameter ignored. Must have 5 columns');
                       else AXISp = yy;
                       end;
      case 775,   axisPOS  = yy(1:4);
                       switch length(yy) case 5, idPOS(3)=yy(5); case 8, idPOS=yy(5:8); end;
      case 821,  TIDcback = yy;
      case 975, TIDcolumn = yy;
      case 783,   Xstring  = yy;
      case 784,   Ystring  = yy;
      case 635,    if length(yy)==1 yy = [yy yy]; end;  ENApre = yy;
      case 841,  HelpFile = yy;
      case 955, HelpFileR = yy;
      case 959, cFile    = yy;
      case 846,  cDEF = 1;
                       cPLTbk = get(0,'defaultaxescolor');
                       cFIGbk = get(0,'defaultfigurecolor');
                       cXYax  = get(0,'defaultaxesxcolor');  cXYlbl = cXYax;
                       if ischar(yy) | (sum(size(yy))==2 & yy==0) yy = 999999; end;
                       yy = ctrip(yy);
                       if all(yy(1,:)==.99) yy = [get(0,'defaultaxescolororder'); yy(2:end,:)]; end;
                       cTRACE = yy;
      case 636,    moveCB = yy;
      case 634,    axisCB = yy;
      case 867,  axLink = yy;
      case 430,      if length(yy) if MverE FIGt = yy;
                                     else     FIGt = get(yy,'Number');
                                     end;
                       end;
      case 862,  ucreq = yy;
      case 777,   SubPlot = yy;  ENApre(1) = 0;
      case 857,  SubTrace = yy; ENApre(2) = 0;
      case 1084, setappdata(gca,'MotionEdit',yy);
      case 1115, setappdata(gca,'MotionZoom',yy);
      case 1013,  setappdata(gca,'MotionZup',yy);
      case 310,
      case 878,  plt('helptext','set',yy);  HelpFileR = 'plt helptext on;';
      case 43,      if length(yy)~=1 | yy<1 | mod(yy,1) | yy>1000
                            disp('Illegal ''+'' parameter was ignored');
                       else H = line(NaN,NaN+zeros(1,yy));
                            Ret1 = [Ret1; H]; nt1=nt+1; nt = nt+length(H);
                            npch(nt1:nt) = 1;
                            [tidn tidw] = size(TRACEid);
                            while tidn < nt
                               tidn=tidn+1; s=sprintf('+%d                                ',tidn);
                               TRACEid = [TRACEid; s(1:tidw)];
                            end;
                       end;
      case 780,   kq = 0;
        while kq < length(yy)
          kq = kq + 1;
          switch yy(kq)
            case 'T', Grid = 'off';
            case 'M', Mbar = 1;
            case 'X', Xsc = 'LogX';  Xscale = 'Log';
            case 'Y', Ysc = 'LogY';  Yscale = 'Log';
            case 'S', Xslide = 1;
            case 'L', LineSmooth = 1;
            case 'N', NoCursor = 1;
            case 'H', FigShow = 0;
            case 'V', xViewOpt = 1;
            case 'C', multiCurOpt = 1;
            case 'I', cFile = '';
            case '-', kq = kq + 1;  km =findstr(yy(kq),'HXYGPFMZRA');
                      if length(km) if km==10 MenuBox=0; else MenuBox(km)=0; end; end;
            case '+', kq = kq + 1;  km =findstr(yy(kq),'HXYGPFMZRA');
                      if length(km) if km==10 MenuBox=ones(1,9);
                                    else if pp & km~=5 MenuBox=0; pp=0; end;
                                         MenuBox(km)=1;
                                    end;
                      end;
          end;
        end;
      otherwise,
         if sum(pfx)
           if pfx(1) aLp = [aLp {y}]; aLv = [aLv {yy}]; end;
           if pfx(2) aRp = [aRp {y}]; aRv = [aRv {yy}]; end;
           if pfx(3) lLp = [lLp {y}]; lLv = [lLv {yy}]; end;
           if pfx(4) lRp = [lRp {y}]; lRv = [lRv {yy}]; end;
           if pfx(5) lXp = [lXp {y}]; lXv = [lXv {yy}]; end;
           if pfx(6) TIp = [TIp {y}]; TIv = [TIv {yy}]; end;
         else
           if iscell(yy)
             if length(yy)==length(Ret1)
               y = {y};
               yy = yy(:);
             else fprintf('Warning: For parameter %s, found %d elements but expected %d\n',y,length(yy),length(Ret1));
             end;
           end;
           set(Ret1,y,yy);
         end;
    end;
  else
     ny = 0;
     if k<=Narg                yy = varargin{k}; else yy = 'a'; end;
     if iscell(y) & iscell(yy) k = k+1;  ny = length(y);
                               if length(yy) == ny
                                 for m=1:ny
                                   H = line(y{m},yy{m}); Ret1=[Ret1; H]; nt=nt+length(H);
                                 end;
                               else disp('Error: Cell array pair must have the same length');
                              end;
     elseif ~isreal(y)         yy = imag(y);  y = real(y);
     elseif isnumeric(yy)      k = k+1;
     elseif iscell(yy)         k = k+1;  yy = feval('cell2mat',yy);
     else                      yy=y; y=1:length(yy);
     end;
     if ~ny  H = line(y,yy);  Ret1 = [Ret1; H];   nt = nt + length(H); end;
  end;
  if addSlots & k>=Narg & ~sum(npch) Narg=Narg+2; varargin = [varargin {'+' 8}]; end;
end;

if iscell(Ylim) YlimR = Ylim{2}; Ylim = Ylim{1}; AXr = 1; end;
if ~iscell(LabelX) LabelX = {LabelX}; end;
if ~iscell(Xlim)   Xlim   = {Xlim};   end;
if (length(LabelX)>1 | length(Xlim)>1) & isempty(SubPlot) & nt>1 SubPlot = [100i -50 100]; end;

if length(SubPlot)
  indep = ~isreal(SubPlot(1));
  if indep SubPlot(1) = imag(SubPlot(1));
  else indep=-1;
  end;
  if SubPlot(end)>0 SubPlot=[SubPlot -999]; end;
  k = find(SubPlot<0);
  npC = diff([0 k])-1;  nC = length(npC);
  dx = -SubPlot(k);  SPw = floor(dx);
  SubPlot(k) = [];
  nSP = length(SubPlot);
  nSPm = nSP - 1;
  if iscell(LabelY) & (length(LabelY)>nSP) AXr=1; end;
  if max(npC) == 1 indep = 1; end;
  dc = .1;
  dw = (3 + (indep>0)*(2-MverE))/100;
  dx = dx-SPw; dx = dx-(dx>.5)+dc;
  if SPw(end)==999 SPw(end)=1099-sum(SPw); end;
  SPdy = SubPlot;  SubPlot = floor(SPdy);
  SPdy = SPdy-SubPlot;  SPdy=SPdy-(SPdy>.5)+dw;
  SubPlot = SubPlot/100;  SPw = SPw/100;
  if ~(posFIG)
    posFIG = round([980-280/nC 600-75/max(npC)]);
  end;
  posFIG = figpos(posFIG);
  if AXr rsp = 40/posFIG(3);
         if length(dx)<2 SPw = SPw-rsp;
         else            dx(2) = dx(2)+rsp;
         end;
  end;
  SPw = SPw - (sum(dx)-dc)/nC;
  SPx = cumsum(dx + [0 SPw(1:end-1)]) - dc;
else  npC=1; nC=1; nSP=0; nSPm=0; indep=0;
      posFIG = figpos(posFIG);
end;
setappdata(gcf,'indep',indep);

nID = nt - nSPm * isempty(SubTrace);
if nID>99 & TRACEid disp(sprintf('Max # of traceIDs = %d',99)); return; end;
if ~iscell(LabelY) LabelY = {LabelY}; end;
if length(LabelY) >= nSPm+2  LabelYr = LabelY{nSPm+2}; AXr = 1; end;

setappdata(FIG,'params',varargin(kparam));
if isempty(TIDcolumn)
  if     nID>48 & nID<100  k = floor(nID/3); TIDcolumn = [k k];
  elseif nID>24                              TIDcolumn = floor(nID/2);
  else                                       TIDcolumn = 0;
  end;
end;
k = sum(TIDcolumn);
if k  TIDcolumn = [nID-k TIDcolumn]; else TIDcolumn = nID; end;
ntid = max(TIDcolumn);
ncol = length(TIDcolumn);
if ncol>1 & all(axisPOS == o4) & all(idPOS == o4) & nID<100
  idPOS(3) = ncol;
  axisPOS = [.4 + ncol/2, 1, (210-11*ncol-ncol^2)/200, 1];
end;
if all(idPOS == o4) & (nt<6 | isempty(LabelY{1})) & ~nSP
   idPOS(3) = 1.2;
end;
fsep = length(findstr(cFile,filesep));
if length(cFile) & ~fsep
  if MLalive
       m = feval('dbstack');
       if length(m)
          n = m(end).name;
          nq = findstr('(',n);
          if length(nq) n = n(1:nq(1)-2); end;
          np = findstr(filesep,n);
          if length(np) np=np(end); else np=0; end;
          if length(n)-np>30 & length(m)>1  n = m(end-1).name; end;
          m = feval('which',n);
       else m = feval('which','plt');
       end;
  else m = GetExee;
  end;
  [pth, name] = fileparts(m);
  if cFile(1) == '#' cFile = [name 'Color']; end;
  cFile = fullfile(pth,[cFile '.mat']);
end;
if fsep cFile = [cFile '.mat']; end;
cFileS = cFile;
if exist(cFile)~=2 & length(cFile)
  if MLalive
       cpath = feval('which','plt.m');
  else cpath = GetExee;
  end;
  cFile = [fileparts(cpath) filesep 'pltColorAll.mat'];
end;
if exist(cFile)==2 load(cFile);
                   if length(cPLTbk2) cPLTbk = cPLTbk2; end;
                   if length(cFIGbk2) cFIGbk = cFIGbk2; end;
                   if length(cTRACE2) cTRACE = cTRACE2; end;
                   if length(cDELTA2) cDELTA = cDELTA2; end;
                   if length(cXYlbl2) cXYlbl = cXYlbl2; end;
end;
if isempty(cTID) cTID = cPLTbk; end;
if length(ENAcur)<nt  ENAcur = [ENAcur ones(1,nt-length(ENAcur))]; end;
if length(DIStrace)<nt  DIStrace = [DIStrace zeros(1,nt-length(DIStrace))]; end;
ndc = length(cTRACE(:,1));

if isnumeric(Title) Title = num2str(Title); end;
terp = 'tex';
if iscell(Title)
  axisPOS = axisPOS .* [1 1 1 1 - length(Title)*.035];
  ntx = findstr('[TexOff]',Title{1});
  if length(ntx)==1  Title{1}(ntx:ntx+7) = []; terp = 'none'; end;
elseif length(Title)
  axisPOS = axisPOS .* [1 1 1 .96];
  ntx = findstr('[TexOff]',Title);
  if length(ntx)==1 Title(ntx:ntx+7) = [];  terp = 'none'; end;
end;
title(Title,'color',cXYlbl,'handlev','on','interp',terp);

setappdata(AX,'DualCur',DualCur);
if ~cGRIDs
  if AXr GridEr = ERAXOR; else GridEr = ERANOR; end;
end;
if ~MverE & AXr & ~cGRIDs & ~GridSt
  GridSty = ':';
  cGRID = [.26 .26 .26];
end;
if AXr & nID>1
   if isempty(Right) Right = nID; end;
   axisPOS = axisPOS .* [1 1 .937 1];
   if ischar(YlimR)
     mn = inf;  mx = -inf;
     if max(Right)>length(Ret1) disp('Error: Right trace number points to non-existing data'); return; end;
     for k=Right
       y = get(Ret1(k),'y');  mn = min(mn,min(y));  mx = max(mx,max(y));
     end;
      df=(mx-mn)/20; YlimR=[mn-df mx+df];
      if ~diff(YlimR) YlimR = [mn mn+max(1e-12,mn*1e-12)];  end;
   end;
   if length(Right)==1 yclr = cTRACE(mod(Right-1,ndc)+1,:); else yclr = cXYax; end;
   AXr = axes('unit','nor','fontsi',fontsz,'YAxisLoc','right','ylim',YlimR,...
              'color',cPLTbk,'xcol',cXYax,'ycol',yclr,'xtick',[]);
   if ~axLink LabelYr = ['\div ' LabelYr ' \div']; end;
   ylabel(LabelYr,'color',yclr,'handlev','on','buttond','plt click link;');
   set(Ret1(Right),'par',AXr);
   setappdata(AXr,'Lhandles',Ret1(Right));
   axes(AX);
   set(gcf,'vis','of');
   AXrl = [AX AXr];
else AXrl = AX;  AXr = []; set(AX,'Box','On');
end;
mrk = repmat('+',1,nt);
mrk(Right) = 'o';
ceq = isequal(cCURSOR,CURcDEF);  cEXPbox = [1 1 .51];
if ceq & sum(cPLTbk)>2 cEXPbox=1-cEXPbox; cCURSOR=1-cCURSOR; end;
curclr = [.7 .7 .7; 0 0 0; cEXPbox; cDELTA];
ENAcurS = sum(ENAcur(1:nt));
if ceq & ENAcurS>1 cCURSOR = [0 0 0]; end;
for k=1:nt  set(Ret1(k),'color',cTRACE(mod(k-1,ndc)+1,:));
            if ENAcur(k) curclr=[curclr; cCURSOR]; else  set(Ret1(k),'tag','SkipCur'); end;
end;
if Style  if length(Style(:,1)) < nt Style=Style'; end;
          for k=1:nt
            if length(findstr(Style(k,1),'+o*.xsd^v<>ph'))
                  set(Ret1(k),'linest','none','marker',Style(k,1));
            else  set(Ret1(k),'linest',Style(k,:));  end;
          end;
end;
if Marker if length(Marker(:,1)) < nt Marker=Marker'; end;
          for k=1:nt set(Ret1(k),'marker',Marker(k,:)); end;
end;
for k=1:nt if DIStrace(k) set(Ret1(k),'vis','of'); end; end;

Ret1a = ones(size(Ret1));
axS = [];
p0 = [];
sRat = [1 1];  ofS = [0 0 0 0];
if length(AXISp)
  kAX0 = find(~AXISp(:,1));
  kAX3 = find(AXISp(:,1) == -3);
  kAX  = [kAX0 kAX3];
  if length(kAX) p0 = AXISp(kAX(1),2:5);
                 AXISp(kAX,:) = [];
  end;
end;
if length(p0)
  if length(kAX3)
                  sRat = imag(p0(3:4));  p0 = real(p0);
                  if ~sRat(1) sRat(1) = p0(3); end;
                  if ~sRat(2) sRat(2) = p0(4); end;
                  sRat = sRat ./ posAX(3:4);
                  ofS = [p0(1:2) - sRat .* posAX(1:2) 0 0];
  end;
  posAX = p0; axisPOS = 1;
end;
 
sRat2 = [sRat sRat];  sRat62 = repmat(sRat2,6,1);  ofS61 = repmat(ofS,6,1);
if ~nSP posAX = posAX .* axisPOS;
        CXL = [.1386 .007 .02 .041];  C1X = [.1643 .006 .10 .045];  C2X = [.2686 .006 .10 .045];
        CYL = [.7609 .007 .02 .041];  C1Y = [.7865 .006 .10 .045];  C2Y = [.8908 .006 .10 .045];
        posC{1} = [CXL;CYL;C1X;C2X;C1Y;C2Y] .* sRat62 + ofS61;
else
  yex = .027 - (indep>0)*.01;
  xStart = posAX(1);
  yStart = posAX(2) + yex;
  hSpace = posAX(3);
  vSpace = posAX(4) - yex;
  SPx = xStart + SPx * hSpace;
  dx = posFIG(3);  dx1 = 64/dx;  dx2 = 14/dx;  dx3 = 67/dx;  dx4 = 19/dx;
  dy = posFIG(4);  dy1 = 20/dy;  dy2 = 24/dy;  y1a = .0076;  y2a = y1a + dy2;
  p2 = 0;  
  for j = 1:nC
    p1 = p2+1;  p2=p1+npC(j)-1;
    dy = SPdy(p1:p2);
    h = SubPlot(p1:p2) - (sum(dy) - dw)/npC(j);
    y = cumsum(dy + [0 h(1:end-1)]) - dw;
    ySP{j} = yStart + vSpace*y;
    hSP{j} = h*vSpace;
    if j==1 posAX = [SPx(1) ySP{1}(1) hSpace*SPw(1) hSP{1}(1)]; end;
    x2 = SPx(j);   dx30 = [dx3 0 0 0];  dx40 = [dx4 0 dx1-dx2 0];
    wj = SPw(j)*posFIG(3);
    dxy = dx30;
    if (indep>0) | (length(y)==1 & wj>220)
         x3 = 1.3*dx3;  
         if length(y)==1 & wj>360 dxy = dx30;        x3 = min(4*x3,SPw(j)-x3-dx3);
         else                     dxy = [0 dy2 0 0]; x3 = min(4*x3,max(SPw(j)-x3,x3));
         end;
         C1X = [x2 y1a dx1 dy1];   C1Y = C1X + [x3 0 0 0];
    else C1X = [x2 y2a dx1 dy1];   C1Y = [x2 y1a dx1 dy1];
    end;
    posC{j} = [C1X-dx40; C1Y-dx40; C1X; C1X+dxy; C1Y; C1Y+dxy] .* sRat62 + ofS61;;
    
    for k=p1:p2
      if k==p1 & j==1 continue; end;
      l = nt+k-nSP;  Ret1a(l) = 0;
      l = Ret1(l);
      if isempty(SubTrace) c = get(l,'color'); else c = cXYax; end;
      a = axes('ycol',c,'xcol',c);
      setappdata(a,'Lhandles',l);
      if length(SubTrace) setappdata(a,'subTr',1); end;
      set(l,'par',a);
      if indep>0 x = get(l,'x');  x = [x(:); 0; 0;]; x = x([1 end]);
                 if diff(x)>0 set(a,'xlim',x); end;
      end;
      if length(LabelY)>=k ylabel(LabelY{k}); end;
      if k==p1 & j>1 if length(LabelX)>=j xlabel(LabelX{j}); else xlabel('X axis'); end; end;
      axS = [axS a];
    end;
  end;
end;

set(AXrl,'pos',posAX,'Xscale',Xscale,'Yscale',Yscale);
if ischar(Ylim)
   Ylim = get(AX,'ylim');
end;
Ret1a = Ret1(logical(Ret1a));
setappdata(AX,'Lhandles',Ret1a);
axData = [AX axS AXr];
AppLh = Ret1;
AppAx = axData;
if exFig
  AppLh = [getappdata(FIG,'Lhandles'); AppLh];
  AppAx = [getappdata(FIG,'axis') AppAx];
end;
setappdata(FIG,'Lhandles',AppLh); 
setappdata(FIG,'axis',AppAx);

pb = [posPEAK;posVALY;posM;posDEL];
if Xslide
   posBox(2) = posBox(2) + .028;  pb(:,2) = pb(:,2) + .028;  pb = [pb; posSLDR];
end;
pbr = size(pb,1);  pb = pb .* repmat(sRat2,pbr,1) + repmat(ofS,pbr,1);
CurID = plt('cursor',AXrl,'init',[posC{1};pb],curclr,'', mrk, 0.8*fontsz,'','on',[],axisCB);
set(findobj(gcf,'style','push','str','D'),'user',cDEFAULT,'tag',cFileS);
CurIDstr  = {@plt 'cursor' CurID};
if indep CurIDstr0 = {@plt 'cursor' 0}; else CurIDstr0 = CurIDstr; end;
set(AXrl,'user',CurID);
Left = setdiff(1:nt-nSPm,Right);
nLeft = length(Left);
if (length(AXr) | nSP) & nLeft==1
  yclr = cTRACE(mod(Left-1,ndc)+1,:); leftclr=yclr;
else yclr = cXYax;  leftclr = cXYlbl;
end;
set(AX,'xcol',cXYax,'ycol',yclr);
xlimm = Xlim{1};
if ischar(xlimm)
  if nLeft xlimm = get(AX,'xlim'); else xlimm = get(AXr,'xlim'); end;
end;
[prefix xmult] = plt('metricp',max(abs((xlimm))));
if ENApre(1) & xmult~=1
  for k=1:nt set(Ret1(k),'x',xmult*get(Ret1(k),'x')); end;
  LabelX{1} = [prefix LabelX{1}];
else xmult = 1;
end;
set(AXrl,'xlim',xlimm*xmult);
[prefix mult] = plt('metricp',max(abs((Ylim))));
ymult = ones(1,nt);
if ENApre(2) & mult~=1
  for k=1:nLeft
     kk = Ret1(Left(k));
     set(kk,'y',mult*get(kk,'y'));
     ymult(Left(k)) = mult;
  end;
  LabelY{1} = [prefix LabelY{1}];
else mult = 1;
end;
set(AX,'ylim',Ylim*mult);
setappdata(FIG,'xymult',[xmult ymult]);
xlabel(LabelX{1},'color',cXYlbl,'handlev','on');
hYlab = ylabel(LabelY{1},'color',leftclr,'handlev','on');
plt('cursor',CurID,'moveCB2',[CurIDstr {'MVcur'}]);
if ~cGRIDs & sum(cPLTbk)>1.5 & (~MverE | isempty(AXr)) cGRID = 1-cGRID; end;
plt('grid',AX,'init',cGRID,GridEr,GridSty);
if Grid(2)=='f' plt('grid',AX,'off'); end;
axes('pos',posC{1}(2,:)+[0 0 .2 0],'vis','of');
text(-.02,.45,'','fontsi',fontsz,'horiz','right','buttond','plt click RMS;','user',AX);
if length(Xstring)
  if ischar(Xstring) & Xstring(1) == '?'
        Xstring(1)=[];
        a = uicontrol('sty','edit','unit','nor','pos',posC{1}(4,:).*[1 1 1.7 1],'horiz','cent',...
                 'backg',[.2 .2 .2],'foreg',[1 1 .3]);
  else  a = text(-2.22,.45,'','color',cXYlbl);
  end;
  set(a,'fontsi',fontsz,'tag','xstr');
  setappdata(a,'evl',Xstring);
  setappdata(AX,'xstr',a);
  uistack(a,'bottom');
end;
if length(Ystring)
  if ischar(Ystring) & Ystring(1) == '?'
        Ystring(1)=[];
        a = uicontrol('sty','edit','unit','nor','pos',posC{1}(6,:),'horiz','cent',...
                 'backg',[.2 .2 .2],'foreg',[1 1 .3]);
  else  a = text(.6,.45,'','color',cXYlbl);
  end;
  set(a,'fontsi',fontsz,'tag','ystr');
  setappdata(a,'evl',Ystring);
  setappdata(AX,'ystr',a);
  uistack(a,'bottom');
end;
nMenu = sum(MenuBox);
aid = -1;
ahi = .035*nMenu;
if nID>1 & TRACEid
  h = 19*ntid;
  ahip = ahi * 525;
  hr = 440 / (h+ahip);
  if hr<1 ahi = ahi*hr;  h = h*hr;  end;
  aidp = sRat2 .* idPOS.*[3 521-h 50 h]./[700 525 700 525] + ofS;
  aid = axes('xlim',[0 ncol],'ylim',[-ntid 0]-.5,'color',cTID,'xcol',cPLTbk,'ycol',cPLTbk,'XtickLabel',' ','YtickLabel',' ','TickLen',[0 0]','user','TraceID',...
        'unit','nor','pos',aidp,'buttond','plt misc tidmv;');
  setappdata(aid,'TIDcback',TIDcback);
  setappdata(aid,'ty',' xy');
  setappdata(aid,'cid',CurID);
  cRid = cPLTbk + .16*(2*(cPLTbk<.5)-1);
  row = 1;  col = 1;
  bln = 0;
  lpl = {'color'; 'marker'; 'linest'; 'linewidth'};
  [tn tw] = size(TRACEid);
  if nID>tn TRACEid = [TRACEid; repmat(' ',nID-tn,tw)]; end;
  enap = 1;
  wmax = 0;
  Cpch = cFIGbk;  if max(Cpch)>.24 Cpch = Cpch*.9; else Cpch = Cpch*1.1; end;
  pch = [];
  for k=1:nID
    s = TRACEid(k,:);
    wmax = max(wmax,length(s));
    if all(s==' ') bln=bln+1; continue; end;
    if s(1)==']' s = s(2:end); enap = 0; end;
    isR = length(find(k==Right));
    if isR & enap cR=cRid; line(col-[1 .05],[0 0]-row,'color',cR,'LineWidth',9);
    else          cR=cPLTbk;
    end;
    d = text(col-.93,-row,s);
    if npch(k)
      pch = [pch patch([col-1 col col col-1],.5-row-[0 0 1 1],Cpch,'edgec',Cpch,'user',{k Ret1(k) d})];
      set(d,'vis','of');
    end;
    ms = {@plt 'click' [Ret1(k) d]};
    set(d,'fontsi',fontsz,'fontw','bol','color',cTRACE(mod(k-1,ndc)+1,:),'buttond',ms);
    setappdata(d,'ty','-');
    if TRACEmk
      mk = line(TRACEmk+col-1,TRACEmk*0-row,lpl,get(Ret1(k),lpl),'buttond',ms);
      setappdata(d,'mk',mk);
      if TRACEmk(1)<.25 set(d,'color',cR); end;
    else mk = [];
    end;
    if DIStrace(k) set(d,'fonta','ita','fontw','nor'); set(mk,lpl,{[0 .3 .3] 'none' '-' 9}); end;
    row = row+1;
    if row>TIDcolumn(col) col=col+1; row=1; end;
  end;
  if length(pch) setappdata(gcf,'pch',pch); end;
  if bln & ncol==1
     dy = aidp(4) * (1 - (nID-bln)/nID);
     aidp = aidp + [0 dy 0 -dy];
     set(aid,'ylim',[bln-nID 0]-.5,'pos',aidp);
  end;
  if wmax>6 & ncol==1
    if aidp(3)*posFIG(3) < 55
       aidp(3) = aidp(3)*1.13; set(aid,'pos',aidp);
    end;
  end;
end;
if nMenu
  posBox(4) = ahi;
  if exFig cFIGbk = get(gcf,'color'); end;  c = .2*cXYax + .8*cFIGbk;
  cb = sum(cXYlbl)<1.5;  cb = .75*cFIGbk + .25*[cb cb cb];
  ambv = .55;  if MverE ambv = .45; end;
  posBox = posBox .* sRat2 + ofS;
  pixLW = posBox([1 3])*posFIG(3);  pixE = 40 - pixLW(2);
  if pixE>0 pixLW = pixLW + [-pixE pixE];
            pixLW = pixLW + [max(5-pixLW(1),0) 0];
            posBox([1 3]) = pixLW/posFIG(3);
  end;
  amb = axes('unit','nor','pos',posBox,'ylim',[-nMenu 0]-ambv,'Box','On','XaxisLoc','top',...
           'color',cb,'xcol',c,'ycol',c,'XtickLabel',' ','YtickLabel',' ','TickLen',[0 0]','tag','MenuBox','buttond','plt misc tidmv;');
  setappdata(amb,'cid',CurID);
  b=0;  t=[];
  zout = [CurIDstr0 {'ZoomOut'}];  mark = [CurIDstr0 {'mark'}];
  logx = [CurIDstr0 {'TGLlogx'}];  logy = [CurIDstr0 {'TGLlogy'}];
  rot  = [CurIDstr0 {'scale' 'old'}];
  txx = { 'Help',    Xsc,  Ysc,  'Grid',    'Print',   'Menu',    'Mark', 'Zout', 'XY\leftrightarrow'};
  btn = { 'plt help 1;'; logx; logy; 'plt click TGLgrid;'; 'plt(''hcpy'',''init'',gcf);'; 'plt click TGLmenu;';  mark;   zout;   rot };
  for k=1:length(MenuBox)
    if MenuBox(k)
       b=b-1;  te = text(.5,b,txx{k},'interp','tex');
       t = [t te];  set(te,'buttond',btn{k});  setappdata(te,'ty','-');
       if k==1 set(te,'user',HelpFile,'tag',HelpFileR); end;
    end;
  end;
  set(t,'fontsi',fontsz,'color',cXYlbl,'horiz','cent');
else amb = [];
end;
if posFIG(1)<0 posFIG = abs(posFIG);
else for k=flipud(findobj('type','fig'))'
      if get(k,'pos')==posFIG  posFIG = posFIG + [30 25 0 0]; end;
     end;
end;
set(FIG,'tag',sprintf('%d',FIGt),'CloseReq','plt misc close;');
if exFig
     Mbar = length(get(FIG,'menu')) ~= 4;
     if Mbar
       plt('click','TGLmenu');
     end;      
else set(FIG,'pos',posFIG,'Name',FigName,'color',cFIGbk); end;
setappdata(FIG,'ucreq',ucreq);
if Mbar plt('click','TGLmenu'); end;
set(AX,aLp,aLv);
set(get(AX,'ylab'),lLp,lLv);
set(get(AX,'xlab'),lXp,lXv);
set(get(AX,'title'),TIp,TIv);
if length(AXr) set(AXr,aRp,aRv);
       set(get(AXr,'ylab'),lRp,lRv);
end;
v = 'off';
for k=1:nLeft
  if strcmp(get(Ret1(Left(k)),'vis'),'on') v = 'on'; break; end;
end;
set(hYlab,'vis',v,'ui',uicontextmenu('call','plt hideCur;'));
leftC = cPLTbk;
CurMain = getappdata(0,'CurMain');
Hc = get(CurMain(CurID),'user');
if length(AXr)
  ls = Ret1(Right)';
  icr = 15+Right;  icg = find(icr>length(Hc));
  if length(icg)
    if length(SubTrace) icr(icg) = [];
    else disp('Error: Subplot data must follow all main plot data in the argument list'); return;
    end;
  end;
  set(Hc(icr),'par',AXr,ERAS,ERAXOR);
  v = 'off'; gridXOR = cPLTbk;
  for k=1:length(ls)
    if strcmp(get(ls(k),'vis'),'on')
       v = 'on';
       leftC = 'none';
       gridXOR = get(gcf,'color');
       break;
    end;
  end;
  set(AXr,'vis',v);
  if GridEr(1)=='x'
    set(findobj(AX,'user','grid'),'color',bitxor(round(255*cGRID),round(255*gridXOR))/255);
  end;
end;
plt('cursor',CurID,'MVcur');
if length(moveCB) plt('cursor',CurID,'moveCB',moveCB); end;
set(AX,'color',leftC);
cidS = CurID;
cidB = CurID;
if nSP
  if ishandle(aid) & all(idPOS([1 2 4]) == [1 1 1])
    set(aid,'unit','nor');
    ysp1 = ySP{1};
    if length(ysp1)>1
      p = get(aid,'pos');
      p(2) = ysp1(2)-p(4)-.025;
      if nMenu & (p(2) < sum(posBox([2 4]))+.015)
         p(2) = posBox(2) + .025;  posBox(2) = p(2) + p(4) + .02;
         set(amb,'pos',posBox);
      end;
      set(aid,'pos',p);
    end;
  end;
  h = plt('cursor',CurID,'obj');
  q = [-1 .1 .1 .1];  u = [q;q;q;q];
  py1 = get(h(5),'pos');   p1 = [u;py1;u;q];
  p = {'pos'  'color' 'Xscale' 'FontSize' 'TickLength' 'Box' 'xlim'};
  if indep>0 p(end) = []; end;
  v = get(AX,p);
  if ischar(v{2}) v{2} = get(AXr,'color'); end;

  ak = 1;
  for j = 1:nC
    r = [posC{j}; u];
    v{1}([1 3]) = [SPx(j) hSpace*SPw(j)];
    if j>1 & indep<0
      if length(Xlim)>=j xlimm = Xlim{j}; else xlimm = 'default'; end;
      if ischar(xlimm) x = get(findobj(axS(ak),'type','line'),'x');
                       xlimm = [min(x) max(x)];
      end;
      v{end} = xlimm;
    end;
    npj = npC(j);
    for k = 1:npj
      if j+k > 2
        v{1}([2 4]) = [ySP{j}(k) hSP{j}(k)];
        axk = axS(ak);  set(axk,p,v);
        cidN = plt('cursor',axk,'init',r,'','','+',8);
        set(axk,'user',cidN);   cidS = [cidS cidN];
        if indep<0
          CurMain = getappdata(0,'CurMain');  Hd = get(CurMain(cidN),'user');
          set(Hd(6),'buttond','plt click EDIT 2;');
          if k==1  cidB = [cidB cidN];
                   set(Hd(4),'buttond','plt click EDIT 1;');
          else     set(axk,'XtickLabel',[]);
          end;
        end;
        ak = ak+1;
      end;
      r(5,1) = r(5,1) + dx3 * (indep<0);
      if k==1 r([1 2 4 6],:) = u;
              if indep<0 r(3,:) = q; end;
      end;
      if indep>0 & npj>1
        if j+k>2 ci=cidN; else ci=CurID; end;
        plt('cursor',ci,'moveCB2',sprintf('plt("misc","icur",%d);',ci));
      end;
    end;
    uistack(Hc(5),'top'); uistack(Hc(7),'top');
  end;
  s = 'plt("cursor",';
  cidSS = {[s int2str(cidS(1))]};
  for k=2:nSP
    SS = [s int2str(cidS(k))];
    cidSS = [cidSS {SS}];
    plt('grid',axData(k),'init',cGRID,GridEr,GridSty);
    if Grid(2)=='f' plt('grid',axData(k),'off'); end;
  end;
  n = length(SubTrace);   m = length(Ret1);  a = length(axData);
  if n == a
    h = 1;
    for k = 1:n
       h2 = h + SubTrace(k) - 1;
       if h2 > m break; end;
       set(Ret1(h:h2),'parent',axData(k));
       h = h2 + 1;
    end;
  elseif n == m
    for k=1:n
      if SubTrace(k) <= a  set(Ret1(k),'parent',axData(SubTrace(k))); end;
    end;
  end;

  set(findobj(FIG,'buttond','plt click RMS;'),'vis','of');
  if indep<0
    setappdata(FIG,'c',0);
    s1a = 'if getappdata(gcf,"c")==%d setappdata(gcf,"c",0); else setappdata(gcf,"c",getappdata(gcf,"c")+1);';
    s2 = ',"update",plt2nd({"cursor",%d,"get"})); end';
    s3 = ',"xlim",get(gca,"xlim")); end';
    p2 = 0;  
    for j = 1:nC
      p1 = p2+1;  p2=p1+npC(j)-1;
      s1 = sprintf(s1a,npC(j));
      for k = p1:p2
        if k==p2 m=p1; else m=k+1; end;
        CI = cidS(k);
        plt('cursor',CI,'moveCB2',[s1 cidSS{m} sprintf(s2,CI)]);
        plt('cursor',CI,'axisCB',[s1 cidSS{m} s3]);
      end;
    end;
  end;
end;

AppC = cidS;  if exFig  AppC = [getappdata(FIG,'cid') AppC]; end;
setappdata(FIG,'cid',AppC);
if Grid(2)=='n' plt('grid',AX); end;
axes(AX);
set(gcf,'vis','of');

setappdata(FIG,'epopup',plt('pop','choices', ...
{'Properties';           'multiCursor';             'xView slider';  ...
     'Cancel';                                                       ...
      'Range';  'Range\leftrightarrow';  'Range\uparrow\downarrow';  ...
     'Insert'; 'Insert\leftrightarrow'; 'Insert\uparrow\downarrow';  ...
     'Modify'; 'Modify\leftrightarrow'; 'Modify\uparrow\downarrow'}, ...
    'interp','tex','visible','off','callbk','plt click Yedit;'));

setappdata(FIG,'Dedit',{cidS(1) 9 -1 43 8 .5 0 -1 1});
setappdata(FIG,'NewData',0);
setappdata(FIG,'EditCur',(196-get(0,'screenpix'))/10);
setappdata(FIG,'logTR',1e6);
setappdata(FIG,'snap',[100 100]);
uic = findobj(FIG,'type','uicontrol')';
txt = findobj(FIG,'type','text')';
for k = [uic axData amb txt] setappdata(k,'ty',' xy'); end;
setappdata(FIG,'uic',uic);
setappdata(FIG,'txt',txt);
setappdata(FIG,'axi',getappdata(FIG,'axis'));

txtp = [];  np = 0;
if length(AXISp)
  for k = 1:length(AXISp(:,1))
    p = AXISp(k,:);  m = p(1);  p = p(2:5);
    switch m
      case -2,   if nMenu set(amb,'pos',p); end;
      case -1,   if ishandle(aid) set(aid,'pos',p); end;
      otherwise, if     m<=length(axData)          set(axData(m),'pos',p);
                 elseif m>201 & m-200<=length(uic) set(uic(m-200),'pos',p);
                 elseif m>300 & m-300<=length(txt) np=np+1; txtp{np} = [m-300 p(1:2)];
                 end;
    end;
  end;
end;

if LineSmooth & Mver>=7 & exist('isprop') & isprop(Ret1(1),'LineSmoothing')
  a = get(Ret1(1),'LineSmoothing');
  if a(2)=='f' set(Ret1,'LineSmoothing','on'); end;
end;
set(findobj(gcf,'str','O'),'user',LineSmooth);
plt('misc','tidtop');
if indep>0 ci=cidS; else ci=cidB; end;
for k=ci plt('cursor',k,'update',-1); end;
if NoCursor setappdata(gcf,'hidecur',[]);
            plt('hideCur');
end;
if xViewOpt     plt('click','Yedit',3); end;
if multiCurOpt  plt('click','Yedit',2); end;
plt('helptext','on');
if FigShow set(FIG,'vis','on'); drawnow;
else       set(gcf,'vis','of');
end;
for k=1:np p=txtp{k}; set(txt(p(1)),'unit','nor','pos',p(2:3)); end;

function r2 = plt2nd(v)
  [r1 r2] = plt(v{:});

function s = stripp(c)
  k = findstr(c,filesep);
  if length(k) s = c(k(end)+1:end-2); else s = c; end;

function c = ctrip(v)
  [s1 s2] = size(v);
  if s1>1 c = [];
          for k = 1:s1  c = [c; ctrip(v(k,:))]; end;
          return;
  end;
  if s2==3
       if max(v)>1 c = v/100; else c = v; end;
  else v1 = floor(v/10000);  v = v - 10000*v1;
       v2 = floor(v/100);    v = round(v - 100*v2);
       c = [v1 v2 v];
       c(find(c==1))=100;
       c = c/100;
  end;
