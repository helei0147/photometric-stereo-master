function [ vectorized_pixel ] = load_png( filename, mask )
%LOAD_PNG 此处显示有关此函数的摘要
%   此处显示详细说明
rect_img = imread(sprintf('%s',filename));
% psu_hdr = rect_img;
psu_hdr = to_psu_hdr(rect_img, 0, 0.077);
for i = 1:3
    slice = psu_hdr(:,:,i);
    vectorized_pixel(:,i) = slice(logical(mask));
end

end

