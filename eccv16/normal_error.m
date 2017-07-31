function [error] = normal_error(normal1, normal2)
    to_acos = sum(normal1.*normal2,2);
    error = acos(to_acos)/pi*180;
    fprintf(sprintf('error:%f\n',sum(error)/size(error,1)));
end