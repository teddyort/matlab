function [ out ] = round( in, unit)
%Rounds the elements of 'in' to the nearest unit specified by 'unit'
%Example1: teddy_round([2.8 3 3.5], 2) = [2 4 4]
%Example2: teddy_round([1.2 1.6 1.9],1/2) = [1 1.5 2]

    up = ceil(in ./ unit) .* unit - in;
    down = floor(in ./ unit) .* unit-in;
    out = min(up+1i, down+1i)+in-1i;
end

