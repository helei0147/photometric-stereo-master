function [ auto_exposed_im, exposure_scale ] = auto_exposure( im, curve_matrix)
%AUTO_EXPOSURE 此处显示有关此函数的摘要
%   此处显示详细说明
%     for channel = 1:3
%         mask = im(:,channel)>0;
%         valid = im(:,channel);
%         valid = valid(mask);
%         k_(channel) = median(valid);
%     end
    pixel_num = size(im,1);
    middle_percent = 0.75;
    for channel = 1:3
        sorted = sort(im(:,channel));
        k_(channel) = sorted(uint32(middle_percent*pixel_num));
    end
    [k, index] = max(k_);
    curve_resolution = size(curve_matrix,2);
    center = floor(curve_resolution/2);
    center_value = curve_matrix(:,center)';
    scale = center_value(index)/k; %曝光时间相对值
    im = im*scale;
    ldr = to_ldr_vec(im,curve_matrix);
    auto_exposed_im = ldr;
    exposure_scale = scale;
end

