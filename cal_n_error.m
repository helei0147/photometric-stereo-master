function [ normal_error ] = cal_n_error( new_N, nn2, v_ind )
%CAL_N_ERROR �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
    masklength=size(v_ind,1);
    acos_error = acos(sum(new_N.*nn2,3))/pi*180;
    N_degree_error=sum(abs(acos_error(v_ind)))/masklength;
    disp(['N degree error:' num2str(N_degree_error)]);
    normal_error = N_degree_error;
end

