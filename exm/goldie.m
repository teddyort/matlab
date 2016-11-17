function p = goldie
%GOLDIE  What does this function do?

%   Copyright 2014 Cleve Moler
%   Copyright 2014 The MathWorks, Inc.
p = 0
A = [1 1; 1 0]
x = [1 1]'
while p ~= x(1)/x(2)
   p = x(1)/x(2)
   x = A*x
end
