"""
Minimal Example to assess smooth translation

"""

import viz # vizard library
import viztask # vizard library
import vizshape
import vizact
import vizmat
from eyetrike_calibration_standard import Markers, run_calibration

import myCave
#import PPinput

def LoadCave():
	"""loads myCave and returns Caveview"""

	#set EH in myCave
	cave = myCave.initCave()
	caveview = cave.getCaveView()
	return (caveview)

# ground texture setting
def setStage():
	
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
	return(gplane1)

class Driver(viz.EventClass):
	def __init__(self, Cave):
		viz.EventClass.__init__(self)
				
		self.__speed = 8.0 #m./s				
		self.__view = Cave													

		self.callback(viz.TIMER_EVENT,self.UpdateView)
		self.starttimer(0,0,viz.FOREVER) #

	def UpdateView(self,num):
		elapsedTime = viz.elapsed()

#		print("Updating View:", viz.elapsed())

		dt = elapsedTime
		#dt = 1.0/60.0
								
		distance = self.__speed * dt
		posnew = (0,0,distance)
				
		self.__view.setPosition(posnew, viz.REL_LOCAL)

			
				
if __name__ == '__main__':

	
	gp = setStage() # build world
	caveview = LoadCave() # load perspective correct view.
	

	#driver = Driver(caveview)
	
	markers = Markers()
	
	print ("Texture Resolution:", markers.hm1.getBoundingBox())
	print ("Texture Scale:", markers.hm1.getScale())
		
	#vizact.ontimer(0, driver.UpdateView)	

