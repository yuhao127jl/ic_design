%%------------------------------------------------------------------------
% ������GPS������ճ���
% ��  �񣺶�ȡGPS������Ƶ�źŽ��в�����ٶ�λ����
% ʱ  �䣺2017-07-17
%%------------------------------------------------------------------------
clc;clear all;close all;
%% *****************************************************
% �����������
%***************************************************************
% fid = fopen('gps_data.txt','rb');   
% fs = 39e6;    % ��Ƶ���� 
% fc = 4.092e6; % ��ƵƵ��
% svnum = 12;   % �������Ǻţ��Ѳ��Կɲ������Ǻ�Ϊ2,5,12,15,26,29   ---gps_data.txt��Ƶ����

fid = fopen('GPSdata-DiscreteComponents-fs38_192-if9_55.bin','rb');
fs = 38.192e6;    % ��Ƶ���� 
fc = 9.548e6; % ��ƵƵ��
% svnum = 3;   % �������Ǻţ��Ѳ��Կɲ������Ǻ�Ϊ3,9,15,18,21,22,26   ---GPSdata-DiscreteComponents-fs38_192-if9_55.bin��Ƶ����
svnum_all = 32;

%% *****************************************************
% GPS�źŵĲ���
%***************************************************************
freq_step = 400;% Ƶ����������
freq_num = 31;  % Ƶ����������
for k=1:svnum_all
    [Num_Acq(k,1),fc_dopplor(k,1),phase_CA(k,1)] = GPS_Acquisition(fid,fc,fs,k,freq_num,freq_step);      
end
SV_Num = find(Num_Acq==1);
fc_dopplor_Acq = fc_dopplor(SV_Num,1);
phase_CA_Acq = phase_CA(SV_Num,1);
Num_Acq = size(SV_Num,1);
fprintf('\nGPS�źŵĲ�������\n');
fprintf('\n*=========*=====*===============*===========*=============*========*\n');
fprintf(  '| Channel | PRN |   Frequency   |  Doppler  | Code Offset | Status |\n');
fprintf(  '*=========*=====*===============*===========*=============*========*\n');
for channelNr = 1 : Num_Acq    
    fprintf('|   %2d    | %3d |  %2.5e |   %5.0f   |    %6d   |     %1s   |\n', ...
        channelNr, ...
        SV_Num(channelNr), ...
        fc_dopplor_Acq(channelNr), ...
        fc_dopplor_Acq(channelNr) - fc, ...
        phase_CA_Acq(channelNr), ...
        'Y');    
end
fprintf('*=========*=====*===============*===========*=============*========*\n\n');

%% *****************************************************
% GPS�źŵĸ���
%***************************************************************
track_time = 37000;  % GPS����ʱ�����ã�Ϊ�˺����ĵ������Ľ���������ĸ���ʱ����Ҫ>=36000ms
% �ж��Ƿ񲶻���������λ
firstSubFrame = zeros(1,Num_Acq);
absoluteSample = zeros(Num_Acq,track_time);
fprintf(['\n','���ڸ��ٴ���GPS����,�����ĵȴ���']);
for m=1:Num_Acq       
    Track(m).PRN = SV_Num(m);      
    fprintf(['\n','���ڸ��ٵ�',int2str(SV_Num(m)),'����......']);
    Track(m).Ip = [];
    Track(m).Qp = [];       
%     [Track(m).Ip,Track(m).Qp,absoluteSample(m,:),firstSubFrame(1,m)] = GPS_Tracking(fid,SV_Num(m),fs,track_time,fc_dopplor_Acq(m,:),phase_CA_Acq(m,:));
    [Track(m).Ip,Track(m).Qp,absoluteSample(m,:),firstSubFrame(1,m),Track(m).Cnt_bit,Track(m).Cnt_CAcode,Track(m).Phi_CA] = GPS_Tracking(fid,SV_Num(m),fs,track_time,fc_dopplor_Acq(m,:),phase_CA_Acq(m,:));    
end

%% *****************************************************
% λͬ��,֡ͬ������żУ�飨ע�����ڷ�����ٻ�·���ˣ���
%***************************************************************
% [Track,firstSubFrame,SV_PRN] = BitFrame_SyncParity(Track,track_time);

%% *****************************************************
% ����GPS�������ģ���ȡ����������
%***************************************************************
% load('trackingResults.mat');% �����õ�����
% Num_Acq = size(trackResults,2);
% track_time = 37000;
% for k=1:Num_Acq
%     Track(k).Ip = trackResults(k).I_P;
%     Track(k).PRN = trackResults(k).PRN;
%     absoluteSample(k,:) = trackResults(k).absoluteSample;
% end
% 
% % ���ٺ��λͬ������֡ͬ������żУ�����
% [Track,firstSubFrame,SV_PRN] = BitFrame_SyncParity(Track,track_time);

% ����GPS�������ģ���ȡ����������    
[ephemeris,activeChn,TOW] = Ephemeris_Analytic(Track,SV_Num,firstSubFrame,track_time);

%% *****************************************************
% ��ȡGPS�۲�����α��۲���
%***************************************************************
readyChnList = activeChn;
transmitTime = TOW;
navSolPeriod = 500;% ÿ��500ms����һ��α��۲���
for m=1:fix((track_time-max(firstSubFrame))/navSolPeriod)
    msOfTheSignal = firstSubFrame + navSolPeriod*(m-1);
    Pseudoranges(m,:) = PseudorangesCalc(Track, msOfTheSignal, activeChn, absoluteSample);   
end



