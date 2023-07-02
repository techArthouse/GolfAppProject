# app.py
import os
import sys

sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))

from backend.controllers import game_bp, player_bp, round_bp, course_bp, auth_bp
from flask import Flask
app = Flask(__name__)

app.register_blueprint(game_bp)
app.register_blueprint(player_bp)
app.register_blueprint(round_bp)
app.register_blueprint(course_bp)
app.register_blueprint(auth_bp)

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5001, debug=True)
