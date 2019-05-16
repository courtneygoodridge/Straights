import pandas as pd # imports dataframes
import matplotlib.pyplot as plt #imports plotting capabilities
import glob

path = r"M:/PhD/Project/Experiment_Code/Straights/Full_Data" # use your path
all_files = glob.glob(path + "/*.csv") # select path and file identifier 

li = [] # empty for csv files to be put

for filename in all_files:
    df = pd.read_csv(filename, index_col = None, header = 0) # read in the csv files
    li.append(df) #append the files 

workingdata = pd.concat(li, axis = 0, ignore_index = True) # concatenate all of the data 

workingdata['ppid_trialn'] = workingdata.ppid.astype(str).str.cat(workingdata.trialn.astype(str), sep ='_')
# unite ppid and trialn column

del workingdata['X.1'] # delete unnecessary columns











### practice - selects timestamp column
# timestamp = workingdata[['timestamp']]
# print(timestamp)

### practicie - red scatter plot of timestamp versus steering wheel angle 
# workingdata.plot(kind='scatter',x='timestamp',y='SWA',color='red')
# plt.show()


