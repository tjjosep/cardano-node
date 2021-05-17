#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
set -e

sudo yum update -y
yum install jq -y
sudo yum install amazon-cloudwatch-agent -y
sudo yum install awslogs -y

cat > /etc/awslogs/awslogs.conf <<- EOF
[general]
state_file = /var/lib/awslogs/agent-state

[/var/log/messages]
file = /var/log/messages
log_group_name = ${loggroup}
log_stream_name = {instance_id}/${componentname}
datetime_format = %b %d %H:%M:%S
initial_position = start_of_file
EOF

region=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
sed -i -e "s/region = us-east-1/region = $region/g" /etc/awslogs/awscli.conf

sudo systemctl start awslogsd
sudo systemctl enable awslogsd.service
