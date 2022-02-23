# Prediction function for outfit recommendation based on a random forest

make_recomm_feature2 <- function(rf_model, obs, n=3) {
  
  # get prob. distribution at final node of obs.
  fn_distr <- predict(rf_model, obs, type="prob")
  
  # Mapping function (adjusted to database) in order to satisfy Asos query
  
  map_asos <-  c("Adidas Continental 80", "Adidas Running shoe", "Adidas sneaker", "Adidas Stan Smith", 
                 "Adidas Superstar", "Adidas Ultraboost", "Oxford shoe", "Asics Gel", "Asics Tiger", "Autumn Boot",               
                 "Flat sandal", "Flat sandal", "Flat sandal", "Converse Chucks (high)", "Converse Chucks (low)",       
                 "Crocs", "Dr. Martens low-level shoe", "Dr. Martens Boot", "Fila sneaker", "Flipflop",                
                 "Gucci Ace", "High heel", "Kswiss sneaker", "Lacoste sneaker", "Heel pump",       
                 "New Balance sneaker", "Nike Airforce One", "Nike Blazer", "Nike Jordans", "Nike Running shoe",         
                 "Puma sneaker", "Reebok sneaker", "Sandal", "Sketchers sneaker", "Steve Madden sneaker",      
                 "Timberland Boot", "Tommy Hilfiger sneaker", "UGG Boot", "Vans classic (slip on)", "Vans (old school)",           
                 "Vans sneaker", "Winter Boot")
  
  
  # output top n classes at final node
  return(map_asos[order(fn_distr, decreasing = T)][1:n])
}



