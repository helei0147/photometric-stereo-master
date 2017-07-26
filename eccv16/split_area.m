lights_89 = load('../data/lighting/lights_89.txt');
L = reshape(lights_89,3,[])';
L(:,3)=-L(:,3);
light_num = size(L,1);
area_index = [1,1,1,1,1];
for i = 1:light_num
    if (L(i,1)<=0)&&(L(i,2)<=0)
        area1(area_index(1)) = i;
        area_index(1)=area_index(1)+1;
    elseif (L(i,1)<=0)&&(L(i,2)>0)
        area2(area_index(2)) = i;
        area_index(2) = area_index(2)+1;
    elseif(L(i,1)>0)&&(L(i,2)<=0)
        area3(area_index(3)) = i;
        area_index(3) = area_index(3)+1;
    else
        area4(area_index(4)) = i;
        area_index(4) = area_index(4)+1;
    end
    if L(i,3)>0.9
        area5(area_index(5)) = i;
        area_index(5) = area_index(5)+1;
    end
end
figure;
plot3(L(area1,1),L(area1,2),L(area1,3),'r.', ...
L(area2,1),L(area2,2),L(area2,3),'g.', ...
L(area3,1),L(area3,2),L(area3,3),'b.', ...
L(area4,1),L(area4,2),L(area4,3),'c.', ...
L(area5,1),L(area5,2),L(area5,3),'co');