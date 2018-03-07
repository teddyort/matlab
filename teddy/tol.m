function [ A ] = tol( A, t )
% For any values in A where real or imaginary part is less than t, that
% part is set to zero.
R = real(A);
I = imag(A);
R(R<t)=0;
I(I<t)=0;
A=R+I*1i;
end

