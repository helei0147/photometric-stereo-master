function error = error_n(x,h,y,L,parameter,intense)
    normal = [n1;n2;n3];
    valid_light_num = size(L,1);
    x=h*normal;
%     to_cal_parameter=zeros(valid_light_num,para_num);

    to_cal_parameter = [ones(valid_light_num,1), y, y.*y, x, x.*y, x.*y.*y, x.*x, x.*x.*y, x.*x.*y.*y];
    
    light_intensity_vector = L*normal;
    Lp = light_intensity_vector*parameter;
    block = to_cal_parameter.*Lp;
    b1 = block(:,1:3);
    b2 = block(:,4:6);
    b3 = block(:,7:9);
    part1 = sum(b1,2);
    part2 = sum(b2,2);
    part3 = sum(b3,2);
    error_vector = part1+part2.*x+part3.*x.*x;
    error_vector = error_vector.^2;
    error = sum(error_vector);
end