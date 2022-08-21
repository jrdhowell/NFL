#load packages

#load packages
library("tidyverse")
library("plumber")
library("randomForest")


#* @apiTitle API NFL Base Contract 
#* @apiDescription Predict the Base Contract amount based on Stats
#* @param team  
#* @param exp Experience 
#* @param pos Position
#* @param fg_per Field Goal Percentage 
#* @param fg_blk Field Goals Blocked 
#* @param fumb_force Forced Fumbles
#* @param fumb_return Fumble Recoveries
#* @param fumb_td Fumble Touchdown
#* @param int_int Interceptions 
#* @param int_lng Longest Interception Return
#* @param ko_yds Total Kickoff Yards (kicker)
#* @param ko_osk_rec Successful Onside Kicks (kicker)
#* @param ko_td Kickoff TD Returns (kicker)
#* @param ko_outbounds Out of bounds kickoff (kicker)
#* @param kor_avg Kickoff return average (returner)
#* @param kor_yds Total kickoff return yards (returner)
#* @param kor_td Kickoff Return Touchdowns (returner)
#* @param kor_fumb Kickoff Return Fumbles (returner)
#* @param pass_td Passing Touchdowns (QB)
#* @param pass_int Passing Interceptions (QB)
#* @param pass_rating Passing Rating (QB)
#* @param pen_penalties Number of Penalties
#* @param pen_yds Total Yards of Penalties
#* @param pen_presnap Number of Presnap Penalties
#* @param pr_avg Punt Return Average (returner)
#* @param pr_yds Total Punt Return Yards (returner)
#* @param pr_long Longest Punt Return in Yards (returner)
#* @param pr_fumb Punt Return Fumbles (returner)
#* @param rec_yds Total Reception Yards (receiver)
#* @param rec_fumble Total Fumbles after Pass (receiver)
#* @param rush_yds Total Rush Yards
#* @param rush_fumble Total Fumbles while Rushing
#* @param tack_comb Number of Combined Tackles
#* @param tack_sack Number of Sacks
#* @get /regression


function(team = "GB", pos = "QB", exp = "3", fg_per = "0", fg_blk = "0", fumb_force = "0", fumb_return = "0", fumb_td = "0", int_int = "0", 
         int_lng = "0", ko_yds = "0", ko_osk_rec = "0", ko_td = "0", ko_outbounds =  "0", kor_avg = "0", kor_yds = "0", kor_td = "0", 
         kor_fumb = "0", pass_td = "20", pass_int = "10", pass_rating = "90", pen_penalties = "0", pen_yds = "0", 
         pen_presnap = "0", pr_avg = "0", pr_yds = "0", pr_long = "0", pr_fumb = "0", rec_yds = "0", rec_fumble = "0", 
         rush_yds = "0", rush_fumble = "0", tack_comb = "0", tack_sack = "0"){
  
  model <- readRDS('model.rds')
  
  test <- data.frame("team" = as.character(team), 
                     "pos" = as.character(pos),
                     "exp" = as.numeric(exp), 
                     "fg_per" = as.double(fg_per), 
                     "fg_blk" = as.numeric(fg_blk), 
                     "fumb_force" = as.numeric(fumb_force), 
                     "fumb_return" = as.numeric(fumb_return), 
                     "fumb_td" = as.numeric(fumb_td), 
                     "int_int" = as.numeric(int_int), 
                     "int_lng" = as.numeric(int_lng), 
                     "ko_yds" = as.numeric(ko_yds), 
                     "ko_osk_rec" = as.numeric(ko_osk_rec), 
                     "ko_td" = as.numeric(ko_td), 
                     "ko_outbounds" = as.numeric(ko_outbounds), 
                     "kor_avg" = as.double(kor_avg), 
                     "kor_yds" = as.numeric(kor_yds), 
                     "kor_td" = as.numeric(kor_td), 
                     "kor_fumb" = as.numeric(kor_fumb), 
                     "pass_td" = as.numeric(pass_td), 
                     "pass_int" = as.numeric(pass_int), 
                     "pass_rating" = as.double(pass_rating), 
                     "pen_penalties" = as.numeric(pen_penalties), 
                     "pen_yds" = as.numeric(pen_yds),
                     "pen_presnap" = as.numeric(pen_presnap), 
                     "pr_avg" = as.double(pr_avg), 
                     "pr_yds" = as.numeric(pr_yds), 
                     "pr_long" = as.numeric(pr_long), 
                     "pr_fumb" = as.numeric(pr_fumb), 
                     "rec_yds" = as.numeric(rec_yds), 
                     "rec_fumble" = as.numeric(rec_fumble), 
                     "rush_yds" = as.numeric(rush_yds), 
                     "rush_fumble" = as.numeric(rush_fumble), 
                     "tack_comb" = as.numeric(tack_comb), 
                     "tack_sack" = as.double(tack_sack))
  
  
  test <- test %>% 
    summarise(base = as.double("200000"),
              team = factor(team, model$forest$xlevels$team), 
              pos = factor(pos, model$forest$xlevels$pos),
              exp = factor(exp, model$forest$xlevels$exp),
              fg_per = factor(ifelse(fg_per <= 0, "0", 
                              ifelse(fg_per <= 70, "<=70%",
                              ifelse(fg_per <= 80, ">70-80%", 
                              ifelse(fg_per <= 90, ">80-90%", ">90-100%")))),
                              model$forest$xlevels$fg_per),
              fg_blk = factor(fg_blk, model$forest$xlevels$fg_blk),
              fumb_force = factor(fumb_force, model$forest$xlevels$fumb_force),
              fumb_return = factor(fumb_return, model$forest$xlevels$fumb_return),
              fumb_td = factor(fumb_td, model$forest$xlevels$fumb_td),
              int_int = factor(as.integer(int_int), model$forest$xlevels$int_int),
              int_lng = factor(ifelse(int_lng <= 0, "0",
                               ifelse(int_lng <=15, "1-15",
                               ifelse(int_lng <= 30, "16-30",
                               ifelse(int_lng <= 60, "31-60", ">60")))),
                               model$forest$xlevels$int_lng),
              ko_yds = factor(ifelse(ko_yds <= 0, "0",
                              ifelse(ko_yds <=4000, ">0-4000",
                              ifelse(ko_yds <=5000, ">4000-5000",
                              ifelse(ko_yds <=6000, ">5000-6000", ">6000")))),
                              model$forest$xlevels$ko_yds),
              ko_osk_rec = factor(as.integer(ko_osk_rec), model$forest$xlevels$ko_osk_rec),
              ko_td = factor(as.integer(ko_td), model$forest$xlevels$ko_td),
              ko_outbounds = factor(as.integer(ko_outbounds), model$forest$xlevels$ko_outbounds),
              kor_avg = factor(ifelse(kor_avg <= 0, "0",
                               ifelse(kor_avg <= 10, ">0-10",
                               ifelse(kor_avg <= 20, ">10-20",
                               ifelse(kor_avg <= 30, ">20-30", ">30")))),
                               model$forest$xlevels$kor_avg),
              kor_yds = factor(ifelse(kor_yds <= 0, "0",
                               ifelse(kor_yds <= 250, "1-250", 
                               ifelse(kor_yds <= 500, "251-500", 
                               ifelse(kor_yds <= 750, ">501-750", ">750")))),
                               model$forest$xlevels$kor_yds),
              kor_td = factor(ifelse(kor_td <= 0, "None", "One or more"), 
                              model$forest$xlevels$kor_td),
              kor_fumb = factor(as.integer(kor_fumb), model$forest$xlevels$kor_fumb),
              pass_td = factor(ifelse(pass_td <=0 , "None",
                               ifelse(pass_td <= 10, "1-10", 
                               ifelse(pass_td <= 20, "11-20", 
                               ifelse(pass_td <= 30, "21-30", "31+")))),
                               model$forest$xlevels$pass_td),
              pass_int = factor(ifelse(pass_int <= 0, "0", 
                               ifelse(pass_int <= 5, "1-5",
                               ifelse(pass_int <= 10, "6-10", "11+"))),
                               model$forest$xlevels$pass_int),
              pass_rating = factor(ifelse(pass_rating <= 0, "0",
                                   ifelse(pass_rating <= 50, ">0-50", 
                                   ifelse(pass_rating <= 70, ">50-70", 
                                   ifelse(pass_rating <= 90, ">70-90", 
                                   ifelse(pass_rating <= 120 , ">90-120", "120+"))))),
                                   model$forest$xlevels$pass_rating),
              pen_penalties = factor(ifelse(pen_penalties <= 0 ,"0", 
                                     ifelse(pen_penalties <= 3, "0-3", 
                                     ifelse(pen_penalties <= 6, "4-6", 
                                     ifelse(pen_penalties <= 9, "7-9", "10+")))),
                                     model$forest$xlevels$pen_penalties),
              pen_yds = factor(ifelse(pen_yds <= 0, "0", 
                               ifelse(pen_yds <= 30, "1-30",
                               ifelse(pen_yds <= 60, "31-60",
                               ifelse(pen_yds <= 90, "61-90", "91+")))),
                               model$forest$xlevels$pen_yds),
              pen_presnap = factor(pen_presnap, model$forest$xlevels$pen_presnap),
              pr_avg = factor(ifelse(pr_avg <= 0, "0", 
                              ifelse(pr_avg <= 10, "1-10", 
                              ifelse(pr_avg <= 20, "11-20", "21+"))),
                              model$forest$xlevels$pr_avg),
              pr_yds = factor(ifelse(pr_yds <= 0, "0", 
                              ifelse(pr_yds<= 100, "1-100", 
                              ifelse(pr_yds <= 200, "101-200", 
                              ifelse(pr_yds <= 300, "201-300", "201+")))),
                              model$forest$xlevels$pr_yds),
              pr_long = factor(ifelse(pr_long <= 0, "0", 
                               ifelse(pr_long <=20, "0-20", 
                               ifelse(pr_long <= 50, "21-50", "50+"))),
                               model$forest$xlevels$pr_long),
              pr_fumb = factor(ifelse(pr_fumb <= 0, "None", "One or more"),
                               model$forest$xlevels$pr_fumb),
              rec_yds = factor(ifelse(rec_yds <= 0 ,"0", 
                               ifelse(rec_yds <= 250, "1-250", 
                               ifelse(rec_yds <= 500, "251-500", 
                               ifelse(rec_yds <= 750, "501-750", 
                               ifelse(rec_yds <= 1000, "750-1000", "1000+"))))),
                               model$forest$xlevels$rec_yds),
              rec_fumble = factor(as.integer(rec_fumble), model$forest$xlevels$rec_fumble),
              rush_yds = factor(ifelse(rush_yds <=0 , "0", 
                                ifelse(rush_yds <= 250, "1-250", 
                                ifelse(rush_yds <= 500, "251-500", 
                                ifelse(rush_yds <= 750, "501-750", 
                                ifelse(rush_yds <= 1000, "750-1000", 
                                ifelse(rush_yds <= 1500, "1001-1500", "1500+")))))),
                                model$forest$xlevels$rush_yds),
              rush_fumble = factor(ifelse(rush_fumble <= 0, "0", 
                                   ifelse(rush_fumble == 1, "1", 
                                   ifelse(rush_fumble == 2, "2", 
                                   ifelse(rush_fumble == 3, "3", 
                                   ifelse(rush_fumble == 4, "4", 
                                   ifelse(rush_fumble == 5, "5", "6+")))))),
                                   model$forest$xlevels$rush_fumble),
              tack_comb = factor(ifelse(tack_comb <= 0 ,"0",
                                 ifelse(tack_comb <= 50, "1-50", 
                                 ifelse(tack_comb <= 100, "51-100", "101+"))),
                                 model$forest$xlevels$tack_comb),
              tack_sack = factor(ifelse(tack_sack <= 0 , "0", 
                                 ifelse(tack_sack <= 5, "1-5", 
                                 ifelse(tack_sack <= 10, "6-10", "10+"))),
                                 model$forest$xlevels$tack_sack))
  
  
exp(predict(model, test))
  
}