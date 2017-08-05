function [ norm_degree_error, exposure_scale, parameter_buffer] = cal_n_pixelwise_without_optimize(image_path, light_file, mat_file, isldr, is_ae, T_low)
exposure_scale = 0;
curve = load('curve.txt');
curve = curve(2:2:6,:);
image_path = sprintf('data/images/%s',image_path);
light_file = sprintf('data/lighting/%s', light_file);
mat_file = sprintf('data/mats/%s',mat_file);
%     load mask
load(sprintf('%s',mat_file));
mask = mask>0;
v_ind=find(mask>0);
%%     load light source info
lights = load(light_file);
lights = reshape(lights,3,[])';
light_number=size(lights,1);
if (isldr == 1)&&(is_ae == 1)
    exposure_scale = zeros(light_number,1);
end
light_true=lights;
%% read in images
valid_pixel_count=size(v_ind,1);
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
    load(sprintf('random_%d.mat',light_number));
    [origin_I, exposure] = random_exposure(origin_I,0.33,random_vec);
end

%% select 50 lights and images for the following operations
load('select_50.mat');
random_50 = uint32(random_50);
light_true = light_true(random_50,:);
origin_I = origin_I(:,random_50);

%% cut off observations with zero pixel value and more than T_low
tic
for i = 1:size(origin_I,1)
    observations = origin_I(i,:);
    observations(observations<1e-6) = -1;% remove shadows
    remained = observations(observations>0);
    remained_num = size(remained,2);
    sorted = sort(remained);
    threshold = sorted(ceil(remained_num*T_low));
    observations(observations>threshold) = -1;
    I(i,:) = observations;
end
fprintf('shadows and high frequency part cut off\n');
toc;
%% some containers and variables.
parameter_buffer = zeros(valid_pixel_count,9);
normal_matrix = zeros(valid_pixel_count,3);
error_buffer = zeros(valid_pixel_count,1);
t0 = cputime;
optimized_count = 0;
%% for every pixel get its normal using Frobenius-norm
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
    
    valid_L_num(i) = size(L,1);
    intense=valid_buffer;
    A = L.'*L;
    b = L.'*intense;
    n = A\b;
%     normalize the normal of this pixel
    n=n/norm(n); 
    normal_matrix(i,:)=n';
    pixel_error = acos(nn(i,:)*n)/pi*180;
    error_buffer(i) = pixel_error;

    to_solve = generate_to_solve(L,n);
    light_intensity = L*n;
    [parameter, para_error] = solve_parameter(to_solve,light_intensity,valid_buffer);
    parameter_buffer(i,:) = parameter';

%     for loop_count = 1:100
%         fun = @(n)another_solve_n(n,L,valid_buffer,parameter);
%         new_n = lsqnonlin(fun,n);
%         new_n = normalize_vectors(new_n');
%         error2 = cal_degree_error(new_n, nn(i,:));
%         error1 = cal_degree_error(n', nn(i,:));
%         n = new_n';
%         if error1-error2<1e-5
%             break;
%         end
%         to_solve = generate_to_solve(L,n);
%         light_intensity = L*n;
%         [parameter, para_error] = solve_parameter(to_solve,light_intensity,valid_buffer);
%     end
%     optimized_normal(i,:) = new_n;
%     opt_count(i) = loop_count;
end
%% calculate pixel normal error and analyse pixels with great error
nan_size = size(find(isnan(normal_matrix(:,1))>0),1);
nan_mask = isnan(normal_matrix(:,1))>0;
C = [valid_L_num',error_buffer];
normal_matrix = interp_nan(normal_matrix);
% show_normal(normal_matrix,mask,image_path);
cos_error_vector= sum(normal_matrix.*nn,2);
%------------------------------------------
without_nan = 0;
without_light_less_than_three_flag = 0;
%------------------------------------------
pixel_in_count = valid_pixel_count;

if without_nan==1
    cos_error_vector(nan_mask) = 1;
    pixel_in_count = pixel_in_count-nan_size;
end

light_less_than_three = size(find(C(:,1)<3),1);
if without_light_less_than_three_flag==1
    cos_error_vector(C(:,1)<3) = 1; % 光不足3个的去除计算
    pixel_in_count = pixel_in_count-light_less_than_three;
end

% set normal error bigger than 90 to 90
cos_error_vector(cos_error_vector<0) = 0;

norm_degree_error = sum(acos(cos_error_vector)/pi*180)/pixel_in_count;

end