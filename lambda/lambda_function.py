import json
import urllib3
import boto3
import time
import os
from decimal import Decimal

http = urllib3.PoolManager()
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('new-weatherdata-table')

API_KEY = os.environ['API_KEY']
CITIES = ["Kochi", "Mumbai", "Delhi", "Bangalore", "Chennai"] 

def lambda_handler(event, context):
    for city in CITIES:
        url = f"https://api.openweathermap.org/data/2.5/weather?q={city}&appid={API_KEY}&units=metric"
        response = http.request('GET', url)
        data = json.loads(response.data.decode('utf-8'))

        item = {
            'city': city,
            'timestamp': int(time.time()),
            'temperature': Decimal(str(data['main']['temp'])),
            'humidity': Decimal(str(data['main']['humidity'])),
            'weather': data['weather'][0]['description'],
            'raw_data': json.dumps(data)
        }

        table.put_item(Item=item)
    
    return {'statusCode': 200, 'body': f'Data inserted for {len(CITIES)} cities'}
