remove_outliers <- function(df, var,stdv) {

  dF= df %>% 
    group_by(month(DATE)) %>% 
    mutate(up_lim=mean(get(var),na.rm = TRUE)+stdv*sd(get(var),na.rm = TRUE),
           lo_lim=mean(get(var),na.rm = TRUE)-stdv*sd(get(var),na.rm = TRUE))
  
  df2 = df %>% dplyr::filter(get(var) < dF$up_lim & get(var) > dF$lo_lim)

  df2
}




