function outsys=SetVals(insys,varargin)
%SetVals - Assign or change the numeric values of elements in a SymSys object.
%
% Call:      sys = SetVals(sys, values)
%             sys    - a sysrep object formed by Lgraph2sys() or Sym2sys().
%             values - (string) a comma separated list of values to be
%                      assignd to system elements.
%
% Example:   mysys = SetVals(mysys,...
%                    'R1=4700, R2=1e5, C = .27e-6, L = 1e-3')

% Author:        Derek Rowell (drowell@mit.edu)
% Revision Date: Nov. 22, 2009
%--------------------------------------------------------------------------
%
% Parse the value string
names = insys.Names;
vals  = insys.Values;
if nargin == 1 || (nargin == 2 && strcmp(varargin{1},''))
   % Reset the values
   for j = 1:length(vals)
      vals(j) = NaN;
   end
elseif nargin == 2
   % Modify the values
   valstring = varargin{1};
   valstring = strrep(valstring,' ','');
   valstring = [strrep(valstring, ',', ';'),';'];
   vals = get_vals(vals, names, valstring);
end
% Form a new value string
valstr = '';
for j = 1:length(vals)
   if ~isnan(vals(j))
      valstr = [valstr, char(names(j)), '=', num2str(vals(j)),';'];
   end
end
% Save new system object
outsys           = insys;
outsys.Values    = vals;
outsys.Valstring = valstr;
end