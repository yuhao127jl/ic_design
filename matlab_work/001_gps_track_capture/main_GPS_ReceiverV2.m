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
fprintf(['\n','���ڸ��ٴ���GPS����,�����ĵȴ���']);
TrackResults = GPS_TrackingNew(fid,SV_Num,fs,track_time,fc_dopplor_Acq,phase_CA_Acq);

%% *****************************************************
% λͬ��,֡ͬ������żУ��
%***************************************************************
% �ж��Ƿ񲶻���������λ
firstSubFrame = zeros(1,Num_Acq);
firstSubFrame = BitFrame_SyncParity(TrackResults,track_time);









