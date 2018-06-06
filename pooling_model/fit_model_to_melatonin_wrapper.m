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
    
end

% Fit the Quick Pooling model for spectral sensitivity
function [spec, points, stats, actSpectra, x, fval, output_struct, statParam, x0_names] = ...
    fit_QuickPooling_simple_v2018(x,y,weights_for_fit,fit_domain,group,model)  

    % Quick RF. 1974. 
    % A vector-magnitude model of contrast detection. 
    % Biological Cybernetics 16:65–67. 
    % http://dx.doi.org/10.1007/BF00271628.
    
    % close all % close all open figures  
    
    %% MODEL options
    
        % use subfunctions to set default options
        options = useDefaultOptionsForMixedModels();        
        
    %% Fit the model
    
        % Use a wrapper function
        [spec, points, stats, actSpectra, x, fval, output_struct, statParam, x0_names] = ...
            fit_mixedModelsForMelatonin(x,y,weights_for_fit,fit_domain,group,model,options);
        
end
    

% wrapper function for the lightLab library's mixed models
function [spec, points, stats, actSpectra, x, fval, output_struct, statParam, x0_names] = ...
    fit_mixedModelsForMelatonin(x,y,weights_for_fit,fit_domain,group,model,options)


    %% Assign the variable names from the options to the input arguments to poolingModel_main

        mode    = model;
        comb_k  = options.poolingModel.comb_k; %[k1 k2]
        contr   = options.poolingModel.contr; % [m c r]
        p       = options.poolingModel.p; % M/L cone ratio
        densit  = options.poolingModel.densit; % [OPN4 Cone S-Cone Rod]
        fMe     = options.poolingModel.fMe;
        oppon   = options.poolingModel.oppon; % [fB0 fD0 fE0]
        bound   = options.poolingModel.bound;
        costF   = options.poolingModel.costF;
        
        % linLog  = options.poolingModel.linLog;
        linLog  = fit_domain;

        % Call the function
        [spec, points, stats, actSpectra, x, fval, output_struct, statParam, x0_names]  = ...
            poolingModel_main(x,y,weights_for_fit,group,mode,linLog,comb_k,contr,p,densit,fMe,oppon,bound,costF,options);

end        