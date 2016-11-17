function sys = ClosedLoop(controller, plant, varargin )
% ClosedLoop -  Creates a SymSys closed-loop controlled system object.
%
%(A)  sys = ClosedLoop(controller,plant)
%       creates a SymSys object for a unity-feedback closed-loop system:
%                        ------------     -------
%           u --->O---->| controller |-->| plant |--+---> y
%               - ^      ------------     -------   |
%                 |                                 |
%                 +---------------------------------+
%
%        where controller and plant are SymSys objects.   The closed-loop
%        system has a transfer function:
%                                Gc(s)Gp(s)
%                  G_cl(s) =  --------------
%                              1 + Gc(s)Gp(s)
%
%(B)  sys = ClosedLoop(controller,plant,sensor)
%          creates a SymSys objectfor a closed-loop system with sensor
%          (feedback) dynamics:
%                        ------------     -------
%           u --->O---->| controller |-->| plant |--+---> y
%               - ^      ------------     -------   |
%                 |            --------             |
%                 +-----------| sensor |<-----------+
%                              --------
%
%      where controller, plant, and sensor are SymSys objects. The
%      closed-loop system has a transfer function:
%                                  Gc(s)Gp(s)
%                  G_cl(s) =  -------------------
%                              1 + H(s)Gc(s)Gp(s)
%
% Notes:  (1)  The controller, plant and sensor objects must be SISO.
%         (2)  The closed-loop system is expressed in phase-variable form.
%         (3)  A system created with ClosedLoop inherits any numeric values
%              assigned to the plant, controller, and sensor objects.
%
%
% Example:   graph = '(1,2,force,Fs),(2,1,mass,m),(2,1,damper,B)';
%            car = Lgraph2sys(graph,'vm','m=10,B=0.1');
%            sensor = TF2sys('1/(T*s+1)','T=0.05');
%            cl = ClosedLoop(Gain('Kp'), car, sensor);
%            TransferFunction(cl,'sym')
%
%   reports the closed-loop transfer function:
%
%                      (Kp T) s + Kp
%             -------------------------------
%                    2
%             (T m) s  + (m + B T) s + B + Kp
%

%  Author:         Derek Rowell   (drowell@mit.edu)
%  Revision date:  Oct 29, 2010
%--------------------------------------------------------------------------
[numc,denc] = TransferFunction(controller,'sym');
[nump,denp] = TransferFunction(plant,'sym');
if nargin == 2
   nums = 1;
   dens = 1;
elseif nargin == 3
   [nums, dens] = TransferFunction(varargin{1},'sym');
else
   error('ClosedLoop: Requires either two or three input arguments')
end
%
closed_loop_tf = (dens*numc*nump)/(denc*denp*dens + numc*nump*nums);
sys = TF2sys(closed_loop_tf);
%
% Inherits the element values from the component systems:
%
sys.Valstring = [controller.Valstring, plant.Valstring];
sys.Values    = [controller.Values;    plant.Values];
sys.Names     = [controller.Names;     plant.Names];
if nargin ==3
   sys.Valstring = [sys.Valstring, varargin{1}.Valstring];
   sys.Values    = [sys.Values;    varargin{1}.Values];
   sys.Names     = [sys.Names;     varargin{1}.Names];
end
end

