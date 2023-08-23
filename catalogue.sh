#!/bin/bash

DATE=$(date +%f-%H-%M-%S)
script_name=$0
LOGFILE=/tmp/$script_name-$DATE.log

R="\e[31m"
G="\e[32m"
N="\e[0m"

USERID=$(id -u)

VALIDATE () {
if [ $1 -ne 0 ]
 then 
   echo -e  $R"$2 is  failure $N"
   exit 1
 else
   echo -e $G"$2 is  success $N"
 fi
}
if [ $USERID -ne 0 ]
then  
  echo "please check root access"
  exit 1
fi

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$LOGFILE

yum install nodejs -y &>>$LOGFILE

VALIDATE $? "NODEJS INSTALLED"

useradd roboshop &>>$LOGFILE

mkdir /app &>>$LOGFILE

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip  &>>$LOGFILE

cd /app &>>$LOGFILE

unzip /tmp/catalogue.zip &>>$LOGFILE

npm install &>>$LOGFILE

VALIDATE $? "NPM INSTALLED"

cp /home/centos/roboshop/catalogue.service /etc/systemd/system/catalogue.service &>>$LOGFILE

systemctl daemon-reload &>>$LOGFILE

systemctl enable catalogue &>>$LOGFILE

systemctl start catalogue &>>$LOGFILE

cp  /home/centos/roboshop/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE

yum install mongodb-org-shell -y &>>$LOGFILE

VALIDATE $? "MONGO CLIENT INSTALLED"

mongo --host mongodb.pracricedevops.online </app/schema/catalogue.js &>>$LOGFILE

VALIDATE $? "loading catalogue data into mongodb"