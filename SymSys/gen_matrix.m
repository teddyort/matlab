function  mat = gen_matrix(equations, variables)
%

%gen_matrix - SymSys internal function
%             Generate a SymSys coefficient matrix from a set of
%             equations, given a set of variables.
%
% Note:     This is not a user called function.
%
% Call:   mat = gen_matrix(equations, variables)
%               equations - a set of symbolic equations
%               variables - a list of variables
%
% Author:        Derek Rowell (drowell@mit.edu)
% Revision Date: April 5, 2009
%--------------------------------------------------------------------------
%
nrows = length(equations);
ncols = length(variables);
mat = sym(zeros(nrows, ncols));
for k =1:nrows
   for j=1:ncols
      [c,t] = coeffs(expand(equations(k)), variables(j));
      for i = 1:length(c)
         if t(i)==variables(j)
            mat(k,j) = c(i);
         end
      end
   end
end
end