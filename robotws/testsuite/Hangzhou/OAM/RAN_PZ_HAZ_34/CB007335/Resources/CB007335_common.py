# -*- coding: utf-8 -*-

import requests
from lxml import etree


def Get_plan_version(release_folder_name='SBTS22R2_packages'):
    url = 'http://10.135.157.75:8081/artifactory/mn5gran_hzlog-local/' + release_folder_name + '/'
    r = requests.get(url)
    html = etree.HTML(r.text)
    content = html.xpath('//a')
    version_name = content[len(content)//2].text[:-1]
    get_url = url + version_name
    package_name = version_name + '_release_BTSSM_downloadable_A54.zip'
    return get_url, package_name


def Get_BTS_Version_name(version):
    package = version.split('_')[2]
    if package == '9999':
        release_folder_name = 'SBTS00_packages'
    else:
        package_version = version.split('_')[0]
        release_folder_name = package_version + '_packages'
    return release_folder_name
