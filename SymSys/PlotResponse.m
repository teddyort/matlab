function PlotResponse(tin,fn,varargin)
%PlotResponse - Plot a symbolic system response (time-domain) function.
%
% Call:      PlotResponse(t,function)
%               t        - a vector of time samples
%               function - a symbolic expression (in t)..
%
%            PlotResponse(t,function,plotoptions)
%               plotoptions - (string) as string of plot options
%                   to be passed to the MATLAB plot() function.
%
% Example:   y = StepResponse(mysys)
%            t = 0:.005:1;
%            Plotresp(t,y,'r')
%                - plots the step response in red.

% Author:        Derek Rowell (drowell@mit.edu)
% Revision Date: Nov 30, 2010
%--------------------------------------------------------------------------
%
fn_str = char(fn);
dirac_flag = false;
if ~isempty(findstr(fn_str,'dirac'))
   dirac_flag = true;
   loc1 = findstr(fn_str,'dirac(t');
   if ~isempty(loc1)
      msg = '';
      for i = 1:length(loc1)
         loc = findstr(fn_str,'dirac(t');
         last = findstr(fn_str(loc(1):length(fn_str)),')');
         msg{i} =fn_str(loc(1):loc(1)+last(1)-1);
         fn_str = [fn_str(1:loc(1)-1),'0',fn_str(loc(1)+last(1):length(fn_str))];
      end
      fn = sym(fn_str);
   end
end
% Use point by point evaluation to avoid problems
% of matrix multiplication implied by the '*' in symbolic
% expressions.
%y = zeros(1,length(tin));
%for i = 1:length(tin)
%   t=tin(i);
%   y(i) = eval(fn);
%end
t = tin;
y = eval(fn);
%
if nargin == 2
   plot(tin,y);
elseif nargin > 2
   plot(tin, y, varargin{:})
end
% Plot annotations:
% Set y-axis minimum to zero
v =axis;
if v(3) > 0
   v(3) = 0;
   axis(v);
end
% If the plot contains Dirac delta functions or its derivatives, annotate 
% it with a vertical line at the time of the impulse, and label with a
%  "dirac'(t)" notation - the "'" indicates order of the derivative.
if dirac_flag
   for i = 1:length(msg)
      leftparen = strfind(msg{i},'(');
      comma = strfind(msg{i},',');
      if isempty(comma)
         deriv_msg = '';
         t_exp = msg{i}(leftparen+1:strfind(msg{i},')')-1);
      else
         t_exp = msg{i}(leftparen+1:comma-1);
         deriv = eval(msg{i}(comma(1)+1:strfind(msg{i},')')-1));
         if deriv > 0
            for j = 1:deriv
               deriv_msg = [deriv_msg,''''];
            end
         end
      end
      t_dirac = eval(solve(t_exp));
      line([t_dirac t_dirac],[v(3) v(4)],'linewidth',4);
      text_msg = ['dirac',deriv_msg,'(',t_exp,')'];
      text_msg = strrep(text_msg,' ','');
      text(t_dirac + 0.01*(v(2)-v(1)),...
           (v(3)+v(4))/2+(i-1)*.05*(v(4)-v(3)), text_msg)
   end
end
xlabel('Time (s)')
ylabel('Response')
end
