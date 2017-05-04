function [ c, ceq ] = normal_constraint( normal )
%NORMAL_CONSTRAINT 此处显示有关此函数的摘要
%   此处显示详细说明
    c=[];
    ceq=norm(normal)-1;
end

