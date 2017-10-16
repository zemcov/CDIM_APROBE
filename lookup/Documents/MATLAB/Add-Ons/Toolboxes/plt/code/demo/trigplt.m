% trigplt.m ------------------------------------------------------------
%
% This example demonstrates:
% - showing the line characteristics in the TraceID using the TraceMK parameter
% - setting the cursor callback with the moveCB parameter
% - setting axis, TraceID box, and MenuBox positons using the 'xy' parameter
% - setting trace characteristics with the Linewidth, Styles, and Markers parameters
% - setting an initial cursor position
% - enabling the multiCursor mode
% - modifying the colors and fonts of the Trace IDs
% - The use of the slider pseudo object
% - The use of HelpText pseudo object to display temporary help information
%   at the top of the plot window. This help text disappears when any parameter
%   is changed but can be re-enabled by clicking on the help button or by right
%   clicking on the help tag in the MenuBox.
% - Shows how to use "inf" in the 'Pos' parameter to position the figure in the
%   upper right corner of the screen. In this example an extra 48 pixels is
%   allocated to the title bar so that the menu bar and one toolbar can be
%   enabled without pushing the title bar off the top of the screen.
% - The clipboard button captures the figure as a bitmap into the clipboard
% - Using "zeros(6)" in the plt call to define 6 traces. The slider callback will
%   overwrite these zeros with the actual data to be displayed. Note that "NaN(6)"
%   would also have worked equally as well for this purpose.

% ----- Author: ----- Paul Mennen
% ----- Email:  ----- paul@mennen.org

function trigplt
  htxt = {'Use the sliders to change the A,B,C,D parameters' ...
          '     - Note that sin/cos use the right axis scale' ...
          '     - The remaining functions use the left axis' ...
          .243+i 'fontsize' 10 'color',[1 .7 .7]};
  p = [ 0 .143 .093 .790 .740;  % position: plot axis
       -1 .009 .105 .100 .217;  % position: TraceID box
       -2 .017 .620 .058 .210]; % position: MenuBox
  S.tid = {'sin' 'cos' 'tan' 'csc' 'sec' 'cot'};
  S.tr = plt(zeros(6),'FigName','trigplt: y = A sin(Bx + C) + D',...
          'Right',1:2,'Pos',[inf inf 780 530 48],'xy',p,'FigBKc',[0 .25 .3],...
          'Xlim',[0 2*pi],'Ylim',{[-8 8] [-1.5 1.5]},'Title',' ',...
          'moveCB',@sliderCB,'DisTrace',[0 0 0 0 0 1],'TraceID',S.tid,...
          'Linewidth',{2 2 1 1 1 1},'Styles','----:-','Markers','nnnnns',...
          'Options','-X -Y I','-Ycolor',[1 .3 .3],'TraceMK',.5,...
          'LabelX','radians','LabelY',{'tan / csc / sec / cot'; 'sin / cos'});
  S.tx = get(gca,'Title');
  set(S.tx,'fontsize',14,'color','yellow','units','norm','pos',[.5 1.01]);
  line([-99 99],[0 0],'color',[1 .3 .3],'linestyle','--'); % make x-axis more obvious
  p = [.04 .955 .2];  dp = [.24 0 0];                      % create 4 pseudo sliders
  S.sl = [plt('slider',p+0*dp,[1   0  1],'--- A ---',@sliderCB,[4 .01]);
          plt('slider',p+1*dp,[1   0 20],'--- B ---',@sliderCB,[4  .2]);
          plt('slider',p+2*dp,[0  -4  4],'--- C ---',@sliderCB,[4  .1]);
          plt('slider',p+3*dp,[0 -.5 .5],'--- D ---',@sliderCB,[4 .01],'3 4 3')];
  fn = get(gcf,'number');             % get figure number
  if ischar(fn) fn = gcf; end;        % older matlab versions don't store the figure number there
  p = [.01 .50 .07 .04;               % position: help button
       .01 .43 .07 .04];              % position: clipboard button
  set([uicontrol uicontrol],'units','norm',{'pos'},num2cell(p,2),...
     {'str'},{'help'; 'clipboard'},{'callback'},...
     {'plt helptext on;'; ['print -f' num2str(fn) ' -dbitmap -noui']});
  set(gcf,'user',S);                  % save structure for slider/cursor callback
  sliderCB;                           % initialize the plot
  plt xleft Yedit 2;                  % enable multiCur (It won't work to use "multiCur" in the
                                      % plt options string because the traces are not yet defined.
  plt('cursor',-1,'update',81);       % move cursor position (to index=81)
  plt('HelpText','on',htxt);          % enable help text
  tid = findobj(gcf,'user','TraceID');
  rhb = findobj(tid,'xdata',[0 .95]); % find the right hand axis identifying patches
  set(rhb,'color',[.2 0 0]);          % change them to dim red
  tx = findobj(tid,'type','text');    % find all the text objects in the traceID box
  set(tx,'fontname','Courier New','fontsize',11);   % change the font and size
% end function trigplt

function sliderCB()  % Update the plot based on current slider and cursor values
  S = get(gcf,'user');
  if isempty(S) return; end;
  plt helptext;  % remove the help text
  A = plt('slider',S.sl(1));   B = plt('slider',S.sl(2));
  C = plt('slider',S.sl(3));   D = plt('slider',S.sl(4));
  s = S.tid{plt('cursor',-1,'getActive')}; % name of active trace
  set(S.tx,'string',prin('%3w %s(%3wx + %3w) + %3w',A,s,B,C,D));
  xx = pi*[0:.02:2];  x = B*xx+C+1e-12;
  f = A*[sin(x); cos(x); tan(x); csc(x); sec(x); cot(x)] + D;
  f(find(abs(f)>10)) = NaN;
  set(S.tr,'x',xx,{'y'},{f(1,:); f(2,:); f(3,:); f(4,:); f(5,:); f(6,:)})
%end function sliderCB
