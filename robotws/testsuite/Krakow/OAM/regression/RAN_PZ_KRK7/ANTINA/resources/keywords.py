from random import choice
from robot.api import logger
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations
from parameters import *
import subprocess
import re
from taf.rfrl.utilities.tl_config import get_count_of_radios, get_radio


def get_random_value_from_list(list_of_items):
    return choice(list_of_items)


def is_cell_added(cell_id: int):
    gnb_cell = GnbCellOperations()
    all_cells_ids = gnb_cell.get_all_cells_id()
    assert cell_id in all_cells_ids, f"Cell {cell_id} not added"
    return True


def is_cell_removed(cell_id: int):
    gnb_cell = GnbCellOperations()
    all_cells_ids = gnb_cell.get_all_cells_id()
    assert cell_id not in all_cells_ids, f"Cell {cell_id} not removed"
    return True


def generate_50mhz_delta(bts_id, cell_id):
    delta_50mhz = [
                {
                    'distName': f"MRBTS-{bts_id}/NRBTS-{bts_id}/NRCELL-{cell_id}",
                    'operation': 'update',
                    'parameters': [{
                        'parameterName': 'chBw',
                        'value': '50MHz',
                        'operation': 'update',
                    },
                        {
                        'parameterName': 'gscnOrSsPbchArfcn',
                        'value': '1',
                        'operation': 'update',
                    },
                        {
                        'parameterName': 'srsForBeamMgmt',
                        'value':
                            [
                                {
                                    'bSRS': '2',
                                    'comb': 'comb2',
                                    'cSRS': '33',
                                    'srsDlBeamFallbackOption': 'fallback once',
                                    'srsDoublePeriodicityEnabled': 'false',
                                    'srsPowerThresholdForDlBm': '-120',
                                    'srsPowerThresholdForUlBm': '-132',
                                    'srsTypeAllocForDlBm': 'antenna switching or codebook',
                                    'srsUePeriodicity': 'slots40',
                                    'srsUlBeamFallbackOption': 'fallback once'
                                }
                            ],
                        'operation': 'update',
                    }]
                },
                {
                    'distName': f"MRBTS-{bts_id}/NRBTS-{bts_id}/BWP_PROFILE-0",
                    'operation': 'update',
                    'parameters': [{
                        'parameterName': 'locationAndBandwidthUl',
                        'value':
                        [
                            {
                                'cRbSizeUl': 'n51',
                                'cRbStartUl': 'crb0'
                            }
                        ],
                        'operation': 'update',
                        }]

                },
                {
                    'distName': f"MRBTS-{bts_id}/NRBTS-{bts_id}/BWP_PROFILE-2",
                    'operation': 'update',
                    'parameters': [{
                        'parameterName': 'locationAndBandwidthUl',
                        'value':
                            [
                                {
                                    'cRbSizeUl': 'n51',
                                    'cRbStartUl': 'crb0'
                                }
                            ],
                        'operation': 'update',
                    }]
                },
                {
                    'distName': f"MRBTS-{bts_id}/NRBTS-{bts_id}/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_DEDICATED-1",
                    'operation': 'update',
                    'parameters': [{
                        'parameterName': 'coresetDedicated',
                        'value':
                            [
                                {
                                    'cceToRegMapping': 'nonInterleaved',
                                    'coresetId': '1',
                                    'cRbStart': '0',
                                    'duration': '1',
                                    'interleaverSize': 'none',
                                    'regBundleSize': 'n6',
                                    'size': '120',
                                }
                            ],
                        'operation': 'update',
                    }]
                }
    ]
    return delta_50mhz


def get_qc_ids(hostname, sw_version):
    if '9999' in sw_version:
        release = 'SBTS00'
    else:
        release = sw_version.split('_')[0]
    try:
        return qc_id_mapping[hostname][release]
    except Exception as e:
        logger.debug(f"Failed to retrieve qc_ids. Probably release: {release} doesn't exist in qc_id_mapping")
        raise e


def get_ue_data(hostname):
    try:
        return ue_data[hostname]
    except Exception as e:
        logger.debug('Failed to retrive ue data.')
        raise e


def get_hostname():
    try:
        full_hostname = subprocess.getoutput("hostname")
        match = re.search(r"\d+\-\d+\-.*\d+", full_hostname)
        if match:
            hostname = match[0].replace("-", "_").rstrip()
            logger.debug(f"Host name: {hostname}")
            return hostname
        else:
            logger.error("Hostname does not match expected pattern.")
            raise ValueError("Invalid hostname format.")
    except Exception as e:
        logger.debug("Failed to retrieve hostname.")
        raise e


def prepare_rmods_with_pdu_ports():
    ru_pdu_mapping = []
    number_of_radios = get_count_of_radios()
    for i in range(number_of_radios):
        ru = get_radio(ru_id=i)
        ru_pdu_mapping.append({
            ru.serial_number: ru.pdu_port
        })
    return ru_pdu_mapping


def get_cell_parameters(cell_id):
    for cell_params in cells_mapping:
        if cell_params['cell_id_to_copy_from'] == cell_id:
            return cell_params
    return None


def get_ue_cycles(tl_data):
    data_for_cycle = []
    for key in tl_data.keys():
        if key.startswith('cells_to_block'):
            ue_params_for_cells = tl_data[key]
            data_for_cycle.append({
                'name': key,
                'cells_to_block': ue_params_for_cells['cells'],
                'ue_index': ue_params_for_cells['ue_index'],
                'ue_key': ue_params_for_cells['ue_key']
            })
            print(f"data for cycle:{data_for_cycle}")
    return data_for_cycle


def get_ue_cycle_by_name(tl_data, cycle_name):
    cycles = get_ue_cycles(tl_data)

    for cycle in cycles:
        if cycle['name'] == cycle_name:
            return cycle

    raise ValueError(f"Cycle {cycle_name} not found in {tl_data}")
