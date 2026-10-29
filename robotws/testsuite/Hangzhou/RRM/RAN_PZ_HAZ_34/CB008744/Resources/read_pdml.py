# -*- coding: utf-8 -*
"""
Author: yulu
Contacts: lu.1.yu@nokia-sbell.com
"""

import re


# get patternId from pdml
def get_patternId_from_pdml(file_path):
    f = open(file_path)
    tex = f.read()
    f.close
    pkt_re = re.compile(r'<packet>([\w\W]*?)</packet>')
    pkt = str(pkt_re.findall(tex))
    proto_re = re.compile(r'<proto name="uldata_pucchreceivereq" showname="patternId \(StaticFixedSizedArray\)"'
                          r'([\w\W]*?)</proto>')
    proto = str(proto_re.findall(pkt))
    showname_re = re.compile(r'showname="patternId_item_([\w\W]*?)"')
    showname = str(showname_re.findall(proto))
    pid_re = re.compile(r'\(([\d]*?)\)')
    pid = pid_re.findall(showname)
    pid = list(map(int, pid))
    return pid
