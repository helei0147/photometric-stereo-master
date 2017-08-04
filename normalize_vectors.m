function [normals] = normalize_vectors(directions)
    len = sum(directions.^2,2);
    len = len.^0.5;
    normals = directions./[len, len, len];
end