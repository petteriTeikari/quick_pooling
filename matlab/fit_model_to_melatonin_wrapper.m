function fit_out = fit_model_to_melatonin_wrapper(data_points, stats, weights_for_fit, ...
                                            fit_domain, model_name, group, plot_ON_norm, ...
                                            timepoint_string, scrsz, path_Code)
                
    % Error to be used in the optimization
    weights_for_fit = weights_for_fit / max(weights_for_fit);
                                        
    % QUICK POOLING
    [spec, points, stats_out, actSpectra, final_x, fval, output_struct, statParam, x0_names] = ...
        fit_QuickPooling_simple_v2018(stats.x, stats.y, weights_for_fit, fit_domain, group, model_name);
    
        fit_stats = calc_fitStats(points, stats.y, 0, statParam.K, 'spectrum');

        fit_out.spec = spec;
        fit_out.points = points;
        fit_out.stats_out = stats_out;
        fit_out.actSpectra = actSpectra;

        fit_out.final_x = final_x;
        fit_out.x0_names = x0_names;
        fit_out.fval = fval;
        fit_out.output_struct = output_struct;
        fit_out.statParam = statParam;
        fit_out.fit_stats = fit_stats;

    % Some other model, with a SWITCH CASE... 
    
        