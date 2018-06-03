fit.aux.models = function(orig_list, point_wavelength, point_tp, param, group_name) {
  
  # save.image() # creating ".RData"
  # source(file.path(script.dir, 'model_fit_wrapper.R', fsep = .Platform$file.sep))
  group_name
  
  x = point_wavelength
  
  # Normalized points
  y = point_tp[[1]]$Melatonin.CA.
  stdev = point_tp[[1]]$Standard.Deviation
  
  # Original points
  # get from orig_list if you want
  
  # Original 
  
  # Init output list
  aux_fit_stat = list()
  
  for (mod in 1 : length(param[['models_to_use_for_aux_fit']])) {
    
    model_used = param[['models_to_use_for_aux_fit']]
    if (identical(model_used, 'melanopic')) {
      aux_fit_stat[[model_used]] = melanopic.fit(x, y, stdev, param, group_name)
      
    } else {
      warning(model_used, ' not implemented!')
    }
    
  }
  
  return(aux_fit_stat)
  
}

melanopic.fit = function(x, y, stdev, param, group_name) {

  # melanopic is defined as fixed peak wavelength, easy to fit it to data
  # whereas if we would fit a nomogram, we would not know the peak wavelength
  # nor the optical density so we should vary 2 parameters
  fit_mode = 'fixed' 
  
  # import the template from the data folder
  melanopic_template = read.csv(file.path(param[['data_path_study']],
                                'Melanopic.csv'))
  
  # if the data points are for old, weight the melanopic fit
  # with "65 yr old standard observer" template
  if (identical(group_name, 'OLD')) {
    
    lens_template = read.csv(file.path(param[['data_path_study']],
                                       'lensTemplates.csv'))
    
    # how much more 65 yr old filters than 25 yr old if melanopic template 
    # already had the lens filtering included
    
    lens_65yr_more_than25yr = lens_template$X.65yr.25yr.
    melanopic_template$Vz.lambda. = melanopic_template$Vz.lambda. * lens_65yr_more_than25yr
    
  }
  
  # fit the template the points
  stat = fit.template.to.points(x, y, stdev, fit_mode,
                                melanopic_template$Wavelength..nm., melanopic_template$Vz.lambda.)
  
  return(stat)
  
}
 
fit.template.to.points = function(x, y, stdev, fit_mode,
                                  x_spectrum, y_spectrum) {

  stdev = clean.unwanted.values.from.vector(stdev)
  
  # inverse of variance   
  w = 1 / (stdev^2)
  w = w / max(w, na.rm = TRUE)
  
  if (identical(fit_mode, 'fixed')) {
    
    # pick points from the template that correspond to the input
    points = pick.points.from.full.spectrum(x, x_spectrum, y_spectrum)  
    
    # calculate now the error between input and output
    stat = list()
    n = length(points)
    K = 0
    stat = recompute.fit.stats(stat, n, K, y, points, stdev, w)
    
  } else {
    warning('fit_mode = ', fit_mode, ' not defined yet')
  }
  
  return(stat)
  
}

clean.unwanted.values.from.vector = function(vector) {
  
  # NA
  indices = is.na(vector)
  vector[indices] = NA
  vector <- na.approx(vector)
  
  # INF
  indices = is.infinite(vector)
  vector[indices] = NA
  vector <- na.approx(vector)

  # ZEROS  
  indices = vector == 0
  vector[indices] = NA
  vector <- na.approx(vector)
  
  return(vector)
  
}
 
pick.points.from.full.spectrum = function(x_points, x_spectrum, y_spectrum) {
  
  indices = which(x_spectrum %in% x_points)
  x_spectrum_pts = x_spectrum[indices]
  y_spectrum_pts = y_spectrum[indices]
  
}