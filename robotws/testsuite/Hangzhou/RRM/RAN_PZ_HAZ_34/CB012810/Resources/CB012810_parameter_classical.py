from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'liujia'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com'
__email__ = 'jia-rebecca.liu@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].instance_id)
_MRBTS1_name = 'MRBTS-'+_gnb_id
_NRBTS1_name = _MRBTS1_name+'/NRBTS-'+_gnb_id
_NRCELL1_name = _NRBTS1_name+'/NRCELL-1'
_NRCELL2_name = _NRBTS1_name+'/NRCELL-2'
_NRCELL3_name = _NRBTS1_name+'/NRCELL-3'
_NRDRB1_name = _NRBTS1_name+'/NRDRB-15'
_NRDRB5_name = _NRBTS1_name+'/NRDRB-10'
_NRDRB7_name = _NRBTS1_name+'/NRDRB-12'
_NRDRB9_name = _NRBTS1_name+'/NRDRB-14'
_QCIDRB7_name = _NRBTS1_name+'/NRDRB-4'
_SERVEDAMF_1 = _NRBTS1_name+'/SERVEDAMF-1'
_SERVEDAMF_2 = _NRBTS1_name+'/SERVEDAMF-2'
_SERVEDAMF_3 = _NRBTS1_name+'/SERVEDAMF-3'
_NRPRIOACC_PROFILE_1 = _NRBTS1_name+'/NRPRIOACC_PROFILE-1'
_NRPRIOACC_PROFILE_2 = _NRBTS1_name+'/NRPRIOACC_PROFILE-2'
_NRRESOURCE_PROFILE_0 = _NRBTS1_name+'/NRRESOURCEGROUP_PROFILE-0'
_NRRESOURCE_PROFILE_1 = _NRBTS1_name+'/NRRESOURCEGROUP_PROFILE-1'
_NRRESOURCE_PROFILE_2 = _NRBTS1_name+'/NRRESOURCEGROUP_PROFILE-2'
_NRRESOURCE_GROUP_4 = _NRRESOURCE_PROFILE_0+'/NRRESOURCEGROUP-4'
_NRRESOURCE_GROUP_5 = _NRRESOURCE_PROFILE_2+'/NRRESOURCEGROUP-5'


PATH_TO_SCF = ''

# ------------------------A2B2015 swconfig------------------------ #
A2B2015_Swconfig = [
    '0x590194=100',
    '0x5900B2=100',
    '0x590186=100',
]

# ------------------------A2B2015 parameter------------------------ #
Online_Modify_A2B2015_23311 = [
    dict(
        value='barred',
        dist_name=_NRCELL3_name,
        parameter='cellBarred'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actAdmissionCtrlSr'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actServiceAwareConfig'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actPriorityAccess'),
    dict(
        value='HPA',
        dist_name=_NRBTS1_name,
        parameter='applyPriorityAccess'),
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        parameter='actAdaptiveSr'),
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        parameter='actSharedSr'),
    dict(
        value='247',
        dist_name=_NRCELL1_name,
        parameter='reqMinNumPuschPrb'),
    dict(
        value='true',
        dist_name=_NRBTS1_name,
        parameter='actUserPreemption'),
    dict(
        value='15',
        dist_name=_NRPRIOACC_PROFILE_1,
        parameter='arpPrioLevelMpsMax'),
    dict(
        value='14',
        dist_name=_NRPRIOACC_PROFILE_1,
        parameter='arpPrioLevelMpsMin'),
    dict(
        value='15',
        dist_name=_NRPRIOACC_PROFILE_2,
        parameter='arpPrioLevelMpsMax'),
    dict(
        value='14',
        dist_name=_NRPRIOACC_PROFILE_2,
        parameter='arpPrioLevelMpsMin'),
    dict(
        value='false',
        dist_name=_NRBTS1_name,
        parameter='actSliceAwareAdmissionCtrl'),
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        parameter='allowEmergencyReservForTempUse'),
    dict(
        value='13',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForEmergency'),
    dict(
        value='17',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForPa'),
    dict(
        value='1',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForTempUse'),
    dict(
        value='5ms',
        dist_name=_NRDRB7_name,
        parameter='srPeriodicityDrb'),
    dict(
        value='5ms',
        dist_name=_NRDRB5_name,
        parameter='srPeriodicityDrb'),
    dict(
        value='slots20',
        dist_name=_NRCELL1_name,
        parameter='srPeriodicity'),
    dict(
        value='slots10',
        dist_name=_NRCELL1_name,
        parameter='srPeriodicityMin'),
    dict(
        value=[dict(csiReportPeriodicity='slots40')],
        dist_name=_NRCELL1_name,
        parameter='periodicCsiAcquisition'),
    dict(value=[dict(nea1_128='0', nea2_128='0', nea3_128='0')],
         dist_name=_NRBTS1_name, parameter='cipherPrefL'),
]

Online_Delete_A2B2015_23311 = [
    dict(
        dist_name=_NRCELL1_name,
        parameter='preferredVoNrSrPeriod'),
]

recovery_parameter_A2B2015_23311 = [
    # dict(
    #     value='Locked',
    #     dist_name=_SERVEDAMF_1,
    #     parameter='administrativeState'),
    # dict(
    #     value='Unlocked',
    #     dist_name=_SERVEDAMF_2,
    #     parameter='administrativeState'),
    # dict(
    #     value='Locked',
    #     dist_name=_SERVEDAMF_3,
    #     parameter='administrativeState'),
    dict(
        value='false',
        dist_name=_NRBTS1_name,
        parameter='actUserPreemption'),
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        parameter='actAdmissionCtrlSr'),
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        parameter='actServiceAwareConfig'),
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        parameter='actPriorityAccess'),
    dict(
        value='none',
        dist_name=_NRBTS1_name,
        parameter='applyPriorityAccess'),
    dict(
        value='notBarred',
        dist_name=_NRCELL3_name,
        parameter='cellBarred'),
    dict(
        value='19',
        dist_name=_NRCELL1_name,
        parameter='reqMinNumPuschPrb'),
    dict(
        value='0',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForEmergency'),
    dict(
        value='0',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForPa'),
    dict(
        value='30',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForTempUse'),
    dict(
        value='40ms',
        dist_name=_NRDRB7_name,
        parameter='srPeriodicityDrb'),
    dict(
        value='40ms',
        dist_name=_NRDRB5_name,
        parameter='srPeriodicityDrb'),
    dict(
        value='slots80',
        dist_name=_NRCELL1_name,
        parameter='srPeriodicity'),
    dict(
        value='slots40',
        dist_name=_NRCELL1_name,
        parameter='srPeriodicityMin'),
    dict(
        value='slots80',
        dist_name=_NRCELL1_name,
        parameter='preferredVoNrSrPeriod'),
    dict(
        value=[dict(csiReportPeriodicity='slots320')],
        dist_name=_NRCELL1_name,
        parameter='periodicCsiAcquisition'),
    dict(
        value='5',
        dist_name=_NRPRIOACC_PROFILE_1,
        parameter='arpPrioLevelMpsMax'),
    dict(
        value='4',
        dist_name=_NRPRIOACC_PROFILE_1,
        parameter='arpPrioLevelMpsMin'),
    dict(
        value='5',
        dist_name=_NRPRIOACC_PROFILE_2,
        parameter='arpPrioLevelMpsMax'),
    dict(
        value='4',
        dist_name=_NRPRIOACC_PROFILE_2,
        parameter='arpPrioLevelMpsMin'),
    dict(value=[dict(nea1_128='5', nea2_128='4', nea3_128='2')],
         dist_name=_NRBTS1_name, parameter='cipherPrefL'),
]

# ------------------------A2B2015 counter------------------------ #
# counter_id_A2B2015 = [
#     'M55165C00002', 'M55165C00003', 'M55165C00015', 'M55165C00020',
#     'M55165C00031', 'M55165C00032',
# ]
#
# counter_dic_path_A2B2015 = [
#     'BTS/{}/NRUC'.format(_NRCELL1_name),
#     'BTS/{}/NRUC'.format(_NRCELL1_name),
#     'BTS/{}/NRUC'.format(_NRCELL1_name),
#     'BTS/{}/NRUC'.format(_NRCELL1_name),
#     'BTS/{}/NRUC'.format(_NRCELL1_name),
#     'BTS/{}/NRUC'.format(_NRCELL1_name),
# ]

# ------------------------A3IWK3001 parameter------------------------ #
Online_Modify_A3IWK3001_23311 = [
    dict(
        value='barred',
        dist_name=_NRCELL3_name,
        parameter='cellBarred'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        parameter='actPriorityAccess'),
    dict(
        value='HPA',
        dist_name=_NRBTS1_name,
        parameter='applyPriorityAccess'),
    dict(
        value='15',
        dist_name=_NRPRIOACC_PROFILE_1,
        parameter='arpPrioLevelMpsMax'),
    dict(
        value='10',
        dist_name=_NRPRIOACC_PROFILE_1,
        parameter='arpPrioLevelMpsMin'),
    dict(
        value='15',
        dist_name=_NRPRIOACC_PROFILE_2,
        parameter='arpPrioLevelMpsMax'),
    dict(
        value='10',
        dist_name=_NRPRIOACC_PROFILE_2,
        parameter='arpPrioLevelMpsMin'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        parameter='actAdmissionCtrlSr'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        parameter='actServiceAwareConfig'),
    dict(
        value='false',
        dist_name=_NRCELL2_name,
        parameter='actAdaptiveSr'),
    dict(
        value='false',
        dist_name=_NRCELL2_name,
        parameter='actSharedSr'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        parameter='actSrAllocOpt'),
    dict(
        value='96',
        dist_name=_NRCELL2_name,
        parameter='reqMinNumPuschPrb'),
    dict(
        value='true',
        dist_name=_NRBTS1_name,
        parameter='actUserPreemption'),
    dict(
        value='false',
        dist_name=_NRBTS1_name,
        parameter='actSliceAwareAdmissionCtrl'),
    dict(
        value='false',
        dist_name=_NRCELL2_name,
        parameter='allowEmergencyReservForTempUse'),
    dict(
        value='7',
        dist_name=_NRCELL2_name,
        parameter='numOfRadioResReservForEmergency'),
    dict(
        value='24',
        dist_name=_NRCELL2_name,
        parameter='numOfRadioResReservForPa'),
    dict(
        value='4',
        dist_name=_NRCELL2_name,
        parameter='numOfRadioResReservForTempUse'),
    dict(
        value='5ms',
        dist_name=_NRDRB7_name,
        parameter='srPeriodicityDrb'),
    dict(
        value='5ms',
        dist_name=_NRDRB5_name,
        parameter='srPeriodicityDrb'),
    dict(
        value='5ms',
        dist_name=_NRDRB1_name,
        parameter='srPeriodicityDrb'),
    dict(
        value='slots20',
        dist_name=_NRCELL2_name,
        parameter='srPeriodicity'),
    dict(
        value='slots20',
        dist_name=_NRCELL2_name,
        parameter='preferredVoNrSrPeriod'),
    dict(
        value='slots5',
        dist_name=_NRCELL2_name,
        parameter='srPeriodicityMin'),
    dict(
        value=[dict(csiReportPeriodicity='slots20')],
        dist_name=_NRCELL2_name,
        parameter='periodicCsiAcquisition'),
    dict(value=[dict(nea1_128='0', nea2_128='0', nea3_128='0')],
         dist_name=_NRBTS1_name, parameter='cipherPrefL'),
    dict(
        value='15min',
        dist_name=_NRBTS1_name+'/NRPMRNL-1',
        parameter='miNrResourceUtilizationPerCell'),
]

recovery_parameter_A3IWK3001_23311 = [
    dict(
        value='notBarred',
        dist_name=_NRCELL3_name,
        parameter='cellBarred'),
    dict(
        value='notBarred',
        dist_name=_NRCELL1_name,
        parameter='cellBarred'),
    dict(
        value='false',
        dist_name=_NRCELL2_name,
        parameter='actPriorityAccess'),
    dict(
        value='none',
        dist_name=_NRBTS1_name,
        parameter='applyPriorityAccess'),
    dict(
        value='5',
        dist_name=_NRPRIOACC_PROFILE_1,
        parameter='arpPrioLevelMpsMax'),
    dict(
        value='4',
        dist_name=_NRPRIOACC_PROFILE_1,
        parameter='arpPrioLevelMpsMin'),
    dict(
        value='5',
        dist_name=_NRPRIOACC_PROFILE_2,
        parameter='arpPrioLevelMpsMax'),
    dict(
        value='4',
        dist_name=_NRPRIOACC_PROFILE_2,
        parameter='arpPrioLevelMpsMin'),
    dict(
        value='false',
        dist_name=_NRCELL2_name,
        parameter='actAdmissionCtrlSr'),
    dict(
        value='false',
        dist_name=_NRCELL2_name,
        parameter='actServiceAwareConfig'),
    dict(
        value='false',
        dist_name=_NRCELL2_name,
        parameter='actAdaptiveSr'),
    dict(
        value='false',
        dist_name=_NRBTS1_name,
        parameter='actUserPreemption'),
    dict(
        value='false',
        dist_name=_NRBTS1_name,
        parameter='actSliceAwareAdmissionCtrl'),
    dict(
        value='19',
        dist_name=_NRCELL2_name,
        parameter='reqMinNumPuschPrb'),
    dict(
        value='0',
        dist_name=_NRCELL2_name,
        parameter='numOfRadioResReservForEmergency'),
    dict(
        value='0',
        dist_name=_NRCELL2_name,
        parameter='numOfRadioResReservForPa'),
    dict(
        value='30',
        dist_name=_NRCELL2_name,
        parameter='numOfRadioResReservForTempUse'),
    dict(
        value='40ms',
        dist_name=_NRDRB7_name,
        parameter='srPeriodicityDrb'),
    dict(
        value='40ms',
        dist_name=_NRDRB5_name,
        parameter='srPeriodicityDrb'),
    dict(
        value='40ms',
        dist_name=_NRDRB1_name,
        parameter='srPeriodicityDrb'),
    dict(
        value='slots80',
        dist_name=_NRCELL2_name,
        parameter='srPeriodicity'),
    dict(
        value='slots40',
        dist_name=_NRCELL2_name,
        parameter='preferredVoNrSrPeriod'),
    dict(
        value='slots40',
        dist_name=_NRCELL2_name,
        parameter='srPeriodicityMin'),
    dict(
        value=[dict(csiReportPeriodicity='slots320')],
        dist_name=_NRCELL2_name,
        parameter='periodicCsiAcquisition'),
    dict(value=[dict(nea1_128='5', nea2_128='4', nea3_128='2')],
         dist_name=_NRBTS1_name, parameter='cipherPrefL'),
]

# ------------------------A3IWK3001 counter------------------------ #
counter_id_A3IWK3001_classical = [
    'M55165C00001', 'M55165C00003', 'M55165C00015', 'M55165C00016',
    'M55165C00018', 'M55165C00020', 'M55165C00030', 'M55165C00032',
]

counter_dic_path_A3IWK3001_classical = [
    'BTS/{}/NRUC'.format(_NRCELL2_name),
    'BTS/{}/NRUC'.format(_NRCELL2_name),
    'BTS/{}/NRUC'.format(_NRCELL2_name),
    'BTS/{}/NRUC'.format(_NRCELL2_name),
    'BTS/{}/NRUC'.format(_NRCELL2_name),
    'BTS/{}/NRUC'.format(_NRCELL2_name),
    'BTS/{}/NRUC'.format(_NRCELL2_name),
    'BTS/{}/NRUC'.format(_NRCELL2_name),
]

# ------------------------CB012810-C3B1------------------------ #
Online_Modify_C3B1_23311 = [

    dict(
        value='barred',
        dist_name=_NRCELL3_name,
        parameter='cellBarred'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actPriorityAccess'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        parameter='actPriorityAccess'),
    dict(
        value='HPA',
        dist_name=_NRBTS1_name,
        parameter='applyPriorityAccess'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actAdaptiveSr'),
    dict(
        value='false',
        dist_name=_NRCELL2_name,
        parameter='actAdaptiveSr'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actSrAllocOpt'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        parameter='actSrAllocOpt'),
    dict(
        value='true',
        dist_name=_NRCELL3_name,
        parameter='actSrAllocOpt'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actAdmissionCtrlSr'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actServiceAwareConfig'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        parameter='actAdmissionCtrlSr'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        parameter='actServiceAwareConfig'),
    dict(
        value='true',
        dist_name=_NRCELL3_name,
        parameter='actAdmissionCtrlSr'),
    dict(
        value='5ms',
        dist_name=_NRDRB7_name,
        parameter='srPeriodicityDrb'),
    dict(
        value='5ms',
        dist_name=_NRDRB5_name,
        parameter='srPeriodicityDrb'),
    dict(
        value='5ms',
        dist_name=_NRDRB1_name,
        parameter='srPeriodicityDrb'),
    dict(
        value='slots20',
        dist_name=_NRCELL2_name,
        parameter='srPeriodicity'),
    dict(
        value='slots20',
        dist_name=_NRCELL2_name,
        parameter='preferredVoNrSrPeriod'),
    dict(
        value='slots5',
        dist_name=_NRCELL2_name,
        parameter='srPeriodicityMin'),
    dict(
        value='slots40',
        dist_name=_NRCELL1_name,
        parameter='srPeriodicity'),
    dict(
        value='slots20',
        dist_name=_NRCELL1_name,
        parameter='srPeriodicityMin'),
    dict(
        value='slots40',
        dist_name=_NRCELL1_name,
        parameter='preferredVoNrSrPeriod'),
    dict(
        value=[dict(csiReportPeriodicity='slots40')],
        dist_name=_NRCELL1_name,
        parameter='periodicCsiAcquisition'),
    dict(
        value=[dict(csiReportPeriodicity='slots20')],
        dist_name=_NRCELL2_name,
        parameter='periodicCsiAcquisition'),
    dict(
        value='96',
        dist_name=_NRCELL2_name,
        parameter='reqMinNumPuschPrb'),
    dict(
        value='247',
        dist_name=_NRCELL1_name,
        parameter='reqMinNumPuschPrb'),
    dict(
        value='9',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForEmergency'),
    dict(
        value='11',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForPa'),
    dict(
        value='0',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForTempUse'),
    dict(
        value='9',
        dist_name=_NRCELL2_name,
        parameter='numOfRadioResReservForEmergency'),
    dict(
        value='30',
        dist_name=_NRCELL2_name,
        parameter='numOfRadioResReservForTempUse'),
    dict(
        value='0',
        dist_name=_NRCELL2_name,
        parameter='numOfRadioResReservForPa'),
    dict(
        value='15',
        dist_name=_NRPRIOACC_PROFILE_1,
        parameter='arpPrioLevelMpsMax'),
    dict(
        value='14',
        dist_name=_NRPRIOACC_PROFILE_1,
        parameter='arpPrioLevelMpsMin'),
    dict(
        value='15',
        dist_name=_NRPRIOACC_PROFILE_2,
        parameter='arpPrioLevelMpsMax'),
    dict(
        value='14',
        dist_name=_NRPRIOACC_PROFILE_2,
        parameter='arpPrioLevelMpsMin'),
    dict(
        value='13',
        dist_name=_NRPRIOACC_PROFILE_1,
        parameter='arpPrioLevelHpaMax'),
    dict(
        value='12',
        dist_name=_NRPRIOACC_PROFILE_1,
        parameter='arpPrioLevelHpaMin'),
    dict(
        value='13',
        dist_name=_NRPRIOACC_PROFILE_2,
        parameter='arpPrioLevelHpaMax'),
    dict(
        value='12',
        dist_name=_NRPRIOACC_PROFILE_2,
        parameter='arpPrioLevelHpaMin'),
    dict(
        value='true',
        dist_name=_NRBTS1_name,
        parameter='actSliceAwareAdmissionCtrl'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='sliceAwareAdmissionCtrlEnabled'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        parameter='sliceAwareAdmissionCtrlEnabled'),
    dict(
        value='true',
        dist_name=_NRCELL3_name,
        parameter='sliceAwareAdmissionCtrlEnabled'),
    dict(
        value=1,
        dist_name=_NRRESOURCE_PROFILE_0,
        parameter='bypassRgLimits'),
    dict(
        value=1,
        dist_name=_NRRESOURCE_PROFILE_1,
        parameter='bypassRgLimits'),
    dict(
        value=1,
        dist_name=_NRRESOURCE_PROFILE_2,
        parameter='bypassRgLimits'),
    dict(
        value='true',
        dist_name=_NRRESOURCE_GROUP_4,
        parameter='allowRegularSrAboveMaxQuota'),
    dict(
        value='false',
        dist_name=_NRRESOURCE_GROUP_5,
        parameter='allowRegularSrAboveMaxQuota'),
    dict(
        value=[dict(maxQuota='50', minQuota='1')],
        dist_name=_NRRESOURCE_GROUP_4,
        parameter='srRacParams'),
    dict(
        value=[dict(maxQuota='3', minQuota='1')],
        dist_name=_NRRESOURCE_GROUP_5,
        parameter='srRacParams'),
    dict(value=[dict(nea1_128='0', nea2_128='0', nea3_128='0')],
         dist_name=_NRBTS1_name, parameter='cipherPrefL'),
    dict(
        value='rsrp',
        dist_name=_NRCELL2_name,
        parameter='a2MeashoEnabledSA'),
]

TDD_CELL1_barred_23311 = [
    dict(
        value='barred',
        dist_name=_NRCELL1_name,
        parameter='cellBarred'),
]

TDD_CELL1_notBarred_23311 = [
    dict(
        value='notBarred',
        dist_name=_NRCELL1_name,
        parameter='cellBarred'),
]

Modify_maxQuato_C3B1_23311 = [
    dict(
        value=[dict(maxQuota='100', minQuota='0')],
        dist_name=_NRRESOURCE_GROUP_5,
        parameter='srRacParams'),
]

Online_Recovery_C3B1_23311 = [
    dict(
        value='notBarred',
        dist_name=_NRCELL3_name,
        parameter='cellBarred'),
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        parameter='actPriorityAccess'),
    dict(
        value='false',
        dist_name=_NRCELL2_name,
        parameter='actPriorityAccess'),
    dict(
        value='none',
        dist_name=_NRBTS1_name,
        parameter='applyPriorityAccess'),
    dict(
        value='40ms',
        dist_name=_NRDRB7_name,
        parameter='srPeriodicityDrb'),
    dict(
        value='40ms',
        dist_name=_NRDRB5_name,
        parameter='srPeriodicityDrb'),
    dict(
        value='40ms',
        dist_name=_NRDRB1_name,
        parameter='srPeriodicityDrb'),
    dict(
        value='slots80',
        dist_name=_NRCELL2_name,
        parameter='srPeriodicity'),
    dict(
        value='slots40',
        dist_name=_NRCELL2_name,
        parameter='preferredVoNrSrPeriod'),
    dict(
        value='slots40',
        dist_name=_NRCELL2_name,
        parameter='srPeriodicityMin'),
    dict(
        value='slots80',
        dist_name=_NRCELL1_name,
        parameter='srPeriodicity'),
    dict(
        value='slots40',
        dist_name=_NRCELL1_name,
        parameter='srPeriodicityMin'),
    dict(
        value='slots80',
        dist_name=_NRCELL1_name,
        parameter='preferredVoNrSrPeriod'),
    dict(
        value='19',
        dist_name=_NRCELL2_name,
        parameter='reqMinNumPuschPrb'),
    dict(
        value='0',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForEmergency'),
    dict(
        value='0',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForPa'),
    dict(
        value='30',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForTempUse'),
    dict(
        value=[dict(csiReportPeriodicity='slots320')],
        dist_name=_NRCELL1_name,
        parameter='periodicCsiAcquisition'),
    dict(
        value='0',
        dist_name=_NRCELL2_name,
        parameter='numOfRadioResReservForEmergency'),
    dict(
        value='30',
        dist_name=_NRCELL2_name,
        parameter='numOfRadioResReservForTempUse'),
    dict(
        value='0',
        dist_name=_NRCELL2_name,
        parameter='numOfRadioResReservForPa'),
    dict(
        value=[dict(csiReportPeriodicity='slots320')],
        dist_name=_NRCELL2_name,
        parameter='periodicCsiAcquisition'),
    dict(
        value='5',
        dist_name=_NRPRIOACC_PROFILE_1,
        parameter='arpPrioLevelMpsMax'),
    dict(
        value='4',
        dist_name=_NRPRIOACC_PROFILE_1,
        parameter='arpPrioLevelMpsMin'),
    dict(
        value='5',
        dist_name=_NRPRIOACC_PROFILE_2,
        parameter='arpPrioLevelMpsMax'),
    dict(
        value='4',
        dist_name=_NRPRIOACC_PROFILE_2,
        parameter='arpPrioLevelMpsMin'),
    dict(
        value='3',
        dist_name=_NRPRIOACC_PROFILE_1,
        parameter='arpPrioLevelHpaMax'),
    dict(
        value='2',
        dist_name=_NRPRIOACC_PROFILE_1,
        parameter='arpPrioLevelHpaMin'),
    dict(
        value='3',
        dist_name=_NRPRIOACC_PROFILE_2,
        parameter='arpPrioLevelHpaMax'),
    dict(
        value='2',
        dist_name=_NRPRIOACC_PROFILE_2,
        parameter='arpPrioLevelHpaMin'),
    dict(
        value='false',
        dist_name=_NRBTS1_name,
        parameter='actSliceAwareAdmissionCtrl'),
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        parameter='sliceAwareAdmissionCtrlEnabled'),
    dict(
        value='false',
        dist_name=_NRCELL2_name,
        parameter='sliceAwareAdmissionCtrlEnabled'),
    dict(
        value='false',
        dist_name=_NRCELL3_name,
        parameter='sliceAwareAdmissionCtrlEnabled'),
    dict(
        value=4,
        dist_name=_NRRESOURCE_PROFILE_0,
        parameter='bypassRgLimits'),
    dict(
        value=4,
        dist_name=_NRRESOURCE_PROFILE_1,
        parameter='bypassRgLimits'),
    dict(
        value=4,
        dist_name=_NRRESOURCE_PROFILE_2,
        parameter='bypassRgLimits'),
    dict(
        value='false',
        dist_name=_NRRESOURCE_GROUP_4,
        parameter='allowRegularSrAboveMaxQuota'),
    dict(
        value='false',
        dist_name=_NRRESOURCE_GROUP_5,
        parameter='allowRegularSrAboveMaxQuota'),
    dict(
        value='none',
        dist_name=_NRCELL1_name,
        parameter='a2MeashoEnabledSA'),
    dict(
        value='none',
        dist_name=_NRCELL2_name,
        parameter='a2MeashoEnabledSA'),
    dict(
        value=[dict(maxQuota='100', minQuota='0')],
        dist_name=_NRRESOURCE_GROUP_5,
        parameter='srRacParams'),
    dict(
        value=[dict(maxQuota='100', minQuota='0')],
        dist_name=_NRRESOURCE_GROUP_4,
        parameter='srRacParams'),
    dict(value=[dict(nea1_128='5', nea2_128='4', nea3_128='2')],
         dist_name=_NRBTS1_name, parameter='cipherPrefL'),
]

counter_id_C3B1_23311 = [
    'M55910C00029',
]

counter_dic_path_C3B1_cell1_23311 = [
    'BTS/{}/NRRESOURCEGROUP-4/NCUPNRG'.format(_NRCELL1_name),
]

counter_dic_path_C3B1_cell2_23311 = [
    'BTS/{}/NRRESOURCEGROUP-5/NCUPNRG'.format(_NRCELL2_name),
]

# ------------------------CB012810-C4B1------------------------ #
Online_Modify_C4B1_23311 = [
    dict(
        value='barred',
        dist_name=_NRCELL1_name,
        parameter='cellBarred'),
    dict(
        value='barred',
        dist_name=_NRCELL3_name,
        parameter='cellBarred'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actPriorityAccess'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        parameter='actPriorityAccess'),
    dict(
        value='HPA',
        dist_name=_NRBTS1_name,
        parameter='applyPriorityAccess'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actAdmissionCtrlSr'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actServiceAwareConfig'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        parameter='actAdmissionCtrlSr'),
    dict(
        value='true',
        dist_name=_NRCELL3_name,
        parameter='actAdmissionCtrlSr'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        parameter='actServiceAwareConfig'),
    dict(
        value='true',
        dist_name=_NRBTS1_name,
        parameter='actSliceAwareAdmissionCtrl'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='sliceAwareAdmissionCtrlEnabled'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        parameter='sliceAwareAdmissionCtrlEnabled'),
    dict(
        value='true',
        dist_name=_NRCELL3_name,
        parameter='sliceAwareAdmissionCtrlEnabled'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actSrAllocOpt'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        parameter='actSrAllocOpt'),
    dict(
        value='true',
        dist_name=_NRCELL3_name,
        parameter='actSrAllocOpt'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actAdaptiveSr'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        parameter='actAdaptiveSr'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='increasePUSCHPrepTimeULCA'),
    dict(
        value='dlAndUl',
        dist_name=_NRCELL2_name + '/NRREL-1',
        parameter='sCellOperationalMode'),
    dict(
        value='247',
        dist_name=_NRCELL1_name,
        parameter='reqMinNumPuschPrb'),
    dict(
        value='96',
        dist_name=_NRCELL2_name,
        parameter='reqMinNumPuschPrb'),
    dict(
        value='5ms',
        dist_name=_NRDRB7_name,
        parameter='srPeriodicityDrb'),
    dict(
        value='5ms',
        dist_name=_NRDRB5_name,
        parameter='srPeriodicityDrb'),
    dict(
        value='5ms',
        dist_name=_NRDRB1_name,
        parameter='srPeriodicityDrb'),
    dict(
        value='slots20',
        dist_name=_NRCELL2_name,
        parameter='srPeriodicity'),
    dict(
        value='slots20',
        dist_name=_NRCELL2_name,
        parameter='preferredVoNrSrPeriod'),
    dict(
        value='slots10',
        dist_name=_NRCELL2_name,
        parameter='srPeriodicityMin'),
    dict(
        value=[dict(csiReportPeriodicity='slots20')],
        dist_name=_NRCELL2_name,
        parameter='periodicCsiAcquisition'),
    dict(
        value='slots40',
        dist_name=_NRCELL1_name,
        parameter='srPeriodicity'),
    dict(
        value='slots20',
        dist_name=_NRCELL1_name,
        parameter='srPeriodicityMin'),
    dict(
        value='slots40',
        dist_name=_NRCELL1_name,
        parameter='preferredVoNrSrPeriod'),
    dict(
        value=[dict(csiReportPeriodicity='slots40')],
        dist_name=_NRCELL1_name,
        parameter='periodicCsiAcquisition'),
    dict(
        value=0,
        dist_name=_NRRESOURCE_PROFILE_0,
        parameter='bypassRgLimits'),
    dict(
        value=0,
        dist_name=_NRRESOURCE_PROFILE_1,
        parameter='bypassRgLimits'),
    dict(
        value=0,
        dist_name=_NRRESOURCE_PROFILE_2,
        parameter='bypassRgLimits'),
    dict(
        value='true',
        dist_name=_NRRESOURCE_GROUP_4,
        parameter='allowRegularSrAboveMaxQuota'),
    dict(
        value='true',
        dist_name=_NRRESOURCE_GROUP_5,
        parameter='allowRegularSrAboveMaxQuota'),
    dict(
        value=[dict(maxQuota='7', minQuota='5')],
        dist_name=_NRRESOURCE_GROUP_5,
        parameter='srRacParams'),
    dict(
        value=[dict(maxQuota='7', minQuota='5')],
        dist_name=_NRRESOURCE_GROUP_4,
        parameter='srRacParams'),
    dict(
        value='1',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForEmergency'),
    dict(
        value='1',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForPa'),
    dict(
        value='0',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForTempUse'),
    dict(
        value='9',
        dist_name=_NRCELL2_name,
        parameter='numOfRadioResReservForEmergency'),
    dict(
        value='1',
        dist_name=_NRCELL2_name,
        parameter='numOfRadioResReservForPa'),
    dict(
        value='0',
        dist_name=_NRCELL2_name,
        parameter='numOfRadioResReservForTempUse'),
    dict(
        value='5',
        dist_name=_NRBTS1_name + '/NRDU-1',
        parameter='dlToUlContributionRatio'),
    dict(value=[dict(nea1_128='0', nea2_128='0', nea3_128='0')],
         dist_name=_NRBTS1_name, parameter='cipherPrefL'),
    dict(
        value='rsrp',
        dist_name=_NRCELL2_name,
        parameter='a2MeashoEnabledSA'),
]

counter_dic_path_C4B1_cell2 = [
    'BTS/{}/NRRESOURCEGROUP-5/NCUPNRG'.format(_NRCELL2_name),
]

counter_id_C4B1_classical = [
    'M55910C00029',
]

counter_dic_path_C4B1_classical = [
    'BTS/{}/NRRESOURCEGROUP-4/NCUPNRG'.format(_NRCELL1_name),
]

Online_Recovery_C4B1_23311 = [
    dict(
        value='notBarred',
        dist_name=_NRCELL1_name,
        parameter='cellBarred'),
    dict(
        value='notBarred',
        dist_name=_NRCELL3_name,
        parameter='cellBarred'),
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        parameter='actSrAllocOpt'),
    dict(
        value='false',
        dist_name=_NRCELL2_name,
        parameter='actSrAllocOpt'),
    dict(
        value='false',
        dist_name=_NRCELL3_name,
        parameter='actSrAllocOpt'),
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        parameter='actAdaptiveSr'),
    dict(
        value='false',
        dist_name=_NRCELL2_name,
        parameter='actAdaptiveSr'),
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        parameter='actAdmissionCtrlSr'),
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        parameter='actServiceAwareConfig'),
    dict(
        value='false',
        dist_name=_NRCELL2_name,
        parameter='actAdmissionCtrlSr'),
    dict(
        value='false',
        dist_name=_NRCELL3_name,
        parameter='actAdmissionCtrlSr'),
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        parameter='actPriorityAccess'),
    dict(
        value='false',
        dist_name=_NRCELL2_name,
        parameter='actPriorityAccess'),
    dict(
        value='none',
        dist_name=_NRBTS1_name,
        parameter='applyPriorityAccess'),
    dict(
        value='false',
        dist_name=_NRBTS1_name,
        parameter='actSliceAwareAdmissionCtrl'),
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        parameter='sliceAwareAdmissionCtrlEnabled'),
    dict(
        value='false',
        dist_name=_NRCELL2_name,
        parameter='sliceAwareAdmissionCtrlEnabled'),
    dict(
        value='false',
        dist_name=_NRCELL3_name,
        parameter='sliceAwareAdmissionCtrlEnabled'),
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        parameter='increasePUSCHPrepTimeULCA'),
    dict(
        value='dlOnly',
        dist_name=_NRCELL2_name + '/NRREL-1',
        parameter='sCellOperationalMode'),
    dict(
        value='19',
        dist_name=_NRCELL1_name,
        parameter='reqMinNumPuschPrb'),
    dict(
        value='19',
        dist_name=_NRCELL2_name,
        parameter='reqMinNumPuschPrb'),
    dict(
        value='40ms',
        dist_name=_NRDRB7_name,
        parameter='srPeriodicityDrb'),
    dict(
        value='40ms',
        dist_name=_NRDRB5_name,
        parameter='srPeriodicityDrb'),
    dict(
        value='40ms',
        dist_name=_NRDRB1_name,
        parameter='srPeriodicityDrb'),
    dict(
        value='slots80',
        dist_name=_NRCELL2_name,
        parameter='srPeriodicity'),
    dict(
        value='slots40',
        dist_name=_NRCELL2_name,
        parameter='preferredVoNrSrPeriod'),
    dict(
        value='slots40',
        dist_name=_NRCELL2_name,
        parameter='srPeriodicityMin'),
    dict(
        value='slots80',
        dist_name=_NRCELL1_name,
        parameter='srPeriodicity'),
    dict(
        value='slots40',
        dist_name=_NRCELL1_name,
        parameter='srPeriodicityMin'),
    dict(
        value='slots80',
        dist_name=_NRCELL1_name,
        parameter='preferredVoNrSrPeriod'),
    dict(
        value=[dict(csiReportPeriodicity='slots320')],
        dist_name=_NRCELL1_name,
        parameter='periodicCsiAcquisition'),
    dict(
        value=[dict(csiReportPeriodicity='slots320')],
        dist_name=_NRCELL3_name,
        parameter='periodicCsiAcquisition'),
    dict(
        value=4,
        dist_name=_NRRESOURCE_PROFILE_0,
        parameter='bypassRgLimits'),
    dict(
        value=4,
        dist_name=_NRRESOURCE_PROFILE_1,
        parameter='bypassRgLimits'),
    dict(
        value=4,
        dist_name=_NRRESOURCE_PROFILE_2,
        parameter='bypassRgLimits'),
    dict(
        value='false',
        dist_name=_NRRESOURCE_GROUP_4,
        parameter='allowRegularSrAboveMaxQuota'),
    dict(
        value='false',
        dist_name=_NRRESOURCE_GROUP_5,
        parameter='allowRegularSrAboveMaxQuota'),
    dict(
        value=[dict(maxQuota='100', minQuota='0')],
        dist_name=_NRRESOURCE_GROUP_5,
        parameter='srRacParams'),
    dict(
        value=[dict(maxQuota='100', minQuota='0')],
        dist_name=_NRRESOURCE_GROUP_4,
        parameter='srRacParams'),
    dict(
        value='0',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForEmergency'),
    dict(
        value='0',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForPa'),
    dict(
        value='30',
        dist_name=_NRCELL1_name,
        parameter='numOfRadioResReservForTempUse'),
    dict(
        value='0',
        dist_name=_NRCELL2_name,
        parameter='numOfRadioResReservForEmergency'),
    dict(
        value='0',
        dist_name=_NRCELL2_name,
        parameter='numOfRadioResReservForPa'),
    dict(
        value='30',
        dist_name=_NRCELL2_name,
        parameter='numOfRadioResReservForTempUse'),
    dict(
        value='101',
        dist_name=_NRBTS1_name + '/NRDU-1',
        parameter='dlToUlContributionRatio'),
    dict(value=[dict(nea1_128='5', nea2_128='4', nea3_128='2')],
         dist_name=_NRBTS1_name, parameter='cipherPrefL'),
]


# ------------------------CB012810-B_IWK2_015------------------------ #
Online_Modify_BIWK2015_23311 = [
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        parameter='actAdaptiveSr'),
    dict(
        value='true',
        dist_name=_NRCELL3_name,
        parameter='actAdaptiveSr'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        parameter='actServiceAwareConfig'),
    dict(
        value='false',
        dist_name=_NRCELL2_name,
        parameter='actAdmissionCtrlSr'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        parameter='actSrAllocOpt'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        parameter='actCDrx'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        parameter='actCDrxVoNR'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        parameter='actVoNR'),
    dict(
        value='false',
        dist_name=_NRBTS1_name,
        parameter='actDrbDrx'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        parameter='actVonr40msProGrant'),
    dict(
        value='slots40',
        dist_name=_NRCELL2_name,
        parameter='preferredVoNrSrPeriod'),
    dict(
        value='false',
        dist_name=_NRCELL2_name,
        parameter='actVoipPacketAggr'),
    dict(
        value='10ms',
        dist_name=_NRBTS1_name + '/NRDRX-4',
        parameter='drxOnDurationTimer'),
    dict(
        value='20ms',
        dist_name=_NRBTS1_name + '/NRDRX-5',
        parameter='drxOnDurationTimer'),
    dict(
        value='40ms',
        dist_name=_NRBTS1_name + '/NRDRX-4',
        parameter='drxLongCycle'),
    dict(
        value='40ms',
        dist_name=_NRBTS1_name + '/NRDRX-5',
        parameter='drxLongCycle'),
    dict(
        value='80ms',
        dist_name=_NRDRB7_name,
        parameter='srPeriodicityDrb'),
    dict(
        value='80ms',
        dist_name=_NRDRB5_name,
        parameter='srPeriodicityDrb'),
    dict(
        value='40ms',
        dist_name=_NRDRB1_name,
        parameter='srPeriodicityDrb'),
    dict(
        value='slots80',
        dist_name=_NRCELL3_name,
        parameter='srPeriodicity'),
    dict(value=[dict(nea1_128='0', nea2_128='0', nea3_128='0')],
         dist_name=_NRBTS1_name, parameter='cipherPrefL'),
]

BIWK2015_online_false_23311 = [
    dict(
        value='false',
        dist_name=_NRCELL2_name,
        parameter='actVonr40msProGrant'),
]

Online_Recovery_BIWK2015_23311 = [
    dict(
        value='false',
        dist_name=_NRCELL2_name,
        parameter='actAdaptiveSr'),
    dict(
        value='false',
        dist_name=_NRCELL2_name,
        parameter='actServiceAwareConfig'),
    dict(
        value='false',
        dist_name=_NRCELL2_name,
        parameter='actAdmissionCtrlSr'),
    dict(
        value='false',
        dist_name=_NRCELL2_name,
        parameter='actSrAllocOpt'),
    dict(
        value='false',
        dist_name=_NRCELL2_name,
        parameter='actVonr40msProGrant'),
    dict(
        value='slots40',
        dist_name=_NRCELL2_name,
        parameter='preferredVoNrSrPeriod'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        parameter='actVoipPacketAggr'),
    dict(
        value='80ms',
        dist_name=_NRBTS1_name + '/NRDRX-4',
        parameter='drxOnDurationTimer'),
    dict(
        value='6ms',
        dist_name=_NRBTS1_name + '/NRDRX-5',
        parameter='drxOnDurationTimer'),
    dict(
        value='160ms',
        dist_name=_NRBTS1_name + '/NRDRX-4',
        parameter='drxLongCycle'),
    dict(
        value='40ms',
        dist_name=_NRBTS1_name + '/NRDRX-5',
        parameter='drxLongCycle'),
    dict(
        value='40ms',
        dist_name=_NRDRB7_name,
        parameter='srPeriodicityDrb'),
    dict(
        value='40ms',
        dist_name=_NRDRB5_name,
        parameter='srPeriodicityDrb'),
    dict(
        value='40ms',
        dist_name=_NRDRB1_name,
        parameter='srPeriodicityDrb'),
    dict(value=[dict(nea1_128='5', nea2_128='4', nea3_128='2')],
         dist_name=_NRBTS1_name, parameter='cipherPrefL'),
]
