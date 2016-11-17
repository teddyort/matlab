function StateSpace(sys,varargin)
%StateSpace - Display the state-space representation of a SymSys object
%                  where the state equations are:
%                      dot(x) = Ax + Bu + Edot(u)
%                          y  = Cx + Du + Fdot(u)
%
% Call:      StateSpace(sys) - "prettyprints" the SymSys state-space
%                     representation of 'sys' in numeric form
%                     if numeric system parameter values are set, otherwise
%                     displays the system in symbolic form.
%            StateSpace(sys, 'sym') -  "prettyprints" the SymSys
%                     object 'sys' in symbolic form.
%
% Note:      The E and F matrices are displayed only if they are non-zero.

% Author:        Derek Rowell (drowell@mit.edu)
% Revision Date: Oct 29, 2010
%--------------------------------------------------------------------------
%
%
E_is_zero = 1;
[rows, cols] = size(sys.E);
for j = 1:rows
   for k = 1:cols
      if sys.E(j,k) ~= 0
         E_is_zero = 0;
      end
   end
end
%
F_is_zero = 1;
[rows, cols] = size(sys.F);
for j = 1:rows
   for k = 1:cols
      if sys.F(j,k) ~= 0
         F_is_zero = 0;
      end
   end
end
fprintf('\n\nState-space representation of system:')
if E_is_zero
   fprintf('\n           dot(x) = Ax + Bu')
else
   fprintf('\n           dot(x) = Ax + Bu + {Edot(u)}')
end
if F_is_zero
   fprintf('\n                y = Cx + Du')
else
   fprintf('\n                y = Cx + Du + {Fdot(u)}')
end
%
if isempty(sys.Valstring) || (nargin > 1 && strcmp(varargin{1},'sym'))
   % Print symbolic matrices
   fprintf('\nState vector x:')
   pretty(sys.StateVars);
   fprintf('\nA matrix:')
   pretty(sys.A);
   fprintf('\nInput vector u:')
   pretty(sys.Inputs);
   fprintf('\nB matrix:')
   pretty(sys.B);
   % Only print E matrix if it is non-zero (rare).
   if ~E_is_zero
      fprintf('\nE matrix:')
      pretty(sys.E);
   end
   %
   fprintf('\nOutput vector y:')
   pretty(sys.Outputs);
   fprintf('\nC matrix:')
   pretty(sys.C);
   fprintf('\nD matrix:')
   pretty(sys.D);
   % Only print F matrix if it is non-zero (rare).
   if ~F_is_zero
      fprintf('\nF matrix:')
      pretty(sys.F);
   end
else
   % Print numeric matrices
   eval(sys.Valstring);
   fprintf('\nState vector x:')
   pretty(sys.StateVars);
   fprintf('\nA matrix:')
   pretty(sym(vpa(subs(sys.A),6)));
   fprintf('\nInput vector u:')
   pretty(sys.Inputs);
   fprintf('\nB matrix:')
   pretty(sym(vpa(subs(sys.B),6)));
   % Only print E matrix if it is non-zero (rare).
   if ~E_is_zero
      fprintf('\nE matrix:')
      pretty(sym(vpa(subs(sys.E),6)));
   end
   fprintf('\nOutput vector y:')
   pretty(sys.Outputs);
   fprintf('\nC matrix:')
   pretty(sym(vpa(subs(sys.C),6)));
   fprintf('\nD matrix:')
   pretty(sym(vpa(subs(sys.D),6)));
   % Only print F matrix if it is non-zero (rare).
   if ~F_is_zero
      fprintf('\nF matrix:')
      pretty(sym(vpa(subs(sys.F),6)));
   end
end
end