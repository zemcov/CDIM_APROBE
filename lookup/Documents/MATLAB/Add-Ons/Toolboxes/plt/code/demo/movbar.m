% movbar.m -------------------------------------------------------------------
%
% movbar plots a series of 40 random bars and displays a horizontal threshold
% line which you can move by sliding the mouse along the vertical green line.
% As you move the threshold line, a string below the plot reports the number
% of bars that exceed the threshold (demonstrating the use of the plt xstring
% parameter.)
%
% These two buttons are created ---
% Rand: Sets the bar heights to a new random data set.
% Walk: Clicking this once starts a random walk process of the bar heights.
%       Clicking a second time halts this process.
%       The Walk button user data holds the walk/halt status (1/0 respectively)
%       demonstrating a simple way to start and stop a moving plot.
%
% Note that you can move the threshold or press the Rand button while it is
% walking. Also if you click on one of the vertical purple bars, the horizontal
% threshold bar will then follow the upper end of that vertical bar. If movbar
% is called with an input agrument, the value of the argument is ignored, but
% movbar will start as if the walk button has been hit.

% ----- Author: ----- Paul Mennen
% ----- Email:  ----- paul@mennen.org


function movbar(in1);
  u = ones(1,999);
  S.tr = plt(-u,cumsum(u),vdata,...           % Line 1 is vertical slider (green)
         'LineWidth',{4 6},'Options','I',...  % Line 2 is the random bars (purple)
         'xstring',@xstr,'xlim',[-2 42]);     % enable xstring parameter
  S.hz  = line([0 41],[0 0],'color',[0 1 0]); % create horizontal threshold line
  S.rnd = uicontrol('pos',[10 445 40 22],'string','Rand','Callback',{@btn,1}); % Rand button
  S.wlk = uicontrol('pos',[10 415 40 22],'string','Walk','Callback',{@btn,0}); % Walk button
  S.ups = text(-.16,.68,'','units','norm','color',[.5 .6 1]);
  text(-.16,.65,'updates/sec','units','norm','color',[.5 .6 1]);
  set(gcf,'user',S);                          % save for callbacks
  plt('cursor',0,'update',550);               % initialize the horizontal level at 550
  set(findobj('tag','xstr'),'fontsize',16);   % increase xstring font size
  set(S.hz,'user',text(-.5,980,...            % save help text in user data
        '\leftarrow click/drag on this green line to move the horizontal threshold',...
        'color',[0 1 .6]));
  if nargin btn(0,0,0); end;                  % walk if input argument provided
% end function movbar

function t = xstr()  % xstring function: move threshold bar
  S = get(gcf,'user');
  if isempty(S) t=S;; return; end;
  tx = get(S.hz,'user');
  if length(tx) delete(tx); set(S.hz,'user',''); end;     % remove help text
  y = imag(plt('cursor',-1,'get'));
  set(S.hz,'y',[y y]);
  t = prin('%d bars > %3W',sum(get(S.tr(2),'y') > y),y); % count bars above threshold
% end function xstr

function btn(h,arg2,r)  % rand and walk button callbacks
  S = get(gcf,'user');
  if r walk(S.tr(2),0);
  else if findstr('S',get(S.wlk,'string')) t = 'Walk'; else t = 'Stop'; end;
       m=0; tic; set(S.wlk,'string',t);  % toggle Walk/Stop 
       while ishandle(S.wlk) & findstr('S',get(S.wlk,'string'))
             walk(S.tr(2));    % walk until button pressed again
             m = m+1;  if ~mod(m,25) set(S.ups,'str',sprintf('%.2f',m/toc)); end;
             drawnow;
       end;
  end;
% end function btn

function walk(h,r) % set the y data for line h (rand button use 2 argument form)
  y = imag(vdata)';                              % compute a random y vector
  if nargin<2                                    % for walk button
    y = 1000 - abs(1000 - abs(get(h,'y') + y/20 - 25));  y(1:3:end) = 0;
  end;
  set(h,'y',y);                                  % update line data
  if isempty(getappdata(gcf,'cid')) return; end; % in case it's closed via demoplt
  plt cursor;                                    % update xstring
% end function walk

function v = vdata()       % generate some data to plot
  x = 1:40;                % plot 40 bars
  y = 1000*rand(size(x));  % some random data to plot
  v = Pvbar(x,0,y);        % vertical bars
% end function vdata