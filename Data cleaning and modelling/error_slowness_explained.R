heading = seq(.1, pi/2, .01) #in radians
degrees = heading*180 / pi

#pi/2 is 90 degrees. 
plot(heading,degrees, xlab = "radians")

#when simulating an agent in a 2D space the x_change = sin(heading) * speed, the y_change = cos(heading) * speed.

plot(heading, sin(heading), xlab = "heading in radians") #you can see that our 0-90 degree (0-pi/2 radians) list asymptotes at 1.
#This means that at 90 degrees heading a person would be going full speed in the x direction. makes perfect sense.

#at more than 90 degrees it reverses until it's going full speed in the y direction (x_change = 0).
threesixty = seq(.1, pi*2, .1)
plot(threesixty, sin(threesixty), xlab = "heading in radians")

#These are the x coordinates of a circle. When you are simulating an agent you are picking a point on this circle then changing the radius (the radius = the speed)
plot(sin(threesixty), cos(threesixty))

#so, for our setup, let's pick 0-45 degrees.
heading = seq(.1, pi/4, .01)
ms = 10 # metres per second.

#let's plot the possible x,y coordinates after 1 second of travel.
plot(sin(heading) * ms, cos(heading) * ms)

#we know that under a constant threshold model, the RT = latency + (threshold / rate that error develops).
#To formulate that as a linear model the coefficient threshold needs to be multiplied by the error rate.
#2 / 4 = 2 * 1/4.
#So, we want it in the form of threshold * 1/error growth.

#By the plot you can see that large heading values get asymptotically small.
#This has a slightly weird interpretation. 
#The inverse of error growth is error slowness, or error decay, by 1 = infinitely slow or most decay (no error at all), and 0 meaning large errors (very quick).
#You may think of a better name...Approach rate is a poor description. I think that we used it in conversation once to refer to sin(heading)*speed with respect to road edges.
plot(heading, 1 / (sin(heading) * ms), xlab = "error slowness")
plot(heading, (sin(heading) * ms), xlab = "error growth")

#so, we would expect small values of error slowness to cause slower reaction times.
#When plotting you might want to take the inverse of error slowness (1/x) to return it to error growth, which has a neater interpretation.




