# we are extending everything from tomcat:8.0 image ...
FROM tomcat:8.0

MAINTAINER Anand Jain

#COPY path-to-your-application-war path-to-webapps-in-docker-tomcat

ADD http://127.0.0.1:8081/repository/nexus_repo/in/javahome/myweb/8.3.0/myweb-8.3.0.war /usr/local/tomcat/webapps/
