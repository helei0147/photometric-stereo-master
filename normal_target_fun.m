function [ f, G ] = normal_target_fun( normal,h,y,L,parameter,intense )
%NORMAL_TARGET_FUN 此处显示有关此函数的摘要
%   此处显示详细说明
    f = error_n(normal(1),normal(2),normal(3),h,y,L,parameter,intense);
    
    func=@(d1,d2,d3)error_n(d1,d2,d3,h,y,L,parameter,intense);
    syms puppy(normal1,normal2,normal3)
    puppy(normal1,normal2,normal3) = func(normal1,normal2,normal3);
    derivative_normal1 = diff(puppy,normal1);
    derivative_normal2 = diff(puppy,normal2);
    derivative_normal3 = diff(puppy,normal3);
    
    d1 = eval(derivative_normal1(normal(1),normal(2),normal(3)));
    d2 = eval(derivative_normal2(normal(1),normal(2),normal(3)));
    d3 = eval(derivative_normal3(normal(1),normal(2),normal(3)));
    
    G = [d1, d2, d3];
end

