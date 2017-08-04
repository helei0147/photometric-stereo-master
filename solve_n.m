function [ error ] = solve_n( n, L, valid_buffer, parameter)
%SOLVE_N fixed BRDF parameters, solve normal of this pixel
%   此处显示详细说明
    valid_light_number = size(L,1);
    v = kron(ones(valid_light_number,1),[0,0,-1]);
    h = L+v;
    h = normalize_vectors(h);
    y = sum(L.*h,2);
    ys = [ones(valid_light_number,1),y,y.*y];
    vec0 = ys*parameter([1,4,7]);
    vec1 = ys*parameter([2,5,8]);
    vec2 = ys*parameter([3,6,9]);
    part0 = vec0;
    part1 = [vec1, vec1, vec1].*h;
    part1 = sum(part1,2);
    h1 = h(:,1);
    h2 = h(:,2);
    h3 = h(:,3);
    q = 2*h1.*h2*n(1)*n(2)+2*h1.*h3*n(1)*n(3)+2*h2.*h3*n(2)*n(3)...
        +h1.*h1*n(1)^2+h2.*h2*n(2)^2+h3.*h3*n(3)^2;
    part2 = vec2.*q;
    left = part0+part1+part2;
    light_intensity = L*n;
    error = (left.*light_intensity-valid_buffer).^2;
end

