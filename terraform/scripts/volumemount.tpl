#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
set -e

region=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
instanceid

abzone=$(curl -s 169.254.169.254/latest/meta-data/placement/availability-zone)
echo "abzone: " $abzone

instanceid=$(curl -s 169.254.169.254/latest/meta-data/placement/instance-id)
echo "instanceid: " $instanceid

aws --region `echo $region` ec2 attach-volume --volume-id ${cardanovolumeid} --instance-id `echo $instanceid` --device ${cardanodevicename}


