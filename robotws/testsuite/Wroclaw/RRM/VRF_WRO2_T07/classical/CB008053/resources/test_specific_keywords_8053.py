from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.DeltaStore import DeltaStore
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.uuf.checkpoints import verify_on_air
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.common.file_helper import get_filepaths
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.matchers import SyslogMessageMatcher as Sm
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.log_helper import LogHelper
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.pm_counters as pm
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.classical.feature_5GC007949.resources.test_specific_keywords as kw_from_7949
import time

mrbts_id = tl.gnbs[0].global_bts_id
nrbts_id = tl.gnbs[0].instance_id


@logged_keyword
def get_nrhoif_dist_name(cell_id, nrhoif_id):
    return 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-{cell_id}/NRHOIF-{nrhoif_id}'.format(
        mrbts_id=mrbts_id,
        nrbts_id=nrbts_id,
        cell_id=cell_id,
        nrhoif_id=nrhoif_id)


@logged_keyword
def set_preconditions_4CC_02(cells_used_in_TC):
    kw_from_7949.backup_current_scf()
    ds = DeltaStore()
    ds.initialise_delta_store()
    kw_from_7949.block_handover_to_cell(ds, [cells_used_in_TC[2]], cells_used_in_TC[1])
    kw_from_7949.block_handover_to_cell(ds, [cells_used_in_TC[1]], cells_used_in_TC[2])
    kw_from_7949.block_handover_to_cell(ds, [cells_used_in_TC[1]], cells_used_in_TC[3])
    kw_from_7949.unblock_handover_to_cell(ds, [cells_used_in_TC[1], cells_used_in_TC[2]], cells_used_in_TC[0])
    ds.add_param_to_delta(kw_from_7949.get_relation_dist_name(cells_used_in_TC[0], cells_used_in_TC[1]),
                          'sCellAdditionMethod', 'covBasedA1')
    ds.add_param_to_delta(kw_from_7949.get_relation_dist_name(cells_used_in_TC[0], cells_used_in_TC[2]),
                          'sCellAdditionMethod', 'covBasedA1')
    ds.add_param_to_delta(kw_from_7949.get_relation_dist_name(cells_used_in_TC[0], cells_used_in_TC[3]),
                          'sCellAdditionMethod', 'covBasedA1')
    ds.add_param_to_delta(kw_from_7949.get_relation_dist_name(cells_used_in_TC[0], cells_used_in_TC[3]),
                          'sCellOperationalMode', 'dlOnly')
    ds.add_param_to_delta(kw_from_7949.get_relation_dist_name(cells_used_in_TC[1], cells_used_in_TC[0]),
                          'sCellAdditionMethod', 'covBasedA1')
    ds.add_param_to_delta(kw_from_7949.get_relation_dist_name(cells_used_in_TC[1], cells_used_in_TC[2]),
                          'sCellAdditionMethod', 'covBasedA1')
    ds.add_param_to_delta(kw_from_7949.get_relation_dist_name(cells_used_in_TC[1], cells_used_in_TC[3]),
                          'sCellAdditionMethod', 'covBasedA1')
    ds.add_param_to_delta(kw_from_7949.get_relation_dist_name(cells_used_in_TC[1], cells_used_in_TC[3]),
                          'sCellOperationalMode', 'dlOnly')
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'sCellActivationMethod', 'bufferBased')
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'maxNumScellsUl', '2')
    ds.add_param_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[0]), 'sCellDeactivationTimerGNB', 'infinity')
    ds.add_param_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[0]), 'a1MeasSCellAddEnabled', 'rsrp')
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'actBcsCheck', 'enabled_FR1')
    kw_from_7949.set_frame_structure_1116_0ms(kw_from_7949.get_cell_dist(cells_used_in_TC[0]), ds)
    ds.add_param_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[0]), 'prachConfigurationIndex', '97')
    ds.add_complex_item_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[0]), 'a1MeasSCellAddSsbRsrp',
                                 a1HysteresisSCellAddSsbRsrp=0, a1ThresholdSCellAddSsbRsrpFDD=70,
                                 a1ThresholdSCellAddSsbRsrpTDD=58, a1TimeToTriggerSCellAddSsbRsrp='480ms')
    ds.add_param_to_delta(get_nrhoif_dist_name(cells_used_in_TC[0], '1'), 'ssBurstSetPeriod', '20')
    ds.add_param_to_delta(get_nrhoif_dist_name(cells_used_in_TC[0], '7'), 'ssBurstSetPeriod', '20')
    kw_from_7949.set_frame_structure_1116_0ms(kw_from_7949.get_cell_dist(cells_used_in_TC[1]), ds)
    ds.add_param_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[1]), 'prachConfigurationIndex', '97')
    ds.add_param_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[1]), 'qRxLevMin', '-40')
    ds.add_param_to_delta(get_nrhoif_dist_name(cells_used_in_TC[1], '1'), 'ssBurstSetPeriod', '20')
    ds.add_param_to_delta(get_nrhoif_dist_name(cells_used_in_TC[1], '7'), 'ssBurstSetPeriod', '20')
    kw_from_7949.set_frame_structure_1070(kw_from_7949.get_cell_dist(cells_used_in_TC[2]), ds)
    ds.add_param_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[2]), 'prachConfigurationIndex', '98')
    ds.add_param_to_delta(get_nrhoif_dist_name(cells_used_in_TC[2], '1'), 'ssBurstSetPeriod', '20')
    ds.add_param_to_delta(get_nrhoif_dist_name(cells_used_in_TC[2], '2'), 'ssBurstSetPeriod', '20')
    kw_from_7949.set_frame_structure_1070(kw_from_7949.get_cell_dist(cells_used_in_TC[4]), ds)
    nrdu_dist_name = 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRDU-1'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id)
    ds.add_param_to_delta(nrdu_dist_name, 'carrierAggregationSupportList',
                          ['ca_Fr1Tdd_Sa', 'ca_Fr1Tdd_Fdd_Sa', 'ca_Fr1Tdd_Any_Sa'])
    # start bts counters collecting
    # ${counter_dir}                 Collect Counters            log_name=TC_D2
    ds.validate_scf()
    delta_8053_02 = ds.collect_delta_store()
    blog('Delta store file (delta_8053_14): {}'.format(delta_8053_02))
    ds.perform_delta_recommissioning(delta_file=delta_8053_02)
    verify_on_air()
    blog("Preconditions fulfilled")


@logged_keyword
def enable_4cc_for_test_02(cells_used_in_TC):
    kw_from_7949.backup_current_scf()
    ds = DeltaStore()
    ds.initialise_delta_store()
    ds.add_param_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[0]), 'maxNumScellsDlFr1', '3')
    ds.add_param_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[1]), 'maxNumScellsDlFr1', '3')
    ds.validate_scf()
    delta_8053_02b = ds.collect_delta_store()
    blog('Delta store file (delta_8053_14): {}'.format(delta_8053_02b))
    ds.perform_delta_recommissioning(delta_file=delta_8053_02b)
    verify_on_air()
    blog("Preconditions fulfilled")


@logged_keyword
def set_preconditions_4CC_14(cells_used_in_TC):
    kw_from_7949.backup_current_scf()
    ds = DeltaStore()
    ds.initialise_delta_store()
    kw_from_7949.block_handover_to_cell(ds, [cells_used_in_TC[2]], cells_used_in_TC[1])
    kw_from_7949.block_handover_to_cell(ds, [cells_used_in_TC[1]], cells_used_in_TC[2])
    kw_from_7949.block_handover_to_cell(ds, [cells_used_in_TC[1]], cells_used_in_TC[3])
    kw_from_7949.unblock_handover_to_cell(ds, [cells_used_in_TC[1], cells_used_in_TC[2]], cells_used_in_TC[0])
    ds.add_param_to_delta(kw_from_7949.get_relation_dist_name(cells_used_in_TC[0], cells_used_in_TC[1]),
                          'sCellAdditionMethod', 'covBasedA1')
    ds.add_param_to_delta(kw_from_7949.get_relation_dist_name(cells_used_in_TC[0], cells_used_in_TC[2]),
                          'sCellAdditionMethod', 'covBasedA1')
    ds.add_param_to_delta(kw_from_7949.get_relation_dist_name(cells_used_in_TC[0], cells_used_in_TC[3]),
                          'sCellAdditionMethod', 'covBasedA1')
    ds.add_param_to_delta(kw_from_7949.get_relation_dist_name(cells_used_in_TC[0], cells_used_in_TC[3]),
                          'sCellOperationalMode', 'dlOnly')
    ds.add_param_to_delta(kw_from_7949.get_relation_dist_name(cells_used_in_TC[1], cells_used_in_TC[0]),
                          'sCellAdditionMethod', 'covBasedA1')
    ds.add_param_to_delta(kw_from_7949.get_relation_dist_name(cells_used_in_TC[1], cells_used_in_TC[2]),
                          'sCellAdditionMethod', 'covBasedA1')
    ds.add_param_to_delta(kw_from_7949.get_relation_dist_name(cells_used_in_TC[1], cells_used_in_TC[3]),
                          'sCellAdditionMethod', 'covBasedA1')
    ds.add_param_to_delta(kw_from_7949.get_relation_dist_name(cells_used_in_TC[1], cells_used_in_TC[3]),
                          'sCellOperationalMode', 'dlOnly')
    ds.add_param_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[0]), 'maxNumScellsDlFr1', '3')
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'sCellActivationMethod', 'bufferBased')
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'maxNumScellsUl', '2')
    ds.add_param_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[0]), 'sCellDeactivationTimerGNB', 'infinity')
    ds.add_param_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[0]), 'a1MeasSCellAddEnabled', 'rsrp')
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'actBcsCheck', 'enabled_FR1')
    kw_from_7949.set_frame_structure_1116_0ms(kw_from_7949.get_cell_dist(cells_used_in_TC[0]), ds)
    ds.add_param_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[0]), 'prachConfigurationIndex', '97')
    ds.add_complex_item_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[0]), 'a1MeasSCellAddSsbRsrp',
                                 a1HysteresisSCellAddSsbRsrp=0, a1ThresholdSCellAddSsbRsrpFDD=52,
                                 a1ThresholdSCellAddSsbRsrpTDD=50, a1TimeToTriggerSCellAddSsbRsrp='480ms')
    ds.add_param_to_delta(get_nrhoif_dist_name(cells_used_in_TC[0], '1'), 'ssBurstSetPeriod', '20')
    ds.add_param_to_delta(get_nrhoif_dist_name(cells_used_in_TC[0], '7'), 'ssBurstSetPeriod', '20')
    kw_from_7949.set_frame_structure_1116_0ms(kw_from_7949.get_cell_dist(cells_used_in_TC[1]), ds)
    ds.add_param_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[1]), 'prachConfigurationIndex', '97')
    ds.add_param_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[1]), 'qRxLevMin', '-30')
    ds.add_param_to_delta(get_nrhoif_dist_name(cells_used_in_TC[1], '1'), 'ssBurstSetPeriod', '20')
    ds.add_param_to_delta(get_nrhoif_dist_name(cells_used_in_TC[1], '7'), 'ssBurstSetPeriod', '20')
    kw_from_7949.set_frame_structure_1070(kw_from_7949.get_cell_dist(cells_used_in_TC[2]), ds)
    ds.add_param_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[2]), 'prachConfigurationIndex', '98')
    ds.add_param_to_delta(get_nrhoif_dist_name(cells_used_in_TC[2], '1'), 'ssBurstSetPeriod', '20')
    ds.add_param_to_delta(get_nrhoif_dist_name(cells_used_in_TC[2], '2'), 'ssBurstSetPeriod', '20')
    kw_from_7949.set_frame_structure_1070(kw_from_7949.get_cell_dist(cells_used_in_TC[4]), ds)
    nrdu_dist_name = 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRDU-1'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id)
    ds.add_param_to_delta(nrdu_dist_name, 'carrierAggregationSupportList',
                          ['ca_Fr1Tdd_Sa', 'ca_Fr1Tdd_Fdd_Sa', 'ca_Fr1Tdd_Any_Sa'])
    ds.validate_scf()
    delta_8053_14 = ds.collect_delta_store()
    blog('Delta store file (delta_8053_14): {}'.format(delta_8053_14))
    ds.perform_delta_recommissioning(delta_file=delta_8053_14)
    verify_on_air()
    blog("Preconditions fulfilled")


@logged_keyword
def check_3cc_in_syslog(btslog_dir):
    regular_expression_for_3cc = r'^[\s\S]*\[PCellId: (847069185|847069186)\][\s\S]*' \
                                 r'Finished with status Status:ok and selected SCells: ' \
                                 r'\[(847069185|847069186|847069187|847069189), ' \
                                 r'(847069185|847069186|847069187|847069189)\][\s\S]*$'
    with LogHelper() as lh:
        syslog = lh.add_syslog(get_filepaths(btslog_dir, pattern='SYSLOG_*.LOG'))
        blog('checking regular_expression: ' + str(regular_expression_for_3cc))
        msg_1 = syslog.find_next(Sm(regular_expression_for_3cc, regex_engine='re'))
        assert msg_1 is not None, 'No sign of 3cc in syslog: {}.'.format(str(btslog_dir))
        blog('FOUND: ' + str(msg_1))
        blog('Syslog from {} analysed successfully.'.format(str(btslog_dir)))


@logged_keyword
def check_4cc_in_syslog_TC02(btslog_dir):
    regular_expression_for_4cc = r'^[\s\S]*\[PCellId: (847069185|847069186)\][\s\S]*' \
                                 r'Finished with status Status:ok and selected SCells: ' \
                                 r'\[(847069185|847069186|847069187|847069189), ' \
                                 r'(847069185|847069186|847069187|847069189), ' \
                                 r'(847069185|847069186|847069187|847069189)' \
                                 r'\][\s\S]*$'
    with LogHelper() as lh:
        syslog = lh.add_syslog(get_filepaths(btslog_dir, pattern='SYSLOG_*.LOG'))
        blog('checking regular_expression: ' + str(regular_expression_for_4cc))
        msg_1 = syslog.find_next(Sm(regular_expression_for_4cc, regex_engine='re'))
        assert msg_1 is not None, 'No sign of 4cc in syslog: {}.'.format(str(btslog_dir))
        blog('FOUND: ' + str(msg_1))
        blog('Syslog from {} analysed successfully.'.format(str(btslog_dir)))


@logged_keyword
def check_4cc_in_syslog(btslog_dir):
    regex_4cc = r'^[\s\S]*\[PCellId: 847069185\][\s\S]*' \
                                 r'Finished with status Status:ok and selected SCells: ' \
                                 r'\[(847069186|847069187|847069189), ' \
                                 r'(847069186|847069187|847069189), ' \
                                 r'(847069186|847069187|847069189)' \
                                 r'\][\s\S]*$'
    regex_pcell_1 = r'^[\s\S]*UE setup[\s\S]*847069185[\s\S]*INITIALACCESS[\s\S]*$'
    regex_scell_2 = r'^[\s\S]*UE setup[\s\S]*847069186[\s\S]*SCELLADDITION[\s\S]*$'
    regex_scell_3 = r'^[\s\S]*UE setup[\s\S]*847069187[\s\S]*SCELLADDITION[\s\S]*$'
    regex_scell_5 = r'^[\s\S]*UE setup[\s\S]*847069189[\s\S]*SCELLADDITION[\s\S]*$'

    with LogHelper() as lh:
        syslog = lh.add_syslog(get_filepaths(btslog_dir, pattern='SYSLOG_*.LOG'))

        blog('checking regular_expression: ' + str(regex_4cc))
        msg_1 = syslog.find_next(Sm(regex_4cc, regex_engine='re'))
        assert msg_1 is not None, 'No sign of 4cc in syslog: {}.'.format(str(btslog_dir))
        blog('FOUND: ' + str(msg_1))
        blog('Syslog from {} analysed successfully.'.format(str(btslog_dir)))

        # blog('checking regular_expression: ' + str(regex_pcell_1))
        # msg_2 = syslog.find_next_anew(Sm(regex_pcell_1, regex_engine='re'))
        # assert msg_2 is not None, 'No sign of Pcell 847069185 INITIALACCESS in syslog: {}.'.format(str(btslog_dir))
        # blog('FOUND: ' + str(msg_2))
        # blog('Syslog from {} analysed successfully (Pcell 847069185 INITIALACCESS).'.format(str(btslog_dir)))
        # blog('------------------------------------')

        blog('checking regular_expression: ' + str(regex_scell_2))
        msg_3 = syslog.find_next_anew(Sm(regex_scell_2, regex_engine='re'))
        assert msg_3 is not None, 'No sign of Scell 847069186 SCELLADDITION in syslog: {}.'.format(str(btslog_dir))
        blog('FOUND: ' + str(msg_3))
        blog('Syslog from {} analysed successfully (Scell 847069186 SCELLADDITION).'.format(str(btslog_dir)))
        blog('------------------------------------')

        blog('checking regular_expression: ' + str(regex_scell_3))
        msg_4 = syslog.find_next_anew(Sm(regex_scell_3, regex_engine='re'))
        assert msg_4 is not None, 'No sign of Scell 847069187 SCELLADDITION in syslog: {}.'.format(str(btslog_dir))
        blog('FOUND: ' + str(msg_4))
        blog('Syslog from {} analysed successfully (Scell 847069187 SCELLADDITION).'.format(str(btslog_dir)))
        blog('------------------------------------')

        blog('checking regular_expression: ' + str(regex_scell_5))
        msg_5 = syslog.find_next_anew(Sm(regex_scell_5, regex_engine='re'))
        assert msg_5 is not None, 'No sign of Scell 847069189 SCELLADDITION in syslog: {}.'.format(str(btslog_dir))
        blog('FOUND: ' + str(msg_5))
        blog('Syslog from {} analysed successfully (Scell 847069189 SCELLADDITION).'.format(str(btslog_dir)))
        blog('------------------------------------')


@logged_keyword
def check_3cc_4cc_counters():
    pm_counters_path = pm.collect_counters()
    checking_result = True
    checking_result_1 = 1
    checking_result_2 = 1
    checking_result_3 = 1
    checking_result_4 = 1
    checking_result_5 = 1
    checking_result_6 = 1

    try:
        pm.check_counter_equals_x(pm_counters_path, 'M55138C02501', ['1', '2'], 1)
    except AssertionError:
        blog("M55138C02501 has wrong value")
        checking_result_1 = 0
        checking_result = False
    try:
        pm.check_counter_equals_x(pm_counters_path, 'M55138C02502', ['1', '2'], 1)
    except AssertionError:
        blog("M55138C02502 has wrong value")
        checking_result_2 = 0
        checking_result = False
    try:
        pm.check_counter_equals_x(pm_counters_path, 'M55139C01501', ['1', '2'], 1)
    except AssertionError:
        blog("M55139C01501 has wrong value")
        checking_result_3 = 0
        checking_result = False
    try:
        pm.check_counter_equals_x(pm_counters_path, 'M55139C01502', ['1', '2'], 1)
    except AssertionError:
        blog("M55139C01502 has wrong value")
        checking_result_4 = 0
        checking_result = False

    if checking_result is False:
        blog('- - - - - - - waiting for another counter period - - - - - - - ')
        time.sleep(300)
        pm_counters_path = pm.collect_counters()
        checking_result = True

        if checking_result_1 == 0:
            checking_result_1 = 1
            checking_result = True
            try:
                pm.check_counter_equals_x(pm_counters_path, 'M55138C02501', ['1', '2'], 1)
            except AssertionError:
                blog("M55138C02501 has wrong value")
                checking_result_1 = 0
                checking_result = False
        if checking_result_2 == 0:
            checking_result_2 = 1
            checking_result = True
            try:
                pm.check_counter_equals_x(pm_counters_path, 'M55138C02502', ['1', '2'], 1)
            except AssertionError:
                blog("M55138C02502 has wrong value")
                checking_result_2 = 0
                checking_result = False
        if checking_result_3 == 0:
            checking_result_3 = 1
            checking_result = True
            try:
                pm.check_counter_equals_x(pm_counters_path, 'M55139C01501', ['1', '2'], 1)
            except AssertionError:
                blog("M55139C01501 has wrong value")
                checking_result_3 = 0
                checking_result = False
        if checking_result_4 == 0:
            checking_result_4 = 1
            checking_result = True
            try:
                pm.check_counter_equals_x(pm_counters_path, 'M55139C01502', ['1', '2'], 1)
            except AssertionError:
                blog("M55139C01502 has wrong value")
                checking_result_4 = 0
                checking_result = False

    return checking_result


@logged_keyword
def disable_4CC_in_DL(cells_used_in_TC):
    kw_from_7949.backup_current_scf()
    ds = DeltaStore()
    ds.initialise_delta_store()
    ds.add_param_to_delta_to_delete_it(kw_from_7949.get_cell_dist(cells_used_in_TC[0]), 'maxNumScellsDlFr1')
    ds.validate_scf()
    delta_8053_03 = ds.collect_delta_store()
    blog('Delta store file (delta): {}'.format(delta_8053_03))
    ds.perform_delta_recommissioning(delta_file=delta_8053_03)
    # verify_on_air()
    blog("sleep 1,5m")
    time.sleep(90)
    blog("4CC disabled")


@logged_keyword
def get_nrrel_dist_name(cell_id, nrrel_id):
    return 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-{cell_id}/NRREL-{nrrel_id}'.format(
        mrbts_id=mrbts_id,
        nrbts_id=nrbts_id,
        cell_id=cell_id,
        nrrel_id=nrrel_id)


@logged_keyword
def disable_4CC_REL_remove(cells_used_in_TC):
    kw_from_7949.backup_current_scf()
    ds = DeltaStore()
    ds.initialise_delta_store()
    ds.delete_managed_object_from_delta(get_nrrel_dist_name(cells_used_in_TC[0], '3'))
    ds.validate_scf()
    delta_8053_03 = ds.collect_delta_store()
    blog('Delta store file (delta): {}'.format(delta_8053_03))
    ds.perform_delta_recommissioning(delta_file=delta_8053_03)
    # verify_on_air()
    blog("sleep 2m")
    time.sleep(120)
    blog("NRREL removed")


@logged_keyword
def set_preconditions_4CC_03(cells_used_in_TC):
    kw_from_7949.backup_current_scf()
    ds = DeltaStore()
    ds.initialise_delta_store()
    kw_from_7949.block_handover_to_cell(ds, [cells_used_in_TC[0]], cells_used_in_TC[2])
    kw_from_7949.block_handover_to_cell(ds, [cells_used_in_TC[0]], '2')
    kw_from_7949.block_handover_to_cell(ds, [cells_used_in_TC[0]], '7')
    ds.add_param_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[0]), 'a2MeashoEnabledSA', 'none')
    ds.update_managed_object_and_parameter_to_delta(
        'MRBTS-{}/NRBTS-{}/NRCELL-1/NRREL-2'.format(mrbts_id, nrbts_id), lcrId='4')
    kw_from_7949.block_handover_to_cell(ds, [cells_used_in_TC[0]], cells_used_in_TC[3])
    ds.add_param_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[2]), 'chBw', '40MHz')
    ds.add_param_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[4]), 'chBw', '40MHz')
    ds.add_param_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[2]), 'pMax', '400')
    ds.add_param_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[4]), 'pMax', '400')
    ds.add_param_to_delta(kw_from_7949.get_relation_dist_name(cells_used_in_TC[0], cells_used_in_TC[2]),
                          'sCellAdditionMethod', 'covBasedA1')
    ds.add_param_to_delta(kw_from_7949.get_relation_dist_name(cells_used_in_TC[0], '2'),
                          'sCellAdditionMethod', 'covBasedA1')
    ds.add_param_to_delta(kw_from_7949.get_relation_dist_name(cells_used_in_TC[0], cells_used_in_TC[3]),
                          'sCellAdditionMethod', 'covBasedA1')
    ds.add_param_to_delta(kw_from_7949.get_relation_dist_name(cells_used_in_TC[0], cells_used_in_TC[3]),
                          'sCellOperationalMode', 'dlOnly')
    ds.add_param_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[0]), 'maxNumScellsDlFr1', '3')
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'sCellActivationMethod', 'bufferBased')
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'maxNumScellsUl', '2')
    ds.add_param_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[0]), 'sCellDeactivationTimerGNB', 'infinity')
    ds.add_param_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[0]), 'a1MeasSCellAddEnabled', 'rsrp')
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'actBcsCheck', 'enabled_FR1')
    ds.add_param_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[2]), 'a2MeasSCellRelEnabled', 'rsrp')
    ds.add_complex_item_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[2]), 'a2MeasSCellRelSsbRsrp',
                                 a2HysteresisSCellRelSsbRsrp=0, a2ThresholdSCellRelSsbRsrp=35,
                                 a2TimeToTriggerSCellRelSsbRsrp='480ms')
    ds.add_param_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[4]), 'a2MeasSCellRelEnabled', 'rsrp')
    ds.add_complex_item_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[4]), 'a2MeasSCellRelSsbRsrp',
                                 a2HysteresisSCellRelSsbRsrp=0, a2ThresholdSCellRelSsbRsrp=35,
                                 a2TimeToTriggerSCellRelSsbRsrp='480ms')
    ds.add_param_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[3]), 'a2MeasSCellRelEnabled', 'rsrp')
    ds.add_complex_item_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[3]), 'a2MeasSCellRelSsbRsrp',
                                 a2HysteresisSCellRelSsbRsrp=0, a2ThresholdSCellRelSsbRsrp=40,
                                 a2TimeToTriggerSCellRelSsbRsrp='480ms')
    ds.add_complex_item_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[0]), 'a1MeasSCellAddSsbRsrp',
                                 a1HysteresisSCellAddSsbRsrp=0, a1ThresholdSCellAddSsbRsrpFDD=65,
                                 a1ThresholdSCellAddSsbRsrpTDD=65, a1TimeToTriggerSCellAddSsbRsrp='480ms')
    ds.add_param_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[3]), 'weightForSCellSelection', '100')
    ds.add_param_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[4]), 'weightForSCellSelection', '4')
    ds.add_param_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[2]), 'weightForSCellSelection', '3')
    ds.add_param_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[1]), 'weightForSCellSelection', '1')
    ds.add_param_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[0]), 'weightForSCellSelection', '1')
    ds.add_param_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[2]), 'qRxLevMin', '-40')
    ds.add_param_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[4]), 'qRxLevMin', '-40')
    kw_from_7949.set_frame_structure_1070(kw_from_7949.get_cell_dist(cells_used_in_TC[0]), ds)
    ds.add_param_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[0]), 'prachConfigurationIndex', '98')
    kw_from_7949.set_frame_structure_1070(kw_from_7949.get_cell_dist(cells_used_in_TC[1]), ds)
    ds.add_param_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[1]), 'prachConfigurationIndex', '98')
    kw_from_7949.set_frame_structure_1208(kw_from_7949.get_cell_dist(cells_used_in_TC[2]), ds)
    ds.add_param_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[2]), 'prachConfigurationIndex', '98')
    kw_from_7949.set_frame_structure_1208(kw_from_7949.get_cell_dist(cells_used_in_TC[4]), ds)
    ds.add_param_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[2]), 'prachConfigurationIndex', '98')
    nrdu_dist_name = 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRDU-1'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id)
    ds.add_param_to_delta(nrdu_dist_name, 'carrierAggregationSupportList',
                          ['ca_Fr1Tdd_Sa', 'ca_Fr1Tdd_Fdd_Sa', 'ca_Fr1Tdd_Any_Sa'])
    ds.validate_scf()
    delta_8053_03 = ds.collect_delta_store()
    blog('Delta store file (delta_8053_03): {}'.format(delta_8053_03))
    ds.perform_delta_recommissioning(delta_file=delta_8053_03)
    verify_on_air()
    blog("Preconditions fulfilled")


@logged_keyword
def enable_4CC_in_DL(cells_used_in_TC):
    kw_from_7949.backup_current_scf()
    ds = DeltaStore()
    ds.initialise_delta_store()
    ds.add_param_to_delta(kw_from_7949.get_cell_dist(cells_used_in_TC[0]), 'maxNumScellsDlFr1', '3')
    ds.validate_scf()
    delta_8053_03 = ds.collect_delta_store()
    blog('Delta store file (delta): {}'.format(delta_8053_03))
    ds.perform_delta_recommissioning(delta_file=delta_8053_03)
    blog("sleep 1m")
    time.sleep(60)
    blog("max DL CA set to 4")


@logged_keyword
def check_3cc_in_syslog_TC03(btslog_dir):
    regular_expression_for_3cc = r'^[\s\S]*\[PCellId: (847069185)\][\s\S]*' \
                                 r'Finished with status Status:ok and selected SCells: ' \
                                 r'\[(847069187|847069188|847069189), ' \
                                 r'(847069187|847069188|847069189)\][\s\S]*$'
    with LogHelper() as lh:
        syslog = lh.add_syslog(get_filepaths(btslog_dir, pattern='SYSLOG_*.LOG'))
        blog('checking regular_expression: ' + str(regular_expression_for_3cc))
        msg_1 = syslog.find_next(Sm(regular_expression_for_3cc, regex_engine='re'))
        assert msg_1 is not None, 'No sign of 3cc in syslog: {}.'.format(str(btslog_dir))
        blog('FOUND: ' + str(msg_1))
        blog('Syslog from {} analysed successfully.'.format(str(btslog_dir)))


@logged_keyword
def check_4cc_in_syslog_TC03(btslog_dir):
    regular_expression_for_4cc = r'^[\s\S]*\[PCellId: 847069185\][\s\S]*' \
                                 r'Finished with status Status:ok and selected SCells: ' \
                                 r'\[(847069187|847069188|847069189), ' \
                                 r'(847069187|847069188|847069189), ' \
                                 r'(847069187|847069188|847069189)' \
                                 r'\][\s\S]*$'
    regex_pcell_1 = r'^[\s\S]*UE setup[\s\S]*847069185[\s\S]*INITIALACCESS[\s\S]*$'
    regex_scell_4 = r'^[\s\S]*UE setup[\s\S]*847069188[\s\S]*SCELLADDITION[\s\S]*$'
    regex_scell_3 = r'^[\s\S]*UE setup[\s\S]*847069187[\s\S]*SCELLADDITION[\s\S]*$'
    regex_scell_5 = r'^[\s\S]*UE setup[\s\S]*847069189[\s\S]*SCELLADDITION[\s\S]*$'

    with LogHelper() as lh:
        syslog = lh.add_syslog(get_filepaths(btslog_dir, pattern='SYSLOG_*.LOG'))
        blog('checking regular_expression: ' + str(regular_expression_for_4cc))
        msg_1 = syslog.find_next(Sm(regular_expression_for_4cc, regex_engine='re'))
        assert msg_1 is not None, 'No sign of 4cc in syslog: {}.'.format(str(btslog_dir))
        blog('FOUND: ' + str(msg_1))
        blog('Syslog from {} analysed successfully.'.format(str(btslog_dir)))

        blog('checking regular_expression: ' + str(regex_pcell_1))
        msg_2 = syslog.find_next_anew(Sm(regex_pcell_1, regex_engine='re'))
        assert msg_2 is not None, 'No sign of Pcell 847069185 INITIALACCESS in syslog: {}.'.format(str(btslog_dir))
        blog('FOUND: ' + str(msg_2))
        blog('Syslog from {} analysed successfully (Pcell 847069185 INITIALACCESS).'.format(str(btslog_dir)))

        blog('checking regular_expression: ' + str(regex_scell_4))
        msg_3 = syslog.find_next_anew(Sm(regex_scell_4, regex_engine='re'))
        assert msg_3 is not None, 'No sign of Scell 847069188 SCELLADDITION in syslog: {}.'.format(str(btslog_dir))
        blog('FOUND: ' + str(msg_3))
        blog('Syslog from {} analysed successfully (Scell 847069188 SCELLADDITION).'.format(str(btslog_dir)))

        blog('checking regular_expression: ' + str(regex_scell_3))
        msg_4 = syslog.find_next_anew(Sm(regex_scell_3, regex_engine='re'))
        assert msg_4 is not None, 'No sign of Scell 847069187 SCELLADDITION in syslog: {}.'.format(str(btslog_dir))
        blog('FOUND: ' + str(msg_4))
        blog('Syslog from {} analysed successfully (Scell 847069187 SCELLADDITION).'.format(str(btslog_dir)))

        blog('checking regular_expression: ' + str(regex_scell_5))
        msg_5 = syslog.find_next_anew(Sm(regex_scell_5, regex_engine='re'))
        assert msg_5 is not None, 'No sign of Scell 847069189 SCELLADDITION in syslog: {}.'.format(str(btslog_dir))
        blog('FOUND: ' + str(msg_5))
        blog('Syslog from {} analysed successfully (Scell 847069189 SCELLADDITION).'.format(str(btslog_dir)))
