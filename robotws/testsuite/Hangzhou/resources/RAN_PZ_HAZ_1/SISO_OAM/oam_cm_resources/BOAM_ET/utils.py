# -*- coding: utf-8 -*-
"""
:<Change Log>
:2017-10-21  Lin licai   first creatation
:2019-03-04  Lin licai   update and add UT for python3
:
:copyright: Nokia
:author: Lin Licai
:contact: lin.licai@nokia-sbell.com.cn
"""

import subprocess
import time
import xml.etree.ElementTree
import xml.dom.minidom


def Get_maxValue(valueList):
    """this keyword to get max value.

    | Input Parameters | Man. | Description |
    | valueList | Y | Input a list for number  |
    | return    | max Value will be returned from input number list|

    Example:
    | Get_maxValue | [2,6,7,8,5] |
    """
    return max(valueList)


def Get_minValue(valueList):
    """this keyword to get minial value.

    | Input Parameters | Man. | Description |
    | valueList | Y | Input a list for number  |
    | return    | minial Value will be returned from input number list|

    Example:
    | Get_minValue | [2,6,7,8,5] |
    """
    return min(valueList)


def Get_avgValue(valueList):
    """this keyword to get avg value.

    | Input Parameters | Man. | Description |
    | valueList | Y | Input a list for number  |
    | return    | avg Value will be returned from input number list|

    Example:
    | Get_avgValue | [2,6,7,8,5] |
    """
    return sum(valueList)/len(valueList)


def Get_Timestamp():
    """this keyword to return current timestamp.

    | Input Parameters | Man. | Description |
    | NA | NA | NA |

    Example:
    | Get_Timestamp | |
    """
    Now = int(time.time())
    timeArray = time.localtime(Now)
    timeStamp = time.strftime("%Y%m%d%H%M%S", timeArray)
    return timeStamp


def start_wireshark(log_path):
    """this keyword to capture wireshark log on localhost.

    | Input Parameters | Man. | Description |
    | log_path | Y | input the path to save wireshark log |

    Example:
    | start_wireshark | /opt/log/btsmsg.cap |
    """
    if _is_linux_root():
        cmd = 'tcpdump -i lo host localhost -s 0 -w %s &' % log_path
    else:
        cmd = 'sudo tcpdump -i lo host localhost -s 0 -w %s &' % log_path
    subprocess.check_call(cmd, shell=True)


def filter_record_in_ruem_log(filepath, tag):
    '''
    param: filepath: delta plan path
    param: tag: logger component, eg: asm
    '''
    et = xml.etree.ElementTree.parse(filepath)
    root = et.getroot()
    namespaces = {'i': 'http://www.nokia.com'}
    record_R = []
    for record in root.findall('./i:record', namespaces):
        for operation in record.findall('./i:operation', namespaces):
            if operation.text == tag:
                record_R.append(record)
    print(record_R)
    record_list = []
    i = 0
    for record in record_R:
        print(record)
        record_list.append({})
        record_list[i].update(record.attrib)
        for child in record:
            record_list[i][str(child.tag).split('}')[-1]] = child.text
        i = i + 1
    return record_list


def Get_Soap_Message_Value(file, parameter):
    """this keyword to get soap specific message value.

    Example:
    | Get_Soap_Message_Value(f.txt, 'ne3scommon:contentTyper') |
    """
    dom = xml.dom.minidom.parse(file)
    root = dom.documentElement
    cc = dom.getElementsByTagName(parameter)
    c1 = cc[0].firstChild.data
    return c1


if __name__ == "__main__":
    str = [1, 3, 5, 8, 10, 13]
    maxValue = Get_maxValue(str)
    print("1.KW Get_maxvalue(str) verify result: %s " % maxValue)
    minValue = Get_minValue(str)
    print("2.KW Get_minValue(str) verify result: %s " % minValue)
    TS = Get_Timestamp()
    print("3.KW Get_Timestamp() verify result: %s " % TS)
    avgValue = Get_avgValue(str)
    print("4.KW Get_avgValue(str) verify result: %s " % avgValue)
