from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'liujia'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com'
__email__ = 'jia-rebecca.liu@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id_1 = str(tl.gnbs[0].instance_id)
_MRBTS1_name = 'MRBTS-'+_gnb_id_1
_NRBTS1_name = _MRBTS1_name+'/NRBTS-'+_gnb_id_1
_NRBTS1CELL1_name = _NRBTS1_name+'/NRCELL-1'
_NRBTS1CELL2_name = _NRBTS1_name+'/NRCELL-2'
_NRBTS1CELL3_name = _NRBTS1_name+'/NRCELL-3'
_GNB1SERVEDAMF_1 = _NRBTS1_name+'/SERVEDAMF-1'
_GNB1SERVEDAMF_2 = _NRBTS1_name+'/SERVEDAMF-2'

_gnb_id_2 = str(tl.gnbs[1].instance_id)
_MRBTS2_name = 'MRBTS-'+_gnb_id_2
_NRBTS2_name = _MRBTS2_name+'/NRBTS-'+_gnb_id_2
_NRBTS2CELL1_name = _NRBTS2_name+'/NRCELL-1'
_NRBTS2CELL2_name = _NRBTS2_name+'/NRCELL-2'
_SERVEDAMF_1 = _NRBTS2_name+'/SERVEDAMF-1'
_SERVEDAMF_2 = _NRBTS2_name+'/SERVEDAMF-2'
_SERVEDAMF_3 = _NRBTS2_name+'/SERVEDAMF-3'
_NRPMRNL = _NRBTS2_name+'/NRPMRNL-1'
_NRBTS2SCTP_1 = _NRBTS2_name+'/NRSCTP-1'
_NRBTS2SYNC_1 = _MRBTS2_name+'/MNL-1/MNLENT-1/SYNC-1'
_NRBTS2_NTP_1 = _MRBTS2_name+'/MNL-1'+'/MNLENT-1'+'/SYNC-1'+'/CLOCK-1'+'/NTP-1'
# _NRBTS2_NTP_1 = _MRBTS2_name+'/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/NTP-1'

_gnb_id_3 = str(tl.gnbs[2].instance_id)
_MRBTS3_name = 'MRBTS-'+_gnb_id_3
_NRBTS3_name = _MRBTS3_name+'/NRBTS-'+_gnb_id_3
_NRBTS3_CLOCK1 = _MRBTS3_name+'/MNL-1/MNLENT-1/SYNC-1/CLOCK-1'


PATH_TO_SCF = ''
# ----------------------swconfig-flag----------------- #
swconfig_12544 = [
    '0x58057A = 4',
    '0x58057c = 1073741824',
    # '0x5801be = 0x3',
    '0x4F0289 = 0x600',
]
# ----------------------counter------------------- #
counter_id_C001 = [
    'M55119C02502', 'M55117C04502', 'M55331C00005',
    'M55119C01501', 'M55117C03001', 'M55331C00001'
]

counter_dic_path_C001 = [
    'BTS/{}/NNGCB'.format(_NRBTS2_name),
    'BTS/{}/NRDU-1/NF1CD'.format(_NRBTS2_name),
    'BTS/{}/NRCELL-1/NRPAG'.format(_NRBTS2_name),
    'BTS/{}/NNGCB'.format(_NRBTS2_name),
    'BTS/{}/NRDU-1/NF1CD'.format(_NRBTS2_name),
    'BTS/{}/NRCELL-1/NRPAG'.format(_NRBTS2_name),
]

counter_id_C007 = [
    'M55119C01501', 'M55119C02501', 'M55119C02502', 'M55117C04502',
    'M55117C03001', 'M55117C04501', 'M55331C00001', 'M55331C00002',
    'M55331C00003', 'M55331C00005', 'M55331C00006', 'M55331C00001',
    'M55331C00002', 'M55331C00003', 'M55331C00005', 'M55331C00006',
]

counter_dic_path_C007 = [
    'BTS/{}/NNGCB'.format(_NRBTS2_name),
    'BTS/{}/NNGCB'.format(_NRBTS2_name),
    'BTS/{}/NNGCB'.format(_NRBTS2_name),
    'BTS/{}/NRDU-1/NF1CD'.format(_NRBTS2_name),
    'BTS/{}/NRDU-1/NF1CD'.format(_NRBTS2_name),
    'BTS/{}/NRDU-1/NF1CD'.format(_NRBTS2_name),
    'BTS/{}/NRPAG'.format(_NRBTS2CELL1_name),
    'BTS/{}/NRPAG'.format(_NRBTS2CELL1_name),
    'BTS/{}/NRPAG'.format(_NRBTS2CELL1_name),
    'BTS/{}/NRPAG'.format(_NRBTS2CELL1_name),
    'BTS/{}/NRPAG'.format(_NRBTS2CELL1_name),
    'BTS/{}/NRPAG'.format(_NRBTS2CELL2_name),
    'BTS/{}/NRPAG'.format(_NRBTS2CELL2_name),
    'BTS/{}/NRPAG'.format(_NRBTS2CELL2_name),
    'BTS/{}/NRPAG'.format(_NRBTS2CELL2_name),
    'BTS/{}/NRPAG'.format(_NRBTS2CELL2_name),
]

counter_id_D002 = [
    'M55117C04502', 'M55117C04503', 'M55331C00005',
    'M55331C00007', 'M55117C03001', 'M55331C00001',
]

counter_dic_path_D002 = [
    'BTS/{}/NRDU-1/NF1CD'.format(_NRBTS2_name),
    'BTS/{}/NRDU-1/NF1CD'.format(_NRBTS2_name),
    'BTS/{}/NRCELL-1/NRPAG'.format(_NRBTS2_name),
    'BTS/{}/NRCELL-1/NRPAG'.format(_NRBTS2_name),
    'BTS/{}/NRDU-1/NF1CD'.format(_NRBTS2_name),
    'BTS/{}/NRCELL-1/NRPAG'.format(_NRBTS2_name),
]

counter_id_eda = [
    'M55125C05002', 'M55125C05003'
]

counter_dic_path_eda = [
    'BTS/{}/NNGCC'.format(_NRBTS2CELL1_name),
    'BTS/{}/NNGCC'.format(_NRBTS2CELL1_name),
]

counter_id_C003 = [
    'M55119C02502', 'M55117C04502', 'M55331C00005',
    'M55119C01501', 'M55117C03001', 'M55331C00001', 'M55331C00005',
]

counter_dic_path_C003 = [
    'BTS/{}/NNGCB'.format(_NRBTS2_name),
    'BTS/{}/NRDU-1/NF1CD'.format(_NRBTS2_name),
    'BTS/{}/NRPAG'.format(_NRBTS2CELL1_name),
    'BTS/{}/NNGCB'.format(_NRBTS2_name),
    'BTS/{}/NRDU-1/NF1CD'.format(_NRBTS2_name),
    'BTS/{}/NRPAG'.format(_NRBTS2CELL1_name),
    'BTS/{}/NRPAG'.format(_NRBTS2CELL2_name),
]

counter_id_D005 = [
    'M55119C01501', 'M55119C02501', 'M55119C02502', 'M55117C04502',
    'M55117C03001', 'M55117C04501', 'M55331C00001', 'M55331C00002',
    'M55331C00003', 'M55331C00005', 'M55331C00006', 'M55331C00007',
    'M55331C00008', 'M55331C00001', 'M55331C00002', 'M55331C00003',
    'M55331C00005', 'M55331C00006', 'M55331C00007', 'M55331C00008'
]

counter_dic_path_D005 = [
    'BTS/{}/NNGCB'.format(_NRBTS2_name),
    'BTS/{}/NNGCB'.format(_NRBTS2_name),
    'BTS/{}/NNGCB'.format(_NRBTS2_name),
    'BTS/{}/NRDU-1/NF1CD'.format(_NRBTS2_name),
    'BTS/{}/NRDU-1/NF1CD'.format(_NRBTS2_name),
    'BTS/{}/NRDU-1/NF1CD'.format(_NRBTS2_name),
    'BTS/{}/NRPAG'.format(_NRBTS2CELL1_name),
    'BTS/{}/NRPAG'.format(_NRBTS2CELL1_name),
    'BTS/{}/NRPAG'.format(_NRBTS2CELL1_name),
    'BTS/{}/NRPAG'.format(_NRBTS2CELL1_name),
    'BTS/{}/NRPAG'.format(_NRBTS2CELL1_name),
    'BTS/{}/NRPAG'.format(_NRBTS2CELL1_name),
    'BTS/{}/NRPAG'.format(_NRBTS2CELL1_name),
    'BTS/{}/NRPAG'.format(_NRBTS2CELL2_name),
    'BTS/{}/NRPAG'.format(_NRBTS2CELL2_name),
    'BTS/{}/NRPAG'.format(_NRBTS2CELL2_name),
    'BTS/{}/NRPAG'.format(_NRBTS2CELL2_name),
    'BTS/{}/NRPAG'.format(_NRBTS2CELL2_name),
    'BTS/{}/NRPAG'.format(_NRBTS2CELL2_name),
    'BTS/{}/NRPAG'.format(_NRBTS2CELL2_name),
]

counter_id_D001 = [
    'M55117C04502', 'M55117C04503', 'M55331C00005', 'M55331C00007',
    'M55117C03001', 'M55331C00001', 'M55331C00001',
]

counter_dic_path_D001 = [
    'BTS/{}/NRDU-1/NF1CD'.format(_NRBTS2_name),
    'BTS/{}/NRDU-1/NF1CD'.format(_NRBTS2_name),
    'BTS/{}/NRPAG'.format(_NRBTS2CELL1_name),
    'BTS/{}/NRPAG'.format(_NRBTS2CELL1_name),
    'BTS/{}/NRDU-1/NF1CD'.format(_NRBTS2_name),
    'BTS/{}/NRPAG'.format(_NRBTS2CELL1_name),
    'BTS/{}/NRPAG'.format(_NRBTS2CELL2_name),
]

counter_id_AB002 = [
    'M55119C02502', 'M55117C04502', 'M55331C00005',
]

counter_dic_path_AB002 = [
    'BTS/{}/NNGCB'.format(_NRBTS2_name),
    'BTS/{}/NRDU-1/NF1CD'.format(_NRBTS2_name),
    'BTS/{}/NRPAG'.format(_NRBTS2CELL1_name),
]

counter_id_ABC005 = [
    'M55331C00007', 'M55331C00004'
]

counter_dic_path_ABC005 = [
    'BTS/{}/NRPAG'.format(_NRBTS2CELL1_name),
    'BTS/{}/NRPAG'.format(_NRBTS2CELL1_name),
]
# ----------------A_101--------------- #
Modify_A_101 = [
    dict(
        value='Disabled',
        dist_name=_NRBTS3_CLOCK1,
        parameter='outputConfiguration1Pps'),
    dict(
        value='Disabled',
        dist_name=_NRBTS3_CLOCK1,
        parameter='outputConfiguration1PpsBackplane'),
    dict(
        value='Disabled',
        dist_name=_NRBTS3_CLOCK1,
        parameter='outputConfiguration2M048'),
]

Modify_A_101_covery = [
    dict(
        value='EnabledWithoutBtsInputReference',
        dist_name=_NRBTS3_CLOCK1,
        parameter='outputConfiguration1Pps'),
    dict(
        value='EnabledWithoutBtsInputReference',
        dist_name=_NRBTS3_CLOCK1,
        parameter='outputConfiguration1PpsBackplane'),
    dict(
        value='EnabledWithoutBtsInputReference',
        dist_name=_NRBTS3_CLOCK1,
        parameter='outputConfiguration2M048'),
]

Delete_NTP_Mo = [
    {'dist_name': _NRBTS2_NTP_1}
]

Online_modify_ABC_005_part2 = [
    dict(
        value='None',
        dist_name=_NRBTS2CELL1_name,
        parameter='actEdrx'),
]

Online_modify_ABC_005_part3 = [
    dict(
        value='Idle + Inactive',
        dist_name=_NRBTS2CELL1_name,
        parameter='actEdrx'),
]

Online_Modify_A_B_002_p1 = [
    dict(
        value='None',
        dist_name=_NRBTS2CELL1_name,
        parameter='actEdrx'),
    dict(
        value='None',
        dist_name=_NRBTS2CELL2_name,
        parameter='actEdrx'),
    dict(
        value='LoosePhaseAndTimeSync',
        dist_name=_NRBTS2SYNC_1,
        parameter='btsSyncMode'),
    dict(
        value='1',
        dist_name=_NRBTS2_name,
        parameter='maxUeRrcInactTime'),
]

Online_Delete_A_B_002_p1 = [
    dict(
        dist_name=_NRBTS2SYNC_1,
        parameter='manualFrameTimingAdjustment'),
]

Online_Modify_A_B_002_p2 = [
    dict(
        value='Idle',
        dist_name=_NRBTS2CELL1_name,
        parameter='actEdrx'),
    dict(
        value='Idle + Inactive',
        dist_name=_NRBTS2CELL2_name,
        parameter='actEdrx'),
    dict(
        value='500',
        dist_name=_NRBTS2_name,
        parameter='maxBtsTimeError'),
    dict(
        value='barred',
        dist_name=_NRBTS2CELL1_name,
        parameter='cellBarred'),
    dict(
        value='notBarred',
        dist_name=_NRBTS2CELL2_name,
        parameter='cellBarred'),
]

Online_Moidfy_A_B_002_Recovery = [
    dict(
        value='10',
        dist_name=_NRBTS2_name,
        parameter='maxUeRrcInactTime'),
]

Online_ADD_A_B_002_Recovery = [
    dict(
        value='0',
        dist_name=_NRBTS2SYNC_1,
        parameter='manualFrameTimingAdjustment'),
]
# ----------------C_001--------------- #
Modify_C_001 = [
    dict(
        value='Unlocked',
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
        value='barred',
        dist_name=_NRBTS2CELL2_name,
        parameter='cellBarred'),
    dict(
        value='3',
        dist_name=_NRBTS2CELL1_name,
        parameter='maxNumPagingRecords'),
    dict(
        value='3',
        dist_name=_NRBTS2CELL2_name,
        parameter='maxNumPagingRecords'),
    dict(value=[dict(sctpWaitTimeInitSeqRetry='5')],
         dist_name=_NRBTS2SCTP_1, parameter='sctpProfile'),
    dict(
        value='no barring',
        dist_name=_NRBTS2CELL1_name,
        parameter='cellBarredRedCap'),
    dict(
        value='None',
        dist_name=_NRBTS2CELL1_name,
        parameter='actEdrx'),
    dict(
        value='None',
        dist_name=_NRBTS2CELL2_name,
        parameter='actEdrx'),
    dict(
        value='20',
        dist_name=_NRBTS2_name,
        parameter='drbInactivityTimerSA'),
    dict(
        value='20',
        dist_name=_NRBTS2_name,
        parameter='drbInactivityTimerSARedCap'),
    dict(
        value='20',
        dist_name=_NRBTS2_name,
        parameter='drbRrcInactInactivityTimerSARedCap'),
    dict(
        value='20',
        dist_name=_NRBTS2_name,
        parameter='srbInactivityTimerSARedCap'),
    dict(
        value='20',
        dist_name=_NRBTS2_name,
        parameter='srbInactivityTimerSA'),
    dict(
        value='20',
        dist_name=_NRBTS2_name,
        parameter='drbRrcInactInactivityTimerSA'),
    dict(
        value='false',
        dist_name=_NRBTS2_name,
        parameter='actRrcInactStateRedCap'),
]

Online_actEdrx_modify_C001 = [
    dict(
        value='Idle',
        dist_name=_NRBTS2CELL1_name,
        parameter='actEdrx'),
    dict(
        value='Idle',
        dist_name=_NRBTS2CELL2_name,
        parameter='actEdrx'),
]

# ----------------C_003--------------- #
Modify_D_002 = [
    dict(
        value='Unlocked',
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
        value='3',
        dist_name=_NRBTS2CELL1_name,
        parameter='maxNumPagingRecords'),
    dict(
        value='3',
        dist_name=_NRBTS2CELL2_name,
        parameter='maxNumPagingRecords'),
    dict(value=[dict(sctpWaitTimeInitSeqRetry='5')],
         dist_name=_NRBTS2SCTP_1, parameter='sctpProfile'),
    dict(
        value='notBarred',
        dist_name=_NRBTS2CELL1_name,
        parameter='cellBarred'),
    dict(
        value='barred',
        dist_name=_NRBTS2CELL2_name,
        parameter='cellBarred'),
    dict(
        value='no barring',
        dist_name=_NRBTS2CELL1_name,
        parameter='cellBarredRedCap'),
    dict(
        value='no barring',
        dist_name=_NRBTS2CELL2_name,
        parameter='cellBarredRedCap'),
    dict(
        value='true',
        dist_name=_NRBTS2CELL1_name,
        parameter='actPriorityAccess'),
    dict(
        value='Idle + Inactive',
        dist_name=_NRBTS2CELL1_name,
        parameter='actEdrx'),
    dict(
        value='Idle',
        dist_name=_NRBTS2CELL2_name,
        parameter='actEdrx'),
    dict(
        value='true',
        dist_name=_NRBTS2_name,
        parameter='actRrcInactStateRedCap'),
    dict(
        value='20',
        dist_name=_NRBTS2_name,
        parameter='drbInactivityTimerSA'),
    dict(
        value='20',
        dist_name=_NRBTS2_name,
        parameter='drbInactivityTimerSARedCap'),
    dict(
        value='20',
        dist_name=_NRBTS2_name,
        parameter='drbRrcInactInactivityTimerSARedCap'),
    dict(
        value='20',
        dist_name=_NRBTS2_name,
        parameter='srbInactivityTimerSARedCap'),
    dict(
        value='20',
        dist_name=_NRBTS2_name,
        parameter='srbInactivityTimerSA'),
    dict(
        value='20',
        dist_name=_NRBTS2_name,
        parameter='drbRrcInactInactivityTimerSA'),
    dict(
        value='10',
        dist_name=_NRBTS2_name,
        parameter='maxUeRrcInactTime'),
    dict(value=[dict(nea1_128='0', nea2_128='0', nea3_128='0')],
         dist_name=_NRBTS2_name, parameter='cipherPrefL'),
    dict(value=[dict(nia1_128='9', nia2_128='0', nia3_128='0')],
         dist_name=_NRBTS2_name, parameter='integrityProtPrefL'),
]

Delete_Para_D_002 = [
    dict(
        dist_name=_NRBTS2_name,
        parameter='ranEdrxPagingCycle'),
]

online_recovery_D002 = [
    dict(
        value='v256',
        dist_name=_NRBTS2_name,
        parameter='ranEdrxPagingCycle'),
]

Online_actEdrx_modify_C003 = [
    dict(
        value='Idle',
        dist_name=_NRBTS2CELL1_name,
        parameter='actEdrx'),
    dict(
        value='Idle',
        dist_name=_NRBTS2CELL2_name,
        parameter='actEdrx'),
]

online_modify_EDA_GNB1 = [
    dict(
        value='Locked',
        dist_name=_GNB1SERVEDAMF_1,
        parameter='administrativeState'),
    dict(
        value='Unlocked',
        dist_name=_GNB1SERVEDAMF_2,
        parameter='administrativeState'),
]

online_modify_EDA_GNB2 = [
    dict(
        value='no barring',
        dist_name=_NRBTS2CELL2_name,
        parameter='cellBarredRedCap'),
]

online_recovery_EDA_GNB1 = [
    dict(
        value='Unlocked',
        dist_name=_GNB1SERVEDAMF_1,
        parameter='administrativeState'),
    dict(
        value='Locked',
        dist_name=_GNB1SERVEDAMF_2,
        parameter='administrativeState'),
]

online_recovery_EDA_GNB2 = [
    dict(
        value='1RX barring',
        dist_name=_NRBTS2CELL2_name,
        parameter='cellBarredRedCap'),
]

Modify_C_003 = [
    dict(
        value='Unlocked',
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
        value='3',
        dist_name=_NRBTS2CELL1_name,
        parameter='maxNumPagingRecords'),
    dict(
        value='3',
        dist_name=_NRBTS2CELL2_name,
        parameter='maxNumPagingRecords'),
    dict(value=[dict(sctpWaitTimeInitSeqRetry='5')],
         dist_name=_NRBTS2SCTP_1, parameter='sctpProfile'),
    dict(
        value='no barring',
        dist_name=_NRBTS2CELL1_name,
        parameter='cellBarredRedCap'),
    dict(
        value='no barring',
        dist_name=_NRBTS2CELL2_name,
        parameter='cellBarredRedCap'),
    dict(
        value='notBarred',
        dist_name=_NRBTS2CELL1_name,
        parameter='cellBarred'),
    dict(
        value='barred',
        dist_name=_NRBTS2CELL2_name,
        parameter='cellBarred'),
    dict(
        value='1',
        dist_name=_NRBTS2_name,
        parameter='maxUeRrcInactTime'),
    dict(
        value='Idle + Inactive',
        dist_name=_NRBTS2CELL1_name,
        parameter='actEdrx'),
    dict(
        value='None',
        dist_name=_NRBTS2CELL2_name,
        parameter='actEdrx'),
    dict(
        value='20',
        dist_name=_NRBTS2_name,
        parameter='drbInactivityTimerSA'),
    dict(
        value='20',
        dist_name=_NRBTS2_name,
        parameter='drbInactivityTimerSARedCap'),
    dict(
        value='20',
        dist_name=_NRBTS2_name,
        parameter='drbRrcInactInactivityTimerSARedCap'),
    dict(
        value='20',
        dist_name=_NRBTS2_name,
        parameter='srbInactivityTimerSARedCap'),
    dict(
        value='20',
        dist_name=_NRBTS2_name,
        parameter='srbInactivityTimerSA'),
    dict(
        value='20',
        dist_name=_NRBTS2_name,
        parameter='drbRrcInactInactivityTimerSA'),
    dict(value=[dict(nea1_128='0', nea2_128='0', nea3_128='0')],
         dist_name=_NRBTS2_name, parameter='cipherPrefL'),
    dict(value=[dict(nia1_128='9', nia2_128='0', nia3_128='0')],
         dist_name=_NRBTS2_name, parameter='integrityProtPrefL'),
]

Recovery_C_003 = [
    dict(
        value='10',
        dist_name=_NRBTS2_name,
        parameter='maxUeRrcInactTime'),
    dict(
        value='notBarred',
        dist_name=_NRBTS2CELL2_name,
        parameter='cellBarred'),
]
# ----------------C_007--------------- #
Modify_C_007 = [
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
        value='3',
        dist_name=_NRBTS2CELL1_name,
        parameter='maxNumPagingRecords'),
    dict(
        value='3',
        dist_name=_NRBTS2CELL2_name,
        parameter='maxNumPagingRecords'),
    dict(value=[dict(sctpWaitTimeInitSeqRetry='5')],
         dist_name=_NRBTS2SCTP_1, parameter='sctpProfile'),
    dict(
        value='Idle',
        dist_name=_NRBTS2CELL1_name,
        parameter='actEdrx'),
    dict(
        value='Idle + Inactive',
        dist_name=_NRBTS2CELL2_name,
        parameter='actEdrx'),
    dict(
        value='no barring',
        dist_name=_NRBTS2CELL1_name,
        parameter='cellBarredRedCap'),
    dict(
        value='false',
        dist_name=_NRBTS2CELL1_name,
        parameter='actPriorityAccess'),
    dict(
        value='true',
        dist_name=_NRBTS2CELL2_name,
        parameter='actPriorityAccess'),
    dict(
        value='true',
        dist_name=_NRBTS2_name,
        parameter='actRrcInactStateRedCap'),
    dict(
        value='20',
        dist_name=_NRBTS2_name,
        parameter='drbInactivityTimerSA'),
    dict(
        value='20',
        dist_name=_NRBTS2_name,
        parameter='drbInactivityTimerSARedCap'),
    dict(
        value='20',
        dist_name=_NRBTS2_name,
        parameter='drbRrcInactInactivityTimerSA'),
    dict(
        value='20',
        dist_name=_NRBTS2_name,
        parameter='drbRrcInactInactivityTimerSARedCap'),
    dict(
        value='20',
        dist_name=_NRBTS2_name,
        parameter='srbInactivityTimerSA'),
    dict(
        value='20',
        dist_name=_NRBTS2_name,
        parameter='srbInactivityTimerSARedCap'),
    dict(
        value='HPA+MPS',
        dist_name=_NRBTS2_name,
        parameter='applyPriorityAccess'),
    dict(
        value='true',
        dist_name=_NRBTS2_name,
        parameter='eDRXBasedDiscardPagingRec'),
    dict(
        value='notBarred',
        dist_name=_NRBTS2CELL1_name,
        parameter='cellBarred'),
    dict(
        value='barred',
        dist_name=_NRBTS2CELL2_name,
        parameter='cellBarred'),
    dict(
        value='v256',
        dist_name=_NRBTS2_name,
        parameter='drxDefaultPaging'),
]

Online_actEdrx_modify_C007 = [
    dict(
        value='Idle + Inactive',
        dist_name=_NRBTS2CELL1_name,
        parameter='actEdrx'),
    dict(
        value='Idle',
        dist_name=_NRBTS2CELL2_name,
        parameter='actEdrx'),
]

Online_Modify_D005 = [
    dict(
        value='false',
        dist_name=_NRBTS2_name,
        parameter='eDRXBasedDiscardPagingRec'),
    dict(
        value='v256',
        dist_name=_NRBTS2_name,
        parameter='drxDefaultPaging'),
    dict(
        value='notBarred',
        dist_name=_NRBTS2CELL2_name,
        parameter='cellBarred'),
    dict(
        value='barred',
        dist_name=_NRBTS2CELL1_name,
        parameter='cellBarred'),
    dict(value=[dict(nea1_128='0', nea2_128='0', nea3_128='0')],
         dist_name=_NRBTS2_name, parameter='cipherPrefL'),
    dict(value=[dict(nia1_128='9', nia2_128='0', nia3_128='0')],
         dist_name=_NRBTS2_name, parameter='integrityProtPrefL'),
]

Online_Recovery_C007 = [
    dict(
        value='notBarred',
        dist_name=_NRBTS2CELL2_name,
        parameter='cellBarred'),
    dict(
        value='notBarred',
        dist_name=_NRBTS2CELL1_name,
        parameter='cellBarred'),
    dict(
        value='Idle',
        dist_name=_NRBTS2CELL1_name,
        parameter='actEdrx'),
    dict(
        value='Idle + Inactive',
        dist_name=_NRBTS2CELL2_name,
        parameter='actEdrx'),
]

Online_Recovery_D005 = [
    dict(
        value='notBarred',
        dist_name=_NRBTS2CELL1_name,
        parameter='cellBarred'),
    dict(
        value='notBarred',
        dist_name=_NRBTS2CELL2_name,
        parameter='cellBarred'),
    dict(value=[dict(nea1_128='3', nea2_128='4', nea3_128='2')],
         dist_name=_NRBTS2_name, parameter='cipherPrefL'),
    dict(value=[dict(nia1_128='3', nia2_128='4', nia3_128='2')],
         dist_name=_NRBTS2_name, parameter='integrityProtPrefL'),
]

# ----------------C_010--------------- #
Modify_C_010 = [
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
        value='3',
        dist_name=_NRBTS2CELL1_name,
        parameter='maxNumPagingRecords'),
    dict(
        value='3',
        dist_name=_NRBTS2CELL2_name,
        parameter='maxNumPagingRecords'),
    dict(value=[dict(sctpWaitTimeInitSeqRetry='5')],
         dist_name=_NRBTS2SCTP_1, parameter='sctpProfile'),
    dict(
        value='no barring',
        dist_name=_NRBTS2CELL1_name,
        parameter='cellBarredRedCap'),
    dict(
        value='no barring',
        dist_name=_NRBTS2CELL2_name,
        parameter='cellBarredRedCap'),
    dict(
        value='Idle',
        dist_name=_NRBTS2CELL1_name,
        parameter='actEdrx'),
    dict(
        value='Idle + Inactive',
        dist_name=_NRBTS2CELL2_name,
        parameter='actEdrx'),
    dict(
        value='true',
        dist_name=_NRBTS2CELL1_name,
        parameter='actPriorityAccess'),
    dict(
        value='false',
        dist_name=_NRBTS2CELL2_name,
        parameter='actPriorityAccess'),
    dict(
        value='false',
        dist_name=_NRBTS2_name,
        parameter='actRrcInactStateRedCap'),
    dict(
        value='20',
        dist_name=_NRBTS2_name,
        parameter='drbInactivityTimerSA'),
    dict(
        value='20',
        dist_name=_NRBTS2_name,
        parameter='drbInactivityTimerSARedCap'),
    dict(
        value='20',
        dist_name=_NRBTS2_name,
        parameter='drbRrcInactInactivityTimerSA'),
    dict(
        value='20',
        dist_name=_NRBTS2_name,
        parameter='drbRrcInactInactivityTimerSARedCap'),
    dict(
        value='20',
        dist_name=_NRBTS2_name,
        parameter='srbInactivityTimerSA'),
    dict(
        value='20',
        dist_name=_NRBTS2_name,
        parameter='srbInactivityTimerSARedCap'),
    dict(
        value='HPA+MPS',
        dist_name=_NRBTS2_name,
        parameter='applyPriorityAccess'),
    dict(
        value='false',
        dist_name=_NRBTS2_name,
        parameter='eDRXBasedDiscardPagingRec'),
    dict(
        value='v256',
        dist_name=_NRBTS2_name,
        parameter='drxDefaultPaging'),
    dict(
        value='postponedPaging',
        dist_name=_NRBTS2_name,
        parameter='actPagingEnh'),
    dict(value=[dict(nea1_128='0', nea2_128='0', nea3_128='0')],
         dist_name=_NRBTS2_name, parameter='cipherPrefL'),
    dict(value=[dict(nia1_128='9', nia2_128='0', nia3_128='0')],
         dist_name=_NRBTS2_name, parameter='integrityProtPrefL'),
]

Online_actEdrx_modify_C010 = [
    dict(
        value='None',
        dist_name=_NRBTS2CELL1_name,
        parameter='actEdrx'),
    dict(
        value='None',
        dist_name=_NRBTS2CELL2_name,
        parameter='actEdrx'),
]

Online_Modify_D007 = [
    dict(
        value='true',
        dist_name=_NRBTS2_name,
        parameter='actRrcInactStateRedCap'),
    dict(
        value='true',
        dist_name=_NRBTS2_name,
        parameter='eDRXBasedDiscardPagingRec'),
    dict(
        value='v256',
        dist_name=_NRBTS2_name,
        parameter='drxDefaultPaging'),
    dict(
        value='disabled',
        dist_name=_NRBTS2_name,
        parameter='actPagingEnh'),
]

Online_Recovery_D007 = [
    dict(value=[dict(nea1_128='3', nea2_128='4', nea3_128='2')],
         dist_name=_NRBTS2_name, parameter='cipherPrefL'),
    dict(value=[dict(nia1_128='3', nia2_128='4', nia3_128='2')],
         dist_name=_NRBTS2_name, parameter='integrityProtPrefL'),

]

# ----------------C_011--------------- #
Modify_C_011 = [
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
        value='3',
        dist_name=_NRBTS2CELL1_name,
        parameter='maxNumPagingRecords'),
    dict(
        value='3',
        dist_name=_NRBTS2CELL2_name,
        parameter='maxNumPagingRecords'),
    dict(value=[dict(sctpWaitTimeInitSeqRetry='5')],
         dist_name=_NRBTS2SCTP_1, parameter='sctpProfile'),
    dict(
        value='None',
        dist_name=_NRBTS2CELL1_name,
        parameter='actEdrx'),
    dict(
        value='Idle',
        dist_name=_NRBTS2CELL2_name,
        parameter='actEdrx'),
    dict(
        value='false',
        dist_name=_NRBTS2_name,
        parameter='actRrcInactStateRedCap'),
    dict(
        value='20',
        dist_name=_NRBTS2_name,
        parameter='drbInactivityTimerSA'),
    dict(
        value='20',
        dist_name=_NRBTS2_name,
        parameter='drbInactivityTimerSARedCap'),
    dict(
        value='20',
        dist_name=_NRBTS2_name,
        parameter='drbRrcInactInactivityTimerSA'),
    dict(
        value='20',
        dist_name=_NRBTS2_name,
        parameter='drbRrcInactInactivityTimerSARedCap'),
    dict(
        value='20',
        dist_name=_NRBTS2_name,
        parameter='srbInactivityTimerSA'),
    dict(
        value='20',
        dist_name=_NRBTS2_name,
        parameter='srbInactivityTimerSARedCap'),
    dict(
        value='true',
        dist_name=_NRBTS2_name,
        parameter='pwsRestIndEnabled'),
    dict(
        value='true',
        dist_name=_NRBTS2_name,
        parameter='actCMAS'),
    dict(
        value='true',
        dist_name=_NRBTS2_name,
        parameter='actETWS'),
]

Online_actEdrx_modify_C011 = [
    dict(
        value='Idle + Inactive',
        dist_name=_NRBTS2CELL1_name,
        parameter='actEdrx'),
    dict(
        value='None',
        dist_name=_NRBTS2CELL2_name,
        parameter='actEdrx'),
]


# ----------------D_001--------------- #
Modify_D_001 = [
    dict(
        value='Unlocked',
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
        value='3',
        dist_name=_NRBTS2CELL1_name,
        parameter='maxNumPagingRecords'),
    dict(
        value='3',
        dist_name=_NRBTS2CELL2_name,
        parameter='maxNumPagingRecords'),
    dict(value=[dict(sctpWaitTimeInitSeqRetry='5')],
         dist_name=_NRBTS2SCTP_1, parameter='sctpProfile'),
    dict(
        value='no barring',
        dist_name=_NRBTS2CELL1_name,
        parameter='cellBarredRedCap'),
    dict(
        value='Idle + Inactive',
        dist_name=_NRBTS2CELL1_name,
        parameter='actEdrx'),
    dict(
        value='None',
        dist_name=_NRBTS2CELL2_name,
        parameter='actEdrx'),
    dict(
        value='true',
        dist_name=_NRBTS2_name,
        parameter='actRrcInactStateRedCap'),
    dict(
        value='20',
        dist_name=_NRBTS2_name,
        parameter='drbInactivityTimerSA'),
    dict(
        value='20',
        dist_name=_NRBTS2_name,
        parameter='drbInactivityTimerSARedCap'),
    dict(
        value='20',
        dist_name=_NRBTS2_name,
        parameter='drbRrcInactInactivityTimerSA'),
    dict(
        value='20',
        dist_name=_NRBTS2_name,
        parameter='drbRrcInactInactivityTimerSARedCap'),
    dict(
        value='20',
        dist_name=_NRBTS2_name,
        parameter='srbInactivityTimerSA'),
    dict(
        value='20',
        dist_name=_NRBTS2_name,
        parameter='srbInactivityTimerSARedCap'),
    dict(
        value='true',
        dist_name=_NRBTS2_name,
        parameter='eDRXBasedDiscardPagingRec'),
    dict(
        value='10',
        dist_name=_NRBTS2_name,
        parameter='tEdrxRanPagingGuard'),
    dict(
        value='v512',
        dist_name=_NRBTS2_name,
        parameter='ranEdrxPagingCycle'),
    dict(
        value='30min',
        dist_name=_NRBTS2_name,
        parameter='t380'),
    dict(
        value='barred',
        dist_name=_NRBTS2CELL2_name,
        parameter='cellBarred'),
    dict(
        value='notBarred',
        dist_name=_NRBTS2CELL1_name,
        parameter='cellBarred'),
    dict(value=[dict(nea1_128='0', nea2_128='0', nea3_128='0')],
         dist_name=_NRBTS2_name, parameter='cipherPrefL'),
    dict(value=[dict(nia1_128='9', nia2_128='0', nia3_128='0')],
         dist_name=_NRBTS2_name, parameter='integrityProtPrefL'),
]

Recovery_D_001 = [
    dict(
        value='notBarred',
        dist_name=_NRBTS2CELL2_name,
        parameter='cellBarred'),
    dict(
        value='notBarred',
        dist_name=_NRBTS2CELL1_name,
        parameter='cellBarred'),
]
