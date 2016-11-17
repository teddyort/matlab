function varargout = RampResponse(sys,varargin)
%RampResponse - Display the symbolic ramp response of a SymSys system
%               object.
%
% Call:  yramp = RampResponse(sys)
%                  sys    - a SymSys object.
%        yramp = RampResponse(sys ,digits)
%                  digits - the precision of the displayed result (in
%                           decimal digits).  The default precision is 5.
%        yramp = RampResponse(sys ,input, output)
%        yramp = RampResponse(sys ,input, output, digits)
%                  input, output - (required for a MIMO system)
%                           system input and output for response.
%                           May be either variable names (string)
%                           or integer identifier.
%
% Examples:  yramp = RampResponse(mysys,3)
%                    - a SISO system with 3 digits of displayed precision
%            yramp = RampResponse(mysys,'Vin','Vout',4)
%                    - a MIMO system, with 4 digits of displayed precision
%            yramp = RampResponse(mysys,2,3,4)
%                    - from input 2, to output 3 of a MIMO system,
%                      with 4 digits of displayed precision,
%                          and from input 2, to output 3.

% Author:        Derek Rowell (drowell@mit.edu)
% Revision Date: Nov. 21, 20010
%----------------------------------------------------------------
%
syms t s
% Handle input arguments
if nargin == 1 || nargin == 3
   precision = 5;
elseif nargin == 2
   precision = varargin{1};
elseif nargin == 4;
   precision = varargin{3};
end
% Handle string or integer input/output specifications
nin  = 1;
nout = 1;
[ninputs, k]  = size(sys.Inputs);
[noutputs, k] = size(sys.Outputs);
if (ninputs >1 || noutputs > 1) && nargin < 3
   error('RampResponse: System is MIMO - must specify an input and an output')
end
if nargin == 3 || nargin == 4
   if ischar(varargin{1})
      nin = 0;
      for k = 1:ninputs
         if varargin{1} == sys.Inputs(k)
            nin = k;
         end
      end
      if nin == 0
         error('RampResponse: Specified input name not found')
      end
   else
      nin = varargin{1};
   end
   if ischar(varargin{2})
      nout = 0;
      for k = 1:noutputs
         if varargin{2} == sys.Outputs(k)
            nout = k;
         end
      end
      if nout == 0
         error('RampResponse: Specified output name not found')
      end
   else
      nout = varargin{2};
   end
end
%
if nin > ninputs
   error('RampResponse: Specified input is greater than number of system inputs.');
end
%
if nout > noutputs
   error('RampResponse:  Specified output is greater than number of system outputs.');
end
%-------------------------
% Form a SISO system by modifying system matrices
% B matrix:
temp   = sys.B;
sys.B = temp(:,nin);
% E matrix
temp   = sys.E;
sys.E = temp(:,nin);
% C matrix
temp   = sys.C;
sys.C = temp(nout,:);
% D matrix
temp   = sys.D;
sys.D = temp(nout,:);
% F matrix
temp   = sys.F;
sys.F = temp(nout,:);
%
%Use Laplace transform method
%
[num, den, gain] = tf_numden(sys);
% Multiply the denominator by s^2 for the ramp response.
den = vpa(den,9);
num = vpa(gain*num, 9);
input=1/s^2;
yramp = xresponse(num,den,input,precision);
%
if nargout == 0
   fprintf('\nRamp Response:\n')
   pretty(yramp)
else
   varargout{1} = yramp;
end
end