"""
:copyright: Nokia Networks
:author: Abderrahmane Nezrouk
:contact: abderrahmane.nezrouk@nokia.com
:maintainer: abderrahmane.nezrouk@nokia.com
:contact: abderrahmane.nezrouk@nokia.com
"""

from pyparsing import *
import re
from datetime import datetime as dt

# from operator import xor
__author__ = 'Abderrahmane Nezrouk'


def msg_instance(qcat_dict):
    msg_instance = []
    if bool(qcat_dict):
        from ute_common_abstract_core.message import Message
        meta_data = qcat_dict['meta_data'].copy()
        if not bool(qcat_dict['message']):
            return Message({}, meta_data)
        if 'RRC OTA' in meta_data['description']:
            msg_dict = ConvertAsnToPythonStructure(qcat_dict['message'])
        else:
            msg_dict = ConvertRLCMACL2L2ToPythonStructure(qcat_dict['message'])
        s = msg_dict.get()
        for item in s:
            if bool(item):
                msg_instance.append(Message(item, meta_data))

    return msg_instance


def fileparser(qdml_file, custom_filter=None):
    '''
    input:
        qmdl converted text file path
        custom filter
                custom_filter =[1, '0x1FF0','0x1FFB', '0x1FFC']
                1 : to exclude.
                0 : to include.
    '''
    filter_data = [True, []]
    if custom_filter is not None:
        if len(custom_filter) > 1 and custom_filter[0] in [0, 1]:
            filter_data = [bool(custom_filter[0]), custom_filter[1:]]
    start = False
    start_time = None
    packet_start = False
    qcat_dict = {}
    pattern = re.compile(
        r'^(?P<date_time>\d{4}\s*\w+\s*\d{1,2}\s*\d+:\d+:\d+\.\d+)\s*\S+\s*(?P<id>\S+)\s*(?P<description>([\w ]+))'
        r'(--)?(?P<subtitle>([\w /]+))?')
    packet_pattern = re.compile(r'^(Version\s*(0[xX])?[0-9a-fA-F]+\s*{\s*$|value\s*\S*\s*::=\s*$)')
    skip_pattern = re.compile(r'^=====|^Further decoding|^Interpreted PDU:|\n$|^\s*$')
    for line in qdml_file:
        matched_skip = skip_pattern.match(line)
        matched = pattern.match(line)
        if matched and not skip_pattern.match(line):
            if bool(matched.groupdict()['id'] in filter_data[1]) != filter_data[0]:
                start = True
                packet_start = False
                lines = line
                date_time = dt.strptime(matched.groupdict()['date_time'], '%Y %b %d %H:%M:%S.%f')
                if start_time is None:
                    start_time = date_time
                if qcat_dict:
                    yield qcat_dict
                qcat_dict = {
                    'meta_data': {
                        'date_time': matched.groupdict()['date_time'],
                        'timestamp': (date_time - start_time).total_seconds(),
                        'id': matched.groupdict()['id'],
                        'description': matched.groupdict()['description'].strip(),
                        'subtitle': None if not bool(matched.groupdict()['subtitle']) else matched.groupdict()[
                            'subtitle'].strip()
                    },
                    'message': ''
                }
            else:
                start = False
                packet_start = False
        elif start:
            if not packet_start:
                packet_matched = packet_pattern.match(line)
                if packet_matched:
                    packet_start = True
            if packet_start:
                qcat_dict['message'] += line
    yield qcat_dict


class ConvertAsnToPythonStructure(object):
    # Athor Przemyslaw Daniel modified by Abderrahmane NEZROUK
    '''
    Example input:
    --------------------------------------------------------------------------------
    value UL-DCCH-Message ::=
    {
      message c1 : ulInformationTransfer :
      {
            criticalExtensions c1 : ulInformationTransfer-r8 :
                {
                  dedicatedInfoType dedicatedInfoNAS : '279B1832F2016741D22EBD4A1D'H
                }
          }
    }

    Output:
    ---------------------------------------------------------------------------------
    {"UL-DCCH-Message": { "message": { "c1": {
          "ulInformationTransfer": {
            "criticalExtensions": { "c1": {
                "ulInformationTransfer-r8": {
                  "dedicatedInfoType": {
                    "dedicatedInfoNAS": "'279B1832F2016741D22EBD4A1D'H"
    }}}}}}}}}
    '''

    def __init__(self, data):
        self.data = data

        expr = Forward()
        LP = Suppress('{')
        RP = Suppress('}')
        DD = Optional(Suppress(':'))
        DE = Suppress('::=')
        key = Word(alphanums + '-')
        value = (Word(alphanums + '-') | Regex(r"(?:'|\").*?(?:'|\").?", flags=re.MULTILINE | re.DOTALL))
        adict = Forward()
        adict << Group(key + DD + (Group(adict) | expr | value)).setParseAction(lambda t: ["!DICT", t])
        bdict = Group(key + DD + (Group(adict) | expr | value)) | expr
        delim_list = (LP + delimitedList(value | expr) + RP).setParseAction(lambda t: ["!LIST", t])
        delim_dict = (LP + delimitedList(bdict) + RP).setParseAction(lambda t: ["!DICT", t])
        empty_dict = (LP + RP).setParseAction(lambda t: ["!DICT", []])
        expr << Group(delim_list | delim_dict | empty_dict | adict)
        header = Regex(r"value .+ ::=")
        full_expr = Suppress(SkipTo(header)) + Suppress("value") + Group(key + DE + expr)
        full_expr = full_expr.setParseAction(lambda t: ["!DICT", t])
        full_expr = OneOrMore(Group(full_expr)).setParseAction(lambda t: ["!LIST", t])

        self.pased_data = full_expr.parseString(self.data).asList()

    def _create_structer(self, parsed_data):
        if parsed_data[0] == '!DICT':
            out = {}
            for k in parsed_data[1]:
                out[k[0]] = self._create_structer(k[1])
            return out
        if parsed_data[0] == '!LIST':
            out = []
            for k in parsed_data[1]:
                out.append(self._create_structer(k))
            return out

        return parsed_data

    def get(self):
        '''
        '''
        ret = self._create_structer(self.pased_data)
        return ret


class ConvertRLCMACL2L2ToPythonStructure(object):
    '''
    # Athor Abderrahmane NEZROUK
    Example input:
    --------------------------------------------------------------------------------
    Version 65538 {
    MacVersion {
        Major.Minor = 1
        2
    }
    Log Fields Change BMask = 0x0000
    Num Records = 1
    Records {
        Num Requested BSR = 0
        Num Sent BSR = 226
        Num Padding BSR = 87
        Num Regular BSR = 0
        Num Periodic BSR = 0
        Num Cancel BSR = 0
        Num Periodic PHR = 0
        Num Pathloss Change PHR = 0
        Num Config Change PHR = 2
        Num SCell Add PHR = 0
        Num Power Backoff Change PHR = 0
        Average BSR = { 0, 219043332096, 0, 0 }
        Grant Received = 0
        Grant Utilized = 0
        Grant Requested = 0
    }
    }

    Output:
    ---------------------------------------------------------------------------------
    {
    'Version 65538': {
        'Records': {
            'Num Power Backoff Change PHR': '0',
            'Num Config Change PHR': '2',
            'Num Padding BSR': '87',
            'Num Cancel BSR': '0',
            'Num Pathloss Change PHR': '0',
            'Num Sent BSR': '226',
            'Num Periodic PHR': '0',
            'Num Periodic BSR': '0',
            'Num Requested BSR': '0',
            'Num SCell Add PHR': '0',
            'Grant Utilized': '0',
            'Average BSR': '{ 0, 219043332096, 0, 0 }',
            'Grant Received': '0',
            'Num Regular BSR': '0',
            'Grant Requested': '0'
            },
        'Log Fields Change BMask': '0x0000',
        'Num Records': '1',
        'MacVersion': {
            '2': None,
            'Major.Minor': '1'
            }
        }
    }
    '''

    def __init__(self, data):
        self.data = data

        left_curlyBracket, right_curlyBracket, equals = map(Suppress, '{}=')
        key = Word(alphanums + ' []().-_')
        value = OneOrMore(Word(alphanums) + Optional(Suppress(',')))  # + Optional(Suppress('\n'))
        item = Forward()
        expr = Group(key + Group(left_curlyBracket + ZeroOrMore(item) + right_curlyBracket))
        Data_Block = Group(left_curlyBracket + OneOrMore(expr | value) + right_curlyBracket)
        key_with_value = Group(key + equals + (Data_Block | restOfLine)("value")).setParseAction(self._custom_parser)
        key_without_value = Group(key + empty().addParseAction(lambda: [None])).setParseAction(lambda t: dict([t[0]]))

        item <<= expr | key_with_value | key_without_value

        full_expr = OneOrMore(Group(item)).setParseAction(lambda t: ["!LIST", t])

        self.pased_data = full_expr.parseString(self.data)

    def _custom_parser(self, tokens):
        k, v = tokens[0]
        return ({k: str(v)})

    def _strip_dicts(self, data):
        return ([self._strip_dict(v) for v in data])

    def _strip_dict(self, data):
        dic = {}
        for k, v in data.iteritems():
            k = k.strip()
            if isinstance(v, dict):
                v = self._strip_dict(v)
            elif v is not None:
                v = v.strip()
            dic.update({k: v})
        return dic

    def _create_structer(self, parsed_data):
        if not bool(parsed_data):
            return None
        if parsed_data[0] == '!LIST':
            out = []
            for k in parsed_data[1]:
                out.append(self._create_structer(k))
            return out
        out = {}
        if not hasattr(parsed_data[0], '__iter__'):
            out[parsed_data[0]] = self._create_structer(parsed_data[1])
        else:
            for k in parsed_data:
                if isinstance(k, dict):
                    out.update(k)
                else:
                    out.update(self._create_structer(k))
        return out

    def get(self):
        '''
        return: object instance
        '''
        ret = self._create_structer(self.pased_data)
        ret = self._strip_dicts(ret)
        return ret
