function [ c,ceq,dc,dceq ] = confungrad( x )
%CONFUNGRAD �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
    x1 = x(1);x2 = x(2);x3 = x(3);
    c = [];
    ceq = x1^2+x2^2+x3^2-1;
    dc = [2*x1; 2*x2; 2*x3];
    dceq = [];
end

