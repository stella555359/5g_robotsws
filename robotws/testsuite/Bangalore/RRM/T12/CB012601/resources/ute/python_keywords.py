import os
import sys
import logging
import xml.etree.ElementTree as ElementTree
from decimal import Decimal


def parse_sw_to_stream(sw_d):
    """
    Script takes parameter sw_version from coam.admin in format: '5G20B_GNB_0000_000800_000612'
    and parses it to stream number: '0.800'
    If it is a knife it looks like: '5G20B_GNB_0000_000800_000612_0ijup_' (Exceptions below are for knife builds)
    """
    try:
        build = '.'.join([str(int(s)) for s in sw_d.split('_')[2:4]])
    except ValueError:
        try:
            build = '.'.join([str(int(s)) for s in sw_d.split('_')[1:3]])
        except ValueError:
            build = '.'.join([str(int(s)) for s in sw_d.split('_')[3:5]])

    return build


def get_nidd_version_from_scf_file(scf_location, managed_object=1):
    """
    :param scf_location: absolute path to SCF file, i.e: "/home/ute/scf.xml"
    :return: (str) NIDD version checked from provided SCF file.
    """
    tree = ElementTree.parse(scf_location)
    try:
        nidd = tree.getroot().find(
            "./{raml}cmData/{raml}managedObject[{object}]".format(
                raml="{raml21.xsd}", object=managed_object)).attrib["version"]
        nidd = nidd.strip() if len(nidd) > 3 else "error"
    except Exception:
        nidd = "error"
    print(nidd)  # do not delete this print, it's necessary!

    return nidd


def add_content_to_file(file_name, content):
    with open(file_name, 'a+') as fh:
        fh.writelines(content)
    return


def cal_data_rate(bytes_rec_int, coll_time_int):
    """
    Method to calculate data rate for Multi UEs.
    """
    data_rate = float(Decimal(bytes_rec_int*8)/Decimal(coll_time_int*1000000))
    print(data_rate)
    return data_rate
