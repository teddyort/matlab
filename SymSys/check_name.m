function outname = check_name(name)
%

%check_name - SymSys internal function
%           Check a SymSys name for a MATLAB reserved word.
%
% Call:     outname  = check_name(name)
%                      name - (string) a element or variable name
%                      out  - (string) a set to "name" if successful,
%                              that is no name clash is found.
%
% Notes:    This is not a user called function.

% Author:        Derek Rowell (drowell@mit.edu)
% Revision Date: Nov. 21, 2010
%--------------------------------------------------------------------------
%
reserved_names = {'i', 'I', 'pi', 'PI', 'eps'};
errmsg = sprintf(['SymSys naming error:  The name "%s" is a MATLAB reserved'...
   ' word\nand cannot be used as a SymSys element or variable name.'...
   '\nChange the name and try again.'],name);
for j = 1:length(reserved_names)
   if strcmp(name, reserved_names(j))
      error(errmsg);
   else
      outname = name;
   end
end
end