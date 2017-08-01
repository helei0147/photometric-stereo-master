for i = 59:59
    [I,L] = public(i);
    
    mask_for_I = [3,5,6,7,9:19,21,23,25];
    I = I(:,mask_for_I);
    L = L(mask_for_I,:);

    normal = factorization(I,L);
    error = normal_error(normal,nn);
    avg_error(i+1) = sum(error)/size(error,1);
end