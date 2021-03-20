function [Pseudoranges] = PseudorangesCalc(Track, msOfTheSignal, activeChn, absoluteSample)
%             函数：位同步、子帧同步和奇偶校后的星历参数提取
% 输 入：
%       Track：位同步、子帧同步和奇偶校后的的卫星号PRN与导航电文比特流数据Ip
%       firstSubFrame：子帧头开始的位置
%       msToProcess：跟踪处理数据的时间（ms）
% 输 出：
%       ephemeris：提取的星历参数
%       TOW：GPS信号的发射时间
fs = 38.192e6;    % 中频采样 
CArate = 1.023e6;  % CA码率1.023MHz
CAlen = 1023;    % 一个CA码周期中CA码个数
speed_c = 299792458;    % 光速, [m/s]
startOffset = 68.802;   %  初始的信号传输时间
travelTime = inf(1, length(activeChn));   % GPS信号传输时间

% 查找到每个CA码片的采样数
samplesPerCode = round(fs / (CArate / CAlen));

% 计算GPS的传输时间  
for k = 1:length(activeChn)       
    travelTime(k) = absoluteSample(k,msOfTheSignal(k)) / samplesPerCode;
end

%*****************************************
% 截断传输时间并计算伪距
minimum = floor(min(travelTime));
travelTime = travelTime - minimum + startOffset;

% 计算伪距观测量
Pseudoranges = travelTime * (speed_c / 1000);  % 传输时间是以ms为单位的，需要转化为s

end