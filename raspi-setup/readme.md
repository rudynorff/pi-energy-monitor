# MQTT on Raspberry Pi

In order to understand the current energy use we will run mosquitto (an MQTT broker) on a Pi. The MQTT broker will receive published messages by 2 clients: 

1. the energy meter (using the Volkszähler)
2. a Shelly 1PM that is used to measure the power input from the photovoltaics system

The published messages will then be sent to the subscribers, incl. the mqtt-exporter that can be found in the /mqtt-exporter directory of this project. The mqtt-exporter simply takes all logged messages with the topics "solar" and "grid" and sends them to a web service for further processing. 

In my case the web service is an AWS Lambda function that processes the data (every x minutes) and plots charts of the current hour, day, month, etc. puts it into an HTML and stores it on an AWS S3 bucket so that it can be viewed in a browser. The project for this can be found in /lambda-graph-plotter

## Installation

Set up the Raspberry Pi (preferrably V3 as it consumed the least amount of power) with a Lite/headless Raspbian. 