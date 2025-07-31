#!/usr/bin/env python3
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.ticker import ScalarFormatter

# Read the CSV files
dimensions = pd.read_csv('feature_dimensionalities.csv')['feature_dimensionality'].values
fractions = pd.read_csv('neuron_activation_fraction.csv').iloc[:, 0].values

# Create the scatter plot
plt.figure(figsize=(10, 8))
plt.scatter(fractions, dimensions, alpha=0.3, s=120, c='blue', edgecolors='none')

# Labels and formatting
plt.xlabel('Prevalencia', fontsize=24)
plt.ylabel('Dimensión de características', fontsize=24)
plt.title('Dimensión de características vs Prevalencia', fontsize=28)

# Make tick labels bigger
plt.xticks(fontsize=20)
plt.yticks(fontsize=20)

# Use scientific notation for x-axis
ax = plt.gca()
ax.xaxis.set_major_formatter(ScalarFormatter(useMathText=True))
ax.ticklabel_format(style='scientific', axis='x', scilimits=(0,0))

# Make the scientific notation exponent bigger
ax.xaxis.offsetText.set_fontsize(20)

# Grid for better readability
plt.grid(True, alpha=0.3)

# Tight layout to prevent label cutoff
plt.tight_layout()

# Save as high-quality PNG
plt.savefig('scatter_plot.png', dpi=300, bbox_inches='tight')
print(f"Plotted {len(dimensions)} data points")
print("Scatter plot saved as 'scatter_plot.png'")
