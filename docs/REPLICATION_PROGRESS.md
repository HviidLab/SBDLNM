# SB-DLNM Replication Study - Progress Report

**Date**: November 11, 2025
**Project**: Time-Series Spatial Bayesian Distributed Lag Non-Linear Model Replication

## Completed Steps

### 1. Project Setup ✓
- Created project directory structure
- Initialized Git repository
- Created GitHub repository at https://github.com/HviidLab/SBDLNM
- Organized SAP documentation in `docs/SAP.md`

### 2. Dependencies Installation ✓
- Downloaded repository from `https://github.com/marcosqz/sbdlnm_smallarea_casestudy`
- Installed all required R packages:
  - sf, spdep, lubridate, dlnm, R2WinBUGS, leaflet, remotes
  - pbugs (from GitHub: fisabio/pbugs)
- WinBUGS 1.4 included in repository at `sbdlnm_repo/WinBUGS14/`

### 3. Data Preparation ✓
- Successfully ran `sbdlnm_repo/01_data_preparation.R`
- Generated output files:
  - `crossbasis_casecrossover.RData` (5.7 MB)
  - `crossbasis_timeseries.RData` (7.9 MB)
  - `data_casecrossover.RData` (4.4 MB)
  - `data_timeseries.RData` (5.8 MB)
  - `dlnm_configuration.RData`
  - `list_neighbours.RData`
  - `trend_timeseries.RData`
  - `seasonality_timeseries.RData`

### 4. Script Configuration ✓
- Modified `sbdlnm_repo/02_run_sbdlm.R`:
  - Enabled only Model 4 (SB-DLNM time-series design)
  - Set to 100 iterations for quick test (original: 50,000)
  - Enabled output file saving
- Modified `sbdlnm_repo/03_plot_sbdlnm.R`:
  - Changed to load Model 4 results instead of Model 3
  - Ready to generate visualizations once model completes

## Current Issue: WinBUGS Execution

**Problem**: WinBUGS is not running successfully via command-line Rscript on Windows.

**Reason**: WinBUGS 1.4 is a GUI-based Windows application that has difficulty running in non-interactive/background shell environments. When called via `pbugs()` from Rscript, it appears to hang.

**Attempted Solutions**:
- Tried running with 10,000 iterations → hung
- Tried running with 100 iterations → hung

## Next Steps

### Option 1: Run Interactively in RStudio (RECOMMENDED)

1. **Open RStudio**
2. **Open the project**: `C:\Users\ander\Documents\SBDLNM\SBDLNM.Rproj`
3. **Set working directory**:
   ```r
   setwd("C:/Users/ander/Documents/SBDLNM/sbdlnm_repo")
   ```
4. **Run the model script interactively**:
   ```r
   source("02_run_sbdlm.R")
   ```
5. **Watch for WinBUGS GUI window** - it may open and show progress
6. **Once complete**, verify output file exists:
   ```r
   file.exists("output/predicted_simsmatrix_model4_spatial_timeseries.RData")
   ```
7. **Generate plots**:
   ```r
   source("03_plot_sbdlnm.R")
   ```
8. **Check plots** in the `plot/` directory

### Option 2: Use Pre-computed Results

The repository includes pre-computed results from the paper authors in `sbdlnm_repo/input/result_paper/`. You could:
1. Use these for initial exploration
2. Generate plots with the paper's results
3. Compare with your own results later

### Option 3: Alternative Bayesian Software

Consider adapting the analysis to use:
- **RStan** or **brms**: Modern R packages for Bayesian analysis
- **JAGS**: Similar to WinBUGS but better command-line support
- **INLA**: Fast alternative for spatial models

This would require modifying the model code but would avoid WinBUGS GUI issues.

## File Locations

- **Project root**: `C:\Users\ander\Documents\SBDLNM\`
- **Repository code**: `C:\Users\ander\Documents\SBDLNM\sbdlnm_repo\`
- **Data outputs**: `C:\Users\ander\Documents\SBDLNM\sbdlnm_repo\output\`
- **Plots**: `C:\Users\ander\Documents\SBDLNM\sbdlnm_repo\plot\`
- **Installation script**: `C:\Users\ander\Documents\SBDLNM\scripts\00_install_packages.R`

## Model Configuration

Current settings in `02_run_sbdlm.R`:
```r
execute_model <- list(
  "model1" = FALSE,  # Independent B-DLNM, case-crossover
  "model2" = FALSE,  # Independent B-DLNM, time-series
  "model3" = FALSE,  # SB-DLNM, case-crossover
  "model4" = TRUE    # SB-DLNM, time-series ← ACTIVE
)

n.iter <- list("model4" = 100)  # Test: 100, Full: 50000
n.chains <- 3
```

## Expected Runtime

- **100 iterations**: ~1-5 minutes
- **10,000 iterations**: ~20-60 minutes
- **50,000 iterations (full)**: ~2-5 hours

Runtime varies significantly based on system specifications and whether WinBUGS can utilize multiple cores effectively.

## Troubleshooting

If WinBUGS still has issues in RStudio:
1. Check that WinBUGS executable exists: `sbdlnm_repo/WinBUGS14/WinBUGS14.exe`
2. Try running WinBUGS directly to ensure it works on your system
3. Check Windows permissions - WinBUGS may need admin rights
4. Review `pbugs` documentation: `?pbugs::pbugs`

## References

- **Paper**: Quijal-Zamorano et al. (2024), DOI: 10.1093/ije/dyae061
- **GitHub**: https://github.com/marcosqz/sbdlnm_smallarea_casestudy
- **Your repo**: https://github.com/HviidLab/SBDLNM
