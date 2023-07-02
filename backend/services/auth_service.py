# auth_service.py

from flask import jsonify
from google.oauth2 import id_token
from google.auth.transport import requests as grequest

CLIENT_ID = '66603309185-k7bccilod9b8pqfk87ngdssgv6ep1da8.apps.googleusercontent.com'

def exchange_code_service(code):
    try:
        server_auth_code = code

        # Verify the ID token
        idinfo = id_token.verify_oauth2_token(
            server_auth_code,
            grequest.Request(),
            CLIENT_ID
        )

        return idinfo, 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
