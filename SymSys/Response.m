function yresp = Response(sys,infun,varargin)
%Response - Display the response of a SymSys system object
%           to a given time function function.
%
% (a)  yresp = Response(sys, function)
%                  sys      - a SymSys object
%                  function - a symbolic expression for the system input.
%                  yresp    - a symbolic expression for the system output.
% (b)       yresp = Response(sys, function, digits)
%                  digits   - the precision of the displayed result (in
%                             decimal digits).  The default precision is 5.
% (c)       yresp = Response(sys, function, input, output)
% (d)       yresp = Response(sys, function, input, output, digits)
%                  input, output - (required for a MIMO system). The
%                           system input and output for the response.
%                           May be either variable names (string)
%                           or integer identifier.
%
% Examples:  syms t
%            y = Response(mysys,exp(-3*t),3)
%                   - the response of a SISO system to an exponential
%                     input, with 3 digits of displayed precision
%            y = Response(mysys,t,'Vin','Vout',4)
%                    - the ramp response of a MIMO system, between input
%                      Vin and output Vout with 4 digits of displayed
%                      precision.
%            y = StepResponse(mysys,heaviside(t),2,3,4)
%                    - the step response of a MIMO system, with 4 digits
%                      of displayed precision, from input 2, to output 3.
%
% Notes:     (1) The time domain input function must be recognized by
%                MATLAB's laplace() function.
%            (2) The variable t must be declared as symbolic prior to
%                invoking Response():
%                     syms t
%                     y = SysResponse(sys, sin(5*t) + t^2)

% Author:        Derek  Rowell (drowell@mit.edu)
% Revision Date: Dec. 1, 2010
%--------------------------------------------------------------------------
%
syms s
syms t real
% Handle input arguments
if nargin == 2 || nargin == 4
   precision = 5;
elseif nargin == 3
   precision = varargin{1};
elseif nargin == 5;
   precision = varargin{3};
end
D__ = digits;
digits(precision);
% Handle string or integer input/output specifications
nin = 1;
nout = 1;
[ninputs, k] =size(sys.Inputs);
[noutputs, k] =size(sys.Outputs);
if (ninputs >1 || noutputs > 1) && nargin < 3
   error('Response: System is MIMO - must specify an input and an output')
end
if nargin == 4 || nargin == 5
   if ischar(varargin{1})
      nin = 0;
      for k = 1:ninputs
         if varargin{1} == sys.Inputs(k)
            nin = k;
         end
      end
      if nin == 0
         error('Response: Specified input name not found')
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
         error('Response: Specified output name not found')
      end
   else
      nout = varargin{2};
   end
end
%
if nin > ninputs
   error('Response: Specified input is greater than number of system inputs.');
end
%
if nout > noutputs
   error('Response:  Specified output is greater than number of system outputs.');
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
num = gain*num;
%
% Form our own partial fractions transfer function representation
% because ilaplace() in MATLAB 2009a hangs for higher order systems.
% Use residue to complete the partial fraction deccomposition into
% first-order terms (real and complex).
% Note: we need to consider repeated roots and an improper t.f.
%
%[r, p, k] = residue(sym2poly(num),sym2poly(den));
n = eval(poly_coef(num,s));
d = eval(poly_coef(den,s));
[r, p, k] = residue(n,d);
%[r, p, k] = residue(vpa(poly_coef(num,s)),vpa(poly_coef(den,s)));
pfrac=0;
i=1;
repeat = 0;   % Repeated root counter.
% Form a sum of first-order linear terms (real and complex)
while i <=length(p)
   if (i>1) && p(i)==p(i-1)
      repeat= repeat+1;
   else
      repeat = 0;
   end
   pfrac = pfrac + r(i)/(s-p(i))^(repeat+1);
   i = i+1;
end
if ~isempty(k)
   L = length(k);
   for i = 1:L
      pfrac = pfrac + k(i)*s^(L-i);
   end
end
pfrac = vpa(pfrac * laplace(sym(infun)),precision);
yresp =  simplify(ilaplace(pfrac));
%yout = simplify((y+conj(y))/2);
%yresp = simplify(vpa(subs(yout,conj(dirac(t)),dirac(t)),precision));
digits(D__);
end
%