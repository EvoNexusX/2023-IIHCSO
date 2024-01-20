function res = swap(sequence, swap)
    temp = sequence(swap(1));
    sequence(swap(1)) = sequence(swap(2));
    sequence(swap(2)) = temp;
    res = sequence;
    clear temp;
end
