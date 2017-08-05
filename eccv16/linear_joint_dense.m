function [ y, valid_light_number ] = linear_joint_dense( I, L, T_low )
%LINEAR_JOINT 此处显示有关此函数的摘要
%   此处显示详细说明
tic;
%     cut off observations for each pixel which are more than T_low
    valid_light_number = zeros(size(I(:,1)));
    for i = 1:size(I,1)
        observations = I(i,:);
        observations(observations<1e-6) = -1;% remove shadows(zero observations)
        remained = observations(observations>0);
        remained_num = size(remained,2);
        sorted = sort(remained);
        index = ceil(remained_num*T_low);
        valid_light_number(i) = index;
        threshold = sorted(index);
        observations(observations>threshold) = -1;
        I(i,:) = observations;
    end
    to_unfold = I.';
    pixel_mask = to_unfold(:)>1e-6;
    
    [p, f] = size(I);
    light_number = f;
    D1 = kron(-eye(p),L);% f*p行，3*p列
    D2 = zeros(f);
    D2(eye(f)>0) = I(1,:);
    temp = zeros(light_number);
    for i = 2:p
        temp(eye(f)>0) = I(i,:);
        D2 = [D2,temp];
    end
    D = [D1,D2'];
    % cut off not valid pixels
    D = D(pixel_mask,:);
    
    [V, k] = svd(D');
    y = V(:,end);
toc;
end

