$(document).ready(function(){
  $('span').on('click', function(evt){
    Shiny.setInputValue('span', evt.target.id);
  });
})
