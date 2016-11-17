function varargout = StepResponse(sys,varargin)
%StepResponse - Display the symbolic step response of a SymSys system object.
%
% Call:  ystep = StepResponse(sys)
%                  sys    - a SymSys object.
%        ystep = StepResponse(sys ,digits)
%                  digits - the precision of the displayed result (in
%                           decimal digits).  The default precision is 5.
%        ystep = StepResponse(sys ,input, output)
%        ystep = StepResponse(sys ,input, output, digits)
%                  input, output - (required for a MIMO system)
%                           system input and output for response.
%                           May be either variable names (string)
%                           or integer identifier.
%
% Examples:  ystep = StepResponse(mysys,3)
%                    - a SISO system with 3 digits of displayed precision
%            ystep = StepResponse(mysys,'Vin','Vout',4)
%                    - a MIMO system, with 4 digits of displayed precision,
%                      input variable Vin, and output Vout, as defined
%                      in the graph and output lists.
%            ystep = StepResponse(mysys,2,3,4)
%                    - from input 2, to output 3 of a MIMO system,
%                      with 4 digits of displayed precision,

% Author:        Derek Rowell (drowell@mit.edu)
% Revision Date: Nov.21, 2010
%----------------------------------------------------------------
%
syms s
syms t real
digits(5);
D__ = digits;
% Handle input arguments
if nargin == 1 || nargin == 3
   precision = 5;
elseif nargin == 2
   precision = varargin{1};
elseif nargin == 4;
   precision = varargin{3};
end
% Handle string or integer input/output specifications
nin = 1;
nout = 1;
ninputs  = length(sys.Inputs);
noutputs = length(sys.Outputs);
if (ninputs >1 || noutputs > 1) && nargin < 3
   error('StepResponse: System is MIMO - must specify an input and an output')
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
         error('StepResponse: Specified input name not found')
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
         error('StepResponse: Specified output name not found')
      end
   else
      nout = varargin{2};
   end
end
%
if nin > ninputs
   error('StepResponse: Specified input is greater than number of system inputs.');
end
%
if nout > noutputs
   error('StepResponse:  Specified output is greater than number of system outputs.');
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
% Multiply the denominator by s for the step response.
den   = vpa(den);
num   = vpa(gain*num);
input = sym(1/s);
ystep = xresponse(num,den,input,precision);
if nargout == 0
   fprintf('\nStep Response:\n')
   pretty(ystep)
else
   varargout{1} = ystep;
end
digits(D__)
end
%