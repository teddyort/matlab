function txt = rlocus_updatefcn(empty,event_obj)
%

% rlocus_updatefcn - Internal SymSys function
%                    SymSys RootLocus() plot tool-tip update function
%                    to customize the text of the data tip when clicked
%                    on the root locus.
%
%    This is an internal SymSys function an is not a user called
%    function.
%
%  Author:          Derek Rowell (drowell@mit.edu)
%  Revision date:  11/12/2010
%
global data param_name poles
pos = get(event_obj,'Position');
% Search through the data looking for a pole that matches the cursor
% position
val = 0;
for i= 1:length(poles(:,1))
   for j = 1:length(poles(1,:))
      if real(poles(i,j)) == pos(1) && imag(poles(i,j)) == pos(2)
         val = data(j);
         wn = sqrt(real(poles(i,j))^2 + imag(poles(i,j))^2);
         zeta = - real(poles(i,j))/wn;
         break
      end
   end
end
%
if pos(2) < 0
   pole_string = ['Pole: ', num2str(pos(1)),' - i',...
      num2str(abs(pos(2)))];
   txt = {[param_name,':  ',num2str(val)],...
      pole_string,...
      ['wn:   ', num2str(wn)],...
      ['zeta: ', num2str(zeta)]};
elseif pos(2)==0
   pole_string = ['Pole:   ', num2str(pos(1))];
   txt = {[param_name,':  ',num2str(val)],
      pole_string};
else
   pole_string = ['Pole: ', num2str(pos(1)),' + i',num2str(pos(2))];
   txt = {[ param_name,':  ',num2str(val)],...
      pole_string,...
      ['wn:   ', num2str(wn)],...
      ['zeta: ', num2str(zeta)]};
end

