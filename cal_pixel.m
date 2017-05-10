function [ optimized_normal, optimized_error, pixel_parameter ] = ...
    cal_pixel( ground_truth, p_raw_normal, p_valid_light, p_valid_I_pixelwise )
%CAL_PIXEL For a specific pixel optimize normal and get opptimized
%parameter.
%   gt is the Ground Truth of this pixel
% raw_normal is the normal get from vanilla Photometric Stereo
% valid_light is the L_low
% valid_I_pixelwise is I_low
    t0 = cputime;
    gt = cell2mat(ground_truth);
    raw_normal = cell2mat(p_raw_normal);
    valid_light = cell2mat(p_valid_light);
    valid_I_pixelwise = cell2mat(p_valid_I_pixelwise);
    L = valid_light;
    valid_light_num = size(L,1);
    
    iter_max = 100;
    para_num = 9;
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
    cos_theta_h=h*raw_normal;
    theta_h=acos(cos_theta_h);
%     now parameter theta_h and theta_d is prepared.
    % x=cos_theta_h; % unnecesary
    y=cos_theta_d;
    
    
%     init error with 100 to jump in the loop.
    iter = 1;
    error = 100;
    temp_n_buffer=zeros(iter_max,4);
    temp_para_buffer = zeros(iter_max,para_num+1);
%     new_normal = zeros(size(raw_normal));
    while error>1e-7
%         optimize parameters.
        to_cal_parameter=zeros(valid_light_num,para_num);
%         after each loop, n is updated, recalculate x
        x=h*raw_normal;
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
        light_intensity_vector = L*raw_normal;
        for para_idx = 1:para_num
            to_solve(:,para_idx)=to_cal_parameter(:,para_idx).*light_intensity_vector;
        end
        para=zeros(para_num,1);
        options=optimoptions('fmincon','Algorithm','interior-point','display','notify');
        func_para = @(para)optimize_parameter(para,to_cal_parameter,light_intensity_vector,valid_I_pixelwise);
        [parameter,~,~,~]=fmincon(func_para,para,[],[],[],[],[],[],[],options);
        para_error = norm((to_cal_parameter*parameter).*light_intensity_vector-valid_I_pixelwise);
        temp_para_buffer(iter,1:para_num)=parameter;
        temp_para_buffer(iter,para_num+1)=para_error;       
%         optimize normal
        [new_error, new_normal] =opt_normal(raw_normal,h,y,L,parameter,valid_I_pixelwise,gt,error);
%         fprintf('%f',new_error);
        if error-new_error<1e-6
            break
        else
            error=new_error;
        end

        temp_n_buffer(iter,1:3)=new_normal';
        temp_n_buffer(iter,4)=new_error;
        iter=iter+1;
%         fprintf('pixel:%d iter:%d\n',i,iter);
        if iter>iter_max
            break
        end
    end
    
    optimized_normal{1} = new_normal;
    pixel_parameter{1} = parameter';
    optimized_error{1} = new_error;

    fprintf('used time %f s, error %f\n',cputime-t0,new_error);
    disp([gt,new_normal']);
end

