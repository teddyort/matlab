function sys = Integrator(K, varargin)
%Integrator   Create a SymSys integrator object with a defined gain.
%
%(A)   sys = Integrator('Ki')
%    creates a SymSys integrator object with a transfer function
%                  Ki
%          G(s) = ---
%                  s
%    where Ki is the gain factor.
%
%(B)   sys = Integrator('K',val)
%    creates an integrator objecr and assigns the numeric value of the gain
%    through the string expression val.
%
% Example:   my_integrator = Integrator('K_int', 'K_int=12')
%    creates a SymSys object named 'my_integrator' and assigns a
%    gain factor of 12 to it.

%   Author:         Derek Rowell   (drowell@mit.edu)
%   Revision date:  Oct 29, 2010
%--------------------------------------------------------------------------
input  = ['u_',K];
output = ['y_',K];
state  = ['x_',K];
sys = Matrices2sys(sym(0),sym(K),sym(1),sym(0),sym(0), sym(0),...
   state,input,output);
%
if nargin == 1
   sys.Valstring = '';
elseif(nargin == 2)
   sys.Valstring = [varargin{1},';'];
end
end

