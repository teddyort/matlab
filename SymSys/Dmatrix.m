function varargout = Dmatrix(sys,varargin)
%Dmatrix - Returns the state-space D matrix of a SymSys system objectS
%          where the state equations are:
%                         dot(x) = Ax + Bu + Edot(u)
%                             y  = Cx + Du + Fdot(u)
%
% Call:      Dmatrix(sys) - "prettyprints" the D matrix of the SymSys
%                      object 'sys' in numeric form, if system
%                      parameter values are set, otherwise
%                      displays the matrix in symbolic form.
%            DAmatrix(sys) -  "prettyprints" the D matrix of the SymSys
%                      object 'sys' in symbolic form.
%            D = Dmatrix(sys) - returns the D matrix of the syrep
%                      object 'sys' in numeric form, if system
%                      parameter values are set, otherwise
%                      returns the matrix in symbolic form.
%            D = Dmatrix(sys,'sym') - forces the return of the
%                      D matrix in symbolic form.

% Author:        Derek Rowell (drowell@mit.edu)
% Revision Date: Nov. 21, 2010
%--------------------------------------------------------------------------
%
if nargout == 0
   if isempty(sys.Valstring) || (nargin > 1 && strcmp(varargin{1},'sym'))
      pretty(sys.D);
   else
      eval(sys.Valstring);
      pretty(sym(vpa(eval(sys.D),6)));
   end
elseif nargout == 1
   if isempty(sys.Valstring) || (nargin > 1 && strcmp(varargin{1},'sym'))
      varargout{1}  = sys.D;
   else
      eval(sys.Valstring);
      varargout{1} = subs(sys.D);
   end
end
end