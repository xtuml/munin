#!/bin/bash

# This script launches a munin development EC2 instance on AWS.
# Prerequisites:
#   - Install `awscli`
#       * on Mac, `brew install awscli`
#       * on Linux/Windows, http://docs.aws.amazon.com/cli/latest/userguide/installing.html
#   - Run `aws configure`
#       * ensure that the output format is "json"
#       * http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html
#   - Put the PEM files for accessing AWS instances in ~/.aws
#   - Install `jq`
#       * on Mac, `brew install jq`
#       * on Linux, `sudo apt-get install jq`
#       * https://stedolan.github.io/jq/
#
# How to use this script:
#   - Replace the variables at the top of the script with values that fit your usage
#   - See usage information for descriptions of specific commands
#   - In order to launch builds on running instances, download the appropriate
#     keypair `pem` file and store it in your `.aws` directory.
#   - To log into a build service instnace with a GUI, use an RDP client
#       * Microsoft Remote Desktop 10 for Mac works well

NAME=myname                         # name to prepend for tagging the instance

AMI_REGION=us-east-1                # Virginia
AMI_ID=ami-05e0abce17b3ccb4d        # us-east AMI name PV benchmarking 5
SG_ID=sg-017c46e14320a0f5d          # us-east security group name "Remote Access"
KEY_PAIR=pvlinuxtest                # keypair for logging in with ssh to us-east

INST_TYPE=t3.xlarge                 # instance type to launch
INST_FILE=running_instance.json     # local file to store the instance data
KEY_LOC=~/.aws                      # location of private keypair storage

function usage() {
    echo "Usage:"
    echo "    # Launch a new munin linux EC2 instance with personal name"
    echo "    ./munin-ec2.sh start dave"
    echo
    echo "    # Stop an existing instance"
    echo "    ./aws-server.sh stop"
    echo
    echo "    # Terminate an existing instance"
    echo "    ./aws-server.sh terminate"
    echo
    echo "    # Log in to the remote linux instance"
    echo "    ./aws-server.sh login"
    echo
    exit 1
}

# Parse command line arguments
COMMAND=
INST_ID=
case $1 in
    "-h"|"--help")
        usage
        ;;
    "start"|"stop"|"terminate"|"login")
        if [[ "" == "$COMMAND" ]]; then
            COMMAND=$1
        else
            usage
        fi
        ;;
    *)
        usage
        ;;
esac

# Handle start command
if [[ "start" == $COMMAND ]]; then

    if [[ "" == "$2" ]]; then
        usage
    else
        NAME=$2
    fi
    echo "Starting munin linux EC2 instance..."
    INST_ID=$(aws ec2 run-instances \
        --region $AMI_REGION \
        --image-id $AMI_ID \
        --security-group-id $SG_ID \
        --count 1 \
        --instance-type $INST_TYPE \
        --key-name $KEY_PAIR \
        | jq -r '.Instances | .[0] | .InstanceId')

    echo "Tagging instance..."
    aws ec2 create-tags --region $AMI_REGION --resources $INST_ID --tags Key=Name,Value=$NAME`date +%s`

    aws ec2 describe-instances --region $AMI_REGION --instance-ids $INST_ID | jq '.Reservations | .[0] | .Instances | .[0]' > $INST_FILE
    INST_IP=$(cat $INST_FILE | jq -r '.PublicIpAddress')
    echo "Instance IP: $INST_IP"
    echo "ssh -i ~/.aws/pvlinuxtest.pem ubuntu@"$INST_IP

# Handle stop command
elif [[ "stop" == $COMMAND ]]; then

    stat $INST_FILE &> /dev/null
    if [[ 0 != $? ]]; then
        echo "Instance file does not exist."
        exit 1
    fi
    INST_ID=$(cat $INST_FILE | jq -r '.InstanceId')
    aws ec2 stop-instances --region $AMI_REGION --instance-ids $INST_ID > /dev/null
    aws ec2 describe-instances --region $AMI_REGION --instance-ids $INST_ID | jq '.Reservations | .[0] | .Instances | .[0]' > $INST_FILE

# Handle terminate command
elif [[ "terminate" == $COMMAND ]]; then

    stat $INST_FILE &> /dev/null
    if [[ 0 != $? ]]; then
        echo "Instance file does not exist."
        exit 1
    fi
    INST_ID=$(cat $INST_FILE | jq -r '.InstanceId')
    aws ec2 create-tags --region $AMI_REGION --resources $INST_ID --tags Key=Name,Value=dead
    aws ec2 terminate-instances --region $AMI_REGION --instance-ids $INST_ID > /dev/null
    rm -f $INST_FILE

# Handle login command
elif [[ "login" == $COMMAND ]]; then

    stat $INST_FILE &> /dev/null
    if [[ 0 != $? ]]; then
        echo "Instance file does not exist."
        exit 1
    fi
    INST_IP=$(cat $INST_FILE | jq -r '.PublicIpAddress')
    ssh -i $KEY_LOC/$KEY_PAIR.pem ubuntu@$INST_IP

else
    usage
fi
