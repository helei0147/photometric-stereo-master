function [error] = cal_degree_error(to_cal, ground_truth)
    to_cal = normalize_vectors(to_cal);
    ground_truth = normalize_vectors(ground_truth);
    cos_error = sum(to_cal.*ground_truth,2);
    error = acos(cos_error)/pi*180;
end