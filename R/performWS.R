#' Title
#'
#' @param rf_model 
#' @param data.val 
#' @param data.cal 
#' @param training_data 
#' @param plot 
#'
#' @return
#' @export
#'
#' @examples
performWS <- function(rf_model, training_data, data.cal, data.val, plot = TRUE){
  
  if(class(rf_model)[2]=="randomForest"){
    cli::cli_bullets(c("v"= "The first column is a {.cls {class(rf_model)[2]}} class"))
    cli::cli_h1("Random Forest Model Information \n The model has been trained with the following parameters:")
    cli::cat_print(rownames(rf_model$importance))
  } else{
    cli::cli_abort(c(
      "!" = "{.arg rf_model} must be a randomForest object.",
      "i" = "You provided an object of class {.cls {class(rf_model)}}."
      ))
  }
  
if(exists("training_data")){
  if(is.data.frame(training_data)){
    } else {
      cli::cli_abort(c("!" = "You provided an object {.arg training_data} of {.cls {class(training_data)}} class."),
                     c("i" = "{.arg training_data} must be a data frame object."))
    }
} else {
  cli::cli_abort(c("i" = "You must provided an {.arg training_data}."))
}
  
  if(exists("data.cal") & exists("data.val")){
    cli::cat_line(c("Argument data.cal and data.val are defined"), col = "blue")
    
    if(is.numeric(data.cal) & is.numeric(data.val)){
      cli::cat_line(c("Argument data.cal and data.val are numeric vectors"), col = "blue")
    } else {
      cli::cli_abort(c( "i" = "You provided an objects {.arg data.cal} and {.arg data.val} of class {.cls {class(data.cal)}}."))
    }
    cal_data <- training_data[data.cal, ]
    val_data <- training_data[data.val, ]
  } else if(exists(data.cal) & !data.val){
    if(is.numeric(data.cal)){
      cli::cat_line(c("Argument data.cal is numeric vector"), col = "blue")
    } else {
      cli::cli_abort(c( "i" = "You provided an object {.arg data.cal} of {.cls {class(data.cal)}} class."))
    }
    cal_data <- training_data[data.cal, ]
    val_data <- training_data[-data.cal, ]
  } else {
    cli::cli_abort(c(
      "!" = "{.arg data.cal} and {.arg data.val} must be defined.",
      "i" = "You provided an object of class {.cls {class(data.cal)}} and {.cls {class(data.val)}}."
    ))
  }
  
# ROC plotting (Area Under the Receiver Operating Characteristic Curve)
  pred_probs.cal <- predict(rf_model, cal_data, type = "prob")[,2]
  pred_class.cal <- predict(rf_model, cal_data, type = "response")
  conf_mat.cal <- caret::confusionMatrix(pred_class.cal, cal_data$water, positive = levels(cal_data$water)[2])
  roc_obj.cal <- pROC::roc(cal_data$water, pred_probs.cal, levels = rev(levels(cal_data$water)))
  auc_value.cal <- pROC::auc(roc_obj.cal)
  
  if(plot){
    plot(roc_obj.cal, col = "blue", main = sprintf("ROC Curve (AUC = %.2f)", pROC::auc(roc_obj.cal)))
    abline(a = 0, b = 1, lty = 2, col = "gray")
  }
  
  if(exists("data.cal") | exists("val_data")){
    pred_probs.val <- predict(rf_model, val_data, type = "prob")[,2]
    pred_class.val <- predict(rf_model, val_data, type = "response")
    conf_mat.val <- caret::confusionMatrix(pred_class.val, val_data$water, positive = levels(val_data$water)[2])
    if(plot){
      plot(roc_obj.val, col = "blue", main = sprintf("ROC Curve (AUC = %.2f)", pROC::auc(roc_obj.val)))
      abline(a = 0, b = 1, lty = 2, col = "gray")
    }
  }
  
  # Perfomance matrics
  # Accuracy: Precisión general del modelo
  accuracy.cal <- conf_mat.cal$overall["Accuracy"]
  # Sensitivity (Recall): Tasa de verdaderos positivos para cada clase
  sensitivity.cal <- conf_mat.cal$byClass["Sensitivity"]
  # Specificity: Tasa de verdaderos negativos para cada clase
  specificity.cal <- conf_mat.cal$byClass["Specificity"]
  # Precision: Proporción de verdaderos positivos sobre los clasificados como positivos
  precision.cal <- conf_mat.cal$byClass["Precision"]
  # F1-Score: Media armónica de precisión y recall
  f1_score.cal <- conf_mat.cal$byClass["F1"]
  
  performance.cal <- c(accuracy.cal, sensitivity.cal, specificity.cal, precision.cal, f1_score.cal)
  
  if(exists("data.cal") | exists("val_data")){
    accuracy.val <- conf_mat.val$overall["Accuracy"]
    sensitivity.val <- conf_mat.val$byClass["Sensitivity"]
    specificity.val <- conf_mat.val$byClass["Specificity"]
    precision.val <- conf_mat.val$byClass["Precision"]
    f1_score.val <- conf_mat.val$byClass["F1"]
    performance.val <- c(accuracy.val, sensitivity.val, specificity.val, precision.val, f1_score.val)
  }
  
  # Partial dependence plot
  if(plot){
    partial.dependencies <- list()
    partial.dependencies[[]] <- pdp::partial(rf_model, pred.var = "VV_sigma", prob = TRUE)
    partial.dependencies[[]] <- pdp::partial(rf_model, pred.var = "VH_sigma", prob = TRUE)
  }
  
}
