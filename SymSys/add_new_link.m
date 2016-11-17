function [out_branches, out_links, out_unassigned] = ...
   add_new_link(new_link, branches, links, unassigned, LGm,...
   Inc_mat, tfts, gyts)
%

% add_new_link - SymSys internal function
%           Add a new link to the normal tree of a linear graph
%           based model.  Then propagate the causality implied
%           by the new link and update the tree accordingly.
%
% Notes:   This is a component of the SymSys symbolic modeling package.
%          This is not a user-called function.
%
% Call:   [out_branches, out_links, out_unassigned] = ...
%               add_new_link(new_link, branches, links, unassigned, LGm,...
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
% Algorithmic note: Because this function is used to propagate causality
%          throughtout the graph, it may call itself recursively, and call
%          the function add_new_branch().   Therefore a single call to
%          add_new_link() may result in many new branches and links being
%          added to the normal tree.
%
% Authors:        Derek Rowell (drowell@mit.edu)
%                 Morteza Ganji (morteza.ganji@gmail.com) IUT, Iran
% Revision Date:  Nov. 10, 2010
%--------------------------------------------------------------------------
%
%  Add the new link only if it does not exist in the links already
%  (Caused by recursive calls with two-ports)
if isempty(find(links==new_link,1))
   % Place the new link in the links, and remove from the remaining edges list
   links = [links; new_link];
   i = find(unassigned(:,1)==new_link);
   if unassigned(i,2)==4
      display(['Modeling error: SymSys found one or more dependent '...
         'A-type sources',char(13),'in your linear graph.',char(13),...
         'This represents a physical violation. Check your model.'])
      error('Dependent A-type sources')
   end
   edge_type = unassigned(i,2);
   unassigned(i,:) = [];
   % Look for two-port constraints - if a two-port edge has been placed in
   % the links:
   % If it is a transformer, the "other" edge must be a branch
   % ("one-in, one-out" rule)
   if edge_type == 6       %TF
      x = find(tfts==new_link);
      [row, col] = ind2sub(size(tfts),x);
      if col == 1
         [branches, links, unassigned] = ...
            add_new_branch(tfts(row,2), branches, links,...
            unassigned, LGm, Inc_mat, tfts, gyts);
      elseif col ==2
         [branches, links, unassigned] = ...
            add_new_branch(tfts(row,1), branches, links,...
            unassigned, LGm, Inc_mat, tfts, gyts);
      end
      % If it is a gyrator, the "other" edge must also be a link
      % ("both-in" rule)
   elseif edge_type == 7
      x = find(gyts==new_link);
      [row, col] = ind2sub(size(gyts),x);
      if col == 1
         [branches, links, unassigned] = ...
            add_new_link(gyts(row,2), branches, links, unassigned,...
            LGm, Inc_mat, tfts, gyts);
      elseif col==2
         [branches, links, unassigned] = ...
            add_new_link(gyts(row,1), branches, links, unassigned,...
            LGm, Inc_mat, tfts, gyts);
      end
   end
   new_branches = [];
   new_links    = [];
   %
   % Propagate causality based on this assignment - look for loops involving
   % the new link, assigned branches and unassigned edges.
   % Form the temporary incidence matrix
   Im_cte = [];
   N_branch    = length(branches);
   % the new incidence matrix is based on 1) the new link, 2) existing
   % branches and 3) unassigned edges
   Im_cte(1,:) = Inc_mat(links(end),:);
   for i = 1:N_branch
      Im_cte(end+1,:) = Inc_mat(branches(i),:);
   end
   Im_cte = [Im_cte; Inc_mat(unassigned(:,1),:)];
   loops = null(Im_cte','r');
   % Find the number of loops containing the new link
   le = find(loops(1,:));
   N_new_loops = length(le);
   ler = loops(N_branch+2:end, le);
   loops(:,le) = [];
   other = loops(N_branch+2:end,:);
   %
   if N_new_loops == 1
      Nbs = find(ler)';
   elseif N_new_loops > 1
      Nbs = [];
      for i = 1:length(unassigned(:,1))
         if length(find(ler(i,:))) == N_new_loops...
               && isempty(find(other(i,:),1))
            Nbs = [Nbs; i];
         end
      end
   end
   %
   for i = 1:length(Nbs)
      new_branches = [new_branches; unassigned(Nbs(i),1)];
   end
   for i=1:length(new_branches)
      [branches, links, unassigned] = ...
         add_new_branch(new_branches(i), branches, links, unassigned,...
         LGm, Inc_mat, tfts, gyts);
   end
end
out_branches=branches;
out_links = links;
out_unassigned = unassigned;
end