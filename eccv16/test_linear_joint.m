[I,L] = public(99);
% mask_for_I = [3,5,6,7,9:19,21,23,25];
% I = I(:,mask_for_I);
% L = L(mask_for_I,:);
light_number = size(L,1);
pixel_number = size(I,1);
y = linear_joint_dense(I,L);
e = y(pixel_number*3+1:end);
e = e.^-1;
b = y(1:pixel_number*3);
if sum(e)<0
    e = -e;
    b = -b;
end
n_ = reshape(b,3,[])';
len = sum(n_.*n_,2);
len = len.^0.5;
n = n_./[len len len];

load('rabbit_small.mat');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% n = -n;
% n(:,3) = -n(:,3);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
zz = zeros(size(nn2));
temp = zeros(size(nn2,1),size(nn2,2));
temp(mask) = n(:,1);zz(:,:,1) = temp;
temp(mask) = n(:,2);zz(:,:,2) = temp;
temp(mask) = n(:,3);zz(:,:,3) = temp;
figure(1);
imagesc(uint8((zz+1)*128));
title('RGB Normal Map');
axis equal;
figure(2);
imagesc(uint8((nn2+1)*128));
title('RGB Normal Map');
axis equal;

error = normal_error(n,nn);
sum(error)/size(error,1)