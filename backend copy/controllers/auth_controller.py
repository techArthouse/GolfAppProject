from flask import Blueprint, request, jsonify
from backend.services import exchange_code

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/exchange', methods=['POST'])
def post_exchange_code():
    server_auth_code = request.json['code']
    response = exchange_code(server_auth_code)
    return response
