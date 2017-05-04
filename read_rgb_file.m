function [ pixels ] = read_rgb_file( rgb_name )
%READ_RGB_FILE read float data from rgb file
%   此处显示详细说明
%     return a nx3 float matrix
    filename=rgb_name;
    fid=fopen(filename,'r');
    if ~fid
        printf('can not read rgb file.');
    end
    img = fread(fid,inf,'float');
    fclose(fid);
    pixels = reshape(img,3,[])';
end

