function sys = Gain(K, varargin)
%Gain   Create a SymSys object with a defined algebraic gain.
%
%(A)   sys = Gain('K')
%    creates a SymSys gain object, with a gain with the symbolic name K.
%
%(B)   sys = Gain('K',val)
%    creates a gain objecr and assigtns the numeric value of the gain
%    through the string expression val.
%
% Example:   prop_controller  = Gain('Kp', 'Kp=12')
%    creates a SymSys object named 'prop_controller' and assigns a
%    gain factor of 12 to it.

%   Author:         Derek Rowell   (drowell@mit.edu)
%   Revision date:  Oct 29, 2010
%--------------------------------------------------------------------------
input  = ['u_',K];
output = ['y_',K];
state  = ['x_',K];
sys = Matrices2sys(sym(0),sym(0),sym(0),sym(K),sym(0), sym(0));
if nargin == 1
   sys.Valstring = '';
elseif(nargin == 2)
   sys.Valstring = [varargin{1},';'];
end
sys.Names = K;
sys.Valstring
eval([varargin{1},';']);
sys.Values = eval(K);
end

