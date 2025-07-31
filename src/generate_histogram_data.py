#!/usr/bin/env python3
import pandas as pd
import numpy as np

# Read the non-log activation fractions
fractions = pd.read_csv('neuron_activation_fraction.csv').iloc[:, 0].values

# Apply log10 transformation
log_fractions = np.log10(fractions + 1e-10)  # Add small epsilon to avoid log(0)

# Restrict to range -7 to 0 and create bins
bin_edges = np.linspace(-7, 0, 71)  # 70 bins from -7 to 0
counts, bin_edges = np.histogram(log_fractions, bins=bin_edges)

# Create bin labels as log10 exponents (use bin centers)
bin_labels = []
for i in range(len(bin_edges) - 1):
    # Use the center of each bin, rounded to 1 decimal place
    bin_center = (bin_edges[i] + bin_edges[i+1]) / 2
    bin_labels.append(round(bin_center, 1))

# Create DataFrame for the histogram data
histogram_df = pd.DataFrame({
    'bin_label': bin_labels,
    'count': counts
})

# Filter out bins with zero counts for cleaner visualization
histogram_df = histogram_df[histogram_df['count'] > 0]

# Save to CSV
histogram_df.to_csv('histogram_data.csv', index=False)

print(f"Generated histogram with {len(histogram_df)} non-empty bins")
print(f"Log10 range: {log_fractions.min():.2f} to {log_fractions.max():.2f}")
print(f"Original range: {fractions.min():.2e} to {fractions.max():.2e}")
print("Histogram data saved as 'histogram_data.csv'")