function [ optimized_error,optimized_n ] = opt_normal( n,h,y,L,parameter,intense,ground_truth,error )
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
    ntf = @(n)normal_target_fun(n,h,y,L,parameter,intense);
    options=optimoptions('fmincon','Algorithm','interior-point','display','notify');
    [optimized_n, ~, ~, ~] = fmincon(ntf, n,[],[],[],[],[],[],@confungrad,options);
    optimized_error = acos(ground_truth*optimized_n);
end

