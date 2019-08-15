# Import the needed libraries
import numpy as np
import matplotlib.pyplot as plt

# Set up timestamps
dur = 100 # how long simulation occurs for
dt = 0.01 # time step increments
ts = np.arange(0, dur, dt) # the overall timestamp

# Specify velocity
v = 10

def predict_reaction_time(heading, threshold): # prediction function takes heading and threshold value arguments 
    """
    Predicts the reaction times. This could be done a lot
    faster, but this is relatively straightforward.
    """

    # Convert heading to radians to work with trigonometry
    heading = np.radians(heading)

    # Constant speed means distance is speed multiplied by time
    dist = v*ts 

    # Get our x position over time
    x = np.sin(heading)*dist 

    #y = np.cos(heading)*dist # We don't need this

    # Find the first instance where the threshold is crossed and return its time 
    rt = ts[np.abs(x) > threshold][0] # rt equals the timestamp where x is larger than the threshold
    return rt

# Specify your demo headings here. Zero will break as it will never cross. Anything not crossing within specified duration fails
headings = [0.5, 1, 1.5, 2]

# Specify some demo thresholds
thresholds = [0.5, 1.0, 1.5]

# Go over the thresholds
for threshold in thresholds:

    # Use our function to predict reaction times for different headings
    rts = [predict_reaction_time(h, threshold) for h in headings]
    
    # Plot the predicted reaction time as a function of "X-slowness"
    plt.plot(1/(np.sin(np.radians(headings))*v), rts, label=f"Threshold {threshold}")

# Some labelings and show the plot
plt.xlabel("X-slowness (s/m)")
plt.ylabel("Reaction time (seconds)")
plt.legend()
plt.show()
