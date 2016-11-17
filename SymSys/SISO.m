function sysout = SISO(sysin, input,output)
% SISO - Convert a MIMO SymSys object to a SISO SymSys object.
%
%   newsys = SISO(sys, input, output)
%          creates an SymSys object "newsys" that represents the system
%          between input variable "in_var", and output variable "out_var" in
%          "sys".
%
% Notes:  1) The input and output objects may be the same.
%         2) The output object inherits the numerical values from the
%            input object.
%
% Example: g = '(1,2,force,Fs),(2,1,damper,B),(2,1,mass,m),(2,1,spring,K)';
%          vals = 'm=3,B = 5 , K = 40';
%          plant = Lgraph2sys(g,'pos=integral(vm),vm',vals);
%          siso_plant = SISO(plant,'Fs','pos');
%

% Author:    D. Rowell (drowell@mit.edu)
% Date:      Nov 1, 2010
%----------------------------------------------------------------
%
%
syms s
% Handle input arguments
% Handle string or integer input/output specifications
nin  = 1;
nout = 1;
[ninputs]  = length(sysin.Inputs);
[noutputs] = length(sysin.Outputs);
%
if ischar(input)
   nin = 0;
   for k = 1:ninputs
      if input == sysin.Inputs(k)
         nin = k;
      end
   end
   if nin == 0
      error('SISO: Specified input name not found')
   end
else
   nin = input;
end
if ischar(output)
   nout = 0;
   for k = 1:noutputs
      if output == sysin.Outputs(k)
         nout = k;
      end
   end
   if nout == 0
      error('SISO: Specified output name not found')
   end
else
   nout = output;
end

%
if nin > ninputs
   error('SISO: Specified input is greater than number of system inputs.');
end
%
if nout > noutputs
   error('SISO: Specified output is greater than number of system outputs.');
end
%-------------------------
% Form a SISO system  with the specified input
% and output by modifying the system matrices
sysout.A = sysin.A;
% B matrix:
temp     = sysin.B;
sysout.B = temp(:,nin);
% E matrix
temp     = sysin.E;
sysout.E = temp(:,nin);
% C matrix
temp     = sysin.C;
sysout.C = temp(nout,:);
% D matrix
temp     = sysin.D;
sysout.D = temp(nout,nin);
% F matrix
temp     = sysin.F;
sysout.F = temp(nout,nin);
%
sysout.StateVars = sysin.StateVars;
temp             = sysin.Inputs;
sysout.Inputs    = temp(nin);
temp             = sysin.Outputs;
sysout.Outputs   = temp(nout);
sysout.Values    = sysin.Values;
sysout.Valstring = sysin.Valstring;
end