# Gallstone Prediction from Clinical & Body Composition Features

A binary classification pipeline in R that predicts gallstone presence from clinical and body composition measurements. 
Three classification approaches are compared using AUC as the primary evaluation metric.

## Overview

This project builds and evalutes a classification piepline on a 322-sample clinical datasewt with 38 total features.
The pipeline serves as a before and after comparison -- models are first evaluated on all features, then on PCA-derived components 
to assess the impact of dimensionality reduction on predictive performance

## Models
| Model | Description | 
|---|---|
| Linear Discriminant Analysis (LDA) | Finds linear combinations of features that best separate classes | 
| Logistic Regression | Baseline binary classifier on raw and PCA features | 
| Regular ized Logistic Regression (Lasso) | L1-penalized logistic regression using cv.glmnet, lambda selected by cross-validation | 

## Pipeline

### Stage 1 - Raw Features
The three models above are fit directly on full feature set with an 80/20 train/test split. 

### Stage 2 - PCA + Factor Analysis
* Features are reduced using PCA with varimax rotation
* Parallel analysis is used to determine the optimal number of components (7 components/factors retained)
* Redundant/low-variance features removed before final factor extraction
* Factor scores are used as predictors in the logistic and regularized logistic regression

The before/after comparison in the pipeline isolates the effect of dimensionality reduction on classification performance. 

## Results

*AUC results coming soon.*

| Model | Stage | Train AUC | Test AUC |
|---|---|---|---|
| LDA | Raw Features | — | — |
| Logistic Regression | Raw Features | — | — |
| Lasso Regression | Raw Features | — | — |
| Logistic Regression | PCA Features | — | — |
| Lasso Regression | PCA Features | — | — |

## Dataset 
**Gallstone Dataset** -- sourced from the [UCI Machine Learning Repository](https://archive.ics.uci.edu/dataset/1150/gallstone-1)
  * 322 samples
  * 38 clinical and body composition features (BMI, cholesterol, liver enzymes, body water, etc.)
  * Target variable: Gallstone (binary: 0 = absent, 1 = present)

## Usage

**1. Install required R packages**
```r
install.packages(c("MASS", "glmnet", "psych", "pROC", "corrplot", 
                   "ggplot2", "GGally", "patchwork", "DataExplorer"))
```

**2. Place the dataset in the project root**

Download `gallstonenew.csv` from [UCI](https://archive.ics.uci.edu/) and place it in the same directory as the script.

**3. Run the script**
```r
source("model.R")
```

## Dependencies 
* R 4.0+
* MASS
* glmnet
* psych
* pROC
* corrplot
* ggplot2
* GGally
* patchwork
* DataExplorer

## Author
**Peter Teresi** [GitHub](https://github.com/pteresi05) - [LinkedIn](https://linkedin.com/in/pete-teresi/)


