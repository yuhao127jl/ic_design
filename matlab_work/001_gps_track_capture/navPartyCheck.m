function status = navPartyCheck(nav_dat)
% GPS�ֵı���У�麯��
% �� �룺nav_dat ---GPS�������ģ��֣��е�32bit���ݣ�����30bit����һ���ֵ������
%                   �����أ�(-2 -1 0 1 2 ... 28 29)��
% �� ����status ---�����żУ��ɹ��򷵻�-1��+1,���򷵻�0
%	a	b	xor 			a	b	product
%  --------------          -----------------
%	0	0	 1			   -1  -1	   1
%	0	1	 0			   -1   1	  -1
%	1	0	 0			    1  -1	  -1
%	1	1	 1			    1   1	   1

%--- ������ݱ����Ƿ�ת ---%
if (nav_dat(2) ~= 1)
    nav_dat(3:26)= -1 .* nav_dat(3:26);  % ȡ��
end

%--- ����6����У��λ ---%
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
        
%--- �Ƚ�6����У��λ����յ�У��λ ---%
if ((sum(parity == nav_dat(27:32))) == 6)
    status = -1 * nav_dat(2);
else
    status = 0;
end
    