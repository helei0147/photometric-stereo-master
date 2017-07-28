function [ ldr_vec ] = to_ldr_vec( im, curve )
%UNTITLED2 将向量式的hdr图片转化为向量式的ldr图片
%   im 是 p行3列的向量化图像
%     curve 是 3行1024列的相机对应函数。

    ldr_vec = zeros(size(im));
%     gray_buffer = im*[0.2989; 0.5870; 0.1140];
%     h_index = uint32(size(im,1)*0.95);
%     l_index = uint32(size(im,1)*0.1);
%     sorted = sort(gray_buffer);
    h_threshold = 1;
    l_threshold = 0;
    for channel = 1:3
%         scale the selected channel
        im_channel = im(:,channel); % 列向量
%         im_channel = (im_channel-l_threshold)/(h_threshold-l_threshold);
        im_channel(im_channel>1) = 1;
        im_channel(im_channel<0) = 0;
        vector = curve(channel,:); % 行向量
        curves = kron(ones(size(im_channel,1),1),vector);
        channels = kron(ones(1,size(curve,2)),im_channel);
        [~, ldr_vec(:,channel)] = max(channels<=curves, [], 2);
    end
    % 从1~1024缩放到0~255
    result = floor((ldr_vec-1)/(size(curve,2)/256));
    ldr_vec = uint8(result);
end

