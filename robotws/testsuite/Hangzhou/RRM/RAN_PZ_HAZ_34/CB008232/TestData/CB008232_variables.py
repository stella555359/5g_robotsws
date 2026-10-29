from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'liujia'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com'
__email__ = 'jia-rebecca.liu@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb1_id = str(tl.gnbs[0].instance_id)
_MRBTS1_name = 'MRBTS-'+_gnb1_id
_NRBTS1_name = _MRBTS1_name+'/NRBTS-'+_gnb1_id
_NRCELL1_name = _NRBTS1_name+'/NRCELL-1'
_NRCELL2_name = _NRBTS1_name+'/NRCELL-2'
_GNB1CELLGRP0 = _NRBTS1_name+'/NRCELLGRP-0'
_GNB1CELLGRP1 = _NRBTS1_name+'/NRCELLGRP-1'
_GNB1NRDU_1 = _NRBTS1_name+'/NRDU-1'
_GNB1NRPMRNL_1 = _NRBTS1_name+'/NRPMRNL-1'
_SERVEDAMF_1 = _NRBTS1_name+'/SERVEDAMF-1'
_NRPRIOACC_1 = _NRBTS1_name+'/NRPRIOACC_PROFILE-1'
_NRPRIOACC_2 = _NRBTS1_name+'/NRPRIOACC_PROFILE-2'
_gnb2_id = str(tl.gnbs[1].instance_id)
_MRBTS2_name = 'MRBTS-'+_gnb2_id
_NRBTS2_name = _MRBTS2_name+'/NRBTS-'+_gnb2_id
_NRCELL3_name = _NRBTS2_name+'/NRCELL-1'
_GNB2CELLGRP0 = _NRBTS2_name+'/NRCELLGRP-0'
_SERVEDAMF_2 = _NRBTS2_name+'/SERVEDAMF-1'
_NRREL1 = _NRCELL2_name+'/NRREL-1'

PATH_TO_SCF = ''


# ----- counter ------#
counter_dic_path_mps_GNB1CELL1 = [
    'BTS/BTS/NRBTS-{}/NRDU-1/NRRCD'.format(_gnb1_id),
    'BTS/CELLS/NRCELL-1/NRRCC',
    'BTS/CELLS/NRCELL-1/NRRCC',
    'BTS/BTS/NRBTS-{}/NRDU-1/NRRCD'.format(_gnb1_id),
]

counter_id_mps = [
    'M55127C03003', 'M55124C09003', 'M55124C01015', 'M55127C00013'
]

counter_dic_path_hpa_GNB1CELL1 = [
    'BTS/BTS/NRBTS-{}/NRDU-1/NRRCD'.format(_gnb1_id),
    'BTS/CELLS/NRCELL-1/NRRCC',
    'BTS/CELLS/NRCELL-1/NRRCC',
    'BTS/BTS/NRBTS-{}/NRDU-1/NRRCD'.format(_gnb1_id),
]

counter_dic_path_hpa_GNB1CELL1_trunk = [
    'BTS/' + _NRBTS1_name + '/NRDU-1/NRRCD',
    'BTS/' + _NRBTS1_name + '/NRCELL-1/NRRCC',
    'BTS/' + _NRBTS1_name + '/NRCELL-1/NRRCC',
    'BTS/' + _NRBTS1_name + '/NRDU-1/NRRCD'
]

counter_id_hpa = [
    'M55127C03001', 'M55124C09001', 'M55124C01005', 'M55127C00005'
]

counter_dic_path_hpa_fail_GNB1CELL1 = [
    'BTS/CELLS/NRCELL-1/NRRCC',
    'BTS/CELLS/NRCELL-1/NRRCC'
]

counter_id_hpa_fail = [
    'M55124C01005', 'M55124C01025'
]

counter_dic_path_ICS_mps_GNB1CELL1 = [
    'BTS/CELLS/NRCELL-1/NNGCC',
    'BTS/CELLS/NRCELL-1/NNGCC',
]

counter_id_ICS_mps = [
    'M55125C12502', 'M55125C12504'
]

counter_dic_path_ICS_hpa_GNB1CELL1 = [
    'BTS/CELLS/NRCELL-1/NNGCC',
    'BTS/CELLS/NRCELL-1/NNGCC',
]

counter_dic_path_ICS_hpa_GNB1CELL1_trunk = [
    'BTS/' + _NRBTS1_name + '/NRCELL-1/NNGCC',
    'BTS/' + _NRBTS1_name + '/NRCELL-1/NNGCC',
]

counter_id_ICS_hpa = [
    'M55125C12501', 'M55125C12503'
]

counter_id_PAGING = [
    'M55119C02501', 'M55117C04501'
]

counter_dic_PAGING_GNB1CELL1 = [
    'BTS/BTS/NRBTS-{}/NNGCB'.format(_gnb1_id),
    'BTS/BTS/NRBTS-{}/NRDU-1/NF1CD'.format(_gnb1_id),
]

counter_dic_PAGING_GNB1CELL1_trunk = [
    'BTS/' + _NRBTS1_name + '/NNGCB',
    'BTS/' + _NRBTS1_name + '/NRDU-1/NF1CD'
]

counter_id_priPAGING = [
    'M55331C00003'
]

counter_dic_priPAGING_GNB1CELL1 = [
    'BTS/CELLS/NRCELL-1/NRPAG'
]

counter_dic_priPAGING_GNB1CELL1_trunk = [
    'BTS/' + _NRBTS1_name + '/NRCELL-1/NRPAG'
]

Lock_GNB2_CELL1 = [
    dict(
        value='Locked',
        dist_name=_NRCELL3_name,
        parameter='administrativeState')
]

Unlock_GNB2_CELL1 = [
    dict(
        value='Unlocked',
        dist_name=_NRCELL3_name,
        parameter='administrativeState')
]

Unlock_GNB1_CELL2 = [
    dict(
        value='Unlocked',
        dist_name=_NRCELL2_name,
        parameter='administrativeState')
]

raPrio_Modify_MPS = [
    dict(
        value='MPS',
        dist_name=_NRCELL1_name,
        parameter='raPrioritizationForAI')
]

raPrio_Modify_MCS = [
    dict(
        value='MCS',
        dist_name=_NRCELL1_name,
        parameter='raPrioritizationForAI')
]

GNB1CELL1_Barred = [
    dict(
        value='barred',
        dist_name=_NRCELL1_name,
        parameter='cellBarred')
]

GNB1CELL2_Barred = [
    dict(
        value='barred',
        dist_name=_NRCELL2_name,
        parameter='cellBarred')
]

GNB2CELL1_Barred = [
    dict(
        value='barred',
        dist_name=_NRCELL3_name,
        parameter='cellBarred')
]

GNB1CELL1_notBarred = [
    dict(
        value='notBarred',
        dist_name=_NRCELL1_name,
        parameter='cellBarred')
]

GNB1CELL2_notBarred = [
    dict(
        value='notBarred',
        dist_name=_NRCELL2_name,
        parameter='cellBarred')
]

GNB2CELL1_notBarred = [
    dict(
        value='notBarred',
        dist_name=_NRCELL3_name,
        parameter='cellBarred')
]

# -------A007------ #
A_007_Modify_Online = [
    dict(
        value='MPS',
        dist_name=_NRBTS1_name,
        parameter='applyPriorityAccess'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actPriorityAccess'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actEmergencyCall'),
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        parameter='allowEmergencyReservForTempUse'),
    dict(
        value='1',
        dist_name=_NRCELL1_name,
        parameter='maxNumOfRrcSA'),
    dict(
        value='1',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForPa'),
    dict(
        value='0',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForTempUse'),
    dict(
        value='0',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForEmergency'),
    dict(
        value='1',
        dist_name=_GNB1NRDU_1,
        parameter='maxNumOfRrcConUEsPerDU'),
    dict(
        value='true',
        dist_name=_NRBTS1_name,
        parameter='actUserPreemption'),
    dict(
        value='5min',
        dist_name=_GNB1NRPMRNL_1,
        parameter='miNrNGCC'),
    dict(
        value='5min',
        dist_name=_GNB1NRPMRNL_1,
        parameter='miNrRRCD'),
    dict(
        value='5min',
        dist_name=_GNB1NRPMRNL_1,
        parameter='miNrRRCC'),
]

A_007_ADD_Para = [
    dict(
        value='1',
        dist_name=_GNB1NRDU_1,
        parameter='numOfDrbsReservForPa'),
]

# -------A012------ #
A_012_Modify_Online = [
    dict(
        value='none',
        dist_name=_NRBTS1_name,
        parameter='applyPriorityAccess'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actPriorityAccess'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actEmergencyCall'),
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        parameter='allowEmergencyReservForTempUse'),
    dict(
        value='false',
        dist_name=_NRBTS1_name,
        parameter='actUserPreemption'),
    dict(
        value='1',
        dist_name=_GNB1CELLGRP0,
        parameter='maxNumOfRrcCGRPSA'),
    dict(
        value='2',
        dist_name=_NRCELL1_name,
        parameter='maxNumOfRrcSA'),
    dict(
        value='0',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForPa'),
    dict(
        value='0',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForTempUse'),
    dict(
        value='2',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForEmergency'),
    dict(
        value='3',
        dist_name=_GNB1NRDU_1,
        parameter='numOfDrbsReservForEmergency'),
    dict(
        value='3',
        dist_name=_NRCELL1_name,
        parameter='maxNumOfNonGBRBearersSA'),
    dict(
        value='0',
        dist_name=_NRCELL1_name,
        parameter='maxNumOfGBRBearersSA'),
    dict(
        value='EnhancedVoNR',
        dist_name=_NRCELL1_name,
        parameter='actGBRAdmissionControl'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actEnhancedVoNR'),
    dict(
        value='5min',
        dist_name=_GNB1NRPMRNL_1,
        parameter='miNrNGCC'),
    dict(
        value='5min',
        dist_name=_GNB1NRPMRNL_1,
        parameter='miNrRRCD'),
    dict(
        value='5min',
        dist_name=_GNB1NRPMRNL_1,
        parameter='miNrRRCC'),
]


# -------A013------ #
A_013_Modify_Online = [
    dict(
        value='HPA',
        dist_name=_NRBTS1_name,
        parameter='applyPriorityAccess'),
    dict(
        value='3',
        dist_name=_NRPRIOACC_1,
        parameter='arpPrioLevelHpaMax'),
    dict(
        value='2',
        dist_name=_NRPRIOACC_1,
        parameter='arpPrioLevelHpaMin'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actPriorityAccess'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actEmergencyCall'),
    dict(
        value='2',
        dist_name=_NRCELL1_name,
        parameter='maxNumOfRrcSA'),
    dict(
        value='1',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForEmergency'),
    dict(
        value='1',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForPa'),
    dict(
        value='1',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForTempUse'),
    dict(
        value='1',
        dist_name=_GNB1NRDU_1,
        parameter='maxNumOfRrcConUEsPerDU'),
    dict(
        value='1',
        dist_name=_GNB1CELLGRP0,
        parameter='maxNumOfRrcCGRPSA'),
    dict(
        value='2',
        dist_name=_NRCELL1_name,
        parameter='maxNumOfNonGBRBearersSA'),
    dict(
        value='0',
        dist_name=_NRCELL1_name,
        parameter='maxNumOfGBRBearersSA'),
    dict(
        value='1',
        dist_name=_GNB1NRDU_1,
        parameter='numOfDrbsReservForEmergency'),
    dict(
        value='EnhancedVoNR',
        dist_name=_NRCELL1_name,
        parameter='actGBRAdmissionControl'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actEnhancedVoNR'),
    dict(
        value='true',
        dist_name=_NRBTS1_name,
        parameter='actUserPreemption'),
    dict(
        value='5min',
        dist_name=_GNB1NRPMRNL_1,
        parameter='miNrNGCC'),
    dict(
        value='5min',
        dist_name=_GNB1NRPMRNL_1,
        parameter='miNrRRCD'),
    dict(
        value='5min',
        dist_name=_GNB1NRPMRNL_1,
        parameter='miNrRRCC'),
]

A_013_ADD_Para = [
    dict(
        value='1',
        dist_name=_GNB1NRDU_1,
        parameter='numOfDrbsReservForPa'),
]

# --------A-018---------#
A_018_Modify_Online = [
    dict(
        value='5',
        dist_name=_NRPRIOACC_1,
        parameter='arpPrioLevelHpaMax'),
    dict(
        value='5',
        dist_name=_NRPRIOACC_1,
        parameter='arpPrioLevelHpaMin'),
    dict(
        value='4',
        dist_name=_NRPRIOACC_1,
        parameter='arpPrioLevelMpsMax'),
    dict(
        value='5',
        dist_name=_NRPRIOACC_2,
        parameter='arpPrioLevelHpaMax'),
    dict(
        value='5',
        dist_name=_NRPRIOACC_2,
        parameter='arpPrioLevelHpaMin'),
    dict(
        value='4',
        dist_name=_NRPRIOACC_2,
        parameter='arpPrioLevelMpsMax'),
    dict(
        value='HPA+MPS',
        dist_name=_NRBTS1_name,
        parameter='applyPriorityAccess'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actPriorityAccess'),
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        parameter='allowEmergencyReservForTempUse'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actEmergencyCall'),
    dict(
        value='1',
        dist_name=_NRCELL1_name,
        parameter='maxNumOfRrcSA'),
    dict(
        value='1',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForPa'),
    dict(
        value='1',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForTempUse'),
    dict(
        value='1',
        dist_name=_GNB1NRDU_1,
        parameter='maxNumOfRrcConUEsPerDU'),
    dict(
        value='true',
        dist_name=_NRBTS1_name,
        parameter='actUserPreemption'),
    dict(
        value='2',
        dist_name=_GNB1CELLGRP0,
        parameter='maxNumOfRrcCGRPSA'),
    dict(
        value='5min',
        dist_name=_GNB1NRPMRNL_1,
        parameter='miNrNGCC'),
    dict(
        value='5min',
        dist_name=_GNB1NRPMRNL_1,
        parameter='miNrRRCD'),
    dict(
        value='5min',
        dist_name=_GNB1NRPMRNL_1,
        parameter='miNrRRCC'),
]

A_018_ADD_Para = [
    dict(
        value='1',
        dist_name=_GNB1NRDU_1,
        parameter='numOfDrbsReservForPa'),
]

# --------A-026---------#
A_026_Modify_Online = [
    dict(
        value='3',
        dist_name=_NRPRIOACC_2,
        parameter='arpPrioLevelHpaMax'),
    dict(
        value='2',
        dist_name=_NRPRIOACC_2,
        parameter='arpPrioLevelHpaMin'),
    dict(
        value='3',
        dist_name=_NRPRIOACC_1,
        parameter='arpPrioLevelHpaMax'),
    dict(
        value='2',
        dist_name=_NRPRIOACC_1,
        parameter='arpPrioLevelHpaMin'),
    dict(
        value='11',
        dist_name=_NRPRIOACC_2,
        parameter='arpPrioLevelMpsMax'),
    dict(
        value='10',
        dist_name=_NRPRIOACC_2,
        parameter='arpPrioLevelMpsMin'),
    dict(
        value='11',
        dist_name=_NRPRIOACC_1,
        parameter='arpPrioLevelMpsMax'),
    dict(
        value='10',
        dist_name=_NRPRIOACC_1,
        parameter='arpPrioLevelMpsMin'),
    dict(
        value='HPA',
        dist_name=_NRBTS1_name,
        parameter='applyPriorityAccess'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actPriorityAccess'),
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        parameter='allowEmergencyReservForTempUse'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actEmergencyCall'),
    dict(
        value='EnhancedVoNR',
        dist_name=_NRCELL1_name,
        parameter='actGBRAdmissionControl'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actEnhancedVoNR'),
    dict(
        value='1',
        dist_name=_NRCELL1_name,
        parameter='maxNumOfRrcSA'),
    dict(
        value='1',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForPa'),
    dict(
        value='1',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForEmergency'),
    dict(
        value='1',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForTempUse'),
    dict(
        value='1',
        dist_name=_GNB1NRDU_1,
        parameter='numOfDrbsReservForEmergency'),
    dict(
        value='2',
        dist_name=_NRCELL1_name,
        parameter='maxNumOfNonGBRBearersSA'),
    dict(
        value='2',
        dist_name=_NRCELL1_name,
        parameter='maxNumOfGBRBearersSA'),
    dict(
        value='true',
        dist_name=_NRBTS1_name,
        parameter='actUserPreemption'),
    dict(
        value='5min',
        dist_name=_GNB1NRPMRNL_1,
        parameter='miNrNGCC'),
    dict(
        value='5min',
        dist_name=_GNB1NRPMRNL_1,
        parameter='miNrRRCD'),
    dict(
        value='5min',
        dist_name=_GNB1NRPMRNL_1,
        parameter='miNrRRCC'),
]

A_026_ADD_Para = [
    dict(
        value='2',
        dist_name=_GNB1NRDU_1,
        parameter='numOfDrbsReservForPa'),
    dict(
        value='1',
        dist_name=_GNB1NRDU_1,
        parameter='numOfDrbsReservForTempUse'),
]
# --------A-030---------#
A_030_Delete_Para_Online_CA = [
    dict(
        dist_name=_NRREL1,
        parameter='sCellAdditionMethod'),
    dict(
        dist_name=_NRREL1,
        parameter='sCellOperationalMode'),
]

A_030_Modify_Para_Online_CA = [
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        parameter='increasePUSCHPrepTimeULCA'),
]

A_030_Modify_Online = [
    dict(
        value='3',
        dist_name=_NRPRIOACC_1,
        parameter='arpPrioLevelHpaMax'),
    dict(
        value='2',
        dist_name=_NRPRIOACC_1,
        parameter='arpPrioLevelHpaMin'),
    dict(
        value='11',
        dist_name=_NRPRIOACC_1,
        parameter='arpPrioLevelMpsMax'),
    dict(
        value='10',
        dist_name=_NRPRIOACC_1,
        parameter='arpPrioLevelMpsMin'),
    dict(
        value='3',
        dist_name=_NRPRIOACC_2,
        parameter='arpPrioLevelHpaMax'),
    dict(
        value='2',
        dist_name=_NRPRIOACC_2,
        parameter='arpPrioLevelHpaMin'),
    dict(
        value='11',
        dist_name=_NRPRIOACC_2,
        parameter='arpPrioLevelMpsMax'),
    dict(
        value='10',
        dist_name=_NRPRIOACC_2,
        parameter='arpPrioLevelMpsMin'),
    dict(
        value='HPA+MPS',
        dist_name=_NRBTS1_name,
        parameter='applyPriorityAccess'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actEmergencyCall'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actPriorityAccess'),
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        parameter='allowEmergencyReservForTempUse'),
    dict(
        value='true',
        dist_name=_NRBTS1_name,
        parameter='actUserPreemption'),
    dict(
        value='on',
        dist_name=_NRCELL1_name,
        parameter='actARPBasedAC'),
    dict(
        value='0',
        dist_name=_NRCELL1_name,
        parameter='maxNumOfRrcSARedCap'),
    dict(
        value='1',
        dist_name=_NRCELL1_name,
        parameter='maxNumOfRrcSA'),
    dict(
        value='2',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForPa'),
    dict(
        value='0',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForTempUse'),
    dict(
        value='0',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForEmergency'),
    dict(
        value='EnhancedVoNR',
        dist_name=_NRCELL1_name,
        parameter='actGBRAdmissionControl'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actEnhancedVoNR'),
    dict(
        value='2',
        dist_name=_NRCELL1_name,
        parameter='maxNumOfNonGBRBearersSA'),
    dict(
        value='0',
        dist_name=_NRCELL1_name,
        parameter='maxNumOfGBRBearersSA'),
    dict(
        value='0',
        dist_name=_GNB1NRDU_1,
        parameter='numOfDrbsReservForEmergency'),
    dict(
        value='1',
        dist_name=_GNB1CELLGRP0,
        parameter='maxNumOfRrcCGRPSA'),
    dict(
        value='dB4',
        dist_name=_NRCELL1_name,
        parameter='powerRampingStepHighPriorityCbra'),
    dict(
        value='MPS+MCS',
        dist_name=_NRCELL1_name,
        parameter='raPrioritizationForAI'),
    dict(
        value='rsrp',
        dist_name=_NRCELL2_name,
        parameter='a2MeashoEnabledSA'),
    dict(
        value='rsrp',
        dist_name=_NRCELL2_name,
        parameter='a1MeashoEnabledSA'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='dedicatedSib1'),
]

A_030_ADD_Para = [
    dict(
        value='1',
        dist_name=_GNB1NRDU_1,
        parameter='numOfDrbsReservForPa'),
]

A_030_MODIFY_GNB2 = [
    dict(
        value='rsrp',
        dist_name=_NRCELL3_name,
        p_name='a2MeashoEnabledSA'),
    dict(
        value='rsrp',
        dist_name=_NRCELL3_name,
        p_name='a1MeashoEnabledSA'),
]

A_030_Change_PRAM = [
    dict(
        value='5',
        dist_name=_NRPRIOACC_1,
        parameter='arpPrioLevelMpsMax'),
    dict(
        value='4',
        dist_name=_NRPRIOACC_1,
        parameter='arpPrioLevelMpsMin'),
    dict(
        value='5',
        dist_name=_NRPRIOACC_2,
        parameter='arpPrioLevelMpsMax'),
    dict(
        value='4',
        dist_name=_NRPRIOACC_2,
        parameter='arpPrioLevelMpsMin'),
    dict(
        value='2',
        dist_name=_NRCELL1_name,
        parameter='maxNumOfRrcSA'),
    dict(
        value='1',
        dist_name=_GNB1CELLGRP0,
        parameter='addNumOfRrcCGRPSAHo'),
    dict(
        value='4',
        dist_name=_NRCELL1_name,
        parameter='maxNumOfNonGBRBearersSA'),
]


PARAM_8232_gnb1_A_030 = [
    dict(value=[dict(nea0='5', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTS1_name,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTS1_name,
         parameter='integrityProtPrefL')
]


PARAM_8232_gnb2_A_030 = [
    dict(value=[dict(nea0='5', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTS2_name,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTS2_name,
         parameter='integrityProtPrefL')
]


# --------A-052---------#
A_052_Modify_Online = [
    dict(
        value='MPS',
        dist_name=_NRBTS1_name,
        parameter='applyPriorityAccess'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actPriorityAccess'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actEmergencyCall'),
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        parameter='allowEmergencyReservForTempUse'),
    dict(
        value='false',
        dist_name=_NRBTS1_name,
        parameter='actUserPreemption'),
    dict(
        value='1',
        dist_name=_NRCELL1_name,
        parameter='maxNumOfRrcSA'),
    dict(
        value='1',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForPa'),
    dict(
        value='0',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForTempUse'),
    dict(
        value='1',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForEmergency'),
    dict(
        value='EnhancedVoNR',
        dist_name=_NRCELL1_name,
        parameter='actGBRAdmissionControl'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actEnhancedVoNR'),
    dict(
        value='3',
        dist_name=_NRCELL1_name,
        parameter='maxNumOfNonGBRBearersSA'),
    dict(
        value='0',
        dist_name=_NRCELL1_name,
        parameter='maxNumOfGBRBearersSA'),
    dict(
        value='1',
        dist_name=_GNB1NRDU_1,
        parameter='numOfDrbsReservForEmergency'),
    dict(
        value='MPS+MCS',
        dist_name=_NRCELL1_name,
        parameter='raPrioritizationForAI'),
    dict(
        value='5min',
        dist_name=_GNB1NRPMRNL_1,
        parameter='miNrNGCC'),
    dict(
        value='5min',
        dist_name=_GNB1NRPMRNL_1,
        parameter='miNrRRCD'),
    dict(
        value='5min',
        dist_name=_GNB1NRPMRNL_1,
        parameter='miNrRRCC'),
]

A_052_ADD_Para = [
    dict(
        value='1',
        dist_name=_GNB1NRDU_1,
        parameter='numOfDrbsReservForPa'),
]

# --------A-060---------#
A_060_Modify_Online_trunk = [
    dict(
        value='HPA+MPS',
        dist_name=_NRBTS1_name,
        parameter='applyPriorityAccess'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actPriorityAccess'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actEmergencyCall'),
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        parameter='allowEmergencyReservForTempUse'),
    dict(
        value='true',
        dist_name=_NRBTS1_name,
        parameter='actUserPreemption'),
    dict(
        value='3',
        dist_name=_NRCELL1_name,
        parameter='maxNumOfRrcSA'),
    dict(
        value='1',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForPa'),
    dict(
        value='0',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForTempUse'),
    dict(
        value='0',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForEmergency'),
    dict(
        value='5',
        dist_name=_NRCELL1_name,
        parameter='maxNumOfNonGBRBearersSA'),
    dict(
        value='0',
        dist_name=_NRCELL1_name,
        parameter='maxNumOfGBRBearersSA'),
    dict(
        value='2',
        dist_name=_GNB1NRDU_1,
        parameter='numOfDrbsReservForEmergency'),
    dict(
        value='1',
        dist_name=_NRPRIOACC_1,
        parameter='arpPrioLevelHpaMax'),
    dict(
        value='1',
        dist_name=_NRPRIOACC_1,
        parameter='arpPrioLevelHpaMin'),
    dict(
        value='5',
        dist_name=_NRPRIOACC_1,
        parameter='arpPrioLevelMpsMax'),
    dict(
        value='5',
        dist_name=_NRPRIOACC_1,
        parameter='arpPrioLevelMpsMin'),
]

A_060_Modify_Online_23R1 = [
    dict(
        value='HPA+MPS',
        dist_name=_NRBTS1_name,
        parameter='applyPriorityAccess'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actPriorityAccess'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actEmergencyCall'),
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        parameter='allowEmergencyReservForTempUse'),
    dict(
        value='true',
        dist_name=_NRBTS1_name,
        parameter='actUserPreemption'),
    dict(
        value='3',
        dist_name=_NRCELL1_name,
        parameter='maxNumOfRrcSA'),
    dict(
        value='1',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForPa'),
    dict(
        value='0',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForTempUse'),
    dict(
        value='0',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForEmergency'),
    dict(
        value='5',
        dist_name=_NRCELL1_name,
        parameter='maxNumOfNonGBRBearersSA'),
    dict(
        value='0',
        dist_name=_NRCELL1_name,
        parameter='maxNumOfGBRBearersSA'),
    dict(
        value='2',
        dist_name=_GNB1NRDU_1,
        parameter='numOfDrbsReservForEmergency'),
    dict(
        value='1',
        dist_name=_NRPRIOACC_2,
        parameter='arpPrioLevelHpaMax'),
    dict(
        value='1',
        dist_name=_NRPRIOACC_2,
        parameter='arpPrioLevelHpaMin'),
    dict(
        value='5',
        dist_name=_NRPRIOACC_2,
        parameter='arpPrioLevelMpsMax'),
    dict(
        value='5',
        dist_name=_NRPRIOACC_2,
        parameter='arpPrioLevelMpsMin'),
]

A_060_ADD_Para = [
    dict(
        value='1',
        dist_name=_GNB1NRDU_1,
        parameter='numOfDrbsReservForPa'),
]

# --------B-003---------#
B_003_Modify_Online = [
    dict(
        value='HPA',
        dist_name=_NRBTS1_name,
        parameter='applyPriorityAccess'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actPriorityAccess'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actEmergencyCall'),
    dict(
        value='true',
        dist_name=_NRBTS1_name,
        parameter='actDrbPreemption'),
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        parameter='allowEmergencyReservForTempUse'),
    dict(
        value='true',
        dist_name=_NRBTS1_name,
        parameter='actUserPreemption'),
    dict(
        value='1',
        dist_name=_NRCELL1_name,
        parameter='maxNumOfRrcSA'),
    dict(
        value='3',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForPa'),
    dict(
        value='1',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForTempUse'),
    dict(
        value='0',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForEmergency'),
    dict(
        value='1',
        dist_name=_NRCELL1_name,
        parameter='maxNumOfNonGBRBearersSA'),
    dict(
        value='2',
        dist_name=_GNB1NRDU_1,
        parameter='numOfDrbsReservForEmergency'),
    dict(
        value='5',
        dist_name=_NRPRIOACC_1,
        parameter='arpPrioLevelHpaMax'),
    dict(
        value='2',
        dist_name=_NRPRIOACC_1,
        parameter='arpPrioLevelHpaMin'),
    dict(
        value='8',
        dist_name=_NRPRIOACC_1,
        parameter='arpPrioLevelMpsMax'),
    dict(
        value='8',
        dist_name=_NRPRIOACC_1,
        parameter='arpPrioLevelMpsMin'),
    dict(
        value='5',
        dist_name=_NRPRIOACC_2,
        parameter='arpPrioLevelHpaMax'),
    dict(
        value='2',
        dist_name=_NRPRIOACC_2,
        parameter='arpPrioLevelHpaMin'),
    dict(
        value='8',
        dist_name=_NRPRIOACC_2,
        parameter='arpPrioLevelMpsMax'),
    dict(
        value='8',
        dist_name=_NRPRIOACC_2,
        parameter='arpPrioLevelMpsMin'),
    dict(
        value='100',
        dist_name=_NRBTS1_name,
        parameter='drbInactivityTimerSA'),
    dict(
        value='100',
        dist_name=_NRBTS1_name,
        parameter='srbInactivityTimerSA'),
    dict(
        value='100',
        dist_name=_NRBTS1_name,
        parameter='drbInactivityTimerSA5qi1'),
    dict(
        value='100',
        dist_name=_NRBTS1_name,
        parameter='drbInactivityTimerSA5qi5'),
]

B_003_ADD_Para = [
    dict(
        value='1',
        dist_name=_NRCELL1_name,
        parameter='pagingPrioLevelPaMin'),
    dict(
        value='2',
        dist_name=_NRCELL1_name,
        parameter='pagingPrioLevelPaMax'),
    dict(
        value='3000',
        dist_name=_NRCELL1_name,
        parameter='tPageCorrInt'),
    dict(
        value='20',
        dist_name=_NRBTS1_name,
        parameter='maxNumOfPreemptions'),
    dict(
        value='120',
        dist_name=_GNB1NRDU_1,
        parameter='numOfDrbsReservForTempUse'),
]

B_003_Falure_Para = [
    dict(
        value='1',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForPa'),
]

# --------C_002---------#
C_002_Modify_Online = [
    dict(
        value='HPA',
        dist_name=_NRBTS1_name,
        parameter='applyPriorityAccess'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actPriorityAccess'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actEmergencyCall'),
    dict(
        value='true',
        dist_name=_NRBTS1_name,
        parameter='actUserPreemption'),
    dict(
        value='true',
        dist_name=_NRBTS1_name,
        parameter='actDrbPreemption'),
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        parameter='allowEmergencyReservForTempUse'),
    dict(
        value='0',
        dist_name=_NRCELL1_name,
        parameter='maxNumOfRrcSARedCap'),
    dict(
        value='1',
        dist_name=_NRCELL1_name,
        parameter='maxNumOfRrcSA'),
    dict(
        value='10',
        dist_name=_NRBTS1_name,
        parameter='drbInactivityTimerSA'),
    dict(
        value='10',
        dist_name=_NRBTS1_name,
        parameter='srbInactivityTimerSA'),
    dict(
        value='oneSixteenthT',
        dist_name=_NRCELL1_name,
        parameter='numOfPagingFrames'),
    dict(
        value='v32',
        dist_name=_NRBTS1_name,
        parameter='drxDefaultPaging'),
    dict(
        value='5min',
        dist_name=_GNB1NRPMRNL_1,
        parameter='miNrPaging'),
    dict(
        value='5min',
        dist_name=_GNB1NRPMRNL_1,
        parameter='miNrNgInterface'),
    dict(
        value='5min',
        dist_name=_GNB1NRPMRNL_1,
        parameter='miNrF1CD'),
    # dict(
    #     value='100',
    #     dist_name=_NRBTS1_name,
    #     parameter='drbInactivityTimerSA'),
    # dict(
    #     value='100',
    #     dist_name=_NRBTS1_name,
    #     parameter='srbInactivityTimerSA'),
    dict(
        value='100',
        dist_name=_NRBTS1_name,
        parameter='drbInactivityTimerSA5qi1'),
    dict(
        value='100',
        dist_name=_NRBTS1_name,
        parameter='drbInactivityTimerSA5qi5'),
    dict(
        value='1',
        dist_name=_NRCELL1_name,
        parameter='maxNumPagingRecords'),
]

C_002_ADD_Para = [
    dict(
        value='1',
        dist_name=_NRCELL1_name,
        parameter='pagingPrioLevelPaMin'),
    dict(
        value='5',
        dist_name=_NRCELL1_name,
        parameter='pagingPrioLevelPaMax'),
    dict(
        value='3000',
        dist_name=_NRCELL1_name,
        parameter='tPageCorrInt'),
]

SWCONFIG_C_002 = [
    '0x5801BE=1',
]
