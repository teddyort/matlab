function [ s ] = mat2lyx( A )
% Formats the matrix A into a string capable of being pasted into a lyx
% matrix.
ajoin = @(f,v,glue) strjoin(arrayfun(f, v,'uniformoutput',0),glue);
s=ajoin(@(r) ajoin(@(x) num2str(x),A(r,:),'\\\'), 1:size(A,1),'&');
end

