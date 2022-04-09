function [RRpsd_f, RRpsd, SSpsd_f, SSpsd, CPSD, CPSD_f] = calc_psd_welch_an_cpsd(t, RRx, RRy, SSx, SSy)
    w = 100;
    noverlap = round(w .* 0.5);
    nfft = 128;
    
    Fs = 4; % Hz
    Ts = 1 / Fs; % sec
    t_interp = 0 : Ts : t(end);
    
    % Интерполяция ритмограммы для промежутка времени от начала первого
    % RR-интервала до конца последнего RR-интервала
    % параметр сглаживания выбран равным 1, потому что при нем кривая идет через все точки
    pol_info = csaps(RRx, RRy, 1);
    RR_int = ppval(pol_info, t_interp);
    
    pol_info = csaps(SSx, SSy, 1);
    SS_int = ppval(pol_info, t_interp);
    
    % Убираем постоянную составляющую и линейный тренд
    RR_int = detrend(RR_int);
    SS_int = detrend(SS_int);

    % СПМ Уэлча
    [RRpsd, RRpsd_f] = pwelch(RR_int, w, noverlap, nfft, Fs);
    [SSpsd, SSpsd_f] = pwelch(SS_int, w, noverlap, nfft, Fs);
    
    % Кросс-СПМ
    [CPSD, CPSD_f] = cpsd(RR_int, SS_int, w, noverlap, nfft, Fs);
    
    % Кросс СПМ возвращается в виде комплексных чисел, берем от них амплитуду
    CPSD = abs(CPSD);
end