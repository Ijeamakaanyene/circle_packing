library(dplyr)
library(purrr)


distance_formula = function(x2, x1, y2, y1){
  dist = sqrt((x2 - x1)^2 + (y2 - y1)^2)
  
  return(dist)
}

pack_circles = function(config, 
                        panel_size, 
                        max_attempts){
  
  # Some nice reminders for inputs
  if(is.data.frame(config) == FALSE){
    usethis::ui_stop("config must be a dataframe")
  }
  if(is.list(panel_size) == FALSE){
    usethis::ui_stop("panel_size must be a list")
  }
  if(length(panel_size$x) == 0 | length(panel_size$y) == 0){
    usethis::ui_stop("panel_size must contain vectors x and y")
  }
  if(is.numeric(config$radius) == FALSE){
    usethis::ui_stop("config file must include a radius column")
  }
  
  
  # count number of circles and sort by decreasing radius
  num_circles = config %>%
    count(radius) %>%
    arrange(-radius)
  
  # set up 
  xt = vector()
  yt = vector()
  rt = vector()
  
  # first placement
  rt[1] = num_circles$radius[1]
  xt[1] = runif(1, min = rt + panel_size$x[1], max = panel_size$x[2] - rt)
  yt[1] = runif(1, min = rt + panel_size$y[1], max = panel_size$y[2] - rt)
  
  
  for(i in 1:nrow(num_circles)){
    
    for(j in 1:num_circles$n[i]){
      
      # overlapping until proven not overlapping
      overlap = 1
      attempts = 0
      
      while(overlap == 1){
        
        #print(attempts)
        
        # place new points
        r_temp = num_circles$radius[i]
        x_temp = runif(1, min = r_temp + panel_size$x[1], max = panel_size$x[2] - r_temp)
        y_temp = runif(1, min = r_temp + panel_size$y[1], max = panel_size$y[2] - r_temp)
        
        
        # get length of already saved points
        df_length = length(xt)
        
        # check for collisions - distance must be greater than sum of radii
        collision_df = map_dfr(1:df_length,
                               ~bind_cols(
                                 dist = distance_formula(xt[.x], x_temp,
                                                         yt[.x], y_temp),
                                 radii_sum = rt[.x] + r_temp
                               ))
        
        check_collision_val = collision_df %>%
          filter(dist > radii_sum) %>%
          nrow()
        
        if(check_collision_val == df_length){
          
          xt = c(xt, x_temp)
          yt = c(yt, y_temp)
          rt = c(rt, r_temp)
          overlap = 0
          
        } else {
          
          if(attempts > max_attempts){
            overlap = 0
            
          } else {
            overlap = 1
            attempts = attempts + 1
            
          }
        }
        
      }
    }
  }
  
  return(tibble(x = xt, y = yt, r = rt))
  
}



