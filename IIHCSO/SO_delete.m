function SO = SO_delete(pos1,pos2)
    n = length(pos1)/3;
    cnt = 1;
    for i = 1 : n
        for j = i + 1 : n
            if pos1(i) ~= pos2(j)
                SO(cnt).x = i;
                SO(cnt).y = j;
            end
        end
    end
end

