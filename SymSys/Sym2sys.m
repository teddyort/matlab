function sys = Sym2sys(gstring, outstring, varargin)
%Sym2sys - Alternative SymSys system object specification.
%
% Call:     sys  = Sym2sys(sysspec, outstring {,valstring})
%                      sysspec - (string) a  modified linear graph element
%                               specification string.
%                      outstring  - (string) a list of output variables.
%                      valstring  - (string) (optional) a list of system
%                               parameter values.
%      (see the documentation for details on the specification strings)
%
% Example:  spec   = ['(force,Fs,1),(damper,B,1:2),(mass,m,2)'];
%           out    =  'velocity:m';
%           values =  'm=3, B=0.5';
%           mysys  = Sym2sys(spec, out, values);
%
% Author:   D. Rowell (drowell@mit.edu)
% Date:     April 5, 2009
%----------------------------------------------------------------
%
%Fetch the valus string if present,
if nargin == 3
   valstring = varargin{1};
   if ~strcmp(valstring,'')
      valstring = [strrep(valstring, ',', ';'),';'];
   end
else
   valstring = '';
end
% Parse the graph specification string and store the element data in a
% structure:
%    g.b_head, g.b_tail -  head and tail of each directed graph edge.
%    g.b_type           -  Standardized branch (element) type
%    g.b_name           -  the user specified element name
%    g.b_coeff          -  the element coefficient
%    g.params           -  list of symbolic parameter names
%    g.Avars            -  across variable on each element
%    g.Tvars            -  through variable on each element
%    g.Inputs           -  system inputs
%------------------------------------------------------------------
% Put the graph specification string into a Maple "list of lists" format
g= strrep(gstring,'<','[');
g= strrep(g,'>',']');
g= strrep(g,'(','[');
g= strrep(g,')',']');
g= strrep(g,'{','[');
g= strrep(g,'}',']');
g= strrep(g,'][','],[');
g= strrep(g,' ','');
% Check for imbalance in brackets
nleft  = findstr(g, '[');
nright = findstr(g, ']');
if ~(length(nleft) == length(nright))
   error('Imbalance in parentheses/brackets in system specification string')
end
%
g_out = '';
%Parse the string into element specifications
elements = regexp(g, '\[\w.*?\]', 'match');
%
% Handle each element - break down into substrings
for i= 1:length(elements)
%   parts = regexp(elements{i}, '\w*[:]\w*|\w*', 'match');
   str = elements{i};
   str = strrep(str,'[','');
   str = strrep(str,']','');
   parts = {};
   [parts{1},str] = strtok(str,',');
   k=1;
   while ~isempty(str)
      k=k+1;
      [parts{k},str] = strtok(str(2:length(str)),',');
   end
   [b_type,~,~,~] = find_branch_type(parts{1});
% Determine whether this is a one-port elelement
   if   strcmp(b_type,'A')  || strcmp(b_type, 'T')  || strcmp(b_type, 'D') ...
     || strcmp(b_type,'As') || strcmp(b_type, 'Ts')
      % Handle the tail and head
      colon = findstr(parts{3}, ':');
      if isempty(colon)
         if strcmp(b_type,'Ts')
            b_tail = '1';
            b_head = sprintf('%i',(eval(parts{3})+1));
         else
            b_head = '1';
            b_tail = sprintf('%i',(eval(parts{3})+1));
         end
      else
         b_tail = sprintf('%i',eval(parts{3}(1:colon(1)-1)) + 1);
         b_head = sprintf('%i',eval(parts{3}(colon(1)+1:length(parts{3}))) + 1);
      end
      if length(parts) == 3
         g_out = [g_out, '(',b_tail,':',b_head,',',parts{1},',',...
                    parts{2},')'];
      elseif length(parts) == 5
         g_out = [g_out, '(',b_tail,':',b_head,',',parts{1},',',...
              parts{2},',', parts{4},',',parts{5},')'];
      else
         error('Sym2sys:  Invalid number of entries in %s', elements{i})
      end
%
   elseif strcmp(b_type,'CAs')  || strcmp(b_type, 'CTs')
      % Handle the tail and head
      colon = findstr(parts{3}, ':');
      if isempty(colon)
         if strcmp(b_type,'cTs')
            b_tail = '1';
            b_head = sprintf('%i',(eval(parts{3})+1));
         else
            b_head = '1';
            b_tail = sprintf('%i',(eval(parts{3})+1));
         end
      else
         b_tail = sprintf('%i',eval(parts{3}(1:colon(1)-1)) + 1);
         b_head = sprintf('%i',eval(parts{3}(colon(1)+1:length(parts{3})))+1);
      end
      if length(parts) == 4
         g_out = [g_out, '(',b_tail,':',b_head,',',parts{1},',',...
              parts{2},',', parts{4},')'];
      elseif length(parts) == 5
         g_out = [g_out, '(',b_tail,':',b_head,',',parts{1},',',...
              parts{2},',', parts{4},',',parts{5},')'];
      else
         error('Sym2sys:  Invalid number of entries in %s', elements{i})
      end
%      
   elseif strcmp(b_type,'TF')  || strcmp(b_type, 'GY')  
      % It is a two-port
      % Add the "a" side branch
      colon = findstr(parts{3}, ':');
      if isempty(colon)
         b_heada = '1';
         b_taila = sprintf('%i',(eval(parts{3})+1));
      else
         b_taila = sprintf('%i%',eval(parts{3}(1:colon(1)-1)) + 1);
         b_heada = sprintf('%i%',eval(parts{3}(colon(1)+1:length(parts{3}))) + 1);
      end
      % Add the "b" side branch
      colon = findstr(parts{4}, ':');
      if isempty(colon)
         b_headb = '1';
         b_tailb = sprintf('%i',eval(parts{4})+1);
      else
         b_tailb = sprintf('%i',eval(parts{4}(1:colon(1)-1)) + 1);
         b_headb = sprintf('%i',eval(parts{4}(colon(1)+1:length(parts{4}))) + 1);
      end
      g_out = [g_out,'(', b_taila,':',b_heada,',',b_tailb,':',b_headb,...
               ',', parts{1},',', parts{2},')'];
   end
end
   sys = Lgraph2sys(g_out, outstring);
%
end

