#' @name train_rf_model
#'
#' @title 
#' Training a Random Forest model to detect water presence using radar-derived indices
#'
#' @description
#' This function trains a Random Forest classifier to estimate water presence in wetland ecosystems 
#' using radar-derived indices from Sentinel-1 data. The function is part of the WetSAT-ML project from SEI 
#' and is designed to work with the outputs of the \code{radar_index_stack} function. It uses the 
#' calculated backscatter indices (VV, VH, and derived indices) as predictor variables and a binary 
#' water presence label (1 = water, 0 = no water) as the response variable. The function performs 
#' model training, testing, and evaluation, returning both the trained model and its performance metrics.
#'
#' @param training_data A data frame containing the training dataset. The first column must be a 
#'                      factor representing water presence (1 = water, 0 = no water), and the remaining 
#'                      columns must correspond to the predictor variables (radar-derived indices).
#' @param ntree Integer. The number of trees to grow in the Random Forest model. Default is \code{500}.
#' @param por.train Numeric value between 0 and 1 specifying the proportion of the dataset used for model training.
#'                  The remaining portion is used for model validation. Default is \code{0.7} (70% training / 30% validation).
#' @param mtry Integer specifying the number of variables randomly selected as candidates at each split. Default is \code{3}.
#' @param plot.out A variable importance plot is generated based on the trained model. Default is \code{TRUE}.
#' @param print.CM The function prints the confusion matrix and variable importance metrics. Default is \code{TRUE}.
#'
#' @return 
#' A list containing:
#' \itemize{
#'   \item \strong{model}: The trained Random Forest model object.
#'   \item \strong{accuracy}: The overall accuracy of the model evaluated on the validation dataset.
#'   \item \strong{training.set}: The row indices of the observations used for model training.
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
train_rf_model <- function(training_data, ntree = 500, por.train = 0.7, mtry = 3, plot.out = TRUE, print.CM = TRUE) {
  
  
  if(is.data.frame(training_data)){
    
    cli::cat_line(c("Argument training_data is a data frame"), col = "blue")
    
    if(is.factor(training_data[,1])){
      
      cli::cli_bullets(c("v" = "The first column is a {.cls {class(training_data[,1])}} class", 
                         "v" = "Water presence is define as 1 and not presence as 0 = {.cls {summary(training_data[,1])}}."))
    } else {
      cli::cli_abort(c(
        "!" = "The first column of {.arg training_data} must be a factor."))
    }
    
  } else {
    cli::cli_abort(c(
      "!" = "{.arg training_data} must be a data frame.",
      "i" = "You provided an object of class {.cls {class(training_data)}}.",
      "i" = "Convert using {.fn as.data.frame}."
    ))
  }
  
  if(!exists("por.train")){
    por.train <- 0.7
    cli::cli_bullets(c("!" ="There is not a por.train variable. By default use 70 % of data to calibrate random forest model"))
  } else {
    cli::cat_line(paste(por.train*100, " % is used to calibrate", " and ", abs(1 - por.train)*100, " % to validate random forest model.", sep = ""), col = "blue")
  }
  
  if(!exists("ntree")){
    ntree <- 500
    cli::cli_bullets(c("!" ="By default the value of {.arg ntree} is 500"))
  } 
  
  
  # Split data into training and testing sets
  set.seed(123)
  trainIndex <- caret::createDataPartition(training_data$water, p = por.train, list = FALSE)
  train_set <- training_data[trainIndex, ]
  test_set <- training_data[-trainIndex, ]
  
  # Train Random Forest model
  rf_model <- randomForest::randomForest(
    water ~ ., 
    data = train_set,
    ntree = ntree,
    mtry = mtry,
    importance = TRUE,
    proximity = TRUE
  )
  
  # Evaluate model on test set
  predictions <- predict(rf_model, test_set)
  conf_matrix <- caret::confusionMatrix(predictions, test_set$water)
  
  # Print model evaluation metrics
  if(print.CM){
    print(conf_matrix)
    print(randomForest::importance(rf_model))
  }
  
  # Plot variable importance
  if(plot.out){
    randomForest::varImpPlot(rf_model, main = "Variable Importance")
  }
  return(list(model = rf_model, accuracy = conf_matrix$overall["Accuracy"], training.set = trainIndex))
  
}
