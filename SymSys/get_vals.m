function new_vals = get_vals(vals, names, valstring )
%

%get_vals - SymSys internal function
%          Parse a value string and update the value list.
%
% Note:    This is an internal SymSys function and is not a user called
%          function.
%
% Author:        Derek Rowell (drowell@mit.edu)
% Revision Date: Nov. 23, 2010
%--------------------------------------------------------------------------
%
new_vals = vals;
% check for valid syntax: name=value; in valstring
equals    = strfind(valstring,'=');
semicolon = strfind(valstring,';');
if length(equals) ~= length(semicolon)
   error('SymSys: Syntax error in value specification: %s', valstring)
end
%
temp = valstring;
for k = 1:length(equals)
   [defn,temp] = strtok(temp,';');
   [name,val] = strtok(defn,'=');
      val = str2num(val(2:length(val)));
   if isempty(val)
      error(['SymSys: Invalid numerical value in the value ',...
            'specification: %s'], valstring)
   end
   not_found = true;
   for j = 1:length(names)
      if name==names(j)
         new_vals(j) = val;
         not_found = false;
      end
   end
   if not_found
      error(['SymSys: The parameter name "%s", specified in the',...
             ' value string is not defined for this system.'], name);
   end
end
end

