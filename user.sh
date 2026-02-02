#!/bin/bash
USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

SCRIPT_DIR="$PWD"
MONGODB_HOST="mongodb.rubiya88s.online"

if [ $USERID -ne 0 ]; then
    echo -e "$R Please run this script with root user access $N" | tee -a $LOGS_FILE
    exit 1
fi

mkdir -p $LOGS_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}
dnf module disable nodejs -y &>>$LOGS_FILE
dnf module enable nodejs:20 -y

VALIDATE $? "enabling nodejs"

dnf install nodejs -y &>>$LOGS_FILE
VALIDATE $? "installing node js"

id roboshop &>>$LOGS_FILE
if [$? -ne 0];then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    valiadte $? "sysytem user created"

  else
    echo -e "user alreated created.......$Y skipping $N"
fi

mkdir -p /app 
VALIDATE $? "craeting a directory"

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>$LOGS_FILE
VALIDATE $? "downloading the code"

rm -rf /app/*
VALIDATE $? "Removing existing code"

cd /app
VALIDATE $? "moving into app doirectory" 

unzip /tmp/user.zip &>>$LOGS_FILE
VALIDATE $? "unzip the code"

npm install  &>>$LOGS_FILE
VALIDATE $? "downloading the dependencies"

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service
VALIDATE $? "starting systemctl services"

systemctl daemon-reload
systemctl enable user &>>$LOGS_FILE
systemctl start user

VALIDATE $? "enabling and starting user"

