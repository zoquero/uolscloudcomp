# Lee un fichero de un S3 bucket a partir del evento de creación
# y lo copia transformado a otro bucket
import boto3

def lambda_handler(event, context):
    s3 = boto3.client('s3',
        aws_access_key_id='ASIA2XXXXXXXXXXXX5ZV',
        aws_secret_access_key='nbEXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXIxq',
        aws_session_token='FwoGXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXcTUdHI='
        )
    
    if event:
        file_obj = event["Records"][0]
        bucket_name = str(file_obj['s3']['bucket']['name'])
        dest_bucket_name = bucket_name + '-results'
        object_key = str(file_obj['s3']['object']['key'])
        new_object_key = 'PROCESSED_' + object_key 
        fileObj = s3.get_object(Bucket=bucket_name, Key=object_key)
        object_content = fileObj["Body"].read().decode('utf-8')
        replaced_object_content = object_content.replace('2', 'Z')
        s3.put_object(Body=replaced_object_content, Bucket=dest_bucket_name, Key=new_object_key)
    return {
        'statusCode': 200,
        'body': json.dumps('Objecto procesado por Lambda')
    }
