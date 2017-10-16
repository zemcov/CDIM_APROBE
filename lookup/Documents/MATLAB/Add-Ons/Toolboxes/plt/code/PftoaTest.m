% PftoaTest.m:  Test program for Pftoa.m
% Author:       Paul Mennen (paul@mennen.org)
[fi pth] = uiputfile('PftoaTest.txt','Select a file to save the test output. Hit Cancel to abort');
if isnumeric(fi) disp('Pftoa test aborted'); Pftoa; return; end;
fi = fopen([pth fi],'wt');                                % open file to contain test output
a = [9;2.1;3.99;4.012;5.9876;6.54321;7.065432;8.7654321]; % generate test values
a = a * [1e-105 1e-50 1e-5 1e-4 .001 .01 .1 1 10 100 1e3 1e4 1e5 1e6 1e7 1e8 1e9 1e10 1e105];
a = [0; NaN; a(:); -a(:)];                                 % 306 test values in total
fc = 'WwVv';  fm = '%c:%5s%6s%7s%8s%9s%10s%11s%12s%13s\n';
f = cell(4,9);  s = cell(1,9);  sep = [prin('%d{=}  ',2:12) '\n'];
c = '%%1W ~, %%2W ~, %%3W ~, %%4W ~, %%5W ~, %%6W ~, %%7W ~, %%8W ~, %%9W';
for m=1:4 f(m,:) = prin(strrep(c,'W',fc(m))); end;         % generate the 36 Pftoa format codes
prin(fi,['Each number is printed 37 times using the following formats:\n\n' sep '85{ }%%1.8g\n']);
for m=1:4 prin(fi,fm,fc(m),f{m,:}); end;  prin(fi,sep);    % print the format codes that will be used
for j = 1:length(a)                                        % loop 306 times
  prin(fi,'\ng:83{ }%1.8g\n',a(j));                        % print test value using a g format
  for m = 1:4                                              % use W,w,V,v formats on successive lines
    for k = 1:9  s{k} = prin(['(' f{m,k} ')'],a(j)); end;
    prin(fi,fm,fc(m),s{:});                                % print test value usint the 36 Pftoa format codes
  end;
end;
disp('Pftoa test complete. Test file written');
fclose(fi);                                                 % done with test code
