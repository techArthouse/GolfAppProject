# auth_controller.py

from flask import Blueprint, jsonify, request
from services.auth_service import exchange_code_service
from models import User, Player
from db import get_db_session

auth_controller = Blueprint('auth_controller', __name__)

@auth_controller.route('/exchange', methods=['POST'])
def exchange_code():
    try:
        server_auth_code = request.json['code']
        idinfo, status = exchange_code_service(server_auth_code)

        # Extract user information from the ID token
        sub = idinfo['sub']
        email = idinfo['email']

        session = get_db_session()

        # Check if the user already exists in the database
        user = session.query(User).filter_by(sub=sub).first()

        if user is None:
            # User doesn't exist, create a new user record
            user = User(sub=sub, email=email)
            session.add(user)
            session.commit()

            # Create a new player for the user with a handicap of 0
            player = Player(player_name=email, handicap=0)
            player.user = user  # Assign the user to the player
            session.add(player)
            session.commit()

        # Retrieve the player associated with the user
        player = session.query(Player).filter_by(user_id=user.user_id).first()

        if player is None:
            return jsonify({'error': 'Player not found'}), 404

        # Return a success response with player_id included
        return jsonify({'message': 'Code exchange successful', 'error': '', 'player_id': player.player_id, 'host_id': player.player_id})

    except ValueError as e:
        return jsonify({'message': '', 'error': str(e)}), 400
    except Exception as e:
        return jsonify({'message': '', 'error': str(e)}), 500


# this process now needs to account for an email existing in the invite list