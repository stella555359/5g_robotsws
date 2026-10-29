# -*- coding: utf-8 -*-

import requests
from lxml import etree
import re


def build_is_exists_via_index(version_index, url, content):
    version_name = content[version_index].text[:-1]
    plan_version = version_name + '_release_BTSSM_downloadable_A54.zip'
    version_folder = url + version_name + "/"
    version_details_file = requests.get(version_folder)
    file_pattern = re.compile(r'>{}</a>\s+\d'.format(plan_version))
    search_result = file_pattern.search(version_details_file.text)
    if search_result:
        file_exists = True
    else:
        file_exists = False
    print(file_exists, version_name)
    return file_exists, version_name


def Get_plan_version(bts_version, release_folder_name='SBTS00'):
    bts_name = get_bts_wft_name(bts_version)
    hz_server = 'https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/'
    url = hz_server + release_folder_name + '/'
    r = requests.get(url)
    html = etree.HTML(r.text)
    content = html.xpath('//a')
    build_list_len = len(content)
    my_index = build_list_len // 2
    file_exists, version_name = build_is_exists_via_index(my_index, url, content)
    while (not file_exists and my_index != build_list_len):
        my_index = build_list_len - (build_list_len - my_index) // 2
        file_exists, version_name = build_is_exists_via_index(my_index, url, content)
        tmp_index = my_index
        if bts_name == version_name:
            for i in range(tmp_index-1, tmp_index-15, -1):
                file_exists, version_name = build_is_exists_via_index(i, url, content)
                if file_exists:
                    break
            if not file_exists:
                for i in range(tmp_index+1, build_list_len, 1):
                    file_exists, version_name = build_is_exists_via_index(tmp_index, url, content)
                    if file_exists:
                        break
    plan_version = version_name + '_release_BTSSM_downloadable_A54.zip'
    get_url = url + version_name + '/' + plan_version
    return get_url, plan_version


def Get_BTS_Version_name(version):
    package = version.split('_')[2]
    if package == '9999':
        release_folder_name = 'SBTS00'
    else:
        package_version = version.split('_')[0]
        release_folder_name = package_version
    return release_folder_name


def get_bts_wft_name(version):
    release_folder_name = Get_BTS_Version_name(version)
    v_list = version.split('_')
    v_list[0] = release_folder_name
    return '_'.join(v_list)


if __name__ == '__main__':
    get_url, plan_version = (
        Get_plan_version(bts_version='SBTS23R3_ENB_0000_001664_000000', release_folder_name='SBTS23R3'))
    print(plan_version)
    # print(get_bts_wft_name('SBTS25R1_ENB_9999_001239_000000'))
