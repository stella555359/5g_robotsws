# -*- coding: utf-8 -*-


import re
from taf.ul.vdu.helm import helm
import time
import logging
from SSHLibrary import SSHLibrary
import json
from taf.transport.ssh import ssh
from datetime import datetime, timedelta


def parse_output_with_ps_format_to_dict(output):
    pods_info = {}
    keys = []
    if 'No resources found' in output:
        raise Exception('No pods found in the current environment')
    for line in output.splitlines():
        if not keys:
            if line.strip().startswith('NAME'):
                line = re.sub(r'(\S+) (\S+)', r"\g<1>_\g<2>", line).strip()
                keys.extend([key.lower().replace(" ", "_")
                             for key in line.split()])
                continue
        items = line.split()
        if len(items) != len(keys):
            restarts_index = keys.index('restarts')
            if items[restarts_index] != 0:
                for i in len(keys), len(items):
                    items.pop(restarts_index+1)
            if len(items) != len(keys):
                raise Exception('No pods found in the current environment')
        pod_info = {}
        for i, key in enumerate(keys):
            pod_info[key] = items[i]
        if pod_info:
            pods_info[pod_info['name']] = pod_info
    return pods_info


def wait_until_next_minutes(wait_minutes=10):
    current_time = datetime.now()
    next_min = (current_time + timedelta(minutes=wait_minutes -
                                         current_time.minute % wait_minutes)).replace(second=0, microsecond=0)
    wait_seconds = (next_min - current_time).total_seconds()
    time.sleep(wait_seconds)
