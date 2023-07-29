function SO = SO_add(SO1,SO2)
    
    for i = 1 : length(SO1)
        SO(i) = SO1(i);
    end
    if ~isempty(SO2)
     for i=1 : length(SO2)
         SO(i+length(SO1)) = SO2(i);
     end
    end
end

