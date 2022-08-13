# Data Science NFL Base Contract Regression Project

* Scraped data to collect stats and base contract value for NFL players from the year 2020
* Cleaned and imputed missing data
* Created data visualizations based on collected data
* Created a statistical model that predicts the base contract value based on player stats
* Used various statstical models to find the best fit

## Code and Resources Used
**R Version:** 4.1.2 (2021-11-01) <br/>
**Packages:** tidyverse, rvest, RSelenium, dplyr, stringr, ggplot2, corrplot, caret, janitor, randomForest, glmnet, rpart 
 

## Data Collection

The data was collected from the following websites:

* https://www.spotrac.com/nfl/rankings/2020/base/
* https://www.nfl.com/stats/player-stats/category/passing/2020/POST/all/passingyards/DESC
* https://www.nfl.com/players/active/all
* https://www.nflpenalties.com/all-players.php?view=total&year=2020

The data collected represented the following: Player Name, Team, Experience, Position, Various Stats (i.e. Passing, Tackling, Kicking, etc.), Penalties. 

## Data Preperation and Cleaning

The collected data  required preparation and cleaning. The following steps were taken:

* Combine the various data sets, while being mindful of duplicate player names in a data set and duplicate variable name among the data sets.
* Go through each position to impute missing data. Verified with external sources to determine if a player with NULL data actually saw no playing time during the 2020 season.
* If there was actually stats data in the 2020 season for a player in our set with NULL data, either the actual data was replaced with the NULL data in the cases were it was only one or two players, or the mean of the variable for that positon was used to impute missing data.
* For the experience variable, the mean of the experience for the position was used to impute the NULL experience data. It was seen that most missing experience data was the result of the player retiring by 2022 which is the year the experience data was collected.
* No easy way to determine if there was any NULL penalty data should should not have been collected.
* Feature engineered the specific type of penalties were received by players from a description of all penalties a player received. The new features were not used in the model however.
* Finally, the remaining NULL data was replaced with zero.

## Data Visualizations

Created various visualizations to explore the data. Examples:

![alt text](https://github.com/jrdhowell/NFL/blob/main/visualizations/dist_base.png)
![alt text](https://github.com/jrdhowell/NFL/blob/main/visualizations/dist_pos.png)
![alt text](https://github.com/jrdhowell/NFL/blob/main/visualizations/box_base_team.png)
![alt text](https://github.com/jrdhowell/NFL/blob/main/visualizations/scatter_exp_base1.png)

The main observation from the EDA and visualizations is that there is no linearity between any variables and the target variable.

## Model

Variables were selected to be used in the model.

Changed all variables into factors. For continuous variables, different buckets were created as they were changed to factors.
For example, variable fg_per (field goal percentage) was changed to a factor with levels for "0%", ">0-70%", ">70-80%", ">80-90%", and ">90-100%".

Split the data into a training and test set to allow for prediction with data not seen by the model.

Created various regression models, including Analysis of Variance, Random Forest, Lasso Regression and Decision Tree.

The model with the best results was the Random Forest with an r-squared of 0.79.

![alt text](https://github.com/jrdhowell/NFL/blob/main/visualizations/RF_importance.png)


## Limitations

The biggest limitations are from the data collected. The data set only consisted of the top 1000 earners in the NFL and the penalty data was only avaible for players with a certain number of penalties. 
The data did not encompass all players from 2020 nor all penalites for all the players in the data set.
