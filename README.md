# Replication files for *The Grass is always Greener on the Other Side: (Unfair) Inequality and Support for Democracy*

*Author:* Fabian Reutzel 

*Journal:* [European Journal of Political Economy](https://www.sciencedirect.com/journal/european-journal-of-political-economy)

*Year:* 2024

The repository contains all code files to replicate the dataset construction and all tables and figures of the paper (Stata format). To start the replication you first have to set path globals for input data and outputs via `0_global.do`. 


### Dataset for analysis `LiTS_analysis_data.dta` 
The dataset underlying the analysis is based on publicly available databases (download links are provided in the code files).  
- `1.1_controls.do` replicates the construction of the control variables;
- `1.2_LiTS.do` cleans the Life in Transition Survey (LiTS) III survey;
- `3.0_data_preparation` combines LiTS and controls data with the UI estimates and prepares it for the analysis.


### Estimation of Unfair Inequality (UI) 
While the main results of the paper rely on UI estimates based on regression forests [Brunori et al. (2023)](https://onlinelibrary.wiley.com/doi/full/10.1111/sjoe.12530),
estimates on other parametric estimation techniques are provided as robustness check (see Online Appendix Section AII).
- `2.1_UI_parametric`: calculates parametric unfair UI estimates (standard, lasso, CV);
- `2.2_UI_forest`: uses conditional inference forest to estimate UI;

#### Descriptives & Regression Analysis 
All tables and figures of the paper are produced by the following code files:
- `3.1_descriptives`: estimates country-level descriptives and UI summary statistics; 
- `3.2_regression_analysis`: performs the regression, robustness and sensitivity analysis of the paper.
