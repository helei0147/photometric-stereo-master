function [ optimized_error,optimized_n ] = opt_normal( n,h,y,L,parameter,intense,ground_truth,error )
%UNTITLED �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
    ntf = @(n)normal_target_fun(n,h,y,L,parameter,intense);
    options=optimoptions('fmincon','Algorithm','interior-point','display','notify');
    [optimized_n, ~, ~, ~] = fmincon(ntf, n,[],[],[],[],[],[],@confungrad,options);
    optimized_error = acos(ground_truth*optimized_n);
end

