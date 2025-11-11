# Install required packages for SB-DLNM replication study
# This script installs all dependencies needed for the analysis

cat("Installing required R packages...\n")

# List of CRAN packages to install
cran_packages <- c(
  "sf",           # Spatial data handling
  "spdep",        # Spatial dependence
  "lubridate",    # Date manipulation
  "dlnm",         # Distributed lag non-linear models
  "R2WinBUGS",    # R interface to WinBUGS
  "leaflet",      # Interactive maps
  "remotes"       # For installing from GitHub
)

# Install CRAN packages
cat("\nInstalling CRAN packages...\n")
for (pkg in cran_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    cat(sprintf("Installing %s...\n", pkg))
    install.packages(pkg, repos = "https://cloud.r-project.org/")
  } else {
    cat(sprintf("%s is already installed.\n", pkg))
  }
}

# Install pbugs from GitHub
cat("\nInstalling pbugs from GitHub...\n")
if (!requireNamespace("pbugs", quietly = TRUE)) {
  remotes::install_github("fisabio/pbugs")
  cat("pbugs installed successfully.\n")
} else {
  cat("pbugs is already installed.\n")
}

cat("\nAll packages installed successfully!\n")
