"""
Minimal Example to assess smooth translation

"""

import viz # vizard library

				
if __name__ == '__main__':

	#check emails for vizard support email. If you add the file to viz.ortho you can easily control the pixel size directly.
	
	viz.go()
	texfile = 'C:/VENLAB data/shared_modules/textures/calibmarker.png' #pixel size 137 x 137

	mytex = viz.add(viz.TEXQUAD,viz.SCREEN)
	mytex.texture(viz.add(texfile))	
	mytex.setPosition([.5,.5,0])
	mytex.setScale([4,4,0])		
		
	print ("Texture size:", mytex.getSize())
	print ("Texture Scale:", mytex.getScale())
	
	viz.window.setFullscreen(viz.ON)
	
	print ("Texture size_afterFullscreen:", mytex.getSize())	
	print ("Texture Scale_afterFullscreen:", mytex.getScale())
