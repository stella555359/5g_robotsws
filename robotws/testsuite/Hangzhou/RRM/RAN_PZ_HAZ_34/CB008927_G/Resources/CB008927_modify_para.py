# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MRBTS_ID_0 = 'MRBTS-' + str(tl.gnbs[0].instance_id)
NRBTS_ID_0 = MRBTS_ID_0 + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
NRCELL_23 = NRBTS_ID_0 + '/NRCELL-23'
NRCELL_20 = NRBTS_ID_0 + '/NRCELL-20'

MRBTS_ID_1 = 'MRBTS-' + str(tl.gnbs[1].instance_id)
NRBTS_ID_1 = MRBTS_ID_1 + '/NRBTS-' + str(tl.gnbs[1].global_bts_id)
NRCELL_1 = NRBTS_ID_1 + '/NRCELL-1'
NRCELL_2 = NRBTS_ID_1 + '/NRCELL-2'

HR1_case_parameters = [
    dict(dist_name=NRCELL_23, parameter='actRat1Alloc', value='true', operation='update'),
    dict(dist_name=NRCELL_23, parameter='actDl256Qam', value='false', operation='update'),
    dict(dist_name=NRCELL_23, parameter='actDlLaDynBlerTarget', value='false', operation='update'),
    dict(dist_name=NRCELL_23, parameter='actAdaptiveReTxResMcs', value='false', operation='update'),
    dict(dist_name=NRCELL_23, parameter='actLAForHiReliab', value='true', operation='update'),
    dict(dist_name=NRCELL_23, parameter='pdschHrLaConfig',
         value=[{'dllaMcsMax64qamLowSERANK1HR': '25',
                 'dllaMcsMax64qamLowSERANK2HR': '25',
                 'dllaMcsMax64qamLowSERANK3HR': '20',
                 'dllaMcsMax64qamLowSERANK4HR': '20',
                 'dllaCqiOffsetHR': '0',
                 'dllaDeltaCqiMaxHR': '150',
                 'dllaDeltaCqiMinHR': '-150',
                 'dllaDeltaCqiStepdownHR': '500',
                 'dllaIniDeltaCqiHR': '-30',
                 'dllaIniMcsHR': '3',
                 'dllaMcsMax64qamRANK1HR': '28',
                 'dllaMcsMax64qamRANK2HR': '28',
                 'dllaMcsMax64qamRANK3HR': '28',
                 'dllaMcsMax64qamRANK4HR': '28'}], operation='update')]

HR1_case_parameters_recovery = [
    dict(dist_name=NRCELL_23, parameter='actRat1Alloc', value='true', operation='update'),
    dict(dist_name=NRCELL_23, parameter='actDl256Qam', value='true', operation='update'),
    dict(dist_name=NRCELL_23, parameter='actDlLaDynBlerTarget', value='true', operation='update'),
    dict(dist_name=NRCELL_23, parameter='actAdaptiveReTxResMcs', value='true', operation='update'),
    dict(dist_name=NRCELL_23, parameter='actLAForHiReliab', value='false', operation='update'),
    dict(dist_name=NRCELL_23, parameter='pdschHrLaConfig',
         value=[{'dllaMcsMax64qamLowSERANK1HR': '20',
                 'dllaMcsMax64qamLowSERANK2HR': '20',
                 'dllaMcsMax64qamLowSERANK3HR': '15',
                 'dllaMcsMax64qamLowSERANK4HR': '15',
                 'dllaCqiOffsetHR': '0',
                 'dllaDeltaCqiMaxHR': '150',
                 'dllaDeltaCqiMinHR': '-150',
                 'dllaDeltaCqiStepdownHR': '500',
                 'dllaIniDeltaCqiHR': '-30',
                 'dllaIniMcsHR': '3',
                 'dllaMcsMax64qamRANK1HR': '28',
                 'dllaMcsMax64qamRANK2HR': '28',
                 'dllaMcsMax64qamRANK3HR': '28',
                 'dllaMcsMax64qamRANK4HR': '28'}], operation='update')]

IWK12_case_parameter = [
    dict(dist_name=NRCELL_23 + '/NRHOIF-1', parameter='a3MeasSsbRsrp',
         value=[{'a3OffsetSsbRsrpVoNr': '3',
                 'a3OffsetSsbRsrp': '30',
                 'a3HysteresisSsbRsrp': '0',
                 'a3HysteresisSsbRsrpVoNr': '0',
                 'a3TimeToTriggerSsbRsrpVoNr': 'ms480',
                 'a3TimeToTriggerSsbRsrp': 'ms480'}], operation='update'),
    dict(dist_name=NRCELL_23, parameter='a3MeasSsbRsrp',
         value=[{'a3OffsetSsbRsrp': '3',
                 'a3HysteresisSsbRsrp': '0',
                 'a3TimeToTriggerSsbRsrp': 'ms320'}], operation='update'),]

IWK12_case_parameter_recovery = [
    dict(dist_name=NRCELL_23 + '/NRHOIF-1', parameter='a3MeasSsbRsrp',
         value=[{'a3OffsetSsbRsrpVoNr': '30',
                 'a3OffsetSsbRsrp': '30',
                 'a3HysteresisSsbRsrp': '0',
                 'a3HysteresisSsbRsrpVoNr': '0',
                 'a3TimeToTriggerSsbRsrpVoNr': 'ms480',
                 'a3TimeToTriggerSsbRsrp': 'ms480'}], operation='update'),
    dict(dist_name=NRCELL_23, parameter='a3MeasSsbRsrp',
         value=[{'a3OffsetSsbRsrp': '10',
                 'a3HysteresisSsbRsrp': '0',
                 'a3TimeToTriggerSsbRsrp': 'ms320'}], operation='update'),]

B2_case_parameter_1 = [
    dict(dist_name=NRCELL_23, parameter='a3MeasSsbRsrp',
         value=[{'a3OffsetSsbRsrp': '3',
                 'a3HysteresisSsbRsrp': '0',
                 'a3TimeToTriggerSsbRsrp': 'ms100'}], operation='update'),
    dict(dist_name=NRCELL_20, parameter='qRxLevMin', value='-22', operation='update')]

B2_case_parameter_2 = [
    dict(dist_name=NRCELL_1, parameter='actRat1Alloc', value='false', operation='update'),
    dict(dist_name=NRCELL_2, parameter='qRxLevMin', value='-22', operation='update')]

B2_case_parameter_1_recovery = [
    dict(dist_name=NRCELL_23, parameter='a3MeasSsbRsrp',
         value=[{'a3OffsetSsbRsrp': '10',
                 'a3HysteresisSsbRsrp': '0',
                 'a3TimeToTriggerSsbRsrp': 'ms100'}], operation='update'),
    dict(dist_name=NRCELL_20, parameter='qRxLevMin', value='-65', operation='update')]

B2_case_parameter_2_recovery = [
    dict(dist_name=NRCELL_1, parameter='actRat1Alloc', value='true', operation='update'),
    dict(dist_name=NRCELL_2, parameter='qRxLevMin', value='-65', operation='update')]

IWK15_case_parameter_1 = [
    dict(dist_name=NRCELL_23, parameter='a3MeasSsbRsrp',
         value=[{'a3OffsetSsbRsrp': '3',
                 'a3HysteresisSsbRsrp': '0',
                 'a3TimeToTriggerSsbRsrp': 'ms100'}], operation='update')]

IWK15_case_parameter_2 = [
    dict(dist_name=NRCELL_1, parameter='actRat1Alloc', value='true', operation='update')]

IWK15_case_parameter_1_recovery = [
    dict(dist_name=NRCELL_23, parameter='a3MeasSsbRsrp',
         value=[{'a3OffsetSsbRsrp': '10',
                 'a3HysteresisSsbRsrp': '0',
                 'a3TimeToTriggerSsbRsrp': 'ms100'}], operation='update')]

IWK15_case_parameter_2_recovery = [
    dict(dist_name=NRCELL_1, parameter='actRat1Alloc', value='false', operation='update')]

# check parameter dictionary
attached_pci_11 = [
    dict(xpath='UEContextModificationResponse/spCellConfig/spCellConfigCommon',
         expected_value={'physCellId': '11'}, n='1')]

attached_pci_244 = [
    dict(xpath='UEContextModificationResponse/spCellConfig/spCellConfigCommon',
         expected_value={'physCellId': '244'}, n='1')]

attached_pci_12 = [
    dict(xpath='UEContextModificationResponse/spCellConfig/spCellConfigCommon',
         expected_value={'physCellId': '12'}, n='1')]

resourceAllocation_0 = [
    dict(xpath='UEContextSetupResponse/spCellConfigDedicated/BWP-Downlink/bwp-Dedicated',
         expected_value={'resourceAllocation': 'resourceAllocationType0 (0)'}, n='1')]

resourceAllocation_1 = [
    dict(xpath='UEContextSetupResponse/spCellConfigDedicated/BWP-Downlink/bwp-Dedicated',
         expected_value={'resourceAllocation': 'resourceAllocationType1 (1)'}, n='1')]

resourceAllocation_1_gnb1 = [
    dict(xpath='UEContextModificationResponse/spCellConfigDedicated/BWP-Downlink/bwp-Dedicated',
         expected_value={'resourceAllocation': 'resourceAllocationType1 (1)'}, n='1')]


# flow message
gnb_source_message_flow = dict(order_list=['measurementreport',
                                           'rrcReconfiguration'],
                               should_not_include=['PDUSessionResourceModifyRequest'])

gnb_target_message_flow = dict(order_list=['PathSwitchRequest',
                                           'PathSwitchRequestAcknowledge',
                                           'UEContextModificationResponse'],
                               should_not_include=['PDUSessionResourceModifyRequest'])

vonr_setup_message_flow = dict(order_list=['PDUSessionResourceModifyRequest',
                                           'rrcReconfiguration',
                                           'rrcReconfigurationComplete',
                                           'PDUSessionResourceModifyResponse'])

vonr_fiveQI_1 = [
    dict(xpath='PDUSessionResourceModifyRequest/PDUSessionResourceModifyRequestTransfer',
         expected_value={'fiveQI': '1'}, n='1')]
