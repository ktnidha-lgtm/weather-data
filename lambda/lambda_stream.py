import json
import boto3
import time

s3 = boto3.client('s3')

BUCKET_NAME = "weatherr-data-buckett"
def lambda_handler(event, context):

    data = {
        "city": "Kochi",
        "temperature": 30,
        "humidity": 75,
        "time": time.strftime("%Y-%m-%d %H:%M:%S")
    }
    file_name = f"weather-{int(time.time())}.json"

    s3.put_object(
        Bucket=BUCKET_NAME,
        Key=file_name,
        Body=json.dumps(data),
        ContentType="application/json"
        )

    return {
        "statusCode": 200,
        "body": json.dumps("File uploaded successfully")
    }

