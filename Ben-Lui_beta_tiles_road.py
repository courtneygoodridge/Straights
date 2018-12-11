#TODO: Reorganise code into smaller functions.
#TODO: Add cognitive load.


rootpath = 'C:\VENLAB data\shared_modules\Logitech_force_feedback'
sys.path.append(rootpath)
rootpath = 'C:\VENLAB data\shared_modules'
sys.path.append(rootpath)
rootpath = 'C:/VENLAB data/shared_modules/pupil/capture_settings/plugins/drivinglab_pupil/'
sys.path.append(rootpath)

AUTOWHEEL = True
EYETRACKING = False
PRACTICE = True #flag for whether in practice mode or not.
TILING = True

if PRACTICE: #HACK
	EYETRACKING = False

# if AUTOWHEEL: 
# 	import logitech_wheel_threaded
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
#import myCave #these should be in shared modules
#import PPinput


if EYETRACKING:
	from eyetrike_calibration_standard import Markers, run_calibration
	from eyetrike_accuracy_standard import run_accuracy
	from UDP_comms import pupil_comms

if EYETRACKING: 
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
		
else:
	comms = []

if EYETRACKING:
	filename = str(ExpID) + "_Calibration" #+ str(demographics[0]) + "_" + str(demographics[2]) #add experimental block to filename
	print (filename)
	yield run_calibration(comms, filename)
	yield run_accuracy(comms, filename)		

if AUTOWHEEL:
	#Create a steeringWheel instance
	mywheel = logitech_wheel_threaded.steeringWheelThreaded(handle)	
	mywheel.init() #Initialise the wheel
	mywheel.start() #Start the wheels thread

	#centre the wheel at start of experiment
	mywheel.set_position(0) #Set the pd control target
	mywheel.control_on()
else:
	mywheel = None


##Code will be the threshold vs accumulator pop up bends experiment.

global driver, out, ExpID # global variable
driver = vizdriver.Driver()
ExpID = "BenLui17"

out = "-1"
# start empty world
###################  PERSPECTIVE CORRECT  ##################
###SET UP PHYSICAL DIMENSIONS OF SCREEN####
###################  PERSPECTIVE CORRECT  ##################
cave = myCave.initCave()
caveview = cave.getCaveView()


##Create array of trials.
global radiiPool,occlPool
#radiiPool = [50, 150, 250, 900, 1100, 1300, 2500, 3000, 3500, -1] #This was the selection used for Pilot.
radiiPool = [300, 600, 900, 1200, 1500, 1800, 2100, 2400, 2700, 3000, 3300, 3600,-1] #13 radii conditions. 300m steps.
occlPool = [0, .5, 1] #3 occlusion conditions

N = len(radiiPool) * len(occlPool) ###Number of conditions.
TRIALS = 10 #is this enough? Let's see.
TotalN = N*TRIALS
TRIALSEQ = range(1,N+1)*TRIALS
direc = [1,-1]*(TotalN/2)
TRIALSEQ = np.sort(TRIALSEQ)
TRIALSEQ_signed = np.array(direc)*np.array(TRIALSEQ)
random.shuffle(TRIALSEQ_signed)

# background color
viz.clearcolor(viz.SKYBLUE)

# ground texture setting
def setStage():
	
	global gplane1, gplane2	
	
	#CODE UP TILE-WORK WITH GROUNDPLANE.	
	##should set this up so it builds new tiles if you are reaching the boundary.
	fName = 'textures\strong_edge.bmp'
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

def runtrials():
	
	global trialtype, trialtype_signed, groundplane, radiiPool, out
	
	#yield viztask.waitTime(5.0) #allow me to get into the seat.
	
	setStage() # texture setting. #likely to have to be expanded.
	driver.reset() # initialization of driver
	[leftbends,rightbends] = BendMaker(radiiPool)
	viz.MainScene.visible(viz.ON,viz.WORLD)
	
	
	
	#add text to denote conditons.
	txtCondt = viz.addText("Condition",parent = viz.SCREEN)
	txtCondt.setPosition(.7,.2)
	txtCondt.fontSize(36)
	
	out = ""
	
	def updatePositionLabel():
		global driver, trialtype_signed, trialtype, gplane1, gplane2
		##WHAT DO I NEED TO SAVE?
		
		# get head position(x, y, z)
		pos = viz.get(viz.HEAD_POS)
		pos[1] = 0.0 # (x, 0, z)
		# get body orientation
		ori = viz.get(viz.BODY_ORI)
		steeringWheel = driver.getPos()
									
		#what data do we want? RoadVisibility Flag. SWA. Time, TrialType. x,z of that trial These can be reset in processing by subtracting the initial position and reorienting.
		SaveData(pos[0], pos[2], ori, steeringWheel) ##.
	
		if TILING:
		
			#check if groundplane is culled, and update it if it is. 
			if viz.MainWindow.isCulled(gplane1):
				#if it's not visible, move ahead 50m from the driver.
				
				print 'attempting to shift gplane1'
				#translate bend to driver position.
				driverpos = viz.MainView.getPosition()
				gplane1.setPosition(driverpos[0],0, driverpos[2],viz.ABS_GLOBAL) #bring to driver pos
				
				#now need to set orientation
				#driverEuler = viz.MainView.getEuler()
				gplane1.setEuler(driverEuler[0],0,0, viz.ABS_GLOBAL)		
				
				gplane1.setPosition(0,0, 30, viz.REL_LOCAL) #should match up to the tilesize * 3
				
				
				gplane1.setEuler(0,90,0, viz.REL_LOCAL) #rotate to ground plane	
				
			if viz.MainWindow.isCulled(gplane2):
				#if it's not visible, move ahead 50m from the driver.
				
				print 'attempting to shift gplane2'
				#translate bend to driver position.
				driverpos = viz.MainView.getPosition()
				gplane2.setPosition(driverpos[0],0, driverpos[2],viz.ABS_GLOBAL) #bring to driver pos
				
				#now need to set orientation
				#driverEuler = viz.MainView.getEuler()
				gplane2.setEuler(driverEuler[0],0,0, viz.ABS_GLOBAL)		
				
				gplane2.setPosition(0,0, 30, viz.REL_LOCAL) #should match up to the tilesize y size of the other tile.
				
				gplane2.setEuler(0,90,0, viz.REL_LOCAL) #rotate to ground plane	

	vizact.ontimer((1.0/60.0),updatePositionLabel)
	

	for j in range(0,TotalN):
		#import vizjoy		

		trialtype=abs(TRIALSEQ_signed[j])
		trialtype_signed = TRIALSEQ_signed[j]								
			
		txtDir = ""

		
		# Define a function that saves data
		def SaveData(pos_x, pos_z, ori, steer):
			global out
			
			#what data do we want? RoadVisibility Flag. SWA. Time, TrialType. x,z of that trial These can be reset in processing by subtracting the initial position and reorienting.
			#TODO: Change to Pandas Dataframe.
			if out != '-1':
				# Create the output string
				currTime = viz.tick()										
				out = out + str(float((currTime))) + '\t' + str(trialtype_signed) + '\t' + str(pos_x) + '\t' + str(pos_z)+ '\t' + str(ori)+  '\t' + str(steer) + '\t' + str(radius) + '\t' + str(occlusion) + '\t' + str(int(trialbend.getVisible())) + '\n'							
		
		radiipick = 1
		occlpick = 1
		L = len(radiiPool)
		L2 = L*2
		print trialtype, L, L2
		if trialtype > L and trialtype <= L2:
			print 'here'
			radiipick = trialtype-L #reset trialtype and occl index
			occlpick = 2				
		elif trialtype > L2:
			print 'here too'
			radiipick = trialtype - L2
			occlpick = 3
			
		print radiipick
			#pick correct object
		if trialtype_signed > 0: #right bend
			trialbend = rightbends[radiipick-1]
			txtDir = "R"
		else:
			trialbend = leftbends[radiipick-1]
			txtDir = "L"
				
		
		radius= radiiPool[radiipick-1]
		occlusion = occlPool[occlpick-1]
		if radius > 0: 
			msg = "Radius: " + str(radius) + txtDir + '_' + str(occlusion)
		else:
			msg = "Radius: Straight" + txtDir + '_' + str(occlusion)
		txtCondt.message(msg)				
		
		#translate bend to driver position.
		driverpos = viz.MainView.getPosition()
		print driverpos
		trialbend.setPosition(driverpos[0],0, driverpos[2])
				
		#now need to set orientation
		driverEuler = viz.MainView.getEuler()
		trialbend.setEuler(driverEuler, viz.ABS_GLOBAL)		
		
		#will need to save initial vertex for line origin, and Euler. Is there a nifty way to save the relative position to the road?
		driver.setSWA_invisible()		
		
		yield viztask.waitTime(occlusion) #wait an occlusion period
		
		trialbend.visible(1)
		
		yield viztask.waitTime(2.5-occlusion) #after the occlusion add the road again. 2.5s to avoid ceiling effects.
		
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
		
		driver.setSWA_visible()
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


viztask.schedule(runtrials())

