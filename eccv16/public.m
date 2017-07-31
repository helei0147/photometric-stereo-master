function [I,L] = public(material_index)
% load light
lights = load('../data/lighting/lights_25.txt');
lights = reshape(lights,3,[])';
% lights(:,3) = -lights(:,3);
L = lights;
light_number=size(lights,1);
rgb_path = sprintf('../data/images/rabbit_all/lights_25/hdr/%d_6',material_index);
load('rabbit.mat');
scale_width = 10; scale_height = 10;
mask = mask>0;
width = size(mask,2); height = size(mask,1);
mask_origin = mask;
slice = zeros(size(mask));
load('rabbit_small.mat');
tiny_width = size(mask,2); tiny_height = size(mask,1);

slice_tiny = zeros(size(mask));
valid_pixel_num = size(find(mask>0),1);
I = zeros(valid_pixel_num,light_number);
f = light_number;
p = valid_pixel_num;
for i = 0:light_number-1
    filename = sprintf('%s/%d.rgb',rgb_path,i);
    img = load_rgb(filename);
    gs = img*[0.2989;0.5870;0.1140];
    slice(mask_origin) = gs;
    slice_tiny = slice(1:scale_height:end,1:scale_width:end);
    I(:,i+1) = slice_tiny(mask>0);
end
% scale on light
if exist('random_25.mat')
    load('random_25.mat');
else
    random = rand(light_number,1);
    save('random_25.mat','random');
end
diff_percentage = 0.08;
scale = 1-diff_percentage+2*random*diff_percentage;
I = I.*kron(ones(valid_pixel_num,1),scale');
end