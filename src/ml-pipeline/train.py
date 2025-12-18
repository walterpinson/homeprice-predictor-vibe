#!/usr/bin/env python3
"""
Train a scikit-learn regression model for house price prediction.

This script trains a simple regression model on MLTable-based data and saves
the trained model to ./outputs for Azure ML job capture.
"""

import argparse
import sys
from pathlib import Path
import pandas as pd
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score
import joblib
import mltable


def parse_args():
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(
        description="Train a house price regression model"
    )
    parser.add_argument(
        "--train-data",
        required=True,
        help="Path or URI to the training MLTable",
    )
    parser.add_argument(
        "--val-data",
        required=True,
        help="Path or URI to the validation MLTable",
    )
    parser.add_argument(
        "--target-column",
        default="price",
        help="Name of the target column (default: price)",
    )
    return parser.parse_args()


def load_mltable_data(path: str) -> pd.DataFrame:
    """
    Load data from an MLTable path.
    
    Args:
        path: Path or URI to the MLTable directory
        
    Returns:
        DataFrame with the loaded data
    """
    print(f"[train] Loading data from {path} ...")
    tbl = mltable.load(path)
    df = tbl.to_pandas_dataframe()
    print(f"[train] Loaded {len(df)} rows, {len(df.columns)} columns")
    return df


def prepare_features(df: pd.DataFrame, target_column: str):
    """
    Split DataFrame into features (X) and target (y).
    
    Args:
        df: Input DataFrame
        target_column: Name of the target column
        
    Returns:
        Tuple of (X, y) where X is features and y is target
    """
    if target_column not in df.columns:
        raise ValueError(f"Target column '{target_column}' not found in data")
    
    y = df[target_column]
    X = df.drop(columns=[target_column])
    
    # Drop non-numeric columns or ID columns if present
    if 'id' in X.columns:
        X = X.drop(columns=['id'])
    
    # Convert categorical columns to dummy variables
    X = pd.get_dummies(X, drop_first=True)
    
    print(f"[train] Features: {list(X.columns)}")
    print(f"[train] Feature matrix shape: {X.shape}")
    
    return X, y


def train_model(X_train: pd.DataFrame, y_train: pd.Series):
    """
    Train a RandomForestRegressor model.
    
    Args:
        X_train: Training features
        y_train: Training target
        
    Returns:
        Trained model
    """
    print("[train] Training RandomForestRegressor ...")
    model = RandomForestRegressor(
        n_estimators=100,
        max_depth=10,
        random_state=42,
        n_jobs=-1,
    )
    model.fit(X_train, y_train)
    print("[train] Training complete")
    return model


def evaluate_model(model, X: pd.DataFrame, y: pd.Series, dataset_name: str):
    """
    Evaluate model and print metrics.
    
    Args:
        model: Trained model
        X: Feature matrix
        y: Target values
        dataset_name: Name of the dataset (e.g., "train", "validation")
    """
    predictions = model.predict(X)
    rmse = mean_squared_error(y, predictions) ** 0.5
    mae = mean_absolute_error(y, predictions)
    r2 = r2_score(y, predictions)
    
    print(f"[train] {dataset_name} Metrics:")
    print(f"  RMSE: {rmse:,.2f}")
    print(f"  MAE:  {mae:,.2f}")
    print(f"  R²:   {r2:.4f}")
    
    return {"rmse": rmse, "mae": mae, "r2": r2}


def save_model(model, output_dir: Path):
    """
    Save the trained model to the outputs directory.
    
    Args:
        model: Trained model
        output_dir: Directory to save the model
    """
    output_dir.mkdir(parents=True, exist_ok=True)
    model_path = output_dir / "model.pkl"
    
    print(f"[train] Saving model to {model_path} ...")
    joblib.dump(model, model_path)
    print(f"[train] Model saved successfully")


def main():
    """Main entry point."""
    args = parse_args()
    
    print("=" * 60)
    print("House Price Model Training")
    print("=" * 60)
    print()
    
    # Load data
    train_df = load_mltable_data(args.train_data)
    val_df = load_mltable_data(args.val_data)
    
    # Prepare features
    X_train, y_train = prepare_features(train_df, args.target_column)
    X_val, y_val = prepare_features(val_df, args.target_column)
    
    # Ensure validation data has the same columns as training data
    # (in case of categorical encoding differences)
    missing_cols = set(X_train.columns) - set(X_val.columns)
    for col in missing_cols:
        X_val[col] = 0
    X_val = X_val[X_train.columns]
    
    # Train model
    print()
    model = train_model(X_train, y_train)
    
    # Evaluate
    print()
    train_metrics = evaluate_model(model, X_train, y_train, "Training")
    print()
    val_metrics = evaluate_model(model, X_val, y_val, "Validation")
    
    # Save model
    print()
    output_dir = Path("./outputs")
    save_model(model, output_dir)
    
    print()
    print("=" * 60)
    print("Training Complete")
    print("=" * 60)
    print(f"Model saved to: {output_dir / 'model.pkl'}")
    print(f"Validation RMSE: {val_metrics['rmse']:,.2f}")
    print("=" * 60)


if __name__ == "__main__":
    main()
