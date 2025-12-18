"""
Scoring script for Azure ML managed online endpoint.

This script loads a trained scikit-learn model and provides a prediction
interface for house price estimation.
"""

import os
import json
import logging
import joblib
import pandas as pd

# Global variables
model = None

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def init():
    """
    Initialize the model.
    
    This function is called when the endpoint is created or updated.
    It loads the model from the AZUREML_MODEL_DIR environment variable.
    """
    global model
    
    # Get the path to the model directory
    model_dir = os.getenv("AZUREML_MODEL_DIR")
    if not model_dir:
        raise ValueError("AZUREML_MODEL_DIR environment variable not set")
    
    # Load the model
    model_path = os.path.join(model_dir, "model.pkl")
    logger.info(f"Loading model from: {model_path}")
    
    try:
        model = joblib.load(model_path)
        logger.info("Model loaded successfully")
    except Exception as e:
        logger.error(f"Failed to load model: {e}")
        raise


def run(data):
    """
    Make predictions on input data.
    
    Args:
        data: JSON string or dict containing input records
        
    Returns:
        JSON-serializable dict with predictions
    """
    try:
        # Parse input data
        if isinstance(data, str):
            data = json.loads(data)
        
        # Extract records from the data object
        if isinstance(data, dict):
            if "data" in data:
                records = data["data"]
            else:
                records = [data]
        elif isinstance(data, list):
            records = data
        else:
            raise ValueError(f"Unsupported input type: {type(data)}")
        
        logger.info(f"Processing {len(records)} record(s)")
        
        # Convert to DataFrame
        df = pd.DataFrame(records)
        
        # Validate required columns
        required_columns = [
            "sqft", "bedrooms", "bathrooms", "year_built",
            "neighborhood_code", "garage_spaces", "condition_score",
            "exterior_type"
        ]
        
        missing_columns = set(required_columns) - set(df.columns)
        if missing_columns:
            raise ValueError(f"Missing required columns: {missing_columns}")
        
        # Prepare features (same preprocessing as training)
        X = df.copy()
        
        # One-hot encode categorical features
        X = pd.get_dummies(X, columns=["neighborhood_code", "exterior_type"], drop_first=True)
        
        # Ensure all expected columns from training are present
        # The model was trained with these columns (after one-hot encoding)
        expected_columns = [
            'sqft', 'bedrooms', 'bathrooms', 'year_built', 'garage_spaces',
            'condition_score', 'neighborhood_code_N2', 'neighborhood_code_N3',
            'neighborhood_code_N4', 'neighborhood_code_N5',
            'exterior_type_fiber_cement', 'exterior_type_siding',
            'exterior_type_stucco', 'exterior_type_wood'
        ]
        
        # Add missing columns with 0 values
        for col in expected_columns:
            if col not in X.columns:
                X[col] = 0
        
        # Reorder columns to match training
        X = X[expected_columns]
        
        logger.info(f"Feature matrix shape: {X.shape}")
        
        # Make predictions
        predictions = model.predict(X)
        
        # Convert predictions to list
        predictions_list = predictions.tolist()
        
        logger.info(f"Generated {len(predictions_list)} prediction(s)")
        
        # Return predictions as JSON
        return {"predictions": predictions_list}
        
    except Exception as e:
        error_msg = f"Error during prediction: {str(e)}"
        logger.error(error_msg)
        return {"error": error_msg}
