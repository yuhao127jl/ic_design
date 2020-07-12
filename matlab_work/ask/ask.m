
% ------------------------------------------------------------------
% Projet      :                                
% Filename    :    ask.m                     
% Description :                                
%                                              
% Author      :                                     
% Data        :    07/11/2020 
% ------------------------------------------------------------------
clear all; close all;

% --------------------------------
% defination
% --------------------------------
bw = 14;        			% bit width : 14 bit
bit_len = 2000;				% bit length 
Rb = 10^6;					% bit rate : 1Mbps, so 1us per bit
Fs = 80*Rb;					% sample rate : 80M
dat_len = bit_len*Fs/Rb;	% sample number
Fc = 10*10^6;				% carrier freq : 10MHz

% --------------------------------
% gen carrier
% --------------------------------
t = 0 : 1/Fs : bit_len/Rb;
carrier = cos(2*pi*Fc*t);
carrier = carrier(1:dat_len);

% --------------------------------
% gen bit stream
% --------------------------------
bit_stream = randint(1, bit_len, 2);
bit_stream_upsmp = rectpulse(bit_stream, Fs/Rb);

% --------------------------------
% ask mod
% --------------------------------
ask_mod = bit_stream_upsmp .* carrier;

% --------------------------------
% plot spectrum
% --------------------------------
ask_spectrum = 20*log10(abs(fft(ask_mod, 1024)));
ask_spectrum = ask_spectrum - max(ask_spectrum);

figure(1);
x = 0 : 20000;
plot(x,ask_mod(10000:30000));
axis([0 20000 -1.5 1.5]);
xlabel('Time-t(us)');
ylabel('Amplitude(v)');
title('2ASK Time Domain Waveform');
grid on;

figure(2);
x = 0:length(ask_spectrum) - 1;
x = x/length(x)*Fs/10^6;
plot(x, ask_spectrum);
xlabel('Frequency(MHz)');ylabel('Amplitude(dB)');
title('2ASK Spectrum');
grid on;

% --------------------------------
% write into file
% --------------------------------
norm_Data=ask_mod/max(abs(ask_mod));% Normalization
Q_s=round(norm_Data*(2^(bw-1)-1));
fid=fopen('ASK2.txt','w');
for i=1:length(Q_s)
	B_s=dec2bin(Q_s(i)+(Q_s(i)<0)*2^bw,bw);
	for j=1:bw
	   if B_s(j)=='1'
		   tb=1;
	   else
		   tb=0;
	   end
	   fprintf(fid,'%d',tb);  
	end
	fprintf(fid,'\r\n');
end
fprintf(fid,';'); 
fclose(fid);


