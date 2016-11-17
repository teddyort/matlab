function [] = pz3d( sys )
%Creates a 3d pole-zero plot which displays the magnitude in the zaxis
pts=[pole(sys);zero(sys)];
X1=min(real(pts))-1;
X2=max(real(pts))+1;
Y1=0;
Y2=max(imag(pts))*10;
if X1>=0;X1=0; end
if X2<=0;X2=0; end
if Y2<=0;Y2=10; end
n=50;
[X, Y]=meshgrid(X1:(X2-X1)/n:X2,Y1:(Y2-Y1)/n:Y2);
Z=zeros(size(X));

for ind=1:numel(X)
       Z(ind)=(abs(evalfr(sys,X(ind)+Y(ind)*1i)));
end
surf(X,Y,Z);
camorbit(45,0);
%set(gca,'YScale', 'log')
xlabel('Real Axis');
ylabel('Imaginary Axis');
zlabel('Mag(dB)');
zlimits=zlim();
zlim([0 zlimits(2)]);
rotate3d();
end

