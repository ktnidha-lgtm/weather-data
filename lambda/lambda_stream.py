import json
import boto3
import time

s3 = boto3.client('s3')
BUCKET = "new-weatherdata-bucket"

def lambda_handler(event, context):
    for record in event['Records']:
        if record['eventName'] == 'INSERT':
            new_image = record['dynamodb']['NewImage']
            data = {
                'city': new_image['city']['S'],
                'timestamp': new_image['timestamp']['N'],
                'temperature': new_image['temperature']['N'],
                'humidity': new_image['humidity']['N'],
                'weather': new_image['weather']['S']
            }
            key = f"weather-data/{data['city']}_{int(time.time())}.json"
            s3.put_object(
                Bucket=BUCKET,
                Key=key,
                Body=json.dumps(data),
                ContentType='application/json'
            )
    return {'statusCode': 200}
