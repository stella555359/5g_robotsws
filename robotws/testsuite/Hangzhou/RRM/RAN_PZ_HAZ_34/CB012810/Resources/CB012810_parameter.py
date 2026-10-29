from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'liujia'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com'
__email__ = 'jia-rebecca.liu@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].instance_id)
_global_bts_id = str(tl.gnbs[0].global_bts_id)
_MRBTS1_name = 'MRBTS-'+_global_bts_id
_NRBTS1_name = _MRBTS1_name+'/NRBTS-'+_gnb_id
_NRCELL1_name = _NRBTS1_name+'/NRCELL-1'
_NRCELL2_name = _NRBTS1_name+'/NRCELL-2'
_NRCELL3_name = _NRBTS1_name+'/NRCELL-3'
_NRCELL4_name = _NRBTS1_name+'/NRCELL-4'
_NRDRB1_name = _NRBTS1_name+'/NRDRB-15'
_NRDRB5_name = _NRBTS1_name+'/NRDRB-10'
_NRDRB7_name = _NRBTS1_name+'/NRDRB-12'
_NRDRB9_name = _NRBTS1_name+'/NRDRB-14'
_QCIDRB7_name = _NRBTS1_name+'/NRDRB-4'
_SERVEDAMF_1 = _NRBTS1_name+'/SERVEDAMF-1'
_SERVEDAMF_2 = _NRBTS1_name+'/SERVEDAMF-2'
_SERVEDAMF_3 = _NRBTS1_name+'/SERVEDAMF-3'
_bwpDN5 = _NRBTS1_name+'/BWP_PROFILE-5'
_bwpDN53 = _NRBTS1_name+'/BWP_PROFILE-53'
_bwpDN52 = _NRBTS1_name+'/BWP_PROFILE-52'
_bwpDN57 = _NRBTS1_name+'/BWP_PROFILE-57'
_NRPMRNL = _NRBTS1_name+'/NRPMRNL-1'
_NRBTS1_NRDU1 = _NRBTS1_name+'/NRDU-9999'
_PUG1 = _NRBTS1_name+'/NRDRB_PRIO_PUG-1'
_PUG2 = _NRBTS1_name+'/NRDRB_PRIO_PUG-2'
_PUG8 = _NRBTS1_name+'/NRDRB_PRIO_PUG-8'
_NRPRIOACC_PROFILE_1 = _NRBTS1_name+'/NRPRIOACC_PROFILE-1'
_NRPRIOACC_PROFILE_2 = _NRBTS1_name+'/NRPRIOACC_PROFILE-2'
_NRRESOURCE_PROFILE_0 = _NRBTS1_name+'/NRRESOURCEGROUP_PROFILE-0'
_NRRESOURCE_PROFILE_1 = _NRBTS1_name+'/NRRESOURCEGROUP_PROFILE-1'
_NRRESOURCE_PROFILE_2 = _NRBTS1_name+'/NRRESOURCEGROUP_PROFILE-2'
_NRRESOURCE_GROUP_1 = _NRRESOURCE_PROFILE_0+'/NRRESOURCEGROUP-1'
_NRRESOURCE_GROUP_2 = _NRRESOURCE_PROFILE_1+'/NRRESOURCEGROUP-2'


PATH_TO_SCF = ''

# ------------------------A2B2015 swconfig------------------------ #
A2B2015_Swconfig = [
    '0x590194=100',
    '0x5900B2=100',
    '0x590186=100',
]

TTI_capture_swconfig = [
    '0x5808ff=2',
    '0x580905=32768',
]
# ------------------------A2B2015 parameter------------------------ #
Online_Modify_A2B2015 = [
    # dict(
    #     value='Locked',
    #     dist_name=_SERVEDAMF_1,
    #     parameter='administrativeState'),
    # dict(
    #     value='Locked',
    #     dist_name=_SERVEDAMF_2,
    #     parameter='administrativeState'),
    # dict(
    #     value='Unlocked',
    #     dist_name=_SERVEDAMF_3,
    #     parameter='administrativeState'),
    dict(
        value='barred',
        dist_name=_NRCELL2_name,
        parameter='cellBarred'),
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
        value='200',
        dist_name=_NRBTS1_NRDU1,
        parameter='numOfDrbsReservForEmergency'),
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
    dict(
        value=[dict(nia0='0', nia1_128='5', nia2_128='0', nia3_128='0')],
        dist_name=_NRBTS1_name,
        parameter='integrityProtPrefL'),
    dict(
        value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')],
        dist_name=_NRBTS1_name,
        parameter='cipherPrefL'),
    dict(
        value=_NRBTS1_name + '/NRRESOURCEGROUP_PROFILE-2',
        dist_name=_NRCELL1_name,
        parameter='nrResourceGroupProfileRacDN'),
    dict(
        value=_NRBTS1_name + '/NRRESOURCEGROUP_PROFILE-2',
        dist_name=_NRCELL2_name,
        parameter='nrResourceGroupProfileRacDN'),
    dict(
        value=_NRBTS1_name + '/NRRESOURCEGROUP_PROFILE-2',
        dist_name=_NRCELL3_name,
        parameter='nrResourceGroupProfileRacDN'),
]

Online_Delete_A2B2015 = [
    dict(
        dist_name=_NRCELL1_name,
        parameter='preferredVoNrSrPeriod'),
]

recovery_parameter_A2B2015 = [
    dict(
        value='Locked',
        dist_name=_SERVEDAMF_1,
        parameter='administrativeState'),
    dict(
        value='Unlocked',
        dist_name=_SERVEDAMF_2,
        parameter='administrativeState'),
    dict(
        value='Locked',
        dist_name=_SERVEDAMF_3,
        parameter='administrativeState'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actAdaptiveSr'),
    dict(
        value='false',
        dist_name=_NRBTS1_name,
        parameter='actUserPreemption'),
    dict(
        value='true',
        dist_name=_NRBTS1_name,
        parameter='actSliceAwareAdmissionCtrl'),
    dict(
        value='notBarred',
        dist_name=_NRCELL2_name,
        parameter='cellBarred'),
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
        value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='1')],
        dist_name=_NRBTS1_name,
        parameter='integrityProtPrefL'),
    dict(
        value=_NRBTS1_name + '/NRRESOURCEGROUP_PROFILE-0',
        dist_name=_NRCELL1_name,
        parameter='nrResourceGroupProfileRacDN'),
    dict(
        value=_NRBTS1_name + '/NRRESOURCEGROUP_PROFILE-0',
        dist_name=_NRCELL2_name,
        parameter='nrResourceGroupProfileRacDN'),
    dict(
        value=_NRBTS1_name + '/NRRESOURCEGROUP_PROFILE-1',
        dist_name=_NRCELL3_name,
        parameter='nrResourceGroupProfileRacDN'),
]

# ------------------------A2B2015 counter------------------------ #
counter_id_A2B2015 = [
    'M55165C00002', 'M55165C00003', 'M55165C00015', 'M55165C00020',
    'M55165C00031', 'M55165C00032',
]

counter_dic_path_A2B2015 = [
    'BTS/{}/NRUC'.format(_NRCELL1_name),
    'BTS/{}/NRUC'.format(_NRCELL1_name),
    'BTS/{}/NRUC'.format(_NRCELL1_name),
    'BTS/{}/NRUC'.format(_NRCELL1_name),
    'BTS/{}/NRUC'.format(_NRCELL1_name),
    'BTS/{}/NRUC'.format(_NRCELL1_name),
]

# ------------------------A3IWK3001 parameter------------------------ #
Online_Modify_A3IWK3001 = [
    dict(
        value='barred',
        dist_name=_NRCELL2_name,
        parameter='cellBarred'),
    dict(
        value='-42',
        dist_name=_NRCELL1_name,
        parameter='qRxLevMin'),
    dict(
        value='-43',
        dist_name=_NRCELL3_name,
        parameter='qRxLevMin'),
    dict(
        value='false',
        dist_name=_NRCELL3_name,
        parameter='actAdaptiveSr'),
    dict(
        value='false',
        dist_name=_NRCELL3_name,
        parameter='actSharedSr'),
    dict(
        value='true',
        dist_name=_NRCELL3_name,
        parameter='actSrAllocOpt'),
    dict(
        value='96',
        dist_name=_NRCELL3_name,
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
        dist_name=_NRCELL3_name,
        parameter='allowEmergencyReservForTempUse'),
    dict(
        value=_NRBTS1_name + '/NRRESOURCEGROUP_PROFILE-2',
        dist_name=_NRCELL1_name,
        parameter='nrResourceGroupProfileRacDN'),
    dict(
        value=_NRBTS1_name + '/NRRESOURCEGROUP_PROFILE-2',
        dist_name=_NRCELL2_name,
        parameter='nrResourceGroupProfileRacDN'),
    dict(
        value=_NRBTS1_name + '/NRRESOURCEGROUP_PROFILE-2',
        dist_name=_NRCELL3_name,
        parameter='nrResourceGroupProfileRacDN'),
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
        value='7',
        dist_name=_NRCELL3_name,
        parameter='numOfRadioResReservForEmergency'),
    dict(
        value='24',
        dist_name=_NRCELL3_name,
        parameter='numOfRadioResReservForPa'),
    dict(
        value='4',
        dist_name=_NRCELL3_name,
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
        dist_name=_NRCELL3_name,
        parameter='srPeriodicity'),
    dict(
        value='slots20',
        dist_name=_NRCELL3_name,
        parameter='preferredVoNrSrPeriod'),
    dict(
        value='slots5',
        dist_name=_NRCELL3_name,
        parameter='srPeriodicityMin'),
    dict(
        value=[dict(csiReportPeriodicity='slots20')],
        dist_name=_NRCELL3_name,
        parameter='periodicCsiAcquisition'),
    dict(
        value=[dict(nia0='0', nia1_128='5', nia2_128='0', nia3_128='0')],
        dist_name=_NRBTS1_name,
        parameter='integrityProtPrefL'),
    dict(
        value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')],
        dist_name=_NRBTS1_name,
        parameter='cipherPrefL'),

    dict(
        value='15min',
        dist_name=_NRPMRNL,
        parameter='miNrResourceUtilizationPerCell'),
]

recovery_parameter_A3IWK3001 = [
    dict(
        value='notBarred',
        dist_name=_NRCELL1_name,
        parameter='cellBarred'),
    dict(
        value='notBarred',
        dist_name=_NRCELL2_name,
        parameter='cellBarred'),
    dict(
        value='true',
        dist_name=_NRCELL3_name,
        parameter='actAdaptiveSr'),
    dict(
        value='false',
        dist_name=_NRBTS1_name,
        parameter='actUserPreemption'),
    dict(
        value='true',
        dist_name=_NRBTS1_name,
        parameter='actSliceAwareAdmissionCtrl'),
    dict(
        value=_NRBTS1_name + '/NRRESOURCEGROUP_PROFILE-0',
        dist_name=_NRCELL1_name,
        parameter='nrResourceGroupProfileRacDN'),
    dict(
        value=_NRBTS1_name + '/NRRESOURCEGROUP_PROFILE-0',
        dist_name=_NRCELL1_name,
        parameter='nrResourceGroupProfileRacDN'),
    dict(
        value=_NRBTS1_name + '/NRRESOURCEGROUP_PROFILE-1',
        dist_name=_NRCELL3_name,
        parameter='nrResourceGroupProfileRacDN'),
    dict(
        value='4',
        dist_name=_NRPRIOACC_PROFILE_1,
        parameter='arpPrioLevelMpsMax'),
    dict(
        value='2',
        dist_name=_NRPRIOACC_PROFILE_1,
        parameter='arpPrioLevelMpsMin'),
    dict(
        value='4',
        dist_name=_NRPRIOACC_PROFILE_2,
        parameter='arpPrioLevelMpsMax'),
    dict(
        value='2',
        dist_name=_NRPRIOACC_PROFILE_2,
        parameter='arpPrioLevelMpsMin'),
    dict(
        value='0',
        dist_name=_NRCELL3_name,
        parameter='numOfRadioResReservForEmergency'),
    dict(
        value='0',
        dist_name=_NRCELL3_name,
        parameter='numOfRadioResReservForPa'),
    dict(
        value='30',
        dist_name=_NRCELL3_name,
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
        dist_name=_NRCELL3_name,
        parameter='srPeriodicity'),
    dict(
        value='slots40',
        dist_name=_NRCELL3_name,
        parameter='preferredVoNrSrPeriod'),
    dict(
        value='slots40',
        dist_name=_NRCELL3_name,
        parameter='srPeriodicityMin'),
    dict(
        value=[dict(csiReportPeriodicity='slots320')],
        dist_name=_NRCELL3_name,
        parameter='periodicCsiAcquisition'),
    dict(
        value='5min',
        dist_name=_NRPMRNL,
        parameter='miNrResourceUtilizationPerCell'),
]

# ------------------------A3IWK3001 counter------------------------ #
counter_id_A3IWK3001 = [
    'M55165C00001', 'M55165C00003', 'M55165C00015', 'M55165C00016',
    'M55165C00018', 'M55165C00020', 'M55165C00030', 'M55165C00032',
]

counter_dic_path_A3IWK3001 = [
    'BTS/{}/NRUC'.format(_NRCELL3_name),
    'BTS/{}/NRUC'.format(_NRCELL3_name),
    'BTS/{}/NRUC'.format(_NRCELL3_name),
    'BTS/{}/NRUC'.format(_NRCELL3_name),
    'BTS/{}/NRUC'.format(_NRCELL3_name),
    'BTS/{}/NRUC'.format(_NRCELL3_name),
    'BTS/{}/NRUC'.format(_NRCELL3_name),
    'BTS/{}/NRUC'.format(_NRCELL3_name),
]

# ------------------------CB012810-D#WK3_001------------------------ #
Online_Modify_WK3_001 = [
    dict(
        value='barred',
        dist_name=_NRCELL2_name,
        parameter='cellBarred'),
    dict(
        value='barred',
        dist_name=_NRCELL3_name,
        parameter='cellBarred'),
]

recovery_parameter_WK3_001 = [
    dict(
        value='notBarred',
        dist_name=_NRCELL2_name,
        parameter='cellBarred'),
    dict(
        value='notBarred',
        dist_name=_NRCELL3_name,
        parameter='cellBarred'),
]

# ------------------------CB012810-D#WK8_003------------------------ #
Online_Modify_WK8_003 = [
    dict(
        value='allUes',
        dist_name=_NRCELL1_name,
        parameter='actDrbPriorityPug'),
    dict(
        value='barred',
        dist_name=_NRCELL2_name,
        parameter='cellBarred'),
    dict(
        value='rsrp',
        dist_name=_NRCELL1_name,
        parameter='a2MeashoEnabledSA'),
    dict(
        value='rsrp',
        dist_name=_NRCELL3_name,
        parameter='a2MeashoEnabledSA'),
    dict(
        value=_PUG1,
        dist_name=_NRDRB7_name,
        parameter='nrDrbPrioPugDN'),
    dict(
        value='1500',
        dist_name=_PUG1,
        parameter='drbPriorityPugPayloadSize'),
    dict(
        value='20',
        dist_name=_PUG1,
        parameter='drbPriorityPugPeriodicity'),
    dict(
        value='80',
        dist_name=_NRDRB5_name,
        parameter='priorityLevel'),
    dict(
        value='70',
        dist_name=_NRDRB7_name,
        parameter='priorityLevel'),
]

Online_Add_WK8_003 = [
    dict(
        value=_PUG8,
        dist_name=_NRDRB5_name,
        parameter='nrDrbPrioPugDN'),
]

Online_Delete_WK8_003 = [
    dict(
        dist_name=_NRCELL3_name,
        parameter='actDrbPriorityPug'),
]

Online_Modify_WK8_003_classical = [
    dict(
        value='allUes',
        dist_name=_NRCELL1_name,
        parameter='actDrbPriorityPug'),
    dict(
        value='barred',
        dist_name=_NRCELL3_name,
        parameter='cellBarred'),
    dict(
        value='rsrp',
        dist_name=_NRCELL1_name,
        parameter='a2MeashoEnabledSA'),
    dict(
        value='rsrp',
        dist_name=_NRCELL2_name,
        parameter='a2MeashoEnabledSA'),
    dict(
        value=[dict(nia0='0', nia1_128='5', nia2_128='0', nia3_128='0')],
        dist_name=_NRBTS1_name,
        parameter='integrityProtPrefL'),
    dict(
        value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')],
        dist_name=_NRBTS1_name,
        parameter='cipherPrefL'),
    dict(
        value=_PUG1,
        dist_name=_NRDRB7_name,
        parameter='nrDrbPrioPugDN'),
    dict(
        value='1500',
        dist_name=_PUG1,
        parameter='drbPriorityPugPayloadSize'),
    dict(
        value='20',
        dist_name=_PUG1,
        parameter='drbPriorityPugPeriodicity'),
    dict(
        value='80',
        dist_name=_NRDRB5_name,
        parameter='priorityLevel'),
    dict(
        value='70',
        dist_name=_NRDRB7_name,
        parameter='priorityLevel'),
]

Online_Delete_WK8_003_classical = [
    dict(
        dist_name=_NRCELL2_name,
        parameter='actDrbPriorityPug'),
]
# ------------------------CB012810-D#B3_001------------------------ #
Online_Modify_B3_001 = [
    dict(
        value='barred',
        dist_name=_NRCELL2_name,
        parameter='cellBarred'),
    dict(
        value='barred',
        dist_name=_NRCELL3_name,
        parameter='cellBarred'),
    dict(
        value='allUes',
        dist_name=_NRCELL1_name,
        parameter='actProactUlSchedulingEnh'),
    dict(
        value='onlySkippableGrantCapableUes',
        dist_name=_NRCELL1_name,
        parameter='actDrbPriorityPug'),
    dict(
        value=_PUG1,
        dist_name=_NRDRB7_name,
        parameter='nrDrbPrioPugDN'),
    dict(
        value='20',
        dist_name=_PUG1,
        parameter='drbPriorityPugPeriodicity'),
    dict(
        value='-50',
        dist_name=_PUG1,
        parameter='drbPriorityPugSinrThreshold'),
]

Online_Add_B3_001 = [
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actUlTxSkip'),
    dict(
        value='1200',
        dist_name=_NRCELL1_name,
        parameter='ulProGrantTimerTxSkip'),
    dict(
        value='80',
        dist_name=_NRCELL1_name,
        parameter='payloadSizeProactiveTxSkip'),
    dict(
        value='150',
        dist_name=_NRCELL1_name,
        parameter='ulSchedTimeIntervalTxSkip'),
]

Online_Modify_B3_001_1 = [
    dict(
        value='3000',
        dist_name=_PUG1,
        parameter='drbPriorityPugDuration'),
    dict(
        value='500',
        dist_name=_PUG1,
        parameter='drbPriorityPugPayloadSize'),
    dict(
        value='20',
        dist_name=_PUG1,
        parameter='drbPriorityPugPeriodicity'),
    dict(
        value='-100',
        dist_name=_PUG1,
        parameter='drbPriorityPugSinrThreshold'),
]

# ------------------------CB012810-C3B1------------------------ #
Online_Modify_C3B1 = [
    dict(
        value='-42',
        dist_name=_NRCELL1_name,
        parameter='qRxLevMin'),
    dict(
        value='-43',
        dist_name=_NRCELL3_name,
        parameter='qRxLevMin'),
    dict(
        value='barred',
        dist_name=_NRCELL2_name,
        parameter='cellBarred'),
    dict(
        value='false',
        dist_name=_NRCELL3_name,
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
        value='247',
        dist_name=_NRCELL1_name,
        parameter='reqMinNumPuschPrb'),
    dict(
        value='96',
        dist_name=_NRCELL3_name,
        parameter='reqMinNumPuschPrb'),
    dict(
        value='slots20',
        dist_name=_NRCELL3_name,
        parameter='srPeriodicity'),
    dict(
        value='slots20',
        dist_name=_NRCELL3_name,
        parameter='preferredVoNrSrPeriod'),
    dict(
        value='slots5',
        dist_name=_NRCELL3_name,
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
        dist_name=_NRCELL3_name,
        parameter='periodicCsiAcquisition'),
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
        dist_name=_NRCELL3_name,
        parameter='numOfRadioResReservForEmergency'),
    dict(
        value='30',
        dist_name=_NRCELL3_name,
        parameter='numOfRadioResReservForTempUse'),
    dict(
        value='0',
        dist_name=_NRCELL3_name,
        parameter='numOfRadioResReservForPa'),
    dict(
        value='15',
        dist_name=_NRPRIOACC_PROFILE_2,
        parameter='arpPrioLevelMpsMax'),
    dict(
        value='10',
        dist_name=_NRPRIOACC_PROFILE_2,
        parameter='arpPrioLevelMpsMin'),
    dict(
        value='15',
        dist_name=_NRPRIOACC_PROFILE_1,
        parameter='arpPrioLevelMpsMax'),
    dict(
        value='10',
        dist_name=_NRPRIOACC_PROFILE_1,
        parameter='arpPrioLevelMpsMin'),
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
        dist_name=_NRRESOURCE_GROUP_1,
        parameter='allowRegularSrAboveMaxQuota'),
    dict(
        value='false',
        dist_name=_NRRESOURCE_GROUP_2,
        parameter='allowRegularSrAboveMaxQuota'),
    dict(
        value=[dict(maxQuota='3', minQuota='1')],
        dist_name=_NRRESOURCE_GROUP_2,
        parameter='srRacParams'),
    dict(
        value=[dict(maxQuota='50', minQuota='1')],
        dist_name=_NRRESOURCE_GROUP_1,
        parameter='srRacParams'),
    dict(
        value='rsrp',
        dist_name=_NRCELL1_name,
        parameter='a2MeashoEnabledSA'),
    dict(
        value='rsrp',
        dist_name=_NRCELL3_name,
        parameter='a2MeashoEnabledSA'),
    dict(
        value=[dict(nia0='0', nia1_128='5', nia2_128='0', nia3_128='0')],
        dist_name=_NRBTS1_name,
        parameter='integrityProtPrefL'),
    dict(
        value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')],
        dist_name=_NRBTS1_name,
        parameter='cipherPrefL'),
]

TDD_CELL1_barred = [
    dict(
        value='barred',
        dist_name=_NRCELL1_name,
        parameter='cellBarred'),
]

TDD_CELL1_notBarred = [
    dict(
        value='notBarred',
        dist_name=_NRCELL1_name,
        parameter='cellBarred'),
]

Modify_maxQuato_C3B1 = [
    dict(
        value=[dict(maxQuota='100', minQuota='0')],
        dist_name=_NRRESOURCE_GROUP_2,
        parameter='srRacParams'),
]

Online_Recovery_C3B1 = [
    dict(
        value='notBarred',
        dist_name=_NRCELL2_name,
        parameter='cellBarred'),
    dict(
        value='true',
        dist_name=_NRCELL3_name,
        parameter='actAdaptiveSr'),
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
        dist_name=_NRCELL3_name,
        parameter='srPeriodicity'),
    dict(
        value='slots40',
        dist_name=_NRCELL3_name,
        parameter='preferredVoNrSrPeriod'),
    dict(
        value='slots40',
        dist_name=_NRCELL3_name,
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
        dist_name=_NRCELL3_name,
        parameter='numOfRadioResReservForEmergency'),
    dict(
        value='30',
        dist_name=_NRCELL3_name,
        parameter='numOfRadioResReservForTempUse'),
    dict(
        value='0',
        dist_name=_NRCELL3_name,
        parameter='numOfRadioResReservForPa'),
    dict(
        value=[dict(csiReportPeriodicity='slots320')],
        dist_name=_NRCELL3_name,
        parameter='periodicCsiAcquisition'),
    dict(
        value='4',
        dist_name=_NRPRIOACC_PROFILE_2,
        parameter='arpPrioLevelMpsMax'),
    dict(
        value='2',
        dist_name=_NRPRIOACC_PROFILE_2,
        parameter='arpPrioLevelMpsMin'),
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
        dist_name=_NRRESOURCE_GROUP_1,
        parameter='allowRegularSrAboveMaxQuota'),
    dict(
        value='false',
        dist_name=_NRRESOURCE_GROUP_2,
        parameter='allowRegularSrAboveMaxQuota'),
    dict(
        value='none',
        dist_name=_NRCELL1_name,
        parameter='a2MeashoEnabledSA'),
    dict(
        value='none',
        dist_name=_NRCELL3_name,
        parameter='a2MeashoEnabledSA'),
    dict(
        value=[dict(maxQuota='100', minQuota='0')],
        dist_name=_NRRESOURCE_GROUP_1,
        parameter='srRacParams'),
    dict(
        value=[dict(maxQuota='100', minQuota='0')],
        dist_name=_NRRESOURCE_GROUP_2,
        parameter='srRacParams'),
]

counter_id_C3B1_cell1 = [
    'M55910C00029',
]

counter_dic_path_C3B1_cell1 = [
    'BTS/{}/NRRESOURCEGROUP-1/NCUPNRG'.format(_NRCELL1_name),
]

counter_id_C3B1_cell1_handover = [
    'M55910C00029',
]

counter_dic_path_C3B1_cell1_handover = [
    'BTS/{}/NRRESOURCEGROUP-1/NCUPNRG'.format(_NRCELL1_name),
]

counter_id_C3B1_cell3 = [
    'M55910C00029',
]

counter_dic_path_C3B1_cell3 = [
    'BTS/{}/NRRESOURCEGROUP-2/NCUPNRG'.format(_NRCELL3_name),
]

counter_id_C3B1_cell1_cell3 = [
    'M55910C00029', 'M55910C00029'
]

counter_dic_path_C3B1_cell1_cell3 = [
    'BTS/{}/NRRESOURCEGROUP-1/NCUPNRG'.format(_NRCELL1_name),
    'BTS/{}/NRRESOURCEGROUP-2/NCUPNRG'.format(_NRCELL3_name),
]

# ------------------------CB012810-C4B1------------------------ #
Online_Modify_C4B1 = [
    dict(
        value='barred',
        dist_name=_NRCELL1_name,
        parameter='cellBarred'),
    dict(
        value='barred',
        dist_name=_NRCELL2_name,
        parameter='cellBarred'),
    dict(
        value='-43',
        dist_name=_NRCELL3_name,
        parameter='qRxLevMin'),
    dict(
        value='rsrp',
        dist_name=_NRCELL1_name,
        parameter='a2MeashoEnabledSA'),
    dict(
        value='rsrp',
        dist_name=_NRCELL3_name,
        parameter='a2MeashoEnabledSA'),
    dict(
        value='disabled',
        dist_name=_NRBTS1_name,
        parameter='actBufferBasedSCellAddition'),
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
        dist_name=_NRCELL3_name,
        parameter='actAdaptiveSr'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='increasePUSCHPrepTimeULCA'),
    dict(
        value='dlAndUl',
        dist_name=_NRCELL3_name + '/NRREL-256',
        parameter='sCellOperationalMode'),
    dict(
        value='blind',
        dist_name=_NRCELL3_name + '/NRREL-256',
        parameter='sCellAdditionMethod'),
    dict(
        value='247',
        dist_name=_NRCELL1_name,
        parameter='reqMinNumPuschPrb'),
    dict(
        value='96',
        dist_name=_NRCELL3_name,
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
        dist_name=_NRCELL3_name,
        parameter='srPeriodicity'),
    dict(
        value='slots20',
        dist_name=_NRCELL3_name,
        parameter='preferredVoNrSrPeriod'),
    dict(
        value='slots10',
        dist_name=_NRCELL3_name,
        parameter='srPeriodicityMin'),
    dict(
        value=[dict(csiReportPeriodicity='slots20')],
        dist_name=_NRCELL3_name,
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
        dist_name=_NRRESOURCE_GROUP_1,
        parameter='allowRegularSrAboveMaxQuota'),
    dict(
        value='true',
        dist_name=_NRRESOURCE_GROUP_2,
        parameter='allowRegularSrAboveMaxQuota'),
    dict(
        value=[dict(maxQuota='7', minQuota='5')],
        dist_name=_NRRESOURCE_GROUP_2,
        parameter='srRacParams'),
    dict(
        value=[dict(maxQuota='7', minQuota='5')],
        dist_name=_NRRESOURCE_GROUP_1,
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
        dist_name=_NRCELL3_name,
        parameter='numOfRadioResReservForEmergency'),
    dict(
        value='1',
        dist_name=_NRCELL3_name,
        parameter='numOfRadioResReservForPa'),
    dict(
        value='0',
        dist_name=_NRCELL3_name,
        parameter='numOfRadioResReservForTempUse'),
    dict(
        value=[dict(nia0='0', nia1_128='5', nia2_128='0', nia3_128='0')],
        dist_name=_NRBTS1_name,
        parameter='integrityProtPrefL'),
    dict(
        value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')],
        dist_name=_NRBTS1_name,
        parameter='cipherPrefL'),
]

counter_id_C4B1_cell3 = [
    'M55910C00029', 'M55165C00018',
]

counter_dic_path_C4B1_cell3 = [
    'BTS/{}/NRRESOURCEGROUP-2/NCUPNRG'.format(_NRCELL3_name),
    'BTS/{}/NRUC'.format(_NRCELL3_name),
]

counter_id_C4B1_cell1 = [
    'M55910C00029', 'M55165C00020',
]

counter_dic_path_C4B1_cell1 = [
    'BTS/{}/NRRESOURCEGROUP-1/NCUPNRG'.format(_NRCELL1_name),
    'BTS/{}/NRUC'.format(_NRCELL1_name),
]

Online_Recovery_C4B1 = [
    dict(
        value='notBarred',
        dist_name=_NRCELL1_name,
        parameter='cellBarred'),
    dict(
        value='notBarred',
        dist_name=_NRCELL2_name,
        parameter='cellBarred'),
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
        value='false',
        dist_name=_NRCELL1_name,
        parameter='increasePUSCHPrepTimeULCA'),
    dict(
        value='oneShot_Dl_Fr1',
        dist_name=_NRBTS1_name,
        parameter='actBufferBasedSCellAddition'),
    dict(
        value='1',
        dist_name=_NRCELL1_name,
        parameter='reqMinNumPuschPrb'),
    dict(
        value='96',
        dist_name=_NRCELL3_name,
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
        dist_name=_NRCELL3_name,
        parameter='srPeriodicity'),
    dict(
        value='slots40',
        dist_name=_NRCELL3_name,
        parameter='preferredVoNrSrPeriod'),
    dict(
        value='slots40',
        dist_name=_NRCELL3_name,
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
        dist_name=_NRRESOURCE_GROUP_1,
        parameter='allowRegularSrAboveMaxQuota'),
    dict(
        value='false',
        dist_name=_NRRESOURCE_GROUP_2,
        parameter='allowRegularSrAboveMaxQuota'),
    dict(
        value=[dict(maxQuota='100', minQuota='0')],
        dist_name=_NRRESOURCE_GROUP_2,
        parameter='srRacParams'),
    dict(
        value=[dict(maxQuota='100', minQuota='0')],
        dist_name=_NRRESOURCE_GROUP_1,
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
        dist_name=_NRCELL3_name,
        parameter='numOfRadioResReservForEmergency'),
    dict(
        value='0',
        dist_name=_NRCELL3_name,
        parameter='numOfRadioResReservForPa'),
    dict(
        value='30',
        dist_name=_NRCELL3_name,
        parameter='numOfRadioResReservForTempUse'),
    dict(
        value='none',
        dist_name=_NRCELL1_name,
        parameter='a2MeashoEnabledSA'),
    dict(
        value='none',
        dist_name=_NRCELL3_name,
        parameter='a2MeashoEnabledSA'),
]

Delete_recovery_C4B1 = [
    dict(
        dist_name=_NRCELL3_name + '/NRREL-256',
        parameter='sCellOperationalMode'),
    dict(
        dist_name=_NRCELL3_name + '/NRREL-256',
        parameter='sCellAdditionMethod'),
]

# ------------------------CB012810-B_IWK2_015------------------------ #
Online_Modify_BIWK2015 = [
    dict(
        value='-42',
        dist_name=_NRCELL1_name,
        parameter='qRxLevMin'),
    dict(
        value='-43',
        dist_name=_NRCELL3_name,
        parameter='qRxLevMin'),
    dict(
        value='false',
        dist_name=_NRBTS1_name,
        parameter='actScheUePooling'),
    dict(
        value='false',
        dist_name=_NRBTS1_name,
        parameter='actConnRrcPooling'),
    dict(
        value='false',
        dist_name=_NRBTS1_name,
        parameter='actSlowPrbPooling'),
    dict(
        value='false',
        dist_name=_NRBTS1_name,
        parameter='actSlowPrbPoolingFddFr1Enh'),
    dict(
        value='MixedCAMode',
        dist_name=_NRBTS1_name + '/NRDU-9999',
        parameter='flexibleCAMode'),
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
        dist_name=_NRCELL3_name,
        parameter='actAdaptiveSr'),
    dict(
        value='true',
        dist_name=_NRCELL3_name,
        parameter='actServiceAwareConfig'),
    dict(
        value='false',
        dist_name=_NRCELL3_name,
        parameter='actAdmissionCtrlSr'),
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
        dist_name=_NRCELL3_name,
        parameter='actCDrx'),
    dict(
        value='true',
        dist_name=_NRCELL3_name,
        parameter='actCDrxVoNR'),
    dict(
        value='true',
        dist_name=_NRCELL3_name,
        parameter='actVoNR'),
    dict(
        value='false',
        dist_name=_NRBTS1_name,
        parameter='actDrbDrx'),
    dict(
        value='true',
        dist_name=_NRCELL3_name,
        parameter='actVonr40msProGrant'),
    dict(
        value='slots40',
        dist_name=_NRCELL3_name,
        parameter='preferredVoNrSrPeriod'),
    dict(
        value='20ms',
        dist_name=_NRBTS1_name + '/NRDRX-4',
        parameter='drxOnDurationTimer'),
    dict(
        value='10ms',
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
    dict(
        value=[dict(nia0='0', nia1_128='5', nia2_128='0', nia3_128='0')],
        dist_name=_NRBTS1_name,
        parameter='integrityProtPrefL'),
    dict(
        value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')],
        dist_name=_NRBTS1_name,
        parameter='cipherPrefL'),

]

BIWK2015_online_false = [
    dict(
        value='false',
        dist_name=_NRCELL3_name,
        parameter='actVonr40msProGrant'),
]

Online_Recovery_BIWK2015 = [
    dict(
        value='notBarred',
        dist_name=_NRCELL2_name,
        parameter='cellBarred'),
    dict(
        value='true',
        dist_name=_NRBTS1_name,
        parameter='actScheUePooling'),
    dict(
        value='true',
        dist_name=_NRBTS1_name,
        parameter='actConnRrcPooling'),
    dict(
        value='true',
        dist_name=_NRBTS1_name,
        parameter='actSlowPrbPooling'),
    dict(
        value='true',
        dist_name=_NRBTS1_name,
        parameter='actSlowPrbPoolingFddFr1Enh'),
    dict(
        value='NumberCellAmount',
        dist_name=_NRBTS1_name + '/NRDU-9999',
        parameter='flexibleCAMode'),
    dict(
        value='true',
        dist_name=_NRCELL3_name,
        parameter='actAdmissionCtrlSr'),
    dict(
        value='slots80',
        dist_name=_NRCELL3_name,
        parameter='preferredVoNrSrPeriod'),
    dict(
        value='10ms',
        dist_name=_NRBTS1_name + '/NRDRX-4',
        parameter='drxOnDurationTimer'),
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
        dist_name=_NRCELL3_name,
        parameter='srPeriodicity'),
]
# ------------------------CB012810-E#IWK2_02------------------------ #
Online_Modify_IWK2_002 = [
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actProactGrantsUlLteOnlyMode'),
    dict(
        value='allUes',
        dist_name=_NRCELL1_name,
        parameter='actProactUlSchedulingEnh'),
    dict(
        value='allUes',
        dist_name=_NRCELL1_name,
        parameter='actDrbPriorityPug'),
    dict(
        value=_PUG2,
        dist_name=_QCIDRB7_name,
        parameter='nrDrbPrioPugDN'),
    dict(
        value='Locked',
        dist_name=_SERVEDAMF_1,
        parameter='administrativeState'),
    dict(
        value='5min',
        dist_name=_NRPMRNL,
        parameter='miNrUlHarq'),
]

Online_Modify_IWK2_002_cloud = [
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actProactGrantsUlLteOnlyMode'),
    dict(
        value='allUes',
        dist_name=_NRCELL1_name,
        parameter='actProactUlSchedulingEnh'),
    dict(
        value='allUes',
        dist_name=_NRCELL1_name,
        parameter='actDrbPriorityPug'),
    dict(
        value=_PUG2,
        dist_name=_QCIDRB7_name,
        parameter='nrDrbPrioPugDN'),
    dict(
        value='20',
        dist_name=_PUG2,
        parameter='drbPriorityPugPeriodicity'),
    dict(
        value='Locked',
        dist_name=_SERVEDAMF_1,
        parameter='administrativeState'),
    dict(
        value='Locked',
        dist_name=_SERVEDAMF_2,
        parameter='administrativeState'),
    dict(
        value='Locked',
        dist_name=_SERVEDAMF_3,
        parameter='administrativeState'),
    dict(
        value='5min',
        dist_name=_NRPMRNL,
        parameter='miNrUlHarq'),
    dict(
        value='0',
        dist_name=_NRCELL1_name,
        parameter='rloSinrThreshold'),
]

Online_Modify_IWK2_002_1 = [
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        parameter='actProactGrantsUlLteOnlyMode'),
]

Online_Modify_IWK2_002_recover = [
    dict(
        value='Unlocked',
        dist_name=_SERVEDAMF_1,
        parameter='administrativeState'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actProactGrantsUlLteOnlyMode'),
]

Online_Modify_IWK2_002_cloud_recover = [
    dict(
        value='Unlocked',
        dist_name=_SERVEDAMF_1,
        parameter='administrativeState'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actProactGrantsUlLteOnlyMode'),
]

counter_id_drbpug = [
    'M55302C15112', 'M55302C15113'
]

counter_dic_path_drbpug = [
    'BTS/'+_NRCELL1_name+'/NULHQ', 'BTS/'+_NRCELL1_name+'/NULHQ'
]
