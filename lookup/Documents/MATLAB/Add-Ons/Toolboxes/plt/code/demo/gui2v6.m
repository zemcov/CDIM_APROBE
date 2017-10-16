% gui2v6.m -----------------------------------------------------------------
%
% Note: This is a slightly modified version gui2 which should be used if
% you are running a version of Matlab older than 7.0 because Matlab 6 does
% not support the uipanel. Actually the alternate version should also be used
% if you are running R2014b or newer. The reason for this is that although
% the uipanel is supported, a bug relating to the uipanel's stacking order
% prevents gui2 from working properly in those versions. If you start gui2
% from demoplt, demoplt checks the Matlab version and runs gui2 or gui2v6
% as appropriate.
%
% ----- Author: ----- Paul Mennen
% ----- Email:  ----- paul@mennen.org

function gui2v6()
htxt = {'Select the filter order & type' 'in the parameter box above.' '' ...
        'Vary the ripple & frequency' ' parameters using the sliders.' .6+.62i};
  p = {[.125 .105 .800 .760];  % plot    position
       [.100 .882 .235 .100];  % axis    position: Parameters
       [.165 .935 .040 .030];  % edit    position: filter order
       [.110 .710 .100 .200];  % popup   position: filter type
       [.310 .750 .024 .200];  % popup   position: # of decades
       [.287 .710 .054 .200];  % popup   position: # of points
       [.350 .946 .150     ];  % slider  position: Passband ripple
       [.510 .946 .150     ];  % slider  position: Stopband ripple
       [.670 .946 .150     ];  % slider  position: Cutoff frequency
       [.830 .946 .150     ];  % slider  position: frequency 2
       {-.09 .650          }}; % text    position: eliptic transition ratio
  c = [0 1 0; 1 0 1; 0 1 1; 1 0 0; .2 .6 1];  % trace colors
  S.cfg = [which(mfilename) 'at'];  % use gui2v6.mat to save configuration data
  lbx = 'radians/sec';  lby = {'dB' [blanks(70) 'Phase \circ']};
  typ = {'low pass' 'high pass' 'band pass' 'stop band'};  pts = 100*[1 2 4 8 16];
  S.tr = plt(0,zeros(1,10),'Right',6:10,'Options','logX I','closeReq',@cfg,...
            'DualCur',-5,'TraceID',{'Butter' 'Bessel', 'Cheby1'  'Cheby2' 'Elliptic'},...
            'Ylim',{[-90 60] [-1000 200]},'LabelX',lbx,'LabelY',lby,...
            'TIDcback','t=plt("show"); t=t(find(t<6)); plt("show",[t t+5]);',...
            'xy',p{1},'TraceC',[c;c],'+Ytick',-140:20:0,'-Ytick',[-180 0 180]);
  ca = gca;
  axes('units','norm','pos',p{2},'box','on','xtick',[],'ytick',[],'color','none',...
       'linewidth',3,'xcolor',[.4 .4 .4],'ycolor',[.4 .4 .4],'tag','frame');
  axes(ca);
  S.n   = plt('edit',  p{3} ,[6 1 25],'callbk',@clb,'label','Or~der:');
  S.typ = plt('pop',   p{4} ,typ,'callbk',@clb,'swap');
  S.dec = plt('pop',   p{5} ,1:5,'callbk',@clb,'index',3,'label','Decades:','hide');
  S.pts = plt('pop',   p{6} ,pts,'callbk',@clb,'index',2,'label','Points:', 'hide');
  S.Rp  = plt('slider',p{7} ,[ 2  .01   9],'Passband ripple', @clb);
  S.Rs  = plt('slider',p{8} ,[ 40  10 120],'Stopband ripple', @clb);
  S.Wn  = plt('slider',p{9} ,[.02 .001  1],'Cutoff frequency',@clb,5,'%4.3f 6 2');
  S.Wm  = plt('slider',p{10},[.2  .001  1],'frequency 2',     @clb,5,'%4.3f 6 2');
  S.etr = text(p{11}{:},'','units','norm','horiz','center','color',[.2 .6 1]);
  set(gcf,'user',S);
  h = getappdata(gcf,'sli'); h(5:5:end) = [];  set(h,'buttond','plt ColorPick;');
  for k = 1:length(h) setappdata(h(k),'m',{'backgr' h}); end;
  if exist(S.cfg) load(S.cfg);  % load configuration file if it exists -------------
                  plt('edit',S.n,'value', cf{1});  plt('pop',S.typ,'index',cf{2});
                  plt('pop',S.pts,'index',cf{3});  plt('pop',S.dec,'index',cf{4});
                  plt('slider',S.Rp,'set',cf{5});  plt('slider',S.Rs,'set',cf{6});
                  plt('slider',S.Wn,'set',cf{7});  plt('slider',S.Wm,'set',cf{8});
                  set(h,'background',     cf{9});  set(gcf,'position',     cf{10});
  end;
  clb;                        % initialize plot
  plt cursor -1 updateH -1;   % center cursor
  plt('HelpText','on',htxt);  % show help text
% end function gui2v6

function clb() % callback function for all objects
  S = get(gcf,'user');
  ty = plt('pop',S.typ);                         % get filter type index
  t = {'low' 'high' 'bandpass' 'stop'}; t=t{ty}; % get filter type name
  N   = plt('edit',S.n);                         % get filter order
  dec = plt('pop',S.dec);                        % get number of decades to plot
  pts = str2num(get(S.pts,'string'));            % get # of points to plot
  X   = logspace(-dec,0,pts);  W = X*1i;         % X-axis data (radians/sec)
  Wn  = plt('slider',S.Wn);                      % get filter freq
  Rp  = plt('slider',S.Rp);                      % get passband ripple
  Rs  = plt('slider',S.Rs); Rs2 = max(Rp+.1,Rs); % get stopband ripple (must be > passband)
  if ty>2 Wn = [Wn plt('slider',S.Wm)];          % get frequency 2
          plt('slider',S.Wm,'visON');            % make frequency 2 slider visible
  else    plt('slider',S.Wm,'visOFF');           % make frequency 2 slider invisible
  end;
  [B,A] = butter(N,Wn,t,'s');        H{1} = polyval(B,W)./polyval(A,W);
  [B,A] = besself(N,Wn(1));          H{2} = polyval(B,W)./polyval(A,W);
  [B,A] = cheby1(N,Rp,Wn,t,'s');     H{3} = polyval(B,W)./polyval(A,W);
  [B,A] = cheby2(N,Rs,Wn,t,'s');     H{4} = polyval(B,W)./polyval(A,W);
  [B,A] = ellip(N,Rp,Rs2,Wn,t,'s');  H{5} = polyval(B,W)./polyval(A,W);
  if ty~=1 H{2}=H{2}+NaN; end;       % bessel filter only applicable for low pass
  for k=1:5   % set trace data
    set(S.tr([k k+5]),'x',X,{'y'},{20*log10(abs(H{k})); angle(H{k})*180/pi});
  end;
  plt('cursor',-1,'xlim',X([1 end])); % set Xaxis limits
  plt cursor -1 updateH;              % update cursor
  h = find(get(S.tr(5),'y') < -Rs2);  % compute Elliptic transition ratio
  if     isempty(h)                    h = 0;
  elseif (ty-2)*(ty-3)                 h = X(h(1))/Wn(1);
  else    h = find(diff([h inf])>1);   h = Wn(1)/X(h(1));
  end;
  set(S.etr,'string',prin('Elliptic ~, transition ~, ratio: ~, %5v',h));
  plt('HelpText','off');
% end function clb

function cfg() % write configuration file
  S = get(gcf,'user');  sli = findobj(gcf,'style','slider');
  cf = { plt('edit',S.n);       plt('pop',S.typ);
         plt('pop',S.dec);      plt('pop',S.pts);
         plt('slider',S.Rp);    plt('slider',S.Rs);
         plt('slider',S.Wn);    plt('slider',S.Wm);
         get(sli(1),'backgr');  get(gcf,'position') };
  save(S.cfg,'cf');
% end function cfg
