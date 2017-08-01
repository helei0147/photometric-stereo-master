light_number = 89;
exposure = zeros(89,100);
for i = 0:99
    image_path=sprintf('rabbit_all/lights_%d/hdr/%d_6',light_number,i);
    light_file=sprintf('lights_%d.txt',light_number);
    mat_file = 'rabbit.mat';
    isldr = 0; 
    [error_hdr(i+1),~, hdr_nan(i+1)] = cal_n_pixelwise_without_optimize(image_path,light_file,mat_file,isldr,0);
    [error_ae(i+1), exposure(:,i+1), ae_nan(i+1)] = cal_n_pixelwise_without_optimize(image_path,light_file,mat_file,isldr,1);
end
save('exposure_89.mat','exposure');
save(sprintf('is_nan_%d',light_number),'ae_nan','hdr_nan');