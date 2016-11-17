function [out_branches, out_links, out_unassigned] = ...
   add_new_branch(new_branch, branches, links, unassigned, LGm,...
   Inc_mat, tfts, gyts)
%

%add_new_branch - SymSys internal function
%           Add a new branch to the normal tree of a linear graph
%           based model. Then propagate the causality implied
%           by the new branch and update the tree accordingly.
%
% Notes:   This is a component of the SymSys symbolic modeling package.
%          This is not a user-called function.
%
% Call:   [out_branches, out_links, out_unassigned] = ...
%             add_new_branch(new_link, branches, links, unassigned, LGm,...
%                             Inc_mat, tfts, gyts)
%               new_link   - numerical link identifier of the new link
%               branches   - list of current branches in the tree
%               links      - list of current links associated with the tree
%               unassigned - list of unnassigned graph edges and types
%               LGm        - Linear graph specification matrix
%               Inc_mat    - Incidence matrix for the linear graph
%               tfts       - transformer edge specification
%               gyts       - gyrator edge specification
%
% Returns:      out_branches   - updated list of normal tree branches
%               out_links      - updated list of normal tree links
%               out_unassigned - updated list of unassigned graph edges
%
% Algothmic note: Because this function is used to propagate causality
%          throughtout the graph, it may call itself recursively, and call
%          the function add_new_link().   Therefore a single call to
%          add_new_branchk() may result in many new branches and links
%          being added to the normal tree.
%
% Authors:        Derek Rowell (drowell@mit.edu)
%                 Morteza Ganji (morteza.ganji@gmail.com) IUT, Iran
% Revision Date:  Nov. 10, 2010
%--------------------------------------------------------------------------
%
% Propagate causality based on this assignment - look for loops involving
% the new link, assigned branches and unassigned edges.
% Form the temporary incidence matrix
%
% Check to see if branch has already been added
%    - necessary because of recursive calls in handling two-ports
if isempty(find(branches==new_branch, 1))
   branches = [branches; new_branch];
   i = find(unassigned(:,1)== new_branch);
   edge_type = unassigned(i,2);
   unassigned(i,:) = [];
   % Handle two ports
   % Look for two-port constraints - if a two-port edge has been placed in
   % the branches:
   % If it is a transformer, the "other" branch must be a link
   % ("one-in, one-out" rule)
   if edge_type == 6       %TF
      x = find(tfts==new_branch);
      [row, col] = ind2sub(size(tfts),x);
      if col == 1                    % even or odd?
         [branches, links, unassigned] = ...
            add_new_link(tfts(row,2), branches, links,...
            unassigned, LGm, Inc_mat, tfts, gyts);
      elseif col==2
         [branches, links, unassigned] = ...
            add_new_link(tfts(row,1), branches, links,...
            unassigned, LGm, Inc_mat, tfts, gyts);
      end
      % If it is a gyrator, the "other" edge must also be a branch
      % ("both-in" rule)
   elseif edge_type == 7
      x = find(gyts==new_branch);
      [row, col] = ind2sub(size(gyts),x);
      if col == 1
         [branches, links, unassigned] = ...
            add_new_branch(gyts(row,2), branches, links,...
            unassigned,  LGm, Inc_mat, tfts, gyts);
      elseif col ==2
         [branches, links, unassigned] = ...
            add_new_branch(gyts(row,1), branches, links,...
            unassigned, LGm, Inc_mat, tfts, gyts);
      end
   end
   % Causality propagation
   % Test for loops with all unassigned elements.  If a loop is formed, assign
   % that element to the links.
   Inc_mat_branches = Inc_mat(branches(1),:);
   for m= 2:length(branches)
      Inc_mat_branches =  [Inc_mat_branches;Inc_mat(branches(m),:)];
   end
   test = unassigned(:,1);
   for  i = 1:length(test)
      Inc_mat_temp = [Inc_mat_branches; Inc_mat(test(i),:)];
      if ~isempty(null(Inc_mat_temp','r'))
         [branches, links, unassigned] = ...
            add_new_link(test(i), branches, links, unassigned,...
            LGm, Inc_mat, tfts, gyts);
      end
   end
end
out_branches   = branches;
out_links      = links;
out_unassigned = unassigned;
end

