function [optimized_error,optimized_n] = optimize_normal(n,h,y,valid_light_num,para_num,L,parameter,intense,nn,i,error)
%         optimize normal of this pixel
    new_n = n;

    func=@(d1,d2,d3)error_n(d1,d2,d3,h,y,valid_light_num,para_num,L,parameter,intense);
    syms puppy(normal1,normal2,normal3)
    puppy(normal1,normal2,normal3) = func(normal1,normal2,normal3);
    derivative_normal1 = diff(puppy,normal1);
    derivative_normal2 = diff(puppy,normal2);
    derivative_normal3 = diff(puppy,normal3);
    step = 5e-5;

    gt=nn(i,:);
    normal_iter_times = 200;
    normal_error = zeros(normal_iter_times,1);
    normal_error_index = 1;
    iter_normal = 1;
    while iter_normal <normal_iter_times
        d1 = eval(derivative_normal1(new_n(1),new_n(2),new_n(3)));
        d2 = eval(derivative_normal2(new_n(1),new_n(2),new_n(3)));
        d3 = eval(derivative_normal3(new_n(1),new_n(2),new_n(3)));
        delta = [d1;d2;d3];
        delta = delta/norm(delta);
        temp = new_n+delta*step;
        temp = temp/norm(temp);
        normal_error(iter_normal) = acos(gt*temp)/pi*180;
        if iter_normal==1
            if normal_error(iter_normal)>error% if optimized n is worse than origin, initial error, jump out 
                new_n = n;
                normal_error(normal_error_index)=error;
                break
            else % update
                new_n=temp;
                normal_error_index=normal_error_index+1;
            end
        elseif normal_error(iter_normal-1)-normal_error(iter_normal)<1e-7
            break
        else
            new_n=temp;
            normal_error_index=normal_error_index+1;
        end
        iter_normal=iter_normal+1;
    end
    optimized_error = normal_error(normal_error_index);

    optimized_n=new_n;
end