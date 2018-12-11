"""
Script to run threshold vs accumulator experiment. The participant experiences vection across a textured ground-plane. 
After a few seconds a straight road appears with a experimentally controlled deflection angle. The participants task is to steer so as to try and stay on the straight road.
A further few seconds elapses. The road disapears. The participant experiences a few seconds of vection without a road, then a new straight appears with a different deflection angle.

The main script to run the experiment is Ben-Lui_beta_tiles_road.py

The Class myExperiment handles execution of the experiment.

This script relies on the following modules:

For eyetracking - eyetrike_calibration_standard.py; eyetrike_accuracy_standard.py; also the drivinglab_pupil plugin.

For perspective correct rendering - myCave.py

For motion through the virtual world - vizdriver.py

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
	caveview = cave.getCaveView()
	return (caveview)


def GenerateConditionLists(FACTOR_radiiPool, FACTOR_occlPool, TrialsPerCondition):
	"""Based on two factor lists and TrialsPerCondition, create a factorial design and return trialarray and condition lists"""

	NCndts = len(FACTOR_radiiPool) * len(FACTOR_occlPool)	
#	ConditionList = range(NCndts) 

	#automatically generate factor lists so you can adjust levels using the FACTOR variables
	ConditionList_radii = np.repeat(FACTOR_radiiPool, len(FACTOR_occlPool)	)
	ConditionList_occl = np.tile(FACTOR_occlPool, len(FACTOR_radiiPool)	)

	print (ConditionList_radii)
	print (ConditionList_occl)

	TotalN = NCndts * TrialsPerCondition

	TRIALSEQ = range(0,NCndts)*TrialsPerCondition
	np.random.shuffle(TRIALSEQ)

	direc = [1,-1]*(TotalN/2) #makes half left and half right.
	np.random.shuffle(direc) 

	TRIALSEQ_signed = np.array(direc)*np.array(TRIALSEQ)

	return (TRIALSEQ_signed, ConditionList_radii, ConditionList_occl)

# ground texture setting
def setStage(TILING = True):
	
	"""Creates grass textured groundplane"""
	
	#CODE UP TILE-WORK WITH GROUNDPLANE.	
	##should set this up so it builds new tiles if you are reaching the boundary.
	fName = 'textures\\strong_edge.bmp'
	gtexture = viz.addTexture(fName)
	gtexture.wrap(viz.WRAP_T, viz.REPEAT)
	gtexture.wrap(viz.WRAP_S, viz.REPEAT)
	
	#add groundplane (wrap mode)
###UNCOMMENT FOR TILING
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

	
# road edge setting. Make at start of trial.
def BendMaker(radlist):
	
	#make left and right road edges for for a given radii and return them in a list.
	
	#needs to work with an array of radii

	rdsize = 500 # Hz size for curve length
	
	#left_array= np.arange(0.0, np.pi*1000)/1000
	left_array= np.linspace(0.0, np.pi,rdsize)
	#right_array = np.arange(np.pi*1000, 0.0, -1)/1000  ##arange(start,stop,step). Array with 3142(/1000) numbers
	right_array = np.linspace(np.pi, 0.0, rdsize)  ##arange(start,stop,step). Array with 3142(/1000) numbers
		
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
		viz.startLayer(viz.QUAD_STRIP)
		width = .1 #road width/2
		if r > 0:	#r=-1 means it is a straight.
			while i < rdsize:			
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
			
		leftbendlist.append(leftbend)
		rightbendlist.append(rightbend)
	
	
	return leftbendlist,rightbendlist 

class myExperiment(viz.EventClass):

	def __init__(self, eyetracking, practice, tiling, exp_id):
            
		self.EYETRACKING = eyetracking
		self.PRACTICE = practice
		self.TILING = tiling
		self.EXP_ID = exp_id

		if EYETRACKING == True:	
			LoadEyetrackingModules()
	
		#### PERSPECTIVE CORRECT ######
		self.caveview = LoadCave() #this module includes viz.go()

		##### SET CONDITION VALUES #####
		self.FACTOR_radiiPool = [300, 600, 900, 1200, 1500, 1800, 2100, 2400, 2700, 3000, 3300, 3600,-1] #13 radii conditions. 300m steps.
		self.FACTOR_occlPool = [0, .5, 1] #3 occlusion conditions
		self.TrialsPerCondition = 10	
		[trialsequence_signed, cl_radii, cl_occl]  = GenerateConditionLists(self.FACTOR_radiiPool, self.FACTOR_occlPool, self.TrialsPerCondition)

		self.TRIALSEQ_signed = trialsequence_signed #list of trialtypes in a randomised order. -ve = leftwards, +ve = rightwards.
		self.ConditionList_radii = cl_radii
		self.ConditionList_occl = cl_occl

		##### ADD GRASS TEXTURE #####
		[gplane1, gplane2] = setStage(TILING)
		self.gplane1 = gplane1
		self.gplane2 = gplane2

		##### MAKE BEND OBJECTS #####
		[leftbends,rightbends] = BendMaker(self.FACTOR_radiiPool)
		self.leftbends = leftbends
		self.rightbends = rightbends 

		self.callback(viz.TIMER_EVENT,self.updatePositionLabel)
		self.starttimer(0,1.0/60.0,viz.FOREVER)		
		

	def runtrials(self):
		"""Loops through the trial sequence"""
		
		if self.EYETRACKING:
			filename = str(self.EXP_ID) + "_Calibration" #+ str(demographics[0]) + "_" + str(demographics[2]) #add experimental block to filename
			print (filename)
			yield run_calibration(comms, filename)
			yield run_accuracy(comms, filename)		

		self.driver = vizdriver.Driver(myExp.caveview)	
		
		viz.MainScene.visible(viz.ON,viz.WORLD)		
	
		#add text to denote conditons.
		txtCondt = viz.addText("Condition",parent = viz.SCREEN)
		txtCondt.setPosition(.7,.2)
		txtCondt.fontSize(36)

		out = ""

		
		for i, trialtype_signed in enumerate(myExp.TRIALSEQ_signed):
			#import vizjoy		
			print("Trial: ", str(i))
			print("TrialType: ", str(i))

			trialtype = abs(trialtype_signed)

			trial_radii = self.ConditionList_radii[trialtype] #set radii for that trial
			trial_occl = self.ConditionList_occl[trialtype] #set target number for the trial.

			print(str([trial_radii, trial_occl]))
				
			txtDir = ""
			
			#choose correct road object.
			if trialtype_signed > 0: #right bend
				trialbend = self.rightbends[trialtype]
				txtDir = "R"
			else:
				trialbend = self.leftbends[trialtype]
				txtDir = "L"
						
			if trial_radii > 0: #if trial_radii is above zero it is a bend, not a straight 
				msg = "Radius: " + str(trial_radii) + txtDir + '_' + str(trial_occl)
			else:
				msg = "Radius: Straight" + txtDir + '_' + str(trial_occl)
			txtCondt.message(msg)				

			# Define a function that saves data
			
			#translate bend to driver position.
			driverpos = viz.MainView.getPosition()
			print driverpos
			trialbend.setPosition(driverpos[0],0, driverpos[2])
					
			#now need to set orientation
			driverEuler = viz.MainView.getEuler()
			trialbend.setEuler(driverEuler, viz.ABS_GLOBAL)		
			
			#will need to save initial vertex for line origin, and Euler. Is there a nifty way to save the relative position to the road?
			self.driver.setSWA_invisible()		
			
			yield viztask.waitTime(trial_occl) #wait an occlusion period
			
			trialbend.visible(1)
			
			yield viztask.waitTime(2.5-trial_occl) #after the occlusion add the road again. 2.5s to avoid ceiling effects.
			
			trialbend.visible(0)
			#driver.setSWA_visible()
			
			def checkCentred():
				
				centred = False
				while not centred:
					x = driver.getPos()
					if abs(x) < .5:
						centred = True
						break
				
	#		centred = False
	#		while not centred:
	#			x = driver.getPos()
	#			print x
			
			##wait a while
			print "waiting"
			#TODO: Recentre the wheel on automation.

			yield viztask.waitDirector(checkCentred)
			print "waited"
			
			self.driver.setSWA_visible()
			yield viztask.waitTime(2) #wait for input .		
			
			
			
			
		else:
			#print file after looped through all trials.
			fileproper=('Pilot_CDM.dat')
			# Opens nominated file in write mode
			path = viz.getOption('viz.publish.path/')
			file = open(path + fileproper, 'w')
			file.write(out)
			# Makes sure the file data is really written to the harddrive
			file.flush()                                        
			#print out
			file.close()
			
			#exit vizard
			
			viz.quit() ##otherwise keeps writting data onto last file untill ESC

	def RecordData(self):
		
		"""Records Data into Dataframe"""

		#TODO: convert into pandas.	
			#what data do we want? RoadVisibility Flag. SWA. Time, TrialType. x,z of that trial These can be reset in processing by subtracting the initial position and reorienting.
			#TODO: Change to Pandas Dataframe.
			if out != '-1':
				# Create the output string
				currTime = viz.tick()										
				out = out + str(float((currTime))) + '\t' + str(trialtype_signed) + '\t' + str(pos_x) + '\t' + str(pos_z)+ '\t' + str(ori)+  '\t' + str(steer) + '\t' + str(radius) + '\t' + str(occlusion) + '\t' + str(int(trialbend.getVisible())) + '\n'							
	
	def SaveData(self):
		"""Saves Data"""
	

	def updatePositionLabel(self, num):
		
		"""Timer function that gets called every frame"""
			
		# get head position(x, y, z)
		pos = viz.get(viz.HEAD_POS)
		pos[1] = 0.0 # (x, 0, z)
		# get body orientation
		ori = viz.get(viz.BODY_ORI)
		steeringWheel = driver.getPos()
									
		#what data do we want? RoadVisibility Flag. SWA. Time, TrialType. x,z of that trial These can be reset in processing by subtracting the initial position and reorienting.
		SaveData(pos[0], pos[2], ori, steeringWheel) ##.
	
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
	
if __name__ == '__main__':

	###### SET EXPERIMENT OPTIONS ######	
	EYETRACKING = True
	PRACTICE = False
	TILING = True
	EXP_ID = "BenLui17"

	if PRACTICE == True: # HACK
		EYETRACKING = False 

	myExp = myExperiment(EYETRACKING, PRACTICE, TILING, EXP_ID)


	viztask.schedule(myExp.runtrials())

