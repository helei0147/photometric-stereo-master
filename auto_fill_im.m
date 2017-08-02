function [rect_im] = auto_fill_im( ldr, im_mask )
%AUTO_FILL_IM 此处显示有关此函数的摘要
%   此处显示详细说明
    im_size = size(im_mask);
    show_im = zeros(im_size(1),im_size(2),3);
    show_im = uint8(show_im);
    R_slice = uint8(zeros(im_size));
    im_mask = im_mask>0;
    R_slice(im_mask) = ldr(:,1);
    G_slice = uint8(zeros(im_size));
    G_slice(im_mask) = ldr(:,2);
    B_slice = uint8(zeros(im_size));
    B_slice(im_mask) = ldr(:,3);
    show_im(:,:,1) = R_slice;
    show_im(:,:,2) = G_slice;
    show_im(:,:,3) = B_slice;
    rect_im = show_im;


end

