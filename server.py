from SimpleCV import *
import pygame
import pybrain
from pybrain.tools.shortcuts import buildNetwork
from pybrain.supervised.trainers import BackpropTrainer
from pybrain.datasets import SupervisedDataSet
from pybrain.tools.xml.networkwriter import NetworkWriter
from pybrain.tools.xml.networkreader import NetworkReader
import sys
import pickle
from pybrain.tools.shortcuts import buildNetwork
from flask import Flask, request, session, g, redirect, url_for, \
	 abort, render_template, flash, jsonify


DEBUG = True
SECRET_KEY = 'development key'
USERNAME = 'admin'
PASSWORD = 'default'
app = Flask(__name__)
app.config.from_object(__name__)

app.config.from_envvar('FLASKR_SETTINGS', silent=True)

keymap = {}
allLines = []
g = []
mac = sys.platform == "darwin"
class Point(object):
	'''Creates a point on a coordinate plane with values x and y.'''

	COUNT = 0

	def __init__(self, x, y):
		'''Defines x and y variables'''
		self.x = x
		self.y = y
@app.route('/test')
def test():
	return "Testing 123"
@app.route('/', methods = ['GET','POST'])
def main():
	
	try:
		r =  request.files['image']
		r.save('postimage.JPG')

	except:
		pass
	retrain = False
	if sys.platform != "darwin":
		BGIMAGE = 'postimage.JPG'
	else:
		BGIMAGE = 'color4.JPG'

	if retrain:
		net = buildNetwork(4, 16, 2, bias=True)
	else:
		net = NetworkReader.readFrom('network.xml') 
	simplecvimg = Image(BGIMAGE).scale(600,600).rotate(270)
	# blue = simplecvimg.colorDistance((2,7,63)) * 2  #scale up
	
	blue = simplecvimg.colorDistance((20,32,170)) * 1.5  #scale up
	red = simplecvimg.colorDistance((255,0,0)) * 2

	blueBlobs = blue.findBlobs()

	l1 = DrawingLayer((simplecvimg.width, simplecvimg.height))

	# blueBlobs.show()
	# cv.WaitKey(1000)
	big, second, = None, None
	maxx, twomaxx = 0,0

	for b in blueBlobs:
		if b.area() > maxx:
			twomaxx = maxx
			maxx = b.area()
			second = big
			big = b

	screen = second.crop().invert()
	print big.minRect()
	print red
	# cv.WaitKey(10000)
	# red = simplecvimg.colorDistance((62,5,13)) 

	# green = simplecvimg.colorDistance((140,190,40))
	# red.show()
	# cv.WaitKey(5000)
	screen = screen.crop(screen.width/2, screen.height/2, screen.width-50, screen.height-20, centered=True)
	if mac:
		screen.show()
	screen.save("cropped.png")
	w = screen.width * 1.0
	h = screen.height * 1.0
	elements = screen.findBlobs()


	if elements == None:
		return jsonify({"Error": "No elements"})
	circles = [x for x in elements if x.isCircle(tolerance=0.65)]
	rectangles = [x for x in elements if x.isRectangle(tolerance=0.15)]
		
	circles = [x for x in circles if x not in rectangles]


	for b in circles:
		if mac:
			b.show(color=(255,0,0))
		print "Coordinates: " + str(b.x/w) + ", " + str(b.y/h)
		# cv.WaitKey(10)
	for b in rectangles:
		if mac:
			b.show(color=(0,255,0))
		print "Coordinates: " + str(b.x/w) + ", " + str(b.y/h)
		# cv.WaitKey(10)
	centers = []
	for x in rectangles + circles:
		cr = circles + rectangles
		cr.remove(x)
		for y in cr:
			c1 = x.centroid()
			h = x.minRectHeight()
			w = x.minRectWidth()
			c2 = y.centroid()
			if c2[0] < (c1[0] + w) and c2[0] >(c1[0] - w)  and c2[1] < (c1[1] + h)  and c2[1] > (c1[1] - h)  and y.area() < x.area():
				# x.show(color=(200,100,200))
				# y.show(color=(50,50,255))
				if x in rectangles:
					centers.append([y,x,'rec'])
				else:
					centers.append([y,x,'cir'])
				if x in circles:
					circles.remove(x)
				elif x in rectangles:
					rectangles.remove(x)

	# cv.WaitKey(10000)
	# centers = list((set(circles + rectangles)) - set(centers))
	allFeatures = []
	if retrain:
		ds = SupervisedDataSet(4, 2)
		for b in centers:
			old = b
			b = b[0]
			features = []
			print b.width
			i = b.blobImage().binarize()
			if mac:
				b.blobImage().show()
			i1 = raw_input()
			if i1 == "0":
				end = [0,1]
			else:
				end = [1,0]
			print end
			for x in range(0,2):
				for y in range(0,2):
					print i.width*x,i.width * (x+1),i.height*y,i.height * (y+1)
					z = i.crop((i.width/2) * x, (i.height/2) * y, i.width/2, i.height/2, centered=True)
					features.append(z.meanColor())
			features = [x[0] for x in features]
			allFeatures.append(features)
			ds.addSample(features,end)
		
		trainer  = BackpropTrainer(net, ds)
		t = 10
		while t > .01:
			t = trainer.train()
			print t
		NetworkWriter.writeToFile(net, 'network.xml')
	class1, class2, class3, class4 = [],[],[],[]
	circles = [x for x in circles if x not in [y[0] for y in centers]]
	for b in centers:
		old = b
		b = b[0]
		features = []

		i = b.blobImage().binarize()
		
		for x in range(0,2):
			for y in range(0,2):
				z = i.crop((i.width/2) * x, (i.height/2) * y, i.width/2, i.height/2, centered=True)
				features.append(z.meanColor())
		features = [x[0] for x in features]
		
		v = net.activate(features)
		print v
		if v[0] > v[1]:
			if mac:
				b.show(color=(0,0,255))
			if old[2] == 'rec':
				class1.append(old[1])
			else:
				class2.append(old[1])
			pass
		else:
			if mac:
				b.show(color=(0,255,255))
			if old[2] == 'rec':
				class3.append(old[1])
			else:
				class4.append(old[1])

		# print "Internal Shape Coordinates: " + str(b.x/w) + ", " + str(b.y/h)
		# cv.WaitKey(100)


	# while True:
	# 	cv.WaitKey(10)
	 
	class3 = list(set(class3) - set(class1 + class2  +[x[0] for x in centers]))

	class4 = list(set(class4) - set(class1 + class2 + class3 +[x[0] for x in centers]))

	class5 = set(circles) - set(class1 + class2 + class3 + class4 + [x[0] for x in centers])
	class6 = set(rectangles) - set(class1 + class2 + class3 + class4 + [x[0] for x in centers])


	classes = [class1,class2,class3,class4,class5,class6]
	for x in classes:
		x1 = [(z.centroid(), z.width()/float(screen.width),z.height()/float(screen.height)) for z in x]
		x1 = [(z[0][0]/screen.width,z[0][1]/screen.height, z[1],z[2]) for z in x1]
		classes[classes.index(x)] = x1

	classes = [list(set(x)) for x in classes]

	for c in classes:
		print len(c)

	retValues = {'entities': {"class"+str(classes.index(c)) : c for c in classes}}
	print retValues

	# while True:
	# 	cv.WaitKey(10)
	return None
	return jsonify(retValues)

# Return true if line segments AB and CD intersect
def intersect(A,B,C,D):
    return ccw(A,C,D) != ccw(B,C,D) and ccw(A,B,C) != ccw(A,B,D)
if __name__ == '__main__':
	if sys.platform != "darwin":
		app.run(host='0.0.0.0', debug=True, port=80)
	else:
		#app.run(host='127.0.0.1',port=5000, debug=True)
		main()

