function [Num_Acq,fc_dopplor,phase_CA] = GPS_Acquisition(fid,fc,fs,svnum,freq_num,freq_step)
% GPS���ջ����������壨����FFT����ṹ��
% ����������壺
%   �������������fidΪGPS������Ƶ�����ļ������fcΪ����Ƶ�ʣ�fsΪ����Ƶ�ʣ�svnum
%                Ϊ�貶������Ǻţ�freq_numΪ����������freq_stepΪ��������
%   �������������Num_AcqΪ���ڲ����ms����fc_dopplorΪ����������Ƶ�ʣ�phase_CA
%                Ϊ����������λ
Num_Acq = 0; % �����ms��

Num = 0.001*fs;  % 1ms��Ӧ�Ĳ�����
ts = 1/fs;
rate_ca = 1.023e6;% GPS L1Ƶ��CA������
bit_width = 2;    % ���Ҳ�����λ��
THR = 5;          % �������ޣ�5��)
Acq_val = zeros(freq_num,Num);
Acq_NoneCoh = zeros(freq_num,Num);
Acq_Coh = zeros(freq_num,Num);

% [gpsdata,signalsize]=fread(fid,[1,Num],'bit8');% ��Ӧ��gps_data.txt��Ƶ����
[gpsdata,signalsize]=fread(fid,[1,Num],'int8');% ��Ӧ��GPSdata-DiscreteComponents-fs38_192-if9_55.bin��Ƶ����
CAcode = CAcodegen(svnum,1023);  % ����CA��
CA_39MHz = Interp_Decre(CAcode,fs);% ��ֵ���̣������ʴ�1.023MHz--->39MHz

%********************************************
% GPS�źŵĲ���
%********************************************
for k=1:freq_num
    freq = fc + (k-floor(freq_num/2)) * freq_step;
    carrier = exp(j*2*pi*(0:Num-1)*freq/fs);   % ���ɱ��������ز�NCO
    cosx = quant_bit(real(carrier),bit_width);
    sinx = quant_bit(imag(carrier),bit_width);
    
    gps_Iq = gpsdata.*cosx;
    gps_Qq = gpsdata.*sinx;
    
    % ����FFT�Ĳ������
    gpsdata_DDC = (gps_Iq + j*gps_Qq) / 2^bit_width;
    gps_fft = fft(gpsdata_DDC) / 2^bit_width;
    local_CA = fft(CA_39MHz) / 2^bit_width; 
    Mult_CA2Gps = local_CA .* conj(gps_fft);
    Acq_val(k,:) = ifft(Mult_CA2Gps) / 2^(bit_width+1);
end

Acq_NoneCoh = abs(Acq_val);
Acq_Coh = abs(Acq_NoneCoh);
[amp crw] = max(max(abs(Acq_Coh')));% �����ֵ���Ͷ�����ƫ��ֵ
[amp crn] = max(max(abs(Acq_Coh)));% �����ֵ����CA����λ

% �����о�
Fu_level = mean(mean(Acq_NoneCoh));
if(amp/Fu_level>THR)
    fc_dopplor = fc + freq_step*(crw-floor(freq_num/2));
    phase_CA = Num - crn;
else
    fc_dopplor = 0;
    phase_CA = 0;
end

% ������ά����ͼ
if(amp/Fu_level>THR)
    Num_Acq = 1;
    figure;
    s = surf(abs(Acq_val));
    set(s,'EdgeColor','none','Facecolor','interp');
    title(['GPS�����',num2str(svnum),'����']);
    xlabel('����λ');ylabel('������Ƶƫ(Hz)');zlabel('���ֵ');
end

end

