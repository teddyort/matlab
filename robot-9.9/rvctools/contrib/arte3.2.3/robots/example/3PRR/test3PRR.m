%-- script for the 3PRR --%

%   Authors: 
%           Rafael L�pez Contreras
%           Francisco Mart�nez Femen�a
%           Santiago Gim�nez Garc�a 
%           Albano L�pez G�mez
%           Guillermo Salinas L�pez
%           Jonatan Lloret Reina
%
%Universidad Miguel Hern�ndez de Elche. 


T=eye(4);

%just try different positions and orientations.
T(1,4)=0.5;
T(2,4)=0.7;
phi=pi/10;
T(1,1)=cos(phi);
T(2,1)=sin(phi);
q = inversekinematic_3PRR(robot, T)


%init_lib
%disp('Introduce el valor de la variables activas d1, d2 y d3');
d1 = q(1,1); %input('Ingrese el valor de d1: ')
d2 = q(3,1);%input('Ingrese el valor de d2: ')
d3 = q(5,1);%input('Ingrese el valor de d3: ')
directa = direct_kinematics_3PRR_numerical(robot,[d1 d2 d3], 0.001)

disp('Se dibujan dos de las soluciones, comprobando que el efector final se encuentra en la misma posici�n y orientaci�n');

%Se realiza un bucle for para dibujar las 8 posibles combinaciones.
for i=1 : 8
    directa = direct_kinematics_3PRR_numerical(robot,[q(1,i) q(3,i) q(5,i)], 0.001)
end
%Se observa en algunas que la soluci�n no converge, por lo que la
%soluci�n no ser� v�lida. Otras son soluciones reales, pero el efector no
%se mantiene en la posici�n/orientaci�n deseada.