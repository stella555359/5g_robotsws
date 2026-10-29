# -*- coding: utf-8 -*-
"""
Author: Wang Yixiang
Contacts: yixiang.x.wang@nokia-sbell.com
Description: Verify counter log

"""
import json
import os
import gzip
import logging
import taf.transport.ssh
from taf.analyzer.pmcounter import PMCounterLogReader


def get_counter_file_name(filepath, counter_group):
    """
    Get counter group file from resultMapping.json, ungz counter file to xml format.

    :param filepath:path of resultMapping.json
    :param counter_group:
    :return: return the latest counter file.
    """
    with open(filepath, 'r')as fp:
        json_data = json.load(fp)
        logging.info(json_data)
    try:
        ret = json_data[counter_group]['filenames']
    except Exception as e:
        logging.info("counter file not found.")
        raise Exception("counter file not found.")
    if len(ret) == 0:
        raise Exception("file length is 0, counter file not found.")
    elif len(ret) >= 1:
        return [ret[0]]


def unzip_and_return_xml(counter_gz_file_path):
    filepath, gz_file_name = os.path.split(counter_gz_file_path)
    xml_path = ungz_packet(filepath=filepath, counter_gz_file_path=counter_gz_file_path)
    return xml_path


def ungz_packet(filepath, counter_gz_file_path):
    """ungz zip file to current filepath"""
    xml_name = os.path.basename(counter_gz_file_path)[:-3]
    xml_path = os.path.join(filepath, xml_name)
    g_file = gzip.GzipFile(counter_gz_file_path)
    open(xml_path, "wb").write(g_file.read())
    g_file.close()
    return xml_path


def get_counter_by_cell(xml_file_name, cell_id, counter_id):
    """
    get counter by cell id and counter id.
    :param file_name: xml file name
    :param cell_id: cell id
    :param counter_id: M55110C00007
    :return:
    """
    with open(xml_file_name) as file_obj:
        for log_entry in PMCounterLogReader([file_obj]):
            return log_entry.pm_setup.xpath("//NRCELL[@id='{cell_id}']//@{counter_id}".
                                            format(cell_id=cell_id, counter_id=counter_id))[0]


def get_counter_value(xml_file_name, counter_id):
    """
    get counter value from xml file
    :param file_name: xml file
    :param counter_id: M55110C00007
    :return:
    """
    with open(xml_file_name) as file_obj:
        for log_entry in PMCounterLogReader([file_obj]):
            return log_entry.pm_setup.xpath(".//@{counter_id}".format(counter_id=counter_id))
