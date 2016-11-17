function  [name,expression, is_integral,N_out ] = ...
   parse_output_string(outstring, el_name, Avars, Tvars)
%

% parse_output_string - SymSys internal function
%         to parse an output specification string in struct2sys().
%
% Note:   This is an internal function in the SymSys package.
%         It is not a user called function.
%
% Call:  [names,exp,is_integral,N_out]  = parse_output_string(outputstring)
%               outstring   - (string) a comma separated string
%                              specifying output expressions.
%               names       - (symbolic) the list of output variable names.
%               exp         - (symbolic) the list of expressions.
%               is_integral - (logical) true if the expression is to
%                              be integrated.
%
% Author:        Derek Rowell (drowell@mit.edu)
% Revision Date: April 17, 2009
%----------------------------------------------------------------
%
A_names = {'v','vol','vel','w','ang','rot','p','pre','temp'};
T_names = {'i','cur','f','for','t','tor','q','flo','h','hea'};
% Remove spaces
outstring= strrep(outstring,' ','');
% Check for valid output variables in directly specified names
match_ends = regexp(outstring, '^\w*\,|\,\w*$', 'match');
matches    = regexp(outstring,'\,\w*\,', 'match');
matches    = [matches, match_ends];
matches    = strrep(matches, ',','');
All_vars   = [Avars; Tvars];
if ~isempty(matches)
   for i = 1:length(matches)
      found = 0;
      for j = 1:length(All_vars)
         if matches{i} == All_vars(j)
            found = 1;
            break
         end
      end
      if found
         break
      end
      if ~found
         error(['Output variable specification: System variable ''',...
            matches{i}, ''' not found'])
      end
   end
end
% Convert output variable specifications to internal names.
istart =1;
[start, xend, matches] =regexp(outstring,'\w*:\w*','start', 'end',...
   'match');
for j = 1:length(matches)
   [dummy1,dummy2,eltype] = regexp(matches(j),'\w*','start','end',...
      'match');
   xtype=eltype{1,1};
   xvar = lower(xtype{1,1});
   if length(xvar) > 3
      xvar = xvar(1:3);
   end
   found = 0;
   xel = xtype{1,2};
   for k= 1:length(el_name)
      if xel == el_name(k)
         found = 1;
         for i = 1:length(A_names)
            if strcmp(xvar,A_names{i})
               outstring = strrep(outstring,matches{j},char(Avars(k)));
               break
            end
         end
         for i = 1:length(T_names)
            if strcmp(xvar,T_names{i})
               outstring = strrep(outstring,matches{j},char(Tvars(k)));
               break
            end
         end
      end
   end
   if ~found
      error(['Output variable specification: Element ', xel, ' not found'])
   end
end
commas = findstr(outstring, ',');
ncommas = length(commas);
N_out = ncommas+1;
name = sym(zeros(N_out,1));
expression = sym(zeros(N_out,1));
is_integral = zeros(N_out,1);
for j = 1:ncommas+1
   if j == ncommas + 1
      expstring = outstring(istart:length(outstring));
   else
      expstring = outstring(istart:commas(j)-1);
      istart = commas(j) + 1;
   end
   x1 = findstr(expstring, '=');
   x = findstr(expstring, '=integral(');
   if isempty(x1)
      name(j) = expstring;
      expression(j) = expstring;
   elseif ~isempty(x)
      is_integral(j) = 1;
      name(j) = expstring(1:x-1);
      expression(j) = expstring(x+10: length(expstring)-1);
   else
      name(j) = expstring(1:x1-1);
      expression(j) = expstring(x1+1:length(expstring));
   end
end
end

