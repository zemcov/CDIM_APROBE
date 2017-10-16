% pltquiv.m ---------------------------------------------------------
%
% - This function demonstrates the plotting of quivers, polynomial
%   interpolation, and the use of several of the plt callback
%   functions (moveCB, TIDcback, MotionEdit).
% - The Pquiv.m function appears three times in the plt argument list
%   to plot three vector fields. The first two vector fields (named
%   velocity1 & velocity2) both have their tail locations specified
%   by f (also plotted on the green trace called humps/20) and the
%   arrow lengths are specified by v1 and v2 respectively. The first
%   of these Pquiv calls is somewhat similar to the MatLab command
%   quiver(real(f),imag(f),real(v1),imag(v1)); The third Pquiv call
%   generates the vector field shown in yellow which includes only
%   six vectors. 
% - Uses the xy parameter to make room for long Trace ID names
% - Uses tex commands (e.g. \uparrow) inside Trace ID names
% - Reassigns menu box items. In this example, the 'LinX' button is
%   replaced by a 'Filter' button. Its button down function (which is
%   executed when you click on 'Filter') searches for the 4th trace
%   (findobj) and swaps the contents of its user data and y-axis data.
% - The 'HelpText' parameter is used to identify features of the plot
%   and to explain how to modify the Hermite interpolated function.
%   This help text disappears as soon as you move one of the yellow
%   arrows (as described in the yellow help text).
% - Using NaNs (not a number) to blank out portions of a trace. In this 
%   case, the NaNs were inserted into the x coordinate data, although
%   using the y or z coordinates for this purpose works equally as well.
% - Uses the TraceID callback function (TIDcback) to perform an action
%   when you click on a trace ID. For example, when you click on the
%   forth trace ID (humps+rand) this will appear in the command window:
%   "A trace named humps+rand and color [1 0 0] was toggled".
%   Although this TraceID callback is not particularly useful, it was
%   contrived to demonstrate all the @ substitutions.
% - A MotionEdit function is provided which serves these 3 purposes:
%   1.) The trace data is updated as you drag the edit cursor. Without
%       the MotionEdit function the trace data is only updated when you
%       release the mouse button after the edit cursor has been moved
%       to the desired position. (Trying this on trace 1 will give you
%       a good feel for what this means.)
%   2.) For the quiver traces, moving the arrow position would not normally
%       move the "v" portion of the arrow head as you would hope. This
%       MotionEdit function solves this problem by calling Pquiv as the
%       arrow is being dragged.
%   3.) If you move one of the arrows associated with trace 5 (vectorField)
%       then trace 6 is updated based on a polynomial interpolation which
%       is designed to go thru the tails of all six of the the trace 5 vectors.
%       The derivatives of this polynomial are also constrained so that it
%       matches the slopes of these vectors as well. Use the data editing
%       feature to move the head or the tail of any of these vectors and
%       watch how the interpolated data on trace 6 (blue) is updated in
%       real time to follow the vector field.

% ----- Author: ----- Paul Mennen
% ----- Email:  ----- paul@mennen.org

function pltquiv(a)

if nargin
  if ischar(a)                                % here for filter tag callback
    h = findobj(gcf,'tag','h4');              % swap y data with user data
    set(h,'y',get(h,'user'),'user',get(h,'y'));
  else                                        % here for MotionEdit function
    plt helptext;                             % turn helptext off
    hact = a{3};                              % hact is the handle of the moving edit cursor
    h = get(hact,'user');  h = h{1};          % h is handle of the line being edited
    xy = getxy(h);  n = length(xy);           % get current x & y data for edited trace
    xy(a{9}) = getxy(hact);                   % replace data at current index with edit marker's position
    if ~mod(n,7)                              % here for quiver traces
      n7 = 1:7:n;  a1 = xy(n7);               % extract tail positions from quiver data
      a2 = xy(n7+1)-a1;  xy = Pquiv(a1,a2);   % extract head position anc compute new quiver trace
      if length(a1) == 6                      % if editing vector field, do Hermite interp on trace 6
        h6 = findobj(gcf,'tag','Hermite');    % find the trace 6 handle
        a1 = transpose(a1);  a2 = transpose(a2);
        set(h6,'y',herm(real(a1),imag(a1),real(a2),imag(a2),get(h6,'x'))); % update trace 6 data
      end;
    end;
    setxy(h,xy);                              % update data of edited trace
  end;
else
  x  = (0:.1:5)';  x4 = (0:.01:5)'; x5 = (.5:.8:5)'; x6 = (0:.02:5)'; 
  t = x/5;     y = (.02 + x/100)  .* humps(t);
  t4 = x4/5;  y4 = (.02 + x4/100) .* humps(t4) + 2.5 + rand(size(x4))/2;
  f = complex(x,y);
  v1 = complex(exp(-2*t).*sin(20*t), t .* cos(15*(1-t).^3));
  v2 = .7*exp(-t) .* exp(10i * t.^2);
  y6 = x6;  y5 = humps(x5/5)/25 + 4;  % specify vector field tail coordinates
  x5d = [29; 24; 26; 61; 44; 36]/100; % specify vector field head coordinates (tail offset)
  y5d = [72; 50;-91;-18; 67;-43]/100;
  p  = [1 .190 .110 .795 .870;        % plotting axis position
       -1 .010 .770 .140 .200];       % TraceID box position
  htxt = {'NaN gap' .385+.537i 'fontsize' 10 'color' [1 0 .1] 2i ...
          'Click on "Filter"' 'in the menu box' .785+.463i 'color' [1 0 .1] 'fontangle' 'italic' 2i ...
          'Click on one of the yellow arrowheads, then RIGHT click' ...
          'on the Ycursor edit box and select "Modify" from the menu.' ...
          'Then drag the arrow head and note that the blue trace moves' ...
          .36+.99i 'fontsize' 10 'color' [.8 .8 0] 2i ...
          'in a way that its slope matches the direction of the' ...
          'arrow. Try this again, except click on one of the arrow' ...
          'tails instead.' .41+.88i 'fontsize' 10 'color' [.8 .8 0]};
  tid = {'humps \div 20'  'velocity1 \uparrow'  'velocity2 \uparrow' ...
         'humps+rand'     'vectorField'         'HermiteInterp'          };
  tracec = [0 1 0; 1 0 1; 0 1 1; 1 0 0; 1 1 0; .2 .6 1];
% Note: Identical results are achieved when:   Pquiv(f,v1),Pquiv(f,v2)
%                            is replaced by:   Pquiv([f f],[v1 v2])
  h = plt(f,Pquiv(f,v1),Pquiv(f,v2),x4,y4,Pquiv(x5,y5,x5d,y5d),x6,y6,...
      'xy',p,'Xlim',[-.2 5.2],'Ylim',[0 8],'TraceID',tid,'Options','-Y-M I','TIDcback',...
      ['prin(1,"A trace named  %s and color [{%3w! }]] was toggled\n",' ...
        'get(@TID,"string"),get(@LINE,"color"));'],'FigBKc',30,'TRACEc',tracec,...
      'HelpText',htxt,'MotionEdit','pltquiv');
  set(h(1),'LineWidth',2);
  y4 = filter([1 1 1]/3,1,y4); y4 = y4([3 3:end end]); % smoothed y4
  set(h(4),'tag','h4','user',y4); % save smoothed y4 in trace user data
  set(findobj(gcf,'string','LinX'),'str','Filter','ButtonDownFcn','pltquiv filt;');
  x4(205:235) = NaN;  set(h(4),'x',x4);  % create a gap in trace 4
  set(h(6),'tag','Hermite','y',herm(x5,y5,x5d,y5d,x6));
end;

function c = getxy(h)   % get the x and y coordinates of object h
  c = complex(get(h,'x'),get(h,'y'));

function setxy(h,c)     % set the x and y coordinates of object h
  set(h,'x',real(c),'y',imag(c));

function y = herm(x,y,xd,yd,xx) % Hermite interpolation
  n = length(x);  m = 2*n;  A = zeros(n,m);  B = A;  c = ones(n,1);
  for k = 1:m
    A(:,k) = c;  if k<m  B(:,k+1) = k*c;  c=c.*x; end;
  end;
  y = polyval(flipud([A; B] \ [y; yd./xd]),xx);
