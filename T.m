function [L, S, nIter] = T(image_path, light_file, mat_file)
    name = image_path;
    image_path = sprintf('data/images/%s',image_path);
    light_file = sprintf('data/lighting/%s', light_file);
    mat_file = sprintf('data/mats/%s',mat_file);


    %     load mask
    load(sprintf('%s',mat_file));
    mask = uint8(mask);
    v_ind=find(mask>0);
    %     load light source info
    load (light_file,'lights');
    lights = reshape(lights,3,[])';
    light_number=size(lights,1);
    light_true=lights;
%     light_true(2,:) = -lights(2,:);
    %     load images

    I = cell(light_number,1);
    for i=1:light_number
        filename=sprintf('%s/%d.png',image_path,i-1);
        image = imread(filename);
        I{i}=image;
    end
    N = compute_surfNorm(I, light_true, mask);
    cal_n_error(N,nn2,v_ind);
    h = show_surfNorm(N, 4);
    saveas(h, sprintf('./results/%s_norm2.png', name));
end