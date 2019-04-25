import pandas as pd
import matplotlib.pyplot as plt
df = pd.read_csv ("M:\PhD\Project\Experiment_Code\Straights\BenLui17_1_full.csv")
# df = pd.read_csv ("C:/Users/Courtney/Documents/PhD/Project/Experiment_code/Straights/BenLui17_1_full.csv")
print (df)
timestamp = df[['timestamp']]
print(timestamp)

df.plot(kind='scatter',x='timestamp',y='SWA',color='red')
plt.show()


