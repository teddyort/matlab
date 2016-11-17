function matlabsys = Sys2ss(sys)
%Sys2ss     - Create a MATLAB 'ss' (state-space) system object from a SymSys system
%
% Call:      ssobject = Sys2ss(sys)
%                       ssobject - a MATLAB 'ss' object'
%                       sys      - a Symsys object created by the
%                                  Lgraph2sys() or Sym2sys() functions.
%
%  Notes:    (1) sys must be fully evaluated, that is all system parameter
%            values must have numeric values assigned.
%            (2) Because MATLAB rep[resents systems only by the A, B, C, D
%            matrices, and SymSys system with E and/or F matrices cannot be
%            converted to A MATLAB object using Sys2ss.
%
% Example:   graph = '[2,1,voltage,V],[2,3,resistor,R],[3,1,capacitor,C,vC,iC]';
%            out = 'vC';
%            values = 'C=0.47e-6, R = 10000';
%            sys = Lgraph2sys(graph, out, values);
%            myss = Sys2ss(sys);
%            step(myss);

% Author:        Derek Rowell (drowell@mit.edu)
% Revision Date: May 3, 2009
%--------------------------------------------------------------------------
%
if isempty(sys.Valstring)
   error('sys2ss: System parameters have not been specified')
else
   empty_E = 1;
   [nrows, ncols] = size(sys.E);
   for i = 1:nrows
      for j= 1:ncols
         if ~(sys.E(i,j) == sym(0))
            empty_E = 0;
         end
      end
   end
   empty_F = 1;
   [nrows, ncols] = size(sys.F);
   for i = 1:nrows
      for j= 1:ncols
         if ~(sys.F(i,j) == sym(0))
            empty_F = 0;
         end
      end
   end
   if ~empty_E || ~empty_F
      error(['This system cannot be converted to a MATLAB ''ss'' model'...
         ' because it has non-zero ''E'' and/or ''F'' matrices.'...
         '  Use sys2tf()instead.'])
   end
   eval(sys.Valstring);
   matlabsys = ss(eval(sys.A),eval(sys.B),eval(sys.C),eval(sys.D));
end
end