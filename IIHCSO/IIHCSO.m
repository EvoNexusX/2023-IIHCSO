%fun_num :Test cases
%c: Random number
%N: Number of evaluations
function bestfit = IIHCSO(fun_num,c,N)
    % Fixed random seed for easy debugging
    s1 = RandStream('mt19937ar', 'Seed', c); 
    RandStream.setGlobalStream(s1);
    tot = 0;
    ship = xlsread(fun_num);
    n = length(ship);
    Dimension=n*3;
    Size=n*10;
    cl_size = 10; 
    num = Size/cl_size; 
    fit_tot = zeros(Size,1);
    p_r=0.9;
    m = 4;
    p2 =0.5;
    p = 0.5; 
    phi = 0.1;
    Velocity_max(1:n) = 0;
    Velocity_max(n+1:2*n)=1;
    Velocity_max(2*n+1:3*n)=5;
    ub(1:n) = n;
    lb(1:n) = 1;
    ub(n+1:2*n)=3000 - ship(1:n,3);
    lb(n+1:2*n)=1;
    ub(2*n+1:3*n) = ship(1:n,4);
    lb(2*n+1:3*n) = 1;
    Position=zeros(Dimension,Size);
    Velocity=zeros(Dimension,Size);
    Vmax(1:Dimension)=Velocity_max;
    Vmin(1:Dimension)=-Velocity_max;
    Xmax(1:Dimension)=ub;
    Xmin(1:Dimension)=lb;
    [Position,Velocity,SO]=Initial_position_velocity(n,Dimension,Size,Xmax,Xmin,Vmax,Vmin);
    for i = 1 : Size
        for j = 1 : n
            Position(j,i) = j;
        end
    end
    Pbest_position=Position;
    Gbest_position=zeros(Dimension,1);
   
    for j=1:Size
        tot = tot + 1;
        Pos=Position(:,j);
        fz(:,j)=Fitness(Pos,ship);
        fit_tot(j) = sum(fz(:,j));
    end
    fitness_p = fz;
    xx = fitness_p(2,:);
    sort(xx);
    e0 = xx(2*n);
    Gbest_Fitness = fz(:,1);
    ub = repmat(ub,Size,1);
    ub = ub';
    lb = repmat(lb,Size,1);
    lb = lb';
    bestfit = 0x3f3f;
    H = zeros(Size,m); 
    H(:,1) = 1 : Size;
    Size_num = cl_size;
    vis = zeros(Size,m);
    for i = 2 : m
        Size_num = max(floor(Size_num * p),1);
        for j = 1 : num 
            [A,I] = sort(fit_tot((j-1)*cl_size+1:j*cl_size));
            H((j-1)*Size_num+1:Size_num*j,i) = I(1:Size_num)+(j-1)*cl_size;
            vis(I(1:Size_num)+(j-1)*cl_size,i) = 1;
        end
    end

    c = zeros(1,m); 
    for i = 1 : m
        c(i) = (m-i+1)./sum(1:m);
    end
    for i = 2 : m
        c(i) = c(i) + c(i-1);
    end
    while(tot <=N)
            for i = 1 :Size
                check = 0;
                r = rand(1);
                for j = 1 : m 
                   if r <= c(j)
                       k = j;
                       break;
                   end
                end
                r = rand();
                if r <= p2  %intra-competition
                    competitors = H(:,k);
                else   %inter-competition
                    competitors = H(:,min(k+1,m));
                end
                av_position = zeros(3*n,1);
                Goup = zeros(3*n,1);
                G_id=0;
                %Calcuate average of x and find group
                for k = 1 : length(competitors)
                    if competitors(k) == 0
                        break;
                    end
                    if floor(competitors(k)/cl_size) == floor(i/cl_size)
                        G_id = G_id+1;
                        Goup(G_id) = competitors(k);
                        av_position(n+1:3*n) = av_position(n+1:3*n)+Position(n+1:3*n,competitors(k));
                    end
                end
                av_position(n+1:3*n) = av_position(n+1:3*n)./cl_size;
                r = min(floor(G_id*rand(1)+1),G_id);
                r1 = rand();r2 = rand();r3 = rand();
                if epsiloncomper(fitness_p(:,Goup(r)),fitness_p(:,i),tot,N,e0) == 1
                     check = 1;
                     Velocity(n+1:3*n,i) = r1*Velocity(n+1:3*n,i) + r2*(Position(n+1:3*n,Goup(r))-Position(n+1:3*n,i))+r3*phi*(av_position(n+1:3*n) - Position(n+1:3*n,i)); 
                     SO1 = SO_Multiplication(r1,SO(:,i));
                     SO2 = SO_Multiplication(r2,SO_delete(Position(:,Goup(r)),Position(:,i)));
                     SO3 = SO_add(SO1,SO2);
                end
                if check == 1
                    
                    SO(1:length(SO3),i) = SO3;
                    
                    %Update Position
                    Position(:,i) = SO_calcuate(Position(:,i),SO3(:));
                    Position(n+1:3*n,i) = Position(n+1:3*n,i)+Velocity(n+1:3*n,i);
                    
                    %Limit position boundaries (reflect)
                    reflect = find(Position > ub);
                    Position_old = Position(reflect);
                    Position(reflect) = ub(reflect) - mod((Position(reflect) - ub(reflect)), (ub(reflect) - lb(reflect)));
                    Velocity(reflect) = Position(reflect) - Position_old;
                    reflect = find(Position < lb);
                    Position_old = Position(reflect);
                    Position(reflect) = lb(reflect) + mod((lb(reflect) - Position(reflect)), (ub(reflect) - lb(reflect)));
                    Velocity(reflect) = Position(reflect) - Position_old;
                    
                    if r > p2 && k+1 <=m && vis(i,k+1) == 0
                        for j = 1:Size
                            if H(j,k+1) == 0
                                break;
                            end
                        end
                        H(j,k+1) = i;
                        vis(i,k+1) = 1;
                    end
                    Pos=Position(:,i);
                    fitness_p(:,i)=Fitness(Pos,ship);
                     if epsiloncomper(fitness_p(:,i),Gbest_Fitness,tot,N,e0) == 1
                        Gbest_Fitness=fitness_p(:,i);
                        Gbest_position = Position(:,i);
                     end
                     bestfit = min(bestfit,Gbest_Fitness(1));
                     tot = tot + 1;
                end
            end
        %Limit speed boundary 
        for i=1:Size
            for row=1:Dimension
                if Velocity(row,i)>Vmax(row)
                    Velocity(row,i)=Vmax(row);
                elseif Velocity(row,i)<Vmin(row)
                    Velocity(row,i)=Vmin(row);
                else
                end
            end
        end
        
        %Limit position boundaries (reflect)
        reflect = find(Position > ub);
        Position_old = Position(reflect);
        Position(reflect) = ub(reflect) - mod((Position(reflect) - ub(reflect)), (ub(reflect) - lb(reflect)));
        Velocity(reflect) = Position(reflect) - Position_old;
        
        reflect = find(Position < lb);
        Position_old = Position(reflect);
        Position(reflect) = lb(reflect) + mod((lb(reflect) - Position(reflect)), (ub(reflect) - lb(reflect)));
        Velocity(reflect) = Position(reflect) - Position_old;
        
        %Repair method
        r_s = min(floor(Size*rand()+1),Size);
        if rand() <= p_r
            Position(:,r_s) = Repair(Position(:,r_s),ship);
        end
    end
    bestfit = Gbest_Fitness(1);
end