function fvalue = FinalValue(sys, size, varargin)
% FinalValue - Returns the steady-state step response of a SymSys object
%
% Call:      yfinal = FinalValue(sys, stepsize)
%                  - returns the final value of the SISO SymSys object 'sys'
%                    to a constant input 'stepsize'.
%            yfinal = FinalValue(sys, stepsize, 'sym')
%                  - returns the final value of the SISO SymSys object 'sys'
%                    to a constant input 'stepsize', in terms of the
%                    symbolic system parameters.
%            yfinal = FinalValue(sys, stepsize, in, out)
%                  - returns the final value of the MIMO SymSys object 'sys'
%                    to a constant input 'stepsize', where the input is
%                    applied to input 'in', and the response is measured
%                    at output 'out'.
%            yfinal = FinalValue(sys, stepsize, in, out, 'sym')
%                  - returns the final value of the MIMO SymSys object 'sys'
%                    to a constant input 'stepsize', where the input is
%                    applied to input 'in', and the response is measured
%                    at output 'out'.   The steady-state value is given in
%                    symbolic form.
%
% Notes:    For a MIMO system both the input and output must be specified.
%
%           The input and outputs may be specified by the variable name as
%           a string, such as 'Vs' or 'vm1', or numerically by the varable
%           position in the input and output vectors.
%
%           If the system is not 'Type 0', that is it has no steady-state
%           response, a NaN (not-a-number) is returned.
%
% Example:  g = '(1,2,force,Fs),(2,1,damper,B),(2,1,mass,m)';
%           sys = Lgraph2sys(g,'vm, position=integral(vm)', 'm=2,B=3');
%           v_steadystate = FinalValue(sys,1,'Fs','vm','sym')
%               - returns  v_steadystate = 1/B
%           x_final = FinalValue(sys,1,'Fs','position','sym')
%               - displays a message, and returns x_final = NaN because
%                 this sytem does not reach a steady-state position.

% Author:        Derek Rowell (drowell@mit.edu)
% Revision Date: Nov. 20, 2010
%----------------------------------------------------------------
%
syms s
% Handle input arguments
% Handle string or integer input/output specifications
nin  = 1;
nout = 1;
[ninputs]  = length(sys.Inputs);
[noutputs] = length(sys.Outputs);
if (ninputs>1 || noutputs>1) && nargin<4
   error('FinalValue: System is MIMO - must specify an input and an output')
end
%
if nargin==4 || nargin==5
   if ischar(varargin{1})
      nin = 0;
      for k = 1:ninputs
         if varargin{1} == sys.Inputs(k)
            nin = k;
         end
      end
      if nin == 0
         error('FinalValue: Specified input name not found')
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
         error('FinalValue: Specified output name not found')
      end
   else
      nout = varargin{2};
   end
end
%
if nin > ninputs
   error(['FinalValue: Specified input is greater than the',...
      'number of system inputs.']);
end
%
if nout > noutputs
   error(['FinalValue: Specified output is greater than the',...
      'number of system outputs.']);
end
%-------------------------
if    (nargin == 3 && strcmp(varargin{1},'sym'))...
      || (nargin == 5 && strcmp(varargin{3},'sym'))
   [num, den] = TransferFunction(sys,nin,nout,'sym');
else
   [num, den] = TransferFunction(sys,nin,nout);
end
n = poly_coef(num,s);
d = poly_coef(den,s);
if d(length(d))~=0
   fvalue = simplify(size*n(length(n))/d(length(d)));
else
   fprintf(['\nFinalValue: The system has no steady-state response',...
      ' to a constant input.\n'])
   fvalue = NaN;
end
end