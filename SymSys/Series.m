function sys = Series(sys1, sys2)
% Series   Combine two SymSys objects into a series connected SISO system.
%                      ------        ------
%              u ---->| sys1 |----->| sys2 |-----> y
%                      ------        ------
%
%    sys = Series(sys1,sys2)
%       creates a system sys that combines the two SISO systems sys1 and
%       sys2 in series.
%
% Notes: 1) If possible the state variables of the two input systems are
%           retained in the output system.
%        2) If is not possible to retain the state variables (non-zero
%           E or F matrices), the output system is expressed in
%           phase-variable form.
%        3) Numeric values assigned to elements of the two input systems
%           are inherited by the output system.
%        4) The order of the two systems in the input arguments is
%           important in that the combined system input name is taken
%           from sys1, and the output name is taken from sys2. 
%
% Example:  sys1 = TF2sys('1/(R1*C1*s+1)','R1=1000,C1=0.0001');
%           sys2 = TF2sys('1/(R2*C2*s+1)','R2=2000,C2=0.0002');
%           cascade_sys = Series(sys1, sys2);
%           TransferFunction(cascade_sys,'sym')
%
%         displays the symbolic transfer function for the series system:
%
%                              1
%           ----------------------------------------
%                         2
%          (C1 C2 R1 R2) s  + (C1 R1 + C2 R2) s + 1
%

%   Author:         Derek Rowell   (drowell@mit.edu)
%   Revision date:  Nov. 22, 2010
%--------------------------------------------------------------------------
% Check that both input systems are SISO:
if   (length(sys1.Inputs)  ~= 1 || length(sys2.Inputs)  ~= 1 ...
      || length(sys1.Outputs) ~= 1 || length(sys2.Outputs) ~= 1)
   error(['Series:  Both input systems must be single-input',...
      ' single-output (SISO)'])
end
%
% Attempt to combine the input State-spaces matrices directly.  This can
% only be done if E=[0] and F=[0] for both systems.
%
if is_zero(sys1.E) && is_zero(sys1.F) && is_zero(sys2.E) && is_zero(sys2.F)
   [nrow1,~] = size(sys1.A);
   [~,ncol2] = size(sys2.A);
% Take into account if one of the systems is algebraic, eg a gain block,
% and will not alter the order of the combined system.
if ~is_zero(sys1.A) && ~is_zero(sys2.A)
      A1   = [sys1.A, sym(zeros(nrow1,ncol2))];
      A2   = [sys2.B*sys1.C, sys2.A];
      Anew = [A1;A2];
      Bnew = [sys1.B; sys2.B*sys1.D];
      Cnew = [sys2.D*sys1.C, sys2.C];
      Dnew = sys2.D*sys1.D;
      Enew = 0;
      Fnew = 0;
      StateVars = [sys1.StateVars; sys2.StateVars];
   elseif is_zero(sys1.A)
      Anew = sys2.A;
      Bnew = sys2.B*sys1.D;
      Cnew = sys2.C;
      Dnew = sys2.D*sys1.D;
      Enew = 0;
      Fnew = 0;
      StateVars = [sys2.StateVars];
   elseif is_zero(sys2.A)
      Anew = sys1.A;
      Bnew = sys1.B;
      Cnew = sys2.D*sys1.C;
      Dnew = sys2.D*sys1.D;
      Enew = 0;
      Fnew = 0;
      StateVars = [sys1.StateVars];
   end
   sys = Matrices2sys(Anew,Bnew,Cnew,Dnew,Enew,Fnew,sys1.Inputs,...
                      sys2.Outputs,StateVars);
else
   % Create a phase-variable representation
   [num1,den1] = TransferFunction(sys1,'sym');
   [num2,den2] = TransferFunction(sys2,'sym');
   sys = TF2sys(expand(num1*num2)/expand(den1*den2));
end
% Inherit the values from the input systems
sys.Valstring = [sys1.Valstring , sys2.Valstring];
sys.Values    = [sys1.Values; sys2.Values];
sys.Names     = [sys1.Names; sys2.Names];
end
%-----------------------------------------------
function iszero = is_zero(mat)
[nrows, ncols] = size(mat);
iszero = true;
for j=1:nrows
   for k=1:ncols
      if mat(j,k) ~= 0
         iszero = false;
      end
   end
end
end
