function show_normal( normal, mask, title_temp )
%SHOW_NORMAL 此处显示有关此函数的摘要
%   此处显示详细说明
    zz = auto_fill_im(normal,mask);
    figure;
    imagesc(uint8((zz+1)*128));
    title(title_temp);
    axis equal;
end

