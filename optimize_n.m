function error = optimize_n(normal,h,y,valid_light_num,para_num,L,parameter,intense)
    x=h*normal;
    to_cal_parameter=zeros(valid_light_num,para_num);
    for l_idx=1:valid_light_num
        t_x=[1;x(l_idx);x(l_idx)^2];
        t_y=[1,y(l_idx),y(l_idx)^2];
        xy_matrix=t_x*t_y;% 3 x 3 matrix
        to_cal_parameter(l_idx,:)=xy_matrix(:)';
    end
    light_intensity_vector = L*normal;
    error_vector = (to_cal_parameter*parameter).*light_intensity_vector-intense;
    error_vector = error_vector.^2;
    error = sum(error_vector);
end