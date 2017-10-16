function q = figpos(varargin)
%
% Normally the position of a figure window is specified in pixels as:
% [xleft ybottom width height] relative to the monitor, meaning that
% xleft = 1 refers to the leftmost position of the monitor. However it
% usually is more convenient to specify the figure relative to the
% useable screen space, which takes into account the space needed for
% the taskbar as well as the space needed for the window borders and
% title bar.
%
% Consider the following two methods of creating a new figure window:
%
% figure('BackgroundColor',[0 0 .1],'Position',p);
% figure('BackgroundColor',[0 0 .1],'Position',figpos(p);
%
% In the first method, the pixel coordinates in p are relative to the full
% screen which especially with a multi-window GUI makes it impossible to
% make good use of the screen area without knowing where the taskbar is
% and other desktop variables. In the second line however the coordinates
% in p are relative to a pre-defined clear area of the screen which are
% converted into absolute screen coordinates by figpos (this routine).
%
% To accomplish this, figpos must know the screen area that can accommodate
% the Matlab figure window. It gets this information from the screencfg.m
% routine which normally can determine the optimal border area automatically,
% however it may resort to using predefined constants if you are using a
% very old version of Matlab. It will warn you if this happens, and you
% might want to review the comments in screencfg to see if you want to
% adjust any of the constants. The way screencfg is called in figpos
% it will only optimize the border area the first time it is called.
% After that it gets the border area from the saved value (which is stored
% both in the 'border' application data variable of the root object as
% well as in the file screencfg.txt. This means that if you move or resize
% the taskbar you should type "screencfg" at the command prompt so that
% the border area is recalculated. If you want Matlab to recalculate the
% border area every time it starts up, you could add the line "screencfg;"
% to Matlab's startup file, or the line delete(which('screencfg.txt'));
% which would have the same effect.
%
% First I will first explain how figpos computes the figure position from
% the input argument, although you may find it easier to understand by
% skipping ahead to the examples below.
%
% In rare situations, may want to specify the screen position using the
% standard Matlab convention [left bottom width height] referenced to the
% screen without reference to the border areas. Of course, then you don't
% need to call figpos in the first place ... except for the fact that
% figpos is called automatically by plt, so we need a way to bypass the
% usual figpos processing. The way to do that is simply to place an "i"
% after any element in the 1x4 vector. For example:
%
% figpos([40 50i 600 500]) returns the vector [40 50 600 500].
% figpos(40,50i,600,500) is what I call the scalar form and is equivalent
% to the above. I've always used the vector form in the examples below,
% but you may always use the scalar form if you prefer.
%
% It doesn't matter which element contains the "i", and in fact you can put
% the "i" in all 4 elements if you like, i.e. figpos([400 50 600 500]*1i);
%
% Suppose you call figpos([p1 p2 p3 p4]) where all the terms are real and p3
% and p4 are both positive. This is called "size priority mode" because the
% getting the figure size correct takes priority over getting the left/bottom
% position in the specified place. In this mode, figpos will return
% [left bottom width height] where:
%   width  = the smaller of p3 and the maximum clear width available
%   height = the smaller of p4 and the maximum clear height available
%   left   = p1 + left border width. However if this position would make the
%            right edge of the figure overflow the clear space available, then
%            the left edge is moved rightward just far enough so the figure fits.
%   bottom = p2 + bottom border width. However if this position would make the
%            top edge of the figure overflow the clear space available, then
%            the bottom edge is moved down just far enough so the figure fits.
%
% Suppose you call figpos([p1 p2 -p3 p4]), i.e. the same as the calling
% sequence above except that the 3rd element is negative. The height and
% bottom values are computed exactly as shown above (size priority), but
% the width and left values are now computed as follows (position priority):
%
%   left   = p1 + left border width.
%   width  = p3. However if this width would make the right edge of the figure
%            overflow the clear space available, then the width is reduced by
%            just enough so that the figure fits.
%
% Suppose you call figpos([p1 p2 p3 -p4]), i.e. the 4th element is negative.
% The left and width values are computed exactly as shown in the first all
% positive (size priority mode) but the bottom and height values are now
% computed as follows (position priority):
%
%   bottom = p2 + bottom border width.
%   height = p4. However if this height would make the top edge of the figure
%            overflow the clear space available, then the height is reduced
%            by just enough so that the figure fits.
%
% If you call figpos([p1 p2 -p3 -p4]), then both horizontal and vertical
% coordinates use the position priority method described above.
%
% An optional 5th value in the input vector is allowed to allocate extra space
% for the title bar. You may want to do this if you know that a menu bar or
% toolbar will be enabled since that will make the title bar larger. Since
% this is not accounted for in the border area set up by screencfg, enabling
% these features could cause the top edge of the figure to fall off the top
% edge of the screen. For example:
%
% figpos([p1 p2 p3 p4 48]) would allocate 48 extra pixels in the vertical
% space which would be enough for the menu bar (about 21 pixels high) and
% one toolbar (about 27 pixels high). 
%
% The default left/bottom coordinates are [5 5] which are used if they are
% not supplied. For example:
%
% figpos([730 550])    gives the same results as figpos([5 5 730 550]);
% figpos([730 550 21]) gives the same results as figpos([5 5 730 550 21]);
%
% You also may specify only the figure length or the figure width and let
% figpos calculate the missing size parameter based on the most appropriate
% aspect ration. For example figpos([1000 0]) and figpos([0 944]) both give
% the same results as figpos([1000 944]). This particular aspect ratio (1.006)
% was chosen so that if you plot a circle, the resulting figure is actually
% looks circular rather than elliptical. For example, this line plots a
% perfect circle using 600 points:  plt(exp((1:600)*pi*2i/599),'pos',[1000 0])
%
% If you move your taskbar to a new location, for figpos to continue to work
% properly you should edit the screencfg.m file by commenting out the
% appropriate lines defining the taskbar location. Then to enable those
% changes type "screencfg" at the Matlab command prompt, or simply restarting
% Matlab will enable the changes.
%
% The following examples may clarify the specification described above:
%
% The first example creates 5 plots of the same size placed on the screen
% so that all the plots are as far away from each other as possible. The
% first four plots are placed right at the edge of the screen at the four
% corners, except not so close that any of the figure borders disappear
% and of course not obscuring the taskbar no matter where the taskbar is
% placed. On a small screen even the first four figures would overlap.
% On a large screen, the first four figures would not overlap, but the
% fifth figure would overlap the corners of the other four (unless the
% screen had an exceptionally high resolution).

% y = rand(1,100);  sz = [700 480];      % data to plot and figure size
% plt(y,'pos',[ 0   0  sz]);             % bottom left corner
% plt(y,'pos',[Inf  0  sz]);             % top left corner
% plt(y,'pos',[ 0  Inf sz]);             % bottom right corner
% plt(y,'pos',[Inf Inf sz]);             % top right corner
% p = get(findobj('name','plt'),'pos');  % get positions of all 4 plt figures
% plt(y,'pos',mean(cell2mat(p))*1i);     % put 5th plot at the average position

% The "*1i" in the above line is strictly necessary to prevent figpos from
% adjusting the position using the current border information. The raw pixel
% location is used because the get('pos') command returns raw pixel coordinates.
% With the "*1i" removed, the last figure would not be at the exact arithmetic
% mean position, but actually the error would probably be too small to notice.

% The next example also creates four figures at the corners of the screen,
% although this time, the first figure is a fixed size and the remaining
% figures are tiled so as to fill all the remaining space on the screen.

% plt(y,'pos',[ 0   0   600  400]);  % figure 1 is placed at the lower left corner
% plt(y,'pos',[ 0  440  600 -Inf]);  % use all the remaining space above fig1
% plt(y,'pos',[615  0  -Inf  400]);  % use all the remaining space to the right of fig1
% plt(y,'pos',[615 440 -Inf -Inf]);  % use all the remaining space not used by figs 1-3
% Note that an extra 15 pixels in width and 40 pixels in height is used to create
% a small gap between the four figures.

% In addition to the examples above, a good way to appreciate the value of
% the figpos function is to run demoplt.m and cycle thru all the plt demo
% programs using the "All Demos" button. Notice how well the various
% windows are placed on the screen. You will appreciate the intelligence
% of the placement even more if you are able to rerun the demos using a
% different screen resolution and a different taskbar location. Without
% the figpos function, many of the demos would have to be more complicated
% to place their figures at appropriate screen positions.
%
% ----- Author: ----- Paul Mennen
% ----- Email:  ----- paul@mennen.org

if ~nargin feval('help','figpos'); return; end;
if nargin>1 p = [varargin{:}]; else p = varargin{1}; end; 
n = length(p);
if ~isreal(p)
  q = real(p) + imag(p);                     % remove the "i"
  if n==2     q = [10 55 q];
  elseif n~=4 q = figpos([700 525]);         % invalid input. Use a default size/position
  end;
  if     ~q(3) q(3) = round(q(4)/.944);      % a zero width or height is
  elseif ~q(4) q(4) = round(q(3)*.944);      % similar to axis('equal')
  end;
  return;
end;

set(0,'units','pixels');
z = get(0,'screensize');  z = z(3:4);        % z = screen [width height]

b = screencfg(0);                            % get the border area (Type "screencfg" at the
                                             % command prompt if you move or resize the taskbar.)
if length(b)==5                              % compute r (available region)
     r = b(1:4);                             % region is specified in raw pixels
     if ~b(5) r = r .* [z z]/100; end;       % region is specified in % of screen
else r = [b(1:2) z - [b(1)+b(3) b(2)+b(4)]]; % region is specified with 4 border widths
end;
l = r(1);  b = r(2);  w = r(3);  h = r(4);   % l,b,w,h for region available
  
if n<4  p = [5 5 p]; n=n+2; end; % append default position [5 5] if no position is supplied
if n<4 | n>5 q = figpos([700 525]); return; end; % invalid input. Use a default size/position
if n==5 h = h-p(5); end;  % 5th element specifies height for menu and/or tool bars

if     ~p(3) p(3) = round(p(4)/.944);        % a zero width or height is
elseif ~p(4) p(4) = round(p(3)*.944);        % similar to axis('equal')
end;
                                                          % width/left --------
if p(3)>0 W = min(w,p(3)); L = min(l+p(1), max(l+w-W,l)); % size priority
else      L = l + p(1);    W = min(w-p(1),-p(3));         % position priority
end;
                                                          % height/bottom -----
if p(4)>0 H = min(h,p(4)); B = min(b+p(2), max(b+h-H,b)); % size priority
else      B = b + p(2);    H = min(h-p(2),-p(4));         % position priority
end;

q = [L B W H];  % returned result [left bottom width height]
                       