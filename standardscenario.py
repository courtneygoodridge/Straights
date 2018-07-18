import viz # vizard library
import numpy as np # numpy library - such as matrix calculation
import random # python library
import vizdriver # vizard library
import viztask # vizard library
import math as mt # python library

global driver # global variable

driver = vizdriver.Driver()

###CDM - have removed all code relating to flow and road manipulations, and also removed eyetracking. This code only has a constant curvature bend with a fixation 16.1m ahead of the driver.
###Before the constant curvature bend there is a straight section of 9m. Feel free to change this for the automation phase.
###The code resets the driver after 6secs of driving (i.e. one trial).
###We will build flow/road manipulations into the code once you have familiarised yourself with Vizard and managed to add an automation phase to the beginning of the code.


fixation_counter = 0
rdsize = 600 # Hz size for curve length
edge = 0

# 600Hz data from 0 to PI
left_array = np.linspace(0.0, np.pi, rdsize) ##linspace(start,stop,num) returns evenly spread numbers.
# 600Hz data from PI to o
right_array = np.linspace(np.pi, 0.0, rdsize) 

roadWidth = 3.0 # Road Width
straight_road = 9.0 # Straight Road Length

# all 0 in 50 matrix
xStraight = np.zeros(50)
zStraight = np.zeros(50)

# make random list between 0 to straight length
for a in range(0, 50):
	zStraight[a] = random.uniform(0, straight_road) ##Draws 50 data points from a uniform distribution 0 - 9.
zStraight = np.sort(zStraight)
zStraight = list(zStraight)

####create (invisible) midline for trial
global x_right_mid, z_right_mid, x_left_mid, z_left_mid
r = 60.0 #constant curvature bend of 60m radius.
# 1000 splits during curve because PI = 3.142
x_right_mid = np.zeros(3142)
z_right_mid = np.zeros(3142)
x_left_mid = np.zeros(3142)
z_left_mid = np.zeros(3142)
left_array_fix = np.arange(0.0, np.pi*1000)/1000
right_array_fix = np.arange(np.pi*1000, 0.0, -1)/1000  ##arange(start,stop,step). Array with 3142(/1000) numbers

c = 0
while c < 3142:
	x_right_mid[c] = ( ( (r)*np.cos(right_array_fix[c]) ) + r) 
	z_right_mid[c] = ( ( (r)*np.sin(right_array_fix[c]) ) + straight_road )
	x_left_mid[c] = ( ( (r)*np.cos(left_array_fix[c]) ) - r)
	z_left_mid[c] = ( ( (r)*np.sin(left_array_fix[c]) ) + straight_road )
	
	c += 1

# start empty world
viz.go()
# setting Field-of-View fov(vertical degree, horizontal ratio(vertical*ratio[deg]))
viz.fov(77,1.25) #sets window aspect ratio.
# clipping distance clip(near[m], far[m])
viz.clip(1,60) #clips world at 60m


##Create array of trials.
N = 1 ###Number of conditions, for this code we only have one.
TRIALS = 10
TotalN = N*TRIALS
TRIALSEQ = range(1,N+1)*TRIALS
direc = [1,-1]*(TotalN/2)
TRIALSEQ = np.sort(TRIALSEQ)
TRIALSEQ_signed = np.array(direc)*np.array(TRIALSEQ)
random.shuffle(TRIALSEQ_signed)

# background color
viz.clearcolor(viz.SKYBLUE)
#viz.MainView.getPosition() ## get powition of main viewpoit
#view = viz.get(viz.MAIN_VIEWPOINT)  ## get position of main viewpoint 

#viz.MainView.setPosition(0,1,0)
#viz.MainView.setEuler(0,0,0)

# ground texture setting
def setStage():
	
	global groundplane, groundtexture
	
	fName = 'textures\strong_edge.bmp'
	
	# add groundplane (wrap mode)
	groundtexture = viz.addTexture(fName)
	groundtexture.wrap(viz.WRAP_T, viz.REPEAT)
	groundtexture.wrap(viz.WRAP_S, viz.REPEAT)
	
	groundplane = viz.addTexQuad() ##ground for right bends (tight)
	tilesize = 300
	planesize = tilesize/5
	groundplane.setScale(tilesize, tilesize, tilesize)
	groundplane.setEuler((0, 90, 0),viz.REL_LOCAL)
	matrix = vizmat.Transform()
	matrix.setScale( planesize, planesize, planesize )
	groundplane.texmat( matrix )
	groundplane.texture(groundtexture)
	groundplane.visible(1)
	
# fixation point setting
def addfix():
	global fixation 
	
	##add fixation
	fixName = 'textures/fix_trans.gif'
	fixation = viz.add(viz.TEXQUAD)
	ttsize = .4
	fixation.scale(ttsize, ttsize, ttsize)
	fixation.texture(viz.add(fixName))
	fixation.visible(1)
	
# road edge setting
def roadEdges():
	global inside_edge, outside_edge, trialtype_signed, rdsize, edge, trialtype
	
	if edge == 1: #if already drawn
		inside_edge.remove()
		outside_edge.remove()
	
	road_x = 0
	roadWidth = 3.0
	r = 60	
	x1 = np.zeros(rdsize)
	z1 = np.zeros(rdsize)
	x2 = np.zeros(rdsize)
	z2 = np.zeros(rdsize)	
	
	#normal edges
	if trialtype_signed > 0: #right curve
		##Outside Edge - Right
		# outside edge drawing of straight line
		i = 0
		viz.startlayer(viz.LINE_STRIP) 
		viz.linewidth(1)
		viz.vertex((road_x-(roadWidth/2)), .1, 0)
		viz.vertex((road_x-(roadWidth/2)), .1, straight_road)

		# outside edge drawing of right curve
		while i < rdsize:
			x1[i] = (r+(roadWidth/2))*np.cos(right_array[i]) + r
			z1[i] = (r+(roadWidth/2))*np.sin(right_array[i]) + straight_road				
			viz.vertex(x1[i], .1, z1[i] )				
			i += 1
		outside_edge = viz.endlayer()
		
		outside_edge.alpha(1)
		
		# inside edge drawing of straight line
		i = 0			
		viz.startlayer(viz.LINE_STRIP)
		viz.linewidth(1)
		viz.vertex(road_x-(roadWidth/2), 0.1, 0)
		viz.vertex(road_x-(roadWidth/2), 0.1, straight_road)

		# inside edge drawing of right curve
		while i < rdsize:
			x2[i] = (r-(roadWidth/2))*np.cos(right_array[i]) + r
			z2[i] = (r-(roadWidth/2))*np.sin(right_array[i]) + straight_road
			viz.vertex(x2[i], 0.1, z2[i])
			i += 1				
		inside_edge = viz.endlayer()
		
		inside_edge.alpha(1)
		
	elif trialtype_signed < 0: # left curve
		# outside edge drawing of straight line
		viz.startlayer(viz.LINE_STRIP)
		viz.linewidth(1)
		viz.vertex(road_x+(roadWidth/2), .1, 0)
		viz.vertex(road_x+(roadWidth/2), .1, straight_road)
		i = 0

		# outside edge drawing of left curve
		while i < rdsize:
			x1[i] = (r+(roadWidth/2))*np.cos(left_array[i]) - r
			z1[i] = (r+(roadWidth/2))*np.sin(left_array[i]) + straight_road
			viz.vertex(x1[i], .1, z1[i])				
			i += 1
		outside_edge = viz.endlayer()				
		
		outside_edge.alpha(1)
		
		# inside edge drawing of straight line
		viz.startlayer(viz.LINE_STRIP)
		viz.linewidth(1)			
		viz.vertex(road_x-(roadWidth/2), .1, 0)
		viz.vertex(road_x-(roadWidth/2), .1, straight_road)

		# inside edge drawing of left curve
		i = 0				
		while i < rdsize:
			x2[i] = (r-(roadWidth/2))*np.cos(left_array[i]) - r
			z2[i] = (r-(roadWidth/2))*np.sin(left_array[i]) + straight_road
			viz.vertex(x2[i], 0.1, z2[i])				
			i += 1
		inside_edge = viz.endlayer()
		
		inside_edge.alpha(1)
	edge = 1	


def runtrials():
	
	global trialtype, trialtype_signed, groundplane, fixation_counter, inside_edge, outside_edge
	
	setStage() # texture setting
	addfix()   # fixation setting
	driver.reset() # initialization of driver


	def updatePositionLabel():
		global driver, trialtype_signed, fixation, fixation_counter, rdsize, outside_edge, inside_edge, trialtype, groundplane
		
		# get head position(x, y, z)
		pos = viz.get(viz.HEAD_POS)
		pos[1] = 0.0 # (x, 0, z)
		# get body orientation
		ori = viz.get(viz.BODY_ORI)
		steeringWheel = driver.getPos()

		
		######Fixation. This section makes sure the fixation is moved with the observer. 
		fpheight = .12  
		fixation.setEuler((ori, 0.0, 0.0),viz.ABS_GLOBAL) ##fixation point always faces observer
		
		
		if trialtype_signed > 0: ##fixations for right bends
			while fixation_counter < 3142:
				fix_dist = mt.sqrt( ( ( pos[0] - x_right_mid[fixation_counter] )**2 ) + ( ( pos[2] - z_right_mid[fixation_counter] )**2 ) )
				if ( (fix_dist < 16.0) | (fix_dist > 16.3) ):
					fixation_counter += 1
					continue
				elif ( (fix_dist > 16.0) and (fix_dist < 16.3) ):
					fpx = x_right_mid[fixation_counter]
					fpz = z_right_mid[fixation_counter]
					centre_x = x_right_mid[fixation_counter]
					centre_z = z_right_mid[fixation_counter]
					break
			else: ##if you move more than 16m away from any possible fixation, fixation goes back to 0,0,0
				fixation_counter = 0  ##if you end up finding your path again, there is a brand new fixation for you! 
				fpx = 0
				fpz = 0
				centre_x = 0
				centre_z = 0
		else: ##fixations for left bends
			while fixation_counter < 3142:
				fix_dist = mt.sqrt( ( ( pos[0] - x_left_mid[fixation_counter] )**2 ) + ( ( pos[2] - z_left_mid[fixation_counter] )**2 ) )
				if ( (fix_dist < 16.0) | (fix_dist > 16.3) ):
					fixation_counter += 1
					#compCount += 1
					continue
				elif ( (fix_dist > 16.0) and (fix_dist < 16.3) ):
					fpx = x_left_mid[fixation_counter]
					fpz = z_left_mid[fixation_counter]
					centre_x = x_left_mid[fixation_counter]
					centre_z = z_left_mid[fixation_counter]
					#print fix_dist
					break
			else:
				fixation_counter = 0
				fpx = 0
				fpz = 0
				centre_x = 0	
				centre_z = 0
		
		############################
		## added by Yuki
		# insert variables in driver class
		driver.function_insert(centre_x, centre_z, pos[0], pos[2], fix_dist)
		############################
		
		# fixation coordinate(X, eye height, Z)
		fixation.translate(fpx, fpheight, fpz)
		
		eyedata = 9999
		#SaveData(pos[0], pos[1], pos[2], ori, steeringWheel, eyedata) ##.

	# start action ontimer(rate, function)
	vizact.ontimer((1.0/60.0),updatePositionLabel)
	
	
	for j in range(0,TotalN):
		#import vizjoy
		global outside_edge, inside_edge, trialtype, trialtype_signed
		
		trialtype=abs(TRIALSEQ_signed[j])
		trialtype_signed = TRIALSEQ_signed[j]				
	
		viz.MainScene.visible(viz.OFF,viz.WORLD)
		
##		# Define a function that saves data
##		def SaveData(pos_x, pos_y, pos_z, ori, steer, eye):
##			# Create the output string
##			currTime = viz.tick()
##			#out = str(float((currTime))) + '\t' + str(pos_x) + '\t' + str(pos_z)+ '\t' + str(ori)+ '\t' + str(trialtype_signed) + '\n'
##			
##			out = str(float((currTime))) + '\t' + str(pos_x) + '\t' + str(pos_z)+ '\t' + str(ori)+ '\t' + str(steer) + '\t' + str(trialtype_signed) + '\n'
##			#out = str(float((currTime))) + '\t' + str(pos_x) + '\t' + str(pos_z)+ '\t' + str(ori)+ '\t' + str(steer) + '\t' + str(eye[0]) + '\t' + str(eye[1]) + '\t' + str(eye[2]) + '\t' + str(eye[3]) + '\t' + str(eye[4]) + '\t' + str(trialtype_signed) + '\n'
##			# Write the string to the output file
##			file.write(out)                                     
##			# Makes sure the file data is really written to the harddrive
##			file.flush()                                        
##			#print out
	
			
		roadEdges()	
		
		driver.reset()
		
		viz.MainScene.visible(viz.ON,viz.WORLD)
		
		yield viztask.waitTime(10) #Trial Time
		
		
		if edge == 1:
			inside_edge.remove()
			outside_edge.remove()
		
	else:
		viz.quit() ##otherwise keeps writting data onto last file untill ESC


viztask.schedule(runtrials())

