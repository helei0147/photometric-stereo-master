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
    error = 100;
%         optimize parameters.
    to_cal_parameter=zeros(valid_light_num,para_num);
%         after each loop, n is updated, recalculate x
    x=h*raw_normal;
%     parameter matrix, first dimension is light index, second dimension is
%     9 or 16 parameters for this light condition.
    to_cal_parameter = [ones(valid_light_num,1), y, y.*y, x, x.*y, x.*y.*y, x.*x, x.*x.*y, x.*x.*y.*y];
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
%     para_error = norm((to_cal_parameter*parameter).*light_intensity_vector-valid_I_pixelwise);     
%         optimize normal
% % % %     [new_error, new_normal] =opt_normal(raw_normal,h,y,L,parameter,valid_I_pixelwise,gt,error);

    x=zeros(valid_light_num,1);
    [xerror,new_x] = x_target_fun(x,y,raw_normal,L,parameter,valid_I_pixelwise);
    new_nx = n_target_fun(n, L, new_x);
    new_error = acos(gt*new_nx)/pi*180;
    
    optimized_normal{1} = new_nx;
    pixel_parameter{1} = parameter';
    optimized_error{1} = new_error;
    
    fprintf('used time %f s, error %f\n',cputime-t0,new_error);
    fprintf('raw_error: %f\n',acos(gt*raw_normal)/pi*180);
    disp([gt,new_normal']);
end

