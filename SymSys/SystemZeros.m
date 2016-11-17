function Zeros = SystemZeros(sys)
% SystemZeros -  Find the zeros of a fully evaluated SymSys SISO sytem.
%
%     zeros = SystemZeros(sys)
%                 - sys a "fully evaluated" (all parameters have been
%                       assigned numerical values) SymSys system object.
%

%  Author:         Derek Rowell   (drowell@mit.edu)
%  Revision date:  Oct 29, 2010
%--------------------------------------------------------------------------
syms s
[num,den]  = TransferFunction(sys);
den_coeffs = coeffs(den,s);
num_coeffs = coeffs(num,s);
%
% Check that all coefficients are numeric:
%
x = zeros(1,length(den_coeffs));
for j = 1:length(den_coeffs)
   try
      x(j) = double(den_coeffs(j));
   catch
      error(['SystemZeros: not all system',...
         ' elements have been assigned a numeric value.'])
   end
end
%
x = zeros(1,length(num_coeffs));
for j = 1:length(num_coeffs)
   try
      x(j) = double(num_coeffs(j));
   catch
      error(['SystemZeros: not all system',...
         ' elements have been assigned a numeric value.'])
   end
end
tfsys = Sys2tf(sys);
Zeros = zero(tfsys);
end

