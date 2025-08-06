#' Title
#'
#' @param rf_model 
#' @param data.val 
#' @param data.cal 
#' @param training_data 
#'
#' @return
#' @export
#'
#' @examples
performWS <- function(rf_model, training_data, data.val, data.cal){
  
  if(class(rf_model)[2]=="randomForest"){
    cli::cli_bullets(c("v"= "The first column is a {.cls {class(model.rf)[2]}} class"))
    cli::cli_h1("Random Forest Model Information \n The model has been trained with the following parameters:")
    cli::cat_print(rownames(rf_model$importance))
  } else{
    cli::cli_abort(c(
      "!" = "{.arg model.rf} must be a randomForest object.",
      "i" = "You provided an object of class {.cls {class(model.rf)}}."
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
  

  pred_probs.cal <- predict(rf_model, cal_data, type = "prob")[,2]
  pred_class.cal <- predict(rf_model, cal_data, type = "response")
  
  pred_probs.val <- predict(rf_model, val_data, type = "prob")[,2]
  pred_class.val <- predict(rf_model, val_data, type = "response")
  
  conf_mat.cal <- caret::confusionMatrix(pred_class.cal, cal_data$water, positive = levels(cal_data$water)[2])
  conf_mat.val <- caret::confusionMatrix(pred_class.val, val_data$water, positive = levels(val_data$water)[2])
  print(conf_mat.val)
  
  roc_obj.cal <- pROC::roc(cal_data$water, pred_probs.cal, levels = rev(levels(cal_data$water)))
  auc_value.cal <- pROC::auc(roc_obj.cal)
  
  roc_obj.val <- pROC::roc(val_data$water, pred_probs.val, levels = rev(levels(val_data$water)))
  auc_value.val <- pROC::auc(roc_obj.val)
  
  plot(roc_obj.cal, col = "blue", main = sprintf("ROC Curve (AUC = %.2f)", pROC::auc(roc_obj.cal)))
  abline(a = 0, b = 1, lty = 2, col = "gray")
  
  
  plot(roc_obj.val, col = "blue", main = sprintf("ROC Curve (AUC = %.2f)", pROC::auc(roc_obj.val)))
  abline(a = 0, b = 1, lty = 2, col = "gray")
  
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
  
  
  accuracy.val <- conf_mat.val$overall["Accuracy"]
  sensitivity.val <- conf_mat.val$byClass["Sensitivity"]
  specificity.val <- conf_mat.val$byClass["Specificity"]
  precision.val <- conf_mat.val$byClass["Precision"]
  f1_score.val <- conf_mat.val$byClass["F1"]
  
  performance.val <- c(accuracy.val, sensitivity.val, specificity.val, precision.val, f1_score.val)
  
  
  cat("\n--- Métricas Derivadas de la Matriz de Confusión ---\n")
  cat("Accuracy:", accuracy, "\n")
  cat("Sensitivity (Class Yes):", sensitivity["Class: Yes"], "\n")
  cat("Specificity (Class Yes):", specificity["Class: Yes"], "\n")
  cat("Precision (Class Yes):", precision["Class: Yes"], "\n")
  cat("F1-Score (Class Yes):", f1_score["Class: Yes"], "\n")
  
  
return()
  
}