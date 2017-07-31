function [ y ] = linear_joint( I, L )
%LINEAR_JOINT �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
tic;
    [p, f] = size(I);
    light_number = f;
    D1 = kron(speye(p),L);% f*p�У�3*p��
    D2 = sparse(zeros(f));
    D2(eye(f)>0) = I(1,:);
    temp = zeros(light_number);
    for i = 2:p
        temp(speye(f)>0) = I(i,:);
        D2 = [D2,temp];
    end
    D = [D1,D2'];
    y = null(D,'r');
toc;
end

