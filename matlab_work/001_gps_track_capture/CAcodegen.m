function CA_Code = CAcodegen(PRN,LEN)
% GPS L1接收机本地伪码产生函数定义
% 输入输出定义：
% 函数输入变量：PRN为卫星号（1～32），LEN为产生伪码长度，1023点为一个完整伪码周
%              期，可设为1023
% 函数输出变量：CACode为长度LEN的伪码序列，双极性（+1,-1)

NUM=10;% 移位寄存器级数
g2s = [5;  6;  7;  8;  17; 18; 139;140;
       141;251;252;254;255;256;257;258;
       469;470;471;472;473;474;509;512;
       513;514;515;516;859;860;861;862];% C/A码延迟，GPS的ICD文件上有相关说明
g2shift = g2s(PRN,1);

%******************* Generate G1 code *********************% 
% load shift register
reg = -1*ones(1,10);
for i = 1:LEN      % 顺序执行,设中间值
    G1(i) = reg(NUM);
    save1 = reg(3)*reg(10);  % G1(x)=1+x^3+x^10
    reg(1,2:10) = reg(1:1:9);
    reg(1) = save1;
end

%*******************  Generate G2 code *********************%
% load shift register
reg = -1*ones(1,10);% 0-->+1(电平),1-->-1(电平)
for i = 1:LEN
    G2(i) = reg(NUM);
    save2 = reg(2)*reg(3)*reg(6)*reg(8)*reg(9)*reg(10);% G2(x)=1+x^2+x^3+x^6+x^8+x^9+x^10
    reg(1,2:10) = reg(1:1:9);
    reg(1) = save2;
end
% Shift G2 code 
G2 = [G2(1,end-g2shift+1:end),G2(1,1:end-g2shift)];%有问题！！！

% Form single sample C/A code by multiplying G1 and G2
CA_Code = -G1.*G2;
