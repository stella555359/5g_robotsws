from taf.rfrl.procedures.resources.python.tti_decoder.TTI_decoder import TTI_decoder
from testsuite.Wroclaw.RRM.VRF_WRO1_T03.Resources.cm_operations.AdminOperations import AdminOperations
import logging
import os
from shutil import move
import requests
from re import compile, search

log = logging.getLogger()

BASE_URL = os.getenv('BASE_URL', 'https://wft.int.net.nokia.com')
USERNAME = os.getenv('USERNAME', 'klein')
ACCESS_KEY = os.getenv('ACCESS_KEY', 'xXVToFNgyBZaZKdutp5kpHI5R2fzz1TlexkdMQu8')
URL = BASE_URL + f"/api/v1/SBTS/CI_ENB/builds/"
HEADERS = {USERNAME: ACCESS_KEY, "accept": "application/json"}


def get_component_version_from_wft(sw='SBTS25R3_ENB_0000_000301_000000', component='5g-l2-l3-aggregated'):
    url = URL + f'{sw}/sub_builds/configuration/'
    response = requests.get(url, auth=(USERNAME, ACCESS_KEY), headers=HEADERS)
    x = [x for x in response.json()['object'] if x['component'] == component]
    log.info(x[0]['version'])
    return x[0]['version']


class TtiDecoder(TTI_decoder, AdminOperations):
    def __init__(self):
        super().__init__()
        self.sw = None
        self.path = None

    def decode_tti(self, log_file, output_dir, output_format='legacyCsv', message_filter=None,  sw=None):
        if sw is None:
            self.sw = self.get_bts_sw_version()
        else:
            self.sw = sw
        self.sw = convert_sw_name_to_trunk(self.sw)
        self.find_tti_dec_file()
        self.convert_tti_pcap(log_file, output_dir, output_format, message_filter, self.sw)

    def find_tti_dec_file(self):
        version = get_component_version_from_wft(sw=self.sw)
        try:
            self.path = os.listdir('/opt/tti-dec')
            log.info(f'tti exist:{self.path}')
        except FileNotFoundError:
            log.info('decoder not found, start downloading tti decoder')
            self.download_tti_decoder()
        else:
            result = os.popen(f'grep -ril "{version}" /opt/tti-dec/tti-dec-bin/bin/eventDecoder').read()
            if not result:
                log.info('result is empty')
                self.download_tti_decoder()
            else:
                log.info(f'else result {result}')
        return self.path
    # def find_tti_dec_file(self):
    #     try:
    #         self.path = os.listdir('/opt/tti-dec')
    #         log.info(f'tti decoder found:{self.path}')
    #     except FileNotFoundError:
    #         self.download_tti_decoder()
    #         self._tti_decoding_sw_version = self.sw
    #     return self.path

    def download_tti_decoder(self):
        self.get_tti_dec_location()
        os.system(f'wget {self.path}')
        move(f'/home/ute/MN/UTE/robotws/{self.sw}_tti-dec.deb', '/tmp')
        os.system(f'cd /tmp && sudo dpkg -i {self.sw}_tti-dec.deb')
        try:
            self.path = os.listdir('/opt/tti-dec')
        except FileNotFoundError:
            raise TtiDecoderNotInstalled

    def get_tti_dec_location(self):
        url = URL + f'{self.sw}/storages/refresh.json'
        response = requests.get(url, auth=(USERNAME, ACCESS_KEY), headers=HEADERS)
        self.path = list(filter(compile(".*tti-dec.deb").match, response.json()['files']))
        self.path = self.path[0]


class TtiDecoderNotInstalled(Exception):
    def __str__(self):
        return 'Tti decoder not found: /opt/tti-dec'


def convert_sw_name_to_trunk(sw):
    log.info(sw)
    trunk = search('.*ENB_9999.*', sw)
    log.info(trunk)
    if trunk:
        sw = 'SBTS00' + sw[8:]
        log.info(f'new sw name: {sw}')
    return sw
