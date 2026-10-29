import gzip
import hashlib
import itertools
import logging
import os
import subprocess
import time
import zipfile
import shutil
import pytz
import tarfile
import pexpect
import re
import json
import xml.dom.minidom
import pexpect
import sys

from threading import Timer
from packaging import version
from lxml import etree
from xml.etree import ElementTree as et
from datetime import datetime
from robot.libraries.BuiltIn import BuiltIn

try:
    from cStringIO import StringIO
except ImportError:
    try:
        from StringIO import StringIO
    except ImportError:
        from io import StringIO

_BTS_INSTALL_FILE = '/var/imp/.impLocation.conf'
_BTS_PROCESS_INFO = ['Standalone']
PING_INFO = {}


def convert_case_name(name):
    return name.replace(' ', '_')


def get_json_value_in_list(json_list, para_name, dist_name, class_name=None):
    if isinstance(json_list, list):
        for json_dict in json_list:
            print('json_dict is % s' % json_dict)
            if isinstance(json_dict, dict):
                if not class_name:
                    if json_dict['dist_name'] == dist_name:
                        return json.loads(json_dict['payload'])[para_name]
                else:
                    if json_dict[distName] == dist_name and json_dict[className] == class_name:
                        return json.loads(json_dict['payload'])[para_name]
