% curves.m ----------------------------------------------------------
%
% This program allows you to explore many classic 2D curves
% by allowing you to vary parameters and immediately observe
% the result. This GUI requires many controls to occupy a relatively
% small space since otherwise there would not be much room left
% in the window for the most important part (the plot). The pseudo
% objects provided by plt are perfect for this since they take up
% much less room than the traditional uicontrols. In addition, the
% plt('edit') pseudo objects provide a much easier way to modify the
% numeric values nearly matching the convenience of a slider object.
%
% After starting curves.m, right click on the curve name at the
% bottom of the figure to cycle thru the 42 different cool looking
% curve displays. (Left click on the curve name as well to select from
% the complete list of curves.) The equations in (reddish) orange above
% the curve name, are not only used as the x-axis label, but they are
% also the exact equations that are used to compute the points plotted
% on the graph. The 10 controls that appear above the graph allow
% you to modify the vector t, and the constants a, b, and c that
% appear in these equations, as well as the x/y offsets and line
% styles for each trace. Experiment by both right and left clicking
% on these controls. For the cases when more than one trace is
% plotted, the first control on the left (called trace) indicates
% which trace is affected by the other nine controls above the graph.
% Note that when you left click on a control, it will increase or
% decrease depending on whether you click on the left or right side
% of the text string. Separate values for a, b, and c are saved for
% each trace of a multi-trace plot. This explains the variety of curves
% that can appear for a single set of equations (shown below the
% graph). LEFT clicking on the "Default" button will reset all these
% parameters to their initial settings for only the function currently
% selected. It will have no effect on the settings for the remaining
% 41 curves. However if you RIGHT click on the "Default" button, then
% the settings for all 42 curves will be reset to the values they
% were initialized to when the curves program started.
%
% You can also cycle quickly through all 42 curve names by clicking
% on the "Cycle" button. (Click on the button again to stop.)
% Usually this program is started by typing "curves", however if you
% start it by typing curves('go') or the equivalent command form
% "curves go", then immediately after starting, it will cycle once
% through all 42 curves (at a default rate of one second per curve).
% demoplt.m calls curves this way which explains why it starts cycling
% immediately. If you want the cycle to proceed at a different rate,
% you may select the desired rate with the delay popup just below the
% Cycle button. When the last curve is displayed the cycling stops
% and the time it took to cycle thru all the curves is displayed in
% the upper left corner of the figure. (This a useful as a speed
% performance measure if you set the delay to zero.)
%
% Note the help text (in purple, center left) tells you just enough to
% get started using the program, even if you haven't read any of the
% documentation. This was added using the 'HelpText' parameter. Selecting
% a different curve (with the popup pseudo object) will erase the help
% text and right clicking on the "Help" tag in the MenuBox will make it
% reappear.
%
% For most of the curves there is also some text (in grey) in the plot
% area that describe some technical or historical information related
% to the curve, hopefully making this program more interesting and
% educational. The text is embedded in the same table that stores the
% curve name, equations, and parameters. At the beginning of the text
% string are some codes that specify the text position and font size.


% ----- Author: ----- Paul Mennen
% ----- Email:  ----- paul@mennen.org

function Out = curves(In)

                               % define columns of CRq ----------
qName=1;                       % function name
qT   =2;                       % t vector definition (1x3)
qXlim=3;  qYlim=4;             % xlim (1x2)  ylim (1x2)
qa   =5;  qb   =6;   qc=7;     % a/b/c trace parameters
qSty =8;                       % trace style
qXoff=9;  qYoff=10;            % trace position (x/y offsets)
qEval=11; qNote=12;            % function eval string, trace notes

                               % define user edit strings --------
TXtrc=1;                       % trace number to edit
TXa  =2;  TXb  =3;  TXc  =4;   % a/b/c trace parameters
TXxof=5;  TXyof=6;             % trace position (x/y offsets)
TXstp=7;  TXtmn=8;  TXtmx=9;   % t vector (# of steps, min, max)
TXsty=10;                      % trace style

if ~nargin | ischar(In)
  CRq = curves(-1);
  htxt = {'right or left' 'click on the' 'curve name' 'below the' 'plot' -.165+.65i ...
          'color',[1 .5 1],'fontsize',15};  % define help text
  p = [1 .148 .140 .837 .788;  % position: Main plot
      -1 .004 .670 .086 .216;  % position: TraceID box
     210 .140 .010 .020 .030;  % posiiton: x cursor label
     208 .165 .010 .070 .030;  % position: x cursor
     209 .800 .010 .020 .030;  % position: y cursor label
     206 .825 .010 .070 .030;  % position: y cursor
     317 .160 .380 .000 .000]; % position: y cursor ID
  CRlines = pltinit(1,ones(1,6),'Pos',[960 700],'xy',p,...          % create plot figure
                'LabelY','','FigBKc',061206,'Options','IT-X-Y');
  set(gcf,'defaultuicontrolunits','norm','defaulttextunits','norm');
  CRn = text(0,0,'curve notes','units','norm',...                    % create curve notes
             'fontsize',16,'vertical','top');
  ax = gca;
  set(ax,'TickLen',[0 0]);
  CRb = flipud(get(findobj(gcf,'user','TraceID'),'child'));          % get TraceIDs
  tx = {'Trace' 'a' 'b' 'c' 'Xoffset' 'Yoffset' 't Steps' 't Min' 't Max' 'Style' };
  tl = {' line';' --';' :';' -.';' +';' o';' *';' .';' x';' s';' d';' ^';' v';' >';' <';' p';' h'};
  for k=1:length(tx)    % create the edit and popup psuedo objects above the main axis
    cb = ['curves(' int2str(k) ')'];  x = .07 + k*.086;
    if k==TXsty CRi(k) = plt('pop', [x .505 .04 .450],tl,'callbk',cb,'labely',tx{k});
                CRj(k) = plt('pop',CRi(k),'get','label');
    else        CRi(k) = plt('edit',[x .940 .06 .025],0, 'callbk',cb,'label',{tx{k} [.06 .023i]});
                CRj(k) = plt('edit',CRi(k),'get','label');
    end;
  end;
  plt('edit',CRi(TXtrc),'minmax',[1 99]);
  axes(ax);
  % create the main function selection popup
  CRp = plt('pop',[.43 .01 .24 .98],CRq(:,1),'offset',[.4 .9],'hide',[CRi CRj],'horiz','center',...
            'fontsize',2*get(get(ax,'Xlabel'),'fontsize'),'callbk','curves(0)');
  % create the cycle delay popup (seconds)
  CRd = plt('pop',[.053 .155 .04 .2],[0 .1 .2 .5 1 2 5],'index',5,'label','delay:');
  CRe = uicontrol('pos',[0 .96 .13 .03],'style','text','backgr',get(gcf,'color'),'foregr',[1 .7 .2]);
  set(gcf,'user',{CRlines CRq CRp CRi CRb CRd CRn CRe}); % save all handles & parameters in figure user data
  % create Cylcle & Defaults buttons
  uicontrol('str','Cycle','pos',[.01 .37 .065 .03],'callback','curves(-2)','fontsize',10);
  uicontrol('str','defaults','pos',[.01 .91 .055 .028],'callback','curves(-3)','buttond','curves(-4)');
  g = gcf;
  if nargin curves(-2);  % curves('go') - start cycling
  else curves(0);        % curves()     - update plot with curve #1
  end;
  if gcf==g plt('HelpText','on',htxt); end; % enable the help text
  return;
end; % end if ~nargin | ischar(In)

if In==-1  % This function "curves(-1)" returns a cell array with 42 rows
           % (i.e. one row for each curve name in the curve popup) and 12 columns.
           % The columns contain the following information:
  %
  % Column  value  meaning
  % ------  -----  ----------------------------------------------------------------------------
  %   1     name   The function name appearing in the function popup as well as in large 20
  %                point yellow characters at the bottom of the plot. (Below the x-axis label).
  %   2     tVec   [#Points FirstVal LastVal]
  %                Specifies the t vector which may have any use in the eval string, but is
  %                most comonly used as the x vector.
  %   3     Xlim   [Xleft Xright]
  %                Specifies the initial x-axis limits to be used when viewing this function
  %   4     Ylim   [Ylower Yupper]
  %                Specifies the initial y-axis limits to be used when viewing this function
  %  5,6,7  a,b,c  Specifies the value the equation parameters a,b,c respectively.
  %  8,9,10 Style  Specifes the line style, Xoffset, and Yoffset respectively for each trace.
  %         Xoff   The values for columns 4 thru 9 must be either a scalar (where the same
  %         Yoff   value is to be used of every trace) or a nx1 vector (where n is the number
  %                of traces plotted.
  %  11     eval   This is a string which when evaluated must define the variables x and y
  %                containing the locations of each point to be plotted. If the first charater
  %                is an "@" then the string 'x=r*cos(t); y=r*sin(t);' is appended to the end
  %                of the eval string. If the first character is a "~" then the string
  %                'x=real(z); y=imag(z)' is appended to the end of the eval string. (The @ or
  %                ~ charager itself is of course removed from the eval string). Besides its use
  %                for evaluating the trace coordinates, the eval string is also used as the
  %                x-axis label on the plot. To reduce clutter, non essential portions of this
  %                eval string may be removed from the x-axis label by surrounding them with
  %                underscore characters. These portions so deliminated are still evaluated.
  %                Also the underscore characters themselves are of course removed before
  %                the string is evaluated.
  %  12     note   A note string which appears in dim gray characters in the plot area.
  %                Normally this string appears in 12 point font, the the font size may be
  %                changed by including the characters "~xx" anywhere in the note string.
  %                For example, with the note string "ABC~16DEF~08GHI" the first 3, middle
  %                3 and last 3 characters will be rendered in 12,16, and 8 point type
  %                respectively. By default the note string will begin at location [.66 .91]
  %                (normalized axis coordinates). This default may be changed by prepending
  %                the string "x y$" to the beginning of the note string. x and y must be in
  %                normalized axis units.

  P2 = [0 2*pi];
  % Curve Name             [n tmin tmax]  Xlim        Ylim        a                   b                 c             Style         Xoffset             Yoffset
  Out = ...
  {'Ampersand            ' [306 P2]       [-1.7 2.5]  [-1.3 1.3]  [1110 1107]         [150 153]         [330 310]     [6 8]         [0 2.2]             0                   ...
                           '@C=cos(2*t); A=4*C+2*cos(4*t)+18; B=(a*cos(t)+b*cos(3*t))/30; C=c*C/30+8; r=(sqrt(B.^2-4*A.*C)-B)./A;_r(find(imag(r)))=NaN;_' ...
                           '2 66$The equations:|     x = r cos(t)|     y = r sin(t)|are automatically appended to|polar equations such as this.'
   'Arachnida            ' [196 P2]       [-5.6 1.2]  [-1.4 1.4]  [2 3 5]             [3 2 4]           0             [1 8 1]       [0 -2.3 -4]         0                   ...
                           '@r=sin(a*t)./sin(b*t);' '47 26$~18This curve owes its|name to its spider-like|shape.'
   'Archimedean Spiral   ' [800 0 23]     [-12 54]    [-8 40]    [-1 -2 1 1.05 .5 .5] [30 600 .4 .4 3.5 -3.5]   0     1             [43 43 0 0 20 20]   [0 0 3 3 23 23]     ...
                           '@r=b.*t.^a;' '30 10$~12a = rate at which the curve spirals outward|b = size scale factor (negative for 180\circ rotation)'
   'Bell curve           ' [800 -4 4]     [-4 4]      [-.1 1.1]   [5 7 10 15 20 25]   0                 0             1             0                   0                   ...
                           'x=t; a=a/10; y=exp(-x.^2/(2*a.^2));' '41 15$~28\sigma = a/10'
   'Bicuspid curve       ' [9999 -1 1]    [-1.7 1.7]  [-1.2 1.2]  [1 1 -1 -1]         [1 -1 1 -1]       0             9             0                   0                   ...
                           'x=a*sqrt(1+b*sqrt((1+t).^2.*(1-t.^2))); y=t;_x(find(imag(x)))=NaN;_' '18 81$~30(1+x) (1-x)^3 = (y^2-1)^2||A quartic curve with two cusps.'
   'Black body radiation ' [200 100 2050] [100 2050]  [-1 28]     [6000:-500:3500]    0.01438775        1e-28         1             0                   0                   ...
                           'x=t; v=1e9./t; y=c*v.^5./(exp(b*v/a)-1);' ['36 97$~18Solved in 1901 by Max Planck, leading|to the theory of quantum mechanics.||    ' ...
                           'x = wavelength (nm)|    y = energy density per unit wavelength|    a = temperature (\circK)|    b = hc/k (Planck, light, Boltzman constants)']
   'Bullet nose          ' [300 P2]       [-9 9]      [-1.1 1.1]  [3 4 5 6 8 10]      0                 0             3             0                   0                   ...
                           'x=a*cot(t); y=cos(t);_y(find(abs(t-pi)<1e-6))=NaN;_' '60 54$~24a^2 y^2 - b^2 x^2 = x^2 y^2'
   'Butterfly curve      ' [2000 0 24*pi] [-3.9 3.9]  [-2.8 4.2]  24                  5                 4             1             0                   0                   ...
                           '@r=exp(sin(t))-2*cos(c*t)+sin((2*t-pi)/a).^b;' '31 96$~14Discovered by Temple Fay in 1989.'
   'Catenary             ' [200 -pi pi]   [-1.7 1.7]  [-.2 5.9]   [15 10 7 4 2 1]     0                 0            [1 1 1 1 1 10] 0                   0                   ...
                           'a=a/10; x=t; y=a*cosh(t/a);' ...
                           '2 18$~12The shape a cable assumes under|its own weight supported at its ends.|Equation derived in 1691 by|Liebniz, Huygens, & Johann Bernoulli.'
   'Cissoid of Diocles   ' [800 1.9 4.4]  [-.6 10.2]  [-13 13]    [5 6 7 8 9 10]      0                 0             1             [0 .5 1 1.5 2 2.5]  0                   ...
                           '@r=a*tan(t).*sin(t);' ...
                           '2 97$~14Diocles constructed this curve in 160BC.||y^2 = x^3 / (1-x)||The area between the curve (a=1)|and its asymptote = \pi/4.'
   'Cochleoid            ' [800 0 8*pi]   [-.34 2.1]  [-1 .85]    [1 -1 1 1]          [0 0 -40 30]      0             1             [0 0 1.38 1.42]     [0 0 0 -.01]        ...
                           '@t=a*t; r=sin(t+b/20)./t;' '21 66$The cochleoid (i.e. snail)|was named in 1884 (b=0)||Also known as the|\itouija board curve.'
   'Cocked hat curve     ' [800 0 8*pi]   [-1.5 1.5]  [-3.5 14]   [-2 -1 0 1 2 5]     0                 0             1             0                   [0 1.5 3 4.5 6 7]   ...
                           'x=sin(t); y=cos(t); y=y.^2.*(a+y)./(1+x.^2);' '2 96$Also known as the \itbicorn curve\rm.||(x^2 + 2y - 1)^2 = y^2 (1 - x^2)'
   'Conchoid of Nicomedes' [800 P2]       [-15 15]    [-3.3 5.4]  [4 3 2 1 2 1]       [1 1 1 1 3 2]     0             1             0                   0                   ...
                           '@r=a+b*csc(t);' '4 33$Nicomedes described a tool|to create this curve in 200BC.||Also known as a\it cochloid\rm|or a \itshell curve.'
   'Cranioid             ' [800 P2]       [-17 17]    [-9 21]     6                   13                16            8             0                   0                   ...
                           '@r=a*sin(t)+b*sqrt(1-c*cos(t).^2/20);' ...
                           '25 71$~18This quartic curve is also|known as an \iteyeball curve.\rm||(x^2 + y^2)^2 = 2y^2(x+y) + (2b^2 - b^2c -1)x^2'
   'Cycloid              ' [800 0 18]     [17 160]    [-12 64]    [10 7 4 13 16 -10]  [10 7 4 13 16 10] 0             [8 3 3 1 1 8] 0                   [50 22 27 40 8 0]   ...
                           'x=10*t-a*sin(t); y=1-b*cos(t);' ...
                           '40 78$~14Point on rim of rolling wheel|~12a = b  (cycloid)|a = -b  (inverted cycloid)|a = 10 is the no slip condition'
   'Devil''s curve       ' [2000 -20 20]  [-23 57]    [-30 39]    [96 66]             100               0             [1 6]         [0 35]              0                   ...
                           '_x=[t NaN t NaN t NaN t];_t=t.^2; d=a^2+4*t.*(t-b);_d(find(d<0))=NaN;_d=sqrt(d); y=[a+d 0 a-d];_y(find(y<0))=NaN;_y=sqrt(y); y=[y 0 -y];' ...
                           ['6 99$~18y^2(y^2-a) = x^2(x^2-b)             Also known as the \itdevil on two sticks\rm.|' ...
                            'When a/b=0.96 (trace 1) it''s also called the \itElectric motor curve.']
   'Dumbbell curve       ' [801 -1 1]     [-2 2]      [-.6 2]     [0 23 7 30 37 53]   0                 0             1             [0 1 -1 0 -1 1]     [0 1 1 0 1 1]       ...
                           '@r=sqrt(t.^2+t.^4-t.^6); t=acos(t./r)+(a*pi/30);' ...
                           '27 57$Polar form was used to allow rotations,|but it''s simpler in Cartesian form:|             y^2 = x^4 - x^6' 
   'Ellipse & evolute    ' [800 0 6*pi]   [-31 31]    [-1.1 1.1]  [30 27 24 21 18 15] 0                 0             1             0                   0                   ...
                           'v=bitor(floor(t/pi),1); x=a.*cos(t).^v; y=sin(t).^v;' ''
   'Epispiral            ' [800 2*P2]     [-8 42]     [-11 23]    [.1 1/3 .5 3 4 66]  [4 6 6 11 8 11]   0             1             [-5 2 9 0 17 33]    [17 17 17 0 0 0]    ...
                           '@r=sec(a*t); r(find(abs(r)>b))=NaN;' ['51 98$Shown in order of increasing a values.||' ...
                           'Traces 2,3,4 are also known as:|  - Trisectrix of Maclauren (a=1/3)|  - Trisectrix of Delange (a=1/2)|  - Trefoil (a=3)']
   'Epitrochoid          ' [800 5*P2]     [-20 54]    [-9 42]     [8 5 14 4 2 2]      [5 3 1 2 2 3]     [5 5 1 2 2 3] [1 1 1 9 8 1] [0 36 36 46 2 26]   [10 24 24 0 10 0]   ...
                           '~z=(a+b)*exp(it)-c*exp((1+a/b)*it);' ['3 99$~20The curve is traced by an arm of length|' ...
                           'c attached to the center of a circle|of radius b which is rolling on the|outside of a circle of radius a.']
   'Euler''s spiral      ' [200 -3 3]     [-90 95]    [-72 71]    [93 70 93 32]       [0 24 74 82]      0             [6 6 6 3]     [0 0 0 -55]         [0 0 0 56]          ...
                           '~z=a*fresnel(t).*exp(b*.03i);' ['55.8 21$~12Following the curve path with uniform speed|gives a constant angular acceleration, i.e. the|curvature' ...
                           ' is proportional to arc length (d\phi/ds = s).|This leads to the fresnel integral, the only curve|in this collection requiring a helper function.']
   'Fish Curve           ' [300 P2]       [-23 23]    [-12.5 15]  [-20 5 5 2 2 -9]    [.7*ones(1,5) 1]  1             [9 3 3 1 1 2] [0 13 13 14 14 -7]  [0 9 -9 9 -9 0]     ...
                           '~p=sin(t); q=cos(t);  z=a*p.*q.*(c./p-b*p./q+i);' '2 98$~24A quartic curve:   (2x^2+y^2)^2 + 2y^2 = \surd2(4x^2-6y^2)x + 2x^2'
   'Folium of Descartes  ' [801 -6 6]     [-3 2.2]    [-2 1.7]    [1 -.6]             0                 0             [3 6]         [0 -.85]            [0 -.85]            ...
                           't=t.^3; v=1+t.^3; x=3*a*t./v; y=x.*t;' '2 62$~20x^3 + y^3 = xy||Rene Descartes was|the first to examine|this curve in 1638.'
   'Fourier Series       ' [800 -2 12]    [-2 12]     [-2.5 11.5] [2 2 1 2 4 1]       [1 0 1 1 1 1]     [2 1 1 1 1 2] 1             0                [87 73 44 22 0 -12]/10 ...
                           'x=t; v=0:25; w=1+a*v; v=b*v; y=((-1).^v./(w.^c))*sin(w''*t);' ['2 99$~14a=1/2: all harmonics/only odd harmonics      ' ...
                           'b=0/1: terms are positive/alternate in sign|Each term is scaled by the harmonic # raised to the -c power']
   'Gear Curve           ' [800 P2]       [-3 3]      [-2.1 2.3]  [1 1.4 1.8]         8                 [4 9 15]      1             0                   0                   ...
                           '@r=a+tanh(b*sin(c*t))/b;' '2 99$~20Outer/inner radius: a \pm 1/b|Number of teeth: c'
   'Hypotrochoid         ' [800 0 14*pi]  [-3.5 15]   [-3.2 9]    [3 5 4 5 pi 2]      [1 1 1 3 1 1.2]   [1.2 -1 .5 -3 1 2]  1       [13 7 0 7 0 12]     [0 2 2 2 2 6]       ...
                           '~z=(a-b)*exp(it)-c*exp((1-a/b)*it);' ['5 97$~20The curve is traced by an arm of length|' ...
                           'c attached to the center of a circle|of radius b which is rolling on the|inside of a circle of radius a.']
   'Lemniscate           ' [400 P2]      [-12.4 11.3] [-2 20] [0 1.01 1.005 .9 .5 .9] [0 1 1.1 5 6 -1] [5.7 4 4 2 3 5]  1           [-6 -6 -6 6 6 6]  [12.5 7 1.5 15.5 8 1] ...
                           '@r=c*sqrt(cos(2*t) + b*sqrt(a^4-(sin(2*t)).^2));_r=real(r);_' ['2 98$These curves are Cassini ovals: r^2 = 2cos(2t) + (a-1)/r^2|' ...
                           'The special case a=1 (trace 1) is known as the|\itlemniscate of Bernoulli\rm. (Jacob Bernoulli|named it the \itlemniscus\rm in 1694.)']
   'Limacon              ' [200 3*P2]     [-120 100]  [-68 94]    [48 42 20 3]        [48 32 40 48]     [1 1 1 3]     [1 8 1 1]     [0 15 15 -80]       [0 0 0 -17]         ...
                           '@r=a+b*cos(t/c);' ['3 96$With c=1 this is called the \itlimacon (snail) of Pascal\rm, named after|Etienne Pascal (father of Blaise Pascal).||' ...
                           'With b=1 (trace 1) it''s known as a \itcardioid\rm.||With c\neq1 (trace 4) it''s known as|the \itbotanic curve.']
   'Lissajous curves     ' [400 P2]       [-9 11]    [-1.12 1.3]  [1 5 1 1]           [2 4 2 3]         [99 99 2 1]   [1 1 8 8]     [6 -.5 -7 9]        0                   ...
                           'x=a.*sin(b*t+pi/c); y=sin(t);' ['2 99$~14Discovered in 1815 by Nathaniel Bowditch (sometimes called \itBowditch curves\rm).|' ...
                           'Rediscoverd in 1857 by Jules-Antoine Lissajous while doing his experiments with sound.']
   'Maclaurin Trisectrix ' [800 1.8 4.5]  [-.85 1.66] [-1.4 1.7]  [-5 -3 -1 1 3 5]    0                 0             1             0                   0                   ...
                           '@r=sin(3*t)./sin(2*t); t=t+a*pi/60;' ['37 99$~20In addition to serving as the x-axis label,|the red text below the graph is the|' ...
                           'actual string that Matlab evaluates|to create the curves in the plot.']
   'Marijuana leaf       ' [4000 P2]      [-500 500]  [-130 820]  [8 2 0 0]           [24 10 4 2]       [10 -2 3 1]   1             [0 -300 256 -300]   [0 740 500 620]     ...
                           '@r=(1+.9*cos(a*t)).*(c+cos(b*t)).*(18+cos(200*t)).*(1+sin(t));' ''
   'Polygons             ' [1600 P2]      [-.2 6.1]   [-.25 4.1]  [5 8 5 10 9 11]     [1 1 2 3 4 5]     1             1             [1 3 5 1 3 5]       [3 3 3 .9 .9 .9]    ...
                           '~a=b*pi/a; v=c*cos(a)./cos(mod(b*t-pi/2,2*a)-a); z=v.*exp(it*b);' ''
   'Rose                 ' [800 7*P2]     [-3 3.1]    [-2.1 2]    [2 3 4 1 2 pi]      [1 1 1 3 3 1]     0             1             [-2 0 2 -2 0 2]     [1 1.2 1 -.8 -1 -1] ...
                           '@r=sin(a*t/b);' ''
   'Scarabaeus           ' [800 P2]       [-6 12]     [-3.5 4.5]  [2 3 1 1]           [3 2 1 3]         [2 2 2 7]     1             [0 10 8 4.3]        0                   ...
                           '@r=a*cos(c*t)-b*cos(t);' '3 98$~24In Cartesian form the Scarabaeus (c=2) becomes:|(x^2+y^2) (x^2+y^2+bx) = a^2(x^2-y^2)'
   'Serpentine curve     ' [800 -7 11]    [-7 11]     [-.6 .6]    1:6                 0                 0             1             0                   0                   ...
                           '~z=t+it.*a./(a^2+t.^2);' ...
                           ['43 56$~20Studied by L''Hopital and Huygens.|Named & classified by Newton.||May also be written:|z = a cot(t) + b sin(t)cost(t) i||~14' ...
                           'The equations:      \itx = real(z);      y = imag(z);\rm|are automatically appended to functions such|as this, i.e. defined in terms of z (complex).']
   'Spirograph           ' [5000 200*P2]  [-20.4 8.7] [-10.4 9.6] 11                  73                62            1             0                   0                   ...
                           '~B=b/100; C=c/100; k=1-B; z=a*(k*exp(it)+B*C*exp(k*it/B));' ['2 99$The Spirograph (invented by mathematician Bruno Abakanowicz) was first ' ...
                           'sold|as \itThe Marvelous Wondergraph\rm|in the 1908 Sears catalog.|||||||||a = radius of fixed circle|aB = radius of rolling circle|' ...
                           'aBC = length of pen arm||With a traditional Spirograph, C < 1|||' ...
                           'B>0 draws a \itHypotrochoid\rm (rolling on inside)|B<0 draws an \itEpitrochoid\rm (rolling on outside)']
   'Square wave          ' [400 -2 8]     [-2 8]      [-1.4 6.6]  1:6                 0                 0             1             0                   5:-1:0              ...
                           'x=t; v=1 : 2 : 2*a-1; y=4./(pi*v)*sin(v''*t);' '54 98$~20Trace n shows the|sum of the first|n odd harmonics.'
   'Step (2nd order sys) ' [510 0 1.02]   [0 1.02]    [-.05 1.8]  [1 3 5 7 9 15]*10   12                0             1             0                   0                   ...
                           'x=t; a=a/100; v=sqrt(1-a^2); y=1-exp(-a*b*t).*sin(atan(v/a)+v*b*t)/v;' ...
                           '38 94$~28      a = damping (100\zeta)|||||||||b = angular frequency (\omega_{n})'
   'Strophoid            ' [800 P2]       [-7.4 13.4] [-15 15]    [8 9 10 11 12 13]   0                 0             1             0                   0                   ...
                           '@w=a*cos(t); r=2*w-a^2./w;' ['18 96$~18Studied by Torricelli, Barrow, and others in the mid 1600''s.||' ...
                           '     Also known as the \itfoliate\rm.||||||||||||          in Cartesian form:|          y = x sqrt((1-x)/(1+x))']
   'Talbot''s curve      ' [800 P2]     [-1.23 4.57] [-1.64 2.75] [5 7 9:11 20]       10                0             1             [0 0 0 0 3 3]       [2 1 0 -1 2 0]      ...
                           'a=a/b; v=cos(t); w=sin(t); x=(1+a*w.^2).*v; y=(1-a-a*v.^2).*w;' '39 86$0.5           1.1|||||0.7|||||0.9           2.0|||||1.0'
   'Teardrop             ' [1000 P2]      [-1.1 1.1]  [-.85 .95]  [1 2:2:8 50]        0                 0             [1 6 1 1 1 3] 0                   0                   ...
                           'x=cos(t); y=sin(t).*sin(t/2).^a;' '22 99$~20An alternate formulation:  y^2 = (1-x) x^{a+1}'
   'Witch of Agnesi      ' [800 -4 4]     [-4 4]      [0 5.6]     [3:.5:5.5]          0                 0             1             0                   0                   ...
                           'x=t; y=a./(1+x.^2);' ['3 97$This is the derivative of the arctan|function, the Cauchy probability|density distribution, as well as|' ...
                           'the resonance response curve|(where x is the difference|between the excitation and|resonance frequencies.']
  };
  names = Out(:,qName);
  for k=1:length(names)
    Out{k,qName} = [sprintf('%02d: ',k) names{k}]; % add an index to the function name
    sz = length(Out{k,qa});
    for m=qb:qYoff                           % expand shorter vectors to the size of a
      if length(Out{k,m})<sz Out{k,m} = zeros(1,sz)+Out{k,m}; end;
    end;
  end;
  return;
end; % end if In==-1

a = get(gcf,'user');     % retrieve handles and parameters from user data
CRlines = a{1};  CRq = a{2};  CRp = a{3};  CRi = a{4};  CRb = a{5};  CRd = a{6};  CRn = a{7};  CRe = a{8};
cs = plt('pop',CRp);

if In==-2                                   % cycle button callback
  r = findobj(gcf,'str','Cycle');
  if length(r)                              % are we currently stopped?
    set(r,'str','Stop'); tic;               % yes, change button and start cycling
    while length(findobj(gcf,'str','Stop')) % keep on going until stop button clicked
      if cs==length(CRq(:,1))               % are we on the last function in the list?
        cs = 0;                             % yes ... reset to the first function
        set(findobj(gcf,'str','Stop'),'str','Cycle');   % and halt the while loop
      end;
      cs=cs+1; plt('pop',CRp,'index',cs);               % advance to next function
      curves(0); dly = sscanf(get(CRd,'string'),'%f'); % update plot and delay selected amount
      if dly pause(dly); else drawnow; end;
    end;
  else set(findobj(gcf,'str','Stop'),'str','Cycle'); % no, we're cycling. Halt the while loop.
  end;
  if ishandle(CRe) set(CRe,'str',sprintf('cycle time: %.3f sec',toc)); end;
elseif In==-3 | In==-4   % default button callback (right/left click = -3/-4)
  def = curves(-1);
  if In==-4 CRq = def;  else  CRq(cs,:) = def(cs,:);  end;
  set(gcf,'user',{CRlines CRq CRp CRi CRb CRd CRn CRe});
  curves(0);
else  % 0:  curves(0)     - callback for main function selection popup
      % 1:  curves(TXtrc) - callback for trace number to edit
      % 2:  curves(TXa)   - callback for trace parameter a
      % 3:  curves(TXb)   - callback for trace parameter b
      % 4:  curves(TXc)   - callback for trace parameter c
      % 5:  curves(TXxof) - callback for trace x position
      % 6:  curves(TXyof) - callback for trace y position
      % 7:  curves(TXstp) - callback for t vector (# of steps)
      % 8:  curves(TXtmn) - callback for t vector (min)
      % 9:  curves(TXtmx) - callback for t vector (max)
      % 10: curves(TXsty) - callback for trace style
  tr = plt('edit',CRi(1)); % get trace number
  if ~In | In==TXtrc       % here for curve name and trace number callbacks
    if ~In                 % if curve callback
      tr = 1;              % reset to trace number 1
      plt('edit',CRi(TXstp),'val',CRq{cs,qT}(1)); % for the curve callback only
      plt('edit',CRi(TXtmn),'val',CRq{cs,qT}(2)); % reset the t vector edit pseudo objects
      plt('edit',CRi(TXtmx),'val',CRq{cs,qT}(3)); % to match the stored parameters
      plt('edit',CRi(TXtrc),'val',[tr 1 length(CRq{cs,qa})]); % set cycle length for trace # edit object
      set(CRn,'color',[1 1 1]*.45,'vis','on');    % reset the notes color
      plt helptext;                               % delete the help message
    end;
    plt('edit',CRi(TXa),  'val',CRq{cs,qa}(tr));  % for curve or trace# callbacks
    plt('edit',CRi(TXb),  'val',CRq{cs,qb}(tr));  % reset the edit and popup pseudo objects
    plt('edit',CRi(TXc),  'val',CRq{cs,qc}(tr));  % to match the stored parameters
    plt('edit',CRi(TXxof),'val',CRq{cs,qXoff}(tr));
    plt('edit',CRi(TXyof),'val',CRq{cs,qYoff}(tr));
    plt('pop', CRi(TXsty),'index',CRq{cs,qSty}(tr));
  else
    if In==TXsty CRq{cs,qSty}(tr) = plt('pop',CRi(In)); % curves(1) thru curves(10)
    else  v = plt('edit',CRi(In));                      % save the user entered value
          switch In                                     % and then update the plot
            case TXa,   CRq{cs,qa}(tr)    = v;
            case TXb,   CRq{cs,qb}(tr)    = v;
            case TXc,   CRq{cs,qc}(tr)    = v;
            case TXxof, CRq{cs,qXoff}(tr) = v;
            case TXyof, CRq{cs,qYoff}(tr) = v;
            case TXstp, CRq{cs,qT}(1)     = v;
            case TXtmn, CRq{cs,qT}(2)     = v;
            case TXtmx, CRq{cs,qT}(3)     = v;
          end % end switch In
          c = get(CRn,'color')/2;                               % fade out the notes color
          set(CRn,'color',c,'vis',char('of'+[0 8*(c(1)>.03)])); % invisible on 4th fade
    end;      % if In==TXsty
  end;        % end if ~In | In==TXtrc
  ax = get(CRlines(1),'parent');
  tiny = 1e-99;                                         % prevents divide by zero warnings
  t = CRq{cs,qT};                                       % get t vector [t#OfSteps tMin tMax]
  step = (t(3)-t(2))/t(1);  tt = tiny + t(2):step:t(3); % create t vector
  set(ax,'xlim',CRq{cs,qXlim},'ylim',CRq{cs,qYlim});    % set axis limits to stored values
  aa = CRq{cs,qa}; bb = CRq{cs,qb}; cc = CRq{cs,qc};    % get a/b/c parameters
  Xoff = CRq{cs,qXoff}; Yoff = CRq{cs,qYoff};           % get X/Y offsets, line style
  Style = CRq{cs,qSty};  
  StyCH = plt('pop',CRi(TXsty),'get','choices');
  n = length(aa);                                       % number of traces to plot
  set(CRlines,'x',0,'y',0);                             % clear the trace data
  func = CRq{cs,qEval};                                 % get the function eval string
  polar = func(1)=='@';  cplx = func(1)=='~';           % @,~ tags indicate polar,complex
  if polar | cplx  func = func(2:end); end;             % remove those tags
  f = func;  p = findstr(f,'_');  func(p)=[];  q=[];    % underscore delimits hidden segments
  while length(p)>1 q=[q p(1):p(2)]; p=p(3:end); end;   % q is a list of char indexes to be hidden
  f(q)=[]; f = ['\bf' f];                               % display eval string in bold
  fsz = round(24-length(f)/7);                          % set eval string fontsize based on string length
  f1 = {'.*' '.+' '.-' './' '.^' ';'           '='       '*'        '+'    '-'    '/'  };
  f2 = {'*'  '+'  '-'  '/'  '^'  '       \bf'  ' = \rm'  ' \cdot '  ' + '  ' - '  ' / '};
  for k=1:length(f1) f=strrep(f,f1{k},f2{k}); end;      % make string substitutions for legibility
  set(get(ax,'Xlabel'),'str',f,'fontsize',fsz,...       % set Xaxis label to function eval string
      'color','red','vert','middle','units','norm','pos',[.5 -.07]);
  s = strrep(CRq{cs,qNote},'|',char(10));               % Vertical bars in note string are line feeds
  if isempty(s) sloc = [0 0];
  else ds = findstr(s,'$');                             % Note position is terminated with "$"
       sloc = str2num(s(1:ds-1))/100; s = s(ds+1:end);  % get note position and remove it from note
       ds = findstr(s,'~');                             % "~xx" indicates a fontsize of xx points
       while length(ds)                                 % insert tex command for the fontsize
         s = [s(1:ds-1) '\fontsize{' s(ds+1:ds+2) '}' s(ds+3:end)];  ds = findstr(s,'~');
       end;
  end;
  set(CRn,'str',s,'pos',sloc);                           % set the note string properties
  for m = 1:n                                            % loop for each trace
    t = tt;  a = aa(m);  b = bb(m);  c = cc(m);  STYix = Style(m);
    if STYix==1  sty = '-'; else  sty = StyCH{STYix}; end;
    if STYix<5 mrk = 'none'; else mrk = sty;  sty = 'none'; end;
    if polar func = [func 'x=r.*cos(t); y=r.*sin(t);']; end;
    if cplx  func = ['i=1i;it=i*t;' func 'x=real(z); y=imag(z);']; end;
    eval(func);                                          % evaluate the function string & plot results
    set(CRlines(m),'x',x+Xoff(m),'y',y+Yoff(m),'Marker',mrk,'LineStyle',sty);
    s = ['trace ' int2str(m)];                           % create TraceID
    if m==tr & n>1 s = [s '<<']; end;                    % put an arrow "<<" next to it if this
    set(CRb(m),'string',s);                              % is the currently selected trace
  end;
  for m = (n+1):6 set(CRb(m),'string',''); end;          % blank out unused TraceIDs
  plt('grid',ax);                                        % update the grid lines
  set(gcf,'user',{CRlines CRq CRp CRi CRb CRd CRn CRe}); % save changes in the figure user data
  setappdata(gcf,'xu',[0 0 0]);                          % used by fresnel
end; % end if In==-2
%end function curves

function xy=fresnel(xx) % computes the cos and sin fresnel integrals
xu = [xx(1:2) length(xx)];      % have we already computed this integral?
if ~sum(abs(getappdata(gcf,'xu')-xu)) xy = getappdata(gcf,'xy'); return; end; % yes
setappdata(gcf,'xu',xu);        % no, this has a different xx input than last time
acc = 1e-2;                     % accuracy requested
sx = sign(xx);  xx = abs(xx);   % apply signs at the end
xy = xx;                        % pre-allocate outputs
for n = 1:length(xx)
  x = xx(n);  px = pi*x;  t = px*x/2;  t2  = -t.^2;
  if    ~x    c=0; s=0;
  elseif x < 2.5
    r = x;   c = r;
    for  k=1:50  r=r*t2*(4*k-3)/polyval([16 -4 -2 0],k);  c=c+r;
                 if abs(r) < abs(c)*acc  break; end;
    end;
    s = x*t/3;  r = s;
    for  k=1:50  r=r*t2*(4*k-1)/polyval([16 20 6 0],k);  s=s+r;
                 if abs(r) < abs(s)*acc break; end;
    end;
  elseif x < 4.5;
    m = fix(42 + 1.75*t); su=0; c=0; s=0; f1=0; f0=1e-100;
    for  k = m:-1:0  f = (2*k+3) * f0 / t - f1;
                     if mod(k,2)  s=s+f;  else  c=c+f;  end;
                     su = su + (2*k+1) * f^2;  f1 = f0;  f0 = f;
    end;
    q = sqrt(su);  c = c*x/q;   s=s*x/q;
  else;
    r = 1;  f = 1;
    for k=1:20 r=r*polyval([1 -1 .75],k)/t2; f=f+r; end;
    r = 1 / (px*x);    g = r;
    for k=1:12  r=r*polyval([1 0 -.0625],k)/t2; g=g+r; end;
    t0 = t - fix(t/(2*pi)) * 2*pi;
    c  = .5 + (f*sin(t0) - g * cos(t0)) / px;
    s  = .5 - (f*cos(t0) + g * sin(t0)) / px;
  end;  % end if ~x
  xy(n) = complex(c,s);
end;    % end for n = 1:length(xx)
xy = sx .* xy;            %real/imag part contains cos/sin fresnel integral
setappdata(gcf,'xy',xy);  % save result for next time
% end function fresnel
