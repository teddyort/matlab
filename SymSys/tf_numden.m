function [num,den,gain] = tf_numden(sys, varargin)
%

%tf_numden - Internal SymSys function
%            Return the numerator, denominator, and gain of a symbolic
%            transfer function
%
% Note:      This is an internal SymSys function and is not a user called
%            function
%
% Call:      [num, den, gain] = tf_numden (sys)
%
% Author:        Derek Rowell (drowell@mit.edu)
% Revision Date: April 5, 2009
%----------------------------------------------------------------
%
syms s
% Check for a SISO system
[~, n_in]  = size(sys.B);
[n_out, ~] = size(sys.C);
if ~(n_in ==1) || ~(n_out ==1)
   error('tf_numden: Not a SISO system - need to specify input and output')
end
%
if isempty(sys.Valstring) || (nargin > 1 && strcmp(varargin{1},'sym'))
   A__ = sys.A;
   B__ = sys.B;
   C__ = sys.C;
   D__ = sys.D;
   E__ = sys.E;
   F__ = sys.F;
   %
   [n_rows, m_cols] = size(A__);
   if n_rows == m_cols
      sminusA = (s*eye(n_rows) - A__);
      cpoly =(det(sminusA));
      %
      % Form the numerator and the denominator separately
      % because it handles the D matrix better this way.
      %
      num = sym(collect(simplify(cpoly*(C__*inv(sminusA)*(B__+s*E__)...
                + (D__+s*F__))),s));
      den = sym(collect(simplify(cpoly),s));
%      numcoeff = sym2poly(num);
%     dencoeff = sym2poly(den);
   numcoeff = poly_coef(num,s);
   dencoeff = poly_coef(den,s);
      gain = sym(vpa(1/dencoeff(1),6));
      %x=gcd(sym(num),sym(den),s);
      %num=sym(num/x);
      den=simplify(sym(den/gain));
   else
      error('tf_numden: Invalid system specification')
   end
else
   % Numeric form:
   [n_rows, m_cols] = size(Amatrix(sys));
   %
   if n_rows == m_cols
      sminusA = (s*eye(n_rows) - Amatrix(sys));
      cpoly = (det(sminusA));
      num = sym(collect(simplify(cpoly*(Cmatrix(sys)*inv(sminusA)*...
         (Bmatrix(sys) + s*Ematrix(sys)) + (Dmatrix(sys)+s*Fmatrix(sys)))),s));
      den = sym(collect(simplify(cpoly),s));
      %
      % Extract the coefficients of the numerator and denominator polynomials
      %
      numcoeff = poly_coef(num,s);
      dencoeff = poly_coef(den,s);
      num = vpa(poly2sym(numcoeff/numcoeff(1),s),6);
      %   cmd = ['maple(''sort(',char(num),')'')'];
      %   num = eval(cmd);
      %   den = vpa(poly2sym(dencoeff/dencoeff(1),s),6);
      %   den = eval(cmd);
      %tf = ['(',num,')/(',den,')'];
      x=gcd(sym(num),sym(den),s);
      num=sym(num/x);
      den=simplify(sym(den/x));
      gain = sym(vpa(numcoeff(1)/dencoeff(1),6));
      %
   else
      error('tf_numden: Invalid system - non-square A matrix')
   end
end