import pandas as pd # imports dataframes
import matplotlib.pyplot as plt #imports plotting capabilities
workingdata = pd.read_csv ("M:/PhD/Project/Experiment_Code/Straights/BenLui17_1_full.csv")
# workingdata = pd.read_csv("C:/Users/Courtney/Documents/PhD\Project/Experiment_code/Straights/BenLui17_1_full.csv") # home laptop data reading
print (workingdata)

workingdata['ppid_trialn'] = workingdata.ppid.astype(str).str.cat(workingdata.trialn.astype(str), sep ='_')

 # practice - selects timestamp column
timestamp = workingdata[['timestamp']]
print(timestamp)

# practicie - red scatter plot of timestamp versus steering wheel angle 
workingdata.plot(kind='scatter',x='timestamp',y='SWA',color='red')
plt.show()


