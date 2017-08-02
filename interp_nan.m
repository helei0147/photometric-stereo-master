function [ channel ] = interp_nan( normal )
%INTERP_NAN �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
    channel1 = normal(:,1);
    valid_index = find(isnan(channel1)<1);
    channel = zeros(size(normal));
    for i = 1:3
        temp = normal(:,i);
        not_nan = temp(valid_index);
        channel(:,i) = interp1(valid_index,not_nan,1:size(normal,1),'spline');
    end
    len = sum(channel.*channel,2);
    len = len.^0.5;
    channel = channel./[len, len, len];
end

