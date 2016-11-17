function sys = TF2sys(tf,varargin)
%TF2sys   Create a SymSys object from a transfer function description.
%
%(A)      sys = TF2sys('tf')
%           creates a SymSys object from the string expression tf that
%           defines the transfer function (in the Laplace variable 's').
%
%(B)      sys = TF2sys('tf','values')
%           creates a SymSys object, and defines numeric values for one
%           or more of the symbolic names in the transfer function
%           definition.
%
% Note:   The state space description of the system is returned
%         in phase-variable form.
%
% Example:  newsys  = TF2sys('(s+B*K)/(m*s^2 + B*s + K)', 'B=0.1, K=10')
%         creates a SymSys object named newsys from a transfer function
%                              s + BK
%               G(s) =    ----------------
%                             2
%                          ms   + Bs + K
%         with numeric values defined for B and K.

%   Author:         Derek Rowell   (drowell@mit.edu)
%   Revision date:  Nov. 23, 2010
%--------------------------------------------------------------------------
syms s
try
   tf1 = simplify(sym(tf));
catch
   fprintf('\n Invalid transfer function specification: %s\n', tf)
   error('TF2sys: Syntax error in transfer function.')
end
[num, den] = numden(tf1);
numcoefs = poly_coef(num,sym(s));
dencoefs = poly_coef(den,sym(s));
N = length(dencoefs) - 1;
ncoefs = [sym(zeros(1,N+1-length(numcoefs))), numcoefs];
%ncoefs(N+1-length(numcoefs):N+1) = numcoefs(1:length(numcoefs));
A__ = sym(zeros(N));
B__ = sym(zeros(N,1));
C__ = sym(zeros(1,N));
D__ = sym(zeros(1,1));
E__ = sym(zeros(1,1));
F__ = sym(zeros(1,1));
for j = 1:N-1
   A__(j,j+1) = 1;
end
for j = 1:N
   A__(N,j) = - dencoefs(N+2-j)/dencoefs(1);
end
B__(N,1) = sym(1)/dencoefs(1);
for j = 1:N
   C__(j) = ncoefs(N+2-j) - ncoefs(1)*dencoefs(N+2-j)/dencoefs(1);
end
StateVars = sym(zeros(N,1));
D__ = ncoefs(1)/dencoefs(1);
%
for j = 1:N
   StateVars(j) = sym(sprintf('x_%d',j));
end
%
sys = Matrices2sys(A__,B__,C__,D__,E__,F__,sym('u'),sym('y'),StateVars);
% Parse the numerator and denominator for system parameter names
namestring=char([numcoefs,dencoefs]);
namestring = strrep(namestring,'matrix([[','');
namestring = strrep(namestring,']])',',');
namestring = strrep(namestring,' ','');
namestring = strrep(namestring,'+',',');
namestring = strrep(namestring,'-',',');
namestring = strrep(namestring,'*',',');
namestring = strrep(namestring,'/',',');
namestring = strrep(namestring,'^',',');
namestring = strrep(namestring,'(',',');
namestring = strrep(namestring,')',',');
commas     = strfind(namestring,',');
names = [];
for k = 1:length(commas)
   [name,namestring] = strtok(namestring,',');
   if isempty(str2num(name))
      if isempty(names)
         names = [names; sym(name)];
      end
      not_found = true;
      % Insert a new name into the list
      for j = 1:length(names)
         if sym(name) == names(j)
            not_found = false;
         end
      end
      if not_found
         names = [names; sym(name)];
      end
   end
end
% Set up the values list, define unspecified values as NaN
values = zeros(length(names),1);
for j= 1:length(values)
   values(j) = NaN;
end
%
if nargin == 1
   valstring = '';
elseif nargin == 2
   valstring = strrep(varargin{1},' ','');
   valstring = [strrep(valstring,',',';'),';'];
   values = get_vals(values, names, valstring);
end
%
sys.Names     = names;
sys.Values    = values;
sys.Valstring = valstring;
end


