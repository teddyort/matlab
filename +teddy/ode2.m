function [t, y] = ode2(a, b, c, y0, yp0)
% Second Order Homgenous Solver: Solves second order homogeneous
% differential equations with constant coefficients a, b, and, c.
% Initial conditions are specified in y0, and yp0, the value of y and ydot
% respectively.

M=[0 1;-b/a -c/a];
func=@(t, y) M*y;
[t, y]=ode45(func,[0 10],[y0;yp0]);
y=y(:,1);
end

