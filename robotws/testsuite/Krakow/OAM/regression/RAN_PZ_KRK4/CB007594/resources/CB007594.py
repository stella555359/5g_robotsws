from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.bts.connections.device_aliases import ssh_bts_du
from moler.device import DeviceFactory
from moler.util.moler_test import MolerTest
from moler.exceptions import CommandFailure
from robot.libraries.BuiltIn import BuiltIn
from taf.transport.ssh import ssh
import os
import logging
import re

Common_dir = '/home/scpadm/loads/ASIR/'
Server_IP = "10.66.12.164"
Server_username = "test"
Server_password = "test"

Csn = ssh()


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def download_asir_webem(load_build, path, bts_id=0, du_id=0):
    """
    Download ASIR WebEM.

    :return: None
    """
    device = DeviceFactory.get_device(ssh_bts_du.format("GNB", bts_id, du_id), initial_state="PROXY_PC")
    wget_cmd = device.get_cmd(cmd_name="wget", cmd_params={
        "options": "--header='X-JFrog-Art-Api:"
                   " AKCp8oiHU5YPce4g24nY4H9XxoVHAVzcydFrggjst4Ym8FPW7jnEnLDyTDbkNk6ma5XV2NC95' "
                   "https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local"
                   "/build/{0}/{1}/{1}_ASIRWEBEM.zip -O {2}/{1}_ASIRWEBEM.zip".format(load_build.split("_")[0],
                                                                                      load_build, path)})
    wget_cmd(timeout=120)
    wunzip_cmd = device.get_cmd(cmd_name="unzip", cmd_params={
        "zip_file": "{}/{}_ASIRWEBEM.zip".format(path, load_build),
        "extract_dir": path,
        "options": "-qo"
    })
    wunzip_cmd(timeout=120)


def download_offline_asir_webem_from_local_server(load_build, dest_dir):
    """
    Main Function:
        This method used to download offline asir webem tool from local common load server, parse it into target
        directory after download completion.

    Arguments:
        :param load_build: sw load build info, format should be similar to 'SBTS00_ENB_9999_210622_000005'
        :param dest_dir: destination dir for the parsed executable offline asir webem tool

    Return Value:
        :return asir_resource_list: A list of file

    Examples:
        | Download Offline Asir Webem From Local Server | load_build=SBTS00_ENB_9999_211128_000007 |
        | ...  dest_dir=${OUTPUT DIR} |

    Version:
        | Author | Version | Delivery Date | Comments |
        | Sun Jingang | 1.0.0 | 2021/10/09 | First approved version by VA |
        | Wang Cuicui | 1.0.1 | 2022/01/11 | Improvement to return file list |
    """

    remote_dir = os.path.join(Common_dir, load_build)
    asir_webem_name = load_build + '_ASIRWEBEM.zip'
    parse_cmd = "unzip -qo {0} -d {1}".format(os.path.join(dest_dir, asir_webem_name), dest_dir)

    download_asir_webem(load_build, dest_dir)
    asir_file_name = os.path.join(dest_dir, asir_webem_name)
    asir_index_file = os.path.join(dest_dir, 'index.html')
    asir_resource_list = [asir_file_name, asir_index_file]
    return asir_resource_list


def remove_unused_offline_asir_webem_resource(to_remove_list):
    """
    Main Function:
        This method used to remove old unused offline asir WebEM tool/snapshot related resources
        in order to save disk space.

    Arguments:
        :param to_remove_list: list of file absolute path that parpare to remove

    Return Value:
        :return None

    Examples:
        | Remove Unused Offline Asir Webem Resource | to_remove_list=${file_list} |

    Version:
        | Author | Version | Delivery Date | Comments |
        | Sun Jingang | 1.0.0 | 2021/10/09 | First approved version by VA |
        | Wang Cuicui | 1.0.1 | 2022/01/11 | Improvement to delete file list |
    """

    rm_cmd = "rm -f {0}"
    for item in to_remove_list:
        logging.info("remove from directory{}".format(item))
        os.system(rm_cmd.format(item))
