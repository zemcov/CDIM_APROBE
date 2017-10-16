% wfalltst.m ------------------------------------------------------------------
%
% This program demonstrates the use of "pltwater", a general
% purpose 3D plotting utility.
%
% A surface consisting of a sequence of sync functions is
% created (in z, a 800 x 200 array).
%
% We could have called pltwater with just a single argument (z)
% containing the data, but in this example we have included
% many parameters to tailor the display. These include the
% nT,skip,x,y,HelpTxt parameters which are described in the
% pltwater section of the help file as well as in the comments
% in pltwater.m. The remaining parameters included in the
% pltwater command in this example (HelpText,TraceC,CursorC,
% Title,^Fontsize,LableY,xy) are not unique to pltwater, so they
% are passed directly to plt and are described in the main plt
% programming section of the help file.

% ----- Author: ----- Paul Mennen
% ----- Email:  ----- paul@mennen.org

z = zeros(800,200);
x = -150:49;  f = 2;  j = .04;  m = .3;
for k=1:800
  if k==400 j=-j; m=-m; end;
  x=x+m;  f=f+j;  xx=x/f;
  y = 10*sin(xx)./xx;
  y(isnan(y)) = 1;
  z(k,:) = y;
end;
v = version;  v = sscanf(v(1:3),'%f');
if v<7  f = ' {\itsin(\pix)/x} ';       % function displayed (tex format)
else    f = ' {\it\color{yellow}sin(\pix)/x} ';
end;
b = '\diamondsuit ';                    % Title bullet (tex format)
                                 
t = ...                                 % plot title
   {[b 'A simple example demonstrating the use of the pltwater function'];
    [b 'Displays' f 'with sweeping origin and frequency                ']};

h = ...                                 % help text
   {'\bullet Click the "y" label (bottom edge) to advance one frame.' ...
    '\bullet Hold the mouse button down on that' ...
    '  same label to advance continuously.' ''...
    '\bullet Click on the black bar below the plot' ...
    '  to select the Y axis starting point.' '' ...
    '\bullet Press the start button to view the animation.' ...
    '\bullet Press the same button to stop the animation.' '' ...
    '\bullet Move the five sliders, and click on the' ...
    '  checkboxes to observe the effects.' '' ...
    '\bullet Note that all the plt cursoring features' ...
    '  you have learned for 2D plots still work' ...
    '  (zoom boxes, panning, peak/valley,' ...
    '  delta cursoring, etc.)' ...
    .03+.97i 'fontsize' 13 'color' [.9 .5 .5]};

pltwater(z,'nT',20,'skip',2,'x',10*(0:199)-500,'y',(0:799)/.7,...
 'Options','I','TraceC',[0 .8 1],'CursorC',[1 1 0],'^FontSize',13,'Title',t,...
 'HelpText',h,'LabelY','  Sync amplitude (Zaxis)','xy',[.17 .12 .81 .81]);
 