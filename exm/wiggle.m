function wiggle(X)
% WIGGLE  Dynamic matrix multiplication.
%   wiggle(X) wiggles the 2-by-n matrix X.
%   Eg: wiggle(house)
%       wiggle(hand)

%   Copyright 2014 Cleve Moler
%   Copyright 2014 The MathWorks, Inc.

set(gcf,'menubar','none','numbertitle','off','name','Wiggle')
if nargin < 1
   X = house;
end

thetamax = 0.1;
delta = .025;
t = 0;
stop = uicontrol('string','stop','style','toggle');
while ~get(stop,'value')
   theta = (4*abs(t-round(t))-1) * thetamax;
   G = [cos(theta) sin(theta); -sin(theta) cos(theta)];
   Y = G*X;
   dot2dot(Y);
   drawnow
   t = t + delta;
end
set(stop,'string','close','value',0,'callback','close(gcf)')
