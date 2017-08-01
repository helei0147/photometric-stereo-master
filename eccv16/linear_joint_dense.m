function [ y ] = linear_joint_dense( I, L )
%LINEAR_JOINT 此处显示有关此函数的摘要
%   此处显示详细说明
tic;
    [p, f] = size(I);
    light_number = f;
    D1 = kron(-eye(p),L);% f*p行，3*p列
    D2 = zeros(f);
    D2(eye(f)>0) = I(1,:);
    ind = I(1,:)>0;
    temp = zeros(light_number);
    for i = 2:p
        temp(eye(f)>0) = I(i,:);
        ind = [ind,(I(i,:)>0)];
        D2 = [D2,temp];
    end
    D = [D1,D2'];
    D = D(ind>0,:);
    [V, k] = svd(D');
    y = V(:,end);
toc;
end

