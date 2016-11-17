function sys = Differentiator(K, varargin)
%Differentiator   Create a SymSys differentiator object with a defined gain.
%
%(A)   sys = Differentiator('Kd')
%    creates a SymSys differentiator object with a transfer function
%          G(s) = Kd.s
%    where Kd is the gain factor.
%
%(B)   sys = Differentiator('K',val)
%    creates a differentiator objecr and assigns the numeric value of
%    the gain through the string expression val.
%
% Example:   my_differentiator = Differentiator('K_dif', 'K_dif=2')
%    creates a SymSys object named 'my_differentiator' and assigns a
%    gain factor of 2 to it.

%   Author:         Derek Rowell   (drowell@mit.edu)
%   Revision date:  Oct 29, 2010
%--------------------------------------------------------------------------
sys = Matrices2sys(sym(0),sym(0),sym(0),sym(0),sym(0), sym(K),...
   state,input,output);
%
if nargin == 1
   sys.Valstring = '';
elseif(nargin == 2)
   sys.Valstring = [varargin{1},';'];
end
end

