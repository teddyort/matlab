function varargout = NaturalFrequency(sys, varargin)
% NaturalFrequency - Returns the symbolic undamped natural frequency (w_n) of a system
%            (second-order).
%
% Call:      wn = NaturalFrequency(sys)
%                  - returns the undamped natural frequency of the SISO
%                    SymSys object'sys' in numeric form.
%            wn = NaturalFrequency(sys, 'sym')
%                  - returns the undamped natural frequency of the SISO
%                    SymSys object'sys' in symbolic form.  If no output
%                    variable isspecified the undamped natural frequency
%                    is "pretty-printed" on the display.
%
% Note:     If the system is not second-order with a finite
%           undamped natural frequency, a NaN (not-a-number) is returned.
%
% Example: g = '(1,2,force,Fs),(2,1,damper,B),(2,1,mass,m),(2,1,spring,K)';
%          sys = Lgraph2sys(g,'vm', 'm=2,B=3 K=5');
%          wn  = NaturalFrequency(sys,'sym')
%                - returns  wn = (K/m)^(1/2)
%          wn  = NaturalFrequency(sys)
%                - returns  wn = 1.5811

% Author:        Derek Rowell (drowell@mit.edu)
% Revision Date: Nov. 20, 2010
%----------------------------------------------------------------
%
if (nargin == 2 && strcmp(varargin{1},'sym'))
   coeffs = CharPoly(sys,'sym');
else
   coeffs = CharPoly(sys);
end
if length(coeffs) ~= 3
   fprintf('\nNaturalFrequency:  Not a second-order system./n')
   if nargout == 1
      varargout{1} = NaN;
   end
elseif length(coeffs) == 2 && coeffs(2) == 0
   fprintf(['\nNaturalFrequency:  This system does not have a finite ',...
      'natural frequency./n'])
   if nargout == 1
      varargout{1} = NaN;
   end
else
   wn = sqrt(coeffs(3)/coeffs(1));
   if nargout == 0 && nargin ==2 && strcmp(varargin{1},'sym')
      pretty(wn)
   elseif nargout == 0
      fprintf('\n%f\n',wn);
   else
      varargout{1} = sqrt(coeffs(3)/coeffs(1));
   end
end
end