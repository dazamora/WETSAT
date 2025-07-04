#' Title
#'
#' @param training_data 
#' @param ntree 
#' @param por.train 
#'
#' @return
#' @export
#'
#' @examples
train_rf_model <- function(training_data, ntree = 500, por.train = 0.7) {
  
  # Split data into training and testing sets
  set.seed(123)
  trainIndex <- createDataPartition(training_data$water, p = por.train, list = FALSE)
  train_set <- training_data[trainIndex, ]
  test_set <- training_data[-trainIndex, ]
  
  # Train Random Forest model
  rf_model <- randomForest(
    water ~ ., 
    data = train_set,
    ntree = ntree,
    importance = TRUE
  )
  
  # Evaluate model on test set
  predictions <- predict(rf_model, test_set)
  conf_matrix <- confusionMatrix(predictions, test_set$water)
  
  # Print model evaluation metrics
  print(conf_matrix)
  print(importance(rf_model))
  
  # Plot variable importance
  varImpPlot(rf_model, main = "Variable Importance")
  
  return(list(model = rf_model, accuracy = conf_matrix$overall["Accuracy"]))
}