USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

SCRIPT_DIR=$PWD
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


dnf module disable nginx -y &>>LOGS_FILE
dnf module enable nginx:1.24 -y &>>LOGS_FILE
dnf install nginx -y &>>LOGS_FILE

VALIDATE $? "installing nginix"

systemctl enable nginx &>>LOGS_FILE
systemctl start nginx 

VALIDATE $? "enabling and starting nginix"

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "removing default content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>LOGS_FILE
VALIDATE $? "downloading the code"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>>LOGS_FILE
VALIDATE "unzipping the code"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "copying nginx file"

systemctl restart nginx 
VALIDATE $? "restart nginix"

