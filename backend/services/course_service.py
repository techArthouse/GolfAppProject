# course_service.py
from models import Course

def create_course(course_data):
    return Course.insert_course(course_data)

def retrieve_course(course_id):
    return Course.get_course(course_id)

def retrieve_course(course_id):
    return 0 # needs implementation