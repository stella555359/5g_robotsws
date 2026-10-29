#!/usr/bin/env python
# -*- coding: utf-8 -*-


# http separator
HTTP_CR = '\r'
HTTP_LF = '\n'
HTTP_CRLF = '\r\n'

# Table mapping response codes to messages; entries have the
# form {code: (shortmessage, longmessage)}.
# See RFC 2616.
status_code_table = {
    100: ('Continue', 'Request received, please continue'),
    101: ('Switching Protocols',
          'Switching to new protocol; obey Upgrade header'),

    200: ('OK', 'Request fulfilled, document follows'),
    201: ('Created', 'Document created, URL follows'),
    202: ('Accepted',
          'Request accepted, processing continues off-line'),
    203: ('Non-Authoritative Information', 'Request fulfilled from cache'),
    204: ('No Content', 'Request fulfilled, nothing follows'),
    205: ('Reset Content', 'Clear input form for further input.'),
    206: ('Partial Content', 'Partial content follows.'),

    300: ('Multiple Choices',
          'Object has several resources -- see URI list'),
    301: ('Moved Permanently', 'Object moved permanently -- see URI list'),
    302: ('Found', 'Object moved temporarily -- see URI list'),
    303: ('See Other', 'Object moved -- see Method and URL list'),
    304: ('Not Modified',
          'Document has not changed since given time'),
    305: ('Use Proxy',
          'You must use proxy specified in Location to access this '
          'resource.'),
    307: ('Temporary Redirect',
          'Object moved temporarily -- see URI list'),

    400: ('Bad Request',
          'Bad request syntax or unsupported method'),
    401: ('Unauthorized',
          'No permission -- see authorization schemes'),
    402: ('Payment Required',
          'No payment -- see charging schemes'),
    403: ('Forbidden',
          'Request forbidden -- authorization will not help'),
    404: ('Not Found', 'Nothing matches the given URI'),
    405: ('Method Not Allowed',
          'Specified method is invalid for this resource.'),
    406: ('Not Acceptable', 'URI not available in preferred format.'),
    407: ('Proxy Authentication Required', 'You must authenticate with '
                                           'this proxy before proceeding.'),
    408: ('Request Timeout', 'Request timed out; try again later.'),
    409: ('Conflict', 'Request conflict.'),
    410: ('Gone',
          'URI no longer exists and has been permanently removed.'),
    411: ('Length Required', 'Client must specify Content-Length.'),
    412: ('Precondition Failed', 'Precondition in headers is false.'),
    413: ('Request Entity Too Large', 'Entity is too large.'),
    414: ('Request-URI Too Long', 'URI is too long.'),
    415: ('Unsupported Media Type', 'Entity body in unsupported format.'),
    416: ('Requested Range Not Satisfiable',
          'Cannot satisfy request range.'),
    417: ('Expectation Failed',
          'Expect condition could not be satisfied.'),

    500: ('Internal Server Error', 'Server got itself in trouble'),
    501: ('Not Implemented',
          'Server does not support this operation'),
    502: ('Bad Gateway', 'Invalid responses from another server/proxy.'),
    503: ('Service Unavailable',
          'The server cannot process the request due to a high load'),
    504: ('Gateway Timeout',
          'The gateway server did not receive a timely response'),
    505: ('HTTP Version Not Supported', 'Cannot fulfill request.'),
}


class HttpRequestParser(object):
    """
    HTTP request parser class.
    This class implement is referring to http.server.BaseHTTPRequestHandler
    HTTP request consists of three parts:
      1. One request line identifying the request type and path
      2. A set of headers (optional)
      3. Data part (optional)
    The header and data part are seperated by a blank line (CRLF)
    The request line has following form:
      <method> <URI> <version> CRLF
    The case-sensitve <method> is a method token such as "GET", "POST", "PUT", etc.
    The <URI> is a Uniform Resource Identifier and indicates the request resource.
    The <version> should be "HTTP/1.0" or "HTTP/1.1"
    The request line is ending with CRLF.
    """
    __status = 200
    __msg = ""
    __method = ""
    __uri = ""
    __version = ""
    __data = ""
    __req_header = []

    def __init__(self, msg_req):
        self.__msg = msg_req

    def get_status(self):
        return self.__status

    def get_method(self):
        return self.__method

    def get_uri(self):
        return self.__uri

    def get_version(self):
        return self.__version

    def get_header(self):
        return self.__req_header

    def get_data(self):
        return self.__data

    def req_parse(self):
        lines = self.__msg.split(HTTP_LF)
        lines[0] = lines[0].rstrip(HTTP_CRLF)
        words = lines[0].split()
        # first line should be request line
        if len(words) == 3:
            method, uri, version = words
            if version[:5] != 'HTTP/':
                self.__status = 400
                return False
            version_str = version.split('/', 1)[1]
            version_num = version_str.split('.')
            print("words={}, version={}".format(words, version))
            if len(version_num) != 2:
                self.__status = 400
                return False
            if version_num >= ["2", "0"]:
                self.__status = 505
                return False
            self.__version = version_str
            self.__method = method
            self.__uri = uri
        elif len(words) == 2:
            self.__method, self.__uri = words
        else:
            self.__status = 400
            return False
        # request header
        if len(lines) >= 2:
            for line in lines[1:]:
                line = line.rstrip(HTTP_CRLF)
                if line == '':
                    break
                else:
                    self.__req_header.append(line)
        # data
        if (HTTP_LF + HTTP_CRLF) in self.__msg:
            index = self.__msg.find(HTTP_LF + HTTP_CRLF)
            self.__data = self.__msg[index + 3:]
        return True

    def res_builder(self, status=200, version=1.1, header=None, data=None):
        """
        HTTP response message consists of three parts:
          1. One status line
          2. A set of headers (optional)
          3. Data part (optional)
        The header and data part are seperated by a blank line (CRLF)
        The status line has following form:
          <HTTP-Version> <Status-Code> <Reason-Phrase> CRLF

        This method receive 4 arguments at most.
          status -- status code of response
          version -- a float point number, can be one of 0.9, 1.0, 1.1 and 2.0
          header -- response header, can be a str or a list or a tuple
          data -- only support str data
        This method return a tuple.
        The first item of return tuple indicates build result: 0 -- success, -1 -- failure.
        The second item is the built http response message if no error occurs.
        """

        # check parameters
        if status not in status_code_table:
            return (-1, 'unknown status code')
        if isinstance(version, float) is False:
            return (-1, 'invalid version number')
            # only support HTTP/0.9, HTTP/1.0,  HTTP/1.1 and HTTP/2.0
        if version != 0.9 and version != 1.0 and version != 1.1 and version != 2.0:
            return (-1, 'unspported HTTP version')

            # build status line
        reason = status_code_table[status]
        msg = ''
        msg += 'HTTP/%s %s %s%s' % (version, status, reason[0], HTTP_CRLF)

        # build header
        if header is not None:
            if isinstance(header, str):
                msg += header
                msg += HTTP_CRLF
            if isinstance(header, list) or isinstance(header, tuple):
                for item in header:
                    if isinstance(item, str):
                        msg += item
                        msg += HTTP_CRLF
        # msg += HTTP_CRLF

        # build msg body
        msg += HTTP_CRLF
        if data is not None:
            if isinstance(data, str):
                msg += data

        # return a tuple
        return (0, msg)
