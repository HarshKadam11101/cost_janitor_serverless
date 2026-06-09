import boto3
import os

def lambda_handler(event,context):
    ec2 = boto3.client('ec2')
    sns = boto3.client('sns')

    SNS_TOPIC_ARN = os.environ.get('SNS_TOPIC_ARN')

    waste_report= []

    print("Scanning for unattached EBS volumes...")

    response_volumes = ec2.describe_volumes(
        Filters=[
            {
                'Name':'status',
                'Values':['available']
            }
        ]
    )
    for volume in response_volumes['Volumes']:
        vol_id = volume['VolumeId']
        size = volume['Sized']
        waste_report.append(f"Unattached Volume : {vol_id}({size})")

    response_eips = ec2.describe_addresses()

    for address in response_eips['Addresses']:
        if 'InstanceId' not in address:
            public_ip = address['PublicIp']
            waste_report.append(f"Idle Elastic IP:{public_ip}")

# Output

    if waste_report:
        alert_message = "AWS Cost Janitor found waste! \n\n"
        for item in waste_report:
            alert_message += f"- {item}\n"
        
        # 1. Write the log to CloudWatch
        print(alert_message)
        
        # 2. Send the email via SNS
        if SNS_TOPIC_ARN:
            sns.publish(
                TopicArn=SNS_TOPIC_ARN,
                Subject="AWS Cost Janitor Alert",
                Message=alert_message
            )
            print("Alert successfully routed to SNS.")
        else:
            print("Notice: No SNS_TOPIC_ARN found in environment. Skipping email alert.")
            
    else:
        success_msg = "Your AWS account is clean! No waste found."
        print(success_msg)

    return {"statusCode": 200, "body": waste_report}


if __name__ == "__main__":
    lambda_handler(None,None)