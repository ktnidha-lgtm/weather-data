import json
import urllib.request
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('weatherdata')


API_KEY = "1803e3577ab987710efc114c1d73b224"
CITY = "Kochi"

def lambda_handler(event, context):
    url = f"https://api.openweathermap.org/data/2.5/weather?q={CITY}&appid={API_KEY}&units=metric"

    with urllib.request.urlopen(url) as response:
        data = json.loads(response.read().decode("utf-8"))

    item = {
        "id": CITY,
        "temperature": str(data["main"]["temp"]),
        "humidity": str(data["main"]["humidity"]),
        "weather": data["weather"][0]["main"]
    }

    table.put_item(Item=item)

    return {
        "statusCode": 200,
        "body": json.dumps("Weather data saved successfully")
    }
    
