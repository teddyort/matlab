function varargout = StateICresponse(sys, ic )
%StateICresponse - Displays/returns the homogeneous response of a Symsys object
%                 to a set of initial conditions on the state variables.
%
% (A)  StateICresponse(sys, ic) - "prettyprints" the symbolic closed-form
%           homogeneous response.
%        sys - a SymSys system object,
%        ic  - a vector of initial conditions on the state variables.
%
% (B)  y = StateICresponse(sys, ic) - returns the closed-form homogeneous
%           response in the symbolic variable y.
%
% Note: The initial conditions must be specified in the order that the
%       state variables are specified in StateVars(sys).

% Author:        Derek Rowell (drowell@mit.edu)
% Revision Date: Feb. 10, 2011
%--------------------------------------------------------------------------
%
syms t real
precision=5;
D__ = digits;
digits(precision)
% Check the number of arguments
if nargin ~= 2
   error('StateICresponse: requires two arguments (system and IC''s)')
end;
A__ = Amatrix(sys);
C__ = Cmatrix(sys);
if ~isnumeric(A__) || ~isnumeric(C__)
   error(['StateICresponse: Not all system parameters have been ',...
      'assigned numeric values.']);
end
order = length(A__(:,1));
if length(ic) ~= order
   error(['StateICresponse: Number of specified initial conditions',...
      ' must match the system order'])
end
[nrows, ncols] = size(ic);
if ncols == order && nrows ==1
   ic = ic';
elseif nrows == 1 && ncols ~= order
   error('StateICresponse:  Size of ic vector must match the system order')
end
%
% Compute the matrix exponential and the response
%
exp_At = expm(A__*t);
y = vpa(C__*exp_At*ic);
%
if nargout == 0
   pretty(simplify(y))
else
   varargout{1} = simplify(y);
end
digits(D__);
end

