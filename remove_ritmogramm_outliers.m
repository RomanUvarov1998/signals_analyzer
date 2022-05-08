function [RRx, RRy] = remove_ritmogramm_outliers(RRx, RRy, max_diff)
    assert(length(RRx) == length(RRy));
    
    for n = 2 : length(RRx)
        ratio = RRy(n) / RRy(n - 1);
        if ratio > 1.0 + max_diff
            old_value = RRy(n);
            RRy(n) = RRy(n - 1) * (1.0 + max_diff);
            shift = old_value - RRy(n);
            RRy(n + 1 : end) = RRy(n + 1 : end) - shift;
        end
    end
end

