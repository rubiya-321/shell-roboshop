USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

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

dnf module disable redis -y $LOGS_FILE
VALIDATE $? "disableing redis"

dnf module enable redis:7 -y $LOGS_FILE
VALIDATE $? "enableing redis:7"

dnf install redis -y $LOGS_FILE
VALIDATE $? "installing redis"

sed -i -e "s/127.0.0.1/0.0.0.0/g" /etc/redis/redis.conf $LOGS_FILE
VALIDATE $? "allaowing remote connection"

sed -i -e "/protected-mode/ c protected-mode/no" /etc/redis/redis.conf
VALIDATE $? "changing protected mode from yes to no"

systemctl enable redis $LOGS_FILE
systemctl start redis $LOGS_FILE

VALIDATE $? "enabling and restating redis"
