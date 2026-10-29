# -*- coding: utf-8 -*
"""
Author: yulu
Contacts: lu.1.yu@nokia-sbell.com
"""

import re


def get_pdsch_patternid_from_pdml(file_path):
    with open(file_path) as f:
        tex = f.read()
    pkt_re = re.compile(r'<packet>([\w\W]*?)</packet>')
    pkt = str(pkt_re.findall(tex))
    proto_re = re.compile(r'field name="DlData_PdschGrant.patternId_item"([\w\W]*?)/>')
    proto = str(proto_re.findall(pkt))
    showname_re = re.compile(r'showname="patternId_item_([\w\W]*?)"')
    showname = str(showname_re.findall(proto))
    pid_re = re.compile(r'\(Uint16\): (\d*)')
    pid = pid_re.findall(showname)
    pid = list(map(int, pid))
    return pid


def get_patternid_from_pdml(file_path):
    with open(file_path) as f:
        tex = f.read()
    pkt_re = re.compile(r'<packet>([\w\W]*?)</packet>')
    pkt = str(pkt_re.findall(tex))
    proto_re = re.compile(r'<proto name="uldata_puschreceivereq" showname="patternId \(StaticFixedSizedArray\)"'
                          r'([\w\W]*?)</proto>')
    proto = str(proto_re.findall(pkt))
    showname_re = re.compile(r'showname="patternId_item_([\w\W]*?)"')
    showname = str(showname_re.findall(proto))
    pid_re = re.compile(r'\(([\d]*?)\)')
    pid = pid_re.findall(showname)
    pid = list(map(int, pid))
    return pid
