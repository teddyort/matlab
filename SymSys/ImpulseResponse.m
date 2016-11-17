function varargout = ImpulseResponse(sys,varargin)
%ImpulseResponse - Display the symbolic impulse response of a SymSys object
%
% Call:      yimp = ImpulseResponse(sys {,input, output}  {,precision})
%                sys    - a sysrep object formed by lg2sys().
%                {input, output} - (required for a MIMO system)
%                           system input and output for response.
%                           May be either variable names (string)
%                           or integer identifier.
%                precision - (optional) decimal digits to display
%                          in the output (default is 5).
%
% Example:   yimp = ImpulseResponse(mysys,3) -SISO with 3 digits precision
%            yimp = ImpulseResponse(mysys,'Vin','Vout',4) -MIMO with 4 digits
%                          precision, input Vin, output Vout, as defined
%                          in the graph and output lists.
%            yimp = ImpulseResponse(mysys,2,3,4) -MIMO with 4 digits
%                          precision, input 2, output 3.

% Author:        Derek Rowell (drowell@mit.edu)
% Revision Date: Nov. 21, 2010
%----------------------------------------------------------------
%
D__ = digits;
syms t s
% Handle input arguments
if nargin == 1 || nargin == 3
   precision = 5;
elseif nargin == 2
   precision = varargin{1};
elseif nargin == 4;
   precision = varargin{3};
end
digits(precision);
% Handle string or integer input/output specifications
nin  = 1;
nout = 1;
[ninputs, k] =size(sys.Inputs);
[noutputs, k] =size(sys.Outputs);
if (ninputs >1 || noutputs > 1) && nargin < 3
   error('ImpulseResponse: System is MIMO - must specify an input and an output')
end
if nargin == 3 || nargin == 4
   if ischar(varargin{1})
      for k = 1:ninputs
         nin = 0;
         if varargin{1} == sys.Inputs(k)
            nin = k;
         end
      end
      if nin == 0
         error('ImpulseResponse: Specified input name not found')
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
         error('ImpulseResponse: Specified output name not found')
      end
   else
      nout = varargin{2};
   end
end
%
if nin > ninputs
   error('ImpulseResponse: Specified input is greater than number of system inputs.');
end
%
if nout > noutputs
   error('ImpulseResponse:  Specified output is greater than number of system outputs.');
end
%----------------------------
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
% Use Laplace transform method
%
[num, den, gain] = tf_numden(sys);
den   = vpa(den);
num   = vpa(gain*num);
input = sym(1);
y = xresponse(num,den,input,precision);
if nargout == 0
   fprintf('\nImpulse Response:\n')
   pretty(y);
else
   varargout{1} = y;
end
digits(D__);
end