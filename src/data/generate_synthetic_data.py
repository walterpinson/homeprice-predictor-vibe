#!/usr/bin/env python3
"""
Generate synthetic house price data for Boulder, CO market.

Creates train, validation, and test datasets with realistic correlations
between features and target price.
"""

import csv
import random
import argparse
import os
from pathlib import Path


# Fixed seed for reproducibility
RANDOM_SEED = 42

# Neighborhood base prices (Boulder, CO market)
NEIGHBORHOOD_BASE_PRICES = {
    'N1': 520000,  # Premium area
    'N2': 480000,  # High-end area
    'N3': 410000,  # Mid-range
    'N4': 350000,  # Affordable
    'N5': 440000   # Up-and-coming
}

# Exterior type price multipliers
EXTERIOR_MULTIPLIERS = {
    'brick': 1.08,         # +8% premium
    'fiber_cement': 1.05,  # +5% premium
    'stucco': 1.02,        # +2% premium
    'siding': 1.00,        # baseline
    'wood': 0.98           # -2% (maintenance costs)
}


def generate_house(house_id, seed_offset=0):
    """Generate a single synthetic house record with correlated features."""
    
    # Use seed offset to ensure different values across splits
    random.seed(RANDOM_SEED + house_id + seed_offset)
    
    # Generate square footage (primary driver)
    sqft = random.randint(600, 4500)
    
    # Bedrooms correlate with square footage
    # Rule: ~700 sqft per bedroom, with some variation
    base_bedrooms = max(1, int(sqft / 700))
    bedrooms = min(6, max(1, base_bedrooms + random.randint(-1, 2)))
    
    # Bathrooms correlate with bedrooms (~0.75 ratio)
    base_bathrooms = bedrooms * 0.75
    bathrooms = round(max(1.0, min(4.0, base_bathrooms + random.uniform(-0.5, 0.5))), 1)
    
    # Year built (1950-2023)
    year_built = random.randint(1950, 2023)
    
    # Random neighborhood
    neighborhood = random.choice(['N1', 'N2', 'N3', 'N4', 'N5'])
    
    # Garage spaces (0-3)
    garage_spaces = random.randint(0, 3)
    
    # Condition score (1-10)
    condition_score = random.randint(1, 10)
    
    # Exterior type
    exterior_type = random.choice(['brick', 'siding', 'stucco', 'fiber_cement', 'wood'])
    
    # Calculate price with realistic correlations
    price = calculate_price(
        sqft=sqft,
        bedrooms=bedrooms,
        bathrooms=bathrooms,
        year_built=year_built,
        neighborhood=neighborhood,
        garage_spaces=garage_spaces,
        condition_score=condition_score,
        exterior_type=exterior_type
    )
    
    return {
        'id': house_id,
        'sqft': sqft,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'year_built': year_built,
        'neighborhood_code': neighborhood,
        'garage_spaces': garage_spaces,
        'condition_score': condition_score,
        'exterior_type': exterior_type,
        'price': round(price, 2)
    }


def calculate_price(sqft, bedrooms, bathrooms, year_built, neighborhood, 
                   garage_spaces, condition_score, exterior_type):
    """Calculate realistic price based on correlated features."""
    
    # Start with neighborhood base price
    base_price = NEIGHBORHOOD_BASE_PRICES[neighborhood]
    
    # Square footage factor (primary driver, non-linear)
    # Normalize around 2000 sqft
    sqft_factor = (sqft / 2000) ** 0.8
    
    # Age factor (newer is better, subtle depreciation)
    age = 2023 - year_built
    age_factor = 1.0 - (age / 250)  # Very gradual depreciation
    
    # Condition factor (significant impact)
    # Condition 5 is baseline (1.0), scales from 0.85 to 1.20
    condition_factor = 0.85 + (condition_score / 20)
    
    # Bedroom/bathroom adjustments (minor corrections)
    room_factor = 1.0 + ((bedrooms - 3) * 0.03) + ((bathrooms - 2) * 0.02)
    
    # Garage factor (~4% per space)
    garage_factor = 1.0 + (garage_spaces * 0.04)
    
    # Exterior type factor
    exterior_factor = EXTERIOR_MULTIPLIERS[exterior_type]
    
    # Combine all factors
    predicted_price = (base_price * sqft_factor * age_factor * 
                      condition_factor * room_factor * garage_factor * 
                      exterior_factor)
    
    # Add market noise (±10% random variation)
    noise = random.uniform(-0.10, 0.10)
    final_price = predicted_price * (1 + noise)
    
    return final_price


def generate_dataset(output_path, num_rows, start_id, seed_offset=0):
    """Generate a single dataset and write to CSV."""
    
    fieldnames = ['id', 'sqft', 'bedrooms', 'bathrooms', 'year_built', 
                  'neighborhood_code', 'garage_spaces', 'condition_score', 
                  'exterior_type', 'price']
    
    houses = [generate_house(i, seed_offset) for i in range(start_id, start_id + num_rows)]
    
    with open(output_path, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(houses)
    
    print(f"✓ Created {output_path} with {num_rows} rows")


def main():
    parser = argparse.ArgumentParser(
        description='Generate synthetic house price datasets'
    )
    parser.add_argument('--train-rows', type=int, default=350,
                       help='Number of training rows (default: 350)')
    parser.add_argument('--val-rows', type=int, default=75,
                       help='Number of validation rows (default: 75)')
    parser.add_argument('--test-rows', type=int, default=75,
                       help='Number of test rows (default: 75)')
    
    args = parser.parse_args()
    
    # Get script directory and create output directory
    script_dir = Path(__file__).parent
    output_dir = script_dir / 'raw'
    output_dir.mkdir(exist_ok=True)
    
    print(f"Generating synthetic house price data...")
    print(f"Output directory: {output_dir}")
    print()
    
    # Generate datasets with different seed offsets to ensure variety
    generate_dataset(
        output_dir / 'train.csv',
        num_rows=args.train_rows,
        start_id=1,
        seed_offset=0
    )
    
    generate_dataset(
        output_dir / 'val.csv',
        num_rows=args.val_rows,
        start_id=args.train_rows + 1,
        seed_offset=1000
    )
    
    generate_dataset(
        output_dir / 'test.csv',
        num_rows=args.test_rows,
        start_id=args.train_rows + args.val_rows + 1,
        seed_offset=2000
    )
    
    print()
    print(f"✓ Successfully generated {args.train_rows + args.val_rows + args.test_rows} total rows")
    print(f"  - Training: {args.train_rows} rows")
    print(f"  - Validation: {args.val_rows} rows")
    print(f"  - Test: {args.test_rows} rows")


if __name__ == '__main__':
    main()
