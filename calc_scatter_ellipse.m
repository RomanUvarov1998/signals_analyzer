function [sc_x, sc_y, el_x, el_y] = calc_scatter_ellipse(intervals)
    sc_x = intervals(1 : end - 1);
    sc_y = intervals(2 : end);
    
    % Аппроксимируем линейной регрессией
    x = [sc_x'; ones(1, length(sc_y))];
    k = sc_y' / x;
    
%     figure(4), cla, hold on, grid on;
%     xlim([0, max(sc_x) + 1]);
%     ylim([0, max(sc_y) + 1]);
    
    % Найдем угол наклона прямой
    theta = atand(k(1));
    
    % Повернем точки скаттерограммы вокруг (0; 0) по часовой стрелке,
    % чтобы полуоси эллипса были параллельны осям координат
    R = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
    pts = [sc_x, sc_y] * R;
    
%     scatter(pts(:, 1), pts(:, 2), 'r');
    
    % Найдем описывающий прямоуольник
    max_pt = max(pts);
    min_pt = min(pts);
    
    % Найдем центр описывающего прямоуольника
    center = (max_pt + min_pt) ./ 2;
%     plot(center(1), center(2), '*g');
    ab = max(pts - center);
    
    % Найдем полуоси как половины сторон описывающего прямоуольника
    a = ab(1);
    b = ab(2);
    
    % Создалим точки эллипса по его уравнению
    el_x = linspace(-a, a, 1000);
    el_y = b .* (1 - (el_x ./ a) .^ 2) .^ 0.5;
    el_x = [el_x, flip(el_x)];
    el_y = [el_y, -flip(el_y)];
    
    % Сместим его к центру повернутой скаттерограммы
    el_x = el_x + center(1);
    el_y = el_y + center(2);
    
    el_pts = [el_x; el_y];
    
%     plot(el_x, el_y, 'b');
    
    % Повернем эллипс обратно вокруг точки (0; 0) против часовой стрелки
    theta = -atand(k(1));
    R = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
    
    el_pts = el_pts' * R;
    
    el_x = el_pts(:, 1);
    el_y = el_pts(:, 2);

%     scatter(sc_x, sc_y, 'b');
%     plot(el_x, el_y, 'r');

%     center = center * R;
%     plot(center(1), center(2), '*y');
% 
%     plot(max_pt(1), max_pt(2), '*g');
%     plot(min_pt(1), min_pt(2), '*k');
end

