function varargout = Amatrix(sys,varargin)
%Amatrix - Returns the state-space A matrix of a SymSys system object
%          where the state equations are:
%                   dot(x) = Ax + Bu + Edot(u)
%                       y  = Cx + Du + Fdot(u)
%
% Call:      Amatrix(sys) - "prettyprints" the A matrix of the SymSys
%                      object 'sys' in numeric form, if system
%                      parameter values are set, otherwise
%                      displays the matrix in symbolic form.
%            Amatrix(sys,'sym') - "prettyprints" the A matrix of the
%                      SymSys object 'sys' in symbolic form.
%            A = Amatrix(sys) - returns the A matrix of the SymSys
%                      object 'sys' in numeric form, if system
%                      parameter values are set, otherwise
%                      returns the matrix in symbolic form.
%            A = Amatrix(sys,'sym') - forces the return of the
%                      A matrix in symbolic form.

% Author:        Derek Rowell (drowell@mit.edu)
% Revision Date: Nov. 22, 2010
%--------------------------------------------------------------------------
%
if nargout == 0
   if isempty(sys.Valstring) || (nargin > 1 && strcmp(varargin{1},'sym'))
      pretty(sys.A);
   else
      eval(sys.Valstring);
      pretty(sym(vpa(subs(sys.A),6)));
   end
elseif nargout == 1
   if isempty(sys.Valstring) || (nargin > 1 && strcmp(varargin{1},'sym'))
      varargout{1} = sys.A;
   else
      eval(sys.Valstring);
      varargout{1} = subs(sys.A);
   end
end
end