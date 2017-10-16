% circles12.m -------------------------------------------------------
%
% This is a two part script. The first part creates 3 figures
% each showing a different solution to the following problem:
%
%      *****************************************************
%      *****************************************************
%      **                                                 **
%      **            The 12 circle problem:               **
%      **    Draw 12 circles in a plane so that every     **
%      **    circle is tangent to exactly 5 others.       **
%      **                                                 **
%      *****************************************************
%      *****************************************************
%
% - Demonstrates the utility of using complex numbers to
%   hold the x and y positions of the plotted points.
% - Demonstrates using "prin" to creating the Trace IDs.
% - Demonstrates how to make circles look true by using a zero in the
%   'Pos' argument (width or height). Also two of the plots are placed
%   as far towards the top of the screen as possible, which is done
%   by setting the "Ybottom" value equal to "inf".
% - Demonstrates how to use the 'Link' parameter to link all 4 figures
%   together so that when any of them are closed, the remaining 3 figures
%   are also closed.
% - Note that even though the calls to plt for solutions 1&2 specify
%   same screen location ('Pos' parameter) plt doesn't actually
%   plot them on top of each other. Instead a small offset is added
%   in this situation, a feature that makes it easier to create
%   many plt windows so that any of them can be easily selected
%   with the mouse.
% - The last figure (part 2) shows the use of the Nocursor and -All
%   options to make the cursor objects and menu box items invisible
%   as well as the 'Ticks' option to select axis tick marks instead
%   of the full grid lines.

% ----- Author: ----- Paul Mennen
% ----- Email:  ----- paul@mennen.org

function circles12(in)
  if nargin & ~in
     cbo = findobj(gcf,'style','push','vis','on');
     h = get(cbo,'user');  he = h{1};  e = h{3};  ht = h{4};  h = h{2};
     s = get(gcbo,'str');  c = 'stop rotation';
     if length(s)==13 set(gcbo,'str','start rotation'); return; end;
     set(cbo,'str',c);  m = 0;  tic;  pause(.001);
     while ishandle(cbo) & strcmp(get(cbo,'str'),c)
        s = plt('edit',he);  e = e.*exp(s^3 * .00005i);  m=m+1;
        if ~mod(m,99) set(ht,'str',sprintf('%.2f updates/sec',m/toc)); end;
        set(h,'x',real(e),'y',imag(e)); drawnow;
     end;
     return;
  end;
  N = 600;                        % number of points per circle
  cN = exp((1:N)*pi*2i/N)';       % N point unit circle

  % Solution #3 ------------------------------------------------------
  v = 1:4;  r = (12+5*v)./(12-v); % radii of vertical set of 4
  c = [v-1 9-v complex(4,7-r)];   % center location of all 12 circles
  r = [v v r];                    % radii of all 12 circles
  plt(cN*r + repmat(c,N,1),'FigName','12 Circles (solution 3)',...
      'LineWidth',2,'Options','Ticks I','Pos',[10 inf 640 669],...
      'Xlim',[-1.6  9.5],'Ylim',[-4.8 7.5],'LabelY','','LabelX','',...
      'TraceID',prin('{circle%d!row}',1:12));

  % Solutions #1 and 2 ----------------------------------------------
  % Note: there are 2 more solutions that are essentially combinations of
  %       solutions #1 and #2. If you find yet more solutions, please let me know!
  ID = prin('middle ~, outer ~, {group%d!row}',[1 1 1 1 1 2 2 2 2 2]);
  pi5 = pi/5;  s = 1/sin(pi5);  u5 = ones(1,5);
  c5 = exp((0:4)*pi5*2i);                      % 5 point unit circle
  rg1 = 1/(s-1);                               % radius of group 1 circles
  fg = gcf;  t = 1 + 2*rg1;
  rg2 = roots([s^2-1, -2*(s*sqrt(t)+rg1), t]); % radius of group 2 circles
  b = c5*s*rg1*exp(pi5*1i);
  for k = [2 1]
    c = [0 0 b c5*s*rg2(k)];                   % center location of all 12 circles
    r = [1 rg2(k)*(s+1) rg1*u5 rg2(k)*u5];     % radii of all 12 circles
    plt(cN*r + repmat(c,N,1),'LabelY','','LabelX','','Pos',[600 0],...
       'FigName',sprintf('12 Circles (solution %d)',k),...
       'Link',fg,'Options','Ticks I','TraceID',ID,'LineWidth',2);
  end;
  
  % The second part of this script (below) draws the solution to the
  % following problem:
  %
  %      ********************************************************
  %      ********************************************************
  %      **                                                    **
  %      **   Divide a circle into n congruent parts so that   **
  %      **   at least one part does not touch the center.     **
  %      **       (Hint: as far as I know, the only            **
  %      **              solution uses n = 12)                 **
  %      **                                                    **
  %      ********************************************************
  %      ********************************************************
  %
  % A button and an edit pseudo object is also added below the plot
  % which lets you rotate the image and control the rotation speed
  %
  
  N6 = N/6;  f = 1:6;  na = NaN+f;  cN = cN';
  a = repmat([3 4 5 6 1 2]*N6,N6,1);     % index points for arc centers
  d = cN + cN(a(:));                     % N point circle with translated centers
  e = [reshape(transpose(d),N6,6); na];  % insert NaNs to eliminate stray lines
  f = [na; cN(N6*f); d(N6*(f-.5))];      % draw the lines bisecting the 6 congruent parts
  e = [e(:)' f(:)'];                     % append the bisecting lines to the 6 arcs
  h = plt(e,cN,'Pos',[662 inf 0 400],'Figname','12 circles (part 2)',...
          'Link',fg,'Options','Ticks Nocur -All I','TraceID',['div ';'circ'],...
          'LabelX','','LabelY','','Xlim',[-1.1 1.1],'Ylim',[-1.1 1.1]);
  set(gca,'xtick',[],'ytick',[]);                                    % remove tick marks
  he = plt('edit',[140 8 35 16],[3 1 9],'label','Rotation spe~ed:'); % rotation speed
  ht = text(.3,-1.24,'abc','color',[.3 .7 1]);
  bt = uicontrol('str','start rotation','pos',[190 7 75 20],'user',{he h(1) e ht},...
       'callback','circles12(0);');
  if ~nargin circles12(0); end; % start rotation unless called with nonzero argument
