import numpy as np
import argparse
import time
import cv2
import os
from bounding_box import bounding_box as bb
from flask import Flask, request, Response, jsonify
# import jsonpickle
import io as StringIO
import base64
from io import BytesIO
import io
# import json
from PIL import Image
import urllib.request
# construct the argument parse and parse the arguments

confthres = 0.55
nmsthres = 0.7


# read label in .names file
def readLabelFromFile(labelsDir):
    res = []
    with open(labelsDir) as f:
        for line in f:
            res.append(line[0:len(line)-1])
    return res

def generateColor(listLabel):
    color =['navy', 'blue', 'aqua', 'teal', 'olive',
     'green', 'lime', 'yellow', 'orange', 'red', 'maroon', 
     'fuchsia', 'purple', 'black', 'gray' ,'silver']
    res =[]
    for x in range(len(listLabel)):
        res.append(color[x%len(color)])
    return res
# Use opencv dnn  
def loadModel(cfgFile,weightsFile):
    netRead = cv2.dnn.readNetFromDarknet(cfgFile, weightsFile)
    return netRead

def get_prediction(image,net,LABELS,COLORS):

    (H, W) = image.shape[:2]
    ln = net.getLayerNames()
    ln = [ln[i[0] - 1] for i in net.getUnconnectedOutLayers()]
    blob = cv2.dnn.blobFromImage(image, 0.00392,(416,416),(0,0,0),True,crop=False)
    net.setInput(blob)
    start = time.time()
    layerOutputs = net.forward(ln)
    end = time.time()

    print("[INFO] YOLO took {:.6f} seconds".format(end - start))

    # initialize our lists of detected bounding boxes, confidences, and
    # class IDs, respectively
    boxes = []
    confidences = []
    classIDs = []
    # loop over each of the layer outputs
    for output in layerOutputs:
        # loop over each of the detections
        for detection in output:
            # extract the class ID and confidence (i.e., probability) of
            # the current object detection
            scores = detection[5:]
            classID = np.argmax(scores)
            confidence = scores[classID]

            # filter out weak predictions by ensuring the detected
            # probability is greater than the minimum probability
            if confidence > confthres:
                box = detection[0:4] * np.array([W, H, W, H])
                (centerX, centerY, width, height) = box.astype("int")
                x = int(centerX - (width / 2))
                y = int(centerY - (height / 2))

                # update our list of bounding box coordinates, confidences,
                # and class IDs
                boxes.append([x, y, int(width), int(height)])
                confidences.append(float(confidence))
                classIDs.append(classID)

    # apply non-maxima suppression to suppress weak, overlapping bounding
    # boxes

    idxs = cv2.dnn.NMSBoxes(boxes, confidences, confthres,
                            nmsthres)
    if len(idxs) > 0:
        # loop over the indexes we are keeping
        for i in idxs.flatten():
            # extract the bounding box coordinates
            (x, y) = (boxes[i][0], boxes[i][1])
            (w, h) = (boxes[i][2], boxes[i][3])

            text = "{}: {:.4f}".format(LABELS[classIDs[i]], confidences[i])
            bb.add(image,x,y,x+w,y+h,text,COLORS[classIDs[i]])
            # cv2.rectangle(image, (x, y) , (x + w, y + h), color, 2)
            # cv2.putText(image, text, (x, y ), cv2.FONT_HERSHEY_SIMPLEX,0.5, color, 2)

    listClassne =','.join([str(n) for n in classIDs])
    print((listClassne))
    return image, listClassne

Lables=readLabelFromFile("./coco.names")
Colors=generateColor(Lables)
nets=loadModel("./yolov3.cfg","./yolov3.weights")

###### My custom
custom_Lables=readLabelFromFile("./obj-2.names")
custom_Colors=generateColor(custom_Lables)
custom_nets=loadModel("./yolov3_bird.cfg","./yolov3_bird_21000.weights")

# Initialize the Flask application
app = Flask(__name__)

# route http posts to this method
@app.route('/detection', methods=['POST'])
def main():
    print('Detection')

    # load our input image and grab its spatial dimensions
    img = request.files["image"].read();
    img = Image.open(io.BytesIO(img))

    np_img=np.array(img)
    
    image=np_img.copy()
    image=cv2.cvtColor(image,cv2.COLOR_BGR2RGB)
    res, listIndex=get_prediction(image,nets,Lables,Colors)

    image=cv2.cvtColor(res,cv2.COLOR_BGR2RGB)
    np_img=Image.fromarray(image)
    buffered = BytesIO()
    np_img.save(buffered, format="JPEG")
    # img_str = base64.b64encode(buffered.getvalue())

    my_encoded_img = buffered.getvalue()
    response =Response(response=my_encoded_img, status=200,mimetype="image/jpeg")
    response.headers['connection']='keep-alive'
    response.headers["listIndex"]= listIndex
    print(response.headers)
    return response

@app.route('/detection/url', methods=['POST'])
def mainUrlDetection():
    # load our input image and grab its spatial dimensions
    # img = request.["image"].read();
    imgUrl= request.headers['Url']

    urllib.request.urlretrieve(imgUrl, "imgdetect")
    img = Image.open("imgdetect")

    np_img=np.array(img)

    image=np_img.copy()
    image=cv2.cvtColor(image,cv2.COLOR_BGR2RGB)
    res, listIndex=get_prediction(image,nets,Lables,Colors)

    image=cv2.cvtColor(res,cv2.COLOR_BGR2RGB)
    np_img=Image.fromarray(image)
    buffered = BytesIO()
    np_img.save(buffered, format="JPEG")
    # img_str = base64.b64encode(buffered.getvalue())
    
    my_encoded_img = buffered.getvalue()
    os.remove('imgdetect')
    response =Response(response=my_encoded_img, status=200,mimetype="image/jpeg")
    response.headers["listIndex"]= listIndex
    response.headers['connection']='keep-alive'
    return response

@app.route('/custom', methods=['POST'])
def main2():
    print('Custom')
    # load our input image and grab its spatial dimensions
    img = request.files["image"].read();
    img = Image.open(io.BytesIO(img))

    np_img=np.array(img)
    
    image=np_img.copy()
    image=cv2.cvtColor(image,cv2.COLOR_BGR2RGB)
    res, listIndex=get_prediction(image,custom_nets,custom_Lables,custom_Colors)

    image=cv2.cvtColor(res,cv2.COLOR_BGR2RGB)
    np_img=Image.fromarray(image)
    
    buffered = BytesIO()
    np_img.save(buffered, format="JPEG")

    my_encoded_img = buffered.getvalue()
    response =Response(response=my_encoded_img, status=200,mimetype="image/jpeg")
    response.headers['connection']='keep-alive'
    response.headers["listIndex"]=listIndex
    return response

@app.route('/custom/url', methods=['POST'])
def main2UrlDetection():
    print('Custom request url')

    imgUrl= request.headers['Url']

    urllib.request.urlretrieve(imgUrl, "imgdetect")

    img = Image.open("imgdetect")

    np_img=np.array(img)

    image=np_img.copy()
    image=cv2.cvtColor(image,cv2.COLOR_BGR2RGB)
    res, listIndex=get_prediction(image,custom_nets,custom_Lables,custom_Colors)

    image=cv2.cvtColor(res,cv2.COLOR_BGR2RGB)
    np_img=Image.fromarray(image)
    buffered = BytesIO()
    np_img.save(buffered, format="JPEG")
    # img_str = base64.b64encode(buffered.getvalue())
    
    my_encoded_img = buffered.getvalue()
    os.remove('imgdetect')
    response =Response(response=my_encoded_img, status=200,mimetype="image/jpeg")
    response.headers["listIndex"]= listIndex
    response.headers['connection']='keep-alive'
    return response

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0',port=8558)