%%------------------------------------------------------------------------
% 主程序：GPS软件接收程序
% 任  务：读取GPS数字中频信号进行捕获跟踪定位解算
% 时  间：2017-07-17
%%------------------------------------------------------------------------
clc;clear all;close all;
%% *****************************************************
% 总体参数设置
%***************************************************************
% fid = fopen('gps_data.txt','rb');   
% fs = 39e6;    % 中频采样 
% fc = 4.092e6; % 中频频率
% svnum = 12;   % 捕获到卫星号，已测试可捕获卫星号为2,5,12,15,26,29   ---gps_data.txt中频数据

fid = fopen('GPSdata-DiscreteComponents-fs38_192-if9_55.bin','rb');
fs = 38.192e6;    % 中频采样 
fc = 9.548e6; % 中频频率
% svnum = 3;   % 捕获到卫星号，已测试可捕获卫星号为3,9,15,18,21,22,26   ---GPSdata-DiscreteComponents-fs38_192-if9_55.bin中频数据
svnum_all = 32;

%% *****************************************************
% GPS信号的捕获
%***************************************************************
freq_step = 400;% 频率搜索步长
freq_num = 31;  % 频率搜索次数
for k=1:svnum_all
    [Num_Acq(k,1),fc_dopplor(k,1),phase_CA(k,1)] = GPS_Acquisition(fid,fc,fs,k,freq_num,freq_step);      
end
SV_Num = find(Num_Acq==1);
fc_dopplor_Acq = fc_dopplor(SV_Num,1);
phase_CA_Acq = phase_CA(SV_Num,1);
Num_Acq = size(SV_Num,1);
fprintf('\nGPS信号的捕获结果：\n');
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
% GPS信号的跟踪
%***************************************************************
track_time = 37000;  % GPS跟踪时间设置，为了后续的导航电文解析，这里的跟踪时间需要>=36000ms
% 判断是否捕获到卫星码相位
firstSubFrame = zeros(1,Num_Acq);
absoluteSample = zeros(Num_Acq,track_time);
fprintf(['\n','正在跟踪处理GPS数据,请耐心等待：']);
for m=1:Num_Acq       
    Track(m).PRN = SV_Num(m);      
    fprintf(['\n','正在跟踪第',int2str(SV_Num(m)),'颗星......']);
    Track(m).Ip = [];
    Track(m).Qp = [];       
%     [Track(m).Ip,Track(m).Qp,absoluteSample(m,:),firstSubFrame(1,m)] = GPS_Tracking(fid,SV_Num(m),fs,track_time,fc_dopplor_Acq(m,:),phase_CA_Acq(m,:));
    [Track(m).Ip,Track(m).Qp,absoluteSample(m,:),firstSubFrame(1,m),Track(m).Cnt_bit,Track(m).Cnt_CAcode,Track(m).Phi_CA] = GPS_Tracking(fid,SV_Num(m),fs,track_time,fc_dopplor_Acq(m,:),phase_CA_Acq(m,:));    
end

%% *****************************************************
% 位同步,帧同步和奇偶校验（注：后期放入跟踪环路中了！）
%***************************************************************
% [Track,firstSubFrame,SV_PRN] = BitFrame_SyncParity(Track,track_time);

%% *****************************************************
% 解析GPS导航电文（提取星历参数）
%***************************************************************
% load('trackingResults.mat');% 测试用的数据
% Num_Acq = size(trackResults,2);
% track_time = 37000;
% for k=1:Num_Acq
%     Track(k).Ip = trackResults(k).I_P;
%     Track(k).PRN = trackResults(k).PRN;
%     absoluteSample(k,:) = trackResults(k).absoluteSample;
% end
% 
% % 跟踪后的位同步、子帧同步和奇偶校验过程
% [Track,firstSubFrame,SV_PRN] = BitFrame_SyncParity(Track,track_time);

% 解析GPS导航电文（提取星历参数）    
[ephemeris,activeChn,TOW] = Ephemeris_Analytic(Track,SV_Num,firstSubFrame,track_time);

%% *****************************************************
% 提取GPS观测量：伪距观测量
%***************************************************************
readyChnList = activeChn;
transmitTime = TOW;
navSolPeriod = 500;% 每隔500ms计算一次伪距观测量
for m=1:fix((track_time-max(firstSubFrame))/navSolPeriod)
    msOfTheSignal = firstSubFrame + navSolPeriod*(m-1);
    Pseudoranges(m,:) = PseudorangesCalc(Track, msOfTheSignal, activeChn, absoluteSample);   
end



