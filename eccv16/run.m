addpath('..')
% load ground truth
load('../data/mats/rabbit.mat');
% load light
lights_89 = load('../data/lighting/lights_89.txt');
lights = reshape(lights_89,3,[])';
lights(:,3)=-lights(:,3);
L = lights;
light_number=size(lights,1);
f = light_number;
p = size(find(mask>0),1);
M = zeros(p,f);
mask = mask>0;
% read in auto exposure images in M
for i = 1:89
    image = imread(sprintf('ae_data/%d.png',i));
    R = image(:,:,1);G = image(:,:,2);B = image(:,:,3);
    img(:,1) = R(mask);
    img(:,2) = G(mask);
    img(:,3) = B(mask);
    psu_hdr_vec = to_psu_hdr_vec(img);
    gs_vec = psu_hdr_vec*[0.2989;0.5870;0.1140];
    M(:,i) = gs_vec;
end
D1 = kron(speye(p),L);% f*pÐÐ£¬3*pÁÐ
D2 = sparse(zeros(f));
D2(eye(f)>0) = M(1,:);
for i = 2:p
    temp(speye(f)>0) = M(i,:);
    D2 = [D2,temp];
end
D = [D1,D2'];
y = null(D,'r');