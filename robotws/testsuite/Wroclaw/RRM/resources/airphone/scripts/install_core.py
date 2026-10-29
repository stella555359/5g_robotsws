import os
import sys
import re
import requests
from bs4 import BeautifulSoup
import argparse
RED = '\033[91m'
BOLD = '\033[1m'
NORMAL = '\033[0m'

parser = argparse.ArgumentParser(description='Install core/epcsim')
parser.add_argument('-a', '--air', help='Please provide airhpone build, example -a 11950', required=True)
args = vars(parser.parse_args())
airphone_build = args['air']
airphone_build_link = 'https://hzisoj70.china.nsn-net.net/artifactory/mnp5g-airphone-ci-gen-local/Airphone/4.0.'\
                      + airphone_build + '/AirScale-4.0.' + airphone_build + '.zip'


def check_if_airphone_build_exists():
    airphone_build_does_exist = os.system('cd /home/ute/Desktop\nwget --spider -v ' + airphone_build_link)
    if airphone_build_does_exist != 0:
        sys.exit(
            BOLD + RED + 'Airphone build number: ' + airphone_build +
            ' cannot be found in artifactory\nPlease visit https://hzisoj70.china.nsn-net.net/artifactory/mnp5g-'
            'airphone-ci-gen-local/Airphone/ to ensure your build exists' + NORMAL + '\n')


def get_data_from_website():
    result = requests.get('https://hzisoj70.china.nsn-net.net/artifactory/mnp5g-airphone-ci-gen-local/Airphone/4.0.'
                          + airphone_build)
    webpage_content = result.content
    webpage = BeautifulSoup(webpage_content, "lxml")
    found_build = ''
    for each_build in webpage.findAll('a'):
        if re.match(r".*core2.tar.bz2$", each_build.get('href')):
            found_build = each_build.get('href')
    return found_build


def install_core():
    build = get_data_from_website()
    os.system("rm -rf /opt/iphy/latest\nrm -rf /opt/iphy/essimode\nrm -rf /opt/iphy/*core2*")
    os.system("cd /opt/iphy/\nwget https://hzisoj70.china.nsn-net.net/artifactory/mnp5g-airphone-ci-gen-local/"
              "Airphone/4.0." + airphone_build + "/" + build)
    os.system('mkdir /opt/iphy/essimode\ntar -xvf /opt/iphy/*core2* -C /opt/iphy/essimode')
    os.system('ln -s /opt/iphy/essimode /opt/iphy/latest')


check_if_airphone_build_exists()
install_core()
