function plotx( A, varargin )
%Plots the matrix A with the assumption that the first column is a vector x
%and the other columsn are vectors y.
plot(A(:,1),A(:,2:end), varargin{:});
end

