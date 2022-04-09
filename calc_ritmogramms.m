function [RRx, RRy, SSx, SSy] = calc_ritmogramms(signals)
    t = signals.Time;

    % Вектор флагов R-зубцов переводим в логический формат
    RR_inds = logical(signals.R_Pik);
    % Вектор значений времени для R-зубцов
    RR_starts = t(RR_inds);
    % Вектор длин RR-интервалов
    RR_lenghts = diff(RR_starts); % [R2-R1, R3-R2, R4-R3, ...]
    % Последний R-зубец сигнала не является началом следующего RR-интервала (потому что 
    % следующего RR-интервала нет), поэтому не берем его
    RR_starts = RR_starts(1 : end - 1);
    
    RRx = RR_starts;
    RRy = RR_lenghts;
    
    % то же самое, что и с ритмограммой ЭКГ
    ABP_S_inds = logical(signals.Sis);
    ABP_S_starts = t(ABP_S_inds);
    ABP_S_lenghts = diff(ABP_S_starts);
    ABP_S_starts = ABP_S_starts(1 : end - 1);
    
    SSx = ABP_S_starts;
    SSy = ABP_S_lenghts;
end