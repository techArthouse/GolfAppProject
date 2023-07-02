from flask import Blueprint, request, jsonify
from backend.services import insert_course, get_course

course_bp = Blueprint('course', __name__)

@course_bp.route('/course', methods=['POST'])
def post_course():
    course_data = request.get_json()
    insert_course(course_data)
    return jsonify({'message': 'Course inserted successfully'}), 201

@course_bp.route('/course', methods=['GET'])
def get_course_info():
    course_id = request.args.get('course_id')
    course = get_course(course_id)
    if course is None:
        return jsonify({'error': 'Course not found'}), 404
    return course, 200
