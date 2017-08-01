function [ norm_degree_error, exposure_scale, nan_size ] = cal_n_pixelwise_without_optimize(image_path, light_file, mat_file, isldr, is_ae)
% image_path='rabbit_all/lights_89/hdr/16_6';
% light_file='lights_89.txt';
% mat_file = 'rabbit.mat';
exposure_scale = 0;
curve = load('curve.txt');
curve = curve(2:2:6,:);
name = image_path;
image_path = sprintf('data/images/%s',image_path);
light_file = sprintf('data/lighting/%s', light_file);
mat_file = sprintf('data/mats/%s',mat_file);
iter_max=100;
%     load mask
load(sprintf('%s',mat_file));
mask = uint8(mask);
v_ind=find(mask>0);
%     load light source info
lights = load(light_file);
lights = reshape(lights,3,[])';
light_number=size(lights,1);
if (isldr == 1)&&(is_ae == 1)
    exposure_scale = zeros(light_number,1);
end
light_true=lights;

valid_pixel_count=size(v_ind,1);
I = zeros(valid_pixel_count, light_number); % Image buffer to save 
% grayscale pixels. The third dimension is light index.
ae_path = sprintf('ae/%s',image_path);

ae_exist_flag = 0;
if is_ae
    if exist(ae_path)==0
        mkdir(ae_path)
    else
        ae_exist_flag = 1;
        e_matname = sprintf('%s/exposure_scale.mat',ae_path);
        if exist(e_matname)
            load(e_matname);
        end
    end
end
for i=1:light_number
    tic;
    if isldr
        filename = sprintf('%s/%d.png',image_path,i-1);
        img = load_png(filename,mask);
%         psu_to_ldr('curve.txt',img);
        
    else
        if is_ae == 0
            filename=sprintf('%s/%d.rgb',image_path,i-1);
            img = load_rgb(filename);
            to_dis = sprintf('processing light %d',i);
            disp(to_dis);
        else
            % 自动曝光
            if ae_exist_flag == 1
               % 自动曝光，已经得出了图像，直接读取。
               rect_im = imread(sprintf('%s/%d.png',ae_path,i));
               R = rect_im(:,:,1);G = rect_im(:,:,2);B = rect_im(:,:,3);
               mask = mask>0;
               img(:,1) = R(mask);
               img(:,2) = G(mask);
               img(:,3) = B(mask);
            else
                % 自动曝光，第一次进行曝光，需要计算。保存图像
                filename=sprintf('%s/%d.rgb',image_path,i-1);
                img = load_rgb(filename);
                to_dis = sprintf('processing light %d\n',i);
                disp(to_dis);
                [img, exposure_scale(i,1)] = auto_exposure(img,curve);
                rect_im = auto_fill_im(img,mask);
                imwrite(rect_im,sprintf('%s/%d.png',ae_path,i),'png');
            end
            img = to_psu_hdr_vec(img);
            
        end
    end
    toc;
    
    R = img(:,1);
    G = img(:,2);
    B = img(:,3);
    
    gs_img = 0.2989 * R + 0.5870 * G + 0.1140 * B ;
    origin_I(:,i) = gs_img;
end

if is_ae
    origin_I = origin_I./kron(ones(size(origin_I,1),1),exposure_scale');
    e_matname = sprintf('%s/exposure_scale.mat',ae_path);
    save(e_matname,'exposure_scale');
else
%     [origin_I, exposure] = random_exposure(origin_I,0.08);
end
% total_median = median(origin_I(:));
% for i = 1:light_number
%     origin_I(:,i) = auto_exposure(origin_I(:,i),total_median);
% end
for i = 1:light_number
    gs_img = origin_I(:,i);
    threshold_percent = 0.3;% pixels remain
    sorted_img = sort(gs_img);
    zero_num = size(find(sorted_img<1e-6),1);
    p_num = size(sorted_img,1);
    threshold = sorted_img(uint32((p_num-zero_num)*threshold_percent)+zero_num);
    gs_img(gs_img>threshold)=-1;
    I(:,i)=gs_img;
end
normal_matrix = zeros(valid_pixel_count,3);
total_error=0;
% high frequency part of I is cut-off
para_num=9;
parameter_buffer=zeros(valid_pixel_count,para_num);
error_buffer = zeros(valid_pixel_count,1);
t0 = cputime;
for i=1:size(I,1)
    if mod(i,1000)==0
        fprintf('pixel:%d, used up %f s\n',i,cputime-t0);
    end
    buffer=I(i,:);
    buffer_mask=buffer>0; % a row mask
    valid_buffer=buffer(buffer_mask)'; % a column 
    valid_light=light_true(buffer_mask',:); % first dimension is light index, second dimension is x, y and z
    valid_light_num=size(valid_light,1);
%   first time for photometric stereo, get a initial value for the normal
%   of this pixel
    L=valid_light;
    intense=valid_buffer;
    n = (L.'*L)\(L.'*intense);
    
%     normalize the normal of this pixel
    n=n/norm(n);
    

    normal_matrix(i,:)=n';
    pixel_error = acos(nn(i,:)*n)/pi*180;
    error_buffer(i) = pixel_error;
%     fprintf('pixel %d, error %f\n',i,pixel_error);
%     fprintf('parameter error:%f\n',para_error);
%     fprintf('iter: %d\n',iter);
end
show_normal(normal_matrix,mask,image_path);
cos_error_vector= sum(normal_matrix.*nn,2);
nan_size = size(find(isnan(cos_error_vector)),1);
cos_error_vector(isnan(cos_error_vector))=1;

norm_degree_error = sum(acos(cos_error_vector)/pi*180)/valid_pixel_count

% [pic_height,pic_width]=size(mask);
% first_dim_vector=floor(v_ind/pic_height)+1;
% second_dim_vector=mod(v_ind,pic_height)+1;
% pos_matrix=[first_dim_vector, second_dim_vector];
% for ind=1:size(pos_matrix,1)
%     g
end