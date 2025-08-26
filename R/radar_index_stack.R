#' @name radar_index_stack
#'
#' @title 
#' Radar Indices Calculation and Training Data Extraction
#'
#' @description
#' This function calculates a set of radar-derived indices from dual-polarization backscatter data 
#' (VV and VH) expressed as sigma naught (σ⁰) in decibels (dB). It computes the selected indices 
#' for each pixel and extracts the median values of these indices within a buffer around each 
#' reference station.
#'
#' @param VV A RasterStack of VV-polarized backscatter images represented as sigma naught (σ⁰), expressed in decibels (dB).
#' @param VH A RasterStack of VH-polarized backscatter images represented as sigma naught (σ⁰), expressed in decibels (dB).
#' @param index A character vector specifying the radar indices to calculate from VV and VH backscatter. 
#'              Available options are: "PR", "NDPI", "NVHI", "NVVI", and "RVI" \cite{Mayer et al., 1974}. 
#' @param station An sf point object representing the location of reference stations. The attribute table contains only the station name.
#' @param buff Buffer radius in meters used to extract the median of the indices around each station point. Recommended value: 100.
#'
#' @return 
#' A list with two components:
#' \itemize{
#'   \item \strong{stack.index}: A list containing the calculated radar indices as RasterLayers.
#'   \item \strong{matrix.index.station}: A data frame with the median values of each index 
#'         extracted within the buffer around each reference station.
#' }
#'
#' @author 
#' David Zamora <david.zamora@sei.org> \cr
#' Sebastian Palomino-Angel <sebastian.palomino@sei.org>
#'
#' @references reference
#' \itemize{
#'  \item Mayer, T., Poortinga, A., Bhandari, B., Nicolau, A. P., Markert, K., Thwal, N. S., ... & Saah, D. (2021). Deep learning approach for Sentinel-1 surface water mapping leveraging Google Earth Engine. \emph{ISPRS Open Journal of Photogrammetry and Remote Sensing}, 2, 100005. \doi{10.1016/j.ophoto.2021.100005}  
#'  \item Huang, W., DeVries, B., Huang, C., Lang, M.W., Jones, J.W., Creed, I.F., Carroll, M.L. (2018). Automated extraction of surface water extent from sentinel-1 data. \emph{Rem. Sens.} 10, 797. \emph{10.3390/rs10050797}
#' }
#' 
#' @examples
#' 
radar_index_stack <- function(VV, VH, index, station, buff){
  
  if((raster::nlayers(VV) == raster::nlayers(VH))){
    cli::cat_line("Backscatter variables have same number of layers", col = "blue")
  } else {
    cli::cli_abort(c("x"="Backscatter variables have different number of layers or VV-VH are not raster format"))  
  }
  
  if(exists("index")){
    if(is.character(index)){
      cli::cat_line("The following indices will be calculated: ", col = "blue")
      cli::cat_bullet(paste(index, sep=""), col = "aquamarine4")
    } else {
      cli::cli_abort(c("x" = "The index must be a vector of characters with at least a the index name"))
    }
  } else {
    index <- c("PR", "NDPI", "NVHI", "NVVI", "RVI")
  }
  
  if(raster::nlayers(VV) > 1){
    if(!(class(VV)[1] == "RasterStack")){
      cli::cat_line("The following indices will be calculated: ", col = "blue")
    }
    PR <- VH/VV
    NDPI <- (VV - VH)/(VV + VH)
    NVHI <- VH/(VV + VH)
    NVVI <- VV/(VV + VH)
    RVI <- 4*VH/(VV + VH)
    out.indexes <- list(VV = VV, VH = VH, PR = PR, NDPI = NDPI, NVHI = NVHI, NVVI = NVVI, RVI = RVI)
    
  } else {
    if(length(index) == 5){
      
      PR <- VH/VV
      NDPI <- (VV - VH)/(VV + VH)
      NVHI <- VH/(VV + VH)
      NVVI <- VV/(VV + VH)
      RVI <- 4*VH/(VV + VH)
      out.indexes <- list(VV = VV, VH = VH, PR = PR, NDPI = NDPI, NVHI = NVHI, NVVI = NVVI, RVI = RVI)
    } else {
      
      PR <- VH/VV
      NDPI <- (VV - VH)/(VV + VH)
      NVHI <- VH/(VV + VH)
      NVVI <- VV/(VV + VH)
      RVI <- 4*VH/(VV + VH)
      
      nam.ind <- c("PR", "NDPI", "NVHI", "NVVI", "RVI")
      select.ind <- is.element(nam.ind, index)
      
      out.pre <- list(PR = PR, NDPI = NDPI, NVHI = NVHI, NVVI = NVVI, RVI = RVI)[select.ind]
      out.indexes <- list(VV = VV, VH = VH, out.pre) 
    }
  }
  
  if(exists("station")){
    
    if(inherits(station, "sf") & unique(sf::st_is(station, "POINT"))){
      
      if(sf::st_crs(VV) == sf::st_crs(station)){
        print("salida")
      } else {
        station <- sf::st_transform(station, crs = sf::st_crs(VV))
      }
        
    } else {
      stop("The variable station does not have the structure of the sf package or is not a station point or point set.")
    }
    
    extract.index.buff <- lapply(out.indexes, function(x, y, w) raster::extract(x, y, buffer = w), y = station, w = buff)
    median.extract <- lapply(extract.index.buff, function(x) lapply(x, function(z) apply(z, 2, median, na.rm = TRUE)))
    convert.data.frame <- lapply(median.extract, function(x) do.call(rbind, x))
    
    coord.station <- sf::st_coordinates(station)
    result.station.indexes <- lapply(convert.data.frame, function(x, y) cbind(y, x), y = coord.station)
    
  } else {
    cat("There are not a station variable to extract data from stack indexes")
  }
  
  output <- list(stack.index = out.indexes, matrix.index.station = result.station.indexes)
  return(output)
}


