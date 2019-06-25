import pandas as pd # imports dataframes
import matplotlib.pyplot as plt #imports plotting capabilities
import glob

# path = r"C:/Users/Courtney/Documents/PhD/Project/Experiment_code/Straights/Full_Data"
path = r"C:/Users/pscmgo/OneDrive for Business/PhD/Project/Experiment_Code/Straights/Full_Data" # use your path
all_files = glob.glob(path + "/*.csv") # select path and file identifier 

li = [] # empty for csv files to be put

for filename in all_files:
    df = pd.read_csv(filename, index_col = None, header = 0) # read in the csv files
    li.append(df) #append the files 

workingdata = pd.concat(li, axis = 0, ignore_index = True) # concatenate all of the data 

workingdata['ppid_trialn'] = workingdata.ppid.astype(str).str.cat(workingdata.trialn.astype(str), sep ='_')
# unite ppid and trialn column

del workingdata['X.1'] # delete unnecessary columns

# changes StraightVisible from series to string type
workingdata.StraightVisible.apply(str)

# create boolean series of StraightVisible rows that are true
# use this as an index to generate only data where straight is visible
workingdatatimecourse = workingdata[workingdata["StraightVisible"] == True] 

# calculating yaw rate change 
workingdatatimecourse['YawRateChange'] = workingdatatimecourse.groupby(['ppid_trialn'])['YawRate_seconds'].diff(periods = 1).fillna(0)

# creating anchored timestamp

workingdatatimecourse['anchored_timestamp'] = workingdatatimecourse.groupby(['ppid_trialn'])['timestamp' - min(['timestamp'])]








### practice - selects timestamp column
# timestamp = workingdata[['timestamp']]
# print(timestamp)

### practicie - red scatter plot of timestamp versus steering wheel angle 
# workingdata.plot(kind='scatter',x='timestamp',y='SWA',color='red')
# plt.show()


