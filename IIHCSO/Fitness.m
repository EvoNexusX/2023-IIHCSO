%fitness(1) = tot_wait,fitness(2) = vessel safe distance offset
%fitness(3) = QC distance offset
%x(1:n) priorities of vessels
%x(n+1,2*n) berth position
%x(2*n+1,3*n) the number of QCs
function fitness = Fitness(x,ship)
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
    brideg_offset = 0; 
    ship_t= ship(:,1); 
    ship_w = ship(:,2);
    ship_len = ship(:,3); 
    ship_Qm = ship(:,4); 
    n = length(ship_t);
    CoastLen = 3000;
    Coast = zeros(1,CoastLen); 
    Bridge = zeros(1,NumBridge);
    Berthing_time = zeros(1,n); 
    Offduty_time = zeros(1,n); 
    for i = 1 : n
        no = x(i);
        
        if x(i+n) + ship_len(no) > CoastLen 
            ship_offset = ship_offset + x(i+n) + ship_len(no)-CoastLen ;
            x(i+n) =  x(i+n) + ship_len(no)-CoastLen ;
        end
        if x(i+n) <= 0
            x(i+n) = 1 ;
            ship_offset = ship_offset + 1;
        end
        if ship_t(no) > Coast(x(i+n)) && ship_t(no) > Coast(x(i+n) + ship_len(no)) 
            Berthing_time(i) = ship_t(no);
        else
            cdis = 0;
            ctime = max(Coast(x(i+n)),Coast(x(i+n)+ship_len(no)));

            for j = 1 : floor(0.1*ship_len(no))  
                if x(i+n) + ship_len(no) + j > CoastLen
                    break;
                end
                if ctime - ship_t(no) <=0
                    break;
                end
                now_time = max(Coast(x(i+n)+j),Coast(x(i+n)+ship_len(no))+j);
                if now_time < ctime
                    cdis = j;
                    ctime = now_time;
                end
            end

            for j = 1 : floor(0.1*ship_len(no)) 
                if x(i+n)  - j <= 0
                    break;
                end
                if ctime - ship_t(no) <=0
                    break;
                end
                now_time = max(Coast(x(i+n)-j),Coast(x(i+n)+ship_len(no))-j);
                if now_time < ctime
                    cdis = -j;
                    ctime = now_time;
                end
            end
            ctime = max(0,ctime - ship_t(no));
            x(i+n) = x(i+n) + cdis;
            ship_offset = ship_offset + abs(cdis);
            Berthing_time(i) = ship_t(no) + ctime;
        end


        
        Left_bridge = Qc(x(i+n));
        Right_Bridge = Left_bridge + x(i+2*n) - 1;
        if x(i+2*n) > ship_Qm(no)
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
        cw = ship_w(no)/cnt;
        cnt = 0;
        for j = Left_bridge : Right_Bridge
            if Bridge(j) <= cw
                ship_w(no) = ship_w(no) + Bridge(j);
                cnt = cnt + 1;
            end
        end
        ship_w(no) = ship_w(no)/cnt;
        for j = Left_bridge : Right_Bridge
            if Bridge(j) <= cw
                Bridge(j) = ship_w(no);
            end
            Bridge(j) = Bridge(j) + Berthing_time(i) + ctime;
        end
        Offduty_time(i) = Berthing_time(i) + ctime + ship_w(no);
        Coast = Vis_Bridge_Coast(Coast,x(i+n),x(i+n)+ship_len(no),Offduty_time(i));
        total_wait = total_wait+ctime + Offduty_time(i) - Berthing_time(i);
    end
    
    fitness = zeros(1,3);
    fitness(1) = total_wait;
    fitness(2) = ship_offset;
    fitness(3) = brideg_offset;
end

