
# Java Script and HTML for the Shiny App

js <- "
$(document).ready(function(){
  $('img').on('click', function(){
    Shiny.setInputValue('last_click', this.id);
  });
})
"

image_style_gallery <- "cursor:pointer; width:200pt; height:250pt;border: 1px solid #ddd;
  border-radius: 0px;
  padding: 8px;
  width: 200pt;
  hover:box-shadow: 0 0 2px 1px rgba(0, 140, 186, 0.5);"

image_style_recommendation_shoe <- "cursor:pointer; width:200pt; height:250pt;border: 1px solid #ddd;
  border-radius: 0px;
  padding: 8px;
  width: 200pt;
  hover:box-shadow: 0 0 2px 1px rgba(0, 140, 186, 0.5);"
