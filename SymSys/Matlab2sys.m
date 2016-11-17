function  sys = Matlab2sys(matsys)
%Matlab2sys - Generate a SymSys system object from a MATLAB system object.
%
% Call:   sys = Matlab2sys(matlab_sys)
%         matlab_sys - a MATLAM sytem object.
%
% Example:   mysys = tf([1 9],[1 2 1])
%            symsys_sys = Mat2SymSys(mysys);
%            StateSpace(symsys_sys)
%
% Note:    Matrices2sys will generate names as follows:
%                  state variable names:    x1, ... xn
%                  input variable names:    u1, ....ur
%                  output variable names:   y1, ....um
%          for a system of order n, with r inputs and m outputs.

% Author:        Derek Rowell (drowell@mit.edu)
% Revision Date: April 5, 2009
%--------------------------------------------------------------------------
%
[A, B, C, D] = ssdata(matsys);
% Determine the size of the system
n_states = length(A(:,1));
n_inp = length(B(1,:));
n_out = length(C(:,1));
%
% Sysytem matricies
sys.A = sym(A);
sys.B = sym(B);
sys.C = sym(C);
sys.D = sym(D);
sys.E = sym(zeros(n_states, n_inp));
sys.F = sym(zeros(n_out, n_inp));
%
% State variables
names = sym(zeros(n_states,1));
for k=1:n_states
   name=['x',int2str(k)];
   names(k,1) = name;
end
sys.StateVars = names;
%
% Inputs
names = sym(zeros(n_inp,1));
for k=1:n_inp
   name=['u',int2str(k)];
   names(k,1) = name;
end
sys.Inputs = names;
%
% Outputs
names = sym(zeros(n_out,1));
for k=1:n_out
   name=['y',int2str(k)];
   names(k,1) = name;
end
sys.Outputs = names;
%
% Values
sys.Valstring = '';
sys.Values = [];
sys.Names = [];
end



