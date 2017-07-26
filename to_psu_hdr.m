function [ psudo_hdr ] = to_psu_hdr( png_matrix )
%TO_PSU_HDR 此处显示有关此函数的摘要
%   此处显示详细说明
    curve = load('curve.txt');
    curve_matrix=curve(2:2:6,:);
%     scale the range from 0~255 to 0~1024
    png_matrix = uint32(png_matrix);
    png_matrix=(png_matrix)*4;
    psudo_hdr=zeros(size(png_matrix));
    for channel=1:3
        slice=png_matrix(:,:,channel);
        curve_map=curve_matrix(channel,:);
        psudo_hdr(:,:,channel)=reshape(curve_map(slice+1),size(slice));
    end
end

