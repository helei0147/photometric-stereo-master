function show_normal( normal, mask, title_temp )
%SHOW_NORMAL �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
    zz = auto_fill_im(normal,mask);
    figure;
    imagesc(uint8((zz+1)*128));
    title(title_temp);
    axis equal;
end

