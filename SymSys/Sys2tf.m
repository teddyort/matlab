function tfsys = Sys2tf(sys)
% Sys2tf   - Create a MATLAB 'tf'(transfer function) object from a SymSys system
% Call:      matlabsys = Sys2tf(sys) - returns a MATLAB 'tf' object'
%                   sys       - a SymSys system object,
%                   matlabsys - a MATLAB "tf" system object.
%
% Note:      "sys" must be fully evaluated, that is all system parameters
%            must have numeric values assigned.
%
% Example:   graph = '[(2,1,voltage,V),(2,3,resistor,R),'...
%                      (3,1,capacitor,C,vC,iC)'];
%            out = 'vC';
%            values = 'C=0.47e-6, R = 10000';
%            sys = Lgraph2sys(graph,out,values);
%            mytf = Sys2tf(sys);
%            step(mytf);

% Author:        Derek Rowell (drowell@mit.edu)
% Revision Date: Oct. 24 2010
%----------------------------------------------------------------
%
syms s
[num,den] =TransferFunction(sys);
den_coeffs = poly_coef(den,s);
num_coeffs = poly_coef(num,s);
%
% Check that all coefficients are numeric:
%
den = zeros(1,length(den_coeffs));
for j = 1:length(den_coeffs)
   try
      den(j) = double(den_coeffs(j));
   catch
      error(['SymSys - Error in System Poles: not all system',...
         ' elements have been assigned a numeric value.'])
   end
end
%
num = zeros(1,length(num_coeffs));
for j = 1:length(num_coeffs)
   try
      num(j) = double(num_coeffs(j));
   catch
      error(['SymSys - Error in System Poles: not all system',...
         ' elements have been assigned a numeric value.'])
   end
end
tfsys = tf(num, den);
end