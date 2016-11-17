function sys = Parallel(sys1, sys2)
% Parallel   Combine two SISO SymSys objects into a parallel connected
% system
%                          ------      +
%              u ---.---->| sys1 |----->O-----> y
%                   |      ------     + ^
%                   |      ------       |
%                   ----->| sys2 |------
%                          ------
%    sys = Parallel(sys1,sys2)
%       creates a system sys that combines the two SISO systems sys1 and
%       sys2 in parallel, that is driven by a common input with the two
%       outputs summed.
%
% Notes: 1) The state variables of the two systems are reatained in the
%           system.
%        2) Numeric values assigned to elements of the two input systems
%           are inherited by the output system.
%
% Example:  sys1 = TF2sys('1/(R1*C1*s+1)');
%           sys2 = TF2sys('1/(R2*C2*s+1)');
%           parallel_sys = Parallel(sys1, sys2);
%           TransferFunction(parallel_sys)
%
%         displays the transfer function for the parallel system:
%
%                    (C1 R1 + C2 R2) s + 2
%          ----------------------------------------
%                         2
%          (C1 C2 R1 R2) s  + (C1 R1 + C2 R2) s + 1

%   Author:         Derek Rowell   (drowell@mit.edu)
%   Revision date:  Nov. 22, 2010
%--------------------------------------------------------------------------
% Check that both input systems are SISO:
if   (length(sys1.Inputs)  ~= 1 || length(sys2.Inputs)  ~= 1 ...
      || length(sys1.Outputs) ~= 1 || length(sys2.Outputs) ~= 1)
   error(['Parallel:  Both input systems must be single-input',...
      ' single-output (SISO)'])
end
%
% Combine the two systems
%
[nrow1,ncol1] = size(sys1.A);
[nrow2,ncol2] = size(sys2.A);
% Take into account if one of the systems is algebraic, eg a gain block.
% and will not alter the order of the combined system.
if ~is_zero(sys1.A) && ~is_zero(sys2.A)
   A1 = [sys1.A, zeros(ncol2,nrow1)];
   A2 = [zeros(ncol1,nrow2), sys2.A];
   Anew = [A1; A2];
   Bnew = [sys1.B; sys2.B];
   Cnew = [sys1.C, sys2.C];
   Dnew = sys1.D + sys2.D;
   Enew = [sys1.E; sys2.E];
   Fnew = sys1.F + sys2.F;
   StateVars = [sys1.StateVars; sys2.StateVars];
elseif is_zero(sys1.A)
   Anew = sys2.A;
   Bnew = sys2.B;
   Cnew = sys2.C;
   Dnew = sys2.D + sys1.D;
   Enew = sys2.E;
   Fnew = sys1.F + sys2.F;
   StateVars = [sys2.StateVars];
elseif is_zero(sys2.A)
   Anew = sys1.A;
   Bnew = sys1.B;
   Cnew = sys1.C;
   Dnew = sys2.D + sys1.D;
   Enew = sys1.E;
   Fnew = [sys1.F + sys2.F];
   StateVars = [sys1.StateVars];
end
sys = Matrices2sys(Anew,Bnew,Cnew,Dnew,Enew,Fnew,sym('u'),sym('y'),StateVars);
sys.Valstring = [sys1.Valstring, sys2.Valstring];
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

