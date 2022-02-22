
make_recomm_feature2 <- function(rf_model, obs, n=3) {
  
  # get prob. distribution at final node of obs.
  fn_distr <- predict(rf_model, obs, type="prob")
  
  # output top n classes at final node
  return(rf_model$lvl[order(fn_distr, decreasing = T)][1:n])
  
}



