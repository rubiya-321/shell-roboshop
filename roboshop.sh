#!/bin/bash
AMI_ID="ami-0220d79f3f480ecf5"
SG_ID="sg-08215fd9bc2dcf991"

for instance in $@
do
    INSTANCE_ID=$( aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type "t3.micro" \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query 'Instances[0].InstanceId' \
    --output text )
echo "instance created"
done

