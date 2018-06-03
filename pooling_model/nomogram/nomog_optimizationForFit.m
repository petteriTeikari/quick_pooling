function [z, stat] = nomog_optimizationForFit(z, b1, b2, origData, fitFunc, nomoOptions)

    % INPUTS

    % z(1) - peak wavelength
    %    b1  - corresponding upper and lower bound
    % z(2) - axial density
    %    b2  - corresponding upper and lower bound
    
        % NOTE! you can simply set upper and lower bound of axial density
        % to be the same if you want to fix it some value and only keep one
        % free parameter
        z0 = [z(1) z(2)];
            
    % change the bounds to common Matlab variable naming/syntax
    % of ub and lb (upper and lower) used with optimization
    lb = [min(b1) min(b2)];
    ub = [max(b1) max(b2)];
    
    % reassign to different variables in line with the Matlab syntax/naming
    % for lsqnonlin
    xdata   = origData(:,1);
    ydata   = origData(:,2);    
        
    % nomoOptions   
    %stat = [];
    
%% OPTIMIZATION

    % define optimization options       
    optimOpt = optimset('fmincon');
    optimOpt = optimset(optimOpt, 'Algorithm', 'interior-point', 'Display', 'notify');
    % optimOpt = optimset(optimOpt, 'UseParallel', nomoOptions.optSet_useParallel);
    
    % empty variables for fmincon
    A = []; b = []; Aeq = []; beq = []; nonlcon = [];

    % use the function X from "Optimization Toolbox"
    [z,fval,exitflag,output,lambda,grad,hessian] = fmincon(fitFunc, z0, A,b,Aeq,beq, lb, ub, nonlcon, optimOpt);
    % z = lsqnonlin(fitFunc, z0, lb, ub, optimOpt);
    % z = lsqcurvefit(fitFunc, z0, xdata, ydata, lb, ub, optimOpt) %workNot
    
    % put the output to the stat structure, you can use the hessian for
    % exmaple to estimate your confidence intervals
    stat.fval = fval;
    stat.exitflag = exitflag;
    stat.output = output;
    stat.lambda = lambda;
    stat.grad = grad;
    stat.hessian = hessian;