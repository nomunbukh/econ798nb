#This is a revised script of homework 2
#Created by N. Bukh-Ochir on Septeber 28, 2021

rm(list=ls())

#PART 1
library(rvest) #rvest is used to scrape the New York Times website for the needed data.
library(tidyverse)

#List of the states the data will be pulled for states
states<-c("nevada","arizona","oregon","idaho","utah")
for(i in states){
  #Specifying the URL for desired website to be scraped
  url.1 <- "https://www.nytimes.com/elections/2016/results/"
  url<-paste0(url.1,i)
  webpage <- read_html(url)
  tables<-webpage %>%
    html_nodes("table") #This pulls out all the "table" nodes in the HTML code
  results2<-tables[2] %>%
    html_table(fill=TRUE,header=TRUE) %>%
    as.data.frame() %>%
    rename("County" = "Vote.by.county") %>%
    mutate("Clinton" = as.numeric(gsub(",","",Clinton)),
           "Trump" = as.numeric(gsub(",","",Trump)),
           "pctClinton" = (Clinton)/(Clinton+Trump),
           "pctTrump" = (Trump)/(Clinton+Trump),
           "state" = i)
  assign(i,results2)
}

VOTES <- rbind(nevada, arizona, oregon, idaho, utah)
save(VOTES, file = "C:/Users/nomun/OneDrive/Documents/Git test/econ691nb/econ691nb/Build/Output/VOTES.RData")

#PART 2
#Generate data from Census API
#Pre-defining variables to be used in loop
vars<-c("B01001_001","B01001_002","B02001_001","B02001_002", "B02001_003","B05001_001","B05001_006","B07001_001", "B07001_017","B07001_033","B07001_049","B07001_065","B07001_081" )
states<-c("nevada","arizona","oregon","idaho","utah")
fips<-c(32,04,41,16,49)
#API Command
#install.packages("sf")
library(sf)
library(tidycensus)
k<-1
for(i in fips){
  acs<-get_acs(geography="county",
               variables = vars,
               state = i,
               year = 2016,
               geometry = TRUE)
  temp<-acs %>%
    mutate(variable2 = case_when(variable=="B01001_001" ~ "TotPop",
                                 variable=="B01001_002" ~ "Male",
                                 variable=="B02001_001" ~ "TotRace",
                                 variable=="B02001_002" ~ "White",
                                 variable=="B02001_003" ~ "Black",
                                 variable=="B05001_001" ~ "TotCit",
                                 variable=="B05001_006" ~ "NonCit",
                                 variable=="B07001_001" ~ "TotMob",
                                 variable=="B07001_017" ~ "Stay",
                                 variable=="B07001_033" ~ "SameCounty",
                                 variable=="B07001_049" ~ "SameSt",
                                 variable=="B07001_065" ~ "OthState",
                                 variable=="B07001_081" ~ "Abroad",
                                 TRUE ~ "other")) %>%
    select(!c(moe,variable)) %>%
    spread(key=variable2, value=estimate) %>%
    mutate(perMale = Male/TotPop,
           perWhite = White/TotPop,
           perBlack = Black/TotPop,
           perCit = 1-(NonCit/TotCit),
           perStay = Stay/TotMob,
           perSameCounty = SameCounty/TotMob,
           perSameSt = SameSt/TotMob,
           perOthState = OthState/TotMob,
           perAbroad = Abroad/TotMob) %>%
    select("GEOID","NAME",starts_with("per"),"geometry") %>%
    mutate(state = states[k])
  assign(paste0(states[k],"census"),temp)
  temp$area<-st_area(temp)
  map <- temp %>%
    summarise(area = sum(area)) %>%
    mutate(state = states[k])
  assign(paste0(states[k],"map"),map)
  k<-k+1
  rm(temp, map)
}

arizonacensus$County<-trimws(gsub(" County, Arizona","",arizonacensus$NAME))
idahocensus$County<-trimws(gsub(" County, Idaho","",idahocensus$NAME))
nevadacensus$County<-trimws(gsub(" County, Nevada","",nevadacensus$NAME))
oregoncensus$County<-trimws(gsub(" County, Oregon","",oregoncensus$NAME))
utahcensus$County<-trimws(gsub(" County, Utah","",utahcensus$NAME))

CENSUS.1 <- rbind(arizonacensus,idahocensus,nevadacensus,oregoncensus,utahcensus)%>%
  select(!c(GEOID,NAME))

VOTES<-VOTES[order(VOTES$County),]
CENSUS.1<-CENSUS.1[order(CENSUS.1$County),]
VOTES$County==CENSUS.1$County
VOTES$County[23]
CENSUS.1$County[23]

VOTES$County[63]
CENSUS.1$County[63]

CENSUS.1$County[23]<-VOTES$County[23]
VOTES$County[63]<-CENSUS.1$County[63]

save(CENSUS.1, file = "C:/Users/nomun/OneDrive/Documents/Git test/econ691nb/econ691nb/Build/Output/CENSUS1.RData")


#Data from 2019

k<-1
for(i in fips){
  acs<-get_acs(geography="county",
               variables = vars,
               state = i,
               year = 2019,
               geometry = TRUE)
  temp<-acs %>%
    mutate(variable2 = case_when(variable=="B01001_001" ~ "TotPop",
                                 variable=="B01001_002" ~ "Male",
                                 variable=="B02001_001" ~ "TotRace",
                                 variable=="B02001_002" ~ "White",
                                 variable=="B02001_003" ~ "Black",
                                 variable=="B05001_001" ~ "TotCit",
                                 variable=="B05001_006" ~ "NonCit",
                                 variable=="B07001_001" ~ "TotMob",
                                 variable=="B07001_017" ~ "Stay",
                                 variable=="B07001_033" ~ "SameCounty",
                                 variable=="B07001_049" ~ "SameSt",
                                 variable=="B07001_065" ~ "OthState",
                                 variable=="B07001_081" ~ "Abroad",
                                 TRUE ~ "other")) %>%
    select(!c(moe,variable)) %>%
    spread(key=variable2, value=estimate) %>%
    mutate(perMale = Male/TotPop,
           perWhite = White/TotPop,
           perBlack = Black/TotPop,
           perCit = 1-(NonCit/TotCit),
           perStay = Stay/TotMob,
           perSameCounty = SameCounty/TotMob,
           perSameSt = SameSt/TotMob,
           perOthState = OthState/TotMob,
           perAbroad = Abroad/TotMob) %>%
    select("GEOID","NAME",starts_with("per"),"geometry") %>%
    mutate(state = states[k])
  assign(paste0(states[k],"census"),temp)
  temp$area<-st_area(temp)
  map <- temp %>%
    summarise(area = sum(area)) %>%
    mutate(state = states[k])
  assign(paste0(states[k],"map"),map)
  k<-k+1
  rm(temp, map)
}

arizonacensus$County<-trimws(gsub(" County, Arizona","",arizonacensus$NAME))
idahocensus$County<-trimws(gsub(" County, Idaho","",idahocensus$NAME))
nevadacensus$County<-trimws(gsub(" County, Nevada","",nevadacensus$NAME))
oregoncensus$County<-trimws(gsub(" County, Oregon","",oregoncensus$NAME))
utahcensus$County<-trimws(gsub(" County, Utah","",utahcensus$NAME))

CENSUS.2 <- rbind(arizonacensus,idahocensus,nevadacensus,oregoncensus,utahcensus)%>%
  select(!c(GEOID,NAME))

VOTES<-VOTES[order(VOTES$County),]
CENSUS.2<-CENSUS.2[order(CENSUS.2$County),]
VOTES$County==CENSUS.2$County
VOTES$County[23]
CENSUS.2$County[23]
VOTES$County[63]
CENSUS.2$County[63]

CENSUS.2$County[23]<-VOTES$County[23]
#VOTES$County[63]<-CENSUS.2$County[63]

save(CENSUS.2, file = "C:/Users/nomun/OneDrive/Documents/Git test/econ691nb/econ691nb/Build/Output/CENSUS2.RData")

gamma <- function(x,y){
  temp<-(x-y)/(y)
  return(temp)
}

CENSUS.3 <- CENSUS.1 %>%
  mutate(PC_perMale=gamma(CENSUS.1$perMale,CENSUS.2$perMale),
         PC_perWhite=gamma(CENSUS.1$perWhite,CENSUS.2$perWhite),
         PC_perBlack=gamma(CENSUS.1$perBlack,CENSUS.2$perBlack),
         PC_perCit=gamma(CENSUS.1$perCit,CENSUS.2$perCit),
         PC_perStay=gamma(CENSUS.1$perStay,CENSUS.2$perStay),
         PC_perSameCounty=gamma(CENSUS.1$perSameCounty,CENSUS.2$perSameCounty),
         PC_perSameSt=gamma(CENSUS.1$perSameSt,CENSUS.2$perSameSt),
         PC_perOthState=gamma(CENSUS.1$perOthState,CENSUS.2$perOthState),
         PC_perAbroad=gamma(CENSUS.1$perAbroad,CENSUS.2$perAbroad)) %>%
  select(starts_with("PC"),"County","state","geometry")
CENSUS.3_VOTES<-cbind(CENSUS.3,VOTES)


map1<-ggplot(CENSUS.3_VOTES)+
  geom_sf(aes(fill = pctClinton))+
  scale_fill_gradient(low="white",high="blue",limits=c(0,1),aes(name="Percent Clinton"))+
  theme(panel.grid.major=element_blank(),
        panel.grid.minor=element_blank(),
        panel.background=element_blank(),
        axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.line = element_blank(),
        axis.ticks = element_blank())
map2<-ggplot(CENSUS.3_VOTES)+
  geom_sf(aes(fill = PC_perWhite))+
  scale_fill_gradient(low="white",high="black",limits=c(0,1),aes(name="Percent Clinton"))+
  theme(panel.grid.major=element_blank(),
        panel.grid.minor=element_blank(),
        panel.background=element_blank(),
        axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.line = element_blank(),
        axis.ticks = element_blank())
library(cowplot)
plot_grid(map1,map2)
