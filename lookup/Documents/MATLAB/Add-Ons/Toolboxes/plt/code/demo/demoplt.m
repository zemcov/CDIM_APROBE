% demoplt.m -----------------------------------------------------------
%
% This program makes it easy to run any of the 31 sample programs in
% the plt/demo folder by clicking on the button labled with the
% program name. After installing plt for the first time, it is
% advantageous to run demoplt and to click on the "All Demos" button
% which will cause demoplt to run all 31 sample programs in sequence.
% Simply click on the "continue" button when you are ready to look at
% the next program in the list. By viewing the plots created by all
% the demos you will quickly get a overview of the types of plots that
% are possible using plt. This often gives you ideas about how you can
% use plt for creating your own application. plt5 is first on the list
% because it is the simplest most basic example. The other demos
% appear in alphabetical order.
%
% As each demo is run, you may peruse the code for the demo program
% currently being run in the demoplt list box. Use the list box
% scroll bars to view any portion of the code of interest. If the text
% is to big or small for comfort, adjust the fontsize using the
% fontsize popup menu in the lower right corner of the demoplt figure.
% This fontsize is saved (in demoplt.mat) along with the current
% figure colors and screen location so that the figure will look the
% same the next time demoplt is started. (Delete demoplt.mat to return
% to the original default conditions.)
%
% If you are running a version of Matlab older than 7.0 then the gui1
% button is replaced by the gui1v6 button. gui1.m uses a uitable which
% aren't supported in Matlab 6, so gui1v6 replaces the uitable with a
% radio button. Similarly gui2 is replaced by gui2v6 if you are running
% a version of Matlab older than 7.0 or if you are running version
% 8.4 (R2014b). gui2 uses a uipanelwhich isn't supported in Matlab 6,
% so gui2v6 replaces the uipanel with a uicontrol frame which serves
% pretty much the same function. R2014b supports the uipanel, but the
% v6 version is run because of a bug in R2014b relating to the stacking
% order of a uipanel.
%
% In addition to its main role as a demo program launcher, demoplt
% demonstrates the use of one of plt's pseudo objects, namely the
% ColorPick window. (Note: A pseudo object is a collection of more
% primitive Matlab objects, assembled together to perform a common
% objective.) The ColorPick pseudo object is useful whenever you want
% to allow the user to have control over the color of one of the graphic
% elements. In demoplt there are 4 such elements: The text color, the
% text background color, the button color, and the figure background
% color. The ColorPick window is activated when you left or right click
% on any of the 4 text labels near the bottom of the figure, or any of
% the uicontrol objects adjacent to these labels. (A right click on
% the figure background edit box will bring up the ColorPick window).
% When the ColorPick window appears you can use the sliders or the color
% patches to change the color of the respective graphic element. For more
% details, see the "Pseudo objects" section in the help file.
%
% An optional feature of the ColorPick object is the color change
% callback function (a function to be called whenever a new color is
% selected). This feature is demonstrated here by assigning the color
% change callback to "demoplt(0)". The callback function is used to
% "animate" the figure by briefly modifying the listbox fontsize.
% This particular animation is certainly not useful (see line 111 to
% disable it), but is there merely to demonstrate how to use the callback.
%
% Although it's unrelated to plt, demoplt also demonstrates the use of
% the close request function, which in this example is assigned to
% demoplt(1) and is used to save the currently selected colors and
% screen position to a setup file.
%
% If you right click the "All Demos" button instead of left clicking, then
% all 31 demos are run consecutively without waiting for you to click the
% continue button. This means that the demo figure windows will disappear
% so quickly you may not even be able to see them, but this is still useful
% if you just want to verify that all the demos run without producing
% an error in the command window, or if you just want to time the process.
% (The elapsed time for all 31 demos is shown in the listbox.)

%
% ----- Author: ----- Paul Mennen
% ----- Email:  ----- paul@mennen.org

function demoplt(in1)
  if ~nargin in1 = 'init'; end;
  fg = findobj('name','demoplt');
  cfile = [which(mfilename) 'at'];  % use demoplt.mat to save figure colors
  bx = findobj(fg,'style','listbox');    pu = findobj(fg,'style','popup');
switch in1
case 'close',  % here for close request function
      close(findobj('name','Color Pick'));  % close any open ColorPick windows
      if isempty(fg) return; end;
      fbk = get(fg,'color');  lbk = get(bx,'backgr');  lfg = get(bx,'foregr');
      bbk = get(pu,'backgr'); fpos = get(fg,'pos');   fsz = get(bx,'fontsize');
      if any(get(gcf,'user') ~= [fbk lbk lfg bbk fpos(3:4) fsz]) % has setup changed?
        delete(get(gcf,'child'));  set(gcf,'user',0);            % yes, come here
        uicontrol('pos',[220 300 250 32],'str','Save setup changes', ...
                  'callback','set(gcf,''user'',1);');
        uicontrol('pos',[220 240 250 32],'str','Exit without saving', ...
                  'callback','set(gcf,''user'',2);');
        uicontrol('pos',[220 180 250 32],'str','Reset to default settings', ...
                  'callback','set(gcf,''user'',3);');
        while ~get(gcf,'user') pause(.03); end;
        switch get(gcf,'user')
        case 1, save(cfile,'fbk','lbk','lfg','bbk','fpos','fsz','-v4'); % save .mat setup
                disp('demoplt setup saved to demoplt.mat');
        case 3, delete(cfile); disp('demoplt.mat was deleted');
        end;
      end;
      closereq; % close the demoplt figure
case {'init','go'}
  v = version;  v = sscanf(v(1:3),'%f');
  fcn = {'plt5'      'bounce(0)' 'circles12' 'curves go' 'dice(0)'   ... 
         'editz'     'gauss'     'gui1'      'gui2'      'julia'     ...
         'movbar(1)' 'plt50'     'pltmap(1)' 'pltn'      'pltquiv'   ...
         'pltsq(1)'  'pltvbar'   'pltvar'    'pub'       'pub2'      ...
         'pub3'      'subplt'    'subplt8'   'subplt16'  'subplt20'  ...
         'tasplt'    'trigplt'   'weight'    'wfall(1)'  'wfalltst'  'winplt'};
  if v<7 | v>= 8.4 fcn{9} = 'gui2v6'; end;
  if v<7           fcn{8} = 'gui1v6'; end;

  if length(in1)<4
    for f=fcn   % here for "demoplt go"
      g = f{1};
      k = [findstr(g,' ') findstr(g,'(')];
      if length(k) g = g(1:k-1); end;
      eval(g);
      close all;
    end;
    rmappdata(0,'demoGo');
    return;
  end;
  if length(fg) disp('demoplt is already running'); return; end;
  if exist(cfile) load(cfile);       % get setup infromation from .mat if it exists
  else            fbk = [ 0 .2 .3];  % Otherwise: figure background color
                  lbk = [ 0  0  0];  %            listbox background color
                  lfg = [ 1  1 .5];  %            listbox foreground (text color)
                  bbk = [.4 .8 .8];  %            button background color
                  fpos = [];         %            use default figure position
                  fsz = 9;           %            default listbox fontsize
  end;
  fg = figure('name','demoplt','menu','none','numberT','off','double','off',...
              'pos',figpos([inf 0 655 442]),'color',fbk,'closereq','demoplt close;');
  n = length(fcn);  bt = zeros(1,n+1);
  x = 10;  y = 420;  % starting location for the first demo program button
  for k=1:n          % create 31 buttons
     bt(k) = uicontrol('Pos',[x y 83 18],'string',fcn{k},'callb',{@OneDemo,fcn{k}});
     x = x+92;  if x>600 x=10; y=y-22; end;
  end;
  bt(end) = uicontrol('Pos',[x y 360 18],'user',0,'str','All Demos',...
                      'Enable','inactive','buttond',{@AllDemos,fcn});
  set(bt,'units','norm','fontsize',10,'backgr',bbk);
  set(bt(end),'backgr',fliplr(bbk)); % use a different color for the All Demos button
  bx = uicontrol('style','listbox','units','norm',...  % listbox for viewing demo code
          'pos',[.01 .076 .98 .662],'fontsize',fsz,...
          'fontname','Lucida Console','foregr',lfg,'backgr',lbk);
  axes('pos',[1 2 6 1]/10,'units','norm'); % create an axis to contain the text objects
  set([text(.120,-1.6,'text foregr/backgr:') ...
       text(.497,-1.6,'button color:') ...
       text(.815,-1.6,'figure backgr:')],'color','white','horiz','right');
  setappdata(gcf,'nL',text(1.48,-1.6,'','color',[.6 .5 .2],'horiz','right')); % # of code lines
  set(bx,'string',rdfunc('demoplt'));
  sfbk = strrep(prin('{%3w!  }',fbk),'0.','.'); % remove leading zeros
  p = [.175 .023 .044 .029;  % a(1) position: text color frame
       .225 .023 .044 .029;  % a(2) position: text background frame
       .402 .023 .044 .029;  % a(3) position: button color frame
       .595 .015 .120 .048;  % a(4) position: figure background editbox
       .730 .016 .130 .048]; % a(5) position: fontsize popup
  a = [uicontrol('enable','inactive','buttond','plt ColorPick demoplt(1);') ...
       uicontrol('enable','inactive','buttond','plt ColorPick demoplt(2);') ...
       uicontrol('enable','inactive','buttond','plt ColorPick demoplt(3);') ...
       uicontrol('string',sfbk,      'buttond','plt ColorPick demoplt(4);','fontW','bold') ...
       uicontrol('string',prin('{fontsize: %d!row}',4:18),'value',fsz-3,'fontsize',9,...
         'callback','set(findobj(gcf,''sty'',''l''),''fontsize'',3+get(gcbo,''value''));')];
  set(a,{'style'},{'frame';'frame';'frame';'edit';'popup'},'units','norm',...
        {'pos'},num2cell(p,2),{'backgr'},{lfg; lbk; bbk; bbk; bbk});
  set(a(4),'callback',get(a(4),'buttond'));
  q = {{'backgr',a(1),'foregr',bx,'text color'};  % define color pick actions
       {'backgr',a(2),'backgr',bx,'text background'};
       {'backgr',a(3),'backgr',[a(5) bt],'button color'};
       {'string',a(4),'color', fg,'figure background'}};
  for k=1:4 setappdata(a(k),'m',q{k}); end;
  sz = get(0,'screensize');
  if length(fpos) fpos = figpos([inf 0 fpos(3:4)]); end; % use saved size, ignore position
  if isempty(fpos) & sz(4)>1030
    fpos = figpos([inf 0 710 480]); % use a bigger demoplt figure for large screen sizes
  end;
  if length(fpos) set(fg,'pos',fpos); else fpos = get(fg,'pos'); end;
  set(gcf,'user',[get(fg,'color') get(bx,'backgr') get(bx,'foregr') ...
                  get(a(5),'backgr') fpos(3:4) get(bx,'fontsize')]); % save starting configuration
otherwise,        % here to do the color callback function
  if ischar(in1) disp([in1 ' is not a valid demoplt argument']); return; end;
  t = {'Text foreground  ' 'Text background  ' 'Button           ' 'Figure background'};
  c = { get(bx,'foregr')    get(bx,'backgr')    get(pu,'backgr')    get(fg,'color')   };
  s = sprintf('      %s color was changed to [%.2f %.2f %.2f]',t{in1},c{in1});
  set(bx,'string',[{s}; get(bx,'string')]);   % report color change on the listbox
  set(findobj('style','edit'),'backgr',c{3}); % edit box color tracks button color
end % end switch in1
%end function demoplt

function s=rdfunc(func) % returns a cell array of strings from a program file
  f = findstr(func,' ');
  if length(f) func = func(1:f-1); end;
  f = fopen(which(func));  s = {};
  nL = 0;  % counts lines (not counting comments)
  while 1  ln = fgetl(f);
           if ~ischar(ln), break, end
           s = [s; {ln}];
           ln = deblank(fliplr(ln));
           if length(ln) & (ln(end)~='%') nL=nL+1; end;
  end
  set(getappdata(gcf,'nL'),'str',prin('#Lines = %d',nL));
  fclose(f);
%end function rdfunc

function FGclose() % close all figures except the demoplt figure
  a = transpose(get(0,'child'));
  a(find(a==findobj('name','demoplt'))) = [];  close(a);
%end function FGclose

function OneDemo(h,arg2,func)
  FGclose;
  set(findobj(gcf,'style','push'),'fontw','normal');
  if ishandle(h)
    set(findobj(gcf,'string',func),'fontw','bold');
    set(findobj(gcf,'style','listbox'),'val',1,'string',rdfunc(func));
    if strcmp(func,'pltvar') evalin('base',func); else eval([func ';']); end;
    a = get(0,'child');                % list of all the figure windows
    b = findobj(a,'name','demoplt');   % find demoplt in the list
    if length(b) set(0,'child',[b; a(find(a~=b))]); end; % force demoplt window on-top
  else
    k = [findstr(func,'(') findstr(func,' ')];
    if length(k) func = func(1:k-1); end;
    if strcmp(func,'circles12') func = 'circles12 1'; end;
    if strcmp(func,'pltvar') evalin('base',func); else eval([func ';']); end;
  end;
%end function OneDemo 

function AllDemos(h,arg2,fcn)
  mouse  = get(gcf,'SelectionT');   nf = length(fcn);
  if mouse(1) == 'a'
    t0=clock;  for n=1:nf  OneDemo(-1,0,fcn{n}); end;  FGclose;
    disp(sprintf('Elapsed time: %.2f sec',etime(clock,t0)));
    set(findobj(gcf,'style','listbox'),'string',...
        {'' '' sprintf('Elapsed time: %.2f sec',etime(clock,t0))});
  else     
    n = get(h,'user') + 1;  % function to start
    if n>nf
      set(h,'user',0,'string','All Demos');
      FGclose;
      set(findobj(gcf,'style','push'),'fontw','normal');
      set(findobj(gcf,'style','listbox'),'string',{'' '' '   --- ALL DEMOS COMPLETED ---'});
    else set(h,'user',n,'string','continue');
         OneDemo(0,0,fcn{n});
    end;
  end;
%end function AllDemos
