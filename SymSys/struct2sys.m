function sys = struct2sys(g, outstring, valstring)
%

%struct2sys - Internal SymSys function
%             Generates a SymSys object from a linear graph
%             based data structure produced by Lgraph2sys() or Sym2sys().
%
% Note:    This is an internal SymSys function and is not a user called
%          function.
%
% Call:   sys  = struct2sys(g, outstring, valstring)
%                 g  - a data structure specifying the linear
%                      graph structure of a system as described below.
%                 outstring - (string) a list of system output variables.
%                 valstring - (string) a list of system parameter
%                      values.
%
% Linear graph data structure contents:
%    g.b_head, g.b_tail -  head and tail node of each directed graph edge.
%    g.b_type           -  standardized branch (element) type
%    g.b_name           -  the user specified element name
%    g.b_coeff          -  the element coefficient
%    g.Avars            -  across variable on each element
%    g.Tvars            -  through variable on each element
%    g.Inputs           -  system inputs
%
% Author:         Derek Rowell (drowell@mit.edu)
% Revision Date:  Nov. 23, 2010
%--------------------------------------------------------------------------
%
nbranches    = length(g.b_tail);
nnodes       = max(max([g.b_tail, g.b_head]));
n_Input      = length(g.Inputs);
b_isbranch   = zeros(nbranches,1);
b_constraint = zeros(nbranches,1);
%
% Form the normal tree using the fact that the left null-space of
% the incidence matrix of a directed line graph defines the closed loops
% in the graph.
%
% Form the incidence matrix:
IncMat = zeros(nbranches, nnodes);
for k = 1:nbranches
   IncMat(k, g.b_tail(k)) = -1;
   IncMat(k, g.b_head(k)) =  1;
end
%
branch       = [];
nbranch      = 0;
link         = [];
nlink        = 0;
constraint   = [];
n_constraint = 0;
B            = [];
%
% Use Morteza's algorithm
% [5:4;1;3;6;7;2]; % As,A,GY,D,TF,T,Ts
LGmatrix = zeros(nbranches, 4);
types = [sym('A'); sym('T');  sym('D');  sym('As');  sym('Ts');  sym('TF');  sym('GY')];
for i = 1:nbranches
   for j = 1:7
      if g.b_type(i) == types(j)
         LGmatrix(i,:) = [i, g.b_tail(i), g.b_head(i) , j];
      end;
   end;
end
[branch, link] = normal_tree(LGmatrix);
nbranch = length(branch);
nlink   = length(link);
%
% Check the order of the system and generate an error if the order is zero.
%
order = 0;
for k = 1:nbranch
   if g.b_type(branch(k)) == 'A'
      order = order + 1;
   end
end
for k = 1:nlink
   if g.b_type(link(k)) == 'T'
      order = order + 1;
   end
end
if order == 0
   display(['The specified system is algebraic (zero-order), with no'...
      ' independent',char(13),'energy-storage-elements (ESEs), and'...
      ' therefore SymSys cannot proceed.']);
   error('Inappropriate system for SymSys...')
end
%
% Create an incidence matrix for the branches in the normal tree
Bold = zeros(nbranch, nnodes);
for i = 1:nbranch
   b_isbranch(branch(i)) = 1;
   Bold(i, LGmatrix(branch(i),2)) = -1;
   Bold(i, LGmatrix(branch(i),3)) = 1;
end;
%-----------------------------------------------------------------
%The normal tree is now complete
%-----------------------------------------------------------------
% Create the compatibility equations
for k = 1:nbranches
   if ~b_isbranch(k)
      B = [Bold;IncMat(k,:)];
      n = null(B','r');
      compateqn = sym(0);
      for j = 1:nbranch
         compateqn = compateqn + n(j)*g.Avars(branch(j));
      end
      compateqn       = compateqn + g.Avars(k)*n(nbranch+1);
      constraint      = [constraint; compateqn];
      n_constraint    = n_constraint + 1;
      b_constraint(k) = n_constraint;
   end
end
%
% Create the continuity equations:
for k = 1:nbranch
   if ~strcmp(g.b_type(branch(k)),'As') && ~strcmp(g.b_type(branch(k)),'Ts')
      conteqn = 1* g.Tvars(branch(k));
      B = Bold;
      % Add each link one at a time, and determine if the loop formed
      % includes the branch.   If so include the through variable from the
      % link in the node equation.
      for j = 1:nlink
         B = [Bold; IncMat(link(j),:)];
         n = null(B', 'r');
         conteqn = conteqn - n(k)*g.Tvars(link(j));
      end
      constraint   = [constraint; conteqn];
      n_constraint = n_constraint + 1;
      b_constraint(branch(k)) = n_constraint;
   end
end
%
% Construct the elemental equations
StateEquations     = [];
NonStateEquations  = [];
DependentEquations = [];
StateVars          = [];
StateSecVars       = [];
StateCoeffs        = [];
NonStateVars       = [];
NonStateSecVars    = [];
NonStateCoeffs     = [];
DependVars         = [];
DependSecVars      = [];
DependCoeffs       = [];
n_State            = 0;
n_NonState         = 0;
n_Depend           = 0;
%
k=1;
while k < nbranches +1
   % Sources do not generate equations:
   if ~strcmp(g.b_type(k),'As') && g.b_type(k) ~= 'Ts'
      % If it's an A-type element in the branches:
      if g.b_type(k) == 'A' && b_isbranch(k)
         elemental = g.b_coeff(k)...
            * solve(constraint(b_constraint(k)), g.Tvars(k));
         StateEquations = [StateEquations; elemental];
         StateVars = [StateVars; g.Avars(k)];
         StateSecVars = [StateSecVars; g.Tvars(k)];
         StateCoeffs  = [StateCoeffs; g.b_coeff(k)];
         n_State = n_State + 1;
      end
      % If it is a T-type element in the links:
      if g.b_type(k) =='T' && ~b_isbranch(k)
         elemental = g.b_coeff(k)...
            * solve(constraint(b_constraint(k)), g.Avars(k));
         StateEquations = [StateEquations; elemental];
         StateVars = [StateVars;g.Tvars(k)];
         StateSecVars = [StateSecVars; g.Avars(k)];
         StateCoeffs  = [StateCoeffs; g.b_coeff(k)];
         n_State = n_State + 1;
      end
      % If it's an A-type element in the links (a dependent A-type ESE):
      % Note: DependentEquations implicitly are in terms of derivatives
      if g.b_type(k) == 'A' && ~b_isbranch(k)
         elemental = sym(1)/g.b_coeff(k)...
            * solve(constraint(b_constraint(k)), g.Avars(k));
         DependentEquations = [DependentEquations; elemental];
         DependVars         = [DependVars; g.Tvars(k)];
         DependSecVars      = [DependSecVars; g.Avars(k)];
         DependCoeffs       = [DependCoeffs; g.b_coeff(k)];
         n_Depend = n_Depend + 1;
      end
      % If it is a T-type element in the branches (a dependent T-type ESE):
      % Note: DependentEquations implicitly are in terms of derivatives
      if g.b_type(k) == 'T' && b_isbranch(k)
         elemental = sym(1)/g.b_coeff(k)...
            * solve(constraint(b_constraint(k)),g.Tvars(k));
         DependentEquations = [DependentEquations; elemental];
         DependVars         = [DependVars; g.Avars(k)];
         DependSecVars      = [DependSecVars; g.Tvars(k)];
         DependCoeffs       = [DependCoeffs; g.b_name(k)];
         DependCoeffs       = [DependCoeffs; g.b_coeff(k)];
         n_Depend = n_Depend + 1;
      end
      % If it is a D-type element in the branches
      if g.b_type(k) == 'D' && b_isbranch(k)
         elemental = sym(1)/g.b_coeff(k)...
            *solve(constraint(b_constraint(k)),g.Tvars(k));
         NonStateEquations = [NonStateEquations; elemental];
         NonStateVars      = [NonStateVars; g.Avars(k)];
         NonStateSecVars   = [NonStateSecVars; g.Tvars(k)];
         NonStateCoeffs    = [NonStateCoeffs; sym(1)/g.b_coeff(k)];
         n_NonState        = n_NonState + 1;
         % If it is a D-type element in the links
      elseif g.b_type(k) == 'D' && ~b_isbranch(k)
         elemental = g.b_coeff(k)...
            *solve(constraint(b_constraint(k)),g.Avars(k));
         NonStateEquations = [NonStateEquations; elemental];
         NonStateVars      = [NonStateVars; g.Tvars(k)];
         NonStateSecVars   = [NonStateSecVars; g.Avars(k)];
         NonStateCoeffs    = [NonStateCoeffs; g.b_coeff(k)];
         n_NonState        = n_NonState + 1;
         % If it is a Gyrator with both branches in the tree
      elseif  g.b_type(k) == 'GY' && g.b_type(k+1) == 'GY' && b_isbranch(k)
         NonStateVars      = [NonStateVars;    g.Avars(k); g.Avars(k+1)];
         NonStateSecVars   = [NonStateSecVars; g.Tvars(k); g.Tvars(k+1)];
         NonStateCoeffs    = [NonStateCoeffs; sym(1)/g.b_name(k); sym(1)/g.b_name(k)];
         elementala = -g.b_coeff(k)  * solve(constraint(b_constraint(k+1)),g.Tvars(k+1));
         elementalb =  g.b_coeff(k+1)* solve(constraint(b_constraint(k)),g.Tvars(k));
         NonStateEquations = [NonStateEquations; elementala; elementalb];
         n_NonState        = n_NonState + 2;
         k=k+1;
         % If it is a Gyrator with both branches in the links
      elseif  g.b_type(k) == 'GY' && g.b_type(k+1) == 'GY' && ~b_isbranch(k)
         NonStateVars      = [NonStateVars;    g.Tvars(k); g.Tvars(k+1)];
         NonStateSecVars   = [NonStateSecVars; g.Avars(k); g.Avars(k+1)];
         NonStateCoeffs    = [NonStateCoeffs; sym(1)/g.b_coeff(k); sym(1)/g.b_coeff(k)];
         elementala =  1/g.b_coeff(k)  * solve(constraint(b_constraint(k+1)),g.Avars(k+1));
         elementalb = -1/g.b_coeff(k+1)* solve(constraint(b_constraint(k)),g.Avars(k));
         NonStateEquations = [NonStateEquations; elementala; elementalb];
         n_NonState        = n_NonState + 2;
         k=k+1;
         % If it is a Transformer with branch a in the tree
      elseif  g.b_type(k) == 'TF' && g.b_type(k+1) == 'TF' && b_isbranch(k)
         NonStateVars      = [NonStateVars;    g.Avars(k); g.Tvars(k+1)];
         NonStateSecVars   = [NonStateSecVars; g.Tvars(k); g.Avars(k+1)];
         NonStateCoeffs    = [NonStateCoeffs; sym(1)/g.b_name(k); sym(1)/g.b_name(k)];
         elementala =  1/g.b_coeff(k)  * solve(constraint(b_constraint(k+1)),g.Avars(k+1));
         elementalb = -1/g.b_coeff(k+1)* solve(constraint(b_constraint(k)),g.Tvars(k));
         NonStateEquations = [NonStateEquations; elementala; elementalb];
         n_NonState        = n_NonState + 2;
         k=k+1;
         % If it is a Transformer with branch b in the tree
      elseif  g.b_type(k) == 'TF' && g.b_type(k+1) == 'TF' && b_isbranch(k+1)
         NonStateVars      = [NonStateVars;    g.Tvars(k); g.Avars(k+1)];
         NonStateSecVars   = [NonStateSecVars; g.Avars(k); g.Tvars(k+1)];
         NonStateCoeffs    = [NonStateCoeffs; sym(1)/g.b_coeff(k); sym(1)/g.b_coeff(k)];
         elementala = -g.b_coeff(k)  * solve(constraint(b_constraint(k+1)),g.Tvars(k+1));
         elementalb =  g.b_coeff(k+1)* solve(constraint(b_constraint(k)),g.Avars(k));
         NonStateEquations = [NonStateEquations; elementala; elementalb];
         n_NonState        = n_NonState + 2;
         k=k+1;
      end
   end
   k=k+1;
end
%--------------------------------------------------------------------------
% Write the equations as
%           dx/dt = Px + Qp + Rd + Su
%               p = Hx + Jp + Kd + Lu
%               d = M dx/dt + N du/dt
% where x is the state vector, p is the vector of algebraic (non-state)
% primary variables from D-type and 2-port branches, d is the vector of
% dependent ESE primary variables.  (See Rowell and Wormley p. 150)
% Form the matrices, and substitute to form the state equations
%--------------------------------------------------------------------------
Pmat   = gen_matrix(StateEquations,    StateVars);
Qmat   = gen_matrix(StateEquations,    NonStateVars);
Smat   = gen_matrix(StateEquations,    g.Inputs);
Hmat   = gen_matrix(NonStateEquations, StateVars);
Jmat   = gen_matrix(NonStateEquations, NonStateVars);
Lmat   = gen_matrix(NonStateEquations, g.Inputs);
IminusJ = (eye(size(Jmat)) - Jmat);
Hprime = IminusJ\Hmat;
Lprime = IminusJ\Lmat;
%
if n_Depend == 0   %No dependent ESEs.
   Amatrix = simplify(Pmat + Qmat*Hprime);
   Bmatrix = simplify(Smat + Qmat*Lprime);
   Ematrix = sym(zeros(n_State, n_Input));
else               % There are dependent ESEs.
   %
   % Force the dependent equations into the form
   %               d = M' dx/dt + N' du/dt
   % by noting that
   %               dp/dt = H' dx/dt + K' dd/dt + L' du/dt
   % and substituting to form
   %               d = (VH' + M)dx/dt + (VL' + N)du/dt + VK' dd/dt
   % where (hopefully) VK' = 0....
   %
   Mmat    = gen_matrix(DependentEquations, StateVars);
   Nmat    = gen_matrix(DependentEquations, g.Inputs);
   Vmat    = gen_matrix(DependentEquations, NonStateVars);
   Kmat    = gen_matrix(NonStateEquations,  DependVars);
   Rmat    = gen_matrix(StateEquations,     DependVars);
   Mprime  = Vmat*Hprime + Mmat;
   Nprime  = Vmat*Lprime + Nmat;
   Kprime  = IminusJ\Kmat;
   Tmat    = (eye(n_State) - (Qmat*Kprime + Rmat)*Mprime);
   Amatrix = simplify(Tmat\(Pmat + Qmat*Hprime));
   Bmatrix = simplify(Tmat\(Smat + Qmat*Lprime));
   Ematrix = simplify(Tmat\((Qmat*Kprime + Rmat)*Nprime));
end
%--------------------------------------------------------------------------
%   Form the Algebraic Output Equations
%
[Output_names,out_expressions, is_integral,n_Output] = ...
   parse_output_string(outstring, g.b_name,g.Avars,g.Tvars);
% State Variables (primary)
Cmatrix = sym(zeros(n_Output,n_State));
Dmatrix = sym(zeros(n_Output,n_Input));
Fmatrix = sym(zeros(n_Output,n_Input));
for j=1:n_Output
   row = gen_matrix(out_expressions(j),StateVars);
   Cmatrix(j,:) = Cmatrix(j,:) + row;
end
% State Secondary variables
for j=1:n_Output
   row = gen_matrix(out_expressions(j),StateSecVars);
   for i = 1:length(row)
      if ~(row(i) == sym(0))
         Cmatrix(j,:) = Cmatrix(j,:) + row(i)*Amatrix(i,:)/StateCoeffs(i);
         Dmatrix(j,:) = Dmatrix(j,:) + row(i)*Bmatrix(i,:)/StateCoeffs(i);
         Fmatrix(j,:) = Fmatrix(j,:) + row(i)*Ematrix(i,:)/StateCoeffs(i);
      end
   end
end
%   Algebraic primary variables
%   If there are no dependent energy storage elements in the system
if n_Depend == 0
   %Primary
   for j=1:n_Output
      row = gen_matrix(out_expressions(j),NonStateVars);
      for i = 1:length(row);
         if ~(row(i) == sym(0))
            Cmatrix(j,:) = Cmatrix(j,:) + row(i)*Hprime(i,:);
            Dmatrix(j,:) = Dmatrix(j,:) + row(i)*Lprime(i,:);
         end
      end
   end
   %Secondary
   for j=1:n_Output
      row = gen_matrix(out_expressions(j),NonStateSecVars);
      for i = 1:length(row)
         if ~(row(i) == sym(0))
            Cmatrix(j,:) = Cmatrix(j,:) + row(i)*Hprime(i,:)/NonStateCoeffs(i);
            Dmatrix(j,:) = Dmatrix(j,:) + row(i)*Lprime(i,:)/NonStateCoeffs(i);
         end
      end
   end
else
   Wmat = (eye(n_State) - Rmat*Mprime);
   Vmat = (eye(n_NonState) - Jmat -Kmat*Mprime/Wmat*Qmat);
   Cxx  = Vmat\(Hmat + Kmat*Mprime/Wmat*Pmat);
   Dxx  = Vmat\(Lmat + Kmat*Mprime/Wmat*Smat);
   Fxx  = Vmat\(Kmat*Nprime + Kmat*Mprime/Wmat*Rmat*Nprime);
   % Primary
   for j=1:n_Output
      row = gen_matrix(out_expressions(j),NonStateVars);
      for i = 1:length(row);
         if ~(row(i) == sym(0))
            Cmatrix(j,:) = Cmatrix(j,:) + row(i)*Cxx(i,:);
            Dmatrix(j,:) = Dmatrix(j,:) + row(i)*Dxx(i,:);
            Fmatrix(j,:) = Fmatrix(j,:) + row(i)*Fxx(i,:);
         end
      end
   end
   %Secondary
   for j=1:n_Output
      row = gen_matrix(out_expressions(j),NonStateSecVars);
      for i = 1:length(row);
         if ~(row(i) == sym(0))
            Cmatrix(j,:) = Cmatrix(j,:) + row(i)*Cxx(i,:)/NonStateCoeffs(i);
            Dmatrix(j,:) = Dmatrix(j,:) + row(i)*Dxx(i,:)/NonStateCoeffs(i);
            Fmatrix(j,:) = Fmatrix(j,:) + row(i)*Fxx(i,:)/NonStateCoeffs(i);
         end
      end
   end
end
% Dependent ESE primary variables
if n_Depend > 0
   for j = 1:n_Output
      row = gen_matrix(out_expressions(j),DependVars);
      Cprime = Mprime*Amatrix;
      Dprime = Mprime*Bmatrix;
      Fprime = Mprime*Ematrix + Nprime;
      for i = 1:length(row);
         if ~(row(i) == sym(0))
            Cmatrix(j,:) = Cmatrix(j,:) + Cprime(i,:);
            Dmatrix(j,:) = Dmatrix(j,:) + Dprime(i,:);
            Fmatrix(j,:) = Fmatrix(j,:) + Fprime(i,:);
         end
      end
   end
end
% Dependent ESE secondary variables
if n_Depend > 0
   Vmat = gen_matrix(constraint,NonStateVars);
   Wmat = gen_matrix(constraint,StateVars);
   Xmat = gen_matrix(constraint,g.Inputs);
   Rmat = Vmat*Hprime + Wmat;
   Ymat = Vmat*Lprime + Xmat;
   for j=1:n_Output
      row = gen_matrix(out_expressions(j),DependSecVars);
      for i = 1:length(row)
         if ~(row(i) == sym(0))
            col = gen_matrix(constraint,DependSecVars(i));
            for m = 1:length(col)
               if ~(col(m) == 0)
                  Cmatrix(j,:) = Cmatrix(j,:) - row(i)*Rmat(m,:);
                  Dmatrix(j,:) = Dmatrix(j,:) - row(i)*Ymat(m,:);
               end
            end
         end
      end
   end
end
%
% Look for inputs in the expression
for j=1:n_Output
   row = gen_matrix(out_expressions(j),g.Inputs);
   Dmatrix(j,:) = Dmatrix(j,:) + row;
end
% Handle expressions with integrals by augmenting and modifying
% the matrices.
for j = 1:n_Output
   if is_integral(j)
      StateVars = [StateVars; Output_names(j)];
      n_State   = n_State + 1;
      Amatrix   = [Amatrix; Cmatrix(j,:)];
      Amatrix   = [Amatrix, zeros(n_State,1)];
      Bmatrix   = [Bmatrix; Dmatrix(j,:)];
      Ematrix   = [Ematrix; zeros(1, n_Input)];
      Cmatrix   = [Cmatrix, zeros(n_Output,1)];
      Cmatrix(j,:) = zeros(1,n_State);
      Cmatrix(j,n_State) = 1;
      Dmatrix(j,:) = Fmatrix(j,:);
      Fmatrix(j,:) = zeros(1,n_Input);
   end
end
% Look for prior defined outputs in the expression
% Check only names that have been defined by  'name = expression'
Defined_names = [];
for j=1:n_Output
   if Output_names(j)~=out_expressions(j)
      isInput = false;
      for k = 1:n_Input
         if  Output_names(j) == g.Inputs(k);
            isInput = true;
            break
         end
      end
      if ~isInput
        Defined_names = [Defined_names; Output_names(j)];
      end
   end
end
for j=1:n_Output
   row = gen_matrix(out_expressions(j),Defined_names);
   for k = 1:length(row)
      if row(k) ~=0
         Cmatrix(j,:) = Cmatrix(j,:) + row(k)*Cmatrix(k,:);
         Dmatrix(j,:) = Dmatrix(j,:) + row(k)*Dmatrix(k,:);
         Fmatrix(j,:) = Fmatrix(j,:) + row(k)*Fmatrix(k,:);
      end
   end
end
%
% Warn if the E or F matrices are not empty.
deriv_flag = 0;
[nrows,ncols] = size(Ematrix);
for i= 1:nrows
   for j = 1:ncols
      if ~(Ematrix(i,j) == sym(0))
         deriv_flag = 1;
      end
   end
end
[nrows,ncols] = size(Fmatrix);
for i= 1:nrows
   for j = 1:ncols
      if ~(Fmatrix(i,j) == sym(0))
         deriv_flag = 1;
      end
   end
end
%
if deriv_flag
   fprintf(['\nWarning:  This system has source-dependent energy storage elements.\n',...
      'The power-variable based state-space representation of this system\n',...
      'involves derivatives of the inputs.\n',...
      'The E and/or F matrices must be included in the system description:\n',...
      '             dx/dt = Ax + Bu + Edu/dt\n',...
      '                 y = Cx + Du + Fdu/dt.\n',...
      'The matrices E and F have been computed.\n',...
      'Notes:\n1) Do not use Sys2ss() to convert this system to a MATLAB object,\n',...
      'use Sys2tf() instead.\n',...
      '2) If you need to eliminate the E and F matrices from your ',...
      'model,\nand still retain the use of power-variables, use a Thevenin ',...
      'or\nNorton source instead of an ideal source.\n'])
end
% Now handle the parameter names and values
names = g.params;
vals = zeros(length(names),1);
for j = 1:length(vals)
   vals(j) = NaN;
end
if ~strcmp(valstring,'')
   vals = get_vals(vals, names, valstring);
end
%
% Return the system as a structure
sys.A           = simplify(Amatrix);
sys.B           = simplify(Bmatrix);
sys.C           = simplify(Cmatrix);
sys.D           = simplify(Dmatrix);
sys.E           = simplify(Ematrix);
sys.F           = simplify(Fmatrix);
sys.StateVars   = StateVars;
sys.Inputs      = g.Inputs;
sys.Outputs     = Output_names;
sys.Names       = names;
sys.Values      = vals;
sys.Valstring   = valstring;
end
%
