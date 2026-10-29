# -*- coding: utf-8 -*-
"""
Author: Liu, Renhui     Xiang Liangliang
Contacts: renhui-david.liu@nokia-sbell.com
Description: this script is used to analyze TTI logs
"""
import re
import os.path

from log_metadata import *
from common_utils import run_local_command, extract_files_from_zip_file
from common_log_analysis import check_rules_from_csv_file
import taf.sbts.oam.coam.admin as coam

CLOUDRAN_TRUNK_PREFIX = "vDUCNF00"
MCSHARK_TOOL_LINK = "https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/MCShark"
MCSHARK_PATH_PREFIX = "/home/ute/artifactory/wslte5g_plugins-local/MCShark"
tti_dec_path = "/opt/tti-dec"


def check_tti_logs(log_path, analysis_dict, is_combine_dl_ul=True, product_type=None):
    """
    *Usage:*
        - Keyword
        - First, filter the content from TTI logs based on specific conditions and save it to CSV files.
        - Secondly, verify the CSV files against the conditions specified in the analysis_dict.
    *Contact:*
        - renhui-david.liu@nokia-sbell.com
    """
    if product_type is None:
        log_metadata = load_log_metadata(log_path)
        product_type = log_metadata['product_type']
    log_directory = get_log_directory(log_path)
    download_and_install_tti_deb(log_path, product_type=product_type)
    csv_file_paths = convert_tti(log_directory, log_path, is_combine_dl_ul, timeout="60")
    print(f"csv_file_paths: {csv_file_paths}")
    is_pass = False
    output = None
    result_dict = {}
    for index, rule in enumerate(analysis_dict):
        for file_path in csv_file_paths:
            res_check = check_rules_from_csv_file(file_path, rule)
            if res_check[0]:
                result_dict[index] = res_check
                break
        else:
            result_dict[index] = (False, None)
    return result_dict


def convert_tti(tti_trace_dir, tti_archive, is_combine_dl_ul, timeout="60"):
    """
    *Usage:*
        - Used to convert tti to csv files for cloudRAN bts.
    *Contact:*
        - renhui-david.liu@nokia-sbell.com
    """
    tti_trace_dir = tti_trace_dir.rstrip("/") + "/"
    decoded_log_dir = os.path.join(tti_trace_dir, "decoded_log")
    tti_file_paths = extract_files_from_zip_file(tti_archive, tti_trace_dir, postfix='.pcap')
    tti_csv_file_paths = []
    for tti_file_path in tti_file_paths:
        tti_basename = os.path.basename(tti_file_path)
        tti_filename = os.path.splitext(tti_basename)[0]
        decoder_cmd = "if [ ! -d {} ]; then mkdir -p {}; fi; " \
                      "source {}/venv/bin/activate; cd {}; " \
                      "python3 {}/tti-dec-bin/TtiTraceDecoder.py {} excelCsv --timeout 10000" \
                      " -o {}".format(decoded_log_dir, decoded_log_dir, tti_dec_path,
                                      decoded_log_dir, tti_dec_path, tti_file_path, tti_filename)

        if is_combine_dl_ul:
            decoder_cmd = decoder_cmd + " --combineDlAndUl; deactivate;"
        print("decoder_cmd:", decoder_cmd)
        output = run_local_command(command=decoder_cmd).strip()
        print("The result of decoding tti log:\n", output)
        get_csv_filename_cmd = f"find {decoded_log_dir} -maxdepth 1 -type f -name '*.csv'"
        lines = run_local_command(get_csv_filename_cmd)
        file_paths = lines.strip().splitlines()
        tti_csv_file_paths.extend(file_paths)
    return list(set(tti_csv_file_paths))


def get_sw_release(bts_host="192.168.255.129"):
    admin = coam.admin()
    conn = admin.connect_to(bts_host=bts_host)
    sw_version = conn.get_sw_version()
    split_version = sw_version.split('_')
    release, trunk_flag = split_version[0], split_version[2]
    if trunk_flag == '9999':
        release = 'SBTS00'
    version_part = "_".join(split_version[1:])
    bts_version = f"{release}_{version_part}"
    admin.teardown()
    return release, bts_version


def download_and_install_tti_deb(log_path, tool_name_postfix="_tti-dec.deb", product_type="gnb"):
    tmp_tti_path = "/home/ute/tmp_tti_deb"
    if product_type == "gnb":
        bts_release, bts_version = get_sw_release()
        url = "artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/"
    else:
        log_metadata = load_log_metadata(log_path)
        bts_version = log_metadata['bts_version']
        bts_release = bts_version.split('_')[0]
        url = "https://artifactory-mn-espoo3.int.net.nokia.com/artifactory/" \
              "mnp5g-central-public-local/System_Release/"
    pkg_name = bts_version + tool_name_postfix
    pkg_url = os.path.join(url, bts_release, bts_version, pkg_name)

    install_pkg_cmd = "if [ ! -d {} ]; then mkdir -p {}; fi; " \
                      "if [ ! -d {} ]; then cd {}; wget {}; " \
                      "sudo apt install ./{}; fi; " \
                      "sudo chmod +x {}/tti-dec-bin/TtiTraceDecoder.py;".format(tmp_tti_path, tmp_tti_path,
                                                                                tti_dec_path, tmp_tti_path,
                                                                                pkg_url, pkg_name,
                                                                                tti_dec_path)
    output = run_local_command(install_pkg_cmd).strip()
    print("The result of install_pkg_cmd command:", output)


if __name__ == "__main__":
    log_path = ('/home/ute/results/Liang_Kw_Test_20241128075927/T103_dcap_Classical_gnb_20241128075927/dcap1729045524'
                '.2887876.zip')
    check_tti_logs(log_path, analysis_dict=None, product_type="vdu")
