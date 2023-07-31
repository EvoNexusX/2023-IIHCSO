function SO = SO_Multiplication(c,SO1)
    c = max(1,floor(10*c));
    c = min(c,length(SO1));
    SO = SO1(1:c);
end

