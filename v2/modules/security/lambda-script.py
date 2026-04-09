import json
import base64
import gzip
import boto3
import os

# Initialize the SNS client
sns = boto3.client('sns')
TOPIC_ARN = os.environ['SNS_TOPIC_ARN']

def lambda_handler(event, context):
    # CloudWatch sends logs base64 encoded and compressed
    cw_data = event['awslogs']['data']
    compressed_payload = base64.b64decode(cw_data)
    uncompressed_payload = gzip.decompress(compressed_payload)
    payload = json.loads(uncompressed_payload)

    # Loop through the log events
    for log_event in payload.get('logEvents', []):
        try:
            waf_log = json.loads(log_event['message'])
            
            # Extract the offending IP address
            client_ip = waf_log.get('httpRequest', {}).get('clientIp', 'Unknown IP')
            
            # Format the email message
            message = (
                f"🚨 SOAR Alert: Spammer Blocked\n"
                f"----------------------------------\n"
                f"IP Address: {client_ip}\n"
                f"Rule Triggered: Rate Limit Exceeded\n"
                f"Action Taken: Traffic Dropped"
            )

            # Send the email via SNS
            sns.publish(
                TopicArn=TOPIC_ARN,
                Message=message,
                Subject="⚠️ WAF Spam Alert"
            )
            print(f"Alert sent for IP: {client_ip}")

        except Exception as e:
            print(f"Error parsing log: {e}")