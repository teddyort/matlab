function [branches, links] = normal_tree(LGm_in)
%

%normal_tree - Internal SymSys function
%          Find the branches and links of a linear graph normal tree
%
% Notes:   This is a component of the SymSys symbolic modeling package.
%          This is not a user called function.
%
% Call:   [branches, links] = normal_tree(LGm_in)
%               LGm_in    - (nedge x 4) Linear graph edge definition
%               branches  - branches of the normal tree.
%               links     - links of the normal tree
%
% Authors:       D. Rowell (drowell@mit.edu)
%                Morteza Ganji (morteza.ganji@gmail.com) IUT, Iran
% Revision Date: September 28, 2010
%--------------------------------------------------------------------------
%
%
Atype = 1; Ttype = 2; Dtype = 3; Asource = 4; Tsource = 5;
TF = 6; GY = 7;
sort_order = [Tsource; Asource; Atype; GY; Dtype; TF; Ttype];
N_edge = size(LGm_in,1);
N_vertex = max(max(LGm_in(:,2)),max(LGm_in(:,3)));
unassigned = zeros(N_edge,2);
% Create the Linear Graph matrix in the sort order
LGmatrix = [];
k = 1;
for i = 1:7
   for j = 1:N_edge
      if LGm_in(j,4) == sort_order(i)
         LGmatrix = [LGmatrix; LGm_in(j,:)];
         unassigned(k,:)=[LGm_in(j,1),LGm_in(j,4)];
         k=k+1;
      end
   end
end
%
% Create the system incidence matrix (in the original order
%
Inc_mat=zeros(N_edge,N_vertex);
for i=1:N_edge
   Inc_mat(i,LGm_in(i,2)) = -1;
   Inc_mat(i,LGm_in(i,3) )= 1;
end
%
% Define transformers and gyrators
%
i=1;
transformers=[];
gyrators=[];
while i<N_edge+1
   if LGmatrix(i,4) == TF
      transformers = [transformers; LGmatrix(i,1) LGmatrix(i+1,1)];
      i=i+1;
   elseif LGmatrix(i,4) == GY
      gyrators = [gyrators; LGmatrix(i,1) LGmatrix(i+1,1)];
      i=i+1;
   end
   i=i+1;
end
%
branches=[];
links=[];
%
% Handle T sources first. For now, assume that all T sources may
% be placed in the links. (To be checked later)
%
while  ~isempty(unassigned) && unassigned(1,2) == Tsource
   [branches, links, unassigned] = add_new_link(unassigned(1,1),...
      branches, links, unassigned, LGmatrix, Inc_mat,...
      transformers, gyrators);
end
%
% Now handle all of the remaining edges in the standard order (in the order
% of elements in "unassigned")
%
while ~isempty(unassigned(:,1))
   %
   % Check for a loop formed when the new edge is added.  Assign to branches
   % or links accordingly.
   %
   Im_temp = [Inc_mat(unassigned(1,1),:); Inc_mat(branches,:) ];
   if isempty(null(Im_temp','r'))
      [branches, links, unassigned] = add_new_branch(unassigned(1,1),...
         branches, links, unassigned, LGmatrix, Inc_mat,...
         transformers, gyrators);
   else
      [branches, links, unassigned] = add_new_link(unassigned(1,1),...
         branches, links, unassigned, LGmatrix, Inc_mat,...
         transformers, gyrators);
   end
end
%
% Check for tree completion and T-source violation by ensuring that all
% T-sources are in the links
%
for i = 1:length(branches)
   if LGm_in(branches(i),4)==Tsource
      display(['Modeling error: SymSys found one or more dependent '...
         'T-type sources',char(13),'in your linear graph.',char(13),...
         'This represents a physical violation. Check your model.'])
      error('Dependent T-type sources')
   end
end
end

