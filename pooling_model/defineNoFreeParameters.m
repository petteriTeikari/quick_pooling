function K = defineNoFreeParameters(x0, ub, lb, mode)
    
    diff_lb = logical(ceil(abs(x0 - lb)));
    diff_ub = logical(ceil(abs(x0 - ub)));
    
    free_param = logical(diff_lb + diff_ub);
    
    K = sum(free_param);