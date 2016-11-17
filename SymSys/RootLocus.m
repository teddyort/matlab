function RootLocus(sys,param,min,max,varargin)
%RootLocus - Create a generalized root locus plot for a SymSys object
%
% Call:   RootLocus(sys, parameter, min, max) -  make a root-locus plot
%             (path of system poles in the s-plane) for the SymSys system
%             'sys' as the value of 'parameter' is varied from min to max,
%              using the default of 200 steps.
%
%         RootLocus(sys, prameter, min, max, npoints) -  make a root locus
%             plot for the SymSys system 'sys' as the parameter 'parameter'
%             is varied from the value min to max in npoints steps.
%
% Notes:  RootLocus() makes a "generalized" plot of the path of system
%         poles (eigenvalues) as ANY system parameter is varied.  This is
%         NOT the same as the normal root-locus (such as in MATLAB's
%         rlocus() function), which is restricted to closed-loop pole locus
%         as a single overall gain value is varied in an open-loop system.
%
%         All system parameters must be assigned numerical values before
%         the call to RootLocus().
%
%         The value of the varied system parameter is left unchanged after
%         the call.
%
%         The "data tip" may be used to interctively explore the plot with
%         the cursor.
%
% Example: g = '(1,2,force,Fs),(2,1,mass,m),(2,1,spring,K),(2,1,damper,B)';
%          vals = 'm=2, K=10, B=3';
%          sys = Lgraph2sys(g,'vm',vals)
%          RootLocus(sys,'B',0,10,300)
%          - plots the locus of the poles as the damping coefficient B is
%            varied from B=0 to 10 N-s/m in 300 steps.

% Author:        Derek Rowell (drowell@mit.edu)
% Revision Date: Nov. 20, 2010
%--------------------------------------------------------------------------
syms s
global data param_name poles
if nargin == 5
   N_points = varargin{1};
elseif nargin == 4
   N_points = 201;
else
   error(['RootLocus: Requires either four or five arguments:  ',...
      'RootLocus(sys, param, min, max, {npoints})'])
end
%
delta      = (max - min)/(N_points -1);
range      = min:delta:max;
L          = length(range);
param_name = param;
eval(sys.Valstring);
% Reset the parameter to its symbolic form
str = strcat(param_name,'=sym(''',param_name,''');');
eval(str);
A         = eval(Amatrix(sys,'sym'));
order     = length(A(1,:));
char_poly = poly(A,s);
coeffs    = poly_coef(char_poly,s);
%
% Fill the array of pole locations
%
p         = zeros(order, L);
for j = 1:L
   str = strcat(param_name,'=',num2str(range(j)),';');
   eval(str);
   try
      newroots = roots(eval(coeffs));
   catch
      display(['RootLocus: Poles cannot be calculated for ', str]);
      return
   end
   if j == 1
      p(:,j) = newroots;
   else
      p(:,j) = find_closest(p(:,j-1),newroots);
   end
end
%
% Now insert extra points where complex loci meet the real axis (to
% improve the look of the plot).
% Estimate the location of coincident poles by fitting a parabola to
% the two adjacent conjugate poles.
%
for j= 3:L-2
   for m = 1:order
      if imag(p(m,j-1)) ~= 0 && imag(p(m,j))==0 %   conjugate --> real
         m_conj = find_conjugate(p(:,j-1), p(m,j-1));
         a = (range(j-2) - range(j-1))/...
            (imag(p(m,j-2))^2 - imag(p(m,j-1))^2);
         x = range(j-1) - a*imag(p(m,j-1))^2;
         % Find the pole locations at this value of the parameter
         eval(strcat(param_name,'=',num2str(x),';'));
         newroots = find_closest(p(:,j-1), roots(eval(coeffs)));
         % Because it was a guess, replace with the average of the two
         % roots to force real, coincident roots.
         newroots(m)      = (newroots(m) + newroots(m_conj))/2;
         newroots(m_conj) = newroots(m);
         p     = [p(:,1:j-1), newroots, p(:,j:L)];
         range =            [range(1:j-1), x ,range(j:L)];
         L     = L+1;
         break
      end
      %
      if imag(p(m,j)) == 0 && imag(p(m,j+1))~=0
         m_conj = find_conjugate(p(:,j+1), p(m,j+1));
         a = (range(j+2) - range(j+1))/...
            (imag(p(m,j+2))^2 - imag(p(m,j+1))^2);
         x = range(j+1) - a*imag(p(m,j+1))^2;
         % Find the pole locations at this value of the parameter
         eval(strcat(param_name,'=',num2str(x),';'));
         newroots = find_closest(p(:,j+1), roots(eval(coeffs)));
         % Because it was a guess, replace with the average of the two
         % roots to force real, coincident roots.
         newroots(m)      = (newroots(m) + newroots(m_conj))/2;
         newroots(m_conj) = newroots(m);
         p     = [p(:,1:j), newroots, p(:,j+1:L)];
         range = [range(1:j), x ,range(j+1:L)];
         L     = L+1;
         break
      end
      
   end
end
%
% Set up for cursor based "data tip" exploration on the plot
poles   = p;
N_poles = length(p(:,1));
data    = range;
dcm_obj = datacursormode(gcf);
set(dcm_obj,'UpdateFcn',@rlocus_updatefcn);
% Plot the data
for j = 1: order
   if j>1
      hold on
   end
   plot(real(p(j,:)),imag(p(j,:)),'b','LineWidth',1)
end
%
% Annotate the graph
hold on
grid on
xlabel('Real(s)');
ylabel('Imag(s)');
title(sprintf('Root Locus for parameter %s=%g:%g', param, range(1),...
   range(length(range))));
% Draw a lengend showing max and min ends of each line.
for j= 1:N_poles
   minhandle = plot(real(p(j,1)),imag(p(j,1)),'v');
   maxhandle = plot(real(p(j,L)),imag(p(j,L)),'^');
end
s1 = [param_name,' = ',num2str(range(1))];
s2 = [param_name,' = ',num2str(range(L))];
legend([minhandle(1),maxhandle(1)],s1,s2,'Location','Best')
hold off
end
%--------------------------------------------------------------------------
%  Re-order elements to the closest neighbor
function  y = find_closest(old, new)
y = zeros(size(old));
L = length(old);
for k = 1:L
   mindist = 1e12;
   minm = 1;
   for m = 1:L
      dist = (real(old(k)) - real(new(m)))^2 ...
         + (imag(old(k)) - imag(new(m)))^2;
      if dist < mindist
         mindist = dist;
         minm = m;
      end
   end
   y(k) = new(minm);
   new(minm) = 1e6 + 1i*1e6;
end
end
% Find a conjugate pole at the current location
function  index = find_conjugate(y, value)
L = length(y);
for k = 1:L
   if imag(y(k)) ~= 0 && imag(y(k)) == - imag(value)
      index = k;
      return
   end
end
index = 0;
end

