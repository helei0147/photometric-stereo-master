for i = 0:99
    [I,L] = public(i);
    normal = factorization(I,L);
    error = normal_error(normal,nn);
    avg_error(i+1) = sum(error)/size(error,1);
end