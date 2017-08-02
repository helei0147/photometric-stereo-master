light_number = 25;
counter = 1;
for i = [99, 59, 19, 85, 73]
%     image_path=sprintf('rabbit_all/lights_%d/hdr/%d_6',light_number,i);
%     light_file=sprintf('lights_%d.txt',light_number);
    image_path=sprintf('rabbit_25L_new/%d_6',i);
    light_file='lights_250.txt';
    mat_file = 'rabbit.mat';
    isldr = 0; 
    is_ae = 0;
    [error_hdr(counter),~, hdr_nan(counter)] = cal_n_pixelwise_without_optimize(image_path,light_file,mat_file,isldr,is_ae);
    counter = counter+1;
end