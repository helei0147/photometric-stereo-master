function [optimized_error,optimized_n] = optimize_normal(n,h,y,L,parameter,intense,ground_truth,error)
%         optimize normal of this pixel
% try to optimize the normal, but if the optimized result is worse than
% origin, use the origin result instead.
    new_n = n;
    valid_light_num = size(L,1);
    func=@(d1,d2,d3)error_n(d1,d2,d3,h,y,L,parameter,intense);
    syms puppy(normal1,normal2,normal3)
    puppy(normal1,normal2,normal3) = func(normal1,normal2,normal3);
    derivative_normal1 = diff(puppy,normal1);
    derivative_normal2 = diff(puppy,normal2);
    derivative_normal3 = diff(puppy,normal3);
    step = 1e-5;

    gt=ground_truth;
    
    d1 = eval(derivative_normal1(new_n(1),new_n(2),new_n(3)));
    d2 = eval(derivative_normal2(new_n(1),new_n(2),new_n(3)));
    d3 = eval(derivative_normal3(new_n(1),new_n(2),new_n(3)));
    delta = [d1;d2;d3];
    delta = delta/norm(delta);
    temp = new_n+delta*step;
    temp = temp/norm(temp);
    current_error = acos(gt*temp)/pi*180;
    if current_error>error
        optimized_error = error;
        optimized_n = n;
    else
        optimized_error = current_error; 
        optimized_n=new_n;
    end
end