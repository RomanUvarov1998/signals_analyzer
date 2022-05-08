function inds_matrix = find_power_spans(Td, power)
    power_diff = diff(power);
    
    power_change_treshold = 8;
    min_power = 40;
    skip_time_sec = 10;
    skip_points_count = round(skip_time_sec / Td);
    
    changes_inds = power_diff >= power_change_treshold;
    
    power_change_moments = find(changes_inds);
    
    inds_matrix = zeros(0, 2);
    
    % Если вначале сигнала мощность подходит порогу, добавляем это начало
    if power(1) >= min_power && power_change_moments(1) > 1
        power_change_moments = [1; power_change_moments];
    end
    
    if isempty(power_change_moments)
        inds_matrix = [];
        return;
    end
    
    % Ищем конец последнего промежутка
    last_n = power_change_moments(end);
    last_span_end = find(power_diff(last_n : end) < 0, 1);
    power_change_moments = [power_change_moments; last_span_end + last_n - 1];
    
    for n = 1 : length(power_change_moments) - 1
        n_begin = power_change_moments(n);
        n_end = power_change_moments(n + 1);
        
        % пропустим промежуток, который меньше пропускаемого вначале времени
        if n_end - n_begin <= skip_points_count
            continue;
        end
        
        % пропустим момент, который по уровню мощности меньше 40Вт
        n_middle = round((n_begin + n_end) / 2);
        if power(n_middle) < min_power
           continue; 
        end
        
        inds_matrix = [inds_matrix; ...
            n_begin + skip_points_count, n_end];
    end
end

