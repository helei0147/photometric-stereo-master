function [n] = normalize_normal(normal)
    len = sum(normal.*normal,2);
    len = len.^0.5;
    n = normal./[len, len, len];
end