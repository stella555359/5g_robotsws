#!/usr/bin/env python
# -*- coding: utf-8 -*-


import requests
import re


def get_last_release(product):
    url = 'http://files.ute.nsn-rdnet.net/builds/enb/base/'
    html = requests.get(url).text
    requests.adapters.Default_RETRIES = 5
    s = requests.session()
    s.keep_alive = False
    release_list = []
    if product == 'vcu':
        release_date_list = re.findall(r'<a href="vCUCNF2(.*?)/"', html)
        largest_release = re.split(r'_', "vCUCNF2" + max(release_date_list))
    elif product == 'vdu':
        release_date_list = re.findall(r'<a href="vDUCNF2(.*?)/"', html)
        largest_release = re.split(r'_', "vDUCNF2" + max(release_date_list))
    else:
        release_date_list = re.findall(r'<a href="SBTS2(.*?)/"', html)
        largest_release = re.split(r'_', "SBTS2" + max(release_date_list))
    return largest_release[0]


if __name__ == "__main__":
    print(get_last_release('gnb'))
