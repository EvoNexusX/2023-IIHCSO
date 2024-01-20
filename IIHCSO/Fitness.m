%fitness = tot_wait,offset = vessel safe distance offset
%x(1:n) berth position
%x(n+1,2*n) the number of QCs
%s(1:n) Priority sequence of ships
function [fitness,offset] = Fitness(x,s,ship)
    NumBridge = ship(1,5);
    Qc = zeros(1,3000);
    cnt = 1;
    for i = 1 : 3000
        if mod(i,floor(3000/NumBridge)) == 0
            cnt = cnt + 1;
        end
        Qc(i) = cnt;
     end
    x = round(x);
    total_wait = 0; 
    ship_offset = 0; 
    % arrival time
    ship_t= ship(:,1);
    % cargo
    ship_w = ship(:,2);
    % the length of ship
    ship_len = ship(:,3);
    % the number of QCs
    ship_Qm = ship(:,4); 
    n = length(ship_t);
    CoastLen = 3000;
    % Record when the coastline is free
    Coast = zeros(1,CoastLen); 
    Bridge = zeros(1,NumBridge);
    Berthing_time = zeros(1,n); 
    Offduty_time = zeros(1,n); 
    for i = s
        if ship_t(i) > Coast(x(i)) && ship_t(i) > Coast(x(i) + ship_len(i)) 
            Berthing_time(i) = ship_t(i);
        else
            ctime = max(Coast(x(i)),Coast(x(i)+ship_len(i)));
            for j = 1:floor(0.05*ship_len(i))
                if x(i) + ship_len(i) + j > CoastLen
                    break;
                end
                if x(i) - j < 1
                    break;
                end
                if Coast(x(i)-j) < ctime
                    ship_offset = ship_offset + 1;
                end
                if Coast(x(i)+j+ship_len(i)) < ctime
                    ship_offset = ship_offset + 1;
                end
                Berthing_time(i) = ctime;
            end
        end

        Left_bridge = Qc(x(i+n));
        Right_Bridge = Left_bridge + x(i+n) - 1;
        if x(i+n) > ship_Qm(i)
           brideg_offset = brideg_offset+ x(i+2*n) - ship_Qm(no);
           Right_Bridge = Left_bridge + ship_Qm(no) - 1;
        end
        if Right_Bridge > NumBridge
            brideg_offset = brideg_offset + Right_Bridge - NumBridge;
            Right_Bridge = NumBridge;
        end

        cnt = 0;
        ctime = Bridge(Left_bridge);
        for j = Left_bridge : Right_Bridge
            Bridge(j) = max(0,Bridge(j) - Berthing_time(i));
            ctime = min(ctime,Bridge(j));
        end
        for j = Left_bridge : Right_Bridge
            Bridge(j) = max(0,Bridge(j) - ctime);
            if Bridge(j) == 0
                cnt = cnt + 1;
            end
        end
        cw = ship_w(i)/cnt;
        cnt = 0;
        for j = Left_bridge : Right_Bridge
            if Bridge(j) <= cw
                ship_w(i) = ship_w(i) + Bridge(j);
                cnt = cnt + 1;
            end
        end
        ship_w(i) = ship_w(i)/cnt;
        for j = Left_bridge : Right_Bridge
            if Bridge(j) <= cw
                Bridge(j) = ship_w(i);
            end
            Bridge(j) = Bridge(j) + Berthing_time(i) + ctime;
        end
        Offduty_time(i) = Berthing_time(i) + ctime + ship_w(i);
        Coast = Vis_Bridge_Coast(Coast,x(i),x(i)+ship_len(i),Offduty_time(i));
        total_wait = total_wait+ Offduty_time(i) - ship_t(i);
    end
    fitness = total_wait;
    offset = ship_offset;
end

