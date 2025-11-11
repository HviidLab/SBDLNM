```markdown
# Time-Series SB-DLNM Setup Specification for Claude Code CLI

This document provides a complete, self‑contained specification for setting up and running the **time‑series variant** of the spatial Bayesian distributed lag non‑linear model (SB‑DLNM) described by Quijal‑Zamorano et al. (2024).  It is intended as a starting point for use with Claude Code CLI running on an MCP server in R Studio.  The goal is to automate fetching the necessary resources, installing dependencies and executing the analysis with minimal human intervention.

## 1 Overview

The SB‑DLNM extends traditional distributed lag non‑linear models by introducing spatial dependence between locations.  The time‑series version models lagged non‑linear associations between daily temperature and mortality in small areas while adjusting for long‑term and seasonal trends.  The paper’s authors provide R/WinBUGS code and simulated data so that the analysis can be reproduced without requiring access to confidential mortality records:contentReference[oaicite:0]{index=0}.  These resources are available both as supplementary material in the journal and in an open GitHub repository:contentReference[oaicite:1]{index=1}.

## 2 Resources to Fetch Automatically

Claude Code CLI should download and prepare the following resources during project setup:

| Resource | URL | Purpose |
|---|---|---|
| **Paper (SB‑DLNM)** | DOI: `10.1093/ije/dyae061` | Provides methodological background; supplementary data include code:contentReference[oaicite:2]{index=2}. |
| **GitHub repository** | `https://github.com/marcosqz/sbdlnm_smallarea_casestudy` | Contains the R scripts, WinBUGS model files and simulated datasets:contentReference[oaicite:3]{index=3}. |
| **Repository ZIP** | `https://github.com/marcosqz/sbdlnm_smallarea_casestudy/archive/refs/heads/main.zip` | Used for downloading the repository without `git`. |
| **R package `pbugs`** | `remotes::install_github("fisabio/pbugs")` | Provides the `pbugs()` interface used to call WinBUGS from R. |
| **WinBUGS 1.4** | Included in the repository (`WinBUGS14` folder) | Executable called by `pbugs()` to fit Bayesian models; no external download required. |

## 3 Automated Setup Steps

1. **Create project directory** – e.g., `ts_sb_dlnm_project`.

2. **Download and unpack the repository:**
   ```bash
   # within the project directory
   curl -L -o sbdlnm.zip https://github.com/marcosqz/sbdlnm_smallarea_casestudy/archive/refs/heads/main.zip
   unzip sbdlnm.zip
   mv sbdlnm_smallarea_casestudy-main sbdlnm_repo
   rm sbdlnm.zip

```

1. **Install required R packages.** In an R session, run:
    
    ```r
    install.packages(c("sf", "spdep", "lubridate", "dlnm", "R2WinBUGS", "leaflet"))
    if (!requireNamespace("remotes", quietly = TRUE)) install.packages("remotes")
    remotes::install_github("fisabio/pbugs")  # required for WinBUGS interface
    
    ```
    
2. **Prepare data for the time‑series model.** The repository contains `01_data_preparation.R`, which creates cross‑basis matrices and trend/seasonality objects. Execute this script using Rscript and ensure it runs in the repository directory:
    
    ```bash
    Rscript sbdlnm_repo/01_data_preparation.R
    
    ```
    
    This script loads the simulated time‑series data and shapefile and writes several `.RData` files into the `output` folder.  Note that the mortality data are simulated to preserve confidentiality.
    
3. **Run the time‑series SB‑DLNM.** The second script, `02_run_sbdlm.R`, defines four models. To execute **only the time‑series SB‑DLNM** (Model 4), modify the `execute_model` list at the top of the script so that only `"model4"` is set to `TRUE`:
    
    ```r
    execute_model <- list(
      "model1" = FALSE,  # independent B‑DLNM, case‑crossover design
      "model2" = FALSE,  # independent B‑DLNM, time‑series design
      "model3" = FALSE,  # spatial B‑DLNM, case‑crossover design
      "model4" = TRUE    # spatial B‑DLNM, time‑series design (SB‑DLNM)
    )
    
    ```
    
    You may also adjust the number of iterations and chains (e.g., `n.iter$model4` and `n.chains`) to balance run time and accuracy.  Then run the script:
    
    ```bash
    Rscript sbdlnm_repo/02_run_sbdlm.R
    
    ```
    
    The script calls WinBUGS via the `pbugs` package to fit the time‑series SB‑DLNM and writes the posterior samples to the `output` directory.
    
4. **Generate plots.** Use `03_plot_sbdlnm.R` to visualize exposure–lag–response surfaces, cumulative exposure–response curves and spatial maps for the time‑series SB‑DLNM. Running the script without modification loads the results for Model 3 (case‑crossover). To instead plot the time‑series SB‑DLNM (Model 4), edit the line that loads `final_simsmatrix_model3_spatial_casecrossover.RData` to point to the output file from Model 4. For example:
    
    ```r
    # In 03_plot_sbdlnm.R, replace the following line:
    # load("input/result_paper/final_simsmatrix_model3_spatial_casecrossover.RData")
    # with:
    load("output/predicted_simsmatrix_model4_spatial_timeseries.RData")
    
    ```
    
    Then run:
    
    ```bash
    Rscript sbdlnm_repo/03_plot_sbdlnm.R
    
    ```
    
5. **Review outputs.** The `output` directory will contain: posterior sample matrices, cross‑basis objects, trend and seasonality matrices, and produced plots. Use these to verify that the time‑series SB‑DLNM reproduces the associations reported in the paper.

## 4 Configuration for Future Datasets

The repository’s scripts currently embed many parameters (e.g., maximum lag, knots for exposure/lag dimensions, and spline degrees of freedom).  To make the workflow flexible, you may introduce a YAML configuration file (e.g., `config_ts.yml`) with entries such as:

```yaml
# Example configuration for the time-series SB‑DLNM
data:
  timeseries_path: input/daily_data.RData
  spatial_path: input/shapefile_bcn.shp
model:
  max_lag: 8
  var_prc: [0.50, 0.90]   # percentiles for exposure knots
  var_fun: "ns"          # exposure spline function
  lagnk: 2               # number of lag knots
  df_trend: 1            # degrees of freedom for long-term trend (per 10 years)
  df_seas: 4             # degrees of freedom for seasonal trend
execution:
  n_iter: 50000          # number of iterations for WinBUGS
  n_chains: 3            # number of chains for WinBUGS

```

You would then refactor the R scripts to read parameters from this file and adjust the model accordingly.  This step is optional for basic replication but recommended for reusable workflows.

## 5 Assumptions & Notes

- The code assumes WinBUGS 1.4 can be executed via the `pbugs` package. The repository contains the `WinBUGS14` directory, which should work on most systems; if not, manual installation may be required.
- The mortality data provided in the repository are **simulated**. To run the analysis on real data, you must obtain the original dataset from the Barcelona Public Health Agency and replace the simulated file.
- Running the time‑series SB‑DLNM may be computationally intensive. Adjust iteration counts to suit available computational resources.

## 6 Summary

By following the automated steps above—downloading the GitHub repository, installing the required packages, preparing the data and running the time‑series SB‑DLNM—Claude Code CLI should be able to set up and execute the analysis with minimal manual input.  Additional refinements, such as introducing a YAML configuration file and refactoring the scripts into modular functions, will further enhance usability and adaptability.