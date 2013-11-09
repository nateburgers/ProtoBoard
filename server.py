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

BGIMAGE = 'board6.JPG'
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
	print "DATA"
	# print request.files
	# try:
	# 	r =  request.files['image']
	# except:
	# 	return "Failed to get image"
	# r.save('postimage.JPG')
	BGIMAGE = 'img.JPG'
	
	# return "ASD\n"
	xSpeed = 0
	ySpeed = 0
	simplecvimg = Image(BGIMAGE).scale(600,600).rotate(270)
	train = False
	# blue = simplecvimg.colorDistance((2,7,63)) * 2  #scale up
	
	blue = simplecvimg.colorDistance((20,32,170)) * 1.6  #scale up

	blueBlobs = blue.findLines()

	# blue.show()
	# cv.WaitKey(10000)
	# red = simplecvimg.colorDistance((62,5,13)) 
	red = simplecvimg.colorDistance((130,20,20))

	green = simplecvimg.colorDistance((140,190,40))

	# l1 = DrawingLayer((simplecvimg.width, simplecvimg.height))

	blueBlobs.show()

	# maxBlob.show()
	while True:
		cv.WaitKey(10)
	return 
	redBlobs = (simplecvimg - red).findBlobs(minsize=200)
	blueLine = (simplecvimg - blue).findBlobs()
	greenBlobs = (simplecvimg - green).findBlobs()

	simplecvimg.addDrawingLayer(l1)
	simplecvimg.applyLayers()

	return 
	if redBlobs != None:
		for r in redBlobs:
			#check for location and shape and size if necessary
			#end point!
			endSet = False
			if r.isCircle(tolerance=.5):
				print "Circle"
			else:	
				endSet = True
				print "GOT END"
				endPoint = r.centroid()
				endh = r.minRectHeight()
				endw = r.minRectWidth()
				endx = r.minRectX()
				endy = r.minRectY()
		if endSet == False:
			endh = -1
			endw = -1
			endx = -1
			endy = -1
		print "RED BLOBS FOUND"
		for r in redBlobs:

			print "Loc: " + str(r.centroid()) + " Area: " + str(r.area())
			rh = r.minRectHeight()/2
			rw = r.minRectWidth()/2
			x = r.minRectX()
			y = r.minRectY()
			print x,y
			edge = (int(round(x,0)),int(round(y,0)))
			l1.circle(edge, 10)
			x, y = edge
			newI = simplecvimg.crop(x-rw,y-rh,rw*2,rh*2)
			# l1.rectangle(x-(rw/2),y-(rh/2),color=Color.GREEN)
			black = newI.colorDistance((255,255,255)) * 6
			# if train:
			# 	f = open('training.txt', 'a')

			# for x in range(4):
			# 	for y in range(4):
			# 		l = black.width/4
			# 		h = black.height/4
			# 		n = black.crop(l*x,l*y,l,h)
			# 		#up down left right
			# 		n.show()
			# 		z = list(n.meanColor())
			# 		if train:
			# 			f.write(str(z)+':1,0,0,0\n')

			# 		cv.WaitKey(100)

			if train:
				f.close()
			# black.show() 
			# for x in range(1000):
			# 	cv.WaitKey(10)

			#lets find an arrow  

	if blueLine != None:
		blueLine[0].drawOutline(layer=l1,color=(255,0,0),width=3,alpha=128)

		# blue = blueLine[0].blobMask()
	lines = []
	for blueBlob in blueLine:
		c = blueBlob.contour()
		
		# d = blue.fitContour(c)
		startPoint = (1000,10000)
		for x in c:
			if x[0] < startPoint[0]:
				startPoint = x
		end = (-10,-10)
		for x in c:
			if x[0] > end[0]:
				end = x
		print end



		importantPoints = [startPoint]
		for point in c:
			y_delta = point[1]-importantPoints[-1][1]
			if point[0] > importantPoints[-1][0] and (y_delta > 10 or y_delta<-10):
				importantPoints.append(point)
		importantPoints.append(end)
		past = importantPoints[0]
		curLines = []
		for p in importantPoints:
			l1.circle(p,10)
			curLines.append((past[0],past[1], p[0],p[1]))
			past = p
		allLines.append(curLines)
		lines.append(importantPoints)

	blue.addDrawingLayer(l1)
	blue.applyLayers()
	# blue.show()
	# for x in range(500):
	# 	cv.WaitKey(10)

	# 	cv.WaitKey(10)
	for x in greenBlobs:
		g.append(x.centroid())
	total = []
	for l in allLines:
		past = l[0]
		for x in l[1:]:
			total.append((past[:2],x[2:]))
			past = x


	print total



	print '\n\n\n'
	retValues = {'obstacles': {'lines': total,'dudes':[{'dudex':x[0],'dudey':x[1]} for x in g],'end':{'x':endx,'y':endy,'height':endh,'width':endy}}}
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
	# app.run(host='127.0.0.1',port=5000)

	main()

	# 37 87 98
