function [ I, exposure_scale ] = random_exposure( origin_I, threshold, random_vec )
%RANDOM_EXPOSURE 对输入图像在给定范围内进行随机放大或缩小。
%   origin_I: each colomn is an image 
%   threshold: the rate exposure can vary from.
    [pixel_num, light_num] = size(origin_I);
    
    r = random_vec*2*threshold;
    exposure_scale = ones(1,light_num)-threshold;
    exposure_scale = exposure_scale+r;
    exposure_scale(1) = 1;
    I = origin_I.*kron(ones(pixel_num,1),exposure_scale);
end

