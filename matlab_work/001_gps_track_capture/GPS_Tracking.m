function [Ip,Qp,absoluteSample,firstSubFrame,Cnt_bit,Cnt_CAcode,Phi_CA] = GPS_Tracking(fid,svnum,fs,track_time,fc_dopplor,phase_CA)
%                          GPS接收机跟踪函数定义
% 输入输出定义：
%   函数输入变量：fid为GPS数字中频数据文件句柄，fs为采样频率，svnum为跟踪的卫星号
%                号，track_time为跟踪时间，fc为中心频率，fc_dopplor为捕获后的中
%                心频率，phase_CA为捕获后的码相位
%   函数输出变量：Ip为跟踪后的实部数据，Qp为跟踪后的虚部数据
%                
% global Cnt_bit; 
% global Cnt_CAcode;
% global Phi_CA;
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 参数设置
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rate_CA = 1.023e6;            % GPS L1频点CA码速率
Num = 0.001*fs;        % 1ms的中频信号采样数
    
FLL_tmp = 0;  % FLL更新存储值
PLL_tmp1 = 0;  % PLL更新存储值
Ip = [];   %相关后的I路信号
Qp = [];   %相关后的Q路信号

Code_Phase = phase_CA;% 捕获到的码相位
Freq_JiZhun = fc_dopplor;% 跟踪环路的频率参考
Wmid = 2*pi*Freq_JiZhun;% 跟踪环路的频率对应的角速度：W=2*pi*f
Phase_shift = 0;%每次偏移频率值
Shift_Chip = floor(floor(fs/rate_CA)/2);  % 间隔半个码片
Chip_Inc = 1;% 码片自加1

%----------- 载波环PLL环路滤波器 ------------%
% PLL的环路滤波器参数---参考了谢钢的《GPS原理与接收机设计》
damp_PLL = 0.707;  % 阻尼系数
Bandwidth_PLL = 20;% 噪声带宽
DetaT = 0.001; % 一次积分的时间0.001s
Gain = 0.0009;% 
Wt = 8*Bandwidth_PLL/(damp_PLL^2+1) *DetaT;% 自然频率
C1 = (1/Gain) * (8*damp_PLL*Wt)/(4+4*damp_PLL*Wt+Wt^2);
C2 = (1/Gain) * (4*Wt^2)/(4+4*damp_PLL*Wt+Wt^2);

% %----------- 载波环FLL二阶环路滤波器 ------------%
% FLL的二阶环路滤波器参数
Ip_Fll = 0;
Qp_Fll = 0;
% damp_FLL = 0.707;      % 阻尼系数
% Bandwidth_FLL = 100;;% 噪声带宽
% a2 = 1.414;
% Wn = 2*Bandwidth_FLL/(damp_FLL+1/(4*damp_FLL));% 特征频率或自然频率
% Gain_FLL = 0.05;% 
% A1 = Gain_FLL * Wn^2 * DetaT;
% A2 = Gain_FLL * a2 * Wn;
% Dd_FLL_freq = 0;% 每ms的FLL产生的差异值

% 产生超前、即时、滞后CA码
CAcode_P = Interp_Decre(CAcodegen(svnum,1023),fs);% 即时CA码
CAcode_E = [CAcode_P(Num-Shift_Chip+1:Num),CAcode_P(1:Num-Shift_Chip)];
CAcode_L = [CAcode_P(Shift_Chip+1:Num),CAcode_P(1:Shift_Chip)];
CAcode_PEL = [CAcode_E;CAcode_P;CAcode_L]; 

fseek(fid,Code_Phase,-1);% 从文本开始的Code_Phase相位开始读取数据，如果操作成功则返回0值，否则返回-1
hwaitbar = waitbar(0,'正在跟踪......');
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GPS跟踪环路
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for Loop = 1:track_time    
    waitbar(Loop/track_time,hwaitbar,['跟踪第',int2str(svnum),'颗星:']);
    % 载波NCO
    carrier_exp = exp(j*(Wmid*(0:Num-1)/fs + Phase_shift));
    
    % 读取GPS中频数据
%     [gpsdata,signalsize]=fread(fid,[1,Num],'bit8');% 对应着gps_data.txt中频数据
    [gpsdata,signalsize]=fread(fid,[1,Num],'int8');% 对应着GPSdata-DiscreteComponents-fs38_192-if9_55.bin中频数据
    if(signalsize~=Num)
        break;
    end
    
    % 去载波
    gpsdata_I = gpsdata.*imag(carrier_exp); 
    gpsdata_Q = gpsdata.*real(carrier_exp);
    
    % 积分清除
    for i=1:3
        I(i) = sum(gpsdata_I.*CAcode_PEL(i,:));
        Q(i) = sum(gpsdata_Q.*CAcode_PEL(i,:));
    end
    Ip(Loop) = I(2);% 存储即时的I、Q值
    Qp(Loop) = Q(2);
    if(Loop==1)  % 存储即时的积分清除值
        Ip_Fll = I(2);
        Qp_Fll = Q(2);
    end
    
    % 码环鉴相器
    E = I(1)^2 + Q(1)^2;     
    L = I(3)^2 + Q(3)^2;
    CD_result(Loop) = (E-L) / (E+L);
    
    % 载波环PLL鉴相
    PLL_PD_result(Loop) = atan(Q(2)/I(2)); 
       
    % 载波环FLL鉴相
    cross = (Ip_Fll*Q(2) - Qp_Fll*I(2));% 叉积
    dot = (Ip_Fll*I(2) + Qp_Fll*Q(2));  % 点积
    factor = sqrt(I(2)^2 + Q(2)^2) * sqrt(Ip_Fll^2 + Qp_Fll^2);
    FLL_PD_result(Loop) = sign(dot)*cross/factor;  % 鉴频器
        
    % 载波环PLL更新
    PLL_tmp1 = PLL_tmp1 + C2*PLL_PD_result(Loop);  
    PLL_Phase = PLL_tmp1 + (C1+C2)*PLL_PD_result(Loop);
    Carrior_Phase(Loop) = PLL_PD_result(Loop);
    Dp_PLL_Phase(Loop) = PLL_Phase/(2*pi);
    
    % 载波环FLL更新
    FLL_tmp = FLL_tmp + C2*FLL_PD_result(Loop);
    FLL_Phase = FLL_tmp + (C1+C2)*FLL_PD_result(Loop);
    % 采用FLL更新频率
    Dopplor_FLL_freq(Loop) = FLL_Phase/(2*pi);
    
    % 采用二阶FLL和二阶PLL更新频率
    Wmid = Wmid + FLL_Phase + PLL_Phase;
    
    % 每1ms载波NCO的相位就进行累加
    Phase_shift = Phase_shift + Wmid*Num/fs;
    
    Phase_shift_Loop(Loop) = Phase_shift;
    Dp_FreqLoop(Loop) = FLL_PD_result(Loop);% 多普勒频率变化值
    Wmid_all(Loop) = Wmid/(2*pi); % 此为锁定的频率
    
    if(Loop<10)    
        CD_result_sum(Loop) = sum(CD_result(1:Loop))/Loop;
        PLL_PD_result_2(Loop) = PLL_PD_result(Loop)/2;
        FLL_PD_result_2(Loop) = FLL_PD_result(Loop)/2;
    else   % 码环，载波环的PLL和FLL更新
        CD_result_sum(Loop) = CD_result_sum(Loop-1)*(1-0.01) + CD_result(Loop)*0.01;% 码环更新
        PLL_PD_result_2(Loop) = PLL_PD_result_2(Loop-1)*(1-0.01) + PLL_PD_result(Loop)*0.01;
        FLL_PD_result_2(Loop) = FLL_PD_result_2(Loop-1)*(1-0.01) + FLL_PD_result(Loop)*0.01;% PLL更新
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
    absoluteSample(Loop) = ftell(fid);  % 记录样本头的位置
    Ip_Fll = I(2);
    Qp_Fll = Q(2);
end
close(hwaitbar);
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 跟踪后的位同步、子帧同步和奇偶校验过程
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 子帧的同步字节
preamble_bits = [1 -1 -1 -1 1 -1 1 1];% 同步字节
preamble_ms = kron(preamble_bits, ones(1, 20));% 以ms为单位，从而能够同步到比特位

Ip_bits = Ip;
% 阈值输出并将其转换为-1和+1
Ip_bits(Ip_bits > 0)  =  1;
Ip_bits(Ip_bits <= 0) = -1;

% 与同步字节做相关
XcorrResult = xcorr(Ip_bits, preamble_ms);
xcorrLength = (length(XcorrResult) +  1) /2;

% 找到子帧同步的开始地方，精确到比特位
clear index
clear index_frame
index = find(abs(XcorrResult(xcorrLength : xcorrLength * 2 - 1)) > 153)';

for i = 1:size(index)
    index_frame = index - index(i);
    if (~isempty(find( index_frame == 6000 )))
        %--------------- 重新读取前导位的值进行验证 ----------------%
        % 通过校验第一个子帧的前两个字来验证导航电文的正确性。现在假定已知
        % 点的边界，这里需要读取62ms的比特：
        % 1. 子帧前的2个比特用于奇偶校验；
        % 2. 子帧中的前2个字（遥测字-TLW和交接字-HOW，总共60ms）；
        bits = Ip(1,index(i)-40:index(i)+20*60-1)';
        % 计算每个位的20个值
        bits = reshape(bits, 20, (size(bits, 1) / 20));
        bits = sum(bits);
        % 阈值输出并将其转换为- 1和+ 1
        bits(bits > 0)  =  1;
        bits(bits <= 0) = -1;
        % 奇偶校验
        if(navPartyCheck(bits(1:32)) ~=0 && navPartyCheck(bits(31:62)) ~=0)
            firstSubFrame = index(i);  % 存储子帧头的位置
            break;
        end
    end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 比特计数器和伪码周期计数器
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Len = length(Ip) - firstSubFrame + 1;
Cnt_b = 1;Cnt_CA = 0;
Cnt_CAcode = zeros(1,length(Ip));% CA码周期计数器：每个比特包含20个CA码周期，即从1~20
Cnt_bit = zeros(1,length(Ip));% 比特计数器：每个子帧包含300个数据比特，即从1~300
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
% 跟踪相应的图形
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;
plot(Ip,'-b');
hold on;title(['第',num2str(svnum),'号星跟踪即时相关峰']);
plot(Qp,'-r');

% figure;
% plot(Dopplor_FLL_freq);
% title(['GPS跟踪得到的多普勒频率/Hz']);grid on;

% figure;
% plot(Wmid_all-middle_freq);
% title(['GPS跟踪得到的多普勒频率/Hz']);grid on;

% figure;
% plot(PLL_PD_result_2);
% title(['GPS跟踪锁定的频率/Hz']);grid on;

% figure;
% plot(Code_Phase_all-phase_CA);
% title(['GPS跟踪后的码偏移量']);grid on;

% figure;
% plot(CD_result);
% title(['伪码鉴相器的结果']);grid on;

