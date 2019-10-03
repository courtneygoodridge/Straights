library("tidyverse")
library(magrittr) #for extra pipe functions
library(cowplot)
library("wesanderson")
library(brms)
library(tidybayes)
library(lme4)
library(lattice)

#theme for plots on TRANSITION grant.
theme_transition_report <- theme_classic() +
  theme(strip.background = element_rect(fill=NA,color=NA), 
        strip.text = element_text(face="bold",colour="black",size="12"), 
        axis.title = element_text(face="bold",colour="black",size="12"),
        axis.text.x = element_text(vjust=-.5),
        axis.text.y = element_text(vjust=.5),
        axis.text = element_text(face="plain",colour="black",size="10"),
        legend.text = element_text(face="plain",colour="black",size="10"),
        legend.title = element_text(face="bold",colour="black",size="12"),
        legend.key = element_blank()
        #panel.grid.major.y = element_line(color="grey85",size=.2, linetype = 2)
  )
#set working directory to folder that hosts the binary files.
#setwd("//ds.leeds.ac.uk/staff/staff8/pscwsh/Orca18_Analysis_pilotclone/Post-processing")
#setwd("C:/VENLAB data/SP_18-19/Data/Orca18")
setwd("C:/Users/wills/Google Drive/Placement")

#load steergaze data

loadsteergazedata <- function(){
  steergazedata <- readRDS("orca_steergazedata.rds")  
  
  steergazedata <- steergazedata %>% 
    mutate(bend = ifelse(trialtype_signed < 0, "left", "right"))
  
  steergazedata <- steergazedata %>% 
    rename(SWV = SWA) %>% 
    mutate(SWA = SWV * 90)
  
  #mirror data
  steergazedata <- steergazedata %>% 
    mutate(world_x_mirrored = if_else(bend == "left", World_x * -1, World_x),
           hangle_mirrored = if_else(bend == "left", hangle * -1, hangle),
           SWA_mirrored = if_else(bend == "left", SWA * -1, SWA),
           SWV_mirrored = if_else(bend == "left", SWV * -1, SWV),
           SB_mirrored = if_else(bend == "left", SteeringBias * -1, SteeringBias))
  
  
  #unsophisticated calculation of TTC using rate of change in steering bias
  calc_TTC <- function(SB_mirrored, SB_change){
    
    #need to incorporate the proximity to road edges and direction of travel.
    
    SB_mirrored <- array(SB_mirrored) #needs to be an array to use apply
    
    road_edges <- c(-1.5, 1.5)
    
    distance_to_edges <- apply(SB_mirrored, 1, function(x) road_edges - x)
    
    TTLCs <- apply(distance_to_edges,1, function(x) x / (SB_change * 60))
    
    TTLC <- apply(TTLCs, 1, max)
    
    return(TTLC)
    
  }
  
  #add ttlc
  steergazedata <- steergazedata %>% 
    mutate(SB_change = prepend(diff(SB_mirrored), NA),
           TTLC = calc_TTC(SB_mirrored, SB_change)
    )
  
  steergazedata$ppid <- as.factor(steergazedata$ppid)
  steergazedata$radius <- as.factor(steergazedata$radius)
  steergazedata$yawrate_offset <- as.factor(steergazedata$yawrate_offset)
  steergazedata$cogload <- as.factor(steergazedata$cogload)
  
  #create new column called failure type.
  steergazedata <- steergazedata %>% 
    mutate(failure_type = yawrate_offset)
  
  
  #refactor failure_type
  levels(steergazedata$failure_type)[1] = "Sudden"
  levels(steergazedata$failure_type)[2] = "Gradual"
  levels(steergazedata$failure_type)[3] = "Benign"
  levels(steergazedata$failure_type)[4] = "Benign"
  
  
  #add RT and disengage flag.
  disengage_RT <- function(onsettime, timestamp_trial, autoflag){
    
    #pick first frame where autoflag == false, then take the timestamp and minus the onset_time
    auto_false <- which(autoflag == "FALSE")
    disengage_index <- first(auto_false)
    disengage_trialtime <- timestamp_trial[disengage_index]
    onset_time <- first(onsettime)
    RT <- disengage_trialtime - onset_time #can be negative
    return(RT)
    
  }
  
  steergazedata <- steergazedata  %>% 
    group_by(ppid, radius, yawrate_offset, cogload, block, count) %>% 
    mutate(RT = disengage_RT(OnsetTime, timestamp_trial, AutoFlag),
           disengaged = ifelse(is.na(RT), 0, 1) #whether or not they actually took over.
    )
  
  
  steergazedata <- steergazedata %>% 
    mutate(trialid = paste(ppid, radius, yawrate_offset, cogload, block, count, sep = "_"))
  
  return(steergazedata)
}

steergazedata <- loadsteergazedata()

#head(steergazedata)

#save it as csv for jami.
#write_csv(steergazedata, "orca_raw_longformat.csv")

steergaze_trial <- steergazedata  %>% 
  group_by(ppid, radius, yawrate_offset, cogload, block, count, .drop = F) %>% 
  summarize(trialcode = first(trialcode))


steergaze_expanded_counts <- steergaze_trial %>% 
  ungroup() %>% 
  complete(ppid, radius, yawrate_offset, cogload, 
           fill = list(trialcode = 99)) %>% 
  group_by(radius, yawrate_offset, cogload, .drop = FALSE) %>% 
  tally()

expected_trialcount <- 30 * 6 #30 participants x 6 trials in each condition.

#change the yawrate_offsets to factors.
steergaze_expanded_counts <- steergaze_expanded_counts %>% 
  mutate(failure_type = case_when(yawrate_offset %in% c(-.2, .15) ~ "Benign",
                                  yawrate_offset == -9 ~ "Sudden",
                                  yawrate_offset == -1.5 ~ "Gradual"))

steergaze_expanded_counts$cogload <- factor(steergaze_expanded_counts$cogload, levels = c("None", "Easy", "Hard"))
steergaze_expanded_counts$failure_type <- factor(steergaze_expanded_counts$failure_type, levels = c("Sudden", "Gradual", "Benign"))


#plot counts.
ggplot(steergaze_expanded_counts, aes(y = n, x = factor(cogload), fill = factor(failure_type))) +
  facet_wrap(~radius) +
  theme_transition_report +
  geom_bar(stat="identity", position=position_dodge()) +
  scale_fill_manual(values = rev(wes_palette("BottleRocket2", n=3)), name = "Failure Type") +
  xlab("Cog Load") +
  ylab("Amount of Trials") +
  scale_y_continuous(sec.axis = sec_axis(~./180 * 100, name = "Proportion of Expected Data [%]"))


### Cognitive Load difficulty.

if ((!file.exists("end_of_trial_cogtask.csv")) | (!file.exists("within_trial_cogtask.csv"))){
  
  
  file_path <- "C:/VENLAB data/SP_18-19/Data/Orca18" #filepath (~ means to look in user's working directory)
  file_lists <- list(list.files(file_path, pattern = "Orca18_Distractor_1_(p|P)"),
                     list.files(file_path, pattern = "Orca18_Distractor_2_(p|P)")) #separate into two blocks so I can loop through.
  EoT <- "EndofTrial" #text at end of EndofTrial files. These are the recorded counts at the end of the trial.
  WiT <- "WithinTrial" #text at end of WithinTrial files. These are the RT responses within a trial. 
  
  block = 0
  
  #assign dataframes
  
  EoT_dataframe <- data.frame(X=integer(),
                              ppid=character(), 
                              targetoccurence=double(), 
                              targetnumber=integer(),
                              trialn = integer(),
                              EoTScore1 = double(),
                              TargetCount1 = double(),
                              EoTScore2 = double(),
                              TargetCount2 = double(),
                              EoTScore3 = double(),
                              TargetCount3 = double(),
                              block = integer())
  
  WiT_dataframe <- data.frame(X=integer(),
                              ppid=character(), 
                              targetoccurence=double(), 
                              targetnumber=integer(),
                              trialn = integer(),
                              CurrentAudio = character(),
                              RT = double(),
                              ResponseCategory = integer(),
                              Target1 = character(),
                              Target2 = character(),
                              Target3 = character(),
                              block = integer())
  
  
  
  for (file_block in file_lists){ #loop through  each block so you can add a block number and add 6 to trial number.
    
    #we want to add 6 to the second block trialn.
    block = block + 1
    if (block == 1){
      trial_add = 0
    } else {
      trial_add = 6
    }
    
    for (file_name in file_block){
      
      #print(file_name)
      
      #separate dataframe if EoT or WiT
      
      if (grepl(EoT, file_name)){
        
        EoT_newdata <- read.csv(paste(file_path,'/',file_name, sep = "")) #if already exists add to data frame.
        
        #head(EoT_newdata)
        
        EoT_newdata <- EoT_newdata %>% 
          mutate(trialn = trialn + trial_add,
                 block = block)
        
        EoT_dataframe <- dplyr::union(EoT_newdata, EoT_dataframe) #add to existing datframe  
        
        
      } else if  (grepl(WiT, file_name)) {
        WiT_newdata <- read.csv(paste(file_path,'/',file_name, sep = "")) #load WithinTrial data
        
        WiT_newdata <- WiT_newdata %>% 
          mutate(trialn = trialn + trial_add,
                 block = block)
        
        WiT_dataframe <- dplyr::union(WiT_newdata, WiT_dataframe) #add to existing datframe  
        
      }
    }
  }
  
  write_csv(EoT_dataframe,"end_of_trial_cogtask.csv")
  write_csv(WiT_dataframe,"within_trial_cogtask.csv")
  
} else {
  EoT_dataframe <- read_csv("end_of_trial_cogtask.csv")
  WiT_dataframe <- read_csv("within_trial_cogtask.csv")
}

##### WITHIN TRIAL MEASURES ########


WiT_RTfiltered <- filter(WiT_dataframe, RT == -1 | RT >.1) # Returns dataframe for rows where RT was >.1 or -1 (no response) 

WiT_TruePos <- filter(WiT_RTfiltered, ResponseCategory == 1) #create new dataframe only including true positives

SummaryRTs <- WiT_TruePos %>% group_by(ppid, trialn) %>% summarise(
  targetnumber = first(targetnumber),
  targetoccurence = first(targetoccurence),
  meanRT = mean(RT),
  stdRT = sd(RT))

#Calculate the amount of each type of responses
SummaryCounts <- WiT_RTfiltered %>% group_by(ppid, trialn) %>% summarise(
  targetnumber = first(targetnumber),
  targetoccurence = first(targetoccurence),
  TruePos = sum(ResponseCategory==1),
  FalseNeg = sum(ResponseCategory==2), 
  FalsePos = sum(ResponseCategory==3),
  TrueNeg = sum(ResponseCategory==4), 
  TotalResponses=n())

SummaryCounts <- mutate(SummaryCounts, Perc_Correct = (TruePos + TrueNeg)/ TotalResponses)


####### END OF TRIAL MEASURES ########

#First, replace NA with Zeros for the following code to work. This means I can use the same code on all trials, even though some may have different amounts of targets.
EoT_dataframe[is.na(EoT_dataframe)] <- 0

#Calculate the error for each target.
EoT_dataframe <- mutate(EoT_dataframe, 
                        Error1 = EoTScore1 - TargetCount1,
                        Error2 = EoTScore2 - TargetCount2,
                        Error3 = EoTScore3 - TargetCount3)

#Calculate the total absolute error and divide by targetnumber
EoT_dataframe <- EoT_dataframe %>% 
  mutate(totalcounterror = abs(Error1) + abs(Error2) + abs(Error3),
         totaltargets = abs(TargetCount1) + abs(TargetCount2) + abs(TargetCount3),
         avgcounterror = totalcounterror / targetnumber,
         proportionalcounterror = totalcounterror / totaltargets
  )


########### MERGE DATAFRAMES ############

#merges dataframes for trial measures
SummaryTrialMeasures <- merge(SummaryCounts, SummaryRTs, by = c("ppid","trialn"), all.x = TRUE)

#only select the columns we are interested in 
EoT_avgerror <- select(EoT_dataframe, ppid, trialn, targetnumber, targetoccurence, totalcounterror, totaltargets, avgcounterror, proportionalcounterror)

#merge within trial and EoT measures together
SummaryMeasures <- merge(SummaryTrialMeasures, EoT_avgerror, by = c("ppid","trialn"))

#drop some extra columns created by merging for some unimportant reasons
SummaryMeasures <- select(SummaryMeasures, -targetoccurence.x, -targetnumber.x, -targetoccurence.y, -targetnumber.y)

## merge summary measures and steergaze data

########### MERGE DATAFRAMES ############

SummaryMeasures <- SummaryMeasures %>%
  mutate(cogload = case_when(targetnumber == 1 ~ "Easy", 
                             targetnumber == 3 ~ "Hard"))

#merges dataframes for trial measures
TaskSteerDF <- merge(steergazedata, SummaryMeasures, by = c("ppid", "trialn", "cogload"), all.x = TRUE)

TaskSteerDF <- select(TaskSteerDF, ppid, trialn, radius, yawrate_offset, timestamp_exp, timestamp_trial, trialtype_signed,
                      World_x, World_z, WorldYaw, SWV, YawRate_seconds, TurnAngle_frames, Distance_frames, dt,
                      WheelCorrection, SteeringBias, Closestpt, AutoFlag, AutoFile, OnsetTime, count,
                      cogload, radii, block, bend, SWA, world_x_mirrored, SWA_mirrored, SWV_mirrored, SB_mirrored,
                      SB_change, TTLC, failure_type, RT, disengaged, trialid, TruePos, FalseNeg, FalsePos, TrueNeg, 
                      TotalResponses, Perc_Correct, meanRT, stdRT, targetnumber, targetoccurence, totalcounterror,
                      totaltargets, avgcounterror, proportionalcounterror)

#head(SummaryMeasures)

# box plots for absolute count error.

#so I do not repeat myself below
addscale <- scale_fill_manual(values = wes_palette("Cavalcanti1"), name = "Cognitive Load", labels = c("1"="Easy", "3"="Hard"))
changexlabels <- scale_x_discrete(name = "Cognitive Load", labels=c("1" = "Easy", "3" = "Hard"))

#Example 2: plot ACE for each targetnumber
p_rt <- ggplot(data=SummaryMeasures, aes(y=meanRT, x=factor(targetnumber), fill = factor(targetnumber))) + 
  geom_boxplot(outlier.size = 1) +
  addscale +
  theme_transition_report +
  changexlabels + ylab ("Mean RT for True Positives (s)")

#show(p_rt)

p_pc <- ggplot(data=SummaryMeasures, aes(y=Perc_Correct, x=factor(targetnumber), fill = factor(targetnumber))) + 
  geom_boxplot(outlier.size = 1) +
  addscale +
  theme_transition_report +
  changexlabels + ylab ("Percentage of Targets Responded Correctly (%)")

p_ace <- ggplot(data=SummaryMeasures, aes(y=proportionalcounterror, x=factor(targetnumber), fill = factor(targetnumber))) + 
  geom_boxplot(outlier.size = 1) +
  addscale +
  theme_transition_report +
  changexlabels + ylab ("Average proportional error in estimated count")

legend <- get_legend(p_rt)
p <- plot_grid(p_rt + theme(legend.position="none"), 
               p_pc + theme(legend.position="none"), 
               p_ace + theme(legend.position="none"),
               labels = c("A", "B","C"), nrow=1)
p_legend <- plot_grid(p, legend, rel_widths = c(4,.5))
show(p_legend)


### need to calculate RTs.
if (!exists("steergazedata")){
  #load steergaze data
  steergazedata <- loadsteergazedata()
  
}

#RT and disengaged are already calculated.
steergaze_trialavgs <- steergazedata  %>% 
  ungroup() %>% 
  group_by(ppid, radius, yawrate_offset, cogload, block, count) %>% 
  summarize(RT = first(RT),
            disengaged = first(disengaged), #whether or not they actually took over.
            failure_type = first(failure_type),
            premature = ifelse(RT <= 0, 1, 0))

#head(steergaze_trialavgs)

#disengage %
disengage_perc <- steergaze_trialavgs %>% 
  ungroup() %>% 
  filter(failure_type == "Benign") %>% 
  summarise(pc = sum(disengaged) / n()) 

#negative RT %
premature_perc <- steergaze_trialavgs %>% 
  ungroup() %>% 
  summarise(pc = sum(na.omit(premature)) / n()) 

#first plot is the RTs across different failure types. Boxplots or density estimates are good option.

ggplot(steergaze_trialavgs, aes(x = RT, group = factor(failure_type), fill = factor(failure_type))) +
  geom_density(alpha = .8) +
  xlim(c(0,10)) +
  scale_fill_manual(values = rev(wes_palette("BottleRocket2",n=3)), name = "Failure Type") +
  theme_transition_report +
  xlab(expression("RT"["takeover"]*" (s)"))

#first plot is the RTs across different failure types. Boxplots or density estimates are good option.

p_sudden <- ggplot(filter(steergaze_trialavgs, failure_type == "Sudden"), 
                   aes(x = RT, group = factor(cogload), col = factor(cogload), fill = factor(cogload))) +
  geom_histogram(alpha = .2, position = "identity", bins = 40, aes(y= ..density..), col =NA) +
  geom_density(size = 1.2, fill = NA) +
  xlim(c(0,NA)) +
  #facet_grid(radius~.) +
  scale_fill_manual(values = wes_palette("Cavalcanti1"), name = "Cognitive Load") +
  scale_colour_manual(values = wes_palette("Cavalcanti1"), name = "Cognitive Load") +
  theme_transition_report +
  xlab(expression("RT"["takeover"]*" (s)")) 


p_gradual <- ggplot(filter(steergaze_trialavgs, failure_type == "Gradual"), 
                    aes(x = RT, group = factor(cogload), col = factor(cogload), fill = factor(cogload))) +
  geom_histogram(alpha = .2, position = "identity", bins = 40, aes(y= ..density..), col =NA) +
  geom_density(size = 1.2, fill = NA) +
  xlim(c(0,NA)) +
  #facet_grid(radius~.) +
  scale_fill_manual(values = wes_palette("Cavalcanti1"), name = "Cognitive Load") +
  scale_colour_manual(values = wes_palette("Cavalcanti1"), name = "Cognitive Load") +
  theme_transition_report +
  xlab(expression("RT"["takeover"]*" (s)")) 

p_benign <- ggplot(filter(steergaze_trialavgs, failure_type == "Benign"), 
                   aes(x = RT, group = factor(cogload), col = factor(cogload), fill = factor(cogload))) +
  geom_histogram(alpha = .2, position = "identity", bins = 40, aes(y= ..density..), col =NA) +
  geom_density(size = 1.2, fill = NA) +
  xlim(c(0,NA)) +
  #facet_grid(radius~.) +
  scale_fill_manual(values = wes_palette("Cavalcanti1"), name = "Cognitive Load") +
  scale_colour_manual(values = wes_palette("Cavalcanti1"), name = "Cognitive Load") +
  theme_transition_report +
  xlab(expression("RT"["takeover"]*" (s)")) 

legend <- get_legend(p_sudden)
p_rt_takeover <- plot_grid(p_sudden + theme(legend.position="none"), 
                           p_gradual + theme(legend.position="none"), 
                           p_benign + theme(legend.position="none"),
                           labels = c("Sudden", "Gradual","Benign"), nrow=1, hjust = -1)
p_rt_takeover_legend <- plot_grid(p_rt_takeover, legend, rel_widths = c(4,.5))
show(p_rt_takeover_legend)

p_sudden <- p_sudden +
  labs(title = "Sudden")

p_gradual <- p_gradual +
  labs(title = "Gradual")

p_benign <- p_benign +
  labs(title = "Benign")

show(p_sudden)
show(p_gradual)
show(p_benign)

#calculate modes for reporting in text.
getmode <- function(v, binwidth = NULL) {
  
  #v is a vector. binwidth is the granularity.
  v <- na.omit(v)
  if (!is.null(binwidth)){
    v <- ceiling(v / binwidth) * binwidth  
  }
  uniqv <- unique(v)
  uniqv[which.max(tabulate(match(v, uniqv)))]
  
}


mode_sudden_none <- getmode(filter(steergaze_trialavgs, failure_type == "Sudden",cogload == "None")$RT, binwidth = .01)
mode_sudden_easy <- getmode(filter(steergaze_trialavgs, failure_type == "Sudden",cogload == "Easy")$RT, binwidth = .01)
mode_sudden_hard <- getmode(filter(steergaze_trialavgs, failure_type == "Sudden",cogload == "Hard")$RT, binwidth = .01)

sd_sudden_none <- sd(na.omit(filter(steergaze_trialavgs, failure_type == "Sudden",cogload == "None", RT > 0)$RT)) 
sd_sudden_easy <- sd(na.omit(filter(steergaze_trialavgs, failure_type == "Sudden",cogload == "Easy", RT > 0)$RT)) 
sd_sudden_hard <- sd(na.omit(filter(steergaze_trialavgs, failure_type == "Sudden",cogload == "Hard", RT > 0)$RT)) 

median_gradual_none <- median(na.omit(filter(steergaze_trialavgs, failure_type == "Gradual",cogload == "None", RT > 0)$RT)) 
median_gradual_easy <- median(na.omit(filter(steergaze_trialavgs, failure_type == "Gradual",cogload == "Easy", RT > 0)$RT)) 
median_gradual_hard <- median(na.omit(filter(steergaze_trialavgs, failure_type == "Gradual",cogload == "Hard", RT > 0)$RT))

#B) Plots of sudden take-overs with take-over state dotted.
#C) Plots of gradual take-overs with take-over state dotted.
#D) Plots of no failure take-overs with take-over state dotted.


#load track data
track_80 <- read.csv("track_with_edges_orca_80.csv")
track_40 <- read.csv("track_with_edges_orca_40.csv")

#calculate states at takeover
takeover_state <- steergazedata %>%
  ungroup() %>% 
  filter(AutoFlag == F) %>% 
  group_by(trialid) %>% 
  summarise(x = first(world_x_mirrored),
            z = first(World_z),
            rads = first(radii),
            sb = first(SteeringBias),
            sb_mirrored = first(SB_mirrored),
            sb_change = SB_mirrored[1] - SB_mirrored[2],
            ttlc = (1.5 - abs(sb_mirrored)) / (abs(sb_change)*60),
            cogload = first(cogload),
            failure_type = first(failure_type),
            onset = first(OnsetTime),
            time = first(timestamp_trial),
            RT = time - onset,
            bend = first(bend),
            ppid = first(ppid),
            autofile = first(AutoFile))


#selection <- select_autofile_onset(steergazedata)

#actually let's use the most common file.
selection <- c(getmode(steergazedata$AutoFile), getmode(steergazedata$OnsetTime))


takeover_selection <- takeover_state %>% 
  filter(onset == selection[2],
         rads == 40)

fulltrials_selection <- steergazedata %>% 
  filter(OnsetTime == selection[2],
         radius == 40)


onset_point <- steergazedata %>%
  ungroup() %>% 
  filter(OnsetTime == selection[2],
         radius == 40) %>% 
  group_by(AutoFile) %>% 
  filter(timestamp_trial > OnsetTime) %>% 
  summarise(x = first(world_x_mirrored),
            z = first(World_z))

#plot 
traj_selection <- ggplot(data = fulltrials_selection, aes(x = world_x_mirrored, y= World_z, col = failure_type)) +
  geom_path(aes(group = trialid), alpha = 1) +
  scale_colour_manual(values = rev(wes_palette("BottleRocket2",n=3)), name = "Failure Type") +
  geom_path(data = track_40, aes(x = midlinex, y=midlinez), colour = "grey", linetype = "dashed") +
  geom_path(data = track_40, aes(x = outsidex, y=outsidez), colour = "grey") +
  geom_path(data = track_40, aes(x = insidex, y=insidez), colour = "grey") +
  xlim(c(min(track_40$outsidex), max(fulltrials_selection$world_x_mirrored))) + ylim(c(0,60)) +
  geom_point(data = filter(takeover_selection), aes(x=x, y=z, fill = failure_type), col = "black", alpha = 1, pch=21) +
  scale_fill_manual(values = rev(wes_palette("BottleRocket2",n=3)), name = "Failure Type") +
  guides(fill = F) +
  geom_point(data = onset_point, aes(x=x, y=z), pch = 8, col = "blue") +
  facet_wrap(failure_type~.) +
  ylab("World Z") + xlab("World X") +
  theme_transition_report

show(traj_selection)


## plot example trajectories for each cog load - Sudden failure type
sudden_trial_selection <- fulltrials_selection %>%
  filter(failure_type == "Sudden")

cog_selection <- ggplot(data = sudden_trial_selection, aes(x = world_x_mirrored, y= World_z, col = factor(cogload))) +
  geom_path(aes(group = trialid), alpha = 1) +
  scale_colour_manual(values = (wes_palette("Cavalcanti1",n=3)), name = "Cognitive Load") +
  geom_path(data = track_40, aes(x = midlinex, y=midlinez), colour = "grey", linetype = "dashed") +
  geom_path(data = track_40, aes(x = outsidex, y=outsidez), colour = "grey") +
  geom_path(data = track_40, aes(x = insidex, y=insidez), colour = "grey") +
  xlim(c(min(track_40$outsidex), max(sudden_trial_selection$world_x_mirrored))) + ylim(c(0,60)) +
  geom_point(data = filter(takeover_selection), aes(x=x, y=z, fill = cogload), col = "black", alpha = 1, pch=21) +
  scale_fill_manual(values = wes_palette("Cavalcanti1",n=3), name = "Cognitive Load") +
  guides(fill = F) +
  geom_point(data = onset_point, aes(x=x, y=z), pch = 8, col = "blue") +
  facet_wrap(cogload~.) +
  theme_transition_report + xlab("World_x")

show(cog_selection) ##### For poster!!!! #####


#A) Steering bias for Different failures, 
#B) Cognitive load within failures, 
#C) Radii within failures,

#only select the trials with manual control in them.
steergaze_manual <- steergazedata %>% 
  filter(AutoFlag == FALSE)

### Reset trial so they all start at around [0,0] 
steergaze_manual <- steergaze_manual %>% 
  ungroup() %>% 
  group_by(trialid) %>%
  mutate(timestamp_zero = timestamp_trial - timestamp_trial[1],
         f = seq(1:n()))


####### Below here #######
#plot steering bias, exclude the oversteering SAB
p_sb <- ggplot(data = filter(steergaze_manual, f < 500, yawrate_offset != .15), aes(x = f / 60, y= SB_mirrored, col = factor(failure_type))) +
  geom_path(aes(group = trialid), alpha = .1) +
  geom_smooth(se= F, size = 1.5, method = "loess", span = .1) +
  scale_colour_manual(values = rev(wes_palette("BottleRocket2",n=3)), name = "Failure Type") +
  geom_hline(yintercept = c(-1.5, 1.5), col = "grey", size = 1.5, linetype = "dashed") +
  ylim(c(-2,1.6)) +
  geom_hline(yintercept = 0, col = "black", linetype = "dashed") +
  ylab("Lane Position (m)") + xlab("Time (s)") +
  theme_transition_report


show(p_sb)


## plot SB graphs for sudden and gradual - together and apart
###### image quality coming up very poor!!!! Try again at work #####
p_sb_cogload <- ggplot(data = filter(steergaze_manual, f < 300, yawrate_offset != .15, failure_type != "Benign"), aes(x = f / 60, y= SB_mirrored, col = factor(cogload))) +
  geom_path(aes(group = trialid), alpha = .05) +
  geom_smooth(se= F, size = 1.5, method = "loess", span = .1) +
  facet_wrap(~failure_type) +
  scale_colour_manual(values = wes_palette("Cavalcanti1",n=3), name = "Cognitive Load") +
  geom_hline(yintercept = c(-1.5, 1.5), col = "grey", size = 1.5, linetype = "dashed") +
  ylim(c(-2,1.6)) +
  geom_hline(yintercept = 0, col = "black", linetype = "dashed") +
  ylab("Lane Position (m)") + xlab("Time (s)") +
  theme_transition_report


show(p_sb_cogload)

p_sb_cogload_gradual <- ggplot(data = filter(steergaze_manual, f < 300, yawrate_offset != .15, failure_type == "Gradual"), aes(x = f / 60, y= SB_mirrored, col = factor(cogload))) +
  geom_path(aes(group = trialid), alpha = .05) +
  geom_smooth(se= F, size = 1.5, method = "loess", span = .1) +
  scale_colour_manual(values = wes_palette("Cavalcanti1",n=3), name = "Cognitive Load") +
  geom_hline(yintercept = c(-1.5, 1.5), col = "grey", size = 1.5, linetype = "dashed") +
  ylim(c(-2,1.6)) +
  geom_hline(yintercept = 0, col = "black", linetype = "dashed") +
  ylab("Lane Position (m)") + xlab("Time (s)") +
  labs(title = "Gradual") +
  theme_transition_report


show(p_sb_cogload_gradual)

p_sb_cogload_sudden <- ggplot(data = filter(steergaze_manual, f < 300, yawrate_offset != .15, failure_type == "Sudden"), aes(x = f / 60, y= SB_mirrored, col = factor(cogload))) +
  geom_path(aes(group = trialid), alpha = .05) +
  geom_smooth(se= F, size = 1.5, method = "loess", span = .1) +
  scale_colour_manual(values = wes_palette("Cavalcanti1",n=3), name = "Cognitive Load") +
  geom_hline(yintercept = c(-1.5, 1.5), col = "grey", size = 1.5, linetype = "dashed") +
  ylim(c(-2,1.6)) +
  geom_hline(yintercept = 0, col = "black", linetype = "dashed") +
  ylab("Lane Position (m)") + xlab("Time (s)") +
  labs(title = "Sudden") +
  theme_transition_report


show(p_sb_cogload_sudden)

p_sb_radii <- ggplot(data = filter(steergaze_manual, f < 300, yawrate_offset != .15, failure_type == "Sudden"), aes(x = f, y= SB_mirrored, col = factor(radii))) +
  geom_path(aes(group = trialid), alpha = .1) +
  geom_smooth(se= F, size = 1.5) +
  facet_wrap(~failure_type) +
  scale_colour_manual(values = wes_palette("Darjeeling1",n=2), name = "Bend Radius") +
  geom_hline(yintercept = c(-1.5, 1.5), col = "grey", size = 1.5, linetype = "dashed") +
  ylim(c(-2,1.6)) +
  geom_hline(yintercept = 0, col = "black", linetype = "dashed") +
  theme_transition_report


show(p_sb_radii)

## plot SWA graphs for sudden
#pick up .5 s before trial takeover so you can see how quickly SWA moves after takeover.

delay = 1
steergaze_manual_delay <- steergazedata %>% 
  ungroup() %>% 
  group_by(trialid) %>% 
  filter(timestamp_trial > (RT + OnsetTime - delay))

### Reset trial so they all start at around [0,0] 
steergaze_manual_delay <- steergaze_manual_delay %>% 
  ungroup() %>% 
  group_by(trialid) %>%
  mutate(timestamp_zero = timestamp_trial - timestamp_trial[1],
         f = seq(1:n()))


#plot SWA by time
p_swa_cogload <- ggplot(data = filter(steergaze_manual_delay, f < 360, yawrate_offset != .15), aes(x = timestamp_zero - delay, y= SWA_mirrored, col = factor(cogload))) +
  geom_path(aes(group = trialid), alpha = .1) +
  geom_smooth(se=F, size = 1.5, method="loess", span = .1) +
  facet_wrap(radius~failure_type) +
  scale_colour_manual(values = wes_palette("Cavalcanti1",n=3), name = "Cognitive Load") +
  theme_transition_report +
  ylim(c(0,90)) +
  xlab("Time (s)") + ylab("Steering Wheel Angle (degrees)") +
  geom_vline(xintercept = 0, col = "black", linetype = "dashed")

show(p_swa_cogload)

p_swa_cogload_sudden <- ggplot(data = filter(steergaze_manual_delay, f < 360, yawrate_offset != .15, failure_type =="Sudden"), aes(x = timestamp_zero - delay, y= SWA_mirrored, col = factor(cogload))) +
  geom_path(aes(group = trialid), alpha = .1) +
  geom_smooth(se=F, size = 1.5, method="loess", span = .1) +
  facet_wrap(radius~failure_type) +
  scale_colour_manual(values = wes_palette("Cavalcanti1",n=3), name = "Cognitive Load") +
  theme_transition_report +
  ylim(c(0,90)) +
  xlab("Time (s)") + ylab("Steering Wheel Angle (degrees)") +
  geom_vline(xintercept = 0, col = "black", linetype = "dashed")

show(p_swa_cogload_sudden)

p_swa_cogload_sudden_40 <- ggplot(data = filter(steergaze_manual_delay, f < 360, yawrate_offset != .15, failure_type =="Sudden", radius == 40), aes(x = timestamp_zero - delay, y= SWA_mirrored, col = factor(cogload))) +
  geom_path(aes(group = trialid), alpha = .1) +
  geom_smooth(se=F, size = 1.5, method="loess", span = .1) +
  facet_wrap(radius~failure_type) +
  scale_colour_manual(values = wes_palette("Cavalcanti1",n=3), name = "Cognitive Load") +
  theme_transition_report +
  ylim(c(0,90)) +
  xlab("Time (s)") + ylab("Steering Wheel Angle (degrees)") +
  geom_vline(xintercept = 0, col = "black", linetype = "dashed")

show(p_swa_cogload_sudden_40)

p_swa_cogload_sudden_80 <- ggplot(data = filter(steergaze_manual_delay, f < 360, yawrate_offset != .15, failure_type =="Sudden", radius == 80), aes(x = timestamp_zero - delay, y= SWA_mirrored, col = factor(cogload))) +
  geom_path(aes(group = trialid), alpha = .1) +
  geom_smooth(se=F, size = 1.5, method="loess", span = .1) +
  facet_wrap(radius~failure_type) +
  scale_colour_manual(values = wes_palette("Cavalcanti1",n=3), name = "Cognitive Load") +
  theme_transition_report +
  ylim(c(0,90)) +
  xlab("Time (s)") + ylab("Steering Wheel Angle (degrees)") +
  geom_vline(xintercept = 0, col = "black", linetype = "dashed")

show(p_swa_cogload_sudden_80)


