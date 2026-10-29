import os
import re
import requests
import sys
from abc import abstractmethod
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword

from taf.sbts.oam.coam.admin import admin


class Installer:
    def __init__(
            self,
            save_path,
            installer_name,
            file_name_pattern,
            trunk_sw_prefix='SBTS22R',
            trunk_branch_name='SBTS00',
            root_url="https://lterel.es-si-s3-z4.eecloud.nsn-net.net/build",
            target_dir=''
    ):
        self._target_dir = target_dir
        self._save_path = save_path
        self._root_url = root_url
        self.trunk_sw_prefix = trunk_sw_prefix
        self.trunk_branch_name = trunk_branch_name
        self._url = ''
        self._installer_name = installer_name
        self._file_name_pattern = file_name_pattern
        self._parsed_sw = ''
        self._err_ctx = 'None'

    @abstractmethod
    @logged_keyword
    def _install(self):
        pass

    @staticmethod
    @logged_keyword
    def _get_short_sw_version(sw_version):
        tmp = sw_version[10:]
        splitted_tmp = tmp.split('_')

        short_sw_version = ''
        for full_sw_name_part in splitted_tmp:
            short_sw_version += full_sw_name_part.lstrip('0') + '.'

        short_sw_version = short_sw_version.rstrip('.')

        return short_sw_version

    @logged_keyword
    def _download_file(self, buff_size=1024):
        self._save_path = self._save_path.format(self._parsed_sw)
        r = requests.get(self._url, stream=True)
        blog('Trying to get {}'.format(self._url))
        if r.status_code == 404:
            err_msg = "Can't find {}".format(self._err_ctx)
            assert False, err_msg

        blog('Downloading file...')
        try:
            total_size = int(r.headers['Content-Length'].strip())
            downloaded_size = 0
            with open(self._save_path, 'wb') as fd:
                for chunk in r.iter_content(chunk_size=buff_size):
                    downloaded_size += len(chunk)
                    fd.write(chunk)
                    done = int(50 * downloaded_size / total_size)
                    sys.stdout.write("\r[%s%s]" %
                                     ('=' * done, ' ' * (50 - done)))
                    sys.stdout.flush()
        except Exception as e:
            assert False, e.message

        r.close()

    @logged_keyword
    def download_and_install(self, save_path=None, sw_version=None):
        if save_path:
            self._save_path = save_path
        if not sw_version:
            blog('Connecting to API...')
            api = admin()
            conn = api.connect_to()
            sw_version = conn.get_sw_version()
            api.teardown()
        blog(sw_version)
        self._parse_url(sw_version)
        self._download_file()

        if not os.path.exists(self._target_dir) and self._target_dir:
            os.system('sudo mkdir {}'.format(self._target_dir))

        blog('Installing...')
        self._install()

    @logged_keyword
    def _parse_url(self, sw_version):
        blog('Parsing URL...')
        branch_name = sw_version.split('_')[0]

        if '9999' in re.findall('[9]+', sw_version):
            branch_name = self.trunk_branch_name
            founded_branch_name = re.findall('{}[0-9]'.format(self.trunk_sw_prefix), sw_version)
            if founded_branch_name:
                sw_version = sw_version.replace(
                    founded_branch_name[0], self.trunk_branch_name)
        self._url = self._root_url + \
            "/{}/{}".format(branch_name, self._file_name_pattern.format(sw_version))
        self._parsed_sw = sw_version
