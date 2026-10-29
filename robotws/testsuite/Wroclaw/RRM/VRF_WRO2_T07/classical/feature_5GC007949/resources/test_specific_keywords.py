from time import sleep
from datetime import datetime, timedelta
from taf.config.scf import scf

from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer import finder
from testsuite.Wroclaw.RRM.resources.decorators import wait_until_function_succeeds
from testsuite.Wroclaw.RRM.resources.scf_verification import scf_verifier as sv
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.DeltaStore import DeltaStore
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils import AdminUtils
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_api import AdminApi
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.uuf.checkpoints import verify_on_air
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.attenuator import Attenuator
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.rue import attach_utils as rue_utils
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.gnb_mirroring import L1L2
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.btslog import \
    start_btslog_on_local_machine, stop_and_collect_btslog
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.pm_counters as pmc
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.connections import ssh, connect_to_smod
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.common.file_helper import get_filepaths
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.matchers import PcapMessageMatcher as Pm
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.matchers import SyslogMessageMatcher as Sm
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.log_helper import LogHelper
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.common as common
import subprocess
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation import get_sw_release_name

_ssh = ssh()
mrbts_id = tl.gnbs[0].global_bts_id
nrbts_id = tl.gnbs[0].instance_id

SKIP_REL_ERR = True
REVERT_SCF_TIMEOUT_SECONDS = 600
GLOBAL_GNB_ID_CONSTANT = 2 ** 14
pre_change_scf = None


def suite_setup():
    _l1l2 = L1L2()
    _atten = Attenuator(with_initialisation=False)
    _new_l1l2 = True
    return _l1l2, _atten, _new_l1l2


l1l2, atten, new_l1l2 = suite_setup()


@logged_keyword
def get_relation_dist_name(cell_id, nr_rel):
    return 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-{cell_id}/NRREL-{nr_rel}'.format(
        mrbts_id=mrbts_id,
        nrbts_id=nrbts_id,
        cell_id=cell_id,
        nr_rel=nr_rel)


@logged_keyword
def get_all_cells_relations_dist_list():
    _scf = scf()
    _scf.load_scf(AdminUtils().download_current_scf())
    cell_ids = []
    relations_dist_name_list = []
    with AdminApi() as web_api:
        results = web_api.get_cells_info()
        for cell in results:
            cell_ids.append(cell['globalCellId'])
    for cell_id in cell_ids:
        for rel in range(256):
            dist_name = get_relation_dist_name(cell_id=cell_id, nr_rel=rel)
            if _scf.is_object_in_scf(dist_name):
                relations_dist_name_list.append(dist_name)
    return relations_dist_name_list


@logged_keyword
def set_frame_structure_1116_0ms(cell_dist, delta_obj):
    delta_obj.add_complex_item_to_delta(dist_name=cell_dist, list_name='tddFrameStructure',
                                        frameStructureType='tdLte',
                                        lteToNrFrameShift='0ms',
                                        guardPeriodLength='4Symbols',
                                        tdLteUlDlConfig='tdLteConfig2')


@logged_keyword
def set_frame_structure_1116_3ms(cell_dist, delta_obj):
    delta_obj.add_complex_item_to_delta(dist_name=cell_dist, list_name='tddFrameStructure',
                                        frameStructureType='tdLte',
                                        lteToNrFrameShift='3ms',
                                        guardPeriodLength='4Symbols',
                                        tdLteUlDlConfig='tdLteConfig2')


@logged_keyword
def set_frame_structure_1070(cell_dist, delta_obj):
    delta_obj.add_complex_item_to_delta(dist_name=cell_dist, list_name='tddFrameStructure',
                                        frameStructureType='semiStatic',
                                        ulDlDataSlotRatio='3/7',
                                        guardPeriodLength='2Symbols',
                                        tdLteUlDlConfig='tdLteConfig2')


@logged_keyword
def set_frame_structure_1208(cell_dist, delta_obj):
    delta_obj.add_complex_item_to_delta(dist_name=cell_dist, list_name='tddFrameStructure',
                                        frameStructureType='semiStatic',
                                        ulDlDataSlotRatio='1/4',
                                        guardPeriodLength='2Symbols',
                                        tdLteUlDlConfig='tdLteConfig2')


@logged_keyword
def set_deactivation_timer(deltastore, sCellDeactivationTimerGNB):
    api = AdminUtils()
    cells = api.get_cells_dist_names()
    for cell in cells:
        cell_number = cell.split("-")[-1]
        cell_dist = 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-{cell_id}'.format(mrbts_id=mrbts_id,
                                                                                nrbts_id=nrbts_id,
                                                                                cell_id=str(cell_number))
        deltastore.update_managed_object_and_parameter_to_delta(dist_name=cell_dist,
                                                                sCellDeactivationTimerGNB=sCellDeactivationTimerGNB)


@logged_keyword
def get_cell_dist(cell_mo):
    return common.get_cell_dist(cell_mo)


@logged_keyword
def get_used_relations_list(cells_used_in_TC):
    relations = sorted(get_all_cells_relations_dist_list())
    list_of_all_possible_relations = []
    for cell in cells_used_in_TC:
        for rel in cells_used_in_TC:
            dist_name = get_relation_dist_name(cell_id=cell, nr_rel=rel)
            list_of_all_possible_relations.append(dist_name)
    return list(set(relations).intersection(list_of_all_possible_relations))


@logged_keyword
def set_relations(ds_obj, cells_used_in_TC, sCellAdditionMethod, sCellOperationalMode):
    relations_available = sorted(get_all_cells_relations_dist_list())
    relations_used_in_tc = get_used_relations_list(cells_used_in_TC)
    relations_to_configure = []
    relations_to_delete = []
    for relation in relations_available:
        if relation in relations_used_in_tc:
            relations_to_configure.append(relation)
        else:
            relations_to_delete.append(relation)

    for relation in list(set(relations_to_configure)):
        if "NRREL-{}".format(tl.cell_with_no_CC) in relation or "NRCELL-{}".format(tl.cell_with_no_CC) in relation:
            relations_to_configure.remove(relation)
            relations_to_delete.append(relation)

    for relation in list(set(relations_to_delete)):
        if relation in list(set(relations_to_configure)):
            relations_to_delete.remove(relation)

    for relation in list(set(relations_to_delete)):
        ds_obj.add_param_to_delta_to_delete_it(relation, 'sCellAdditionMethod')
    for relation in list(set(relations_to_configure)):
        ds_obj.add_param_to_delta(relation, 'sCellAdditionMethod', sCellAdditionMethod)

    for relation in list(set(relations_to_delete)):
        ds_obj.add_param_to_delta_to_delete_it(relation, 'sCellOperationalMode')
    for relation in list(set(relations_to_configure)):
        ds_obj.add_param_to_delta(relation, 'sCellOperationalMode', sCellOperationalMode)


@logged_keyword
def set_relations_without_scell_operational_mode(ds_obj, cells_used_in_TC, sCellAdditionMethod):
    relations_available = sorted(get_all_cells_relations_dist_list())
    relations_used_in_tc = get_used_relations_list(cells_used_in_TC)
    relations_to_configure = []
    relations_to_delete = []
    for relation in relations_available:
        if relation in relations_used_in_tc:
            relations_to_configure.append(relation)
        else:
            relations_to_delete.append(relation)

    for relation in list(set(relations_to_configure)):
        if "NRREL-{}".format(tl.cell_with_no_CC) in relation or "NRCELL-{}".format(tl.cell_with_no_CC) in relation:
            relations_to_configure.remove(relation)
            relations_to_delete.append(relation)

    for relation in list(set(relations_to_delete)):
        if relation in list(set(relations_to_configure)):
            relations_to_delete.remove(relation)

    for relation in list(set(relations_to_delete)):
        ds_obj.add_param_to_delta_to_delete_it(relation, 'sCellAdditionMethod')
    for relation in list(set(relations_to_configure)):
        ds_obj.add_param_to_delta(relation, 'sCellAdditionMethod', sCellAdditionMethod)


@logged_keyword
def block_handover_to_cell(ds, source_cells, cell_to_block):
    for source_cell in source_cells:
        dist_name = get_relation_dist_name(cell_id=source_cell, nr_rel=cell_to_block)
        ds.add_param_to_delta(dist_name, 'handoverAllowedSA', 'forbidden')


@logged_keyword
def unblock_handover_to_cell(ds, source_cells, cell_to_unblock):
    for source_cell in source_cells:
        dist_name = get_relation_dist_name(cell_id=source_cell, nr_rel=cell_to_unblock)
        ds.add_param_to_delta(dist_name, 'handoverAllowedSA', 'allowed')


@logged_keyword
def check_if_5QI1_counters_incremented(counter_dir, counter_ids, target_counter_value=1):
    value_dict = pmc.get_relevant_pm_counters(pi_dir=counter_dir, counter_ids=[counter_ids])
    if not value_dict:
        raise KeyError('dict is empty, there is no such counters collected on bts')
    for counter in value_dict.values():
        incremented = False
        for cell, counter_value_list in iter(counter.items()):
            for counter_value in counter_value_list:
                if counter_value >= int(target_counter_value):
                    incremented = True
                    break
            if incremented:
                break
        assert incremented, '5QI1 Counters not incremented'
    blog("VoNR call confirmed")
    return value_dict


@logged_keyword
def get_cells_numbers(cells):
    cell_identities = []
    phy_cell_ids = []
    api = AdminUtils()
    scf_file = api.download_current_scf()
    for cell in cells:
        phy_cell_ids.append(get_physicall_cell_id_from_mo_cell_id(cell, scf_file=scf_file))
        cell_identities.append(get_nrCellIdentity_from_mo_cell_id(cell))
    return cell_identities, phy_cell_ids


@logged_keyword
def backup_current_scf():
    return common.backup_current_scf()


@logged_keyword
def revert_scf(scf_to_revert):
    return common.revert_scf(scf_to_revert)


@logged_keyword
def check_preconditions_a_1(cells_used_in_TC):
    backup_current_scf()
    cells_used_in_TC_without3 = [1, 2]
    ds = DeltaStore()
    ds.initialise_delta_store()
    ds.update_managed_object_and_parameter_to_delta(
        dist_name='MRBTS-{mrbts_id}/NRBTS-{nrbts_id}'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        sCellActivationMethod='blind')
    set_relations_without_scell_operational_mode(ds, cells_used_in_TC_without3, 'blind')
    set_deactivation_timer(ds, 'infinity')
    set_frame_structure_1116_0ms(get_cell_dist(cells_used_in_TC[0]), ds)
    set_frame_structure_1116_0ms(get_cell_dist(cells_used_in_TC[1]), ds)
    set_frame_structure_1208(get_cell_dist(cells_used_in_TC[2]), ds)
    nrdu_dist_name = 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRDU-1'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id)
    ds.add_param_to_delta(nrdu_dist_name, 'carrierAggregationSupportList',
                          ['ca_Fr1Tdd_Sa'])
    ds.validate_scf(skip_parameter_relation_errors=SKIP_REL_ERR)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=SKIP_REL_ERR)
    verify_on_air()
    blog("Preconditions fulfilled")


@logged_keyword
def check_preconditions_a_2(cells_used_in_TC):
    backup_current_scf()
    cells_used_in_TC_without3 = [1, 2]
    ds = DeltaStore()
    ds.initialise_delta_store()
    ds.update_managed_object_and_parameter_to_delta(
        dist_name='MRBTS-{mrbts_id}/NRBTS-{nrbts_id}'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        sCellActivationMethod='bufferBased')
    # set_relations(ds, cells_used_in_TC, 'blind', 'dlOnly')
    set_relations_without_scell_operational_mode(ds, cells_used_in_TC_without3, 'blind')
    set_deactivation_timer(ds, 'ms320')
    set_frame_structure_1116_0ms(get_cell_dist(cells_used_in_TC[0]), ds)
    set_frame_structure_1116_0ms(get_cell_dist(cells_used_in_TC[1]), ds)
    set_frame_structure_1208(get_cell_dist(cells_used_in_TC[2]), ds)
    nrdu_dist_name = 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRDU-1'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id)
    ds.add_param_to_delta(nrdu_dist_name, 'carrierAggregationSupportList',
                          ['ca_Fr1Tdd_Sa'])
    ds.validate_scf(skip_parameter_relation_errors=SKIP_REL_ERR)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=SKIP_REL_ERR)
    verify_on_air()
    blog("Preconditions fulfilled")


@logged_keyword
def check_preconditions_a_8(cells_used_in_TC):
    backup_current_scf()
    # cells_used_in_TC_without3 = [1, 2]
    ds = DeltaStore()
    ds.initialise_delta_store()
    ds.update_managed_object_and_parameter_to_delta(
        dist_name='MRBTS-{mrbts_id}/NRBTS-{nrbts_id}'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        sCellActivationMethod='blind',
        sCellDeactivationBadRlqCount=2)
    ds.update_managed_object_and_parameter_to_delta(
        dist_name='MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-3'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        sCellBadChannelQualityThreshold=4)
    set_relations(ds, cells_used_in_TC, 'blind', 'dlOnly')
    # set_relations_without_scell_operational_mode(ds, cells_used_in_TC_without3, 'blind')
    # set_relations_without_scell_operational_mode(ds, cells_used_in_TC, 'blind')
    set_deactivation_timer(ds, 'infinity')
    set_frame_structure_1116_0ms(get_cell_dist(cells_used_in_TC[0]), ds)
    set_frame_structure_1116_0ms(get_cell_dist(cells_used_in_TC[1]), ds)
    set_frame_structure_1208(get_cell_dist(cells_used_in_TC[2]), ds)
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-1'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'prachConfigurationIndex', '97')
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-2'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'prachConfigurationIndex', '97')
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-2'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'qRxLevMin', '-30')
    nrdu_dist_name = 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRDU-1'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id)
    ds.add_param_to_delta(nrdu_dist_name, 'carrierAggregationSupportList',
                          ['ca_Fr1Tdd_Sa', 'ca_Fr1Tdd_Fdd_Sa', 'ca_Fr1Tdd_Any_Sa'])
    ds.validate_scf()
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta)
    verify_on_air()
    blog("Preconditions fulfilled")


@logged_keyword
def check_preconditions_a_11(cells_used_in_TC):
    backup_current_scf()
    ds = DeltaStore()
    ds.initialise_delta_store()
    ds.update_managed_object_and_parameter_to_delta(
        dist_name='MRBTS-{mrbts_id}/NRBTS-{nrbts_id}'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        sCellActivationMethod='bufferBased')
    set_relations(ds, cells_used_in_TC, 'blind', 'dlOnly')
    # set_relations_without_scell_operational_mode(ds, cells_used_in_TC, 'blind')
    set_deactivation_timer(ds, 'ms320')
    set_frame_structure_1070(get_cell_dist(cells_used_in_TC[0]), ds)
    set_frame_structure_1116_0ms(get_cell_dist(cells_used_in_TC[1]), ds)
    set_frame_structure_1116_0ms(get_cell_dist(cells_used_in_TC[2]), ds)
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-1'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'prachConfigurationIndex', '97')
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-2'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'prachConfigurationIndex', '97')
    nrdu_dist_name = 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRDU-1'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id)
    ds.add_param_to_delta(nrdu_dist_name, 'carrierAggregationSupportList',
                          ['ca_Fr1Tdd_Sa', 'ca_Fr1Tdd_Fdd_Sa', 'ca_Fr1Tdd_Any_Sa'])
    ds.validate_scf()
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta)
    verify_on_air()
    lock_cell_before_test(7)
    blog("Preconditions fulfilled")


@logged_keyword
def check_preconditions_b_01(cells_used_in_TC):
    backup_current_scf()
    cells_used_in_TC_without3 = [1, 2]
    ds = DeltaStore()
    ds.initialise_delta_store()
    ds.update_managed_object_and_parameter_to_delta(
        dist_name='MRBTS-{mrbts_id}/NRBTS-{nrbts_id}'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        sCellActivationMethod='blind')
    # set_relations(ds, cells_used_in_TC, 'covBasedA1', 'dlOnly')
    set_relations_without_scell_operational_mode(ds, cells_used_in_TC_without3, 'covBasedA1')
    set_deactivation_timer(ds, 'infinity')
    set_frame_structure_1116_0ms(get_cell_dist(cells_used_in_TC[0]), ds)
    set_frame_structure_1116_0ms(get_cell_dist(cells_used_in_TC[1]), ds)
    set_frame_structure_1208(get_cell_dist(cells_used_in_TC[2]), ds)
    nrdu_dist_name = 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRDU-1'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id)
    ds.add_param_to_delta(nrdu_dist_name, 'carrierAggregationSupportList',
                          ['ca_Fr1Tdd_Sa'])
    ds.validate_scf(skip_parameter_relation_errors=SKIP_REL_ERR)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=SKIP_REL_ERR)
    verify_on_air()
    blog("Preconditions fulfilled")


@logged_keyword
def check_preconditions_b_04(cells_used_in_TC):
    backup_current_scf()
    ds = DeltaStore()
    ds.initialise_delta_store()
    ds.update_managed_object_and_parameter_to_delta(
        dist_name='MRBTS-{mrbts_id}/NRBTS-{nrbts_id}'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        sCellActivationMethod='blind')
    # set_relations(ds, cells_used_in_TC, 'covBasedA1', 'dlOnly')
    set_relations_without_scell_operational_mode(ds, cells_used_in_TC, 'covBasedA1')
    ds.add_param_to_delta_to_delete_it(get_relation_dist_name(cells_used_in_TC[3], cells_used_in_TC[1]),
                                       'sCellAdditionMethod')
    ds.add_param_to_delta_to_delete_it(get_relation_dist_name(cells_used_in_TC[3], cells_used_in_TC[2]),
                                       'sCellAdditionMethod')
    ds.add_param_to_delta_to_delete_it(get_relation_dist_name(cells_used_in_TC[3], cells_used_in_TC[1]),
                                       'sCellOperationalMode')
    ds.add_param_to_delta_to_delete_it(get_relation_dist_name(cells_used_in_TC[3], cells_used_in_TC[2]),
                                       'sCellOperationalMode')
    set_deactivation_timer(ds, 'infinity')
    block_handover_to_cell(ds, [cells_used_in_TC[1], cells_used_in_TC[2]], tl.cell_with_no_CC)  # src_mo=1,2; block=3
    unblock_handover_to_cell(ds, [cells_used_in_TC[1], cells_used_in_TC[2]], cells_used_in_TC[3])
    set_frame_structure_1070(get_cell_dist(cells_used_in_TC[0]), ds)
    set_frame_structure_1116_0ms(get_cell_dist(cells_used_in_TC[1]), ds)
    set_frame_structure_1116_0ms(get_cell_dist(cells_used_in_TC[2]), ds)
    set_frame_structure_1208(get_cell_dist(cells_used_in_TC[3]), ds)
    set_frame_structure_1208(get_cell_dist(cells_used_in_TC[4]), ds)
    nrdu_dist_name = 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRDU-1'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id)
    ds.add_param_to_delta(nrdu_dist_name, 'carrierAggregationSupportList',
                          ['ca_Fr1Tdd_Sa'])
    ds.validate_scf(skip_parameter_relation_errors=SKIP_REL_ERR)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=SKIP_REL_ERR)
    verify_on_air()
    lock_cell_before_test(7)
    blog("Preconditions fulfilled")


@logged_keyword
def check_preconditions_b_05(cells_used_in_TC):
    backup_current_scf()
    cells_used_in_TC = [1, 2, 3, 5, 6]
    ds = DeltaStore()
    ds.initialise_delta_store()
    ds.update_managed_object_and_parameter_to_delta(
        dist_name='MRBTS-{mrbts_id}/NRBTS-{nrbts_id}'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        sCellActivationMethod='blind')
    # set_relations(ds, cells_used_in_TC, 'covBasedA1')
    # set_relations(ds, cells_used_in_TC, 'covBasedA1', 'dlOnly')
    set_relations_without_scell_operational_mode(ds, cells_used_in_TC, 'covBasedA1')
    # set_relations_without_scell_operational_mode(ds, cells_used_in_TC, 'covBasedA1')
    # set_relations_without_scell_operational_mode(ds, cells_used_in_TC, 'blind')
    set_deactivation_timer(ds, 'infinity')
    set_frame_structure_1116_0ms(get_cell_dist(cells_used_in_TC[0]), ds)
    set_frame_structure_1116_0ms(get_cell_dist(cells_used_in_TC[1]), ds)
    set_frame_structure_1208(get_cell_dist(cells_used_in_TC[2]), ds)
    nrdu_dist_name = 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRDU-1'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id)
    ds.add_param_to_delta(nrdu_dist_name, 'carrierAggregationSupportList',
                          ['ca_Fr1Tdd_Sa', 'ca_Fr1Tdd_Fdd_Sa', 'ca_Fr1Tdd_Any_Sa'])
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-1/NRREL-5'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'sCellOperationalMode', 'dlOnly')
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-1/NRREL-6'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'sCellOperationalMode', 'dlOnly')
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-1/NRREL-2'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'sCellOperationalMode', 'dlOnly')
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-1/NRREL-3'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'sCellOperationalMode', 'dlOnly')
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-2/'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'qRxLevMin', '-30')
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-5/'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'qRxLevMin', '-30')
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-6/'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'qRxLevMin', '-30')

    ds.validate_scf(skip_parameter_relation_errors=SKIP_REL_ERR)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=SKIP_REL_ERR)
    verify_on_air()
    blog("Preconditions fulfilled")


@logged_keyword
def check_preconditions_b_13(cells_used_in_TC):
    backup_current_scf()
    # cells_used_in_TC_without3 = [1, 2, 7]
    ds = DeltaStore()
    ds.initialise_delta_store()
    ds.update_managed_object_and_parameter_to_delta(
        dist_name='MRBTS-{mrbts_id}/NRBTS-{nrbts_id}'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        sCellActivationMethod='blind')
    block_handover_to_cell(ds, [cells_used_in_TC[0], cells_used_in_TC[1]], cells_used_in_TC[2])  # src_mo=1,2; block=3
    unblock_handover_to_cell(ds, [cells_used_in_TC[0], cells_used_in_TC[1]], cells_used_in_TC[3])
    set_relations(ds, cells_used_in_TC, 'covBasedA1', 'dlOnly')
    # set_relations_without_scell_operational_mode(ds, cells_used_in_TC_without3, 'covBasedA1')
    set_deactivation_timer(ds, 'infinity')
    set_frame_structure_1116_0ms(get_cell_dist(cells_used_in_TC[0]), ds)
    set_frame_structure_1116_0ms(get_cell_dist(cells_used_in_TC[1]), ds)
    set_frame_structure_1208(get_cell_dist(cells_used_in_TC[2]), ds)
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-1'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'prachConfigurationIndex', '97')
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-2'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'prachConfigurationIndex', '97')
    nrdu_dist_name = 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRDU-1'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id)
    ds.add_param_to_delta(nrdu_dist_name, 'carrierAggregationSupportList',
                          ['ca_Fr1Tdd_Sa', 'ca_Fr1Tdd_Fdd_Sa', 'ca_Fr1Tdd_Any_Sa'])
    ds.validate_scf()
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta)
    verify_on_air()
    blog("Preconditions fulfilled")


@logged_keyword
def remove_preconditions_b13(cells_used_in_TC):
    ds = DeltaStore()
    ds.initialise_delta_store()
    unblock_handover_to_cell(ds, [cells_used_in_TC[0], cells_used_in_TC[1]], cells_used_in_TC[2])
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta)
    verify_on_air()
    blog("Preconditions removed")


@logged_keyword
def check_preconditions_d_1(cells_used_in_TC):
    backup_current_scf()
    # cells_used_in_TC_without3 = [1, 2]
    ds = DeltaStore()
    ds.initialise_delta_store()
    ds.update_managed_object_and_parameter_to_delta(
        dist_name='MRBTS-{mrbts_id}/NRBTS-{nrbts_id}'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        sCellActivationMethod='blind')
    set_relations(ds, cells_used_in_TC, 'covBasedA1', 'dlOnly')
    # set_relations_without_scell_operational_mode(ds, cells_used_in_TC_without3, 'covBasedA1')
    set_deactivation_timer(ds, 'infinity')
    set_frame_structure_1116_0ms(get_cell_dist(cells_used_in_TC[0]), ds)
    set_frame_structure_1116_0ms(get_cell_dist(cells_used_in_TC[1]), ds)
    set_frame_structure_1208(get_cell_dist(cells_used_in_TC[2]), ds)
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-1'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'prachConfigurationIndex', '97')
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-2'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'prachConfigurationIndex', '97')
    nrdu_dist_name = 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRDU-1'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id)
    ds.add_param_to_delta(nrdu_dist_name, 'carrierAggregationSupportList',
                          ['ca_Fr1Tdd_Sa', 'ca_Fr1Tdd_Fdd_Sa', 'ca_Fr1Tdd_Any_Sa'])
    ds.validate_scf()
    for cell in cells_used_in_TC:
        ds.add_param_to_delta(get_cell_dist(cell), 'dlMimoMode', '8x4 Closed Loop Spatial Multiplexing')
        ds.add_complex_item_to_delta(get_cell_dist(cell), list_name='periodicCsiAcquisition',
                                     scramblingIdStep='3',
                                     csiReportPeriodicity='slots320',
                                     csirsNumberWithinReportPeriod_Set1=4,
                                     csirsPower=15,
                                     maxCsirsNumber=4)
    ds.validate_scf()
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta)
    verify_on_air()
    blog("Preconditions fulfilled")


@logged_keyword
def check_preconditions_d_2(cells_used_in_TC):
    bts_sw_release = int(get_sw_release_name()[4:8].replace('R', ''))
    CONDITIONAL_RELEASE = int('SBTS25R1'[4:].replace('R', ''))
    # actcdrxvonr parameter is frozen since 25R1, must be true
    backup_current_scf()
    # cells_used_in_TC_without3 = [1, 2, 4, 0]
    ds = DeltaStore()
    ds.initialise_delta_store()
    ds.update_managed_object_and_parameter_to_delta(
        dist_name='MRBTS-{mrbts_id}/NRBTS-{nrbts_id}'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        sCellActivationMethod='bufferBased')
    if CONDITIONAL_RELEASE < bts_sw_release:
        ds.update_managed_object_and_parameter_to_delta(
            dist_name='MRBTS-{mrbts_id}/NRBTS-{nrbts_id}'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
            actFlexSCellSelectFr1='true')
    set_relations(ds, cells_used_in_TC, 'covBasedA1', 'dlOnly')
    # set_relations_without_scell_operational_mode(ds, cells_used_in_TC_without3, 'covBasedA1')
    bts_id = 51701
    nrbts_object = f'MRBTS-{bts_id}/NRBTS-{bts_id}'
    set_deactivation_timer(ds, 'infinity')
    source_cell = cells_used_in_TC[0:2]
    target_cell = cells_used_in_TC[2]
    for cell in source_cell:
        ds.add_param_to_delta(get_cell_dist(cell), 'actCDrxVoNR', 'true')
        ds.add_param_to_delta(get_cell_dist(cell), 'actCDrx', 'true')
    if CONDITIONAL_RELEASE < bts_sw_release:
        ds.add_param_to_delta(get_cell_dist(target_cell), 'actCDrxVoNR', 'true')
    else:
        ds.add_param_to_delta(get_cell_dist(target_cell), 'actCDrxVoNR', 'false')
    ds.add_param_to_delta(get_cell_dist(target_cell), 'actCDrx', 'false')
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-1'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'prachConfigurationIndex', '97')
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-2'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'prachConfigurationIndex', '97')
    set_frame_structure_1116_0ms(get_cell_dist(cells_used_in_TC[0]), ds)
    set_frame_structure_1116_0ms(get_cell_dist(cells_used_in_TC[1]), ds)
    set_frame_structure_1208(get_cell_dist(cells_used_in_TC[2]), ds)
    nrdu_dist_name = 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRDU-1'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id)
    ds.add_param_to_delta(nrdu_dist_name, 'carrierAggregationSupportList',
                          ['ca_Fr1Tdd_Sa', 'ca_Fr1Tdd_Fdd_Sa', 'ca_Fr1Tdd_Any_Sa'])
    ds.add_param_to_delta(nrbts_object + '/NRCELL-5',
                          'qRxLevMin', '-22')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-6',
                          'qRxLevMin', '-22')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                          'qRxLevMin', '-22')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-3',
                          'qRxLevMin', '-60')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-4',
                          'qRxLevMin', '-22')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-7',
                          'qRxLevMin', '-22')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-0',
                          'qRxLevMin', '-22')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-1/NRREL-3',
                          'handoverAllowedSA', 'allowed')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-1',
                          'a2MeashoEnabledSA', 'rsrp')
    ds.validate_scf()
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta)
    verify_on_air()
    blog("Preconditions fulfilled")


@logged_keyword
def check_preconditions_e_1(cells_used_in_TC):
    backup_current_scf()
    # cells_used_in_TC_without3 = [1, 2]
    ds = DeltaStore()
    ds.initialise_delta_store()
    ds.update_managed_object_and_parameter_to_delta(
        dist_name='MRBTS-{mrbts_id}/NRBTS-{nrbts_id}'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        sCellActivationMethod='bufferBased')
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-1'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'prachConfigurationIndex', '97')
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-2'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'prachConfigurationIndex', '97')
    set_relations(ds, cells_used_in_TC, 'covBasedA1', 'dlOnly')
    # set_relations_without_scell_operational_mode(ds, cells_used_in_TC_without3, 'covBasedA1')
    set_deactivation_timer(ds, 'infinity')
    ds.add_param_to_delta(get_cell_dist(cells_used_in_TC[0]), 'actPerCsiReportBundlingTddFr1', 'true')
    set_frame_structure_1116_0ms(get_cell_dist(cells_used_in_TC[0]), ds)
    set_frame_structure_1116_0ms(get_cell_dist(cells_used_in_TC[1]), ds)
    set_frame_structure_1208(get_cell_dist(cells_used_in_TC[2]), ds)
    nrdu_dist_name = 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRDU-1'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id)
    ds.add_param_to_delta(nrdu_dist_name, 'carrierAggregationSupportList',
                          ['ca_Fr1Tdd_Sa', 'ca_Fr1Tdd_Fdd_Sa', 'ca_Fr1Tdd_Any_Sa'])
    ds.validate_scf()
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta)
    verify_on_air()
    blog("Preconditions fulfilled")


@logged_keyword
def verify_tput_on_cells(l1l2_logs, btslog_dir, handover_to_CA=True):
    pcell, scells = find_attached_cc_cells_identities(btslog_dir, handover_to_CA=handover_to_CA)
    lh = LogHelper()
    blog("Opening Wireshark")
    finder = lh.add_pcap(pcap_file_path=l1l2_logs, tshark_filter='dldata_pdschsendreq or uldata_puschreceivereq')
    verify_tput_scheduled_on_specific_cell(finder, pcell, 'dl')
    verify_tput_scheduled_on_specific_cell(finder, pcell, 'ul')
    for cell in scells:
        verify_tput_scheduled_on_specific_cell(finder, cell, 'dl')
        verify_tput_not_scheduled_on_specific_cell(finder, cell, 'ul')
    blog('Throughput confirmed')


@logged_keyword
def check_scelladdition(btslog_dir):
    find_scelladdition_prints(btslog_dir)
    blog('sCellAddition confirmed')


@logged_keyword
def check_carrier_aggregation_activation(btslog_dir):
    find_scellactivation_prints(btslog_dir, "START")
    blog('sCellActivation confirmed')


@logged_keyword
def check_carrier_aggregation_deactivation(btslog_dir):
    find_scellactivation_prints_deact(btslog_dir, "DEACTIVATE")
    blog('sCellDeactivation confirmed')


@logged_keyword
def verify_tput_scheduled_on_specific_cell(finder, cellidentity, direction='dl', minimal_mcs=4):
    api = AdminUtils()
    scf_file = api.download_current_scf()
    cell_phys_id = get_physicall_cell_id_from_mo_cell_id(int(cellidentity) - int(mrbts_id) * GLOBAL_GNB_ID_CONSTANT,
                                                         scf_file)
    blog("Veryfiing {direction} on cell {cell_phys_id}, {cellidentity}."
         .format(direction=direction.upper(), cell_phys_id=cell_phys_id, cellidentity=cellidentity))
    if direction == 'dl':
        matcher = Pm('dldata_pdschsendreq', message_type_pattern='empty'). \
            containing('*dmrsScramblingSequenceInt*', '*{}*'.format(cell_phys_id))
        blog("Searching for messages in pcap")
        all_msgs = finder.find_all_anew(matcher)
        for msg in all_msgs:
            if msg is not None:
                if find_mcs(msg) > minimal_mcs:
                    blog('Throughput on {direction} cell {cell} confirmed'.format(direction=direction.upper(),
                                                                                  cell=cellidentity))
                    return
        assert False, "Looped over and found no required MCS"
    elif direction == 'ul':
        matcher = Pm('uldata_puschreceivereq', message_type_pattern='empty'). \
            containing('*dmrsScramblingSequenceInt*', '*{}*'.format(cell_phys_id))
        blog("Searching for messages in pcap")
        all_msgs = finder.find_all_anew(matcher)
        for msg in all_msgs:
            if msg is not None:
                if find_mcs(msg) > minimal_mcs:
                    blog('Throughput on {direction} cell {cell} confirmed'.format(direction=direction.upper(),
                                                                                  cell=cellidentity))
                    return
        assert False, "Looped over and found no required MCS"
    else:
        raise Exception("Direction of throughput must be in format: 'dl' or 'ul'.")


@logged_keyword
def verify_tput_not_scheduled_on_specific_cell(finder, cellidentity, direction='dl'):
    api = AdminUtils()
    scf_file = api.download_current_scf()
    cell_phys_id = get_physicall_cell_id_from_mo_cell_id(int(cellidentity) - int(mrbts_id) * GLOBAL_GNB_ID_CONSTANT,
                                                         scf_file)
    blog("Veryfiing {direction} NOT on cell {cell_phys_id}, {cellidentity}."
         .format(direction=direction.upper(), cell_phys_id=cell_phys_id, cellidentity=cellidentity))
    if direction == 'dl':
        matcher = Pm('dldata_pdschsendreq', message_type_pattern='empty'). \
            containing('*dmrsScramblingSequenceInt*', '*{}*'.format(cell_phys_id))
        blog("Searching for messages in pcap")
        all_msgs = finder.find_all_anew(matcher)
        assert not all_msgs, "Found message suggesting throughput"
    elif direction == 'ul':
        matcher = Pm('uldata_puschreceivereq', message_type_pattern='empty'). \
            containing('*dmrsScramblingSequenceInt*', '*{}*'.format(cell_phys_id))
        blog("Searching for messages in pcap")
        all_msgs = finder.find_all_anew(matcher)
        assert not all_msgs, "Found message suggesting throughput"
    else:
        raise Exception("Direction of throughput must be in format: 'dl' or 'ul'.")
    blog('Throughput not being on {direction} cell {cell} confirmed'.format(direction=direction.upper(),
                                                                            cell=cellidentity))


def find_mcs(msg):
    return int(msg.find('*mcs*').first()['val'])


@logged_keyword
def get_physicall_cell_id_from_mo_cell_id(cell_object_id, scf_file=None):
    cell_dist = 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-{cell_id}/'.format(mrbts_id=mrbts_id,
                                                                             nrbts_id=nrbts_id,
                                                                             cell_id=str(cell_object_id))
    param_to_get = cell_dist + "physCellId"
    return int(sv.get_single_parameter_value_from_scf_file(param_to_get, scf_file=scf_file)[0])


@logged_keyword
def get_nrCellIdentity_from_mo_cell_id(cell_object_id):
    cell_dist = 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-{cell_id}/'.format(mrbts_id=mrbts_id,
                                                                             nrbts_id=nrbts_id,
                                                                             cell_id=str(cell_object_id))
    api = AdminUtils()
    scf_file = api.download_current_scf()
    lcr_id = str(sv.get_single_parameter_value_from_scf_file(cell_dist + "lcrId", scf_file=scf_file)).strip("'[]")
    return int(mrbts_id) * GLOBAL_GNB_ID_CONSTANT + int(lcr_id)


@logged_keyword
def find_scellactivation_prints(btslog_dir, state_to_find):
    pcell, scells = find_attached_cc_cells_identities(btslog_dir)
    list_of_prints = []
    for scell in scells:
        print_to_find = r'CaSCellActivatedCheck[\s\S]*Cell {scell}[\s\S]*isCellActivated true' \
            .format(pcell=pcell, scell=scell, modif_type=state_to_find)
        with LogHelper() as lh:
            syslog = lh.add_syslog(get_filepaths(btslog_dir, pattern='SYSLOG_*.LOG'))
            list_of_prints.append(syslog.find_all(Sm(print_to_find, regex_engine='re')))
        assert list_of_prints, "No sCellActivation {modif_type} prints were found for cell {scell}." \
            .format(modif_type=state_to_find, scell=scell)
    return list_of_prints


def find_scellactivation_prints_deact(btslog_dir, state_to_find):
    pcell, scells = find_attached_cc_cells_identities(btslog_dir)
    list_of_prints = []
    for scell in scells:
        print_to_find = r'RemoteDlSCellActivationManager[\s\S]*update DeactResp[\s\S]*sCellId={scell}' \
            .format(pcell=pcell, scell=scell, modif_type=state_to_find)
        with LogHelper() as lh:
            syslog = lh.add_syslog(get_filepaths(btslog_dir, pattern='SYSLOG_*.LOG'))
            list_of_prints.append(syslog.find_all(Sm(print_to_find, regex_engine='re')))
        assert list_of_prints, "No sCellActivation {modif_type} prints were found for cell {scell}." \
            .format(modif_type=state_to_find, scell=scell)
    return list_of_prints


@logged_keyword
def find_scellactivation_prints_from_specific_cell(btslog_dir, state_to_find, scell):
    pcell, scells = find_attached_cc_cells_identities(btslog_dir)
    print_to_find = r'CaSCellActivatedCheck[\s\S]*Cell {scell}[\s\S]*isCellActivated true' \
        .format(pcell=pcell, scell=scell, modif_type=state_to_find)
    with LogHelper() as lh:
        syslog = lh.add_syslog(get_filepaths(btslog_dir, pattern='SYSLOG_*.LOG'))
        list_of_prints = syslog.find_all(Sm(print_to_find, regex_engine='re'))
        assert list_of_prints, "No sCellActivation {modif_type} prints were found for cell {scell}." \
            .format(modif_type=state_to_find, scell=scell)
    return list_of_prints[0]


def find_scellactivation_prints_deact_rlq(btslog_dir, state_to_find, scell):
    pcell, scells = find_attached_cc_cells_identities(btslog_dir)
    print_to_find = r'RemoteDlSCellActivationManager[\s\S]*update DeactResp[\s\S]*sCellId={scell}' \
        .format(pcell=pcell, scell=scell, modif_type=state_to_find)
    with LogHelper() as lh:
        syslog = lh.add_syslog(get_filepaths(btslog_dir, pattern='SYSLOG_*.LOG'))
        list_of_prints = syslog.find_all(Sm(print_to_find, regex_engine='re'))
        assert list_of_prints, "No sCellActivation {modif_type} prints were found for cell {scell}." \
            .format(modif_type=state_to_find, scell=scell)
    return list_of_prints[0]


@logged_keyword
def find_dettach_prints(btslog_dir):
    print_to_find = r'UeResourceReleaseReq, procedure:modifyRelease'
    with LogHelper() as lh:
        syslog = lh.add_syslog(get_filepaths(btslog_dir, pattern='SYSLOG_*.LOG'))
        found_line = syslog.find_next_anew(Sm(print_to_find, regex_engine='re'))
    assert found_line, "No dettach prints were found."
    return found_line


@logged_keyword
def find_scelladdition_prints(btslog_dir):
    pcell, scells = find_attached_cc_cells_identities(btslog_dir)
    pcell_to_find = r'pCellNrCellIdentity: {pcell}'.format(pcell=pcell)
    list_of_prints_scell = []
    with LogHelper() as lh:
        syslog = lh.add_syslog(get_filepaths(btslog_dir, pattern='SYSLOG_*.LOG'))
        list_of_prints_pcell = syslog.find_all(Sm(pcell_to_find, regex_engine='re'))
        assert list_of_prints_pcell, "No SCELLADDITION prints were found with servingCell={}.".format(pcell)
        for scell in scells:
            scell_to_find = r'UE setup for: nrCellIdentity={scell}[\s\S]*ueAddCause=SCELLADDITION'.format(scell=scell)
            list_of_prints_scell.append(syslog.find_all(Sm(scell_to_find, regex_engine='re')))
            assert list_of_prints_scell, "No SCELLADDITION prints were found with scellID={}.".format(scell)
    return list_of_prints_pcell, list_of_prints_scell


@logged_keyword
def find_rlq_prints(btslog_dir):
    print_to_find = r'ScellChannelQualityEvaluator prepare sending SCellStatusInd with rlqStatus:BAD'
    with LogHelper() as lh:
        syslog = lh.add_syslog(get_filepaths(btslog_dir, pattern='SYSLOG_*.LOG'))
        list_of_syslog_prints = syslog.find_all(Sm(print_to_find, regex_engine='re'))
    assert list_of_syslog_prints, "No ChannelQualityEvaluator prints were found."
    return list_of_syslog_prints


@logged_keyword
def find_attached_cc_cells_identities(btslog_dir, handover_to_CA=True):
    print_to_find = r'NrRelPCellSetupResp on SCellNrCellIdentity:'
    with LogHelper() as lh:
        syslog = lh.add_syslog(get_filepaths(btslog_dir, pattern='SYSLOG_*.LOG'))
        list_of_prints = syslog.find_all(Sm(print_to_find, regex_engine='re'))
    assert list_of_prints, \
        "No ScellUeSchedulingReq found in syslog, please verify manually wether 3CC is working at all"
    scells_raw = []
    pcell = None
    for msg in list_of_prints:
        pcell = msg.split(":")[-1].split()[0]
        scells_raw.append(msg.split(":")[-2].split()[0])
    scells = []
    for cell in scells_raw:
        if cell not in scells:
            scells.append(cell)
    if handover_to_CA:
        return pcell, scells
    elif pcell in scells:
        scells.remove(pcell)
        return pcell, scells


@logged_keyword
def find_used_pcells(btslog_dir):
    print_to_find = r'EQ_L2_PS_DL_CA.*ScellStatusInd coming from peer SCell.*PCellNrCellIdentity:'  # 23R1, 23R2
    with LogHelper() as lh:
        syslog = lh.add_syslog(get_filepaths(btslog_dir, pattern='SYSLOG_*.LOG'))
        list_of_prints = syslog.find_all_anew(Sm(print_to_find, regex_engine='re'))
    assert list_of_prints, "nrCellIdentity from Handover msgs was not found in syslog."
    pcell_cells_list = []
    for msg in list_of_prints:
        pcell_cells_list.append(msg.split(':')[-1])
    assert len(list(set(pcell_cells_list))) == 2, "Did not find expected number of used primary cells during TC"
    return list(set(pcell_cells_list))


@logged_keyword
def extract_timestamp_from_syslog_line(syslog_line):
    today = datetime.now()
    split_line = syslog_line.split()
    log_time = datetime.strptime(split_line[1] + ' ' + split_line[2], '%d.%m %H:%M:%S.%f') + timedelta(hours=1)
    return log_time.replace(year=today.year)


@logged_keyword
def verify_deactivation_via_rlq(btslog_dir, wait_time_between_deact_and_dettach_inseconds):
    find_rlq_prints(btslog_dir)
    pcell, scells = find_attached_cc_cells_identities(btslog_dir)
    # first scell attached is last to dettach, therefore scells[1] is deactivated first - via rlq
    try:
        prints_deact = find_scellactivation_prints_deact_rlq(btslog_dir, "DEACTIVATE", scells[1])
    except Exception:
        prints_deact = find_scellactivation_prints_deact_rlq(btslog_dir, "DEACTIVATE", scells[0])
    prints_dettach = find_dettach_prints(btslog_dir)
    timestamp_deact_scell = extract_timestamp_from_syslog_line(prints_deact)
    timestamp_dettach = extract_timestamp_from_syslog_line(prints_dettach)
    time_difference = (timestamp_dettach - timestamp_deact_scell).total_seconds()
    #  wait_time_between_deact_and_dettach_inseconds minus 10s because of occasional slack of syslog
    assert time_difference > int(wait_time_between_deact_and_dettach_inseconds) - 10, \
        "Deactivation happened too soon relative to dettach, " \
        "time difference was: {real_time} and should be {expected}".format(
            real_time=time_difference,
            expected=wait_time_between_deact_and_dettach_inseconds)
    blog("Deactivation via RLQ confirmed")


@logged_keyword
def get_smod_time():
    smod_master_alias = connect_to_smod()
    timestamp = str(_ssh.execute(command='date +"%Y-%m-%d %T"', connection=smod_master_alias).strip())
    timestamp = datetime.strptime(timestamp, '%Y-%m-%d %H:%M:%S')
    return timestamp


@logged_keyword
def check_ho_related_msg_in_bts_log(btslog_dir):
    pattern = r'ConcreteIntraGnbIntraDuHandoverProcedure[\s\S]*endProcedure[\s\S]*status Completed'

    cmd = f"grep -r -P '{pattern}' {btslog_dir}"

    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)

    if result.returncode == 0 and result.stdout:
        msg = result.stdout
        blog(f"HANDOVER COMPLETION MSG: {msg}")
    else:
        raise AssertionError(
            'ConcreteIntraGnbIntraDuHandoverProcedure endProcedure status Completed not found'
        )

    blog(f"Handover confirmed")


@logged_keyword
def check_scell_change_msg_in_bts_log(btslog_dir, secondary_cells_used_in_TC):
    scells_identity_to_check = []
    for cell in secondary_cells_used_in_TC:
        scells_identity_to_check.append(get_nrCellIdentity_from_mo_cell_id(cell))
    pcell, scells = find_attached_cc_cells_identities(btslog_dir)
    for scell in scells_identity_to_check:
        assert str(scell) in scells, "Did not find {scell} in list of additioned to 3CC during this TC run".format(
            scell=scell)
    blog("Scell change confirmed")


@logged_keyword
def check_scell_release(btslog_dir, wait_time_after_attach, waited_after_attach_timestamp):
    addition_timestamp_pcell, addition_timestamp_scells = find_scelladdition_prints(btslog_dir)
    addition_line = str(addition_timestamp_scells[0]).strip("[]")
    addition_timestamp = extract_timestamp_from_syslog_line(addition_line) + timedelta(
        seconds=int(wait_time_after_attach))
    assert addition_timestamp > waited_after_attach_timestamp, \
        "Addition should occur after wait time, not instantly after Attach!"
    blog('sCellAddition confirmed')


@logged_keyword
def check_scell_activation(btslog_dir, waited_after_attach_timestamp):
    pcell, scells = find_attached_cc_cells_identities(btslog_dir)
    activation_line = find_scellactivation_prints_from_specific_cell(btslog_dir, "START", scells[0])
    activation_timestamp = extract_timestamp_from_syslog_line(activation_line)
    assert activation_timestamp > waited_after_attach_timestamp, \
        "Activation should occur after wait time, not instantly after Attach!"
    blog('sCellActivation confirmed')


@logged_keyword
def unlock_cell_after_test(cell_mo):
    with AdminApi() as web_api:
        web_api.unlock(get_cell_dist(cell_mo), timeout=60)


@logged_keyword
def lock_cell_before_test(cell_mo):
    with AdminApi() as web_api:
        web_api.lock(get_cell_dist(cell_mo), timeout=60)


@logged_keyword
def get_multiple_cells_dists(cells_used_in_TC):
    return [get_cell_dist(cell) for cell in cells_used_in_TC]
