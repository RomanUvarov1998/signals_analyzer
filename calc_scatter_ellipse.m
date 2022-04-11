function [sc_x, sc_y, el_x, el_y, el_params, ax, ay, bx, by] = calc_scatter_ellipse(intervals, dots_percentage)
    sc_x = intervals(1 : end - 1);
    sc_y = intervals(2 : end);
    
    assert(length(sc_x) == length(sc_y));
    N = length(sc_x);
    
%     figure(4), cla, hold on, grid on; %
    
    lens = sqrt(sc_x .^ 2 + sc_y .^ 2);
    tangents = sc_y ./ sc_x;
    alphas = atand(tangents);
    phi = zeros(size(alphas));
    phi(alphas > 45) = alphas(alphas > 45) - 45;
    phi(alphas == 45) = 0;
    phi(alphas < 45) = 45 - alphas(alphas < 45);
    
    tx = lens .* cosd(phi);
    ty = lens .* sind(phi);
    
    assert(0.0 < dots_percentage && dots_percentage <= 1);
    
    dp = 1.0 - dots_percentage;
    p_from = dp / 2;
    p_to = 1.0 - dp / 2;
    
    ind_from = round(p_from * N);
    ind_to = round(p_to * N);
    
    ind_from = max(1, ind_from);
    ind_to = max(N, ind_to);
    
    tx = sort(tx);
    ty = sort(ty);
    
    tx = tx(ind_from : ind_to);
    ty = ty(ind_from : ind_to);
    
    ell_len = max(tx) - min(tx);
    ell_wid = max(ty) - min(ty);
    
    a = ell_len / 2;
    b = ell_wid / 2;
    
    el_x = linspace(-a, a, 1000);
    el_y = b .* (1 - (el_x ./ a) .^ 2) .^ 0.5;
    
    el_x = [el_x, flip(el_x)];
    el_y = [el_y, -flip(el_y)];
%     plot(el_x, el_y, 'g'); %
    
    % Оси
    ax = linspace(-a, a, 100);
    ay = ax .* 0;
    by = linspace(-b, b, 100);
    bx = by .* 0;
    
    % rotate
    theta = 45;
    R = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
    
    el_pts = [el_x; el_y];
    el_pts = R * el_pts;
    el_x = el_pts(1, :);
    el_y = el_pts(2, :);
    
    axy = [ax; ay];
    axy = R * axy;
    ax = axy(1, :);
    ay = axy(2, :);
    
    bxy = [bx; by];
    bxy = R * bxy;
    bx = bxy(1, :);
    by = bxy(2, :);
    
%     plot(el_x, el_y, 'm'); %
    
    % shift
    x0 = (max(sc_y) + min(sc_y)) / 2;
    y0 = (max(sc_x) + min(sc_x)) / 2;
    
    el_x = el_x + x0;
    el_y = el_y + y0;
    
    ax = ax + x0;
    ay = ay + y0;
    
    bx = bx + x0;
    by = by + y0;
    
%     scatter(sc_x, sc_y, 'b'); %
%     plot(el_x, el_y, 'r'); %
%     plot(ax, ay, '--k'); %
%     plot(bx, by, '--m'); %
    
    % Параметры эллипса
    el_params.ell_len = ell_len; 
    el_params.ell_wid = ell_wid;
    el_params.square = pi * a * b; 
    el_params.m_sr = mean(intervals); 
    el_params.interv_min = min(intervals); 
    el_params.interv_max = max(intervals); 
    el_params.interv_range = el_params.interv_max - el_params.interv_min;
    el_params.mo = mode(intervals);
end

