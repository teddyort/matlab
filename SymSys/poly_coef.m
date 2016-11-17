function coefs = poly_coef(poly, var)
%

% poly_coef - Internal SymSys function
%             Returns a complete set of symbolic polynomial coefficients.
%
% Note:   This is an internal function in the SymSys package.
%         It is not a user called function.
%
% Call:  coeffs  = polycoefs(polynomial, var)
%               polynomial - a symbolic polynomial
%               var        -  a variable name(symbolic)
%               coeffs     - list of coefficients in descending order.
%
% Author:        Derek Rowell (drowell@mit.edu)
% Revision Date: April 17, 2009
%----------------------------------------------------------------
%
[c,t] = coeffs(poly,var);
order=0;
% Find the order of the polynomial
while t(1) ~= sym(var^order) && order<100
   order=order+1;
end
coefs = sym(zeros(1, order + 1));
%
for j = order+1:-1:2
   for k=1:length(t)
      if t(k) == var^(j-1)
         coefs(order+2-j) = c(k);
      end
   end
end
% The polynomial term in s^{0} is reported as 1.
if t(length(t)) == 1
   coefs(order+1) = c(length(t));
end
