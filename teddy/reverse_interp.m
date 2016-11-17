function [ xx ] = reverse_interp( x, y, yy )
%Does a reverse interpolation.
% Tries to find the xx values corresponding to the yy values given a
% function values y at x.
xx = fnzeros(spline(x,y-yy));
end

