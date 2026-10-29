from io import StringIO
import gzip
import subprocess
import time
import base64
import random
import string
import xml.etree.ElementTree
import datetime
import xml.etree.ElementTree as ET


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


if __name__ == "__main__":
    filter_record_in_ruem_log('AutonomousSecurityEvent')
