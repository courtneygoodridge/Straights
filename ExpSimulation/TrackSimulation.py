import sys

rootpath = "C:/Users/Courtney/Documents/PhD/Project/Experiment_code/Straights/ExpSimulation"
sys.path.append(rootpath)

import numpy as np
import matplotlib.pyplot as plt
import pdb
import pandas as pd
import math as mt

import simTrackMaker

class vehicle:
    
    def __init__(self, initialyaw, speed, dt, Course):

        
        self.pos = [0, 0]
        self.yaw = initialyaw #heading offset angle, radians
        self.speed = speed 
        self.dt = dt       
        self.midline = Course
    
        
        self.yawrate = 0
        
        self.pos_history = []
        self.yaw_history = []
        self.yawrate_history = []                
        self.steering_bias_history = []   
        self.closestpt_history = []         
        self.vis_angle_corrected_history = []
        self.vis_angle_history = []

        self.Course = Course      
        
        self.closest_pt, self.current_steering_bias, self.current_vis_angle_corrected, self.current_vis_angle  = self.calculate_errors() 


        #calculate road angle with correction.      

        #calculate road angle without correction.      

        #self.save_history()     
        

    def calculate_errors(self, ego_dist = 10, camera_rotation = 0):

        #calculates lane error (steering bias), road angle, and road angle with camera rotation.
        
        #for straights, steering bias is just x.
        steering_bias = self.pos[0]

        #for road angle we find the point in the road at ego_dist ahead (10 m is default)

        midlinedist = np.sqrt(
            ((self.pos[0]-self.midline[:,0])**2)
            +((self.pos[1]+ego_dist-self.midline[:,1])**2)
            ) #get a 4000 array of distances from the midline
        idx = np.argmin(abs(midlinedist)) #find smallest difference. This is the closest index on the midline.	

        chosen_pt = self.midline[idx,:] #xy of chosen point

        #when is camera_aligned with z axis, the angle is tan(opp/adj) = tan(x/z)
        x_dist = abs(self.pos[0] - chosen_pt[0])
        z_dist = abs(self.pos[1] - chosen_pt[1])
        vis_angle_corrected = mt.tan(x_dist / z_dist) #distance from closest point				

        #when camera rotation is veridical to yaw you add the yaw angle.

        vis_angle = vis_angle_corrected + camera_rotation


        return chosen_pt, steering_bias, vis_angle_corrected, vis_angle


    def move_vehicle(self, newyawrate = 0):           
        """update the position of the vehicle over timestep dt"""                        
                                 
        self.yawrate = newyawrate

        # self.yawrate = np.deg2rad(0.5) # np.random.normal(0, 0.001)

        maxheadingval = np.deg2rad(35.0) #in rads per second
        
        self.yawrate = np.clip(self.yawrate, -maxheadingval, maxheadingval)
        # print(self.yawrate)
        # self.yawrate = 0.0

        self.yaw = self.yaw + self.yawrate * self.dt  #+ np.random.normal(0, 0.005)
        
        #zrnew = znew*cos(omegaH) + xnew*sin(omegaH);
        #xrnew = xnew*cos(omegaH) - znew*sin(omegaH)

        x_change = self.speed * self.dt * np.sin(self.yaw)
        y_change = self.speed * self.dt * np.cos(self.yaw)
        
        self.pos = self.pos + np.array([x_change, y_change]) 

        self.closest_pt, self.current_steering_bias, self.current_vis_angle_corrected, self.current_vis_angle = self.calculate_errors(camera_rotation=self.yaw)
        
        self.save_history()
    
    def save_history(self):

        self.pos_history.append(self.pos)        
        self.yaw_history.append(self.yaw)
        self.yawrate_history.append(self.yawrate)
        self.steering_bias_history.append(self.current_steering_bias)
        self.closestpt_history.append(self.closest_pt)
        self.vis_angle_corrected_history.append(self.current_vis_angle_corrected)
        self.vis_angle_history.append(self.current_vis_angle)   

def runSimulation(Course, headingoffset= 0, onsettime = 0):

    """run simulation and return RMS"""

    #Sim params
    fps = 60.0
    speed = 8.0
 
   # print ("speed; ", speed)

    dt = 1.0 / fps
    run_time = 2 #seconds
    time = 0

    Car = vehicle(headingoffset, speed, dt, Course)

    i = 0

    while (time < run_time):

        time += dt              
        
        Car.move_vehicle()           

        i += 1

    return Car
    
if __name__ == '__main__':
    

    #create straight that is arbitrarily long. 
    mystraight  = simTrackMaker.lineStraight(startpos = [0,0], length= 200, size = 2000)#, texturefile='strong_edge_soft.bmp')    
        #
    Course = mystraight.midline
    #create array of heading offsets. keep in radians
    headingoffsets = np.deg2rad(np.linspace(0,10,10))

    totalrows = len(headingoffsets) 
    
    simResults = []

    row_i = 0    
    for ho_i,ho in enumerate(headingoffsets):        
        
        print("ran")
        Car = runSimulation(Course, headingoffset = ho)

        #Append results.
        simResults.append(Car)
    
    #now plot lane positions over time for each condition. 
    plt.figure(1)

    for i, sim in enumerate(simResults):
        
        print(sim)
        steeringbias = np.array(sim.steering_bias_history)
        plt.plot(range(len(steeringbias)), steeringbias, 'b-')
    
    plt.xlabel("Time (s)")
    plt.ylabel("Positional Error (m)")
    
    plt.savefig('PositionalError.png', dpi = 300)
    plt.show()
    

    #egocentric angle to point at 10 m ahead without corrected camera.
    plt.figure(2)

    for i, sim in enumerate(simResults):
        
        print(sim)
        vis_angle = np.array(sim.vis_angle_history)
        plt.plot(range(len(vis_angle)), vis_angle, 'r-')
    
    plt.xlabel("Time (s)")
    plt.ylabel("Veridical (unrotated) Visual Angle (m)")
    
    plt.savefig('VisualAngle.png', dpi = 300)
    plt.show()

    #egocentric angle to point at 10 m ahead with corrected camera
    plt.figure(3)

    for i, sim in enumerate(simResults):
        
        print(sim)
        vis_angle_corrected = np.array(sim.vis_angle_corrected_history)
        plt.plot(range(len(vis_angle_corrected)), vis_angle_corrected, 'r-')
    
    plt.xlabel("Time (s)")
    plt.ylabel("Rotated Camera Visual Angle (m)")
    
    plt.savefig('VisualAngle_Rotated.png', dpi = 300)
    plt.show()


    