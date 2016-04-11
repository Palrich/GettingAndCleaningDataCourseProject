Getting and Cleaning Data Course Project
========================================
author: Richard Paleczny


Project Details
---------------

(As taken from the project desc. on Coursera)
The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.

You should create one R script called run_analysis.R that does the following.

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement.
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names.
5. From the data set in step 4, creates a second, independent tidy data set with the average of     each variable for each activity and each subject.


Information about Project
-------------------------------

Refer to CodeBook.md in this repo for details on how to reproduce the analysis and to create the tidy data. For the purposes of the codebook, the variable "tableTidy" is the one being described in the codebook, which is the independent tidy data table with the averages calculated. For the larger tidy data table from which "tableTidy" was derived, see the variable "mergeTableAllData".

Walkthrough of script "run_analysis.r":

For this project I decided to use data tables entirely to make processes run quicker and also for simplicity. This script first acquires the packages "data.table" and "reshape2". The script then assumes the user to be in the directory containing the folder "UCI HAR Dataset". This is necessary so that the rest of the script can run and start reading the files. The files are read using fread. First the data containing subject ID numbers is read and then the files containing the data on the type of activity pose the subject was engaged in when the measurement was taken. And lastly, the files containing the actual experimental values are read in. All of these files can be merged and have the same number of rows because they all correspond to each other(i.e. the measurements recorded which subjects did which activities at what times and the positions of the data match between subject and activity and measurement). 

Firstly, I rowbind subject ID tables and activity tables between both test groups "train" and "test" to get one table containing information about the entire study. I do the same with the experimental data. I take all of these row bound tables and merge them into one large table, "mergeTableAllData". Since the project calls for information about only the mean and sd of the experimental values, I subset "mergeTableAllData" by grepped "mean" and "sd" features from "features.txt", these are the columns in "mergeTableAllData" which correspond to all features from "features.txt" list which contain information about mean and sd.

Next, I merge "mergeTableAllData" with the labels in "activity_labels.txt" by an "activityName" column as key, so that each value in "activityType" corresponds to its proper label. Since experimental values are all spread out in the "mergeTableAllData", I melt the dataset into one long dataset keeping all columns except those containing experimental values. Lastly, regular expressions are used to filter out different descriptive data about different features. The activity and feature columns of the "mergeTableAllData" are converted to factors to allow matrix multiplication of grepl values to ultimately create one long matrix that correspond to different factor levels of features column. The labels are applied level wise, where label 1 is level 1, depending on the value in the matrix, 1, 2, 3. The number of levels depends on the number of ways a particular feature can be categorized, see the codebook and script for variable names and the different ways in which features were categorized.

Lastly, another independent tidy data set is created by subsetting the main data set and applying a mean function to the experimental values, to get an average either of standard deviations or means.
