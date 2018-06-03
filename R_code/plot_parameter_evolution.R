plot.parameter.evolution = function(contrib_df, aux_df, param, param_out) {
  
  # How to customize the ggplot2 plot
  # http://r-statistics.co/Complete-Ggplot2-Tutorial-Part2-Customizing-Theme-With-R-Code.html
  
  # save(contrib_df, param, param_out, file='evolution_debug.RData')
  
  # combine the aux to contrib_df
  contrib_df = rbind(contrib_df, aux_df)
  
  # Init the AGE PLOT
  p = list()
  groups = levels(as.factor(contrib_df$group))
  
  # TODO! read from parameters
  model_to_plot = c('opponent_(+L-M)-S', 'melanopic')
  
  for (g in 1:length(groups)) {
    
    # select the desired group (i.e. OLD vs YOUNG)
    df_sub = subset(contrib_df, contrib_df$group == groups[[g]])
    
    # Keep only one model
    df_sub = subset(df_sub, df_sub$model %in% model_to_plot)
    
    p[[g]] = ggplot(data=df_sub,
                    aes(x=timepoint_names, y=value, 
                        color=parameter)) # shape=model))
  
    # e.g. http://ggplot2.tidyverse.org/reference/aes_linetype_size_shape.html
    # TODO! Fix the connecting line
    # p[[g]] = p[[g]] + geom_line(aes(linetype=model, color=parameter))
    
    p[[g]] = p[[g]] + geom_point(aes(stroke=2))
    
    p[[g]] = p[[g]] + labs(title=groups[[g]])
    
  }
    
  do.call(grid.arrange, c(p, list(ncol=2)))
  
}
