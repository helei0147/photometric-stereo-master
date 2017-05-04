clear all

image_path = 'data/images/55_6_png_1';
light_file = 'data/lighting/light_89.txt';
mat_file = 'data/mats/rabbit.mat';


%     load mask
load(sprintf('%s',mat_file));
mask = uint8(mask);
v_ind=find(mask>0);
%     load light source info
load(sprintf('%s',light_file));
lights = reshape(light_89,3,[])';
lights(:,3)=-lights(:,3);
light_number=size(lights,1);
light_true=lights;

I = cell(light_number,1);
for i=1:light_number
    filename=sprintf('%s/%d.png',image_path,i-1);
    image = imread(filename);
    I{i}=image;
end
N = compute_surfNorm(I, light_true, mask);
N(:,:,3)=-N(:,:,3);
cal_n_error(N,nn2,v_ind);
h = show_surfNorm(N, 4);
saveas(h, './results/rabbit_norm2_no_reverse.png');