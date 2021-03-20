function [Ip,Qp,absoluteSample,firstSubFrame,Cnt_bit,Cnt_CAcode,Phi_CA] = GPS_Tracking(fid,svnum,fs,track_time,fc_dopplor,phase_CA)
%                          GPS���ջ����ٺ�������
% ����������壺
%   �������������fidΪGPS������Ƶ�����ļ������fsΪ����Ƶ�ʣ�svnumΪ���ٵ����Ǻ�
%                �ţ�track_timeΪ����ʱ�䣬fcΪ����Ƶ�ʣ�fc_dopplorΪ��������
%                ��Ƶ�ʣ�phase_CAΪ����������λ
%   �������������IpΪ���ٺ��ʵ�����ݣ�QpΪ���ٺ���鲿����
%                
% global Cnt_bit; 
% global Cnt_CAcode;
% global Phi_CA;
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ��������
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rate_CA = 1.023e6;            % GPS L1Ƶ��CA������
Num = 0.001*fs;        % 1ms����Ƶ�źŲ�����
    
FLL_tmp = 0;  % FLL���´洢ֵ
PLL_tmp1 = 0;  % PLL���´洢ֵ
Ip = [];   %��غ��I·�ź�
Qp = [];   %��غ��Q·�ź�

Code_Phase = phase_CA;% ���񵽵�����λ
Freq_JiZhun = fc_dopplor;% ���ٻ�·��Ƶ�ʲο�
Wmid = 2*pi*Freq_JiZhun;% ���ٻ�·��Ƶ�ʶ�Ӧ�Ľ��ٶȣ�W=2*pi*f
Phase_shift = 0;%ÿ��ƫ��Ƶ��ֵ
Shift_Chip = floor(floor(fs/rate_CA)/2);  % ��������Ƭ
Chip_Inc = 1;% ��Ƭ�Լ�1

%----------- �ز���PLL��·�˲��� ------------%
% PLL�Ļ�·�˲�������---�ο���л�ֵġ�GPSԭ������ջ���ơ�
damp_PLL = 0.707;  % ����ϵ��
Bandwidth_PLL = 20;% ��������
DetaT = 0.001; % һ�λ��ֵ�ʱ��0.001s
Gain = 0.0009;% 
Wt = 8*Bandwidth_PLL/(damp_PLL^2+1) *DetaT;% ��ȻƵ��
C1 = (1/Gain) * (8*damp_PLL*Wt)/(4+4*damp_PLL*Wt+Wt^2);
C2 = (1/Gain) * (4*Wt^2)/(4+4*damp_PLL*Wt+Wt^2);

% %----------- �ز���FLL���׻�·�˲��� ------------%
% FLL�Ķ��׻�·�˲�������
Ip_Fll = 0;
Qp_Fll = 0;
% damp_FLL = 0.707;      % ����ϵ��
% Bandwidth_FLL = 100;;% ��������
% a2 = 1.414;
% Wn = 2*Bandwidth_FLL/(damp_FLL+1/(4*damp_FLL));% ����Ƶ�ʻ���ȻƵ��
% Gain_FLL = 0.05;% 
% A1 = Gain_FLL * Wn^2 * DetaT;
% A2 = Gain_FLL * a2 * Wn;
% Dd_FLL_freq = 0;% ÿms��FLL�����Ĳ���ֵ

% ������ǰ����ʱ���ͺ�CA��
CAcode_P = Interp_Decre(CAcodegen(svnum,1023),fs);% ��ʱCA��
CAcode_E = [CAcode_P(Num-Shift_Chip+1:Num),CAcode_P(1:Num-Shift_Chip)];
CAcode_L = [CAcode_P(Shift_Chip+1:Num),CAcode_P(1:Shift_Chip)];
CAcode_PEL = [CAcode_E;CAcode_P;CAcode_L]; 

fseek(fid,Code_Phase,-1);% ���ı���ʼ��Code_Phase��λ��ʼ��ȡ���ݣ���������ɹ��򷵻�0ֵ�����򷵻�-1
hwaitbar = waitbar(0,'���ڸ���......');
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GPS���ٻ�·
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for Loop = 1:track_time    
    waitbar(Loop/track_time,hwaitbar,['���ٵ�',int2str(svnum),'����:']);
    % �ز�NCO
    carrier_exp = exp(j*(Wmid*(0:Num-1)/fs + Phase_shift));
    
    % ��ȡGPS��Ƶ����
%     [gpsdata,signalsize]=fread(fid,[1,Num],'bit8');% ��Ӧ��gps_data.txt��Ƶ����
    [gpsdata,signalsize]=fread(fid,[1,Num],'int8');% ��Ӧ��GPSdata-DiscreteComponents-fs38_192-if9_55.bin��Ƶ����
    if(signalsize~=Num)
        break;
    end
    
    % ȥ�ز�
    gpsdata_I = gpsdata.*imag(carrier_exp); 
    gpsdata_Q = gpsdata.*real(carrier_exp);
    
    % �������
    for i=1:3
        I(i) = sum(gpsdata_I.*CAcode_PEL(i,:));
        Q(i) = sum(gpsdata_Q.*CAcode_PEL(i,:));
    end
    Ip(Loop) = I(2);% �洢��ʱ��I��Qֵ
    Qp(Loop) = Q(2);
    if(Loop==1)  % �洢��ʱ�Ļ������ֵ
        Ip_Fll = I(2);
        Qp_Fll = Q(2);
    end
    
    % �뻷������
    E = I(1)^2 + Q(1)^2;     
    L = I(3)^2 + Q(3)^2;
    CD_result(Loop) = (E-L) / (E+L);
    
    % �ز���PLL����
    PLL_PD_result(Loop) = atan(Q(2)/I(2)); 
       
    % �ز���FLL����
    cross = (Ip_Fll*Q(2) - Qp_Fll*I(2));% ���
    dot = (Ip_Fll*I(2) + Qp_Fll*Q(2));  % ���
    factor = sqrt(I(2)^2 + Q(2)^2) * sqrt(Ip_Fll^2 + Qp_Fll^2);
    FLL_PD_result(Loop) = sign(dot)*cross/factor;  % ��Ƶ��
        
    % �ز���PLL����
    PLL_tmp1 = PLL_tmp1 + C2*PLL_PD_result(Loop);  
    PLL_Phase = PLL_tmp1 + (C1+C2)*PLL_PD_result(Loop);
    Carrior_Phase(Loop) = PLL_PD_result(Loop);
    Dp_PLL_Phase(Loop) = PLL_Phase/(2*pi);
    
    % �ز���FLL����
    FLL_tmp = FLL_tmp + C2*FLL_PD_result(Loop);
    FLL_Phase = FLL_tmp + (C1+C2)*FLL_PD_result(Loop);
    % ����FLL����Ƶ��
    Dopplor_FLL_freq(Loop) = FLL_Phase/(2*pi);
    
    % ���ö���FLL�Ͷ���PLL����Ƶ��
    Wmid = Wmid + FLL_Phase + PLL_Phase;
    
    % ÿ1ms�ز�NCO����λ�ͽ����ۼ�
    Phase_shift = Phase_shift + Wmid*Num/fs;
    
    Phase_shift_Loop(Loop) = Phase_shift;
    Dp_FreqLoop(Loop) = FLL_PD_result(Loop);% ������Ƶ�ʱ仯ֵ
    Wmid_all(Loop) = Wmid/(2*pi); % ��Ϊ������Ƶ��
    
    if(Loop<10)    
        CD_result_sum(Loop) = sum(CD_result(1:Loop))/Loop;
        PLL_PD_result_2(Loop) = PLL_PD_result(Loop)/2;
        FLL_PD_result_2(Loop) = FLL_PD_result(Loop)/2;
    else   % �뻷���ز�����PLL��FLL����
        CD_result_sum(Loop) = CD_result_sum(Loop-1)*(1-0.01) + CD_result(Loop)*0.01;% �뻷����
        PLL_PD_result_2(Loop) = PLL_PD_result_2(Loop-1)*(1-0.01) + PLL_PD_result(Loop)*0.01;
        FLL_PD_result_2(Loop) = FLL_PD_result_2(Loop-1)*(1-0.01) + FLL_PD_result(Loop)*0.01;% PLL����
    end
    
    if(mod(Loop,10)==1)
        if(CD_result_sum(Loop)<0)
            Code_Phase = Code_Phase + Chip_Inc;
            CAcode_P = [CAcode_P(2:end),CAcode_P(1)];
            CAcode_E = [CAcode_E(2:end),CAcode_E(1)];
            CAcode_L = [CAcode_L(2:end),CAcode_L(1)];
            CAcode_PEL = [CAcode_E;CAcode_P;CAcode_L];
        elseif(CD_result_sum(Loop)>0)
            Code_Phase = Code_Phase - Chip_Inc;
            CAcode_P = [CAcode_P(end),CAcode_P(1:end-1)];
            CAcode_E = [CAcode_E(end),CAcode_E(1:end-1)];
            CAcode_L = [CAcode_L(end),CAcode_L(1:end-1)];
            CAcode_PEL = [CAcode_E;CAcode_P;CAcode_L];
        end
    end
    Code_Phase_all(Loop) = Code_Phase;
    absoluteSample(Loop) = ftell(fid);  % ��¼����ͷ��λ��
    Ip_Fll = I(2);
    Qp_Fll = Q(2);
end
close(hwaitbar);
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ���ٺ��λͬ������֡ͬ������żУ�����
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ��֡��ͬ���ֽ�
preamble_bits = [1 -1 -1 -1 1 -1 1 1];% ͬ���ֽ�
preamble_ms = kron(preamble_bits, ones(1, 20));% ��msΪ��λ���Ӷ��ܹ�ͬ��������λ

Ip_bits = Ip;
% ��ֵ���������ת��Ϊ-1��+1
Ip_bits(Ip_bits > 0)  =  1;
Ip_bits(Ip_bits <= 0) = -1;

% ��ͬ���ֽ������
XcorrResult = xcorr(Ip_bits, preamble_ms);
xcorrLength = (length(XcorrResult) +  1) /2;

% �ҵ���֡ͬ���Ŀ�ʼ�ط�����ȷ������λ
clear index
clear index_frame
index = find(abs(XcorrResult(xcorrLength : xcorrLength * 2 - 1)) > 153)';

for i = 1:size(index)
    index_frame = index - index(i);
    if (~isempty(find( index_frame == 6000 )))
        %--------------- ���¶�ȡǰ��λ��ֵ������֤ ----------------%
        % ͨ��У���һ����֡��ǰ����������֤�������ĵ���ȷ�ԡ����ڼٶ���֪
        % ��ı߽磬������Ҫ��ȡ62ms�ı��أ�
        % 1. ��֡ǰ��2������������żУ�飻
        % 2. ��֡�е�ǰ2���֣�ң����-TLW�ͽ�����-HOW���ܹ�60ms����
        bits = Ip(1,index(i)-40:index(i)+20*60-1)';
        % ����ÿ��λ��20��ֵ
        bits = reshape(bits, 20, (size(bits, 1) / 20));
        bits = sum(bits);
        % ��ֵ���������ת��Ϊ- 1��+ 1
        bits(bits > 0)  =  1;
        bits(bits <= 0) = -1;
        % ��żУ��
        if(navPartyCheck(bits(1:32)) ~=0 && navPartyCheck(bits(31:62)) ~=0)
            firstSubFrame = index(i);  % �洢��֡ͷ��λ��
            break;
        end
    end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ���ؼ�������α�����ڼ�����
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Len = length(Ip) - firstSubFrame + 1;
Cnt_b = 1;Cnt_CA = 0;
Cnt_CAcode = zeros(1,length(Ip));% CA�����ڼ�������ÿ�����ذ���20��CA�����ڣ�����1~20
Cnt_bit = zeros(1,length(Ip));% ���ؼ�������ÿ����֡����300�����ݱ��أ�����1~300
for m=1:Len
    if(Cnt_CA==20)
        Cnt_CA = 1;
        if(Cnt_b==300)
            Cnt_b = 1;
        else   
            Cnt_b = Cnt_b + 1;
        end
    else
        Cnt_CA = Cnt_CA + 1;
        Cnt_b = Cnt_b;
    end
    Cnt_CAcode(1,firstSubFrame+m-1) = Cnt_CA;
    Cnt_bit(1,firstSubFrame+m-1) = Cnt_b;
end
Phi_CA = phase_CA;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ������Ӧ��ͼ��
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;
plot(Ip,'-b');
hold on;title(['��',num2str(svnum),'���Ǹ��ټ�ʱ��ط�']);
plot(Qp,'-r');

% figure;
% plot(Dopplor_FLL_freq);
% title(['GPS���ٵõ��Ķ�����Ƶ��/Hz']);grid on;

% figure;
% plot(Wmid_all-middle_freq);
% title(['GPS���ٵõ��Ķ�����Ƶ��/Hz']);grid on;

% figure;
% plot(PLL_PD_result_2);
% title(['GPS����������Ƶ��/Hz']);grid on;

% figure;
% plot(Code_Phase_all-phase_CA);
% title(['GPS���ٺ����ƫ����']);grid on;

% figure;
% plot(CD_result);
% title(['α��������Ľ��']);grid on;

