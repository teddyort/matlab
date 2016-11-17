function sys = Lgraph2sys(gstring, outstring, varargin)
%Lgraph2sys - Create a SymSys system object from a linear
%                       graph specification.
%
%Call:    sys  = Lgraph2sys(graph, outstring {,valstring})
%             graph      - (string) a linear graph element specification
%                           string.
%             outstring  - (string) a list of output variables.
%             valstring  - (string) (optional) a list of system
%                          parameter values.
%      (see the documentation for details on the specification strings)
%
% Example:  graph  = ['(2,1,voltage,Vs),(2,3,resistor,R),'...
%                     '(3,1,capacitor,C.vC,iC)'];
%           out    =  'vC';
%           values =  'R=10000, C=1e-6';
%           mysys = LGraph2sys(graph, out, values);

% Author:        Derek Rowell (drowell@mit.edu)
% Revision Date: Nov 28, 2010
%--------------------------------------------------------------------------
%
%Fetch the valus string if present,
if nargin == 3
   valstring = varargin{1};
   if ~strcmp(valstring,'')
      valstring = strrep(valstring,' ','');
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
g = strrep(gstring,'<','[');
g = strrep(g,'>',']');
g = strrep(g,'(','[');
g = strrep(g,')',']');
g = strrep(g,'{','[');
g = strrep(g,'}',']');
g = strrep(g,'][','],[');
g = strrep(g,' ','');
g = strrep(g,':',',');
% Check for imbalance in brackets
nleft  = findstr(g, '[');
nright = findstr(g, ']');
if ~(length(nleft) == length(nright))
   error('Imbalance in parentheses/brackets in system specification string')
end
% Parse the graph string so as to prepare a MATLAB
% statement string that will declare the symbolic names
% for elements and variables:
%     syms name1 name2 .....
% Look for '[[' at start
%
n_tf = 0;
n_gy = 0;
%
b_tail  = [];
b_head  = [];
b_type  = [];
b_name  = [];
params  = [];
b_coeff = [];
Avars   = [];
Tvars   = [];
%
Inputs  = [];
n_controlled_source = 0;
control_input = [];
control_output = [];
%
%
i    = 1;
while i < length(g)
   while ~(g(i) == '[')
      i = i+1;
   end
   i      = i+1;
   istart = i;
   ileft  = 1;
   while ~(g(i) == ']') || ( g(i) == ']' && ~(ileft == 1))
      if(g(i) == ']')
         ileft = ileft-1;
      end
      if g(i) == '['
         ileft = ileft+1;
      end
      i = i+1;
   end;
   g_element = g(istart:i-1);
   el_string = g(istart:i-1);
   token = {};
   raw_token = {};
   [raw_token{1},el_string] = strtok(el_string,',');
   token{1} = strrep(raw_token{1},'[','');
   token{1} = strrep(token{1},']','');
   k=1;
   while ~isempty(el_string)
      k=k+1;
      [raw_token{k},el_string] = strtok(el_string(2:length(el_string)),',');
      token{k} = strrep(raw_token{k},'[','');
      token{k} = strrep(token{k},']','');
   end
   n_tokens = length(token);
   % We now have a string for a branch - check for a valid one-port
   [b_typex, b_signx, avar_prefix, tvar_prefix] = find_branch_type(token{3});
   if ~strcmp(b_typex,'')
      % It is a one-port: source or passive element
      if isnan(str2double(token{1})) || isnan(str2double(token{2}))
         error(['Lgraph2sys: Invalid element in linear graph:\n',...
            '    (%s)\n- nodes (elements 1 & 2) must be numeric'],g_element);
      end
      b_tail = [b_tail; eval(token{1})];
      b_head = [b_head; eval(token{2})];
      b_type =  [b_type; sym(b_typex)];
      b_namex = check_name(token{4});
      if strcmp(b_typex, 'As')
         if ~n_tokens == 4
            error(['Lgraph2sys: Invalid element specification in linear ',...
               'graph:\n    (%s)\n- a source-element list must contain ',...
               '4 items.'],g_element);
         end
         Avars = [Avars; sym(b_namex)];
         Tvars = [Tvars; sym(['xx_',b_namex])];
         Inputs = [Inputs; sym(b_namex)];
         b_name = [b_name; sym(b_namex)];
      elseif strcmp(b_typex, 'Ts')
         if ~n_tokens == 4
            error(['Lgraph2sys: Invalid element specification in linear ',...
               'graph:\n    (%s)\n- a source-element list must contain ',...
               '4 items.'],g_element);
         end
         Tvars = [Tvars; sym(b_namex)];
         Avars = [Avars; sym(['xx_',b_namex])];
         Inputs = [Inputs; sym(b_namex)];
         b_name = [b_name; sym(b_namex)];
      elseif strcmp(b_typex, 'CAs')
         % It is a controlled A-source
         if ~(n_tokens == 5 || n_tokens == 6)
            error(['Lgraph2sys: Invalid element specification in ',...
               'linear graph:\n    (%s)\n- a controlled-source elements',...
               ' list must contain 5 or 6 items.'],g_element);
         end
         b_namex = check_name(token{4});
         params  = [params; sym(b_namex)];
         control_exp = check_name(raw_token{5});
         % Strip the name from the control expression definition
         equals = strfind(control_exp,'=');
         if ~isempty(equals)
            control_exp = control_exp(equals(1)+1:length(control_exp));
         end
         n_controlled_source = n_controlled_source + 1;
         % Create an A-type source as a temporaray "alias" for the
         % controlled source.   Generate a system, and then modify
         % the matrices
         b_name1         = b_namex;
         b_type(length(b_type)) = sym('As');
         b_typex        = 'As';
         Tvars     = [Tvars; sym(['xx_',b_namex])];
         if n_tokens == 6
            b_namex = token{6};
         else
            b_namex = ['V',b_namex];
         end
         Avars     = [Avars; b_namex];
         b_name    = [b_name; b_namex];
         outstring      = [outstring, ',', b_namex,'=',b_name1,...
            '*(',control_exp, ')'];
         control_input  = [control_input;  sym(b_namex)];
         control_output = [control_output; sym(b_namex)];
      elseif strcmp(b_typex, 'CTs')
         % It is a controlled T-source
         if ~(n_tokens == 5 || n_tokens == 6)
            error(['Lgraph2sys: Invalid element specification in ',...
               'linear graph:\n    (%s)\n- a controlled-source element',...
               ' list must contain 5 or 6 items.'],g_element);
         end
         b_namex = check_name(token{4});
         params  = [params; sym(b_namex)];
         control_exp = check_name(raw_token{5});
         % Strip the name from the control expression definition
         equals = strfind(control_exp,'=');
         if ~isempty(equals)
            control_exp = control_exp(equals(1)+1:length(control_exp));
         end
         n_controlled_source = n_controlled_source + 1;
         % Create an T-type source as a temporaray "alias" for the
         % controlled source.   Generate a system, and then modify
         % the matrices
         b_name1         = b_namex;
         b_typex        = 'Ts';
         b_type(length(b_type)) = sym('Ts');
         Avars     = [Avars; sym(['xx_',b_namex])];
         if n_tokens == 6
            b_namex = token{6};
         else
            b_namex = ['F',b_namex];
         end
         Tvars     = [Tvars; b_namex];
         b_name    = [b_name; b_namex];
         outstring = [outstring, ',', b_namex,'=',b_name1,...
            '*(',control_exp, ')'];
         control_input  = [control_input;  sym(b_namex)];
         control_output = [control_output; sym(b_namex)];
      else
         % It is a passive one-port element
         if ~(n_tokens == 4 || n_tokens == 6)
            error(['Lgraph2sys: Invalid element specification in linear ',...
               'graph:\n    (%s)\n- a passive-element list must contain',...
               ' 4 or 6 items.'],g_element);
         end
         params = [params; sym(b_namex)];
         b_name = [b_name; sym(b_namex)];
         if n_tokens == 4
            aname = check_name([avar_prefix,b_namex]);
            tname = check_name([tvar_prefix,b_namex]);
            Avars = [Avars; sym(aname)];
            Tvars = [Tvars; sym(tname)];
         elseif n_tokens == 6
            name = check_name(token{5});
            Avars  = [Avars; sym(name)];
            name = check_name(token{6});
            Tvars  = [Tvars; sym(name)];
         end
      end
      if b_signx == -1
         b_coeff = [b_coeff; 1/sym(b_namex)];
      else
         b_coeff = [b_coeff; sym(b_namex)];
      end
   else
      % Check for a two-port
      [b_typex,b_signx,~,~] = find_branch_type(token{5});
      if strcmp(b_typex, 'TF')
         n_tf = n_tf +1;
         x = ['tf', int2str(n_tf)];
         varname = ['_tf',int2str(n_tf)];
      elseif strcmp(b_typex, 'GY')
         n_gy = n_gy +1;
         x = ['gy', int2str(n_gy)];
         varname = ['_gy',int2str(n_gy)];
      else
         error([' Lgraph2sys: Invalid element specification:\n',...
            '    (%s)\n - unknown element type'],g_element)
      end
      if isnan(str2double(token(1))) || isnan(str2double(token(2))) ||...
            isnan(str2double(token(3))) || isnan(str2double(token(4)))
         error(['Lgraph2sys: Invalid element in linear graph:\n',...
            '    (%s)\nnodes (elements 1,2,3 & 4) must be numeric'],g_element);
      end
      if ~(n_tokens == 6 || n_tokens == 10)
         error(['Lgraph2sys: Invalid element specification in linear ',...
            'graph:\n    (%s)\na passive element must have 4 or 6 ',...
            'items.'],g_element);
      end
      coeffname = check_name(token{6});
      if b_signx == -1
         b_coeffx = 1/sym(coeffname);
      else
         b_coeffx = sym(coeffname);
      end
      params = update_params(params, coeffname);
      % Add the "a" side branch
      b_tail = [b_tail; eval(token{1})];
      b_head = [b_head; eval(token{2})];
      b_type = [b_type; sym(b_typex)];
      b_name = [b_name; sym([x,'a'])];
      b_coeff = [b_coeff; b_coeffx];
      if n_tokens == 6
         y = ['v', varname, 'a'];
         Avars = [Avars; sym(y)];
         y = ['f', varname, 'a'];
         Tvars = [Tvars; sym(y)];
      elseif n_tokens == 10
         name = check_name(token{7});
         Avars =   [Avars; sym(name)];
         name = check_name(token{8});
         Tvars =   [Tvars; sym(name)];
      end
      % Add the "b" side branch
      b_tail = [b_tail; eval(token{3})];
      b_head = [b_head; eval(token{4})];
      b_type =  [b_type; sym(b_typex)];
      b_name = [b_name; sym([x,'b'])];
      if n_tokens == 6
         b_coeff = [b_coeff; b_coeffx];
         y = ['v', varname, 'b'];
         Avars = [Avars; sym(y)];
         y = ['f', varname, 'b'];
         Tvars = [Tvars; sym(y)];
      elseif n_tokens ==10
         b_coeff = [b_coeff; b_coeffx];
         name = check_name(token{9});
         Avars = [Avars; sym(name)];
         name = check_name(token{10});
         Tvars = [Tvars; sym(name)];
      end
   end
end
% Check for duplicate names
for i = 1:length(b_name)-1
   for j = i+1:length(b_name)
      if (b_name(i) == b_name(j)) ||...
            (Avars(i) == Avars(j)) ||...
            (Tvars(i) == Tvars(j))
         error('Duplicate names found in graph specification')
      end
   end
end
% Return values as a structure
gout.b_tail  = b_tail;
gout.b_head  = b_head;
gout.b_type  = b_type;
gout.b_name  = b_name;
gout.b_coeff = b_coeff;
gout.params  = params;
gout.Avars   = Avars;
gout.Tvars   = Tvars;
gout.Inputs  = [Inputs; control_input];
%
sys = struct2sys(gout,outstring,valstring);
% If there are controlled-sources, modify the system matrices
% Note: The controlled output will be the last in the output list because
% it was added to the end of the outstring.
if n_controlled_source > 0
   for i = 1:n_controlled_source
      input=length(sys.Inputs);
      output=length(sys.Outputs);
      B1   = sys.B(:,1:input-1);
      B2   = sys.B(:,input);
%      E1   = sys.E(:,1:input-1);
%      E2   = sys.E(:,input);
      C1   = sys.C(1:output-1,:);
      C2   = sys.C(output,:);
      D11  = sys.D(1:output-1,1:input-1);
      D12  = sys.D(1:output-1,input);
      D21  = sys.D(output,1:input-1);
      D22  = sys.D(output,input);
      sys.A = simplify(sys.A + B2*C2/(1-D22));
      sys.B = simplify(B1+B2*D21/(1-D22));
%      sys.E = simplify(E1+E2*D21/(1-D22));
      sys.C = simplify(C1 + D12*C2/(1-D22));
      sys.D = simplify(D11 + D12*D21);
      sys.Inputs(input) = [];
      sys.Outputs(output) = [];
   end
end
end
%--------------------------------------------------------------------------
% Allow two-ports to specify the parameter as a ratio or product
function newparams = update_params(params, new_param)
% Add all names to the parameter list...
new_param = strrep(new_param,'','');
new_param = strrep(new_param,'*',';');
new_param = strrep(new_param,'/',';');
[t,r] = strtok(new_param,';');
newparams = [params; sym(t)];
while ~isempty(r)
   [t,r] = strtok(r(2:length(r)),';');
   newparams = [newparams; sym(t)];
end
end
