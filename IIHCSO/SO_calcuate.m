function pos = SO_calcuate(pos1,SO)
    for i = 1 : length(SO)
        x = SO(i).x;
        y = SO(i).y;
        temp = pos1(x);
        pos1(x) = pos1(y);
        pos1(y) = temp;
    end
    pos = pos1;
end

