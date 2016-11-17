function varargout = Ematrix(sys,varargin)
%Ematrix - Returns the state-space E matrix of a SymSys system object
%          where the state equations are:
%                   dot(x) = Ax + Bu + Edot(u)
%                       y  = Cx + Du + Fdot(u)
%
% Call:      Ematrix(sys) - "prettyprints" the E matrix of the SymSys
%                      object 'sys' in numeric form, if system
%                      parameter values are set, otherwise
%                      displays the matrix in symbolic form.
%            Ematrix(sys) -  "prettyprints" the E matrix of the SymSys
%                      object 'sys' in symbolic form.
% Call:      E = Ematrix(sys) - returns the E matrix of the SymSys
%                      object 'sys' in numeric form, if system
%                      parameter values are set, otherwise
%                      returns the matrix in symbolic form.
%            E = Ematrix(sys,'sym') - forces the return of the
%                      E matrix in symbolic form.

% Author:        Derek Rowell (drowell@mit.edu)
% Revision Date: Nov. 21, 2010
%--------------------------------------------------------------------------
%
if nargout == 0
   if isempty(sys.Valstring) || (nargin > 1 && strcmp(varargin{1},'sym'))
      pretty(sys.E);
   else
      eval(sys.Valstring);
      pretty(sym(vpa(eval(sys.E),6)));
   end
elseif nargout == 1
   if isempty(sys.Valstring) || (nargin > 1 && strcmp(varargin{1},'sym'))
      varargout{1}  = sys.E;
   else
      eval(sys.Valstring);
      varargout{1} = subs(sys.E);
   end
end
end