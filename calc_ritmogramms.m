function [RRx, RRy, SSx, SSy] = calc_ritmogramms(signals, t_span)
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
    
    % то же самое, что и с ритмограммой ЭКГ
    SS_inds = logical(signals.Sis);
    SS_starts = t(SS_inds);
    
    SS_span_inds = t_span(1) <= SS_starts & SS_starts <= t_span(end);
    SS_starts = SS_starts(SS_span_inds);
    
    SS_lenghts = diff(SS_starts);
    SS_starts = SS_starts(1 : end - 1);
    
    SSx = SS_starts;
    SSy = SS_lenghts;
end