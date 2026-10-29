import argparse
import csv
import re
import os
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from moler.device import DeviceFactory


def convert_all_pcaps(directory_path, pcap_files, max_files=2, slots_per_frame=10):
    number_of_parsing_files = 0
    csv_files = {}
    converted_csv_files = {}
    background_cmds = {}
    all_params = [_get_prach_params(directory_path),
                  _get_pusch_params(directory_path)]

    for params in all_params:
        background_cmds[params['name']] = []
        csv_files[params['name']] = []

        for index, pcap_file_name in enumerate(pcap_files):
            number_of_parsing_files = number_of_parsing_files + 1
            pcap_file_path = os.path.join(directory_path, pcap_file_name)

            device = _get_new_device(base_name=params['name'], number=index)
            csv_file, background_cmd = _convert_pcap_to_csv(pcap_file=pcap_file_path,
                                                            fields=params['fields'],
                                                            filters=params['filter'], device=device)

            background_cmds[params['name']].append(background_cmd)
            csv_files[params['name']].append(csv_file)
            if number_of_parsing_files == max_files:
                _wait_when_finish(background_cmds)
                number_of_parsing_files = 0

    for name in background_cmds:
        for cmd in background_cmds[name]:
            cmd.await_done(timeout=20 * 60)

        converted_csv_files[name] = []
        for csv_file in csv_files[name]:
            converted_to_dec = _convert_all_hex_values_to_dec(csv_file)
            converted_csv_files[name].append(converted_to_dec)

    for params in all_params:
        _merge_into_one_csv_file(converted_csv_files[params['name']], params['file_name'])
        _add_asfn_to_csv_file(source_file=params['file_name'], slots_per_frame=slots_per_frame)


def _wait_when_finish(background_cmds):
    for name in background_cmds:
        for cmd in background_cmds[name]:
            cmd.await_done(timeout=20 * 60)


def _get_prach_params(directory_path):
    filters = ['uldata_prachreceiveind']
    fields = [
        'frame.time',
        'frame.time_epoch',
        '3gpp.sfn',
        '3gpp.slot',
        '3gpp.subcellid',
        'UlData_PrachReceiveInd_t.processInRealTime',
        'UlData_PrachReceiveInd_t.sfnForProcessing',
        'UlData_PrachReceiveInd_t.slotForProcessing',
        'UlData_prachReceiveIndSubcell_t.noisePower',
    ]

    merged_csv_file_name = os.path.join(directory_path, 'uldata_prachreceiveind_merged.csv')
    return {'filter': filters, 'fields': fields, 'file_name': merged_csv_file_name, 'name': 'prach'}


def _get_pucch_params(directory_path):
    filters = ['uldata_pucchreceiverespps']

    fields = [
        'frame.time',
        'frame.time_epoch',
        '3gpp.sfn',
        '3gpp.slot',
        '3gpp.subcellid',
        'UlData_PucchReceiveRespPs_t.processInRealTime',
        'UlData_PucchReceiveRespPs_t.sfnForProcessing',
        'UlData_PucchReceiveRespPs_t.slotForProcessing',
        'UlData_pucchReceiveRespPsPucchResource_t.noisePower',
        'UlData_PucchReceiveRespPs_t.subcells.Length',
        'UlData_pucchReceiveRespPsPucchResource_t.pucchFormat',
        'UlData_pucchReceiveRespPsSubcell_t.noisePerPrb_item',
    ]

    merged_csv_file_name = os.path.join(directory_path, 'uldata_pucchreceiverespps_merged.csv')
    return {'filter': filters, 'fields': fields, 'file_name': merged_csv_file_name, 'name': 'pucch'}


def _get_pusch_params(directory_path):
    filters = ['uldata_puschreceiverespps']
    fields = [
        'frame.time',
        'frame.time_epoch',
        '3gpp.sfn',
        '3gpp.slot',
        '3gpp.subcellid',
        'UlData_PuschReceiveRespPs_t.processInRealTime',
        'UlData_PuschReceiveRespPs_t.sfnForProcessing',
        'UlData_PuschReceiveRespPs_t.slotForProcessing',
        'UlData_puschReceiveRespPsSubcell_t.noisePower',
        'UlData_PuschReceiveRespPs_t.subcells.Length',
        '3gpp.rnti',
        'UlData_puschReceiveRespPsSubcell_t.noisePerPrb_item',
    ]

    merged_csv_file_name = os.path.join(directory_path, 'uldata_puschreceiverespps_merged.csv')
    return {'filter': filters, 'fields': fields, 'file_name': merged_csv_file_name, 'name': 'pusch'}


def _get_new_device(base_name, number):
    source_device = 'UnixLocal'
    new_device = DeviceFactory.get_cloned_device(source_device=source_device,
                                                 new_name='{}_{}_{}'.format(source_device, base_name, number))
    return new_device


def _convert_all_hex_values_to_dec(source_file, output_file=None):
    """
    Convert all hex to dec number in source_file and save to output_file
    :param source_file:  path to csv file
    :param output_file:  path to output file -
    :return:
    """
    if not output_file:
        file_name, extension = os.path.splitext(source_file)
        output_file = "{}_converted{}".format(file_name, extension)
    lcells = []
    llines = []
    with open(source_file, 'r') as f:
        reader = csv.reader(f, delimiter=',')
        for row in reader:
            for cell in row:
                if re.match(r"(0x[0-9a-fA-F]+)", cell):
                    cell = int(cell, 16)
                lcells.append(cell)
            llines.append(lcells)
            lcells = []

    with open(output_file, 'w') as new_f:
        writer = csv.writer(new_f, delimiter=',')
        writer.writerows(llines)

    return output_file


def _add_asfn_to_csv_file(source_file, output_file=None, slots_per_frame=20):
    """
    Convert all hex to dec number in source_file and save to output_file
    :param source_file:  path to csv file
    :param output_file:  path to output file -
    :return:
    """
    sfn_column_index = 2
    slot_column_index = 3
    super_frame = 0
    previous_sfn_value = None

    if not output_file:
        file_name, extension = os.path.splitext(source_file)
        output_file = "{}_asfn{}".format(file_name, extension)

    llines = []
    noise_per_prb_index = None
    noise_per_prb_columns = ['noisePerPrb_item_{}'.format(index) for index in range(0, 273)]

    with open(source_file, 'r') as f:
        reader = csv.reader(f, delimiter=',')
        for row_number, row in enumerate(reader):
            if row_number == 0:
                row.insert(2, 'asfn')

                for column_index, column_name in enumerate(row, 0):
                    row[column_index] = column_name.split('.')[-1]
                    if 'noisePerPrb_item' in column_name:
                        noise_per_prb_index = column_index
                if noise_per_prb_index:
                    del row[noise_per_prb_index]
                    row[noise_per_prb_index:noise_per_prb_index] = noise_per_prb_columns
            else:
                sfn_value = int(row[sfn_column_index])
                slot_value = int(row[slot_column_index])

                if previous_sfn_value and sfn_value < previous_sfn_value:
                    super_frame = super_frame + 1
                asfn = (((super_frame * 1024) + sfn_value) * slots_per_frame) + slot_value
                row.insert(2, asfn)
                previous_sfn_value = sfn_value
                if noise_per_prb_index:
                    values = row.pop(noise_per_prb_index).split(',')
                    row[noise_per_prb_index:noise_per_prb_index] = values

            llines.append(row)

    with open(output_file, 'w') as new_f:
        writer = csv.writer(new_f, delimiter=',')
        writer.writerows(llines)

    return output_file


def _convert_pcap_to_csv(pcap_file, csv_file=None, fields=None, filters=None, options=None, timeout=30 * 60,
                         device=None):
    """
    Convert pcap file to csv format.

    :param pcap_file:   path to source pcap_file
    :param csv_file:    path to destination csv file
    :param fields:      list of fields - option -e
    :param filters:     list of filters - option -Y
    :param options:     additional options used in conversion, eg -Y SCTP
    :param timeout:     conversion timeout
    """
    if device is None:
        local_pc = DeviceFactory.get_device(name='UnixLocal')
    else:
        local_pc = device

    if not csv_file:
        file_name, extension = os.path.splitext(pcap_file)
        csv_file = "{}_{}_{}.csv".format(file_name, extension.lstrip('.'), filters[0])

    tshark_options = "-E header=y -E separator=, -E quote=d -E occurrence=a"

    if fields:
        field_options = ' -T fields -e {}'.format(' -e '.join(fields))
        tshark_options = tshark_options + field_options

    if filters:
        filters_options = ' -Y "{}"'.format(' || '.join(filters))
        tshark_options = tshark_options + filters_options

    if options:
        tshark_options = tshark_options + ' ' + options

    cmd_options = "-r {} {} > {}".format(pcap_file, tshark_options, csv_file)
    convert_cmd = local_pc.get_cmd(cmd_name="tshark", cmd_params={'options': cmd_options})
    convert_cmd.start(timeout=timeout)

    return csv_file, convert_cmd


def _unzip_file(file_path, extract_dir):
    local_pc = DeviceFactory.get_device(name='UnixLocal')
    unzip = local_pc.get_cmd(cmd_name='unzip', cmd_params={'zip_file': file_path, 'extract_dir': extract_dir})
    unzip(timeout=60)


def _get_pcap_files(directory_path):
    local_pc = DeviceFactory.get_device(name='UnixLocal')
    ls = local_pc.get_cmd(cmd_name="ls", cmd_params={'path': os.path.join(directory_path, '*.pcap*')})
    pcap_files = ls()['files']
    return pcap_files


def _sort_pcap_files(pcap_files):
    _re_file_number = re.compile(r'\.pcap(\d+)')

    def get_file_number(file_name):
        match = _re_file_number.search(file_name)
        last_pcap_iter = 99  # pcap numbering from 0 to 99, if no number means that it is the last part (99)
        if match:
            return int(match.group(1))
        else:
            return last_pcap_iter

    sorted_files = sorted(pcap_files, key=get_file_number)

    return sorted_files


def _merge_into_one_csv_file(csv_files, merged_file):
    local_pc = DeviceFactory.get_device(name='UnixLocal')
    for index, csv_file in enumerate(csv_files, 0):
        if index == 0:
            cp_cmd = local_pc.get_cmd(cmd_name='cp', cmd_params={'src': csv_file, 'dst': merged_file})
            cp_cmd()
        else:
            tail_cmd = local_pc.get_cmd(cmd_name='run_script',
                                        cmd_params={'script_command': 'tail -n +2 {} >> {}'
                                                    .format(csv_file, merged_file)})
            tail_cmd(timeout=60)


def _load_moler_configuration(log_path):
    config = {
        'DEVICES': {
            'UnixLocal': {
                'DEVICE_CLASS': 'moler.device.unixlocal.UnixLocal'
            }
        },
        'LOGGER': {
            'DATE_FORMAT': '%d %H:%M:%S',
            'DEBUG_LEVEL': 'INFO',
            'MODE': 'write',
            'PATH': log_path,
            'RAW_LOG': False,
        }
    }
    load_config(config=config)


def _get_base_log_dir(source_path):
    if os.path.isdir(source_path):
        return source_path
    elif os.path.isfile(source_path) and '.zip' in source_path:
        return os.path.dirname(source_path)
    else:
        print("Incorrect source path")


def _parse_arguments():
    parser = argparse.ArgumentParser(description="Script for converting and merging all pcaps to one csv file")
    parser.add_argument("-p", "--path", help="Path to directory or zipped file", required=True)
    parser.add_argument("-s", "--slots_per_frame", help="Slots per Frame", default=10)
    parser.add_argument("-m", "--parallel_files", help="Max files parsed parallel",
                        required=False, default=2)
    return parser.parse_args()


@load_moler_configuration_from_tl()
def convert_gnblog_to_csv(path, threads, slots_per_frame):
    """ convert_gnblog_to_csv is a function to transform raw bip log from gnb_logs tool to machine
        readable csv files with noise values per PRB during 5 minute interval per message type

        :path: Absolute path to gnb_logs zip file
        :threads: Amount of threads used in processing
        :slots_per_frame: number of slots per PRB per frame

        :return: Path to excel with calculated avg and max values per PRB for comparison with gNB counters
    """
    base_log_dir = _get_base_log_dir(path)
    if os.path.isfile(path) and '.zip' in path:
        _unzip_file(file_path=path, extract_dir=base_log_dir)
        pcaps_dir = os.path.join(base_log_dir, os.path.basename(path).split('.zip')[0], "bip")
    else:
        pcaps_dir = base_log_dir

    all_pcap_files = _get_pcap_files(pcaps_dir)
    sorted_pcap_files = _sort_pcap_files(all_pcap_files)

    convert_all_pcaps(directory_path=pcaps_dir, pcap_files=sorted_pcap_files,
                      max_files=int(threads), slots_per_frame=int(slots_per_frame))
    return pcaps_dir
