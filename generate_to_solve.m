function [ to_solve ] = generate_to_solve( L, n )
%GENERATE_TO_SOLVE 1+x+x^2+y+x*y+x^2*y+y^2+x*y^2+x^2*y^2
%   h: average of vision and light
%   x: h*n y: L*n
    v = zeros(size(L));
    v(:,3) = -1;
    h = normalize_vectors(v+L);
    y = sum(L.*h,2);
    x = h*n;
    to_solve = [ones(size(L,1),1), x, x.^2, ...
        y, x.*y, (x.^2).*y, y.^2, x.*(y.^2), (x.^2).*(y.^2)];

end

