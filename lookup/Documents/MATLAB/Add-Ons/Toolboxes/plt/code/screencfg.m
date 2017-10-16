function b = screencfg(In) % sets the screen borders to allow
                           % room for the taskbar & title bar.
%
% If called without an argument, screencfg attempts to determine the
% current screen borders automatically. If the automatic procedure fails,
% then the predefined taskbar size and position defined in the file
% "TaskbarSZ.m" is assumed (which may be edited if needed). The output of
% this function is a 4 or 5 element row vector called the "border vector".
% This border vector (in addition to being this function's return value)
% is written in text form to screencfg.txt (in the same folder containing
% screencfg.m), and is also saved in the 'border' application property
% value of the matlab root object.
%
% If called with a vector argument, then the supplied argument is taken
% to be the new border vector.
%
% If called with a scalar argument, then screencfg first looks for the
% 'border' application property value. If this property exists, then
% its value is returned and nothing further is done. However if the
% 'border' property does not exist, then screencfg will look for
% the screencfg.txt file and if it exist will return the values stored
% there and will also save this vector in the 'border' property. If the
% screencfg.txt file also does not exist, then screencfg will behave
% as if it was called without an argument (described above).
%
% When a 4 element vector is used for the border vector, its form
% is [left bottom right top] where each number represents the number
% of pixels of clear space (i.e. not used for matlab figures) that
% must exist at the four edges of the screen indicated. When a 5
% element vector is used its form is:
%
% [left bottom width height 0] - The largest visible screen position
% in pixel units using the standard Matlab figure positioning scheme.
%
% [left bottom width height 1] - Same as above except that normalized
% coordinates are used.

foobar = 0;
if exist('foobar')
      fi = feval('which','screencfg.m');  fi = [fi(1:end-1) 'txt']; % text file name
      foobar = 1;
else  fi = [fileparts(GetExe) filesep 'screencfg.txt'];
end;
if nargin
  if length(In) > 3
    b = In;  setappdata(0,'border',b);
    if size(b,1)>1  % column vector comes here
      b = transpose(b);  setappdata(0,'border',b);
      fid = fopen(fi,'wt');
      prin(fid,'{ %d}\n',b); fclose(fid); % save border vector in file
    end;
    return;
  else
    b = getappdata(0,'border');
    if length(b) return; end;
    if exist(fi)
      b = dataread('file',fi,'%d')';
      if length(b)>3 setappdata(0,'border',b); return; end;
    end;
  end;
end;

% We are here because no argument was provided to screencfg
% or because the border vector could not be found either in
% the border property or in the screencfg.txt file.
%
% First lets determine the window border thickness:
%
set(0,'unit','pix');  sz = get(0,'screensize');
a = figure('menu','none','units','norm','outerposition',[0 0 1 1]);
set(a,'units','pix');  ha = feval('handle',a);
p = get(a,'pos');  BT = p(1)-1;  % get border thickness
Title = sz(4) - p(4) - 2*BT;     % get title bar height (see note below)
if foobar & exist('isprop') & feval('isprop',ha,'Javaframe')
  drawnow; % avoids Java errors
  feval('warning','off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
  jFig = get(ha,'JavaFrame');
  jFig.setMaximized(1);
  for k=1:100 % wait at most 1 second for the maximize command to take effect
    pause(.01); q = get(a,'pos');  if any(p~=q) break; end;
  end;
  TaskH = 0;  TaskW = 0;
  if q(2)>9           loc = 'bottom';  TaskH = q(2)-1;
  elseif q(1)>9       loc = 'left';    TaskW = q(1)-1;
  elseif q(3)>sz(3)-9 loc = 'top';     TaskH = sz(4) - q(4) - Title;
  else                loc = 'right';   TaskW = sz(3) - q(3);
  end;
  b = bCalc(fi,loc,BT,Title,TaskH,TaskW);  % calculate border vector
  delete(a);
  return;
end;
delete(a);
  
% Title Bar size note: ---------------------------------------------------------
% If the figure menu bar is enabled or if any of the figure toolbars are enabled
% the window will grow taller which might cause the title bar to fall of the top
% edge of the screen. This could be prevented by increasing the "Title" constant
% by about 21 for the menu bar and by about 27 for each toolbar in use. However
% this isn't the best way since plt based programs don't often need the menu bar
% and the toolbars are needed even more rarely. So increasing the Title constant
% will prevent you from using all the available screen height. So it's better to
% leave the Title constant to value calculated above. Then if a toolbar is
% required, you can allocate the space for it using the 5th entry in the
% position vector. (See "figpos.m" for a description of how this works).
% Another approach is to use "shoveit" (a very old windows utility, but it still
% works for me even in windows 10). That utility detects when the title bar is
% lost and shoves the figure window lower so that you don't loose access to the
% close button.
% ------------------------------------------------------------------------------

% Unless you have a very old version of Matlab, this routine will have
% returned by now, and so you will not have much interest in what happens
% in the rest of this function.
%
% Since the automated procedure above for determining the screen configuration
% did not succeeed we will now use the predefined constants defined in the
% TaskbarSZ.m routine to specify the taskbar size and location.
%
% The border thickness (BT) and the title height are always able to be determined
% automatically (using the 'outerposition' property above) although you could still
% change those variables if you choose to by adding lines of code right after this
% comment paragraph. For instance if you set "BT = 0" then the inside of the Matlab
% window will still be visible, but the border may not be. Or you could include
% something like "BT = BT + 5" if you prefer that the figures be placed farther
% away from the screen edges. Likewise you could alter "Title" from its calculated
% value. Even if you set this to zero, the interior of the figure will still be
% visible, however the title bar may fall off the top edge of the screen which is
% not usually very convenient.

disp('Warning: screencfg.m could not determin the taskbar location automatically');
disp('Instead constants (which you may want to edit) within screencfg.m are used');
disp('You will see this warning only once.');

[loc,TaskH,TaskW] = TaskbarSZ;          % Call TaskbarSZ to get the taskbar size & location
b = bCalc(fi,loc,BT,Title,TaskH,TaskW); % calculate the border vector

% Although adjusting the 3 constants in TaskbarSZ is usually the easiest
% method for defining the screen area, an alternative method would be to
% comment out the previous two lines and specify the border vector directly
% using the 5 element border vector form. For example:

% b = [6 56 1100 1700 0];  % This would define an area of 1100x1700 pixels near
                           % the bottom left corner of your screen where you
                           % would like your Matlab figures to be placed.
                           % The fifth value (0) indicates that pixel
                           % coordinates are being used.

% b = [.5 5 75 90 1];      % This would define an area of 75% of your screen
                           % width and 90% of your screen height where your
                           % Matlab figures will be placed. The left edge of
                           % this window will be one half percent of the width
                           % away from the edge and the bottom edge will be
                           % 5% of the screen height from the bottom. The fifth
                           % value (1) indicates that normalized (percent)
                           % coordinates are being used.

return;

function b = bCalc(fi,loc,BT,Title,TaskH,TaskW)
  % Calulates the border vector and saves the result into file "fi" as
  % well as the 'border' application data variable of matlab's root object. 
  switch lower(loc(1))
    %                    left   bottom   right  top
    %                    -----  -------  -----  -----------
    case 'b', b = BT + [ 0      TaskH    0      Title       ];  % Taskbar at the bottom 
    case 't', b = BT + [ 0      0        0      Title+TaskH ];  % Taskbar at the top
    case 'l', b = BT + [ TaskW  0        0      Title       ];  % Taskbar at the left                             -------  --------------  --------  --------
    case 'r', b = BT + [ 0      0        TaskW  Title       ];  % Taskbar at the right
    case 'n', b = BT + [ 0      0        0      Title       ];  % Taskbar hidden or not used
    otherwise,  prin(1,'Warning from screencfg: "%s" is not a valid location string',loc);
  end;
  setappdata(0,'border',b);           % save border vector in root object
  fid = fopen(fi,'wt');
  prin(fid,'{ %d}\n',b); fclose(fid); % save border vector in file
