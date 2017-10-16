% pltn.m -------------------------------------------------------------------------
%
% Similar to plt5 and plt50, except that this is a function instead of a script.
% - Demonstrates that plt can be used to plot un unlimited number of
%   traces (although trace IDs can't be used with more than 99 traces)
% - pltn(1) will plot a single trace.
% - pltn(99) or pltn with no argument will plot 99 traces. If you
%   specify more traces than this, the trace IDs are not displayed (since
%   there will not be room for them). "pltn" with no arguments does
%   the same thing as pltn(99).
% - You can change the number of traces ploted even after pltn is already
%   running by entering a new number in the "# of lines" edit box
%   (under the TraceID box).
%   Try entering "1000" into this edit box just to proove that it actually works!
%   Going much beyond 1000 traces is a good performance test, since on slower
%   computers you will start to notice some significant lag on pan operations.
% - The TIDcolumn parameter is used to divide the trace IDs into 2 or 3
%   columns if necessary. (Putting all 99 IDs in one column isn't practical.)
% - TraceIDs are disabled when more than 99 traces are specified. (Otherwise
%   plt would give an error message.)
% - The 'Ystring' parameter creates a continuous readout of the cursor index.
% - The 'Xstring' parameter creates a continuous readout of the date
%   and time corresponding to the cursor X position. The edit box form is used
%   (the question mark character at the beginning of the string).
% - A popup menu (pseudo object) is created below the x-axis label which allows
%   you to adjust the line thickness. Notice that you can right click on the
%   popup to increment the line thickness (which sometimes is more convenient
%   than opening the popup menu).
% - A callback is written for the Xstring edit box that moves the cursor to
%   the index with a corresponding time as close as possible to the entered
%   value. For example, try this:
%     1) Click on the top trace (makes it easy to see the cursor).
%     2) Enter dates into the edit box - e.g. "30 dec 2006", "3-jan-07 9:59", etc.
%     3) Verify that the cursor moves to the corresponding point

% ----- Author: ----- Paul Mennen
% ----- Email:  ----- paul@mennen.org

function pltn(Nlines)
  if ~nargin Nlines = 99; end;  % plot 99 lines if Nlines not specified
  timeRef = '28-Dec-06 15:38:59'; % test start time
  t  = (0:399)/400;  u = 1-t;
  y1 = 8.6 - 1.4*exp(-6*t).*sin(70*t);
  y2 = repmat([1 0 1 0 1 0]+6.4,100,1); y2 = y2(:)';
  f = (0:.15:25)-12.5; f = sin(f)./f;
  y2 = filter(f,sum(f),y2); y2(1:200) = [];
  y3 = 2 * t .* cos(15*u.^3) + 5;
  y4 = 4 - 2*exp(-1.4*t).*sin(30*t.^5);
  y5 = u .* sin(20*u.^3) + 2.2;
  w = ones(ceil(Nlines/5),1);  wi = flipud(cumsum(w))-1;
  s = 5.3*(t-.5);  v = wi * (sqrt(16-s.*s)-3)/8;
  y = [y1(w,:)+v; y2(w,:)+v; y3(w,:)+v; y4(w,:)+v; y5(w,:)+v];
  y = y(1:Nlines,:); t = 234.5678 * (t+.08);
  if Nlines>99 TraceID = [];
  else         TraceID = prin('{ID%02d!row}',1:Nlines);
  end;
 S.tr = plt(t,y,'Xlim',t([1 end]),'TraceID',TraceID,'TIDcolumn','',...
    'LabelX',[' hours past ' timeRef],'Pos',[870 700],'Options','LI',...
    'Linewidth',2,'Xstring','?plt("datestr",@XU+@XVAL/24)',...
    'Ystring','sprintf("Sample  # %d",@IDX)','xy',[-2 .01 .09 .05 .16],...
    'Ylim',[min(y(end,:)) max(y(1,:))] + [-.1 .1],'FigBKc',001515);
  S.ref = datenum(timeRef);
  set(findobj(gcf,'tag','xstr'),'User',S.ref,'Callback',{@xstrCB,S});
  plt cursor;        % update xstring
  u1 = uicontrol('style','text','pos',[ 5 183 41 27],'str','# of lines:'); % edit box label
  u2 = uicontrol('style','edit','pos',[51 187 33 20],'str',prin('%d',Nlines),... % edit box
      'callback','a=str2num(get(gcbo,''str'')); close(gcf); pltn(a);');
  set([u1 u2],'units','norm','backgr',[.6 .6 1],'foregr','black','fontw','bold');
  plt('pop',[-.62 .02 .1 .2],1:8,'index',2,'Fontsize',12,... % Linewidth popup
      'label',{'Linewidth:','','Color',[0 .6 1],'Fontsize',12,'Fontweight','bold'},...
      'callbk','set(getappdata(gcf,"Lhandles"),"LineWidth",@IDX);');
% end function pltn

function xstrCB(h,arg2,S)  % xstring edit box callback
  dt = datenum(get(h,'string')) - S.ref;
  [mn k] = min(abs(get(S.tr(1),'x')-dt*24)); % k = index minimizing time error
  plt('cursor',-1,'update',k);               % move cursor to the desired spot
%end function xstrCB