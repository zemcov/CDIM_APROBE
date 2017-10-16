% gui1.m --------------------------------------------------------
%
% Usually plt is used to build gui applications which include plotting,
% however this example doesn't include plots so that it remains trivial,
% making it a good example to start with if you have no previous exposure
% to Matlab GUI programming. The only pseudo object used in gui1 is the
% pseudo slider which is a collection of 5 uicontrols designed to work
% together to control a single parameter. The remaining controls used
% in gui1 are standard matlab uicontrols.        
%
% This GUI doesn't actually perform any useful function other than to
% demonstrate how to create various controls and move them around
% until the GUI appears as desired. The slider callback generates new
% random numbers for the listbox, textbox, and uitable. The remaining
% callbacks are just stubs that notify you that you clicked on the object.
%
% You can most easily absorb the point of this example by reading the
% section of the help file called "GUI building with plt"
%
% gui1.m uses a uitable which aren't supported in Matlab 6, so if you are
% running a version of Matlab older than 7.0 then you should run an alternate
% version of this program called gui1v6.m which replaces the uitable with a
% radio button. If you start gui1 from demoplt, demoplt checks the Matlab
% version and runs gui1 or gui1v6 as appropriate.
%
% ----- Author: ----- Paul Mennen
% ----- Email:  ----- paul@mennen.org

function gui1()
  figure('name','gui1','menu','none','pos',[60 60 430 350],'color',[0 .1 .2]);
  cho = {'choice A' 'choice B' 'choice C'}; % choices for popup control
  p = {[.020 .920 .300     ];  % PseudoSlider 1
       [.350 .920 .300     ];  % PseudoSlider 2
       [.680 .920 .300     ];  % PseudoSlider 3
       [.020 .500 .480 .280];  % uitable
       [.540 .500 .440 .280];  % frame
       [.680 .710 .170 .050];  % popup
       [.570 .610 .380 .060];  % slider
       [.570 .520 .170 .060];  % button
       [.780 .520 .170 .060];  % checkbox
       [.020 .050 .480 .400];  % listbox (80 lines)
       [.540 .050 .440 .400]}; % text (10 lines)
% First we create the pseudo sliders and the uitable. Even though we don't use these
% handles we save them anyway because in a real gui we would almost always need them.
  h1 = plt('slider',p{1}, 10,'PseudoSlider 1',@CBsli);
  h2 = plt('slider',p{2}, 60,'PseudoSlider 2',@CBsli);
  h3 = plt('slider',p{3},800,'PseudoSlider 3',@CBsli); 
  h4 = uitable('units','norm','pos',p{4});
% Next we create all 7 uicontrols in one line. Note how the properties for each uicontrol
% in the next three lines (style, string, callback) line up directly under the uicontrol
% command that created the object. 
  h =            [uicontrol uicontrol uicontrol uicontrol uicontrol uicontrol uicontrol];
  set(h,{'style'},{'frame' ;'popup';  'slider';'pushb'  ;'checkbox';'listbox';'text';},...
       {'string'},{'frame1'; cho   ;  'slider';'button1';'check001';''       ;''     },...
       { 'callb'},{''      ; @CBpop;  @CBsli  ;@CBpush  ; @CBcheck ;''       ;''     },...
       'backgr',[.5 1 1],'units','norm',{'pos'},p(5:end));
  set(h(1),'backgr',[1 1 2]/6,'foregr',[1 1 1]/2); % colors for the frame
  set(gcf,'user',[h1 h2 h3 h4 h]);  CBsli;     % save the handles for the slider callback.
%end function gui1

function CBpop(a,b)
                      disp('popup callback');
function CBcheck(a,b)
                      disp('checkbox callback');
function CBpush(a,b)
                      disp('pushbutton callback');

function CBsli(a,b)                      % The slider callback -------------------
  h = get(gcf,'user');                   % Get the handle list
  t = 1e20.^(rand(3,80))/1e6;            % Random numbers (with wide dynamic range)
  set(h(10:11),'fontname','courier',...  % Use the same random table of numbers
    'string',prin('3{%6V   }~, ',t));    %  for both the listbox and the textbox
  set(h(4),'data',100*rand(3,2));        % More random numbers for the uitable
