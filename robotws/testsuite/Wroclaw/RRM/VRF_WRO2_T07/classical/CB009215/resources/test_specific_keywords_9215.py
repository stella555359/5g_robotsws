import re
import csv
from taf.config.scf import scf
import time
from collections import OrderedDict
import json

from testsuite.Wroclaw.RRM.VRF_WRO2_T07.classical.CB009333.resources.test_specific_keywords_9333 import \
    MRBTS_ID, SKIP_REL_ERR
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils import AdminUtils
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config as tl
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.test.test_file_helper import os
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.gnb_mirroring import L1L2
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.attenuator import Attenuator
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.rue.attach_utils as rue_utils
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword, wait_until_function_succeeds
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.log_helper import LogHelper
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.common.file_helper import get_filepaths
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod import TcpdumpSmod
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.matchers import PcapMessageMatcher
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.DeltaStore import DeltaStore
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation import get_sw_release_name, get_bts_id
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation import \
    load_scf, wait_for_online_state, _validate_path
from socket import gethostname
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.robot_globals import robot_globals
from itertools import chain
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.common import backup_current_scf as backup_scf

taf_ue = rue_utils.get_library_instance('taf.ue')

l1l2 = L1L2()
tcpdump = TcpdumpSmod()
scf = scf()
atten = Attenuator(with_initialisation=True)
au = AdminUtils()
ds = DeltaStore()

mrbts_id = tl.tl.gnbs[0].instance_id
nrbts_id = tl.tl.gnbs[0].global_bts_id

ports = {"1st": [1, 3], "2nd": [2, 4], "3rd": [9, 11], "4th": [10, 12], "5th": [5, 7], "6th": [6, 8], "FDD": [13, 14],
         "AHLOA1": [19, 20, 21, 22], "AHLOA2": [15, 16, 17, 18]}
scf_timeout_wait = 600


@logged_keyword
@wait_until_function_succeeds(retry_time_in_seconds=scf_timeout_wait, retry_interval_in_seconds=30)
def scf_commissioning(scf_file):
    au = AdminUtils()
    au.perform_commissioning(bts_id=MRBTS_ID, scf_file=scf_file, skip_parameter_relation_errors=SKIP_REL_ERR)
    au.wait_for_all_cells_on_air_state()
    time.sleep(60)


@logged_keyword
def upload_scf(testcase, config_dir=None, skip_relation_errors=False):
    if config_dir is None:
        config_dir = _validate_path("{}/testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB009215/custom_config".
                                    format(robot_globals.execdir()))
    load_scf(scf_path=resolve_custom_scf_path(testcase, config_dir), skip_relation_errors=skip_relation_errors)
    wait_for_online_state()


@logged_keyword
def resolve_custom_scf_path(testcase, config_dir):
    branch = get_sw_release_name()
    rat = ''
    try:
        rat = str(get_bts_id())[0]
    except Exception as e:
        blog("Error {} occured during getting bts id".format(e), level='ERROR')
        pass
    rat = rat if rat in ['4', '5'] else '5'
    file_name = '{}_{}_{}G_{}.xml'.format(gethostname().replace('-', '_'), branch, rat, testcase)
    filepath = "{config}/{branch}/{file}".format(config=config_dir, branch=branch, file=file_name)
    assert os.path.isfile(filepath), "FileNotFoundError: [Errno 2] No such file or directory: {}".format(filepath)
    blog(filepath)
    return filepath


@logged_keyword
def prepare_cell_for_attach(*cell: str):
    cell_for_attach = list(chain(*[ports[id] for id in list(ports.keys()) if id in cell]))
    atten.gradually_decrease_attenuation(init_value=6, min_value=0, step=3, interval=0.2,
                                         ports=cell_for_attach, attenuator_id=1)
    atten.gradually_increase_attenuation(init_value=0, max_value=6, step=3, interval=0.2,
                                         ports=create_attenuation_list(*cell), attenuator_id=1)
    blog("Cell prepared")


@logged_keyword
def check_5qi_setup(pcap_file):
    frames = log_finder(pcap_file, 'ngap', 'PDUSessionResourceModifyRequest', message_type_pattern='empty')
    for msg in frames:
        found_5qi_msg = msg.find('fiveQI*').first()['val']
        blog(found_5qi_msg)
        if int(found_5qi_msg) == 1:
            blog('PDUSessionResourceModifyRequest with fiveQI = 1 param found.')
            return True
    assert False, 'PDUSessionResourceModifyRequest with fiveQI = 1 param NOT found!'


@logged_keyword
def create_attenuation_list(*args: str):
    return list(chain(
        *[cell_ports for cell, cell_ports in ports.items() if cell not in {*args}]
    ))


@logged_keyword
def log_finder(pcap_file, tfilter, message_name_pattern, message_type_pattern):
    with LogHelper() as lh:
        finder = lh.add_pcap(pcap_file_path=pcap_file, tshark_filter=tfilter, lua=None)
        return finder.find_all(PcapMessageMatcher(message_name_pattern, message_type_pattern=message_type_pattern))


@logged_keyword
def nullify_attenuation_on_all_cells():
    atten.initialise_attenuator()
    atten.nullify_attenuation_on_all_ports()


def read_and_parse_tti_data_for_cell(path_to_tti, direction):
    with open(path_to_tti, 'r') as csv_file:
        csv_dict = csv.reader(csv_file)
        csv_reader = list(csv_dict)
        ttifilter = [direction + 'AllocatedPooledResourcesData: hfnTickCount']
        tti_dict_cell = list()
        for row in csv_reader:
            if row[0] in ttifilter:
                new_row = dict()
                new_row.update({'Event': row[0][:-14]})
                sfn_column = get_sfn_column_for_cell_dict(row)
                print(sfn_column)
                new_row.update({'sfn': row[sfn_column]})
                for index_dic in range(2, sfn_column - 1):
                    if (index_dic + sfn_column) < len(row):
                        new_row.update({row[index_dic]: row[index_dic + sfn_column - 1]})
                    else:
                        break
                tti_dict_cell.append(new_row)
    return tti_dict_cell


def get_sfn_column_for_cell_dict(row_from_list):
    sfn_column = 0
    for i, element in enumerate(row_from_list):
        if element.isdigit():
            sfn_column = i + 1
            break
    return sfn_column


def read_and_parse_tti_data_for_subpool(path_to_tti, direction):
    current_release = get_sw_release_name()
    with open(path_to_tti, 'r') as csv_file:
        csv_dict = csv.reader(csv_file)
        csv_reader = list(csv_dict)
        ttifilter = [direction + 'InterL1SubpoolReconfData: hfnTickCount']
        tti_dict_subpool = list()
        for row in csv_reader:
            if row[0] in ttifilter:
                new_row = dict()
                new_row.update({'Event': row[0][:-14]})
                first_column = get_first_column_for_subpool_dict(row)
                new_row.update({'sfn': row[first_column]})
                if current_release == "SBTS24R3" or current_release == "SBTS24R2":
                    for index_dic in range(2, 31):
                        if (index_dic + first_column) < len(row):
                            new_row.update({row[index_dic]: row[index_dic + first_column - 1]})
                        else:
                            break
                else:
                    for index_dic in range(2, 25):
                        if (index_dic + first_column) < len(row):
                            new_row.update({row[index_dic]: row[index_dic + first_column - 1]})
                        else:
                            break
                tti_dict_subpool.append(new_row)
                new_row = dict()
                new_row.update({'Event': row[0][:-14]})
                first_column = get_first_column_for_subpool_dict(row)
                new_row.update({'sfn': row[first_column]})
                for index_dic in range(2, 10):
                    if (index_dic + first_column) < len(row):
                        new_row.update({row[index_dic]: row[index_dic + first_column - 1]})
                    else:
                        break
                if current_release == "SBTS24R3" or current_release == "SBTS24R2":
                    for index_dic in range(10, 31):
                        if (index_dic + first_column) < len(row):
                            new_row.update({row[index_dic]: row[index_dic + first_column + 20]})
                        else:
                            break
                else:
                    for index_dic in range(10, 25):
                        if (index_dic + first_column) < len(row):
                            new_row.update({row[index_dic]: row[index_dic + first_column + 14]})
                        else:
                            break
                tti_dict_subpool.append(new_row)
    return tti_dict_subpool


def get_first_column_for_subpool_dict(row_from_list):
    first_column = 0
    for i, element in enumerate(row_from_list):
        if element.isdigit():
            first_column = i + 1
            break
    return first_column


def get_cell_subpool_dict(tti_dict_cell, direction, cell_id_to_ignore, long_cell_id_to_ignore):
    cell_dict = {}
    for single_dict in tti_dict_cell:
        if single_dict['Event'] == direction + 'AllocatedPooledResourcesData' and \
                single_dict['nrCellIdentity'] != long_cell_id_to_ignore:
            sfn = single_dict['sfn']
            break
        else:
            continue
    for single_dict in tti_dict_cell:
        if single_dict['Event'] == direction + 'AllocatedPooledResourcesData':
            if len(cell_dict.keys()) < 6 and single_dict['sfn'] == sfn and \
                    single_dict['nrCellIdentity'] != long_cell_id_to_ignore:
                cell = single_dict['lcrId']
                cell_dict[cell] = single_dict
            else:
                continue
    return cell_dict


def verify_subpools_with_vendor(value_per_subpool, vendor_stream_prb):
    subpool_list = value_per_subpool.keys()
    all_subpools_list = []
    all_current_prb = 0
    all_calculated_prb = 0
    for subpool in subpool_list:
        all_subpools_list.append(value_per_subpool[subpool]['subPoolId'])
    for subpool in range(int(all_subpools_list[0]), int(all_subpools_list[-1])):
        assert value_per_subpool[str(subpool)]['l1PoolId'] == value_per_subpool[str(subpool + 1)]['l1PoolId'], \
            blog('PoolId is different for two subpools')
    for subpoolid in subpool_list:
        assert value_per_subpool[subpoolid]['defaultStreamPrbCapacityPerSp'] == vendor_stream_prb, \
            blog('default stream PRB is different than vendor modification',
                 value_per_subpool[subpoolid]['defaultStreamPrbCapacityPerSp'])
        assert value_per_subpool[subpoolid]['poolMaxNumStreamPrb'] == str(2 * int(vendor_stream_prb)), \
            blog('Max stream PRB for pool is different than vendor modification',
                 value_per_subpool[subpoolid]['poolMaxNumStreamPrb'])
    for subpool in range(int(all_subpools_list[0]), int(all_subpools_list[-1])):
        assert value_per_subpool[str(subpool)]['poolMaxNumStreamPrb'] == \
               value_per_subpool[str(subpool + 1)]['poolMaxNumStreamPrb'], \
               blog('Pool max stream PRB is different for 2 subpools')
    for subpoolid in all_subpools_list:
        all_current_prb += int((value_per_subpool[subpoolid]['currentStreamPrbCapacityPerSp']))
        all_calculated_prb += int((value_per_subpool[subpoolid]['calculatedStreamPrbCapacityPerSp']))
    for subpoolid in all_subpools_list:
        assert value_per_subpool[subpoolid]['poolMaxNumStreamPrb'] == str(all_current_prb), \
            blog('Pool max stream PRB is different than current stream capacity for both subpools')
        assert value_per_subpool[subpoolid]['poolMaxNumStreamPrb'] == str(all_calculated_prb), \
            blog('Pool max stream PRB is different than calculated stream capacity for both subpools')
    blog("Correct PRB capacity based on vendor changes")


def verify_cell_assignment_to_subpool_with_bts_log(dir_path):
    sys_list = get_filepaths(dir_path, pattern='SYSLOG_*.LOG')
    blog(sys_list)
    output_dict = {}
    for log in sys_list:
        with open(log) as file:
            syslog = file.read()
            matches = re.findall(r'Received from CM cprt::cm::SCellMappingReq:(.*?)$', syslog, re.MULTILINE)
            matches = re.split(r'(?<=\})\s*(?=\{)', re.sub(r'\s', '', ''.join(matches)))
        if matches != ['']:
            for match in matches:
                match = json.loads(match)
                output_dict[match['CellMappingList'][0]['nrCellIdentity']] = {
                    'l1PoolId': match['CellMappingList'][0]['dlSubcellList'][0]['l1PoolId'],
                    'l1SubpoolId': match['CellMappingList'][0]['dlSubcellList'][0]['l1SubpoolId'],
                    'dlSubcellType': match['CellMappingList'][0]['dlSubcellList'][0]['dlSubcellType']}
        else:
            continue
    return output_dict


def verify_cells(cell_dict, btslog, empty_cells, traffic_cells):
    subpoolId_empty = btslog[int(cell_dict[empty_cells[0]]['nrCellIdentity'])]['l1SubpoolId']
    subpoolId_traffic = btslog[int(cell_dict[traffic_cells[0]]['nrCellIdentity'])]['l1SubpoolId']
    for cell in empty_cells:
        subpoolid = btslog[int(cell_dict[cell]['nrCellIdentity'])]['l1SubpoolId']
        assert subpoolid == subpoolId_empty, blog('Different subpool for empty cells')
        blog('Subpool id {} is same for all empty cells'.format(subpoolid))
    for cell in traffic_cells:
        subpoolid = btslog[int(cell_dict[cell]['nrCellIdentity'])]['l1SubpoolId']
        assert subpoolid == subpoolId_traffic, blog('Different subpool for traffic cells')
        blog('Subpool id {} is same for all traffic cells'.format(subpoolid))
    poolId_all = btslog[int(cell_dict[empty_cells[0]]['nrCellIdentity'])]['l1PoolId']
    all_cells = empty_cells + traffic_cells
    for cell in all_cells:
        poolid = btslog[int(cell_dict[cell]['nrCellIdentity'])]['l1PoolId']
        assert poolid == poolId_all, blog('Different pool for all cells')
        blog('Pool id {} is same for all cells'.format(poolid))
    return subpoolId_empty, subpoolId_traffic


def verify_min_and_current_prb_in_cells_based_on_cell_type(value_per_subpool, value_per_cell, btslog,
                                                           subP_empty, subP_traffic, direction, min_prb):
    cell_list = value_per_cell.keys()
    min_subP_prb_empty = 0
    min_subP_prb_traffic = 0
    alloc_subP_prb_empty = 0
    alloc_subP_prb_traffic = 0
    for cell in cell_list:
        cell_type = list(btslog[int(value_per_cell[cell]['nrCellIdentity'])]['dlSubcellType'])
        num_layer = cell_type.pop()
        aloc_min = int(value_per_cell[cell]['allocStreamPrbMin' + direction])
        aloc = int(value_per_cell[cell]['numAllocCellPrb' + direction]) * int(num_layer)
        assert aloc_min == int(num_layer) * int(min_prb), \
            blog('Min Stream PRB per cell type is {} and is other then min prb x cell type {}'
                 .format(aloc_min, num_layer))
        blog('Min Stream PRB per cell type is {} and equal to min prb x cell type {}'.format(aloc_min, num_layer))
        if btslog[int(value_per_cell[cell]['nrCellIdentity'])]['l1SubpoolId'] == subP_empty:
            min_subP_prb_empty += aloc_min
            alloc_subP_prb_empty += aloc
        elif btslog[int(value_per_cell[cell]['nrCellIdentity'])]['l1SubpoolId'] == subP_traffic:
            min_subP_prb_traffic += aloc_min
            alloc_subP_prb_traffic += aloc
        else:
            continue
    assert int(value_per_subpool[str(subP_empty)]['minStreamPrbAllocationSp']) == min_subP_prb_empty, \
        blog('minStreamPrbAllocationSp is different than sum of allocStreamPrbMin for all cells from empty subPool')
    blog('minStreamPrbAllocationSp equal to sum of allocStreamPrbMin for all cells from empty subPool')
    assert int(value_per_subpool[str(subP_traffic)]['minStreamPrbAllocationSp']) == min_subP_prb_traffic, \
        blog('minStreamPrbAllocationSp is different than sum of allocStreamPrbMin for all cells from traffic subPool')
    blog('minStreamPrbAllocationSp equal to sum of allocStreamPrbMin for all cells from traffic subPool')
    # analysis not possible due to unstable environment and dynamic prb allocation -
    # assert int(value_per_subpool[str(subP_empty)]['currentStreamPrbCapacityPerSp']) in range(
    #     alloc_subP_prb_empty, alloc_subP_prb_empty+10), \
    #     blog('CurrentStreamPrbCapacityPerSp is different than sum of NumAllocCellPrb for cells from empty subPool')


def verify_current_prb_in_cells_based_on_cell_type(value_per_cell, btslog, subP_empty, subP_traffic, direction):
    cell_list = value_per_cell.keys()
    alloc_subP_prb_empty = 0
    alloc_subP_prb_traffic = 0
    for cell in cell_list:
        cell_type = list(btslog[int(value_per_cell[cell]['nrCellIdentity'])]['dlSubcellType'])
        num_layer = cell_type.pop()
        aloc = int(value_per_cell[cell]['numAllocCellPrb' + direction]) * int(num_layer)
        if btslog[int(value_per_cell[cell]['nrCellIdentity'])]['l1SubpoolId'] == subP_empty:
            alloc_subP_prb_empty += aloc
        elif btslog[int(value_per_cell[cell]['nrCellIdentity'])]['l1SubpoolId'] == subP_traffic:
            alloc_subP_prb_traffic += aloc
        else:
            continue


def verify_empty_cells(value_per_subpool, value_per_cell, subP_empty, subP_traffic, empty_cells,
                       direction, min_prb, max_prb):
    assert int(value_per_subpool[str(subP_empty)]['calculatedStreamPrbCapacityPerSp']) < \
           int(value_per_subpool[str(subP_traffic)]['calculatedStreamPrbCapacityPerSp']), \
           blog('calculated Stream PRB for empty subPool is higher then for traffic subPool')
    blog('calculated Stream PRB for empty subPool is lower than for traffic subPool')
    for cell in empty_cells:
        assert int(value_per_cell[cell]['allocStreamPrbGbr' + direction]) == 0, \
            blog('GBR traffic visible in empty cell')
        assert int(value_per_cell[cell]['allocStreamPrbNonGbr' + direction]) == 0, \
            blog('non GBR traffic visible in empty cell')
        assert int(min_prb) <= int(value_per_cell[cell]['numAllocCellPrb' + direction]) < int(max_prb), \
            blog('PRB allocated in empty cell is too low or too high')
    blog('PRB allocated in empty cell is correct')


def verify_traffic_cells(value_per_subpool, value_per_cell, subP_empty, subP_traffic, traffic_cells, direction,
                         min_prb):
    assert int(value_per_subpool[str(subP_empty)]['calculatedStreamPrbCapacityPerSp']) < \
           int(value_per_subpool[str(subP_traffic)]['calculatedStreamPrbCapacityPerSp']), \
           blog('calculated Stream PRB for empty subPool is higher then for traffic subPool')
    blog('calculated Stream PRB for empty subPool is lower than for traffic subPool')
    for cell in traffic_cells:
        assert int(value_per_cell[cell]['allocStreamPrbNonGbr' + direction]) > 0, \
            blog('Lack of non GBR traffic in traffic cell')
        assert int(value_per_cell[cell]['numAllocCellPrb' + direction]) > int(min_prb), \
            blog('PRB allocated in traffic cell is too low')
        if cell == '3':
            assert int(value_per_cell[cell]['allocStreamPrbGbr' + direction]) > 0, \
                blog('GBR traffic not visible in GBR cell')
        elif cell != '3':
            assert int(value_per_cell[cell]['allocStreamPrbGbr' + direction]) == 0, \
                blog('GBR traffic visible in non GBR cell')
        else:
            continue
    blog('PRB allocated in traffic cell is correct')


def zab_verification(value_per_cell, direction):
    cell_list = value_per_cell.keys()
    sum_for_cell = {}
    for cell in cell_list:
        sum_for_cell[cell] = int(value_per_cell[cell]['allocStreamPrbNonGbr' + direction]) + \
                             int(value_per_cell[cell]['allocStreamPrbGbr' + direction])

    sum_list = list(sum_for_cell.values())
    sum_list.sort()
    high_traffic = sum_list.pop()
    for cell in cell_list:
        if sum_for_cell[cell] == high_traffic:
            zab_cell = cell
            blog('The highest request {} is for cell {}'.format(high_traffic, zab_cell))
            assert int(value_per_cell[zab_cell]['hasZabPrivilege']) == 1, blog(
                'No ZAB for cell {} with highest GBR and non GBR request'.format(zab_cell))
            blog('ZAB visible for cell {} with highest GBR and non GBR request'.format(zab_cell))
        else:
            continue


def tti_analysis_9215(input_file, raw_value_analysis, filter):
    processing_data = False
    extracted_data = []
    with open(input_file, newline='') as infile:
        reader = csv.reader(infile)
        for row in reader:
            if not processing_data and row and row[0].startswith(str(filter)):
                processing_data = True
            if processing_data:
                extracted_data.append(','.join(row))
                if row and any(char.isdigit() and char != '-' for char in row[0]):
                    processing_data = False
    data = extracted_data
    extracted_data = {}
    # Przechodzenie przez każdy wpis w danych
    for entry in data:
        entry_data = entry.split(': ')[1].split(',')
        num_params = len(entry_data) // 2
        param_names = entry_data[:num_params]
        param_values = entry_data[num_params:]
        if len(param_names) != len(param_values):
            print("Wrong ammount of key an values:", entry)
            continue
        for i, (param_name, value) in enumerate(zip(param_names, param_values)):
            value = value.strip()
            if param_name not in extracted_data:
                extracted_data[param_name] = []
            if value.isdigit():
                extracted_data[param_name].append(int(value))
            else:
                extracted_data[param_name].append(value)

    values_counts = [len(values) for values in list(extracted_data.values())[int(raw_value_analysis):]]
    for i, count in enumerate(values_counts):
        assert count == values_counts[
            0], "Different value of keys Key: {}, Value: {}".format(
            list(extracted_data.keys())[i + 10], count)
    return extracted_data


def doubled_data(data, cellTddId):
    new_data = {}
    cleaned_data = remove_empty_values(data)
    max_length = max(len(value) for value in cleaned_data.values() if isinstance(value, list))
    print(max_length)
    cellTddId = int(cellTddId)
    print("typ danej", type(cellTddId))
    for key, value in cleaned_data.items():
        if isinstance(value, list):
            if len(value) < max_length:
                repeated_values = []
                for item in value:
                    repeated_values.extend([item] * (max_length // len(value)))
                new_data[key] = repeated_values
            else:
                new_data[key] = value
        else:
            new_data[key] = value
    lcrId = None
    if 'lcrId' in data:
        lcrId_list = data['lcrId']
        lcrId = next((value for value in lcrId_list if value != cellTddId), None)
        print("lcrId is equal to:", lcrId)
    else:
        print("Key 'lcrId' does not exist in dict")
    return new_data, lcrId


def remove_empty_values(data):
    cleaned_data = {}
    for key, value in data.items():
        if isinstance(value, list):
            cleaned_data[key] = [item for item in value if item != '']
        else:
            cleaned_data[key] = value
    return cleaned_data


def create_pool_dictionary(data, lcrId, subpoolid):
    pool_dictionary = {}
    lcrId = int(lcrId)
    subpoolid = int(subpoolid)
    assert lcrId in data['lcrId'], f"lcrId {lcrId} not found in the data."
    assert subpoolid in data['subPoolId'], f"subPoolId {subpoolid} not found in the data."
    for i in range(len(data['l1PoolId'])):
        if data['lcrId'][i] == lcrId and data['subPoolId'][i] == subpoolid:
            pool_dictionary['lcrId'] = str(data['lcrId'][i])
            pool_dictionary['l1PoolId'] = str(data['l1PoolId'][i])
            pool_dictionary['subPoolId'] = str(data['subPoolId'][i])
            pool_dictionary['poolMaxNumStreamPrb'] = str(data['poolMaxNumStreamPrb'][i])
            pool_dictionary['minStreamPrbAllocationSp'] = str(data['minStreamPrbAllocationSp'][i])
            pool_dictionary['maxStreamPrbAllocationSp'] = str(data['maxStreamPrbAllocationSp'][i])
            pool_dictionary['maxStreamPrbCgAllocLimitSp'] = str(data['maxStreamPrbCgAllocLimitSp'][i])
            pool_dictionary['maxStreamPrbGbrAllocLimitSp'] = str(data['maxStreamPrbGbrAllocLimitSp'][i])
            pool_dictionary['maxStreamPrbNonGbrAllocLimitSp'] = str(data['maxStreamPrbNonGbrAllocLimitSp'][i])
            pool_dictionary['defaultStreamPrbCapacityPerSp'] = str(data['defaultStreamPrbCapacityPerSp'][i])
            pool_dictionary['defaultLayerPrbCapacityPerSp'] = str(data['defaultLayerPrbCapacityPerSp'][i])
            pool_dictionary['totalStreamPrbDemandCg'] = str(data['totalStreamPrbDemandCg'][i])
            pool_dictionary['totalStreamPrbDemandGbr'] = str(data['totalStreamPrbDemandGbr'][i])
            pool_dictionary['currentStreamPrbCapacityPerSp'] = str(data['currentStreamPrbCapacityPerSp'][i])
            pool_dictionary['calculatedStreamPrbCapacityPerSp'] = str(data['calculatedStreamPrbCapacityPerSp'][i])
            pool_dictionary['currentLayerPrbCapacityPerSp'] = str(data['currentLayerPrbCapacityPerSp'][i])
            pool_dictionary['calculatedLayerPrbCapacityPerSp'] = str(data['calculatedLayerPrbCapacityPerSp'][i])
            break
    return pool_dictionary


def create_list_two_dict(dictionarypool0, dictionarypool1):
    combine_dict = {'0': dictionarypool0, '1': dictionarypool1}
    print(combine_dict)
    return combine_dict
