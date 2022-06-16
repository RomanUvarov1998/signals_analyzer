function [RRx, RRy, SSx, SSy, DDx, DDy, RRx_old, RRy_old, SSx_old, SSy_old, DDx_old, DDy_old] = calc_ritmogramms(signals, t_span, RR_max_diff, SS_max_diff, DD_max_diff)
    t = signals.Time;
    
    if isempty(t_span)
        t_span = [t(1), t(end)];
    end

    RR_inds = logical(signals.R_Pik);
    RR_starts = t(RR_inds);
    
    RR_span_inds = t_span(1) <= RR_starts & RR_starts <= t_span(end);
    RR_starts = RR_starts(RR_span_inds);
    
    RR_lenghts = diff(RR_starts); % [R2-R1, R3-R2, R4-R3, ...]
    RR_starts = RR_starts(1 : end - 1);
    
    RRx = RR_starts;
    RRy = RR_lenghts;
    
    RRx_old = RRx; RRy_old = RRy;
    if ~isempty(RRx) || ~isempty(RRy)
        [RRx, RRy] = remove_ritmogramm_outliers(RRx, RRy, RR_max_diff, 'RR');
    end
    
    % систолы
    SS_inds = logical(signals.Sis);
    
    SS_span_inds = SS_inds & t_span(1) <= t & t <= t_span(end);
    
    SSx = t(SS_span_inds);
    SSy = signals.Press(SS_span_inds);
    
    SSx_old = SSx; SSy_old = SSy;
    if ~isempty(SSx) || ~isempty(SSy)
        [SSx, SSy] = remove_ritmogramm_outliers(SSx, SSy, SS_max_diff, 'SS');
    end
    
    % диастолы
    DD_inds = logical(signals.Dia);
    
    DD_span_inds = DD_inds & t_span(1) <= t & t <= t_span(end);
    
    DDx = t(DD_span_inds);
    DDy = signals.Press(DD_span_inds);
    
    DDx_old = DDx; DDy_old = DDy;
    if ~isempty(DDx) || ~isempty(DDy)
        [DDx, DDy] = remove_ritmogramm_outliers(DDx, DDy, DD_max_diff, 'DD');
    end
end