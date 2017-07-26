function [ psu_hdr_im_vec ] = to_psu_hdr_vec( im_vec )
%UNTITLED3 此处显示有关此函数的摘要
%   此处显示详细说明
    curve = load('curve.txt');
    curve_matrix=curve(2:2:6,:);
%     scale the range from 0~255 to 0~1024
    im_vec = uint32(im_vec);
    im_vec = im_vec*4;
    psu_hdr_im_vec = zeros(size(im_vec));
    for channel=1:3
        slice=im_vec(:,channel);
        curve_map=curve_matrix(channel,:);
        psu_hdr_im_vec(:,channel) = reshape(curve_map(slice+1),size(slice));
    end

end

