import json
import boto3
from datetime import datetime
from botocore.exceptions import ClientError

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('items-table')

def lambda_handler(event, context):
    if event.get('httpMethod') == 'GET' and event.get('path') == '/health':
        return {'statusCode': 200, 'body': json.dumps({'ok': True, 'ts': datetime.utcnow().isoformat() + 'Z'})}
    
    if event.get('httpMethod') == 'POST' and event.get('path') == '/items':
        try:
            body = json.loads(event.get('body', '{}'))
            item_id = body.get('id')
            message = body.get('message')
            if not item_id or not message:
                return {'statusCode': 400, 'body': json.dumps({'error': 'id and message required'})}
            
            table.put_item(
                Item={'id': item_id, 'message': message, 'created_at': datetime.utcnow().isoformat()},
                ConditionExpression='attribute_not_exists(id)'
            )
            return {'statusCode': 201, 'body': json.dumps({'saved': True})}
        
        except ClientError as e:
            if e.response['Error']['Code'] == 'ConditionalCheckFailedException':
                return {'statusCode': 200, 'body': json.dumps({'saved': False, 'reason': 'duplicate'})}
            return {'statusCode': 500, 'body': json.dumps({'error': str(e)})}
    
    return {'statusCode': 404, 'body': json.dumps({'error': 'Not found'})}
