# SUBFUNCTIONS ----------------------------------------------------------------  
import.matlab.results = function(files_points, files_spectra, files_stats, files_contribs) {

  # group these into one dataframe (or list)
  fit = list()
  point = list()
  stat = list()
  contrib = list()
    
  for (i in 1:length(files_points)) {
    
    # get filename
    filename_sep = strsplit(files_points[i], .Platform$file.sep)[[1]]
    just_filename = tail(filename_sep, n=1)
    just_path = gsub(just_filename, '', files_points[i])
    
    # get field names from filename
    name_sep = strsplit(just_filename, '___')[[1]]
    model_name = name_sep[2]
    group = name_sep[3]
    timepoint = name_sep[4]
    
    # import data
    points = read.csv(files_points[i])
    spectrum = read.csv(files_spectra[i])
    stats = read.csv(files_stats[i])
    contribs = read.csv(files_contribs[i])
    
    # RE-GROUP
    
    # constant for all the different groups and models
    fit$wavelength = spectrum$Wavelength
    point$wavelength = points$Wavelength
    contrib$OD_Rods = contribs$dens_R
    contrib$OD_Cones = contribs$dens_C
    contrib$OD_SCones = contribs$dens_CS
    contrib$OD_Melanopsin = contribs$dens_M
    
    # SPECTRUM FIT
    fit[[group]][[timepoint]][[model_name]] = spectrum$Spectrum.Fit
    
    # POINTS (input vs. fit)
    point[[group]][[timepoint]][[model_name]]$Melatonin.CA. = points$Melatonin.CA.
    point[[group]][[timepoint]][[model_name]]$Standard.Deviation = points$Standard.Deviation
    point[[group]][[timepoint]][[model_name]]$Fit = points$Fit
    
    point[[group]][[timepoint]][[model_name]]$Residual = points$Residual
    point[[group]][[timepoint]][[model_name]]$Residual.ABS = points$Residual.ABS
    point[[group]][[timepoint]][[model_name]]$Variance.in = points$Variance.in # check this!
    point[[group]][[timepoint]][[model_name]]$Weights.normalized = points$Weights.normalized
    
    # STATS 
    stat[[group]][[timepoint]][[model_name]]$N = stats$N
    stat[[group]][[timepoint]][[model_name]]$K = stats$K
    
      # Recompute fit stats
      stat[[group]][[timepoint]][[model_name]] = 
        recompute.fit.stats(stat[[group]][[timepoint]][[model_name]],
                            stats$N, stats$K, 
                            point[[group]][[timepoint]][[model_name]]$Melatonin.CA.,
                            point[[group]][[timepoint]][[model_name]]$Fit, 
                            point[[group]][[timepoint]][[model_name]]$Standard.Deviation,
                            point[[group]][[timepoint]][[model_name]]$Weights.normalized)
      
    # CONTRIBUTIONS
    contrib[[group]][[timepoint]][[model_name]]$k1 = contribs$k1
    contrib[[group]][[timepoint]][[model_name]]$k2 = contribs$k2
    contrib[[group]][[timepoint]][[model_name]] = 
      contribution.wrapper(contribs, contrib[[group]][[timepoint]][[model_name]], model_name)
    
  }
  
  return(list(fit, point, stat, contrib))
}

recompute.fit.stats = function(stat_in, n, K, y_in, y_fit, error, w) {
  
  res = abs(y_in - y_fit)
  
  # TODO!
  # Recheck the weighed R2
  res_weighed = res * w
  
  # Rsquare in general
  # https://en.wikipedia.org/wiki/Coefficient_of_determination
  
  # Rsquare in R
  # https://stats.stackexchange.com/questions/230556/calculate-r-square-in-r-for-two-vectors
  SS_residual = sum((res)^2)
  SS_total = sum((y_in-mean(y_in))^2)
  R2 = 1 - (SS_residual/SS_total)
  
  # weighed Rsquare (weigh the residuals)
  SS_residual_weighed = sum((res_weighed)^2)
  R2weighed = 1 - (SS_residual_weighed/SS_total)
  
  RMSE = sqrt(mean((y_fit-y_in)^2))
  
  stat_in$SS_residual_weighed = SS_residual_weighed
  stat_in$SS_residual = SS_residual
  stat_in$SS_total = SS_total
  stat_in$R2 = R2
  stat_in$R2weighed = R2weighed
  stat_in$RMSE = RMSE
  
  # We need to compute the BIC, AIC "by hand" as R has many functions if we would
  # have created the model in R, but now our model was defined in Matlab
  # n = number of data points (observations)
  # K = was the number of free parameters
  # w = weights used when fitting the model
  
  # https://stats.stackexchange.com/questions/87345/calculating-aic-by-hand-in-r
  
  # or: 
  # Calculating the log likelihood requires a vector of residuals, 
  # the number of observations in the data, 
  # and a vector of weights (if applicable)
  
  # log likelihood
  ll<-0.5 * (sum(log(w)) - n * (log(2 * pi) + 1 - log(n) + log(sum(w * res^2))))
  
  # Calculating the BIC or AIC requires ll, and additionally requires the df associated with the calculation of the log likelihood, 
  # which is equal to the original number of parameters being estimated plus 1.
  df.ll = K + 1
  
  # BIC
  bic = -2 * ll + log(n) * df.ll
  
  # AIC
  aic = -2 * ll + 2 * df.ll
  
  stat_in$ll = ll
  stat_in$df.ll = df.ll
  stat_in$BIC = bic
  stat_in$AIC = aic
  
  return(stat_in)
  
}

contribution.wrapper = function(contribs, contrib, model_name) {
  
  # Now in Matlab we had all the parameters always in the matrix x0
  # used by fmincon, but depending on the model, not all the variables
  # were changed during the optimization so we need this wrapper to add
  # some intelligence to this part then
  
  # And if you look at "poolingModel_function.m", it is a bit messy
  # between different models, so we try to harmonize it now, and mark
  # the variables with NA if they were not optimized in that model
  
  # Original from McDougal and Gamlin (2010)
  # "Simple Quick Pooling model"
  if (identical(model_name, 'simple')) {
    contrib$melanopsin = contribs$m0
    contrib$rods = contribs$r0
    contrib$SWS = NA
    contrib$MWS = NA
    contrib$MWSplusLWS = contribs$c0
    contrib$LWS = NA
    contrib$opponentWeight = NA
      
  # Opponent term, from Kurtenbach et al. (1999) 
  # http://dx.doi.org/10.1364/JOSAA.16.001541  
  } else if (identical(model_name, 'opponent_(L-M)')) {
    contrib$melanopsin = contribs$m0
    contrib$rods = contribs$r0
    contrib$SWS = NA
    contrib$MWS = NA
    contrib$Cones = contribs$c0
    contrib$MWSplusLWS = NA # in opponent term
    contrib$LWS = NA
    contrib$opponentWeight = contribs$fD0
  
  # Opponent term, from  Woelders et al. (2018)
  # https://doi.org/10.1073/pnas.1716281115
  } else if (identical(model_name, 'opponent_(+L-M)-S')) {
    contrib$melanopsin = contribs$m0
    contrib$rods = contribs$r0
    contrib$SWS = contribs$fB0
    contrib$MWS =  contribs$inhMWS
    contrib$Cones = contribs$c0
    contrib$MWSplusLWS = NA # in opponent term
    contrib$LWS = contribs$fE0
    contrib$opponentWeight = contribs$fD0
    
  # Opponent term, from  Spitschan et al. (2014)
  # https://dx.doi.org/10.1073/pnas.1400942111
  } else if (identical(model_name, 'opponent_(M+L)-S')) {
    contrib$melanopsin = contribs$m0
    contrib$rods = contribs$r0
    contrib$SWS = contribs$fB0
    contrib$MWS = NA
    contrib$Cones = contribs$c0
    contrib$MWSplusLWS = contribs$fE0 # in opponent term
    contrib$LWS = NA
    contrib$opponentWeight = contribs$fD0
    
  } else {
    warning('your model name should never be here = ', model_name)
  }
  
  return(contrib)
}

plot.wrapper = function(fit, point, stat, contrib, orig_list, param) {
  
  # plot the model fits
  out_list = plot.the.model.fits(fit$wavelength, fit, point, point$wavelength, stat, 
                                 orig_list, param)
  
  return(out_list)
  
}

plot.the.model.fits = function(fit_wavelength, fit, point, point_wavelength, stat, 
                               orig_list, param) {
  
  # get the variables in the list
  groups = names(point)
  groups = groups[groups != "wavelength"];
  timepoints = names(point[[groups[1]]])
  models = names(point[[groups[1]]][[timepoints[1]]])
  
  p = list()
  dfs_g = list()
  df_out_param_g = list()
  
  for (i in 1:length(groups)) { # YOUNG, OLD
    
    group_out = plot.model.fit.per.group(groups[i], 
                             fit_wavelength, fit[[groups[i]]], 
                             point_wavelength, point[[groups[i]]],
                             stat[[groups[i]]], orig_list, param)
    
    p[[groups[i]]] = group_out[[1]]
    dfs_g[[groups[i]]] = group_out[[2]]
    df_out_param_g[[groups[i]]] = group_out[[3]]
    
  }
  
  return(list(p, dfs_g, df_out_param_g))
  
}

plot.model.fit.per.group = function(group, fit_wavelength, fit_g, 
                                    point_wavelength, point_g, stat_g, orig_list, param) {
  
  no_of_cols = length(fit_g)
  timepoints = names(fit_g)
  p = list()
  dfs_tp = list()
  df_out_param_tp = list()
  
  for (i in 1:length(fit_g)) {
    
    tp_out = plot.model.fit.per.timepoint(group, timepoints[i], 
                                 fit_wavelength, fit_g[[i]], 
                                 point_g[[i]], point_wavelength, stat_g[[i]], 
                                 orig_list, param)
    
    p[[i]] = tp_out[[1]]
    dfs_tp[[timepoints[i]]] = tp_out[[2]]
    df_out_param_tp[[timepoints[i]]] = tp_out[[3]]
    
  }
  
  # 4 columns here, 1 row, arrange
  do.call(grid.arrange, c(p, list(ncol=length(fit_g)/2)))
  
  return(list(p, dfs_tp, df_out_param_tp))
  
}


convert.lists.to.df.for.timepoint.plot = function(model_names,
                                                  fit_wavelength,
                                                  fit_tp,
                                                  point_wavelength,
                                                  point_tp) {
  
  # convert the list into a dataframe
  
  # THE WHOLE SPECTRUM FITS
  fits_to_plot = data.frame(x = fit_wavelength)
  for (var in 1:length(model_names)) {
    fits_to_plot[[model_names[var]]] = fit_tp[[model_names[var]]]
  }
  
  
  # ------------------------
  # TODO!
  # ------------------------
  # NOW A TOTALLY GHETTO FIX HERE
  # In the original Najjar et al. dataset, the wavelength vectors were
  # always the same which is not anymore the case with Brainard et al. 
  # and Thapan et al. which used different wavelengths, now only the Thapan is saved to input
  
  # If there is a mismatch between x and y
  # i.e. only works for Brainard (and not your added custom datasets later on)
  if (length(point_wavelength) == 6 & length(point_tp[[model_names[1]]]$Melatonin.CA.) == 9) {
    point_wavelength = c(420, 440, 460, 480, 505, 530, 555, 575, 600)
    warning('Ghetto fix for Brainard et al. (2001) data. Modify this if you start adding more datasets')
    # these are the wavelengths used by Brainard et al. (2001)
  }
  
  # POINTS IN
  points_in = data.frame(x            = point_wavelength, 
                         y            = point_tp[[model_names[1]]]$Melatonin.CA.,
                         
                         variance     = point_tp[[model_names[1]]]$Variance.in,
                         stdev        = point_tp[[model_names[1]]]$Standard.Deviation,
                         
                         rel_variance = point_tp[[model_names[1]]]$Variance.in /
                                        point_tp[[model_names[1]]]$Melatonin.CA.,
                         rel_stdev    = point_tp[[model_names[1]]]$Standard.Deviation /
                                        point_tp[[model_names[1]]]$Melatonin.CA.)
  
  # plot(points_in$x, points_in$y)
  
  # POINTS FITTED
  points_of_fit = data.frame(x = point_wavelength)
  for (var in 1:length(model_names)) {
    points_of_fit[[model_names[var]]] = point_tp[[model_names[var]]]$Fit
  }
  
  return(list(fits_to_plot, points_in, points_of_fit))
  
}

import.orig.points = function(data_path_study) {
  
  # filenames
  young_mean = 'young_mean.csv'
  young_SD = 'young_SD.csv'
  old_mean = 'old_mean.csv'
  old_SD = 'old_SD.csv'
  
  # read
  y_m = read.csv(file.path(data_path_study, young_mean))
  wavelength = y_m$Wavelength
  y_m = y_m[ , !(names(y_m) %in% "Wavelength")]
  y_sd = read.csv(file.path(data_path_study, young_SD))
  y_sd = y_sd[ , !(names(y_sd) %in% "Wavelength")]
  o_m = read.csv(file.path(data_path_study, old_mean))
  o_m = o_m[ , !(names(o_m) %in% "Wavelength")]
  o_sd = read.csv(file.path(data_path_study, old_SD))
  o_sd = o_sd[ , !(names(o_sd) %in% "Wavelength")]
  
  # Depending what you want to do later
  orig_mean = data.frame(wavelength=wavelength,
                         young=y_m, old=o_m)
  
  orig_SD = data.frame(wavelength=wavelength,
                       young_SD=y_sd, young_hi=y_m+y_sd, young_lo=y_m-y_sd,
                       old_SD=o_sd, old_hi=o_m+o_sd, old_lo=o_m-o_sd)
  
  orig_all = cbind(orig_mean, orig_SD[ , !(names(orig_SD) %in% "wavelength")])
  
  return(list(orig_mean, orig_SD, orig_all))
  
}

plot.time.evolution = function(contrib, param_out, param) {
  
  # First reshape the list so that the time point matrices are at the end of the list
  reshaped = reshape.contrib.list(contrib)
    contrib_reshaped = reshaped[[1]]
    timepoint_names = reshaped[[2]]

  # Trim away the variables not found from the above defined lists
  param[['what_to_output']] = 'list'
  contrib_trim = trim.list.to.desired.variables(contrib_reshaped, timepoint_names, param[['what_to_output']],
                                                param_out, param)  
  
  param[['what_to_output']] = 'df'
  contrib_df = trim.list.to.desired.variables(contrib_reshaped, timepoint_names, param[['what_to_output']],
                                              param_out, param)  

  # Do the same reshaping for the aux variables
  param[['evolution_models']] = param[['aux_model_to_track']]
  param[['parameters_to_plot']] = param[['aux_metrics']]
  aux_reshape_out = reshape.param.out(param_out, param, var_name = 'aux_fits')
    aux_reshaped = aux_reshape_out[[1]]
    
  aux_df = trim.list.to.desired.variables(aux_reshaped, timepoint_names, param[['what_to_output']],
                                              param_out, param)    
  
  # Actually then plot
  plot.parameter.evolution(contrib_df, aux_df, param, param_out)
  
}


trim.list.to.desired.variables = function(list_in, timepoint_names, what_to_output,
                                          param_out, param) {
  
  groups = names(list_in)  
  list_out = list()
  vectors_out = list() # long data_frame
  
  for (g in 1:length(groups)) {
    
    group_name = groups[g]
    models = names(list_in[[group_name]])
    
    # get rid of unwanted model names
    to_incl = param[['evolution_models']]
    indices = models %in% to_incl
    models = models[indices]
    
      # TODO! now if you wanted something that is not in models, you do not notice it
      # i.e. check for typos, etc.
      if (length(models) == 0) {
        warning('No models in the end selected, problem with your inclusion? defined in "param$evolution_models"')
      }
    
    for (m in 1:length(models)) {
        
      model = models[[m]]  
      parameters = names(list_in[[group_name]][[model]])
      
      # get rid of unwanted parameter names
      to_incl = param[['parameters_to_plot']]
      indices = parameters %in% to_incl
      parameters = parameters[indices]
        # TODO! now if you wanted something that is not in parameters, you do not notice it
        # i.e. check for typos, etc.
        if (length(parameters) == 0) {
          warning('No parameters in the end selected, problem with your inclusion? defined in "param$parameters_to_plot"')
        }
      
        # TODO! We are not looping through the parameters from aux_fits now, so if you would like 
        # to see evaluation of Rsquare, RMS, AIC, BIC, etc. 
        # But as init implementation the weighed R^2 seemed good as we used weighed optimization as
        # well in the Matlab implementation (thus R^2 is considerably worse for that reason than the Rsquared)
    
      for (p in 1:length(parameters)) {
        
        parameter = parameters[[p]]
        parameter_evolution = list_in[[group_name]][[model]][[parameter]]
        
        # How many combinations, for the long version
        combinations = length(groups)*
                       length(models)*
                       length(parameters)*
                       length(parameter_evolution)
        
        # return just the trimmed list
        list_out[[group_name]][[model]][[parameter]] = list_in[[group_name]][[model]][[parameter]] 
        
        # TODO! If you want to manipulate the data in some other way
        #INJECTIONPOINT
        if (identical(what_to_output, 'df')) {
          
          # output as a long-format data frame
          
          # So now we have multiple factors
          # GROUP (young vs. old)
          # MODEL (which opponency, etc.)
          # PARAMETERS (melanopsin, cone, rod contribution etc.)
          # TIMEPOINTS (15, 30, 45, 60)
          
          # i.e. the number of time points, and then we have to replicate
          # the other variables to this length
          no_of_entries = length(list_in[[group_name]][[model]][[parameter]])
          
          value_vector = list_in[[group_name]][[model]][[parameter]]
          
          # aux_vector = aux_fits[[group_name]][[model]][[parameter]]
          
          timepoint_name_vector = timepoint_names
          group_vector = rep(group_name, no_of_entries)
          model_vector = rep(model, no_of_entries)
          parameter_vector = rep(parameter, no_of_entries)
          
          # easier to plot geom_line()?
          # ind = ((g-1)*length(models)) + ((m-1)*length(parameters)) + p 
          # str(ind)
          # lineplot_group = rep(ind, no_of_entries)
          
          # And make a long format, so we have "combinations" length vector
          if (g == 1 & m == 1 & p == 1) {
            
            # Init first the vector (on first iteration)
            vectors_out[['value']] = value_vector
            vectors_out[['timepoint_names']] = timepoint_name_vector
            vectors_out[['group']] = group_vector
            vectors_out[['model']] = model_vector
            vectors_out[['parameter']] = parameter_vector
          
          } else {
            
            # append on further iterations
            vectors_out[['value']] = c(vectors_out[['value']], value_vector)
            vectors_out[['timepoint_names']] = c(vectors_out[['timepoint_names']], timepoint_name_vector)
            vectors_out[['group']] = c(vectors_out[['group']], group_vector)
            vectors_out[['model']] = c(vectors_out[['model']], model_vector)
            vectors_out[['parameter']] = c(vectors_out[['parameter']], parameter_vector)
          
          }
        }
      }
    }
  }
  
  if (identical(what_to_output, 'df')) {
    # output as a long-format data frame
    df = data.frame(vectors_out)
    return(df)
    
  } else if (identical(what_to_output, 'list')) {
    return(list_out)  
  }
}

reshape.param.out = function(param_out, param, var_name) {
 
  list_out = list()
  groups = param[['groups']]
  
  for (g in 1:length(groups)) {
    
    group_name = groups[g]
    timepoints = names(param_out[[group_name]])
    
    for (tp in 1:length(timepoints)) {
      
      timepoint = timepoints[[tp]]
      
      # reshape single variable at time
      # TODO! add for (var_name in 1 : length(var_names))
      models = names(param_out[[group_name]][[timepoint]][[var_name]])
      
      for (m in 1:length(models)) {
        
        model = models[[m]]  
        
        # parameters_per_model = param_out[[group_name]][[timepoint]][[var_name]][[model]]
        parameters_per_model = param[['aux_metrics']]
        
        for (p in 1:length(parameters_per_model)) {
          
          parameter_name = parameters_per_model[[p]]
          parameter_value = param_out[[group_name]][[timepoint]][[var_name]][[model]][[parameter_name]]
          
          if (tp == 1) {
            mat = as.numeric(matrix(ncol=length(timepoints)))
            list_out[[group_name]][[model]][[parameter_name]] = mat
            list_out[[group_name]][[model]][[parameter_name]][tp] = parameter_value
          } else {
            list_out[[group_name]][[model]][[parameter_name]][tp] = parameter_value 
          }
          
        }
      }
    }
  }
  
  return(list(list_out, timepoints))
   
}

reshape.contrib.list = function(contrib) {
 
  list_out = list()
  
  groups = param[['groups']]
  for (g in 1:length(groups)) {
    
    group_name = groups[g]
    timepoints = names(contrib[[group_name]])
    
    for (tp in 1:length(timepoints)) {
    
        timepoint = timepoints[[tp]]
        models = names(contrib[[group_name]][[timepoint]])
        
        for (m in 1:length(models)) {
          
          model = models[[m]]  
          parameters_per_model = contrib[[group_name]][[timepoint]][[model]]
            
          for (p in 1:length(parameters_per_model)) {
            
            parameter_name = names(parameters_per_model)[[p]]
            parameter_value = contrib[[group_name]][[timepoint]][[model]][[parameter_name]]
            
            if (tp == 1) {
              mat = as.numeric(matrix(ncol=length(timepoints)))
              list_out[[group_name]][[model]][[parameter_name]] = mat
              list_out[[group_name]][[model]][[parameter_name]][tp] = parameter_value
            } else {
              list_out[[group_name]][[model]][[parameter_name]][tp] = parameter_value 
            }
            
          }
        }
    }
  }
  
  return(list(list_out, timepoints))
  
}
 
 
