from testsuite.Wroclaw.RRM.resources.log.matchers import SyslogMessageMatcher as SM
from testsuite.Wroclaw.RRM.resources.log.helper import LogHelper
from testsuite.Wroclaw.RRM.resources.preconditions_py import bts_prefix
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config as tl
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.scf_tools.delta_modifier import edit_delta_object
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_api import AdminApi

bts_id = tl.tl.gnbs[0].instance_id

nrrel_params = [
    {'parameterName': 'cellIndividualSsbRsrpOffset', 'operation': 'update', 'value': '0dB'},
    {'parameterName': 'cellIndividualSsbRsrqOffset', 'operation': 'update', 'value': '0dB'},
    {'parameterName': 'gNbId', 'operation': 'update', 'value': bts_id},
    {'parameterName': 'gNbIdLength', 'operation': 'update', 'value': 24},
    {'parameterName': 'gnbPlmn', 'operation': 'update', 'value':
        [{
            'mcc': 310,
            'mnc': 260,
            'mncLength': 3
        }]},
    {'parameterName': 'handoverAllowedSA', 'operation': 'update', 'value': 'allowed'},
    {'parameterName': 'removeNotAllowed', 'operation': 'update', 'value': 'true'},
    {'parameterName': 'sCellAdditionMethod', 'operation': 'update', 'value': 'covBasedA1'}
]


def set_params_for_3CC_FFF_CA_to_3CC_FTT_CA(cell_nr):
    return {
        bts_prefix + '/NRCELL-' + cell_nr + '/a1ThresholdSCellAddSsbRsrpFDD': '65',
        bts_prefix + '/NRCELL-' + cell_nr + '/a1ThresholdSCellAddSsbRsrpTDD': '75',
    }


def set_params_for_3CC_FTT_CA_with_FDD_PCell_to_2CC_FF_CA(cell_nr, fdd_sCells, tdd_sCells):
    return {
        bts_prefix + '/NRCELL-' + cell_nr + '/a1ThresholdSCellAddSsbRsrpFDD': '75',
        bts_prefix + '/NRCELL-' + cell_nr + '/a1ThresholdSCellAddSsbRsrpTDD': '65',
        bts_prefix + '/NRCELL-' + tdd_sCells[0] + '/weightForSCellSelection': '5',
        bts_prefix + '/NRCELL-' + tdd_sCells[1] + '/weightForSCellSelection': '5',
        bts_prefix + '/NRCELL-' + fdd_sCells[0] + '/weightForSCellSelection': '90',
        bts_prefix + '/NRCELL-' + fdd_sCells[1] + '/weightForSCellSelection': '90'
    }


def get_emil_msg_from_CSV_sCellAdd_H32(log_path):
    log_path = str(log_path)
    log_path = log_path.encode('unicode_escape')
    with LogHelper() as lh:
        finder = lh.add_syslog(log_path)
        cell_add = finder.find_next(SM('*sCellToAddModList*'))
        assert cell_add, "Cell addition message not found in DCAP logs"
        s_cell_id = finder.find_next(SM('*physCellId 107*'))
        assert s_cell_id, "SCell with ID 107 not found in DCAP logs"
        s_cell_id = finder.find_next(SM('*physCellId 108*'))
        assert s_cell_id, "SCell with ID 108 not found in DCAP logs"
        cell_add = finder.find_next(SM('*sCellToAddModList*'))
        assert cell_add, "Cell addition message not found in DCAP logs"
        s_cell_id = finder.find_next(SM('*physCellId 104*'))
        assert s_cell_id, "SCell with ID 104 not found in DCAP logs"
        s_cell_id = finder.find_next(SM('*physCellId 105*'))
        assert s_cell_id, "SCell with ID 105 not found in DCAP logs"


def get_emil_msg_from_CSV_sCellAdd_H30(log_path):
    log_path = str(log_path)
    log_path = log_path.encode('unicode_escape')
    with LogHelper() as lh:
        finder = lh.add_syslog(log_path)
        cell_add = finder.find_next(SM('*sCellToAddModList*'))
        assert cell_add, "Cell addition message not found in DCAP logs"
        s_cell_id = finder.find_next(SM('*physCellId 104*'))
        assert s_cell_id, "SCell with ID 104 not found in DCAP logs"
        s_cell_id = finder.find_next(SM('*physCellId 105*'))
        assert s_cell_id, "SCell with ID 105 not found in DCAP logs"
        cell_add = finder.find_next(SM('*sCellToAddModList*'))
        assert cell_add, "Cell addition message not found in DCAP logs"
        s_cell_id = finder.find_next(SM('*physCellId 107*'))
        assert s_cell_id, "SCell with ID 107 not found in DCAP logs"


def trim_newline_from_path(log_path):
    return log_path.split()[0]


def set_arfcn_parameters():
    edit_delta_object(bts_prefix + '/NRDU-1',
                      carrierAggregationSupportList=['ca_Fdd_Fdd', 'ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Nsa'])
    return {
        bts_prefix + '/NRDU-1/' + 'actConnectedModeMobilityCA': 'true',
        bts_prefix + '/NRCELL-104/nrarfcn': '518250',
        bts_prefix + '/NRCELL-105/nrarfcn': '518700',
        bts_prefix + '/NRCELL-106/nrarfcn': '509802',
        bts_prefix + '/NRCELL-108/NRCELL_FDD-1/nrarfcnDl': '424380',
        bts_prefix + '/NRCELL-108/NRCELL_FDD-1/nrarfcnUl': '345620',
    }


def add_nrrel_object(nrcell_id, nrrel_id):
    related_cell_id = -1
    with AdminApi() as web_api:
        dist_name = '{mrbts_id}/NRCELL-{nrcell_id}/NRREL-{nrrel_id}'.format(mrbts_id=bts_prefix,
                                                                            nrbts_id=bts_prefix,
                                                                            nrcell_id=nrcell_id,
                                                                            nrrel_id=nrrel_id)

        nrrel_params.append({'parameterName': 'lcrId', 'operation': 'update', 'value': nrrel_id})

        new_nrrel_params = list(nrrel_params)
        new_nrrel_params.append({'parameterName': 'nrRelId', 'operation': 'update', 'value': nrrel_id})

        try:
            web_api.perform_object_recommissioning(dist_name=dist_name,
                                                   parameter=new_nrrel_params,
                                                   operation='create',
                                                   skip_parameter_relation_errors=False,
                                                   should_activate=True)
        except Exception:
            blog("NRREL-{0} object already exists, updating the object".format(nrrel_id))
            web_api.perform_object_recommissioning(dist_name=dist_name,
                                                   parameter=nrrel_params,
                                                   operation='update',
                                                   skip_parameter_relation_errors=False,
                                                   should_activate=True)
