plot.model.fit.per.timepoint = function(group_name, timepoint, 
                                        fit_wavelength, fit_tp, 
                                        point_tp, point_wavelength, stat_tp, 
                                        orig_list, param) {
  
  model_names = names(fit_tp)
  
  # In case you want the scale the fit and the data point to the original range
  # TODO! Need to be implemented
  orig_mean = orig_list[[1]]
  orig_SD = orig_list[[2]]
  orig_all = orig_list[[3]]
  
  # Convert lists to dataframes
  dfs = convert.lists.to.df.for.timepoint.plot(model_names,
                                               fit_wavelength,
                                               fit_tp,
                                               point_wavelength,
                                               point_tp)
    
  # Unwrap the returned list
  fits_to_plot = dfs[[1]]
  points_in = dfs[[2]]
  points_of_fit = dfs[[3]]
  
  #INJECTIONPOINT
  # Fit other models for the points of this timepoint
  aux_fits = fit.aux.models(orig_list, point_wavelength, point_tp, param, group_name)
    
  
  # Melt the data frame to long format
  factors = model_names
  fits_df_melt = melt(fits_to_plot, id='x')
  points_df_melt = melt(points_in, id='x')
  error = points_in
  
  # str(stat_tp[[model_names[i]]])
  
  # Rename the legends
  legend = list()
  for (i in 1 : length(model_names)) {
    trim_name = sub('opponent_', '', model_names[i])
    legend = c(legend, paste(trim_name, 
                      ', R^2=', round(stat_tp[[model_names[i]]]$R2, digits = 2),
                      ', AIC=', round(stat_tp[[model_names[i]]]$AIC, digits = 2),
                      sep=''))
  }
  
  # The spectrum fit
  # https://stackoverflow.com/questions/29795775/combining-geom-point-and-geom-line-in-one-plot
  p = ggplot()
  p = p + geom_line(data=fits_df_melt, aes(x=x, y=value, group=variable, 
                                           color=variable))
  
  # The Input points
  p = p + geom_point(data=points_in, aes(x=x, y=y))
  
  # Error bars (TODO!)
  # p = p + geom_errorbar(data=error, aes(ymin=y-stdev, ymax=y+stdev), width=.1)
  
  # Labels
  p = p + labs(x='Wavelength [nm]', y="Melatonin suppression\n[Nonneg Max Norm.]")
  p = p + labs(title=paste(group_name, ': ', timepoint))
  p + theme(plot.title = element_text(size=12, face="bold"))
  
  
  # Modifying the legend
  # http://www.cookbook-r.com/Graphs/Legends_(ggplot2)/
  p = p + labs(colour = 'Model')
  p = p + scale_color_manual(labels = legend, 
                             values = c("black", "#E69F00", "#56B4E9", "#009E73"))
  
  p = p + theme(legend.text = element_text(size = 8))
  
    # Colorblind-friendly palette
    # http://www.cookbook-r.com/Graphs/Colors_(ggplot2)/#a-colorblind-friendly-palette
  
  # Final print (i.e. display of figure)
  print(p)  
  
  # put something here if you wanna push it all the way out to the calling main function
  df_out_param = list()
  df_out_param[['placeholder']] = NA
  df_out_param[['aux_fits']] = aux_fits
  
  return(list(p, dfs, df_out_param))
  
}
