function bigscreen(arg)
%BIGSCREEN  Set graphics properties for large audiences.
%   BIGSCREEN with no arguments or BIGSCREEN('on') sets the figure
%   window size and location, and several Handle Graphics font and
%   line sizes to values appropriate for big screen projectors.
%
%   BIGSCREEN('off') sets them back to their "factory" defaults.

%   Copyright 2014 Cleve Moler
%   Copyright 2014 The MathWorks, Inc.

if nargin == 0 | isequal(arg,'on')
   % Turn on bigscreen
   s = get(0,'screensize');
   w = 1024;
   h = 768;
   fs = 14;
   lw = 2;
   if s(3) == 1024
      w = 768;
      h = 672;
      fs = 12;
   end
   if s(3) == 800
      w = 680;
      h = 510;
      fs = 12;
   end
   x = (s(3)-w)/2;
   y = (s(4)-h)/2;
   set(0,'defaultfigureposition',[x y w h], ...
      'defaultuicontrolfontsize',fs, ...
      'defaulttextfontsize',fs, ...
      'defaultaxesfontsize',fs, ...
      'defaultlinemarkersize',fs, ...
      'defaultlinelinewidth',lw, ...
      'defaultuicontrolfontweight','bold', ...
      'defaulttextfontweight','bold', ...
      'defaultaxesfontweight','bold')

elseif isequal(arg,'off')
   % Turn off bigscreen
   set(0,'defaultfigureposition','factory', ...
      'defaultuicontrolfontsize','factory', ...
      'defaulttextfontsize','factory', ...
      'defaultaxesfontsize','factory', ...
      'defaultlinemarkersize','factory', ...
      'defaultlinelinewidth','factory', ...
      'defaultuicontrolfontweight','factory', ...
      'defaulttextfontweight','factory', ...
      'defaultaxesfontweight','factory');

else
   error('Unfamiliar argument')
end
