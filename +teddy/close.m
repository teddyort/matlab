function [ result ] = close( a,b,tol )
%CLOSE Returns true if two values are close to each other within a
%tolerance
%   CLOSE(a,b,tol) True if a is within tolerance tol of b
%   CLOSE(a,b) True if a is withing 1e-10 of b. (default tol=1e-10)
    if nargin < 3
        tol = 1e-10;
    end
    result = abs(a-b) < tol;

end

