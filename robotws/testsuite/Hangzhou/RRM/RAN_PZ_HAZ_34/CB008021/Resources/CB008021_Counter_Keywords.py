"""
:copyright: Nokia Networks
:author: Yan Xin
:contact: xin.yan@nokia-sbell.com
:maintainer: Yan Xin
:contact: Yan Xin
"""
import datetime
import gzip
from xml.etree import ElementTree as ET


def get_sleep_time_waiting_for_counter_create(interval):
    """
    Counters will generate at the end of this period, so need to wait until counter you want create.
    :param interval: int, same with nidd parameter miNrRip
    """
    currenttime = datetime.datetime.now()
    return interval-int(currenttime.strftime('%Y%m%d.%H%M00')[11:13]) % interval


def get_non_zero_value_list_from_value_list(value_list):
    tmplist = []
    for elm in value_list:
        if elm != 0:
            tmplist.append(elm)
    return tmplist


def calculate_average_except_zero_value(value_list):
    """
    Calculate average value of all counters' value except zero value
    :param value_list: list, list saved all counters' value get from counter file
    """
    tmplist = get_non_zero_value_list_from_value_list(value_list)
    if len(tmplist) == 0:
        return 0, 0
    else:
        return round(sum(tmplist)/len(tmplist), 2), len(tmplist)


def sorted_list_except_zero_value(value_list):
    tmplist = get_non_zero_value_list_from_value_list(value_list)
    print(tmplist)
    if len(tmplist) == 0:
        return tmplist, 0
    else:
        return sorted(tmplist, reverse=True), len(tmplist)


def get_pm_counter_time_for_file(interval):
    """
    Get pm counter time to match counter file
    :param interval: int, same with nidd parameter miNrRip
    """
    currenttime = datetime.datetime.now()
    adjust_min = int(currenttime.strftime('%Y%m%d.%H%M00')[11:13]) % interval
    targettimepro = currenttime + datetime.timedelta(minutes=-adjust_min) + datetime.timedelta(hours=-8)
    targettime = targettimepro.strftime('%Y%m%d.%H%M00')
    return targettime


def unzip_counter_file(file_name):
    '''
    unzip compressed files
    :param file_name: files name need to depress
    :return: None
    '''
    f_name = file_name.replace('.gz', '')
    g_file = gzip.GzipFile(file_name)
    open(f_name, 'wb+').write(g_file.read())
    g_file.close()


def get_counter_value_from_counter_file(xmlfile, counter_list):
    '''
    :param xmlname: PM file name get
    :param counter_list: dedicated counter list
    :return: counter value
    '''
    root = ET.parse(xmlfile).getroot()
    dic = {}
    for elem in root.findall('./PMSetup/PMMOResult/NE-WBTS_1.0'):
        if elem.get('measurementType') == 'NRRIP':
            # for child in elem.getchildren():
            for child in list(elem):
                for i in counter_list:
                    if child.tag == i:
                        dic[child.tag] = float(child.text)
            break
    return dic
