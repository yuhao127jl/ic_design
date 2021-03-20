function [Pseudoranges] = PseudorangesCalc(Track, msOfTheSignal, activeChn, absoluteSample)
%             ������λͬ������֡ͬ������żУ�������������ȡ
% �� �룺
%       Track��λͬ������֡ͬ������żУ��ĵ����Ǻ�PRN�뵼�����ı���������Ip
%       firstSubFrame����֡ͷ��ʼ��λ��
%       msToProcess�����ٴ������ݵ�ʱ�䣨ms��
% �� ����
%       ephemeris����ȡ����������
%       TOW��GPS�źŵķ���ʱ��
fs = 38.192e6;    % ��Ƶ���� 
CArate = 1.023e6;  % CA����1.023MHz
CAlen = 1023;    % һ��CA��������CA�����
speed_c = 299792458;    % ����, [m/s]
startOffset = 68.802;   %  ��ʼ���źŴ���ʱ��
travelTime = inf(1, length(activeChn));   % GPS�źŴ���ʱ��

% ���ҵ�ÿ��CA��Ƭ�Ĳ�����
samplesPerCode = round(fs / (CArate / CAlen));

% ����GPS�Ĵ���ʱ��  
for k = 1:length(activeChn)       
    travelTime(k) = absoluteSample(k,msOfTheSignal(k)) / samplesPerCode;
end

%*****************************************
% �ضϴ���ʱ�䲢����α��
minimum = floor(min(travelTime));
travelTime = travelTime - minimum + startOffset;

% ����α��۲���
Pseudoranges = travelTime * (speed_c / 1000);  % ����ʱ������msΪ��λ�ģ���Ҫת��Ϊs

end