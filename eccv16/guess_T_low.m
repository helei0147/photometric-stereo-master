function [ T_low ] = guess_T_low( para_max )
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
    denominator = 1+exp(-(para_max-1100)/250);
    numerator = 0.8;
    T_low = numerator/denominator+0.1
end

