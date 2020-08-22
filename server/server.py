import numpy as np
import argparse
import cv2
import os
from bounding_box import bounding_box as bb
from flask import Flask, request, Response, jsonify
import io as StringIO
import base64
from io import BytesIO
import io
from PIL import Image
import urllib.request

CONFIDENCE = 0.6
NMS_THRES = 0.7

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
def loadNetAndLayerName(cfgFile,weightsFile):
    netRead = cv2.dnn.readNetFromDarknet(cfgFile, weightsFile)
    layerName = netRead.getLayerNames()
    layerName = [layerName[i[0] - 1] for i in netRead.getUnconnectedOutLayers()]
    return netRead, layerName

def predict(image,net,layer,label,default_colors):
    (imageHeight, imageWidth) = image.shape[:2]
    #Detect object
    blob = cv2.dnn.blobFromImage(image, 0.00392,(416,416),(0,0,0),True,crop=False)
    net.setInput(blob)
    layerOutputs = net.forward(layer)
    # Box dimensions
    boxes = []
    confidences = []
    classIDs = []
    for output in layerOutputs:
        for detection in output:
            scores = detection[5:]
            classID = np.argmax(scores)
            confidence = scores[classID]

            if confidence > CONFIDENCE:
                box = detection[0:4] * np.array([imageWidth, imageHeight, imageWidth, imageHeight])
                (centerX, centerY, width, height) = box.astype("int")
                #possible make value < 0
                x = int(centerX - (width / 2))
                y = int(centerY - (height / 2))
                print(x,y,width, height)
                if(y<0):
                    y=0
                if(x<0):
                    x=0
                boxes.append([x, y, int(width), int(height)])
                confidences.append(float(confidence))
                classIDs.append(classID)

    # Draw labels
    idxs = cv2.dnn.NMSBoxes(boxes, confidences, CONFIDENCE,NMS_THRES)
    
    if len(idxs) > 0:
        for i in idxs.flatten():
            (x, y) = (boxes[i][0], boxes[i][1])
            (w, h) = (boxes[i][2], boxes[i][3])
            text = "{}: {:.4f}".format(label[classIDs[i]], confidences[i])
            bb.add(image,x,y,x+w,y+h,text,default_colors[classIDs[i]])

    listClassne =','.join([str(n) for n in classIDs])
    print((listClassne))
    return image, listClassne

##### Call functions above
default_labels=readLabelFromFile("./coco.names")
default_colors=generateColor(default_labels)
default_nets,default_layer=loadNetAndLayerName("./yolov3.cfg","./yolov3.weights")

###### My custom model
custom_labels=readLabelFromFile("./bird_labels.txt")
custom_colors=generateColor(custom_labels)
custom_nets,custom_layer=loadNetAndLayerName("./yolov3_bird.cfg","./yolov3_bird_21000.weights")

def handle_image_and_predict(img,net,layer, labels,colors):
    np_img  =np.array(img)    
    image=np_img.copy()
    image=cv2.cvtColor(image,cv2.COLOR_BGR2RGB)
    res, listIndex=predict(image,net,layer,labels,colors)
    image=cv2.cvtColor(res,cv2.COLOR_BGR2RGB)
    np_img=Image.fromarray(image)
    buffered = BytesIO()
    np_img.save(buffered, format="JPEG")
    return buffered, listIndex

def create_response_from_image(img,net,layer,labels,colors):
    buffered, listIndex = handle_image_and_predict(img,net,layer,labels,colors)
    my_encoded_img = buffered.getvalue()
    response =Response(response=my_encoded_img, status=200,mimetype="image/jpeg")
    response.headers["listIndex"]= listIndex
    response.headers['connection']='keep-alive'
    return response


app = Flask(__name__)

@app.route('/detection', methods=['POST'])
def main():
    print('Detection')
    img = request.files["image"].read();
    img = Image.open(io.BytesIO(img))
    return create_response_from_image(img,default_nets,default_layer,default_labels,default_colors)
@app.route('/detection/url', methods=['POST'])
def mainUrlDetection():
    print('detection url')
    imgUrl= request.form.to_dict(flat=False)['url'][0]
    img = Image.open(urllib.request.urlopen(imgUrl))
    return create_response_from_image(img,default_nets,default_layer,default_labels,default_colors)

@app.route('/custom', methods=['POST'])
def main2():
    print('Custom')
    # Get file from post request
    img = request.files["image"].read();
    img = Image.open(io.BytesIO(img))
    # predict
    return create_response_from_image(img,custom_nets,custom_layer,custom_labels,custom_colors)

@app.route('/custom/url', methods=['POST'])
def main2UrlDetection():
    print('Custom request url')
    imgUrl= request.form.to_dict(flat=False)['url'][0]
    img = Image.open(urllib.request.urlopen(imgUrl))
    return create_response_from_image(img,custom_nets,custom_layer,custom_labels,custom_colors)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0',port=8558)