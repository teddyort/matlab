function [ tf ] = ss2tf(A,B,C,D )
% Convert matrices A,B,C, and D to a transfer function.
% Allows the system mmatrices to be symbolic
% Returns a symbolic transfer function in which the symbol 's' represents
% the laplace transform variable

syms s;
tf=C*(s*eye(size(A))-A)^-1*B+D;
end

