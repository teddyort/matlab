function varargout = DampingRatio(sys, varargin)
% DampingRatio - Returns the symbolic damping ratio (zeta) of a second-order SISO
%             SymSys system object.
%
% Call:      zeta = DampingRatio(sys)
%                  - returns the damping ratio of the SISO SymSys object
%                    'sys' in numeric form.
%            tau = DampingRatio(sys, 'sym')
%                  - returns the damping ratio of the SISO SymSys object
%                    'sys' in symbolic form.  If no output variable is
%                    specified the damping ratio is "pretty-printed" on the
%                    display.
%
% Note:     If the system is not SISO, or not second-order with a finite
%           damping ratio, a NaN (not-a-number) is returned.
%
% Example:  g = '(1,2,force,Fs),(2,1,damper,B),(2,1,mass,m),(2,1,spring,K)';
%           sys  = Lgraph2sys(g,'vm', 'm=2,B=3 K=5');
%           zeta = DampingRatio(sys,'sym')
%               - returns  zeta = (B^2/(4*K*m1))^(1/2)
%           zeta = DampingRatio(sys)
%               - returns zeta = 0.4743

% Author:        Derek Rowell (drowell@mit.edu)
% Revision Date: Nov. 20, 2010
%----------------------------------------------------------------
%
if length(sys.Inputs) ~= 1 || length(sys.Outputs) ~= 1
   fprintf(['\nDampingRatio:  System is not single-input',...
      ' single-output./n'])
   wn = NaN;
   return
end
if (nargin == 2 && strcmp(varargin{1},'sym'))
   coeffs = CharPoly(sys,'sym');
else
   coeffs = CharPoly(sys);
end
if length(coeffs) ~= 3
   fprintf('\nDampingRatio:  Not a second-order system./n')
   if nargout == 1
      varargout{1} = NaN;
   end
elseif length(coeffs) == 2 && coeffs(2) == 0
   fprintf(['\nDampingRatio:  This system does not have a finite ',...
      'natural frequency./n'])
   if nargout == 1
      varargout{1} = NaN;
   end
else
   zeta = sqrt(simplify(coeffs(2)^2*coeffs(1)/(4*coeffs(3))));
   if nargout == 0 && nargin ==2 && strcmp(varargin{1},'sym')
      pretty(zeta)
   elseif nargout == 0
      fprintf('\n%f\n',zeta);
   else
      varargout{1} = zeta;
   end
end
end