% Rastrigin 函数定义
rastrigin = @(x) 10 * length(x) + sum(x.^2 - 10 * cos(2 * pi * x));

% 生成维度为 2 的随机向量
x1 = linspace(-5.12, 5.12, 100);
x2 = linspace(-5.12, 5.12, 100);
[X1, X2] = meshgrid(x1, x2);
X = [X1(:), X2(:)];
Y = rastrigin(X');

% Reshape Y back to 2D grid for surf plot
Y = reshape(Y, size(X1));

% 绘制 Rastrigin 函数的三维面图
figure;
surf(X1, X2, Y);
xlabel('x_1');
ylabel('x_2');
zlabel('Rastrigin(x)');
title('Rastrigin Function (2 Dimensions)');
