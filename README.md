# Replication Repository for "The Grass is always Greener on the Other Side: (Unfair) Inequality and Support for Democracy"

The repository contains all code underlying the dataset construction and the analysis which can be replicated using "LiTS_analysis_data.dta". 

## "0_globals" sets path globals for input data and outputs;
## "1.1_controls" and "1.2_LiTS" replicate the construction of the control variables and the cleaning of the LiTS III (download links to the underylying data are indicated in the do files);
## "2.1_UI_parametric" calculates parametric unfair inequality (UI) estimates (standard, lasso, CV);
## "2.2_UI_forest" uses condtionla inference forest to estimate UI;
## "3.0_data_preparation" combines the LiTS and controls data with the UI estimates and prepares it for the analysis;
## "3.1_descriptives" estimates country-level descriptives and UI summary statistics; 
## "3.2_regression_analysis" performs the regression analysis of the paper. 
