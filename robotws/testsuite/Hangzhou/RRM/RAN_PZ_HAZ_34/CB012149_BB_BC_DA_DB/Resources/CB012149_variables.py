from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Shi Ming & Zhang Yayun'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'ming.shi@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_enb_id = str(tl.enbs[0].instance_id)
_gnb_id = str(tl.gnbs[0].instance_id)
_global_id = str(tl.gnbs[0].global_bts_id)
_gnb_id2 = str(tl.gnbs[1].instance_id)
_MRBTSname = 'MRBTS-' + _global_id
_MRBTSname2 = 'MRBTS-' + _gnb_id2
_MRBTSname_enb = 'MRBTS-' + _global_id
_NRBTSname = _MRBTSname + '/NRBTS-' + _gnb_id
_NRBTSname2 = _MRBTSname2 + '/NRBTS-' + _gnb_id2
_LNBTSname = _MRBTSname_enb + '/LNBTS-' + _enb_id
_LTECELLname = _LNBTSname + '/LNCEL-4'
_LTECELL48040name = _LNBTSname + '/LNCEL-48040'
_LTECELL48041name = _LNBTSname + '/LNCEL-48041'
_LTECELL48042name = _LNBTSname + '/LNCEL-48042'
_LTECELL48043name = _LNBTSname + '/LNCEL-48043'
_LTECELL48044name = _LNBTSname + '/LNCEL-48044'
_LTECELL48045name = _LNBTSname + '/LNCEL-48045'
_LTECELL48046name = _LNBTSname + '/LNCEL-48046'
_LTECELL48047name = _LNBTSname + '/LNCEL-48047'
_LTECELL48048name = _LNBTSname + '/LNCEL-48048'
_LTECELL48049name = _LNBTSname + '/LNCEL-48049'
_NRCELLname = _NRBTSname + '/NRCELL-1'
_NRCELL2name = _NRBTSname + '/NRCELL-2'
_NRCELL3name = _NRBTSname + '/NRCELL-3'
_NRCELL4name = _NRBTSname + '/NRCELL-4'
_NRCELL21name = _NRBTSname + '/NRCELL-21'
_NRCELL400name = _NRBTSname + '/NRCELL-400'
_NRCELL410name = _NRBTSname + '/NRCELL-410'
_NRCELL544name = _NRBTSname + '/NRCELL-544'
_NRCELL545name = _NRBTSname + '/NRCELL-545'
_NRCELL644name = _NRBTSname + '/NRCELL-644'
_NRCELL645name = _NRBTSname + '/NRCELL-645'
_NRCELL700name = _NRBTSname + '/NRCELL-700'
_NRCELL701name = _NRBTSname + '/NRCELL-701'
_NRBTSDUname = _NRBTSname + '/NRDU-9999'
_NRBTSDUname2 = _NRBTSname2 + '/NRDU-1'
_NRCELLname2 = _NRBTSname2 + '/NRCELL-1'
_NRBTSDUnameGRPgNB1cell = _NRBTSname + '/NRCELLGRP-0'
_NRBTSDUnameGRPgNB1cell2 = _NRBTSname + '/NRCELLGRP-1'
_NRREL1namegnb1 = _NRCELLname + '/NRREL-1'
_NRREL2namegnb1 = _NRCELLname + '/NRREL-2'
_NRREL3namegnb1 = _NRCELLname + '/NRREL-3'
_NRRELLnamegnb1 = _NRCELL2name + '/NRREL-0'
_NRRELLnamegnb11 = _NRCELL2name + '/NRREL-1'
_NRRELLnamegnb12 = _NRCELL2name + '/NRREL-2'
_NRRELL400namegnb12 = _NRCELL400name + '/NRREL-2'
_NRRELLnamegnb13 = _NRCELL2name + '/NRREL-3'
_NRRELLnamegnb2 = _NRCELLname2 + '/NRREL-2'
_NRRELLnamegnb20 = _NRCELLname2 + '/NRREL-1'
_NRREL21namegnb1 = _NRCELL2name + '/NRREL-1'
_SERVEDAMF = _NRBTSname + '/SERVEDAMF-1'
_NRCELL1_FDD1 = _NRCELLname + '/NRCELL_FDD-1'
_NRCELL2_FDD1 = _NRCELL2name + '/NRCELL_FDD-1'
_NRCELL400_FDD1 = _NRCELL400name + '/NRCELL_FDD-1'
_BWP_PROFILE_0 = _NRBTSname + '/BWP_PROFILE-0'
_BWP_PROFILE_7 = _NRBTSname + '/BWP_PROFILE-7'
_BWP_PROFILE_8 = _NRBTSname + '/BWP_PROFILE-8'
_NRULCG_PROFILE_2 = _NRBTSname + '/NRULCG_PROFILE-2'
_NRDRB_10 = _NRBTSname + '/NRDRB-10'
_NRDRB_12 = _NRBTSname + '/NRDRB-12'
_NRDRB_13 = _NRBTSname + '/NRDRB-13'
_NRDRB_15 = _NRBTSname + '/NRDRB-15'
_NRPMRNL = _NRBTSname + '/NRPMRNL-1'
_NRDLMUMIMO_1_700 = _NRCELL700name + '/NRDLMUMIMO-1'

NRCELLname = _NRBTSname + '/NRCELL-1'
NRCELL2name = _NRBTSname + '/NRCELL-2'
NRCELL3name = _NRBTSname + '/NRCELL-3'
NRCELL4name = _NRBTSname + '/NRCELL-4'
NRCELL21name = _NRBTSname + '/NRCELL-21'
NRCELL400name = _NRBTSname + '/NRCELL-400'
NRCELL410name = _NRBTSname + '/NRCELL-410'
NRCELL544name = _NRBTSname + '/NRCELL-544'
NRCELL545name = _NRBTSname + '/NRCELL-545'
NRCELL644name = _NRBTSname + '/NRCELL-644'
NRCELL645name = _NRBTSname + '/NRCELL-645'
NRCELL700name = _NRBTSname + '/NRCELL-700'
NRCELL701name = _NRBTSname + '/NRCELL-701'

_BWP_PROFILE_7001 = _NRBTSname + '/BWP_PROFILE-7001'
_BWP_PROFILE_7002 = _NRBTSname + '/BWP_PROFILE-7002'
_BWP_PROFILE_7003 = _NRBTSname + '/BWP_PROFILE-7003'
_BWP_PROFILE_7004 = _NRBTSname + '/BWP_PROFILE-7004'
_BWP_PROFILE_7005 = _NRBTSname + '/BWP_PROFILE-7005'
_BWP_PROFILE_7006 = _NRBTSname + '/BWP_PROFILE-7006'
_BWP_PROFILE_7007 = _NRBTSname + '/BWP_PROFILE-7007'
_BWP_PROFILE_7008 = _NRBTSname + '/BWP_PROFILE-7008'
_BWP_PROFILE_7011 = _NRBTSname + '/BWP_PROFILE-7011'
_BWP_PROFILE_7012 = _NRBTSname + '/BWP_PROFILE-7012'
_BWP_PROFILE_7013 = _NRBTSname + '/BWP_PROFILE-7013'
_BWP_PROFILE_7014 = _NRBTSname + '/BWP_PROFILE-7014'
_BWP_PROFILE_7015 = _NRBTSname + '/BWP_PROFILE-7015'
_BWP_PROFILE_7016 = _NRBTSname + '/BWP_PROFILE-7016'
_BWP_PROFILE_7017 = _NRBTSname + '/BWP_PROFILE-7017'
_BWP_PROFILE_7018 = _NRBTSname + '/BWP_PROFILE-7018'

_LCELNR_4 = _MRBTSname + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4'
_LCELNR_16 = _MRBTSname + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-16'

_CHANNELGROUP_4_1 = _LCELNR_4 + '/CHANNELGROUP-1'
_CHANNELGROUP_4_2 = _LCELNR_4 + '/CHANNELGROUP-2'
_CHANNELGROUP_4_3 = _LCELNR_4 + '/CHANNELGROUP-3'
_CHANNELGROUP_4_4 = _LCELNR_4 + '/CHANNELGROUP-4'
_CHANNELGROUP_16_1 = _LCELNR_16 + '/CHANNELGROUP-1'
_CHANNELGROUP_16_2 = _LCELNR_16 + '/CHANNELGROUP-2'
_CHANNELGROUP_16_3 = _LCELNR_16 + '/CHANNELGROUP-3'
_CHANNELGROUP_16_4 = _LCELNR_16 + '/CHANNELGROUP-4'

_CHANNEL_4_1_1 = _CHANNELGROUP_4_1 + '/CHANNEL-1'
_CHANNEL_4_1_2 = _CHANNELGROUP_4_1 + '/CHANNEL-2'
_CHANNEL_4_1_3 = _CHANNELGROUP_4_1 + '/CHANNEL-3'
_CHANNEL_4_1_4 = _CHANNELGROUP_4_1 + '/CHANNEL-4'
_CHANNEL_4_1_5 = _CHANNELGROUP_4_1 + '/CHANNEL-5'
_CHANNEL_4_1_6 = _CHANNELGROUP_4_1 + '/CHANNEL-6'
_CHANNEL_4_1_7 = _CHANNELGROUP_4_1 + '/CHANNEL-7'
_CHANNEL_4_1_8 = _CHANNELGROUP_4_1 + '/CHANNEL-8'
_CHANNEL_16_1_1 = _CHANNELGROUP_16_1 + '/CHANNEL-1'
_CHANNEL_16_1_2 = _CHANNELGROUP_16_1 + '/CHANNEL-2'
_CHANNEL_16_1_3 = _CHANNELGROUP_16_1 + '/CHANNEL-3'
_CHANNEL_16_1_4 = _CHANNELGROUP_16_1 + '/CHANNEL-4'
_CHANNEL_16_1_5 = _CHANNELGROUP_16_1 + '/CHANNEL-5'
_CHANNEL_16_1_6 = _CHANNELGROUP_16_1 + '/CHANNEL-6'
_CHANNEL_16_1_7 = _CHANNELGROUP_16_1 + '/CHANNEL-7'
_CHANNEL_16_1_8 = _CHANNELGROUP_16_1 + '/CHANNEL-8'

CB012149_ciphering_algorithms_json_file = 'CB012149_ciphering_algorithms.json'
CB012149_ciphering_algorithms = [
    {
        "distName": _NRBTSname,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "cipherPrefL",
                "operation": "update",
                "value": [
                    dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')
                ]
            },
            {
                "parameterName": "integrityProtPrefL",
                "operation": "update",
                "value": [
                    dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')
                ]
            }
        ]
    }
]

CB012149_recover_ciphering_algorithms_json_file = 'CB012149_recover_ciphering_algorithms.json'
CB012149_recover_ciphering_algorithms = [
    {
        "distName": _NRBTSname,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "cipherPrefL",
                "operation": "update",
                "value": [
                    dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')
                ]
            },
            {
                "parameterName": "integrityProtPrefL",
                "operation": "update",
                "value": [
                    dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')
                ]
            }
        ]
    }
]

tmp_EDA_04474899_variable_18 = dict(
    value=[
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '9',
            'monitoringSymbolWithinSlot': 'symbol_0',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl10',
            'searchSpaceId': '1',
            'searchSpaceType': 'Type0A',
            'slotOffset': '4'
        },
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '1',
            'monitoringSymbolWithinSlot': 'symbol_0_1',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl40',
            'searchSpaceId': '2',
            'searchSpaceType': 'Type1',
            'slotOffset': '26'
        },
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '3',
            'monitoringSymbolWithinSlot': 'symbol_0',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl5',
            'searchSpaceId': '3',
            'searchSpaceType': 'Type2',
            'slotOffset': '0'
        }
    ],
    dist_name=f'{_NRBTSname}/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1',
    parameter='searchSpaceCommon')

tmp_EDA_04474899_variable_80 = dict(
    value=[
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '9',
            'monitoringSymbolWithinSlot': 'symbol_0',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl10',
            'searchSpaceId': '14',
            'searchSpaceType': 'Type0A',
            'slotOffset': '4'
        },
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '1',
            'monitoringSymbolWithinSlot': 'symbol_0_1',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl40',
            'searchSpaceId': '15',
            'searchSpaceType': 'Type1',
            'slotOffset': '26'
        },
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '3',
            'monitoringSymbolWithinSlot': 'symbol_0',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl5',
            'searchSpaceId': '16',
            'searchSpaceType': 'Type2',
            'slotOffset': '0'
        }
    ],
    dist_name=f'{_NRBTSname}/BWP_PROFILE-80/PDCCH-1/PDCCH_CONFIG_COMMON-1',
    parameter='searchSpaceCommon')

tmp_EDA_04474899_variable_82 = dict(
    value=[
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '9',
            'monitoringSymbolWithinSlot': 'symbol_0',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl10',
            'searchSpaceId': '9',
            'searchSpaceType': 'Type0A',
            'slotOffset': '4'
        },
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '1',
            'monitoringSymbolWithinSlot': 'symbol_0_1',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl40',
            'searchSpaceId': '10',
            'searchSpaceType': 'Type1',
            'slotOffset': '26'
        },
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '3',
            'monitoringSymbolWithinSlot': 'symbol_0',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl5',
            'searchSpaceId': '11',
            'searchSpaceType': 'Type2',
            'slotOffset': '0'
        }
    ],
    dist_name=f'{_NRBTSname}/BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_COMMON-1',
    parameter='searchSpaceCommon')

tmp_EDA_04474899_variable_84 = dict(
    value=[
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '9',
            'monitoringSymbolWithinSlot': 'symbol_0',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl10',
            'searchSpaceId': '4',
            'searchSpaceType': 'Type0A',
            'slotOffset': '4'
        },
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '1',
            'monitoringSymbolWithinSlot': 'symbol_0_1',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl40',
            'searchSpaceId': '5',
            'searchSpaceType': 'Type1',
            'slotOffset': '26'
        },
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '3',
            'monitoringSymbolWithinSlot': 'symbol_0',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl5',
            'searchSpaceId': '6',
            'searchSpaceType': 'Type2',
            'slotOffset': '0'
        }
    ],
    dist_name=f'{_NRBTSname}/BWP_PROFILE-84/PDCCH-1/PDCCH_CONFIG_COMMON-1',
    parameter='searchSpaceCommon')

tmp_EDA_04474899_variable_18_recover = dict(
    value=[
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '9',
            'monitoringSymbolWithinSlot': 'symbol_0',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl10',
            'searchSpaceId': '1',
            'searchSpaceType': 'Type0A',
            'slotOffset': '4'
        },
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '1',
            'monitoringSymbolWithinSlot': 'symbol_0_1',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl1',
            'searchSpaceId': '2',
            'searchSpaceType': 'Type1',
            'slotOffset': '0'
        },
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '3',
            'monitoringSymbolWithinSlot': 'symbol_0',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl5',
            'searchSpaceId': '3',
            'searchSpaceType': 'Type2',
            'slotOffset': '0'
        }
    ],
    dist_name=f'{_NRBTSname}/BWP_PROFILE-18/PDCCH-1/PDCCH_CONFIG_COMMON-1',
    parameter='searchSpaceCommon')

tmp_EDA_04474899_variable_80_recover = dict(
    value=[
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '9',
            'monitoringSymbolWithinSlot': 'symbol_0',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl10',
            'searchSpaceId': '14',
            'searchSpaceType': 'Type0A',
            'slotOffset': '4'
        },
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '1',
            'monitoringSymbolWithinSlot': 'symbol_0_1',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl1',
            'searchSpaceId': '15',
            'searchSpaceType': 'Type1',
            'slotOffset': '0'
        },
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '3',
            'monitoringSymbolWithinSlot': 'symbol_0',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl5',
            'searchSpaceId': '16',
            'searchSpaceType': 'Type2',
            'slotOffset': '0'
        }
    ],
    dist_name=f'{_NRBTSname}/BWP_PROFILE-80/PDCCH-1/PDCCH_CONFIG_COMMON-1',
    parameter='searchSpaceCommon')

tmp_EDA_04474899_variable_82_recover = dict(
    value=[
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '9',
            'monitoringSymbolWithinSlot': 'symbol_0',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl10',
            'searchSpaceId': '9',
            'searchSpaceType': 'Type0A',
            'slotOffset': '4'
        },
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '1',
            'monitoringSymbolWithinSlot': 'symbol_0_1',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl1',
            'searchSpaceId': '10',
            'searchSpaceType': 'Type1',
            'slotOffset': '0'
        },
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '3',
            'monitoringSymbolWithinSlot': 'symbol_0',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl5',
            'searchSpaceId': '11',
            'searchSpaceType': 'Type2',
            'slotOffset': '0'
        }
    ],
    dist_name=f'{_NRBTSname}/BWP_PROFILE-82/PDCCH-1/PDCCH_CONFIG_COMMON-1',
    parameter='searchSpaceCommon')

tmp_EDA_04474899_variable_84_recover = dict(
    value=[
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '9',
            'monitoringSymbolWithinSlot': 'symbol_0',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl10',
            'searchSpaceId': '4',
            'searchSpaceType': 'Type0A',
            'slotOffset': '4'
        },
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '1',
            'monitoringSymbolWithinSlot': 'symbol_0_1',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl1',
            'searchSpaceId': '5',
            'searchSpaceType': 'Type1',
            'slotOffset': '0'
        },
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '3',
            'monitoringSymbolWithinSlot': 'symbol_0',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl5',
            'searchSpaceId': '6',
            'searchSpaceType': 'Type2',
            'slotOffset': '0'
        }
    ],
    dist_name=f'{_NRBTSname}/BWP_PROFILE-84/PDCCH-1/PDCCH_CONFIG_COMMON-1',
    parameter='searchSpaceCommon')

tmp_EDA_04474899_variable_csiReportPeriodicity = dict(
    value=[{'csiReportPeriodicity': 'slots40', 'csirsNumberWithinReportPeriod_Set1': '4', 'csirsPower': '15',
            'maxCsirsNumber': '4', 'scramblingIdStep': '3'}],
    dist_name=_NRCELL2name,
    parameter='periodicCsiAcquisition')

tmp_EDA_04474899_variable_csiReportPeriodicity_recover = dict(
    value=[{'csiReportPeriodicity': 'slots320', 'csirsNumberWithinReportPeriod_Set1': '4', 'csirsPower': '15',
            'maxCsirsNumber': '4', 'scramblingIdStep': '3'}],
    dist_name=_NRCELL2name,
    parameter='periodicCsiAcquisition')

tmp_EDA_04474899_variable_rbgLimit = dict(
    value=[{'dataBufferThreshold': '60000', 'endMcs': '28', 'prbAllocationDirection': 'highPerforming_High2low',
            'rank': '2', 'rbgLimit': '0', 'startMcs': '20'}],
    dist_name=_NRCELL2name,
    parameter='dlInterferenceAvoidance')

tmp_EDA_04474899_variable_rbgLimit_recover = dict(
    value=[{'dataBufferThreshold': '60000', 'endMcs': '28', 'prbAllocationDirection': 'highPerforming_High2low',
            'rank': '2', 'rbgLimit': '1', 'startMcs': '20'}],
    dist_name=_NRCELL2name,
    parameter='dlInterferenceAvoidance')

tmp_EDA_04474899 = [
    dict(value='true', dist_name=_NRBTSname, parameter='actTddCsiRsOpt'),
    dict(value='true', dist_name=_NRBTSname, parameter='actTddCsiImRm'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actCsiRsMuting'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actSmallestRRCSetup'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actRat1Alloc'),
    dict(value='0', dist_name=_NRCELL2name, parameter='percRedSEDlRat1VoNR'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL'),
    dict(value='Locked', dist_name=_NRCELL21name, parameter='administrativeState'),
]

tmp_EDA_04474899_recover = [
    dict(value='true', dist_name=_NRBTSname, parameter='actTddCsiRsOpt'),
    dict(value='true', dist_name=_NRBTSname, parameter='actTddCsiImRm'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actCsiRsMuting'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actSmallestRRCSetup'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actRat1Alloc'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL'),
    dict(value='Unlocked', dist_name=_NRCELL21name, parameter='administrativeState'),
]

tmp_EDA_04474899_recover_delete = [
    dict(dist_name=_NRCELL2name, parameter='percRedSEDlRat1VoNR'),
]

tmp_EDA_04474899_variable_7001 = dict(
    value=[
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '9',
            'monitoringSymbolWithinSlot': 'symbol_0',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl10',
            'searchSpaceId': '1',
            'searchSpaceType': 'Type0A',
            'slotOffset': '4'
        },
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '1',
            'monitoringSymbolWithinSlot': 'symbol_0_1',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl40',
            'searchSpaceId': '2',
            'searchSpaceType': 'Type1',
            'slotOffset': '26'
        },
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '4',
            'monitoringSymbolWithinSlot': 'symbol_0',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl10',
            'searchSpaceId': '3',
            'searchSpaceType': 'Type2',
            'slotOffset': '6'
        }
    ],
    dist_name=f'{_NRBTSname}/BWP_PROFILE-7001/PDCCH-1/PDCCH_CONFIG_COMMON-1',
    parameter='searchSpaceCommon')

tmp_EDA_04474899_variable_7002 = dict(
    value=[
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '9',
            'monitoringSymbolWithinSlot': 'symbol_0',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl10',
            'searchSpaceId': '4',
            'searchSpaceType': 'Type0A',
            'slotOffset': '4'
        },
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '1',
            'monitoringSymbolWithinSlot': 'symbol_0_1',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl40',
            'searchSpaceId': '5',
            'searchSpaceType': 'Type1',
            'slotOffset': '26'
        },
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '4',
            'monitoringSymbolWithinSlot': 'symbol_0',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl10',
            'searchSpaceId': '6',
            'searchSpaceType': 'Type2',
            'slotOffset': '6'
        }
    ],
    dist_name=f'{_NRBTSname}/BWP_PROFILE-7002/PDCCH-1/PDCCH_CONFIG_COMMON-1',
    parameter='searchSpaceCommon')

tmp_EDA_04474899_variable_7003 = dict(
    value=[
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '9',
            'monitoringSymbolWithinSlot': 'symbol_0',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl10',
            'searchSpaceId': '9',
            'searchSpaceType': 'Type0A',
            'slotOffset': '4'
        },
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '1',
            'monitoringSymbolWithinSlot': 'symbol_0_1',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl40',
            'searchSpaceId': '10',
            'searchSpaceType': 'Type1',
            'slotOffset': '26'
        },
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '4',
            'monitoringSymbolWithinSlot': 'symbol_0',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl10',
            'searchSpaceId': '11',
            'searchSpaceType': 'Type2',
            'slotOffset': '6'
        }
    ],
    dist_name=f'{_NRBTSname}/BWP_PROFILE-7003/PDCCH-1/PDCCH_CONFIG_COMMON-1',
    parameter='searchSpaceCommon')

tmp_EDA_04474899_variable_7004 = dict(
    value=[
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '9',
            'monitoringSymbolWithinSlot': 'symbol_0',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl10',
            'searchSpaceId': '14',
            'searchSpaceType': 'Type0A',
            'slotOffset': '4'
        },
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '1',
            'monitoringSymbolWithinSlot': 'symbol_0_1',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl40',
            'searchSpaceId': '15',
            'searchSpaceType': 'Type1',
            'slotOffset': '26'
        },
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '4',
            'monitoringSymbolWithinSlot': 'symbol_0',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl10',
            'searchSpaceId': '16',
            'searchSpaceType': 'Type2',
            'slotOffset': '6'
        }
    ],
    dist_name=f'{_NRBTSname}/BWP_PROFILE-7004/PDCCH-1/PDCCH_CONFIG_COMMON-1',
    parameter='searchSpaceCommon')

tmp_EDA_04474899_variable_7001_recover = dict(
    value=[
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '9',
            'monitoringSymbolWithinSlot': 'symbol_0',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl10',
            'searchSpaceId': '1',
            'searchSpaceType': 'Type0A',
            'slotOffset': '4'
        },
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '1',
            'monitoringSymbolWithinSlot': 'symbol_0_1',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl1',
            'searchSpaceId': '2',
            'searchSpaceType': 'Type1',
            'slotOffset': '0'
        },
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '4',
            'monitoringSymbolWithinSlot': 'symbol_0',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl10',
            'searchSpaceId': '3',
            'searchSpaceType': 'Type2',
            'slotOffset': '6'
        }
    ],
    dist_name=f'{_NRBTSname}/BWP_PROFILE-7001/PDCCH-1/PDCCH_CONFIG_COMMON-1',
    parameter='searchSpaceCommon')

tmp_EDA_04474899_variable_7002_recover = dict(
    value=[
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '9',
            'monitoringSymbolWithinSlot': 'symbol_0',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl10',
            'searchSpaceId': '14',
            'searchSpaceType': 'Type0A',
            'slotOffset': '4'
        },
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '1',
            'monitoringSymbolWithinSlot': 'symbol_0_1',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl1',
            'searchSpaceId': '5',
            'searchSpaceType': 'Type1',
            'slotOffset': '0'
        },
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '4',
            'monitoringSymbolWithinSlot': 'symbol_0',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl10',
            'searchSpaceId': '6',
            'searchSpaceType': 'Type2',
            'slotOffset': '6'
        }
    ],
    dist_name=f'{_NRBTSname}/BWP_PROFILE-7002/PDCCH-1/PDCCH_CONFIG_COMMON-1',
    parameter='searchSpaceCommon')

tmp_EDA_04474899_variable_7003_recover = dict(
    value=[
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '9',
            'monitoringSymbolWithinSlot': 'symbol_0',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl10',
            'searchSpaceId': '9',
            'searchSpaceType': 'Type0A',
            'slotOffset': '4'
        },
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '1',
            'monitoringSymbolWithinSlot': 'symbol_0_1',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl1',
            'searchSpaceId': '10',
            'searchSpaceType': 'Type1',
            'slotOffset': '0'
        },
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '4',
            'monitoringSymbolWithinSlot': 'symbol_0',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl10',
            'searchSpaceId': '11',
            'searchSpaceType': 'Type2',
            'slotOffset': '6'
        }
    ],
    dist_name=f'{_NRBTSname}/BWP_PROFILE-7003/PDCCH-1/PDCCH_CONFIG_COMMON-1',
    parameter='searchSpaceCommon')

tmp_EDA_04474899_variable_7004_recover = dict(
    value=[
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '9',
            'monitoringSymbolWithinSlot': 'symbol_0',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl10',
            'searchSpaceId': '14',
            'searchSpaceType': 'Type0A',
            'slotOffset': '4'
        },
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '1',
            'monitoringSymbolWithinSlot': 'symbol_0_1',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl1',
            'searchSpaceId': '15',
            'searchSpaceType': 'Type1',
            'slotOffset': '0'
        },
        {
            'coresetId': '0',
            'dciFormat': 'formats0-0-And-1-0',
            'duration': '4',
            'monitoringSymbolWithinSlot': 'symbol_0',
            'numOfPdcchCandidatesInAL2': 'n0',
            'numOfPdcchCandidatesInAL4': 'n2',
            'numOfPdcchCandidatesInAL8': 'n0',
            'numOfPdcchCandidatesInAL16': 'n0',
            'periodicity': 'sl10',
            'searchSpaceId': '16',
            'searchSpaceType': 'Type2',
            'slotOffset': '6'
        }
    ],
    dist_name=f'{_NRBTSname}/BWP_PROFILE-7004/PDCCH-1/PDCCH_CONFIG_COMMON-1',
    parameter='searchSpaceCommon')

tmp_EDA_04474899_variable_csiReportPeriodicity_348 = dict(
    value=[{'csiReportPeriodicity': 'slots40', 'csirsNumberWithinReportPeriod_Set1': '1', 'csirsPower': '4',
            'maxCsirsNumber': '4', 'scramblingIdStep': '3'}],
    dist_name=_NRCELL700name,
    parameter='periodicCsiAcquisition')

tmp_EDA_04474899_variable_csiReportPeriodicity_recover_348 = dict(
    value=[{'csiReportPeriodicity': 'slots320', 'csirsNumberWithinReportPeriod_Set1': '1', 'csirsPower': '4',
            'maxCsirsNumber': '4', 'scramblingIdStep': '3'}],
    dist_name=_NRCELL700name,
    parameter='periodicCsiAcquisition')

tmp_EDA_04474899_variable_rbgLimit_348 = dict(
    value=[{'dataBufferThreshold': '60000', 'endMcs': '28', 'prbAllocationDirection': 'highPerforming_High2low',
            'rank': '2', 'rbgLimit': '0', 'startMcs': '20'}],
    dist_name=_NRCELL700name,
    parameter='dlInterferenceAvoidance')

tmp_EDA_04474899_variable_rbgLimit_recover_348 = dict(
    value=[{'dataBufferThreshold': '60000', 'endMcs': '28', 'prbAllocationDirection': 'highPerforming_High2low',
            'rank': '2', 'rbgLimit': '0', 'startMcs': '20'}],
    dist_name=_NRCELL700name,
    parameter='dlInterferenceAvoidance')

tmp_EDA_04474899_348 = [
    dict(value='true', dist_name=_NRBTSname, parameter='actTddCsiRsOpt'),
    dict(value='true', dist_name=_NRBTSname, parameter='actTddCsiImRm'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actCsiRsMuting'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actSmallestRRCSetup'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actRat1Alloc'),
    dict(value='0', dist_name=_NRCELL700name, parameter='percRedSEDlRat1VoNR'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL'),
    dict(value='Locked', dist_name=_NRCELL701name, parameter='administrativeState'),
]

tmp_EDA_04474899_recover_348 = [
    dict(value='true', dist_name=_NRBTSname, parameter='actTddCsiRsOpt'),
    dict(value='false', dist_name=_NRBTSname, parameter='actTddCsiImRm'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actCsiRsMuting'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actSmallestRRCSetup'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actRat1Alloc'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL'),
    dict(value='Unlocked', dist_name=_NRCELL701name, parameter='administrativeState'),
]

tmp_EDA_04474899_recover_delete_348 = [
    dict(dist_name=_NRCELL700name, parameter='percRedSEDlRat1VoNR'),
]

PARAM_12149_delete_gnb1_BB_02_initial = [
    dict(dist_name=_NRRELLnamegnb13, parameter='sCellAdditionMethod'),
    dict(dist_name=_NRRELLnamegnb13, parameter='sCellOperationalMode'),
]

PARAM_12149_gnb1_BB_02_348 = [
    dict(value='disabled', dist_name=_NRBTSname, parameter='actBufferBasedSCellAddition'),
    dict(value='4', dist_name=_NRCELL2name, parameter='maxNumScellsDlFr1'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    dict(value='false', dist_name=_NRCELL3name, parameter='actLAForHiReliab'),
    dict(value='infinity', dist_name=_NRCELL2name, parameter='sCellDeactivationTimerGNB'),
    dict(value='infinity', dist_name=_NRCELL3name, parameter='sCellDeactivationTimerGNB'),
    dict(value='1TTI', dist_name=_NRCELL2name, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL3name, parameter='sCellActivationLevel'),
    dict(value='5TTI', dist_name=_NRCELL2name, parameter='sCellActivationLevelUL'),
    dict(value='5TTI', dist_name=_NRCELL3name, parameter='sCellActivationLevelUL'),
    dict(value='longPucch', dist_name=_NRCELL2name, parameter='pucchModeSelect'),
    dict(value='longPucch', dist_name=_NRCELL3name, parameter='pucchModeSelect'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcs'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actAdaptiveReTxResMcs'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='false', dist_name=_NRCELL3name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actShortBsrLimitAdaptation'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actShortBsrLimitAdaptation'),
    dict(value='slots20', dist_name=_NRCELL2name, parameter='srPeriodicity'),
    dict(value='true', dist_name=_NRCELL2_FDD1, parameter='actPerCsiReportBundlingFdd'),
    dict(value='zeroDot15', dist_name=_NRCELL2name, parameter='pucchF3MaxCodeRate'),
    dict(value='zeroDot15', dist_name=_NRCELL3name, parameter='pucchF3MaxCodeRate'),
    dict(value='qpsk_4psk', dist_name=_NRCELL2name, parameter='pucchF3ModulationScheme'),
    dict(value='qpsk_4psk', dist_name=_NRCELL3name, parameter='pucchF3ModulationScheme'),
    dict(value='true', dist_name=_NRCELL3name, parameter='increasePUSCHPrepTimeULCA'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actRescheduleBlockedRetx'),
    dict(value='1', dist_name=_NRCELL3name, parameter='maxNumOfUlCaUeParallelTx'),
    dict(value='true', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='50', dist_name=_NRBTSDUname, parameter='dlToUlContributionRatio'),
    dict(value='bufferBased', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='15', dist_name=_NRBTSname, parameter='ulTxSwitchingBoost'),
    dict(value='sf10', dist_name=_NRBTSname, parameter='periodicBSRTimer'),
    dict(value=['ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fdd', 'ca_Fdd_Any_Sa'],
         dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    dict(value=['ca_F_Fr1T_Sa_switchedUl'], dist_name=_NRBTSDUname, parameter='ulTxSwitchingSupportList'),
    dict(value=['A1-based'], dist_name=_NRBTSname, parameter='actMeasBasedSCellAdditionSa'),
    dict(value='covBasedA1', dist_name=_NRRELLnamegnb12, parameter='sCellAdditionMethod'),
    dict(value='covBasedA1', dist_name=_NRRELLnamegnb13, parameter='sCellAdditionMethod'),
    dict(value='dlAndUl', dist_name=_NRRELLnamegnb12, parameter='sCellOperationalMode'),
    dict(value='rsrp', dist_name=_NRCELL2name, parameter='a1MeasSCellAddEnabled'),
    # dict(value='false', dist_name=_NRCELL4name, parameter='increasePUSCHPrepTimeULCA'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_12149_recover_gnb1_BB_02_348 = [
    dict(value='oneShot_Dl_Fr1', dist_name=_NRBTSname, parameter='actBufferBasedSCellAddition'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actLAForHiReliab'),
    dict(value='infinity', dist_name=_NRCELL2name, parameter='sCellDeactivationTimerGNB'),
    dict(value='infinity', dist_name=_NRCELL3name, parameter='sCellDeactivationTimerGNB'),
    dict(value='1TTI', dist_name=_NRCELL2name, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL3name, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL2name, parameter='sCellActivationLevelUL'),
    dict(value='1TTI', dist_name=_NRCELL3name, parameter='sCellActivationLevelUL'),
    dict(value='longPucch', dist_name=_NRCELL2name, parameter='pucchModeSelect'),
    dict(value='longPucch', dist_name=_NRCELL3name, parameter='pucchModeSelect'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcs'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actAdaptiveReTxResMcs'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='false', dist_name=_NRCELL3name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actShortBsrLimitAdaptation'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actShortBsrLimitAdaptation'),
    dict(value='slots80', dist_name=_NRCELL2name, parameter='srPeriodicity'),
    dict(value='false', dist_name=_NRCELL2_FDD1, parameter='actPerCsiReportBundlingFdd'),
    dict(value='zeroDot15', dist_name=_NRCELL2name, parameter='pucchF3MaxCodeRate'),
    dict(value='zeroDot15', dist_name=_NRCELL3name, parameter='pucchF3MaxCodeRate'),
    dict(value='qpsk_4psk', dist_name=_NRCELL2name, parameter='pucchF3ModulationScheme'),
    dict(value='qpsk_4psk', dist_name=_NRCELL3name, parameter='pucchF3ModulationScheme'),
    dict(value='false', dist_name=_NRCELL3name, parameter='actRescheduleBlockedRetx'),
    dict(value='false', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='101', dist_name=_NRBTSDUname, parameter='dlToUlContributionRatio'),
    dict(value='bufferBased', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='15', dist_name=_NRBTSname, parameter='ulTxSwitchingBoost'),
    dict(value='sf10', dist_name=_NRBTSname, parameter='periodicBSRTimer'),
    dict(value=['ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Sa_WithUl'],
         dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    dict(value=['none'], dist_name=_NRBTSDUname, parameter='ulTxSwitchingSupportList'),
    dict(value=['disabled'], dist_name=_NRBTSname, parameter='actMeasBasedSCellAdditionSa'),
    dict(value='none', dist_name=_NRCELL2name, parameter='a1MeasSCellAddEnabled'),
    # dict(value='true', dist_name=_NRCELL4name, parameter='increasePUSCHPrepTimeULCA'),
    dict(value='blind', dist_name=_NRRELLnamegnb13, parameter='sCellAdditionMethod'),
    dict(value='dlAndUl', dist_name=_NRRELLnamegnb13, parameter='sCellOperationalMode'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_12149_gnb1_BB_02_383 = [
    dict(value='disabled', dist_name=_NRBTSname, parameter='actBufferBasedSCellAddition'),
    dict(value='4', dist_name=_NRCELLname, parameter='maxNumScellsDlFr1'),
    dict(value='false', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    dict(value='infinity', dist_name=_NRCELLname, parameter='sCellDeactivationTimerGNB'),
    dict(value='infinity', dist_name=_NRCELL2name, parameter='sCellDeactivationTimerGNB'),
    dict(value='1TTI', dist_name=_NRCELLname, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL2name, parameter='sCellActivationLevel'),
    dict(value='5TTI', dist_name=_NRCELLname, parameter='sCellActivationLevelUL'),
    dict(value='5TTI', dist_name=_NRCELL2name, parameter='sCellActivationLevelUL'),
    dict(value='longPucch', dist_name=_NRCELLname, parameter='pucchModeSelect'),
    dict(value='longPucch', dist_name=_NRCELL2name, parameter='pucchModeSelect'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELLname, parameter='actAdaptiveReTxResMcs'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcs'),
    dict(value='false', dist_name=_NRCELLname, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELLname, parameter='actShortBsrLimitAdaptation'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actShortBsrLimitAdaptation'),
    dict(value='slots20', dist_name=_NRCELLname, parameter='srPeriodicity'),
    dict(value='true', dist_name=_NRCELL1_FDD1, parameter='actPerCsiReportBundlingFdd'),
    dict(value='zeroDot15', dist_name=_NRCELLname, parameter='pucchF3MaxCodeRate'),
    dict(value='zeroDot15', dist_name=_NRCELL2name, parameter='pucchF3MaxCodeRate'),
    dict(value='qpsk_4psk', dist_name=_NRCELLname, parameter='pucchF3ModulationScheme'),
    dict(value='qpsk_4psk', dist_name=_NRCELL2name, parameter='pucchF3ModulationScheme'),
    dict(value='true', dist_name=_NRCELL2name, parameter='increasePUSCHPrepTimeULCA'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actRescheduleBlockedRetx'),
    dict(value='1', dist_name=_NRCELL2name, parameter='maxNumOfUlCaUeParallelTx'),
    dict(value='true', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='50', dist_name=_NRBTSDUname, parameter='dlToUlContributionRatio'),
    dict(value='bufferBased', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='15', dist_name=_NRBTSname, parameter='ulTxSwitchingBoost'),
    dict(value='sf10', dist_name=_NRBTSname, parameter='periodicBSRTimer'),
    dict(value=['ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fdd', 'ca_Fdd_Any_Sa', 'ca_Fdd_Fr1Tdd_Sa_WithUl'],
         dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    dict(value=['ca_F_Fr1T_Sa_switchedUl'], dist_name=_NRBTSDUname, parameter='ulTxSwitchingSupportList'),
    dict(value=['A1-based'], dist_name=_NRBTSname, parameter='actMeasBasedSCellAdditionSa'),
    dict(value='covBasedA1', dist_name=_NRREL2namegnb1, parameter='sCellAdditionMethod'),
    dict(value='dlAndUl', dist_name=_NRREL2namegnb1, parameter='sCellOperationalMode'),
    dict(value='rsrp', dist_name=_NRCELLname, parameter='a1MeasSCellAddEnabled'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL'),
    dict(value='slots20', dist_name=_NRCELLname, parameter='preferredVoNrSrPeriod'),
    dict(value='slots10', dist_name=_NRCELLname, parameter='srPeriodicityMin'),
    dict(value='n25600', dist_name=_NRCELL2name, parameter='timingAdvanceOffset'),
    dict(value='n25600', dist_name=_NRCELL21name, parameter='timingAdvanceOffset'),
    dict(value='Locked', dist_name=_NRCELL21name, parameter='administrativeState'),
]

PARAM_12149_recover_gnb1_BB_02_383 = [
    dict(value='oneShot_Dl_Fr1', dist_name=_NRBTSname, parameter='actBufferBasedSCellAddition'),
    dict(value='true', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    dict(value='ms1280', dist_name=_NRCELLname, parameter='sCellDeactivationTimerGNB'),
    dict(value='ms1280', dist_name=_NRCELL2name, parameter='sCellDeactivationTimerGNB'),
    dict(value='1TTI', dist_name=_NRCELLname, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL2name, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELLname, parameter='sCellActivationLevelUL'),
    dict(value='1TTI', dist_name=_NRCELL2name, parameter='sCellActivationLevelUL'),
    dict(value='longPucch', dist_name=_NRCELLname, parameter='pucchModeSelect'),
    dict(value='longPucch', dist_name=_NRCELL2name, parameter='pucchModeSelect'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELLname, parameter='actAdaptiveReTxResMcs'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcs'),
    dict(value='false', dist_name=_NRCELLname, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELLname, parameter='actShortBsrLimitAdaptation'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actShortBsrLimitAdaptation'),
    dict(value='slots80', dist_name=_NRCELLname, parameter='srPeriodicity'),
    dict(value='false', dist_name=_NRCELL1_FDD1, parameter='actPerCsiReportBundlingFdd'),
    dict(value='zeroDot15', dist_name=_NRCELLname, parameter='pucchF3MaxCodeRate'),
    dict(value='zeroDot15', dist_name=_NRCELL2name, parameter='pucchF3MaxCodeRate'),
    dict(value='qpsk_4psk', dist_name=_NRCELLname, parameter='pucchF3ModulationScheme'),
    dict(value='qpsk_4psk', dist_name=_NRCELL2name, parameter='pucchF3ModulationScheme'),
    dict(value='true', dist_name=_NRCELL2name, parameter='increasePUSCHPrepTimeULCA'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actRescheduleBlockedRetx'),
    dict(value='1', dist_name=_NRCELL2name, parameter='maxNumOfUlCaUeParallelTx'),
    dict(value='false', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='101', dist_name=_NRBTSDUname, parameter='dlToUlContributionRatio'),
    dict(value='bufferBased', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='15', dist_name=_NRBTSname, parameter='ulTxSwitchingBoost'),
    dict(value='sf10', dist_name=_NRBTSname, parameter='periodicBSRTimer'),
    dict(value=['ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Sa_WithUl'],
         dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    dict(value=['none'], dist_name=_NRBTSDUname, parameter='ulTxSwitchingSupportList'),
    dict(value=['A1-based'], dist_name=_NRBTSname, parameter='actMeasBasedSCellAdditionSa'),
    dict(value='none', dist_name=_NRCELLname, parameter='a1MeasSCellAddEnabled'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL'),
    dict(value='slots40', dist_name=_NRCELLname, parameter='preferredVoNrSrPeriod'),
    dict(value='slots40', dist_name=_NRCELLname, parameter='srPeriodicityMin'),
    dict(value='n39936', dist_name=_NRCELL2name, parameter='timingAdvanceOffset'),
    dict(value='n39936', dist_name=_NRCELL21name, parameter='timingAdvanceOffset'),
    dict(value='Unlocked', dist_name=_NRCELL21name, parameter='administrativeState'),
]

PARAM_12149_delete_gnb1_BB_02 = [
    dict(dist_name=_NRCELL2name, parameter='maxNumScellsDlFr1'),
    dict(dist_name=_NRRELLnamegnb12, parameter='sCellAdditionMethod'),
    dict(dist_name=_NRRELLnamegnb12, parameter='sCellOperationalMode'),
    dict(dist_name=_NRCELL3name, parameter='increasePUSCHPrepTimeULCA'),
    dict(dist_name=_NRCELL3name, parameter='maxNumOfUlCaUeParallelTx'),
]

PARAM_12149_delete_gnb1_BB_02_383 = [
    dict(dist_name=_NRCELLname, parameter='maxNumScellsDlFr1'),
    dict(dist_name=_NRREL2namegnb1, parameter='sCellAdditionMethod'),
    dict(dist_name=_NRREL2namegnb1, parameter='sCellOperationalMode'),
]

PARAM_12149_gnb1_BB_04_348 = [
    dict(value='disabled', dist_name=_NRBTSname, parameter='actBufferBasedSCellAddition'),
    dict(value='4', dist_name=_NRCELL2name, parameter='maxNumScellsDlFr1'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    dict(value='false', dist_name=_NRCELL3name, parameter='actLAForHiReliab'),
    dict(value='infinity', dist_name=_NRCELL2name, parameter='sCellDeactivationTimerGNB'),
    dict(value='infinity', dist_name=_NRCELL3name, parameter='sCellDeactivationTimerGNB'),
    dict(value='1TTI', dist_name=_NRCELL2name, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL3name, parameter='sCellActivationLevel'),
    dict(value='5TTI', dist_name=_NRCELL2name, parameter='sCellActivationLevelUL'),
    dict(value='5TTI', dist_name=_NRCELL3name, parameter='sCellActivationLevelUL'),
    dict(value='longPucch', dist_name=_NRCELL2name, parameter='pucchModeSelect'),
    dict(value='longPucch', dist_name=_NRCELL3name, parameter='pucchModeSelect'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcs'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actAdaptiveReTxResMcs'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='false', dist_name=_NRCELL3name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actShortBsrLimitAdaptation'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actShortBsrLimitAdaptation'),
    dict(value='slots20', dist_name=_NRCELL2name, parameter='srPeriodicity'),
    dict(value='true', dist_name=_NRCELL2_FDD1, parameter='actPerCsiReportBundlingFdd'),
    dict(value='zeroDot15', dist_name=_NRCELL2name, parameter='pucchF3MaxCodeRate'),
    dict(value='zeroDot15', dist_name=_NRCELL3name, parameter='pucchF3MaxCodeRate'),
    dict(value='qpsk_4psk', dist_name=_NRCELL2name, parameter='pucchF3ModulationScheme'),
    dict(value='qpsk_4psk', dist_name=_NRCELL3name, parameter='pucchF3ModulationScheme'),
    dict(value='true', dist_name=_NRCELL3name, parameter='increasePUSCHPrepTimeULCA'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actRescheduleBlockedRetx'),
    dict(value='1', dist_name=_NRCELL3name, parameter='maxNumOfUlCaUeParallelTx'),
    dict(value='true', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='50', dist_name=_NRBTSDUname, parameter='dlToUlContributionRatio'),
    dict(value='bufferBased', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='15', dist_name=_NRBTSname, parameter='ulTxSwitchingBoost'),
    dict(value='sf10', dist_name=_NRBTSname, parameter='periodicBSRTimer'),
    dict(value=['ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fdd', 'ca_Fdd_Any_Sa'],
         dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    dict(value=['ca_F_Fr1T_Sa_switchedUl'], dist_name=_NRBTSDUname, parameter='ulTxSwitchingSupportList'),
    dict(value='blind', dist_name=_NRRELLnamegnb12, parameter='sCellAdditionMethod'),
    dict(value='dlAndUl', dist_name=_NRRELLnamegnb12, parameter='sCellOperationalMode'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_12149_recover_gnb1_BB_04_348 = [
    dict(value='oneShot_Dl_Fr1', dist_name=_NRBTSname, parameter='actBufferBasedSCellAddition'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actLAForHiReliab'),
    dict(value='infinity', dist_name=_NRCELL2name, parameter='sCellDeactivationTimerGNB'),
    dict(value='infinity', dist_name=_NRCELL3name, parameter='sCellDeactivationTimerGNB'),
    dict(value='1TTI', dist_name=_NRCELL2name, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL3name, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL2name, parameter='sCellActivationLevelUL'),
    dict(value='1TTI', dist_name=_NRCELL3name, parameter='sCellActivationLevelUL'),
    dict(value='longPucch', dist_name=_NRCELL2name, parameter='pucchModeSelect'),
    dict(value='longPucch', dist_name=_NRCELL3name, parameter='pucchModeSelect'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcs'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actAdaptiveReTxResMcs'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='false', dist_name=_NRCELL3name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actShortBsrLimitAdaptation'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actShortBsrLimitAdaptation'),
    dict(value='slots80', dist_name=_NRCELL2name, parameter='srPeriodicity'),
    dict(value='false', dist_name=_NRCELL2_FDD1, parameter='actPerCsiReportBundlingFdd'),
    dict(value='zeroDot15', dist_name=_NRCELL2name, parameter='pucchF3MaxCodeRate'),
    dict(value='zeroDot15', dist_name=_NRCELL3name, parameter='pucchF3MaxCodeRate'),
    dict(value='qpsk_4psk', dist_name=_NRCELL2name, parameter='pucchF3ModulationScheme'),
    dict(value='qpsk_4psk', dist_name=_NRCELL3name, parameter='pucchF3ModulationScheme'),
    dict(value='false', dist_name=_NRCELL3name, parameter='actRescheduleBlockedRetx'),
    dict(value='false', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='101', dist_name=_NRBTSDUname, parameter='dlToUlContributionRatio'),
    dict(value='bufferBased', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='15', dist_name=_NRBTSname, parameter='ulTxSwitchingBoost'),
    dict(value='sf10', dist_name=_NRBTSname, parameter='periodicBSRTimer'),
    dict(value=['ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Sa_WithUl'],
         dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    dict(value=['none'], dist_name=_NRBTSDUname, parameter='ulTxSwitchingSupportList'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_12149_delete_gnb1_BB_04_348 = [
    dict(dist_name=_NRCELL2name, parameter='maxNumScellsDlFr1'),
    dict(dist_name=_NRRELLnamegnb12, parameter='sCellAdditionMethod'),
    dict(dist_name=_NRRELLnamegnb12, parameter='sCellOperationalMode'),
    dict(dist_name=_NRCELL3name, parameter='increasePUSCHPrepTimeULCA'),
    dict(dist_name=_NRCELL3name, parameter='maxNumOfUlCaUeParallelTx'),
]

PARAM_12149_gnb1_BB_04_383 = [
    dict(value='disabled', dist_name=_NRBTSname, parameter='actBufferBasedSCellAddition'),
    dict(value='4', dist_name=_NRCELLname, parameter='maxNumScellsDlFr1'),
    dict(value='false', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    dict(value='infinity', dist_name=_NRCELLname, parameter='sCellDeactivationTimerGNB'),
    dict(value='infinity', dist_name=_NRCELL2name, parameter='sCellDeactivationTimerGNB'),
    dict(value='1TTI', dist_name=_NRCELLname, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL2name, parameter='sCellActivationLevel'),
    dict(value='5TTI', dist_name=_NRCELLname, parameter='sCellActivationLevelUL'),
    dict(value='5TTI', dist_name=_NRCELL2name, parameter='sCellActivationLevelUL'),
    dict(value='longPucch', dist_name=_NRCELLname, parameter='pucchModeSelect'),
    dict(value='longPucch', dist_name=_NRCELL2name, parameter='pucchModeSelect'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELLname, parameter='actAdaptiveReTxResMcs'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcs'),
    dict(value='false', dist_name=_NRCELLname, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELLname, parameter='actShortBsrLimitAdaptation'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actShortBsrLimitAdaptation'),
    dict(value='slots20', dist_name=_NRCELLname, parameter='srPeriodicity'),
    dict(value='true', dist_name=_NRCELL1_FDD1, parameter='actPerCsiReportBundlingFdd'),
    dict(value='zeroDot15', dist_name=_NRCELLname, parameter='pucchF3MaxCodeRate'),
    dict(value='zeroDot15', dist_name=_NRCELL2name, parameter='pucchF3MaxCodeRate'),
    dict(value='qpsk_4psk', dist_name=_NRCELLname, parameter='pucchF3ModulationScheme'),
    dict(value='qpsk_4psk', dist_name=_NRCELL2name, parameter='pucchF3ModulationScheme'),
    dict(value='true', dist_name=_NRCELL2name, parameter='increasePUSCHPrepTimeULCA'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actRescheduleBlockedRetx'),
    dict(value='1', dist_name=_NRCELL2name, parameter='maxNumOfUlCaUeParallelTx'),
    dict(value='true', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='50', dist_name=_NRBTSDUname, parameter='dlToUlContributionRatio'),
    dict(value='bufferBased', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='15', dist_name=_NRBTSname, parameter='ulTxSwitchingBoost'),
    dict(value='sf10', dist_name=_NRBTSname, parameter='periodicBSRTimer'),
    dict(value=['ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fdd', 'ca_Fdd_Any_Sa', 'ca_Fdd_Fr1Tdd_Sa_WithUl'],
         dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    dict(value=['ca_F_Fr1T_Sa_switchedUl'], dist_name=_NRBTSDUname, parameter='ulTxSwitchingSupportList'),
    dict(value='blind', dist_name=_NRREL2namegnb1, parameter='sCellAdditionMethod'),
    dict(value='dlAndUl', dist_name=_NRREL2namegnb1, parameter='sCellOperationalMode'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL'),
    dict(value='slots20', dist_name=_NRCELLname, parameter='preferredVoNrSrPeriod'),
    dict(value='slots10', dist_name=_NRCELLname, parameter='srPeriodicityMin'),
    dict(value='n25600', dist_name=_NRCELL2name, parameter='timingAdvanceOffset'),
    dict(value='n25600', dist_name=_NRCELL21name, parameter='timingAdvanceOffset'),
    dict(value='Locked', dist_name=_NRCELL21name, parameter='administrativeState'),
]

PARAM_12149_recover_gnb1_BB_04_383 = [
    dict(value='oneShot_Dl_Fr1', dist_name=_NRBTSname, parameter='actBufferBasedSCellAddition'),
    dict(value='true', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    dict(value='ms1280', dist_name=_NRCELLname, parameter='sCellDeactivationTimerGNB'),
    dict(value='ms1280', dist_name=_NRCELL2name, parameter='sCellDeactivationTimerGNB'),
    dict(value='1TTI', dist_name=_NRCELLname, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL2name, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELLname, parameter='sCellActivationLevelUL'),
    dict(value='1TTI', dist_name=_NRCELL2name, parameter='sCellActivationLevelUL'),
    dict(value='longPucch', dist_name=_NRCELLname, parameter='pucchModeSelect'),
    dict(value='longPucch', dist_name=_NRCELL2name, parameter='pucchModeSelect'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELLname, parameter='actAdaptiveReTxResMcs'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcs'),
    dict(value='false', dist_name=_NRCELLname, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELLname, parameter='actShortBsrLimitAdaptation'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actShortBsrLimitAdaptation'),
    dict(value='slots80', dist_name=_NRCELLname, parameter='srPeriodicity'),
    dict(value='false', dist_name=_NRCELL1_FDD1, parameter='actPerCsiReportBundlingFdd'),
    dict(value='zeroDot15', dist_name=_NRCELLname, parameter='pucchF3MaxCodeRate'),
    dict(value='zeroDot15', dist_name=_NRCELL2name, parameter='pucchF3MaxCodeRate'),
    dict(value='qpsk_4psk', dist_name=_NRCELLname, parameter='pucchF3ModulationScheme'),
    dict(value='qpsk_4psk', dist_name=_NRCELL2name, parameter='pucchF3ModulationScheme'),
    dict(value='true', dist_name=_NRCELL2name, parameter='increasePUSCHPrepTimeULCA'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actRescheduleBlockedRetx'),
    dict(value='1', dist_name=_NRCELL2name, parameter='maxNumOfUlCaUeParallelTx'),
    dict(value='false', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='101', dist_name=_NRBTSDUname, parameter='dlToUlContributionRatio'),
    dict(value='bufferBased', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='15', dist_name=_NRBTSname, parameter='ulTxSwitchingBoost'),
    dict(value='sf10', dist_name=_NRBTSname, parameter='periodicBSRTimer'),
    dict(value=['ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Sa_WithUl'],
         dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    dict(value=['none'], dist_name=_NRBTSDUname, parameter='ulTxSwitchingSupportList'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL'),
    dict(value='slots40', dist_name=_NRCELLname, parameter='preferredVoNrSrPeriod'),
    dict(value='slots40', dist_name=_NRCELLname, parameter='srPeriodicityMin'),
    dict(value='n39936', dist_name=_NRCELL2name, parameter='timingAdvanceOffset'),
    dict(value='n39936', dist_name=_NRCELL21name, parameter='timingAdvanceOffset'),
    dict(value='Unlocked', dist_name=_NRCELL21name, parameter='administrativeState'),
]

PARAM_12149_delete_gnb1_BB_04_383 = [
    dict(dist_name=_NRCELLname, parameter='maxNumScellsDlFr1'),
    dict(dist_name=_NRREL2namegnb1, parameter='sCellAdditionMethod'),
    dict(dist_name=_NRREL2namegnb1, parameter='sCellOperationalMode'),
]

PARAM_12149_gnb1_72a_to_72e = [
    dict(value='true', dist_name=_NRCELL700name, parameter='actEcpri72e'),
    dict(value='true', dist_name=_NRCELL701name, parameter='actEcpri72e'),
    dict(value='16Rx', dist_name=_NRCELL700name, parameter='numberOfRxBeamforming'),
    dict(value='16Rx', dist_name=_NRCELL701name, parameter='numberOfRxBeamforming'),
    dict(value='true', dist_name=_LCELNR_4, parameter='actSimplChConfMAA'),
    dict(value='true', dist_name=_LCELNR_16, parameter='actSimplChConfMAA'),
]

OBJECT_DELETE_12149_gnb1_72a_to_72e = [
    dict(dist_name=_CHANNEL_4_1_2),
    dict(dist_name=_CHANNEL_4_1_3),
    dict(dist_name=_CHANNEL_4_1_4),
    dict(dist_name=_CHANNEL_4_1_5),
    dict(dist_name=_CHANNEL_4_1_6),
    dict(dist_name=_CHANNEL_4_1_7),
    dict(dist_name=_CHANNEL_4_1_8),
    dict(dist_name=_CHANNELGROUP_4_2),
    dict(dist_name=_CHANNELGROUP_4_3),
    dict(dist_name=_CHANNELGROUP_4_4),
    dict(dist_name=_CHANNEL_16_1_2),
    dict(dist_name=_CHANNEL_16_1_3),
    dict(dist_name=_CHANNEL_16_1_4),
    dict(dist_name=_CHANNEL_16_1_5),
    dict(dist_name=_CHANNEL_16_1_6),
    dict(dist_name=_CHANNEL_16_1_7),
    dict(dist_name=_CHANNEL_16_1_8),
    dict(dist_name=_CHANNELGROUP_16_2),
    dict(dist_name=_CHANNELGROUP_16_3),
    dict(dist_name=_CHANNELGROUP_16_4),
]

CB012149_72a_to_72e = [
    {
        "distName": _NRBTSname,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "cipherPrefL",
                "operation": "update",
                "value": [
                    dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')
                ]
            },
            {
                "parameterName": "integrityProtPrefL",
                "operation": "update",
                "value": [
                    dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')
                ]
            }
        ]
    },
    {
        "distName": _NRCELL700name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actEcpri72e",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "numberOfRxBeamforming",
                "value": "16Rx",
                "operation": "update"
            }
        ]
    },
    {
        "distName": _NRCELL701name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actEcpri72e",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "numberOfRxBeamforming",
                "value": "16Rx",
                "operation": "update"
            }
        ]
    },
    {
        "distName": _LCELNR_4,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actSimplChConfMAA",
                "operation": "update",
                "value": "true"
            }
        ]
    },
    {
        "distName": _LCELNR_16,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actSimplChConfMAA",
                "operation": "update",
                "value": "true"
            }
        ]
    },
    {
        "distName": _CHANNEL_4_1_2,
        "operation": "delete",
        "parameters": []
    },
    {
        "distName": _CHANNEL_4_1_3,
        "operation": "delete",
        "parameters": []
    },
    {
        "distName": _CHANNEL_4_1_4,
        "operation": "delete",
        "parameters": []
    },
    {
        "distName": _CHANNEL_4_1_5,
        "operation": "delete",
        "parameters": []
    },
    {
        "distName": _CHANNEL_4_1_6,
        "operation": "delete",
        "parameters": []
    },
    {
        "distName": _CHANNEL_4_1_7,
        "operation": "delete",
        "parameters": []
    },
    {
        "distName": _CHANNEL_4_1_8,
        "operation": "delete",
        "parameters": []
    },
    {
        "distName": _CHANNELGROUP_4_2,
        "operation": "delete",
        "parameters": []
    },
    {
        "distName": _CHANNELGROUP_4_3,
        "operation": "delete",
        "parameters": []
    },
    {
        "distName": _CHANNELGROUP_4_4,
        "operation": "delete",
        "parameters": []
    },
    {
        "distName": _CHANNEL_16_1_2,
        "operation": "delete",
        "parameters": []
    },
    {
        "distName": _CHANNEL_16_1_3,
        "operation": "delete",
        "parameters": []
    },
    {
        "distName": _CHANNEL_16_1_4,
        "operation": "delete",
        "parameters": []
    },
    {
        "distName": _CHANNEL_16_1_5,
        "operation": "delete",
        "parameters": []
    },
    {
        "distName": _CHANNEL_16_1_6,
        "operation": "delete",
        "parameters": []
    },
    {
        "distName": _CHANNEL_16_1_7,
        "operation": "delete",
        "parameters": []
    },
    {
        "distName": _CHANNEL_16_1_8,
        "operation": "delete",
        "parameters": []
    },
    {
        "distName": _CHANNELGROUP_16_2,
        "operation": "delete",
        "parameters": []
    },
    {
        "distName": _CHANNELGROUP_16_3,
        "operation": "delete",
        "parameters": []
    },
    {
        "distName": _CHANNELGROUP_16_4,
        "operation": "delete",
        "parameters": []
    }
]

PARAM_12149_gnb1_BB_10_348 = [
    dict(value='TypeB', dist_name=_NRCELL400name, parameter='puschMappingType'),
    dict(value='disabled', dist_name=_NRBTSname, parameter='actSCellReleaseForInactiveSCell'),
    dict(value='disabled', dist_name=_NRBTSname, parameter='actBufferBasedSCellAddition'),
    dict(value='4', dist_name=_NRCELL400name, parameter='maxNumScellsDlFr1'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actLAForHiReliab'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actLAForHiReliab'),
    dict(value='infinity', dist_name=_NRCELL400name, parameter='sCellDeactivationTimerGNB'),
    dict(value='infinity', dist_name=_NRCELL700name, parameter='sCellDeactivationTimerGNB'),
    dict(value='1TTI', dist_name=_NRCELL400name, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL700name, parameter='sCellActivationLevel'),
    dict(value='5TTI', dist_name=_NRCELL400name, parameter='sCellActivationLevelUL'),
    dict(value='5TTI', dist_name=_NRCELL700name, parameter='sCellActivationLevelUL'),
    dict(value='longPucch', dist_name=_NRCELL400name, parameter='pucchModeSelect'),
    dict(value='longPucch', dist_name=_NRCELL700name, parameter='pucchModeSelect'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actAdaptiveReTxResMcs'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actAdaptiveReTxResMcs'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actShortBsrLimitAdaptation'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actShortBsrLimitAdaptation'),
    dict(value='slots20', dist_name=_NRCELL400name, parameter='srPeriodicity'),
    dict(value='true', dist_name=_NRCELL400_FDD1, parameter='actPerCsiReportBundlingFdd'),
    dict(value='zeroDot15', dist_name=_NRCELL400name, parameter='pucchF3MaxCodeRate'),
    dict(value='zeroDot15', dist_name=_NRCELL700name, parameter='pucchF3MaxCodeRate'),
    dict(value='qpsk_4psk', dist_name=_NRCELL400name, parameter='pucchF3ModulationScheme'),
    dict(value='qpsk_4psk', dist_name=_NRCELL700name, parameter='pucchF3ModulationScheme'),
    dict(value='true', dist_name=_NRCELL700name, parameter='increasePUSCHPrepTimeULCA'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actRescheduleBlockedRetx'),
    dict(value='1', dist_name=_NRCELL700name, parameter='maxNumOfUlCaUeParallelTx'),
    dict(value='true', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='50', dist_name=_NRBTSDUname, parameter='dlToUlContributionRatio'),
    dict(value='bufferBased', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='15', dist_name=_NRBTSname, parameter='ulTxSwitchingBoost'),
    dict(value='sf10', dist_name=_NRBTSname, parameter='periodicBSRTimer'),
    dict(value=['ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fdd', 'ca_Fdd_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Any_Sa', 'ca_Fdd_Any_Sa',
                'ca_Fr1Tdd_Fdd_Nsa', 'ca_Fr1Tdd_Fdd_Sa', 'ca_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Sa_WithUl'],
         dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    dict(value=['ca_F_Fr1T_Sa_switchedUl'], dist_name=_NRBTSDUname, parameter='ulTxSwitchingSupportList'),
    dict(value='blind', dist_name=_NRRELL400namegnb12, parameter='sCellAdditionMethod'),
    dict(value='dlAndUl', dist_name=_NRRELL400namegnb12, parameter='sCellOperationalMode'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL'),
    dict(value='slots20', dist_name=_NRCELL400name, parameter='preferredVoNrSrPeriod'),
    dict(value='slots10', dist_name=_NRCELL400name, parameter='srPeriodicityMin'),
    dict(value='n25600', dist_name=_NRCELL400name, parameter='timingAdvanceOffset'),
    dict(value='n25600', dist_name=_NRCELL410name, parameter='timingAdvanceOffset'),
    dict(value='n25600', dist_name=_NRCELL700name, parameter='timingAdvanceOffset'),
    dict(value='n25600', dist_name=_NRCELL701name, parameter='timingAdvanceOffset'),
    dict(value='locked', dist_name=_LTECELL48040name, parameter='administrativeState'),
    dict(value='locked', dist_name=_LTECELL48045name, parameter='administrativeState'),
    dict(value='Locked', dist_name=_NRCELL701name, parameter='administrativeState'),
]

PARAM_12149_recover_gnb1_BB_10_348 = [
    dict(value='TypeB', dist_name=_NRCELL400name, parameter='puschMappingType'),
    dict(value='timer_based_Fr1', dist_name=_NRBTSname, parameter='actSCellReleaseForInactiveSCell'),
    dict(value='oneShot_Dl_Fr1', dist_name=_NRBTSname, parameter='actBufferBasedSCellAddition'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actLAForHiReliab'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actLAForHiReliab'),
    dict(value='infinity', dist_name=_NRCELL400name, parameter='sCellDeactivationTimerGNB'),
    dict(value='infinity', dist_name=_NRCELL700name, parameter='sCellDeactivationTimerGNB'),
    dict(value='1TTI', dist_name=_NRCELL400name, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL700name, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL400name, parameter='sCellActivationLevelUL'),
    dict(value='1TTI', dist_name=_NRCELL700name, parameter='sCellActivationLevelUL'),
    dict(value='longPucch', dist_name=_NRCELL400name, parameter='pucchModeSelect'),
    dict(value='longPucch', dist_name=_NRCELL700name, parameter='pucchModeSelect'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actAdaptiveReTxResMcs'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actAdaptiveReTxResMcs'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actShortBsrLimitAdaptation'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actShortBsrLimitAdaptation'),
    dict(value='slots80', dist_name=_NRCELL400name, parameter='srPeriodicity'),
    dict(value='false', dist_name=_NRCELL400_FDD1, parameter='actPerCsiReportBundlingFdd'),
    dict(value='zeroDot15', dist_name=_NRCELL400name, parameter='pucchF3MaxCodeRate'),
    dict(value='zeroDot15', dist_name=_NRCELL700name, parameter='pucchF3MaxCodeRate'),
    dict(value='qpsk_4psk', dist_name=_NRCELL400name, parameter='pucchF3ModulationScheme'),
    dict(value='qpsk_4psk', dist_name=_NRCELL700name, parameter='pucchF3ModulationScheme'),
    dict(value='true', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actRescheduleBlockedRetx'),
    dict(value='101', dist_name=_NRBTSDUname, parameter='dlToUlContributionRatio'),
    dict(value='bufferBased', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='15', dist_name=_NRBTSname, parameter='ulTxSwitchingBoost'),
    dict(value='sf10', dist_name=_NRBTSname, parameter='periodicBSRTimer'),
    dict(value=['ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fdd', 'ca_Fdd_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Any_Sa', 'ca_Fdd_Any_Sa',
                'ca_Fr1Tdd_Fdd_Nsa', 'ca_Fr1Tdd_Fdd_Sa', 'ca_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Sa_WithUl'],
         dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    dict(value=['none'], dist_name=_NRBTSDUname, parameter='ulTxSwitchingSupportList'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL'),
    dict(value='slots40', dist_name=_NRCELL400name, parameter='preferredVoNrSrPeriod'),
    dict(value='slots40', dist_name=_NRCELL400name, parameter='srPeriodicityMin'),
    dict(value='n0', dist_name=_NRCELL400name, parameter='timingAdvanceOffset'),
    dict(value='n0', dist_name=_NRCELL410name, parameter='timingAdvanceOffset'),
    dict(value='n39936', dist_name=_NRCELL700name, parameter='timingAdvanceOffset'),
    dict(value='n39936', dist_name=_NRCELL701name, parameter='timingAdvanceOffset'),
    dict(value='unlocked', dist_name=_LTECELL48040name, parameter='administrativeState'),
    dict(value='unlocked', dist_name=_LTECELL48045name, parameter='administrativeState'),
    dict(value='Unlocked', dist_name=_NRCELL701name, parameter='administrativeState'),
]

PARAM_12149_delete_gnb1_BB_10_348 = [
    dict(dist_name=_NRCELL400name, parameter='maxNumScellsDlFr1'),
    dict(dist_name=_NRRELL400namegnb12, parameter='sCellAdditionMethod'),
    dict(dist_name=_NRRELL400namegnb12, parameter='sCellOperationalMode'),
    dict(dist_name=_NRCELL700name, parameter='increasePUSCHPrepTimeULCA'),
    dict(dist_name=_NRCELL700name, parameter='maxNumOfUlCaUeParallelTx'),
]

PARAM_12149_gnb1_BB_10_383 = [
    dict(value='TypeB', dist_name=_NRCELLname, parameter='puschMappingType'),
    dict(value='disabled', dist_name=_NRBTSname, parameter='actBufferBasedSCellAddition'),
    dict(value='4', dist_name=_NRCELLname, parameter='maxNumScellsDlFr1'),
    dict(value='false', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    dict(value='infinity', dist_name=_NRCELLname, parameter='sCellDeactivationTimerGNB'),
    dict(value='infinity', dist_name=_NRCELL2name, parameter='sCellDeactivationTimerGNB'),
    dict(value='1TTI', dist_name=_NRCELLname, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL2name, parameter='sCellActivationLevel'),
    dict(value='5TTI', dist_name=_NRCELLname, parameter='sCellActivationLevelUL'),
    dict(value='5TTI', dist_name=_NRCELL2name, parameter='sCellActivationLevelUL'),
    dict(value='longPucch', dist_name=_NRCELLname, parameter='pucchModeSelect'),
    dict(value='longPucch', dist_name=_NRCELL2name, parameter='pucchModeSelect'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELLname, parameter='actAdaptiveReTxResMcs'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcs'),
    dict(value='false', dist_name=_NRCELLname, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELLname, parameter='actShortBsrLimitAdaptation'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actShortBsrLimitAdaptation'),
    dict(value='slots20', dist_name=_NRCELLname, parameter='srPeriodicity'),
    dict(value='true', dist_name=_NRCELL1_FDD1, parameter='actPerCsiReportBundlingFdd'),
    dict(value='zeroDot15', dist_name=_NRCELLname, parameter='pucchF3MaxCodeRate'),
    dict(value='zeroDot15', dist_name=_NRCELL2name, parameter='pucchF3MaxCodeRate'),
    dict(value='qpsk_4psk', dist_name=_NRCELLname, parameter='pucchF3ModulationScheme'),
    dict(value='qpsk_4psk', dist_name=_NRCELL2name, parameter='pucchF3ModulationScheme'),
    dict(value='true', dist_name=_NRCELL2name, parameter='increasePUSCHPrepTimeULCA'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actRescheduleBlockedRetx'),
    dict(value='1', dist_name=_NRCELL2name, parameter='maxNumOfUlCaUeParallelTx'),
    dict(value='true', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='50', dist_name=_NRBTSDUname, parameter='dlToUlContributionRatio'),
    dict(value='bufferBased', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='15', dist_name=_NRBTSname, parameter='ulTxSwitchingBoost'),
    dict(value='sf10', dist_name=_NRBTSname, parameter='periodicBSRTimer'),
    dict(value=['ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fdd', 'ca_Fdd_Any_Sa', 'ca_Fdd_Fr1Tdd_Sa_WithUl'],
         dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    dict(value=['ca_F_Fr1T_Sa_switchedUl'], dist_name=_NRBTSDUname, parameter='ulTxSwitchingSupportList'),
    dict(value='blind', dist_name=_NRREL2namegnb1, parameter='sCellAdditionMethod'),
    dict(value='dlAndUl', dist_name=_NRREL2namegnb1, parameter='sCellOperationalMode'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL'),
    dict(value='slots20', dist_name=_NRCELLname, parameter='preferredVoNrSrPeriod'),
    dict(value='slots10', dist_name=_NRCELLname, parameter='srPeriodicityMin'),
    dict(value='n25600', dist_name=_NRCELL2name, parameter='timingAdvanceOffset'),
    dict(value='n25600', dist_name=_NRCELL21name, parameter='timingAdvanceOffset'),
    dict(value='Locked', dist_name=_NRCELL21name, parameter='administrativeState'),
]

PARAM_12149_recover_gnb1_BB_10_383 = [
    dict(value='TypeA', dist_name=_NRCELLname, parameter='puschMappingType'),
    dict(value='oneShot_Dl_Fr1', dist_name=_NRBTSname, parameter='actBufferBasedSCellAddition'),
    dict(value='true', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    dict(value='ms1280', dist_name=_NRCELLname, parameter='sCellDeactivationTimerGNB'),
    dict(value='ms1280', dist_name=_NRCELL2name, parameter='sCellDeactivationTimerGNB'),
    dict(value='1TTI', dist_name=_NRCELLname, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL2name, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELLname, parameter='sCellActivationLevelUL'),
    dict(value='1TTI', dist_name=_NRCELL2name, parameter='sCellActivationLevelUL'),
    dict(value='longPucch', dist_name=_NRCELLname, parameter='pucchModeSelect'),
    dict(value='longPucch', dist_name=_NRCELL2name, parameter='pucchModeSelect'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELLname, parameter='actAdaptiveReTxResMcs'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcs'),
    dict(value='false', dist_name=_NRCELLname, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELLname, parameter='actShortBsrLimitAdaptation'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actShortBsrLimitAdaptation'),
    dict(value='slots80', dist_name=_NRCELLname, parameter='srPeriodicity'),
    dict(value='false', dist_name=_NRCELL1_FDD1, parameter='actPerCsiReportBundlingFdd'),
    dict(value='zeroDot15', dist_name=_NRCELLname, parameter='pucchF3MaxCodeRate'),
    dict(value='zeroDot15', dist_name=_NRCELL2name, parameter='pucchF3MaxCodeRate'),
    dict(value='qpsk_4psk', dist_name=_NRCELLname, parameter='pucchF3ModulationScheme'),
    dict(value='qpsk_4psk', dist_name=_NRCELL2name, parameter='pucchF3ModulationScheme'),
    dict(value='true', dist_name=_NRCELL2name, parameter='increasePUSCHPrepTimeULCA'),
    dict(value='false', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actRescheduleBlockedRetx'),
    dict(value='1', dist_name=_NRCELL2name, parameter='maxNumOfUlCaUeParallelTx'),
    dict(value='101', dist_name=_NRBTSDUname, parameter='dlToUlContributionRatio'),
    dict(value='bufferBased', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='15', dist_name=_NRBTSname, parameter='ulTxSwitchingBoost'),
    dict(value='sf10', dist_name=_NRBTSname, parameter='periodicBSRTimer'),
    dict(value=['ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Sa_WithUl'],
         dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    dict(value=['none'], dist_name=_NRBTSDUname, parameter='ulTxSwitchingSupportList'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL'),
    dict(value='slots40', dist_name=_NRCELLname, parameter='preferredVoNrSrPeriod'),
    dict(value='slots40', dist_name=_NRCELLname, parameter='srPeriodicityMin'),
    dict(value='n39936', dist_name=_NRCELL2name, parameter='timingAdvanceOffset'),
    dict(value='n39936', dist_name=_NRCELL21name, parameter='timingAdvanceOffset'),
    dict(value='Unlocked', dist_name=_NRCELL21name, parameter='administrativeState'),
]

PARAM_12149_delete_gnb1_BB_10_383 = [
    dict(dist_name=_NRCELLname, parameter='maxNumScellsDlFr1'),
    dict(dist_name=_NRREL2namegnb1, parameter='sCellAdditionMethod'),
    dict(dist_name=_NRREL2namegnb1, parameter='sCellOperationalMode'),
]

LIST_12149_gnb1_DB_01_delete = [
    dict(dist_name=_NRCELL700name, list_name='tddFrameStructure', p_name='lteToNrFrameShift', index=0),
    dict(dist_name=_NRCELL700name, list_name='tddFrameStructure', p_name='frameStructureType', index=0),
    dict(dist_name=_NRCELL700name, list_name='tddFrameStructure', p_name='guardPeriodLength', index=0),
    dict(dist_name=_NRCELL700name, list_name='tddFrameStructure', p_name='tdLteUlDlConfig', index=0),
    dict(dist_name=_NRCELL701name, list_name='tddFrameStructure', p_name='lteToNrFrameShift', index=0),
    dict(dist_name=_NRCELL701name, list_name='tddFrameStructure', p_name='frameStructureType', index=0),
    dict(dist_name=_NRCELL701name, list_name='tddFrameStructure', p_name='guardPeriodLength', index=0),
    dict(dist_name=_NRCELL701name, list_name='tddFrameStructure', p_name='tdLteUlDlConfig', index=0),
]

LIST_12149_gnb1_DB_01_add = [
    dict(dist_name=_NRCELL700name, list_name='tddFrameStructure',
         elements={'frameStructureType': 'semiStatic', 'guardPeriodLength': '4Symbols',
                   'tdLteUlDlConfig': 'tdLteConfig2', 'ulDlDataSlotRatio': '4/6'}),
    dict(dist_name=_NRCELL701name, list_name='tddFrameStructure',
         elements={'frameStructureType': 'semiStatic', 'guardPeriodLength': '4Symbols',
                   'tdLteUlDlConfig': 'tdLteConfig2', 'ulDlDataSlotRatio': '4/6'})
]

LIST_12149_gnb1_DB_01_change_frame_Structure = [
    # dict(dist_name=_NRCELL700name, list_name='tddFrameStructure',
    #      elements=[dict(p_name='frameStructureType', value='semiStatic', index=0),
    #                dict(p_name='guardPeriodLength', value='4Symbols', index=0),
    #                dict(p_name='tdLteUlDlConfig', value='tdLteConfig2', index=0),
    #                # dict(p_name='ulDlDataSlotRatio', value='4/6', index=0)
    #                ]),
    # dict(dist_name=_NRCELL701name, list_name='tddFrameStructure',
    #      elements=[dict(p_name='frameStructureType', value='semiStatic', index=0),
    #                dict(p_name='guardPeriodLength', value='4Symbols', index=0),
    #                dict(p_name='tdLteUlDlConfig', value='tdLteConfig2', index=0),
    #                # dict(p_name='ulDlDataSlotRatio', value='4/6', index=0)
    #                ]),
    dict(dist_name=_NRCELL700name, list_name='cellBwpList',
         elements=[dict(p_name='actPdcchCceFragmentControl', value='false', index=0),
                   dict(p_name='actUpperThrAckNackFiltering', value='false', index=0),
                   dict(p_name='actUpperThrAckNackHrFiltering', value='false', index=0),
                   dict(p_name='bwpDN', value=_BWP_PROFILE_7005, index=0),
                   dict(p_name='cellBwpId', value='0', index=0),
                   dict(p_name='pdcchResourcePreference', value='peakRate', index=0),
                   dict(p_name='actPdcchCceFragmentControl', value='false', index=1),
                   dict(p_name='actUpperThrAckNackFiltering', value='true', index=1),
                   dict(p_name='actUpperThrAckNackHrFiltering', value='true', index=1),
                   dict(p_name='bwpDN', value=_BWP_PROFILE_7006, index=1),
                   dict(p_name='cellBwpId', value='1', index=1),
                   dict(p_name='pdcchBlockingThresholdDL', value='30', index=0),
                   dict(p_name='pdcchBlockingThresholdUL', value='30', index=0),
                   dict(p_name='pdcchFreeThresholdDL', value='50', index=0),
                   dict(p_name='pdcchFreeThresholdUL', value='50', index=0),
                   dict(p_name='pdcchResourcePreference', value='peakRate', index=1),
                   dict(p_name='actPdcchCceFragmentControl', value='false', index=2),
                   dict(p_name='actUpperThrAckNackFiltering', value='true', index=2),
                   dict(p_name='actUpperThrAckNackHrFiltering', value='true', index=2),
                   dict(p_name='bwpDN', value=_BWP_PROFILE_7007, index=2),
                   dict(p_name='cellBwpId', value='2', index=2),
                   dict(p_name='pdcchBlockingThresholdDL', value='30', index=1),
                   dict(p_name='pdcchBlockingThresholdUL', value='30', index=1),
                   dict(p_name='pdcchFreeThresholdDL', value='50', index=1),
                   dict(p_name='pdcchFreeThresholdUL', value='50', index=1),
                   dict(p_name='pdcchResourcePreference', value='peakRate', index=2),
                   dict(p_name='actPdcchCceFragmentControl', value='false', index=3),
                   dict(p_name='actUpperThrAckNackFiltering', value='true', index=3),
                   dict(p_name='actUpperThrAckNackHrFiltering', value='true', index=3),
                   dict(p_name='bwpDN', value=_BWP_PROFILE_7008, index=3),
                   dict(p_name='cellBwpId', value='3', index=3),
                   dict(p_name='pdcchBlockingThresholdDL', value='30', index=2),
                   dict(p_name='pdcchBlockingThresholdUL', value='30', index=2),
                   dict(p_name='pdcchFreeThresholdDL', value='50', index=2),
                   dict(p_name='pdcchFreeThresholdUL', value='50', index=2),
                   dict(p_name='pdcchResourcePreference', value='peakRate', index=3)]),
    dict(dist_name=_NRCELL701name, list_name='cellBwpList',
         elements=[dict(p_name='actPdcchCceFragmentControl', value='false', index=0),
                   dict(p_name='actUpperThrAckNackFiltering', value='false', index=0),
                   dict(p_name='actUpperThrAckNackHrFiltering', value='false', index=0),
                   dict(p_name='bwpDN', value=_BWP_PROFILE_7015, index=0),
                   dict(p_name='cellBwpId', value='0', index=0),
                   dict(p_name='pdcchResourcePreference', value='peakRate', index=0),
                   dict(p_name='actPdcchCceFragmentControl', value='false', index=1),
                   dict(p_name='actUpperThrAckNackFiltering', value='true', index=1),
                   dict(p_name='actUpperThrAckNackHrFiltering', value='true', index=1),
                   dict(p_name='bwpDN', value=_BWP_PROFILE_7016, index=1),
                   dict(p_name='cellBwpId', value='1', index=1),
                   dict(p_name='pdcchBlockingThresholdDL', value='30', index=0),
                   dict(p_name='pdcchBlockingThresholdUL', value='30', index=0),
                   dict(p_name='pdcchFreeThresholdDL', value='50', index=0),
                   dict(p_name='pdcchFreeThresholdUL', value='50', index=0),
                   dict(p_name='pdcchResourcePreference', value='peakRate', index=1),
                   dict(p_name='actPdcchCceFragmentControl', value='false', index=2),
                   dict(p_name='actUpperThrAckNackFiltering', value='true', index=2),
                   dict(p_name='actUpperThrAckNackHrFiltering', value='true', index=2),
                   dict(p_name='bwpDN', value=_BWP_PROFILE_7017, index=2),
                   dict(p_name='cellBwpId', value='2', index=2),
                   dict(p_name='pdcchBlockingThresholdDL', value='30', index=1),
                   dict(p_name='pdcchBlockingThresholdUL', value='30', index=1),
                   dict(p_name='pdcchFreeThresholdDL', value='50', index=1),
                   dict(p_name='pdcchFreeThresholdUL', value='50', index=1),
                   dict(p_name='pdcchResourcePreference', value='peakRate', index=2),
                   dict(p_name='actPdcchCceFragmentControl', value='false', index=3),
                   dict(p_name='actUpperThrAckNackFiltering', value='true', index=3),
                   dict(p_name='actUpperThrAckNackHrFiltering', value='true', index=3),
                   dict(p_name='bwpDN', value=_BWP_PROFILE_7018, index=3),
                   dict(p_name='cellBwpId', value='3', index=3),
                   dict(p_name='pdcchBlockingThresholdDL', value='30', index=2),
                   dict(p_name='pdcchBlockingThresholdUL', value='30', index=2),
                   dict(p_name='pdcchFreeThresholdDL', value='50', index=2),
                   dict(p_name='pdcchFreeThresholdUL', value='50', index=2),
                   dict(p_name='pdcchResourcePreference', value='peakRate', index=3)]),
    dict(dist_name=_NRCELL700name, list_name='fPdcchMonOccsnPo', value='5'),
    dict(dist_name=_NRCELL701name, list_name='fPdcchMonOccsnPo', value='5'),
]

LIST_12149_gnb1_DB_01_change_frame_Structure_2 = [
    dict(dist_name=_NRCELL700name, list_name='fPdcchMonOccsnPo', value='5'),
    dict(dist_name=_NRCELL701name, list_name='fPdcchMonOccsnPo', value='5'),
]

PARAM_12149_gnb1_DB_01_change_frame_Structure = [
    dict(value='false', dist_name=_NRBTSname, p_name='actNrRimRsResourcePooling'),
    dict(value='disabled', dist_name=_NRBTSname, p_name='actFlexibleBISlotDurationMode'),
    dict(value='TypeA', dist_name=_NRCELL400name, p_name='puschMappingType'),
    dict(value='TypeA', dist_name=_NRCELL700name, p_name='puschMappingType'),
    dict(value='false', dist_name=_NRCELL700name, p_name='actIncUlPdcchCapacity'),
    dict(value='disabled', dist_name=_NRCELL700name, p_name='actNrRim'),
    dict(value='2', dist_name=_NRCELL700name, p_name='pagingOffset'),
    dict(value='highUlBlerOrUlNackFloodBased', dist_name=_NRCELL700name, p_name='actBadUplinkRadioRedirect'),
    dict(value='false', dist_name=_NRCELL701name, p_name='actIncUlPdcchCapacity'),
    dict(value='disabled', dist_name=_NRCELL701name, p_name='actNrRim'),
    dict(value='2', dist_name=_NRCELL701name, p_name='pagingOffset'),
    dict(value='highUlBlerOrUlNackFloodBased', dist_name=_NRCELL701name, p_name='actBadUplinkRadioRedirect'),
]

PARAM_12149_gnb1_DB_01_delete_CELL_700 = dict(
    value=[{'lteToNrFrameShift': '0ms'}],
    dist_name=_NRCELL700name,
    parameter='tddFrameStructure')

PARAM_12149_gnb1_DB_01_delete_CELL_701 = dict(
    value=[{'lteToNrFrameShift': '0ms'}],
    dist_name=_NRCELL701name,
    parameter='tddFrameStructure')

PARAM_12149_gnb1_DB_01_change_frame_CELL_700_1 = dict(
    value=[dict(frameStructureType='semiStatic', guardPeriodLength='4Symbols', tdLteUlDlConfig='tdLteConfig2',
                ulDlDataSlotRatio='4/6')],
    dist_name=_NRCELL700name,
    parameter='tddFrameStructure')

PARAM_12149_gnb1_DB_01_change_frame_CELL_700_2 = dict(
    value=[dict(actPdcchCceFragmentControl='false', actUpperThrAckNackFiltering='false',
                actUpperThrAckNackHrFiltering='false', bwpDN=_BWP_PROFILE_7005, cellBwpId='0',
                pdcchResourcePreference='peakRate'),
           dict(actPdcchCceFragmentControl='false', actUpperThrAckNackFiltering='true',
                actUpperThrAckNackHrFiltering='true', bwpDN=_BWP_PROFILE_7006, cellBwpId='1',
                pdcchBlockingThresholdDL='30', pdcchBlockingThresholdUL='30', pdcchFreeThresholdDL='50',
                pdcchFreeThresholdUL='50', pdcchResourcePreference='peakRate'),
           dict(actPdcchCceFragmentControl='false', actUpperThrAckNackFiltering='true',
                actUpperThrAckNackHrFiltering='true', bwpDN=_BWP_PROFILE_7007, cellBwpId='2',
                pdcchBlockingThresholdDL='30', pdcchBlockingThresholdUL='30', pdcchFreeThresholdDL='50',
                pdcchFreeThresholdUL='50', pdcchResourcePreference='peakRate'),
           dict(actPdcchCceFragmentControl='false', actUpperThrAckNackFiltering='true',
                actUpperThrAckNackHrFiltering='true', bwpDN=_BWP_PROFILE_7008, cellBwpId='3',
                pdcchBlockingThresholdDL='30', pdcchBlockingThresholdUL='30', pdcchFreeThresholdDL='50',
                pdcchFreeThresholdUL='50', pdcchResourcePreference='peakRate'), ],
    dist_name=_NRCELL700name, parameter='cellBwpList')

PARAM_12149_gnb1_DB_01_change_frame_CELL_701_1 = dict(
    value=[dict(frameStructureType='semiStatic', guardPeriodLength='4Symbols', tdLteUlDlConfig='tdLteConfig2',
                ulDlDataSlotRatio='4/6')], dist_name=_NRCELL701name,
    parameter='tddFrameStructure')

PARAM_12149_gnb1_DB_01_change_frame_CELL_701_2 = dict(
    value=[dict(actPdcchCceFragmentControl='false', actUpperThrAckNackFiltering='false',
                actUpperThrAckNackHrFiltering='false', bwpDN=_BWP_PROFILE_7015, cellBwpId='0',
                pdcchResourcePreference='peakRate'),
           dict(actPdcchCceFragmentControl='false', actUpperThrAckNackFiltering='true',
                actUpperThrAckNackHrFiltering='true', bwpDN=_BWP_PROFILE_7016, cellBwpId='1',
                pdcchBlockingThresholdDL='30', pdcchBlockingThresholdUL='30', pdcchFreeThresholdDL='50',
                pdcchFreeThresholdUL='50', pdcchResourcePreference='peakRate'),
           dict(actPdcchCceFragmentControl='false', actUpperThrAckNackFiltering='true',
                actUpperThrAckNackHrFiltering='true', bwpDN=_BWP_PROFILE_7017, cellBwpId='2',
                pdcchBlockingThresholdDL='30', pdcchBlockingThresholdUL='30', pdcchFreeThresholdDL='50',
                pdcchFreeThresholdUL='50', pdcchResourcePreference='peakRate'),
           dict(actPdcchCceFragmentControl='false', actUpperThrAckNackFiltering='true',
                actUpperThrAckNackHrFiltering='true', bwpDN=_BWP_PROFILE_7018, cellBwpId='3',
                pdcchBlockingThresholdDL='30', pdcchBlockingThresholdUL='30', pdcchFreeThresholdDL='50',
                pdcchFreeThresholdUL='50', pdcchResourcePreference='peakRate'), ],
    dist_name=_NRCELL701name, parameter='cellBwpList')

PARAM_12149_gnb1_DB_01_change_frame_others = [
    dict(value='disabled', dist_name=_NRBTSname, parameter='actFlexibleBISlotDurationMode'),
    dict(value='TypeA', dist_name=_NRCELL400name, parameter='puschMappingType'),
    dict(value='TypeA', dist_name=_NRCELL700name, parameter='puschMappingType'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actIncUlPdcchCapacity'),
    dict(value='disabled', dist_name=_NRCELL700name, parameter='actNrRim'),
    dict(value='2', dist_name=_NRCELL700name, parameter='pagingOffset'),
    dict(value=['5'], dist_name=_NRCELL700name, parameter='fPdcchMonOccsnPo'),
    dict(value='highUlBlerOrUlNackFloodBased', dist_name=_NRCELL700name, parameter='actBadUplinkRadioRedirect'),
    dict(value='false', dist_name=_NRCELL701name, parameter='actIncUlPdcchCapacity'),
    dict(value='disabled', dist_name=_NRCELL701name, parameter='actNrRim'),
    dict(value='2', dist_name=_NRCELL701name, parameter='pagingOffset'),
    dict(value=['5'], dist_name=_NRCELL701name, parameter='fPdcchMonOccsnPo'),
    dict(value='highUlBlerOrUlNackFloodBased', dist_name=_NRCELL701name, parameter='actBadUplinkRadioRedirect'),
]

PARAM_12149_gnb1_DB_01_348 = [
    dict(value='true', dist_name=_NRCELL400name, parameter='actFullPwrMode'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actFullPwrMode'),
    dict(value='true', dist_name=_NRBTSname, parameter='actCoverageNonCoherentUes'),
    dict(value='disabled', dist_name=_NRBTSname, parameter='actSCellReleaseForInactiveSCell'),
    dict(value='disabled', dist_name=_NRBTSname, parameter='actBufferBasedSCellAddition'),
    dict(value='TypeA', dist_name=_NRCELL400name, parameter='puschMappingType'),
    dict(value='TypeA', dist_name=_NRCELL700name, parameter='puschMappingType'),
    dict(value='4', dist_name=_NRCELL400name, parameter='maxNumScellsDlFr1'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actLAForHiReliab'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actLAForHiReliab'),
    dict(value='infinity', dist_name=_NRCELL400name, parameter='sCellDeactivationTimerGNB'),
    dict(value='infinity', dist_name=_NRCELL700name, parameter='sCellDeactivationTimerGNB'),
    dict(value='1TTI', dist_name=_NRCELL400name, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL700name, parameter='sCellActivationLevel'),
    dict(value='5TTI', dist_name=_NRCELL400name, parameter='sCellActivationLevelUL'),
    dict(value='5TTI', dist_name=_NRCELL700name, parameter='sCellActivationLevelUL'),
    dict(value='longPucch', dist_name=_NRCELL400name, parameter='pucchModeSelect'),
    dict(value='longPucch', dist_name=_NRCELL700name, parameter='pucchModeSelect'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actAdaptiveReTxResMcs'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actAdaptiveReTxResMcs'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actShortBsrLimitAdaptation'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actShortBsrLimitAdaptation'),
    dict(value='slots20', dist_name=_NRCELL400name, parameter='srPeriodicity'),
    dict(value='true', dist_name=_NRCELL400_FDD1, parameter='actPerCsiReportBundlingFdd'),
    dict(value='zeroDot15', dist_name=_NRCELL400name, parameter='pucchF3MaxCodeRate'),
    dict(value='zeroDot15', dist_name=_NRCELL700name, parameter='pucchF3MaxCodeRate'),
    dict(value='qpsk_4psk', dist_name=_NRCELL400name, parameter='pucchF3ModulationScheme'),
    dict(value='qpsk_4psk', dist_name=_NRCELL700name, parameter='pucchF3ModulationScheme'),
    dict(value='true', dist_name=_NRCELL700name, parameter='increasePUSCHPrepTimeULCA'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actRescheduleBlockedRetx'),
    dict(value='1', dist_name=_NRCELL700name, parameter='maxNumOfUlCaUeParallelTx'),
    dict(value='true', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='50', dist_name=_NRBTSDUname, parameter='dlToUlContributionRatio'),
    dict(value='bufferBased', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='15', dist_name=_NRBTSname, parameter='ulTxSwitchingBoost'),
    dict(value='sf10', dist_name=_NRBTSname, parameter='periodicBSRTimer'),
    dict(value=['ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fdd', 'ca_Fdd_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Any_Sa', 'ca_Fdd_Any_Sa',
                'ca_Fr1Tdd_Fdd_Nsa', 'ca_Fr1Tdd_Fdd_Sa', 'ca_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Sa_WithUl'],
         dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    dict(value=['ca_F_Fr1T_Sa_switchedUl'], dist_name=_NRBTSDUname, parameter='ulTxSwitchingSupportList'),
    dict(value='covBasedA1', dist_name=_NRRELL400namegnb12, parameter='sCellAdditionMethod'),
    dict(value='dlAndUl', dist_name=_NRRELL400namegnb12, parameter='sCellOperationalMode'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL'),
    dict(value='slots20', dist_name=_NRCELL400name, parameter='preferredVoNrSrPeriod'),
    dict(value='slots10', dist_name=_NRCELL400name, parameter='srPeriodicityMin'),
    dict(value='n25600', dist_name=_NRCELL400name, parameter='timingAdvanceOffset'),
    dict(value='n25600', dist_name=_NRCELL410name, parameter='timingAdvanceOffset'),
    dict(value='n25600', dist_name=_NRCELL700name, parameter='timingAdvanceOffset'),
    dict(value='n25600', dist_name=_NRCELL701name, parameter='timingAdvanceOffset'),
    dict(value='locked', dist_name=_LTECELL48040name, parameter='administrativeState'),
    dict(value='locked', dist_name=_LTECELL48045name, parameter='administrativeState'),
    dict(value='Locked', dist_name=_NRCELL701name, parameter='administrativeState'),
]

PARAM_12149_recover_gnb1_DB_01_348 = [
    dict(value='true', dist_name=_NRCELL400name, parameter='actFullPwrMode'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actFullPwrMode'),
    dict(value='false', dist_name=_NRBTSname, parameter='actCoverageNonCoherentUes'),
    dict(value='timer_based_Fr1', dist_name=_NRBTSname, parameter='actSCellReleaseForInactiveSCell'),
    dict(value='oneShot_Dl_Fr1', dist_name=_NRBTSname, parameter='actBufferBasedSCellAddition'),
    dict(value='TypeB', dist_name=_NRCELL400name, parameter='puschMappingType'),
    dict(value='TypeB', dist_name=_NRCELL700name, parameter='puschMappingType'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actLAForHiReliab'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actLAForHiReliab'),
    dict(value='infinity', dist_name=_NRCELL400name, parameter='sCellDeactivationTimerGNB'),
    dict(value='infinity', dist_name=_NRCELL700name, parameter='sCellDeactivationTimerGNB'),
    dict(value='1TTI', dist_name=_NRCELL400name, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL700name, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL400name, parameter='sCellActivationLevelUL'),
    dict(value='1TTI', dist_name=_NRCELL700name, parameter='sCellActivationLevelUL'),
    dict(value='longPucch', dist_name=_NRCELL400name, parameter='pucchModeSelect'),
    dict(value='longPucch', dist_name=_NRCELL700name, parameter='pucchModeSelect'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actAdaptiveReTxResMcs'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actAdaptiveReTxResMcs'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actShortBsrLimitAdaptation'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actShortBsrLimitAdaptation'),
    dict(value='slots80', dist_name=_NRCELL400name, parameter='srPeriodicity'),
    dict(value='false', dist_name=_NRCELL400_FDD1, parameter='actPerCsiReportBundlingFdd'),
    dict(value='zeroDot15', dist_name=_NRCELL400name, parameter='pucchF3MaxCodeRate'),
    dict(value='zeroDot15', dist_name=_NRCELL700name, parameter='pucchF3MaxCodeRate'),
    dict(value='qpsk_4psk', dist_name=_NRCELL400name, parameter='pucchF3ModulationScheme'),
    dict(value='qpsk_4psk', dist_name=_NRCELL700name, parameter='pucchF3ModulationScheme'),
    dict(value='true', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actRescheduleBlockedRetx'),
    dict(value='101', dist_name=_NRBTSDUname, parameter='dlToUlContributionRatio'),
    dict(value='bufferBased', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='15', dist_name=_NRBTSname, parameter='ulTxSwitchingBoost'),
    dict(value='sf10', dist_name=_NRBTSname, parameter='periodicBSRTimer'),
    dict(value=['ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fdd', 'ca_Fdd_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Any_Sa', 'ca_Fdd_Any_Sa',
                'ca_Fr1Tdd_Fdd_Nsa', 'ca_Fr1Tdd_Fdd_Sa', 'ca_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Sa_WithUl'],
         dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    dict(value=['none'], dist_name=_NRBTSDUname, parameter='ulTxSwitchingSupportList'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL'),
    dict(value='slots40', dist_name=_NRCELL400name, parameter='preferredVoNrSrPeriod'),
    dict(value='slots40', dist_name=_NRCELL400name, parameter='srPeriodicityMin'),
    dict(value='n0', dist_name=_NRCELL400name, parameter='timingAdvanceOffset'),
    dict(value='n0', dist_name=_NRCELL410name, parameter='timingAdvanceOffset'),
    dict(value='n39936', dist_name=_NRCELL700name, parameter='timingAdvanceOffset'),
    dict(value='n39936', dist_name=_NRCELL701name, parameter='timingAdvanceOffset'),
    dict(value='unlocked', dist_name=_LTECELL48040name, parameter='administrativeState'),
    dict(value='unlocked', dist_name=_LTECELL48045name, parameter='administrativeState'),
    dict(value='Unlocked', dist_name=_NRCELL701name, parameter='administrativeState'),
]

PARAM_12149_delete_gnb1_DB_01_348 = [
    dict(dist_name=_NRCELL400name, parameter='maxNumScellsDlFr1'),
    dict(dist_name=_NRRELL400namegnb12, parameter='sCellAdditionMethod'),
    dict(dist_name=_NRRELL400namegnb12, parameter='sCellOperationalMode'),
    dict(dist_name=_NRCELL700name, parameter='increasePUSCHPrepTimeULCA'),
    dict(dist_name=_NRCELL700name, parameter='maxNumOfUlCaUeParallelTx'),
]

PARAM_12149_gnb1_DB_01_383 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actFullPwrMode'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actFullPwrMode'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlTransPreEnhRankSwitchIwk'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actUlTransPreEnhRankSwitchIwk'),
    dict(value='true', dist_name=_NRBTSname, parameter='actCoverageNonCoherentUes'),
    dict(value='disabled', dist_name=_NRBTSname, parameter='actBufferBasedSCellAddition'),
    dict(value='4', dist_name=_NRCELLname, parameter='maxNumScellsDlFr1'),
    dict(value='false', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    dict(value='infinity', dist_name=_NRCELLname, parameter='sCellDeactivationTimerGNB'),
    dict(value='infinity', dist_name=_NRCELL2name, parameter='sCellDeactivationTimerGNB'),
    dict(value='1TTI', dist_name=_NRCELLname, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL2name, parameter='sCellActivationLevel'),
    dict(value='5TTI', dist_name=_NRCELLname, parameter='sCellActivationLevelUL'),
    dict(value='5TTI', dist_name=_NRCELL2name, parameter='sCellActivationLevelUL'),
    dict(value='longPucch', dist_name=_NRCELLname, parameter='pucchModeSelect'),
    dict(value='longPucch', dist_name=_NRCELL2name, parameter='pucchModeSelect'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELLname, parameter='actAdaptiveReTxResMcs'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcs'),
    dict(value='false', dist_name=_NRCELLname, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELLname, parameter='actShortBsrLimitAdaptation'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actShortBsrLimitAdaptation'),
    dict(value='slots20', dist_name=_NRCELLname, parameter='srPeriodicity'),
    dict(value='true', dist_name=_NRCELL1_FDD1, parameter='actPerCsiReportBundlingFdd'),
    dict(value='zeroDot15', dist_name=_NRCELLname, parameter='pucchF3MaxCodeRate'),
    dict(value='zeroDot15', dist_name=_NRCELL2name, parameter='pucchF3MaxCodeRate'),
    dict(value='qpsk_4psk', dist_name=_NRCELLname, parameter='pucchF3ModulationScheme'),
    dict(value='qpsk_4psk', dist_name=_NRCELL2name, parameter='pucchF3ModulationScheme'),
    dict(value='true', dist_name=_NRCELL2name, parameter='increasePUSCHPrepTimeULCA'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actRescheduleBlockedRetx'),
    dict(value='1', dist_name=_NRCELL2name, parameter='maxNumOfUlCaUeParallelTx'),
    dict(value='true', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='50', dist_name=_NRBTSDUname, parameter='dlToUlContributionRatio'),
    dict(value='bufferBased', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='15', dist_name=_NRBTSname, parameter='ulTxSwitchingBoost'),
    dict(value='sf10', dist_name=_NRBTSname, parameter='periodicBSRTimer'),
    dict(value=['ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fdd', 'ca_Fdd_Any_Sa', 'ca_Fdd_Fr1Tdd_Sa_WithUl'],
         dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    dict(value=['ca_F_Fr1T_Sa_switchedUl'], dist_name=_NRBTSDUname, parameter='ulTxSwitchingSupportList'),
    dict(value=['A1-based'], dist_name=_NRBTSname, parameter='actMeasBasedSCellAdditionSa'),
    # sCellAdditionMethod: Conditional RAT reset
    dict(value='covBasedA1', dist_name=_NRREL2namegnb1, parameter='sCellAdditionMethod'),
    dict(value='dlAndUl', dist_name=_NRREL2namegnb1, parameter='sCellOperationalMode'),
    dict(value='rsrp', dist_name=_NRCELLname, parameter='a1MeasSCellAddEnabled'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL'),
    dict(value='slots20', dist_name=_NRCELLname, parameter='preferredVoNrSrPeriod'),
    dict(value='slots10', dist_name=_NRCELLname, parameter='srPeriodicityMin'),
    # timingAdvanceOffset: Conditional RAT reset
    dict(value='n25600', dist_name=_NRCELL2name, parameter='timingAdvanceOffset'),
    dict(value='n25600', dist_name=_NRCELL21name, parameter='timingAdvanceOffset'),
    dict(value='Locked', dist_name=_NRCELL21name, parameter='administrativeState'),
]

PARAM_12149_recover_gnb1_DB_01_383 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actFullPwrMode'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actFullPwrMode'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUlTransPreEnhRankSwitchIwk'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actUlTransPreEnhRankSwitchIwk'),
    dict(value='false', dist_name=_NRBTSname, parameter='actCoverageNonCoherentUes'),
    dict(value='oneShot_Dl_Fr1', dist_name=_NRBTSname, parameter='actBufferBasedSCellAddition'),
    dict(value='true', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    dict(value='ms1280', dist_name=_NRCELLname, parameter='sCellDeactivationTimerGNB'),
    dict(value='ms1280', dist_name=_NRCELL2name, parameter='sCellDeactivationTimerGNB'),
    dict(value='1TTI', dist_name=_NRCELLname, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL2name, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELLname, parameter='sCellActivationLevelUL'),
    dict(value='1TTI', dist_name=_NRCELL2name, parameter='sCellActivationLevelUL'),
    dict(value='longPucch', dist_name=_NRCELLname, parameter='pucchModeSelect'),
    dict(value='longPucch', dist_name=_NRCELL2name, parameter='pucchModeSelect'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELLname, parameter='actAdaptiveReTxResMcs'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcs'),
    dict(value='false', dist_name=_NRCELLname, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELLname, parameter='actShortBsrLimitAdaptation'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actShortBsrLimitAdaptation'),
    dict(value='slots80', dist_name=_NRCELLname, parameter='srPeriodicity'),
    dict(value='false', dist_name=_NRCELL1_FDD1, parameter='actPerCsiReportBundlingFdd'),
    dict(value='zeroDot15', dist_name=_NRCELLname, parameter='pucchF3MaxCodeRate'),
    dict(value='zeroDot15', dist_name=_NRCELL2name, parameter='pucchF3MaxCodeRate'),
    dict(value='qpsk_4psk', dist_name=_NRCELLname, parameter='pucchF3ModulationScheme'),
    dict(value='qpsk_4psk', dist_name=_NRCELL2name, parameter='pucchF3ModulationScheme'),
    dict(value='true', dist_name=_NRCELL2name, parameter='increasePUSCHPrepTimeULCA'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actRescheduleBlockedRetx'),
    dict(value='false', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='101', dist_name=_NRBTSDUname, parameter='dlToUlContributionRatio'),
    dict(value='bufferBased', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='15', dist_name=_NRBTSname, parameter='ulTxSwitchingBoost'),
    dict(value='sf10', dist_name=_NRBTSname, parameter='periodicBSRTimer'),
    dict(value=['ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Sa_WithUl'],
         dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    dict(value=['none'], dist_name=_NRBTSDUname, parameter='ulTxSwitchingSupportList'),
    dict(value=['A1-based'], dist_name=_NRBTSname, parameter='actMeasBasedSCellAdditionSa'),
    dict(value='none', dist_name=_NRCELLname, parameter='a1MeasSCellAddEnabled'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL'),
    dict(value='slots40', dist_name=_NRCELLname, parameter='preferredVoNrSrPeriod'),
    dict(value='slots40', dist_name=_NRCELLname, parameter='srPeriodicityMin'),
    dict(value='n39936', dist_name=_NRCELL2name, parameter='timingAdvanceOffset'),
    dict(value='n39936', dist_name=_NRCELL21name, parameter='timingAdvanceOffset'),
    dict(value='Unlocked', dist_name=_NRCELL21name, parameter='administrativeState'),
]

PARAM_12149_lte_common_383_WA = [
    dict(value='locked', dist_name=_LTECELLname, parameter='administrativeState'),
]

PARAM_12149_recover_lte_common_383_WA = [
    dict(value='unlocked', dist_name=_LTECELLname, parameter='administrativeState'),
]

PARAM_12149_delete_gnb1_DB_01_383 = [
    dict(dist_name=_NRCELLname, parameter='maxNumScellsDlFr1'),
    dict(dist_name=_NRREL2namegnb1, parameter='sCellAdditionMethod'),
    dict(dist_name=_NRREL2namegnb1, parameter='sCellOperationalMode'),
]

ParameterToDelete_12149_gnb1_BC_01 = [
    dict(dist_name=_NRBTSDUname, list_name='carrierAggregationSupportList'),
    dict(dist_name=_NRCELL2name, list_name='a1MeasSCellAddSsbRsrp'),
    dict(dist_name=_BWP_PROFILE_0),
    dict(dist_name=_NRCELL3name, list_name='cellBwpList'),
    dict(dist_name=_NRCELL4name, list_name='cellBwpList')
]

ListToModify_12149_gnb1_BC_01 = [
    dict(dist_name=_NRBTSname, list_name='actMeasBasedSCellAdditionSa',
         elements=[dict(p_name='', value='A1-based', index=0)
                   ]),
    dict(dist_name=_NRBTSname, list_name='cipherPrefL',
         elements=[dict(p_name='nea0', value='9', index=0),
                   dict(p_name='nea1_128', value='0', index=0),
                   dict(p_name='nea2_128', value='0', index=0),
                   dict(p_name='nea3_128', value='0', index=0),
                   ]),
    dict(dist_name=_NRBTSname, list_name='integrityProtPrefL',
         elements=[dict(p_name='nia0', value='0', index=0),
                   dict(p_name='nia1_128', value='9', index=0),
                   dict(p_name='nia2_128', value='0', index=0),
                   dict(p_name='nia3_128', value='0', index=0),
                   ]),
    dict(dist_name=_NRBTSDUname, list_name='ulTxSwitchingSupportList',
         elements=[dict(p_name='', value='ca_F_Fr1T_Sa_switchedUl', index=0)
                   ])
]

ListToAdd_12149_gnb1_BC_01 = [
    dict(
        dist_name=_NRCELL2name,
        list_name='a1MeasSCellAddSsbRsrp',
        elements=dict(
            a1HysteresisSCellAddSsbRsrp='0',
            a1ThresholdSCellAddSsbRsrpFDD='80',
            a1ThresholdSCellAddSsbRsrpTDD='80',
            a1ThresholdUlTxSwitchingDelta='2',
            a1TimeToTriggerSCellAddSsbRsrp='320ms')),
    dict(
        dist_name=_NRCELL3name,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            bwpDN=_NRBTSname + '/BWP_PROFILE-7',
            pdcchResourcePreference='peakRate',
            cellBwpId='0')
    ),
    dict(
        dist_name=_NRCELL3name,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='true',
            actUpperThrAckNackHrFiltering='true',
            bwpDN=_NRBTSname + '/BWP_PROFILE-8',
            pdcchResourcePreference='peakRate',
            cellBwpId='1')
    ),
    dict(
        dist_name=_NRCELL4name,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            bwpDN=_NRBTSname + '/BWP_PROFILE-7',
            pdcchResourcePreference='peakRate',
            cellBwpId='0')
    ),
    dict(
        dist_name=_NRCELL4name,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='true',
            actUpperThrAckNackHrFiltering='true',
            bwpDN=_NRBTSname + '/BWP_PROFILE-8',
            pdcchResourcePreference='peakRate',
            cellBwpId='1')
    ),
    dict(elements=['ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fdd', 'ca_Fdd_Any_Sa', 'ca_Fdd_Fr1Tdd_Sa_WithUl'],
         dist_name=_NRBTSDUname, list_name='carrierAggregationSupportList')
]

PARAM_12149_gnb1_BC_1_001 = [
    dict(value='4', dist_name=_NRCELL2name, p_name='maxNumScellsDlFr1'),
    dict(value='disabled', dist_name=_NRBTSname, p_name='actBufferBasedSCellAddition'),
    dict(value='false', dist_name=_NRCELL3name, p_name='actPowerSavingBWP'),
    dict(value='false', dist_name=_NRCELL3name, p_name='actInitialBWPFlexibility'),
    dict(value='false', dist_name=_NRCELL4name, p_name='actPowerSavingBWP'),
    dict(value='false', dist_name=_NRCELL4name, p_name='actInitialBWPFlexibility'),
    dict(value='rsrp', dist_name=_NRCELL2name, p_name='a1MeasSCellAddEnabled'),
    dict(value='false', dist_name=_NRCELL2name, p_name='actUlCgType2'),
    dict(value='false', dist_name=_NRCELL3name, p_name='actUlCgType2'),
    dict(value='Disabled', dist_name=_NRCELL2name, p_name='actUlSlotAgg'),
    dict(value='Disabled', dist_name=_NRCELL3name, p_name='actUlSlotAgg'),
    dict(value='true', dist_name=_NRCELL3name, p_name='increasePUSCHPrepTimeULCA'),
    dict(value='false', dist_name=_NRCELL2name, p_name='actAdaptiveReTxResMcs'),
    dict(value='false', dist_name=_NRCELL3name, p_name='actAdaptiveReTxResMcs'),
    dict(value='true', dist_name=_NRCELL2_FDD1, p_name='actPerCsiReportBundlingFdd'),
    dict(value='true', dist_name=_NRBTSDUname, p_name='actConnectedModeMobilityCA'),
    dict(value='50', dist_name=_NRBTSDUname, p_name='dlToUlContributionRatio'),
    dict(value='NumberCellAmount', dist_name=_NRBTSDUname, p_name='flexibleCAMode'),
    dict(value='bufferBased', dist_name=_NRBTSname, p_name='sCellActivationMethod'),
    dict(value='false', dist_name=_NRBTSname, p_name='actOverheatingAssistance'),
    dict(value='infinity', dist_name=_NRCELLname, p_name='sCellDeactivationTimerGNB'),
    dict(value='false', dist_name=_NRCELL3name, p_name='actEnhancedPDSCHSchSplSlot'),
    dict(value='covBasedA1', dist_name=_NRRELLnamegnb12, p_name='sCellAdditionMethod'),
    dict(value='dlAndUl', dist_name=_NRRELLnamegnb12, p_name='sCellOperationalMode')
]

PARAM_12149_gnb1_BC_1_001_new = [
    dict(value='4', dist_name=_NRCELL2name, p_name='maxNumScellsDlFr1'),
    dict(value='disabled', dist_name=_NRBTSname, p_name='actBufferBasedSCellAddition'),
    dict(value='false', dist_name=_NRCELL3name, p_name='actPowerSavingBWP'),
    dict(value='false', dist_name=_NRCELL3name, p_name='actInitialBWPFlexibility'),
    dict(value='false', dist_name=_NRCELL4name, p_name='actPowerSavingBWP'),
    dict(value='false', dist_name=_NRCELL4name, p_name='actInitialBWPFlexibility'),
    dict(value='rsrp', dist_name=_NRCELL2name, p_name='a1MeasSCellAddEnabled'),
    dict(value='false', dist_name=_NRCELL2name, p_name='actUlCgType2'),
    dict(value='false', dist_name=_NRCELL3name, p_name='actUlCgType2'),
    dict(value='Disabled', dist_name=_NRCELL2name, p_name='actUlSlotAgg'),
    dict(value='Disabled', dist_name=_NRCELL3name, p_name='actUlSlotAgg'),
    dict(value='true', dist_name=_NRCELL3name, p_name='increasePUSCHPrepTimeULCA'),
    dict(value='false', dist_name=_NRCELL2name, p_name='actAdaptiveReTxResMcs'),
    dict(value='false', dist_name=_NRCELL3name, p_name='actAdaptiveReTxResMcs'),
    dict(value='true', dist_name=_NRCELL2_FDD1, p_name='actPerCsiReportBundlingFdd'),
    dict(value='true', dist_name=_NRBTSDUname, p_name='actConnectedModeMobilityCA'),
    dict(value='50', dist_name=_NRBTSDUname, p_name='dlToUlContributionRatio'),
    dict(value='NumberCellAmount', dist_name=_NRBTSDUname, p_name='flexibleCAMode'),
    dict(value='bufferBased', dist_name=_NRBTSname, p_name='sCellActivationMethod'),
    dict(value='false', dist_name=_NRBTSname, p_name='actOverheatingAssistance'),
    dict(value='infinity', dist_name=_NRCELLname, p_name='sCellDeactivationTimerGNB'),
    dict(value='false', dist_name=_NRCELL3name, p_name='actEnhancedPDSCHSchSplSlot'),
    dict(value='covBasedA1', dist_name=_NRRELLnamegnb12, p_name='sCellAdditionMethod'),
    dict(value='covBasedA1', dist_name=_NRRELLnamegnb13, p_name='sCellAdditionMethod'),
    dict(value='dlAndUl', dist_name=_NRRELLnamegnb12, p_name='sCellOperationalMode')
]

PARAM_12149_gnb1_BC_1_001_383 = [
    dict(value='disabled', dist_name=_NRBTSname, parameter='actBufferBasedSCellAddition'),
    dict(value='4', dist_name=_NRCELLname, parameter='maxNumScellsDlFr1'),
    dict(value='false', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    dict(value='infinity', dist_name=_NRCELLname, parameter='sCellDeactivationTimerGNB'),
    dict(value='infinity', dist_name=_NRCELL2name, parameter='sCellDeactivationTimerGNB'),
    dict(value='1TTI', dist_name=_NRCELLname, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL2name, parameter='sCellActivationLevel'),
    dict(value='5TTI', dist_name=_NRCELLname, parameter='sCellActivationLevelUL'),
    dict(value='5TTI', dist_name=_NRCELL2name, parameter='sCellActivationLevelUL'),
    dict(value='longPucch', dist_name=_NRCELLname, parameter='pucchModeSelect'),
    dict(value='longPucch', dist_name=_NRCELL2name, parameter='pucchModeSelect'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELLname, parameter='actAdaptiveReTxResMcs'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcs'),
    dict(value='false', dist_name=_NRCELLname, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELLname, parameter='actShortBsrLimitAdaptation'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actShortBsrLimitAdaptation'),
    dict(value='slots20', dist_name=_NRCELLname, parameter='srPeriodicity'),
    dict(value='true', dist_name=_NRCELL1_FDD1, parameter='actPerCsiReportBundlingFdd'),
    dict(value='zeroDot15', dist_name=_NRCELLname, parameter='pucchF3MaxCodeRate'),
    dict(value='zeroDot15', dist_name=_NRCELL2name, parameter='pucchF3MaxCodeRate'),
    dict(value='qpsk_4psk', dist_name=_NRCELLname, parameter='pucchF3ModulationScheme'),
    dict(value='qpsk_4psk', dist_name=_NRCELL2name, parameter='pucchF3ModulationScheme'),
    dict(value='true', dist_name=_NRCELL2name, parameter='increasePUSCHPrepTimeULCA'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actRescheduleBlockedRetx'),
    dict(value='1', dist_name=_NRCELL2name, parameter='maxNumOfUlCaUeParallelTx'),
    dict(value='true', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='50', dist_name=_NRBTSDUname, parameter='dlToUlContributionRatio'),
    dict(value='bufferBased', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='15', dist_name=_NRBTSname, parameter='ulTxSwitchingBoost'),
    dict(value='sf10', dist_name=_NRBTSname, parameter='periodicBSRTimer'),
    dict(value=['ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fdd', 'ca_Fdd_Any_Sa'],
         dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    dict(value=['ca_F_Fr1T_Sa_switchedUl'], dist_name=_NRBTSDUname, parameter='ulTxSwitchingSupportList'),
    dict(value='blind', dist_name=_NRREL2namegnb1, parameter='sCellAdditionMethod'),
    dict(value='dlAndUl', dist_name=_NRREL2namegnb1, parameter='sCellOperationalMode'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL'),
    dict(value='slots20', dist_name=_NRCELLname, parameter='preferredVoNrSrPeriod'),
    dict(value='slots10', dist_name=_NRCELLname, parameter='srPeriodicityMin'),
    dict(value='n25600', dist_name=_NRCELL2name, parameter='timingAdvanceOffset'),
    dict(value='n25600', dist_name=_NRCELL21name, parameter='timingAdvanceOffset'),
    dict(value='Locked', dist_name=_NRCELL21name, parameter='administrativeState'),
]

PARAM_12149_recover_gnb1_BC_1_001_383 = [
    dict(value='oneShot_Dl_Fr1', dist_name=_NRBTSname, parameter='actBufferBasedSCellAddition'),
    dict(value='true', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    dict(value='ms1280', dist_name=_NRCELLname, parameter='sCellDeactivationTimerGNB'),
    dict(value='ms1280', dist_name=_NRCELL2name, parameter='sCellDeactivationTimerGNB'),
    dict(value='1TTI', dist_name=_NRCELLname, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL2name, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELLname, parameter='sCellActivationLevelUL'),
    dict(value='1TTI', dist_name=_NRCELL2name, parameter='sCellActivationLevelUL'),
    dict(value='longPucch', dist_name=_NRCELLname, parameter='pucchModeSelect'),
    dict(value='longPucch', dist_name=_NRCELL2name, parameter='pucchModeSelect'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELLname, parameter='actAdaptiveReTxResMcs'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcs'),
    dict(value='false', dist_name=_NRCELLname, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELLname, parameter='actShortBsrLimitAdaptation'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actShortBsrLimitAdaptation'),
    dict(value='slots80', dist_name=_NRCELLname, parameter='srPeriodicity'),
    dict(value='false', dist_name=_NRCELL1_FDD1, parameter='actPerCsiReportBundlingFdd'),
    dict(value='zeroDot15', dist_name=_NRCELLname, parameter='pucchF3MaxCodeRate'),
    dict(value='zeroDot15', dist_name=_NRCELL2name, parameter='pucchF3MaxCodeRate'),
    dict(value='qpsk_4psk', dist_name=_NRCELLname, parameter='pucchF3ModulationScheme'),
    dict(value='qpsk_4psk', dist_name=_NRCELL2name, parameter='pucchF3ModulationScheme'),
    dict(value='true', dist_name=_NRCELL2name, parameter='increasePUSCHPrepTimeULCA'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actRescheduleBlockedRetx'),
    dict(value='1', dist_name=_NRCELL2name, parameter='maxNumOfUlCaUeParallelTx'),
    dict(value='false', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='101', dist_name=_NRBTSDUname, parameter='dlToUlContributionRatio'),
    dict(value='bufferBased', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='15', dist_name=_NRBTSname, parameter='ulTxSwitchingBoost'),
    dict(value='sf10', dist_name=_NRBTSname, parameter='periodicBSRTimer'),
    dict(value=['ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Sa_WithUl'],
         dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    dict(value=['none'], dist_name=_NRBTSDUname, parameter='ulTxSwitchingSupportList'),
    dict(value=['A1-based'], dist_name=_NRBTSname, parameter='actMeasBasedSCellAdditionSa'),
    dict(value='none', dist_name=_NRCELLname, parameter='a1MeasSCellAddEnabled'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL'),
    dict(value='slots40', dist_name=_NRCELLname, parameter='preferredVoNrSrPeriod'),
    dict(value='slots40', dist_name=_NRCELLname, parameter='srPeriodicityMin'),
    dict(value='n39936', dist_name=_NRCELL2name, parameter='timingAdvanceOffset'),
    dict(value='n39936', dist_name=_NRCELL21name, parameter='timingAdvanceOffset'),
    dict(value='Unlocked', dist_name=_NRCELL21name, parameter='administrativeState'),
]

PARAM_12149_delete_gnb1_BC_1_001_383 = [
    dict(dist_name=_NRCELLname, parameter='maxNumScellsDlFr1'),
    dict(dist_name=_NRREL2namegnb1, parameter='sCellAdditionMethod'),
    dict(dist_name=_NRREL2namegnb1, parameter='sCellOperationalMode'),
]

PARAM_12149_gnb1_DA_IWK16 = [
    dict(value='4', dist_name=_NRCELL2name, p_name='maxNumScellsDlFr1'),
    dict(value='disabled', dist_name=_NRBTSname, p_name='actBufferBasedSCellAddition'),
    dict(value='15', dist_name=_NRBTSname, p_name='ulTxSwitchingBoost'),
    dict(value='ms1280', dist_name=_NRCELL2name, p_name='sCellDeactivationTimerGNB'),
    dict(value='ms1280', dist_name=_NRCELL3name, p_name='sCellDeactivationTimerGNB'),
    dict(value='intra-gNB', dist_name=_NRCELL2name, p_name='actK1Opt'),
    dict(value='intra-gNB', dist_name=_NRCELL3name, p_name='actK1Opt'),
    dict(value='true', dist_name=_NRCELL2name, p_name='actUlCgType2'),
    dict(value='true', dist_name=_NRCELL3name, p_name='actUlCgType2'),
    dict(value='1TTI', dist_name=_NRCELL2name, p_name='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL3name, p_name='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL2name, p_name='sCellActivationLevelUL'),
    dict(value='1TTI', dist_name=_NRCELL3name, p_name='sCellActivationLevelUL'),
    dict(value='10', dist_name=_NRULCG_PROFILE_2, p_name='grantedPacketSize'),
    dict(value='4', dist_name=_NRULCG_PROFILE_2, p_name='maxNumPrbs'),
    dict(value='ms80', dist_name=_NRULCG_PROFILE_2, p_name='periodicity'),
    dict(value=_NRULCG_PROFILE_2, dist_name=_NRDRB_13, p_name='nrDrbUlCgDN'),
    dict(value='false', dist_name=_NRCELL2_FDD1, p_name='actPerCsiReportBundlingFdd'),
    dict(value='slots20', dist_name=_NRCELL2name, p_name='srPeriodicity'),
    dict(value='TypeB', dist_name=_NRCELL2name, p_name='puschMappingType'),
    dict(value='false', dist_name=_NRCELL3name, p_name='actPowerSavingBWP'),
    dict(value='false', dist_name=_NRCELL3name, p_name='actInitialBWPFlexibility'),
    dict(value='false', dist_name=_NRCELL4name, p_name='actPowerSavingBWP'),
    dict(value='false', dist_name=_NRCELL4name, p_name='actInitialBWPFlexibility'),
    dict(value='rsrp', dist_name=_NRCELL2name, p_name='a1MeasSCellAddEnabled'),
    dict(value='Disabled', dist_name=_NRCELL2name, p_name='actUlSlotAgg'),
    dict(value='Disabled', dist_name=_NRCELL3name, p_name='actUlSlotAgg'),
    dict(value='true', dist_name=_NRCELL3name, p_name='increasePUSCHPrepTimeULCA'),
    dict(value='false', dist_name=_NRCELL2name, p_name='actAdaptiveReTxResMcs'),
    dict(value='false', dist_name=_NRCELL3name, p_name='actAdaptiveReTxResMcs'),
    dict(value='true', dist_name=_NRCELL2_FDD1, p_name='actPerCsiReportBundlingFdd'),
    dict(value='true', dist_name=_NRBTSDUname, p_name='actConnectedModeMobilityCA'),
    dict(value='50', dist_name=_NRBTSDUname, p_name='dlToUlContributionRatio'),
    dict(value='NumberCellAmount', dist_name=_NRBTSDUname, p_name='flexibleCAMode'),
    dict(value='bufferBased', dist_name=_NRBTSname, p_name='sCellActivationMethod'),
    dict(value='false', dist_name=_NRBTSname, p_name='actOverheatingAssistance'),
    dict(value='infinity', dist_name=_NRCELLname, p_name='sCellDeactivationTimerGNB'),
    dict(value='false', dist_name=_NRCELL3name, p_name='actEnhancedPDSCHSchSplSlot'),
    dict(value='covBasedA1', dist_name=_NRRELLnamegnb12, p_name='sCellAdditionMethod'),
    dict(value='false', dist_name=_NRCELL2name, p_name='actAperCsi'),
    dict(value='false', dist_name=_NRCELL3name, p_name='actAperCsi'),
    dict(value='5min', dist_name=_NRPMRNL, p_name='miNrCCD'),
    dict(value='false', dist_name=_NRCELL3name, p_name='actShortBsrLimitAdaptation'),
    dict(value='dlAndUl', dist_name=_NRRELLnamegnb12, p_name='sCellOperationalMode')
]

PARAM_12149_gnb1_DA_IWK16_new = [
    dict(value='4', dist_name=_NRCELL2name, p_name='maxNumScellsDlFr1'),
    dict(value='disabled', dist_name=_NRBTSname, p_name='actBufferBasedSCellAddition'),
    dict(value='15', dist_name=_NRBTSname, p_name='ulTxSwitchingBoost'),
    dict(value='ms1280', dist_name=_NRCELL2name, p_name='sCellDeactivationTimerGNB'),
    dict(value='ms1280', dist_name=_NRCELL3name, p_name='sCellDeactivationTimerGNB'),
    dict(value='intra-gNB', dist_name=_NRCELL2name, p_name='actK1Opt'),
    dict(value='intra-gNB', dist_name=_NRCELL3name, p_name='actK1Opt'),
    dict(value='true', dist_name=_NRCELL2name, p_name='actUlCgType2'),
    dict(value='true', dist_name=_NRCELL3name, p_name='actUlCgType2'),
    dict(value='1TTI', dist_name=_NRCELL2name, p_name='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL3name, p_name='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL2name, p_name='sCellActivationLevelUL'),
    dict(value='1TTI', dist_name=_NRCELL3name, p_name='sCellActivationLevelUL'),
    dict(value='10', dist_name=_NRULCG_PROFILE_2, p_name='grantedPacketSize'),
    dict(value='4', dist_name=_NRULCG_PROFILE_2, p_name='maxNumPrbs'),
    dict(value='ms80', dist_name=_NRULCG_PROFILE_2, p_name='periodicity'),
    dict(value=_NRULCG_PROFILE_2, dist_name=_NRDRB_13, p_name='nrDrbUlCgDN'),
    dict(value='false', dist_name=_NRCELL2_FDD1, p_name='actPerCsiReportBundlingFdd'),
    dict(value='slots20', dist_name=_NRCELL2name, p_name='srPeriodicity'),
    dict(value='TypeB', dist_name=_NRCELL2name, p_name='puschMappingType'),
    dict(value='false', dist_name=_NRCELL3name, p_name='actPowerSavingBWP'),
    dict(value='false', dist_name=_NRCELL3name, p_name='actInitialBWPFlexibility'),
    dict(value='false', dist_name=_NRCELL4name, p_name='actPowerSavingBWP'),
    dict(value='false', dist_name=_NRCELL4name, p_name='actInitialBWPFlexibility'),
    dict(value='rsrp', dist_name=_NRCELL2name, p_name='a1MeasSCellAddEnabled'),
    dict(value='Disabled', dist_name=_NRCELL2name, p_name='actUlSlotAgg'),
    dict(value='Disabled', dist_name=_NRCELL3name, p_name='actUlSlotAgg'),
    dict(value='true', dist_name=_NRCELL3name, p_name='increasePUSCHPrepTimeULCA'),
    dict(value='false', dist_name=_NRCELL2name, p_name='actAdaptiveReTxResMcs'),
    dict(value='false', dist_name=_NRCELL3name, p_name='actAdaptiveReTxResMcs'),
    dict(value='true', dist_name=_NRCELL2_FDD1, p_name='actPerCsiReportBundlingFdd'),
    dict(value='true', dist_name=_NRBTSDUname, p_name='actConnectedModeMobilityCA'),
    dict(value='50', dist_name=_NRBTSDUname, p_name='dlToUlContributionRatio'),
    dict(value='NumberCellAmount', dist_name=_NRBTSDUname, p_name='flexibleCAMode'),
    dict(value='bufferBased', dist_name=_NRBTSname, p_name='sCellActivationMethod'),
    dict(value='false', dist_name=_NRBTSname, p_name='actOverheatingAssistance'),
    dict(value='infinity', dist_name=_NRCELLname, p_name='sCellDeactivationTimerGNB'),
    dict(value='false', dist_name=_NRCELL3name, p_name='actEnhancedPDSCHSchSplSlot'),
    dict(value='covBasedA1', dist_name=_NRRELLnamegnb12, p_name='sCellAdditionMethod'),
    dict(value='covBasedA1', dist_name=_NRRELLnamegnb13, p_name='sCellAdditionMethod'),
    dict(value='false', dist_name=_NRCELL2name, p_name='actAperCsi'),
    dict(value='false', dist_name=_NRCELL3name, p_name='actAperCsi'),
    dict(value='5min', dist_name=_NRPMRNL, p_name='miNrCCD'),
    dict(value='false', dist_name=_NRCELL3name, p_name='actShortBsrLimitAdaptation'),
    dict(value='dlAndUl', dist_name=_NRRELLnamegnb12, p_name='sCellOperationalMode')
]

ListToModify_12149_gnb1_DA_IWK16 = [
    dict(dist_name=_NRBTSname, list_name='actMeasBasedSCellAdditionSa',
         elements=[dict(p_name='', value='A1-based', index=0)
                   ]),
    dict(dist_name=_NRBTSname, list_name='cipherPrefL',
         elements=[dict(p_name='nea0', value='9', index=0),
                   dict(p_name='nea1_128', value='0', index=0),
                   dict(p_name='nea2_128', value='0', index=0),
                   dict(p_name='nea3_128', value='0', index=0),
                   ]),
    dict(dist_name=_NRBTSname, list_name='integrityProtPrefL',
         elements=[dict(p_name='nia0', value='0', index=0),
                   dict(p_name='nia1_128', value='9', index=0),
                   dict(p_name='nia2_128', value='0', index=0),
                   dict(p_name='nia3_128', value='0', index=0),
                   ]),
    dict(dist_name=_NRCELL2name, list_name='ulConfiguredGrantType2',
         elements=[
             # dict(p_name='maxGBRAndCgType2TrafficLimit', value='50', index=0),
             dict(p_name='ulCgMaxNumPrbs', value='4', index=0),
             dict(p_name='ulCgMaxNumUeUl', value='1', index=0),
             dict(p_name='ulCgPrbStartOffset', value='0', index=0),
         ]),
    dict(dist_name=_NRBTSDUname, list_name='ulTxSwitchingSupportList',
         elements=[dict(p_name='', value='ca_F_Fr1T_Sa_switchedUl', index=0)
                   ])
]

PARAM_12149_gnb1_DA_IWK8 = [
    dict(value='4', dist_name=_NRCELL2name, p_name='maxNumScellsDlFr1'),
    dict(value='none', dist_name=_NRCELL2name, p_name='a1MeashoEnabledSA'),
    dict(value='none', dist_name=_NRCELL2name, p_name='a2MeashoEnabledSA'),
    dict(value='none', dist_name=_NRCELL2name, p_name='a3MeasEnabled'),
    dict(value='disabled', dist_name=_NRBTSname, p_name='actBufferBasedSCellAddition'),
    dict(value='Enabled_VoNr', dist_name=_NRCELL2name, p_name='actUlSlotAgg'),
    dict(value='false', dist_name=_NRCELL3name, p_name='actPowerSavingBWP'),
    dict(value='false', dist_name=_NRCELL3name, p_name='actInitialBWPFlexibility'),
    dict(value='false', dist_name=_NRCELL4name, p_name='actPowerSavingBWP'),
    dict(value='false', dist_name=_NRCELL4name, p_name='actInitialBWPFlexibility'),
    dict(value='rsrp', dist_name=_NRCELL2name, p_name='a1MeasSCellAddEnabled'),
    dict(value='false', dist_name=_NRCELL2name, p_name='actUlCgType2'),
    dict(value='false', dist_name=_NRCELL3name, p_name='actUlCgType2'),
    dict(value='Enabled_VoNr', dist_name=_NRCELL3name, p_name='actUlSlotAgg'),
    dict(value='true', dist_name=_NRCELL3name, p_name='increasePUSCHPrepTimeULCA'),
    dict(value='false', dist_name=_NRCELL2name, p_name='actAdaptiveReTxResMcs'),
    dict(value='false', dist_name=_NRCELL3name, p_name='actAdaptiveReTxResMcs'),
    dict(value='true', dist_name=_NRCELL2_FDD1, p_name='actPerCsiReportBundlingFdd'),
    dict(value='true', dist_name=_NRBTSDUname, p_name='actConnectedModeMobilityCA'),
    dict(value='50', dist_name=_NRBTSDUname, p_name='dlToUlContributionRatio'),
    dict(value='NumberCellAmount', dist_name=_NRBTSDUname, p_name='flexibleCAMode'),
    dict(value='bufferBased', dist_name=_NRBTSname, p_name='sCellActivationMethod'),
    dict(value='false', dist_name=_NRBTSname, p_name='actOverheatingAssistance'),
    dict(value='infinity', dist_name=_NRCELLname, p_name='sCellDeactivationTimerGNB'),
    dict(value='false', dist_name=_NRCELL3name, p_name='actEnhancedPDSCHSchSplSlot'),
    dict(value='covBasedA1', dist_name=_NRRELLnamegnb12, p_name='sCellAdditionMethod'),
    dict(value='dlAndUl', dist_name=_NRRELLnamegnb12, p_name='sCellOperationalMode')
]

PARAM_12149_gnb1_DA_IWK8_new = [
    dict(value='4', dist_name=_NRCELL2name, p_name='maxNumScellsDlFr1'),
    dict(value='none', dist_name=_NRCELL2name, p_name='a1MeashoEnabledSA'),
    dict(value='none', dist_name=_NRCELL2name, p_name='a2MeashoEnabledSA'),
    dict(value='none', dist_name=_NRCELL2name, p_name='a3MeasEnabled'),
    dict(value='disabled', dist_name=_NRBTSname, p_name='actBufferBasedSCellAddition'),
    dict(value='Enabled_VoNr', dist_name=_NRCELL2name, p_name='actUlSlotAgg'),
    dict(value='false', dist_name=_NRCELL3name, p_name='actPowerSavingBWP'),
    dict(value='false', dist_name=_NRCELL3name, p_name='actInitialBWPFlexibility'),
    dict(value='false', dist_name=_NRCELL4name, p_name='actPowerSavingBWP'),
    dict(value='false', dist_name=_NRCELL4name, p_name='actInitialBWPFlexibility'),
    dict(value='rsrp', dist_name=_NRCELL2name, p_name='a1MeasSCellAddEnabled'),
    dict(value='false', dist_name=_NRCELL2name, p_name='actUlCgType2'),
    dict(value='false', dist_name=_NRCELL3name, p_name='actUlCgType2'),
    dict(value='Enabled_VoNr', dist_name=_NRCELL3name, p_name='actUlSlotAgg'),
    dict(value='true', dist_name=_NRCELL3name, p_name='increasePUSCHPrepTimeULCA'),
    dict(value='false', dist_name=_NRCELL2name, p_name='actAdaptiveReTxResMcs'),
    dict(value='false', dist_name=_NRCELL3name, p_name='actAdaptiveReTxResMcs'),
    dict(value='true', dist_name=_NRCELL2_FDD1, p_name='actPerCsiReportBundlingFdd'),
    dict(value='true', dist_name=_NRBTSDUname, p_name='actConnectedModeMobilityCA'),
    dict(value='50', dist_name=_NRBTSDUname, p_name='dlToUlContributionRatio'),
    dict(value='NumberCellAmount', dist_name=_NRBTSDUname, p_name='flexibleCAMode'),
    dict(value='bufferBased', dist_name=_NRBTSname, p_name='sCellActivationMethod'),
    dict(value='false', dist_name=_NRBTSname, p_name='actOverheatingAssistance'),
    dict(value='infinity', dist_name=_NRCELLname, p_name='sCellDeactivationTimerGNB'),
    dict(value='false', dist_name=_NRCELL3name, p_name='actEnhancedPDSCHSchSplSlot'),
    dict(value='covBasedA1', dist_name=_NRRELLnamegnb12, p_name='sCellAdditionMethod'),
    dict(value='covBasedA1', dist_name=_NRRELLnamegnb13, p_name='sCellAdditionMethod'),
    dict(value='dlAndUl', dist_name=_NRRELLnamegnb12, p_name='sCellOperationalMode'),
    dict(value='1', dist_name=_NRCELL4name, p_name='maxNumOfUlCaUeParallelTx'),
    dict(value='true', dist_name=_NRCELL4name, p_name='actRescheduleBlockedRetx'),
    dict(value='true', dist_name=_NRCELL2name, p_name='actHighSpeedCell'),
    dict(value='true', dist_name=_NRCELL3name, p_name='actHighSpeedCell'),
    dict(value='Two additional DMRS', dist_name=_NRCELL2name, p_name='dlDMRSAdditionalPosition'),
    dict(value='Two additional DMRS', dist_name=_NRCELL3name, p_name='dlDMRSAdditionalPosition'),
    dict(value='Two additional DMRS', dist_name=_NRCELL2name, p_name='ulDMRSAdditionalPosition'),
    dict(value='Two additional DMRS', dist_name=_NRCELL3name, p_name='ulDMRSAdditionalPosition'),
    dict(value='TypeB', dist_name=_NRCELL2name, p_name='puschMappingType'),
    dict(value='TypeB', dist_name=_NRCELL3name, p_name='puschMappingType'),
]

ListToModify_12149_gnb1_DA_IWK8 = [
    dict(dist_name=_NRBTSname, list_name='actMeasBasedSCellAdditionSa',
         elements=[dict(p_name='', value='A1-based', index=0)
                   ]),
    dict(dist_name=_NRBTSname, list_name='cipherPrefL',
         elements=[dict(p_name='nea0', value='9', index=0),
                   dict(p_name='nea1_128', value='0', index=0),
                   dict(p_name='nea2_128', value='0', index=0),
                   dict(p_name='nea3_128', value='0', index=0),
                   ]),
    dict(dist_name=_NRCELL2name, list_name='ulTransPrecodeCtl',
         elements=[dict(p_name='ulSlotAggOffTotPwrThresh', value='20', index=0),
                   dict(p_name='ulSlotAggOnTotPwrThresh', value='12', index=0),
                   dict(p_name='ulTransPrecodeOffSinrThresh', value='20', index=0),
                   dict(p_name='ulTransPrecodeOffSinrThrRedCap', value='20', index=0),
                   dict(p_name='ulTransPrecodeOnSinrThresh', value='15', index=0),
                   dict(p_name='ulTransPrecodeOnSinrThrRedCap', value='15', index=0),
                   dict(p_name='ulTransPrecodePi2Bpsk', value='true', index=0),
                   dict(p_name='ulTransPrePi2BpskPwrBoost', value='false', index=0),
                   ]),
    dict(dist_name=_NRBTSname, list_name='integrityProtPrefL',
         elements=[dict(p_name='nia0', value='0', index=0),
                   dict(p_name='nia1_128', value='9', index=0),
                   dict(p_name='nia2_128', value='0', index=0),
                   dict(p_name='nia3_128', value='0', index=0),
                   ]),
    dict(dist_name=_NRBTSDUname, list_name='ulTxSwitchingSupportList',
         elements=[dict(p_name='', value='ca_F_Fr1T_Sa_switchedUl', index=0)
                   ])
]

ParameterToDelete_12149_gnb1_DA_IWK8 = [
    dict(dist_name=_NRBTSDUname, list_name='carrierAggregationSupportList'),
    dict(dist_name=_NRCELL2name, list_name='a1MeasSCellAddSsbRsrp'),
    dict(dist_name=_BWP_PROFILE_0),
    dict(dist_name=_NRCELL3name, list_name='cellBwpList'),
    dict(dist_name=_NRCELL4name, list_name='cellBwpList'),
    dict(dist_name=_NRRELLnamegnb13, list_name='sCellAdditionMethod'),
    dict(dist_name=_NRRELLnamegnb13, list_name='sCellOperationalMode'),
]

PARAM_12149_gnb1_DA_IWK19_348 = [
    dict(value='true', dist_name=_NRCELL400name, parameter='actAperCsi'),  # 5GC001817
    dict(value='TypeB', dist_name=_NRCELL400name, parameter='puschMappingType'),
    dict(value='disabled', dist_name=_NRBTSname, parameter='actSCellReleaseForInactiveSCell'),
    dict(value='disabled', dist_name=_NRBTSname, parameter='actBufferBasedSCellAddition'),
    dict(value='4', dist_name=_NRCELL400name, parameter='maxNumScellsDlFr1'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actLAForHiReliab'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actLAForHiReliab'),
    dict(value='infinity', dist_name=_NRCELL400name, parameter='sCellDeactivationTimerGNB'),
    dict(value='infinity', dist_name=_NRCELL700name, parameter='sCellDeactivationTimerGNB'),
    dict(value='1TTI', dist_name=_NRCELL400name, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL700name, parameter='sCellActivationLevel'),
    dict(value='5TTI', dist_name=_NRCELL400name, parameter='sCellActivationLevelUL'),
    dict(value='5TTI', dist_name=_NRCELL700name, parameter='sCellActivationLevelUL'),
    dict(value='longPucch', dist_name=_NRCELL400name, parameter='pucchModeSelect'),
    dict(value='longPucch', dist_name=_NRCELL700name, parameter='pucchModeSelect'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actAdaptiveReTxResMcs'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actAdaptiveReTxResMcs'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actShortBsrLimitAdaptation'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actShortBsrLimitAdaptation'),
    dict(value='slots20', dist_name=_NRCELL400name, parameter='srPeriodicity'),
    dict(value='true', dist_name=_NRCELL400_FDD1, parameter='actPerCsiReportBundlingFdd'),
    dict(value='zeroDot15', dist_name=_NRCELL400name, parameter='pucchF3MaxCodeRate'),
    dict(value='zeroDot15', dist_name=_NRCELL700name, parameter='pucchF3MaxCodeRate'),
    dict(value='qpsk_4psk', dist_name=_NRCELL400name, parameter='pucchF3ModulationScheme'),
    dict(value='qpsk_4psk', dist_name=_NRCELL700name, parameter='pucchF3ModulationScheme'),
    dict(value='true', dist_name=_NRCELL700name, parameter='increasePUSCHPrepTimeULCA'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actRescheduleBlockedRetx'),
    dict(value='1', dist_name=_NRCELL700name, parameter='maxNumOfUlCaUeParallelTx'),
    dict(value='true', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='50', dist_name=_NRBTSDUname, parameter='dlToUlContributionRatio'),
    dict(value='bufferBased', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='15', dist_name=_NRBTSname, parameter='ulTxSwitchingBoost'),
    dict(value='sf10', dist_name=_NRBTSname, parameter='periodicBSRTimer'),
    dict(value=['ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fdd', 'ca_Fdd_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Any_Sa', 'ca_Fdd_Any_Sa',
                'ca_Fr1Tdd_Fdd_Nsa', 'ca_Fr1Tdd_Fdd_Sa', 'ca_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Sa_WithUl'],
         dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    dict(value=['ca_F_Fr1T_Sa_switchedUl'], dist_name=_NRBTSDUname, parameter='ulTxSwitchingSupportList'),
    dict(value=['A1-based'], dist_name=_NRBTSname, parameter='actMeasBasedSCellAdditionSa'),
    dict(value='covBasedA1', dist_name=_NRRELL400namegnb12, parameter='sCellAdditionMethod'),
    dict(value='dlAndUl', dist_name=_NRRELL400namegnb12, parameter='sCellOperationalMode'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL'),
    dict(value='slots20', dist_name=_NRCELL400name, parameter='preferredVoNrSrPeriod'),
    dict(value='slots10', dist_name=_NRCELL400name, parameter='srPeriodicityMin'),
    dict(value='n25600', dist_name=_NRCELL400name, parameter='timingAdvanceOffset'),
    dict(value='n25600', dist_name=_NRCELL410name, parameter='timingAdvanceOffset'),
    dict(value='n25600', dist_name=_NRCELL700name, parameter='timingAdvanceOffset'),
    dict(value='n25600', dist_name=_NRCELL701name, parameter='timingAdvanceOffset'),
    dict(value='locked', dist_name=_LTECELL48040name, parameter='administrativeState'),
    dict(value='locked', dist_name=_LTECELL48045name, parameter='administrativeState'),
    dict(value='Locked', dist_name=_NRCELL701name, parameter='administrativeState'),
]

PARAM_12149_recover_gnb1_DA_IWK19_348 = [
    dict(value='true', dist_name=_NRCELL400name, parameter='actAperCsi'),  # 5GC001817
    dict(value='TypeB', dist_name=_NRCELL400name, parameter='puschMappingType'),
    dict(value='timer_based_Fr1', dist_name=_NRBTSname, parameter='actSCellReleaseForInactiveSCell'),
    dict(value='oneShot_Dl_Fr1', dist_name=_NRBTSname, parameter='actBufferBasedSCellAddition'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actLAForHiReliab'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actLAForHiReliab'),
    dict(value='infinity', dist_name=_NRCELL400name, parameter='sCellDeactivationTimerGNB'),
    dict(value='infinity', dist_name=_NRCELL700name, parameter='sCellDeactivationTimerGNB'),
    dict(value='1TTI', dist_name=_NRCELL400name, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL700name, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL400name, parameter='sCellActivationLevelUL'),
    dict(value='1TTI', dist_name=_NRCELL700name, parameter='sCellActivationLevelUL'),
    dict(value='longPucch', dist_name=_NRCELL400name, parameter='pucchModeSelect'),
    dict(value='longPucch', dist_name=_NRCELL700name, parameter='pucchModeSelect'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actAdaptiveReTxResMcs'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actAdaptiveReTxResMcs'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actShortBsrLimitAdaptation'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actShortBsrLimitAdaptation'),
    dict(value='slots80', dist_name=_NRCELL400name, parameter='srPeriodicity'),
    dict(value='false', dist_name=_NRCELL400_FDD1, parameter='actPerCsiReportBundlingFdd'),
    dict(value='zeroDot15', dist_name=_NRCELL400name, parameter='pucchF3MaxCodeRate'),
    dict(value='zeroDot15', dist_name=_NRCELL700name, parameter='pucchF3MaxCodeRate'),
    dict(value='qpsk_4psk', dist_name=_NRCELL400name, parameter='pucchF3ModulationScheme'),
    dict(value='qpsk_4psk', dist_name=_NRCELL700name, parameter='pucchF3ModulationScheme'),
    dict(value='true', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actRescheduleBlockedRetx'),
    dict(value='101', dist_name=_NRBTSDUname, parameter='dlToUlContributionRatio'),
    dict(value='bufferBased', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='15', dist_name=_NRBTSname, parameter='ulTxSwitchingBoost'),
    dict(value='sf10', dist_name=_NRBTSname, parameter='periodicBSRTimer'),
    dict(value=['ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fdd', 'ca_Fdd_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Any_Sa', 'ca_Fdd_Any_Sa',
                'ca_Fr1Tdd_Fdd_Nsa', 'ca_Fr1Tdd_Fdd_Sa', 'ca_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Sa_WithUl'],
         dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    dict(value=['none'], dist_name=_NRBTSDUname, parameter='ulTxSwitchingSupportList'),
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL'),
    dict(value='slots40', dist_name=_NRCELL400name, parameter='preferredVoNrSrPeriod'),
    dict(value='slots40', dist_name=_NRCELL400name, parameter='srPeriodicityMin'),
    dict(value='n0', dist_name=_NRCELL400name, parameter='timingAdvanceOffset'),
    dict(value='n0', dist_name=_NRCELL410name, parameter='timingAdvanceOffset'),
    dict(value='n39936', dist_name=_NRCELL700name, parameter='timingAdvanceOffset'),
    dict(value='n39936', dist_name=_NRCELL701name, parameter='timingAdvanceOffset'),
    dict(value='unlocked', dist_name=_LTECELL48040name, parameter='administrativeState'),
    dict(value='unlocked', dist_name=_LTECELL48045name, parameter='administrativeState'),
    dict(value='Unlocked', dist_name=_NRCELL701name, parameter='administrativeState'),
]

PARAM_12149_delete_gnb1_DA_IWK19_348 = [
    dict(dist_name=_NRCELL400name, parameter='maxNumScellsDlFr1'),
    dict(dist_name=_NRRELL400namegnb12, parameter='sCellAdditionMethod'),
    dict(dist_name=_NRRELL400namegnb12, parameter='sCellOperationalMode'),
    dict(dist_name=_NRCELL700name, parameter='increasePUSCHPrepTimeULCA'),
    dict(dist_name=_NRCELL700name, parameter='maxNumOfUlCaUeParallelTx'),
]

PARAM_12149_gnb1_DA_IWK19_383 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actAperCsi'),  # 5GC001817
    dict(value='TypeB', dist_name=_NRCELLname, parameter='puschMappingType'),
    dict(value='disabled', dist_name=_NRBTSname, parameter='actBufferBasedSCellAddition'),
    dict(value='4', dist_name=_NRCELLname, parameter='maxNumScellsDlFr1'),
    dict(value='false', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    dict(value='infinity', dist_name=_NRCELLname, parameter='sCellDeactivationTimerGNB'),
    dict(value='infinity', dist_name=_NRCELL2name, parameter='sCellDeactivationTimerGNB'),
    dict(value='1TTI', dist_name=_NRCELLname, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL2name, parameter='sCellActivationLevel'),
    dict(value='5TTI', dist_name=_NRCELLname, parameter='sCellActivationLevelUL'),
    dict(value='5TTI', dist_name=_NRCELL2name, parameter='sCellActivationLevelUL'),
    dict(value='longPucch', dist_name=_NRCELLname, parameter='pucchModeSelect'),
    dict(value='longPucch', dist_name=_NRCELL2name, parameter='pucchModeSelect'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELLname, parameter='actAdaptiveReTxResMcs'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcs'),
    dict(value='false', dist_name=_NRCELLname, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELLname, parameter='actShortBsrLimitAdaptation'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actShortBsrLimitAdaptation'),
    dict(value='slots20', dist_name=_NRCELLname, parameter='srPeriodicity'),
    dict(value='true', dist_name=_NRCELL1_FDD1, parameter='actPerCsiReportBundlingFdd'),
    dict(value='zeroDot15', dist_name=_NRCELLname, parameter='pucchF3MaxCodeRate'),
    dict(value='zeroDot15', dist_name=_NRCELL2name, parameter='pucchF3MaxCodeRate'),
    dict(value='qpsk_4psk', dist_name=_NRCELLname, parameter='pucchF3ModulationScheme'),
    dict(value='qpsk_4psk', dist_name=_NRCELL2name, parameter='pucchF3ModulationScheme'),
    dict(value='true', dist_name=_NRCELL2name, parameter='increasePUSCHPrepTimeULCA'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actRescheduleBlockedRetx'),
    dict(value='1', dist_name=_NRCELL2name, parameter='maxNumOfUlCaUeParallelTx'),
    dict(value='true', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='50', dist_name=_NRBTSDUname, parameter='dlToUlContributionRatio'),
    dict(value='bufferBased', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='15', dist_name=_NRBTSname, parameter='ulTxSwitchingBoost'),
    dict(value='sf10', dist_name=_NRBTSname, parameter='periodicBSRTimer'),
    dict(value=['ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fdd', 'ca_Fdd_Any_Sa', 'ca_Fdd_Fr1Tdd_Sa_WithUl'],
         dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    dict(value=['ca_F_Fr1T_Sa_switchedUl'], dist_name=_NRBTSDUname, parameter='ulTxSwitchingSupportList'),
    dict(value='blind', dist_name=_NRREL2namegnb1, parameter='sCellAdditionMethod'),
    dict(value='dlAndUl', dist_name=_NRREL2namegnb1, parameter='sCellOperationalMode'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL'),
    dict(value='slots20', dist_name=_NRCELLname, parameter='preferredVoNrSrPeriod'),
    dict(value='slots10', dist_name=_NRCELLname, parameter='srPeriodicityMin'),
    dict(value='n25600', dist_name=_NRCELL2name, parameter='timingAdvanceOffset'),
    dict(value='n25600', dist_name=_NRCELL21name, parameter='timingAdvanceOffset'),
    dict(value='Locked', dist_name=_NRCELL21name, parameter='administrativeState'),
    dict(value='Locked', dist_name=_NRCELL3name, parameter='administrativeState'),
]

PARAM_12149_gnb2_DA_IWK19_383 = [
    dict(value='Locked', dist_name=_NRCELLname, parameter='administrativeState'),
]

PARAM_12149_recover_gnb1_DA_IWK19_383 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actAperCsi'),  # 5GC001817
    dict(value='TypeA', dist_name=_NRCELLname, parameter='puschMappingType'),
    dict(value='oneShot_Dl_Fr1', dist_name=_NRBTSname, parameter='actBufferBasedSCellAddition'),
    dict(value='true', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    dict(value='ms1280', dist_name=_NRCELLname, parameter='sCellDeactivationTimerGNB'),
    dict(value='ms1280', dist_name=_NRCELL2name, parameter='sCellDeactivationTimerGNB'),
    dict(value='1TTI', dist_name=_NRCELLname, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL2name, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELLname, parameter='sCellActivationLevelUL'),
    dict(value='1TTI', dist_name=_NRCELL2name, parameter='sCellActivationLevelUL'),
    dict(value='longPucch', dist_name=_NRCELLname, parameter='pucchModeSelect'),
    dict(value='longPucch', dist_name=_NRCELL2name, parameter='pucchModeSelect'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELLname, parameter='actAdaptiveReTxResMcs'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcs'),
    dict(value='false', dist_name=_NRCELLname, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELLname, parameter='actShortBsrLimitAdaptation'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actShortBsrLimitAdaptation'),
    dict(value='slots80', dist_name=_NRCELLname, parameter='srPeriodicity'),
    dict(value='false', dist_name=_NRCELL1_FDD1, parameter='actPerCsiReportBundlingFdd'),
    dict(value='zeroDot15', dist_name=_NRCELLname, parameter='pucchF3MaxCodeRate'),
    dict(value='zeroDot15', dist_name=_NRCELL2name, parameter='pucchF3MaxCodeRate'),
    dict(value='qpsk_4psk', dist_name=_NRCELLname, parameter='pucchF3ModulationScheme'),
    dict(value='qpsk_4psk', dist_name=_NRCELL2name, parameter='pucchF3ModulationScheme'),
    dict(value='true', dist_name=_NRCELL2name, parameter='increasePUSCHPrepTimeULCA'),
    dict(value='false', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actRescheduleBlockedRetx'),
    dict(value='1', dist_name=_NRCELL2name, parameter='maxNumOfUlCaUeParallelTx'),
    dict(value='101', dist_name=_NRBTSDUname, parameter='dlToUlContributionRatio'),
    dict(value='bufferBased', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='15', dist_name=_NRBTSname, parameter='ulTxSwitchingBoost'),
    dict(value='sf10', dist_name=_NRBTSname, parameter='periodicBSRTimer'),
    dict(value=['ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Sa_WithUl'],
         dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    dict(value=['none'], dist_name=_NRBTSDUname, parameter='ulTxSwitchingSupportList'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL'),
    dict(value='slots40', dist_name=_NRCELLname, parameter='preferredVoNrSrPeriod'),
    dict(value='slots40', dist_name=_NRCELLname, parameter='srPeriodicityMin'),
    dict(value='n39936', dist_name=_NRCELL2name, parameter='timingAdvanceOffset'),
    dict(value='n39936', dist_name=_NRCELL21name, parameter='timingAdvanceOffset'),
    dict(value='Unlocked', dist_name=_NRCELL21name, parameter='administrativeState'),
    dict(value='Unlocked', dist_name=_NRCELL3name, parameter='administrativeState'),
]

PARAM_12149_delete_gnb1_DA_IWK19_383 = [
    dict(dist_name=_NRCELLname, parameter='maxNumScellsDlFr1'),
    dict(dist_name=_NRREL2namegnb1, parameter='sCellAdditionMethod'),
    dict(dist_name=_NRREL2namegnb1, parameter='sCellOperationalMode'),
]

PARAM_12149_recover_gnb2_DA_IWK19_383 = [
    dict(value='Unlocked', dist_name=_NRCELLname, parameter='administrativeState'),
]

PARAM_12149_gnb1_DA_IWK8_348 = [
    # CB008236
    dict(value='Enabled_VoNr', dist_name=_NRCELL400name, parameter='actUlSlotAgg'),
    dict(value='Disabled', dist_name=_NRCELL700name, parameter='actUlSlotAgg'),
    dict(value='Deact_Scells_VoNr_SAg', dist_name=_NRCELL400name, parameter='sCellDeactInPoorRf'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actVoipPacketAggr'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actVoipPacketAggr'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actUlAudioGapReduction'),
    # CB008236
    dict(value='TypeA', dist_name=_NRCELL400name, parameter='puschMappingType'),
    dict(value='TypeA', dist_name=_NRCELL700name, parameter='puschMappingType'),
    dict(value='disabled', dist_name=_NRBTSname, parameter='actSCellReleaseForInactiveSCell'),
    dict(value='disabled', dist_name=_NRBTSname, parameter='actBufferBasedSCellAddition'),
    dict(value='4', dist_name=_NRCELL400name, parameter='maxNumScellsDlFr1'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actLAForHiReliab'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actLAForHiReliab'),
    dict(value='infinity', dist_name=_NRCELL400name, parameter='sCellDeactivationTimerGNB'),
    dict(value='infinity', dist_name=_NRCELL700name, parameter='sCellDeactivationTimerGNB'),
    dict(value='1TTI', dist_name=_NRCELL400name, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL700name, parameter='sCellActivationLevel'),
    dict(value='5TTI', dist_name=_NRCELL400name, parameter='sCellActivationLevelUL'),
    dict(value='5TTI', dist_name=_NRCELL700name, parameter='sCellActivationLevelUL'),
    dict(value='longPucch', dist_name=_NRCELL400name, parameter='pucchModeSelect'),
    dict(value='longPucch', dist_name=_NRCELL700name, parameter='pucchModeSelect'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actAdaptiveReTxResMcs'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actAdaptiveReTxResMcs'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actShortBsrLimitAdaptation'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actShortBsrLimitAdaptation'),
    dict(value='slots20', dist_name=_NRCELL400name, parameter='srPeriodicity'),
    dict(value='true', dist_name=_NRCELL400_FDD1, parameter='actPerCsiReportBundlingFdd'),
    dict(value='zeroDot15', dist_name=_NRCELL400name, parameter='pucchF3MaxCodeRate'),
    dict(value='zeroDot15', dist_name=_NRCELL700name, parameter='pucchF3MaxCodeRate'),
    dict(value='qpsk_4psk', dist_name=_NRCELL400name, parameter='pucchF3ModulationScheme'),
    dict(value='qpsk_4psk', dist_name=_NRCELL700name, parameter='pucchF3ModulationScheme'),
    dict(value='true', dist_name=_NRCELL700name, parameter='increasePUSCHPrepTimeULCA'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actRescheduleBlockedRetx'),
    dict(value='1', dist_name=_NRCELL700name, parameter='maxNumOfUlCaUeParallelTx'),
    dict(value='true', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='50', dist_name=_NRBTSDUname, parameter='dlToUlContributionRatio'),
    dict(value='bufferBased', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='15', dist_name=_NRBTSname, parameter='ulTxSwitchingBoost'),
    dict(value='sf10', dist_name=_NRBTSname, parameter='periodicBSRTimer'),
    dict(value=['ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fdd', 'ca_Fdd_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Any_Sa', 'ca_Fdd_Any_Sa',
                'ca_Fr1Tdd_Fdd_Nsa', 'ca_Fr1Tdd_Fdd_Sa', 'ca_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Sa_WithUl'],
         dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    dict(value=['ca_F_Fr1T_Sa_switchedUl'], dist_name=_NRBTSDUname, parameter='ulTxSwitchingSupportList'),
    dict(value=['A1-based'], dist_name=_NRBTSname, parameter='actMeasBasedSCellAdditionSa'),
    dict(value='covBasedA1', dist_name=_NRRELL400namegnb12, parameter='sCellAdditionMethod'),
    dict(value='dlAndUl', dist_name=_NRRELL400namegnb12, parameter='sCellOperationalMode'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL'),
    dict(value='slots20', dist_name=_NRCELL400name, parameter='preferredVoNrSrPeriod'),
    dict(value='slots10', dist_name=_NRCELL400name, parameter='srPeriodicityMin'),
    dict(value='n25600', dist_name=_NRCELL400name, parameter='timingAdvanceOffset'),
    dict(value='n25600', dist_name=_NRCELL410name, parameter='timingAdvanceOffset'),
    dict(value='n25600', dist_name=_NRCELL700name, parameter='timingAdvanceOffset'),
    dict(value='n25600', dist_name=_NRCELL701name, parameter='timingAdvanceOffset'),
    dict(value='locked', dist_name=_LTECELL48040name, parameter='administrativeState'),
    dict(value='locked', dist_name=_LTECELL48045name, parameter='administrativeState'),
    dict(value='Locked', dist_name=_NRCELL701name, parameter='administrativeState'),
]

PARAM_12149_recover_gnb1_DA_IWK8_348 = [
    # CB008236
    dict(value='Enabled_VoNr', dist_name=_NRCELL400name, parameter='actUlSlotAgg'),
    dict(value='Disabled', dist_name=_NRCELL700name, parameter='actUlSlotAgg'),
    dict(value='Deact_Scells_VoNr_SAg', dist_name=_NRCELL400name, parameter='sCellDeactInPoorRf'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actVoipPacketAggr'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actVoipPacketAggr'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actUlAudioGapReduction'),
    # CB008236
    dict(value='TypeB', dist_name=_NRCELL400name, parameter='puschMappingType'),
    dict(value='TypeB', dist_name=_NRCELL700name, parameter='puschMappingType'),
    dict(value='timer_based_Fr1', dist_name=_NRBTSname, parameter='actSCellReleaseForInactiveSCell'),
    dict(value='oneShot_Dl_Fr1', dist_name=_NRBTSname, parameter='actBufferBasedSCellAddition'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actLAForHiReliab'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actLAForHiReliab'),
    dict(value='infinity', dist_name=_NRCELL400name, parameter='sCellDeactivationTimerGNB'),
    dict(value='infinity', dist_name=_NRCELL700name, parameter='sCellDeactivationTimerGNB'),
    dict(value='1TTI', dist_name=_NRCELL400name, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL700name, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL400name, parameter='sCellActivationLevelUL'),
    dict(value='1TTI', dist_name=_NRCELL700name, parameter='sCellActivationLevelUL'),
    dict(value='longPucch', dist_name=_NRCELL400name, parameter='pucchModeSelect'),
    dict(value='longPucch', dist_name=_NRCELL700name, parameter='pucchModeSelect'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actAdaptiveReTxResMcs'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actAdaptiveReTxResMcs'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actShortBsrLimitAdaptation'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actShortBsrLimitAdaptation'),
    dict(value='slots80', dist_name=_NRCELL400name, parameter='srPeriodicity'),
    dict(value='false', dist_name=_NRCELL400_FDD1, parameter='actPerCsiReportBundlingFdd'),
    dict(value='zeroDot15', dist_name=_NRCELL400name, parameter='pucchF3MaxCodeRate'),
    dict(value='zeroDot15', dist_name=_NRCELL700name, parameter='pucchF3MaxCodeRate'),
    dict(value='qpsk_4psk', dist_name=_NRCELL400name, parameter='pucchF3ModulationScheme'),
    dict(value='qpsk_4psk', dist_name=_NRCELL700name, parameter='pucchF3ModulationScheme'),
    dict(value='true', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actRescheduleBlockedRetx'),
    dict(value='101', dist_name=_NRBTSDUname, parameter='dlToUlContributionRatio'),
    dict(value='bufferBased', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='15', dist_name=_NRBTSname, parameter='ulTxSwitchingBoost'),
    dict(value='sf10', dist_name=_NRBTSname, parameter='periodicBSRTimer'),
    dict(value=['ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fdd', 'ca_Fdd_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Any_Sa', 'ca_Fdd_Any_Sa',
                'ca_Fr1Tdd_Fdd_Nsa', 'ca_Fr1Tdd_Fdd_Sa', 'ca_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Sa_WithUl'],
         dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    dict(value=['none'], dist_name=_NRBTSDUname, parameter='ulTxSwitchingSupportList'),
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL'),
    dict(value='slots40', dist_name=_NRCELL400name, parameter='preferredVoNrSrPeriod'),
    dict(value='slots40', dist_name=_NRCELL400name, parameter='srPeriodicityMin'),
    dict(value='n0', dist_name=_NRCELL400name, parameter='timingAdvanceOffset'),
    dict(value='n0', dist_name=_NRCELL410name, parameter='timingAdvanceOffset'),
    dict(value='n39936', dist_name=_NRCELL700name, parameter='timingAdvanceOffset'),
    dict(value='n39936', dist_name=_NRCELL701name, parameter='timingAdvanceOffset'),
    dict(value='unlocked', dist_name=_LTECELL48040name, parameter='administrativeState'),
    dict(value='unlocked', dist_name=_LTECELL48045name, parameter='administrativeState'),
    dict(value='Unlocked', dist_name=_NRCELL701name, parameter='administrativeState'),
]

PARAM_12149_delete_gnb1_DA_IWK8_348 = [
    dict(dist_name=_NRCELL400name, parameter='maxNumScellsDlFr1'),
    dict(dist_name=_NRRELL400namegnb12, parameter='sCellAdditionMethod'),
    dict(dist_name=_NRRELL400namegnb12, parameter='sCellOperationalMode'),
    dict(dist_name=_NRCELL700name, parameter='increasePUSCHPrepTimeULCA'),
    dict(dist_name=_NRCELL700name, parameter='maxNumOfUlCaUeParallelTx'),
]

PARAM_gnb1_EDA_05437018_348 = [
    # CB008236
    dict(value='Enabled_VoNr', dist_name=_NRCELL400name, parameter='actUlSlotAgg'),
    dict(value='Disabled', dist_name=_NRCELL700name, parameter='actUlSlotAgg'),
    dict(value='Deact_Scells_VoNr_SAg', dist_name=_NRCELL400name, parameter='sCellDeactInPoorRf'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actVoipPacketAggr'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actVoipPacketAggr'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actUlAudioGapReduction'),
    # CB008236
    dict(value='TypeA', dist_name=_NRCELL400name, parameter='puschMappingType'),
    dict(value='TypeA', dist_name=_NRCELL700name, parameter='puschMappingType'),
    dict(value='disabled', dist_name=_NRBTSname, parameter='actSCellReleaseForInactiveSCell'),
    dict(value='disabled', dist_name=_NRBTSname, parameter='actBufferBasedSCellAddition'),
    dict(value='4', dist_name=_NRCELL400name, parameter='maxNumScellsDlFr1'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actLAForHiReliab'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actLAForHiReliab'),
    dict(value='infinity', dist_name=_NRCELL400name, parameter='sCellDeactivationTimerGNB'),
    dict(value='infinity', dist_name=_NRCELL700name, parameter='sCellDeactivationTimerGNB'),
    dict(value='1TTI', dist_name=_NRCELL400name, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL700name, parameter='sCellActivationLevel'),
    dict(value='5TTI', dist_name=_NRCELL400name, parameter='sCellActivationLevelUL'),
    dict(value='5TTI', dist_name=_NRCELL700name, parameter='sCellActivationLevelUL'),
    dict(value='longPucch', dist_name=_NRCELL400name, parameter='pucchModeSelect'),
    dict(value='longPucch', dist_name=_NRCELL700name, parameter='pucchModeSelect'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actCDrx'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actAdaptiveReTxResMcs'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actAdaptiveReTxResMcs'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actShortBsrLimitAdaptation'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actShortBsrLimitAdaptation'),
    dict(value='slots80', dist_name=_NRCELL400name, parameter='srPeriodicity'),
    dict(value='true', dist_name=_NRCELL400_FDD1, parameter='actPerCsiReportBundlingFdd'),
    dict(value='zeroDot15', dist_name=_NRCELL400name, parameter='pucchF3MaxCodeRate'),
    dict(value='zeroDot15', dist_name=_NRCELL700name, parameter='pucchF3MaxCodeRate'),
    dict(value='qpsk_4psk', dist_name=_NRCELL400name, parameter='pucchF3ModulationScheme'),
    dict(value='qpsk_4psk', dist_name=_NRCELL700name, parameter='pucchF3ModulationScheme'),
    dict(value='true', dist_name=_NRCELL700name, parameter='increasePUSCHPrepTimeULCA'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actRescheduleBlockedRetx'),
    dict(value='1', dist_name=_NRCELL700name, parameter='maxNumOfUlCaUeParallelTx'),
    dict(value='true', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='50', dist_name=_NRBTSDUname, parameter='dlToUlContributionRatio'),
    dict(value='bufferBased', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='15', dist_name=_NRBTSname, parameter='ulTxSwitchingBoost'),
    dict(value='sf10', dist_name=_NRBTSname, parameter='periodicBSRTimer'),
    dict(value=['ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fdd', 'ca_Fdd_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Any_Sa', 'ca_Fdd_Any_Sa',
                'ca_Fr1Tdd_Fdd_Nsa', 'ca_Fr1Tdd_Fdd_Sa', 'ca_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Sa_WithUl'],
         dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    dict(value=['ca_F_Fr1T_Sa_switchedUl'], dist_name=_NRBTSDUname, parameter='ulTxSwitchingSupportList'),
    dict(value=['A1-based'], dist_name=_NRBTSname, parameter='actMeasBasedSCellAdditionSa'),
    dict(value='covBasedA1', dist_name=_NRRELL400namegnb12, parameter='sCellAdditionMethod'),
    dict(value='dlAndUl', dist_name=_NRRELL400namegnb12, parameter='sCellOperationalMode'),
    dict(value='slots20', dist_name=_NRCELL400name, parameter='preferredVoNrSrPeriod'),
    dict(value='slots20', dist_name=_NRCELL400name, parameter='srPeriodicityMin'),
    dict(value='n25600', dist_name=_NRCELL400name, parameter='timingAdvanceOffset'),
    dict(value='n25600', dist_name=_NRCELL410name, parameter='timingAdvanceOffset'),
    dict(value='n25600', dist_name=_NRCELL700name, parameter='timingAdvanceOffset'),
    dict(value='n25600', dist_name=_NRCELL701name, parameter='timingAdvanceOffset'),
    dict(value='locked', dist_name=_LTECELL48040name, parameter='administrativeState'),
    dict(value='locked', dist_name=_LTECELL48045name, parameter='administrativeState'),
    dict(value='Locked', dist_name=_NRCELL701name, parameter='administrativeState'),
    dict(value='80ms', dist_name=_NRDRB_12, parameter='srPeriodicityDrb'),
    dict(value='80ms', dist_name=_NRDRB_10, parameter='srPeriodicityDrb'),
    dict(value=['FR1 CA incompatible'], dist_name=_NRDRB_15, parameter='cellAggrLevel'),
    dict(value=['FR1 CA incompatible'], dist_name=_NRDRB_13, parameter='cellAggrLevel'),
]

PARAM_recover_gnb1_EDA_05437018_348 = [
    # CB008236
    dict(value='Enabled_VoNr', dist_name=_NRCELL400name, parameter='actUlSlotAgg'),
    dict(value='Disabled', dist_name=_NRCELL700name, parameter='actUlSlotAgg'),
    dict(value='Deact_Scells_VoNr_SAg', dist_name=_NRCELL400name, parameter='sCellDeactInPoorRf'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actVoipPacketAggr'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actVoipPacketAggr'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actUlAudioGapReduction'),
    # CB008236
    dict(value='TypeB', dist_name=_NRCELL400name, parameter='puschMappingType'),
    dict(value='TypeB', dist_name=_NRCELL700name, parameter='puschMappingType'),
    dict(value='timer_based_Fr1', dist_name=_NRBTSname, parameter='actSCellReleaseForInactiveSCell'),
    dict(value='oneShot_Dl_Fr1', dist_name=_NRBTSname, parameter='actBufferBasedSCellAddition'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actLAForHiReliab'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actLAForHiReliab'),
    dict(value='infinity', dist_name=_NRCELL400name, parameter='sCellDeactivationTimerGNB'),
    dict(value='infinity', dist_name=_NRCELL700name, parameter='sCellDeactivationTimerGNB'),
    dict(value='1TTI', dist_name=_NRCELL400name, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL700name, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL400name, parameter='sCellActivationLevelUL'),
    dict(value='1TTI', dist_name=_NRCELL700name, parameter='sCellActivationLevelUL'),
    dict(value='longPucch', dist_name=_NRCELL400name, parameter='pucchModeSelect'),
    dict(value='longPucch', dist_name=_NRCELL700name, parameter='pucchModeSelect'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actAdaptiveReTxResMcs'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actAdaptiveReTxResMcs'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actShortBsrLimitAdaptation'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actShortBsrLimitAdaptation'),
    dict(value='slots80', dist_name=_NRCELL400name, parameter='srPeriodicity'),
    dict(value='false', dist_name=_NRCELL400_FDD1, parameter='actPerCsiReportBundlingFdd'),
    dict(value='zeroDot15', dist_name=_NRCELL400name, parameter='pucchF3MaxCodeRate'),
    dict(value='zeroDot15', dist_name=_NRCELL700name, parameter='pucchF3MaxCodeRate'),
    dict(value='qpsk_4psk', dist_name=_NRCELL400name, parameter='pucchF3ModulationScheme'),
    dict(value='qpsk_4psk', dist_name=_NRCELL700name, parameter='pucchF3ModulationScheme'),
    dict(value='true', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actRescheduleBlockedRetx'),
    dict(value='101', dist_name=_NRBTSDUname, parameter='dlToUlContributionRatio'),
    dict(value='bufferBased', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='15', dist_name=_NRBTSname, parameter='ulTxSwitchingBoost'),
    dict(value='sf10', dist_name=_NRBTSname, parameter='periodicBSRTimer'),
    dict(value=['ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fdd', 'ca_Fdd_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Any_Sa', 'ca_Fdd_Any_Sa',
                'ca_Fr1Tdd_Fdd_Nsa', 'ca_Fr1Tdd_Fdd_Sa', 'ca_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Sa_WithUl'],
         dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    dict(value=['none'], dist_name=_NRBTSDUname, parameter='ulTxSwitchingSupportList'),
    dict(value='slots40', dist_name=_NRCELL400name, parameter='preferredVoNrSrPeriod'),
    dict(value='slots40', dist_name=_NRCELL400name, parameter='srPeriodicityMin'),
    dict(value='n0', dist_name=_NRCELL400name, parameter='timingAdvanceOffset'),
    dict(value='n0', dist_name=_NRCELL410name, parameter='timingAdvanceOffset'),
    dict(value='n39936', dist_name=_NRCELL700name, parameter='timingAdvanceOffset'),
    dict(value='n39936', dist_name=_NRCELL701name, parameter='timingAdvanceOffset'),
    dict(value='unlocked', dist_name=_LTECELL48040name, parameter='administrativeState'),
    dict(value='unlocked', dist_name=_LTECELL48045name, parameter='administrativeState'),
    dict(value='Unlocked', dist_name=_NRCELL701name, parameter='administrativeState'),
    dict(value='5ms', dist_name=_NRDRB_12, parameter='srPeriodicityDrb'),
    dict(value='5ms', dist_name=_NRDRB_10, parameter='srPeriodicityDrb'),
    dict(value=['FR1 CA incompatible'], dist_name=_NRDRB_15, parameter='cellAggrLevel'),
    dict(value=['FR1 CA incompatible'], dist_name=_NRDRB_13, parameter='cellAggrLevel'),
]

PARAM_delete_gnb1_EDA_05437018_348 = [
    dict(dist_name=_NRCELL400name, parameter='maxNumScellsDlFr1'),
    dict(dist_name=_NRRELL400namegnb12, parameter='sCellAdditionMethod'),
    dict(dist_name=_NRRELL400namegnb12, parameter='sCellOperationalMode'),
    dict(dist_name=_NRCELL700name, parameter='increasePUSCHPrepTimeULCA'),
    dict(dist_name=_NRCELL700name, parameter='maxNumOfUlCaUeParallelTx'),
]

PARAM_12149_gnb1_DA_IWK8_383 = [
    # CB008236
    dict(value='Enabled_VoNr', dist_name=_NRCELLname, parameter='actUlSlotAgg'),
    dict(value='Disabled', dist_name=_NRCELL2name, parameter='actUlSlotAgg'),
    dict(value='Deact_Scells_VoNr_SAg', dist_name=_NRCELLname, parameter='sCellDeactInPoorRf'),
    dict(value='true', dist_name=_NRCELLname, parameter='actVoipPacketAggr'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actVoipPacketAggr'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlAudioGapReduction'),
    # CB008236
    dict(value='TypeB', dist_name=_NRCELLname, parameter='puschMappingType'),
    dict(value='disabled', dist_name=_NRBTSname, parameter='actBufferBasedSCellAddition'),
    dict(value='4', dist_name=_NRCELLname, parameter='maxNumScellsDlFr1'),
    dict(value='false', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    dict(value='infinity', dist_name=_NRCELLname, parameter='sCellDeactivationTimerGNB'),
    dict(value='infinity', dist_name=_NRCELL2name, parameter='sCellDeactivationTimerGNB'),
    dict(value='1TTI', dist_name=_NRCELLname, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL2name, parameter='sCellActivationLevel'),
    dict(value='5TTI', dist_name=_NRCELLname, parameter='sCellActivationLevelUL'),
    dict(value='5TTI', dist_name=_NRCELL2name, parameter='sCellActivationLevelUL'),
    dict(value='longPucch', dist_name=_NRCELLname, parameter='pucchModeSelect'),
    dict(value='longPucch', dist_name=_NRCELL2name, parameter='pucchModeSelect'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELLname, parameter='actAdaptiveReTxResMcs'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcs'),
    dict(value='false', dist_name=_NRCELLname, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELLname, parameter='actShortBsrLimitAdaptation'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actShortBsrLimitAdaptation'),
    dict(value='slots20', dist_name=_NRCELLname, parameter='srPeriodicity'),
    dict(value='true', dist_name=_NRCELL1_FDD1, parameter='actPerCsiReportBundlingFdd'),
    dict(value='zeroDot15', dist_name=_NRCELLname, parameter='pucchF3MaxCodeRate'),
    dict(value='zeroDot15', dist_name=_NRCELL2name, parameter='pucchF3MaxCodeRate'),
    dict(value='qpsk_4psk', dist_name=_NRCELLname, parameter='pucchF3ModulationScheme'),
    dict(value='qpsk_4psk', dist_name=_NRCELL2name, parameter='pucchF3ModulationScheme'),
    dict(value='true', dist_name=_NRCELL2name, parameter='increasePUSCHPrepTimeULCA'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actRescheduleBlockedRetx'),
    dict(value='1', dist_name=_NRCELL2name, parameter='maxNumOfUlCaUeParallelTx'),
    dict(value='true', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='50', dist_name=_NRBTSDUname, parameter='dlToUlContributionRatio'),
    dict(value='bufferBased', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='15', dist_name=_NRBTSname, parameter='ulTxSwitchingBoost'),
    dict(value='sf10', dist_name=_NRBTSname, parameter='periodicBSRTimer'),
    dict(value=['ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fdd', 'ca_Fdd_Any_Sa', 'ca_Fdd_Fr1Tdd_Sa_WithUl'],
         dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    dict(value=['ca_F_Fr1T_Sa_switchedUl'], dist_name=_NRBTSDUname, parameter='ulTxSwitchingSupportList'),
    dict(value='blind', dist_name=_NRREL2namegnb1, parameter='sCellAdditionMethod'),
    dict(value='dlAndUl', dist_name=_NRREL2namegnb1, parameter='sCellOperationalMode'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL'),
    dict(value='slots20', dist_name=_NRCELLname, parameter='preferredVoNrSrPeriod'),
    dict(value='slots10', dist_name=_NRCELLname, parameter='srPeriodicityMin'),
    dict(value='n25600', dist_name=_NRCELL2name, parameter='timingAdvanceOffset'),
    dict(value='n25600', dist_name=_NRCELL21name, parameter='timingAdvanceOffset'),
    dict(value='Locked', dist_name=_NRCELL21name, parameter='administrativeState'),
]

PARAM_12149_recover_gnb1_DA_IWK8_383 = [
    # CB008236
    dict(value='Enabled_VoNr', dist_name=_NRCELLname, parameter='actUlSlotAgg'),
    dict(value='Disabled', dist_name=_NRCELL2name, parameter='actUlSlotAgg'),
    dict(value='None', dist_name=_NRCELLname, parameter='sCellDeactInPoorRf'),
    dict(value='true', dist_name=_NRCELLname, parameter='actVoipPacketAggr'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actVoipPacketAggr'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUlAudioGapReduction'),
    # CB008236
    dict(value='TypeA', dist_name=_NRCELLname, parameter='puschMappingType'),
    dict(value='oneShot_Dl_Fr1', dist_name=_NRBTSname, parameter='actBufferBasedSCellAddition'),
    dict(value='true', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    dict(value='ms1280', dist_name=_NRCELLname, parameter='sCellDeactivationTimerGNB'),
    dict(value='ms1280', dist_name=_NRCELL2name, parameter='sCellDeactivationTimerGNB'),
    dict(value='1TTI', dist_name=_NRCELLname, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL2name, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELLname, parameter='sCellActivationLevelUL'),
    dict(value='1TTI', dist_name=_NRCELL2name, parameter='sCellActivationLevelUL'),
    dict(value='longPucch', dist_name=_NRCELLname, parameter='pucchModeSelect'),
    dict(value='longPucch', dist_name=_NRCELL2name, parameter='pucchModeSelect'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELLname, parameter='actAdaptiveReTxResMcs'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcs'),
    dict(value='false', dist_name=_NRCELLname, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELLname, parameter='actShortBsrLimitAdaptation'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actShortBsrLimitAdaptation'),
    dict(value='slots80', dist_name=_NRCELLname, parameter='srPeriodicity'),
    dict(value='false', dist_name=_NRCELL1_FDD1, parameter='actPerCsiReportBundlingFdd'),
    dict(value='zeroDot15', dist_name=_NRCELLname, parameter='pucchF3MaxCodeRate'),
    dict(value='zeroDot15', dist_name=_NRCELL2name, parameter='pucchF3MaxCodeRate'),
    dict(value='qpsk_4psk', dist_name=_NRCELLname, parameter='pucchF3ModulationScheme'),
    dict(value='qpsk_4psk', dist_name=_NRCELL2name, parameter='pucchF3ModulationScheme'),
    dict(value='true', dist_name=_NRCELL2name, parameter='increasePUSCHPrepTimeULCA'),
    dict(value='false', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actRescheduleBlockedRetx'),
    dict(value='1', dist_name=_NRCELL2name, parameter='maxNumOfUlCaUeParallelTx'),
    dict(value='101', dist_name=_NRBTSDUname, parameter='dlToUlContributionRatio'),
    dict(value='bufferBased', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='15', dist_name=_NRBTSname, parameter='ulTxSwitchingBoost'),
    dict(value='sf10', dist_name=_NRBTSname, parameter='periodicBSRTimer'),
    dict(value=['ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Sa_WithUl'],
         dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    dict(value=['none'], dist_name=_NRBTSDUname, parameter='ulTxSwitchingSupportList'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL'),
    dict(value='slots40', dist_name=_NRCELLname, parameter='preferredVoNrSrPeriod'),
    dict(value='slots40', dist_name=_NRCELLname, parameter='srPeriodicityMin'),
    dict(value='n39936', dist_name=_NRCELL2name, parameter='timingAdvanceOffset'),
    dict(value='n39936', dist_name=_NRCELL21name, parameter='timingAdvanceOffset'),
    dict(value='Unlocked', dist_name=_NRCELL21name, parameter='administrativeState'),
]

PARAM_12149_delete_gnb1_DA_IWK8_383 = [
    dict(dist_name=_NRCELLname, parameter='maxNumScellsDlFr1'),
    dict(dist_name=_NRREL2namegnb1, parameter='sCellAdditionMethod'),
    dict(dist_name=_NRREL2namegnb1, parameter='sCellOperationalMode'),
]

ListToAdd_12149_gnb1_D_IWK6 = [
    dict(
        dist_name=_NRCELL3name,
        list_name='a2MeasSCellRelSsbRsrp',
        elements=dict(
            a2HysteresisSCellRelSsbRsrp='0',
            a2ThresholdSCellRelSsbRsrp='40',
            a2ThresholdUlTxSwitchingDelta='1',
            a2TimeToTriggerSCellRelSsbRsrp='320ms')),
    dict(
        dist_name=_NRCELL2name,
        list_name='a2MeasSCellRelSsbRsrp',
        elements=dict(
            a2HysteresisSCellRelSsbRsrp='0',
            a2ThresholdSCellRelSsbRsrp='40',
            a2TimeToTriggerSCellRelSsbRsrp='320ms')),
    dict(
        dist_name=_NRCELL3name,
        list_name='a6MeasSCellSwapSsbRsrp',
        elements=dict(
            a6HysteresisSCellSwapSsbRsrp='0',
            a6OffsetSCellSwapSsbRsrp='2',
            useAllowedCellListRsrp='true',
            a6TimeToTrigSCellSwapSsbRsrp='ms320')),
    dict(
        dist_name=_NRCELL3name,
        list_name='a6MeasSCellSwapSsbRsrq',
        elements=dict(
            a6HysteresisSCellSwapSsbRsrq='0',
            a6OffsetSCellSwapSsbRsrq='2',
            useAllowedCellListRsrq='false',
            a6TimeToTrigSCellSwapSsbRsrq='ms320')),
    dict(
        dist_name=_NRCELL2name,
        list_name='a1MeasSCellAddSsbRsrp',
        elements=dict(
            a1HysteresisSCellAddSsbRsrp='0',
            a1ThresholdSCellAddSsbRsrpFDD='80',
            a1ThresholdSCellAddSsbRsrpTDD='80',
            a1ThresholdUlTxSwitchingDelta='2',
            a1TimeToTriggerSCellAddSsbRsrp='320ms')),
    dict(
        dist_name=_NRCELL3name,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            bwpDN=_NRBTSname + '/BWP_PROFILE-7',
            pdcchResourcePreference='peakRate',
            cellBwpId='0')
    ),
    dict(
        dist_name=_NRCELL3name,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='true',
            actUpperThrAckNackHrFiltering='true',
            bwpDN=_NRBTSname + '/BWP_PROFILE-8',
            pdcchResourcePreference='peakRate',
            cellBwpId='1')
    ),
    dict(
        dist_name=_NRCELL4name,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            bwpDN=_NRBTSname + '/BWP_PROFILE-7',
            pdcchResourcePreference='peakRate',
            cellBwpId='0')
    ),
    dict(
        dist_name=_NRCELL4name,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='true',
            actUpperThrAckNackHrFiltering='true',
            bwpDN=_NRBTSname + '/BWP_PROFILE-8',
            pdcchResourcePreference='peakRate',
            cellBwpId='1')
    ),
    dict(elements=['ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fdd', 'ca_Fdd_Any_Sa', 'ca_Fdd_Fr1Tdd_Sa_WithUl'],
         dist_name=_NRBTSDUname, list_name='carrierAggregationSupportList')
]

gnb1_12149_DA_IWK16_MOsToAdd = [
    dict(class_name='com.nokia.srbts.nrbts:NRULCG_PROFILE', dist_name=_NRULCG_PROFILE_2, version="NRBTSCL24R3_2412_101")
]

CB012149_IWK16_pcell_check_kpi_names_value_zero = [
    "CG_INI_TX_PUSCH_UNSUCC",
    "CG_RE_TX_PUSCH_SUCC",
    "CG_RE_TX_PUSCH_UNSUCC",
    "UL_CG_DEACT_ATT",
    "UL_CG_DEACT_ATT_SUCC"
]
CB012149_IWK16_pcell_check_kpi_names_value_larger_zero = [
    "UL_CG_ACT_ATT",
    "UL_CG_ACT_ATT_SUCC",
    "CG_INI_TX_PUSCH_SUCC",
    "PEAK_CG_ACT_UE",
    "PRB_ALLOC_CG_ACT_PUSCH",
    "TOT_CG_ACT_UE",
    "UL_SLOT_ALLOC_CG"
]

CB012149_DA_pcell_check_kpi_names_value_zero = [
    "SUM_1L_PUSCH_REC_SCELL_ACT_2P",
    "SUM_2L_PUSCH_REC_SCELL_ACT_2P",
]
CB012149_DA_pcell_check_kpi_names_value_larger_zero = [
    "ACC_NUM_UL_TX_SW_OP1_UE_CAP",
    "ACC_NUM_UL_TX_SW_OP1_UE_CONFG",
    "DEN_1_SEC_SAMPLE",
    "AVG_NUM_UE_DENOM",
    "SUM_1L_PUSCH_REC_SCELL_ACT_1P"
]
CB012149_DA_scell_check_kpi_names_value_larger_zero = [
    "SUM_2L_PUSCH_REC_SCELL_ACT_2P",
    "DEN_1_SEC_SAMPLE",
    "AVG_NUM_UE_DENOM",
]
CB012149_DA_scell_check_kpi_names_value_zero = [
    "ACC_NUM_UL_TX_SW_OP1_UE_CAP",
    "ACC_NUM_UL_TX_SW_OP1_UE_CONFG",
    "SUM_1L_PUSCH_REC_SCELL_ACT_2P",
    "SUM_1L_PUSCH_REC_SCELL_ACT_1P"
]

CB012149_BB_04_pcell_check_kpi_names_value_zero = [
    "SUM_1L_PUSCH_REC_SCELL_ACT_2P",
    "SUM_2L_PUSCH_REC_SCELL_ACT_2P",
]
CB012149_BB_04_pcell_check_kpi_names_value_larger_zero = [
    "ACC_NUM_UL_TX_SW_OP1_UE_CAP",
    "ACC_NUM_UL_TX_SW_OP1_UE_CONFG",
    "DEN_1_SEC_SAMPLE",
    "AVG_NUM_UE_DENOM",
    "SUM_1L_PUSCH_REC_SCELL_ACT_1P"
]
CB012149_BB_04_scell_check_kpi_names_value_larger_zero = [
    "SUM_1L_PUSCH_REC_SCELL_ACT_2P",
    "SUM_2L_PUSCH_REC_SCELL_ACT_2P",
    "DEN_1_SEC_SAMPLE",
    "AVG_NUM_UE_DENOM",
]
CB012149_BB_04_after_25r3_cni_141831_pcell_check_kpi_names_value_zero = [
    "SUM_1L_PUSCH_REC_SCELL_ACT_2P",
    "SUM_2L_PUSCH_REC_SCELL_ACT_2P",
    "ACC_NUM_UL_TX_SW_OP1_UE_CONFG",
]
CB012149_BB_04_after_25r3_cni_141831_pcell_check_kpi_names_value_larger_zero = [
    "ACC_NUM_UL_TX_SW_OP1_UE_CAP",
    "DEN_1_SEC_SAMPLE",
    "AVG_NUM_UE_DENOM",
    "SUM_1L_PUSCH_REC_SCELL_ACT_1P"
]

CB012149_IWK8_scell_check_kpi_names_value_larger_zero = [
    "SCELL_DEACT_SAG",
    "SCELL_UL_SUSPEND_SAG"
]

CB012149_IWK6_pcell_check_kpi_names_value_larger_zero = [
    "SCELL_SWAP_1_ATT_SA",
    "SCELL_SWAP_1_SUCC_SA"
]

CB012149_BB_04_scell_check_kpi_names_value_zero = [
    "ACC_NUM_UL_TX_SW_OP1_UE_CAP",
    "ACC_NUM_UL_TX_SW_OP1_UE_CONFG",
    "SUM_1L_PUSCH_REC_SCELL_ACT_1P"
]
