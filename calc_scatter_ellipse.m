function [sc_x, sc_y, el_x, el_y, el_params] = calc_scatter_ellipse(intervals)
    sc_x = intervals(1 : end - 1);
    sc_y = intervals(2 : end);
    
    % Магическим образом находим матрицу эллипса и его центр
    % Код украден с:
    % https://viewer.mathworks.com/?viewer=plain_code&url=https%3A%2F%2Fwww.mathworks.com%2Fmatlabcentral%2Fmlc-downloads%2Fdownloads%2Fsubmissions%2F9542%2Fversions%2F3%2Fcontents%2FMinVolEllipse.m&embed=web
    [A, c] = MinVolEllipse([sc_x, sc_y]', 0.01);
    
    % Собственные числа и вектора матрица А
    [V, D] = eig(A);
    
    % Полуоси эллипса
    a = 1 / sqrt(D(1, 1));
    b = 1 / sqrt(D(2, 2));
    
    % Множество точек Х у неповернутого эллипса с центом (0; 0)
    el_x = linspace(-a, a, 1000);
    % Множество точек Y у неповернутого эллипса с центом (0; 0)
    el_y = b .* (1 - (el_x ./ a) .^ 2) .^ 0.5;
    % Вторая половина эллипса
    el_x = [el_x, flip(el_x)];
    el_y = [el_y, -flip(el_y)];
    
    % Угол поворота эллипса
    theta = -atand(V(1, 2) / V(1, 1));
    % Матрица поворота эллипса
    R = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
    
    % Поворачиваем эллипс
    el_pts = [el_x; el_y]';
    el_pts = el_pts * R;
    
    el_x = el_pts(:, 1);
    el_y = el_pts(:, 2);
    
    % Устанавливаем центр эллипса
    el_x = el_x + c(1);
    el_y = el_y + c(2);
    
    % Параметры эллипса
    el_params.a = a; 
    el_params.b = b;
    el_params.square = pi * a * b; 
    el_params.m_sr = mean(intervals); 
    el_params.interv_min = min(intervals); 
    el_params.interv_max = max(intervals); 
    el_params.interv_range = el_params.interv_max - el_params.interv_min;
    el_params.mo = mode(intervals);
end

