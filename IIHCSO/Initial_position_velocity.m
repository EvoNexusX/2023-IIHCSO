function [Position,Velocity,SO] = Initial_position_velocity(n,Dimension,Size,Xmax,Xmin,Vmax,Vmin)
  for i=n+1:Dimension
      Position(i,:)=Xmin(i)+(Xmax(i)-Xmin(i))*rand(1,Size); % 产生合理范围内的随机位置，rand(1,Size)用于产生一行Size个随机数
      Velocity(i,:)=Vmin(i)+(Vmax(i)-Vmin(i))*rand(1,Size);
  end
  for i = 1 : Size
      num = max(1,floor(rand*n));
      for j = 1 : num
          SO(j,i).x = max(1,floor(rand*n));
          SO(j,i).y = max(1,floor(rand*n));
      end
  end
end
