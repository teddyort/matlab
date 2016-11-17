function sys = PID(Kp, Ki, Kd, varargin)
% PID   Create a SymSys PID controller object.
%
%(a)   sys = PID(Kp,Ki,Kd)
%    creates a PID SymSys objecr with transfer function
%                          Ki
%           G_p(s) = Kp + --- + Kds
%                          s
%    where Kp, Ki, Kd are symbolic names (string) for the proportional,
%    integral and derivative coefficients.
%
%(b)   sys = PID(Kp,Ki,Kd,vals)
%    creates a PID SymSys objecr and assigtns numeric values to one or more
%    of the coefficients as defined by the  comma-separated sring variable
%    vals.
%
% Example:   controller = PID('prop', 'int', 'deriv', 'prop=20,int=2')
%    creates a SymSys object named 'controller' and assigns numeric values
%    to the proportional and integral gains.

%   Author:         Derek Rowell   (drowell@mit.edu)
%   Revision date:  Oct 29, 2010
%--------------------------------------------------------------------------
sys = Matrices2sys(sym(0),sym(1),sym(Ki),sym(Kp),sym(0), sym(Kd),...
   'x','u','y');
if nargin == 3
   sys.Valstring = '';
elseif nargin == 4
   values = [strrep(varargin{1},',',';'),';'];
   sys.Valstring = values;
end
end

