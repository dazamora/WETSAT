#' Title
#'
#' @param VV Is the backscatter of the signal transmited and recived vertical
#' @param VH 
#' @param index 
#' @param nameID 
#'
#' @return
#' @export
#'
#' @examples
#' 
radar_index_stack <- function(VV, VH, index, nameID){
  salida <- VV+VH
  return(salida)
}