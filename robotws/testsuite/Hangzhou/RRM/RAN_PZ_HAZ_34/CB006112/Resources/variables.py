from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Xing Jing'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'jing.1.xing@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'


_gnb_id = str(tl.gnbs[0].instance_id)
_gnb_id2 = str(tl.gnbs[1].instance_id)
#  _gnb_id = str(tl.gnbs[1].instance_id)
_MRBTSname = 'MRBTS-'+_gnb_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id
_MRBTSname2 = 'MRBTS-' + _gnb_id2
_NRBTSname2 = _MRBTSname2 + '/NRBTS-' + _gnb_id2
_NRBTS_name2 = 'NRBTS-' + _gnb_id2
_NRCELLname = _NRBTSname+'/NRCELL-1'
_NRDRB15name = _NRBTSname+'/NRDRB-15'
_ho_path1 = 'BTS/CELLS/NRCELL-1/RSADU'
_Trunk_ho_path1 = f'BTS/{_NRBTSname}/NRCELL-1/RSADU'
_enb_id = str(tl.gnbs[0].instance_id + 10)
_LNBTSname = _MRBTSname+'/LNBTS-'+_enb_id
_LTECELLname = _LNBTSname+'/LNCEL-4'
_SERVEDAMF_21 = f'{_NRBTSname2}/SERVEDAMF-1'
_SERVEDAMF_22 = f'{_NRBTSname2}/SERVEDAMF-2'

_EDA_04136786_path1 = f'BTS/{_NRBTSname2}/NRCELL-1/NNGCC'


PATH_TO_SCF = ''

counter_id_5QI2_gNB12_cell1_2 = [
    'M55138C01004', 'M55139C00509', 'M55138C01009', 'M55140C00501'
]

Trunk_counter_dic_path_5QI2_gNB2_cell1_2 = [
    f'BTS/{_NRBTSname2}/NRCELL-1/RSACU', f'BTS/{_NRBTSname2}/NRCELL-1/RSADU',
    f'BTS/{_NRBTSname2}/NRCELL-1/RSACU', f'BTS/{_NRBTSname2}/RSANB'
]

counter_dic_path_5QI2_gNB2_cell1_2 = [
    'BTS/CELLS/NRCELL-1/RSACU', 'BTS/CELLS/NRCELL-1/RSADU',
    'BTS/CELLS/NRCELL-1/RSACU', f'BTS/BTS/{_NRBTS_name2}/RSANB',
]


# counter_id_5QI2_gNB12_cell1 = [
#     'M55138C01001', 'M55149C01001', 'M55138C01002', 'M55149C01002', 'M55149C01003',
#     'M55138C01006', 'M55138C01007', 'M55139C00501', 'M55139C00502', 'M55139C00511',
#     'M55139C00512', 'M55145C01501', 'M55139C00504'
# ]

counter_id_5QI2_gNB12_cell1 = [
    'M55138C01001', 'M55149C01001', 'M55138C01002', 'M55149C01002', 'M55149C01003',
    'M55138C01006', 'M55138C01007', 'M55139C00501', 'M55139C00502', 'M55145C01501', 'M55139C00504'
]

# Trunk_counter_dic_path_5QI2_gNB2_cell1 = [
#     f'BTS/{_NRBTSname2}/NRCELL-1/RSACU', f'BTS/{_NRBTSname2}/MCC-001/MNC-01/SST-1/SD-13714341/NSL',
#     f'BTS/{_NRBTSname2}/NRCELL-1/RSACU', f'BTS/{_NRBTSname2}/MCC-001/MNC-01/SST-1/SD-13714341/NSL',
#     f'BTS/{_NRBTSname2}/MCC-001/MNC-01/SST-1/SD-13714341/NSL',
#     f'BTS/{_NRBTSname2}/NRCELL-1/RSACU', f'BTS/{_NRBTSname2}/NRCELL-1/RSACU',
#     f'BTS/{_NRBTSname2}/NRCELL-1/RSADU', f'BTS/{_NRBTSname2}/NRCELL-1/RSADU',
#     f'BTS/{_NRBTSname2}/NRCELL-1/RSADU', f'BTS/{_NRBTSname2}/NRCELL-1/RSADU',
#     f'BTS/{_NRBTSname2}/NRCELL-1/MCC-001/MNC-01/NRANS', f'BTS/{_NRBTSname2}/NRCELL-1/RSADU'
# ]

Trunk_counter_dic_path_5QI2_gNB2_cell1 = [
    f'BTS/{_NRBTSname2}/NRCELL-1/RSACU', f'BTS/{_NRBTSname2}/MCC-001/MNC-01/SST-1/SD-13714341/NSL',
    f'BTS/{_NRBTSname2}/NRCELL-1/RSACU', f'BTS/{_NRBTSname2}/MCC-001/MNC-01/SST-1/SD-13714341/NSL',
    f'BTS/{_NRBTSname2}/MCC-001/MNC-01/SST-1/SD-13714341/NSL',
    f'BTS/{_NRBTSname2}/NRCELL-1/RSACU', f'BTS/{_NRBTSname2}/NRCELL-1/RSACU',
    f'BTS/{_NRBTSname2}/NRCELL-1/RSADU', f'BTS/{_NRBTSname2}/NRCELL-1/RSADU',
    f'BTS/{_NRBTSname2}/NRCELL-1/MCC-001/MNC-01/NRANS', f'BTS/{_NRBTSname2}/NRCELL-1/RSADU'
]

# counter_dic_path_5QI2_gNB2_cell1 = [
#     'BTS/CELLS/NRCELL-1/RSACU', f'BTS/BTS/{_NRBTS_name2}/MCC-001_MNC-01/SST-1_SD-13714341/NSL',
#     'BTS/CELLS/NRCELL-1/RSACU', f'BTS/BTS/{_NRBTS_name2}/MCC-001_MNC-01/SST-1_SD-13714341/NSL',
#     f'BTS/BTS/{_NRBTS_name2}/MCC-001_MNC-01/SST-1_SD-13714341/NSL',
#     'BTS/CELLS/NRCELL-1/RSACU', 'BTS/CELLS/NRCELL-1/RSACU',
#     'BTS/CELLS/NRCELL-1/RSADU', 'BTS/CELLS/NRCELL-1/RSADU',
#     'BTS/CELLS/NRCELL-1/RSADU', 'BTS/CELLS/NRCELL-1/RSADU',
#     'BTS/CELLS/NRCELL-1/MCC-001_MNC-01/NRANS', 'BTS/CELLS/NRCELL-1/RSADU'
# ]

counter_dic_path_5QI2_gNB2_cell1 = [
    'BTS/CELLS/NRCELL-1/RSACU', f'BTS/BTS/{_NRBTS_name2}/MCC-001_MNC-01/SST-1_SD-13714341/NSL',
    'BTS/CELLS/NRCELL-1/RSACU', f'BTS/BTS/{_NRBTS_name2}/MCC-001_MNC-01/SST-1_SD-13714341/NSL',
    f'BTS/BTS/{_NRBTS_name2}/MCC-001_MNC-01/SST-1_SD-13714341/NSL',
    'BTS/CELLS/NRCELL-1/RSACU', 'BTS/CELLS/NRCELL-1/RSACU',
    'BTS/CELLS/NRCELL-1/RSADU', 'BTS/CELLS/NRCELL-1/RSADU',
    'BTS/CELLS/NRCELL-1/MCC-001_MNC-01/NRANS', 'BTS/CELLS/NRCELL-1/RSADU'
]

EDA_04136786_paras = [
    dict(value='Locked', dist_name=_SERVEDAMF_21, parameter='administrativeState'),
    dict(value='Unlocked', dist_name=_SERVEDAMF_22, parameter='administrativeState'),
]
EDA_04136786_recover_paras = [
    dict(value='Unlocked', dist_name=_SERVEDAMF_21, parameter='administrativeState'),
    dict(value='Locked', dist_name=_SERVEDAMF_22, parameter='administrativeState'),
]

counter_EDA_04136786_M55125C05002 = {'gnb_id': 1, 'dic_path': _EDA_04136786_path1, 'counter_id': 'M55125C05002'}
counter_EDA_04136786_M55125C05003 = {'gnb_id': 1, 'dic_path': _EDA_04136786_path1, 'counter_id': 'M55125C05003'}

PARAM_CB006112_B_08_WA = [
    dict(value='locked', dist_name=_LTECELLname, parameter='administrativeState')
]
PARAM_CB006112_B_08_recover_WA = [
    dict(value='unlocked', dist_name=_LTECELLname, parameter='administrativeState')
]

PARAM_6112_A_009 = [
    dict(new_value='true', dist_name=_NRCELLname,
         filter_param='Activate VoIP packet aggregation', abbr='actVoipPacketAggr'),
    dict(new_value='false', dist_name=_NRCELLname,
         filter_param='Activate connected DRX', abbr='actCDrx'),
    dict(new_value='false', dist_name=_NRCELLname,
         filter_param='Activate connected DRX VoNR', abbr='actCDrxVoNR'),
    dict(new_value='40', dist_name=_NRBTSname,
         filter_param='Uplink VoIP packet aggregation SINR threshold', abbr='ulVoipPacketAggrSinrThresh'),
    dict(new_value='slots40', dist_name=_NRCELLname,
         filter_param='CSI reporting periodicity', abbr='csiReportPeriodicity')
]
PARAM_6112_A_009_1 = [
    dict(new_value='false', dist_name=_NRCELLname,
         filter_param='Activate VoIP packet aggregation', abbr='actVoipPacketAggr')
]

PARAM_6112_A_009_2 = [
    dict(new_value='true', dist_name=_NRCELLname,
         filter_param='Activate VoIP packet aggregation', abbr='actVoipPacketAggr'),
    dict(new_value='2', dist_name=_NRBTSname,
         filter_param='Uplink VoIP packet aggregation SINR threshold', abbr='ulVoipPacketAggrSinrThresh'),
]

PARAM_6112_A_011_trunk = [
    dict(new_value='slots80', dist_name=_NRCELLname,
         filter_param='CSI reporting periodicity', abbr='csiReportPeriodicity'),
    dict(new_value='50', dist_name=_NRCELLname,
         filter_param='A2 Threshold Ssb Rsrp for Handover SA', abbr='a2ThresholdhoSsbRsrpSA'),
    dict(new_value='true', dist_name=_NRCELLname,
         filter_param='Activate connected DRX', abbr='actCDrx'),
    dict(new_value='true', dist_name=_NRCELLname,
         filter_param='Activate connected DRX VoNR', abbr='actCDrxVoNR'),
    dict(new_value='20ms', dist_name=_NRDRB15name,
         filter_param='Discard timer', abbr='discardTimer'),
]

PARAM_6112_A_011_21A = [
    dict(new_value='slots80', dist_name=_NRCELLname,
         filter_param='CSI reporting periodicity', abbr='csiReportPeriodicity'),
    dict(new_value='50', dist_name=_NRCELLname,
         filter_param='A2 Threshold Ssb Rsrp for Handover SA mode', abbr='a2ThresholdhoSsbRsrpSA'),
    dict(new_value='true', dist_name=_NRCELLname,
         filter_param='Activate connected DRX', abbr='actCDrx'),
    dict(new_value='true', dist_name=_NRCELLname,
         filter_param='Activate connected DRX VoNR', abbr='actCDrxVoNR'),
    dict(new_value='20ms', dist_name=_NRDRB15name,
         filter_param='Discard timer', abbr='discardTimer'),
]

PARAM_6112_A_011_1 = [
    dict(new_value='100ms', dist_name=_NRDRB15name,
         filter_param='Discard timer', abbr='discardTimer')
]

PARAMS_TO_MODIFY_6112_A16 = [

    dict(value='150', dist_name='NRBTS-${tl.gnbs[1].instance_id}', parameter='drbInactivityTimerSA5qi5'),
]

PARAMS_TO_MODIFY_6112_A16_2 = [
    dict(value='15', dist_name='NRBTS-${tl.gnbs[1].instance_id}', parameter='drbInactivityTimerSA5qi5'),
]

PARAMS_TO_MODIFY_6112_B17 = [
    dict(
        value=[dict(drxInactivityTimer='1ms', drxLongCycle='20ms', drxOnDurationTimer='2ms', drxRetransTimerDl='0slot',
                    drxRetransTimerUl='0slot')],
        dist_name='NRBTS-${tl.gnbs[1].instance_id}/NRCELL-1',
        parameter='drxProfile1'),
    dict(
        value=[dict(drxInactivityTimer='1ms', drxLongCycle='20ms', drxOnDurationTimer='2ms', drxRetransTimerDl='0slot',
                    drxRetransTimerUl='0slot')],
        dist_name='NRBTS-${tl.gnbs[1].instance_id}/NRCELL-1',
        parameter='drxProfile2'),
]

PARAMS_TO_MODIFY_6112_B17_1 = [
    dict(
        value=[dict(drxInactivityTimer='1ms', drxLongCycle='40ms', drxOnDurationTimer='2ms', drxRetransTimerDl='0slot',
                    drxRetransTimerUl='0slot')],
        dist_name='NRBTS-${tl.gnbs[1].instance_id}/NRCELL-1',
        parameter='drxProfile1'),
]

PARAMS_TO_MODIFY_6112_B17_2 = [
    dict(
        value=[dict(drxInactivityTimer='1ms', drxLongCycle='20ms', drxOnDurationTimer='2ms', drxRetransTimerDl='0slot',
                    drxRetransTimerUl='0slot')],
        dist_name='NRBTS-${tl.gnbs[1].instance_id}/NRCELL-1',
        parameter='drxProfile1'),
    dict(
        value=[dict(drxInactivityTimer='1ms', drxLongCycle='40ms', drxOnDurationTimer='2ms', drxRetransTimerDl='0slot',
                    drxRetransTimerUl='0slot')],
        dist_name='NRBTS-${tl.gnbs[1].instance_id}/NRCELL-1',
        parameter='drxProfile2'),
]

PARAM_6112_gnb2_A_014 = [
    dict(value='60000ms', dist_name=_NRBTSname, parameter='tWaitingRlRecover'),
    dict(value='6000ms', dist_name=_NRBTSname, parameter='t310'),
    dict(value='6000ms', dist_name=_NRCELLname, parameter='t310VoNR'),
    dict(value='viaRRCSetup', dist_name=_NRBTSname, parameter='rrcReestabTypeSA'),
    dict(value='75', dist_name=_NRCELLname, parameter='rlpDetCsiBsiThreshold'),
    dict(value='5', dist_name=_NRCELLname, parameter='rlpDetDlHarqThreshold'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_8700_A_015 = [
    dict(value='on', dist_name=_NRCELLname, parameter='actARPBasedAC'),
    dict(value='3', dist_name=_NRCELLname, parameter='maxNumOfGBRBearersSA'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_8700_recover_A_015 = [
    dict(value='off', dist_name=_NRCELLname, parameter='actARPBasedAC'),
    dict(value='384', dist_name=_NRCELLname, parameter='maxNumOfGBRBearersSA'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]
AMOUNT_OF_CELLS = 1

SA_HO_DU_GBR_LACK_RAD_RES = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55139C00508'}
Trunk_SA_HO_DU_GBR_LACK_RAD_RES = {'gnb_id': 1, 'dic_path': _Trunk_ho_path1, 'counter_id': 'M55139C00508'}
