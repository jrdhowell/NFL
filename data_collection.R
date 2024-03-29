

# Below we will be webscraping data from 4 different sources

#(1) we will grab a table of players, their position, team and base contract from spotrac.com from the 2020 season, noting that it only includes the "top" salaries from 2020 (1000 entries)

#(2) from  NFL.com, using some helper function and nested loops, stats for players in the 2020 season will be scraped from several different sites

#(3) from NFL.com, using a similar technique, get experience data for players from 2022 season. This will need to be accounted for later.

#(4) from nflpenalties.com penalty data will be scraped, noting that it only includes penalty data for players that accumalated at least 4 accepted penalties in 2020

#(5) export data sets as .csv files

  


#load packages
load.libraries <- c('tidyverse', 'rvest', 'RSelenium', 'dplyr', 'stringr')
install.lib <- load.libraries[!load.libraries %in% installed.packages()]
for(libs in install.lib) install.packages(libs, dependences = TRUE)
sapply(load.libraries, require, character = TRUE)


#create webdriver
rD <- rsDriver(browser="firefox", port=4567L, verbose = FALSE)
remDr <- rD[["client"]]




#navigate to first site
remDr$navigate("https://www.spotrac.com/nfl/rankings/2020/base/")

#collect site elements
html <- remDr$getPageSource()[[1]]
website <- read_html(html)


#Collect base salary and position data
allTables <- html_nodes(website, css = "table")
dt <- html_table(allTables[[1]], fill = TRUE)

#collect clean player names
player_data_html <- html_nodes(website,'.team-name')
player_data <- html_text(player_data_html)

#create complete dataframe of player, team, position and base contract 
df <- data_frame(player_data, as.data.frame(dt)[,2], as.data.frame(dt)[,3], as.data.frame(dt)[,4])
colnames(df) <- c("Player", "team", "pos", "base")

#clean whitespaces from team
df <- df %>% mutate(team = substr(team, nchar(team)-3, nchar(team))) %>% mutate(team = str_trim(team))







# helper functions to extract the data
# from https://www.nfl.com/stats/player-stats/category/passing/2020/POST/all/passingyards/DESC

entity <- function(s){
  
  # function to return the table 
  # from current page (s) as dataframe
  
  allTables <- html_nodes(s, css = "table")
  
  dtable <- html_table(allTables)
  
  data <- as.data.frame(dtable)
  
  return(data)
}



getData <- function(mainURL, subURL, target, remDr){
  
  # function to return all data from all pages in subURLs
  
  #target website
  url = paste(mainURL, subURL, sep = "")
  
  #navigate to website with 
  remDr$navigate(url)
  
  #pause for website navigation
  Sys.sleep(1)
  
  #got information about current page
  html <- remDr$getPageSource()[[1]]
  website <- read_html(html)
  
  #save data from table on the page
  tempdf <- entity(website)
  
  #store nextpage location, if no nextpage then NA
  nextpage <- website %>% html_node(target)
  
  #while the next page button exists
  while (!is.na(nextpage)) {
    #navigate page
    #scroll down
    webElem <- remDr$findElement("css", "body")
    webElem$sendKeysToElement(list(key = "end"))
    
    #find button
    morepages <- remDr$findElement(using = 'css selector', target)
    #click button to move to "next page"
    morepages$clickElement()
    #pause for page to load
    Sys.sleep(1)  
    
    
    #add data from new page
    #and update current page inf
    html <- remDr$getPageSource()[[1]]
    website <- read_html(html)
    tempdf <- rbind(tempdf, entity(website))
    nextpage <- website %>% html_node(target)
  }
  
  return(tempdf)
  
}




#second website link for player stats in 2020
link <- "https://www.nfl.com/stats/player-stats/category/passing/2020/POST/all/passingyards/DESC"

website <- read_html(link)

# Extracting sub URLs
# this will select each stats category 
subURLs <- html_nodes(website,'.d3-o-tabs__list-item') %>% 
  html_children() %>% 
  html_attr('href')


# Removing NA values and last `/browse` URL
subURLs <- subURLs[!is.na(subURLs)][1:11]

# Main URL - to complete the above URLs
mainURL <- "https://www.nfl.com"



#nextpage target
target <- '.nfl-o-table-pagination__buttons'



#scraping stats data

df_pass <- getData(mainURL, subURLs[1], target, remDr)

df_rush <- getData(mainURL, subURLs[2], target, remDr)

df_rec <- getData(mainURL, subURLs[3], target, remDr)

df_fumb <- getData(mainURL, subURLs[4], target, remDr)

df_tack <- getData(mainURL, subURLs[5], target, remDr)

df_int <- getData(mainURL, subURLs[6], target, remDr)

df_fg <- getData(mainURL, subURLs[7], target, remDr)

df_ko <-  getData(mainURL, subURLs[8], target, remDr)

df_kor <- getData(mainURL, subURLs[9], target, remDr)

df_punt <- getData(mainURL, subURLs[10], target, remDr)

df_pr <- getData(mainURL, subURLs[11], target, remDr)







# helper functions to scrape the data
# from https://www.nfl.com/players/active/all


scrape <- function(remDr){
  
  # function to return the Player and experience level 
  # from current page as dataframe
  
  player <- remDr$findElement(using = "css",".nfl-c-player-header__title")
  
  experience <- remDr$findElements(using = "css",".nfl-c-player-info__value")
  
  # create dataframe, data we are looking for is the fifth element
  # in experience list
  data <- data.frame(player$getElementText()[[1]], experience[[5]]$getElementText()[[1]])
  
  # add column names
  colnames(data) <- c("Player", "exp")
  
  return(data)
}




getPlayers <- function(URL, target, remDr){
  
  # function to cycle through all pages (nextpage button)
  # and return all data from all sub pages
  # will return dataframe of all players and experience in a 
  # certain letter catagory (ex. A)
  
  # navigate to page
  remDr$navigate(URL)
  
  # collect page elements
  html <- remDr$getPageSource()[[1]]
  website <- read_html(html)
  
  # morepages will direct to each player's page
  morepages <- remDr$findElements(using = 'css selector', '.d3-o-player-fullname')
  
  # to store data
  df_temp <- data.frame()
  
  # for loop to go to each player's page
  pagecount <- length(morepages)
  for(x in 1:pagecount) {
    
    
    # click button to move to "next page"
    morepages[[x]]$clickElement()
    
    # new link
    link <- remDr$getCurrentUrl()[[1]]
    
    # if nextpage button actually moved to new page
    if (URL != link) {
      
      # collect data 
      df_temp <- rbind(df_temp, scrape(remDr))
      
      # move back to main page
      remDr$navigate(URL)
      # rescope morepages
      morepages <- remDr$findElements(using = 'css selector', '.d3-o-player-fullname')
      
    }  
  }
  
  
  # after collecting all data on page
  # store nextpage location, if no nextpage then NA
  nextpage <- website %>% html_node(target)
  
  
  
  # if the nextpage button exists
  if (!is.na(nextpage)) {
    
    # find button
    morepages <- remDr$findElement(using = 'css selector', target)
    # click button to move to "next page"
    morepages$clickElement()
    
    
    
    # collect new link
    link <- remDr$getCurrentUrl()[[1]]
    
    # if nextpage button actually moved to new page
    if (URL != link) {
      
      # collect data from next page with nested function
      df_temp <- rbind(df_temp, getPlayers(link, target, remDr))
      
    } 
    
  }
  
  return(df_temp)
  
  
  
}





# new page link, to collect experience level of entire 2022 roster
link <- "https://www.nfl.com/players/active/all"

website <- read_html(link)

# Extracting sub URLs
# this will get all Letter (A-Z) categories of players
subURLs <- html_nodes(website,'.d3-o-tabs__list-item') %>% 
  html_children() %>% 
  html_attr('href')


# Removing NA values and last `/browse` URL
subURLs <- subURLs[!is.na(subURLs)]


# Main URL - to complete the above URLs
mainURL <- "https://www.nfl.com"



df_2022exp <- data.frame()

# target for nextpage element
target <- ".nfl-o-table-pagination__next"


# scraping data from all subURLs
for (x in 2:length(subURLs[])) {
  df_2022exp <- rbind(df_2022exp, getPlayers(paste(mainURL, subURLs[x], sep = ""), target, remDr))
}




#navigate to site to collect penalty data
#remDr$navigate("https://www.nflpenalties.com/all-players.php?view=total&year=2020")

#collect site elements
html <- remDr$getPageSource()[[1]]
website <- read_html(html)


#Collect penalty data data
allTables <- html_nodes(website, css = "table")
dt <- html_table(allTables[[1]], fill = TRUE)

#create complete dataframe of player, team, position and base contract 
df_pen <- data_frame(dt)
names(df_pen)[1] <- c("Player")



# export data to cvs files


write.csv(df, "datasets/player_contract_2020.csv", row.names=FALSE)

write.csv(df_2022exp, "datasets/player_exp_2022.csv", row.names=FALSE)

write.csv(df_fg, "datasets/stats_fg_2020.csv", row.names=FALSE)

write.csv(df_fumb, "datasets/stats_fumb_2020.csv", row.names=FALSE)

write.csv(df_int, "datasets/stats_int_2020.csv", row.names=FALSE)

write.csv(df_ko, "datasets/stats_ko_2020.csv", row.names=FALSE)

write.csv(df_kor, "datasets/stats_kor_2020.csv", row.names=FALSE)

write.csv(df_pass, "datasets/stats_pass_2020.csv", row.names=FALSE)

write.csv(df_pr, "datasets/stats_pr_2020.csv", row.names=FALSE)

write.csv(df_punt, "datasets/stats_punt_2020.csv", row.names=FALSE)

write.csv(df_rec, "datasets/stats_rec_2020.csv", row.names=FALSE)

write.csv(df_rush, "datasets/stats_rush_2020.csv", row.names=FALSE)

write.csv(df_tack, "datasets/stats_tack_2020.csv", row.names=FALSE)

write.csv(df_pen, "datasets/stats_pen_2020.csv", row.names=FALSE)


