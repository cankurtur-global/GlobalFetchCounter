#!/usr/bin/python
import random
import json
import urllib.parse
import uuid
from wsgiref.util import setup_testing_defaults
from wsgiref.simple_server import make_server

chosen_path = ''

def index_view(environ, start_response):
    global chosen_path
    chosen_path = str(uuid.uuid1())
    print("Chosen path %s for next request" % chosen_path)

    status = '200 OK'
    headers = [('Content-type', 'application/json')]
    start_response(status, headers)
    response = {'next_path': 'http://%s/%s/' % (environ.get('HTTP_HOST', 'localhost'), chosen_path)}
    return [json.dumps(response).encode('utf-8')]

def detail_view(environ, start_response):
    full_path =  environ.get('PATH_INFO', '')
    headers = [('Content-type', 'application/json')]
    try:
        (_, path, _) = full_path.split('/')
        if chosen_path == path:
            status = '200 OK'
            response_code = str(uuid.uuid4())
            print('Response code: %s' % response_code)
            start_response(status, headers)            
            response = {'path': path, 'response_code': response_code}
            return [json.dumps(response).encode('utf-8')]
        else:
            print('Bad path request: %s' % path)
            status = "400 Bad Request"
            start_response(status, headers)
            error_response = {'error': 'App requested the wrong path, expected: %s' % chosen_path}
            return [json.dumps(error_response).encode('utf-8')]
                    
    except ValueError:
        status = '404 Not Found'
        headers = [('Content-type', 'text/plain')]
        start_response(status, headers)
        return [b'Unexpected path']

def simple_app(environ, start_response):
    setup_testing_defaults(environ)

    if environ['PATH_INFO'] == '/':
        return index_view(environ, start_response)
    elif environ['PATH_INFO'] == '/environ/':
        print("Within elif")
        status = '200 OK'
        headers = [('Content-type', 'text/plain')]
        start_response(status, headers)
        ret = ["%s: %s\n" % (key, value)
               for key, value in environ.iteritems()]
        return ret
    else:
        return detail_view(environ, start_response)
    

httpd = make_server('', 8000, simple_app)
print("Serving on port 8000...")
httpd.serve_forever()
