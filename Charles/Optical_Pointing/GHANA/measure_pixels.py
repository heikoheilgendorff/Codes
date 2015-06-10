# This code reads in the png image


import matplotlib.pyplot as plt
import matplotlib.image as mpimg
import numpy as nm

# read in image:
img = mpimg.imread( '2015-03-30-225343.png' )

# find centre:
dim_y = nm.shape(img)[0]
dim_x = nm.shape(img)[1]
cent_y = dim_y/2.
cent_x = dim_x/2.

# find peak:
peak = nm.amax(img)
peak_y,peak_x,z = nm.unravel_index(img.argmax(), img.shape)

# find difference:
diff_x = cent_x - peak_x
diff_y = cent_y - peak_y

'''
print "For x:"
print "cent_x: ",cent_x
print "peak_x: ",peak_x
print "diff_x: ", diff_x

print "For y:"
print "cent_y: ",cent_y
print "peak_y: ",peak_y
print "diff_y: ",diff_y
'''

#convert difference from pixels to degrees:
y_deg = 3.9 # size of y in degrees
y_pix = y_deg/dim_y # size of y_pixel in degrees
diff_y_deg = y_pix*diff_y # difference in elevation in degrees

x_deg = 5.2
x_pix = x_deg/dim_x
diff_x_deg = x_pix*diff_x # difference in azimuth in degrees

print "Move el (degrees):"
print diff_y_deg
print "Move az (degrees):"
print diff_x_deg

plt.imshow(img)
plt.show()


