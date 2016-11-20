function tight_print( A )
% Prints a matrix of integers with tight spacing
fprintf([repmat(sprintf('%% %dd',max(floor(log10(abs(A(:)))))+2+any(A(:)<0)),1,size(A,2)) '\n'],A');
end

