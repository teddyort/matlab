function [ tfSym ] = tf2sym( Tf )
%Converts a transfer function object to a symbolic version

[num, den]=tfdata(Tf);
syms s;
tfSym=poly2sym(cell2mat(num), s)/poly2sym(cell2mat(den),s);

end

