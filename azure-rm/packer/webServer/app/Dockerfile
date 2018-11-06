#########################################################
#Dockerfile allows app.py (which is a web application
#deployed on a web server) to be run in a Docker container
#########################################################

#########################################################
#ubuntu is the repo and latest is the tag which helps 
#label the image from the docker container
#########################################################
FROM ubuntu:latest

#########################################################
#identifies the author of the container
#########################################################
MAINTAINER general "general@pgn.com"

#########################################################
#updates all applications that may be used by the 
#application in order to get the newest versions before 
#running the web server
#########################################################
RUN apt-get update -y

#########################################################
#installs python which will be used to run the application
#on the web server
#########################################################
RUN apt-get install -y python-pip python-dev build-essential

#########################################################
#copies all files needed to run the application into a 
#directory called 'app' to have a consistently named woring directory
#########################################################
COPY . /app

#########################################################
#sets the working directory as the newly created directory: 
#'app'...this helps verify all of the documents needed are 
#in the same directory
#########################################################
WORKDIR /app

#########################################################
#runs the requirements.txt file...text file includes all 
#versions and applications needed for the application to 
#run successfully (right now it only includes flask)
#########################################################
RUN pip install -r requirements.txt

#########################################################
#first part of the command that will be run to start 
#application within docker container...this app is run with python
#########################################################
ENTRYPOINT ["python"]

#########################################################
#second part of the command that will be run to start 
#application within docker container...this is the actual 
#file that controls the web application
#########################################################
CMD ["app.py"] 
