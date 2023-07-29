function check = epsiloncomper(fit1,fit2,t,N,e0)
    G=N;
    Tc = 0.5;
    c = -(log(e0)+5)/(log(1-Tc));
    if t/G <= Tc
        e = e0*(1-t./G)^(c);
    else
        e = 0;
    end
    if sum(fit1(2:3)) <= e && sum(fit2(2:3)) <= e
        if fit1(1) < fit2(1)
            check = 1;
        else
            check = 0;
        end
    else
        if sum(fit1(2:3) < fit2(2:3))
            check = 1;
        else
            check = 0;
        end
    end
end

