function error = error_n(n1,n2,n3,h,y,L,parameter,intense)
    normal = [n1;n2;n3];
    valid_light_num = size(L,1);
    x=h*normal;
%     to_cal_parameter=zeros(valid_light_num,para_num);
    t_x = [ones(valid_light_num,1),x,x.^2];
    t_y = [ones(valid_light_num,1),y,y.^2];

    for l_idx=1:valid_light_num
        temp1 = t_x(l_idx,:).';
        temp2 = t_y(l_idx,:);
        xy_matrix=temp1*temp2;% 3 x 3 matrixf
        to_cal_parameter(l_idx,:)=xy_matrix(:).';
    end
    light_intensity_vector = L*normal;
    error_vector = (to_cal_parameter*parameter).*light_intensity_vector-intense;
    error_vector = error_vector.^2;
    error = sum(error_vector);
end