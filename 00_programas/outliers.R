remove_outliers <- function(df, var, stdv) {
  # we set the limits for the filter by its monthly mean and
  ## the standard deviation selected in the parameters file
  dF = df %>%
    group_by(month(DATE)) %>%
    mutate(
      up_lim = mean(get(var), na.rm = TRUE) + stdv * sd(get(var), na.rm = TRUE),
      lo_lim = mean(get(var), na.rm = TRUE) - stdv * sd(get(var), na.rm = TRUE)
    )
  
  # Now we filter and keep those values with "NA"
  ## otherwise, we'll removing useful data
  df2 = df %>% dplyr::filter(get(var) < dF$up_lim &
                               get(var) > dF$lo_lim | is.na(get(var)))
  
  df2
  
}




