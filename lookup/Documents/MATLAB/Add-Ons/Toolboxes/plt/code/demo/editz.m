% editz.m - A primitive filter design program.
%
% This function demonstrates the usefulness of plt's data editing
% capability. Two plots are created, the lower one showing the poles and
% zeros of a z-plane transfer function and the upper one other showing
% the magnitude and phase of it's frequency response. The frequency
% response plot automatically updates even while you are dragging a root
% to a new location. At first the updating in real time (i.e. while you
% are dragging) may not seem so important, but when you use the program
% its becomes clear that this allows you to gain a feel for how the root
% locations effect the frequency response reacts.  This real time motion
% is accomplished by using the 'MotionEdit' parameter (see line 131).
%
% In addition to demonstrating various plt features, my other goal for this
% little application was to create a tool to help engineering students
% develop a feel for how the magnitude & phase response reacts to a change
% in the positions of the transfer function poles & zeros. This application
% won't make much sense until you have learned to think in the z-plane.
% If you haven't yet learned this, I highly recommend "Sitler's notes"
% - a paper on the subject which is just about as old as the subject itself,
% yet I believe nothing else quite as good has been written since.
% This paper was never officially published, but the good news is you can
% find it on my web site (www.mennen.org) in the section titled
% "Signal processing papers".
%
% When the program first starts, text appears in the pole/zero plot that
% tells you how you can use the mouse to move the transfer function roots.
% You may miss these important instructions since the help text is removed
% in the cursor callback function (to reduce clutter). However you can
% re-enable the help text at any time by clicking on the yellow "editz help"
% tag which is centered near the left edge of the figure window. (Note that
% right clicking on the Help tag in the menu box has the same effect.)
%
% In the frequency plot, the x-cursor edit box shows the cursor location
% as a fraction of the sample rate. The Xstring parameter is used to show
% this as an angular measure (in degrees) just to the right of the x-cursor
% readout. Since the DualCur parameter is used, there are two y-cursor edit
% boxes. The first one (green) shows the magnitude response in dB and the
% second one (purple) shows the phase response in degrees. The Ystring
% parameter is used to show the magnitude response in linear form (in
% percent). Note that after the plot command, the Ystring is moved to the
% left of the plot because by default the Ystring appears in the same place
% as the dual cursor readout. The alternate location allows room for a
% multi-line Ystring which is generated using prin's cell array output
% feature. The AxisLink parameter is used so that by default the mag/phase
% axes are controlled separately.
%
% In the pole/zero plot, the x and y-cursor edit boxes show the pole/zero
% locations in Cartesian form. The Xstring parameter shows the polar form
% just to the right of the x-cursor readout.
%
% Normally plt's data editing is initiated when you right click on either
% the x or the y cursor readouts. However when data editing is being used
% extensively (as in this program) it is useful to provide an easier way to
% enter editing mode. In this program, this is done with the patch object
% that appears just below the traceID box. (The patch object is created on
% line 146 of this file). The 'Dedit' application data variable is used
% (see lines 137 to 139) to change the default editing mode from the usual
% default (change only the y coordinate) to the alternative (allow changing
% both the x and y coordinates. Also the application data variable
% 'EditCur' (see line 140) is used to change the default size of the
% cursors used for editing.
%
% Notice that while dragging a pole or a zero to a new location, the pole
% or zero remains inside the diamond shape edit cursor ... EXCEPT when you
% get close to the x axis. At that point the root jumps out of the edit
% cursor and sticks to the x axis (for as long as the edit cursor
% remains inside the green band). Without this snap to behavior it would be
% nearly impossible to create a purely real root. Similarly, when you drag a
% zero (but not a pole) "close" enough to the unit circle, the zero will
% "snap to" the circle. Without this feature it would be difficult to
% create a transfer function with a symmetric numerator polynomial.
%
% How "close" is close enough for these snap to operations? Well this is
% determined by the Tolerance slider which is in the lower left corner of
% the pole/zero plot. Notice that as you move this slider, the width of the
% green band surrounding the x-axis and the unit circle gets bigger. To
% disable the snap to feature, simply move the tolerance slider to 0.
%
% Shows how you can take advantage of both left and right click actions on
% a button. Left clicking on the "Delete P/Z" button deletes the root under
% the cursor as you might expect. Right clicking on this button undoes the
% previous delete. This is a multi-level undo, so you could delete all the
% zeros and then restore them one by one by successive right clicks on the
% Delete P/Z button. These buttons can also be used to change a collection of
% N poles to a collection of N zeros at the same locations. To do this,
% deleting the N poles, then click on any zero, and then right click on the
% Delete P/Z button N times. (Of course you can similarly change zeros to poles.)
%
% Demonstrates the use of the 'Fig' parameter to put two plots in one figure
% with each plot possessing all the features available to any single plot
% created by plt.

% ----- Author: ----- Paul Mennen
% ----- Email:  ----- paul@mennen.org

function editz(a)               % A primitive filter design program.
  if nargin                     % pole/zero edit mouse motion function -----------------
    hact = a{3};                % hact is the handle of the moving edit cursor
    h=get(hact,'user'); h=h{1}; % h is handle of the line being edited
    p = getxy(hact);            % position of edit cursor (diamond)
    q = getxy(h);               % position of poles or zeros being edited
    q(a{9}) = p; setxy(h,q);    % replace its value with the cursor position & update the pz plot
    plt('cursor',-2);           % update FrqResp & Xstring (mag/angle)
    return;
  end;
  % initialize ------------------------------------------------------------------------
  helpT = {...  % help text
   'Only the roots on or above the x axis are shown' .18+.88i 2i ...
   '- To move a root:' '      Click on it' ...
   '      Then click inside the red box under the Delete P/Z button' ...
   '      Then drag the root to the desired location' ...
   '      The root will snap to the x-axis if you get close' ...
   '      A zero will snap to the unit circle if you get close' ...
   '- To add a root, click on the New Zero or New Pole button' ...
   '- To remove the cursored root, click on the Delete P/Z button' ...
      .18+.5i 'color' [.5 .5 1] 'fontsize' 10 -2i...
   'Click here' 'to allow a' 'root to be' 'dragged.' -.168+.844i};
  z=roots([1 4.3 8 8 4.3 1]); p=roots([1 .38 .82]);    % initial numerator/denominator polynomials
  z=z(find(imag(z)>-1e-5));  p=p(find(imag(p)>-1e-5)); % plot only upper half of unit circle
  uc = exp((0:.01:1)*pi*1j);    % uc = half unit circle (101 points)
  x = 0:.001:.5;                % frequency axis
  % frequency response plot -----------------------------------------------------------
  S.fr = pltinit(x,x,x,x,'Pos',[755 720],'Ylim',[-100 1],'YlimR',[-400 200],'ENApre',[0 0],...
       'TRACEid',{'Mag','Phase'},'LabelY',{'  dB' 'Phase'},'Title',' ','FigBKc',[0 .1 .2],...
       'xy',[-3  .136 .644 .79 .32+.58i; -1 .01 .92 .07 .04],'LabelX','Fraction of sample rate',...
       'Xstring','sprintf("      %4.2f\\circ",360*@XVAL)','Options','-Y I','AxisLink',0,...
       'Ystring','prin("Mag (lin): ~, %6.4f%%",100*min(1,10^(@YVAL/20)))','DualCur',2);
  S.ti = get(gca,'title'); % reposition axis title to give more room for H(z)
  set(S.ti,'pos',get(S.ti,'pos') - [.02 0 0]);  set(S.ti,'units','norm','fontsize',10);
  S.H = exp(pi*get(S.fr(1),'x')*2i); % used for evaluating polynomial around unit circle
  set(getappdata(gca,'ystr'),'pos',[-3.24 11],'color','green'); % move Ystring
  % pole/zero plot ---------------------------------------------------------------------
  S.pz = pltinit('Fig',gcf,z,p,uc,'Xlim',[-1.1 1.1],'Ylim',[-.12,1.3],'ENAcur',[1 1 0],...
       'TRACEc',[0 1 1; 1 1 0; .5 .5 .5],'Styles','nn-','Markers','oxn','Options','-X-Y I',...
       'TRACEid',['Zeros '; 'Poles ';'circle'],'LabelX','real','LabelY','imag','HelpText',helpT,...
       'Xstring','sprintf("           (%4.3f, %4.2f\\circ)",abs(@XY),angle(@XY)*180/pi)',...
       'xy',[-3 .2 .066 .74 .5+.55j; -1 .09 .5 .065 .06; -2 .01 .09 .06 .12],'MotionEdit','editz');
  h = plt('cursor',0,'obj');  set(h(7:10),'vis','off'); % delta & peak/valley buttons not needed
  a = getappdata(gcf,'Dedit');  % default edit mode for xCursor edit box right click is "Modify Up/Down"
  a{2} = 7; % use 4,5,6,7,8,9 for Insert,InsertLeftRight,InsertUpDown,Modify,ModifyLeftRight,ModifyUpDown
  setappdata(gcf,'Dedit',a);     % change it to Modify
  setappdata(gcf,'EditCur',getappdata(gcf,'EditCur')+2);  % make edit cursor larger
  uicontrol('string','New zero',  'units','norm','pos',[.04 .310 .08 .025],'Callback',@newPZ);
  uicontrol('string','New pole',  'units','norm','pos',[.04 .275 .08 .025],'Callback',@newPZ);
  uicontrol('string','Delete P/Z','units','norm','pos',[.04 .225 .08 .025],'Callback',@curCB,...
            'ButtonDown',{@curCB 0});
  td = findobj(gcf,'user','TraceID');  td = td(1);
  patch([-.3 -.3 1 1],-[4 9 9 4],[0 .05 .1],'clip','off','parent',td,'ButtonD','plt click EDIT 1;');
  text(-.25,-9.75,'editz help','color',[0 1 0],'ButtonD','plt helptext on;','parent',td);
  S.pa = [patch(0,0,'k'); patch(0,0,'k')];
  set(S.pa,'FaceColor',[0 .15 .15],'EdgeColor',[0 .15 .15]);
  uistack(S.pa,'bottom');   % move patches to bottom of viewing stack
  v = version;  v = str2num(v(1:3));
  if v < 7                                                    % fix bugs in Matlab 6
    ch = get(gca,'child');  set(gca,'child',ch([3:end 1 2])); % uistack bug
    set(S.pa,'ButtonDown','plt cursor 0 axisCB;');            % bug with patch
  end;
  S.sl = plt('slider',[.006 .053 .15],[.025 0 .05],'Tolerance',@sliderCB,[4 .001],'%1.3f');
  setappdata(gcf,'S',S);       % save the handle list
  plt('cursor',0,'moveCB',@curCB);
  curCB; sliderCB;             % update frequency response plot, set tolerance patch
  axes(td);  plt helptext on;
% end function editz

function newPZ(a,b)                      % add a new pole or zero
  S = getappdata(gcf,'S');  t = get(gco,'string');
  u = 1 + (t(5)=='p');      r = S.pz(u); % u=1/2 for new zero/pole
  setxy(r,[0 getxy(r)]);                 % insert new root [(0,0)] at the beginning of list
  plt('cursor',-2,'setActive',u,1);      % move the cursor to the new root
  plt click EDIT 1;                      % and put it in edit mode
% end function newPZ

function sliderCB()                                  % tolerance slider callback
  S = getappdata(gcf,'S');
  v = plt('slider',S.sl);                            % get tolerance value from slider
  setxy(S.pa(1),[-1-v -1-v 1+v 1+v]+[-v v v -v]*1j); % set patch around x axis
  uc = exp((0:.02:1)*pi*1j);                         % half unit circle
  setxy(S.pa(2),[(1+v)*uc (1-v)*fliplr(uc)]);        % set patch around unit circle (outsie/inside)
% end function sliderCB

function curCB(a,b,c)                       % pz plot cursor callback (also delete P/Z button)
  S = getappdata(gcf,'S');
  z = getxy(S.pz(1));  p = getxy(S.pz(2));  % get zeros and poles from plot
  al = plt('cursor',-2,'getActive');
  u = get(gco,'user');
  switch nargin
  case 0, ytol = plt('slider',S.sl);        % here for pz plot cursor callback (snap to tolerance)
          az=find(abs(imag(z))<ytol); ap=find(abs(imag(p))<ytol); % any roots close to the x axis?
          z(az)=real(z(az));          p(ap)=real(p(ap));          % if so, snap to the x axis
          az = find(abs(1-abs(z))<ytol);                          % any zeros close to the unit circle?
          z(az) = exp(angle(z(az))*1j);                           % if so, snap to the unit circle
  case 2, [xy k] = plt('cursor',-2,'get');  % delete P/Z button left click - deletes the cursored root
          if     al==1 & length(z)>=k set(gco,'user',[u z(k)]);  z(k) = [];
          elseif al==2 & length(p)>=k set(gco,'user',[u p(k)]);  p(k) = [];
          end;
          plt('cursor',-2,'updateN',1);
  case 3, if isempty(u) return; end;        % delete P/Z button right click - MULTI-LEVEL UNDELETE
          if al==1  z = [z u(end)];         % Note that you can change n poles into n zeros,
          else      p = [p u(end)];         % by deleting the poles, then click on any zero
          end;                              % then right click the delete P/Z button n times.
          set(gco,'user',u(1:end-1));
  end;
  setxy(S.pz(1),z);  setxy(S.pz(2),p);     % in case anything changed
  % update the frequency response plot ------------------------------------------------------------------
  pn = real(poly([z conj(z(find(imag(z)>1e-5)))])); % append complex conjugates, convert to polynomial
  pd = real(poly([p conj(p(find(imag(p)>1e-5)))])); % append complex conjugates, convert to polynomial
  pv = polyval(pn,S.H) ./ polyval(pd,S.H);          % evaluate polynomials around unit circle (same as freqz)
  H = 20 * log10(abs(pv));                          % compute frequency response (magnitude)
  set(S.fr,{'y'},{H-max(H); angle(pv)*180/pi });    % update frequency response plot (mag/phase)
  if length(pn)+length(pd)>15 fmt ='H(z) = {%4w!,} / {%4w!,}'; else fmt ='H(z) = {%5w!  } / {%5w!  }'; end;
  set(S.ti,'string',prin(fmt,pn,pd));
  cid = getappdata(gcf,'cid');
  plt('cursor',cid(1),'update');                    % update cursor y-axis positions
  em = getappdata(gcf,'Dedit'); em=em{3}; eh=ishandle(em);   % put the pole/zero data in the
  if exist('eh') & (~eh | (eh & isempty(get(em,'button'))))  % base workspace if we are not
     assignin('base','z',z);  assignin('base','npoly',pn);   % currently moving a root
     assignin('base','p',p);  assignin('base','dpoly',pd);
  end;
  if nargin plt cursor; end;
  plt helptext;                             % turn off help text
% end function curCB

function c = getxy(h)   % get the x and y coordinates of object h
  c = complex(get(h,'x'),get(h,'y'));

function setxy(h,c)     % set the x and y coordinates of object h
  set(h,'x',real(c),'y',imag(c));