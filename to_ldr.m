function to_ldr( rgb_path,  target_path, light_file_name, model_mat)
    % tonemap
    % read in the response function curve.
    load 'curve.txt'
    curve_matrix=curve(2:2:6,:);
    % load position of lights
    lights = load(light_file_name);
    imgNum=size(lights,2)/3;
    % load normal map and mask
    load(sprintf('%s',model_mat));
    target_path=sprintf('%s_noscale',target_path);
    rgb_name = sprintf('%s/%d.rgb',rgb_path,1);    
    fid=fopen(rgb_name,'r');
    hdr_vector=reshape(fread(fid,inf,'float'),3,[])';
    fclose(fid);
    pixel_num = size(hdr_vector,1);
    hdr_buffer=zeros(pixel_num,3,imgNum);
    gray_buffer = zeros(pixel_num,imgNum);
    for i = 0:imgNum-1
        rgb_name = sprintf('%s/%d.rgb',rgb_path,i);
        
        fid=fopen(rgb_name,'r');
        hdr_buffer(:,:,i+1)=reshape(fread(fid,inf,'float'),3,[])';
        temp = rgb2gray(hdr_buffer(:,:,i+1));
        gray_buffer(:,i+1) = temp(:,1);
        fclose(fid);
    end
    v = gray_buffer(:);
%     v = hdr_buffer(:);
    h_index = uint32(size(v,1)*0.95);
    l_index = uint32(size(v,1)*0.1);
    sorted_v = sort(v);
    h_value = sorted_v(h_index);
    l_value = sorted_v(l_index);
    fprintf('high: %f, low: %f\n',h_value,l_value);
    for i=0:imgNum-1
        % load the rgb file to convert
        t0 = cputime;
        hdr_vector=hdr_buffer(:,:,i+1);
        hdr_vector = (hdr_vector-l_value)/(h_value-l_value);
        hdr_vector(hdr_vector>1)=1;
        hdr_vector(hdr_vector<0)=0;
        % store the result of tonemapping in double
        mapped_vector=zeros(size(hdr_vector));
        % get pixel position of value greater than 1 

        for channel=1:3 % RGB channels
            curves = zeros(size(mapped_vector,1),size(curve_matrix,2));
            for k = 1:size(curves,1)
                curves(k,:) = curve_matrix(channel,:);
            end
            pixels = zeros(size(curves));
            for k = 1:size(curves,2)
                pixels(:,k) = hdr_vector(:,channel);
            end
            [~,mapped_vector(:,channel)] = min(abs(pixels-curves),[],2);
        end
        png_size=size(nn2);
        png_file=uint8(zeros(png_size));
        mat=zeros(size(mask));
        v_ind= mask>0;

        for ind=1:3
            mat(v_ind)=mapped_vector(:,ind);
            png_file(:,:,ind)=uint8(mat/4);
        end
        imshow(png_file);
        if ~exist(target_path,'dir')
            mkdir(target_path);
        end
        imwrite(png_file,sprintf('%s/%d.png',target_path,i));
        %save(png_file,sprintf('png/%d.png',i));
        fprintf('image %d, used time: %fs\n',i,cputime-t0);
    end
end