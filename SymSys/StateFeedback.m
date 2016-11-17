function newsys = StateFeedback(sys,gains)
%StateFeedback - Create a Symsys system object from state-feedback gains
%
% Call:      newsys = StateFeedback(sys, gains)
%                sys   - an existing SymSys system object.
%                gains - a (1 x n) row vector of state-feedback gains, 
%                        where n is the order of sys.
%                        The entries in gains must be in the order
%                        of the states as revealed by StateVars(sys).

% Author:        Derek Rowell (drowell@mit.edu)
% Revision Date: Nov. 24, 2010
%--------------------------------------------------------------------------
%
syms a
order = length(sys.A(:,1));
if length(gains) ~= order
   error('Length of gain vector is not compatible with the system order.')
end
newsys   = sys;
newsys.A = sys.A - sys.B*gains;
% Look for symbolic names in the gain matrix
names = sys.Names;
vals = sys.Values;
namestring = [];
for i = 1:length(gains)
   namestring = [namestring, gains(i)];
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
         vals  = [vals;  NaN];
      end
   end
end
% Set up the values list, define unspecified values as NaN
%
newsys.Valstring = sys.Valstring;
newsys.Values = vals;
newsys.Names = names;

end