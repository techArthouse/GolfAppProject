# app.py
import os
import sys
from controllers import game_bp, player_bp, round_bp, course_bp, auth_controller
from db import get_db_session
from flask import Flask

app = Flask(__name__)

app.register_blueprint(game_bp)
app.register_blueprint(player_bp)
app.register_blueprint(round_bp)
app.register_blueprint(course_bp)
app.register_blueprint(auth_controller)

@app.teardown_appcontext
def cleanup(resp_or_exc):
    print('Teardown received')
    get_db_session().close()

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5001, debug=True)
