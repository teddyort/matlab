function varargout = Fmatrix(sys,varargin)
%Fmatrix - Returns the state-space F matrix of a SymSys system object
%          where the state equations are:
%                         dot(x) = Ax + Bu + Edot(u)
%                             y  = Cx + Du + Fdot(u)
%
% Call:      Fmatrix(sys) - "prettyprints" the F matrix of the SymSys
%                      object 'sys' in numeric form, if system
%                      parameter values are set, otherwise
%                      displays the matrix in symbolic form.
%            Fmatrix(sys) -  "prettyprints" the F matrix of the SymSys
%                      object 'sys' in symbolic form.
%            F = Fmatrix(sys) - returns the F matrix of the SymSys
%                      object 'sys' in numeric form, if system
%                      parameter values are set, otherwise
%                      returns the matrix in symbolic form.
%            F = Fmatrix(sys,'sym') - forces the return of the
%                      F matrix in symbolic form.

% Author:        Derek Rowell (drowell@mit.edu)
% Revision Date: Nov. 21, 2010
%----------------------------------------------------------------
%
if nargout == 0
   if isempty(sys.Valstring) || (nargin > 1 && strcmp(varargin{1},'sym'))
      pretty(sys.F);
   else
      eval(sys.Valstring);
      pretty(sym(vpa(eval(sys.F),6)));
   end
elseif nargout == 1
   if isempty(sys.Valstring) || (nargin > 1 && strcmp(varargin{1},'sym'))
      varargout{1}  = sys.F;
   else
      eval(sys.Valstring);
      varargout{1} = subs(sys.F);
   end
end
end