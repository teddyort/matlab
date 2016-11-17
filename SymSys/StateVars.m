function StateVars(sys)
% StateVars - Display the names of the state-variables of a SymSys system
%
% Call:      StateVars(sys)
%                sys - a SymSys object.

% Author:        Derek Rowell (drowell@mit.edu)
% Revision Date: April 5, 2009
%--------------------------------------------------------------------------
%
pretty(sys.StateVars)
end