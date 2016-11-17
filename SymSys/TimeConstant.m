function varargout = TimeConstant(sys, varargin)
% TimeConstant - Returns the time-constant of a first-order SymSys system.
%
% Call:      tau = TimeConstant(sys)
%                  - returns the time constant of the SISO SymSys object
%                    'sys' in numeric form.
%            tau = TimeConstant(sys, 'sym')
%                  - returns the time constant of the SISO SymSys object
%                    'sys' in symbolic form.
%
% Note:     If the system is not SISO, or not first-order with a finite
%           time constant, a NaN (not-a-number) is returned.
%
% Example:  g = '(1,2,force,Fs),(2,1,damper,B),(2,1,mass,m)';
%           sys = Lgraph2sys(g,'vm, position=integral(vm)', 'm=2,B=3');
%           tau = TimeConstat(sys,'sym')
%               - returns  tau = m/B
%           tau = FinalValue(sys)
%               - returns tau = 0.6667

% Author:        Derek Rowell (drowell@mit.edu)
% Revision Date: Nov. 20, 2010
%----------------------------------------------------------------
%
if length(sys.Inputs) ~= 1 || length(sys.Outputs) ~= 1
   fprintf(['\nTimeConstant:  System is not single-input',...
      ' single-output./n'])
   if nargout == 1
      varargout{1} = NaN;
   end
   return
end
if (nargin == 2 && strcmp(varargin{1},'sym'))
   coeffs = CharPoly(sys,'sym');
else
   coeffs = CharPoly(sys);
end
%
if length(coeffs) ~= 2
   fprintf('\nTimeConstant:  Not a first-order system./n')
   if nargout == 1
      varargout{1} = NaN;
   end
elseif length(coeffs) == 2 && coeffs(2) == 0
   fprintf(['\nTimeConstant:  This system does not have a finite ',...
      'time-constant./n'])
   if nargout == 1
      varargout{1} = NaN;
   end
else
   tau = simplify(coeffs(1)/coeffs(2));
   if nargout == 0 && nargin ==2 && strcmp(varargin{1},'sym')
      pretty(tau)
   elseif nargout == 0
      fprintf('\n%f\n',tau);
   else
      varargout{1} = tau;
   end
end
end