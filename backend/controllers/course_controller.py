# course_controller.py
from flask import Blueprint, request, jsonify
from services.course_service import create_course, retrieve_course

course_bp = Blueprint('course', __name__)

@course_bp.route('/course', methods=['POST'])
def post_course():
    course_data = request.get_json()
    new_course = create_course(course_data)
    return jsonify({'course_id': new_course.course_id}), 201

@course_bp.route('/course', methods=['GET'])
def get_course_info():
    course_id = request.args.get('course_id')
    course = retrieve_course(course_id)
    if course is None:
        return jsonify({'error': 'Course not found'}), 404
    return course, 200
