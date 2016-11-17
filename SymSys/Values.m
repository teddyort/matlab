function  varargout = Values(sys)
%Values - Display the parameter values for a SymSys system object
%
% (A)      Values(sys) - displays the numerical values of system parameters
%              of the SymSys object 'sys'.
%
% (B)      out_string = Values(sys) - assigns the parameter system value
%              string  of the SymSys object 'sys' to out_string.  The
%              values are not displayed.

% Author:        Derek Rowell (drowell@mit.edu)
% Revision Date: Oct. 25, 2010
%--------------------------------------------------------------------------
%
val_string = sys.Valstring;
if nargout == 0
   names = sys.Names;
   vals  = sys.Values;
   if isempty(names)
      fprintf('\nThis system contains no symbolic system parameters.\n')
   else
      fprintf('\nSystem parameter values:')
      for j = 1:length(names);
         if ~isnan(vals(j))
            fprintf('\n%s:\t%g',char(names(j)),vals(j))
         else
            fprintf('\n%s:\t(not defined)',char(names(j)))
         end
      end
      fprintf('\n\n')
   end
elseif nargout == 1
   varargout{1} = val_string;
end
end