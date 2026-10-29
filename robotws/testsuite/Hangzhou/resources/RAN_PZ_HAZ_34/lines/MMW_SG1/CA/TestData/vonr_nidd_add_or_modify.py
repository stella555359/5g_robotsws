from robot.libraries.BuiltIn import BuiltIn
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.NIDD_modify_scf_common import *
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.NIDD_modify_scf_1390 import *


def creat_n310_t310_for_vonr(dn_pcell_list):
    list_n310_t310 = []
    if len(dn_pcell_list) == 0:
        raise Exception("There is no PCELL on GNB, please check.")
    else:
        for pcell_index in range(0, len(dn_pcell_list)):
            n310 = dict(
                dist_name=DN_PCELL_LIST[pcell_index],
                p_name='n310VoNR',
                value='n10', ),
            list_n310_t310 += list(n310)

            t310 = dict(
                dist_name=DN_PCELL_LIST[pcell_index],
                p_name='t310VoNR',
                value='2000ms', ),
            list_n310_t310 += list(t310)
    return list_n310_t310


def create_cdrx_and_vonr_according_to_pcell_to_modify(
        dn_pcell_list,
        drxInactivityTimer='10ms',
        drxLongCycle='40ms',
        drxOnDurationTimer='10ms'):
    """
        Author: Liu Zheng
        Description: create cdrx and vonr parameters according to pcell.
        :param dn_pcell_list: pcell list
        :return: return a list of parameters with cdrx and vonr values for update. Format will be:
        [{dist_name=MRBTS-10152/NRBTS-10152/NRCELL-2,
         list_name='drxProfile2', elements={
         "drxInactivityTimer": '4ms',
         "drxLongCycle": '40ms',
         "drxOnDurationTimer": '6ms',
         "drxRetransTimerDl": '0slot',
         "drxRetransTimerUl": '0slot'}},
         {dist_name=MRBTS-10152/NRBTS-10152/NRCELL-3,
         list_name='drxProfile2', elements={
         "drxInactivityTimer": '4ms',
         "drxLongCycle": '40ms',
         "drxOnDurationTimer": '6ms',
         "drxRetransTimerDl": '0slot',
         "drxRetransTimerUl": '0slot'}}]
        """
    list_cdrx_vonr = []
    if len(dn_pcell_list) == 0:
        raise Exception("There is no PCELL on GNB, please check.")
    else:
        for pcell_index in range(0, len(dn_pcell_list)):
            list_cdrx_vonr_tmp = [
                dict(
                    value='true',
                    dist_name=DN_PCELL_LIST[pcell_index],
                    p_name='actCDrxVoNR'),
                dict(
                    value='true',
                    dist_name=DN_PCELL_LIST[pcell_index],
                    p_name='actEnhancedVoNR'),
                dict(
                    value='true',
                    dist_name=DN_PCELL_LIST[pcell_index],
                    p_name='actVoNR'),
                dict(
                    value='off',
                    dist_name=DN_PCELL_LIST[pcell_index],
                    p_name='actVoNrMobilityThresholds'),
                dict(
                    value='true',
                    dist_name=DN_PCELL_LIST[pcell_index],
                    p_name='actCDrx'),
                dict(
                    value=drxInactivityTimer,
                    dist_name=DN_PCELL_LIST[pcell_index],
                    p_name='drxInactivityTimer',
                    list_name='drxProfile1'),
                dict(
                    value=drxLongCycle,
                    dist_name=DN_PCELL_LIST[pcell_index],
                    p_name='drxLongCycle',
                    list_name='drxProfile1'),
                dict(
                    value=drxOnDurationTimer,
                    dist_name=DN_PCELL_LIST[pcell_index],
                    p_name='drxOnDurationTimer',
                    list_name='drxProfile1'),
                dict(
                    value='0slot',
                    dist_name=DN_PCELL_LIST[pcell_index],
                    p_name='drxRetransTimerDl',
                    list_name='drxProfile1'),
                dict(
                    value='0slot',
                    dist_name=DN_PCELL_LIST[pcell_index],
                    p_name='drxRetransTimerUl',
                    list_name='drxProfile1'),
            ]
            list_cdrx_vonr += list_cdrx_vonr_tmp
    return list_cdrx_vonr


def create_cdrx_profile2_according_to_pcell_to_add(dn_pcell_list):
    """
    Author: Liu Zheng
    Description: create cdrx profile2 parameters according to pcell.
    :param dn_pcell_list: pcell list
    :return: return a list of parameters with profile2 values for add. Format will be:
    [{dist_name=MRBTS-10152/NRBTS-10152/NRCELL-2,
     list_name='drxProfile2', elements={
     "drxInactivityTimer": '4ms',
     "drxLongCycle": '40ms',
     "drxOnDurationTimer": '6ms',
     "drxRetransTimerDl": '0slot',
     "drxRetransTimerUl": '0slot'}},
     {dist_name=MRBTS-10152/NRBTS-10152/NRCELL-3,
     list_name='drxProfile2', elements={
     "drxInactivityTimer": '4ms',
     "drxLongCycle": '40ms',
     "drxOnDurationTimer": '6ms',
     "drxRetransTimerDl": '0slot',
     "drxRetransTimerUl": '0slot'}}]
    """
    list_drxprofile = []
    if len(dn_pcell_list) == 0:
        raise Exception("There is no PCELL on GNB, please check.")
    else:
        for pcell_index in range(0, len(dn_pcell_list)):
            dict_drxprofile = dict(dist_name=dn_pcell_list[pcell_index],
                                   list_name='drxProfile2', elements={
                "drxInactivityTimer": '10ms',
                "drxLongCycle": '40ms',
                "drxOnDurationTimer": '10ms',
                "drxHarqRttTimerDl": '0symbols',
                "drxHarqRttTimerUl": '0symbols',
                "drxRetransTimerDl": '0slot',
                "drxRetransTimerUl": '0slot'}),
            list_drxprofile += list(dict_drxprofile)
    return list(list_drxprofile)


PARAMS_TO_ADD_FOR_VONR_COMMON = [

    dict(class_name='com.nokia.srbts.nrbts:NRDRB_MAC',
         version='NRBTSCL22R1_2106_100', opertion='create',
         dist_name=DN_NRBTS + '/NRDRB_MAC-3'),

    dict(class_name='com.nokia.srbts.nrbts:NRDRB_MAC',
         version='NRBTSCL22R1_2106_100', opertion='create',
         dist_name=DN_NRBTS + '/NRDRB_MAC-4'),

    dict(dist_name=DN_NRBTS + '/NRDRB_MAC-3',
         p_name='lcgid',
         value='0'),
    dict(dist_name=DN_NRBTS + '/NRDRB_MAC-3',
         p_name='schedulPrio',
         value='4'),

    dict(dist_name=DN_NRBTS + '/NRDRB_MAC-4',
         p_name='lcgid',
         value='4'),

    dict(dist_name=DN_NRBTS + '/NRDRB_MAC-4',
         p_name='schedulPrio',
         value='5'),

    dict(class_name='com.nokia.srbts.nrbts:NRDRB_RLC_UM',
         version='NRBTSCL22R1_2106_100', opertion='create',
         dist_name=DN_NRBTS + '/NRDRB_RLC_UM-1'),

    dict(dist_name=DN_NRBTS + '/NRDRB_RLC_UM-1',
         p_name='dlTReassemblyUm',
         value='ms15'),
    dict(dist_name=DN_NRBTS + '/NRDRB_RLC_UM-1',
         p_name='rlcUMDrbSNLength',
         value='rlcUm12bitSN'),
    dict(dist_name=DN_NRBTS + '/NRDRB_RLC_UM-1',
         p_name='ulTReassemblyUm',
         value='ms15'),

    dict(class_name='com.nokia.srbts.nrbts:NRDRB_PDCP',
         version='NRBTSCL22R1_2106_100', opertion='create',
         dist_name=DN_NRBTS + '/NRDRB_PDCP-3'),

    dict(dist_name=DN_NRBTS + '/NRDRB_PDCP-3',
         p_name='cuFlowControlProfId',
         value='1'),
    dict(dist_name=DN_NRBTS + '/NRDRB_PDCP-3',
         p_name='pdcpBufDiscardEnabled',
         value='false'),
    dict(dist_name=DN_NRBTS + '/NRDRB_PDCP-3',
         p_name='pdcpBufDiscardThreshold',
         value='20000'),
    dict(dist_name=DN_NRBTS + '/NRDRB_PDCP-3',
         p_name='tReorderingDl',
         value='ms100'),
    dict(dist_name=DN_NRBTS + '/NRDRB_PDCP-3',
         p_name='tReorderingUl',
         value='ms100'),
    dict(dist_name=DN_NRBTS + '/NRDRB_PDCP-3',
         p_name='pdcpDelayThreshRetxMode',
         value='disabled'),

    dict(class_name='com.nokia.srbts.nrbts:NRDRB',
         version='NRBTSCL22R1_2106_100', opertion='create',
         dist_name=DN_NRBTS + '/NRDRB-15'),

    dict(dist_name=DN_NRBTS + '/NRDRB-15',
         p_name='actDddsReduction',
         value='false'),
    dict(dist_name=DN_NRBTS + '/NRDRB-15',
         p_name='discardTimer',
         value='100ms'),
    dict(dist_name=DN_NRBTS + '/NRDRB-15',
         p_name='dlAllowMinDelayLinkXxCalib',
         value='false'),
    dict(dist_name=DN_NRBTS + '/NRDRB-15',
         p_name='dlFlowControlAlgo',
         value='none'),
    dict(dist_name=DN_NRBTS + '/NRDRB-15',
         p_name='dscp',
         value='44'),
    dict(dist_name=DN_NRBTS + '/NRDRB-15',
         p_name='maxDddsPeriodCpuOvld',
         value='40'),
    dict(dist_name=DN_NRBTS + '/NRDRB-15',
         p_name='nrDrbMacDN',
         value=DN_NRBTS + '/NRDRB_MAC-4'),
    dict(dist_name=DN_NRBTS + '/NRDRB-15',
         p_name='nrDrbPdcpDN',
         value=DN_NRBTS + '/NRDRB_PDCP-3'),
    dict(dist_name=DN_NRBTS + '/NRDRB-15',
         p_name='nrDrbRlcUmDN',
         value=DN_NRBTS + '/NRDRB_RLC_UM-1'),
    dict(dist_name=DN_NRBTS + '/NRDRB-15',
         p_name='numSduDiscard',
         value='1'),
    dict(dist_name=DN_NRBTS + '/NRDRB-15',
         p_name='queuingDelayDiscardEnabled',
         value='false'),
    dict(dist_name=DN_NRBTS + '/NRDRB-15',
         p_name='queuingDelaySduDiscardThreshold',
         value='750'),
    dict(dist_name=DN_NRBTS + '/NRDRB-15',
         p_name='resType',
         value='GBR'),
    dict(dist_name=DN_NRBTS + '/NRDRB-15',
         p_name='rlcMode',
         value='RLC_UM'),
    dict(dist_name=DN_NRBTS + '/NRDRB-15',
         p_name='schedulWeight',
         value='1'),
    dict(dist_name=DN_NRBTS + '/NRDRB-15',
         p_name='sduDiscardIntervalTmr',
         value='500'),
    dict(dist_name=DN_NRBTS + '/NRDRB-15',
         p_name='actLostPduFastRetx',
         value='false'),
    dict(dist_name=DN_NRBTS + '/NRDRB-15',
         p_name='actOptDataFlowRateEst',
         value='false'),
    dict(dist_name=DN_NRBTS + '/NRDRB-15',
         p_name='endMarkerTimer',
         value='2000'),
    dict(dist_name=DN_NRBTS + '/NRDRB-15',
         list_name='nsaDrbParam', elements={
             "actPrioritizeX2AfterInactivity": 'true',
             "dlDataSplitBufferBuildUpThreshold": '5',
             "dlDataSplitBufferBuildUpThresholdPrioritizeX2": '5',
             "dlDataSplitGainThreshold": '5',
             "dlDataSplitMode": 'dlOverF1UX2U',
             "actX2DuplicateTxNSA3x": 'false',
             "dlPreferredPath": 'F1-U',
             "inactivityThresholdForPrioritizeX2": '300',
             "inactivityThresholdForRestartPrioritizeX2": '100',
             "initialDLTrafficRouting": 'initDLoverX2U',
             "nsa3xBearerAllowed": 'true',
             "prioritizeX2Period": '500',
             "ulDataPath": 'ulOverNr',
             "ulDataSplitThreshold": 'infinity',
             "dlNumOfCongOrGainDdds": '2'}),
    dict(dist_name=DN_NRBTS + '/NRDRB-15',
         list_name='cellAggrLevel', elements=['Not FR1 CA eligible']),
    dict(class_name='com.nokia.srbts.nrbts:NRDRB_5QI',
         version='NRBTSCL22R1_2106_100', opertion='create',
         dist_name=DN_NRBTS + '/NRDRB_5QI-6'),
    dict(dist_name=DN_NRBTS + '/NRDRB_5QI-6',
         list_name='fiveqiValueList', elements=['1']),
    dict(dist_name=DN_NRBTS + '/NRDRB_5QI-6',
         p_name='nrDrbDN',
         value=DN_NRBTS + '/NRDRB-15'),
]

# PARAMS_TO_ADD_FOR_VONR_21B_SPECIAL = [
#     dict(dist_name=DN_NRBTS + '/NRDRB-15',
#          p_name='durationThresDiscard',
#          value='50'),
#     dict(dist_name=DN_NRBTS + '/NRDRB-15',
#          p_name='volThresDiscard',
#          value='100'),
# ]

# PARAMS_TO_ADD_FOR_VONR_23R1_SPECIAL = [
#     dict(dist_name=DN_NRBTS + '/NRDRB_MAC-3',
#          p_name='prioritisedBitRate',
#          value='16kBps'),
#     dict(dist_name=DN_NRBTS + '/NRDRB_MAC-4',
#          p_name='prioritisedBitRate',
#          value='16kBps'),
#     dict(dist_name=DN_NRBTS + '/NRDRB_MAC-4',
#          p_name='schedulBSD',
#          value='100ms'),
#     dict(dist_name=DN_NRBTS + '/NRDRB-15',
#          p_name='maxRlcQueueingDelayGbr',
#          value='20'),
#     dict(dist_name=DN_NRBTS + '/NRDRB-15',
#          p_name='maxTransferDelayGbr',
#          value='20'),
#     dict(dist_name=DN_NRBTS + '/NRDRB-15',
#          p_name='maxDataRateGbrDl',
#          value='1000'),
#     dict(dist_name=DN_NRBTS + '/NRDRB-15',
#          p_name='maxDataRateGbrUl',
#          value='1000'),
# ] + PARAMS_TO_ADD_FOR_VONR_21B_SPECIAL

# PARAMS_TO_ADD_FOR_VONR_23R2_SPECIAL = [
#     dict(dist_name=DN_NRBTS + '/NRDRB-15',
#          p_name='actDlTxResumeOnPdcpStatRep',
#          value='false'),
#     dict(dist_name=DN_NRBTS + '/NRDRB-15',
#          p_name='dlAllowMinDelayLinkX2Calib',
#          value='false'),
#     dict(dist_name=DN_NRBTS + '/NRDRB-15',
#          p_name='durationThresDiscardDl',
#          value='40'),
#     dict(dist_name=DN_NRBTS + '/NRDRB-15',
#          p_name='durationThresDiscardUl',
#          value='20'),
#     dict(dist_name=DN_NRBTS + '/NRDRB-15',
#          p_name='volThresDiscardDl',
#          value='8000'),
#     dict(dist_name=DN_NRBTS + '/NRDRB-15',
#          p_name='volThresDiscardUl',
#          value='800'),
# ] + PARAMS_TO_ADD_FOR_VONR_23R1_SPECIAL

PARAMS_TO_ADD_FOR_VONR_23R3_SPECIAL = [
    dict(dist_name=DN_NRBTS + '/NRDRB_MAC-3',
         p_name='prioritisedBitRate',
         value='16kBps'),
    dict(dist_name=DN_NRBTS + '/NRDRB_MAC-4',
         p_name='prioritisedBitRate',
         value='16kBps'),
    dict(dist_name=DN_NRBTS + '/NRDRB_MAC-4',
         p_name='schedulBSD',
         value='100ms'),
    dict(dist_name=DN_NRBTS + '/NRDRB-15',
         p_name='actDlTxResumeOnPdcpStatRep',
         value='false'),
    dict(dist_name=DN_NRBTS + '/NRDRB-15',
         p_name='caPduReSendingDelayMargin',
         value='2'),
    dict(dist_name=DN_NRBTS + '/NRDRB-15',
         p_name='dlAllowMinDelayLinkX2Calib',
         value='false'),
    dict(dist_name=DN_NRBTS + '/NRDRB-15',
         p_name='durationThresDiscardDl',
         value='40'),
    dict(dist_name=DN_NRBTS + '/NRDRB-15',
         p_name='durationThresDiscardUl',
         value='20'),
    dict(dist_name=DN_NRBTS + '/NRDRB-15',
         p_name='rlcPduDelayThCa',
         value='30'),
    dict(dist_name=DN_NRBTS + '/NRDRB-15',
         p_name='volThresDiscardDl',
         value='8000'),
    dict(dist_name=DN_NRBTS + '/NRDRB-15',
         p_name='volThresDiscardUl',
         value='800'),

    dict(dist_name=DN_NRBTS + '/NRDRB-15',
         p_name='durationThresDiscardDlMacSdu',
         value='40'),
    dict(dist_name=DN_NRBTS + '/NRDRB-15',
         p_name='durationThresDiscardDlPdcpPdu5GLeg',
         value='40'),
    dict(dist_name=DN_NRBTS + '/NRDRB-15',
         p_name='durationThresDiscardDlPdcpPduLteLeg',
         value='40'),
    dict(dist_name=DN_NRBTS + '/NRDRB-15',
         p_name='volThresDiscardDlMacSdu',
         value='8000'),
    dict(dist_name=DN_NRBTS + '/NRDRB-15',
         p_name='volThresDiscardDlPdcpPdu5GLeg',
         value='8000'),
    dict(dist_name=DN_NRBTS + '/NRDRB-15',
         p_name='volThresDiscardDlPdcpPduLteLeg',
         value='8000'),
    dict(dist_name=DN_NRBTS + '/NRDRB-15',
         p_name='maxRlcQueueingDelayGbr',
         value='20'),
    dict(dist_name=DN_NRBTS + '/NRDRB-15',
         p_name='maxTransferDelayGbr',
         value='20'),
    dict(dist_name=DN_NRBTS + '/NRDRB-15',
         p_name='maxDataRateGbrDl',
         value='1000'),
    dict(dist_name=DN_NRBTS + '/NRDRB-15',
         p_name='maxDataRateGbrUl',
         value='1000'),
    dict(dist_name=DN_NRBTS + '/NRDRB-15',
         p_name='durationThresDiscard',
         value='50'),
    dict(dist_name=DN_NRBTS + '/NRDRB-15',
         p_name='volThresDiscard',
         value='100'),
]

PARAMS_TO_ADD_FOR_N310_T310 = list(
    creat_n310_t310_for_vonr(
        dn_pcell_list=DN_PCELL_LIST))


def create_vonr_according_to_pcell_to_modify(dn_pcell_list):
    """
        Author: Liu Zheng
        Description: create vonr parameters according to pcell.
        :param dn_pcell_list: pcell list
        :return: return a list of parameters with cdrx and vonr values for update. Format will be:
        [{dist_name=MRBTS-10152/NRBTS-10152/NRCELL-2,
         list_name='drxProfile2', elements={
         "drxInactivityTimer": '4ms',
         "drxLongCycle": '40ms',
         "drxOnDurationTimer": '6ms',
         "drxRetransTimerDl": '0slot',
         "drxRetransTimerUl": '0slot'}},
         {dist_name=MRBTS-10152/NRBTS-10152/NRCELL-3,
         list_name='drxProfile2', elements={
         "drxInactivityTimer": '4ms',
         "drxLongCycle": '40ms',
         "drxOnDurationTimer": '6ms',
         "drxRetransTimerDl": '0slot',
         "drxRetransTimerUl": '0slot'}}]
        """
    list_vonr = []
    if len(dn_pcell_list) == 0:
        raise Exception("There is no PCELL on GNB, please check.")
    else:
        for pcell_index in range(0, len(dn_pcell_list)):
            list_vonr_tmp = [
                dict(
                    value='true',
                    dist_name=DN_PCELL_LIST[pcell_index],
                    p_name='actEnhancedVoNR'),
                dict(
                    value='true',
                    dist_name=DN_PCELL_LIST[pcell_index],
                    p_name='actVoNR'),
                dict(
                    value='off',
                    dist_name=DN_PCELL_LIST[pcell_index],
                    p_name='actVoNrMobilityThresholds'),
            ]
            list_vonr += list_vonr_tmp
    return list_vonr


MODIFY_NRDRB_10_SCF = [
    dict(
        value=DN_NRBTS + '/NRDRB_MAC-3',
        dist_name=DN_NRBTS + '/NRDRB-10',
        p_name='nrDrbMacDN'),
    dict(
        value='nonGBR_Signaling',
        dist_name=DN_NRBTS + '/NRDRB-10',
        p_name='resType'),
]

# After enable CB009109(actDrbDrx) in 24R3, it will activates the extension of
# DRX profiles which allows operator to improve UE battery consumption by optimizing
# DRX for each specific service 5QI and/or QCI.
# The APN for TL255 UE is wap2.nokia.com.
# It use 5QI7(NRDRB-12) for UDP and 5QI1(NRDRB-15) for VONR.

PARAMS_TO_MODIFY_NRDRX_DEFAULT_NONGBR = [
    dict(
        value='10ms',
        dist_name=DN_NRBTS + '/NRDRX-4',
        p_name='drxInactivityTimer'),
    dict(
        value='40ms',
        dist_name=DN_NRBTS + '/NRDRX-4',
        p_name='drxLongCycle'),
    dict(
        value='10ms',
        dist_name=DN_NRBTS + '/NRDRX-4',
        p_name='drxOnDurationTimer'),
    dict(
        value='NonGbr',
        dist_name=DN_NRBTS + '/NRDRX-4',
        p_name='userLabel'),
    dict(
        value=DN_NRBTS + '/NRDRX-4',
        dist_name=DN_NRBTS + '/NRDRB-12',
        p_name='nrDrxDN'),
    # dict(
    #     value=DN_NRBTS + '/NRDRX-4',
    #     dist_name=DN_PCELL,
    #     p_name='nonGbrNrDrxDN')
]

PARAMS_TO_MODIFY_NRDRX_DEFAULT_VONR = [
    dict(
        value='true',
        dist_name=DN_NRBTS,
        p_name='actDrbDrx'),
    dict(
        value='10ms',
        dist_name=DN_NRBTS + '/NRDRX-6',
        p_name='drxInactivityTimer'),
    dict(
        value='40ms',
        dist_name=DN_NRBTS + '/NRDRX-6',
        p_name='drxLongCycle'),
    dict(
        value='10ms',
        dist_name=DN_NRBTS + '/NRDRX-6',
        p_name='drxOnDurationTimer'),
    dict(
        value='VoNR',
        dist_name=DN_NRBTS + '/NRDRX-6',
        p_name='userLabel'),
    dict(
        value=DN_NRBTS + '/NRDRX-6',
        dist_name=DN_NRBTS + '/NRDRB-15',
        p_name='nrDrxDN'),
    # dict(
    #     value=DN_NRBTS + '/NRDRX-6',
    #     dist_name=DN_PCELL,
    #     p_name='voNRNrDrxDN')
]

PARAMS_TO_MODIFY_NRDRX_ENABLE_VONR = [
    dict(
        value='true',
        dist_name=DN_PCELL,
        p_name='actCDrxVoNR'),
    dict(
        value='true',
        dist_name=DN_PCELL,
        p_name='actEnhancedVoNR'),
    dict(
        value='true',
        dist_name=DN_PCELL,
        p_name='actVoNR'),
    dict(
        value='off',
        dist_name=DN_PCELL,
        p_name='actVoNrMobilityThresholds'),
    dict(
        value='true',
        dist_name=DN_PCELL,
        p_name='actCDrx'),
]

if program in ['23R3', '23R4', '24R1', '24R2']:
    PARAMS_TO_ADD_FOR_VONR = PARAMS_TO_ADD_FOR_VONR_COMMON + \
                             PARAMS_TO_ADD_FOR_VONR_23R3_SPECIAL + PARAMS_TO_ADD_FOR_N310_T310
else:
    PARAMS_TO_ADD_FOR_VONR = []

if program in ['23R3', '23R4', '24R1', '24R2']:
    PARAMS_TO_ADD_FOR_VONR_AND_CDRX = PARAMS_TO_ADD_FOR_VONR + \
        create_cdrx_profile2_according_to_pcell_to_add(dn_pcell_list=DN_PCELL_LIST)
else:
    PARAMS_TO_ADD_FOR_VONR_AND_CDRX = []

if program in ['23R3', '23R4', '24R1', '24R2']:
    PARAMS_TO_MODIFY_CDRX_VONR_ALIGNBWP = MODIFY_SCF_DEFAULT_ALIGNBWP + MODIFY_NRDRB_10_SCF + \
        create_cdrx_and_vonr_according_to_pcell_to_modify(dn_pcell_list=DN_PCELL_LIST)
else:
    PARAMS_TO_MODIFY_CDRX_VONR_ALIGNBWP = MODIFY_SCF_DEFAULT_ALIGNBWP + MODIFY_NRDRB_10_SCF + \
        PARAMS_TO_MODIFY_NRDRX_DEFAULT_NONGBR + PARAMS_TO_MODIFY_NRDRX_DEFAULT_VONR + PARAMS_TO_MODIFY_NRDRX_ENABLE_VONR

if __name__ == '__main__':
    DN_PCELL_LIST = ['2', '3', '4']
    DN_NRBTS = 'mrbts_255'
    profile2_list = create_cdrx_profile2_according_to_pcell_to_add(
        dn_pcell_list=DN_PCELL_LIST)
    print('profile2_list is:%s' % profile2_list)
