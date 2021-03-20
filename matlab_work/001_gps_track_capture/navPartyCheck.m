function status = navPartyCheck(nav_dat)
% GPS字的比特校验函数
% 输 入：nav_dat ---GPS导航电文（字）中的32bit数据，包括30bit和上一个字的最后两
%                   个比特（(-2 -1 0 1 2 ... 28 29)）
% 输 出：status ---如果奇偶校验成功则返回-1或+1,否则返回0
%	a	b	xor 			a	b	product
%  --------------          -----------------
%	0	0	 1			   -1  -1	   1
%	0	1	 0			   -1   1	  -1
%	1	0	 0			    1  -1	  -1
%	1	1	 1			    1   1	   1

%--- 检查数据比特是否反转 ---%
if (nav_dat(2) ~= 1)
    nav_dat(3:26)= -1 .* nav_dat(3:26);  % 取反
end

%--- 计算6比特校验位 ---%
parity(1) = nav_dat(1)  * nav_dat(3)  * nav_dat(4)  * nav_dat(5)  * nav_dat(7)  * ...
            nav_dat(8)  * nav_dat(12) * nav_dat(13) * nav_dat(14) * nav_dat(15) * ...
            nav_dat(16) * nav_dat(19) * nav_dat(20) * nav_dat(22) * nav_dat(25);

parity(2) = nav_dat(2)  * nav_dat(4)  * nav_dat(5)  * nav_dat(6)  * nav_dat(8)  * ...
            nav_dat(9)  * nav_dat(13) * nav_dat(14) * nav_dat(15) * nav_dat(16) * ...
            nav_dat(17) * nav_dat(20) * nav_dat(21) * nav_dat(23) * nav_dat(26);

parity(3) = nav_dat(1)  * nav_dat(3)  * nav_dat(5)  * nav_dat(6)  * nav_dat(7)  * ...
            nav_dat(9)  * nav_dat(10) * nav_dat(14) * nav_dat(15) * nav_dat(16) * ...
            nav_dat(17) * nav_dat(18) * nav_dat(21) * nav_dat(22) * nav_dat(24);

parity(4) = nav_dat(2)  * nav_dat(4)  * nav_dat(6)  * nav_dat(7)  * nav_dat(8)  * ...
            nav_dat(10) * nav_dat(11) * nav_dat(15) * nav_dat(16) * nav_dat(17) * ...
            nav_dat(18) * nav_dat(19) * nav_dat(22) * nav_dat(23) * nav_dat(25);

parity(5) = nav_dat(2)  * nav_dat(3)  * nav_dat(5)  * nav_dat(7)  * nav_dat(8)  * ...
            nav_dat(9)  * nav_dat(11) * nav_dat(12) * nav_dat(16) * nav_dat(17) * ...
            nav_dat(18) * nav_dat(19) * nav_dat(20) * nav_dat(23) * nav_dat(24) * ...
            nav_dat(26);

parity(6) = nav_dat(1)  * nav_dat(5)  * nav_dat(7)  * nav_dat(8)  * nav_dat(10) * ...
            nav_dat(11) * nav_dat(12) * nav_dat(13) * nav_dat(15) * nav_dat(17) * ...
            nav_dat(21) * nav_dat(24) * nav_dat(25) * nav_dat(26);
        
%--- 比较6比特校验位与接收的校验位 ---%
if ((sum(parity == nav_dat(27:32))) == 6)
    status = -1 * nav_dat(2);
else
    status = 0;
end
    