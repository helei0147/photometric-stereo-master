function [ normal ] = factorization( I, L )
%FACTORIZATION 此处显示有关此函数的摘要
%   此处显示详细说明
    [U,S,V] = svds(I',3);
    
    % randomly get three normal vector
    picked_num = 3;
    picked = zeros(3);
    [pixel_num, light_num] = size(I);
    index = uint32(rand(1,picked_num)*pixel_num+1);
    for i = 1:picked_num
        picked(i,:) = V(index(i),:);
    end
    s = S.^(0.5);
    re = det(s*picked);
    if re<0
        s = -s;
    end
    S_cap = U*s;
    B_cap = (s*V')';
    % pick up 6 pixel with the same reflectance ratio
    index = uint32(rand(1,6)*pixel_num+1);
    to_solve = zeros(3*light_num,9);
    for i = 1:light_num
        temp = zeros(3,9);
        temp(1,4:6) = -L(i,3)*S_cap(i,:);
        temp(1,7:9) = L(i,2)*S_cap(i,:);
        temp(2,1:3) = L(i,3)*S_cap(i,:);
        temp(2,7:9) = -L(i,1)*S_cap(i,:);
        temp(3,1:3) = -L(i,2)*S_cap(i,:);
        temp(3,4:6) = L(i,1)*S_cap(i,:);
        start = i*3-2;
        rear = i*3;
        to_solve(start:rear,:) = temp;
    end
%     
%     y = null(to_solve,'r');
    [V,k] = svd(to_solve');
    y = V(:,1);
    H = zeros(3,3);
    H(1,:) = y(1:3)';
    H(2,:) = y(4:6)';
    H(3,:) = y(7:9)';
    H_ = inv(H);
    normal = H_*(B_cap');
    normal = normal';
    len = sum(normal.^2,2);
    len = len.^0.5;
    len = [len , len, len];
    normal = normal./len;
%     u = S_cap(:,1);
%     v = S_cap(:,2);
%     w = S_cap(:,3);
% 
%     unfold = [u.*u, 2*u.*v, 2*u.*w, v.*v, 2*v.*w, w.*w];
%     x = unfold\ones(pixel_num,1);
%     line1 = [x(1), x(2), x(3)];
%     line2 = [x(2), x(4), x(5)];
%     line3 = [x(3), x(5), x(6)];
%     B = [line1; line2; line3];
%     [A,sigma,A_] = eig(B);
%     A = A*(sigma.^0.5);
%     S = S_cap*A;
%     len = sum(S.^2,2);
%     len = len.^0.5;
%     len = [len,len,len];
%     normal = S./len;

end

