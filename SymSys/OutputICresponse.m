function varargout = OutputICresponse(sys, ic )
%OutputICresponse - Displays/returns the homogeneous response of a SymSys
%                  SISO system object to a set of initial conditions on
%                  the output variable.
%
% (A)  OutputICresponse(sys, ic) - "prettyprints" the symbolic closed-form
%           homogeneous response.
%        sys - a SymSys system object,
%        ic  - a vector of N initial conditions on the output variable
%              y(t), consisting of y(0), and its first (N-1) derivatives
%              evaluated at t=0, where N is the system order.
%
% (B)  y = OutputICresponse(sys, ic) - returns the closed-form homogeneous
%           response in the symbolic variable y.
%

% Author:        Derek Rowell (drowell@mit.edu)
% Revision Date: Nov. 14, 2010
%--------------------------------------------------------------------------
%
syms s
precision = 5;
D__ = digits;
digits(precision);
% Check the number of arguments
if nargin ~= 2
   error('OutputICresponse: requires two arguments (system and IC''s)')
end;
%
cpoly = CharPoly(sys);
A__ = Amatrix(sys);
order = length(A__(:,1));
if length(ic) ~= order
   error(['OutputICresponse: Number of specified initial conditions',...
      ' must match the system order'])
end
if ~isnumeric(A__)
   error(['OutputICresponse: Not all system parameters have been ',...
      'assigned numeric values.']);
end
%
y_temp = 0;
for i = 1:order
   for j = 1:i
      y_temp = y_temp + cpoly(order+1-i)*s^(i-j)*ic(j);
   end;
end;
%
% From xresponse():
[r, p, k] = residue(sym2poly(y_temp),cpoly);
partial_frac = 0;
i = 1;
repeat = 0;
% Form a sum of first-order linear terms (real and complex)
while i <= length(p)
   if i>1 && p(i) == p(i-1)
      repeat = repeat+1;
   else
      repeat = 0;
   end
   partial_frac = partial_frac + r(i)/(s-p(i))^(repeat+1);
   i = i+1;
end
if ~isempty(k)
   partial_frac = partial_frac + k*input;
end
%
precision = 5;
y = ilaplace(partial_frac);
if nargout == 0
   pretty(simplify(vpa(y, precision)))
else
   varargout{1} = simplify(vpa(y, precision));
end
digits(D__);
end

