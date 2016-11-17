function yout = xresponse(num,den,input,precision)
%

%xresponse - Internal SymSys function
%            Find the time domain response from a Laplace input.
%
% Note:      This is an internal SymSys function and is not a user called
%            function.
%
% Call:     y = xresponse(num, den, input, precision)
%                 num, den - numerator and denominator of the system
%                            transfer function.
%                 input     - Laplace transform of the system input.
%                 precision - arithmetic precision (decimal digits)
%                 y        -  symbolic response
%
% Author:        Derek Rowell (drowell@mit.edu)
% Revision Date: Nov. 29, 2010
%----------------------------------------------------------------
%
syms s
syms t real
D__ = digits;
digits(precision);
[innum,inden] = numden(input);
num = num*innum;
den = den*inden;
[r, p, k] = residue(sym2poly(num),sym2poly(den));
pfrac  = 0;
i      = 1;
repeat = 0;
% Form a sum of first-order linear terms (real and complex)
while i <=length(p)
   if (i>1) && p(i)==p(i-1)
      repeat = repeat+1;
   else
      repeat = 0;
   end
   pfrac = pfrac + r(i)/(s-p(i))^(repeat+1);
   i = i+1;
end
if ~isempty(k)
   L = length(k);
   for i = 1:L
      pfrac = pfrac + k(i)*s^(L-i);
   end
end
pfrac = vpa(pfrac, precision);
%
yout = simplify(ilaplace(pfrac));
%yout=vpa(ilaplace(pfrac),precision);
%yout = simplify(vpa((y+conj(y))/2,precision));
%yout = subs(yout,conj(dirac(t)),dirac(t));
%yout=vpa(y);
digits(D__);
end
