function C = morse_table(C,M,dd) 
% MORSE_TABLE
% C = morse_table
% C = morse_table(morse_tree)
% C = morse_table(morse_tree_extended)
% Generate tables of the ASCII and Morse codes
% for the characters defined by the binary trees.

%   Copyright 2014 Cleve Moler
%   Copyright 2014 The MathWorks, Inc.

   if nargin < 3           % Choose binary tree
      if nargin == 0
         M = morse_tree;
      else
         M = C;
      end
      C = cell(256,1);     % The temporary code table
      dd = '';             % dots and dashes
   end
   
   if ~isempty(M)                        % Depth first search
      if ~isempty(M{1})
         C{double(M{1})} = dd;           % Use ASCII value as an index
      end
      C = morse_table(C,M{2},[dd '.']);   % Recursive call
      C = morse_table(C,M{3},[dd '-']);   % Recursive call
   end

   if nargin < 3                    % Final processing, convert to char.
      c = char(C{:});
      k = find(c(:,1) ~= ' ');      % Find the nonblank entries.
      b = blanks(length(k))';
      C = [char(k) b b int2str(k) b b char(C{k})];
   end
