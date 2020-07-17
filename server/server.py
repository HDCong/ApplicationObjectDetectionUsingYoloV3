import numpy as np
import argparse
import time
import cv2
import os
from flask import Flask, request, Response, jsonify
import jsonpickle
#import binascii
import io as StringIO
import base64
from io import BytesIO
import io
import json
from PIL import Image

# construct the argument parse and parse the arguments

confthres = 0.7
nmsthres = 0.6
yolo_path = '.'

def get_labels(labels_path):
    lpath=os.path.sep.join([yolo_path, labels_path])
    LABELS = open(lpath).read().strip().split("\n")
    return LABELS

def get_colors(LABELS):
    np.random.seed(42)
    COLORS = np.random.randint(0, 255, size=(len(LABELS), 3),dtype="uint8")
    return COLORS

def get_weights(weights_path):
    weightsPath = os.path.sep.join([yolo_path, weights_path])
    return weightsPath

def get_config(config_path):
    configPath = os.path.sep.join([yolo_path, config_path])
    return configPath

def load_model(configpath,weightspath):
    print("[INFO] loading YOLO from disk...")
    net = cv2.dnn.readNetFromDarknet(configpath, weightspath)
    return net


def image_to_byte_array(image:Image):
  imgByteArr = io.BytesIO()
  image.save(imgByteArr, format='PNG')
  imgByteArr = imgByteArr.getvalue()
  return imgByteArr


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

            # draw a bounding box rectangle and label on the image
            color = [int(c) for c in COLORS[classIDs[i]]]
            cv2.rectangle(image, (x, y), (x + w, y + h), color, 2)
            text = "{}: {:.4f}".format(LABELS[classIDs[i]], confidences[i])
            print(text)
            fontScale = (w * h) / (W * H) # Would work best for almost square images
            thick=2
            print(W,H)
            print(w,h)
            if W< 1000 or H <1000:
                fontScale=1
                thick=1
            # 2000
            elif W< 2000 or H <2000:
                fontScale=3
                thick=3
            # 4000
            elif(H <3000 or W<3000):
                fontScale=5
                thick= 5
            else:
                fontScale=7
                thick=5
            # print(w)
            # print(h)
            cv2.putText(image, text, (x, y+int(h/2) ), cv2.FONT_HERSHEY_TRIPLEX,fontScale, color, thick)
    return image


labelsPath="coco.names"
cfgpath="yolov3.cfg"
wpath="yolov3.weights"
Lables=get_labels(labelsPath)
CFG=get_config(cfgpath)
Weights=get_weights(wpath)
nets=load_model(CFG,Weights)
Colors=get_colors(Lables)
# Initialize the Flask application
app = Flask(__name__)

# route http posts to this method
@app.route('/detection', methods=['POST'])
def main():

    # load our input image and grab its spatial dimensions
    img = request.files["image"].read();
    img = Image.open(io.BytesIO(img))

    np_img=np.array(img)
    
    image=np_img.copy()
    image=cv2.cvtColor(image,cv2.COLOR_BGR2RGB)
    res=get_prediction(image,nets,Lables,Colors)

    image=cv2.cvtColor(res,cv2.COLOR_BGR2RGB)
    np_img=Image.fromarray(image)
    # print(type(np_img))
    # img_encoded=image_to_byte_array(np_img)

    buffered = BytesIO()
    np_img.save(buffered, format="JPEG")
    # img_str = base64.b64encode(buffered.getvalue())
    
    my_encoded_img = buffered.getvalue()

    return Response(response=my_encoded_img, status=200,mimetype="image/jpeg")


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0',port=8558)