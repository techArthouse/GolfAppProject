from backend.models import exchange_code

def execute_code_exchange(server_auth_code):
    return exchange_code(server_auth_code)
