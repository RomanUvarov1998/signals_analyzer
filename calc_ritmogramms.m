function [RRx, RRy, SSx, SSy, RRx_old, RRy_old, SSx_old, SSy_old] = calc_ritmogramms(signals, t_span, RR_max_diff, SS_max_diff)
    t = signals.Time;
    
    if (nargin == 1)
        t_span = [t(1), t(end)];
    end
    
    % Вектор флагов R-зубцов переводим в логический формат
    RR_inds = logical(signals.R_Pik);
    % Вектор значений времени для R-зубцов
    RR_starts = t(RR_inds);
    
    RR_span_inds = t_span(1) <= RR_starts & RR_starts <= t_span(end);
    RR_starts = RR_starts(RR_span_inds);
    
    % Вектор длин RR-интервалов
    RR_lenghts = diff(RR_starts); % [R2-R1, R3-R2, R4-R3, ...]
    % Последний R-зубец сигнала не является началом следующего RR-интервала (потому что 
    % следующего RR-интервала нет), поэтому не берем его
    RR_starts = RR_starts(1 : end - 1);
    
    RRx = RR_starts;
    RRy = RR_lenghts;
    
    RRx_old = RRx; RRy_old = RRy;
    [RRx, RRy] = remove_ritmogramm_outliers(RRx, RRy, RR_max_diff);
    
    % то же самое, что и с ритмограммой ЭКГ
    SS_inds = logical(signals.Sis);
    SS_starts = t(SS_inds);
    
    SS_span_inds = t_span(1) <= SS_starts & SS_starts <= t_span(end);
    SS_starts = SS_starts(SS_span_inds);
    
    SS_lenghts = diff(SS_starts);
    SS_starts = SS_starts(1 : end - 1);
    
    SSx = SS_starts;
    SSy = SS_lenghts;
    
    SSx_old = SSx; SSy_old = SSy;
    [SSx, SSy] = remove_ritmogramm_outliers(SSx, SSy, SS_max_diff);
end