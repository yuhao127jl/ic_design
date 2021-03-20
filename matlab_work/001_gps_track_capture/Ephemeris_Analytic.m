function   [ephemeris,activeChnList,TOW] = Ephemeris_Analytic(Track,SV_PRN,firstSubFrame,msToProcess)
%             函数：位同步、子帧同步和奇偶校后的星历参数提取
% 输 入：
%       Track：位同步、子帧同步和奇偶校后的的卫星号PRN与导航电文比特流数据Ip
%       firstSubFrame：子帧头开始的位置
%       msToProcess：跟踪处理数据的时间（ms）
% 输 出：
%       ephemeris：提取的星历参数
%       TOW：GPS信号的发射时间

% load('trackingResults.mat');% 测试用的数据
% msToProcess = 37000;
Num_Acq = size(Track,2);
activeChnList = SV_PRN;
gpsPi = 3.1415926535898;  % pi的定义
TiChu_PRN = [];
% for k=1:Num_Acq
%     Track(k).Ip = trackResults(k).I_P;
%     Track(k).PRN = trackResults(k).PRN;
% end

% 跟踪后的位同步、子帧同步和奇偶校验过程
% [firstSubFrame,SV_PRN] = BitFrame_SyncParity(Track,msToProcess);

% 判断导航电文是否有36s的数据（保证能够解析出星历参数），跟踪到的卫星是否满足定位要求
if (msToProcess < 36000) || (Num_Acq < 4)
    disp('采集的中频数据太短 或 能跟踪到的卫星太少无法进行定位. 退出！！！');
    ephemeris = [];
    TOW = [];
    return
end

for k=1:Num_Acq
    % 从子帧头开始读取5个子帧数据（一帧）
    NavBits = Track(k).Ip(firstSubFrame(k) - 20 : firstSubFrame(k) + (1500 * 20) -1)';
    NavBits = reshape(NavBits, 20, (size(NavBits, 1) / 20));
    navBits_Best = sum(NavBits);% 累加后得到较好的估计值
    
    % 映射成0/1值，navBits_Best>0--->1;navBits_Best<=0--->0;
    navBits_Best = (navBits_Best > 0);
    navBitsBin = dec2bin(navBits_Best);  %将十进制转化为二进制（字符char类型）
    
    %% 解析导航电文，得到星历参数
    bits = navBitsBin(2:1501)';
    D30Star = navBitsBin(1);   % 上一帧数据的最后一个比特   
    for i = 1:5
        % 将帧数据拆分成5个子帧
        subframe = bits(300*(i-1)+1 : 300*i);

        % 纠正所有10个字的极性
        for j = 1:10
            word = subframe(30*(j-1)+1 : 30*j);  % 子帧中的每一个字
            if D30Star == '1'
                % 数据比特翻转
                data = word(1:24);
                dataLength = length(data);
                temp(1:dataLength) = '1';               
                invertMask = bin2dec(char(temp));                
                word(1:24) = dec2bin(bitxor(bin2dec(data), invertMask), dataLength);  % 对24个数据按位取反
            end
            subframe(30*(j-1)+1 : 30*j) = word;           
            D30Star = subframe(30*j);
        end

        % 读取子帧号
        subframeID = bin2dec(subframe(50:52));

        % 解析各个子帧中的星历参数
        switch subframeID
            case 1  % 第1子帧
                ephemeris(k).weekNumber  = bin2dec(subframe(61:70)) + 1024;
                ephemeris(k).accuracy    = bin2dec(subframe(73:76));
                ephemeris(k).health      = bin2dec(subframe(77:82));
                ephemeris(k).T_GD        = BuMa2Dec(subframe(197:204)) * 2^(-31);
                ephemeris(k).IODC        = bin2dec([subframe(83:84) subframe(211:218)]);
                ephemeris(k).t_oc        = bin2dec(subframe(219:234)) * 2^4;
                ephemeris(k).a_f2        = BuMa2Dec(subframe(241:248)) * 2^(-55);
                ephemeris(k).a_f1        = BuMa2Dec(subframe(249:264)) * 2^(-43);
                ephemeris(k).a_f0        = BuMa2Dec(subframe(271:292)) * 2^(-31);
            case 2  % 第2子帧
                % It contains first part of ephemeris parameters
                ephemeris(k).IODE_sf2    = bin2dec(subframe(61:68));
                ephemeris(k).C_rs        = BuMa2Dec(subframe(69: 84)) * 2^(-5);
                ephemeris(k).deltan      = BuMa2Dec(subframe(91:106)) * 2^(-43) * gpsPi;
                ephemeris(k).M_0         = BuMa2Dec([subframe(107:114) subframe(121:144)]) * 2^(-31) * gpsPi;
                ephemeris(k).C_uc        = BuMa2Dec(subframe(151:166)) * 2^(-29);
                ephemeris(k).e           = bin2dec([subframe(167:174) subframe(181:204)]) * 2^(-33);
                ephemeris(k).C_us        = BuMa2Dec(subframe(211:226)) * 2^(-29);
                ephemeris(k).sqrtA       = bin2dec([subframe(227:234) subframe(241:264)]) * 2^(-19);
                ephemeris(k).t_oe        = bin2dec(subframe(271:286)) * 2^4;
            case 3  % 第3子帧
                ephemeris(k).C_ic        = BuMa2Dec(subframe(61:76)) * 2^(-29);
                ephemeris(k).omega_0     = BuMa2Dec([subframe(77:84) subframe(91:114)]) * 2^(-31) * gpsPi;
                ephemeris(k).C_is        = BuMa2Dec(subframe(121:136)) * 2^(-29);
                ephemeris(k).i_0         = BuMa2Dec([subframe(137:144) subframe(151:174)]) * 2^(-31) * gpsPi;
                ephemeris(k).C_rc        = BuMa2Dec(subframe(181:196)) * 2^(-5);
                ephemeris(k).omega       = BuMa2Dec([subframe(197:204) subframe(211:234)]) * 2^(-31) * gpsPi;
                ephemeris(k).omegaDot    = BuMa2Dec(subframe(241:264)) * 2^(-43) * gpsPi;
                ephemeris(k).IODE_sf3    = bin2dec(subframe(271:278));
                ephemeris(k).iDot        = BuMa2Dec(subframe(279:292)) * 2^(-43) * gpsPi;
            case 4  % 第4子帧
                % Almanac, ionospheric model, UTC parameters.
                % SV health (PRN: 25-32).
                % Not decoded at the moment.
            case 5  % 第5子帧
                % SV almanac and health (PRN: 1-24).
                % Almanac reference week number and time.
                % Not decoded at the moment.
        end % switch subframeID 
    end % for i = 1:5 
    
    if ( isempty(ephemeris(k).IODC) || isempty(ephemeris(k).IODE_sf2) || isempty(ephemeris(k).IODE_sf3) )
        % 剔除不含IODC或IODE的卫星
        activeChnList = setdiff(SV_PRN, Track(k).PRN);
        TiChu_PRN = [TiChu_PRN; Track(k).PRN];
    end    
    
    % 计算数组中第一个子帧的周内秒：用帧的最后一个子帧对应的周内时减去30s，就是GPS数据发射的时间
    TOW(k) = bin2dec(subframe(31:47)) * 6 - 30;
end

