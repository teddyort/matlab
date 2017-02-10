function [ result ] = all_close( a,b,tol )
%ALL_CLOSE returns true if all the values of a are close to the
%corresponding values of b.
%   Values are close if they are within tolerance tol of each other.
%   Default tolerance is 1e-10
%   
%   ALL_CLOSE(a,b,tol) Returns true if all values of a are within tolerance
%   tol of the corresponding values of b.
%
%   ALL_CLOSE(a,b) Returns true if all values of a are within 1e-10 the 
%   corresponding values of b.
    if nargin < 3
        tol = 1e-10;
    end
    result = teddy.all(teddy.close(a,b,tol));

end

