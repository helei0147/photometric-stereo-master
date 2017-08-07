light_number = 89;
counter = 1;
% 99, 59, 19, 85, 
for i = [0:97,99]
%     image_path=sprintf('rabbit_all/lights_%d/hdr/%d_6',light_number,i);
    image_path=sprintf('sphere_89light/%d_7',i);
    light_file=sprintf('lights_%d.txt',light_number);
%     image_path=sprintf('rabbit_25L_new/%d_6',i);
%     light_file='lights_250.txt';
    mat_file = 'sphere.mat';
    isldr = 0; 
    is_ae = 0;
    [error_hdr(counter), ~, parameter_buffer] = cal_n_pixelwise_without_optimize(image_path,light_file,mat_file,isldr,is_ae,0.2);
%     save(sprintf('para_results/%d_0.3.mat',i),'parameter_buffer');
    counter = counter+1;
%     k = sum(abs(parameter_buffer))/size(parameter_buffer,1);
%     plot(k);
end