function varargout = TransferFunction(sys, varargin)
%TransferFunction - Display the transfer function of a SymSys system object
%
% Call:      TransferFunction(sys) - displays the transfer function of the
%                      SymSys object 'sys' in numeric form if all system
%                      parameter values are set, otherwise
%                      displays the transfer function in symbolic form.
%            TransferFunction(sys,'sym') - forces the display of the
%                      transfer function in symbolic form.

% Author:        Derek Rowell (drowell@mit.edu)
% Revision Date: Nov. 29, 2010
%----------------------------------------------------------------
%
syms s
% Handle input arguments
% Handle string or integer input/output specifications
nin  = 1;
nout = 1;
[ninputs]  = length(sys.Inputs);
[noutputs] = length(sys.Outputs);
if (ninputs >1 || noutputs > 1) && nargin < 3
   error('TransferFunction: System is MIMO - must specify an input and an output')
end
%
precision = 5;
digits(precision);
if nargin == 3 || nargin == 4
   if ischar(varargin{1})
      nin = 0;
      for k = 1:ninputs
         if varargin{1} == sys.Inputs(k)
            nin = k;
         end
      end
      if nin == 0
         error('TransferFunction: Specified input name not found')
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
         error('TransferFunction: Specified output name not found')
      end
   else
      nout = varargin{2};
   end
end
%
if nin > ninputs
   error('TransferFunction: Specified input is greater than number of system inputs.');
end
%
if nout > noutputs
   error('TransferFunction:  Specified output is greater than number of system outputs.');
end
%-------------------------
% Form a SISO system  with the specified input
% and output by modifying the system matrices
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
sys.D = temp(nout,nin);
% F matrix
temp   = sys.F;
sys.F = temp(nout,nin);
%
A__ = sys.A;
B__ = sys.B;
C__ = sys.C;
D__ = sys.D;
E__ = sys.E;
F__ = sys.F;
%
[n_rows, m_cols] = size(A__);
if n_rows == m_cols
   sminusA = (s*eye(n_rows) - A__);
   cpoly   = expand(det(sminusA));
   den     = cpoly;
   %
   % Form the numerator and the denominator separately
   % because it handles the D matrix better this way.
   %
   num = collect(simplify(cpoly*((C__/sminusA)*(B__+s*E__)...
                 + (D__+s*F__))),s);
   numcoeff = poly_coef(num,s);
   dencoeff = poly_coef(den,s);
   % Remove cancelling poles/zeros at the origin
   while numcoeff(length(numcoeff))==0 && dencoeff(length(dencoeff))==0
      numcoeff = numcoeff(1:length(numcoeff)-1);
      dencoeff = dencoeff(1:length(dencoeff)-1);
   end
   num = poly2sym(numcoeff,s);
   den = poly2sym(dencoeff,s);
   tf = num/den;
   if isempty(sys.Valstring) || ...
         ((nargin == 2 || nargin == 4) && strcmp(varargin{nargin-1},'sym'))
      if nargout == 0
         pretty(collect(expand(simplify(num/den)),s))
      elseif nargout == 1
         varargout(1) = {collect(expand(simplify(num/den)),s)};
      elseif nargout ==2
         varargout(1) = {num};
         varargout(2) = {den};
      end
   else
      eval(sys.Valstring);
      try
         num = subs(num);
         den = subs(den);
      catch
         error(['TransferFunction: Cannot compute numerical transfer ',...
            'function because not all system parameters have been '...
            'assigned numerical values.'])
      end
      % Remove cancelling poles/zeros at the origin
      numcoeff = poly_coef(num,s);
      dencoeff = poly_coef(den,s);
      if length(numcoeff) > length(dencoeff)
         fprintf('\nWarning: This system does not have a "proper" transfer function\n')
      end
      while  numcoeff(length(numcoeff))==0. ...
            && dencoeff(length(dencoeff))==0
         numcoeff = numcoeff(1:length(numcoeff)-1);
         dencoeff = dencoeff(1:length(dencoeff)-1);
      end
      num = poly2sym(numcoeff,s);
      den = poly2sym(dencoeff,s);
      tf = num/den;
      if nargout == 0
         pretty(vpa(tf,5))
      elseif nargout == 1
         varargout(1) = {vpa(tf,5)};
      elseif nargout ==2
         varargout(1) = {vpa(subs(num),5)};
         varargout(2) = {vpa(subs(den),5)};
      end
   end
else
   error('TransferFunction: Invalid system specification')
end
end