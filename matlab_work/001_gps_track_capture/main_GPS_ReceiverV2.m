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
fprintf(['\n','正在跟踪处理GPS数据,请耐心等待：']);
TrackResults = GPS_TrackingNew(fid,SV_Num,fs,track_time,fc_dopplor_Acq,phase_CA_Acq);

%% *****************************************************
% 位同步,帧同步和奇偶校验
%***************************************************************
% 判断是否捕获到卫星码相位
firstSubFrame = zeros(1,Num_Acq);
firstSubFrame = BitFrame_SyncParity(TrackResults,track_time);









