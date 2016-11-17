function newsys = PhaseVariable(sys)
%PhaseVariable    - Transform a Symsys object to a phase-variable representation
%
% Call            newsys = PhaseVariable(sys)
%                          sys - an existing SymSys system object.

% Author:         Derek Rowell (drowell@mit.edu)
% Revision Date:  Nov. 29, 2010
%--------------------------------------------------------------------------
%
if ~length(sys.Inputs) == 1 || ~length(sys.Outputs) == 1
   error('PhaseVariable: The system must be single-input single- output')
end
tf1 = TransferFunction(sys,'sym');
newsys = TF2sys(tf1);
newsys.Names     = sys.Names;
newsys.Values    = sys.Values;
newsys.Valstring = sys.Valstring;
end

