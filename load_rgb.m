function [ img ] = load_rgb( filename )
%LOAD_RGB 此处显示有关此函数的摘要
%   此处显示详细说明

fid=fopen(filename,'r');
img = fread(fid,inf,'float');
fclose(fid);
img = reshape(img,3,[])';
end

