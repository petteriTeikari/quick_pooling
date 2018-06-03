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

        
   

    