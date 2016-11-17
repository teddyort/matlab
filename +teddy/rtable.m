function [ rt ] = rtable( p )
%Generates a routh table given a polynomial

m=length(p);
n=ceil(m/2)+1;
%create the empty routh table
rt = zeros(m,n);
r1=p(1:2:end);
r2=p(2:2:end);
rt(1,1:length(r1)) = p(1:2:end); %Enter the first row
rt(2,1:length(r2)) = p(2:2:end); %Enter the second row

%now fill in the rest of the rows
for i = 3:m
    c1 = rt(i-2:i-1,1);
    for j = 1:n-1
        c2 = rt(i-2:i-1,j+1);
        rt(i,j) = -det([c1 c2])/rt(i-1,1);
    end
end


end

