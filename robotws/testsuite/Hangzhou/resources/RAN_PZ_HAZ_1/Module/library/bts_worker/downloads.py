# -*- coding: utf-8 -*-

import json
import subprocess
import sys
import os
import re
import requests
import hashlib
import logging
from functools import partial
logger = logging.getLogger(__name__)


def get_sha(plan_sw_build, **kwargs):
    header = {'accept': 'application/json'}
    sha256 = ''
    wft_access_key = 'S3roP5dXbVm4tlZnIhigteyuUHNlgt8mxe2566VD'
    response = requests.get(
        'https://wft.int.net.nokia.com:8091/api/v1/SBTS/{0}/builds/{1}/storages/results.json?access_key={2}'.format(
            "swcomponent", plan_sw_build, wft_access_key),
        headers=header).json()
    test = response[1].get('storage').get('storage-items')
    file_name = plan_sw_build + '_release_BTSSM_downloadable_A54.zip'
    for i in range(len(test)):

        if test[i].get('title') == file_name:
            print('sha256', test[i].get('hashes'))
            re = test[i].get('hashes')
            sha256 = re['sha256']
            print(sha256)
    return sha256


def sha256_of_file(filename):
    with open(filename, 'rb') as f:
        d = hashlib.sha256()
        for buf in iter(partial(f.read, 128), b''):
            d.update(buf)
        readable_hash = d.hexdigest()
        print("file hash value is %s" % readable_hash)
    return readable_hash
