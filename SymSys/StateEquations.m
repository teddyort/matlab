function StateEquations(sys)
%StateEquations - Display the state and output equations of a SymSys object
%                 in "LaTeX" formatted form.
%
%Call:            StateEquations(sys)
%                    where sys is a SymSys object,           

% Author:    Morteza Ganji
% Modified:  Derek Rowell
% Revision Date: March, 14, 2011
%--------------------------------------------------------------------------
%
Sstring=['d/dt',latex(sys.StateVars),'=',latex(sys.A),latex(sys.StateVars),'+'];
Sstring=[Sstring,latex(sys.B),latex(sys.Inputs),];
deriv_flag = 0;
[nrows,ncols] = size(sys.E);
for i= 1:nrows
   for j = 1:ncols
      if ~(sys.E(i,j) == sym(0))
         deriv_flag = 1;
      end
   end
end
if deriv_flag
   Sstring = [Sstring,'+',latex(sys.E),'d/dt('];
   Sstring=[Sstring,latex(sys.Inputs),')'];
end
%
sdisp(Sstring,'State Equations')
%
Ostring=[latex(sys.Outputs),'=',latex(sys.C),latex(sys.StateVars),'+'];
Ostring=[Ostring,latex(sys.D),latex(sys.Inputs)];
%
deriv_flag = 0;
[nrows,ncols] = size(sys.F);
for i= 1:nrows
   for j = 1:ncols
      if ~(sys.F(i,j) == sym(0))
         deriv_flag = 1;
      end
   end
end
if deriv_flag
  Ostring = [Ostring,'+',latex(sys.F),'d/dt('];
  Ostring = [Ostring,latex(sys.Inputs),')'];
end
%
sdisp(Ostring,'Output Equations')
%
end


function sdisp(xx, title)
% Original function: "sexy.m" written by Naor Movshovitz
% http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=11150&objectType=file
if  length(xx)>1300
    error('Size of Array too large for current latex version');
end
S = ['$',xx,'$'];
%S=strrep(S,'&','& \quad');
S=strrep(S,'{\it','\mathrm{');
S=strrep(S,'\left(','\left[');
S=strrep(S,'\right)','\right]');
h=msgbox(S,title);
set(h,'resize','on')
h1=get(h,'children');
h2=h1(1);
h3=get(h2,'children');
if isempty(h3)
    h2=h1(2); h3=get(h2,'children');
end
set(h3,'visible','off')
set(h3,'interpreter','latex')
set(h3,'string',S)
set(h3,'fontsize',12)
w=get(h3,'extent');
W=get(h,'position');
W(3)=max(w(3)+10,125);
W(4)=w(4)+40;
set(h,'position',W)
h4=h1(2);
if ~strcmp(get(h4,'tag'),'OKButton'), h4=h1(1); end
o=get(h4,'position');
o(1)=(W(3)-o(3))/2;
set(h4,'position',o)
set(h3,'visible','on')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%