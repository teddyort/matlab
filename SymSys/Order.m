function order = Order(sys)
%Order - Returns the system order (defined by the size of the Amatrix)
%        of a SymSys system object.
%
% Call:  order = Order(sys)
%        sys - a Symsys system object.

% Author:        Derek Rowell (drowell@mit.edu)
% Revision Date: April 5, 2009
%--------------------------------------------------------------------------
%
order = length(sys.A(:,1);
end