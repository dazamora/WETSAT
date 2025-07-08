#' Title
#'
#' @param A 
#' @param B 
#' @param C 
#'
#' @return
#' @export
#'
#' @examples
performWS <- function(A, B, C){
  
  
  # Read validation data
  validation <- st_read(validation_file)
  validation_sp <- as(validation, "Spatial")
  
  # Extract predicted values at validation points
  predicted <- extract(water_mask, validation_sp)
  
  # Get actual values from validation data
  actual <- validation$class
  
  # Create confusion matrix
  conf_matrix <- confusionMatrix(
    as.factor(predicted), 
    as.factor(actual),
    positive = "1"
  )
  
  return(conf_matrix)
  
  
  # --- 3. Predicciones ---
  predictions_class <- predict(rf_model, newdata = test_data)
  predictions_prob <- predict(rf_model, newdata = test_data, type = "prob") # Probabilidades para la curva ROC
  
  # --- 4. Métricas de Evaluación ---
  
  # 4.1. Matriz de Confusión
  confusion_matrix <- confusionMatrix(predictions_class, test_data$Target)
  print("--- Matriz de Confusión ---")
  print(confusion_matrix)
  
  # Métricas clave de la matriz de confusión:
  # Accuracy: Precisión general del modelo
  accuracy <- confusion_matrix$overall["Accuracy"]
  # Sensitivity (Recall): Tasa de verdaderos positivos para cada clase
  sensitivity <- confusion_matrix$byClass["Sensitivity"]
  # Specificity: Tasa de verdaderos negativos para cada clase
  specificity <- confusion_matrix$byClass["Specificity"]
  # Precision: Proporción de verdaderos positivos sobre los clasificados como positivos
  precision <- confusion_matrix$byClass["Precision"]
  # F1-Score: Media armónica de precisión y recall
  f1_score <- confusion_matrix$byClass["F1"]
  
  cat("\n--- Métricas Derivadas de la Matriz de Confusión ---\n")
  cat("Accuracy:", accuracy, "\n")
  cat("Sensitivity (Class Yes):", sensitivity["Class: Yes"], "\n")
  cat("Specificity (Class Yes):", specificity["Class: Yes"], "\n")
  cat("Precision (Class Yes):", precision["Class: Yes"], "\n")
  cat("F1-Score (Class Yes):", f1_score["Class: Yes"], "\n")
  
  
  # 4.2. AUC-ROC (Area Under the Receiver Operating Characteristic Curve)
  # Para clasificación binaria, es una métrica muy importante
  # Asegúrate de que la clase positiva esté en la segunda columna de predictions_prob
  roc_obj <- roc(response = test_data$Target, predictor = predictions_prob[, "Yes"])
  auc_value <- auc(roc_obj)
  cat("\n--- AUC (Area Under the Curve) ---\n")
  cat("AUC:", auc_value, "\n")
  
  
}