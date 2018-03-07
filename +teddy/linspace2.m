function y = linspace2(x0, dx, N )
%LINSPACE2 Returns N equally spaced values
%   Similar to the builtin linspace except the spacing and the number of
%   values is known while the final value is implicit
%   
%   Example: 
%   linspace2(0,0.1,5) Returns: [0 0.1 0.2 0.3 0.4]
    
    y=linspace(x0, x0+(N-1)*dx, N);
end

