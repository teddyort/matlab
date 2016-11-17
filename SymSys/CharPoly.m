function varargout = CharPoly(sys, varargin)
% CharPoly - Displays or returns the symbolic characteristic polynomial
%            of a SymSys object.
%
% (A)    CharPoly(sys) - displays the characteristic polynomial of the
%                      SymSys object 'sys'.  Displays the polynomial in
%                      numeric form if values have been assigned to the
%                      system parameters, otherwise in symbolic form.
% (B)    CharPoly(sys,'sym') - displays the characteristic polynomial of
%                      the SymSys object 'sys' in symbolic form.
% (C)    coefs = CharPoly(sys), or
%        coefs = CharPoly(sys,'sym') - returns the coefficients of the
%                      characteristic polynomial in the row vector 'coefs'
%                      (in descending order), in numeric or symbolic form.

% Author:        Derek  Rowell (drowell@mit.edu)
% Revision Date: Nov. 22, 2010
%----------------------------------------------------------------
%
syms s
D = digits;
precision = 5;
digits(precision);
%
if nargin == 2 && strcmp(varargin{1},'sym')
   A__ = Amatrix(sys,'sym');
   cpoly = poly(A__,s);
else
   A__ = Amatrix(sys);
   cpoly =vpa(poly(A__,s));
end
%
if nargout == 0
   pretty(cpoly)
else
   coefs = poly_coef(cpoly,s);
   % Attempt to evaluate the coefficients - it will fail is they are
   % not all numeric.
   try
      coefs = eval(coefs);
   catch
      % Don't do anything if there was an error - just return the symbolic
      % form.
   end
   varargout{1} = coefs;
end
digits(D);
end

