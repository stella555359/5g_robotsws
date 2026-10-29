# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Jonah Verzosa
:contact: jonah.verzosa@nokia.com
:maintainer: Michael Liclican, Al-john Vizcarra
:contact: michael.liclican@nokia.com, al-john.vizcarra@nokia.com
"""
from .downloader import Downloader
from ute_common_downloader.connection import Connection
from ute_common_downloader.shell import Shell
from .k3 import k3_data_reader
from SSHLibrary.abstractclient import SSHClientException
from .exception import MissingNsetapVersion, FileDoesNotExist
import re
import subprocess
import os

SVN_ROOT = 'https://svne1.access.nsn.com/isource/svnroot'
ALT_ROOT = 'https://esisov70.emea.nsn-net.net/isource/svnroot'
PLUGIN_PATH = {'2.4': '~/.config/wireshark/plugins/',
               '2.6': '~/.local/lib/wireshark/plugins/2.6/epan',
               '3.0': '~/.local/lib/wireshark/plugins/3.0/epan/'}


def download_k3_files(enb_load, dest, svn_root=SVN_ROOT, **kwargs):
    """ Downloads K3 Files by reading enb specific metafile.ini from files.ute """

    downloader = Downloader(**kwargs)
    ttcn3_src, codec_src, pcmd_ttcn3_src, pcmd_codec_src = _build_k3_download_urls(svn_root, enb_load)
    ttcn3_alt_src, codec_alt_src, pcmd_ttcn3_alt_src, pcmd_codec_alt_src = _build_k3_download_urls(ALT_ROOT, enb_load)

    ttcn3_dest = '{}/k3/plugins/ttcn3'.format(dest)
    files_src_alt_dest_list = [[codec_src, codec_alt_src, dest],
                               [ttcn3_src, ttcn3_alt_src, ttcn3_dest],
                               [pcmd_ttcn3_src, pcmd_ttcn3_alt_src, ttcn3_dest],
                               [pcmd_codec_src, pcmd_codec_alt_src, dest]]

    for src, alt_src, dest in files_src_alt_dest_list:
        try:
            downloader.execute_svn_export(src, dest)
        except SSHClientException:
            downloader.execute_svn_export(alt_src, dest)


def download_ws_lte_files(enb_load, dest, **kwargs):
    """ Downloads wireshark lte files by reading enb specific metafile.ini from files.ute """
    dest = _get_absolute_path(dest or _get_wireshark_plugin_path())
    if not os.path.exists(dest):
        os.makedirs(dest)
    downloader = Downloader(**kwargs)
    nsetap_plugin_src = _build_nsetap_plugin_download_url(enb_load)
    nsetap_plugin_dest = '{dest}/{nsetap_plugin_name}'.format(dest=dest,
                                                              nsetap_plugin_name=nsetap_plugin_src.split('/')[-1])
    downloader.execute_wget(nsetap_plugin_src, nsetap_plugin_dest)


def get_nsetap_version(enb_load=None):
    """ Get NSETAP version in enb specific metafile.ini from files.ute """
    enb_load = enb_load if enb_load else _get_enb_sw_version('192.168.255.129')
    downloader = Downloader()
    try:
        downloader.execute_wget(src=k3_data_reader.MANIFEST_BASE_URL.format(enb_load), dest='/tmp/Manifest.ini')
    except (SSHClientException, FileDoesNotExist):
        enb_load = _convert_trunk_format(enb_load)
        downloader.execute_wget(src=k3_data_reader.MANIFEST_BASE_URL.format(enb_load), dest='/tmp/Manifest.ini')
    manifest_config = k3_data_reader.read_manifest('/tmp/Manifest.ini')
    try:
        return manifest_config['nsetap_version']
    except KeyError:
        raise MissingNsetapVersion("NSETAP version is not included in Manifest.ini of enb load")


def _get_wireshark_version():
    wireshark_info = subprocess.check_output(['dpkg', '-s', 'wireshark']).decode('utf-8').splitlines()
    return ''.join([line.split()[1] for line in wireshark_info if 'Version: ' in line])


def _convert_trunk_format(enb_load):
    return re.sub(r'(?:(?<=SBTS)|(?<=[FT]L))[^_]+(?=_)', '00', enb_load)


def _build_k3_download_urls(svn_root, enb_load):
    nsetap_url = 'NSETAP_{version}'.format(version=get_nsetap_version(enb_load))

    ttcn3_src = '{svn_root}/{k3_trunk}/C_Test/SC_K3LTEASN1/Include/ttcn3'
    ttcn3_src = ttcn3_src.format(svn_root=svn_root, k3_trunk=k3_data_reader.K3_TRUNK_BASE_URL)

    codec_src = '{svn_root}/{k3_trunk}/C_Test/SC_K3LTEASN1/Libraries/redhat64/release/'
    codec_src = codec_src.format(svn_root=svn_root, k3_trunk=k3_data_reader.K3_TRUNK_BASE_URL)

    pcmd_ttcn3_src = '{svn_root}/{k3_pcmd}/{nsetap}/include/ttcn3/PCMDmod.ttcn3'
    pcmd_ttcn3_src = pcmd_ttcn3_src.format(svn_root=svn_root, k3_pcmd=k3_data_reader.K3_PCMD_BASE_URL,
                                           nsetap=nsetap_url)

    pcmd_codec_src = '{svn_root}/{k3_pcmd}/{nsetap}/lib64/release/PCMDlib.so'
    pcmd_codec_src = pcmd_codec_src.format(svn_root=svn_root, k3_pcmd=k3_data_reader.K3_PCMD_BASE_URL,
                                           nsetap=nsetap_url)

    return ttcn3_src, codec_src, pcmd_ttcn3_src, pcmd_codec_src


def _build_nsetap_plugin_download_url(enb_load):
    ws_lte_base_url = 'http://files.ute.nsn-rdnet.net/builds/wireshark/nsetap'
    ws_full_version_name = _get_wireshark_version()
    ws_major_version_name = '.'.join(ws_full_version_name.split('.')[0:2])
    debian_alias = ws_full_version_name.split('+')[1]
    nsetap_version = get_nsetap_version(enb_load)
    nsetap_plugin_url = '{ws_lte_base_url}/nsetap-{ws_major_version_name}-{nsetap_version}+{debian_alias}.so'
    return nsetap_plugin_url.format(ws_lte_base_url=ws_lte_base_url,
                                    ws_major_version_name=ws_major_version_name,
                                    nsetap_version=nsetap_version,
                                    debian_alias=debian_alias)


def _get_enb_sw_version(trs_ip):
    TARGET_BD_REGEX = r'(?<=TargetBD_)\w+(?=\.xml)'
    conn = Connection()
    conn.username = 'toor4nsn'
    conn.password = 'oZPS0POrRieRtu'
    conn.host = trs_ip
    ret = Shell(conn).execute_command('ls /rom/TargetBD_*.xml').strip().decode('utf-8').splitlines()[-1]
    return re.search(TARGET_BD_REGEX, ret).group(0)


def _get_absolute_path(path):
    return os.path.abspath(os.path.expanduser(path))


def _get_wireshark_plugin_path():
    ws_major_version = '.'.join(_get_wireshark_version().split('.')[0:2])
    return PLUGIN_PATH.get(ws_major_version) or PLUGIN_PATH.get('2.4')
