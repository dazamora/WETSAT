#' Title
#'
#' @param s1_data 
#' @param rf_model 
#' @param output_dir 
#'
#' @return
#' @export
#'
#' @examples
#' 
classify_water_surface <- function(s1_data, rf_model, output_dir = "./RESULTS/Test") {
  
  # Create output directory if it doesn't exist
  if(!dir.exists(output_dir)) dir.create(output_dir)
  
  # Predict water surface
  water_prediction <- predict(s1_data, rf_model, type = "prob")
  water_binary <- water_prediction[[2]] > 0.5  # Probability of water > 0.5
  
  # Save water classification
  writeRaster(water_binary, 
              filename = file.path(output_dir, "water_classification.tif"), 
              format = "GTiff", 
              overwrite = TRUE)
  
  # Calculate water surface area
  pixel_area <- res(water_binary)[1] * res(water_binary)[2]  # m²
  water_pixels <- sum(values(water_binary) == 1, na.rm = TRUE)
  water_area_m2 <- water_pixels * pixel_area
  water_area_km2 <- water_area_m2 / 1000000
  
  # Create a simple report
  report <- data.frame(
    total_pixels = length(na.omit(values(water_binary))),
    water_pixels = water_pixels,
    water_percentage = (water_pixels / length(na.omit(values(water_binary)))) * 100,
    water_area_m2 = water_area_m2,
    water_area_km2 = water_area_km2
  )
  
  # Save report
  write.csv(report, file.path(output_dir, "water_surface_report.csv"), row.names = FALSE)
  
  # Visualize results
  mapview(water_binary, col.regions = c("white", "blue"), legend = TRUE)
  
  return(list(classification = water_binary, report = report))
}