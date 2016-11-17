function sys = OpenLoop(controller, plant, varargin)
% OpenLoop - Combine SymSys objects into an open-loop (cascade) system.
%          representing the open-loop of a closed-loop system
%          with a controller, plant, and feedback elements.
%
%                        ------------     -------
%           u --->O---->| controller |-->| plant |--+---> y
%               - ^      ------------     -------   |
%                 |            --------             |
%                 +-----------| sensor |<-----------+
%                              --------
%
% The open loop system is:
%               ------------      -------      --------
%       u ---->| controller |--->| plant |--->| sensor | ---> y
%               ------------      -------      --------
%
%    sys = Series(Controller,plant)
%       creates an open-loop system for a unity feedback system.d
%
%    sys = Series(Controller,plant,feedback)
%       creates an open-loop system for a system with feedback dynamics
%
% Example:  controller = PID('Kp','Kd','Ki');
%           plant = TF2sys('1/(m*s+B)','m=10,B=0.5');
%           sensor = TF2sys('1/(R*Cs+1)','R2=2000,C2=0.0002');
%           ol = OPenLoop(controller,plant,sensor);
%           TransferFunction(ol,'sym')
%
%         displays the symbolic transfer function for the series system:
%
%                              1
%           ----------------------------------------
%                         2
%          (C1 C2 R1 R2) s  + (C1 R1 + C2 R2) s + 1
%

%   Author:         Derek Rowell   (drowell@mit.edu)
%   Revision date:  Oct 29, 2010
%--------------------------------------------------------------------------
%
sys = Series(controller,plant);
if nargin == 3
   sys1 = Series(sys,varargin{1});
   sys=sys1;
end
end


