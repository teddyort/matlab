function [b_class,b_sign,b_a_prefix,b_t_prefix] = find_branch_type(b_spec)
%

%find_branch_type - SymSys internal function
%         Generate standardized branch (element) specifications.
%
% Note:   This is not a user called function.
%
% Call:   [b_class,b_sign,b_a_prefix,b_t_prefix] = find_branch_type(b_spec)
%                   b_spec     - (string) user specified branch type
%                   b_class    - (string) standardized element type.
%                   b_sign     - specifies how the element coefficient is
%                               used.
%                   b_a_prefix - (string) Default across variable prefix.
%                   b_t_prefix - (string) Default through variable prefix.
%
%Author:        Derek Rowell (drowell@mit.edu)
%Revision Date: July 10, 2010
%--------------------------------------------------------------------------
%
found = 0;
names ={ 'voltag', 'As',  '1', 'v', 'f';
   'veloci', 'As',  '1', 'v', 'f';
   'angvel', 'As',  '1', 'v', 'f';
   'angula', 'As',  '1', 'v', 'f';
   'pressu', 'As',  '1', 'v', 'f';
   'temper', 'As',  '1', 'v', 'f';
   'as',     'As',  '1', 'v', 'f';
   'veloci', 'As',  '1', 'v', 'f';
   'curren', 'Ts',  '1', 'v', 'f';
   'force',  'Ts',  '1', 'v', 'f';
   'torque', 'Ts',  '1', 'v', 'f';
   'flow',   'Ts',  '1', 'v', 'f';
   'flowra', 'Ts',  '1', 'v', 'f';
   'volflo', 'Ts',  '1', 'v', 'f';
   'heatfl', 'Ts',  '1', 'v', 'f';
   'ts',     'Ts',  '1', 'v', 'f';
   'heat',   'Ts',  '1', 'v', 'f';
   'a',       'A', '-1', 'v', 'f';
   't',       'T', '-1', 'v', 'f';
   'd',       'D', '-1', 'v', 'f';
   'c',       'A', '-1', 'v', 'i';
   'capaci',  'A', '-1', 'v', 'i';
   'l',       'T', '-1', 'v', 'i';
   'induct',  'T', '-1', 'v', 'i';
   'resist',  'D', '-1', 'v', 'i';
   'conduc',  'D',  '1', 'v', 'i';
   'r',       'D', '-1', 'v', 'i';
   'g',       'D',  '1', 'v', 'i';
   'resist',  'D', '-1', 'v', 'i';
   'conduc',  'D',  '1', 'v', 'i';
   'mass',    'A', '-1', 'v', 'F';
   'compli',  'T', '-1', 'v', 'F';
   'spring',  'T',  '1', 'v', 'F';
   'damper',  'D',  '1', 'v', 'F';
   'dashpo',  'D',  '1', 'v', 'F';
   'inerti',  'A', '-1', 'W', 'T';
   'i',       'A', '-1', 'W', 'T';
   'j',       'A', '-1', 'W', 'T';
   'rotK',    'T',  '1', 'W', 'T';
   'Krot',    'T',  '1', 'W', 'T';
   'rotspr',  'T',  '1', 'W', 'T';
   'torspr',  'T',  '1', 'W', 'T';
   'rotdas',  'D',  '1', 'W', 'T';
   'rotdam',  'D',  '1', 'W', 'T';
   'drot',    'D',  '1', 'W', 'T';
   'fluidc',  'A', '-1', 'p', 'Q';
   'cf',      'A', '-1', 'p', 'Q';
   'if',      'T', '-1', 'p', 'Q';
   'rf',      'D', '-1', 'p', 'Q';
   'fluidr',  'D', '-1', 'p', 'Q';
   'inerta',  'T', '-1', 'p', 'Q';
   'thermc',  'A', '-1', 'T', 'q';
   'thermr',  'D', '-1', 'T', 'q';
   'transf',  'TF', '1', 'v', 'f';
   'motor',   'TF', '-1', 'v', 'f';
   'genera',  'TF', '1', 'v', 'f';
   'tf',      'TF', '1', 'v', 'f';
   'gyrato',  'GY', '1', 'v', 'f';
   'gy',      'GY', '1', 'v', 'f';
   'cvs',     'CAs','1', 'v', 'f';
   'cvolta',  'CAs','1', 'v', 'f';
   'cveloc',  'CAs','1', 'v', 'F';
   'cpress',  'CAs','1', 'p', 'Q';
   'cps',     'CAs','1', 'p', 'Q';
   'cangve',  'CAs','1', 'W', 'T';
   'cws',     'CAs','1', 'W', 'T';      
   'cfs',     'CTs','1',  'v', 'f'};
%
b_spec1 = lower(b_spec);
if length(b_spec1) > 6
   b_spec1 = b_spec1(1:6);
end
[nrows,~] = size(names);
for j=1:nrows
   if strcmp(b_spec1, names{j,1})
      found      = 1;
      b_class    = names{j,2};
      b_sign     = eval(names{j,3});
      b_a_prefix = names{j,4};
      b_t_prefix = names{j,5};
      break
   end
end
if ~found
      b_class    = '';
      b_sign     = '';
      b_a_prefix = '';
      b_t_prefix = '';
end
end