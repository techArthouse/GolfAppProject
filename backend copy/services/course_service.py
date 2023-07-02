from backend.models import insert_course, get_course

def create_course(course_data):
    return insert_course(course_data)

def retrieve_course(course_id):
    return get_course(course_id)
