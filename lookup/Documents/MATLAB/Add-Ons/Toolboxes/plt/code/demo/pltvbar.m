% pltvbar.m -------------------------------------------------------------------
%
% This script demonstrates the use of Pvbar and Pebar to plot
% vertical bar plots and error bar plots respectively.
% Some other things to note about pltvbar are:
% - The first Pvbar in the argument list plots two functions on a single
%   trace (green) with the 1st function (phase1) defining the position
%   of the bottom of the vertical bars and the 2nd function (phase2)
%   defining the position of the tops of the bars.
% - The second Pvbar in the list plots 3 functions (called serp, bell1, and
%   bell2). The 3 columns of the first Pvbar argument define the x coordinates
%   for those three functions. The next argument (0) indicates that the bottom
%   of all the vertical bars is at y=0. The last vbar argument gives the
%   y coordinate for each of the 3 functions (one function per column).
% - The next pair (after the 'LineWidth') plots two traces corresponding to the
%   two columns of poly23. The 1st column is a 2nd order polynomial and the
%   2nd column is 3rd order.
% - The Pebar function creates two error bar traces, the 1st defined by the 1st
%   column of each of the 3 arguments and the 2nd defined by the 2nd column.
% - The 'LineWidth' argument appears in the middle of the plt call to change
%   the width of only the traces defined earlier in the argument list.
% - The 'TraceID' argument is used to assign names for each trace that are
%   appropriate for the data being displayed.
% - The 'xy' argument is used to widen the TraceID box to make room for the
%   longer than usual trace ID names, to move the MenuBox (making room for the
%   character data table) and to make the main axis slighly larger than the default.
% - The '+FontSize','+FontWeight','+FontAngle','+Xtick','+Ytick' arguments are
%   used to modify the main axis properties of the same name (without the plus).
% - The Grid pseudo object is used to create an 8x3 table of character data.
%   This table really doesn't have anything to do with the plot, but was
%   included just to demonstrate an unusual way to use this pseudo object.

% ----- Author: ----- Paul Mennen
% ----- Email:  ----- paul@mennen.org

x  = (0:.25:6)';  t  = (0:.01:1)';
serp  = 19 * x ./ (x.*x+1);
bell1 = 12 * exp(-(x-2.5).^2);  phase1 = 1.4 * exp(-2*t) .* sin(20*t) + 20;
bell2 = 12 * exp(-(x-4).^2);    phase2 = 3 * t .* cos(5*pi*(1-t).^3) + 16;
p2 = polyval([-0.7 4 8],x);     p3 = polyval([-0.35 3.5 -9 28],x);
poly23 = [p2 p3];               errval = [0*x+1 2*cos(7+x/2)];
Id = {'phase 1&2' 'serpentine' 'bell curve 1' 'bell curve 2' ...
      'quadradic' 'cubic' 'err-constant', 'err-cosine'};     % trace IDs
p = [-1 .004 .71  .08 .28;             % position: TraceID box
     -2 .01  .45  .05 .24;             % position: Menubox
     -3 .14  .072 .85+.78i .92+.6i];   % position: Main axis
plt('TraceID',Id,'Pos',[1060 700],'xy',p,'FigBKc',101020, ...
    Pvbar(6*t,phase1,phase2),Pvbar([x x+.05 x+.1],0,[serp bell1 bell2]), ...
    'LineWidth',3,'+Xtick',0:2:6,'+Ytick',[12 13.7 14.7 21.2 26.8], ...
    x,poly23,Pebar([x x],poly23,errval),'xlim',[-.1 6.2], ...
    '+FontSize',11,'+FontWeight','bold','+FontAngle','Italic');

% A figure somewhat similar to what is created by the above plt
% command could also be generated using the standard MatLab plot
% function (not that I would really recommend this) as follows:
% --------------------------------------------------------------
% hold on;
% h1 = plot(Pvbar(6*t,phase1,phase2),'LineWidth',3);
% h2 = plot(Pvbar([x x+.05 x+.1],0,[serp bell1 bell2]),'LineWidth',3);
% h3 = plot(x,poly23);
% h4 = plot(Pebar([x x],poly23,errval));
% set([h1;h2;h3;h4],{'color'},num2cell([get(gca,'ColorOrder'); .7 0 0],2));
% set(gcf,'Name','pltvbar','Pos',[10 50 1000 600]);
% set(gca,'xlim',[-.1 6.2]);
% legend(Id{:},-1);
% --------------------------------------------------------------

% Now we create the 8x3 character table. Although in a real situation
% the character data would have some meaning, but here we just fill in
% the table with random gibberish.

cf = get(gcf,'color');  ct = [1 .4 .4];    % figure and text colors
s = get(gcf,'pos'); fs = round(s(3)/75-2); % best font size for this figure size
ax = axes('ylim',[0 8],'ytick',1:7,'xtick',[-.1 .9],'xlim',[-1 1.6],...
          'pos',[.008 .1 .12 .32],'color',cf,'xcolor',cf,'ycolor',cf);
plt('grid',ax,'init',[.2 .2 .5]);          % create the 8x3 grid
for x = -1:1                               % create 3 columns of text objects
  for y = 0:7                              % create 8 rows of text objects
    s = char(floor(65+26*rand(1,3)-32*x)); % generate random text data
    text(x,y+.5,s,'color',ct,'fontname','Segoe Script','fontsize',fs);
  end;
end;
