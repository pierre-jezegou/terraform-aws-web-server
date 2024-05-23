import boto3

REGION_NAME = 'us-east-1'

ec2 = boto3.client('ec2', region_name=REGION_NAME)
vpc_id = ec2.describe_vpcs().get('Vpcs', [{}])[0].get('VpcId', '')

subnets = [instance['SubnetId']
           for instance
           in ec2.describe_subnets().get('Subnets', [{}])
           if instance['VpcId'] == vpc_id ]

print(vpc_id)
print(subnets)
