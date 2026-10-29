# -*- coding: utf-8 -*-

import os
import re
# import urllib3
# from bs4 import BeautifulSoup
import urllib.request


try:
    from bs4 import BeautifulSoup
except ImportError:
    # import pip
    # pip.main(['install', '--upgrade', 'beautifulsoup'])
    from pip._internal import main
    main(['install', '--upgrade', 'beautifulsoup'])
    from BeautifulSoup import BeautifulSoup

URL = 'http://files.ute.nsn-rdnet.net/builds/enb/base/'


def download_newest_22R3():
    html = urllib.request.urlopen(URL)
    soup = BeautifulSoup(html, features="lxml")
    newest_sw = soup.find_all(
        'a', text=re.compile('.*{}.*'.format('SBTS22R3_ENB_0000'))
    )[-5]
    print(type(newest_sw))
    build = ''
    for i in newest_sw:
        build = build + str(i.text)
        print(i.text)
    build = build[:-1]
    print("build", build)
    # sw_url = sww +'release_BTSSM_downloadable.zip'
    #
    # os.system('wget {} -O /tmp/build/{}.zip'.format(sw_url, newest_sw))
    return build


def download_newest_22R4():
    html = urllib.request.urlopen(URL)
    soup = BeautifulSoup(html, features="lxml")
    newest_sw = soup.find_all(
        'a', text=re.compile('.*{}.*'.format('SBTS22R4_ENB_0000'))
    )[-5]
    print(type(newest_sw))
    build = ''
    for i in newest_sw:
        build = build + str(i.text)
        print(i.text)
    build = build[:-1]
    print("build", build)
    # sw_url = sww +'release_BTSSM_downloadable.zip'
    #
    # os.system('wget {} -O /tmp/build/{}.zip'.format(sw_url, newest_sw))
    return build
