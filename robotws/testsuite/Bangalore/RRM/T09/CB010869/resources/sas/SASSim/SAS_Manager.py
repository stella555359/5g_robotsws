# -*- coding: utf-8 -*-


import json
import os
import socket
import ssl

from sas.Consts import *

HELP = 'Usage\r\n\
  help|?                               -- show this help\r\n\
  cbsd                                 -- show all information of connected CBSDs\r\n\
  blacklist                            -- show blacklist information\r\n\
  blacklist_add <CBSD_ID>              -- add a CBSD to blacklist\r\n\
  blacklist_del <CBSD_ID>              -- remove a CBSD from blacklist\r\n\
  PPA                                  -- show PPA members\r\n\
  PPA_add <CBSD_ID>                    -- add a CBSD to be a PPA member\r\n\
  PPA_del <CBSD_ID>                    -- remove a PPA member\r\n\
  grant_suspend <CBSD_ID> <GRANT_ID>   -- suspend a grant\r\n\
  grant_terminate <CBSD_ID> <GRANT_ID> -- terminate a grant\r\n\
  grant_free <CBSD_ID> <GRANT_ID>      -- free the suspended or terminated grant\r\n\
  grant_renew <enable|disable>         -- enable or disable grant renewal\r\n\
  transmit_renew <enable|disable>      -- enable or disable transmit renewal\r\n\
  server_version                       -- show SAS server version\r\n\
  server_conf <IP> <PORT>              -- specify SAS server IP address and port to connect\r\n\
  tls <enable|disable>                 -- connect to SAS server with TLS mode or TCP mode\r\n\
  block <messageTag>                   -- update option block_request\r\n\
  connection_reject <ipaddr>           -- connection or request from ipaddr will be rejected \r\n\
  exit                                 -- terminate this process'

HTTP_CR = '\r'
HTTP_LF = '\n'
HTTP_CRLF = '\r\n'

HTTP_METHOD_POST = 'POST'
HTTP_VERSION_11 = 'HTTP/1.1'
HTTP_HEADER_HOST = 'Host:www.Nokia.com'
HTTP_HEADER_CTYPE = 'Content-type: application/json'

HTTP_HEADERS = HTTP_HEADER_HOST + HTTP_CRLF + HTTP_HEADER_CTYPE + HTTP_CRLF

HTTP_REQ_HEADER_CBSD = (HTTP_METHOD_POST + ' ' + '/' + SAS_VERSION_TS_11 + '/' + METHOD_MNG_CBSD + ' '
                        + HTTP_VERSION_11 + HTTP_CRLF + HTTP_HEADERS + HTTP_CRLF)
HTTP_REQ_BODY_CBSD = '{"mngCbsdRequest": 0}'

HTTP_REQ_HEADER_BLIST = (HTTP_METHOD_POST + ' ' + '/' + SAS_VERSION_TS_11 + '/' + METHOD_MNG_BLIST + ' '
                         + HTTP_VERSION_11 + HTTP_CRLF + HTTP_HEADERS + HTTP_CRLF)
HTTP_REQ_BODY_BLIST = '{"mngBlistRequest": 0}'

HTTP_REQ_HEADER_BL_ADD = (HTTP_METHOD_POST + ' ' + '/' + SAS_VERSION_TS_11 + '/' + METHOD_MNG_BL_ADD + ' '
                          + HTTP_VERSION_11 + HTTP_CRLF + HTTP_HEADERS + HTTP_CRLF)

HTTP_REQ_HEADER_BL_DEL = (HTTP_METHOD_POST + ' ' + '/' + SAS_VERSION_TS_11 + '/' + METHOD_MNG_BL_DEL + ' '
                          + HTTP_VERSION_11 + HTTP_CRLF + HTTP_HEADERS + HTTP_CRLF)

HTTP_REQ_HEADER_PPA = (HTTP_METHOD_POST + ' ' + '/' + SAS_VERSION_TS_11 + '/' + METHOD_MNG_PPA + ' '
                       + HTTP_VERSION_11 + HTTP_CRLF + HTTP_HEADERS + HTTP_CRLF)
HTTP_REQ_BODY_PPA = '{"mngPpaRequest": 0}'

HTTP_REQ_HEADER_PPA_ADD = (HTTP_METHOD_POST + ' ' + '/' + SAS_VERSION_TS_11 + '/' + METHOD_MNG_PPA_ADD + ' '
                           + HTTP_VERSION_11 + HTTP_CRLF + HTTP_HEADERS + HTTP_CRLF)

HTTP_REQ_HEADER_PPA_DEL = (HTTP_METHOD_POST + ' ' + '/' + SAS_VERSION_TS_11 + '/' + METHOD_MNG_PPA_DEL
                           + ' ' + HTTP_VERSION_11 + HTTP_CRLF + HTTP_HEADERS + HTTP_CRLF)

HTTP_REQ_HEADER_GRANT_SP = (HTTP_METHOD_POST + ' ' + '/' + SAS_VERSION_TS_11 + '/' + METHOD_MNG_GRANT_SP
                            + ' ' + HTTP_VERSION_11 + HTTP_CRLF + HTTP_HEADERS + HTTP_CRLF)

HTTP_REQ_HEADER_GRANT_TN = (HTTP_METHOD_POST + ' ' + '/' + SAS_VERSION_TS_11 + '/' + METHOD_MNG_GRANT_TN
                            + ' ' + HTTP_VERSION_11 + HTTP_CRLF + HTTP_HEADERS + HTTP_CRLF)

HTTP_REQ_HEADER_GRANT_FREE = (HTTP_METHOD_POST + ' ' + '/' + SAS_VERSION_TS_11 + '/' + METHOD_MNG_GRANT_FREE
                              + ' ' + HTTP_VERSION_11 + HTTP_CRLF + HTTP_HEADERS + HTTP_CRLF)

HTTP_REQ_HEADER_GRANT_RENEW = (HTTP_METHOD_POST + ' ' + '/' + SAS_VERSION_TS_11 + '/' + METHOD_MNG_GRANT_RENEW
                               + ' ' + HTTP_VERSION_11 + HTTP_CRLF + HTTP_HEADERS + HTTP_CRLF)
HTTP_REQ_BODY_GRANT_RENEW_ENABLE = '{"mngGrantRenewRequest": 1}'
HTTP_REQ_BODY_GRANT_RENEW_DISABLE = '{"mngGrantRenewRequest": 0}'

HTTP_REQ_HEADER_TRANSMIT_RENEW = (HTTP_METHOD_POST + ' ' + '/' + SAS_VERSION_TS_11 + '/'
                                  + METHOD_MNG_TRANSMIT_RENEW
                                  + ' ' + HTTP_VERSION_11 + HTTP_CRLF + HTTP_HEADERS + HTTP_CRLF)
HTTP_REQ_BODY_TRANSMIT_RENEW_ENABLE = '{"mngTransmitRenewRequest": 1}'
HTTP_REQ_BODY_TRANSMIT_RENEW_DISABLE = '{"mngTransmitRenewRequest": 0}'

HTTP_REQ_HEADER_VERSION = (HTTP_METHOD_POST + ' ' + '/' + SAS_VERSION_TS_11 + '/' + METHOD_MNG_VERSION
                           + ' ' + HTTP_VERSION_11 + HTTP_CRLF + HTTP_HEADERS + HTTP_CRLF)
HTTP_REQ_BODY_VERSION = '{"mngVersionRequest": 0}'

HTTP_REQ_HEADER_OPTION_BLOCK_REQUEST = (
            HTTP_METHOD_POST + ' ' + '/' + SAS_VERSION_TS_11 + '/' + METHOD_MNG_OPTION_BLOCK_REQUEST
            + ' ' + HTTP_VERSION_11 + HTTP_CRLF + HTTP_HEADERS + HTTP_CRLF)

HTTP_REQ_HEADER_OPTION_CONNECTION_REJECT = (
            HTTP_METHOD_POST + ' ' + '/' + SAS_VERSION_TS_11 + '/' + METHOD_MNG_OPTION_CONNECTION_REJECT
            + ' ' + HTTP_VERSION_11 + HTTP_CRLF + HTTP_HEADERS + HTTP_CRLF)
server_ip = 'localhost'
server_port = 443
tls_enable = True
SOCK_BUF_MAX = 8192

# key file and certificate file
KEY_FILE = os.path.dirname(os.path.realpath(__file__)) + '/nokia04.key'
CERT_FILE = os.path.dirname(os.path.realpath(__file__)) + '/nokia04.cert'

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


class HttpResponseParser(object):
    """
    HTTP response parser class.
    This class implement is referring to http.server.BaseHTTPRequestHandler
    HTTP response consists of three parts:
      1. One status line
      2. A set of headers (optional)
      3. Data part (optional)
    The header and data part are seperated by a blank line (CRLF)
    The status line has following form:
      <version> <status-code> <reason-phrase> CRLF
    The <version> should be "HTTP/1.0" or "HTTP/1.1"
    The status line is ending with CRLF.
    """
    __status = 200
    __msg = ""
    __version = ""
    __data = ""
    __res_header = []

    def __init__(self, msg_res):
        self.__msg = msg_res

    def get_status(self):
        return self.__status

    def get_version(self):
        return self.__version

    def get_header(self):
        return self.__req_header

    def get_data(self):
        return self.__data

    def res_parse(self):
        lines = self.__msg.split(HTTP_LF)
        lines[0] = lines[0].rstrip(HTTP_CRLF)
        words = lines[0].split(None, 2)
        # first line should be status line
        if len(words) == 3:
            version, status, reason = words
            if version[:5] != 'HTTP/':
                print('Bad response version %s' % version)
                return False
            version_str = version.split('/', 1)[1]
            version_num = version_str.split('.')
            if len(version_num) != 2:
                print('Bad response version %s' % version)
                return False
            if version_num >= (2, 0):
                self.__status = 505
                print('Invalid HTTP version %s' % version_str)
                return False
            self.__version = version_str
        else:
            return False
        # request header
        if len(lines) >= 2:
            for line in lines[1:]:
                line = line.rstrip(HTTP_CRLF)
                if line == '':
                    break
                else:
                    self.__res_header.append(line)
        # data
        if (HTTP_LF + HTTP_CRLF) in self.__msg:
            index = self.__msg.find(HTTP_LF + HTTP_CRLF)
            self.__data = self.__msg[index + 3:]
        return True


def data_send_recv(data):
    try:
        sock = socket.socket(socket.AF_INET)
        sock.settimeout(2)
        if tls_enable:
            conn = ssl.wrap_socket(sock, KEY_FILE, CERT_FILE,
                                   cert_reqs=ssl.CERT_NONE, ssl_version=ssl.PROTOCOL_SSLv23)
            conn.connect((server_ip, server_port))
            conn.sendall(data)
            res = conn.recv(SOCK_BUF_MAX)
            conn.close()
        else:
            sock.connect((server_ip, server_port))
            sock.sendall(data)
            res = sock.recv(SOCK_BUF_MAX)
            sock.close()
        return [True, res]
    except socket.error:
        print('socket-related error!')
        return [False, b'']
    except socket.herror or socket.gaierror:
        print('address-related error!')
        return [False, b'']
    except socket.timeout:
        print('socket timeout!')
        return [False, b'']
    except Exception as err:
        print('unexpected error! %s' % err)
        return [False, b'']


def cbsd_req():
    msg = HTTP_REQ_HEADER_CBSD + HTTP_REQ_BODY_CBSD
    return msg.encode('utf-8')


def cbsd_res(msg):
    http_p = HttpResponseParser(msg)
    if http_p.res_parse() is False:
        print('invalid http response')
        return
    if 200 != http_p.get_status():
        print('http status %d' % http_p.get_status())
        return
    msg_json = http_p.get_data()
    msg_body = json.loads(msg_json)
    if RES_MNG_CBSD not in msg_body:
        print('invalid %s' % RES_MNG_CBSD)
        return False
    cbsd_list_ret = msg_body[RES_MNG_CBSD]
    if 'response' not in cbsd_list_ret:
        print('invalid response msg due to missing error body')
        return False
    err_ret = cbsd_list_ret['response']
    if 'responseCode' not in err_ret:
        print('invalid response msg due to missing error code')
        return False
    if err_ret['responseCode'] != 0:
        print('get CBSD info fail with error code %d' % err_ret['responseCode'])
        return False
    if 'cbsd' not in cbsd_list_ret:
        print('invalid response msg due to missing cbsd body')
        return False
    cbsd_list = cbsd_list_ret['cbsd']
    num = len(cbsd_list)
    print('CBSD number: %d' % num)
    num = 0
    for cbsd in cbsd_list:
        print('CBSD %d' % num)
        if PAR_CBSD_ID in cbsd:
            print('    cbsd ID: %s' % cbsd[PAR_CBSD_ID])
        if PAR_OP_STATE in cbsd:
            print('    operate status: %s' % cbsd[PAR_OP_STATE])
        if PAR_USER_ID in cbsd:
            print('    user ID: %s' % cbsd[PAR_USER_ID])
        if PAR_FCC_ID in cbsd:
            print('    fcc ID: %s' % cbsd[PAR_FCC_ID])
        if PAR_CBSD_SN in cbsd:
            print('    serial number: %s' % cbsd[PAR_CBSD_SN])
        if PAR_CALL_SIGN in cbsd:
            print('    call sign: %s' % cbsd[PAR_CALL_SIGN])
        if PAR_CBSD_CAT in cbsd:
            print('    cbsd category: %s' % cbsd[PAR_CBSD_CAT])
        if PAR_CBSD_INFO in cbsd:
            print('    CBSD information:')
            info = cbsd[PAR_CBSD_INFO]
            if PAR_INFO_VENDOR in info:
                print('        vendor: %s' % info[PAR_INFO_VENDOR])
            if PAR_INFO_MODEL in info:
                print('        model: %s' % info[PAR_INFO_MODEL])
            if PAR_INFO_SV in info:
                print('        software version: %s' % info[PAR_INFO_SV])
            if PAR_INFO_HV in info:
                print('        hardware version: %s' % info[PAR_INFO_HV])
            if PAR_INFO_FV in info:
                print('        firmware version: %s' % info[PAR_INFO_FV])
        if PAR_AIR_IF in cbsd:
            print('    air interface:')
            if PAR_RADIO_TECH in cbsd[PAR_AIR_IF]:
                print('        radio technology: %s' % cbsd[PAR_AIR_IF][PAR_RADIO_TECH])
            if PAR_RADIO_SPEC in cbsd[PAR_AIR_IF]:
                print('        supported spec: %s' % cbsd[PAR_AIR_IF][PAR_RADIO_SPEC])
        if PAR_INSTALL_PAR in cbsd:
            print('    installation param:')
            instPar = cbsd[PAR_INSTALL_PAR]
            if PAR_LATITUDE in instPar:
                print('        latitude: %s degrees' % instPar[PAR_LATITUDE])
            if PAR_LONGITUDE in instPar:
                print('        longitude: %s degrees' % instPar[PAR_LONGITUDE])
            if PAR_HEIGHT in instPar:
                print('        height: %s meters' % instPar[PAR_HEIGHT])
            if PAR_HEIGHT_TYPE in instPar:
                print('        height type: %s' % instPar[PAR_HEIGHT_TYPE])
            if PAR_HORI_ACCU in instPar:
                print('        horizontal accuracy: %s meters' % instPar[PAR_HORI_ACCU])
            if PAR_VERT_ACCU in instPar:
                print('        vertical accuracy: %s meters' % instPar[PAR_VERT_ACCU])
            if PAR_INDOOR_DEP in instPar:
                print('        indoor deployment: %s' % instPar[PAR_INDOOR_DEP])
            if PAR_ANT_AZIM in instPar:
                print('        antenna azimuth: %s degrees' % instPar[PAR_ANT_AZIM])
            if PAR_ANT_DOWN_TILT in instPar:
                print('        antenna downtilt: %s degrees' % instPar[PAR_ANT_DOWN_TILT])
            if PAR_ANT_EIRP in instPar:
                print('        eirp capability: %s dBm/10MHz' % instPar[PAR_ANT_EIRP])
            if PAR_ANT_GAIN in instPar:
                print('        antenna gain: %s dBi' % instPar[PAR_ANT_GAIN])
            if PAR_ANT_BEAMW in instPar:
                print('        antenna beamwidth: %s degrees' % instPar[PAR_ANT_BEAMW])
            if PAR_ANT_MODEL in instPar:
                print('        antenna model: %s' % instPar[PAR_ANT_MODEL])
        if PAR_MEAS_CAP in cbsd:
            print('    measurement capability:')
            meas = cbsd[PAR_MEAS_CAP]
            if isinstance(meas, list):
                for cap in meas:
                    print('        %s' % cap)
        if PAR_GROUP_PAR in cbsd:
            print('    grouping:')
            group = cbsd[PAR_GROUP_PAR]
            if PAR_GROUP_TYPE in group:
                print('        group type: %s' % group[PAR_GROUP_TYPE])
            if PAR_GROUP_ID in group:
                print('        group ID: %s' % group[PAR_GROUP_ID])
        grant_list = cbsd[PAR_GRANTS]
        grant_num = len(grant_list)
        print('    Grant number: %d' % grant_num)
        grant_num = 0
        for grant in grant_list:
            print('    Grant %d' % grant_num)
            if PAR_GRANT_ID in grant:
                print('        grantID: %s' % grant[PAR_GRANT_ID])
            if PAR_OP_STATE in grant:
                print('        op state: %s' % grant[PAR_OP_STATE])
            if PAR_MAX_EIRP in grant:
                print('        max EIRP: %s' % grant[PAR_MAX_EIRP])
            if PAR_LOW_FREQ in grant:
                print('        low frequency: %s' % grant[PAR_LOW_FREQ])
            if PAR_HIGH_FREQ in grant:
                print('        high frequency: %s' % grant[PAR_HIGH_FREQ])
            if PAR_CHN_TYPE in grant:
                print('        channel type: %s' % grant[PAR_CHN_TYPE])
            if PAR_GRANT_EXP in grant:
                print('        grant expire: %s' % grant[PAR_GRANT_EXP])
            if PAR_TRANS_EXP in grant:
                print('        transmit expire: %s' % grant[PAR_TRANS_EXP])
            grant_num += 1
        num += 1


def blist_req():
    msg = HTTP_REQ_HEADER_BLIST + HTTP_REQ_BODY_BLIST
    return msg.encode('utf-8')


def blist_res(msg):
    http_p = HttpResponseParser(msg)
    if http_p.res_parse() is False:
        print('invalid http response')
        return
    if 200 != http_p.get_status():
        print('http status %d' % http_p.get_status())
        return
    msg_json = http_p.get_data()
    msg_body = json.loads(msg_json)
    if RES_MNG_BLIST not in msg_body:
        print('invalid %s' % RES_MNG_BLIST)
        return False
    blist_list_ret = msg_body[RES_MNG_BLIST]
    if 'response' not in blist_list_ret:
        print('invalid response msg due to missing error body')
        return False
    err_ret = blist_list_ret['response']
    if 'responseCode' not in err_ret:
        print('invalid response msg due to missing error code')
        return False
    if err_ret['responseCode'] != 0:
        print('get blacklist info fail with error code %d' % err_ret['responseCode'])
        return False
    if 'blacklist' not in blist_list_ret:
        print('invalid response msg due to missing blacklist body')
        return False
    blist_list = blist_list_ret['blacklist']
    num = len(blist_list)
    print('blacklist number: %d' % num)
    num = 0
    for blist in blist_list:
        print('    %d: %s' % (num, blist))
        num = num + 1


def blist_add_req(items):
    """
    request format:
      POST xxxx/v1.0/mngBlistAdd HTTP/1.1 \r\n
      [header items]
      "{mngBlistAddRequest: [cbsd_id_0, cbsd_id_1, ...]}"
    """
    blist = items.split()
    body = {}
    body[REQ_MNG_BL_ADD] = blist
    msg = HTTP_REQ_HEADER_BL_ADD + json.dumps(body)
    return msg.encode('utf-8')


def blist_add_res(msg):
    """
    response format:
      HTTP/1.1 200 OK
      [header items]
      "{mngBlistAddResponse: {"response": {"responseCode": 0, "responseMessage": "request is approved by SAS"}}}"
    """
    http_p = HttpResponseParser(msg)
    if http_p.res_parse() is False:
        print('invalid http response')
        return
    if 200 != http_p.get_status():
        print('http status %d' % http_p.get_status())
        return
    msg_json = http_p.get_data()
    msg_body = json.loads(msg_json)
    if RES_MNG_BL_ADD not in msg_body:
        print('invalid %s' % RES_MNG_BL_ADD)
        return False
    bl_add_ret = msg_body[RES_MNG_BL_ADD]
    if 'response' not in bl_add_ret:
        print('invalid response msg due to missing error body')
        return False
    err_ret = bl_add_ret['response']
    if 'responseCode' not in err_ret:
        print('invalid response msg due to missing error code')
        return False
    if err_ret['responseCode'] == 0:
        print('adding blacklist item success')
        return True
    else:
        print('adding blacklist item fail with error code %d' % err_ret['responseCode'])
        return False


def blist_del_req(items):
    """
    request format:
      POST xxxx/v1.0/mngBlistDel HTTP/1.1 \r\n
      [header items]
      "{mngBlistDelRequest: [cbsd_id_0, cbsd_id_1, ...]}"
    """
    blist = items.split()
    body = {}
    body[REQ_MNG_BL_DEL] = blist
    msg = HTTP_REQ_HEADER_BL_DEL + json.dumps(body)
    return msg.encode('utf-8')


def blist_del_res(msg):
    """
    response format:
      HTTP/1.1 200 OK \r\n
      [header items]
      "{mngBlistDelResponse: {"response": {"responseCode": 0, "responseMessage": "request is approved by SAS"}}}"
    """
    http_p = HttpResponseParser(msg)
    if http_p.res_parse() is False:
        print('invalid http response')
        return
    if 200 != http_p.get_status():
        print('http status %d' % http_p.get_status())
        return
    msg_json = http_p.get_data()
    msg_body = json.loads(msg_json)
    if RES_MNG_BL_DEL not in msg_body:
        print('invalid %s' % RES_MNG_BL_DEL)
        return False
    bl_del_ret = msg_body[RES_MNG_BL_DEL]
    if 'response' not in bl_del_ret:
        print('invalid response msg due to missing error body')
        return False
    err_ret = bl_del_ret['response']
    if 'responseCode' not in err_ret:
        print('invalid response msg due to missing error code')
        return False
    if err_ret['responseCode'] == 0:
        print('removing blacklist item success')
        return True
    else:
        print('removing blacklist item fail with error code %d' % err_ret['responseCode'])
        return False


def ppa_req():
    msg = HTTP_REQ_HEADER_PPA + HTTP_REQ_BODY_PPA
    return msg.encode('utf-8')


def ppa_res(msg):
    http_p = HttpResponseParser(msg)
    if not http_p.res_parse():
        print('invalid http response')
        return
    if 200 != http_p.get_status():
        print('http status %d' % http_p.get_status())
        return
    msg_json = http_p.get_data()
    msg_body = json.loads(msg_json)
    if RES_MNG_PPA not in msg_body:
        print('invalid %s' % RES_MNG_PPA)
        return False
    ppa_list_ret = msg_body[RES_MNG_PPA]
    if 'response' not in ppa_list_ret:
        print('invalid response msg due to missing error body')
        return False
    err_ret = ppa_list_ret['response']
    if 'responseCode' not in err_ret:
        print('invalid response msg due to missing error code')
        return False
    if err_ret['responseCode'] != 0:
        print('get PPA info fail with error code %d' % err_ret['responseCode'])
        return False
    if 'PPA' not in ppa_list_ret:
        print('invalid response msg due to missing PPA body')
        return False
    ppa_list = ppa_list_ret['PPA']
    num = len(ppa_list)
    print('PPA number: %d' % num)
    num = 0
    for ppa in ppa_list:
        print('    %d: %s' % (num, ppa))
        num = num + 1


def ppa_add_req(items):
    """
    request format:
      POST xxxx/v1.0/mngPpaAdd HTTP/1.1 \r\n
      [header items]
      "{mngPpaAddRequest: [cbsd_id_0, cbsd_id_1, ...]}"
    """
    blist = items.split()
    body = {}
    body[REQ_MNG_PPA_ADD] = blist
    msg = HTTP_REQ_HEADER_PPA_ADD + json.dumps(body)
    return msg.encode('utf-8')


def ppa_add_res(msg):
    """
    response format:
      HTTP/1.1 200 OK \r\n
      [header items]
      "{mngPpaAddRequest: {"response": {"responseCode": 0, "responseMessage": "request is approved by SAS"}}}"
    """
    http_p = HttpResponseParser(msg)
    if not http_p.res_parse():
        print('invalid http response')
        return
    if 200 != http_p.get_status():
        print('http status %d' % http_p.get_status())
        return
    msg_json = http_p.get_data()
    msg_body = json.loads(msg_json)
    if RES_MNG_PPA_ADD not in msg_body:
        print('invalid %s' % RES_MNG_PPA_ADD)
        return False
    ppa_add_ret = msg_body[RES_MNG_PPA_ADD]
    if 'response' not in ppa_add_ret:
        print('invalid response msg due to missing error body')
        return False
    err_ret = ppa_add_ret['response']
    if 'responseCode' not in err_ret:
        print('invalid response msg due to missing error code')
        return False
    if err_ret['responseCode'] == 0:
        print('adding PPA item success')
        return True
    else:
        print('adding PPA item fail with error code %d' % err_ret['responseCode'])
        return False


def ppa_del_req(items):
    """
    request format:
      POST xxxx/v1.0/mngPpaDel HTTP/1.1 \r\n
      [header items]
      "{mngPpaDelRequest: [cbsd_id_0, cbsd_id_1, ...]}"
    """
    blist = items.split()
    body = {}
    body[REQ_MNG_PPA_DEL] = blist
    msg = HTTP_REQ_HEADER_PPA_DEL + json.dumps(body)
    return msg.encode('utf-8')


def ppa_del_res(msg):
    """
    response format:
      HTTP/1.1 200 OK \r\n
      [header items]
      "{mngPpaDelResponse: {"response": {"responseCode": 0, "responseMessage": "request is approved by SAS"}}}"
    """
    http_p = HttpResponseParser(msg)
    if not http_p.res_parse():
        print('invalid http response')
        return
    if 200 != http_p.get_status():
        print('http status %d' % http_p.get_status())
        return
    msg_json = http_p.get_data()
    msg_body = json.loads(msg_json)
    if RES_MNG_PPA_DEL not in msg_body:
        print('invalid %s' % RES_MNG_PPA_DEL)
        return False
    ppa_del_ret = msg_body[RES_MNG_PPA_DEL]
    if 'response' not in ppa_del_ret:
        print('invalid response msg due to missing error body')
        return False
    err_ret = ppa_del_ret['response']
    if 'responseCode' not in err_ret:
        print('invalid response msg due to missing error code')
        return False
    if err_ret['responseCode'] == 0:
        print('removing PPA item success')
        return True
    else:
        print('removing PPA item fail with error code %d' % err_ret['responseCode'])
        return False


def grant_suspend_req(cbsdID, grantID):
    """
    request format:
      POST xxxx/v1.0/mngGrantSuspend HTTP/1.1 \r\n
      [header items]
      "{mngGrantSuspendRequest: {'cbsdId': 'xxxxxxxx', 'grantId': 'xxxxxxxx'}}"
    """
    par = {}
    par[PAR_CBSD_ID] = cbsdID
    par[PAR_GRANT_ID] = grantID
    body = {}
    body[REQ_MNG_GRANT_SP] = par
    msg = HTTP_REQ_HEADER_GRANT_SP + json.dumps(body)
    return msg.encode('utf-8')


def grant_suspend_res(msg):
    """
    response format:
      HTTP/1.1 200 OK \r\n
      [header items]
      "{mngGrantSuspendResponse: {"response": {"responseCode": 0,
       "responseMessage": "request is approved by SAS"}}}"
    """
    http_p = HttpResponseParser(msg)
    if not http_p.res_parse():
        print('invalid http response')
        return
    if 200 != http_p.get_status():
        print('http status %d' % http_p.get_status())
        return
    msg_json = http_p.get_data()
    msg_body = json.loads(msg_json)
    if RES_MNG_GRANT_SP not in msg_body:
        print('invalid %s' % RES_MNG_GRANT_SP)
        return False
    suspend_ret = msg_body[RES_MNG_GRANT_SP]
    if 'response' not in suspend_ret:
        print('invalid response msg due to missing error body')
        return False
    err_ret = suspend_ret['response']
    if 'responseCode' not in err_ret:
        print('invalid response msg due to missing error code')
        return False
    if err_ret['responseCode'] == 0:
        print('suspending grant success')
        return True
    else:
        print('suspending grant fail with error code %d' % err_ret['responseCode'])
        return False


def grant_terminate_req(cbsdID, grantID):
    """
    request format:
      POST xxxx/v1.0/mngGrantTerminate HTTP/1.1 \r\n
      [header items]
      "{mngGrantTerminateRequest: {'cbsdId': 'xxxxxxxx', 'grantId': 'xxxxxxxx'}}"
    """
    par = {}
    par[PAR_CBSD_ID] = cbsdID
    par[PAR_GRANT_ID] = grantID
    body = {}
    body[REQ_MNG_GRANT_TN] = par
    msg = HTTP_REQ_HEADER_GRANT_TN + json.dumps(body)
    return msg.encode('utf-8')


def grant_terminate_res(msg):
    """
    response format:
      HTTP/1.1 200 OK \r\n
      [header items]
      "{mngGrantTerminateResponse: {"response": {"responseCode": 0,
       "responseMessage": "request is approved by SAS"}}}"
    """
    http_p = HttpResponseParser(msg)
    if not http_p.res_parse():
        print('invalid http response')
        return
    if 200 != http_p.get_status():
        print('http status %d' % http_p.get_status())
        return
    msg_json = http_p.get_data()
    msg_body = json.loads(msg_json)
    if RES_MNG_GRANT_TN not in msg_body:
        print('invalid %s' % RES_MNG_GRANT_TN)
        return False
    tn_ret = msg_body[RES_MNG_GRANT_TN]
    if 'response' not in tn_ret:
        print('invalid response msg due to missing error body')
        return False
    err_ret = tn_ret['response']
    if 'responseCode' not in err_ret:
        print('invalid response msg due to missing error code')
        return False
    if err_ret['responseCode'] == 0:
        print('terminating grant success')
        return True
    else:
        print('terminating grant fail with error code %d' % err_ret['responseCode'])
        return False


def grant_free_req(cbsdID, grantID):
    """
    request format:
      POST xxxx/v1.0/mngGrantFree HTTP/1.1 \r\n
      [header items]
      "{mngGrantFreeRequest: {'cbsdId': 'xxxxxxxx', 'grantId': 'xxxxxxxx'}}"
    """
    par = {}
    par[PAR_CBSD_ID] = cbsdID
    par[PAR_GRANT_ID] = grantID
    body = {}
    body[REQ_MNG_GRANT_FREE] = par
    msg = HTTP_REQ_HEADER_GRANT_FREE + json.dumps(body)
    return msg.encode('utf-8')


def grant_free_res(msg):
    """
    response format:
      HTTP/1.1 200 OK \r\n
      [header items]
      "{mngGrantFreeResponse: {"response": {"responseCode": 0,
      "responseMessage": "request is approved by SAS"}}}"
    """
    http_p = HttpResponseParser(msg)
    if not http_p.res_parse():
        print('invalid http response')
        return
    if 200 != http_p.get_status():
        print('http status %d' % http_p.get_status())
        return
    msg_json = http_p.get_data()
    msg_body = json.loads(msg_json)
    if RES_MNG_GRANT_FREE not in msg_body:
        print('invalid %s' % RES_MNG_GRANT_FREE)
        return False
    free_ret = msg_body[RES_MNG_GRANT_FREE]
    if 'response' not in free_ret:
        print('invalid response msg due to missing error body')
        return False
    err_ret = free_ret['response']
    if 'responseCode' not in err_ret:
        print('invalid response msg due to missing error code')
        return False
    if err_ret['responseCode'] == 0:
        print('free grant success')
        return True
    else:
        print('free grant fail with error code %d' % err_ret['responseCode'])
        return False


def grant_renew_req(renew):
    """
    request format for enable renewal:
      POST xxxx/v1.0/mngGrantRenew HTTP/1.1 \r\n
      [header items]
      "{mngGrantRenewRequest: 1}"
    request format for disable renewal:
      POST xxxx/v1.0/mngGrantRenew HTTP/1.1 \r\n
      [header items]
      "{mngGrantRenewRequest: 0}"
    """
    if renew:
        msg = HTTP_REQ_HEADER_GRANT_RENEW + HTTP_REQ_BODY_GRANT_RENEW_ENABLE
    else:
        msg = HTTP_REQ_HEADER_GRANT_RENEW + HTTP_REQ_BODY_GRANT_RENEW_DISABLE
    return msg.encode('utf-8')


def grant_renew_res(msg):
    """
    response format:
      HTTP/1.1 200 OK \r\n
      [header items]
      "{mngGrantRenewResponse: {"response": {"responseCode":
       0, "responseMessage": "request is approved by SAS"}}}"
    """
    http_p = HttpResponseParser(msg)
    if not http_p.res_parse():
        print('invalid http response')
        return
    if 200 != http_p.get_status():
        print('http status %d' % http_p.get_status())
        return
    msg_json = http_p.get_data()
    msg_body = json.loads(msg_json)
    if RES_MNG_GRANT_RENEW not in msg_body:
        print('invalid %s' % RES_MNG_GRANT_RENEW)
        return False
    free_ret = msg_body[RES_MNG_GRANT_RENEW]
    if 'response' not in free_ret:
        print('invalid response msg due to missing error body')
        return False
    err_ret = free_ret['response']
    if 'responseCode' not in err_ret:
        print('invalid response msg due to missing error code')
        return False
    if err_ret['responseCode'] == 0:
        print('configuring grant renewal success')
        return True
    else:
        print('configuring grant renewal fail with error code %d' % err_ret['responseCode'])
        return False


def transmit_renew_req(renew):
    """
    request format for enable renewal:
      POST xxxx/v1.0/mngTransmitRenew HTTP/1.1 \r\n
      [header items]
      "{mngTransmitRenewRequest: 1}"
    request format for disable renewal:
      POST xxxx/v1.0/mngTransmitRenew HTTP/1.1 \r\n
      [header items]
      "{mngTransmitRenewRequest: 0}"
    """
    if renew:
        msg = HTTP_REQ_HEADER_TRANSMIT_RENEW + HTTP_REQ_BODY_TRANSMIT_RENEW_ENABLE
    else:
        msg = HTTP_REQ_HEADER_TRANSMIT_RENEW + HTTP_REQ_BODY_TRANSMIT_RENEW_DISABLE
    return msg.encode('utf-8')


def transmit_renew_res(msg):
    """
    response format:
      HTTP/1.1 200 OK \r\n
      [header items]
      "{mngTransmitRenewResponse: {"response": {"responseCode":
      0, "responseMessage": "request is approved by SAS"}}}"
    """
    http_p = HttpResponseParser(msg)
    if not http_p.res_parse():
        print('invalid http response')
        return
    if 200 != http_p.get_status():
        print('http status %d' % http_p.get_status())
        return
    msg_json = http_p.get_data()
    msg_body = json.loads(msg_json)
    if RES_MNG_TRANSMIT_RENEW not in msg_body:
        print('invalid %s' % RES_MNG_TRANSMIT_RENEW)
        return False
    free_ret = msg_body[RES_MNG_TRANSMIT_RENEW]
    if 'response' not in free_ret:
        print('invalid response msg due to missing error body')
        return False
    err_ret = free_ret['response']
    if 'responseCode' not in err_ret:
        print('invalid response msg due to missing error code')
        return False
    if err_ret['responseCode'] == 0:
        print('configuring transmit renewal success')
        return True
    else:
        print('configuring transmit renewal fail with error code %d' % err_ret['responseCode'])
        return False


def version_req():
    msg = HTTP_REQ_HEADER_VERSION + HTTP_REQ_BODY_VERSION
    return msg.encode('utf-8')


def version_res(msg):
    """
    response format:
      HTTP/1.1 200 OK \r\n
      [header items]
      "{mngVersionResponse: {"response": {"responseCode": 0,
      "responseMessage": "request is approved by SAS"},
      "version": "V1.2.3", "versionInfo": "compliance with SAS to CBSD protocol V1.0.0"}}"
    """
    http_p = HttpResponseParser(msg)
    if not http_p.res_parse():
        print('invalid http response')
        return
    if 200 != http_p.get_status():
        print('http status %d' % http_p.get_status())
        return
    msg_json = http_p.get_data()
    msg_body = json.loads(msg_json)
    if RES_MNG_VERSION not in msg_body:
        print('invalid %s' % RES_MNG_VERSION)
        return False
    ver_ret = msg_body[RES_MNG_VERSION]
    if 'response' not in ver_ret:
        print('invalid response msg due to missing error body')
        return False
    err_ret = ver_ret['response']
    if 'responseCode' not in err_ret:
        print('invalid response msg due to missing error code')
        return False
    if err_ret['responseCode'] != 0:
        print('get server version fail with error code %d' % err_ret['responseCode'])
        return False
    if 'version' in ver_ret:
        print('SAS server version: %s' % ver_ret['version'])
    if 'versionInfo' in ver_ret:
        print('version info: %s' % ver_ret['versionInfo'])
    return True


def update_option_blocked_request_req(tag):
    """
    request format:
      POST xxxx/v1.0/mngOptionBlockRequest HTTP/1.1 \r\n
      [header items]
      "{mngBlockRequestRequest: 'xxxxxxxx'}"
    """
    body = {}
    body[REQ_MNG_OPTION_BLOCK_REQUEST] = tag
    msg = HTTP_REQ_HEADER_OPTION_BLOCK_REQUEST + json.dumps(body)
    return msg.encode('utf-8')


def update_option_blocked_request_res(msg):
    """
    response format:
      HTTP/1.1 200 OK \r\n
      [header items]
      "{mngBlockRequestResponse: {"response": {"responseCode": 0}}"
    """
    http_p = HttpResponseParser(msg)
    if not http_p.res_parse():
        print('invalid http response')
        return
    if 200 != http_p.get_status():
        print('http status %d' % http_p.get_status())
        return
    msg_json = http_p.get_data()
    msg_body = json.loads(msg_json)
    if RES_MNG_OPTION_BLOCK_REQUEST not in msg_body:
        print('invalid %s' % RES_MNG_OPTION_BLOCK_REQUEST)
        return False
    ver_ret = msg_body[RES_MNG_OPTION_BLOCK_REQUEST]
    if 'response' not in ver_ret:
        print('invalid response msg due to missing error body')
        return False
    err_ret = ver_ret['response']
    if 'responseCode' not in err_ret:
        print('invalid response msg due to missing error code')
        return False
    if err_ret['responseCode'] != 0:
        print('get server version fail with error code %d' % err_ret['responseCode'])
        return False
    return True


def update_option_connection_reject_req(ipaddr):
    """
    request format:
      POST xxxx/v1.0/mngOptionConnectionReject HTTP/1.1 \r\n
      [header items]
      "{mngConnectionRejectRequest: 'xxxxxxxx'}"
    """
    body = {}
    body[REQ_MNG_OPTION_CONNECTION_REJECT] = ipaddr
    msg = HTTP_REQ_HEADER_OPTION_CONNECTION_REJECT + json.dumps(body)
    return msg.encode('utf-8')


def update_option_connection_reject_res(msg):
    """
    response format:
      HTTP/1.1 200 OK \r\n
      [header items]
      "{mngConnectionRejectResponse: {"response": {"responseCode": 0}}"
    """
    http_p = HttpResponseParser(msg)
    if not http_p.res_parse():
        print('invalid http response')
        return
    if 200 != http_p.get_status():
        print('http status %d' % http_p.get_status())
        return
    msg_json = http_p.get_data()
    msg_body = json.loads(msg_json)
    if RES_MNG_OPTION_CONNECTION_REJECT not in msg_body:
        print('invalid %s' % RES_MNG_OPTION_CONNECTION_REJECT)
        return False
    ver_ret = msg_body[RES_MNG_OPTION_CONNECTION_REJECT]
    if 'response' not in ver_ret:
        print('invalid response msg due to missing error body')
        return False
    err_ret = ver_ret['response']
    if 'responseCode' not in err_ret:
        print('invalid response msg due to missing error code')
        return False
    if err_ret['responseCode'] != 0:
        print('get server version fail with error code %d' % err_ret['responseCode'])
        return False
    return True


def cbsd_func():
    req = cbsd_req()
    ret = data_send_recv(req)
    if ret[0]:
        cbsd_res(ret[1].decode('utf-8'))


def blist_func():
    req = blist_req()
    ret = data_send_recv(req)
    if ret[0]:
        blist_res(ret[1].decode('utf-8'))


def blist_add_func(items):
    req = blist_add_req(items)
    ret = data_send_recv(req)
    if ret[0]:
        blist_add_res(ret[1].decode('utf-8'))


def blist_del_func(items):
    req = blist_del_req(items)
    ret = data_send_recv(req)
    if ret[0]:
        blist_del_res(ret[1].decode('utf-8'))


def ppa_func():
    req = ppa_req()
    ret = data_send_recv(req)
    if ret[0]:
        ppa_res(ret[1].decode('utf-8'))


def ppa_add_func(items):
    req = ppa_add_req(items)
    ret = data_send_recv(req)
    if ret[0]:
        ppa_add_res(ret[1].decode('utf-8'))


def ppa_del_func(items):
    req = ppa_del_req(items)
    ret = data_send_recv(req)
    if ret[0]:
        ppa_del_res(ret[1].decode('utf-8'))


def grant_suspend_func(cbsd, grant):
    req = grant_suspend_req(cbsd, grant)
    ret = data_send_recv(req)
    if ret[0]:
        grant_suspend_res(ret[1].decode('utf-8'))


def grant_terminate_func(cbsd, grant):
    req = grant_terminate_req(cbsd, grant)
    ret = data_send_recv(req)
    if ret[0]:
        grant_terminate_res(ret[1].decode('utf-8'))


def grant_free_func(cbsd, grant):
    req = grant_free_req(cbsd, grant)
    ret = data_send_recv(req)
    if ret[0]:
        grant_free_res(ret[1].decode('utf-8'))


def grant_renew_func(renew):
    req = grant_renew_req(renew)
    ret = data_send_recv(req)
    if ret[0]:
        grant_renew_res(ret[1].decode('utf-8'))


def transmit_renew_func(renew):
    req = transmit_renew_req(renew)
    ret = data_send_recv(req)
    if ret[0]:
        transmit_renew_res(ret[1].decode('utf-8'))


def version_func():
    req = version_req()
    ret = data_send_recv(req)
    if ret[0]:
        version_res(ret[1].decode('utf-8'))


def update_option_blocked_request_func(messageTag):
    req = update_option_blocked_request_req(messageTag)
    ret = data_send_recv(req)
    if ret[0]:
        update_option_blocked_request_res(ret[1].decode('utf-8'))


def update_option_connection_reject_func(ipaddr):
    req = update_option_connection_reject_req(ipaddr)
    ret = data_send_recv(req)
    if ret[0]:
        update_option_connection_reject_res(ret[1].decode('utf-8'))


def server_conf_func(ip, port=None):
    global server_ip
    server_ip = ip
    print('change server ip to %s' % server_ip)
    if port is not None:
        global server_port
        if isinstance(port, int):
            server_port = port
            print('change server port to %s' % server_port)
        if isinstance(port, str) or isinstance(port, unicode):
            if port.isdigit():
                server_port = int(port)
                print('change server port to %s' % server_port)
            else:
                print('port %s is not valid' % port)


def tls_mode_func(tls):
    global tls_enable
    if tls:
        if tls_enable:
            print('TLS mode is already enabled')
        else:
            tls_enable = tls
            print('TLS mode is enabled')
    elif not tls:
        if not tls_enable:
            print('TLS mode is already disabled')
        else:
            tls_enable = tls
            print('TLS mode is disabled')


def get_config():
    global KEY_FILE
    global CERT_FILE
    config = ConfigParser.ConfigParser()
    # read the same config file used by SAS_Sim
    config.read('SAS_Sim.conf')
    if config.has_option(sec, 'key_file_name'):
        KEY_FILE = config.get(sec, 'key_file_name')
    if config.has_option(sec, 'cert_file_name'):
        CERT_FILE = config.get(sec, 'cert_file_name')


# main loop
def main_loop():
    while (True):
        cmd_line = raw_input('#')
        cmd_par = cmd_line.split(None)
        if len(cmd_par) == 0:
            continue
        elif cmd_par[0] == 'help' or cmd_par[0] == '?':
            print(HELP)
        elif cmd_par[0] == 'cbsd':
            cbsd_func()
        elif cmd_par[0] == 'blacklist':
            blist_func()
        elif cmd_par[0] == 'blacklist_add':
            if len(cmd_par) == 2:
                blist_add_func(cmd_par[1])
            else:
                print('invalid parameter')
        elif cmd_par[0] == 'blacklist_del':
            if len(cmd_par) == 2:
                blist_del_func(cmd_par[1])
            else:
                print('invalid parameter')
        elif cmd_par[0] == 'PPA':
            ppa_func()
        elif cmd_par[0] == 'PPA_add':
            if len(cmd_par) == 2:
                ppa_add_func(cmd_par[1])
            else:
                print('invalid parameter')
        elif cmd_par[0] == 'PPA_del':
            if len(cmd_par) == 2:
                ppa_del_func(cmd_par[1])
            else:
                print('invalid parameter')
        elif cmd_par[0] == 'grant_suspend':
            if len(cmd_par) == 3:
                grant_suspend_func(cmd_par[1], cmd_par[2])
            else:
                print('invalid parameters')
        elif cmd_par[0] == 'grant_terminate':
            if len(cmd_par) == 3:
                grant_terminate_func(cmd_par[1], cmd_par[2])
            else:
                print('invalid parameters')
        elif cmd_par[0] == 'grant_free':
            if len(cmd_par) == 3:
                grant_free_func(cmd_par[1], cmd_par[2])
            else:
                print('invalid parameters')
        elif cmd_par[0] == 'grant_renew':
            if len(cmd_par) == 1:
                print('missing parameter')
            elif len(cmd_par) == 2:
                if cmd_par[1] == 'enable':
                    grant_renew_func(True)
                elif cmd_par[1] == 'disable':
                    grant_renew_func(False)
                else:
                    print('invalid parameter')
            else:
                # will not reach here
                print('too many parameters')
        elif cmd_par[0] == 'transmit_renew':
            if len(cmd_par) == 1:
                print('missing parameter')
            elif len(cmd_par) == 2:
                if cmd_par[1] == 'enable':
                    transmit_renew_func(True)
                elif cmd_par[1] == 'disable':
                    transmit_renew_func(False)
                else:
                    print('invalid parameter')
            else:
                # will not reach here
                print('too many parameters')
        elif cmd_par[0] == 'server_version':
            version_func()
        elif cmd_par[0] == 'server_conf':
            if len(cmd_par) == 1:
                print('missing parameter')
            if len(cmd_par) == 2:
                server_conf_func(cmd_par[1])
            elif len(cmd_par) == 3:
                server_conf_func(cmd_par[1], cmd_par[2])
            else:
                print('too many arguments')
        elif cmd_par[0] == 'tls':
            if len(cmd_par) == 1:
                print('missing parameter')
            elif len(cmd_par) == 2:
                if cmd_par[1] == 'enable':
                    tls_mode_func(True)
                elif cmd_par[1] == 'disable':
                    tls_mode_func(False)
                else:
                    print('invalid parameter')
            else:
                # will not reach here
                print('too many parameters')
        elif cmd_par[0] == 'block':
            if len(cmd_par) == 1:
                print('missing parameter')
            elif len(cmd_par) == 2:
                update_option_blocked_request_func(cmd_par[1])
            else:
                # will not reach here
                print('too many parameters')
        elif cmd_par[0] == 'connection_reject':
            if len(cmd_par) == 1:
                print('missing parameter')
            elif len(cmd_par) == 2:
                update_option_connection_reject_func(cmd_par[1])
            else:
                # will not reach here
                print('too many parameters')
        elif cmd_par[0] == 'exit':
            break
        else:
            print('invalid cmd, use help to show all valid cmd')


# main entry
if __name__ == '__main__':
    try:
        print("Welcome to SAS-Manager and type help for usage")
        main_loop()
    except SystemExit:
        print("system exit!")
    except KeyboardInterrupt:
        print("keyboard interrupt!")
    except GeneratorExit:
        print("generator exit!")
    except Exception:
        print('error or warning detect!')
    finally:
        print("SAS-Manager end")
