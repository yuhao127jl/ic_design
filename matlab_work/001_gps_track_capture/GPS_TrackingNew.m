function [TrackResults] = GPS_TrackingNew(fid,SV_Num,samplingFreq,track_time,fc_dopplor,phase_CA)
%                          GPS接收机跟踪函数定义
% 输入输出定义：
%   函数输入变量：fid为GPS数字中频数据文件句柄，fs为采样频率，svnum为跟踪的卫星号
%                号，track_time为跟踪时间，fc_dopplor为捕获后的中心频率，phase_CA
%                为捕获后的码相位
%   函数输出变量：TrackResults为跟踪后的输出值，包含参数有

codeLength = 1023;
codeFreqBasis = 1.023e6;
earlyLateSpc = 0.5;  % 半个码片
Interval = 0.001;   % 积分清零-求和间隔为1ms
% 记录C/A码开始采样的位置:
TrackResults.absoluteSample = zeros(1, track_time);
% C/A码的频率:
TrackResults.codeFreq = inf(1, track_time);
% 跟踪载波的频率:
TrackResults.carrFreq = inf(1, track_time);
% I路的相关值输出:
TrackResults.I_P = zeros(1, track_time);
TrackResults.I_E = zeros(1, track_time);
TrackResults.I_L = zeros(1, track_time);
% Q路的相关值输出
TrackResults.Q_E = zeros(1, track_time);
TrackResults.Q_P = zeros(1, track_time);
TrackResults.Q_L = zeros(1, track_time);
% 环路鉴别器：
TrackResults.dllDiscr = inf(1, track_time);
TrackResults.dllDiscrFilt = inf(1, track_time);
TrackResults.pllDiscr = inf(1, track_time);
TrackResults.pllDiscrFilt = inf(1, track_time);
TrackResults = repmat(TrackResults, 1, length(SV_Num));  %所有卫星的跟踪结果

% PLL滤波器相关参数
PLL_LBW = 25;
PLL_zata = 0.7;
Wp = PLL_LBW*8*PLL_zata / (4*PLL_zata.^2 + 1);
% 解出t1 & t2（滤波器系数）
tau1carr = 0.25 / (Wp * Wp);
tau2carr = 2.0 * PLL_zata / Wp;

% DLL滤波器相关参数
DLL_LBW = 2;
DLL_zata = 0.7;
Wd = DLL_LBW*8*DLL_zata / (4*DLL_zata.^2 + 1);
% 解出t1 & t2（滤波器系数）
tau1code = 1.0 / (Wd * Wd);
tau2code = 2.0 * DLL_zata / Wd;

hwaitbar = waitbar(0,'正在跟踪......');
for chn=1:length(SV_Num)
    fprintf(['\n','正在跟踪第',int2str(SV_Num(chn)),'颗星......']);
    TrackResults(chn).PRN = SV_Num(chn,1);
    fseek(fid,phase_CA(chn,1)-1,'bof');
    % 产生C/A码
    caCode = CAcodegen(SV_Num(chn),1023);
    caCode = [caCode(1023) caCode caCode(1)];
    
    codeFreq = 1.023e6;
    remCodePhase = 0.0;
    carrFreq = fc_dopplor(chn,1);
    carrFreqBasis = fc_dopplor(chn,1);
    remCarrPhase = 0.0;   
    oldCodeNco = 0.0;
    oldCodeError = 0.0;    
    oldCarrNco = 0.0;
    oldCarrError = 0.0;
    
    for loop=1:track_time
        waitbar(loop/track_time,hwaitbar,['跟踪第',int2str(SV_Num(chn,1)),'颗星:']);
        codePhaseStep = codeFreq / samplingFreq;
        blksize = ceil((codeLength-remCodePhase) / codePhaseStep);
        [rawSignal, samplesRead] = fread(fid,blksize,'int8');
        rawSignal = rawSignal';
        if (samplesRead ~= blksize)
            disp('在跟踪处理过程无法读取准确的采样数，退出!')
            fclose(fid);
            return
        end
        %*******************************
        % 码环跟踪过程
        % 超前码
        tcode = (remCodePhase-earlyLateSpc) : codePhaseStep : ((blksize-1)*codePhaseStep+remCodePhase-earlyLateSpc);
        tcode2 = ceil(tcode) + 1;
        earlyCode = caCode(tcode2);        
        % 滞后码
        tcode = (remCodePhase+earlyLateSpc) : codePhaseStep : ((blksize-1)*codePhaseStep+remCodePhase+earlyLateSpc);
        tcode2 = ceil(tcode) + 1;
        lateCode = caCode(tcode2);        
        % 即时码
        tcode = remCodePhase : codePhaseStep : ((blksize-1)*codePhaseStep+remCodePhase);
        tcode2 = ceil(tcode) + 1;
        promptCode = caCode(tcode2);
        
        remCodePhase = (tcode(blksize) + codePhaseStep) - 1023.0;        
        time = (0:blksize) ./ samplingFreq; 
        
        %*******************************
        % 产生sin/cos载波进行去载波
        trigarg = ((carrFreq * 2.0 * pi) .* time) + remCarrPhase;
        remCarrPhase = rem(trigarg(blksize+1), (2 * pi));       
        carrCos = cos(trigarg(1:blksize));
        carrSin = sin(trigarg(1:blksize));
        % 去载波，下变频到基带
        qBasebandSignal = carrCos .* rawSignal;
        iBasebandSignal = carrSin .* rawSignal;
        
        %*******************************
        % 积分清零（计算超前、即时、滞后的积分累加值）
        I_E = sum(earlyCode  .* iBasebandSignal);
        Q_E = sum(earlyCode  .* qBasebandSignal);
        I_P = sum(promptCode .* iBasebandSignal);
        Q_P = sum(promptCode .* qBasebandSignal);
        I_L = sum(lateCode   .* iBasebandSignal);
        Q_L = sum(lateCode   .* qBasebandSignal);
        
        %********************************
        % 载波环鉴相器 (相位检测)
        carrError = atan(Q_P / I_P) / (2.0 * pi);
        
        %*******************************
        % 载波环滤波器
        carrNco = oldCarrNco + (tau2carr/tau1carr) * (carrError - oldCarrError) + carrError * (Interval/tau1carr);
        oldCarrNco   = carrNco;
        oldCarrError = carrError;        
        % 基于NCO更正载波频率
        carrFreq = carrFreqBasis + carrNco;
        TrackResults(chn).carrFreq(loop) = carrFreq; 
        
        %********************************
        % 码环鉴相器 (相位检测)
        codeError = (sqrt(I_E * I_E + Q_E * Q_E) - sqrt(I_L * I_L + Q_L * Q_L)) / (sqrt(I_E * I_E + Q_E * Q_E) + sqrt(I_L * I_L + Q_L * Q_L));
        
        %*******************************
        % 码环滤波器
        codeNco = oldCodeNco + (tau2code/tau1code) * (codeError - oldCodeError) + codeError * (Interval/tau1code);
        oldCodeNco   = codeNco;
        oldCodeError = codeError;        
        % 基于NCO更正码相位
        codeFreq = codeFreqBasis - codeNco;       
        TrackResults(chn).codeFreq(loop) = codeFreq;
        
        %******************************
        % 保存跟踪环路的相关参数
        TrackResults(chn).absoluteSample(loop) = ftell(fid);
        
        TrackResults(chn).dllDiscr(loop)       = codeError;
        TrackResults(chn).dllDiscrFilt(loop)   = codeNco;
        TrackResults(chn).pllDiscr(loop)       = carrError;
        TrackResults(chn).pllDiscrFilt(loop)   = carrNco;
        
        TrackResults(chn).I_E(loop) = I_E;
        TrackResults(chn).I_P(loop) = I_P;
        TrackResults(chn).I_L(loop) = I_L;
        TrackResults(chn).Q_E(loop) = Q_E;
        TrackResults(chn).Q_P(loop) = Q_P;
        TrackResults(chn).Q_L(loop) = Q_L;                
    end   % for loop   
end
close(hwaitbar);
    