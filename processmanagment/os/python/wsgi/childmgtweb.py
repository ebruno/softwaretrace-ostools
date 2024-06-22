import json
import urllib.parse
import types
from json2html import *
import childmgt.ChildMgt
import procmgt.ProcMgt

required_base = '/softwaretrace/processmanagment'
valid_versions = ['v1']
valid_collections = ['processes']
valid_nouns = ['zombies']
version_position = 0
collection_position = 1

class RequestException(Exception):
    """ """
    def __init__(self,message='RequestException',invalid_value=None,valid_values=None):
        Exception.__init__(self,message)
        self._message = message
        self._invalid_value = invalid_value
        self._valid_values = valid_values
        
    def __str__(self):
        result = self._message
        if not isinstance(self._invalid_value,type(None)):
            result += ", invalid value:" + self._invalid_value
        if not isinstance(self._valid_values,type(None)):
            result += " valid values: " + str(self._valid_values)
        return result


def decode_path(url_path=None,path_separator='/'):
    result = None
    if not isinstance(url_path,type(None)):
        loc = url_path.index(required_base)
        if loc == 0:
            tmp_val = url_path[len(required_base):]
            if tmp_val[0] == path_separator:
                tmp_val = tmp_val[1:]
            components = tmp_val.split(path_separator)
            if components[version_position] in valid_versions:
                if components[collection_position] in valid_collections:
                    result = {'request': {'version':components[version_position],
                                          'requested_info': components[collection_position:]}
                    }
                else:
                    raise RequestException("Collection is invalid.",
                                           invalid_value=components[collection_position],
                                           valid_values=valid_collections)
            else:
                raise RequestException("Version is not supported.",
                                       invalid_value=components[version_position],
                                       valid_values=valid_versions)
    return result

def process_request(environ=None,inrequest=None,params=None):
    result = None
    if not isinstance(inrequest,type(None)):
        print(inrequest)
        request = inrequest['request']
        requested_info = request['requested_info']
        print(requested_info)
        if request['version'] == 'v1':
            if requested_info[0] == 'processes':
                if len(requested_info) > 1:
                    if requested_info[1] in valid_nouns:
                        a = 1
                    else:
                        try:
                            pid = int(requested_info[1])
                        except ValueError as e:
                            pass
                    
                else:
                    proc_info = procmgt.ProcMgt.ProcMgt()
                    result = proc_info.getStatusAsDictionary()
                    result = json2html.convert(json=result)
            else:
                print(requested_info[0])
        else:
            print('version',request['version'],'is not supported')
    return result

def application(environ,start_response):
    body = ''
    params = []
    response_code = '200 OK'
    try:
        print(environ)
        request = decode_path(urllib.parse.unquote(environ['PATH_INFO']))
        if environ['REQUEST_METHOD'] == 'GET':
            params = urllib.parse.unquote_plus(environ['QUERY_STRING']).split('&')
        elif environ['REQUEST_METHOD'] == 'POST':
            request_body_size = 0
            try:
                request_body_size = int(environ.get('CONTENT_LENGTH',0))
                if request_body_size > 0:
                    request_body = environ['wsgi.input'].read(request_body_size)
                    params = urllib.parse.unquote_plus(request_body.decode('utf-8')).split('&')
            except ValueError as e:
                pass            
        else:
            response_code = '405 Method Not Allowed'
        if response_code == '200 OK':
            proc_info = process_request(environ=environ,inrequest=request,params=params)
            body = json.dumps(proc_info,separators=(',', ':'))
    except RequestException as e:
        response_code = '400 Bad Request'
        body = str(e)
        pass
    except KeyError as e:
        response_code = '400 Bad Request'
        
    headers = [('Content-Type', 'text/html; Charset=utf8'),
                ('Content-Length', str(len(body)))]
    body = body.encode('utf-8')
    start_response(response_code, headers)
    return [body]



