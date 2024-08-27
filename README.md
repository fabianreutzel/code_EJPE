# Replication files for *The Grass is always Greener on the Other Side: (Unfair) Inequality and Support for Democracy*

#### *Author:* Fabian Reutzel

#### *Journal:* [European Journal of Political Economy](https://www.sciencedirect.com/journal/european-journal-of-political-economy)

#### *Year:* 2024 

The repository contains all code files to replicate the dataset construction and all tables and figures of the paper (primarily `Stata` format).

To start the replication, you first have to set path globals for input data and outputs via `0_global.do`.

## Dataset

The analysis' dataset  `LiTS_analysis_data.dta` is based on publicly available databases (download links are provided in the code) and constructed using the following code files: 

- `1.1_controls.do` replicates the construction of the control variables; 

- `1.2_LiTS.do` cleans the Life in Transition Survey (LiTS) III survey; 

- `3.0_data_preparation.do` combines LiTS and controls data with the UI estimates and prepares it for the analysis.


## Estimation of Unfair Inequality (UI)

While the main results of the paper rely on UI estimates based on regression forests [(Brunori et al., 2023)](https://onlinelibrary.wiley.com/doi/full/10.1111/sjoe.12530), estimates on other parametric estimation techniques are provided as robustness check (see Online Appendix Section AII). 

- `2.1_UI_parametric.do`: calculates parametric unfair UI estimates (standard, lasso, CV); 

- `2.2_UI_forest.R`: uses conditional inference forest to estimate UI (`R` code);

## Descriptives & Analysis

All tables and figures of the paper are produced by the following code files: 

- `3.1_descriptives.do`: estimates country-level descriptives and UI summary statistics; 

- `3.2_analysis.do`: performs the regression, robustness and sensitivity analysis of the paper.
