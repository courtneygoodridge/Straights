"""
Script to run threshold vs accumulator experiment. The participant experiences vection across a textured ground-plane. 
After a few seconds a straight road appears with a experimentally controlled deflection angle. The participants task is to steer so as to try and stay on the straight road.
A further few seconds elapses. The road disapears. The participant experiences a few seconds of vection without a road, then a new straight appears with a different deflection angle.

The main script to run the experiment is Ben-Lui__beta_main.py

The Class myExperiment handles execution of the experiment.

This script relies on the following modules:

For eyetracking - eyetrike_calibration_standard.py; eyetrike_accuracy_standard.py; also the drivinglab_pupil plugin.

For perspective correct rendering - myCave.py

For motion through the virtual world - vizdriver_BenLui.py

"""
import sys

rootpath = 'C:\\VENLAB data\\shared_modules\\Logitech_force_feedback'
sys.path.append(rootpath)
rootpath = 'C:\\VENLAB data\\shared_modules'
sys.path.append(rootpath)
rootpath = 'C:\\VENLAB data\\shared_modules\\pupil\\capture_settings\\plugins\\drivinglab_pupil\\'
sys.path.append(rootpath)

import viz # vizard library
import numpy as np # numpy library - such as matrix calculation
import random # python library
import vizdriver_BenLui as vizdriver # vizard library
import viztask # vizard library
import math as mt # python library
import vizshape
import vizact
import vizmat
import myCave
import pandas as pd
#import PPinput

def LoadEyetrackingModules():

	"""load eyetracking modules and check connection"""

	from eyetrike_calibration_standard import Markers, run_calibration
	from eyetrike_accuracy_standard import run_accuracy
	from UDP_comms import pupil_comms

	###Connect over network to eyetrike and check the connection
	comms = pupil_comms() #Initiate a communication with eyetrike	
	#Check the connection is live
	connected = comms.check_connection()

	if not connected:
		print("Cannot connect to Eyetrike. Check network")
		raise Exception("Could not connect to Eyetrike")
	else:
		pass	
	#markers = Markers() #this now gets added during run_calibration				
	
def LoadCave():
	"""loads myCave and returns Caveview"""

	#set EH in myCave
	cave = myCave.initCave()
	#caveview = cave.getCaveView()
	return (cave)

def GenerateConditionLists(FACTOR_headingpool, FACTOR_occlPool, TrialsPerCondition):
	"""Based on two factor lists and TrialsPerCondition, create a factorial design and return trialarray and condition lists"""

	NCndts = len(FACTOR_headingpool) * len(FACTOR_occlPool)	
#	ConditionList = range(NCndts) 

	#automatically generate factor lists so you can adjust levels using the FACTOR variables
	ConditionList_heading = np.repeat(FACTOR_headingpool, len(FACTOR_occlPool)	)
	ConditionList_occl = np.tile(FACTOR_occlPool, len(FACTOR_headingpool)	)

	print (ConditionList_heading)
	print (ConditionList_occl)

	TotalN = NCndts * TrialsPerCondition

	TRIALSEQ = range(0,NCndts)*TrialsPerCondition
	np.random.shuffle(TRIALSEQ)

	direc = [1,-1]*(TotalN/2) #makes half left and half right.
	np.random.shuffle(direc) 

	TRIALSEQ_signed = np.array(direc)*np.array(TRIALSEQ)

	return (TRIALSEQ_signed, ConditionList_heading, ConditionList_occl)

# ground texture setting
def setStage(TILING = True):
	
	"""Creates grass textured groundplane"""
	
	# background color
	viz.clearcolor(viz.SKYBLUE)
	
	#CODE UP TILE-WORK WITH GROUNDPLANE.	
	##should set this up so it builds new tiles if you are reaching the boundary.
	fName = 'textures\\strong_edge.bmp'
	gtexture = viz.addTexture(fName)
	gtexture.wrap(viz.WRAP_T, viz.REPEAT)
	gtexture.wrap(viz.WRAP_S, viz.REPEAT)
	#add groundplane (wrap mode)
###UNCOMMENT FOR TILING
# Tiling saves memory by using two groundplane tiles instead of a massive groundplane. Since the drivers are essentially driving linearly forward, they cover a lot of distance across the z axis.
	gplane1 = viz.addTexQuad() ##
	tilesize = 1000 #half a km wide
	#planesize = tilesize/5
	planesize = tilesize/5.0
	gplane1.setScale(tilesize, tilesize*2, tilesize)
	gplane1.setEuler((0, 90, 0),viz.REL_LOCAL)
	#groundplane.setPosition((0,0,1000),viz.REL_LOCAL) #move forward 1km so don't need to render as much.
	matrix = vizmat.Transform()
	matrix.setScale( planesize, planesize*2, planesize )
	gplane1.texmat( matrix )
	#gplane1.texture(gtexture)
	gplane1.texture(gtexture)
	gplane1.visible(1)
#
	if TILING:
		gplane2 = gplane1.copy() #create duplicate.
		gplane2.setScale(tilesize, tilesize*2, tilesize)
		gplane2.setEuler((0, 90, 0),viz.REL_LOCAL)
		#groundplane.setPosition((0,0,1000),viz.REL_LOCAL) #move forward 1km so don't need to render as much.
		gplane2.texmat( matrix )
		#gplane1.texture(gtexture)
		gplane2.texture(gtexture)
		gplane2.visible(1)
		gplane2.setPosition(0,0,tilesize*2)
		gplane2.zoffset(-1)
	else:
		gplane2 = []
	
	return(gplane1, gplane2)
#	##To save CPU I could move a small quad with the person.
#	gsizex = 50 #groundplane size, metres squared
#	gsizez = 160 #clipped at 150.
#	#groundplane = vizshape.addPlane(size=(gsize[0],gsize[1]),axis=vizshape.AXIS_Y,cullFace=True) ##make groundplane
#	#draw black quad
#	#groundplane.texture(viz.add('black.bmp')) #make groundplane black
#	viz.startLayer(viz.QUADS)
#	viz.vertexColor(viz.BLACK)
#	viz.vertex(0-gsizex,0,0)	
#	viz.vertex(0-gsizex,0,+gsizez)
#	viz.vertex(0+gsizex,0,+gsizez)
#	viz.vertex(0+gsizex,0,0)
#	groundplane = viz.endLayer()
#	groundplane.dynamic()
#	groundplane.visible(1)
#	link = viz.link(viz.MainView,groundplane)
#	link.clampPosY(0)
#	
#	
#	
##	#NEED TO TILE THIS DOTS & JUST BEYOND
##
#	#Build dot plane to cover black groundplane
#	ndots = 100000 #arbitrarily picked. perhaps we could match dot density to K & W, 2013? 
#	dsize = 5000
#	viz.startlayer(viz.POINTS)
#	viz.vertexColor(viz.WHITE)	
#	viz.pointSize(2)
#	for i in range (0,ndots):
#		x =  (random.random() - .5)  * dsize
#		z = (random.random() - .5) * dsize
#		viz.vertex([x,0,z])
#	
#	dots = viz.endLayer()
#	dots.setPosition(0,0,0)
#	dots.visible(1)

	


def StraightMaker(x, start_z, end_z, colour = [.8,.8,.8], primitive= viz.QUAD_STRIP, width=None):
	"""returns a straight, given some starting coords and length"""
	viz.startlayer(primitive)
	if width is None:
		if primitive == viz.QUAD_STRIP:
			width = .05
		elif primitive == viz.LINE_STRIP:
			width = 2
			viz.linewidth(width)
			width = 0
	
	viz.vertex(x-width,.1,start_z)
	viz.vertexcolor(colour)
	viz.vertex(x+width,.1,start_z)
	viz.vertexcolor(colour)
	viz.vertex(x-width,.1,end_z)
	viz.vertexcolor(colour)
	viz.vertex(x+width,.1,end_z)		

	straightedge = viz.endlayer()

	return straightedge


def BendMaker(radlist):
	
	"""makes left and right road edges for for a given heading and return them in a list"""
	
	#needs to work with an array of heading

	rdsize = 500 # Hz size for curve length
	
	#left_array= np.arange(0.0, np.pi*1000)/1000 # arange(start,stop,step). Array with 3142(/1000) numbers. 
	left_array= np.linspace(0.0, np.pi,rdsize) #### creates evenly spaced 500 steps from 0 to pi for left heading turn to be made 
	#right_array = np.arange(np.pi*1000, 0.0, -1)/1000  ##arange(start,stop,step). Array with 3142(/1000) numbers
	right_array = np.linspace(np.pi, 0.0, rdsize)  #### From pi to 0 in 500 steps (opposite for opposite corner)

	#### Above code creates gradual turns for the bends of varying heading. 
	#### I would need less gradual spacing - spacing would have to be the same so all 500 points would in a straight line 

	# left_array = np.linspace(0.0, 5000, rdsize)
	# right_array = np.linspace(5000, 0.0, rdsize)	

	#### Code above did not create 2 straight lines 
	#### However is did remove the curved bends and create random zig zags within the environment
	#### Clearly not what is needed but I now know that this parameter can manipulate the line bend
	#### At certain intervals, a one remaining straight line appear which was clearly the -1 in the heading pool
	#### Perhaps incorporating the the straight lines vertices in these left/right_array parameters mights create the staright lines I need?

	# left_array = viz.vertex(0+width,.1,100.0)
	# right_array = viz.vertex(0+width,.1,100.0)

	
	leftbendlist = []
	rightbendlist = []
	grey = [.8,.8,.8]
	for r in radlist:
		x1 = np.zeros(rdsize)
		z1 = np.zeros(rdsize)
		x2 = np.zeros(rdsize)
		z2 = np.zeros(rdsize)	
			
		i = 0

		##try using quad-strip for roads.
		viz.startLayer(viz.QUAD_STRIP) # Investigate quad strips on google 
		width = .1 #road width/2
		if r > 0:	#r=-1 means it is a straight.
			while i < rdsize:
				
				######### COURTNEY EDITS BELOW #############

				#### I'm trying to place a straight road angled at each of the heading rather than the bends that are currently there.
				#### i.e. if the heading is greater than 0 and while i is smaller than the rdsize, plot vertices to create straight roads. 
				#### The road will be created at an angle to create the heading that are being looped through.
				#### However, rdsize refers to the points on the curve, so without changing this I could have 500 small straight roads?
				#### Also would it more likely be that I'd have to specify angle for this to work? What is the relationship between angle and heading?
				#### rdsize creates the small squares that are put together to create the bend of the heading chosen, with x and z being their coordinates.
				#### 

				# x1[i] = viz.vertex(0+width,.1,0)
				# z1[i] = viz.vertex(0-width,.1,0)
				# x2[i] = viz.vertex(0+width,.1,100.0) * right_array[i] #100m straight
				# z2[i] = viz.vertex(0-width,.1,100.0) * right_array[i] #100m straight
				# viz.vertexColor(grey)
				# i + = 1
				
				# I need to somehow incorporate the left and right arrary variables as these dictate which direction the straight bend should go
				# Perhaps multilping by the right array alongside indexing from the loop? Not sure how or why this could work
				# Might use np.tan() function? This creates a straight line that touches but does intersect a curve
				# Potential to use this to create a straight line that is at the tangent of the heading of the original bend?
				
				# One option could be to keep the origianl code all the same and just use the np.tan() function
				# In the hope that instead of creating a bend, it would create a straight line at a tangent of the bend 

				# Or could use it with the edits I have a suggested above 
				# i.e. I still might need to create a straight line with the left and right array variables (see below).

				# x1[i] = viz.vertex(0+width,.1,0)
				# z1[i] = viz.vertex(0-width,.1,0)
				# x2[i] = viz.vertex(0+width,.1,100.0) * np.tan(right_array[i]) #100m straight
				# z2[i] = viz.vertex(0-width,.1,100.0) * np.tan(right_array[i]) #100m straight
				# viz.vertexColor(grey)
				# i + = 1

				####### np.tan() did not work. All bends were removed from the environment

				######### COURTNEY EDITS ABOVE ############

						
				#need two vertices at each point to form quad vertices
				#inside edge
				x1[i] = ((r-width)*np.cos(right_array[i])) + r
				z1[i] = ((r-width)*np.sin(right_array[i]))
				#print (z1[i])
				viz.vertexColor(grey)
				viz.vertex(x1[i], .1, z1[i] )		
				
				#outside edge. #does it matter if it's overwritten? 
				x1[i] = ((r+width)*np.cos(right_array[i])) + r
				z1[i] = ((r+width)*np.sin(right_array[i]))
				#print (z1[i])
				viz.vertexColor(grey)
				viz.vertex(x1[i], .1, z1[i] )	
				i += 1
		else:
			viz.vertexColor(grey)
			viz.vertex(0+width,.1,0)
			viz.vertex(0-width,.1,0)
			viz.vertex(0+width,.1,100.0) #100m straight
			viz.vertex(0-width,.1,100.0) #100m straight
			
		rightbend = viz.endlayer()
		rightbend.visible(0)
		rightbend.dynamic()

		### Above codes for the bends towards the right handside. 
		### The X and Z coordinates help map the quad strips onto the environment.
		### The else statement means that if r is less than zero, a straight is created.
		### rdsize = 500 represents the curve length, however I do not want a curve anymore. 
		### This needs to be edited so quad strips can be connected at angles to created straight curves.
		### Try altering the rdsize and running code to see how that affects the shape of the bend.
			
		i=0
		viz.startLayer(viz.QUAD_STRIP)
		width = .1 #road width/2
		if r > 0:	#r=-1 means it is a straight.
			while i < rdsize:			
				#need two vertices at each point to form quad vertices
				#inside edge
				x2[i] = ((r-width)*np.cos(left_array[i])) - r
				z2[i] = ((r-width)*np.sin(left_array[i]))
				#print (z1[i])
				viz.vertexColor(grey)
				viz.vertex(x2[i], .1, z2[i] )		
				
				#outside edge. #does it matter if it's overwritten? 
				x1[2] = ((r+width)*np.cos(left_array[i])) - r
				z1[2] = ((r+width)*np.sin(left_array[i]))
				#print (z1[i])
				viz.vertexColor(grey)
				viz.vertex(x1[2], .1, z2[i] )	
				i += 1
		else:
			viz.vertexColor(grey)
			viz.vertex(0+width,.1,0)
			viz.vertex(0-width,.1,0)
			viz.vertex(0+width,.1,100.0) #100m straight
			viz.vertex(0-width,.1,100.0) #100m straight
		
		leftbend = viz.endlayer()	
		leftbend.visible(0)
		leftbend.dynamic()

		### Above codes for the left hand bends
			
		leftbendlist.append(leftbend)
		rightbendlist.append(rightbend)
	
	
	return leftbendlist,rightbendlist 

class myExperiment(viz.EventClass):

	def __init__(self, eyetracking, practice, tiling, exp_id, ppid = 1):

		viz.EventClass.__init__(self) #specific to vizard classes
	
		self.EYETRACKING = eyetracking
		self.PRACTICE = practice
		self.TILING = tiling
		self.EXP_ID = exp_id

		if EYETRACKING == True:	
			LoadEyetrackingModules()

		self.PP_id = ppid
		self.VisibleRoadTime = 2.5 #length of time that road is visible. Constant throughout experiment
	
		#### PERSPECTIVE CORRECT ######
		self.cave = LoadCave()
		self.caveview = self.cave.getCaveView() #this module includes viz.go()

		##### SET CONDITION VALUES #####
		self.FACTOR_headingpool = np.linspace(-45.0, 45.0, 5) #array from -45 to 45. 
		self.FACTOR_occlPool = [0, .5, 1] #3 occlusion delay time conditions
		self.TrialsPerCondition = 10	
		[trialsequence_signed, cl_heading, cl_occl]  = GenerateConditionLists(self.FACTOR_headingpool, self.FACTOR_occlPool, self.TrialsPerCondition)

		self.TRIALSEQ_signed = trialsequence_signed #list of trialtypes in a randomised order. -ve = leftwards, +ve = rightwards.
		self.ConditionList_heading = cl_heading
		self.ConditionList_occl = cl_occl

		##### ADD GRASS TEXTURE #####
		[gplane1, gplane2] = setStage(TILING)
		self.gplane1 = gplane1
		self.gplane2 = gplane2

		##### MAKE STRAIGHT OBJECT #####
		self.Straight = StraightMaker(x = 0, start_z = 0, end_z = 200)	

		self.callback(viz.TIMER_EVENT,self.updatePositionLabel)
		self.starttimer(0,0,viz.FOREVER) #self.update position label is called every frame.
		
		self.driver = None
		self.SAVEDATA = False

		####### DATA SAVING ######
		datacolumns = ['ppid', 'heading','occlusion','trialn','timestamp','trialtype_signed','World_x','World_z','WorldYaw','SWA','YawRate_seconds','TurnAngle_frames','Distance_frames','dt', 'StraightVisible']
		self.Output = pd.DataFrame(columns=datacolumns) #make new empty EndofTrial data

		### parameters that are set at the start of each trial ####
		self.Trial_heading = 0
		self.Trial_occlusion = 0 				
		self.Trial_N = 0 #nth trial
		self.Trial_trialtype_signed = 0			
		#self.Trial_Timer = 0 #keeps track of trial length. 
		#self.Trial_BendObject = None		
		
		#### parameters that are updated each timestamp ####
		self.Current_pos_x = 0
		self.Current_pos_z = 0
		self.Current_yaw = 0
		self.Current_SWA = 0
		self.Current_Time = 0
		self.Current_RowIndex = 0
		seStraight = 0
		self.Current_YawRate_seconds = 0
		self.Current_TurnAngle_frames = 0
		self.Current_distance = 0
		self.Current_dt = 0

		self.callback(viz.EXIT_EVENT,self.SaveData) #if exited, save the data. 

	def runtrials(self):
		"""Loops through the trial sequence"""
		
		if self.EYETRACKING:
			filename = str(self.EXP_ID) + "_Calibration" #+ str(demographics[0]) + "_" + str(demographics[2]) #add experimental block to filename
			print (filename)
			yield run_calibration(comms, filename)
			yield run_accuracy(comms, filename)		

		self.driver = vizdriver.Driver(self.caveview)	
		self.SAVEDATA = True # switch saving data on.
		
		viz.MainScene.visible(viz.ON,viz.WORLD)		
	
		#add text to denote conditons.
		txtCondt = viz.addText("Condition",parent = viz.SCREEN)
		txtCondt.setPosition(.7,.2)
		txtCondt.fontSize(36)		

		if self.EYETRACKING:
			comms.start_trial()
		
		for i, trialtype_signed in enumerate(self.TRIALSEQ_signed):

			### iterates each trial ###

			#import vizjoy		
			print("Trial: ", str(i))
			print("TrialType: ", str(trialtype_signed))
			
			trialtype = abs(trialtype_signed)

			trial_heading = self.ConditionList_heading[trialtype] #set heading for that trial
			trial_occl = self.ConditionList_occl[trialtype] #set target number for the trial.

			print(str([trial_heading, trial_occl]))

			txtDir = ""
			
			######choose correct road object.######

			# changes message on screen			
			msg = msg = "heading: " + str(trial_heading) + '_' + str(trial_occl)
			txtCondt.message(msg)	

			#update class trial parameters#
			self.Trial_N = i
			self.Trial_heading = trial_heading
			self.Trial_occlusion = trial_occl			
			#self.Trial_BendObject = trialbend			
			
			#translate bend to driver position.
			driverpos = viz.MainView.getPosition()
			print driverpos
			self.Straight.setPosition(driverpos[0],0, driverpos[2])
					
			#now need to set orientation
			driverEuler = viz.MainView.getEuler()
			#Euler needs to be in yaw,pitch,roll
			#bendEuler = driverEuler 
			self.Straight.setEuler(driverEuler, viz.ABS_GLOBAL)		
			
			#will need to save initial vertex for line origin, and Euler. Is there a nifty way to save the relative position to the road?
			self.driver.setSWA_invisible()		
			
			yield viztask.waitTime(trial_occl) #wait an occlusion period. Will viztask waitime work within a class? 
			
			self.Straight.visible(1)
			
			yield viztask.waitTime(self.VisibleRoadTime-trial_occl) #after the occlusion add the road again. 2.5s to avoid ceiling effects.
			
			self.Straight.visible(0)
			#driver.setSWA_visible()
			
			def checkCentred():
				
				centred = False
				x = self.driver.getPos()
				if abs(x) < .5:
					centred = True						
				
				return (centred)
			
			##wait a while
			print "waiting"
			#TODO: Recentre the wheel on automation.

			yield viztask.waitTrue(checkCentred)
			print "waited"
			
			self.driver.setSWA_visible()
			yield viztask.waitTime(2) #wait for input .		
	
		#loop has finished.
		CloseConnections(self.EYETRACKING)
		#viz.quit() 

	
	def getNormalisedEuler(self):
		"""returns three dimensional euler on 0-360 scale"""
		
		euler = self.caveview.getEuler()
		
		euler[0] = vizmat.NormAngle(euler[0])
		euler[1] = vizmat.NormAngle(euler[1])
		euler[2] = vizmat.NormAngle(euler[2])

		return euler

	def RecordData(self):
		
		"""Records Data into Dataframe"""

		if self.SAVEDATA:
			#datacolumns = ['ppid', 'heading','occlusion','trialn','timestamp','trialtype_signed','World_x','World_z','WorldYaw','SWA','BendVisible']
			output = [self.PP_id, self.Trial_heading, self.Trial_occlusion, self.Trial_N, self.Current_Time, self.Trial_trialtype_signed, 
			self.Current_pos_x, self.Current_pos_z, self.Current_yaw, self.Current_SWA, self.Current_YawRate_seconds, self.Current_TurnAngle_frames, 
			self.Current_distance, self.Current_dt, self.Straight] #output array.		

			self.Output.loc[self.Current_RowIndex,:] = output #this dataframe is actually just one line. 		
	
	def SaveData(self):

		"""Saves Current Dataframe to csv file"""
		self.Output.to_csv('Data//Pilot.csv')

	def updatePositionLabel(self, num): #num is a timer parameter
		
		"""Timer function that gets called every frame. Updates parameters for saving and moves groundplane if TILING mode is switched on"""

		#print("UpdatingPosition...")	
		#update driver view.
		if self.driver is None: #if self.driver == None, it hasn't been initialised yet. Only gets initialised at the start of runtrials()
			UpdateValues = [0, 0, 0, 0, 0]
		else:
			UpdateValues = self.driver.UpdateView() #update view and return values used for update
		
		# get head position(x, y, z)
		pos = self.caveview.getPosition()
				
		ori = self.getNormalisedEuler()		
									
		### #update Current parameters ####
		self.Current_pos_x = pos[0]
		self.Current_pos_z = pos[2]
		self.Current_SWA = UpdateValues[4]
		self.Current_yaw = ori[0]
		self.Current_RowIndex += 1
		self.Current_Time = viz.tick()
		self.Current_YawRate_seconds = UpdateValues[0]
		self.Current_TurnAngle_frames = UpdateValues[1]
		self.Current_distance = UpdateValues[2]
		self.Current_dt = UpdateValues[3]

		
		self.Current_StraightVisibleFlag = self.Straight.getVisible()	
	


		self.RecordData() #write a line in the dataframe.
	
		if self.TILING:
		
			#check if groundplane is culled, and update it if it is. 
			if viz.MainWindow.isCulled(self.gplane1):
				#if it's not visible, move ahead 50m from the driver.
				
				print 'attempting to shift gplane1'
				#translate bend to driver position.
				driverpos = viz.MainView.getPosition()
				self.gplane1.setPosition(driverpos[0],0, driverpos[2],viz.ABS_GLOBAL) #bring to driver pos
				
				#now need to set orientation
				#driverEuler = viz.MainView.getEuler()
				self.gplane1.setEuler(driverEuler[0],0,0, viz.ABS_GLOBAL)		
				
				self.gplane1.setPosition(0,0, 30, viz.REL_LOCAL) #should match up to the tilesize * 3
				
				
				self.gplane1.setEuler(0,90,0, viz.REL_LOCAL) #rotate to ground plane	
				
			if viz.MainWindow.isCulled(self.gplane2):
				#if it's not visible, move ahead 50m from the driver.
				
				print 'attempting to shift gplane2'
				#translate bend to driver position.
				driverpos = viz.MainView.getPosition()
				self.gplane2.setPosition(driverpos[0],0, driverpos[2],viz.ABS_GLOBAL) #bring to driver pos
				
				#now need to set orientation
				#driverEuler = viz.MainView.getEuler()
				self.gplane2.setEuler(driverEuler[0],0,0, viz.ABS_GLOBAL)		
				
				self.gplane2.setPosition(0,0, 30, viz.REL_LOCAL) #should match up to the tilesize y size of the other tile.
				
				self.gplane2.setEuler(0,90,0, viz.REL_LOCAL) #rotate to ground plane		

def CloseConnections(EYETRACKING):
	
	"""Shuts down EYETRACKING and wheel threads then quits viz"""		
	
	print ("Closing connections")
	if EYETRACKING: 
	 	comms.stop_trial() #closes recording			
	
	#kill automation
	viz.quit()
	
if __name__ == '__main__':

	###### SET EXPERIMENT OPTIONS ######	
	EYETRACKING = True
	PRACTICE = True
	TILING = False #to reduce memory load set True to create two groundplane tiles that dynamically follow the driver's position instead of one massive groundplane.
	EXP_ID = "BenLui17"

	if PRACTICE == True: # HACK
		EYETRACKING = False 

	myExp = myExperiment(EYETRACKING, PRACTICE, TILING, EXP_ID) #initialises a myExperiment class

	viz.callback(viz.EXIT_EVENT,CloseConnections, myExp.EYETRACKING)

	viztask.schedule(myExp.runtrials())

