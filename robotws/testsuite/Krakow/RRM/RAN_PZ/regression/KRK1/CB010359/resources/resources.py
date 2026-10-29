import os
import re
import glob
import shutil
import logging

from robot.errors import ExecutionFailed
from ta5g_commissioning import ta5g_commissioning
from ta5g_cell_operations import ta5g_cell_operations


def extract_dcap_logs(dcap_zip_dir, output_dir, merged_pcap_name, logs_to_collect=['tti_trace']):
    """
    Function for extracting logs from DCAP zip file
        :param dcap_zip_dir:        Dcap zip file location.
        :param output_dir:          Desired location for log extraction.
        :param merged_pcap_name:    Name of the pcap file as the result from merging
        :param logs_to_collect:     Optional, List of desired logs to be extracted.
                                          Defaults to ['sherpa', 'syslog', 'bip', 'emil', 'tti_trace', 'pm_counters',
                                          'snapshot', 'scf'].
    """
    dcap_logs_dir = f'{dcap_zip_dir}/dcap_unzipped'
    zipped_dcap_dir = f'{dcap_zip_dir}/{merged_pcap_name}'
    _find_and_extract_dcap(dcap_zip_dir=dcap_zip_dir, dcap_logs_dir=dcap_logs_dir)
    _find_and_move_files(dcap_logs_dir=dcap_logs_dir, output_dir=output_dir, logs_to_collect=logs_to_collect)
    _merge_splitted_pcaps(output_dir=output_dir, merged_pcap_name=merged_pcap_name)
    _move_zippped_pcap(dcap_logs_dir=dcap_zip_dir, output_dir=zipped_dcap_dir)


def _merge_splitted_pcaps(output_dir, merged_pcap_name):
    """
    Merge pcap files that DCAP splitted into parts for easier validation
        :param output_dir:          Output directory for merged pcaps
        :param merged_pcap_name:    Name of the pcap file as the result from merging
    """
    tti_files_list = glob.glob(f'{output_dir}/*L2_COMPONENT.pcap')
    if len(tti_files_list) > 1:
        logging.info(f'Merging tti_trace files.')
        os.system(f'cd {output_dir} ; mergecap -a {" ".join(sorted(tti_files_list))} -w '
                  f'tti_trace-{merged_pcap_name}.pcap')
        for source_file in tti_files_list:
            os.remove(source_file)
    elif len(tti_files_list) == 1:
        os.rename(tti_files_list[0], f'{output_dir}/tti_trace.pcap')


def _find_and_extract_dcap(dcap_zip_dir, dcap_logs_dir):
    """
    Unpack dcap to selected directory
        :param dcap_zip_dir:    Location of DCAP zip directory
        :param dcap_logs_dir:   Destination of unzipped DCAP files
    """
    try:
        dcap_file_name = glob.glob(fr'{dcap_zip_dir}/dcap_*.*.zip')[0]
        shutil.unpack_archive(dcap_file_name, dcap_logs_dir)
    except IndexError:
        raise ExecutionFailed('Dcap file not found.')
    else:
        logging.info(f'{dcap_file_name} unpacked successfully.')


def _find_and_move_files(dcap_logs_dir, output_dir, logs_to_collect):
    """
    This function locates logs specified in 'logs_to_collect', moves them to desired location and simplifies log files
    names.
        :param dcap_logs_dir:       Location with unzipped dcap files
        :param output_dir:          Desired end location for dcap logs
        :param logs_to_collect:     List of desired logs to be located and moved
    """
    regex_dict = {'sherpa': r'.*SHERPA.pcap', 'emil': r'.*5gm', 'bip': r'.*bip*.*.zip',
                  'syslog': r'.*_Syslog_*.', 'tti_trace': r'.*L2_COMPONENT.pcap', 'snapshot': r'.*Full_snapshot.zip',
                  'pm_counters': r'.*getPmFiles.zip', 'scf': r'.*_scf.xml'}

    for source_file in glob.glob(fr'{dcap_logs_dir}/**/*', recursive=True):
        for log_type in logs_to_collect:
            if re.match(regex_dict[log_type], source_file):
                if log_type == 'tti_trace':
                    shutil.move(source_file, f'{output_dir}/{os.path.basename(source_file)}')
                else:
                    shutil.move(source_file, f'{output_dir}/{log_type}{os.path.splitext(source_file)[1]}')
                logging.info(f'Moving {os.path.basename(source_file)} file.')
    _delete_folder(output_dir, 'dcap_unzipped')


def _delete_folder(folder_path, folder_name):
    if os.path.exists(f'{folder_path}/{folder_name}'):
        shutil.rmtree(f'{folder_path}/{folder_name}')
        logging.info(f'{folder_name} folder deleted.')


def _move_zippped_pcap(dcap_logs_dir, output_dir):
    """
        This function locates zipped dcap and moves it to desired location.
            :param dcap_logs_dir: Location with zipped dcap logs
            :param output_dir: Desired end location for zipped dcap logs
        """
    path = os.path.join(dcap_logs_dir, output_dir)
    if not os.path.exists(path):
        os.mkdir(path)
    source_files = os.listdir(dcap_logs_dir)
    for source_file in source_files:
        if source_file.startswith('dcap') and source_file.endswith('.zip'):
            shutil.move(os.path.join(dcap_logs_dir, source_file), os.path.join(output_dir, source_file))


def activate_feature_flag_for_all_cells():
    """
          This function activates flag actDlPaWarmUp in gNB configuration
          """
    cell_id_list = ta5g_cell_operations().get_list_of_all_cells_ids()
    for cell_id in cell_id_list:
        dist_name = 'MRBTS-262569/NRBTS-262569/NRCELL-{}'.format(cell_id)
        ta5g_commissioning().perform_parameter_commissioning(parameter='actDlPaWarmUp', value='true',
                                                             dist_name=dist_name)


def deactivate_feature_flag_for_all_cells():
    """
          This function deactivates flag actDlPaWarmUp in gNB configuration
          """
    cell_id_list = ta5g_cell_operations().get_list_of_all_cells_ids()
    for cell_id in cell_id_list:
        dist_name = 'MRBTS-262569/NRBTS-262569/NRCELL-{}'.format(cell_id)
        ta5g_commissioning().perform_parameter_commissioning(parameter='actDlPaWarmUp', value='false',
                                                             dist_name=dist_name)
