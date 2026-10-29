"""
:copyright: Nokia Networks
:author: Damian Zak
:maintainer: Damian Zak
:contact: damian.zak@nokia.com
:team: MN_RAN_L2_SW_2_KRK_CntDlv_SG
"""

import os
import re
import glob
import shutil

from robot.errors import ExecutionFailed

from testsuite.Bangalore.resources.python.utilities import logger_console


def extract_dcap_logs(dcap_zip_dir, output_dir, logs_to_collect=['sherpa', 'syslog', 'bip', 'emil', 'tti_trace',
                      'pm_counters', 'snapshot', 'scf', 'celltrace']):
    """
    Function for extracting logs from DCAP zip file

    Args:
        dcap_logs_dir (str): Dcap zip file location.
        output_dir (str): Desired location for log extraction.
        logs_to_collect (list, optional): List of desired logs to be extracted.
                                          Defaults to ['sherpa', 'syslog', 'bip', 'emil', 'tti_trace', 'pm_counters',
                                          'snapshot', 'scf'].
    """
    dcap_logs_dir = f'{dcap_zip_dir}/dcap_unzipped'
    _find_and_extract_dcap(dcap_zip_dir=dcap_zip_dir, dcap_logs_dir=dcap_logs_dir, output_dir=output_dir)
    _find_and_move_files(dcap_logs_dir=dcap_logs_dir, output_dir=output_dir, logs_to_collect=logs_to_collect)
    if 'bip' in logs_to_collect:
        _unzip_bip(output_dir=output_dir)
    _merge_splitted_pcaps(output_dir=output_dir)


def _delete_folder(folder_path, folder_name):
    if os.path.exists(f'{folder_path}/{folder_name}'):
        shutil.rmtree(f'{folder_path}/{folder_name}')
        logger_console(f'{folder_name} folder deleted.')


def _find_and_extract_dcap(dcap_zip_dir, dcap_logs_dir, output_dir):
    """
    Args:
        dcap_zip_dir (str): Location of DCAP zip directory
        dcap_logs_dir (str): Destination of unzipped DCAP files
    """
    try:
        dcap_file_name = glob.glob(fr'{dcap_zip_dir}/UTFLab_*.zip')[0]
        shutil.unpack_archive(dcap_file_name, dcap_logs_dir)
    except IndexError:
        raise ExecutionFailed('Dcap file not found.')
    else:
        logger_console(f'{dcap_file_name} unpacked successfully.')


def _find_and_move_files(dcap_logs_dir, output_dir, logs_to_collect):
    """
    This function locates logs specified in 'logs_to_collect', moves them to desired location and simplifies log files
    names.

    Args:
        dcap_logs_dir (str): Location with unzipped dcap files
        output_dir (str): Desired end location for dcap logs
        logs_to_collect (list): List of desired logs to be located and moved
    """
    regex_dict = {'sherpa': r'.*SHERPA.pcap', 'emil': r'.*5gm', 'bip': r'.*bip*.*.zip',
                  'syslog': r'.*_Syslog_*.', 'tti_trace': r'.*L2_component.pcap', 'snapshot': r'.*Full_snapshot.zip',
                  'pm_counters': r'.*getPmFiles.zip', 'scf': r'.*_scf.xml', 'ipCapture': r'.*apture.pcap',
                  'celltrace': r'.*.lcbin'}

    for file in glob.glob(fr'{dcap_logs_dir}/**/*', recursive=True):
        for log_type in logs_to_collect:
            if re.match(regex_dict[log_type], file):
                if log_type == 'tti_trace' or log_type == 'sherpa':
                    shutil.move(file, f'{output_dir}/{os.path.basename(file)}')
                else:
                    shutil.move(file, f'{output_dir}/{log_type}{os.path.splitext(file)[1]}')
                logger_console(f'Moving {os.path.basename(file)} file.')
    _delete_folder(output_dir, 'dcap_unzipped')


def _merge_splitted_pcaps(output_dir):
    """
    Merge pcapc files that DCAP splitted into parts for easier validation

    Args:
        output_dir (str): Output directory for merged pcaps
    """
    regex_dict = {'sherpa': '*SHERPA.pcap', 'tti_trace': '*L2_COMPONENT.pcap', 'L1L2_bip': '*2011*.pcap'}
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


def _unzip_bip(output_dir):
    """
    Function for unpacking and moving bip logs file out of nested dcap compression

    Args:
        output_dir (str): Bip pcap output path
    """
    bip_unzipped_path = f'{output_dir}/bip_unzipped'
    try:
        shutil.unpack_archive(glob.glob(f'{output_dir}/*bip*.zip')[0], bip_unzipped_path)
        for file in glob.glob(f'{bip_unzipped_path}/*'):
            if re.match(r'.*2011*.*.zip', file):
                shutil.unpack_archive(file, output_dir)
        for file in glob.glob(f'{output_dir}/*.xz'):
            if re.match(r'.*2011*.*L2L1*.*.xz', file):
                os.system(f'cd {output_dir} ; unxz {file}')
            else:
                os.remove(file)
    except IndexError:
        logger_console('Bip pcap file not found.')
    else:
        logger_console('Bip logs extracted successfully.')
    if os.path.exists(f'{output_dir}/bip.zip'):
        os.remove(f'{output_dir}/bip.zip')
    _delete_folder(output_dir, 'bip_unzipped')
