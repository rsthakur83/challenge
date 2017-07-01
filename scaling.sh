#!/bin/bash

vpcid="vpc-4ec86637"

asg1=`sudo aws autoscaling describe-launch-configurations --region us-east-1|grep LaunchConfigurationName|awk '{print $2}'|cut -c 2-19`
fis="fis"
sec="sec"
sub1=`sudo aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpcid"|grep "SubnetId"|awk '{print $2}'|cut -c 2-16|tail -1`
sub2=`sudo aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpcid"|grep "SubnetId"|awk '{print $2}'|cut -c 2-16|head -1`

echo "ASG 2 $asg1"
lcfg1="machine-factory-v1"
lcfg2="machine-factory-v2"

if [ "$asg1" == "$lcfg1" ]
then
rm -rf $fis/terraform.*;cp userdata.sh $fis;cd $fis;sudo terraform plan;sudo terraform apply
sleep 120
aws autoscaling attach-load-balancers --auto-scaling-group-name machine-factory-v2 --load-balancer-names web-elb
sleep 10
aws autoscaling detach-load-balancers --auto-scaling-group-name machine-factory-v1 --load-balancer-names web-elb
sleep 10
sudo aws autoscaling delete-launch-configuration --launch-configuration-name $lcfg1
sleep 20
aws autoscaling delete-auto-scaling-group --auto-scaling-group-name  machine-factory-v1


else
 rm -rf $fis/terraform.*;cp userdata.sh $sec;cd $sec;sudo terraform plan;sudo terraform apply
 sleep 120

aws autoscaling attach-load-balancers --auto-scaling-group-name machine-factory-v1 --load-balancer-names web-elb
sleep 10
aws autoscaling detach-load-balancers --auto-scaling-group-name machine-factory-v2 --load-balancer-names web-elb
sleep 10
sudo aws autoscaling delete-launch-configuration --launch-configuration-name $lcfg2
sleep 20
aws autoscaling delete-auto-scaling-group --auto-scaling-group-name  machine-factory-v2


fi
