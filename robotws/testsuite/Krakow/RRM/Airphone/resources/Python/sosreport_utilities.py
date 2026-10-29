"""
:copyright: Nokia Networks
:author: Kamil Pokusa
:maintainer: Kamil Pokusa
:contact: kamil.pokusa@nokia.com
:team: MN_RAN_L2_SW_2_KRK_CntDlv_SG
"""

import os
import glob
import tarfile

from testsuite.Krakow.RRM.Airphone.resources.Python.file_management import unzip_file
from testsuite.Krakow.RRM.Airphone.resources.Python.utilities import logger_console


def unzip_files_from_sosreport(
        zip_file_name="btsSnapshot.zip",
        zipped_log_path="./Snapshot",
        logs_to_collect=None):
    """
    Unzip sosreport and get particular files

            Parameters:
                    zip_file_name (str): name of SosReport file
                    zipped_log_path (str): path to SosReport file
                    logs_to_collect (list): tuple of log's name. Avaliable option:
                        - tti_trace,
                        - snapshot_ue_app,
                        - snapshot_gnb,
                        - syscom_ap,
                        - biplog_gNB,
                        - basic_config,
                        - egate_console,
                        - iphy,
                        - scf,
                        - gnb_swconfig
                        - ap_swconfig

            Returns:
                    nothing
    """
    if logs_to_collect is None:
        logs_to_collect = ["tti_trace", "snapshot_ue_app", "snapshot_gnb", "syscom_ap", "syscom_gnb", "biplog_gNB",
                           "biplog_ue_ap", "basic_config", "egate_console",
                           "iphy", "scf", "gnb_swconfig", "ap_swconfig"]
    dict_for_valid = {
        "syscom_gnb": "_syscom.pcap",
        "biplog_gNB": "bts_tcpdump_L2L1_bip_filtering_off.pcap",
        "biplog_ue_ap": "UEAPP_tcpdump_L2L1_bip_filtering_off.pcap",
        "gnb_swconfig": "/bts/conf/swconfig.txt",
        "ap_swconfig": "/UEAPP/conf/swconfig.txt",
        "scf": "SCF.xml",
        "iphy": "iphy.xml",
        "egate_console": "egate_console.log",
        "basic_config": "basic_config.cfg",
        "snapshot_ue_app": "UeAppSnapshot.zip",
        "syscom_ap": "syscom.pcap",
        "snapshot_gnb": "btsSnapshot.zip",
    }
    if "tti_trace" in logs_to_collect:
        _get_tti_traces_gnb_from_sosreport(zip_file_name, zipped_log_path)
        logs_to_collect.remove("tti_trace")
    for item in logs_to_collect:
        _unzipp_sosreport_and_search_for_file_pattern(
            zip_file_name,
            zipped_log_path,
            dict_for_valid[item]
        )
        logger_console(f"File {item}")
    if "gnb_swconfig" in logs_to_collect:
        os.system(f"mv {zipped_log_path}/unzipped/bts/conf/swconfig.txt "
                  f"{zipped_log_path}/unzipped/bts/conf/gnb_swconfig.txt")
    if "ap_swconfig" in logs_to_collect:
        os.system(f"mv {zipped_log_path}/unzipped/UEAPP/conf/swconfig.txt "
                  f"{zipped_log_path}/unzipped/UEAPP/conf/ap_swconfig.txt")
    if "biplog_gNB" in logs_to_collect:
        _merge_splitted_pcaps(f"{zipped_log_path}/unzipped/bts")
    if "biplog_ue_ap" in logs_to_collect:
        _merge_splitted_pcaps(f"{zipped_log_path}/unzipped/UEAPP")


def _get_tti_traces_gnb_from_sosreport(zip_file_name, zipped_log_path):
    """
    Get ttitrace file from snapshot from sosreport

        Parameters:
                zip_file_name (str): name of SosReport file
                zipped_log_path (str): path to SosReport file

        Returns:
                nothing
    """
    zipped_bts_snapshot_path = os.path.join(zipped_log_path, "unzipped/bts/btsSnapshot.zip")
    destination_bts_snapshot_part = os.path.join(zipped_log_path, "unzipped/bts/")
    _unzipp_sosreport_and_search_for_file_pattern(
        zip_file_name,
        zipped_log_path,
        name_pattern="btsSnapshot.zip"
    )

    unzip_file(zipped_bts_snapshot_path, destination_bts_snapshot_part)
    _tti_trace_unzip(zip_file_name, zipped_log_path)
    os.system(f"cd {zipped_log_path}/unzipped;"
              f"rm -rf bts;")


def _tti_trace_unzip(zip_file_name="btsSnapshot.zip", zipped_log_path="./Snapshot"):
    """
    Unzip tti_traces logs

        Parameters:
                zip_file_name (str): name of SosReport file
                zipped_log_path (str): path to SosReport file

        Returns:
                nothing
    """
    zipped_bts_snapshot_path = os.path.join(zipped_log_path, zip_file_name)
    destination_bts_snapshot = os.path.join(zipped_log_path, "unzipped")
    unzip_file(zipped_bts_snapshot_path, destination_bts_snapshot)
    _transform_bin_file_to_csv(destination_bts_snapshot)


def _transform_bin_file_to_csv(log_path, name_log="2730_L2RT20_L2TtiTrace_EventsSnapshot"):
    """
    Function transform bin file to txt

        Parameters:
                log_path (str): path to folder that includes logs
                name_log (str): name of log file without extension
        Returns:
                If something go wrong program print problem and go forward
                If all go right way, program return nothing
    """
    os.system(f"cd {log_path};"
              f"mv {log_path}/bts/{name_log}.bin {log_path};"
              f"wget https://s3-china-1.eecloud.nsn-net.net/mMIMO-debug-tool/TtiTraceHelper;"
              f"chmod u+x TtiTraceHelper;"
              f"./TtiTraceHelper {name_log}.bin;"
              f"mv {name_log}.dlAndUl.csv {log_path};"
              f"rm -rf cache;"
              f"rm .info.json {name_log}.bin configure.json;")


def _unzipp_sosreport_and_search_for_file_pattern(
        zip_file_name="SosReport.tgz",
        zipped_log_path="./Sosreport_To_test",
        name_pattern=""):
    """
    Unpack part of Sosreport

        Parameters
                zip_file_name (str):      name of Sosreport file
                zipped_log_path (str):    path to folder that contain Sosreport tgz
        Returns:
                Function not return anything
    """
    zipped_bts_sosoreport_path = os.path.join(zipped_log_path, zip_file_name)
    destination_bts_sosoreport = os.path.join(zipped_log_path, "unzipped")

    tar = tarfile.open(zipped_bts_sosoreport_path)
    for item in tar:
        if str(item).find(name_pattern) >= 0:
            tar.extract(item, path=destination_bts_sosoreport)
            logger_console(item)


def _merge_splitted_pcaps(output_dir):
    """
    Merge pcapc files that DCAP splitted into parts for easier validation

    Args:
        output_dir (str): Output directory for merged pcaps
    """
    regex_dict = {'ueapp_bip_filtering': '*UEAPP*L2L1_bip_filtering_off.pcap*',
                  'bts_bip_filtering': '*bts*L2L1_bip_filtering_off.pcap*'}
    for key, value in regex_dict.items():
        pcap_output_file_path = f'{output_dir}/{key}.pcap'
        if os.path.exists(pcap_output_file_path):
            os.remove(pcap_output_file_path)
        file_split_check = glob.glob(f'{output_dir}/{value}')
        if len(file_split_check) > 1:
            logger_console(f'Merging {key} files.')
            os.system(f'cd {output_dir} ; mergecap -a {" ".join(sorted(file_split_check))} -w {key}.pcap')
            for file in file_split_check:
                os.remove(file)
        elif len(file_split_check) == 1:
            os.rename(file_split_check[0], f'{output_dir}/{key}.pcap')
