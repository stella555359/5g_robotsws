from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'liujia'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com'
__email__ = 'jia-rebecca.liu@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id_1 = str(tl.gnbs[0].instance_id)
_global_bts_id = str(tl.gnbs[0].global_bts_id)
_MRBTS1_name = 'MRBTS-'+_global_bts_id
_NRBTS1_name = _MRBTS1_name+'/NRBTS-'+_gnb_id_1
_NRBTS1CELL1_name = _NRBTS1_name+'/NRCELL-1'
_NRBTS1CELL2_name = _NRBTS1_name+'/NRCELL-2'
_NRBTS1CELL3_name = _NRBTS1_name+'/NRCELL-3'
_SERVEDAMF_1 = _NRBTS1_name+'/SERVEDAMF-1'
_SERVEDAMF_2 = _NRBTS1_name+'/SERVEDAMF-2'
_SERVEDAMF_3 = _NRBTS1_name+'/SERVEDAMF-3'
_NRPMRNL = _NRBTS1_name+'/NRPMRNL-1'
_NRBTS1SCTP_1 = _NRBTS1_name+'/NRSCTP-1'
_NRBTS1SYNC_1 = _MRBTS1_name+'/MNL-1/MNLENT-1/SYNC-1'
_NRBTS1_NTP_1 = _NRBTS1SYNC_1+'/CLOCK-1/NTP-1'
_PDCP_2 = _NRBTS1_name + '/NRDRB_PDCP-2'
_RLC_AM_2 = _NRBTS1_name + '/NRDRB_RLC_AM-2'

_enb_id_1 = str(tl.enbs[0].instance_id)
_ENBTS1_name = 'MRBTS-'+_enb_id_1
_LNBTS1_name = _ENBTS1_name+'/LNBTS-'+_enb_id_1
_LNBTS1_CLOCK1 = _ENBTS1_name+'/MNL-1/MNLENT-1/SYNC-1/CLOCK-1'


PATH_TO_SCF = ''
# ----------------------swconfig-flag----------------- #
swconfig_12544 = [
    '0x58057A = 4',
    '0x58057c = 1073741824',
    '0x4F0289 = 0x600',
]
# ----------------------counter------------------- #
counter_id_C001_VM = [
    'M55119C02502', 'M55117C04502', 'M55331C00005',
    'M55119C01501', 'M55117C03001', 'M55331C00001'
]

counter_dic_path_C001_VM = [
    'BTS/{}/NNGCB'.format(_NRBTS1_name),
    'BTS/{}/NRDU-9999/NF1CD'.format(_NRBTS1_name),
    'BTS/{}/NRCELL-3/NRPAG'.format(_NRBTS1_name),
    'BTS/{}/NNGCB'.format(_NRBTS1_name),
    'BTS/{}/NRDU-9999/NF1CD'.format(_NRBTS1_name),
    'BTS/{}/NRCELL-3/NRPAG'.format(_NRBTS1_name),
]

counter_id_D002_VM = [
    'M55117C04502', 'M55117C04503', 'M55331C00005',
    'M55331C00007', 'M55117C03001', 'M55331C00001',
]

counter_dic_path_D002_VM = [
    'BTS/{}/NRDU-9999/NF1CD'.format(_NRBTS1_name),
    'BTS/{}/NRDU-9999/NF1CD'.format(_NRBTS1_name),
    'BTS/{}/NRCELL-3/NRPAG'.format(_NRBTS1_name),
    'BTS/{}/NRCELL-3/NRPAG'.format(_NRBTS1_name),
    'BTS/{}/NRDU-9999/NF1CD'.format(_NRBTS1_name),
    'BTS/{}/NRCELL-3/NRPAG'.format(_NRBTS1_name),
]

counter_id_C003_VM = [
    'M55119C02502', 'M55117C04502', 'M55331C00005',
    'M55119C01501', 'M55117C03001', 'M55331C00001',
]

counter_dic_path_C003_VM = [
    'BTS/{}/NNGCB'.format(_NRBTS1_name),
    'BTS/{}/NRDU-9999/NF1CD'.format(_NRBTS1_name),
    'BTS/{}/NRPAG'.format(_NRBTS1CELL3_name),
    'BTS/{}/NNGCB'.format(_NRBTS1_name),
    'BTS/{}/NRDU-9999/NF1CD'.format(_NRBTS1_name),
    'BTS/{}/NRPAG'.format(_NRBTS1CELL3_name),
]

counter_id_ABC005_VM = [
    'M55331C00007', 'M55331C00004'
]

counter_dic_path_ABC005_VM = [
    'BTS/{}/NRPAG'.format(_NRBTS1CELL3_name),
    'BTS/{}/NRPAG'.format(_NRBTS1CELL3_name),
]

counter_id_D001_VM = [
    'M55117C04502', 'M55117C04503', 'M55331C00005', 'M55331C00007',
    'M55117C03001', 'M55331C00001',
]

counter_dic_path_D001_VM = [
    'BTS/{}/NRDU-9999/NF1CD'.format(_NRBTS1_name),
    'BTS/{}/NRDU-9999/NF1CD'.format(_NRBTS1_name),
    'BTS/{}/NRPAG'.format(_NRBTS1CELL3_name),
    'BTS/{}/NRPAG'.format(_NRBTS1CELL3_name),
    'BTS/{}/NRDU-9999/NF1CD'.format(_NRBTS1_name),
    'BTS/{}/NRPAG'.format(_NRBTS1CELL3_name),
]
# ----------------prepare TL to TDD only--------------- #
delete_for_FDD = [
    dict(dist_name=_MRBTS1_name + '/EQM-1/APEQM-1/RMOD-1'),
    dict(dist_name=_MRBTS1_name + '/EQM-1/HWTOP-1/CABLINK-3'),
    dict(dist_name=_MRBTS1_name + '/EQM-1/HWTOP-1/CABLINK-5'),
    dict(dist_name=_MRBTS1_name + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1'),
    dict(dist_name=_MRBTS1_name + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1'),
    dict(dist_name=_MRBTS1_name + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2'),
    dict(dist_name=_MRBTS1_name + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-1'),
    dict(dist_name=_MRBTS1_name + '/MNL-1/MNLENT-1/SYNC-2'),
    dict(dist_name=_MRBTS1_name + '/MNL-1/MNLENT-1/SYNC-2/CLOCK-1'),
    dict(dist_name=_MRBTS1_name + '/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1'),
    dict(dist_name=_MRBTS1_name + '/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1'),
    dict(dist_name=_MRBTS1_name + '/MNL-1/MNLENT-1/SYNC-2/TIME-1'),
    dict(dist_name=_NRBTS1CELL1_name),
    dict(dist_name=_NRBTS1CELL1_name + '/NRHOIF-1'),
    dict(dist_name=_NRBTS1CELL1_name + '/NRPLMNSET_NSA-1'),
    dict(dist_name=_NRBTS1CELL1_name + '/NRPLMNSET_SA-1'),
    dict(dist_name=_NRBTS1CELL1_name + '/NRREDRT-0'),
    dict(dist_name=_NRBTS1CELL1_name + '/NRREL-256'),
    dict(dist_name=_NRBTS1CELL1_name + '/NRULMUMIMO-0'),
    dict(dist_name=_NRBTS1CELL2_name),
    dict(dist_name=_NRBTS1CELL2_name + '/NRHOIF-1'),
    dict(dist_name=_NRBTS1CELL2_name + '/NRPLMNSET_NSA-1'),
    dict(dist_name=_NRBTS1CELL2_name + '/NRPLMNSET_SA-1'),
    dict(dist_name=_NRBTS1CELL2_name + '/NRREDRT-0'),
    dict(dist_name=_NRBTS1CELL2_name + '/NRREL-256'),
    dict(dist_name=_NRBTS1CELL2_name + '/NRULMUMIMO-0'),
    dict(dist_name=_NRBTS1_name + '/NRCELLGRP-3000'),
    dict(dist_name=_NRBTS1_name + '/NRCELLGRP-3010'),
    dict(dist_name=_NRBTS1CELL3_name + '/NRREL-256'),
    dict(dist_name=_NRBTS1_name + '/NRPGRP-1'),
    dict(dist_name=_NRBTS1_name + '/NRPGRP-2'),

    dict(dist_name=_NRBTS1_name, list_name='actVoiceFallbackDuringHOPrep'),
    dict(dist_name=_NRBTS1_name + '/NRDU-9999', list_name='refNrCellGroup'),

    dict(dist_name=_NRBTS1_name, p_name='powerSavingAvoidanceForPACalls'),
]

modify_for_FDD = [
    dict(value='false', dist_name=_NRBTS1_name, p_name='actTddCsiRsOpt'),
    dict(value='disabled', dist_name=_NRBTS1_name, p_name='actFlexibleBISlotDurationMode'),
    dict(value='false', dist_name=_NRBTS1_name, p_name='actInterFreqIntraGnbMobilityNSA'),
    dict(value='false', dist_name=_NRBTS1_name, p_name='actIntraFreqIntraGnbMobilityNSA'),
    dict(value='false', dist_name=_NRBTS1_name, p_name='actInterFreqInterGnbMobilityNSA'),
    dict(value='false', dist_name=_NRBTS1_name, p_name='actNormVCFallback'),
    dict(value='false', dist_name=_NRBTS1_name, p_name='actNormVCFallbackEnh'),
    dict(value='false', dist_name=_NRBTS1_name, p_name='actTddCsiImRm'),
    dict(value='false', dist_name=_NRBTS1_name, p_name='actNrLBPowerSaving'),
    dict(value='false', dist_name=_NRBTS1_name, p_name='actNrLBmMimoRTXPowerSaving'),
    dict(value='disabled', dist_name=_NRBTS1_name, p_name='actCoordinated4g5gPowerSaving'),
    dict(value='false', dist_name=_NRBTS1_name, p_name='actNrExtCellSOMethod'),
    dict(value='false', dist_name=_NRBTS1_name, p_name='actNrMixedSOMethod'),
    dict(value='false', dist_name=_NRBTS1_name, p_name='actNrLBRTXPowerSaving'),
    dict(value='false', dist_name=_NRBTS1_name, p_name='actSSBBoostInmMIMOMuting'),
    dict(value='false', dist_name=_MRBTS1_name + '/MNL-1/MNLENT-1/SYNC-1', p_name='actEcpriMasterClock'),
    dict(value='false', dist_name=_NRBTS1_name, p_name='actNsaUeBasedInterFreqAnrNr'),
    dict(value='none', dist_name=_NRBTS1_name, p_name='actHigherPrioFreqHo'),
    dict(value='none', dist_name=_NRBTS1_name, p_name='actA1HoPrefNRLayer'),

]

addlist_for_FDD = [
    dict(
        dist_name=_NRBTS1_name + '/NRDU-9999',
        list_name='refNrCellGroup',
        elements=['3020']),
]

# ----------------A_101--------------- #
Disable_output_sync = [
    dict(
        value='Disabled',
        dist_name=_LNBTS1_CLOCK1,
        parameter='outputConfiguration1PpsBackplane'),
    dict(
        value='Disabled',
        dist_name=_LNBTS1_CLOCK1,
        parameter='outputConfiguration1Pps'),
    dict(
        value='Disabled',
        dist_name=_LNBTS1_CLOCK1,
        parameter='outputConfiguration2M048'),
]

Recovery_output_sync = [
    dict(
        value='EnabledWithoutBtsInputReference',
        dist_name=_LNBTS1_CLOCK1,
        parameter='outputConfiguration1PpsBackplane'),
    dict(
        value='EnabledWithoutBtsInputReference',
        dist_name=_LNBTS1_CLOCK1,
        parameter='outputConfiguration1Pps'),
    dict(
        value='EnabledWithoutBtsInputReference',
        dist_name=_LNBTS1_CLOCK1,
        parameter='outputConfiguration2M048'),
]

Delete_NTP_Mo_VM = [
    {'dist_name': _NRBTS1_NTP_1}
]

Online_modify_ABC_005_part2_VM = [
    dict(
        value='None',
        dist_name=_NRBTS1CELL3_name,
        parameter='actEdrx'),
]

Online_modify_ABC_005_part3_VM = [
    dict(
        value='Idle + Inactive',
        dist_name=_NRBTS1CELL3_name,
        parameter='actEdrx'),
]

# ----------------C_001--------------- #
Modify_C_001_VM = [
    dict(
        value='Unlocked',
        dist_name=_SERVEDAMF_1,
        parameter='administrativeState'),
    dict(
        value='Locked',
        dist_name=_SERVEDAMF_2,
        parameter='administrativeState'),
    dict(
        value='3',
        dist_name=_NRBTS1CELL3_name,
        parameter='maxNumPagingRecords'),
    dict(value=[dict(sctpWaitTimeInitSeqRetry='5')],
         dist_name=_NRBTS1SCTP_1, parameter='sctpProfile'),
    dict(
        value='no barring',
        dist_name=_NRBTS1CELL3_name,
        parameter='cellBarredRedCap'),
    # dict(
    #     value='Idle + Inactive',
    #     dist_name=_NRBTS1CELL1_name,
    #     parameter='actEdrx'),
    dict(
        value='None',
        dist_name=_NRBTS1CELL3_name,
        parameter='actEdrx'),
    dict(
        value='20',
        dist_name=_NRBTS1_name,
        parameter='drbInactivityTimerSA'),
    dict(
        value='20',
        dist_name=_NRBTS1_name,
        parameter='drbInactivityTimerSARedCap'),
    dict(
        value='20',
        dist_name=_NRBTS1_name,
        parameter='drbRrcInactInactivityTimerSARedCap'),
    dict(
        value='20',
        dist_name=_NRBTS1_name,
        parameter='srbInactivityTimerSARedCap'),
    dict(
        value='20',
        dist_name=_NRBTS1_name,
        parameter='srbInactivityTimerSA'),
    dict(
        value='20',
        dist_name=_NRBTS1_name,
        parameter='drbRrcInactInactivityTimerSA'),
    dict(
        value='false',
        dist_name=_NRBTS1_name,
        parameter='actRrcInactStateRedCap'),
    dict(
        value=[dict(nia0='0', nia1_128='5', nia2_128='0', nia3_128='0')],
        dist_name=_NRBTS1_name,
        parameter='integrityProtPrefL'),
    dict(
        value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')],
        dist_name=_NRBTS1_name,
        parameter='cipherPrefL'),
]

Online_actEdrx_modify_C001_VM = [
    # dict(
    #     value='None',
    #     dist_name=_NRBTS1CELL1_name,
    #     parameter='actEdrx'),
    dict(
        value='Idle',
        dist_name=_NRBTS1CELL3_name,
        parameter='actEdrx'),
]

# ----------------C_003--------------- #
Modify_D_002_VM = [
    dict(
        value='Unlocked',
        dist_name=_SERVEDAMF_1,
        parameter='administrativeState'),
    dict(
        value='Locked',
        dist_name=_SERVEDAMF_2,
        parameter='administrativeState'),
    dict(
        value='3',
        dist_name=_NRBTS1CELL3_name,
        parameter='maxNumPagingRecords'),
    dict(value=[dict(sctpWaitTimeInitSeqRetry='5')],
         dist_name=_NRBTS1SCTP_1, parameter='sctpProfile'),
    dict(
        value='no barring',
        dist_name=_NRBTS1CELL3_name,
        parameter='cellBarredRedCap'),
    dict(
        value='true',
        dist_name=_NRBTS1CELL3_name,
        parameter='actPriorityAccess'),
    dict(
        value='Idle + Inactive',
        dist_name=_NRBTS1CELL3_name,
        parameter='actEdrx'),
    # dict(
    #     value='Idle',
    #     dist_name=_NRBTS1CELL1_name,
    #     parameter='actEdrx'),
    dict(
        value='true',
        dist_name=_NRBTS1_name,
        parameter='actRrcInactStateRedCap'),
    dict(
        value='20',
        dist_name=_NRBTS1_name,
        parameter='drbInactivityTimerSA'),
    dict(
        value='20',
        dist_name=_NRBTS1_name,
        parameter='drbInactivityTimerSARedCap'),
    dict(
        value='20',
        dist_name=_NRBTS1_name,
        parameter='drbRrcInactInactivityTimerSARedCap'),
    dict(
        value='20',
        dist_name=_NRBTS1_name,
        parameter='srbInactivityTimerSARedCap'),
    dict(
        value='20',
        dist_name=_NRBTS1_name,
        parameter='srbInactivityTimerSA'),
    dict(
        value='20',
        dist_name=_NRBTS1_name,
        parameter='drbRrcInactInactivityTimerSA'),
    dict(
        value='10',
        dist_name=_NRBTS1_name,
        parameter='maxUeRrcInactTime'),
    dict(value=[dict(nea1_128='0', nea2_128='0', nea3_128='0')],
         dist_name=_NRBTS1_name, parameter='cipherPrefL'),
    dict(value=[dict(nia1_128='9', nia2_128='0', nia3_128='0')],
         dist_name=_NRBTS1_name, parameter='integrityProtPrefL'),
]

Delete_Para_D_002_VM = [
    dict(
        dist_name=_NRBTS1_name,
        parameter='ranEdrxPagingCycle'),
]

Delete_Mo_D_002_VM = [
    {'dist_name': _NRBTS1_NTP_1}
]

online_recovery_D002_VM = [
    dict(
        value='v256',
        dist_name=_NRBTS1_name,
        parameter='ranEdrxPagingCycle'),
]

Online_actEdrx_modify_C003_VM = [
    dict(
        value='Idle',
        dist_name=_NRBTS1CELL3_name,
        parameter='actEdrx'),
    # dict(
    #     value='Idle + Inactive',
    #     dist_name=_NRBTS1CELL1_name,
    #     parameter='actEdrx'),
]

Modify_C_003_VM = [
    dict(
        value='Unlocked',
        dist_name=_SERVEDAMF_1,
        parameter='administrativeState'),
    dict(
        value='Locked',
        dist_name=_SERVEDAMF_2,
        parameter='administrativeState'),
    dict(
        value='3',
        dist_name=_NRBTS1CELL3_name,
        parameter='maxNumPagingRecords'),
    dict(value=[dict(sctpWaitTimeInitSeqRetry='5')],
         dist_name=_NRBTS1SCTP_1, parameter='sctpProfile'),
    dict(
        value='Idle + Inactive',
        dist_name=_NRBTS1CELL3_name,
        parameter='actEdrx'),
    dict(
        value='no barring',
        dist_name=_NRBTS1CELL3_name,
        parameter='cellBarredRedCap'),
    dict(
        value='1',
        dist_name=_NRBTS1_name,
        parameter='maxUeRrcInactTime'),
    dict(
        value='20',
        dist_name=_NRBTS1_name,
        parameter='drbInactivityTimerSA'),
    dict(
        value='20',
        dist_name=_NRBTS1_name,
        parameter='drbInactivityTimerSARedCap'),
    dict(
        value='20',
        dist_name=_NRBTS1_name,
        parameter='drbRrcInactInactivityTimerSARedCap'),
    dict(
        value='20',
        dist_name=_NRBTS1_name,
        parameter='srbInactivityTimerSARedCap'),
    dict(
        value='20',
        dist_name=_NRBTS1_name,
        parameter='srbInactivityTimerSA'),
    dict(
        value='20',
        dist_name=_NRBTS1_name,
        parameter='drbRrcInactInactivityTimerSA'),
    dict(value=[dict(nea1_128='0', nea2_128='0', nea3_128='0')],
         dist_name=_NRBTS1_name, parameter='cipherPrefL'),
    dict(value=[dict(nia1_128='9', nia2_128='0', nia3_128='0')],
         dist_name=_NRBTS1_name, parameter='integrityProtPrefL'),
]

Recovery_C_003_VM = [
    dict(
        value='10',
        dist_name=_NRBTS1_name,
        parameter='maxUeRrcInactTime'),
    dict(value=[dict(sctpWaitTimeInitSeqRetry='239')],
         dist_name=_NRBTS1SCTP_1, parameter='sctpProfile'),
    dict(
        value='8',
        dist_name=_NRBTS1CELL3_name,
        parameter='maxNumPagingRecords'),
]

# ----------------D_001--------------- #
Modify_D_001_VM = [
    dict(
        value='Unlocked',
        dist_name=_SERVEDAMF_1,
        parameter='administrativeState'),
    dict(
        value='Locked',
        dist_name=_SERVEDAMF_2,
        parameter='administrativeState'),
    dict(
        value='3',
        dist_name=_NRBTS1CELL3_name,
        parameter='maxNumPagingRecords'),
    dict(value=[dict(sctpWaitTimeInitSeqRetry='5')],
         dist_name=_NRBTS1SCTP_1, parameter='sctpProfile'),
    dict(
        value='Idle + Inactive',
        dist_name=_NRBTS1CELL3_name,
        parameter='actEdrx'),
    dict(
        value='true',
        dist_name=_NRBTS1_name,
        parameter='actRrcInactStateRedCap'),
    dict(
        value='20',
        dist_name=_NRBTS1_name,
        parameter='drbInactivityTimerSA'),
    dict(
        value='20',
        dist_name=_NRBTS1_name,
        parameter='drbInactivityTimerSARedCap'),
    dict(
        value='20',
        dist_name=_NRBTS1_name,
        parameter='drbRrcInactInactivityTimerSA'),
    dict(
        value='20',
        dist_name=_NRBTS1_name,
        parameter='drbRrcInactInactivityTimerSARedCap'),
    dict(
        value='20',
        dist_name=_NRBTS1_name,
        parameter='srbInactivityTimerSA'),
    dict(
        value='20',
        dist_name=_NRBTS1_name,
        parameter='srbInactivityTimerSARedCap'),
    dict(
        value='true',
        dist_name=_NRBTS1_name,
        parameter='eDRXBasedDiscardPagingRec'),
    dict(
        value='10',
        dist_name=_NRBTS1_name,
        parameter='tEdrxRanPagingGuard'),
    dict(
        value='v512',
        dist_name=_NRBTS1_name,
        parameter='ranEdrxPagingCycle'),
    dict(
        value='30min',
        dist_name=_NRBTS1_name,
        parameter='t380'),
    dict(value=[dict(nea1_128='0', nea2_128='0', nea3_128='0')],
         dist_name=_NRBTS1_name, parameter='cipherPrefL'),
    dict(value=[dict(nia1_128='9', nia2_128='0', nia3_128='0')],
         dist_name=_NRBTS1_name, parameter='integrityProtPrefL'),
]

Online_actEdrx_modify_D001_VM = [
    dict(
        value='Idle + Inactive',
        dist_name=_NRBTS1CELL3_name,
        parameter='actEdrx'),
    # dict(
    #     value='Idle + Inactive',
    #     dist_name=_NRBTS1CELL1_name,
    #     parameter='actEdrx'),
]

Online_Modify_A_B_002_p1_VM = [
    dict(
        value='None',
        dist_name=_NRBTS1CELL3_name,
        parameter='actEdrx'),
    dict(
        value='LoosePhaseAndTimeSync',
        dist_name=_NRBTS1SYNC_1,
        parameter='btsSyncMode'),
    dict(
        value='1',
        dist_name=_NRBTS1_name,
        parameter='maxUeRrcInactTime'),
]

Online_Delete_A_B_002_p1_VM = [
    dict(
        dist_name=_NRBTS1SYNC_1,
        parameter='manualFrameTimingAdjustment'),
]

Online_Modify_A_B_002_p2_VM = [
    # dict(
    #     value='Idle',
    #     dist_name=_NRBTS1CELL1_name,
    #     parameter='actEdrx'),
    dict(
        value='Idle + Inactive',
        dist_name=_NRBTS1CELL3_name,
        parameter='actEdrx'),
    dict(
        value='500',
        dist_name=_NRBTS1_name,
        parameter='maxBtsTimeError'),
    # dict(
    #     value='barred',
    #     dist_name=_NRBTS2CELL1_name,
    #     parameter='cellBarred'),
    # dict(
    #     value='notBarred',
    #     dist_name=_NRBTS2CELL2_name,
    #     parameter='cellBarred'),
]

Online_Moidfy_A_B_002_Recovery_VM = [
    dict(
        value='10',
        dist_name=_NRBTS1_name,
        parameter='maxUeRrcInactTime'),
]

Online_ADD_A_B_002_Recovery_VM = [
    dict(
        value='0',
        dist_name=_NRBTS1SYNC_1,
        parameter='manualFrameTimingAdjustment'),
]

# ---------------9384_A--------------- #
counter_id_9384_12bit = [
    'M55166C00011',
    'M55166C00012',
    'M55138C00057',
    'M55166C00014',
    'M55166C00015',
    'M55166C00016',
    'M55138C00056',
    'M55166C00013'
]

counter_dic_path_9384_12bit = [
    'BTS/' + _NRBTS1_name + '/NRCELL-3/NRCCD',
    'BTS/' + _NRBTS1_name + '/NRCELL-3/NRCCD',
    'BTS/' + _NRBTS1_name + '/NRCELL-3/RSACU',
    'BTS/' + _NRBTS1_name + '/NRCELL-3/NRCCD',
    'BTS/' + _NRBTS1_name + '/NRCELL-3/NRCCD',
    'BTS/' + _NRBTS1_name + '/NRCELL-3/NRCCD',
    'BTS/' + _NRBTS1_name + '/NRCELL-3/RSACU',
    'BTS/' + _NRBTS1_name + '/NRCELL-3/NRCCD'
]

Online_Modify_9384_12bit = [
    dict(value='len12bits', dist_name=_PDCP_2, parameter='pdcpSNLengthRedCap'),
    dict(value='rlcAm12bitSN', dist_name=_RLC_AM_2, parameter='rlcAMDrbSNLengthRedCap'),
    dict(value='viaRRCSetup', dist_name=_NRBTS1_name, parameter='rrcReestabTypeSA'),
    dict(value='false', dist_name=_NRBTS1_name, parameter='actInterGnbRREPreparedCell'),
    dict(
        value='20',
        dist_name=_NRBTS1_name,
        parameter='drbInactivityTimerSA'),
    dict(
        value='20',
        dist_name=_NRBTS1_name,
        parameter='drbInactivityTimerSARedCap'),
    dict(
        value='20',
        dist_name=_NRBTS1_name,
        parameter='drbRrcInactInactivityTimerSARedCap'),
    dict(
        value='20',
        dist_name=_NRBTS1_name,
        parameter='srbInactivityTimerSARedCap'),
    dict(
        value='20',
        dist_name=_NRBTS1_name,
        parameter='srbInactivityTimerSA'),
    dict(
        value='20',
        dist_name=_NRBTS1_name,
        parameter='drbRrcInactInactivityTimerSA'),
    dict(
        value='false',
        dist_name=_NRBTS1_name,
        parameter='actRrcInactStateRedCap'),
    dict(value=[dict(nea1_128='0', nea2_128='0', nea3_128='0')],
         dist_name=_NRBTS1_name, parameter='cipherPrefL'),
    dict(value=[dict(nia1_128='9', nia2_128='0', nia3_128='0')],
         dist_name=_NRBTS1_name, parameter='integrityProtPrefL'),
    dict(
        value='5min',
        dist_name=_NRBTS1_name + '/NRPMRNL-1',
        parameter='miNrCCD'),
    dict(
        value='5min',
        dist_name=_NRBTS1_name + '/NRPMRNL-1',
        parameter='miNrRSACU'),
]

Online_Modify_9384_ulgrant = [
    dict(value='slots40', dist_name=_NRBTS1CELL3_name, parameter='srPeriodicityMin')
]

Online_Modify_9384_failure = [
    dict(value='0', dist_name=_NRBTS1CELL3_name, parameter='maxNumOfRrcSARedCap')
]

counter_dic_path_failure_scenario = [
    'BTS/' + _NRBTS1_name + '/NRCELL-3/NRCCD',
    'BTS/' + _NRBTS1_name + '/NRCELL-3/NRCCD'
]

counter_id_failure_scenario = [
    'M55166C00011',
    'M55166C00015'
]
