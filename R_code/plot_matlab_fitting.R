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
  data_path_CUSTOM = file.path(data_path, 'custom', fsep = .Platform$file.sep)
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
  files_points_CUSTOM = list.files(path=data_path_CUSTOM, pattern=pattern, recursive=FALSE, full.names = TRUE)
  
  # spectra
  pattern = '*._spectrum.csv'
  files_spectra = list.files(path=data_path, pattern=pattern, recursive=FALSE, full.names = TRUE)
  files_spectra_CUSTOM = list.files(path=data_path_CUSTOM, pattern=pattern, recursive=FALSE, full.names = TRUE)
  
  # stats
  pattern = '*._stats.csv'
  files_stats = list.files(path=data_path, pattern=pattern, recursive=FALSE, full.names = TRUE)
  files_stats_CUSTOM = list.files(path=data_path_CUSTOM, pattern=pattern, recursive=FALSE, full.names = TRUE)
  
  # contributions
  pattern = '*._contributions.csv'
  files_contribs = list.files(path=data_path, pattern=pattern, recursive=FALSE, full.names = TRUE)
  files_contribs_CUSTOM = list.files(path=data_path_CUSTOM, pattern=pattern, recursive=FALSE, full.names = TRUE)
  
  
# IMPORT ----------------------------------------------------------------  
  
  imported = import.matlab.results(files_points, files_spectra, files_stats, files_contribs)
    fit = imported[[1]]
    point = imported[[2]]
    stat = imported[[3]]
    contrib = imported[[4]]
    
  imported_CUSTOM = import.matlab.results(files_points_CUSTOM, files_spectra_CUSTOM, 
                                   files_stats_CUSTOM, files_contribs_CUSTOM)
    fit_CUSTOM = imported_CUSTOM[[1]]
    point_CUSTOM = imported_CUSTOM[[2]]
    stat_CUSTOM = imported_CUSTOM[[3]]
    contrib_CUSTOM = imported_CUSTOM[[4]]
    
    # get original points 
    orig_list = import.orig.points(data_path_study)
    
# PLOT ----------------------------------------------------------------    
  
  ## Full spectrum fits
    
    # NAJJAR et al. 
    
      # Parameters 
      param[['what_to_plot']] = 'matlab'
      param[['models_to_use_for_aux_fit']] = c('melanopic')
      
      # Actual function for plotting  
      out_list = plot.wrapper(fit, point, stat, contrib, orig_list, param)
        p_out = out_list[[1]]
        df_out = out_list[[2]]
        param_out = out_list[[3]]
        
    # CUSTOM DATA
        
      # Parameters 
      param[['what_to_plot']] = 'matlab_CUSTOM'
      param[['models_to_use_for_aux_fit']] = c('melanopic')
      
      # Actual function for plotting  
      out_list_CUSTOM = plot.wrapper(fit_CUSTOM, point_CUSTOM, stat_CUSTOM, contrib_CUSTOM, 
                                     orig_list, param)
        p_out_CUSTOM = out_list_CUSTOM[[1]]
        df_out_CUSTOM = out_list_CUSTOM[[2]]
        param_out_CUSTOM = out_list_CUSTOM[[3]]
      
    
  ## Evolution of contributions
    
    # What to keep for plot (or further stat analysis)  
    param[['groups']] = c('OLD', 'YOUNG')
    
    param[['aux_model_to_track']] = 'melanopic'
    param[['aux_metrics']] = c('RMSE')
    
    param[['evolution_models']] = c("opponent_(+L-M)-S", "opponent_(L-M)", "opponent_(M+L)-S", "simple")
    param[['parameters_to_plot']] = c('melanopsin', 'rods', 'SWS', 'MWS', 'Cones', 'MWSplusLWS', 'LWS', 'opponentWeight')
    param[['parameters_to_plot']] = c('melanopsin', 'opponentWeight')
    
    # Function call
    plot.time.evolution(contrib, param_out, param)
    
    param[['groups']] = c('CUSTOM')
    plot.time.evolution(contrib_CUSTOM, param_out_CUSTOM, param)
  
  
