# INIT ----------------------------------------------------------------

  # Libraries
  library(ggplot2)
  library(grid)
  library(gridExtra)
  library(reshape2)
  library(zoo) # for interpolating the NAs away


  # Define Paths
  script.dir <- dirname(sys.frame(1)$ofile)
  data_path = file.path(script.dir, '..', 'data_out_from_matlab', fsep = .Platform$file.sep)
  data_path_study = file.path(script.dir, '..', 'data', fsep = .Platform$file.sep)
  
  # Init param
  param = list()
  param[['code_path']] = script.dir
  param[['data_path']] = data_path
  param[['data_path_study']] = data_path_study
  
  # Source subfunction(s)
  
  # The "boring" data wrangling here
  source(file.path(script.dir, 'plot_subfunctions.R', fsep = .Platform$file.sep))
  
  # The fun stuff on these
  source(file.path(script.dir, 'plot_model_fit_per_timepoint.R', fsep = .Platform$file.sep))
  source(file.path(script.dir, 'plot_parameter_evolution.R', fsep = .Platform$file.sep))
  source(file.path(script.dir, 'model_fit_wrapper.R', fsep = .Platform$file.sep))

    
# GET FILE LISTINGS ----------------------------------------------------------------
  
  # points
  pattern = '*._points.csv'
  files_points = list.files(path=data_path, pattern=pattern, recursive=FALSE, full.names = TRUE)
  
  # spectra
  pattern = '*._spectrum.csv'
  files_spectra = list.files(path=data_path, pattern=pattern, recursive=FALSE, full.names = TRUE)
  
  # stats
  pattern = '*._stats.csv'
  files_stats = list.files(path=data_path, pattern=pattern, recursive=FALSE, full.names = TRUE)
  
  # contributions
  pattern = '*._contributions.csv'
  files_contribs = list.files(path=data_path, pattern=pattern, recursive=FALSE, full.names = TRUE)
  
  
# IMPORT ----------------------------------------------------------------  
  
  imported = import.matlab.results(files_points, files_spectra, files_stats, files_contribs)
    fit = imported[[1]]
    point = imported[[2]]
    stat = imported[[3]]
    contrib = imported[[4]]
    
# PLOT ----------------------------------------------------------------    
  
  ## Full spectrum fits

    # CUSTOM DATA
        
      # Parameters 
      param[['what_to_plot']] = 'matlab_CUSTOM'
      param[['models_to_use_for_aux_fit']] = c('melanopic')
      orig_list = NA
      
      # Actual function for plotting  
      out_list = plot.wrapper(fit, point, stat, contrib, 
                                     orig_list, param)
      
        p_out = out_list[[1]]
        df_out = out_list[[2]]
        param_out = out_list[[3]]
      
    
  ## Evolution of contributions
    
    param[['aux_model_to_track']] = 'melanopic'
    param[['aux_metrics']] = c('RMSE')
    
    param[['evolution_models']] = c("opponent_(+L-M)-S", "opponent_(L-M)", "opponent_(M+L)-S", "simple")
    # param[['parameters_to_plot']] = c('melanopsin', 'rods', 'SWS', 'MWS', 'Cones', 'MWSplusLWS', 'LWS', 'opponentWeight')
    param[['parameters_to_plot']] = c('melanopsin', 'opponentWeight')
    
    param[['groups']] = c('CUSTOM')
    plot.time.evolution(contrib, param_out, param)
  
  
