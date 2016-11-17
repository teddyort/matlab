function varargout = Bmatrix(sys,varargin)
%Bmatrix - Returns the state-space B matrix of a SymSys system object
%          where the state equations are:
%                         dot(x) = Ax + Bu + Edot(u)
%                             y  = Cx + Du + Fdot(u)
%
% Call:      Bmatrix(sys) - "prettyprints" the B matrix of the SymSys
%                      object 'sys' in numeric form, if system
%                      parameter values are set, otherwise
%                      displays the matrix in symbolic form.
%            Bmatrix(sys) -  "prettyprints" the B matrix of the SymSys
%                      object 'sys' in symbolic form.
%            B = Bmatrix(sys) - returns the B matrix of the SymSys
%                      object 'sys' in numeric form, if system
%                      parameter values are set, otherwise
%                      returns the matrix in symbolic form.
%            B = Bmatrix(sys,'sym') - forces the return of the
%                      A matrix in symbolic form.

% Author:        Derek Rowell (drowell@mit.edu)
% Revision Date: Nov. 2, 2010
%--------------------------------------------------------------------------
%
if nargout == 0
   if isempty(sys.Valstring) || (nargin > 1 && strcmp(varargin{1},'sym'))
      pretty(sys.B);
   else
      eval(sys.Valstring);
      pretty(sym(vpa(eval(sys.B),6)));
   end
elseif nargout == 1
   if isempty(sys.Valstring) || (nargin > 1 && strcmp(varargin{1},'sym'))
      varargout{1}  = sys.B;
   else
      eval(sys.Valstring);
      varargout{1} = subs(sys.B);
   end
end
end