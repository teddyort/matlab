function [] = bode( w,m,p )
%Make a bode plot from given frequency, gain, and phase data.
subplot(2,1,1);
loglog(w,m,'.','MarkerSize',20);
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on
subplot(2,1,2);
semilogx(w,p,'.','MarkerSize',20);
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on
end

