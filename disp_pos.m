function disp_pos( mask, i )
%DISP_POS 此处显示有关此函数的摘要
%   此处显示详细说明
    [height, width] = size(mask);
    slice = uint8(zeros(size(mask)));
    valid_pix_num = size(find(mask>0),1);
    vec = uint8(zeros(valid_pix_num,1));
    vec(i) = 255;
    slice(mask) = vec;
    pic = uint8(zeros(height,width,3));
    pic(:,:,1) = slice;
    imshow(pic);
end

