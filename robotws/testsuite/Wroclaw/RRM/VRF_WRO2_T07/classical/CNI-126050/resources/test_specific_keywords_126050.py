from testsuite.Wroclaw.RRM.VRF_WRO2_T07.classical.CB007564.resources.test_specific_keywords_7564 import atten
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.manual.logs_collector import l1l2
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.DeltaStore import DeltaStore
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.common import au
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from taf.analyzer.pmcounter.interface import pmcounter

from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.log_helper import log_finder
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.rue.attach_utils import taf_ue
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation import get_sw_release_name

mrbts_id = 55200
CONDITIONAL_RELEASE_25R3 = int('SBTS25R3'[4:].replace('R', ''))


def CNI_126050_activation(bts_id=mrbts_id):
    bts_sw_release = int(get_sw_release_name()[4:8].replace('R', ''))
    ds = DeltaStore()
    ds.initialise_delta_store()
    nrbts_object = f'MRBTS-{bts_id}/NRBTS-{bts_id}'
    ds.add_param_to_delta(nrbts_object + '/NRPMRNL-1',
                          'miNrRip', '5min')
    if bts_sw_release >= CONDITIONAL_RELEASE_25R3:
        ds.add_param_to_delta(nrbts_object + '/NRPMRNL-1/NRPMCCP-1',
                              'actNrUlRipCounter', ['PUCCH F1', 'PRACH with Preamble', 'PRACH without Preamble',
                                                    'Unscheduled PUSCH PRBs', 'Scheduled PUSCH PRBs',
                                                    'Other PUCCH formats'])
    else:
        ds.add_param_to_delta('MRBTS-55109/NRBTS-55109', 'actNrUlRipMeasurement', 'enabledWithPRACH_PUCCH_F1')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-1',
                          'actPrachNoPreambleNoisePwrEst', 'true')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                          'actPrachNoPreambleNoisePwrEst', 'true')

    ds.validate_scf(skip_parameter_relation_errors=False)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=False)
    blog("------------------Feature CNI - 126050 and counters activated-------------------------")


def get_and_verify_counters_CNI_126050(counter_dir, counter_start, counter_end, cell_id, counter_name):
    counter_start_dig = int(counter_start[0][-2:])
    counter_end_dig = int(counter_end[0][-2:])
    all_values = []
    for i in range(counter_start_dig, counter_end_dig + 1):
        counter_key = f"{counter_name[0]}{i:02d}"
        value_dict = get_relevant_pm_counters_CNI_126050(pi_dir=counter_dir, counter_ids=[counter_key])
        sub_values = value_dict.get(counter_key, {})

        if isinstance(sub_values, dict) and cell_id in sub_values:
            values = sub_values[cell_id]
            if values and values[-1] not in ["-", None, ""]:
                all_values.append((counter_key, cell_id, values[-1]))

    return all_values


def Compare_counters_CNI126050(counter_avg, counter_max, cellID, prb1):
    dict1 = {key[-2:]: value for key, _, value in counter_avg}
    dict2 = {key[-2:]: value for key, _, value in counter_max}
    valid_values = []
    data = []
    prb1_list = list(map(int, prb1.split()))

    for key in dict1:
        data.append(key)

    range_expected = [f"{i:02d}" for i in range(1, 78) if i not in prb1_list]

    for element in range_expected:
        if element not in data:
            return "fail", f"lack of element: {element} in average counters"

    for key in dict2:
        data.append(key)

    for element in range_expected:
        if element not in data:
            return "fail", f"lack of element: {element} in max counters"

    blog("all prbs are present exclude 03 and 75 for 20mhz cell")

    for key in dict1:
        if key in dict2:
            val1 = dict1[key]
            val2 = dict2[key]
            if val2 >= val1:
                valid_values.append((key, val1, val2))
            else:
                assert False, f"Value of max counter is lower than avg for counter {key}, with value {val1}"
        else:
            assert False, f"lack of counter {key} in max counters"

    blog("cell id:", cellID, valid_values, "average / max counters comparison passed")
    return "success", "pass"


def check_test_results_126050(result1, result2):
    result1_status, result1_message = result1
    result2_status, result2_message = result2

    if result1_status == "fail" and result2_status == "fail":
        assert False, f"Both comparisons failed: {result1_message}, {result2_message}"
    else:
        print("At least one comparison passed")


def get_relevant_pm_counters_CNI_126050(pi_dir, counter_ids):
    analyzer = pmcounter()
    pi_dict = analyzer.get_pi_value(pi_list=counter_ids, pi_dir=pi_dir, pi_file_pattern='PM*')
    value_dict = extract_values_from_pi_dict_126050(pi_dict)

    return value_dict


def extract_values_from_pi_dict_126050(pi_dict):
    result_dict = {}
    pi_dict = [entry for entry in pi_dict if list(list(entry.values())[0].values())[0]]

    for date_entry in pi_dict:
        counter_id_dict = list(date_entry.values())[0]
        counter_id = list(counter_id_dict.keys())[0]
        mrbts_dict = list(counter_id_dict.values())[0]

        for cell_id, counter_val in mrbts_dict.items():
            cell_id = cell_id.split('-')[-1]

            def convert_value(v):
                try:
                    return int(v) if v.isdigit() else float(v)
                except ValueError:
                    return v

            if counter_id in result_dict and cell_id in result_dict[counter_id]:
                result_dict[counter_id][cell_id].append(convert_value(counter_val))
            else:
                result_dict[counter_id] = {
                    k.split('-')[-1]: [convert_value(v)] for (k, v) in mrbts_dict.items()
                }

    return result_dict


def lock_cell_126050(cell_id):
    au.lock_cells(cell_id)
    blog("cell", cell_id, "locked")


def qrx_levmin_setup(cell_id, bts_id=mrbts_id):
    ds = DeltaStore()
    ds.initialise_delta_store()
    nrbts_object = f'MRBTS-{bts_id}/NRBTS-{bts_id}'
    ds.add_param_to_delta(nrbts_object + f'/NRCELL-{cell_id}',
                          'qRxLevMin', '-45')
    ds.validate_scf(skip_parameter_relation_errors=False)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=False)
    blog("------------------Preconditions for cell qrxlevmin done-------------------------")


def Dectivate_feature_CNI126050(cell_id, bts_id=mrbts_id):
    ds = DeltaStore()
    ds.initialise_delta_store()
    nrbts_object = f'MRBTS-{bts_id}/NRBTS-{bts_id}'
    ds.add_param_to_delta(nrbts_object + f'/NRCELL-{cell_id}',
                          'qRxLevMin', '-60')
    ds.validate_scf(skip_parameter_relation_errors=False)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=False)
    blog("------------------Rollback qrxlevmin done -------------------------")


def attenuation_126050_attach(atten_value=90, cell_1_attenuator_ports=tl.gnbs[0].dus[0].rus[1].attenuation_ports,
                              cell_2_attenuator_ports=tl.gnbs[0].dus[0].rus[2].attenuation_ports):
    atten.initialise_attenuator()
    blog(cell_1_attenuator_ports, "ports cell 1")
    blog(cell_2_attenuator_ports, "ports cell 2")

    atten.set_attenuation(value_string=atten_value, ports=cell_1_attenuator_ports)
    atten.set_attenuation(value_string='0', ports=cell_2_attenuator_ports)
    blog("attenuation for attach UE 2 done")


def start_logging_pcap_126050(pcap_filename="126050_dbm", smod_slave=False):
    l1l2.start_gnbmirroring(pcap_filename)


def stop_logging_pcap_126050():
    l1l2.stop_gnbmirroring_and_download_logs()


def check_126050_l1l2(pcap_file, filter_bip1='uldata_puschreceiverespps', filter_bip2='UlData_PuschReceiveRespPs_t',
                      replaced_list=[]):
    frames = log_finder(pcap_file,
                        filter_bip1,
                        filter_bip2)

    loop = (len(frames))

    for idx in range(loop):
        data = str(frames[idx])
        processed_data = data.replace("[", "").replace("]", "").replace("'", "").replace(" ", "").replace("(", ""). \
            replace(")", "").replace("Int16", "").replace(" (Uint16)", "").replace("(Uint8", ""). \
            replace("StrPatternDictstartSymbolUint8", "startSymbol").replace("Float32", "")
        replaced_list.extend([element.strip() for element in processed_data.split(',')])
    analysis_bip_dbm(replaced_list)

    return replaced_list


def analysis_bip_dbm(data_to_analysis):
    for i in range(0, 78):
        if i == 3 or i == 75:
            continue
        search = f"noisePerPrb_item_{i}"
        for idx, item in enumerate(data_to_analysis):
            if item == search:
                if idx + 1 < len(data_to_analysis):
                    dbm_value = data_to_analysis[idx + 1]
                    assert -140 <= float(dbm_value) <= -60, f"Value found {dbm_value} out of the range {search}"

    blog("correct values of dbm range -60 to -140")


def verify_tput_126050(ue1, ue2):
    taf_ue.check_data_transfer_is_alive(dt_name=f'{ue1}_DT_DL')
    taf_ue.check_data_transfer_is_alive(dt_name=f'{ue1}_DT_UL')
    taf_ue.check_data_transfer_is_alive(dt_name=f'{ue2}_DT_DL')
    taf_ue.check_data_transfer_is_alive(dt_name=f'{ue2}_DT_UL')
