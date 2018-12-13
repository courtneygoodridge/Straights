"""
Minimal Example to assess smooth translation

"""

import viz # vizard library

				
if __name__ == '__main__':

	viz.go()
	texfile = 'C:/VENLAB data/shared_modules/textures/calibmarker.png' #pixel size 137 x 137

	mytex = viz.add(viz.TEXQUAD,viz.SCREEN)
	mytex.texture(viz.add(texfile))	
	mytex.setPosition([.5,.5,0])
	mytex.setScale([2,2,2])		
