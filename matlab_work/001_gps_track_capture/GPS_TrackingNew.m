function [TrackResults] = GPS_TrackingNew(fid,SV_Num,samplingFreq,track_time,fc_dopplor,phase_CA)
%                          GPS���ջ����ٺ�������
% ����������壺
%   �������������fidΪGPS������Ƶ�����ļ������fsΪ����Ƶ�ʣ�svnumΪ���ٵ����Ǻ�
%                �ţ�track_timeΪ����ʱ�䣬fc_dopplorΪ����������Ƶ�ʣ�phase_CA
%                Ϊ����������λ
%   �������������TrackResultsΪ���ٺ�����ֵ������������

codeLength = 1023;
codeFreqBasis = 1.023e6;
earlyLateSpc = 0.5;  % �����Ƭ
Interval = 0.001;   % ��������-��ͼ��Ϊ1ms
% ��¼C/A�뿪ʼ������λ��:
TrackResults.absoluteSample = zeros(1, track_time);
% C/A���Ƶ��:
TrackResults.codeFreq = inf(1, track_time);
% �����ز���Ƶ��:
TrackResults.carrFreq = inf(1, track_time);
% I·�����ֵ���:
TrackResults.I_P = zeros(1, track_time);
TrackResults.I_E = zeros(1, track_time);
TrackResults.I_L = zeros(1, track_time);
% Q·�����ֵ���
TrackResults.Q_E = zeros(1, track_time);
TrackResults.Q_P = zeros(1, track_time);
TrackResults.Q_L = zeros(1, track_time);
% ��·��������
TrackResults.dllDiscr = inf(1, track_time);
TrackResults.dllDiscrFilt = inf(1, track_time);
TrackResults.pllDiscr = inf(1, track_time);
TrackResults.pllDiscrFilt = inf(1, track_time);
TrackResults = repmat(TrackResults, 1, length(SV_Num));  %�������ǵĸ��ٽ��

% PLL�˲�����ز���
PLL_LBW = 25;
PLL_zata = 0.7;
Wp = PLL_LBW*8*PLL_zata / (4*PLL_zata.^2 + 1);
% ���t1 & t2���˲���ϵ����
tau1carr = 0.25 / (Wp * Wp);
tau2carr = 2.0 * PLL_zata / Wp;

% DLL�˲�����ز���
DLL_LBW = 2;
DLL_zata = 0.7;
Wd = DLL_LBW*8*DLL_zata / (4*DLL_zata.^2 + 1);
% ���t1 & t2���˲���ϵ����
tau1code = 1.0 / (Wd * Wd);
tau2code = 2.0 * DLL_zata / Wd;

hwaitbar = waitbar(0,'���ڸ���......');
for chn=1:length(SV_Num)
    fprintf(['\n','���ڸ��ٵ�',int2str(SV_Num(chn)),'����......']);
    TrackResults(chn).PRN = SV_Num(chn,1);
    fseek(fid,phase_CA(chn,1)-1,'bof');
    % ����C/A��
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
        waitbar(loop/track_time,hwaitbar,['���ٵ�',int2str(SV_Num(chn,1)),'����:']);
        codePhaseStep = codeFreq / samplingFreq;
        blksize = ceil((codeLength-remCodePhase) / codePhaseStep);
        [rawSignal, samplesRead] = fread(fid,blksize,'int8');
        rawSignal = rawSignal';
        if (samplesRead ~= blksize)
            disp('�ڸ��ٴ�������޷���ȡ׼ȷ�Ĳ��������˳�!')
            fclose(fid);
            return
        end
        %*******************************
        % �뻷���ٹ���
        % ��ǰ��
        tcode = (remCodePhase-earlyLateSpc) : codePhaseStep : ((blksize-1)*codePhaseStep+remCodePhase-earlyLateSpc);
        tcode2 = ceil(tcode) + 1;
        earlyCode = caCode(tcode2);        
        % �ͺ���
        tcode = (remCodePhase+earlyLateSpc) : codePhaseStep : ((blksize-1)*codePhaseStep+remCodePhase+earlyLateSpc);
        tcode2 = ceil(tcode) + 1;
        lateCode = caCode(tcode2);        
        % ��ʱ��
        tcode = remCodePhase : codePhaseStep : ((blksize-1)*codePhaseStep+remCodePhase);
        tcode2 = ceil(tcode) + 1;
        promptCode = caCode(tcode2);
        
        remCodePhase = (tcode(blksize) + codePhaseStep) - 1023.0;        
        time = (0:blksize) ./ samplingFreq; 
        
        %*******************************
        % ����sin/cos�ز�����ȥ�ز�
        trigarg = ((carrFreq * 2.0 * pi) .* time) + remCarrPhase;
        remCarrPhase = rem(trigarg(blksize+1), (2 * pi));       
        carrCos = cos(trigarg(1:blksize));
        carrSin = sin(trigarg(1:blksize));
        % ȥ�ز����±�Ƶ������
        qBasebandSignal = carrCos .* rawSignal;
        iBasebandSignal = carrSin .* rawSignal;
        
        %*******************************
        % �������㣨���㳬ǰ����ʱ���ͺ�Ļ����ۼ�ֵ��
        I_E = sum(earlyCode  .* iBasebandSignal);
        Q_E = sum(earlyCode  .* qBasebandSignal);
        I_P = sum(promptCode .* iBasebandSignal);
        Q_P = sum(promptCode .* qBasebandSignal);
        I_L = sum(lateCode   .* iBasebandSignal);
        Q_L = sum(lateCode   .* qBasebandSignal);
        
        %********************************
        % �ز��������� (��λ���)
        carrError = atan(Q_P / I_P) / (2.0 * pi);
        
        %*******************************
        % �ز����˲���
        carrNco = oldCarrNco + (tau2carr/tau1carr) * (carrError - oldCarrError) + carrError * (Interval/tau1carr);
        oldCarrNco   = carrNco;
        oldCarrError = carrError;        
        % ����NCO�����ز�Ƶ��
        carrFreq = carrFreqBasis + carrNco;
        TrackResults(chn).carrFreq(loop) = carrFreq; 
        
        %********************************
        % �뻷������ (��λ���)
        codeError = (sqrt(I_E * I_E + Q_E * Q_E) - sqrt(I_L * I_L + Q_L * Q_L)) / (sqrt(I_E * I_E + Q_E * Q_E) + sqrt(I_L * I_L + Q_L * Q_L));
        
        %*******************************
        % �뻷�˲���
        codeNco = oldCodeNco + (tau2code/tau1code) * (codeError - oldCodeError) + codeError * (Interval/tau1code);
        oldCodeNco   = codeNco;
        oldCodeError = codeError;        
        % ����NCO��������λ
        codeFreq = codeFreqBasis - codeNco;       
        TrackResults(chn).codeFreq(loop) = codeFreq;
        
        %******************************
        % ������ٻ�·����ز���
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
    