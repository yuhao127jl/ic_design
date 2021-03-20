function   firstSubFrame = BitFrame_SyncParity(Track,msToProcess)
%             函数：跟踪后的位同步、子帧同步和奇偶校验过程
% 输 入：
%       Track：跟踪后的卫星号PRN与导航电文比特流数据Ip
%       msToProcess：跟踪处理数据的时间（ms）
% 输 出：
%       firstSubFrame：帧同步，位同步后的子帧头的位置
%       SV_PRN：剔除无用卫星通道后的卫星号

% load('trackingResults.mat');% 测试用的数据

Num_Acq = size(Track,2);
pos = ones(Num_Acq,1);
% 判断导航电文是否有36s的数据（保证能够解析出星历参数），跟踪到的卫星是否满足定位要求
if (msToProcess < 36000) || (Num_Acq < 4)
    disp('采集的中频数据太短 或 能跟踪到的卫星太少无法进行定位. 退出！！！');
%     navSolutions = [];
%     eph          = [];
    return
end

for k=1:Num_Acq
    Ip(k,:) = Track(k).Ip;
    SV_PRN(k,1) = Track(k).PRN;
end

% 子帧的同步字节
preamble_bits = [1 -1 -1 -1 1 -1 1 1];% 同步字节
preamble_ms = kron(preamble_bits, ones(1, 20));% 以ms为单位，从而能够同步到比特位
firstSubFrame = zeros(1,Num_Acq);

for k=1:Num_Acq
    bits = Ip(k,:);
    % 阈值输出并将其转换为-1和+1
    bits(bits > 0)  =  1;
    bits(bits <= 0) = -1;

    % 与同步字节做相关
    XcorrResult = xcorr(bits, preamble_ms);
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
            bits = Ip(k,index(i)-40:index(i)+20*60-1)';
            % 计算每个位的20个值
            bits = reshape(bits, 20, (size(bits, 1) / 20));
            bits = sum(bits);
            % 阈值输出并将其转换为- 1和+ 1
            bits(bits > 0)  =  1;
            bits(bits <= 0) = -1;
            % 奇偶校验
            if(navPartyCheck(bits(1:32)) ~=0 && navPartyCheck(bits(31:62)) ~=0)
                firstSubFrame(1,k) = index(i);
                break;
            end
        end
    end

    if(firstSubFrame==0)
        % 如果没有找到子帧头，则不再找这颗卫星即剔除这颗卫星
        SV_PRN = setdiff(SV_PRN, SV_PRN(k,1));
        pos(k,1) = 0;
        disp(['无法找到通道（卫星）',num2str(SV_PRN(k,1)),'的子帧头!']);        
    end
end

% 剔除找不到子帧头的卫星的导航比特数据
sig = 1;
for k=1:Num_Acq
    if(pos(k,1)==1)
        TrackResults(sig).Ip = Track(k).Ip;
        TrackResults(sig).PRN = Track(k).PRN;
        sig = sig + 1;
    end  
end