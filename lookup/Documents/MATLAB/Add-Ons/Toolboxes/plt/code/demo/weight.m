% weight.m ----------------------------------------------------------
%
% - The SubPlot argument is used to create three axes. The lower axis
%   contains four traces showing the magnitude in dB (decibels) of
%   four different weighting functions used in sound level meters
%   (as defined by IEC 651). The middle axis shows the same 4 traces except
%   using linear units instead of dB as used for the lower axis. The top
%   axis shows the inverse of the linear magnitude traces, which isn't
%   particularly useful except that I wanted to demonstrate plotting three
%   axes in a single figure.
% - Normally plt only puts one trace on each subplot except for the
%   main (lower) axis. So in this case (with 12 traces) plt puts 10
%   traces on the lower axis and one on the other two. Since we really
%   want 4 and 4 and 4, the 'SubTrace' parameter is used to specify
%   exactly which traces should be on each axis. However the plt cursoring
%   functions have not been designed to handle the 'SubTrace' parameter
%   so weight.m will have to contain some of its own cursor code.
% - When using the SubTrace parameter the native plt cursor objects will
%   not behave consistently, so normally the cursors will be disabled.
%   Alternatively the program can modify the cursor behavior to make it
%   consistent with the particular SubTrace settings - and this is the
%   approach used in this example. The 'moveCB' cursor callback runs the
%   curCB function which keeps the cursors on all three axes synchronized
%   so that the cursors in the upper two axes automatically move to the
%   same trace and the same x position of the cursor in the main (lower) plot.
% - The traceID callback ('TIDcback') insures that the traceID box
%   controls the visibility of the traces in all three axes.
% - Note the LineWidth argument in the plt call. This illustrates how
%   any line property may be included in the calling sequence.
% - The Ctrace argument is used to change plt's default trace color order.
%   Note that the color triples may be specified using matlab's
%   traditional method (0 to 1) or using percent (0 to 100) or by
%   combining the 3 numbers into a single decimal value (rrggbb).

% ----- Author: ----- Paul Mennen
% ----- Email:  ----- paul@mennen.org

function weight()
  f = 1000*10.^(-2 : 2/63 : 1.33);   g = f.^2;               % x axis for plot
  Wc = g ./ ((g + 20.6^2) .* (g + 12200^2));                 % C weight
  Wb = Wc .* sqrt(g ./ (g + 158.5^2));                       % B weight
  Wa = Wc .* g ./ sqrt((g + 107.7^2) .* (g + 737.9^2));      % A weight
  Wd = f .* sqrt( ((1037918.48-g).^2 + 1080768.16*g) ./ ...  % D weight
        (((9837328-g).^2 + 11723776*g) .* (g+79919.29) .* (g+1345600)));
  [m ref] = min(abs(f-1000));             % use 1000 Hz as the reference frequency
  W = [Wa/Wa(ref); Wb/Wb(ref); Wc/Wc(ref); Wd/Wd(ref)]; % normalize to reference
  ctrace = [0 .9 0; 1 0 1; 0 1 1; 1 1 0]; % color for A/B/C/D weighting respectively
  ctrace = [0 90 0; 1 0 1; 0 1 1; 1 1 0]; % equivalent to above
  ctrace = [9000; 10001; 101; 10100];     % also equivalent to above
  S.lh = plt(f,[20*log10(W); W; 1./W],'FigName','A B C & D Weighting','EnaPre',[0 0],...
       'LineWidth',{2 2 2 2 1 1 1 1 1 1 1 1},'TIDcback',@tidCB,'SubPlot',[55 30 15],...
       'Xlim',f([1 end]),'Ylim',[-55 15],'FigBKc',152525,'PltBKc',060000,...
       'SubTrace',[4 4 4],'TRACEid',prin('{%Xweight!row}',10:13),...
       'Options','Xlog -Y I','LabelX','Hz','LabelY',{'Magnitude (dB)' 'Magnitude' '1/Mag'},...
       'Ctrace',ctrace,'Pos',[0 0 820 600]);
  S.ax = getappdata(gcf,'axis'); set(gcf,'user',S); % save for traceID callback
  plt('cursor',-2,'ylim',[-.06 1.4]);               % set y limits (Magnitude)
  plt('cursor',-3,'ylim',[0 4]);                    % set y limits (1/Magnitude)
  b = {'buttond'};                                  % copy buttondown functions
  set(S.lh(5:12),b,repmat(get(S.lh(1:4),b),2,1));   % Three axes, each with 4 lines
  plt('cursor',-1,'moveCB',@curCB);  curCB;         % set cursor callback & update

function curCB() % cursor callback (moveCB)
   S = get(gcf,'user');
   [n h]  = plt('cursor',-1,'getActive');
   [xy k] = plt('cursor',-1,'get');
   x = real(xy);             n = min(4,n);
   y2 = get(S.lh(n+4),'y');  y2 = y2(k);
   y3 = get(S.lh(n+8),'y');  y3 = y3(k);
   c = get(h,'color');   e = findobj(gcf,'style','edit');
   set(e([8 4]),'Backgr',c,{'string'},prin('1/%5w ~; %4.2fdB',y2,y3));
   for ax = S.ax(2:3)                              % fixup the cursor for upper two axes
     mkr = findobj(ax,'markersize',8);             % find the subplot's cursor
     set(mkr,'x',x,'y',y2,'color',c,'vis','on');   % update cursor position and color
     yl = get(ax,'ylim');  yd = diff(yl)*[-.9 .1]; % adjust ylim if cursor out of range
     if     y2>yl(2) set(ax,'ylim',y2+yd);          plt('grid',ax);
     elseif y2<yl(1) set(ax,'ylim',y2-fliplr(yd));  plt('grid',ax);
     end;
     y2 = y3;
   end;
%end function curCB

function tidCB()    % traceID callback
  S = get(gcf,'user');  a = {'vis'};
  set(S.lh(5:12),a,repmat(get(S.lh(1:4),a),2,1));
% end function tidCB
