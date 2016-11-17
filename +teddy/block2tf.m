function [ T ] = block2tf( blockName )
%Converts a simulink block diagram to a simplified transfer function
mysys=linmod(blockName);
Tss=ss(mysys.a,mysys.b,mysys.c,mysys.d);
[n,d]=tfdata(Tss,'v');
T=tf(n,d);
end

