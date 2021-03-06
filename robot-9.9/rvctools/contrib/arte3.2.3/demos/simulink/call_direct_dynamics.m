%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  qdd = call_direct_dynamics(input)
%  Auxiliar function for the simulink model SIMULATE_ROBOT_AND_CONTROLLER.
%  Rearranges the inputs coming from the simulink model and calls the
%  function accel.
%  As a result the instantaneous acceleration at each joint is returned.
%
%  See also ACCEL.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright (C) 2012, by Arturo Gil Aparicio
%
% This file is part of ARTE (A Robotics Toolbox for Education).
% 
% ARTE is free software: you can redistribute it and/or modify
% it under the terms of the GNU Lesser General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% ARTE is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Lesser General Public License for more details.
% 
% You should have received a copy of the GNU Lesser General Public License
% along with ARTE.  If not, see <http://www.gnu.org/licenses/>.
function qdd = call_direct_dynamics(input)

global robot

%set friction to zero
%robot.friction = 0;

torque = input(1:6);   % Input torque at each joint
q   = input(7:12);	   % Joint positions
qd  = input(13:18);	   % Joint speeds


% Compute acceleration
qdd = accel(robot, q, qd, torque);

