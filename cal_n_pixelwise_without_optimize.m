clear all
image_path='71_6_noscale';
light_file='light_89.txt';
mat_file = 'rabbit.mat';
isldr = 1; 
name = image_path;
image_path = sprintf('data/images/%s',image_path);
light_file = sprintf('data/lighting/%s', light_file);
mat_file = sprintf('data/mats/%s',mat_file);
iter_max=100;
%     load mask
load(sprintf('%s',mat_file));
mask = uint8(mask);
v_ind=find(mask>0);
nn(:,3)=-nn(:,3);
%     load light source info
load data/lighting/light_89.txt;
lights = reshape(light_89,3,[])';
light_number=size(lights,1);

light_true=lights;
light_true(:,3)=-light_true(:,3);

valid_pixel_count=size(v_ind,1);
I = zeros(valid_pixel_count, light_number); % Image buffer to save 
% grayscale pixels. The third dimension is light index.

for i=1:light_number
    if isldr
        filename = sprintf('%s/%d.png',image_path,i-1);
        img = load_png(filename,mask);
%         psu_to_ldr('curve.txt',img);
    else
        filename=sprintf('%s/%d.rgb',image_path,i-1);
        img = load_rgb(filename);
    end
    R = img(:,1);
    G = img(:,2);
    B = img(:,3);
    
    gs_img = 0.2989 * R + 0.5870 * G + 0.1140 * B ;
    img_median=median(gs_img);
    gs_img(gs_img>img_median)=-1;
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
    if mod(i,100)==0
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
    fprintf('pixel %d, error %f\n',i,pixel_error);
%     fprintf('parameter error:%f\n',para_error);
%     fprintf('iter: %d\n',iter);
end

cos_error_vector= sum(normal_matrix.*nn,2);
cos_error_vector(isnan(cos_error_vector))=1;
norm_degree_error = sum(acos(cos_error_vector)/pi*180)/valid_pixel_count

% [pic_height,pic_width]=size(mask);
% first_dim_vector=floor(v_ind/pic_height)+1;
% second_dim_vector=mod(v_ind,pic_height)+1;
% pos_matrix=[first_dim_vector, second_dim_vector];
% for ind=1:size(pos_matrix,1)
%     g
