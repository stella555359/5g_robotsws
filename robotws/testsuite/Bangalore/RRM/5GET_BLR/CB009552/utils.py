from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
import os
from ipaddress import IPv6Address, ip_address
import json
from lxml import etree
import yaml
import re
from IPy import IP
import traceback
import socket
from robot.libraries.OperatingSystem import OperatingSystem
from robot.libraries.String import String
import datetime
from dateutil import parser
import time
import csv
import openpyxl
import copy
import sys
import random
from io import BytesIO
from zipfile import ZipFile
import gzip
import logging
import uuid
from taf.hw.fhgw.cli import cli
from pprint import pprint
import os.path
import linecache
import ipaddress

log_format = "%(asctime)s - %(levelname)s - %(message)s"
logging.basicConfig(level=logging.DEBUG, format=log_format)

try:
    from cStringIO import StringIO
except ImportError:
    try:
        from StringIO import StringIO
    except ImportError:
        from io import StringIO

issh_cli = cli()

__all__ = [
    "get_value_for_key",
    "parse_snapshot_file_list",
]


def get_value_for_key(dictionary, value):
    for key, val in dictionary.items():
        if val == value:
            print(aaaa)
            return key
    return key


def parse_snapshot_file_list(snapshot_dir):
    """
    Parse the snapshot_file_list.txt to get the parent zip file and the sub-files in it.

    *AUTHOR*: calla.wang@nokia-sbell.com

    :param str snapshot_dir: snapshot directory in UTE, like /home/ute/snapshot
    :return: dict of file content, like
    {'MRBTS-10776_metadata.txt': [],
     'MRBTS-10776_E044_part_1.zip:': ['MRBTS-10776_E042_runtime_cpidInfo.log',
                                      'MRBTS-10776_E046_runtime_cpidInfo.log',
                                      'MRBTS-10776_E048_runtime_cpidInfo.log',
                                      'MRBTS-10776_E047_runtime_cpidInfo.log',
                                      'MRBTS-10776_E020_runtime_cpidInfo.log',
                                      'MRBTS-10776_E045_runtime_cpidInfo.log'
                                      ]
    }
    """
    if not os.path.isdir(snapshot_dir):
        raise Exception('snapshot file list not exist!')
    cont = {}
    flag = False
    value_list = []
    snapshot_list_file = os.path.join(snapshot_dir, 'snapshot_file_list.txt')
    with open(snapshot_list_file, 'r') as f:
        for line in f.readlines():
            if not len(line.strip()):
                continue
            if line.startswith('\t') or line.startswith(' '):
                value_list.append(line.strip())
            else:
                if flag:
                    cont[key] = value_list
                key = line.strip().strip(':')
                flag = True
                value_list = []
        if flag:
            cont[key] = value_list
    return cont
