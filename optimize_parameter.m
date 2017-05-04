function error = optimize_parameter(para,to_solve,light_intensity,valid_buffer)
error_vector = (to_solve*para).*light_intensity-valid_buffer;
error_vector = error_vector.^2;
error = sum(error_vector);
end