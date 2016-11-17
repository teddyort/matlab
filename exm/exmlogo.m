function exmlogo(which_color)
% TWO LOGOS
% exmlogo
% exmlogo('exm')
% exmlogo('ncm')
% L-shaped membrane on the covers of the print
% versions of Numerical Computing with MATLAB
% and Experiments with MATLAB.
% Rotate in 3D with the mouse or arrow keys.

%   Copyright 2014 Cleve Moler
%   Copyright 2014 The MathWorks, Inc.

if ~verLessThan('matlab','8.4')
   error('Sorry, no longer available.')
end

if nargin == 0
   which_color = 'exm';
end

% Set up the figure window

clf
shg
set(gcf,'menubar','none','numbertitle','off','name','exmlogo', ...
    'inverthardcopy','off')

switch which_color
   case 'ncm'
      set(gcf,'color',[0 0 1/4],'colormap',jet(8))
   case 'exm'
      set(gcf,'color',[1/3 0 0],'colormap',flipud(jet(8)))
end
axes('pos',[0 0 1 1])
axis off
daspect([1 1 1])

% Compute MathWorks logo

L = rot90(membranetx(1,32,10,10),2);

% Filled contour plot with transparent lifted patches

b = (1/16:1/8:15/16)';
hold on
for k = 1:8
   [c,h(k)] = contourf(L,[b(k) b(k)]);
   if strcmp(get(h(k),'Type'),'hggroup')
     h(k) = get(h(k),'Children');
   end
   m(k) = length(get(h(k),'xdata'));
   set(h(k),'linewidth',2,'edgecolor','w', ...
      'facealpha',.5,'zdata',4*k*ones(m(k),1))
end
hold off
view(12,30)
axis([0 64 0 64 0 32])
axis vis3d
rotate3d on

% print -djpeg two_logos.jpg
