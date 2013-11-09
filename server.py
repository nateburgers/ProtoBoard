import cv
import cv2
from SimpleCV import *
import pygame
import pybrain
from pybrain.tools.shortcuts import buildNetwork
from pybrain.supervised.trainers import BackpropTrainer
from pybrain.datasets import SupervisedDataSet
from pybrain.tools.xml.networkwriter import NetworkWriter
from pybrain.tools.xml.networkreader import NetworkReader
import itertools
import time
import pygame
import pybrain
import pickle
from pybrain.tools.shortcuts import buildNetwork
from pybrain.supervised.trainers import BackpropTrainer
from pybrain.datasets import SupervisedDataSet
from pybrain.tools.xml.networkwriter import NetworkWriter
from pybrain.tools.xml.networkreader import NetworkReader
import itertools
import time
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
	# print request.files
	# try:
	# 	r =  request.files['image']
	# except:
	# 	return "Failed to get image"
	# r.save('postimage.JPG')
	retrain = False
	BGIMAGE = 'xo4.JPG'
	if retrain:
		net = buildNetwork(4, 16, 2, bias=True)
	else:
		net = NetworkReader.readFrom('network.xml') 
	simplecvimg = Image(BGIMAGE).scale(600,600).rotate(270)
	# blue = simplecvimg.colorDistance((2,7,63)) * 2  #scale up
	
	blue = simplecvimg.colorDistance((20,32,170)) * 1.5  #scale up

	
	blueBlobs = blue.findBlobs()

	# cv.WaitKey(10000)
	# red = simplecvimg.colorDistance((62,5,13)) 
	red = simplecvimg.colorDistance((130,20,20))

	green = simplecvimg.colorDistance((140,190,40))

	l1 = DrawingLayer((simplecvimg.width, simplecvimg.height))

	# blueBlobs.show()
	big, second, = None, None
	maxx, twomaxx = 0,0

	for b in blueBlobs:
		if b.area() > maxx:
			twomaxx = maxx
			maxx = b.area()
			second = big
			big = b


	screen = second.crop().invert()
	screen = screen.crop(screen.width/2, screen.height/2, screen.width-50, screen.height-20, centered=True)
	screen.show()
	w = screen.width * 1.0
	h = screen.height * 1.0
	elements = screen.findBlobs()



	circles = [x for x in elements if x.isCircle(tolerance=0.7)]
	rectangles = [x for x in elements if x.isRectangle(tolerance=0.15)]
		
	circles = [x for x in circles if x not in rectangles]


	for b in circles:
		b.show(color=(255,0,0))
		print "Coordinates: " + str(b.x/w) + ", " + str(b.y/h)
		# cv.WaitKey(10)
	for b in rectangles:
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
				else:
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
			b.show(color=(0,0,255))
			if old[2] == 'rec':
				class1.append(old[1])
			else:
				class2.append(old[1])
			pass
		else:
			b.show(color=(0,255,255))
			if old[2] == 'rec':
				class3.append(old[1])
			else:
				class4.append(old[1])

		# print "Internal Shape Coordinates: " + str(b.x/w) + ", " + str(b.y/h)
		# cv.WaitKey(100)


	# while True:
	# 	cv.WaitKey(10)
	 
	
	print len(class1)
	print len(class2)
	print len(class3)
	print len(class4)
	class5 = set(circles) - set(class1 + class2 + class3 + class4)
	class6 = set(rectangles) - set(class1 + class2 + class3 + class4 + [x[0] for x in centers])
	print len(class5)
	print len(class6)


	classes = [class1,class2,class3,class4,class5,class6]
	for x in classes:
		x1 = [z.centroid() for z in x]
		x1 = [( z[0]/screen.width,z[1]/screen.height) for z in x1]
		classes[classes.index(x)] = x1

	retValues = {'entities': {"class"+str(classes.index(c)) : c for c in classes}}
	print retValues


	return jsonify(retValues)
def seg_intersect(a,b):
	a1 = Point(a[0],a[1])
	a2 = Point(a[2],a[3])
	b1 = Point(b[0],b[1])
	b2 = Point(b[2],b[3])
	return intersect(a1,a2,b1,b2)

def ccw(A,B,C):
    return (C.y-A.y) * (B.x-A.x) > (B.y-A.y) * (C.x-A.x)

# Return true if line segments AB and CD intersect
def intersect(A,B,C,D):
    return ccw(A,C,D) != ccw(B,C,D) and ccw(A,B,C) != ccw(A,B,D)
if __name__ == '__main__':
	# app.run(host='0.0.0.0',port=80)
	app.run(host='127.0.0.1',port=5000)

	# main()

	# 37 87 98
