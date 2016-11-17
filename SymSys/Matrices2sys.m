function sys = Matrices2sys(Amatrix, Bmatrix,Cmatrix,Dmatrix,varargin)
%Matrices2sys - Generate a SymSys system object from a set of state-space matrices
%
% Call:   sys = Matrices2sys(A,B,C,D)
%             A,B,C,D,E,F - a set of numeric or symbolic state-space system
%                matrices expressind the system in the form:
%                dot(x) = Ax + Bu
%                    y  = Cx + Du
%         sys = Matrices2sys(A,B,C,D,E,F)
%             A,B,C,D,E,F - a set of numeric or symbolic state-space system
%                matrices expressind the system in the form:
%                dot(x) = Ax + Bu + Edot(u)
%                    y  = Cx + Du + Fdot(u)
%
% Note:    Matrices2sys will generate names as follows:
%                  state variable names:    x1, ... xn
%                  input variable names:    u1, ....ur
%                  output variable names:   y1, ....um
%          for a system of order n, with r inputs and m outputs.
%
% Example:    syms m B K
%             A = [-B/m, -1/m; K, 0]; B = [1/m; 0]; C = [1, 0]; D = 0;
%             newsys = Matrices2sys(A,B,C,D);
%             TransferFunction(newsys,'sym')

% Author:        Derek Rowell (drowell@mit.edu)
% Revision Date: Nov. 24, 2010
%--------------------------------------------------------------------------
%
if nargin ~= 4 && nargin ~= 6  && nargin ~= 7 && nargin ~= 9
   error('Matrices2sys: Must have four or six input arguments')
end
% Error checking on matrix sizes
[nrowsA, ncolsA] = size(Amatrix);
[nrowsB, ncolsB] = size(Bmatrix);
[nrowsC, ncolsC] = size(Cmatrix);
[nrowsD, ncolsD] = size(Dmatrix);
if nrowsA ~= ncolsA
   error('SymSys:  A matrix is not sqyare')
elseif nrowsB ~= nrowsA
   error(['SymSys:  The number of rows in the B matrix does not',...
      ' match the A matrix.'])
elseif ncolsC ~= nrowsA
   error(['SymSys:  The number of columns in the C matrix does not',...
      ' match the A matrix.'])
elseif nrowsD ~= nrowsC || ncolsD ~= ncolsB
   error(['SymSys:  The size of the D matrix does not',...
      ' match the B or C matrices.'])
end
if nargin == 6 || nargin == 9
   [nrowsE, ncolsE] = size(varargin{1});
   [nrowsF, ncolsF] = size(varargin{2});
   if nrowsE ~= ncolsA || ncolsE ~= ncolsB
      error(['SymSys:  The size of the E matrix does not',...
         ' match the A or B matrices.'])
   elseif nrowsF ~= ncolsC || ncolsF ~= ncolsB
      error(['SymSys:  The size of the F matrix does not',...
         ' match the C or B matrices.'])
   end
end
%
%
n_states = nrowsA;
n_inp    = ncolsB;
n_out    = nrowsC;
% Return the system as a structure
sys.A    = simplify(sym(Amatrix));
sys.B    = simplify(sym(Bmatrix));
sys.C    = simplify(sym(Cmatrix));
sys.D    = simplify(sym(Dmatrix));
if nargin == 6 || nargin == 9
   sys.E = simplify(sym(varargin{1}));
   sys.F = simplify(sym(varargin{2}));
elseif nargin == 4 || nargin == 7
   sys.E = sym(zeros(size(sys.B)));
   sys.F = sym(zeros(size(sys.D)));
end
%
if nargin == 4 || nargin == 6
   % State variables
   names = sym(zeros(n_states,1));
   for k=1:n_states
      name=['x',int2str(k)];
      names(k,1) = name;
   end
   sys.StateVars = names;
   %
   % Inputs
   names = sym(zeros(n_inp,1));
   for k=1:n_inp
      name=['u',int2str(k)];
      names(k,1) = name;
   end
   sys.Inputs = names;
   %
   % Outputs
   names = sym(zeros(n_out,1));
   for k=1:n_out
      name=['y',int2str(k)];
      names(k,1) = name;
   end
   sys.Outputs = names;
elseif nargin == 7
   sys.Inputs    = varargin{1};
   sys.Outputs   = varargin{2};
   sys.StateVars = varargin{3};
elseif nargin == 9
   sys.Inputs    = varargin{3};
   sys.Outputs   = varargin{4};
   sys.StateVars = varargin{5};
end
%
% Look for symbolic (as opposed to neumeric) matrix elements and enter
% into the "names" and "values" lists.
% Form a list of all of the matrix elements
namestring = [];
for i = 1:nrowsA
   namestring = [namestring, sys.A(i,:)];
end
for i = 1:nrowsB
   namestring = [namestring, sys.B(i,:)];
end
for i = 1:nrowsC
   namestring = [namestring, sys.C(i,:)];
end
for i = 1:nrowsD
   namestring = [namestring, sys.D(i,:)];
end
if nargin == 6 || nargin == 9
   
   for i = 1:nrowsE
      namestring = [namestring, sys.E(i,:)];
   end
   for i = 1:nrowsF
      namestring = [namestring, sys.F(i,:)];
   end
end
% Parse the list to extract symbolic elements as separate elements.
namestring = char(namestring);
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
% Form the lists
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
sys.Valstring = '';
sys.Values = values;
sys.Names = names;
end