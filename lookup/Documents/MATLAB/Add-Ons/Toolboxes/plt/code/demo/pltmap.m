% pltmap.m ------------------------------------------------------------------
%
% The main purpose of this function is to demonstrate the use of the
% image pseudo object. The subplot parameter is used to partition the
% figure into two parts. The left part displays a conventional 2D plot
% which includes the following five traces.
% 1.) A circle (green trace) whose radius is controlled by its amplitude
%     slider (leftmost slider above the plot in the "Y amplitudes" section).
% 2.) A hyperbola (purple trace). Its amplitude slider controls the
%     asymptote slope. 
% 3.) A polygon (cyan trace). Its amplitude slider controls both the size
%     of the figure and the number of sides (which range from 3 to 7).
% 4.) Two lines (red and blue traces). Their amplitude sliders control
%     the lines' positions as well as determines the lines' orientation
%     (vertical/horizontal).
%
% The five Z amplitude sliders assign a z coordinate to each of the five
% traces, then these 500 points (100 points per trace) are interpolated
% using griddata to create the two input function displayed using an
% intensity map on the right side of the figure.
%
% The many features of pltmap and the image pseudo object are intertwined
% so to help you explore these features, consider starting up pltmap and
% running through these tasks:
%
% Adjust some of the "Y amplitudes" (5 sliders near the upper left
% corner) and observe how they affect their respective traces (1-5).
% Note that the intensity map changes as well since the z values are
% computed from the shapes of these five traces.
%
% Disable and enable the various traces by clicking on the trace names
% in the TraceID box. Note that the intensity map shape is determined
% only from the enabled traces. A strange thing happens if you disable
% all the traces except for trace 4 or trace 5 (showing just a single
% horizontal or vertical line). What happens is that the intensity map
% no longer represents anything associated with the 2D plot. This is
% because the griddata function is used to interpolate the data from
% the 2D plot, but it fails because it doesn't have enough data when
% provided with just a single line of zero or infinite slope. So when
% this error is detected, pltmap creates an alternate intensity map
% showing a 2 dimensional sync function with a random center position.
% (For variety, this sync function also appears for a the first few
% seconds of a moving display [see the description of the "Run" button
% below], but note that this happens only the first time the Run button
% is pressed after pltmap is started. Subsequent presses of the Run
% button simply start the intensity map updating in the usual fashion. 
%
% Adjust the "Z amplitudes" for each of the 5 traces using the sliders.
% The z values of the traces are not plotted in the 2D plot (left) but
% note how these amplitudes affect the intensity map. 
%
% Click on the "color bar", the vertical color key strip near the upper
% left corner of the intensity map. Note that this cycles the color map
% through seven choices. Some of the color maps have a particular purpose,
% but mostly this is simply a visual preference. 
%
% Note that the intensity map appears somewhat pixelated. This is because
% it is composed of a relatively small number of pixels (200x200). Try zooming
% in on an interesting looking region of the intensity map using a zoom box.
% Hold the shift key down and drag the mouse to create the zoom box. Then
% click inside the zoom box to expand the display. Even though you still
% have only 200x200 pixels, the display will look smoother because all
% these pixels are focused on a smaller region of the more quickly changing
% z data. You can also zoom in by RIGHT clicking on the "view all" button
% in the lower right corner. Then left click on the view all button to expand
% the limits back to their original values to show the entire z data set. 
%
% Also try opening a zoom box in the 2D plot (left). You can do this as
% before (shift key and mouse drag) or try the "double click and drag" mouse
% technique which avoids having to use the keyboard. You may be surprised to
% see that the intensity map zooms to show the region inside the zoom box of
% the 2D plot even as you are dragging the edge of the zoom box. If you then
% click inside the zoom box the 2D plot will also expand to show just the
% region inside the zoom box ... but let's not do this just yet. First try
% moving the zoom box around. Do this by clicking the mouse near the mid-point
% of any edge, and drag the zoom box around while holding the mouse button
% down. Also note that if you drag one of the corners instead of a midpoint
% then the zoom box changes its size instead of its position. In both cases
% the intensity map continues to update so that it shows only the zoom box
% region. These mouse motions are further described in the paragraph titled
% "Adjusting the expansion box" in the Zooming and panning section.
%
% Try sliding the resolution slider (just to the left of the color bar) all
% the way to the top of the slider. This will select a resolution of 800x800 
% (16 times as many pixels as before) so the display will look much smoother,
% but the drawback is that the update rate will be much slower. Try moving
% the slider all the way to the bottom (50x50 pixels). Now the intensity map
% will look very blocky, and the update rate will be very fast. Note that
% when you click inside the intensity map, the cursor will center itself on
% one of the blocks even if you click near the edge of one of the blocks.
% This makes it easier to interpret the Z value cursor readout (shown below
% the intensity map. Also note the x and y cursor readouts are updated as
% you would expect every time you click on the image. Reset the resolution
% slider to 200 before continuing. 
%
% Try adjusting the "edge" slider (right below the color bar). The default
% value of the slider is "1" which means that only the z data range between
% the mean +/- sigma is used for assigning colors of the z values. This means
% that all the data bigger than 1 standard deviation above the mean is
% represented by the same color. If you move the slider to "2", then two
% standard deviations of the data are used so that you can see variations
% near the extremes that you couldn't see before. But the downside is that
% you will see less detail for smaller changes in the z values closer to the
% mean. You can also adjust the mid point for the range of focus using the
% mid slider (just to the left of the edge slider). For example if you are
% more interested in getting a view of the data greater than the mean you might
% set mid=.5 and edge=.8. This would mean that the range of data that produces
% different colors in the image would be between the mean +/- 0.3 sigma
%
% Although it doesn't really demonstrate any more features of the new image
% pseudo object, if you really want to be mesmerized by the display, press the
% "Run" button. What happens is that a random selection of the 10 sliders above
% the 2D plot are selected to start moving. (The remaining sliders that are held
% fixed are made invisible so you can easily see what is changing). As the
% sliders are moving up and down, both the 2D and 3D plots are continuously
% updated to reflect the new information in the sliders. As this is happening
% you will see the small (blue) frame counter below the Run/Stop button counting
% down from 100 to zero. When zero is reached, a new random selection is made
% from the set of 10 sliders and the frame counter begins down counting anew
% from 100. While all this is happening, you may change the speed slider to
% adjust the motion rates and you also may adjust pretty much everything else
% mentioned in the above bullet points. If you find that 100 frame count is too
% long or short for your taste, simply click on the yellow "100" and you will
% be presented with a popup menu allowing you to vary this frame count from as
% small as five to as large as 1000. 

% ----- Author: ----- Paul Mennen
% ----- Email:  ----- paul@mennen.org

function pltmap(in1)

xy = [-1 .005 .275 .037 .15; -2 .005 .09 .037 .17]; % positions: TraceID & Menubox
S.l = plt(0,zeros(1,6),'Pos',[830 550],'FigBKc',001212,'xy',xy,...
       'Xlim',[0 10],'Ylim',[0 10],'Styles','oooooo','pos',[1200 700],...
       'Options','-X-Y I','LabelY','Y axis','TIDcback',@cdata,...
       'MotionZoom',@zom,'Subplot',[67.96 -40.94 100.96 -61.02]);
S.cn = text(-.15,.805,'100','units','norm','color',[.31 .5 1],'user',warning('off'));
% Note: Warnings are turned off in the line above to suppress the annoying warnings
% produced by the griddata command. The previous warning states are saved so that
% they can be restored when the program exits. The following line tells plt to do this.
% Actually this is only needed for very old Matlab versions because newer Matlab
% versions automaically save the warning states and restores them when a program exits.
setappdata(gcf,'ucreq','warning(get(findobj(gcf,"color",[.31 .5 1]),"user"));');
S.ax = gca;   rand('state',0);
tid = flipud(get(findobj(gcf,'user','TraceID'),'child'));
tid = get([tid; tid],'string'); % the lables for the ten amplitude sliders
for k=1:10  p = [.039*k - .02*(k<6) .747 .014 .180 .03]; % create 10 amplitude sliders
            S.sli(k) = plt('slider',p,10*[rand 0 1],tid{k},@cdata,1,'3');
end;
S.sl = flipud(findobj(gcf,'sty','slider')); % save just the 10 slider uicontrols
S.res = plt('slider',[.423 .58 .014 .27],[200 50 800],'Res',@cdata,[4 25]);
S.spd = plt('slider',[.015 .47 .014 .18],[20 1 100],'Speed','',2);
S.cnt = plt('pop',[.045 .435 .03 .16],100*[.05 .1 .2 .5 1 2 5 10],'index',5);
S.run = uicontrol('string','Run','units','norm','pos',[4 61 3 3]/100,'callback',@run);
s = '------------- Y amplitudes -------------';
text(-.22,1.465,s,'units','norm','color',[.9 .9 .3]);  s(15)='Z';
text( .49,1.465,s,'units','norm','color',[.9 .9 .3]);
S.img = -1;                % indicate that we haven't yet created the intensity map
set(gcf,'user',S); cdata;  % initialize the intensity map
if nargin run(S.run); end; % start running if an argument was provided

function zom(a)
  plt('cursor',-2,'xylim',a);

function cdata
  S = get(gcf,'user'); xg=[]; yg=[]; az=[]; t=0:99;
  if ~isstruct(S) return; end;
  vis = get(getappdata(S.ax,'Lhandles'),'vis');
  vis = strrep(strrep([vis{:}],'off','0'),'on','1')-'0'; % visible traces
  if ~sum(vis(1:3)) vis(1)=1; end;       % must have one nonlinear trace active
  for k=1:5                              % cycle thru all 5 traces
    if ~vis(k) continue; end;            % skip the invisible traces
    ay = max(plt('slider',S.sli(k)),.1); % get the y amplitude
    az = [az plt('slider',S.sli(k+5))];  % get the z amplitude
    switch(k)
      case 1, z = 0.5*ay*exp(.02i*t*pi);                                    % circle
              X=min(max(real(z)+5,.5),9.5); Y=min(max(imag(z)+5,.5),9.5);
      case 2, z = exp([-25:-1 1:25] * pi * .018i);                          % hyperbola
              X=1./real(z); Y=0.2*ay*X .* imag(z)+5; X=[5-X 5+X]; Y=[Y Y];
      case 3, d = floor(ay); ay=ay-d; a=2*pi/(5+d); e = mod(d,2);           % polygon
              c = max(8*(e+(1-2*e)*ay),.04);  s = .0404*t*pi;
              v = c*cos(a)./cos(mod(s-pi/2,2*a)-a);  z = v .* exp(1i*s);
              X=min(max(real(z)+5,0),10);  Y=min(max(imag(z)+5,0),10);
      otherwise, X = .05+t/10; Y=0*X+2*ay; if ay>5 XX=X; X=Y-10; Y=XX; end; % horiz/vert lines
    end;
    set(S.l(k),'x',X,'y',Y);  xg = [xg X];  yg = [yg Y];
  end;
  hh = repmat(az,length(t),1);  rs = plt('slider',S.res) - 1;  rs0 = 0:rs;
  if ishandle(S.img)                              % here if image object exists
       a = get(S.img,'parent'); xl=get(a,'xlim'); yl=get(a,'ylim');
       x = rs0*diff(xl)/rs + xl(1);  y = rs0*diff(yl)/rs + yl(1);
  else x = 10*rs0/rs;  y = x;                     % no image object (use default limits)
  end;
  [xi,yi] = meshgrid(x,y);                        % n x n grid (n = slider value)
  z = griddata(xg,yg,hh(:),xi,yi,'cubic');        % compute the z matrix
  if ishandle(S.img)
       plt('image',S.img,'xyz',x,y,z);            % modify the image pseudo object
  else opt = {'Cbar' 'Edge' 'Mid' 'grid' 'view'}; % options for image pseudo object
       S.img = plt('image',2,x,y,z,opt);          % create the image pseudo object
       set(gcf,'user',S);                         % save image handle
       plt('cursor',-2,'axisCB',@cdata);  plt('cursor',-2,'updateN');
  end;
% end function cdata

function run(a,b)
  if sum(get(a,'string')) == 422                % does the button say "Stop"
    set(a,'string','Run'); return;              % yes, change it to say "Run"
  end;
  set(a,'string','Stop');                       % no, change it to say "Stop"
  sc = [1 1 .1 1 1 1 3 3 3 3 3]/300;            % polygon amplitude slider moves slower
  S=get(gcf,'user'); xlbl=get(S.ax,'XLabel');
  tic; cn=0; cnt=0;  dir = 2*mod(0:9,2)-1;      % direction: dir = +1/-1 (up/down)
  while ishandle(a) & sum(get(a,'string'))==422 % loop until Stop button is pressed
    if ~cnt mv = find(rand(1,10)>.5);           % every S.cnt updates, choose a new set
            cnt=str2num(get(S.cnt,'string'));   % of sliders to move around
            set(xlbl,'str',prin('%.2f updates/sec',cn/toc));
            set(S.sl,'vis','off');
            set(S.sl(mv),'vis','on');           % Only show the siders that are moving
    end;
    s = plt('slider',S.spd) .* sc;
    for k=mv  v = plt('slider',S.sli(k)) + s(k)*dir(k);
              if v>10 | v<0 dir(k) = -dir(k);  v = min(max(v,0),10); end;
              plt('slider',S.sli(k),'val',v);
    end;
    cnt=cnt-1;  cn=cn+1;  set(S.cn,'string',sprintf('%d',cnt));
    if ishandle(a) cdata; end; drawnow;
  end;
  if ishandle(a) set(S.sl,'vis','on'); end;
% end function run