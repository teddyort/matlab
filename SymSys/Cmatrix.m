function varargout = Cmatrix(sys,varargin)
%Cmatrix - Returns the state-space C matrix of a SymSys system objectSS
%          where the state equations are:
%                         dot(x) = Ax + Bu + Edot(u)
%                             y  = Cx + Du + Fdot(u)
%
% Call:      Cmatrix(sys) - "prettyprints" the C matrix of the SymSys
%                      object 'sys' in numeric form, if system
%                      parameter values are set, otherwise
%                      displays the matrix in symbolic form.
%            Cmatrix(sys) -  "prettyprints" the C matrix of the SymSys
%                      object 'sys' in symbolic form.
%            C = Cmatrix(sys) - returns the C matrix of the SymSys
%                      object 'sys' in numeric form, if system
%                      parameter values are set, otherwise
%                      returns the matrix in symbolic form.
%            C = Cmatrix(sys,'sym') - forces the return of the
%                      C matrix in symbolic form.

% Author:        Derek Rowell (drowell@mit.edu)
% Revision Date: Nov. 21, 2010
%--------------------------------------------------------------------------
%
if nargout == 0
   if isempty(sys.Valstring) || (nargin > 1 && strcmp(varargin{1},'sym'))
      pretty(sys.C);
   else
      eval(sys.Valstring);
      pretty(sym(vpa(eval(sys.C),6)));
   end
elseif nargout == 1
   if isempty(sys.Valstring) || (nargin > 1 && strcmp(varargin{1},'sym'))
      varargout{1}  = sys.C;
   else
      eval(sys.Valstring);
      varargout{1} = subs(sys.C);
   end
end
end