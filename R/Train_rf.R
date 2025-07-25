#' @name 
#' Train_rf
#' 
#' @title 
#' Training random forest algorithm to estimate water presence in wetlands ecosystems using radar data
#' 
#' @description
#' A short description...
#' 
#'
#' @param training_data 
#' @param ntree 
#' @param por.train 
#'
#' @return
#' @export
#' 
#' @author David Zamora <david.zamora@sei.org> \cr
#' Sebastian Palomino <sebastian.palomino@sei.org> \cr
#'
#' @references reference
#' \itemize{
#'  \item Mayer, T., Poortinga, A., Bhandari, B., Nicolau, A. P., Markert, K., Thwal, N. S., ... & Saah, D. (2021). Deep learning approach for Sentinel-1 surface water mapping leveraging Google Earth Engine. \emph{ISPRS Open Journal of Photogrammetry and Remote Sensing}, 2, 100005. \doi{10.1016/j.ophoto.2021.100005}  
#'  \item Huang, W., DeVries, B., Huang, C., Lang, M.W., Jones, J.W., Creed, I.F., Carroll, M.L. (2018). Automated extraction of surface water extent from sentinel-1 data. \emph{Rem. Sens.} 10, 797. \emph{10.3390/rs10050797}
#' }
#' 
#' @examples
#' 
train_rf_model <- function(training_data, ntree = 500, por.train = 0.7, plot.out) {
  
  # Split data into training and testing sets
  set.seed(123)
  trainIndex <- caret::createDataPartition(training_data$water, p = por.train, list = FALSE)
  train_set <- caret::training_data[trainIndex, ]
  test_set <- caret::training_data[-trainIndex, ]
  
  # Train Random Forest model
  rf_model <- randomForest::randomForest(
    water ~ ., 
    data = train_set,
    ntree = ntree,
    importance = TRUE
  )
  
  # Evaluate model on test set
  predictions <- predict(rf_model, test_set)
  conf_matrix <- caret::confusionMatrix(predictions, test_set$water)
  
  # Print model evaluation metrics
  print(conf_matrix)
  print(importance(rf_model))
  
  # Plot variable importance
  if(plot.out){
    randomForest::varImpPlot(rf_model, main = "Variable Importance")
  }
  return(list(model = rf_model, accuracy = conf_matrix$overall["Accuracy"]))
}