import dotenv
import os
import boto3
import json
from botocore.exceptions import ClientError

def get_secret():
    secret_name = "cloneme/secrets"
    region_name = "us-east-1"

    # Create a Secrets Manager client
    session = boto3.session.Session(profile_name='clone-me-bbd')
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    try:
        get_secret_value_response = client.get_secret_value(SecretId=secret_name)
    except ClientError as e:
        # For a list of exceptions thrown, see
        # https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
        raise e

    secret = get_secret_value_response['SecretString']
    return json.loads(secret)

def set_secret():
    dotenv_file = dotenv.find_dotenv('.env')
    secret = get_secret() 
    for key in secret:
        value = secret[key]
        dotenv.set_key(dotenv_file, key, value)

set_secret();