exposure = zeros(89,100);
for i = 0:99
    image_path=sprintf('rabbit_all/lights_89/hdr/%d_6',i);
    light_file='lights_89.txt';
    mat_file = 'rabbit.mat';
    isldr = 0; 
%     [error_hdr(i+1),~] = cal_n_pixelwise_without_optimize(image_path,light_file,mat_file,isldr,0);
    [error_ae(i+1), exposure(:,i+1)] = cal_n_pixelwise_without_optimize(image_path,light_file,mat_file,isldr,1);
end
save exposure.mat exposure