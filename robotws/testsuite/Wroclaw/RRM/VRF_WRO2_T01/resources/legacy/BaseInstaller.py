import os
import re
import requests
import sys
from abc import abstractmethod

from taf.sbts.oam.coam.admin import admin


class Installer:
    def __init__(
            self,
            save_path,
            installer_name,
            file_name_pattern,
            root_url="https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build",
            target_dir=''
    ):
        self._target_dir = target_dir
        self._save_path = save_path
        self._root_url = root_url
        self._url = ''
        self._installer_name = installer_name
        self._file_name_pattern = file_name_pattern
        self._parsed_sw = ''
        self._err_ctx = 'None'

    @abstractmethod
    def _install(self):
        pass

    # This method get full SW version name and returns striped SW name. It
    # means that this removes prefix and zeroes.
    @staticmethod
    def _get_short_sw_version(self, sw_version):
        tmp = sw_version[10:]
        splitted_tmp = tmp.split('_')

        short_sw_version = ''
        for full_sw_name_part in splitted_tmp:
            short_sw_version += full_sw_name_part.lstrip('0') + '.'

        short_sw_version = short_sw_version.rstrip('.')

        return short_sw_version

        # File downloading using requests library. It opens two files: source file form url and target on HDD.
        # Writing to a file is portioned and described by buff_size.
        # Writer takes buff_size(default 128) bytes and writes them to a target
        # file till the target file EOF.

    def _download_file(self, buff_size=1024):
        self._save_path = self._save_path.format(self._parsed_sw)
        r = requests.get(self._url, stream=True)
        print('* Trying to get {}'.format(self._url))
        if r.status_code == 404:
            err_msg = "Can't find {}".format(self._err_ctx)
            assert False, err_msg

        print('* Downloading')
        try:
            # Below lines are commented to check stdout buffer overload issue. Progress bar is missing right now.
            # total_size = int(r.headers['Content-Length'].strip())
            # downloaded_size = 0
            with open(self._save_path, 'wb') as fd:
                for chunk in r.iter_content(chunk_size=buff_size):
                    # downloaded_size += len(chunk)
                    fd.write(chunk)
                    # done = int(50 * downloaded_size / total_size)
                    # sys.stdout.write("\r[%s%s]" %
                    #                  ('=' * done, ' ' * (50 - done)))
                    # sys.stdout.flush()
        except Exception as e:
            assert False, e
            print(e)
        print('\n')

        r.close()

    # *** If you are using robotframework use this function as keyword ***
    # *** assertions help you investigate problems in robot code ****
    # Main function it does whole class logic.
    # It uses taf library to get SW version then calls parse and download method.
    # If file is ready method copies luashark to self._luashark_root_dir
    # It removes .zip and unzipped files.
    # Previous lua is removed as well.
    def download_and_install(self, save_path=None, sw_version=None):
        if save_path:
            self._save_path = save_path
        if not sw_version:
            print('* Connecting to API')
            api = admin()
            conn = api.connect_to()
            sw_version = conn.get_sw_version()
            api.teardown()
        print(sw_version)
        self._parse_url(sw_version)
        self._download_file()

        if not os.path.exists(self._target_dir) and self._target_dir:
            os.system('sudo mkdir {}'.format(self._target_dir))

        print('* Installing')
        self._install()

    def usage(self):
        print(
            "Usage:\n"
            "python: python {}.py -> to run\n"
            "robot: use 'download and install' as keyword\n".format(
                self._installer_name))

    def _parse_url(self, sw_version):
        print('* Parsing url')
        branch_name = sw_version.split('_')[0]
        # Trunk is named 22R* in WEBEM but in WTF it is named as SBTS00
        if '9999' in re.findall('[9]+', sw_version):
            branch_name = 'SBTS00'
            founded_branch_name = re.findall('SBTS2[0-9]R[0-9]', sw_version)
            if founded_branch_name:
                sw_version = sw_version.replace(
                    founded_branch_name[0], 'SBTS00')
        self._url = self._root_url + \
            "/{}/{}/{}".format(branch_name, sw_version, self._file_name_pattern.format(sw_version))
        self._parsed_sw = sw_version
