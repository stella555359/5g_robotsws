"""
Author: Ding Binmei
Description: Provide common keyword for online parameter operations for 7935 feature
"""
from robot.libraries.BuiltIn import BuiltIn
import testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.Parameters_modify_lib \
    as param_modify_lib
import testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.lib.get_bts_info as get_bts_info
import testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.coam_parameter as coam_parameter
import testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.coam_gnb_classical as coam_gnb_classical
import json
import logging
# import NIDD_Modify_data_template as data_template
DN_MNLENT = param_modify_lib.DN_MRBTS+"/MNL-1/MNLENT-1"

# RU_SYNC_MAPPING get from BTS in suite setup
RU_SYNC_MAPPING = BuiltIn().get_variable_value('${RU_SYNC_MAPPING}')


def get_params_to_disable_7935_on_related_rmod_id(list_rmod_id):
    """
    Author: Ding Binmei
    When actRuIntelligentSynceAstHoTime are disabled for all rmods, the following parameters should be deleted
    :param list_rmod_id: list of rmod_id. Example: ['1', '2', '3']
    """
    params_disable_7935 = []
    for rmod_id in list_rmod_id:
        rmod_id = str(rmod_id)
        dn_sync = DN_MNLENT + "/SYNC-" + RU_SYNC_MAPPING[rmod_id]['sync_id']
        params_disable_7935_on_sync = [
            dict(dist_name=dn_sync, parameter='maximumRuTimeErrorAstHoEnd'),
            dict(dist_name=dn_sync, parameter='maxPtpNetworkTimeErrorRuIn'),
            dict(dist_name=dn_sync, parameter='synceAssistedHoldoverMode')]
        dn_syncE = dn_sync + "/CLOCK-1/SYNCE-1"
        params_disable_7935_on_syncE = [
            dict(dist_name=dn_syncE, parameter='ruAstHoSyncePortNumber'),
            dict(dist_name=dn_syncE, parameter='synceNtwReAgtForceMajor')
        ]
        params_disable_7935 += params_disable_7935_on_sync + params_disable_7935_on_syncE
    return params_disable_7935


def get_param_update_for_actRuIntelligentSynceAstHoTime(list_rmod_id, value):
    """
    Author: Ding Binmei
    :param list_rmod_id: list of rmod_id
    :param value: value to update. true/false
    """
    params_update = []
    for rmod_id in list_rmod_id:
        rmod_id = str(rmod_id)
        dn_sync = DN_MNLENT + "/SYNC-" + RU_SYNC_MAPPING[rmod_id]['sync_id']
        params_update.append(dict(dist_name=dn_sync, parameter='actRuIntelligentSynceAstHoTime', value=str(value)))
    return params_update


def get_params_to_update_for_counters(value):
    """
    Author: Ding Binmei
    :param value: value to update. 5min/15min/30min/.../disabled
    """
    return [
        dict(value=str(value), dist_name='MNL-1/MNLENT-1/PMMNL-1', parameter='ruSynceHoPeriod'),
        dict(value=str(value), dist_name='MNL-1/MNLENT-1/PMMNL-1', parameter='ruSynceNetworkReArrgt'),
        dict(value=str(value), dist_name='MNL-1/MNLENT-1/PMMNL-1', parameter='ruTopPhaseSync')
    ]


def get_params_to_enable_7935_based_on_disable_params(dict_disable_params, connection="GNB_OAM"):
    """
    Author: Ding Binmei
    :param dict_disable_params: dict of disable parameters.
           Should be the value for params_for_online_modify.RESTAPI_DISABLE_7935_ALL_PARAMs
    Example: Can only support keys with param_to_del and param_to_upd
    {
        "param_to_del": [
            {"dist_name": "MNL-1/MNLENT-1/PMCADM-1", "parameter": "ruSynceHoPeriod"},
            {"dist_name": "MNL-1/MNLENT-1/PMCADM-1", "parameter": "ruSynceNetworkReArrgt"},
            {"dist_name": "MNL-1/MNLENT-1/PMCADM-1", "parameter": "ruTopPhaseSync"}
        ],
        "param_to_upd": [
            {"dist_name": "MNL-1/MNLENT-1/PMCADM-1", "parameter": "ruSynceHoPeriod", "value": "5min"},
            {"dist_name": "MNL-1/MNLENT-1/PMCADM-1", "parameter": "ruSynceNetworkReArrgt", "value": "5min"},
            {"dist_name": "MNL-1/MNLENT-1/PMCADM-1", "parameter": "ruTopPhaseSync", "value": "5min"}
        ]
    }
    """
    modify_type = dict_disable_params.keys()
    delta_file_list_updated = []
    if "param_to_del" in modify_type:
        if dict_disable_params['param_to_del']:
            delta_file_del = coam_parameter.create_delete_parameters_delta(
                parameters=dict_disable_params['param_to_del'], connection=connection)
            delta_file_list_updated.append(delta_file_del['reverse'])
    if "param_to_upd" in modify_type:
        if dict_disable_params['param_to_upd']:
            delta_file_upd = coam_parameter.create_update_parameters_delta(
                parameters=dict_disable_params['param_to_upd'], connection=connection)
            delta_file_list_updated.append(delta_file_upd['reverse'])
    combined_json_data = []
    for json_file in delta_file_list_updated:
        file_obj = open(json_file, 'r')
        file_content = json.load(file_obj)
        combined_json_data.extend(file_content)
        file_obj.close()
    file_folder = delta_file_list_updated[0].rsplit(sep='/', maxsplit=1)[0]
    combined_json_file = file_folder + '/combined_reverse.json'
    logging.debug("combined_json_file is {}".format(combined_json_file))
    logging.debug("combined_json_data is {}".format(combined_json_data))
    with open(combined_json_file, 'w') as f:
        json.dump(combined_json_data, f, indent=4, separators=(',', ':'))
    return combined_json_file


def get_params_to_update_for_ssmAcceptanceLevel(list_rmod_id, exp_ssmAcceptanceLevel):
    """
    Author: Ding Binmei
    :param list_rmod_id: list of rmod_id
    :param exp_ssmAcceptanceLevel: expected value for ssmAcceptanceLevel. E.G: ssmPRCorPRS/ssmePRTC
    :return: list of parameters to update
    """
    params_update = []
    for rmod_id in list_rmod_id:
        rmod_id = str(rmod_id)
        dn_syncE = DN_MNLENT + "/SYNC-" + RU_SYNC_MAPPING[rmod_id]['sync_id']+"/CLOCK-1/SYNCE-1"
        params_update.append(
            dict(dist_name=dn_syncE, parameter='ssmAcceptanceLevel', value=str(exp_ssmAcceptanceLevel)))
    return params_update


def _get_params_to_delete_mo(list_dn):
    obj_to_del = []
    for dn in list_dn:
        obj_to_del.append({'dist_name': dn})
    return obj_to_del


def get_params_to_enable_ecpri72e(list_rmod_id, connection="GNB_OAM"):
    """
    Author: Ding Binmei
    Description: Get params to enable ecpri72e based on rmod_id
    Based on pdl validation. When enable 72e, the following parameters should be updated:
        prams to be updated:
        --NRCELL-101/actEcpri72e=true
        --NRCELL-101/numberOfRxBeamforming = 16Rx
        --NRCELL-101/nrCellType=16DL4UL
        --NRCELL-101/actSimplChConfMAA=true
        params to be added:
        --NRCELL-101/numberOfRxPucch=8Rx
        mos to be deleted: Can only leave one channel group and on channel under one cell
        --MRBTS-2121/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-101/CHANNELGROUP-2
        --MRBTS-2121/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-101/CHANNEL-2
    :param list_rmod_id: list of rmod_id
    :param connection: connection alias for coam
    :return: dict_params_to_enable_ecpri72e
    """
    gnb_relation_mapping = coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids(
        connection_alias=connection)
    dict_params_to_enable_ecpri72e = {"param_to_upd": [], "param_to_add": [], "object_to_del": []}
    for rmod_id in list_rmod_id:
        rmod_id = str(rmod_id)
        cell_ids = coam_gnb_classical.get_cell_ids_based_on_rmod_id(
            rmod_id=rmod_id, gnb_relation_mapping=gnb_relation_mapping, connection_alias=connection)
        for cell_id in cell_ids:
            dn_cell = param_modify_lib.DN_NRBTS + "/NRCELL-" + str(cell_id)
            lcrId = gnb_relation_mapping[cell_id]["lcrId"]
            dn_LCELNR = param_modify_lib.DN_MRBTS + "/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-" + str(lcrId)
            # params to be updated based on pdl rule
            list_params_to_update = [
                dict(dist_name=dn_cell, parameter='actEcpri72e', value='true'),
                dict(dist_name=dn_cell, parameter='numberOfRxBeamforming', value='16Rx'),
                dict(dist_name=dn_cell, parameter='nrCellType', value='16DL4UL'),
                dict(dist_name=dn_LCELNR, parameter='actSimplChConfMAA', value='true'),
            ]
            dict_params_to_enable_ecpri72e["param_to_upd"].extend(list_params_to_update)
            # params to be added based on pdl rule
            list_params_to_add = [dict(dist_name=dn_cell, parameter='numberOfRxPucch', value='8Rx')]
            dict_params_to_enable_ecpri72e["param_to_add"].extend(list_params_to_add)
            # params to be deleted based on pdl rule:
            #   if actSimplChConfMAA set to true, one cell can only have one channel group and one channel
            dict_dn_info_channel_groups_channels = (
                get_bts_info.get_dn_for_channel_groups_and_channels_based_on_cell_id(
                    cell_id=cell_id, gnb_relation_mapping=gnb_relation_mapping, connection_alias=connection))
            logging.debug("dict_dn_info_channel_groups_channels is {}".format(dict_dn_info_channel_groups_channels))
            list_dn_channel_groups = dict_dn_info_channel_groups_channels["dn_channel_group"]
            list_dn_channel = dict_dn_info_channel_groups_channels["dn_channel"]
            dn_channel_grps_and_channels_to_be_deleted = []
            if len(list_dn_channel_groups) > 1:
                dn_channel_grps_and_channels_to_be_deleted = list_dn_channel_groups[1:]
            if len(list_dn_channel) > 1:
                dn_channel_grps_and_channels_to_be_deleted.extend(list_dn_channel[1:])
            logging.debug("dn_channel_grps_and_channels_to_be_deleted is {}".format(
                dn_channel_grps_and_channels_to_be_deleted))
            dict_params_to_enable_ecpri72e["object_to_del"].extend(_get_params_to_delete_mo(
                list_dn=dn_channel_grps_and_channels_to_be_deleted))
    return dict_params_to_enable_ecpri72e


def get_params_to_update_for_ruAstHoSyncePortNumber(list_rmod_id, exp_ruAstHoSyncePortNumber):
    """
    Author: Ding Binmei
    :param list_rmod_id: list of rmod_id
    :param exp_ruAstHoSyncePortNumber: expected value for ruAstHoSyncePortNumber. E.G: 1/3
    :return: list of parameters to update
    """
    params_update = []
    for rmod_id in list_rmod_id:
        rmod_id = str(rmod_id)
        dn_syncE = DN_MNLENT + "/SYNC-" + RU_SYNC_MAPPING[rmod_id]['sync_id']+"/CLOCK-1/SYNCE-1"
        params_update.append(
            dict(dist_name=dn_syncE, parameter='ruAstHoSyncePortNumber', value=str(exp_ruAstHoSyncePortNumber)))
    return params_update


def get_params_to_update_synceAssistedHoldoverMode_to_ManualHoldover(list_rmod_id, exp_manualSynceAssistedHoPeriod):
    """
    Author: Ding Binmei
    Description: Get params to update synceAssistedHoldoverMode to ManualHoldover
    :param list_rmod_id: list of rmod_id
    :param exp_manualSynceAssistedHoPeriod: value to update for manualSynceAssistedHoPeriod. 1~600 (h)
    :return: dict_params_to_update
    """
    dict_params_to_update = {"param_to_upd": [], "param_to_add": []}
    for rmod_id in list_rmod_id:
        rmod_id = str(rmod_id)
        dn_sync = DN_MNLENT + "/SYNC-" + RU_SYNC_MAPPING[rmod_id]['sync_id']
        dict_params_to_update["param_to_upd"].append(
            dict(dist_name=dn_sync, parameter='synceAssistedHoldoverMode', value='ManualHoldover'))
        dict_params_to_update["param_to_add"].append(
            dict(dist_name=dn_sync, parameter='manualSynceAssistedHoPeriod',
                 value=str(exp_manualSynceAssistedHoPeriod)))
    return dict_params_to_update
