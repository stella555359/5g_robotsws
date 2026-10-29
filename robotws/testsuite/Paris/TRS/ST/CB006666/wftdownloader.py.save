# -*- coding: utf-8 -*-
__author__ = """"Szymon Kramczynski"""
__contact__ = """szymon.kramczynski@nokia.com"""

import requests
import bs4
import os
import lxml
import time
# import exceptions
import sys


def download_software(software_table, download_path, soft_build, btssm=False, puttibatti=False,
                      download_proxies=''):
    if not type(software_table) == list:
        software_table = [software_table]
    status_table = []
    for soft in software_table:
        print("soft: {}".format(soft))
        link_from_xml = _retrive_xml_link(soft, download_path, download_proxies, soft_build, btssm, puttibatti)
        print("links: {}".format(link_from_xml))
        for link in link_from_xml:
            if link:
                status = _download_file(link, soft, download_path, download_proxies)
                if status:
                    print("Downloaded Successfully")
                    status_table.append(status)
                    # return True
                else:
                    print("Unable to download file")
                    status_table.append(status)
            else:
                # unable o get link
                print(link)
                status_table.append(False)
    print(status_table)
    return status_table


def _retrive_xml_link(soft, download_path, download_proxies, soft_build, btssm, puttibatti):
    try:
        if soft != "":
            response = requests.get("https://wft.int.net.nokia.com/ext/build_content/{0}".format(soft),
                                    proxies=download_proxies)
            soup = bs4.BeautifulSoup(response.content, "lxml")
            if soft_build:
                soft_url = soft_tag(soft, soup)
            else:
                soft_url = ""
            if btssm:
                btssm_url = btssm_tag(soft, soup, download_proxies)
            else:
                btssm_url = ""
            if puttibatti:
                puttibatti_url = puttibatti_tag(soft, soup)
            else:
                puttibatti_url = ""
            print(soft_url, btssm_url, puttibatti_url)
            return [soft_url, btssm_url, puttibatti_url]
    except Exception as e:
        print(e)
        return False


def soft_tag(soft, soup):
    if str("_release_BTSSM_downloadable_A54") in str(soup):
        suffix = "_release_BTSSM_downloadable_A54.zip"
    else:
        suffix = "_release_BTSSM_downloadable_A53.zip"
    if "SBTS" in soft:
        soft_tag = soup.find("file", {'title': '{0}{1}'.format(soft, suffix)})
    else:
        soft_tag = soup.find("file", {'title': '{0}{1}'.format(soft, "_release_BTSSM_downloadable.zip")})
    if soft_tag is None:
        print("soft_tag Was None changing to string")
        soft_tag = ''

    if len(str(soft_tag)) > 0:
        soft_url = soft_tag.get("url")
        if "https" not in str(soft_url):
            soft_url = str(soft_url).replace("http", "https")
        return soft_url
    else:
        print('Unable to retrive link from build content file')
        # hardcoded link if xml with release notes is old (without link)
        # hardcoded_link = _create_url(soft)
        # if "https" not in str(hardcoded_link):
        #     hardcoded_link = str(hardcoded_link).replace("http", "https")
        # return hardcoded_link


def btssm_tag(soft, soup, download_proxies):
    btssm_tag = soup.find("tool", {'title': 'BTS Site Manager Binaries'})
    if btssm_tag is None:
        btssm_tag = ''
    if len(str(btssm_tag)) > 0:
        btssm_origin = btssm_tag.get("origin")
        cname = btssm_origin.split("_")
        release = cname[0]
        if cname[0] == "FL17ASP1":
            release = "FL17A"
        name = "{0}-{1}_{2}_{3}".format(release, cname[2], cname[3], cname[4])
        build = "{0}_BTSSM_{1}_{2}_{3}".format(cname[0], cname[2], cname[3], cname[4])

        response = requests.get("https://wft.int.net.nokia.com/ext/build_content/{0}".format(btssm_origin),
                                proxies=download_proxies)
        btssm_soup = bs4.BeautifulSoup(response.content, "lxml")
        # print btssm_soup
        btssm_base_link = btssm_soup.find("build_artifact", title="SVN", description="BTSSM_Installer").get("url")
        btssm_url = "{0}/C_Element/SE_UICA/Setup/BTSSiteEM-{1}_x64.bin".format(btssm_base_link, name)
        if "https" not in str(btssm_url):
            btssm_url = str(btssm_url).replace("http", "https")

    else:
        print("Empty tag")
        btssm_url = ""
    return btssm_url


def puttibatti_tag(soft, soup):
    if str("_release_puttibatti_A53.zip") in str(soup):
        suffix = "_release_puttibatti_A53.zip"
    else:
        suffix = "_release_puttibatti_A54.zip"
    if "SBTS" in soft:
        puttibatti_tag = soup.find("file", {'title': '{}'.format(soft + suffix)})
    else:
        puttibatti_tag = soup.find("file", {'title': '{}'.format(soft + "_release_puttibatti.zip")})
    if puttibatti_tag is None:
        puttibatti_tag = ''
    if len(str(puttibatti_tag)) > 0:
        puttibatti_url = puttibatti_tag.get("url")
        if "https" not in str(puttibatti_url):
            puttibatti_url = str(puttibatti_url).replace("http", "https")
    else:
        puttibatti_url = ""
    return puttibatti_url


def _create_url(soft):
    if "SBTS" in soft:
        created_link = "{0}{1}/{2}{3}".format("https://10.159.69.245/lteRel/build/", soft.split("_")[0], soft,
                                              "_release_BTSSM_downloadable_A53.zip")
    else:
        created_link = "{0}{1}/{2}{3}".format("https://10.159.69.245/lteRel/build/", soft.split("_")[0], soft,
                                              "_release_BTSSM_downloadable.zip")
    return created_link


def _check_remote_file_size(url, download_proxies):
    try:
        if "btssiteem" in url.lower():
            response = requests.get(url, stream=True, allow_redirects=True, proxies=download_proxies,
                                    auth=("ca_uuf", "ca_uuf_pass"))
        else:
            response = requests.get(url, stream=True, allow_redirects=True, proxies=download_proxies)
        content_size = response.headers['Content-Length']
        # print response.headers
        print("content_size: {}".format(content_size))
        return content_size
    except KeyError:
        calculated_size = str(len(response.content))
        print("calculated_size: {}".format(calculated_size))
        return calculated_size


def _download_file(url, soft, download_path, download_proxies):
    try:
        filename = url.split('/')[-1]
        remote_file_size = int(_check_remote_file_size(url, download_proxies))
        file_exist = check_if_file_exist(download_path, filename)
        if not file_exist:
            if remote_file_size >> 20 > 100:  # should have more than 100 MB
                if "btssiteem" in url.lower():
                    response = requests.get(url, proxies=download_proxies, stream=True, auth=("ca_uuf", "ca_uuf_pass"))
                else:
                    response = requests.get(url, proxies=download_proxies, stream=True)
                if response.status_code == 404:
                    return False
                else:
                    print("File: {}".format(filename))
                    with open("{0}/{1}".format(download_path, filename), 'wb') as f:
                        for chunk in response.iter_content(chunk_size=1024 * 1024):
                            if chunk:
                                f.write(chunk)
                    return True
        else:
            return "Exists"
    except Exception as e:
        print("Error: {}".format(e))
        return False


def check_if_file_exist(download_path, filename):
    if os.path.exists(os.path.join(download_path, filename)):
        return True
    else:
        return False


# if __name__ == '__main__':
#     tab = [
#         'SBTS00_FSM3_9999_181004_010145',
#         # 'FL16A_ENB_0000_005049_000000',
#         # 'FL16A_ENB_0000_006051_000000'
#     ]
#     api_key_wft = "eJthyhsgkSDVhm9KGx0hZS8o61GNXx2fuDUCFuqK"
#     path = "/home/ute/Desktop/Global_veryfication/"
#     for soft in tab:
#         if not os.path.exists("{0}{1}".format(path, soft)):
#             os.makedirs("{0}{1}".format(path, soft))
#         download_software(soft, "/home/ute/Desktop/Global_veryfication/{0}".format(soft), api_key=api_key_wft,
#                           soft_build=True, btssm=True, puttibatti=True)
