"""This module will install ltepat on the current TL or linux machine.
"""

import subprocess
import pathlib
import requests
import logging

logger = logging.getLogger(__name__)


def install_lte_pat():
    """This will prepare ltepat for use on the current TL or linux machine.
    It will install mono, download and unpack ltepat to the directory '/home/ute/ltepat'.
    If the directory already exists, it will not do anything.
    """
    if pathlib.Path('/home/ute/ltepat/PMKPITool.exe').is_file():
        print('PMKPITool is already installed')
        return
    _get_access_to_packages()
    _update_apt()
    _install_mono()
    _download_and_unpack_ltepat()


def _get_access_to_packages():
    subprocess.run(args=['sudo', 'apt-get', 'install', 'ute-config-repo'], stdout=subprocess.DEVNULL, check=True)


def _update_apt():
    subprocess.run(args=['sudo', 'apt-get', 'update'], stdout=subprocess.DEVNULL, check=True)


def _install_mono():
    subprocess.run(args=['sudo', 'apt-get', 'install', 'mono-complete', '-y'], stdout=subprocess.DEVNULL, check=True)


def _download_and_unpack_ltepat():
    """Modified by AI: 2026-03-11 - Use requests library for URL list with iterative fallback download attempts."""
    download_urls = [
        (
            'http://ltepat.eecloud.dynamic.nsn-net.net/LTEPAT/LTEPATSetup.7z',
            'http://87.254.212.120:8080/'
        ),
        (
            'http://turandot.dynamic.nsn-net.net/share/Performance_Logs/06_ltepat/PMKPITool.7z',
            'http://defra1c-proxy.emea.nsn-net.net:8080'
        ),
    ]
    ltepat_local = pathlib.Path('/home/ute/ltepat/PMKPITool.7z')

    subprocess.run(args=['rm', '-rf', str(ltepat_local.parent)], stdout=subprocess.DEVNULL, check=True)
    subprocess.run(args=['mkdir', str(ltepat_local.parent)], stdout=subprocess.DEVNULL, check=True)
    for download_url, proxy in download_urls:
        proxies = {'http': proxy, 'https': proxy}
        try:
            response = requests.get(download_url, proxies=proxies, timeout=120)
            response.raise_for_status()
            with open(ltepat_local, 'wb') as f:
                f.write(response.content)
            break
        except (requests.RequestException, OSError):
            logger.error('Failed to download LTEPATSetup.7z/PMKPITool.7z from all configured URLs.')
            continue

    subprocess.run(args=f'cd {ltepat_local.parent} && yes | 7za x {ltepat_local.name}',
                   shell=True, stdout=subprocess.DEVNULL, check=True)


if __name__ == '__main__':
    install_lte_pat()
