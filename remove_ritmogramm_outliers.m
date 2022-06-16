function [RRx, RRy] = remove_ritmogramm_outliers(RRx, RRy, max_diff, signal_type)
    assert(length(RRx) == length(RRy));
    
    if strcmp(signal_type, 'RR')
    
        for n = 2 : length(RRx)
            ratio = RRy(n) / RRy(n - 1);
            if ratio > 1.0 + max_diff
                old_value = RRy(n);
                RRy(n) = RRy(n - 1) * (1.0 + max_diff);
                shift = old_value - RRy(n);
                RRx(n + 1 : end) = RRx(n + 1 : end) - shift;
            elseif ratio < 1.0 - max_diff
                old_value = RRy(n);
                RRy(n) = RRy(n - 1) * (1.0 - max_diff);
                shift = old_value - RRy(n);
                RRx(n + 1 : end) = RRx(n + 1 : end) - shift;
            end
        end
    
    elseif strcmp(signal_type, 'SS') || strcmp(signal_type, 'DD')
    
        N = round(max_diff);
        RRy_out = zeros(size(RRy));
        RRy_out(1 : N) = RRy(1 : N);
        for n = N : length(RRy)
            RRy_out(n) = median(RRy(n - N + 1 : n));
        end

        RRy = RRy_out;
        
    end
end

