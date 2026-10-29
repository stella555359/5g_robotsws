import csv
import re

from testsuite.Wroclaw.RRM.VRF_WRO2_T07.classical.CB007564.resources.test_specific_keywords_7564 import atten, tcpdump
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.DeltaStore import DeltaStore
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.log_helper import log_finder
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.test.test_file_helper import os
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tti.tti_streaming import convert_tti_to_csv, \
    stop_generation_of_tti_trace_using_taf
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.robot_globals import robot_globals
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.rue.attach_utils import taf_ue
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation import get_sw_release_name
from testsuite.Wroclaw.RRM.resources.log.log import blog
# from taf.transport.ssh import ssh
from time import sleep
from robot.libraries.BuiltIn import BuiltIn
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.pm_counters as pmc
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.gnb_mirroring import L1L2

l1l2 = L1L2()
# mrbts_id = tl.gnbs[0].global_bts_id
mrbts_id = 55200  # for purpose of problem
nrbts_id = tl.gnbs[0].instance_id
CONDITIONAL_RELEASE_4 = int('SBTS25R1'[4:].replace('R', ''))
CONDITIONAL_RELEASE_5 = int('SBTS25R2'[4:].replace('R', ''))
CONDITIONAL_RELEASE_6 = int('SBTS26R1'[4:].replace('R', ''))


def preparing_for_counters_time_setting(bts_id=mrbts_id):
    ds = DeltaStore()
    ds.initialise_delta_store()
    nrbts_object = f'MRBTS-{bts_id}/NRBTS-{bts_id}'
    ds.add_param_to_delta(nrbts_object + '/NRPMRNL-1',
                          'miNrDlHarq', '5min')
    ds.add_param_to_delta(nrbts_object + '/NRPMRNL-1',
                          'miNrDlHarqLowSEMCS', '5min')
    ds.add_param_to_delta(nrbts_object + '/NRPMRNL-1',
                          'miNrDlSignalQuality', '5min')
    ds.add_param_to_delta(nrbts_object + '/NRPMRNL-1',
                          'miNrUlHarq', '5min')
    ds.add_param_to_delta(nrbts_object + '/NRPMRNL-1',
                          'miNrUlHarqOne', '5min')
    ds.add_param_to_delta(nrbts_object + '/NRPMRNL-1',
                          'miNrMacPduTput', '5min')
    ds.add_param_to_delta(nrbts_object + '/NRPMRNL-1',
                          'miNrUlHarqLowSEMCS', '5min')
    ds.add_param_to_delta(nrbts_object + '/NRPMRNL-1',
                          'miNrCellUtilization', '5min')
    ds.add_param_to_delta(nrbts_object + '/NRPMRNL-1',
                          'miNrPDCP1Report', '5min')
    ds.add_param_to_delta(nrbts_object + '/NRPMRNL-1',
                          'miNrPDCP2Report', '5min')
    ds.add_param_to_delta(nrbts_object + '/NRPMRNL-1',
                          'miNrMacSduReport', '5min')
    ds.add_param_to_delta(nrbts_object + '/NRPMRNL-1',
                          'miNrUlSignalQuality', '5min')
    ds.validate_scf(skip_parameter_relation_errors=False)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=False)
    blog("------------------Preconditions for cell counters done-------------------------")


def feature_actrat1_activation(bts_id=mrbts_id):
    ds = DeltaStore()
    ds.initialise_delta_store()
    nrbts_object = f'MRBTS-{bts_id}/NRBTS-{bts_id}'
    ds.add_param_to_delta(nrbts_object + '/NRCELL-1',
                          'percRedSEDlRat1VoNR', '0')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                          'percRedSEDlRat1VoNR', '0')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-1',
                          'actRat1Alloc', 'true')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                          'actRat1Alloc', 'true')
    ds.validate_scf(skip_parameter_relation_errors=False)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=False)
    blog("------------------Preconditions for cell interferences done-------------------------")


@logged_keyword
def attenuation_8409_A2(atten_value=90, cell_1_attenuator_ports=tl.gnbs[0].dus[0].rus[1].attenuation_ports,
                        cell_2_attenuator_ports=tl.gnbs[0].dus[0].rus[2].attenuation_ports):
    atten.initialise_attenuator()
    blog(cell_1_attenuator_ports, "ports cell 1")
    blog(cell_2_attenuator_ports, "ports cell 2")

    atten.set_attenuation(value_string='10', ports=cell_1_attenuator_ports)
    atten.set_attenuation(value_string=atten_value, ports=cell_2_attenuator_ports)


@logged_keyword
def attenuation_8409_A2_loop(atten_value=60, cell_1_attenuator_ports=tl.gnbs[0].dus[0].rus[1].attenuation_ports,
                             cell_2_attenuator_ports=tl.gnbs[0].dus[0].rus[2].attenuation_ports):
    atten_value = int(atten_value)
    atten.initialise_attenuator()
    bts_sw_release = int(get_sw_release_name()[4:8].replace('R', ''))
    if bts_sw_release > CONDITIONAL_RELEASE_4:
        for i in range(0, 2, 1):
            atten.set_attenuation(value_string='10', ports=cell_1_attenuator_ports)
            atten.set_attenuation(value_string='25', ports=cell_2_attenuator_ports)
            sleep(1)
            atten.set_attenuation(value_string='20', ports=cell_1_attenuator_ports)
            atten.set_attenuation(value_string='35', ports=cell_2_attenuator_ports)
            sleep(1)
            atten.set_attenuation(value_string='30', ports=cell_1_attenuator_ports)
            atten.set_attenuation(value_string='45', ports=cell_2_attenuator_ports)
            sleep(1)
            atten.set_attenuation(value_string='10', ports=cell_1_attenuator_ports)
            atten.set_attenuation(value_string='25', ports=cell_2_attenuator_ports)
            sleep(1)
            atten.set_attenuation(value_string='10', ports=cell_1_attenuator_ports)
            atten.set_attenuation(value_string='15', ports=cell_2_attenuator_ports)
            sleep(1)
            atten.set_attenuation(value_string='10', ports=cell_1_attenuator_ports)
            atten.set_attenuation(value_string='10', ports=cell_2_attenuator_ports)
            blog("atten loop no", i)
    else:
        for i in range(0, 2, 1):
            atten.set_attenuation(value_string='10', ports=cell_1_attenuator_ports)
            atten.set_attenuation(value_string='25', ports=cell_2_attenuator_ports)
            sleep(1)
            atten.set_attenuation(value_string='20', ports=cell_1_attenuator_ports)
            atten.set_attenuation(value_string='35', ports=cell_2_attenuator_ports)
            sleep(1)
            atten.set_attenuation(value_string='30', ports=cell_1_attenuator_ports)
            atten.set_attenuation(value_string='45', ports=cell_2_attenuator_ports)
            sleep(1)
            atten.set_attenuation(value_string='10', ports=cell_1_attenuator_ports)
            atten.set_attenuation(value_string='25', ports=cell_2_attenuator_ports)
            blog("atten loop no", i)
    atten.set_attenuation(value_string='0', ports=cell_1_attenuator_ports)
    atten.set_attenuation(value_string='40', ports=cell_2_attenuator_ports)


def get_dataNRcell1_Id(data, cell_filter='1', counter_ids_8049_A_C=None):
    if counter_ids_8049_A_C is None:
        counter_ids_8049_A_C = [
            'M55308C10003', 'M55308C10004', 'M55308C10001',
            'M55308C10002', 'M55308C26002', 'M55308C26001'
        ]

    filtered_counters = [data[counter_id][cell_filter][-1] for counter_id in counter_ids_8049_A_C]
    if int(filtered_counters[0]) == 0:
        filtered_counters = [data[counter_id][cell_filter][-2] for counter_id in counter_ids_8049_A_C]
        blog("missalignment with counter time collection - TTI longer collecting, taken -2 element or not raising")
    blog(filtered_counters)
    return filtered_counters


@logged_keyword
def compare_counters_8409(counters_before_feature, counters_after_feature, countersid):
    blog(counters_before_feature[0], counters_after_feature[0])
    max_loop = len(counters_before_feature)
    blog("counters value without feature", countersid)
    blog("counters value without feature", counters_before_feature)
    blog("counters value without feature", countersid)
    blog("counters value with feature", counters_after_feature)
    for i in range(0, max_loop):
        assert counters_before_feature[i] != 0 and counters_after_feature[i] != 0, f"Counters at index {i} are  " \
                                                                                   f"equal to zero"


@logged_keyword
def get_and_verify_counters(counter_dir, counter_ids):
    value_dict = pmc.get_relevant_pm_counters(pi_dir=counter_dir, counter_ids=counter_ids)
    if not value_dict:
        raise KeyError('dict is empty, there is no such counters collected on bts')
    return value_dict


@logged_keyword
def preparing_for_feature_8409_set(bts_id=mrbts_id):
    ds = DeltaStore()
    ds.initialise_delta_store()
    bts_sw_release = int(get_sw_release_name()[4:8].replace('R', ''))
    nrbts_object = f'MRBTS-{bts_id}/NRBTS-{bts_id}'
    ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                          'actConfDlInterferenceGen', 'PDSCH')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                          'actDtxOptimizedScheduler', 'false')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                          'mcsIndexForArtificialLoad', '28')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                          'actEnhDtxOptimizedScheduler', 'false')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                          'targetTotalLoadSectorBeam', '80')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                          'qRxLevMin', '-22')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-3',
                          'qRxLevMin', '-22')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-4',
                          'qRxLevMin', '-22')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-5',
                          'qRxLevMin', '-22')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-6',
                          'qRxLevMin', '-22')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-7',
                          'qRxLevMin', '-22')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-8',
                          'qRxLevMin', '-22')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-9',
                          'qRxLevMin', '-22')
    ds.validate_scf(skip_parameter_relation_errors=False)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=False)
    blog("------------------Preconditions for cell interferences done-------------------------")


def preparing_for_feature_8409_set_pooling_off(bts_id=mrbts_id):
    preparing_for_feature_8409_set(bts_id=mrbts_id)
    eqm_object = f'MRBTS-{bts_id}/EQM-1/APEQM-1/CABINET-1'
    nrbts_object = f'MRBTS-{bts_id}/NRBTS-{bts_id}'
    ds = DeltaStore()
    ds.initialise_delta_store()
    blog("------------------Turning off pooling-------------------------")
    ds.add_param_to_delta(eqm_object + '/BBMOD-1',
                          'fddNrCellConfigTradeoff', 'max cells')
    ds.add_param_to_delta(eqm_object + '/BBMOD-2',
                          'fddNrCellConfigTradeoff', 'max cells')
    ds.validate_scf(skip_parameter_relation_errors=False)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=False)
    ds = DeltaStore()
    ds.initialise_delta_store()
    ds.add_param_to_delta(nrbts_object,
                          'actSlowPrbPooling', 'false')
    ds.add_param_to_delta(nrbts_object,
                          'actSlowPrbPoolingFddFr1Enh', 'false')
    ds.add_param_to_delta(nrbts_object + '/NRDU-1',
                          'flexibleCAMode', 'ConfigurationIndependent')
    ds.validate_scf(skip_parameter_relation_errors=False)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=False)
    blog("------------------Pooling off 8409 activated-------------------------")


def ActivatingFeature8409_A_C_combine(bts_id=mrbts_id):
    bts_sw_release = int(get_sw_release_name()[4:8].replace('R', ''))
    ds = DeltaStore()
    ds.initialise_delta_store()
    nrbts_object = f'MRBTS-{bts_id}/NRBTS-{bts_id}'
    ds.add_param_to_delta(nrbts_object + '/NRCELL-1',
                          'actCsiImRandomizationFddNonDss', 'true')
    if bts_sw_release <= CONDITIONAL_RELEASE_4:
        ds.add_param_to_delta(nrbts_object + '/NRCELL-1',
                              'tmpActFeat2', '67108864')
        ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                              'tmpActFeat2', '67108864')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-1',
                          'actPdschAtSsbSlots', 'true')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-1',
                          'actDlCqiIncrRestriction', 'true')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                          'actPdschAtSsbSlots', 'true')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                          'actCsiImRandomizationFddNonDss', 'true')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                          'actDlCqiIncrRestriction', 'true')
    if bts_sw_release >= CONDITIONAL_RELEASE_4:
        ds.add_param_to_delta(nrbts_object + '/NRCELL-1',
                              'actPdschAllocAroundSsb', 'true')
        ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                              'actPdschAllocAroundSsb', 'true')
    if bts_sw_release > CONDITIONAL_RELEASE_4:
        ds.add_param_to_delta(nrbts_object + '/NRCELL-1',
                              'actDlForceRankDowng', 'dlNonGbrBrOnly')
        ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                              'actDlForceRankDowng', 'dlNonGbrBrOnly')
        ds.add_param_to_delta(nrbts_object + '/NRCELL-1',
                              'shortTermBlerThreshold1', '12')
        ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                              'shortTermBlerThreshold1', '12')
        ds.add_param_to_delta(nrbts_object + '/NRCELL-1',
                              'shortTermBlerThreshold2', '10')
        ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                              'shortTermBlerThreshold2', '10')
    if bts_sw_release > CONDITIONAL_RELEASE_4:
        ds.add_complex_item_to_delta(nrbts_object + '/NRCELL-2', 'dlForceRankDowngCtl',
                                     maxMcsForDlSrb='19',
                                     maxMcsForDlVoNRCtrl='19')
        ds.add_complex_item_to_delta(nrbts_object + '/NRCELL-1', 'dlForceRankDowngCtl',
                                     maxMcsForDlSrb='19',
                                     maxMcsForDlVoNRCtrl='19')
    ds.validate_scf(skip_parameter_relation_errors=False)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=False)
    blog("------------------Feature 8409 for part A and C Activated-------------------------")


def ActivatingFeature8409_B(bts_id=mrbts_id):
    ds = DeltaStore()
    ds.initialise_delta_store()
    nrbts_object = f'MRBTS-{bts_id}/NRBTS-{bts_id}'
    ds.add_param_to_delta(nrbts_object + '/NRCELL-1',
                          'actVoNRIncCodingGain', 'false')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                          'actVoNRIncCodingGain', 'false')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-1',
                          'actDlPowerBoost', 'dlVoNRPowerBoost')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                          'actDlPowerBoost', 'dlVoNRPowerBoost')

    ds.validate_scf(skip_parameter_relation_errors=False)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=False)
    blog("------------------Feature 8409 for part B Activated-------------------------")


@logged_keyword
def SCF_Revert_8409(bts_id=mrbts_id):
    bts_sw_release = int(get_sw_release_name()[4:8].replace('R', ''))
    ds = DeltaStore()
    ds.initialise_delta_store()
    nrbts_object = f'MRBTS-{bts_id}/NRBTS-{bts_id}'
    ds.add_param_to_delta(nrbts_object + '/NRCELL-1',
                          'actCsiImRandomizationFddNonDss', 'false')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-1',
                          'tmpActFeat2', '0')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                          'tmpActFeat2', '0')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-1',
                          'actPdschAtSsbSlots', 'false')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                          'actPdschAtSsbSlots', 'false')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                          'actCsiImRandomizationFddNonDss', 'false')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-1',
                          'actDlCqiIncrRestriction', 'false')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                          'actDlCqiIncrRestriction', 'false')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                          'actConfDlInterferenceGen', 'none')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                          'actDtxOptimizedScheduler', 'true')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                          'actEnhDtxOptimizedScheduler', 'true')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                          'qRxLevMin', '-60')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-3',
                          'qRxLevMin', '-60')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-4',
                          'qRxLevMin', '-60')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-5',
                          'qRxLevMin', '-60')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-6',
                          'qRxLevMin', '-60')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-7',
                          'qRxLevMin', '-60')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-8',
                          'qRxLevMin', '-60')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-9',
                          'qRxLevMin', '-60')
    if bts_sw_release >= CONDITIONAL_RELEASE_4:
        ds.add_param_to_delta(nrbts_object + '/NRCELL-1',
                              'actPdschAllocAroundSsb', 'false')
        ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                              'actPdschAllocAroundSsb', 'false')
    if bts_sw_release > CONDITIONAL_RELEASE_4:
        ds.add_param_to_delta(nrbts_object + '/NRCELL-1',
                              'actDlForceRankDowng', 'disabled')
        ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                              'actDlForceRankDowng', 'disabled')
        ds.add_param_to_delta_to_delete_it(nrbts_object + '/NRCELL-1',
                                           'shortTermBlerThreshold1')
        ds.add_param_to_delta_to_delete_it(nrbts_object + '/NRCELL-2',
                                           'shortTermBlerThreshold1')
        ds.add_param_to_delta_to_delete_it(nrbts_object + '/NRCELL-1',
                                           'shortTermBlerThreshold2')
        ds.add_param_to_delta_to_delete_it(nrbts_object + '/NRCELL-2',
                                           'shortTermBlerThreshold2')
    ds.validate_scf(skip_parameter_relation_errors=False)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=False)
    blog("------------------SCF reverted-------------------------")


@logged_keyword
def SCF_Revert_8409_pooling(bts_id=mrbts_id):
    SCF_Revert_8409(bts_id=mrbts_id)
    ds = DeltaStore()
    ds.initialise_delta_store()
    eqm_object = f'MRBTS-{bts_id}/EQM-1/APEQM-1/CABINET-1'
    nrbts_object = f'MRBTS-{bts_id}/NRBTS-{bts_id}'
    ds.add_param_to_delta(nrbts_object,
                          'actSlowPrbPooling', 'true')
    ds.add_param_to_delta(nrbts_object,
                          'actSlowPrbPoolingFddFr1Enh', 'true')
    ds.add_param_to_delta(nrbts_object + '/NRDU-1',
                          'flexibleCAMode', 'NumberCellAmount')
    ds.add_param_to_delta(eqm_object + '/BBMOD-1',
                          'fddNrCellConfigTradeoff', 'not used')
    ds.add_param_to_delta(eqm_object + '/BBMOD-2',
                          'fddNrCellConfigTradeoff', 'not used')

    ds.validate_scf(skip_parameter_relation_errors=False)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=False)
    blog("------------------SCF reverted-------------------------")


def SCF_Revert_8409_B(bts_id=mrbts_id):
    ds = DeltaStore()
    ds.initialise_delta_store()
    nrbts_object = f'MRBTS-{bts_id}/NRBTS-{bts_id}'
    ds.add_param_to_delta(nrbts_object + '/NRCELL-1',
                          'actVoNRIncCodingGain', 'true')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                          'actVoNRIncCodingGain', 'true')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-1',
                          'actDlPowerBoost', 'disabled')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                          'actDlPowerBoost', 'disabled')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                          'qRxLevMin', '-60')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-3',
                          'qRxLevMin', '-60')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-4',
                          'qRxLevMin', '-60')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-5',
                          'qRxLevMin', '-60')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-6',
                          'qRxLevMin', '-60')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-7',
                          'qRxLevMin', '-60')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-8',
                          'qRxLevMin', '-60')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-9',
                          'qRxLevMin', '-60')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                          'actConfDlInterferenceGen', 'none')
    ds.add_param_to_delta_to_delete_it(nrbts_object + '/NRCELL-1',
                                       'percRedSEDlRat1VoNR')
    ds.add_param_to_delta_to_delete_it(nrbts_object + '/NRCELL-2',
                                       'percRedSEDlRat1VoNR')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-1',
                          'actRat1Alloc', 'false')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                          'actRat1Alloc', 'false')
    ds.validate_scf(skip_parameter_relation_errors=False)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=False)
    blog("------------------Feature 8409 for part B Activated-------------------------")


@logged_keyword
def verify_tput():
    taf_ue.check_data_transfer_is_alive(dt_name="DT_DL")
    taf_ue.check_data_transfer_is_alive(dt_name="DT_UL")
    taf_ue.verify_average_throughput(dt_name="DT_DL", tput_min="1Mbits/sec")
    taf_ue.verify_average_throughput(dt_name="DT_UL", tput_min="1Mbits/sec")


def stop_tti_traces_in_streaming_mode_8409(tti_collector_name='TTI', tti_output_dir=None, decoded_output_file=None,
                                           tcpdump_filename='tti_tcpdump', with_decode=True,
                                           output_file_format='legacyCsv'):
    outputdir = robot_globals.outputdir()
    testname = robot_globals.testname()
    decoded_output_file = \
        os.path.join(tti_collector_name, testname) if decoded_output_file is None else decoded_output_file
    tti_output_dir = outputdir if tti_output_dir is None else tti_output_dir

    stop_generation_of_tti_trace_using_taf(tti_output_dir=tti_output_dir)
    tti_pcap_path = os.path.join(tti_output_dir, tti_collector_name, tcpdump_filename, tcpdump_filename + '.pcap')
    if with_decode:
        convert_tti_to_csv(
            input_file_path=tti_pcap_path, output_file=decoded_output_file, output_file_format=output_file_format)
    blog('TTI streaming stopped!')
    return os.path.join(robot_globals.outputdir(), decoded_output_file + '.dl.csv')


def tti_analysis_8409(input_file, filter_csv='csiSrReportData', parameter_filter='cqi', test_type='',
                      elements_to_skip=0):
    global index_filter, index_digit
    processing_data = False
    matches = []
    with open(input_file, newline='') as file:
        content = csv.reader(file)
        for line in file:
            if re.search(filter_csv, line):
                matches.append(line.strip())
    result_list = []
    for match in matches:
        params = match.split(': ')[1].split(',')
        result_list.append(params)
    sum_of_cqi = []
    for idx in range(len(result_list)):
        replaced_list = str(result_list[idx])
        replaced_list = replaced_list.replace("[", "").replace("]", "").replace("'", "").replace(" ", "")
        replaced_list = replaced_list.split(",")
        for i in range(len(replaced_list)):
            if replaced_list[i] == parameter_filter:
                index_filter = i
            if replaced_list[i].isdigit():
                index_digit = i
                break
        if (replaced_list[index_filter + index_digit]) != '255':
            sum_of_cqi.append(int(replaced_list[index_filter + index_digit]))
        else:
            elements_to_skip += 1

    if test_type == 'sum':
        value_parameters = sum(sum_of_cqi)
        blog("sum value of parameter", filter_csv, parameter_filter, value_parameters)
    else:
        sum_of_parameter = sum(sum_of_cqi)
        average_value_of_parameter = float(sum_of_parameter) / (len(result_list) - elements_to_skip)
        value_parameters = average_value_of_parameter
        blog("average value of parameter", filter_csv, parameter_filter, average_value_of_parameter)
    return value_parameters


def check_CQI_values(cqi_ue, cqi_bts):
    assert cqi_ue >= cqi_bts, "cqi value of UE is smaller than cqi from bts"
    blog("cqi comparison passed")


def check_CQI_values_for_randomization(cqi_ue, cqi_bts):
    assert cqi_ue > cqi_bts, "cqi value of UE is smaller than cqi from bts"
    blog("cqi comparison passed")


@logged_keyword
def stop_logging_pcap(teardown=False):
    tcpdump.stop_tcpdump_and_download_logs_from_smod(teardown)
    l1l2.stop_gnbmirroring_and_download_logs()


@logged_keyword
def start_logging_pcap(pcap_filename="default", smod_slave=False):
    l1l2.start_gnbmirroring(filename="CB008409")
    if pcap_filename == "default":
        tcpdump.start_tcpdump_on_smod(smod_slave=smod_slave)
    else:
        tcpdump.start_tcpdump_on_smod(filename="CB008409{}.pcap".format(pcap_filename), smod_slave=smod_slave)


def check_pcap_8409(pcap_file, protocol='f1ap', filter_pcap='DLRRCMessageTransfer', parameter_1=None,
                    value_to_check_list=None):
    global param_name, param_value
    if parameter_1 is None:
        parameter_1 = []
    if value_to_check_list is None:
        value_to_check_list = {}
    parameter_1 = str(parameter_1)
    parameter_1 = parameter_1.split()
    value_to_check = {}

    for item in value_to_check_list:
        key, value = item.split(':')
        key = key.strip()
        value = value.strip()
        value_to_check[key] = value

    frames = log_finder(pcap_file, protocol, filter_pcap)
    found_params_values = []

    for msg in frames:
        found_all_params = True
        found_params = {}

        for param in parameter_1:
            found_param_result = msg.find(param + '*')
            if not found_param_result:
                found_all_params = False
                break
            found_param_value = found_param_result.first()['val']
            found_params[param] = found_param_value
            blog('Value for parameter', param, 'is equal to:', found_param_value)

        if found_all_params:
            blog('All parameters found in the message:', parameter_1)
            found_params_values.append(found_params)

            all_params_ok = True
            for param_name, param_value in value_to_check.items():
                if param_name in found_params:
                    if found_params[param_name].strip() != param_value:
                        blog('Found', param_name, 'with unexpected value:', found_params[param_name])
                        all_params_ok = False
                else:
                    blog('Parameter', param_name, 'not found in the message.')
                    all_params_ok = False
            if not all_params_ok:
                raise ValueError('parameters have unexpected values.', param_name, param_value)
            else:
                blog('All parameters have expected values.')

    if found_params_values:
        return found_params_values
    else:
        raise ValueError('Values of parameters from pcap are wrong!', parameter_1)


def check_CB008409_l1l2(pcap_file, filter_bip1='dldata_csirssendreq', filter_bip2='DlData_CsiRsSendReq',
                        replaced_list=[]):
    bts_sw_release = int(get_sw_release_name()[4:8].replace('R', ''))
    if bts_sw_release > CONDITIONAL_RELEASE_4:
        filter_bip1 = 'dldata_csirssendreql1sw'
        filter_bip2 = 'DlData_CsiRsSendReqL1sw_t'
    frames = log_finder(pcap_file,
                        filter_bip1,
                        filter_bip2)
    loop = (len(frames))

    for idx in range(loop):
        data = str(frames[idx])
        processed_data = data.replace("[", "").replace("]", "").replace("'", "").replace(" ", "").replace("(", ""). \
            replace(")", "").replace("Int16", "").replace(" (Uint16)", "").replace("(Uint8", ""). \
            replace("StrPatternDictstartSymbolUint8", "startSymbol")
        replaced_list.extend([element.strip() for element in processed_data.split(',')])
    return replaced_list


def check_pcap_8409_pooling_off(pcap_file, protocol='f1ap', filter_pcap='DLRRCMessageTransfer', parameter_1=None,
                                value_to_check_list1=None, value_to_check_list2=None):
    global param_name, param_value
    if parameter_1 is None:
        parameter_1 = []
    if value_to_check_list1 is None:
        value_to_check_list1 = {}
    if value_to_check_list2 is None:
        value_to_check_list2 = {}
    parameter_1 = str(parameter_1)
    parameter_1 = parameter_1.split()
    value_to_check = {}
    value_to_check2 = {}

    for item in value_to_check_list1:
        key, value = item.split(':')
        key = key.strip()
        value = value.strip()
        value_to_check[key] = value

    for item in value_to_check_list2:
        key, value = item.split(':')
        key = key.strip()
        value = value.strip()
        value_to_check2[key] = value

    frames = log_finder(pcap_file, protocol, filter_pcap)
    found_params_values = []

    for msg in frames:
        found_all_params = True
        found_params = {}

        for param in parameter_1:
            found_param_result = msg.find(param + '*')
            if not found_param_result:
                found_all_params = False
                break
            found_param_value = found_param_result.first()['val']
            found_params[param] = found_param_value
            blog('Value for parameter', param, 'is equal to:', found_param_value)

        if found_all_params:
            blog('All parameters found in the message:', parameter_1)
            found_params_values.append(found_params)

            all_params_ok = True

            for param_name in value_to_check.keys():
                if param_name in found_params:
                    actual_value = found_params[param_name].strip()
                    expected_value1 = value_to_check[param_name]
                    expected_value2 = value_to_check2[param_name]

                    if actual_value != expected_value1 and actual_value != expected_value2:
                        blog(actual_value)
                        blog(f"Expected either: {expected_value1} or {expected_value2}")
                        blog('Found', param_name, 'with unexpected value:', actual_value)
                        all_params_ok = False
                else:
                    blog('Parameter', param_name, 'not found in the message.')
                    all_params_ok = False

            if not all_params_ok:
                raise ValueError('Parameters have unexpected values.', param_name, actual_value)
            else:
                blog('All parameters have expected values.')

        if found_params_values:
            return found_params_values
        else:
            raise ValueError('Values of parameters from pcap are wrong!', parameter_1)

    if found_params_values:
        return found_params_values
    else:
        raise ValueError('Values of parameters from pcap are wrong!', parameter_1)


@logged_keyword
def analysis_bip_8409(replaced_list, parameter1='csiTransmitPower', parameter2="startSymbol"):
    value_1 = []
    value_2 = []
    result_dict = {}
    if parameter1 not in replaced_list or parameter2 not in replaced_list:
        raise ValueError("Chosen parameters are not present in replaced_list")
    for i in range(len(replaced_list)):
        if replaced_list[i] == parameter1:
            value_2.append(replaced_list[i + 1])
        if replaced_list[i] == parameter2:
            value_1.append(replaced_list[i + 1])
    result = value_2[:]
    for i in range(0, len(result), 2):  # reverse the ord
        if i + 1 < len(result):
            result[i], result[i + 1] = result[i + 1], result[i]
    value_2 = result
    first_indication = []
    seen_values = set()
    for idx, value in enumerate(value_1):
        if value not in seen_values:
            first_indication.append(idx)
            seen_values.add(value)
    for idx in range(len(first_indication)):
        csiTransmitPower = value_2[first_indication[idx]]
        start_symbol = value_1[first_indication[idx]]
        result_dict[start_symbol] = csiTransmitPower
    blog('values from bip log are:', result_dict)
    assert result_dict.get('13') == '-743', "For startSymbol 10 value is not equal to" + result_dict.get('13')
    result_dict.pop('13', None)
    for key, value in result_dict.items():
        assert value != '-743', f"For key {key} value is equal to -743"
    blog("checking complete - bip pass")


@logged_keyword
def attenuation_8409_B_loop(cell_1_attenuator_ports=tl.gnbs[0].dus[0].rus[1].attenuation_ports,
                            cell_2_attenuator_ports=tl.gnbs[0].dus[0].rus[2].attenuation_ports):
    atten.initialise_attenuator()
    for i in range(0, 2, 1):
        atten.set_attenuation(value_string='10', ports=cell_1_attenuator_ports)
        atten.set_attenuation(value_string='25', ports=cell_2_attenuator_ports)
        sleep(1)
        atten.set_attenuation(value_string='20', ports=cell_1_attenuator_ports)
        atten.set_attenuation(value_string='35', ports=cell_2_attenuator_ports)
        sleep(1)
        atten.set_attenuation(value_string='30', ports=cell_1_attenuator_ports)
        atten.set_attenuation(value_string='45', ports=cell_2_attenuator_ports)
        sleep(1)
        atten.set_attenuation(value_string='40', ports=cell_1_attenuator_ports)
        atten.set_attenuation(value_string='25', ports=cell_2_attenuator_ports)
        sleep(1)
        atten.set_attenuation(value_string='50', ports=cell_1_attenuator_ports)
        atten.set_attenuation(value_string='15', ports=cell_2_attenuator_ports)
        sleep(1)
        atten.set_attenuation(value_string='10', ports=cell_1_attenuator_ports)
        atten.set_attenuation(value_string='10', ports=cell_2_attenuator_ports)
        sleep(1)
        blog("atten loop no", i)
    atten.set_attenuation(value_string='0', ports=cell_1_attenuator_ports)
    atten.set_attenuation(value_string='90', ports=cell_2_attenuator_ports)


def compare_tti_vs_counter(tti_sum, counter_vaule):
    if isinstance(tti_sum, list):
        tti_sum = tti_sum[0]
    if isinstance(counter_vaule, list):
        counter_vaule = counter_vaule[0]

    assert isinstance(tti_sum, (int, str)) and isinstance(counter_vaule, (int, str)), \
        "Arguments must be integers or strings"

    assert int(tti_sum) > 0, "TTI value of power boost not incremented"
    assert int(tti_sum) == int(counter_vaule), "Value sum of boost from TTI is not equal"

    blog("Power boost comparison passed")


def activation_cni_CB0133099():
    bts_sw_release = int(get_sw_release_name()[4:8].replace('R', ''))
    ds = DeltaStore()
    ds.initialise_delta_store()
    bts_id = 55200
    nrbts_object = f'MRBTS-{bts_id}/NRBTS-{bts_id}'
    if bts_sw_release >= CONDITIONAL_RELEASE_6:
        ds.add_param_to_delta(nrbts_object + '/NRCELL-1',
                              'actCsiImRandomizationFddNonDssPciBased', 'true')
        ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                              'actCsiImRandomizationFddNonDssPciBased', 'true')
        blog("cni 133099 activated")
    ds.validate_scf(skip_parameter_relation_errors=False)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta)


def deactivation_cni_CB0133099():
    bts_sw_release = int(get_sw_release_name()[4:8].replace('R', ''))
    ds = DeltaStore()
    ds.initialise_delta_store()
    bts_id = 55200
    nrbts_object = f'MRBTS-{bts_id}/NRBTS-{bts_id}'
    if bts_sw_release >= CONDITIONAL_RELEASE_6:
        ds.add_param_to_delta(nrbts_object + '/NRCELL-1',
                              'actCsiImRandomizationFddNonDssPciBased', 'false')
        ds.add_param_to_delta(nrbts_object + '/NRCELL-2',
                              'actCsiImRandomizationFddNonDssPciBased', 'false')
        blog("cni 133099 deactivated")
    ds.validate_scf(skip_parameter_relation_errors=False)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta)
