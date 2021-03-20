function [Num_Acq,fc_dopplor,phase_CA] = GPS_Acquisition(fid,fc,fs,svnum,freq_num,freq_step)
% GPS接收机捕获函数定义（基于FFT捕获结构）
% 输入输出定义：
%   函数输入变量：fid为GPS数字中频数据文件句柄，fc为中心频率，fs为采样频率，svnum
%                为需捕获的卫星号，freq_num为搜索次数，freq_step为搜索步长
%   函数输出变量：Num_Acq为用于捕获的ms数，fc_dopplor为捕获后的中心频率，phase_CA
%                为捕获后的码相位
Num_Acq = 0; % 捕获的ms数

Num = 0.001*fs;  % 1ms对应的采样数
ts = 1/fs;
rate_ca = 1.023e6;% GPS L1频点CA码速率
bit_width = 2;    % 正弦波采样位宽
THR = 5;          % 捕获门限（5倍)
Acq_val = zeros(freq_num,Num);
Acq_NoneCoh = zeros(freq_num,Num);
Acq_Coh = zeros(freq_num,Num);

% [gpsdata,signalsize]=fread(fid,[1,Num],'bit8');% 对应着gps_data.txt中频数据
[gpsdata,signalsize]=fread(fid,[1,Num],'int8');% 对应着GPSdata-DiscreteComponents-fs38_192-if9_55.bin中频数据
CAcode = CAcodegen(svnum,1023);  % 产生CA码
CA_39MHz = Interp_Decre(CAcode,fs);% 插值过程：采样率从1.023MHz--->39MHz

%********************************************
% GPS信号的捕获
%********************************************
for k=1:freq_num
    freq = fc + (k-floor(freq_num/2)) * freq_step;
    carrier = exp(j*2*pi*(0:Num-1)*freq/fs);   % 生成本地正交载波NCO
    cosx = quant_bit(real(carrier),bit_width);
    sinx = quant_bit(imag(carrier),bit_width);
    
    gps_Iq = gpsdata.*cosx;
    gps_Qq = gpsdata.*sinx;
    
    % 基于FFT的捕获过程
    gpsdata_DDC = (gps_Iq + j*gps_Qq) / 2^bit_width;
    gps_fft = fft(gpsdata_DDC) / 2^bit_width;
    local_CA = fft(CA_39MHz) / 2^bit_width; 
    Mult_CA2Gps = local_CA .* conj(gps_fft);
    Acq_val(k,:) = ifft(Mult_CA2Gps) / 2^(bit_width+1);
end

Acq_NoneCoh = abs(Acq_val);
Acq_Coh = abs(Acq_NoneCoh);
[amp crw] = max(max(abs(Acq_Coh')));% 输出幅值最大和多普勒偏移值
[amp crn] = max(max(abs(Acq_Coh)));% 输出幅值最大和CA码相位

% 门限判决
Fu_level = mean(mean(Acq_NoneCoh));
if(amp/Fu_level>THR)
    fc_dopplor = fc + freq_step*(crw-floor(freq_num/2));
    phase_CA = Num - crn;
else
    fc_dopplor = 0;
    phase_CA = 0;
end

% 画出三维搜索图
if(amp/Fu_level>THR)
    Num_Acq = 1;
    figure;
    s = surf(abs(Acq_val));
    set(s,'EdgeColor','none','Facecolor','interp');
    title(['GPS捕获第',num2str(svnum),'号星']);
    xlabel('码相位');ylabel('多普勒频偏(Hz)');zlabel('检测值');
end

end

