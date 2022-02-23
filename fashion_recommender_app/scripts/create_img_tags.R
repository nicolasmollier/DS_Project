# Create the sources for the image gallery such that all images in the folder 'www'
# are displayed in the shoe gallery

image_galery_files <- list.files("www/img")

image_style_gallery <- "cursor:pointer; width:200pt; height:250pt;border: 1px solid #ddd;
  border-radius: 0px;
  padding: 8px;
  width: 200pt;
  margin-bottom: 4px;
  hover:box-shadow: 0 0 2px 1px rgba(0, 140, 186, 0.5);"

capture.output(for(i in seq_along(image_galery_files)){
  file_name <- image_galery_files[[i]]
  file_src <- paste0("img/", file_name)
  img_id <- str_replace_all(file_name, "_", " ") %>% 
    str_remove(".jpg")
  print(img(id=img_id,src=file_src, style=image_style_gallery))
}, file = "scripts/img_html")


