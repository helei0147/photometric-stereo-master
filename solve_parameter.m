function [parameter, error] = solve_parameter(to_solve,light_intensity,valid_buffer)
% solve biquadratic parameters of pixel's BRDF
% light_intensity is n'*L_low, valid_buffer is pixel value from valid observations
% parameter is a vector with, error is each pixel value error vector
    parameter_length = size(to_solve,2);
    light_intensity_matrix = kron(ones(1,parameter_length),light_intensity);
    A = to_solve.*light_intensity_matrix;
    parameter = (A.'*A)\(A.'*valid_buffer);
    error = (to_solve*parameter).*light_intensity-valid_buffer;
end