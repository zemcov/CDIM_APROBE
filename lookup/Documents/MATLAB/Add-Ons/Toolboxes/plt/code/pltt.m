function H = pltt(x,y,ID)      % Add trace (x,y) to the plt object in the current figure.
                               % Name the new trace ID (if ID is included).

  if nargin>1 & iscell(y)      % add multiple traces with y = cell array
    ky = length(y);
    if ~iscell(x) x = {x}; end;  kx = length(x);
    if nargin<3 ID = 0; end;
    if ~iscell(ID) ID = {ID}; end;
    ki = length(ID);
    for k = 1:ky  pltt(x{min(k,kx)},y{k},ID{min(k,ki)}); end;
    return;
  end;

  sy = size(y);
  if nargin>1 & min(sy)>1     % add multiple traces with y = matrix
    sx = size(x);
    if min(sx)~=1 disp('pltt error: x must be a row or column vector'); return; end;
    rc = find(sy==max(sx));
    if isempty(rc) disp('pltt error: rows or columns of y must be the same size as x'); return; end;
    if nargin<3 ID = 0; end;
    if ~iscell(ID) ID = {ID}; end;
    ki = length(ID);
    if rc==1 for k = 1:sy(2) pltt(x,y(:,k),ID{min(k,ki)}); end;  % plot columns of y
    else     for k = 1:sy(1) pltt(x,y(k,:),ID{min(k,ki)}); end;  % plot rows of y
    end;
    return;
  end;

  pch = getappdata(gcf,'pch');
  if isempty(pch)
    if isempty(pch) disp('pltt: No slots are available'); return; end;
  end;
  p = pch(1);  pch(1) = [];        % use the first available slot
  switch nargin
    case 0, disp('Usage: H = pltt(x,y,ID);'); return;
    case 1, ID=0;  if isreal(x)         y = x;        x = 1:length(y);
                   else                 y = imag(x);  x = real(x);
                   end;
    case 2, if ischar(y)  ID = y;
                          if isreal(x)  y = x;        x = 1:length(y);
                          else          y = imag(x);  x = real(x);
                          end;
            else          ID = 0;
            end;
  end;
  u = get(p,'user');
  ymult = getappdata(gcf,'xymult');        % get metric prefix factors
  x = x*ymult(1);  y = y*ymult(u{1});
  H = u{2};  set(H,'x',x,'y',y);  ud = 0;
  ax = get(H,'parent');
  xl = get(ax,'xlim');  xg = get(ax,'xscale');  xg = xg(3)=='g'; % xg true for logx
  yl = get(ax,'ylim');  yg = get(ax,'yscale');  yg = yg(3)=='g'; % yg true for logy
  x1 = min(x);  x2 = max(x);  dx = (x2-x1)/30;  x1 = x1-dx;  x2 = x2+dx;
  y1 = min(y);  y2 = max(y);  dy = (y2-y1)/30;  y1 = y1-dy;  y2 = y2+dy;
  if x1 < xl(1)  if ~xg | x1>=0 xl(1)=x1;  ud=1;  end;  end;
  if x2 > xl(2)                 xl(2)=x2;  ud=1;        end;
  if y1 < yl(1)  if ~yg | y1>=0 yl(1)=y1;  ud=1;  end;  end;
  if y2 > yl(2)                 yl(2)=y2;  ud=1;        end;
  if ud plt('cursor',get(ax,'user'),'set','xylim',[xl yl]); end;
  if ischar(ID),set(u{3},'string',ID); end;
  set(u{3},'vis','on');
  if length(pch) delete(p); setappdata(gcf,'pch',pch);
  else           set(p,'vis','off');       % don't delete the last patch
  end;
% end function pltt
