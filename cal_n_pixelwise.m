clear all
image_path='55_6';
light_file='light_89.txt';
mat_file = 'rabbit.mat';

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
    filename=sprintf('%s/%d.rgb',image_path,i-1);
    fid=fopen(filename,'r');
    img = fread(fid,inf,'float');
    fclose(fid);
    img=reshape(img,3,[])';
    R = img(:,1);
    G = img(:,2);
    B = img(:,3);
    
    gs_img = 0.2989 * R + 0.5870 * G + 0.1140 * B ;
    img_median=median(gs_img);
    gs_img(gs_img>img_median)=-1;
    I(:,i)=gs_img;
end
normal_matrix = zeros(valid_pixel_count,3);
% high frequency part of I is cut-off
para_num=9;
parameter_buffer=zeros(valid_pixel_count,para_num);
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
    
%----------------------------------------------------------------------------
    
    raw_err = nn(i,:)*n;
    fprintf('raw PS error:%f\n',acos(raw_err)/pi*180);
%     v is valid_light_number x 3 amtrix, each row is [0,0,-1]
    v=zeros(size(valid_light));
    v(:,3)=-1;
%     use acos to calculate theta_d
    cos_theta_2d=sum(L.*v, 2);
    theta_d=acos(cos_theta_2d)/2; % a value between 0 and pi/2
    cos_theta_d=cos(theta_d);
%     calculate vector h
    h=L+v;
%     normalize h
    for l_idx=1:valid_light_num
        h(l_idx,:)=h(l_idx,:)/norm(h(l_idx,:));
    end
%     calculate theta_h
    cos_theta_h=h*n;
    theta_h=acos(cos_theta_h);
%     now parameter theta_h and theta_d is prepared.
    x=cos_theta_h;
    y=cos_theta_d;
    
    
%     init error with 100 to jump in the loop.
    iter = 1;
    error=100;
    temp_n_buffer=zeros(iter_max,4);
    temp_para_buffer = zeros(iter_max,para_num+1);
    while error>1e-7
%         optimize parameters.
        to_cal_parameter=zeros(valid_light_num,para_num);
%         after each loop, n is updated, recalculate x
        x=h*n;
%     parameter matrix, first dimension is light index, second dimension is
%     9 or 16 parameters for this light condition.
        for l_idx=1:valid_light_num
            t_x=[1;x(l_idx);x(l_idx)^2];
            t_y=[1,y(l_idx),y(l_idx)^2];
            xy_matrix=t_x*t_y;% 3 x 3 matrix
            to_cal_parameter(l_idx,:)=xy_matrix(:)';
        end
%     use argmin to optimize
        to_solve=zeros(size(to_cal_parameter));
        light_intensity_vector = L*n;
        for para_idx = 1:para_num
            to_solve(:,para_idx)=to_cal_parameter(:,para_idx).*light_intensity_vector;
        end
        para=zeros(para_num,1);
        options=optimoptions('fmincon','Algorithm','interior-point','display','notify');
        func_para = @(para)optimize_parameter(para,to_cal_parameter,light_intensity_vector,intense);
        [parameter,fval,exitflag,output]=fmincon(func_para,para,[],[],[],[],[],[],[],options);
        para_error = norm((to_cal_parameter*parameter).*light_intensity_vector-valid_buffer);
        temp_para_buffer(iter,1:para_num)=parameter;
        temp_para_buffer(iter,para_num+1)=para_error;
%         fprintf('parameter:');
%         parameter'
%         fprintf('\nparameter_error: %f\n',para_error);
        
        
%         optimize normal of this pixel
        
        prmt=n;
        options=optimoptions('fmincon','Algorithm','interior-point','display','notify');
        func=@(normal)optimize_n(normal,h,y,valid_light_num,para_num,L,parameter,intense);
        [new_n,fval,exitflag,output]=fmincon(func,prmt,[],[],[],[],[],[],@normal_constraint,options);
        gt=nn(i,:);
        normal_error = acos(gt*new_n)/pi*180;
%         ----------------------
        error = normal_error;
%         ----------------------
        n=new_n;
%         fprintf('pixel:%d,iter:%d,degree_error:%f\n',i,iter,normal_error)
%         disp(['normal:',num2str(n'),'n_err:',num2str(error)]);
        temp_n_buffer(iter,1:3)=n';
        temp_n_buffer(iter,4)=error;
        iter=iter+1;
%         fprintf('pixel:%d iter:%d\n',i,iter);
        if iter>iter_max
            break
        end
    end
    
%----------------------------------------------------------------------------
    normal_matrix(i,:)=n';
    parameter_buffer(i,:)=parameter';
    pixel_error = acos(nn(i,:)*n)/pi*180;
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
