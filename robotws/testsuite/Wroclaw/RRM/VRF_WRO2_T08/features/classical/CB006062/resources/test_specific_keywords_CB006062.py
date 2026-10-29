import gzip
import re
from zipfile import ZipFile

from robot.libraries.BuiltIn import BuiltIn
from taf.sw.reporting_portal import reporting_portal
from ute_common_abstract_core.aliases_registry import aliases_registry

from testsuite.Wroclaw.RRM.resources.webUI_operations import make_webui_snapshot

ute_rp = reporting_portal()

BD_parameters = [
    {"parameterName": "actAperCsi", "operation": "update", "value": "false"},
    {"parameterName": "actUlDftSOfdm", "operation": "update", "value": "true"},
    {"parameterName": "actUl256Qam", "operation": "update", "value": "false"},
    {"parameterName": "ulDMRSAdditionalPosition", "operation": "update", "value": "One additional DMRS"},
    {"parameterName": "dlPtrs", "operation": "update", "value":
        [{"dlPtrsFreqDensityThresNrb0": "107", "dlPtrsFreqDensityThresNrb1": "107", "actDlPtrs": "true"}]},
    {"parameterName": "ulPtrs", "operation": "update", "value":
        [{"ulPtrsFreqDensityThresNrb0": "107", "ulPtrsFreqDensityThresNrb1": "107", "actUlPtrs": "true"}]},
    {"parameterName": "frequencyDensityThresNrb0", "operation": "update", "value": "107"},
    {"parameterName": "frequencyDensityThresNrb1", "operation": "update", "value": "107"},
    {"parameterName": "pucchModeSelect", "operation": "update", "value": "longPucch"},
    {"parameterName": "ulDataDmrsFdm", "operation": "update", "value":
        [{"actUlDataDmrsFdm": "false", "ulDataDmrsFdmThres64QamMcs": 20, "ulDataDmrsFdmThres256QamMcs": 20}]},
]
BF_parameters = [
    {"parameterName": "actAperCsi", "operation": "update", "value": "false"},
    {"parameterName": "actUlDftSOfdm", "operation": "update", "value": "false"},
    {"parameterName": "actUl256Qam", "operation": "update", "value": "true"},
    {"parameterName": "ulDMRSAdditionalPosition", "operation": "update", "value": "One additional DMRS"},
    {"parameterName": "dlPtrs", "operation": "update", "value":
        [{"dlPtrsFreqDensityThresNrb0": "107", "dlPtrsFreqDensityThresNrb1": "107", "actDlPtrs": "true"}]},
    {"parameterName": "ulPtrs", "operation": "update", "value":
        [{"ulPtrsFreqDensityThresNrb0": "107", "ulPtrsFreqDensityThresNrb1": "107", "actUlPtrs": "true"}]},
    {"parameterName": "frequencyDensityThresNrb0", "operation": "update", "value": "107"},
    {"parameterName": "frequencyDensityThresNrb1", "operation": "update", "value": "107"},
    {"parameterName": "pucchModeSelect", "operation": "update", "value": "longPucch"},
    {"parameterName": "ulDataDmrsFdm", "operation": "update", "value":
        [{"actUlDataDmrsFdm": "false", "ulDataDmrsFdmThres64QamMcs": 20, "ulDataDmrsFdmThres256QamMcs": 20}]},
]
BB_parameters = [
    {"parameterName": "actAperCsi", "operation": "update", "value": "false"},
    {"parameterName": "actUlDftSOfdm", "operation": "update", "value": "false"},
    {"parameterName": "actUl256Qam", "operation": "update", "value": "false"},
    {"parameterName": "ulDMRSAdditionalPosition", "operation": "update", "value": "No additional DMRS"},
    {"parameterName": "dlPtrs", "operation": "update", "value":
        [{"dlPtrsFreqDensityThresNrb0": "277", "dlPtrsFreqDensityThresNrb1": "276", "actDlPtrs": "true"}]},
    {"parameterName": "ulPtrs", "operation": "update", "value":
        [{"ulPtrsFreqDensityThresNrb0": "277", "ulPtrsFreqDensityThresNrb1": "276", "actUlPtrs": "true"}]},
    {"parameterName": "frequencyDensityThresNrb0", "operation": "update", "value": "277"},
    {"parameterName": "frequencyDensityThresNrb1", "operation": "update", "value": "277"},
    {"parameterName": "pucchModeSelect", "operation": "update", "value": "longPucch"},
    {"parameterName": "ulDataDmrsFdm", "operation": "update", "value":
        [{"actUlDataDmrsFdm": "false", "ulDataDmrsFdmThres64QamMcs": 20, "ulDataDmrsFdmThres256QamMcs": 20}]},
]
BI_SA_parameters = [
    {"parameterName": "actAperCsi", "operation": "update", "value": "true"},
    {"parameterName": "actUlDftSOfdm", "operation": "update", "value": "true"},
    {"parameterName": "actUl256Qam", "operation": "update", "value": "true"},
    {"parameterName": "ulDMRSAdditionalPosition", "operation": "update", "value": "One additional DMRS"},
    {"parameterName": "dlPtrs", "operation": "update", "value":
        [{"dlPtrsFreqDensityThresNrb0": "107", "dlPtrsFreqDensityThresNrb1": "107", "actDlPtrs": "true"}]},
    {"parameterName": "ulPtrs", "operation": "update", "value":
        [{"ulPtrsFreqDensityThresNrb0": "107", "ulPtrsFreqDensityThresNrb1": "107", "actUlPtrs": "true"}]},
    {"parameterName": "frequencyDensityThresNrb0", "operation": "update", "value": "107"},
    {"parameterName": "frequencyDensityThresNrb1", "operation": "update", "value": "107"},
    {"parameterName": "pucchModeSelect", "operation": "update", "value": "longPucch"},
    {"parameterName": "ulDataDmrsFdm", "operation": "update", "value":
        [{"actUlDataDmrsFdm": "false", "ulDataDmrsFdmThres64QamMcs": 20, "ulDataDmrsFdmThres256QamMcs": 20}]},
]
BI_NSA_1_parameters = [
    {"parameterName": "actAperCsi", "operation": "update", "value": "true"},
    {"parameterName": "actUlDftSOfdm", "operation": "update", "value": "true"},
    {"parameterName": "actUl256Qam", "operation": "update", "value": "true"},
    {"parameterName": "ulDMRSAdditionalPosition", "operation": "update", "value": "No additional DMRS"},
    {"parameterName": "dlPtrs", "operation": "update", "value":
        [{"dlPtrsFreqDensityThresNrb0": "277", "dlPtrsFreqDensityThresNrb1": "276", "actDlPtrs": "true"}]},
    {"parameterName": "ulPtrs", "operation": "update", "value":
        [{"ulPtrsFreqDensityThresNrb0": "277", "ulPtrsFreqDensityThresNrb1": "276", "actUlPtrs": "true"}]},
    {"parameterName": "frequencyDensityThresNrb0", "operation": "update", "value": "277"},
    {"parameterName": "frequencyDensityThresNrb1", "operation": "update", "value": "277"},
    {"parameterName": "pucchModeSelect", "operation": "update", "value": "longPucch"},
    {"parameterName": "ulDataDmrsFdm", "operation": "update", "value":
        [{"actUlDataDmrsFdm": "false", "ulDataDmrsFdmThres64QamMcs": 20, "ulDataDmrsFdmThres256QamMcs": 20}]},
]
BI_NSA_2_parameters = [
    {"parameterName": "actAperCsi", "operation": "update", "value": "true"},
    {"parameterName": "actUlDftSOfdm", "operation": "update", "value": "true"},
    {"parameterName": "actUl256Qam", "operation": "update", "value": "true"},
    {"parameterName": "ulDMRSAdditionalPosition", "operation": "update", "value": "One additional DMRS"},
    {"parameterName": "dlPtrs", "operation": "update", "value":
        [{"dlPtrsFreqDensityThresNrb0": "107", "dlPtrsFreqDensityThresNrb1": "107", "actDlPtrs": "true"}]},
    {"parameterName": "ulPtrs", "operation": "update", "value":
        [{"ulPtrsFreqDensityThresNrb0": "107", "ulPtrsFreqDensityThresNrb1": "107", "actUlPtrs": "true"}]},
    {"parameterName": "frequencyDensityThresNrb0", "operation": "update", "value": "107"},
    {"parameterName": "frequencyDensityThresNrb1", "operation": "update", "value": "107"},
    {"parameterName": "pucchModeSelect", "operation": "update", "value": "longPucch"},
    {"parameterName": "ulDataDmrsFdm", "operation": "update", "value":
        [{"actUlDataDmrsFdm": "false", "ulDataDmrsFdmThres64QamMcs": 20, "ulDataDmrsFdmThres256QamMcs": 20}]},
]
BH_parameters = [
    {"parameterName": "actAperCsi", "operation": "update", "value": "true"},
    {"parameterName": "actUlDftSOfdm", "operation": "update", "value": "false"},
    {"parameterName": "actUl256Qam", "operation": "update", "value": "false"},
    {"parameterName": "ulDMRSAdditionalPosition", "operation": "update", "value": "No additional DMRS"},
    {"parameterName": "dlPtrs", "operation": "update", "value":
        [{"dlPtrsFreqDensityThresNrb0": "277", "dlPtrsFreqDensityThresNrb1": "276", "actDlPtrs": "true"}]},
    {"parameterName": "ulPtrs", "operation": "update", "value":
        [{"ulPtrsFreqDensityThresNrb0": "277", "ulPtrsFreqDensityThresNrb1": "276", "actUlPtrs": "true"}]},
    {"parameterName": "frequencyDensityThresNrb0", "operation": "update", "value": "277"},
    {"parameterName": "frequencyDensityThresNrb1", "operation": "update", "value": "277"},
    {"parameterName": "pucchModeSelect", "operation": "update", "value": "longPucch"},
    {"parameterName": "ulDataDmrsFdm", "operation": "update", "value":
        [{"actUlDataDmrsFdm": "false", "ulDataDmrsFdmThres64QamMcs": 20, "ulDataDmrsFdmThres256QamMcs": 20}]},
]
scf_parameters = {'BD': BD_parameters, 'BF': BF_parameters, 'BH': BH_parameters, 'BI_NSA_1': BI_NSA_1_parameters,
                  'BI_NSA_2': BI_NSA_2_parameters, 'BI_SA': BI_SA_parameters, 'BB': BB_parameters}


def correct_tc_name():
    ute_rp.map_testcase('[1]6062_BI_SA_PUSCH data and DMRS FDM co-existence with DFT-s-OFDM, '
                        'PUSCH 256QAM and aperiodic CSI for FDD FR1  - PTRS off')


def check_if_newer_branch(sw):
    return True if sw.split("_")[0] in \
                   ['SBTS00', 'SBTS22R4', 'SBTS23R1', 'SBTS23R2', 'SBTS23R3', 'SBTS23R4', 'SBTS24R1'] else False


def check_if_dlptrs_not_supported(sw):
    return True if sw.split("_")[0] in ['SBTS00', 'SBTS23R2', 'SBTS23R3', 'SBTS23R4', 'SBTS24R1'] else False


def get_scf_params(subfeature, is_it_newer_branch, dlptrs_not_supported):
    scf_params = scf_parameters[subfeature]
    if is_it_newer_branch:
        scf_params = [x for x in scf_params if 'frequencyDensityThresNrb' not in x["parameterName"]]
    return [x for x in scf_params if 'dlPtrs' not in x["parameterName"]] if dlptrs_not_supported else scf_params


def change_ulDataDmrsFdm_True():
    parameter = [
        {"parameterName": "ulDataDmrsFdm", "operation": "update", "value":
            [{"actUlDataDmrsFdm": "true", "ulDataDmrsFdmThres64QamMcs": 20, "ulDataDmrsFdmThres256QamMcs": 20}]}
    ]
    return parameter


def change_ulDataDmrsFdm_False():
    parameter = [
        {"parameterName": "ulDataDmrsFdm", "operation": "update", "value":
            [{"actUlDataDmrsFdm": "false", "ulDataDmrsFdmThres64QamMcs": 20, "ulDataDmrsFdmThres256QamMcs": 20}]}
    ]
    return parameter


def _file_reader(filename):
    with open(filename, 'rb') as f:
        for line in f:
            try:
                line = line.decode()
            except UnicodeDecodeError:
                continue
            yield line


def check_rrc_message_enabled(txt_path):
    rrc_pattern = re.compile(
        r'.*?transformPrecoder enabled,')
    for line in _file_reader(txt_path):
        if rrc_pattern.match(line):
            return True
    raise ValueError('No msg found in qxdm file')


def check_rrc_message_disabled(txt_path):
    rrc_pattern = re.compile(
        r'.*?transformPrecoder disabled,')
    for line in _file_reader(txt_path):
        if rrc_pattern.match(line):
            return True
    raise ValueError('No msg found in qxdm file')


def get_throughput_list(dt_alias):
    dt = aliases_registry()[dt_alias]
    throughput_list = []
    client_rows = dt.get_client_report_rows()
    server_rows = dt.get_server_report_rows()
    for c, s in zip(client_rows, server_rows):
        if s.bandwidth_unit == 'K':
            throughput_list.append(float(s.bandwidth_amount) / 1024.0)
        else:
            throughput_list.append(float(s.bandwidth_amount))
    return throughput_list


def get_average_throughput_from_given_time(dt_alias, start_time, end_time):
    throughput_list = get_throughput_list(dt_alias)
    start_time = int(start_time) - 1
    end_time = int(end_time) - 1
    return sum(throughput_list[start_time:end_time]) / len(throughput_list[start_time:end_time])


def get_antenna_ports_value(rrc_file, expected_value, match_all=True):
    expected_value = int(expected_value)
    with open(rrc_file, 'rb') as f:
        port_lst = []
        for line in f:
            try:
                line = line.decode()
            except UnicodeDecodeError:
                continue
            antenna_index = line.find("Antenna")
            if antenna_index != -1:
                port_index = next(f).decode().find("Port")
                if port_index == antenna_index:
                    next(f)
                    value_line = next(f, b"EOF").decode()
                    while antenna_index <= len(value_line) and value_line[antenna_index - 1] == "|":
                        port = value_line[antenna_index:antenna_index + len("Antenna"):].strip()
                        if port:
                            port_lst.append(int(port))
                        if value_line == "EOF":
                            break
                        else:
                            value_line = next(f, b"EOF").decode()
        for port in set(port_lst):
            print("Port", port, "occurence number :", port_lst.count(port))
        if match_all:
            assert len(set(port_lst)) == 1 and expected_value in set(port_lst), \
                "Other value found in ports value. Values founded in logs {}".format(",".join(str(port)
                                                                                     for port in set(port_lst)))
        else:
            assert expected_value in set(port_lst), "Value '{}' not found in logs".format(expected_value)
        return True


def verify_aperiodic_csi_in_snapshot(should_be_zero=True):
    log_path = "{path}/{filename}_snapshot.zip".format(path=BuiltIn().get_variable_value("${LOG_PATH}"),
                                                       filename=BuiltIn().get_variable_value("${test_name}"))
    make_webui_snapshot(timeout=1500)
    zip = ZipFile(log_path)
    zip.extractall('/tmp/extracted_snapshot')
    internal_files = {}
    current_zip = 'Invalid'
    with open('/tmp/extracted_snapshot/snapshot_file_list.txt', 'r') as f:
        for line in f:
            line = line.strip()
            if line and line[-1] == ':':
                current_zip = line[:-1]
                continue
            match = re.findall(r'.*RD\.BTS.*ANY.xml*', line)
            if match:
                if not internal_files.get(current_zip):
                    internal_files[current_zip] = []
                internal_files[current_zip].append(match[0].strip())
    zip_files = list(internal_files.keys())
    zip_files.sort(key=lambda x: int(x.split('_')[-1].split('.')[0]))
    zip_file = zip_files[-1]
    xml_file_list = internal_files[zip_file]
    zip = ZipFile('/tmp/extracted_snapshot/{}'.format(zip_file))
    zip.extractall('/tmp/extracted_snapshot/{}_extracted'.format(zip_file))
    xml_file_list.sort()
    xml_file = xml_file_list[-1]
    print("ZipFile: {}, XMLfile: {}".format(zip_file, xml_file))
    with gzip.open('/tmp/extracted_snapshot/{}_extracted/{}.gz'.format(zip_file, xml_file), 'r') as f:
        match = re.findall(r'.*<SUCC_ACSI_PUSCH>(\d+)</SUCC_ACSI_PUSCH>.*', f.read().decode())
        assert match, "Could not find any SUCC_ACSI_PUSCH in snapshot"
        match = int(match[0])
        print("Found ACSI value: {}".format(match))
        if should_be_zero:
            assert not match, "ACSI value is not 0 --> found ACSI: {}".format(match)
        else:
            assert match, "ASCI value is not greater than 0: --> found ASCI: {}".format(match)


def compare_throughputs(tputs_lower, tputs_higher, gain=1, error_margin=0.02):
    if isinstance(tputs_lower, list) and isinstance(tputs_higher, list):
        assert len(tputs_lower) == len(tputs_higher), "Comparing unequal number of throughputs!"
    else:
        tputs_lower = [tputs_lower]
        tputs_higher = [tputs_higher]
    for ind, tput_pair in enumerate(zip(tputs_lower, tputs_higher)):
        assert gain*tput_pair[0]-error_margin*tput_pair[0] <= tput_pair[1], \
            "{} is greater than {} - Tput nr {}".format(tput_pair[0], tput_pair[1], ind)
