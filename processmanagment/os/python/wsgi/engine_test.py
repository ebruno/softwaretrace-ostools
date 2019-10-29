#!/usr/bin/env python3
import sys
import json
import urllib.parse
import webtest
from webtest import TestApp

sys.path.append('..')

import childmgt.ChildMgt

from childmgtweb import application

def main():
    app = TestApp(application)
    query_data = [('af','b g'), ('d','  e')]
    post_data = [('a','b'), ('c','  d')]
    headers_html = { 'Accept' : 'text/html;q=0.9'}
    headers_json = { 'Accept' : 'application/json'}
    
    try:
        resp = app.get('/softwaretrace/processmanagment/v1/processes',query_data,headers_json)
        print(resp)
        resp = app.get('/softwaretrace/processmanagment/v1/processes',query_data,headers_html)
        print(resp)
#        resp = app.post('/softwaretrace/processmanagment/v1/processes/zombies',post_data)
#        print(resp)
#        resp = app.get('/softwaretrace/processmanagment/v1/processes/45',query_data)
#        print(resp)
#        resp = app.get('/softwaretrace/processmanagment/v1/tasks/45',query_data)
#        print(resp)
    except webtest.app.AppError as e:
        print(e)
        pass


if __name__ == '__main__':
    main()
