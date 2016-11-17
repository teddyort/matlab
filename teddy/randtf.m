function [ G ] = randtf(zmax,pmax)
%Random Transfer Function Generator: Generates a random transfer function.
%with between 0 and zmax zeros, and between zero and pmax poles
imax=10;

Ni=randi([0 floor(zmax/2)])*2;
k=randi(imax);
z=randi([-imax 0],1,randi([0 zmax-Ni]));
zr=randi([-imax 0],1,Ni/2);
zi=randi([-imax 0],1,Ni/2)*1i;
z=[z zr+zi zr-zi];

Ni=randi([0 floor(pmax/2)])*2;
p=randi([-imax 0],1,randi([0 pmax-Ni]));
pr=randi([-imax 0],1,Ni/2);
pi=randi([-imax 0],1,Ni/2)*1i;
p=[p pr+pi pr-pi];

if length(z) < length(p)
    G=zpk(z,p,k);
else
    G=zpk(p,z,k);
end

end
