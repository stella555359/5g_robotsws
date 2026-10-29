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
_NRCELLname = _NRBTSname + '/NRCELL-1'
_NRCELL2name = _NRBTSname + '/NRCELL-2'
_NRCELL3name = _NRBTSname + '/NRCELL-3'
_NRCELL4name = _NRBTSname + '/NRCELL-4'
_NRCELL21name = _NRBTSname + '/NRCELL-21'
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
_NRRELLnamegnb23 = _NRCELL2name + '/NRREL-3'
_NRRELLnamegnb2 = _NRCELLname2 + '/NRREL-2'
_NRRELLnamegnb20 = _NRCELLname2 + '/NRREL-1'
_NRREL21namegnb1 = _NRCELL2name + '/NRREL-1'
_SERVEDAMF = _NRBTSname + '/SERVEDAMF-1'
_NRDU = _NRBTSname + '/NRDU-9999'
_LTEENB = _NRBTSname + '/LTEENB-0'
_LTEENB2 = _NRBTSname2 + '/LTEENB-0'
_NRRELL2NRREDRT = _NRCELL2name + '/NRREDRT-0'
_NRRELL1NRREDRT = _NRCELLname + '/NRREDRT-1'
_NRPUSCHHRLA_1 = _NRBTSname + '/NRPUSCHHRLA-1'
_NRPUSCHHRLA2_1 = _NRBTSname2 + '/NRPUSCHHRLA-1'
_NRPMRNL_1 = _NRBTSname + '/NRPMRNL-1'
_NRPMRNL2_1 = _NRBTSname2 + '/NRPMRNL-1'
_alSelection = _NRBTSname + '/BWP_PROFILE-54'
_BWP_PROFILE_54 = _alSelection + '/PDCCH-1'
_NRPDSCHHRLA_1 = _NRBTSname + '/NRPDSCHHRLA-1'
_NRPDSCHHRLA_2 = _NRBTSname + '/NRPDSCHHRLA-2'
_NRPDCCHHRLA_1 = _NRBTSname + '/NRPDCCHHRLA-1'
_NRDRB4name = _NRBTSname + '/NRDRB-4'
_NRDRB5name = _NRBTSname + '/NRDRB-5'
_NRDRB10name = _NRBTSname + '/NRDRB-10'
_NRDRB12name = _NRBTSname + '/NRDRB-12'
_NRDRB13name = _NRBTSname + '/NRDRB-13'
_NRDRB15name = _NRBTSname + '/NRDRB-15'
_NRDRB16name = _NRBTSname + '/NRDRB-16'

_NRPDSCHHRLA2_1 = _NRBTSname2 + '/NRPDSCHHRLA-1'
_NRPDSCHHRLA2_2 = _NRBTSname2 + '/NRPDSCHHRLA-2'
_NRPDCCHHRLA2_1 = _NRBTSname2 + '/NRPDCCHHRLA-1'
_NRDRB10name2 = _NRBTSname2 + '/NRDRB-10'
_NRDRB12name2 = _NRBTSname2 + '/NRDRB-12'
_NRDRB13name2 = _NRBTSname2 + '/NRDRB-13'
_NRDRB15name2 = _NRBTSname2 + '/NRDRB-15'
_NRDRB16name2 = _NRBTSname2 + '/NRDRB-16'

_BWP_PROFILE_41 = _NRBTSname + '/BWP_PROFILE-41'
_BWP_PROFILE_42 = _NRBTSname + '/BWP_PROFILE-42'
_BWP_PROFILE_43 = _NRBTSname + '/BWP_PROFILE-43'
_BWP_PROFILE_5 = _NRBTSname + '/BWP_PROFILE-5'
_BWP_PROFILE_054 = _NRBTSname + '/BWP_PROFILE-54'
_BWP_PROFILE_42_PDCCH_1 = _BWP_PROFILE_42 + '/PDCCH-1'
_BWP_PROFILE_087 = _NRBTSname + '/BWP_PROFILE-87'
_BWP_PROFILE_088 = _NRBTSname + '/BWP_PROFILE-88'
_BWP_PROFILE_089 = _NRBTSname + '/BWP_PROFILE-89'

_initial_MME_IP = '10.110.115.132'
_MME_IP = '10.110.194.171'
# _LNMME_0 = _LNBTSname + '/LNMME-0'
_LNMME_0 = f"{_MRBTSname_enb}/LNBTS-{_enb_id}/LNMME-0"
_LNMME_MO = f"{_MRBTSname_enb}/LNBTS-{_enb_id}/LNMME-0"

NRPUSCHHRLA_GNB1 = _NRBTSname + '/NRPUSCHHRLA-1'
NRPDSCHHRLA_GNB1 = _NRBTSname + '/NRPDSCHHRLA-1'
NRCELLname_GNB1 = _NRBTSname + '/NRCELL-1'
NRCELL2name_GNB1 = _NRBTSname + '/NRCELL-2'
NRCELL3name_GNB1 = _NRBTSname + '/NRCELL-3'
NRCELL700name_GNB1 = _NRBTSname + '/NRCELL-700'

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

_NRCELL400name = _NRBTSname + '/NRCELL-400'
_NRCELL410name = _NRBTSname + '/NRCELL-410'
_NRCELL544name = _NRBTSname + '/NRCELL-544'
_NRCELL545name = _NRBTSname + '/NRCELL-545'
_NRCELL644name = _NRBTSname + '/NRCELL-644'
_NRCELL645name = _NRBTSname + '/NRCELL-645'
_NRCELL700name = _NRBTSname + '/NRCELL-700'
_NRCELL701name = _NRBTSname + '/NRCELL-701'

_NRREL400_2namegnb1 = _NRCELL400name + '/NRREL-2'
_NRREL544_1namegnb1 = _NRCELL544name + '/NRREL-1'

_NRCELL400_FDD1 = _NRCELL400name + '/NRCELL_FDD-1'
_NRCELL544_FDD1 = _NRCELL544name + '/NRCELL_FDD-1'
_NRDLMUMIMO_1_700 = _NRCELL700name + '/NRDLMUMIMO-1'

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

PATH_TO_SCF = ''

CB008246_ciphering_algorithms_json_file = 'CB008246_ciphering_algorithms.json'
CB008246_ciphering_algorithms = [
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

CB008246_recover_ciphering_algorithms_json_file = 'CB008246_recover_ciphering_algorithms.json'
CB008246_recover_ciphering_algorithms = [
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

# cases 8246_D_006 TRUNK####
counter_id_D006_HR_gNB1_cell2_New = [
    'M55366C00001', 'M55366C00002', 'M55366C00005', 'M55366C00006', 'M55308C00005', 'M55308C00008',
    'M55308C03001', 'M55308C03005', 'M55308C10001', 'M55308C10003', 'M55309C01001', 'M55308C02000'
]

Trunk_counter_dic_path_D006_HR_gNB1_cell2_New = [
    f'BTS/{_NRBTSname}/NRCELL-2/DHQLSE', f'BTS/{_NRBTSname}/NRCELL-2/DHQLSE', f'BTS/{_NRBTSname}/NRCELL-2/DHQLSE',
    f'BTS/{_NRBTSname}/NRCELL-2/DHQLSE', f'BTS/{_NRBTSname}/NRCELL-2/NCELA', f'BTS/{_NRBTSname}/NRCELL-2/NCELA',
    f'BTS/{_NRBTSname}/NRCELL-2/NCELA', f'BTS/{_NRBTSname}/NRCELL-2/NCELA', f'BTS/{_NRBTSname}/NRCELL-2/NCELA',
    f'BTS/{_NRBTSname}/NRCELL-2/NCELA', f'BTS/{_NRBTSname}/NRCELL-2/NMSDU', f'BTS/{_NRBTSname}/NRCELL-2/NCELA'
]

counter_dic_path_D006_HR_gNB1_cell2_New = [
    'BTS/CELLS/NRCELL-2/DHQLSE', 'BTS/CELLS/NRCELL-2/DHQLSE', 'BTS/CELLS/NRCELL-2/DHQLSE',
    'BTS/CELLS/NRCELL-2/DHQLSE', 'BTS/CELLS/NRCELL-2/NCELA', 'BTS/CELLS/NRCELL-2/NCELA',
    'BTS/CELLS/NRCELL-2/NCELA', 'BTS/CELLS/NRCELL-2/NCELA', 'BTS/CELLS/NRCELL-2/NCELA',
    'BTS/CELLS/NRCELL-2/NCELA', 'BTS/CELLS/NRCELL-2/NMSDU', 'BTS/CELLS/NRCELL-2/NCELA'
]

counter_id_D006_BR_gNB1_cell2_New = [
    'M55366C00009', 'M55366C00010', 'M55366C00011', 'M55366C00012', 'M55308C00005', 'M55308C00008',
    'M55308C03001', 'M55308C03005', 'M55308C10001', 'M55308C10003', 'M55309C01001', 'M55308C02000'
]

Trunk_counter_dic_path_D006_BR_gNB1_cell2_New = [
    f'BTS/{_NRBTSname}/NRCELL-2/DHQLSE', f'BTS/{_NRBTSname}/NRCELL-2/DHQLSE', f'BTS/{_NRBTSname}/NRCELL-2/DHQLSE',
    f'BTS/{_NRBTSname}/NRCELL-2/DHQLSE', f'BTS/{_NRBTSname}/NRCELL-2/NCELA', f'BTS/{_NRBTSname}/NRCELL-2/NCELA',
    f'BTS/{_NRBTSname}/NRCELL-2/NCELA', f'BTS/{_NRBTSname}/NRCELL-2/NCELA', f'BTS/{_NRBTSname}/NRCELL-2/NCELA',
    f'BTS/{_NRBTSname}/NRCELL-2/NCELA', f'BTS/{_NRBTSname}/NRCELL-2/NMSDU', f'BTS/{_NRBTSname}/NRCELL-2/NCELA'
]

counter_dic_path_D006_BR_gNB1_cell2_New = [
    'BTS/CELLS/NRCELL-2/DHQLSE', 'BTS/CELLS/NRCELL-2/DHQLSE', 'BTS/CELLS/NRCELL-2/DHQLSE',
    'BTS/CELLS/NRCELL-2/DHQLSE', 'BTS/CELLS/NRCELL-2/NCELA', 'BTS/CELLS/NRCELL-2/NCELA',
    'BTS/CELLS/NRCELL-2/NCELA', 'BTS/CELLS/NRCELL-2/NCELA', 'BTS/CELLS/NRCELL-2/NCELA',
    'BTS/CELLS/NRCELL-2/NCELA', 'BTS/CELLS/NRCELL-2/NMSDU', 'BTS/CELLS/NRCELL-2/NCELA'
]

# cases 8246_D_008 TRUNK####
counter_id_D008_HR_gNB1_cell1_New = [
    'M55366C00001', 'M55366C00002', 'M55366C00005', 'M55366C00006', 'M55308C00005', 'M55308C00008',
    'M55308C03001', 'M55308C03005', 'M55308C10001', 'M55308C10003', 'M55309C01001', 'M55308C02000'
]

Trunk_counter_dic_path_D008_HR_gNB1_cell1_New = [
    f'BTS/{_NRBTSname}/NRCELL-1/DHQLSE', f'BTS/{_NRBTSname}/NRCELL-1/DHQLSE', f'BTS/{_NRBTSname}/NRCELL-1/DHQLSE',
    f'BTS/{_NRBTSname}/NRCELL-1/DHQLSE', f'BTS/{_NRBTSname}/NRCELL-1/NCELA', f'BTS/{_NRBTSname}/NRCELL-1/NCELA',
    f'BTS/{_NRBTSname}/NRCELL-1/NCELA', f'BTS/{_NRBTSname}/NRCELL-1/NCELA', f'BTS/{_NRBTSname}/NRCELL-1/NCELA',
    f'BTS/{_NRBTSname}/NRCELL-1/NCELA', f'BTS/{_NRBTSname}/NRCELL-1/NMSDU', f'BTS/{_NRBTSname}/NRCELL-1/NCELA'
]

counter_dic_path_D008_HR_gNB1_cell1_New = [
    'BTS/CELLS/NRCELL-1/DHQLSE', 'BTS/CELLS/NRCELL-1/DHQLSE', 'BTS/CELLS/NRCELL-1/DHQLSE',
    'BTS/CELLS/NRCELL-1/DHQLSE', 'BTS/CELLS/NRCELL-1/NCELA', 'BTS/CELLS/NRCELL-1/NCELA',
    'BTS/CELLS/NRCELL-1/NCELA', 'BTS/CELLS/NRCELL-1/NCELA', 'BTS/CELLS/NRCELL-1/NCELA',
    'BTS/CELLS/NRCELL-1/NCELA', 'BTS/CELLS/NRCELL-1/NMSDU', 'BTS/CELLS/NRCELL-1/NCELA'
]

counter_id_D008_BR_gNB1_cell1_New = [
    'M55366C00009', 'M55366C00010', 'M55366C00011', 'M55366C00012', 'M55308C00005', 'M55308C00008',
    'M55308C03001', 'M55308C03005', 'M55308C10001', 'M55308C10003', 'M55309C01001', 'M55308C02000'
]

Trunk_counter_dic_path_D008_BR_gNB1_cell1_New = [
    f'BTS/{_NRBTSname}/NRCELL-1/DHQLSE', f'BTS/{_NRBTSname}/NRCELL-1/DHQLSE', f'BTS/{_NRBTSname}/NRCELL-1/DHQLSE',
    f'BTS/{_NRBTSname}/NRCELL-1/DHQLSE', f'BTS/{_NRBTSname}/NRCELL-1/NCELA', f'BTS/{_NRBTSname}/NRCELL-1/NCELA',
    f'BTS/{_NRBTSname}/NRCELL-1/NCELA', f'BTS/{_NRBTSname}/NRCELL-1/NCELA', f'BTS/{_NRBTSname}/NRCELL-1/NCELA',
    f'BTS/{_NRBTSname}/NRCELL-1/NCELA', f'BTS/{_NRBTSname}/NRCELL-1/NMSDU', f'BTS/{_NRBTSname}/NRCELL-1/NCELA'
]

counter_dic_path_D008_BR_gNB1_cell1_New = [
    'BTS/CELLS/NRCELL-1/DHQLSE', 'BTS/CELLS/NRCELL-1/DHQLSE', 'BTS/CELLS/NRCELL-1/DHQLSE',
    'BTS/CELLS/NRCELL-1/DHQLSE', 'BTS/CELLS/NRCELL-1/NCELA', 'BTS/CELLS/NRCELL-1/NCELA',
    'BTS/CELLS/NRCELL-1/NCELA', 'BTS/CELLS/NRCELL-1/NCELA', 'BTS/CELLS/NRCELL-1/NCELA',
    'BTS/CELLS/NRCELL-1/NCELA', 'BTS/CELLS/NRCELL-1/NMSDU', 'BTS/CELLS/NRCELL-1/NCELA'
]

# cases 8246_L_005RUNK####
counter_id_L005_HR_gNB1_cell2 = [
    'M55366C00001', 'M55366C00002', 'M55367C00001', 'M55367C00002', 'M55365C03007', 'M55365C03008',
    'M55365C03002', 'M55365C03003'
]

counter_id_L005_HR_gNB1_cell700 = [
    'M55365C09001', 'M55365C09002', 'M55365C09003', 'M55365C09004', 'M55365C09006', 'M55365C09007',
    'M55365C09008', 'M55365C09009'
]

counter_dic_path_L005_HR_gNB1_cell2 = [
    'BTS/CELLS/NRCELL-2/DHQLSE', 'BTS/CELLS/NRCELL-2/DHQLSE', 'BTS/CELLS/NRCELL-2/UHQLSE',
    'BTS/CELLS/NRCELL-2/UHQLSE', 'BTS/CELLS/NRCELL-2/PDCCH2', 'BTS/CELLS/NRCELL-2/PDCCH2',
    'BTS/CELLS/NRCELL-2/PDCCH2', 'BTS/CELLS/NRCELL-2/PDCCH2'
]

Trunk_counter_dic_path_L005_HR_gNB1_cell2 = [
    f'BTS/{_NRBTSname}/NRCELL-2/DHQLSE', f'BTS/{_NRBTSname}/NRCELL-2/DHQLSE', f'BTS/{_NRBTSname}/NRCELL-2/UHQLSE',
    f'BTS/{_NRBTSname}/NRCELL-2/UHQLSE', f'BTS/{_NRBTSname}/NRCELL-2/PDCCH2', f'BTS/{_NRBTSname}/NRCELL-2/PDCCH2',
    f'BTS/{_NRBTSname}/NRCELL-2/PDCCH2', f'BTS/{_NRBTSname}/NRCELL-2/PDCCH2'
]

Trunk_counter_dic_path_L005_HR_gNB1_cell2_348 = [
    f'BTS/{_NRBTSname}/NRCELL-700/DHQLSE', f'BTS/{_NRBTSname}/NRCELL-700/DHQLSE',
    f'BTS/{_NRBTSname}/NRCELL-700/UHQLSE',
    f'BTS/{_NRBTSname}/NRCELL-700/UHQLSE', f'BTS/{_NRBTSname}/NRCELL-700/PDCCH2',
    f'BTS/{_NRBTSname}/NRCELL-700/PDCCH2',
    f'BTS/{_NRBTSname}/NRCELL-700/PDCCH2', f'BTS/{_NRBTSname}/NRCELL-700/PDCCH2'
]

Trunk_counter_dic_path_L005_HR_gNB1_cell700_348 = [
    f'BTS/{_NRBTSname}/NRCELL-700/PDCCH2', f'BTS/{_NRBTSname}/NRCELL-700/PDCCH2',
    f'BTS/{_NRBTSname}/NRCELL-700/PDCCH2',
    f'BTS/{_NRBTSname}/NRCELL-700/PDCCH2', f'BTS/{_NRBTSname}/NRCELL-700/PDCCH2',
    f'BTS/{_NRBTSname}/NRCELL-700/PDCCH2',
    f'BTS/{_NRBTSname}/NRCELL-700/PDCCH2', f'BTS/{_NRBTSname}/NRCELL-700/PDCCH2'
]

# cases 8246_J_003 TRUNK####
counter_id_J003_64QAM_BR_gNB1_cell1 = [
    'M55302C00033', 'M55302C00034'
]

counter_dic_path_J003_64QAM_BR_gNB1_cell1 = [
    'BTS/CELLS/NRCELL-1/NULHQ', 'BTS/CELLS/NRCELL-1/NULHQ'
]

Trunk_counter_dic_path_J003_64QAM_BR_gNB1_cell1 = [
    f'BTS/{_NRBTSname}/NRCELL-1/NULHQ', f'BTS/{_NRBTSname}/NRCELL-1/NULHQ'
]

counter_id_J003_64QAM_HR_gNB1_cell1 = [
    'M55302C00029', 'M55302C00030', 'M55302C00031', 'M55302C00032'
]

counter_dic_path_J003_64QAM_HR_gNB1_cell1 = [
    'BTS/CELLS/NRCELL-1/NULHQ', 'BTS/CELLS/NRCELL-1/NULHQ', 'BTS/CELLS/NRCELL-1/NULHQ', 'BTS/CELLS/NRCELL-1/NULHQ'
]

Trunk_counter_dic_path_J003_64QAM_HR_gNB1_cell1 = [
    f'BTS/{_NRBTSname}/NRCELL-1/NULHQ', f'BTS/{_NRBTSname}/NRCELL-1/NULHQ',
    f'BTS/{_NRBTSname}/NRCELL-1/NULHQ', f'BTS/{_NRBTSname}/NRCELL-1/NULHQ'
]

# cases 8246_J_005 TRUNK####
counter_id_J005_LowSE_BR_gNB1_cell1 = [
    'M55302C00033', 'M55302C00034'
]

Trunk_counter_dic_path_J005_LowSE_BR_gNB1_cell1 = [
    f'BTS/{_NRBTSname}/NRCELL-1/NULHQ', f'BTS/{_NRBTSname}/NRCELL-1/NULHQ'
]

counter_id_J005_LowSE_HR_gNB1_cell1 = [
    'M55367C00001', 'M55367C00002', 'M55367C00003', 'M55367C00004'
]

Trunk_counter_dic_path_J005_LowSE_HR_gNB1_cell1 = [
    f'BTS/{_NRBTSname}/NRCELL-1/UHQLSE', f'BTS/{_NRBTSname}/NRCELL-1/UHQLSE',
    f'BTS/{_NRBTSname}/NRCELL-1/UHQLSE', f'BTS/{_NRBTSname}/NRCELL-1/UHQLSE'
]

# cases 8246_J_006 TRUNK####
counter_id_J006_LowSE_HR_gNB1_cell1 = [
    'M55367C00001', 'M55367C00002', 'M55367C00003', 'M55367C00004'
]

counter_dic_path_J006_LowSE_HR_gNB1_cell1 = [
    'BTS/CELLS/NRCELL-1/UHQLSE', 'BTS/CELLS/NRCELL-1/UHQLSE', 'BTS/CELLS/NRCELL-1/UHQLSE', 'BTS/CELLS/NRCELL-1/UHQLSE'
]

Trunk_counter_dic_path_J006_LowSE_HR_gNB1_cell1 = [
    f'BTS/{_NRBTSname}/NRCELL-1/UHQLSE', f'BTS/{_NRBTSname}/NRCELL-1/UHQLSE',
    f'BTS/{_NRBTSname}/NRCELL-1/UHQLSE', f'BTS/{_NRBTSname}/NRCELL-1/UHQLSE'
]

# cases 8246_J_009 TRUNK####
counter_id_J009_LowSE_HR_gNB1_cell1 = [
    'M55367C00001', 'M55367C00002', 'M55367C00003', 'M55367C00004'
]

counter_dic_path_J009_LowSE_HR_gNB1_cell1 = [
    'BTS/CELLS/NRCELL-1/UHQLSE', 'BTS/CELLS/NRCELL-1/UHQLSE', 'BTS/CELLS/NRCELL-1/UHQLSE', 'BTS/CELLS/NRCELL-1/UHQLSE'
]

Trunk_counter_dic_path_J009_LowSE_HR_gNB1_cell1 = [
    f'BTS/{_NRBTSname}/NRCELL-1/UHQLSE', f'BTS/{_NRBTSname}/NRCELL-1/UHQLSE',
    f'BTS/{_NRBTSname}/NRCELL-1/UHQLSE', f'BTS/{_NRBTSname}/NRCELL-1/UHQLSE'
]

# cases 8246_R_007 TRUNK####
counter_id_R007_64QAM_HR_gNB1_cell2 = [
    'M55366C00013', 'M55366C00014', 'M55367C00013', 'M55308C01000', 'M55308C01001'
]

Trunk_counter_dic_path_R007_64QAM_HR_gNB1_cell2 = [
    f'BTS/{_NRBTSname}/NRCELL-2/DHQLSE', f'BTS/{_NRBTSname}/NRCELL-2/DHQLSE',
    f'BTS/{_NRBTSname}/NRCELL-2/UHQLSE', f'BTS/{_NRBTSname}/NRCELL-2/NCELA',
    f'BTS/{_NRBTSname}/NRCELL-2/NCELA'
]

counter_id_R007_64QAM_BR_gNB1_cell2 = [
    'M55366C00013', 'M55366C00014', 'M55367C00013', 'M55308C01000', 'M55308C01001'
]

Trunk_counter_dic_path_R007_64QAM_BR_gNB1_cell2 = [
    f'BTS/{_NRBTSname}/NRCELL-2/DHQLSE', f'BTS/{_NRBTSname}/NRCELL-2/DHQLSE',
    f'BTS/{_NRBTSname}/NRCELL-2/UHQLSE', f'BTS/{_NRBTSname}/NRCELL-2/NCELA',
    f'BTS/{_NRBTSname}/NRCELL-2/NCELA'
]

PARAM_8246_gnb1_72a_to_72e = [
    dict(value='true', dist_name=_NRCELL700name, parameter='actEcpri72e'),
    dict(value='true', dist_name=_NRCELL701name, parameter='actEcpri72e'),
    dict(value='16Rx', dist_name=_NRCELL700name, parameter='numberOfRxBeamforming'),
    dict(value='16Rx', dist_name=_NRCELL701name, parameter='numberOfRxBeamforming'),
    dict(value='true', dist_name=_LCELNR_4, parameter='actSimplChConfMAA'),
    dict(value='true', dist_name=_LCELNR_16, parameter='actSimplChConfMAA'),
]

OBJECT_DELETE_8246_gnb1_72a_to_72e = [
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

CB008246_72a_to_72e = [
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

PARAM_8246_gnb1_E_006 = [
    # dict(value='true', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    # dict(value='true', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    # dict(value='true', dist_name=_NRCELLname, parameter='scalingStepdownHREnabled'),
    # dict(value='true', dist_name=_NRCELL2name, parameter='scalingStepdownHREnabled'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='10000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutageTbsThresh'),
    dict(value='20000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverTbsThresh'),
    # dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrUlHarqLowSEMCS'),
    # dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrUlHarq'),
    # dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrSignalQualityLowSEMCS'),
    # dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrUlSignalQuality'),
    # dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrUlSignalQuality2'),
    # dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrMacSduReport'),
    # dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrCellUtilization'),
    # dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrMacPduTput'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_recover_gnb1_E_006 = [
    # dict(value='false', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    # dict(value='false', dist_name=_NRCELLname, parameter='scalingStepdownHREnabled'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='scalingStepdownHREnabled'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='500', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutageTbsThresh'),
    dict(value='4000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverTbsThresh'),
    # dict(value='disabled', dist_name=_NRPMRNL_1, parameter='miNrUlHarqLowSEMCS'),
    # dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrUlHarq'),
    # dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrSignalQualityLowSEMCS'),
    # dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrUlSignalQuality'),
    # dict(value='disabled', dist_name=_NRPMRNL_1, parameter='miNrUlSignalQuality2'),
    # dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrMacSduReport'),
    # dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrCellUtilization'),
    # dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrMacPduTput'),
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_gnb1_E_008 = [
    # dict(value='true', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    # dict(value='true', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    # dict(value='true', dist_name=_NRCELLname, parameter='scalingStepdownHREnabled'),
    # dict(value='true', dist_name=_NRCELL2name, parameter='scalingStepdownHREnabled'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='10000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutageTbsThresh'),
    dict(value='20000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverTbsThresh'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUlDftSOfdm'),
    # dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrUlHarqLowSEMCS'),
    # dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrUlHarq'),
    # dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrSignalQualityLowSEMCS'),
    # dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrUlSignalQuality'),
    # dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrUlSignalQuality2'),
    # dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrMacSduReport'),
    # dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrCellUtilization'),
    # dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrMacPduTput'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_recover_gnb1_E_008 = [
    # dict(value='false', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    # dict(value='false', dist_name=_NRCELLname, parameter='scalingStepdownHREnabled'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='scalingStepdownHREnabled'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='500', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutageTbsThresh'),
    dict(value='4000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverTbsThresh'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlDftSOfdm'),
    # dict(value='disabled', dist_name=_NRPMRNL_1, parameter='miNrUlHarqLowSEMCS'),
    # dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrUlHarq'),
    # dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrSignalQualityLowSEMCS'),
    # dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrUlSignalQuality'),
    # dict(value='disabled', dist_name=_NRPMRNL_1, parameter='miNrUlSignalQuality2'),
    # dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrMacSduReport'),
    # dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrCellUtilization'),
    # dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrMacPduTput'),
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_gnb1_G_008_2 = [
    dict(value=[dict(dllaCqiOffsetHR='0', dllaDeltaCqiMaxHR='15', dllaDeltaCqiMinHR='-15', dllaDeltaCqiStepdownHR='2',
                     dllaIniDeltaCqiHR='-5', dllaIniMcsHR='3', dllaMcsMax64qamLowSERANK1HR='25',
                     dllaMcsMax64qamLowSERANK2HR='25',
                     dllaMcsMax64qamLowSERANK3HR='20', dllaMcsMax64qamLowSERANK4HR='20', dllaMcsMax64qamRANK1HR='23',
                     dllaMcsMax64qamRANK2HR='23', dllaMcsMax64qamRANK3HR='20', dllaMcsMax64qamRANK4HR='20')],
         dist_name=_NRCELL2name, parameter='pdschHrLaConfig'),
]

parameters_to_update_8246_G_008 = [
    # dict(value='2', dist_name=_NRPDSCHHRLA_2, parameter='dlHRBlerOutageMcsThresh64qam'),
    dict(value='7', dist_name=_NRPDSCHHRLA_2, parameter='dlHRBlerOutageMcsThresh64qam'),
    dict(value='2', dist_name=_NRPDSCHHRLA_2, parameter='dlHRBlerOutageMcsThresh64qamLowSE'),
    dict(value='50', dist_name=_NRPDSCHHRLA_2, parameter='dlHRBlerOutagePercentage'),
    dict(value='20', dist_name=_NRPDSCHHRLA_2, parameter='dlHRBlerOutagePeriod'),
    # dict(value='28', dist_name=_NRPDSCHHRLA_2, parameter='dlHRBlerRecoverMcsThresh64qam'),
    dict(value='11', dist_name=_NRPDSCHHRLA_2, parameter='dlHRBlerRecoverMcsThresh64qam'),
    dict(value='10', dist_name=_NRPDSCHHRLA_2, parameter='dlHRBlerRecoverMcsThresh64qamLowSE'),
    dict(value='60', dist_name=_NRPDSCHHRLA_2, parameter='dlHRBlerRecoverPercentage'),
    dict(value='30', dist_name=_NRPDSCHHRLA_2, parameter='dlHRBlerRecoverPeriod'),
    dict(value='10', dist_name=_NRPDSCHHRLA_2, parameter='dllaBlerTargetHR'),
    dict(value='2', dist_name=_NRPDSCHHRLA_2, parameter='nrPdschHRLaId'),
    dict(value='110', dist_name=_NRPDSCHHRLA_2, parameter='scalFactorForHRGbrDl'),
]

PARAM_8246_gnb1_G_008 = [
    # dict(value='true', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    # dict(value='true', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    dict(value='10', dist_name=_NRCELL2name, parameter='dllaBlerTarget'),
    dict(value='static', dist_name=_BWP_PROFILE_54, parameter='alSelection'),
    dict(value='AL4', dist_name=_BWP_PROFILE_54, parameter='dciDedicatedAggregationLevelHR'),
    dict(value=[dict(dllaCqiOffsetHR='0', dllaDeltaCqiMaxHR='15', dllaDeltaCqiMinHR='-15', dllaDeltaCqiStepdownHR='2',
                     dllaIniDeltaCqiHR='-5', dllaIniMcsHR='3', dllaMcsMax64qamLowSERANK1HR='25',
                     dllaMcsMax64qamLowSERANK2HR='25',
                     dllaMcsMax64qamLowSERANK3HR='20', dllaMcsMax64qamLowSERANK4HR='20', dllaMcsMax64qamRANK1HR='20',
                     dllaMcsMax64qamRANK2HR='20', dllaMcsMax64qamRANK3HR='20', dllaMcsMax64qamRANK4HR='20')],
         dist_name=_NRCELL2name, parameter='pdschHrLaConfig'),
    dict(value='10', dist_name=_NRPDSCHHRLA_1, parameter='dllaBlerTargetHR'),
    # dict(value='0', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerOutageMcsThresh64qam'),
    dict(value='6', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerOutageMcsThresh64qam'),
    dict(value='10', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerRecoverMcsThresh64qam'),
    # dict(value='28', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerRecoverMcsThresh64qam'),
    dict(value='30', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerRecoverPeriod'),
    dict(value='60', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerRecoverPercentage'),
    dict(value=f'{_NRBTSname}/NRPDCCHHRLA-1', dist_name=_NRDRB10name, parameter='nrPdcchHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPDSCHHRLA-1', dist_name=_NRDRB10name, parameter='nrPdschHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPUSCHHRLA-1', dist_name=_NRDRB10name, parameter='nrPuschHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPDSCHHRLA-2', dist_name=_NRDRB12name, parameter='nrPdschHRLaDN'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDlMuMimo'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcs'),
    # dict(value=['none'], dist_name=_NRDU, parameter='carrierAggregationSupportList'),
    # dict(value='true', dist_name=_NRCELLname, parameter='scalingStepdownHREnabled'),
    # dict(value='true', dist_name=_NRCELL2name, parameter='scalingStepdownHREnabled'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUlDftSOfdm'),
    dict(value='10', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerRecoverPeriod'),
    dict(value='10', dist_name=_NRPDSCHHRLA_2, parameter='dlHRBlerRecoverPeriod'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_recover_gnb1_G_008 = [
    # dict(value='false', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    dict(value='10', dist_name=_NRCELL2name, parameter='dllaBlerTarget'),
    dict(value='dynamic', dist_name=_BWP_PROFILE_54, parameter='alSelection'),
    dict(value='AL4', dist_name=_BWP_PROFILE_54, parameter='dciDedicatedAggregationLevelHR'),
    dict(value=[dict(dllaCqiOffsetHR='0', dllaDeltaCqiMaxHR='15', dllaDeltaCqiMinHR='-15', dllaDeltaCqiStepdownHR='2',
                     dllaIniDeltaCqiHR='-5', dllaIniMcsHR='3', dllaMcsMax64qamLowSERANK1HR='25',
                     dllaMcsMax64qamLowSERANK2HR='25',
                     dllaMcsMax64qamLowSERANK3HR='20', dllaMcsMax64qamLowSERANK4HR='20', dllaMcsMax64qamRANK1HR='25',
                     dllaMcsMax64qamRANK2HR='25', dllaMcsMax64qamRANK3HR='20', dllaMcsMax64qamRANK4HR='20')],
         dist_name=_NRCELL2name, parameter='pdschHrLaConfig'),
    dict(value='10', dist_name=_NRPDSCHHRLA_1, parameter='dllaBlerTargetHR'),
    dict(value='3', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerOutageMcsThresh64qam'),
    dict(value='5', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerRecoverMcsThresh64qam'),
    dict(value='30', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerRecoverPeriod'),
    dict(value='60', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerRecoverPercentage'),
    dict(value=f'{_NRBTSname}/NRPDSCHHRLA-1', dist_name=_NRDRB12name, parameter='nrPdschHRLaDN'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDlMuMimo'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcs'),
    # dict(value=['none'], dist_name=_NRDU, parameter='carrierAggregationSupportList'),
    # dict(value='false', dist_name=_NRCELLname, parameter='scalingStepdownHREnabled'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='scalingStepdownHREnabled'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlDftSOfdm'),
    dict(value='10', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerRecoverPeriod'),
    dict(value='10', dist_name=_NRPDSCHHRLA_2, parameter='dlHRBlerRecoverPeriod'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

parameters_to_delete_8246_G_008 = [
    {'dist_name': _NRPDSCHHRLA_2}
]

PARAM_8246_recover_delete_gnb1_G_008 = [
    dict(value=f'{_NRBTSname}/NRPDCCHHRLA-1', dist_name=_NRDRB10name, parameter='nrPdcchHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPDSCHHRLA-1', dist_name=_NRDRB10name, parameter='nrPdschHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPUSCHHRLA-1', dist_name=_NRDRB10name, parameter='nrPuschHRLaDN')

]

PARAM_8246_gnb1_D_006 = [
    # dict(value='true', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    # dict(value='true', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    # dict(value='false', dist_name=_NRCELLname, parameter='actDl256Qam'),
    # dict(value='false', dist_name=_NRCELLname, parameter='actUl256Qam'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    # dict(value='false', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    # dict(value='true', dist_name=_NRCELLname, parameter='scalingStepdownHREnabled'),
    # dict(value='true', dist_name=_NRCELL2name, parameter='scalingStepdownHREnabled'),
    # dict(value='false', dist_name=_NRCELLname, parameter='actUlDftSOfdm'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_recover_gnb1_D_006 = [
    # dict(value='false', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    # dict(value='true', dist_name=_NRCELLname, parameter='actDl256Qam'),
    # dict(value='true', dist_name=_NRCELLname, parameter='actUl256Qam'),
    # dict(value='true', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    # dict(value='true', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    # dict(value='true', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    # dict(value='false', dist_name=_NRCELLname, parameter='scalingStepdownHREnabled'),
    # dict(value='false', dist_name=_NRCELL2name, paramreter='scalingStepdownHREnabled'),
    # dict(value='true', dist_name=_NRCELLname, parameter='actUlDftSOfdm'),
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_gnb1_D_008 = [
    # dict(value='true', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    # dict(value='true', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    # dict(value='false', dist_name=_NRCELLname, parameter='actDl256Qam'),
    # dict(value='false', dist_name=_NRCELLname, parameter='actUl256Qam'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    # dict(value='false', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    # dict(value='true', dist_name=_NRCELLname, parameter='scalingStepdownHREnabled'),
    # dict(value='true', dist_name=_NRCELL2name, parameter='scalingStepdownHREnabled'),
    # dict(value='false', dist_name=_NRCELLname, parameter='actUlDftSOfdm'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_recover_gnb1_D_008 = [
    # dict(value='false', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    # dict(value='true', dist_name=_NRCELLname, parameter='actDl256Qam'),
    # dict(value='true', dist_name=_NRCELLname, parameter='actUl256Qam'),
    # dict(value='true', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    # dict(value='true', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    # dict(value='true', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    # dict(value='false', dist_name=_NRCELLname, parameter='scalingStepdownHREnabled'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='scalingStepdownHREnabled'),
    # dict(value='true', dist_name=_NRCELLname, parameter='actUlDftSOfdm'),
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_gnb1_H_006 = [
    # dict(value='true', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    # dict(value='true', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    # dict(value='true', dist_name=_NRCELLname, parameter='scalingStepdownHREnabled'),
    # dict(value='true', dist_name=_NRCELL2name, parameter='scalingStepdownHREnabled'),
    dict(value='40MHz', dist_name=_NRCELLname, parameter='chBw'),
    dict(value='false', dist_name=_NRCELLname, parameter='actRel16DmrsForPusch'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='500', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutageTbsThresh'),
    dict(value='4000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverTbsThresh'),
    # dict(value='false', dist_name=_NRCELLname, parameter='actUlDftSOfdm'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrPdcch2'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrPdcch'),
    dict(value=[dict(
        cqiDciCssAl2HR='110', cqiDciCssAl4HR='100', cqiDciCssAl8HR='90')],
        dist_name=_BWP_PROFILE_42_PDCCH_1,
        parameter='dynamicAggregationLevelHRSet'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_recover_gnb1_H_006 = [
    # dict(value='false', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    # dict(value='false', dist_name=_NRCELLname, parameter='scalingStepdownHREnabled'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='scalingStepdownHREnabled'),
    dict(value='100MHz', dist_name=_NRCELLname, parameter='chBw'),
    dict(value='true', dist_name=_NRCELLname, parameter='actRel16DmrsForPusch'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='500', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutageTbsThresh'),
    dict(value='4000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverTbsThresh'),
    # dict(value='true', dist_name=_NRCELLname, parameter='actUlDftSOfdm'),
    dict(value='disabled', dist_name=_NRPMRNL_1, parameter='miNrPdcch2'),
    dict(value='disabled', dist_name=_NRPMRNL_1, parameter='miNrPdcch'),
    dict(value=[dict(
        cqiDciCssAl2HR='94', cqiDciCssAl4HR='65', cqiDciCssAl8HR='57')],
        dist_name=_BWP_PROFILE_42_PDCCH_1,
        parameter='dynamicAggregationLevelHRSet'),
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_list_8246_gnb1_H_006 = dict(
    value=[
        {
            'actPdcchCceFragmentControl': 'false',
            'actUpperThrAckNackFiltering': 'false',
            'actUpperThrAckNackHrFiltering': 'false',
            'bwpDN': _BWP_PROFILE_41,
            'cellBwpId': '0',
            'pdcchResourcePreference': 'peakRate'
        },
        {
            'actPdcchCceFragmentControl': 'false',
            'actUpperThrAckNackFiltering': 'true',
            'actUpperThrAckNackHrFiltering': 'true',
            'bwpDN': _BWP_PROFILE_42,
            'cellBwpId': '1',
            'pdcchResourcePreference': 'peakRate'
        },
        {
            'actPdcchCceFragmentControl': 'false',
            'actUpperThrAckNackFiltering': 'true',
            'actUpperThrAckNackHrFiltering': 'true',
            'bwpDN': _BWP_PROFILE_43,
            'cellBwpId': '2',
            'pdcchResourcePreference': 'peakRate'
        }
    ],
    dist_name=_NRCELLname,
    parameter='cellBwpList')

PARAM_list_8246_recover_gnb1_H_006 = dict(
    value=[
        {
            'actPdcchCceFragmentControl': 'false',
            'actUpperThrAckNackFiltering': 'false',
            'actUpperThrAckNackHrFiltering': 'false',
            'bwpDN': _BWP_PROFILE_5,
            'cellBwpId': '0',
            'pdcchResourcePreference': 'peakRate'
        },
        {
            'actPdcchCceFragmentControl': 'false',
            'actUpperThrAckNackFiltering': 'true',
            'actUpperThrAckNackHrFiltering': 'true',
            'bwpDN': _BWP_PROFILE_054,
            'cellBwpId': '1',
            'pdcchResourcePreference': 'peakRate'
        },
        {
            'actPdcchCceFragmentControl': 'false',
            'actUpperThrAckNackFiltering': 'true',
            'actUpperThrAckNackHrFiltering': 'true',
            'bwpDN': _BWP_PROFILE_089,
            'cellBwpId': '2',
            'pdcchResourcePreference': 'peakRate'
        }
    ],
    dist_name=_NRCELLname,
    parameter='cellBwpList')

PARAM_8246_gnb1_I_007 = [
    # dict(value='true', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    # dict(value='true', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    # dict(value='true', dist_name=_NRCELLname, parameter='scalingStepdownHREnabled'),
    # dict(value='true', dist_name=_NRCELL2name, parameter='scalingStepdownHREnabled'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='10000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutageTbsThresh'),
    dict(value='20000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverTbsThresh'),
    # in oder to fix issue on radioNetwork: radio-resources-not-available (22) when attach 5QI-3, mapping CN
    dict(value='30000', dist_name=_NRDRB16name, parameter='maxDataRateGbrDl'),
    dict(value='30000', dist_name=_NRDRB16name, parameter='maxDataRateGbrUl'),
    dict(value=_NRPDCCHHRLA_1, dist_name=_NRDRB16name, parameter='nrPdcchHRLaDN'),
    dict(value=_NRPDSCHHRLA_1, dist_name=_NRDRB16name, parameter='nrPdschHRLaDN'),
    dict(value=_NRPUSCHHRLA_1, dist_name=_NRDRB16name, parameter='nrPuschHRLaDN'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_recover_gnb1_I_007 = [
    # dict(value='false', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    # dict(value='false', dist_name=_NRCELLname, parameter='scalingStepdownHREnabled'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='scalingStepdownHREnabled'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='500', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutageTbsThresh'),
    dict(value='4000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverTbsThresh'),
    dict(value='1000', dist_name=_NRDRB16name, parameter='maxDataRateGbrDl'),
    dict(value='1000', dist_name=_NRDRB16name, parameter='maxDataRateGbrUl'),
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_recover_delete_gnb1_I_007 = [
    dict(dist_name=_NRDRB16name, parameter='nrPdcchHRLaDN'),
    dict(dist_name=_NRDRB16name, parameter='nrPdschHRLaDN'),
    dict(dist_name=_NRDRB16name, parameter='nrPuschHRLaDN'),
]

parameters_to_update_8246_H_001 = [
    dict(value='1', dist_name=_NRPDSCHHRLA_2, parameter='dlHRBlerOutageMcsThresh64qam'),
    dict(value='2', dist_name=_NRPDSCHHRLA_2, parameter='dlHRBlerOutageMcsThresh64qamLowSE'),
    dict(value='50', dist_name=_NRPDSCHHRLA_2, parameter='dlHRBlerOutagePercentage'),
    dict(value='20', dist_name=_NRPDSCHHRLA_2, parameter='dlHRBlerOutagePeriod'),
    dict(value='5', dist_name=_NRPDSCHHRLA_2, parameter='dlHRBlerRecoverMcsThresh64qam'),
    dict(value='14', dist_name=_NRPDSCHHRLA_2, parameter='dlHRBlerRecoverMcsThresh64qamLowSE'),
    dict(value='60', dist_name=_NRPDSCHHRLA_2, parameter='dlHRBlerRecoverPercentage'),
    dict(value='10', dist_name=_NRPDSCHHRLA_2, parameter='dlHRBlerRecoverPeriod'),
    dict(value='9', dist_name=_NRPDSCHHRLA_2, parameter='dllaBlerTargetHR'),
    dict(value='2', dist_name=_NRPDSCHHRLA_2, parameter='nrPdschHRLaId'),
    dict(value='110', dist_name=_NRPDSCHHRLA_2, parameter='scalFactorForHRGbrDl'),
]

PARAM_8246_gnb1_H_001 = [
    # dict(value='true', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    # dict(value='true', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    dict(value='10', dist_name=_NRCELL2name, parameter='dllaBlerTarget'),
    dict(value='dynamic', dist_name=_BWP_PROFILE_54, parameter='alSelection'),
    dict(value='AL4', dist_name=_BWP_PROFILE_54, parameter='dciDedicatedAggregationLevelHR'),
    # dict(value=[dict(dllaCqiOffsetHR='0', dllaDeltaCqiMaxHR='150', dllaDeltaCqiMinHR='-150',
    #      dllaDeltaCqiStepdownHR='500', dllaIniDeltaCqiHR='-30', dllaIniMcsHR='3', dllaMcsMax64qamLowSERANK1HR='28',
    #      dllaMcsMax64qamLowSERANK2HR='28', dllaMcsMax64qamLowSERANK3HR='28', dllaMcsMax64qamLowSERANK4HR='28',
    #      dllaMcsMax64qamRANK1HR='28', dllaMcsMax64qamRANK2HR='28', dllaMcsMax64qamRANK3HR='28',
    #      dllaMcsMax64qamRANK4HR='28')],
    #      dist_name=_NRCELLname, parameter='pdschHrLaConfig'),
    dict(value=[dict(aggregationLevelListHR='AL4_AL8', cqiCorrectionUpHR='2', cqiDciCssAl16HR='0', cqiDciCssAl1HR='106',
                     cqiDciCssAl2HR='74', cqiDciCssAl4HR='45', cqiDciCssAl8HR='37', highOlcCqiOffsetHR='1',
                     lowOlcCqiOffsetHR='1', pCqiErasureActTimerHR='160', pCqiErasureReductionHR='10',
                     pdcchCqiOffsetHR='10')],
         dist_name=_BWP_PROFILE_54, parameter='dynamicAggregationLevelHRSet'),
    dict(value='15', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerOutageMcsThresh64qamLowSE'),
    dict(value='20', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerRecoverMcsThresh64qamLowSE'),
    dict(value='10', dist_name=_NRPDSCHHRLA_1, parameter='dllaBlerTargetHR'),
    dict(value='10', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerRecoverPeriod'),
    dict(value='60', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerRecoverPercentage'),
    dict(value='20', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerOutagePeriod'),
    dict(value='20', dist_name=_NRPDSCHHRLA_2, parameter='dlHRBlerOutagePeriod'),
    dict(value=f'{_NRBTSname}/NRPDCCHHRLA-1', dist_name=_NRDRB10name, parameter='nrPdcchHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPDSCHHRLA-1', dist_name=_NRDRB10name, parameter='nrPdschHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPUSCHHRLA-1', dist_name=_NRDRB10name, parameter='nrPuschHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPDSCHHRLA-2', dist_name=_NRDRB12name, parameter='nrPdschHRLaDN'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDlMuMimo'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcs'),
    # dict(value=['none'], dist_name=_NRDU, parameter='carrierAggregationSupportList'),
    # dict(value='true', dist_name=_NRCELLname, parameter='scalingStepdownHREnabled'),
    # dict(value='true', dist_name=_NRCELL2name, parameter='scalingStepdownHREnabled'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUlDftSOfdm'),
    dict(value='10', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerRecoverPeriod'),
    dict(value='10', dist_name=_NRPDSCHHRLA_2, parameter='dlHRBlerRecoverPeriod'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_recover_gnb1_H_001 = [
    # dict(value='false', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    dict(value='10', dist_name=_NRCELL2name, parameter='dllaBlerTarget'),
    dict(value='dynamic', dist_name=_BWP_PROFILE_54, parameter='alSelection'),
    dict(value='AL4', dist_name=_BWP_PROFILE_54, parameter='dciDedicatedAggregationLevelHR'),
    # dict(value=[dict(dllaCqiOffsetHR='0', dllaDeltaCqiMaxHR='150', dllaDeltaCqiMinHR='-150',
    #      dllaDeltaCqiStepdownHR='500', dllaIniDeltaCqiHR='-30', dllaIniMcsHR='3', dllaMcsMax64qamLowSERANK1HR='28',
    #      dllaMcsMax64qamLowSERANK2HR='28', dllaMcsMax64qamLowSERANK3HR='28', dllaMcsMax64qamLowSERANK4HR='28',
    #      dllaMcsMax64qamRANK1HR='28', dllaMcsMax64qamRANK2HR='28', dllaMcsMax64qamRANK3HR='28',
    #      dllaMcsMax64qamRANK4HR='28')],
    #      dist_name=_NRCELLname, parameter='pdschHrLaConfig'),
    dict(value=[dict(aggregationLevelListHR='AL4_AL8', cqiCorrectionUpHR='1', cqiDciCssAl16HR='0', cqiDciCssAl1HR='106',
                     cqiDciCssAl2HR='74', cqiDciCssAl4HR='45', cqiDciCssAl8HR='37', highOlcCqiOffsetHR='1',
                     lowOlcCqiOffsetHR='1', pCqiErasureActTimerHR='0', pCqiErasureReductionHR='0',
                     pdcchCqiOffsetHR='10')],
         dist_name=_BWP_PROFILE_54, parameter='dynamicAggregationLevelHRSet'),
    dict(value='2', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerOutageMcsThresh64qamLowSE'),
    dict(value='14', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerRecoverMcsThresh64qamLowSE'),
    dict(value='10', dist_name=_NRPDSCHHRLA_1, parameter='dllaBlerTargetHR'),
    dict(value='10', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerRecoverPeriod'),
    dict(value='60', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerRecoverPercentage'),
    dict(value='20', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerOutagePeriod'),
    dict(value='20', dist_name=_NRPDSCHHRLA_2, parameter='dlHRBlerOutagePeriod'),
    dict(value=f'{_NRBTSname}/NRPDSCHHRLA-1', dist_name=_NRDRB12name, parameter='nrPdschHRLaDN'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDlMuMimo'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcs'),
    # dict(value=['none'], dist_name=_NRDU, parameter='carrierAggregationSupportList'),
    # dict(value='false', dist_name=_NRCELLname, parameter='scalingStepdownHREnabled'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='scalingStepdownHREnabled'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlDftSOfdm'),
    dict(value='10', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerRecoverPeriod'),
    dict(value='10', dist_name=_NRPDSCHHRLA_2, parameter='dlHRBlerRecoverPeriod'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

parameters_to_delete_8246_H_001 = [
    {'dist_name': _NRPDSCHHRLA_2}
]

PARAM_8246_recover_delete_gnb1_H_001 = [
    dict(value=f'{_NRBTSname}/NRPDCCHHRLA-1', dist_name=_NRDRB10name, parameter='nrPdcchHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPDSCHHRLA-1', dist_name=_NRDRB10name, parameter='nrPdschHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPUSCHHRLA-1', dist_name=_NRDRB10name, parameter='nrPuschHRLaDN')

]

PARAM_8246_gnb1_M_005 = [
    # dict(value='false', dist_name=_NRCELLname, parameter='actRel16DmrsForPusch'),
    dict(value='6', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerOutageMcsThresh64qam'),
    dict(value='10', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerRecoverMcsThresh64qam'),
    dict(value='30000', dist_name=_NRDRB16name, parameter='maxDataRateGbrDl'),
    dict(value='30000', dist_name=_NRDRB16name, parameter='maxDataRateGbrUl'),
    dict(value='10', dist_name=_NRCELL2name, parameter='dllaBlerTarget'),
    dict(value='dynamic', dist_name=_BWP_PROFILE_54, parameter='alSelection'),
    dict(value='AL4', dist_name=_BWP_PROFILE_54, parameter='dciDedicatedAggregationLevelHR'),
    # dict(value=[dict(dllaCqiOffsetHR='0', dllaDeltaCqiMaxHR='15', dllaDeltaCqiMinHR='-15', dllaDeltaCqiStepdownHR='1',
    #      dllaIniDeltaCqiHR='-5', dllaIniMcsHR='3', dllaMcsMax64qamLowSERANK1HR='28', dllaMcsMax64qamLowSERANK2HR='28',
    #      dllaMcsMax64qamLowSERANK3HR='28', dllaMcsMax64qamLowSERANK4HR='28', dllaMcsMax64qamRANK1HR='28',
    #      dllaMcsMax64qamRANK2HR='28', dllaMcsMax64qamRANK3HR='28', dllaMcsMax64qamRANK4HR='28')],
    #      dist_name=_NRCELL2name, parameter='pdschHrLaConfig'),
    dict(value='11', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerRecoverMcsThresh64qamLowSE'),
    dict(value='10', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerRecoverPeriod'),
    dict(value=f'{_NRBTSname}/NRPDCCHHRLA-1', dist_name=_NRDRB10name, parameter='nrPdcchHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPDSCHHRLA-1', dist_name=_NRDRB10name, parameter='nrPdschHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPUSCHHRLA-1', dist_name=_NRDRB10name, parameter='nrPuschHRLaDN'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDlMuMimo'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcs'),
    # dict(value=['none'], dist_name=_NRDU, parameter='carrierAggregationSupportList'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUlDftSOfdm'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_recover_gnb1_M_005 = [
    # dict(value='true', dist_name=_NRCELLname, parameter='actRel16DmrsForPusch'),
    dict(value='1', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerOutageMcsThresh64qam'),
    dict(value='5', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerRecoverMcsThresh64qam'),
    dict(value='1000', dist_name=_NRDRB16name, parameter='maxDataRateGbrDl'),
    dict(value='1000', dist_name=_NRDRB16name, parameter='maxDataRateGbrUl'),
    dict(value='10', dist_name=_NRCELL2name, parameter='dllaBlerTarget'),
    dict(value='dynamic', dist_name=_BWP_PROFILE_54, parameter='alSelection'),
    dict(value='AL4', dist_name=_BWP_PROFILE_54, parameter='dciDedicatedAggregationLevelHR'),
    # dict(value=[dict(dllaCqiOffsetHR='0', dllaDeltaCqiMaxHR='15', dllaDeltaCqiMinHR='-15', dllaDeltaCqiStepdownHR='2',
    #      dllaIniDeltaCqiHR='-5', dllaIniMcsHR='3', dllaMcsMax64qamLowSERANK1HR='28', dllaMcsMax64qamLowSERANK2HR='28',
    #      dllaMcsMax64qamLowSERANK3HR='28', dllaMcsMax64qamLowSERANK4HR='28', dllaMcsMax64qamRANK1HR='28',
    #      dllaMcsMax64qamRANK2HR='28', dllaMcsMax64qamRANK3HR='28', dllaMcsMax64qamRANK4HR='28')],
    #      dist_name=_NRCELL2name, parameter='pdschHrLaConfig'),
    dict(value='14', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerRecoverMcsThresh64qamLowSE'),
    dict(value='30', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerRecoverPeriod'),
    dict(value=f'{_NRBTSname}/NRPDCCHHRLA-1', dist_name=_NRDRB12name, parameter='nrPdcchHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPDSCHHRLA-1', dist_name=_NRDRB12name, parameter='nrPdschHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPUSCHHRLA-1', dist_name=_NRDRB12name, parameter='nrPuschHRLaDN'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDlMuMimo'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcs'),
    # dict(value=['none'], dist_name=_NRDU, parameter='carrierAggregationSupportList'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlDftSOfdm'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_delete_gnb1_M_005 = [
    dict(value=f'{_NRBTSname}/NRPDCCHHRLA-1', dist_name=_NRDRB12name, parameter='nrPdcchHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPDSCHHRLA-1', dist_name=_NRDRB12name, parameter='nrPdschHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPUSCHHRLA-1', dist_name=_NRDRB12name, parameter='nrPuschHRLaDN')

]

PARAM_8246_recover_delete_gnb1_M_005 = [
    dict(value=f'{_NRBTSname}/NRPDCCHHRLA-1', dist_name=_NRDRB10name, parameter='nrPdcchHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPDSCHHRLA-1', dist_name=_NRDRB10name, parameter='nrPdschHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPUSCHHRLA-1', dist_name=_NRDRB10name, parameter='nrPuschHRLaDN')

]

PARAM_8246_gnb1_P_002 = [
    dict(value='false', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='10000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutageTbsThresh'),
    dict(value='20000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverTbsThresh'),
    dict(value='5', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutagePeriod'),
    dict(value='5', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerOutagePeriod'),
    dict(value=_NRPDCCHHRLA_1, dist_name=_NRDRB16name, parameter='nrPdcchHRLaDN'),
    dict(value=_NRPDSCHHRLA_1, dist_name=_NRDRB16name, parameter='nrPdschHRLaDN'),
    dict(value=_NRPUSCHHRLA_1, dist_name=_NRDRB16name, parameter='nrPuschHRLaDN'),
    dict(value='30000', dist_name=_NRDRB16name, parameter='maxDataRateGbrDl'),
    dict(value='30000', dist_name=_NRDRB16name, parameter='maxDataRateGbrUl'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_recover_gnb1_P_002 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='500', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutageTbsThresh'),
    dict(value='4000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverTbsThresh'),
    dict(value='10', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutagePeriod'),
    dict(value='10', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerOutagePeriod'),
    dict(value='1000', dist_name=_NRDRB16name, parameter='maxDataRateGbrDl'),
    dict(value='1000', dist_name=_NRDRB16name, parameter='maxDataRateGbrUl'),
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_recover_delete_gnb1_P_002 = [
    dict(dist_name=_NRDRB16name, parameter='nrPdcchHRLaDN'),
    dict(dist_name=_NRDRB16name, parameter='nrPdschHRLaDN'),
    dict(dist_name=_NRDRB16name, parameter='nrPuschHRLaDN'),
]

PARAM_8246_gnb1_P_003 = [
    # dict(value='true', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    # dict(value='true', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    # dict(value='true', dist_name=_NRCELLname, parameter='scalingStepdownHREnabled'),
    # dict(value='true', dist_name=_NRCELL2name, parameter='scalingStepdownHREnabled'),
    dict(value='false', dist_name=_NRCELLname, parameter='actRel16DmrsForPusch'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='10000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutageTbsThresh'),
    dict(value='20000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverTbsThresh'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUlDftSOfdm'),
    dict(value=_NRPDCCHHRLA_1, dist_name=_NRDRB16name, parameter='nrPdcchHRLaDN'),
    dict(value=_NRPDSCHHRLA_1, dist_name=_NRDRB16name, parameter='nrPdschHRLaDN'),
    dict(value=_NRPUSCHHRLA_1, dist_name=_NRDRB16name, parameter='nrPuschHRLaDN'),
    dict(value='30000', dist_name=_NRDRB16name, parameter='maxDataRateGbrDl'),
    dict(value='30000', dist_name=_NRDRB16name, parameter='maxDataRateGbrUl'),
    # dict(value='false', dist_name=_NRBTSname, parameter='actInterFreqHoSA'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]
PARAM_8246_gnb2_P_003 = [
    # dict(value='true', dist_name=_NRCELLname2, parameter='actLAForHiReliab'),
    # dict(value='true', dist_name=_NRCELLname2, parameter='scalingStepdownHREnabled'),
    dict(value='1', dist_name=_NRCELLname2, parameter='maxNumOfRrcSA'),
    dict(value='0', dist_name=_NRCELLname2, parameter='maxNumOfRrcSARedCap'),
    dict(value='false', dist_name=_NRCELLname2, parameter='actRel16DmrsForPusch'),
    dict(value='false', dist_name=_NRCELLname2, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname2, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELLname2, parameter='actDlLaDynBlerTarget'),
    dict(value='10000', dist_name=_NRPUSCHHRLA2_1, parameter='ulHRBlerOutageTbsThresh'),
    dict(value='20000', dist_name=_NRPUSCHHRLA2_1, parameter='ulHRBlerRecoverTbsThresh'),
    dict(value='false', dist_name=_NRCELLname2, parameter='actUlDftSOfdm'),
    dict(value=_NRPDCCHHRLA2_1, dist_name=_NRDRB16name2, parameter='nrPdcchHRLaDN'),
    dict(value=_NRPDSCHHRLA2_1, dist_name=_NRDRB16name2, parameter='nrPdschHRLaDN'),
    dict(value=_NRPUSCHHRLA2_1, dist_name=_NRDRB16name2, parameter='nrPuschHRLaDN'),
    dict(value='30000', dist_name=_NRDRB16name2, parameter='maxDataRateGbrDl'),
    dict(value='30000', dist_name=_NRDRB16name2, parameter='maxDataRateGbrUl'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname2,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname2,
         parameter='integrityProtPrefL')
]

PARAM_8246_recover_gnb1_P_003 = [
    # dict(value='false', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    # dict(value='false', dist_name=_NRCELLname, parameter='scalingStepdownHREnabled'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='scalingStepdownHREnabled'),
    dict(value='true', dist_name=_NRCELLname, parameter='actRel16DmrsForPusch'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='500', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutageTbsThresh'),
    dict(value='4000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverTbsThresh'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlDftSOfdm'),
    dict(value='1000', dist_name=_NRDRB16name, parameter='maxDataRateGbrDl'),
    dict(value='1000', dist_name=_NRDRB16name, parameter='maxDataRateGbrUl'),
    # dict(value='true', dist_name=_NRBTSname, parameter='actInterFreqHoSA'),
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]
PARAM_8246_recover_gnb1_P_003_24R2 = [
    # dict(value='false', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    # dict(value='false', dist_name=_NRCELLname, parameter='scalingStepdownHREnabled'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='scalingStepdownHREnabled'),
    dict(value='false', dist_name=_NRCELLname, parameter='actRel16DmrsForPusch'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='500', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutageTbsThresh'),
    dict(value='4000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverTbsThresh'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlDftSOfdm'),
    dict(value='1000', dist_name=_NRDRB16name, parameter='maxDataRateGbrDl'),
    dict(value='1000', dist_name=_NRDRB16name, parameter='maxDataRateGbrUl'),
    # dict(value='true', dist_name=_NRBTSname, parameter='actInterFreqHoSA'),
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]
PARAM_8246_recover_delete_gnb1_P_003 = [
    dict(dist_name=_NRDRB16name, parameter='nrPdcchHRLaDN'),
    dict(dist_name=_NRDRB16name, parameter='nrPdschHRLaDN'),
    dict(dist_name=_NRDRB16name, parameter='nrPuschHRLaDN'),
]
PARAM_8246_recover_gnb2_P_003 = [
    # dict(value='true', dist_name=_NRCELLname2, parameter='actLAForHiReliab'),
    # dict(value='true', dist_name=_NRCELLname2, parameter='scalingStepdownHREnabled'),
    dict(value='275', dist_name=_NRCELLname2, parameter='maxNumOfRrcSA'),
    dict(value='10', dist_name=_NRCELLname2, parameter='maxNumOfRrcSARedCap'),
    dict(value='true', dist_name=_NRCELLname2, parameter='actRel16DmrsForPusch'),
    dict(value='true', dist_name=_NRCELLname2, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname2, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELLname2, parameter='actDlLaDynBlerTarget'),
    dict(value='10000', dist_name=_NRPUSCHHRLA2_1, parameter='ulHRBlerOutageTbsThresh'),
    dict(value='20000', dist_name=_NRPUSCHHRLA2_1, parameter='ulHRBlerRecoverTbsThresh'),
    dict(value='true', dist_name=_NRCELLname2, parameter='actUlDftSOfdm'),
    dict(value='1000', dist_name=_NRDRB16name2, parameter='maxDataRateGbrDl'),
    dict(value='1000', dist_name=_NRDRB16name2, parameter='maxDataRateGbrUl'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname2,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname2,
         parameter='integrityProtPrefL')
]
PARAM_8246_recover_gnb2_P_003_24R2 = [
    # dict(value='true', dist_name=_NRCELLname2, parameter='actLAForHiReliab'),
    # dict(value='true', dist_name=_NRCELLname2, parameter='scalingStepdownHREnabled'),
    dict(value='275', dist_name=_NRCELLname2, parameter='maxNumOfRrcSA'),
    dict(value='10', dist_name=_NRCELLname2, parameter='maxNumOfRrcSARedCap'),
    dict(value='false', dist_name=_NRCELLname2, parameter='actRel16DmrsForPusch'),
    dict(value='true', dist_name=_NRCELLname2, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname2, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELLname2, parameter='actDlLaDynBlerTarget'),
    dict(value='10000', dist_name=_NRPUSCHHRLA2_1, parameter='ulHRBlerOutageTbsThresh'),
    dict(value='20000', dist_name=_NRPUSCHHRLA2_1, parameter='ulHRBlerRecoverTbsThresh'),
    dict(value='true', dist_name=_NRCELLname2, parameter='actUlDftSOfdm'),
    dict(value='1000', dist_name=_NRDRB16name2, parameter='maxDataRateGbrDl'),
    dict(value='1000', dist_name=_NRDRB16name2, parameter='maxDataRateGbrUl'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname2,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname2,
         parameter='integrityProtPrefL')
]
PARAM_8246_recover_delete_gnb2_P_003 = [
    dict(dist_name=_NRDRB16name2, parameter='nrPdcchHRLaDN'),
    dict(dist_name=_NRDRB16name2, parameter='nrPdschHRLaDN'),
    dict(dist_name=_NRDRB16name2, parameter='nrPuschHRLaDN'),
]

PARAM_8246_enb1_P_009 = [
    dict(value=_MME_IP, dist_name=_LNMME_0, parameter='ipAddrPrim'),
]

PARAM_8246_recover_enb1_P_009 = [
    dict(value=_initial_MME_IP, dist_name=_LNMME_0, parameter='ipAddrPrim'),
]

PARAM_8246_gnb1_P_009 = [
    dict(value='1', dist_name=_NRCELLname, parameter='maxNumOfUsersPerCell'),
    dict(value='1', dist_name=_NRCELL2name, parameter='maxNumOfUsersPerCell'),
    # dict(value='0', dist_name=_NRCELLname, parameter='maxNumOfRrcSA'),
    # dict(value='0', dist_name=_NRCELL2name, parameter='maxNumOfRrcSA'),
    # dict(value='1', dist_name=_NRCELLname, parameter='maxNumOfUsersPerNRCell'),
    # dict(value='1', dist_name=_NRCELL2name, parameter='maxNumOfUsersPerNRCell'),
    dict(value='1', dist_name=_NRCELLname, parameter='maxNumOfCaUsersNRCell'),
    dict(value='1', dist_name=_NRCELL2name, parameter='maxNumOfCaUsersNRCell'),
    dict(value='1', dist_name=_NRCELLname, parameter='maxNumOfSCellAlloc'),
    dict(value='1', dist_name=_NRCELL2name, parameter='maxNumOfSCellAlloc'),
    dict(value='1', dist_name=_NRCELLname, parameter='maxNumOfNrDcSnUsers'),
    dict(value='1', dist_name=_NRCELL2name, parameter='maxNumOfNrDcSnUsers'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='10000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutageTbsThresh'),
    dict(value='20000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverTbsThresh'),
    dict(value=_NRPDCCHHRLA_1, dist_name=_NRDRB4name, parameter='nrPdcchHRLaDN'),
    dict(value=_NRPDSCHHRLA_1, dist_name=_NRDRB4name, parameter='nrPdschHRLaDN'),
    dict(value=_NRPUSCHHRLA_1, dist_name=_NRDRB4name, parameter='nrPuschHRLaDN'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]
PARAM_8246_gnb1_P_009_AMF = [
    dict(value='Locked', dist_name=_SERVEDAMF, parameter='administrativeState'),
]

PARAM_8246_recover_gnb1_P_009 = [
    dict(value='275', dist_name=_NRCELLname, parameter='maxNumOfUsersPerCell'),
    dict(value='275', dist_name=_NRCELL2name, parameter='maxNumOfUsersPerCell'),
    # dict(value='275', dist_name=_NRCELLname, parameter='maxNumOfRrcSA'),
    # dict(value='275', dist_name=_NRCELL2name, parameter='maxNumOfRrcSA'),
    # dict(value='275', dist_name=_NRCELLname, parameter='maxNumOfUsersPerNRCell'),
    # dict(value='275', dist_name=_NRCELL2name, parameter='maxNumOfUsersPerNRCell'),
    dict(value='250', dist_name=_NRCELLname, parameter='maxNumOfCaUsersNRCell'),
    dict(value='250', dist_name=_NRCELL2name, parameter='maxNumOfCaUsersNRCell'),
    dict(value='250', dist_name=_NRCELLname, parameter='maxNumOfSCellAlloc'),
    dict(value='250', dist_name=_NRCELL2name, parameter='maxNumOfSCellAlloc'),
    dict(value='275', dist_name=_NRCELLname, parameter='maxNumOfNrDcSnUsers'),
    dict(value='275', dist_name=_NRCELL2name, parameter='maxNumOfNrDcSnUsers'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='500', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutageTbsThresh'),
    dict(value='4000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverTbsThresh'),
    dict(value='Unlocked', dist_name=_SERVEDAMF, parameter='administrativeState'),
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]
PARAM_8246_recover_gnb1_P_009_AMF = [
    dict(value='Unlocked', dist_name=_SERVEDAMF, parameter='administrativeState'),
]
PARAM_8246_recover_delete_gnb1_P_009 = [
    dict(dist_name=_NRDRB4name, parameter='nrPdcchHRLaDN'),
    dict(dist_name=_NRDRB4name, parameter='nrPdschHRLaDN'),
    dict(dist_name=_NRDRB4name, parameter='nrPuschHRLaDN'),
]

PARAM_list_8246_gnb1_K_001_01_24R1 = [
    dict(dist_name=_NRCELLname, list_name='cellBwpList',
         elements=[dict(p_name='actUpperThrAckNackFiltering', value='true', index=1)]),
    dict(dist_name=_NRCELLname, list_name='cellBwpList',
         elements=[dict(p_name='actUpperThrAckNackHrFiltering', value='true', index=1)]),
]
PARAM_8246_gnb1_K_001_24R1 = [
    dict(value=[dict(ulDataDmrsFdmThres64QamLowSEMcs='20', ulDataDmrsFdmThres64QamMcs='20',
                     ulDataDmrsFdmThres256QamMcs='20')],
         dist_name=_NRCELLname,
         parameter='ulDataDmrsFdm'),
    dict(value=[dict(ulDataDmrsFdmThres64QamLowSEMcs='20', ulDataDmrsFdmThres64QamMcs='20',
                     ulDataDmrsFdmThres256QamMcs='20')],
         dist_name=_NRCELL2name,
         parameter='ulDataDmrsFdm'),
    dict(value=[dict(ulDataDmrsFdmThres64QamLowSEMcs='20', ulDataDmrsFdmThres64QamMcs='20',
                     ulDataDmrsFdmThres256QamMcs='20')],
         dist_name=_NRCELL3name,
         parameter='ulDataDmrsFdm'),
    dict(value=[dict(dlDataDmrsFdmThres64QamLowSEMcs='20')],
         dist_name=_NRCELLname,
         parameter='dlDataDmrsFdm'),
    dict(value=[dict(dlDataDmrsFdmThres64QamLowSEMcs='20')],
         dist_name=_NRCELL2name,
         parameter='dlDataDmrsFdm'),
    dict(value=[dict(dlDataDmrsFdmThres64QamLowSEMcs='20')],
         dist_name=_NRCELL3name,
         parameter='dlDataDmrsFdm'),
    dict(value='true', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actLAForHiReliab'),
    dict(value='true', dist_name=_NRCELLname, parameter='scalingStepdownHREnabled'),
    dict(value='true', dist_name=_NRCELL3name, parameter='scalingStepdownHREnabled'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL3name, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL3name, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='false', dist_name=_NRCELL3name, parameter='actDlLaDynBlerTarget'),
    dict(value='Disabled', dist_name=_NRCELL3name, parameter='actUlSlotAgg'),
    dict(value='true', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='disabled', dist_name=_NRBTSname, parameter='actBufferBasedSCellAddition'),
    dict(value=['ca_Fr1Tdd_Any_Sa', 'ca_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Nsa', 'ca_Fdd_Fr1Tdd_Sa',
                'ca_Fr1Tdd_Fdd_Sa'], dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    dict(value=_NRPDCCHHRLA_1, dist_name=_NRDRB12name, parameter='nrPdcchHRLaDN'),
    dict(value=_NRPDSCHHRLA_1, dist_name=_NRDRB12name, parameter='nrPdschHRLaDN'),
    dict(value=_NRPUSCHHRLA_1, dist_name=_NRDRB12name, parameter='nrPuschHRLaDN'),
    dict(value='blind', dist_name=_NRREL3namegnb1, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL3namegnb1, parameter='sCellOperationalMode'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_recover_gnb1_K_001_24R1 = [
    dict(value='false', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    dict(value='false', dist_name=_NRCELL3name, parameter='actLAForHiReliab'),
    dict(value='false', dist_name=_NRCELLname, parameter='scalingStepdownHREnabled'),
    dict(value='false', dist_name=_NRCELL3name, parameter='scalingStepdownHREnabled'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actDlLaDynBlerTarget'),
    dict(value='Disabled', dist_name=_NRCELL3name, parameter='actUlSlotAgg'),
    dict(value='false', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='oneShot_Dl_Fr1', dist_name=_NRBTSname, parameter='actBufferBasedSCellAddition'),
    dict(value=['ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Sa_WithUl'],
         dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]
PARAM_8246_recover_delete_gnb1_K_001_24R1 = [
    dict(dist_name=_NRDRB12name, parameter='nrPdcchHRLaDN'),
    dict(dist_name=_NRDRB12name, parameter='nrPdschHRLaDN'),
    dict(dist_name=_NRDRB12name, parameter='nrPuschHRLaDN'),
    dict(dist_name=_NRREL3namegnb1, parameter='sCellAdditionMethod'),
    dict(dist_name=_NRREL3namegnb1, parameter='sCellOperationalMode'),
]
PARAM_list_8246_gnb1_K_001_01 = [
    dict(dist_name=_NRCELLname, list_name='cellBwpList',
         elements=[dict(p_name='actUpperThrAckNackFiltering', value='true', index=1)]),
    dict(dist_name=_NRCELLname, list_name='cellBwpList',
         elements=[dict(p_name='actUpperThrAckNackHrFiltering', value='true', index=1)]),
]
PARAM_8246_gnb1_K_001 = [
    dict(value=[dict(ulDataDmrsFdmThres64QamLowSEMcs='20', ulDataDmrsFdmThres64QamMcs='20',
                     ulDataDmrsFdmThres256QamMcs='20')],
         dist_name=_NRCELLname,
         parameter='ulDataDmrsFdm'),
    dict(value=[dict(ulDataDmrsFdmThres64QamLowSEMcs='20', ulDataDmrsFdmThres64QamMcs='20',
                     ulDataDmrsFdmThres256QamMcs='20')],
         dist_name=_NRCELL2name,
         parameter='ulDataDmrsFdm'),
    dict(value=[dict(dlDataDmrsFdmThres64QamLowSEMcs='20')],
         dist_name=_NRCELLname,
         parameter='dlDataDmrsFdm'),
    dict(value=[dict(dlDataDmrsFdmThres64QamLowSEMcs='20')],
         dist_name=_NRCELL2name,
         parameter='dlDataDmrsFdm'),
    # dict(value='true', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    # dict(value='true', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    dict(value='true', dist_name=_NRCELLname, parameter='scalingStepdownHREnabled'),
    # dict(value='false', dist_name=_NRCELLname, parameter='actUlDftSOfdm'),
    dict(value='Disabled', dist_name=_NRCELLname, parameter='actUlSlotAgg'),
    dict(value='true', dist_name=_NRCELL2name, parameter='scalingStepdownHREnabled'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='Disabled', dist_name=_NRCELL2name, parameter='actUlSlotAgg'),
    dict(value=_NRPDCCHHRLA_1, dist_name=_NRDRB13name, parameter='nrPdcchHRLaDN'),
    dict(value=_NRPDSCHHRLA_1, dist_name=_NRDRB13name, parameter='nrPdschHRLaDN'),
    dict(value=_NRPUSCHHRLA_1, dist_name=_NRDRB13name, parameter='nrPuschHRLaDN'),
    dict(value='30000', dist_name=_NRDRB13name, parameter='maxDataRateGbrDl'),
    dict(value='30000', dist_name=_NRDRB13name, parameter='maxDataRateGbrUl'),
    dict(value='true', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='disabled', dist_name=_NRBTSname, parameter='actBufferBasedSCellAddition'),
    # dict(value='false', dist_name=_NRBTSname, parameter='actInterFreqHoSA'),
    dict(value='false', dist_name=_NRBTSname, parameter='actSaUeBasedInterFreqAnrNr'),
    dict(value=['ca_Fr1Tdd_Any_Sa', 'ca_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Nsa', 'ca_Fdd_Fr1Tdd_Sa',
                'ca_Fr1Tdd_Fdd_Sa', 'ca_Fdd_Fr1Tdd_Sa_WithUl'], dist_name=_NRBTSDUname,
         parameter='carrierAggregationSupportList'),
    dict(value=['A1-based'], dist_name=_NRBTSname, parameter='actMeasBasedSCellAdditionSa'),
    # dict(value=_NRPDCCHHRLA_1, dist_name=_NRDRB12name, parameter='nrPdcchHRLaDN'),
    # dict(value=_NRPDSCHHRLA_1, dist_name=_NRDRB12name, parameter='nrPdschHRLaDN'),
    # dict(value=_NRPUSCHHRLA_1, dist_name=_NRDRB12name, parameter='nrPuschHRLaDN'),
    dict(value='covBasedA1', dist_name=_NRREL2namegnb1, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL2namegnb1, parameter='sCellOperationalMode'),
    dict(value='rsrp', dist_name=_NRCELLname, parameter='a1MeasSCellAddEnabled'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL'),
    dict(value='Locked', dist_name=_NRCELL21name, parameter='administrativeState'),
]
PARAM_8246_gnb1_K_001_358 = [
    dict(value='false', dist_name=_NRBTSname, parameter='actInterFreqHoSA'),
]
PARAM_8246_delete_gnb1_K_001 = [
    dict(dist_name=_NRDRB12name, parameter='nrPdcchHRLaDN'),
    dict(dist_name=_NRDRB12name, parameter='nrPdschHRLaDN'),
    dict(dist_name=_NRDRB12name, parameter='nrPuschHRLaDN'),
]

PARAM_8246_recover_gnb1_K_001 = [
    # dict(value='false', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    dict(value='false', dist_name=_NRCELLname, parameter='scalingStepdownHREnabled'),
    dict(value='true', dist_name=_NRCELL2name, parameter='scalingStepdownHREnabled'),
    # dict(value='true', dist_name=_NRCELLname, parameter='actUlDftSOfdm'),
    dict(value='Enabled_VoNr', dist_name=_NRCELLname, parameter='actUlSlotAgg'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='Enabled_VoNr', dist_name=_NRCELL2name, parameter='actUlSlotAgg'),
    dict(value=_NRPDCCHHRLA_1, dist_name=_NRDRB12name, parameter='nrPdcchHRLaDN'),
    dict(value=_NRPDSCHHRLA_1, dist_name=_NRDRB12name, parameter='nrPdschHRLaDN'),
    dict(value=_NRPUSCHHRLA_1, dist_name=_NRDRB12name, parameter='nrPuschHRLaDN'),
    dict(value='1000', dist_name=_NRDRB13name, parameter='maxDataRateGbrDl'),
    dict(value='1000', dist_name=_NRDRB13name, parameter='maxDataRateGbrUl'),
    dict(value='false', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='oneShot_Dl_Fr1', dist_name=_NRBTSname, parameter='actBufferBasedSCellAddition'),
    dict(value='true', dist_name=_NRBTSname, parameter='actInterFreqHoSA'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSaUeBasedInterFreqAnrNr'),
    dict(value=['ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Sa_WithUl'],
         dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    dict(value=['A1-based'], dist_name=_NRBTSname, parameter='actMeasBasedSCellAdditionSa'),
    dict(value='none', dist_name=_NRCELLname, parameter='a1MeasSCellAddEnabled'),
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL'),
]
PARAM_8246_recover_delete_gnb1_K_001 = [
    dict(dist_name=_NRDRB13name, parameter='nrPdcchHRLaDN'),
    dict(dist_name=_NRDRB13name, parameter='nrPdschHRLaDN'),
    dict(dist_name=_NRDRB13name, parameter='nrPuschHRLaDN'),
    dict(dist_name=_NRREL400_2namegnb1, parameter='sCellAdditionMethod'),
    dict(dist_name=_NRREL400_2namegnb1, parameter='sCellOperationalMode'),
]
PARAM_8246_recover_gnb1_K_001_383 = [
    # dict(value='false', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    dict(value='false', dist_name=_NRCELLname, parameter='scalingStepdownHREnabled'),
    dict(value='true', dist_name=_NRCELL2name, parameter='scalingStepdownHREnabled'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlDftSOfdm'),
    dict(value='Enabled_VoNr', dist_name=_NRCELLname, parameter='actUlSlotAgg'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='Disabled', dist_name=_NRCELL2name, parameter='actUlSlotAgg'),
    dict(value=_NRPDCCHHRLA_1, dist_name=_NRDRB12name, parameter='nrPdcchHRLaDN'),
    dict(value=_NRPDSCHHRLA_1, dist_name=_NRDRB12name, parameter='nrPdschHRLaDN'),
    dict(value=_NRPUSCHHRLA_1, dist_name=_NRDRB12name, parameter='nrPuschHRLaDN'),
    dict(value='1000', dist_name=_NRDRB13name, parameter='maxDataRateGbrDl'),
    dict(value='1000', dist_name=_NRDRB13name, parameter='maxDataRateGbrUl'),
    dict(value='false', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='oneShot_Dl_Fr1', dist_name=_NRBTSname, parameter='actBufferBasedSCellAddition'),
    dict(value='true', dist_name=_NRBTSname, parameter='actInterFreqHoSA'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSaUeBasedInterFreqAnrNr'),
    dict(value=['ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Sa_WithUl'],
         dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    dict(value=['A1-based'], dist_name=_NRBTSname, parameter='actMeasBasedSCellAdditionSa'),
    dict(value='none', dist_name=_NRCELLname, parameter='a1MeasSCellAddEnabled'),
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL'),
    dict(value='Unlocked', dist_name=_NRCELL21name, parameter='administrativeState'),
]
PARAM_8246_recover_delete_gnb1_K_001_383 = [
    dict(dist_name=_NRDRB13name, parameter='nrPdcchHRLaDN'),
    dict(dist_name=_NRDRB13name, parameter='nrPdschHRLaDN'),
    dict(dist_name=_NRDRB13name, parameter='nrPuschHRLaDN'),
    dict(dist_name=_NRREL2namegnb1, parameter='sCellAdditionMethod'),
    dict(dist_name=_NRREL2namegnb1, parameter='sCellOperationalMode'),
]

PARAM_8246_gnb1_K_001_348 = [
    # dict(value=[dict(ulDataDmrsFdmThres64QamLowSEMcs='20', ulDataDmrsFdmThres64QamMcs='20',
    #                  ulDataDmrsFdmThres256QamMcs='20')],
    #      dist_name=_NRCELLname,
    #      parameter='ulDataDmrsFdm'),
    # dict(value=[dict(ulDataDmrsFdmThres64QamLowSEMcs='20', ulDataDmrsFdmThres64QamMcs='20',
    #                  ulDataDmrsFdmThres256QamMcs='20')],
    #      dist_name=_NRCELL2name,
    #      parameter='ulDataDmrsFdm'),
    # dict(value=[dict(ulDataDmrsFdmThres64QamLowSEMcs='20', ulDataDmrsFdmThres64QamMcs='20',
    #                  ulDataDmrsFdmThres256QamMcs='20')],
    #      dist_name=_NRCELL3name,
    #      parameter='ulDataDmrsFdm'),
    # dict(value=[dict(dlDataDmrsFdmThres64QamLowSEMcs='20')],
    #      dist_name=_NRCELLname,
    #      parameter='dlDataDmrsFdm'),
    # dict(value=[dict(dlDataDmrsFdmThres64QamLowSEMcs='20')],
    #      dist_name=_NRCELL2name,
    #      parameter='dlDataDmrsFdm'),
    # dict(value=[dict(dlDataDmrsFdmThres64QamLowSEMcs='20')],
    #      dist_name=_NRCELL3name,
    #      parameter='dlDataDmrsFdm'),
    # dict(value='true', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    # dict(value='true', dist_name=_NRCELL3name, parameter='actLAForHiReliab'),
    dict(value='locked', dist_name=_LTECELL48040name, parameter='administrativeState'),
    dict(value='locked', dist_name=_LTECELL48045name, parameter='administrativeState'),
    dict(value='Locked', dist_name=_NRCELL701name, parameter='administrativeState'),
    dict(value='true', dist_name=_NRCELL400name, parameter='scalingStepdownHREnabled'),
    # dict(value='false', dist_name=_NRCELL400name, parameter='actUlDftSOfdm'),
    dict(value='Disabled', dist_name=_NRCELL400name, parameter='actUlSlotAgg'),
    dict(value='true', dist_name=_NRCELL700name, parameter='scalingStepdownHREnabled'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actDlLaDynBlerTarget'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actDlLaDynBlerTarget'),
    dict(value='Disabled', dist_name=_NRCELL700name, parameter='actUlSlotAgg'),
    dict(value=_NRPDCCHHRLA_1, dist_name=_NRDRB13name, parameter='nrPdcchHRLaDN'),
    dict(value=_NRPDSCHHRLA_1, dist_name=_NRDRB13name, parameter='nrPdschHRLaDN'),
    dict(value=_NRPUSCHHRLA_1, dist_name=_NRDRB13name, parameter='nrPuschHRLaDN'),
    dict(value='30000', dist_name=_NRDRB13name, parameter='maxDataRateGbrDl'),
    dict(value='30000', dist_name=_NRDRB13name, parameter='maxDataRateGbrUl'),
    dict(value='true', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='disabled', dist_name=_NRBTSname, parameter='actBufferBasedSCellAddition'),
    dict(value='disabled', dist_name=_NRBTSname, parameter='actSCellReleaseForInactiveSCell'),
    # dict(value='false', dist_name=_NRBTSname, parameter='actInterFreqHoSA'),
    dict(value='false', dist_name=_NRBTSname, parameter='actSaUeBasedInterFreqAnrNr'),
    # dict(value=['ca_Fr1Tdd_Any_Sa', 'ca_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Nsa', 'ca_Fdd_Fr1Tdd_Sa',
    #             'ca_Fr1Tdd_Fdd_Sa'], dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    dict(value=['ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fdd', 'ca_Fdd_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Any_Sa', 'ca_Fdd_Any_Sa',
                'ca_Fr1Tdd_Fdd_Nsa', 'ca_Fr1Tdd_Fdd_Sa', 'ca_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Sa_WithUl'],
         dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    dict(value=['A1-based'], dist_name=_NRBTSname, parameter='actMeasBasedSCellAdditionSa'),
    # dict(value=_NRPDCCHHRLA_1, dist_name=_NRDRB12name, parameter='nrPdcchHRLaDN'),
    # dict(value=_NRPDSCHHRLA_1, dist_name=_NRDRB12name, parameter='nrPdschHRLaDN'),
    # dict(value=_NRPUSCHHRLA_1, dist_name=_NRDRB12name, parameter='nrPuschHRLaDN'),
    dict(value='covBasedA1', dist_name=_NRREL400_2namegnb1, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL400_2namegnb1, parameter='sCellOperationalMode'),
    dict(value='rsrp', dist_name=_NRCELL400name, parameter='a1MeasSCellAddEnabled'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actUlTransPreEnhHo'),
    dict(value='Disabled', dist_name=_NRCELL400name, parameter='actUlSlotAgg'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actUlTransPreEnhRankSwitchIwk'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actUlTransPreEnhSinrMetric'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]
PARAM_8246_recover_gnb1_K_001_348 = [
    # dict(value='false', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    # dict(value='false', dist_name=_NRCELL3name, parameter='actLAForHiReliab'),
    dict(value='unlocked', dist_name=_LTECELL48040name, parameter='administrativeState'),
    dict(value='unlocked', dist_name=_LTECELL48045name, parameter='administrativeState'),
    dict(value='Unlocked', dist_name=_NRCELL701name, parameter='administrativeState'),
    dict(value='false', dist_name=_NRCELL400name, parameter='scalingStepdownHREnabled'),
    dict(value='false', dist_name=_NRCELL700name, parameter='scalingStepdownHREnabled'),
    # dict(value='true', dist_name=_NRCELL400name, parameter='actUlDftSOfdm'),
    dict(value='Enabled_VoNr', dist_name=_NRCELL400name, parameter='actUlSlotAgg'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actDlLaDynBlerTarget'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actDlLaDynBlerTarget'),
    dict(value='Disabled', dist_name=_NRCELL700name, parameter='actUlSlotAgg'),
    dict(value=_NRPDCCHHRLA_1, dist_name=_NRDRB12name, parameter='nrPdcchHRLaDN'),
    dict(value=_NRPDSCHHRLA_1, dist_name=_NRDRB12name, parameter='nrPdschHRLaDN'),
    dict(value=_NRPUSCHHRLA_1, dist_name=_NRDRB12name, parameter='nrPuschHRLaDN'),
    dict(value='1000', dist_name=_NRDRB13name, parameter='maxDataRateGbrDl'),
    dict(value='1000', dist_name=_NRDRB13name, parameter='maxDataRateGbrUl'),
    dict(value='true', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='oneShot_Dl_Fr1', dist_name=_NRBTSname, parameter='actBufferBasedSCellAddition'),
    dict(value='timer_based_Fr1', dist_name=_NRBTSname, parameter='actSCellReleaseForInactiveSCell'),
    dict(value='true', dist_name=_NRBTSname, parameter='actInterFreqHoSA'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSaUeBasedInterFreqAnrNr'),
    dict(value=['ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fdd', 'ca_Fdd_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Any_Sa', 'ca_Fdd_Any_Sa',
                'ca_Fr1Tdd_Fdd_Nsa', 'ca_Fr1Tdd_Fdd_Sa', 'ca_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Sa_WithUl'],
         dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    dict(value=['A1-based'], dist_name=_NRBTSname, parameter='actMeasBasedSCellAdditionSa'),
    dict(value='rsrp', dist_name=_NRCELL400name, parameter='a1MeasSCellAddEnabled'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actUlTransPreEnhHo'),
    dict(value='Enabled_VoNr', dist_name=_NRCELL400name, parameter='actUlSlotAgg'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actUlTransPreEnhRankSwitchIwk'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actUlTransPreEnhSinrMetric'),
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_delete_gnb1_K_004 = [
    dict(dist_name=_NRDRB12name, parameter='nrPdcchHRLaDN'),
    dict(dist_name=_NRDRB12name, parameter='nrPdschHRLaDN'),
    dict(dist_name=_NRDRB12name, parameter='nrPuschHRLaDN'),
]
PARAM_8246_gnb1_K_004 = [
    # dict(value='false', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    # dict(value='true', dist_name=_NRCELLname, parameter='scalingStepdownHREnabled'),
    # dict(value='true', dist_name=_NRCELL2name, parameter='scalingStepdownHREnabled'),
    dict(value='bufferBased', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='false', dist_name=_NRCELLname, parameter='actRel16DmrsForPusch'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    # dict(value='false', dist_name=_NRCELLname, parameter='actUlDftSOfdm'),
    dict(value=_NRPDCCHHRLA_1, dist_name=_NRDRB13name, parameter='nrPdcchHRLaDN'),
    dict(value=_NRPDSCHHRLA_1, dist_name=_NRDRB13name, parameter='nrPdschHRLaDN'),
    dict(value=_NRPUSCHHRLA_1, dist_name=_NRDRB13name, parameter='nrPuschHRLaDN'),
    # dict(value='30000', dist_name=_NRDRB16name, parameter='maxDataRateGbrDl'),
    # dict(value='30000', dist_name=_NRDRB16name, parameter='maxDataRateGbrUl'),
    dict(value='true', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='DLOnly', dist_name=_NRBTSDUname, parameter='actInterGnbCa'),
    dict(value='blind', dist_name=_NRREL2namegnb1, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL2namegnb1, parameter='sCellOperationalMode'),
    dict(value=['ca_Fr1Tdd_Any_Sa', 'ca_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Nsa', 'ca_Fdd_Fr1Tdd_Sa',
                'ca_Fr1Tdd_Fdd_Sa'],
         dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    # dict(value=['ca_Fr1Tdd_Any_Sa', 'ca_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Nsa', 'ca_Fdd_Fr1Tdd_Sa',
    #             'ca_Fr1Tdd_Fdd_Sa', 'ca_Fdd_Fr1Tdd_Sa_WithUl', 'ca_Fr1Tdd_Fdd_Sa_WithUl'],
    #      dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]
PARAM_8246_gnb1_K_004_above_25R2 = [
    # dict(value='false', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    # dict(value='true', dist_name=_NRCELLname, parameter='scalingStepdownHREnabled'),
    # dict(value='true', dist_name=_NRCELL2name, parameter='scalingStepdownHREnabled'),
    dict(value='bufferBased', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='false', dist_name=_NRCELLname, parameter='actRel16DmrsForPusch'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUlDftSOfdm'),
    dict(value=_NRPDCCHHRLA_1, dist_name=_NRDRB13name, parameter='nrPdcchHRLaDN'),
    dict(value=_NRPDSCHHRLA_1, dist_name=_NRDRB13name, parameter='nrPdschHRLaDN'),
    dict(value=_NRPUSCHHRLA_1, dist_name=_NRDRB13name, parameter='nrPuschHRLaDN'),
    # dict(value='30000', dist_name=_NRDRB16name, parameter='maxDataRateGbrDl'),
    # dict(value='30000', dist_name=_NRDRB16name, parameter='maxDataRateGbrUl'),
    dict(value='true', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='DLOnly', dist_name=_NRBTSDUname, parameter='actInterGnbCa'),
    dict(value='blind', dist_name=_NRREL2namegnb1, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL2namegnb1, parameter='sCellOperationalMode'),
    dict(value=['ca_Fr1Tdd_Any_Sa', 'ca_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Nsa', 'ca_Fdd_Fr1Tdd_Sa',
                'ca_Fr1Tdd_Fdd_Sa'],
         dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    # dict(value=['ca_Fr1Tdd_Any_Sa', 'ca_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Nsa', 'ca_Fdd_Fr1Tdd_Sa',
    #             'ca_Fr1Tdd_Fdd_Sa', 'ca_Fdd_Fr1Tdd_Sa_WithUl', 'ca_Fr1Tdd_Fdd_Sa_WithUl'],
    #      dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]
PARAM_8246_delete_gnb2_K_004 = [
    dict(dist_name=_NRDRB12name2, parameter='nrPdcchHRLaDN'),
    dict(dist_name=_NRDRB12name2, parameter='nrPdschHRLaDN'),
    dict(dist_name=_NRDRB12name2, parameter='nrPuschHRLaDN'),
]
PARAM_8246_gnb2_K_004 = [
    # dict(value='false', dist_name=_NRCELLname2, parameter='actLAForHiReliab'),
    # dict(value='true', dist_name=_NRCELLname2, parameter='scalingStepdownHREnabled'),
    dict(value='false', dist_name=_NRCELLname2, parameter='actRel16DmrsForPusch'),
    dict(value='false', dist_name=_NRCELLname2, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname2, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELLname2, parameter='actDlLaDynBlerTarget'),
    # dict(value='false', dist_name=_NRCELLname2, parameter='actUlDftSOfdm'),
    dict(value=_NRPDCCHHRLA2_1, dist_name=_NRDRB13name2, parameter='nrPdcchHRLaDN'),
    dict(value=_NRPDSCHHRLA2_1, dist_name=_NRDRB13name2, parameter='nrPdschHRLaDN'),
    dict(value=_NRPUSCHHRLA2_1, dist_name=_NRDRB13name2, parameter='nrPuschHRLaDN'),
    # dict(value='30000', dist_name=_NRDRB16name2, parameter='maxDataRateGbrDl'),
    # dict(value='30000', dist_name=_NRDRB16name2, parameter='maxDataRateGbrUl'),
    dict(value='true', dist_name=_NRBTSDUname2, parameter='actConnectedModeMobilityCA'),
    dict(value='DLOnly', dist_name=_NRBTSDUname2, parameter='actInterGnbCa'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname2,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname2,
         parameter='integrityProtPrefL')
]

PARAM_8246_recover_gnb1_K_004 = [
    # dict(value='true', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    # dict(value='true', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    # dict(value='false', dist_name=_NRCELLname, parameter='scalingStepdownHREnabled'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='scalingStepdownHREnabled'),
    dict(value='true', dist_name=_NRCELLname, parameter='actRel16DmrsForPusch'),
    dict(value='blind', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    # dict(value='true', dist_name=_NRCELLname, parameter='actUlDftSOfdm'),
    # dict(value='1000', dist_name=_NRDRB16name, parameter='maxDataRateGbrDl'),
    # dict(value='1000', dist_name=_NRDRB16name, parameter='maxDataRateGbrUl'),
    dict(value=_NRPDCCHHRLA_1, dist_name=_NRDRB12name, parameter='nrPdcchHRLaDN'),
    dict(value=_NRPDSCHHRLA_1, dist_name=_NRDRB12name, parameter='nrPdschHRLaDN'),
    dict(value=_NRPUSCHHRLA_1, dist_name=_NRDRB12name, parameter='nrPuschHRLaDN'),
    dict(value='true', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='disabled', dist_name=_NRBTSDUname, parameter='actInterGnbCa'),
    dict(value=['ca_Fr1Tdd_Any_Sa', 'ca_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Nsa', 'ca_Fdd_Fr1Tdd_Sa',
                'ca_Fr1Tdd_Fdd_Sa'],
         dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]
PARAM_8246_recover_gnb1_K_004_24R2 = [
    # dict(value='true', dist_name=_NRCELLname, parameter='actLAForHiReliab'),
    # dict(value='true', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    # dict(value='false', dist_name=_NRCELLname, parameter='scalingStepdownHREnabled'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='scalingStepdownHREnabled'),
    dict(value='false', dist_name=_NRCELLname, parameter='actRel16DmrsForPusch'),
    dict(value='blind', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlDftSOfdm'),
    # dict(value='1000', dist_name=_NRDRB16name, parameter='maxDataRateGbrDl'),
    # dict(value='1000', dist_name=_NRDRB16name, parameter='maxDataRateGbrUl'),
    dict(value=_NRPDCCHHRLA_1, dist_name=_NRDRB12name, parameter='nrPdcchHRLaDN'),
    dict(value=_NRPDSCHHRLA_1, dist_name=_NRDRB12name, parameter='nrPdschHRLaDN'),
    dict(value=_NRPUSCHHRLA_1, dist_name=_NRDRB12name, parameter='nrPuschHRLaDN'),
    dict(value='true', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='disabled', dist_name=_NRBTSDUname, parameter='actInterGnbCa'),
    dict(value=['ca_Fr1Tdd_Any_Sa', 'ca_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Nsa', 'ca_Fdd_Fr1Tdd_Sa',
                'ca_Fr1Tdd_Fdd_Sa'],
         dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]
PARAM_8246_recover_delete_gnb1_K_004 = [
    dict(dist_name=_NRDRB13name, parameter='nrPdcchHRLaDN'),
    dict(dist_name=_NRDRB13name, parameter='nrPdschHRLaDN'),
    dict(dist_name=_NRDRB13name, parameter='nrPuschHRLaDN'),
    dict(dist_name=_NRREL2namegnb1, parameter='sCellAdditionMethod'),
    dict(dist_name=_NRREL2namegnb1, parameter='sCellOperationalMode'),
]
PARAM_8246_recover_gnb2_K_004 = [
    # dict(value='true', dist_name=_NRCELLname2, parameter='actLAForHiReliab'),
    # dict(value='true', dist_name=_NRCELLname2, parameter='scalingStepdownHREnabled'),
    dict(value='true', dist_name=_NRCELLname2, parameter='actRel16DmrsForPusch'),
    dict(value='true', dist_name=_NRCELLname2, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname2, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELLname2, parameter='actDlLaDynBlerTarget'),
    # dict(value='true', dist_name=_NRCELLname2, parameter='actUlDftSOfdm'),
    # dict(value='1000', dist_name=_NRDRB16name2, parameter='maxDataRateGbrDl'),
    # dict(value='1000', dist_name=_NRDRB16name2, parameter='maxDataRateGbrUl'),
    dict(value=_NRPDCCHHRLA2_1, dist_name=_NRDRB12name2, parameter='nrPdcchHRLaDN'),
    dict(value=_NRPDSCHHRLA2_1, dist_name=_NRDRB12name2, parameter='nrPdschHRLaDN'),
    dict(value=_NRPUSCHHRLA2_1, dist_name=_NRDRB12name2, parameter='nrPuschHRLaDN'),
    dict(value='true', dist_name=_NRBTSDUname2, parameter='actConnectedModeMobilityCA'),
    dict(value='disabled', dist_name=_NRBTSDUname2, parameter='actInterGnbCa'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname2,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname2,
         parameter='integrityProtPrefL')
]
PARAM_8246_recover_gnb2_K_004_24R2 = [
    # dict(value='true', dist_name=_NRCELLname2, parameter='actLAForHiReliab'),
    # dict(value='true', dist_name=_NRCELLname2, parameter='scalingStepdownHREnabled'),
    dict(value='false', dist_name=_NRCELLname2, parameter='actRel16DmrsForPusch'),
    dict(value='true', dist_name=_NRCELLname2, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname2, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELLname2, parameter='actDlLaDynBlerTarget'),
    dict(value='true', dist_name=_NRCELLname2, parameter='actUlDftSOfdm'),
    # dict(value='1000', dist_name=_NRDRB16name2, parameter='maxDataRateGbrDl'),
    # dict(value='1000', dist_name=_NRDRB16name2, parameter='maxDataRateGbrUl'),
    dict(value=_NRPDCCHHRLA2_1, dist_name=_NRDRB12name2, parameter='nrPdcchHRLaDN'),
    dict(value=_NRPDSCHHRLA2_1, dist_name=_NRDRB12name2, parameter='nrPdschHRLaDN'),
    dict(value=_NRPUSCHHRLA2_1, dist_name=_NRDRB12name2, parameter='nrPuschHRLaDN'),
    dict(value='true', dist_name=_NRBTSDUname2, parameter='actConnectedModeMobilityCA'),
    dict(value='disabled', dist_name=_NRBTSDUname2, parameter='actInterGnbCa'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname2,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname2,
         parameter='integrityProtPrefL')
]
PARAM_8246_recover_delete_gnb2_K_004 = [
    dict(dist_name=_NRDRB13name2, parameter='nrPdcchHRLaDN'),
    dict(dist_name=_NRDRB13name2, parameter='nrPdschHRLaDN'),
    dict(dist_name=_NRDRB13name2, parameter='nrPuschHRLaDN'),
]

PARAM_8246_gnb1_04444966 = [
    dict(value='8x4 Closed Loop Spatial Multiplexing', dist_name=_NRCELLname, parameter='dlMimoMode'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCsirsMultiplexing'),
    dict(value='true', dist_name=_NRBTSname, parameter='actTransPhaseUlPrbNonRandom'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlLaOllaForRetxInDft'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlTransPreEnhHo'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlTransPreEnhRankSwitchIwk'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlDftSOfdm'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlTransPreEnhSinrMetric'),
    dict(value='true', dist_name=_NRCELLname, parameter='actAperCsi'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUlCgType2'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_recover_gnb1_04444966 = [
    dict(value='false', dist_name=_NRBTSname, parameter='actTransPhaseUlPrbNonRandom'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUlLaOllaForRetxInDft'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUlTransPreEnhHo'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUlTransPreEnhRankSwitchIwk'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlDftSOfdm'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUlTransPreEnhSinrMetric'),
    dict(value='2x2 Closed Loop Spatial Multiplexing', dist_name=_NRCELLname, parameter='dlMimoMode'),
    dict(value='false', dist_name=_NRCELLname, parameter='actCsirsMultiplexing'),
    dict(value='true', dist_name=_NRCELLname, parameter='actAperCsi'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlCgType2'),
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

LIST_PARAM_RECOVER_DELETE_gnb1_04444966 = dict(
    value=[{'csirsNumberWithinReportPeriod_Set1': '4', 'csirsPower': '10', 'maxCsirsNumber': '4'}],
    dist_name=_NRCELLname,
    parameter='periodicCsiAcquisition')
LIST_PARAM_RECOVER_gnb1_04444966 = dict(value=[{'csiReportPeriodicity': 'slots320', 'scramblingIdStep': '3'}],
                                        dist_name=_NRCELLname,
                                        parameter='periodicCsiAcquisition')
LIST_PARAM_ADD_gnb1_04444966 = dict(
    value=[{'csiReportPeriodicity': 'slots320', 'csirsNumberWithinReportPeriod_Set1': '4', 'csirsPower': '10',
            'maxCsirsNumber': '4', 'scramblingIdStep': '3'}],
    dist_name=_NRCELLname,
    parameter='periodicCsiAcquisition')

LIST_PARAM_MODIFY_gnb1_04444966_348 = dict(
    value=[{'csiReportPeriodicity': 'slots320', 'csirsNumberWithinReportPeriod_Set1': '4', 'csirsPower': '10',
            'maxCsirsNumber': '4', 'scramblingIdStep': '3'}],
    dist_name=_NRCELL700name,
    parameter='periodicCsiAcquisition')

LIST_PARAM_RECOVER_MODIFY_gnb1_04444966_348 = dict(
    value=[{'csiReportPeriodicity': 'slots320', 'csirsNumberWithinReportPeriod_Set1': '1', 'csirsPower': '4',
            'maxCsirsNumber': '4', 'scramblingIdStep': '3'}],
    dist_name=_NRCELL700name,
    parameter='periodicCsiAcquisition')

PARAM_8246_gnb1_04444966_348 = [
    # dict(value='8x4 Closed Loop Spatial Multiplexing', dist_name=_NRCELL700name, parameter='dlMimoMode'),
    # dict(value='true', dist_name=_NRCELL700name, parameter='actCsirsMultiplexing'),
    # dict(value='true', dist_name=_NRBTSname, parameter='actTransPhaseUlPrbNonRandom'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actUlLaOllaForRetxInDft'),
    # dict(value='true', dist_name=_NRCELL700name, parameter='actUlTransPreEnhHo'),
    # dict(value='true', dist_name=_NRCELL700name, parameter='actUlTransPreEnhRankSwitchIwk'),
    # dict(value='true', dist_name=_NRCELL700name, parameter='actUlDftSOfdm'),
    # dict(value='true', dist_name=_NRCELL700name, parameter='actUlTransPreEnhSinrMetric'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actAperCsi'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actUlCgType2'),
    dict(value='Locked', dist_name=_NRCELL701name, parameter='administrativeState'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_recover_gnb1_04444966_348 = [
    dict(value='false', dist_name=_NRCELL700name, parameter='actUlLaOllaForRetxInDft'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actAperCsi'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actUlCgType2'),
    dict(value='Unlocked', dist_name=_NRCELL701name, parameter='administrativeState'),
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_gnb1_K_006 = [
    dict(value='bufferBased', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='true', dist_name=_NRBTSDUname, parameter='actNonBfAndBfCa'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='ms1280', dist_name=_NRCELL2name, parameter='sCellDeactivationTimerGNB'),
    dict(value=[dict(dllaMcsMax64qamLowSERANK1HR='20', dllaMcsMax64qamLowSERANK2HR='20',
                     dllaMcsMax64qamLowSERANK3HR='20', dllaMcsMax64qamLowSERANK4HR='20')],
         dist_name=_NRCELLname,
         parameter='pdschHrLaConfig'),
    dict(value=[dict(dllaMcsMax64qamLowSERANK1HR='20', dllaMcsMax64qamLowSERANK2HR='20',
                     dllaMcsMax64qamLowSERANK3HR='20', dllaMcsMax64qamLowSERANK4HR='20')],
         dist_name=_NRCELL2name,
         parameter='pdschHrLaConfig'),
    dict(value='true', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='blind', dist_name=_NRREL1namegnb1, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL1namegnb1, parameter='sCellOperationalMode'),
    dict(value=['ca_Fr1Tdd_Any_Sa', 'ca_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Nsa', 'ca_Fdd_Fr1Tdd_Sa',
                'ca_Fr1Tdd_Fdd_Sa'], dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_recover_gnb1_K_006 = [
    dict(value='blind', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='false', dist_name=_NRBTSDUname, parameter='actNonBfAndBfCa'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='infinity', dist_name=_NRCELL2name, parameter='sCellDeactivationTimerGNB'),
    dict(value=[dict(dllaMcsMax64qamLowSERANK1HR='28', dllaMcsMax64qamLowSERANK2HR='28',
                     dllaMcsMax64qamLowSERANK3HR='28', dllaMcsMax64qamLowSERANK4HR='28')],
         dist_name=_NRCELLname,
         parameter='pdschHrLaConfig'),
    dict(value=[dict(dllaMcsMax64qamLowSERANK1HR='28', dllaMcsMax64qamLowSERANK2HR='28',
                     dllaMcsMax64qamLowSERANK3HR='28', dllaMcsMax64qamLowSERANK4HR='28')],
         dist_name=_NRCELL2name,
         parameter='pdschHrLaConfig'),
    dict(value='true', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value=['ca_Fr1Tdd_Any_Sa', 'ca_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Nsa', 'ca_Fdd_Fr1Tdd_Sa',
                'ca_Fr1Tdd_Fdd_Sa'],
         dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]
PARAM_8246_recover_delete_gnb1_K_006 = [
    dict(dist_name=_NRREL1namegnb1, parameter='sCellAdditionMethod'),
    dict(dist_name=_NRREL1namegnb1, parameter='sCellOperationalMode'),
]

# PARAM_8246_gnb1_K_006_348 = [
#     dict(value='locked', dist_name=_LTECELL48040name, parameter='administrativeState'),
#     dict(value='locked', dist_name=_LTECELL48045name, parameter='administrativeState'),
#     dict(value='Locked', dist_name=_NRCELL701name, parameter='administrativeState'),
#     dict(value='bufferBased', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
#     dict(value='true', dist_name=_NRBTSDUname, parameter='actNonBfAndBfCa'),
#     dict(value='false', dist_name=_NRCELL400name, parameter='actDl256Qam'),
#     dict(value='false', dist_name=_NRCELL400name, parameter='actUl256Qam'),
#     dict(value='false', dist_name=_NRCELL700name, parameter='actUl256Qam'),
#     dict(value='false', dist_name=_NRCELL700name, parameter='actDl256Qam'),
#     dict(value='false', dist_name=_NRCELL400name, parameter='actDlLaDynBlerTarget'),
#     dict(value='false', dist_name=_NRCELL700name, parameter='actDlLaDynBlerTarget'),
#     # dict(value='ms1280', dist_name=_NRCELL700name, parameter='sCellDeactivationTimerGNB'),
#     dict(value=[dict(dllaMcsMax64qamLowSERANK1HR='20', dllaMcsMax64qamLowSERANK2HR='20',
#                      dllaMcsMax64qamLowSERANK3HR='20', dllaMcsMax64qamLowSERANK4HR='20')],
#          dist_name=_NRCELL400name,
#          parameter='pdschHrLaConfig'),
#     dict(value=[dict(dllaMcsMax64qamLowSERANK1HR='20', dllaMcsMax64qamLowSERANK2HR='20',
#                      dllaMcsMax64qamLowSERANK3HR='20', dllaMcsMax64qamLowSERANK4HR='20')],
#          dist_name=_NRCELL700name,
#          parameter='pdschHrLaConfig'),
#     dict(value='true', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
#     dict(value='blind', dist_name=_NRREL400_2namegnb1, parameter='sCellAdditionMethod'),
#     dict(value='dlOnly', dist_name=_NRREL400_2namegnb1, parameter='sCellOperationalMode'),
#     dict(value=['ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fdd', 'ca_Fdd_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Any_Sa', 'ca_Fdd_Any_Sa',
#                 'ca_Fr1Tdd_Fdd_Nsa', 'ca_Fr1Tdd_Fdd_Sa', 'ca_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Sa_WithUl'],
#          dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
#     dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
#          parameter='cipherPrefL'),
#     dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
#          parameter='integrityProtPrefL')
# ]

PARAM_8246_gnb1_K_006_348 = [
    dict(value='TypeB', dist_name=_NRCELL400name, parameter='puschMappingType'),
    dict(value='disabled', dist_name=_NRBTSname, parameter='actSCellReleaseForInactiveSCell'),
    dict(value='disabled', dist_name=_NRBTSname, parameter='actBufferBasedSCellAddition'),
    dict(value='4', dist_name=_NRCELL400name, parameter='maxNumScellsDlFr1'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actLAForHiReliab'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actLAForHiReliab'),
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
    dict(value='blind', dist_name=_NRREL400_2namegnb1, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL400_2namegnb1, parameter='sCellOperationalMode'),
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
    dict(value='false', dist_name=_NRCELL400name, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actDlLaDynBlerTarget'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actDlLaDynBlerTarget'),
    dict(value=[dict(dllaMcsMax64qamLowSERANK1HR='20', dllaMcsMax64qamLowSERANK2HR='20',
                     dllaMcsMax64qamLowSERANK3HR='20', dllaMcsMax64qamLowSERANK4HR='20')],
         dist_name=_NRCELL400name,
         parameter='pdschHrLaConfig'),
    dict(value=[dict(dllaMcsMax64qamLowSERANK1HR='20', dllaMcsMax64qamLowSERANK2HR='20',
                     dllaMcsMax64qamLowSERANK3HR='20', dllaMcsMax64qamLowSERANK4HR='20')],
         dist_name=_NRCELL700name,
         parameter='pdschHrLaConfig'),
    # disable CB008247
    dict(value='false', dist_name=_NRDLMUMIMO_1_700, parameter='actMuAwareTdSch'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actDlSrsBm'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actUlSrsBm'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actSrsUlBeamFallbackByRetrx'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actSrsBeamFallbackByRetrx'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actPdschBeamPowerBalance'),
    # dict(value='false', dist_name=_NRCELL700name, parameter='actDlSrsSubbandBm'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actDlSrsForCA'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actDlRankProbing'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actDlMuMimoEnh'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actCsirsBeamPowerBalance'),
]

# PARAM_8246_recover_gnb1_K_006_348 = [
#     dict(value='unlocked', dist_name=_LTECELL48040name, parameter='administrativeState'),
#     dict(value='unlocked', dist_name=_LTECELL48045name, parameter='administrativeState'),
#     dict(value='Unlocked', dist_name=_NRCELL701name, parameter='administrativeState'),
#     dict(value='bufferBased', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
#     dict(value='false', dist_name=_NRBTSDUname, parameter='actNonBfAndBfCa'),
#     dict(value='true', dist_name=_NRCELL400name, parameter='actDl256Qam'),
#     dict(value='true', dist_name=_NRCELL400name, parameter='actUl256Qam'),
#     dict(value='true', dist_name=_NRCELL700name, parameter='actUl256Qam'),
#     dict(value='true', dist_name=_NRCELL700name, parameter='actDl256Qam'),
#     dict(value='true', dist_name=_NRCELL400name, parameter='actDlLaDynBlerTarget'),
#     dict(value='true', dist_name=_NRCELL700name, parameter='actDlLaDynBlerTarget'),
#     # dict(value='infinity', dist_name=_NRCELL2name, parameter='sCellDeactivationTimerGNB'),
#     dict(value=[dict(dllaMcsMax64qamLowSERANK1HR='28', dllaMcsMax64qamLowSERANK2HR='28',
#                      dllaMcsMax64qamLowSERANK3HR='28', dllaMcsMax64qamLowSERANK4HR='28')],
#          dist_name=_NRCELL400name,
#          parameter='pdschHrLaConfig'),
#     dict(value=[dict(dllaMcsMax64qamLowSERANK1HR='28', dllaMcsMax64qamLowSERANK2HR='28',
#                      dllaMcsMax64qamLowSERANK3HR='28', dllaMcsMax64qamLowSERANK4HR='28')],
#          dist_name=_NRCELL700name,
#          parameter='pdschHrLaConfig'),
#     dict(value='true', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
#     dict(value=['ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fdd', 'ca_Fdd_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Any_Sa', 'ca_Fdd_Any_Sa',
#                 'ca_Fr1Tdd_Fdd_Nsa', 'ca_Fr1Tdd_Fdd_Sa', 'ca_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Sa_WithUl'],
#          dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
#     dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
#          parameter='cipherPrefL'),
#     dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
#          parameter='integrityProtPrefL')
# ]
# PARAM_8246_recover_delete_gnb1_K_006_348 = [
#     dict(dist_name=_NRREL400_2namegnb1, parameter='sCellAdditionMethod'),
#     dict(dist_name=_NRREL400_2namegnb1, parameter='sCellOperationalMode'),
# ]

PARAM_8246_recover_gnb1_K_006_348 = [
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
    dict(value=[dict(dllaMcsMax64qamLowSERANK1HR='28', dllaMcsMax64qamLowSERANK2HR='28',
                     dllaMcsMax64qamLowSERANK3HR='28', dllaMcsMax64qamLowSERANK4HR='28')],
         dist_name=_NRCELL400name,
         parameter='pdschHrLaConfig'),
    dict(value=[dict(dllaMcsMax64qamLowSERANK1HR='28', dllaMcsMax64qamLowSERANK2HR='28',
                     dllaMcsMax64qamLowSERANK3HR='28', dllaMcsMax64qamLowSERANK4HR='28')],
         dist_name=_NRCELL700name,
         parameter='pdschHrLaConfig'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actDlLaDynBlerTarget'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actDlLaDynBlerTarget'),
    # enable CB008247
    dict(value='true', dist_name=_NRDLMUMIMO_1_700, parameter='actMuAwareTdSch'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actDlSrsBm'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actUlSrsBm'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actSrsUlBeamFallbackByRetrx'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actSrsBeamFallbackByRetrx'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actPdschBeamPowerBalance'),
    # dict(value='true', dist_name=_NRCELL700name, parameter='actDlSrsSubbandBm'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actDlSrsForCA'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actDlRankProbing'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actDlMuMimoEnh'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actCsirsBeamPowerBalance'),
]

PARAM_8246_recover_delete_gnb1_K_006_348 = [
    dict(dist_name=_NRCELL400name, parameter='maxNumScellsDlFr1'),
    dict(dist_name=_NRREL400_2namegnb1, parameter='sCellAdditionMethod'),
    dict(dist_name=_NRREL400_2namegnb1, parameter='sCellOperationalMode'),
    dict(dist_name=_NRCELL700name, parameter='increasePUSCHPrepTimeULCA'),
    dict(dist_name=_NRCELL700name, parameter='maxNumOfUlCaUeParallelTx'),
]

PARAM_8246_gnb1_K_06 = [
    dict(value='false', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value=_NRPDCCHHRLA_1, dist_name=_NRDRB10name, parameter='nrPdcchHRLaDN'),
    dict(value=_NRPDSCHHRLA_1, dist_name=_NRDRB10name, parameter='nrPdschHRLaDN'),
    dict(value=_NRPUSCHHRLA_1, dist_name=_NRDRB10name, parameter='nrPuschHRLaDN'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_recover_gnb1_K_06 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]
PARAM_8246_recover_delete_gnb1_K_06 = [
    dict(dist_name=_NRDRB10name, parameter='nrPdcchHRLaDN'),
    dict(dist_name=_NRDRB10name, parameter='nrPdschHRLaDN'),
    dict(dist_name=_NRDRB10name, parameter='nrPuschHRLaDN'),
]

PARAM_8246_enb1_K_011 = [
    dict(value=_MME_IP, dist_name=_LNMME_0, parameter='ipAddrPrim'),
]

PARAM_8246_recover_enb1_K_011 = [
    dict(value=_initial_MME_IP, dist_name=_LNMME_0, parameter='ipAddrPrim'),
]

PARAM_8246_gnb1_K_011 = [
    dict(value='bufferBased', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='true', dist_name=_NRBTSDUname, parameter='actNonBfAndBfCa'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='ms1280', dist_name=_NRCELL2name, parameter='sCellDeactivationTimerGNB'),
    dict(value=_NRPDCCHHRLA_1, dist_name=_NRDRB5name, parameter='nrPdcchHRLaDN'),
    dict(value=_NRPDSCHHRLA_1, dist_name=_NRDRB5name, parameter='nrPdschHRLaDN'),
    dict(value=_NRPUSCHHRLA_1, dist_name=_NRDRB5name, parameter='nrPuschHRLaDN'),
    dict(value='Locked', dist_name=_SERVEDAMF, parameter='administrativeState'),
    dict(value='blind', dist_name=_NRREL1namegnb1, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL1namegnb1, parameter='sCellOperationalMode'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_recover_gnb1_K_011 = [
    dict(value='blind', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='false', dist_name=_NRBTSDUname, parameter='actNonBfAndBfCa'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actLAForHiReliab'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='infinity', dist_name=_NRCELL2name, parameter='sCellDeactivationTimerGNB'),
    dict(value='Unlocked', dist_name=_SERVEDAMF, parameter='administrativeState'),
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]
PARAM_8246_recover_delete_gnb1_K_011 = [
    dict(dist_name=_NRDRB5name, parameter='nrPdcchHRLaDN'),
    dict(dist_name=_NRDRB5name, parameter='nrPdschHRLaDN'),
    dict(dist_name=_NRDRB5name, parameter='nrPuschHRLaDN'),
    dict(dist_name=_NRREL1namegnb1, parameter='sCellAdditionMethod'),
    dict(dist_name=_NRREL1namegnb1, parameter='sCellOperationalMode'),
]

# PARAM_8246_gnb1_K_011_348 = [
#     dict(value='Locked', dist_name=_NRCELL701name, parameter='administrativeState'),
#     dict(value='Locked', dist_name=_NRCELL544name, parameter='administrativeState'),
#     dict(value='Locked', dist_name=_NRCELL644name, parameter='administrativeState'),
#     dict(value='locked', dist_name=_LTECELL48040name, parameter='administrativeState'),
#     dict(value='locked', dist_name=_LTECELL48045name, parameter='administrativeState'),
#     dict(value='locked', dist_name=_LTECELL48043name, parameter='administrativeState'),
#     dict(value='locked', dist_name=_LTECELL48044name, parameter='administrativeState'),
#     dict(value='bufferBased', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
#     dict(value='true', dist_name=_NRBTSDUname, parameter='actNonBfAndBfCa'),
#     dict(value='false', dist_name=_NRCELL700name, parameter='actLAForHiReliab'),
#     dict(value='false', dist_name=_NRCELL400name, parameter='actDl256Qam'),
#     dict(value='false', dist_name=_NRCELL400name, parameter='actUl256Qam'),
#     dict(value='false', dist_name=_NRCELL700name, parameter='actUl256Qam'),
#     dict(value='false', dist_name=_NRCELL700name, parameter='actDl256Qam'),
#     dict(value='false', dist_name=_NRCELL400name, parameter='actDlLaDynBlerTarget'),
#     dict(value='false', dist_name=_NRCELL700name, parameter='actDlLaDynBlerTarget'),
#     # dict(value='ms1280', dist_name=_NRCELL700name, parameter='sCellDeactivationTimerGNB'),
#     dict(value=_NRPDCCHHRLA_1, dist_name=_NRDRB5name, parameter='nrPdcchHRLaDN'),
#     dict(value=_NRPDSCHHRLA_1, dist_name=_NRDRB5name, parameter='nrPdschHRLaDN'),
#     dict(value=_NRPUSCHHRLA_1, dist_name=_NRDRB5name, parameter='nrPuschHRLaDN'),
#     dict(value='Locked', dist_name=_SERVEDAMF, parameter='administrativeState'),
#     dict(value='blind', dist_name=_NRREL400_2namegnb1, parameter='sCellAdditionMethod'),
#     dict(value='dlOnly', dist_name=_NRREL400_2namegnb1, parameter='sCellOperationalMode'),
#     dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
#          parameter='cipherPrefL'),
#     dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
#          parameter='integrityProtPrefL')
# ]

PARAM_8246_gnb1_K_011_348 = [
    dict(value='Locked', dist_name=_NRCELL701name, parameter='administrativeState'),
    dict(value='Locked', dist_name=_NRCELL400name, parameter='administrativeState'),
    dict(value='Locked', dist_name=_NRCELL644name, parameter='administrativeState'),
    dict(value='Locked', dist_name=_NRCELL545name, parameter='administrativeState'),
    dict(value='Locked', dist_name=_NRCELL645name, parameter='administrativeState'),
    dict(value='Locked', dist_name=_NRCELL410name, parameter='administrativeState'),
    dict(value='locked', dist_name=_LTECELL48040name, parameter='administrativeState'),
    dict(value='locked', dist_name=_LTECELL48042name, parameter='administrativeState'),
    dict(value='locked', dist_name=_LTECELL48049name, parameter='administrativeState'),
    dict(value='locked', dist_name=_LTECELL48045name, parameter='administrativeState'),
    dict(value='locked', dist_name=_LTECELL48043name, parameter='administrativeState'),
    dict(value='locked', dist_name=_LTECELL48044name, parameter='administrativeState'),
    dict(value='locked', dist_name=_LTECELL48046name, parameter='administrativeState'),
    dict(value='locked', dist_name=_LTECELL48047name, parameter='administrativeState'),
    dict(value='locked', dist_name=_LTECELL48048name, parameter='administrativeState'),
    dict(value=_NRPDCCHHRLA_1, dist_name=_NRDRB5name, parameter='nrPdcchHRLaDN'),
    dict(value=_NRPDSCHHRLA_1, dist_name=_NRDRB5name, parameter='nrPdschHRLaDN'),
    dict(value=_NRPUSCHHRLA_1, dist_name=_NRDRB5name, parameter='nrPuschHRLaDN'),
    dict(value='Locked', dist_name=_SERVEDAMF, parameter='administrativeState'),
    dict(value='TypeB', dist_name=_NRCELL544name, parameter='puschMappingType'),
    dict(value='disabled', dist_name=_NRBTSname, parameter='actSCellReleaseForInactiveSCell'),
    dict(value='disabled', dist_name=_NRBTSname, parameter='actBufferBasedSCellAddition'),
    dict(value='4', dist_name=_NRCELL544name, parameter='maxNumScellsDlFr1'),
    dict(value='true', dist_name=_NRCELL544name, parameter='actLAForHiReliab'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actLAForHiReliab'),
    dict(value='infinity', dist_name=_NRCELL544name, parameter='sCellDeactivationTimerGNB'),
    dict(value='infinity', dist_name=_NRCELL700name, parameter='sCellDeactivationTimerGNB'),
    dict(value='1TTI', dist_name=_NRCELL544name, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL700name, parameter='sCellActivationLevel'),
    dict(value='5TTI', dist_name=_NRCELL544name, parameter='sCellActivationLevelUL'),
    dict(value='5TTI', dist_name=_NRCELL700name, parameter='sCellActivationLevelUL'),
    dict(value='longPucch', dist_name=_NRCELL544name, parameter='pucchModeSelect'),
    dict(value='longPucch', dist_name=_NRCELL700name, parameter='pucchModeSelect'),
    dict(value='true', dist_name=_NRCELL544name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL544name, parameter='actAdaptiveReTxResMcs'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actAdaptiveReTxResMcs'),
    dict(value='false', dist_name=_NRCELL544name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELL544name, parameter='actShortBsrLimitAdaptation'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actShortBsrLimitAdaptation'),
    dict(value='slots20', dist_name=_NRCELL544name, parameter='srPeriodicity'),
    dict(value='true', dist_name=_NRCELL544_FDD1, parameter='actPerCsiReportBundlingFdd'),
    dict(value='zeroDot15', dist_name=_NRCELL544name, parameter='pucchF3MaxCodeRate'),
    dict(value='zeroDot15', dist_name=_NRCELL700name, parameter='pucchF3MaxCodeRate'),
    dict(value='qpsk_4psk', dist_name=_NRCELL544name, parameter='pucchF3ModulationScheme'),
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
    dict(value='blind', dist_name=_NRREL544_1namegnb1, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL544_1namegnb1, parameter='sCellOperationalMode'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL'),
    dict(value='slots20', dist_name=_NRCELL544name, parameter='preferredVoNrSrPeriod'),
    dict(value='slots10', dist_name=_NRCELL544name, parameter='srPeriodicityMin'),
    dict(value='n25600', dist_name=_NRCELL544name, parameter='timingAdvanceOffset'),
    dict(value='n25600', dist_name=_NRCELL644name, parameter='timingAdvanceOffset'),
    dict(value='n25600', dist_name=_NRCELL545name, parameter='timingAdvanceOffset'),
    dict(value='n25600', dist_name=_NRCELL645name, parameter='timingAdvanceOffset'),
    dict(value='n25600', dist_name=_NRCELL700name, parameter='timingAdvanceOffset'),
    dict(value='n25600', dist_name=_NRCELL701name, parameter='timingAdvanceOffset'),
    dict(value='false', dist_name=_NRCELL544name, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELL544name, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELL544name, parameter='actDlLaDynBlerTarget'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actDlLaDynBlerTarget'),
    # disable CB008247
    dict(value='false', dist_name=_NRDLMUMIMO_1_700, parameter='actMuAwareTdSch'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actDlSrsBm'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actUlSrsBm'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actSrsUlBeamFallbackByRetrx'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actSrsBeamFallbackByRetrx'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actPdschBeamPowerBalance'),
    # dict(value='false', dist_name=_NRCELL700name, parameter='actDlSrsSubbandBm'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actDlSrsForCA'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actDlRankProbing'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actDlMuMimoEnh'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actCsirsBeamPowerBalance'),
]

# PARAM_8246_recover_gnb1_K_011_348 = [
#     dict(value='Unlocked', dist_name=_NRCELL701name, parameter='administrativeState'),
#     dict(value='Unlocked', dist_name=_NRCELL544name, parameter='administrativeState'),
#     dict(value='Unlocked', dist_name=_NRCELL644name, parameter='administrativeState'),
#     dict(value='unlocked', dist_name=_LTECELL48040name, parameter='administrativeState'),
#     dict(value='unlocked', dist_name=_LTECELL48045name, parameter='administrativeState'),
#     dict(value='unlocked', dist_name=_LTECELL48043name, parameter='administrativeState'),
#     dict(value='unlocked', dist_name=_LTECELL48044name, parameter='administrativeState'),
#     dict(value='bufferBased', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
#     dict(value='false', dist_name=_NRBTSDUname, parameter='actNonBfAndBfCa'),
#     dict(value='true', dist_name=_NRCELL700name, parameter='actLAForHiReliab'),
#     dict(value='true', dist_name=_NRCELL400name, parameter='actDl256Qam'),
#     dict(value='true', dist_name=_NRCELL400name, parameter='actUl256Qam'),
#     dict(value='true', dist_name=_NRCELL700name, parameter='actUl256Qam'),
#     dict(value='true', dist_name=_NRCELL700name, parameter='actDl256Qam'),
#     dict(value='true', dist_name=_NRCELL400name, parameter='actDlLaDynBlerTarget'),
#     dict(value='true', dist_name=_NRCELL700name, parameter='actDlLaDynBlerTarget'),
#     # dict(value='infinity', dist_name=_NRCELL700name, parameter='sCellDeactivationTimerGNB'),
#     dict(value='Unlocked', dist_name=_SERVEDAMF, parameter='administrativeState'),
#     dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
#          parameter='cipherPrefL'),
#     dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
#          parameter='integrityProtPrefL')
# ]
# PARAM_8246_recover_delete_gnb1_K_011_348 = [
#     dict(dist_name=_NRDRB5name, parameter='nrPdcchHRLaDN'),
#     dict(dist_name=_NRDRB5name, parameter='nrPdschHRLaDN'),
#     dict(dist_name=_NRDRB5name, parameter='nrPuschHRLaDN'),
#     dict(dist_name=_NRREL400_2namegnb1, parameter='sCellAdditionMethod'),
#     dict(dist_name=_NRREL400_2namegnb1, parameter='sCellOperationalMode'),
# ]

PARAM_8246_recover_gnb1_K_011_348 = [
    dict(value='Unlocked', dist_name=_NRCELL701name, parameter='administrativeState'),
    dict(value='Unlocked', dist_name=_NRCELL400name, parameter='administrativeState'),
    dict(value='Unlocked', dist_name=_NRCELL644name, parameter='administrativeState'),
    dict(value='Unlocked', dist_name=_NRCELL545name, parameter='administrativeState'),
    dict(value='Unlocked', dist_name=_NRCELL645name, parameter='administrativeState'),
    dict(value='Unlocked', dist_name=_NRCELL410name, parameter='administrativeState'),
    dict(value='unlocked', dist_name=_LTECELL48040name, parameter='administrativeState'),
    dict(value='unlocked', dist_name=_LTECELL48042name, parameter='administrativeState'),
    dict(value='unlocked', dist_name=_LTECELL48049name, parameter='administrativeState'),
    dict(value='unlocked', dist_name=_LTECELL48045name, parameter='administrativeState'),
    dict(value='unlocked', dist_name=_LTECELL48043name, parameter='administrativeState'),
    dict(value='unlocked', dist_name=_LTECELL48044name, parameter='administrativeState'),
    dict(value='unlocked', dist_name=_LTECELL48046name, parameter='administrativeState'),
    dict(value='unlocked', dist_name=_LTECELL48047name, parameter='administrativeState'),
    dict(value='unlocked', dist_name=_LTECELL48048name, parameter='administrativeState'),
    dict(value='Unlocked', dist_name=_SERVEDAMF, parameter='administrativeState'),
    dict(value='TypeB', dist_name=_NRCELL544name, parameter='puschMappingType'),
    dict(value='timer_based_Fr1', dist_name=_NRBTSname, parameter='actSCellReleaseForInactiveSCell'),
    dict(value='oneShot_Dl_Fr1', dist_name=_NRBTSname, parameter='actBufferBasedSCellAddition'),
    dict(value='true', dist_name=_NRCELL544name, parameter='actLAForHiReliab'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actLAForHiReliab'),
    dict(value='infinity', dist_name=_NRCELL544name, parameter='sCellDeactivationTimerGNB'),
    dict(value='infinity', dist_name=_NRCELL700name, parameter='sCellDeactivationTimerGNB'),
    dict(value='1TTI', dist_name=_NRCELL544name, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL700name, parameter='sCellActivationLevel'),
    dict(value='1TTI', dist_name=_NRCELL544name, parameter='sCellActivationLevelUL'),
    dict(value='1TTI', dist_name=_NRCELL700name, parameter='sCellActivationLevelUL'),
    dict(value='longPucch', dist_name=_NRCELL544name, parameter='pucchModeSelect'),
    dict(value='longPucch', dist_name=_NRCELL700name, parameter='pucchModeSelect'),
    dict(value='true', dist_name=_NRCELL544name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actCDrx'),
    dict(value='true', dist_name=_NRCELL544name, parameter='actAdaptiveReTxResMcs'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actAdaptiveReTxResMcs'),
    dict(value='false', dist_name=_NRCELL544name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELL544name, parameter='actShortBsrLimitAdaptation'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actShortBsrLimitAdaptation'),
    dict(value='slots80', dist_name=_NRCELL544name, parameter='srPeriodicity'),
    dict(value='false', dist_name=_NRCELL544_FDD1, parameter='actPerCsiReportBundlingFdd'),
    dict(value='zeroDot15', dist_name=_NRCELL544name, parameter='pucchF3MaxCodeRate'),
    dict(value='zeroDot15', dist_name=_NRCELL700name, parameter='pucchF3MaxCodeRate'),
    dict(value='qpsk_4psk', dist_name=_NRCELL544name, parameter='pucchF3ModulationScheme'),
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
    dict(value='slots40', dist_name=_NRCELL544name, parameter='preferredVoNrSrPeriod'),
    dict(value='slots40', dist_name=_NRCELL544name, parameter='srPeriodicityMin'),
    dict(value='n0', dist_name=_NRCELL544name, parameter='timingAdvanceOffset'),
    dict(value='n0', dist_name=_NRCELL644name, parameter='timingAdvanceOffset'),
    dict(value='n0', dist_name=_NRCELL545name, parameter='timingAdvanceOffset'),
    dict(value='n0', dist_name=_NRCELL645name, parameter='timingAdvanceOffset'),
    dict(value='n39936', dist_name=_NRCELL700name, parameter='timingAdvanceOffset'),
    dict(value='n39936', dist_name=_NRCELL701name, parameter='timingAdvanceOffset'),
    dict(value='unlocked', dist_name=_LTECELL48040name, parameter='administrativeState'),
    dict(value='unlocked', dist_name=_LTECELL48045name, parameter='administrativeState'),
    dict(value='Unlocked', dist_name=_NRCELL701name, parameter='administrativeState'),
    dict(value='true', dist_name=_NRCELL544name, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELL544name, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELL544name, parameter='actDlLaDynBlerTarget'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actDlLaDynBlerTarget'),
    dict(value='500', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutageTbsThresh'),
    dict(value='4000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverTbsThresh'),
    # enable CB008247
    dict(value='true', dist_name=_NRDLMUMIMO_1_700, parameter='actMuAwareTdSch'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actDlSrsBm'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actUlSrsBm'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actSrsUlBeamFallbackByRetrx'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actSrsBeamFallbackByRetrx'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actPdschBeamPowerBalance'),
    # dict(value='true', dist_name=_NRCELL700name, parameter='actDlSrsSubbandBm'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actDlSrsForCA'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actDlRankProbing'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actDlMuMimoEnh'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actCsirsBeamPowerBalance'),
]

PARAM_8246_recover_delete_gnb1_K_011_348 = [
    dict(dist_name=_NRDRB5name, parameter='nrPdcchHRLaDN'),
    dict(dist_name=_NRDRB5name, parameter='nrPdschHRLaDN'),
    dict(dist_name=_NRDRB5name, parameter='nrPuschHRLaDN'),
    dict(dist_name=_NRCELL544name, parameter='maxNumScellsDlFr1'),
    dict(dist_name=_NRREL544_1namegnb1, parameter='sCellAdditionMethod'),
    dict(dist_name=_NRREL544_1namegnb1, parameter='sCellOperationalMode'),
    dict(dist_name=_NRCELL700name, parameter='increasePUSCHPrepTimeULCA'),
    dict(dist_name=_NRCELL700name, parameter='maxNumOfUlCaUeParallelTx'),
]

PARAM_8246_enb1_K_012 = [
    dict(value=_MME_IP, dist_name=_LNMME_MO, parameter='ipAddrPrim'),
]

PARAM_8246_recover_enb1_K_012 = [
    dict(value=_initial_MME_IP, dist_name=_LNMME_MO, parameter='ipAddrPrim'),
]

PARAM_8246_gnb1_K_012_amf = [
    dict(value='Locked', dist_name=_SERVEDAMF, parameter='administrativeState'),
]

PARAM_8246_gnb1_K_012_24R1 = [
    dict(value='rsrp', dist_name=_NRCELLname, parameter='a1MeasSCellAddEnabled'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value=_NRPDCCHHRLA_1, dist_name=_NRDRB4name, parameter='nrPdcchHRLaDN'),
    dict(value=_NRPDSCHHRLA_1, dist_name=_NRDRB4name, parameter='nrPdschHRLaDN'),
    dict(value=_NRPUSCHHRLA_1, dist_name=_NRDRB4name, parameter='nrPuschHRLaDN'),
    # dict(value='Locked', dist_name=_SERVEDAMF, parameter='administrativeState'),
    dict(value='covBasedA1', dist_name=_NRREL1namegnb1, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL1namegnb1, parameter='sCellOperationalMode'),
    dict(value='true', dist_name=_NRBTSname, parameter='actMeasBasedSCellAddition'),
    dict(value='true', dist_name=_NRBTSname, parameter='actMeasBasedSCellAdditionNsa'),
    # dict(value=['A1-based'],
    #      dist_name=_NRBTSname, parameter='actMeasBasedSCellAdditionSa'),
    # dict(value='8', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerOutageMcsThresh64qamLowSE'),
    # dict(value='13', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerRecoverMcsThresh64qamLowSE'),
    # dict(value='2', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerRecoverPeriod'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]
PARAM_8246_gnb1_K_012 = [
    dict(value='bufferBased', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='true', dist_name=_NRBTSDUname, parameter='actNonBfAndBfCa'),
    dict(value='rsrp', dist_name=_NRCELLname, parameter='a1MeasSCellAddEnabled'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value=_NRPDCCHHRLA_1, dist_name=_NRDRB4name, parameter='nrPdcchHRLaDN'),
    dict(value=_NRPDSCHHRLA_1, dist_name=_NRDRB4name, parameter='nrPdschHRLaDN'),
    dict(value=_NRPUSCHHRLA_1, dist_name=_NRDRB4name, parameter='nrPuschHRLaDN'),
    # dict(value='Locked', dist_name=_SERVEDAMF, parameter='administrativeState'),
    dict(value='covBasedA1', dist_name=_NRREL1namegnb1, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL1namegnb1, parameter='sCellOperationalMode'),
    # dict(value='true', dist_name=_NRBTSname, parameter='actMeasBasedSCellAddition'),
    dict(value='true', dist_name=_NRBTSname, parameter='actMeasBasedSCellAdditionNsa'),
    dict(value=['A1-based'],
         dist_name=_NRBTSname, parameter='actMeasBasedSCellAdditionSa'),
    # dict(value='8', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerOutageMcsThresh64qamLowSE'),
    # dict(value='13', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerRecoverMcsThresh64qamLowSE'),
    # dict(value='2', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerRecoverPeriod'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_recover_gnb1_K_012_24R1 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='Unlocked', dist_name=_SERVEDAMF, parameter='administrativeState'),
    dict(value='false', dist_name=_NRBTSname, parameter='actMeasBasedSCellAddition'),
    dict(value='false', dist_name=_NRBTSname, parameter='actMeasBasedSCellAdditionNsa'),
    # dict(value=['disabled'],
    #      dist_name=_NRBTSname, parameter='actMeasBasedSCellAdditionSa'),
    # dict(value='2', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerOutageMcsThresh64qamLowSE'),
    # dict(value='11', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerRecoverMcsThresh64qamLowSE'),
    # dict(value='1', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerRecoverPeriod'),
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]
PARAM_8246_recover_gnb1_K_012 = [
    dict(value='blind', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='false', dist_name=_NRBTSDUname, parameter='actNonBfAndBfCa'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='Unlocked', dist_name=_SERVEDAMF, parameter='administrativeState'),
    # dict(value='false', dist_name=_NRBTSname, parameter='actMeasBasedSCellAddition'),
    dict(value='false', dist_name=_NRBTSname, parameter='actMeasBasedSCellAdditionNsa'),
    dict(value=['disabled'],
         dist_name=_NRBTSname, parameter='actMeasBasedSCellAdditionSa'),
    # dict(value='2', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerOutageMcsThresh64qamLowSE'),
    # dict(value='11', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerRecoverMcsThresh64qamLowSE'),
    # dict(value='1', dist_name=_NRPDSCHHRLA_1, parameter='dlHRBlerRecoverPeriod'),
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]
PARAM_8246_recover_delete_gnb1_K_012 = [
    dict(dist_name=_NRDRB4name, parameter='nrPdcchHRLaDN'),
    dict(dist_name=_NRDRB4name, parameter='nrPdschHRLaDN'),
    dict(dist_name=_NRDRB4name, parameter='nrPuschHRLaDN'),
    dict(dist_name=_NRREL1namegnb1, parameter='sCellAdditionMethod'),
    dict(dist_name=_NRREL1namegnb1, parameter='sCellOperationalMode'),
    dict(dist_name=_NRCELLname, parameter='a1MeasSCellAddEnabled'),
]

PARAM_8246_gnb1_K_16 = [
    dict(value='bufferBased', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='true', dist_name=_NRBTSDUname, parameter='actNonBfAndBfCa'),
    dict(value=[dict(dllaMcsMax64qamLowSERANK1HR='20', dllaMcsMax64qamLowSERANK2HR='20',
                     dllaMcsMax64qamLowSERANK3HR='20', dllaMcsMax64qamLowSERANK4HR='20')],
         dist_name=_NRCELLname,
         parameter='pdschHrLaConfig'),
    dict(value=[dict(dllaMcsMax64qamLowSERANK1HR='20', dllaMcsMax64qamLowSERANK2HR='20',
                     dllaMcsMax64qamLowSERANK3HR='20', dllaMcsMax64qamLowSERANK4HR='20')],
         dist_name=_NRCELL2name,
         parameter='pdschHrLaConfig'),
    dict(value=[dict(ullaMcsMax64qamLowSERANK1HR='20', ullaMcsMax64qamLowSERANK2HR='20',
                     ullaMcsMax64qamRANK1HR='20', ullaMcsMax64qamRANK2HR='20')],
         dist_name=_NRCELLname,
         parameter='puschHrLaConfig'),
    dict(value=[dict(ullaMcsMax64qamLowSERANK1HR='20', ullaMcsMax64qamLowSERANK2HR='20',
                     ullaMcsMax64qamRANK1HR='20', ullaMcsMax64qamRANK2HR='20')],
         dist_name=_NRCELL2name,
         parameter='puschHrLaConfig'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='true', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='blind', dist_name=_NRREL1namegnb1, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL1namegnb1, parameter='sCellOperationalMode'),
    dict(value=['ca_Fr1Tdd_Any_Sa', 'ca_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Nsa', 'ca_Fdd_Fr1Tdd_Sa',
                'ca_Fr1Tdd_Fdd_Sa'], dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlCgType2'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actUlCgType2'),
    dict(value=f'{_NRBTSname}/NRULCG_PROFILE-1', dist_name=_NRDRB10name, parameter='nrDrbUlCgDN'),
    dict(value=f'{_NRBTSname}/NRULCG_PROFILE-1', dist_name=_NRDRB12name, parameter='nrDrbUlCgDN'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_recover_gnb1_K_16 = [
    dict(value='blind', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='false', dist_name=_NRBTSDUname, parameter='actNonBfAndBfCa'),
    dict(value=[dict(dllaMcsMax64qamLowSERANK1HR='28', dllaMcsMax64qamLowSERANK2HR='28',
                     dllaMcsMax64qamLowSERANK3HR='28', dllaMcsMax64qamLowSERANK4HR='28')],
         dist_name=_NRCELLname,
         parameter='pdschHrLaConfig'),
    dict(value=[dict(dllaMcsMax64qamLowSERANK1HR='28', dllaMcsMax64qamLowSERANK2HR='28',
                     dllaMcsMax64qamLowSERANK3HR='28', dllaMcsMax64qamLowSERANK4HR='28')],
         dist_name=_NRCELL2name,
         parameter='pdschHrLaConfig'),
    dict(value=[dict(ullaMcsMax64qamLowSERANK1HR='28', ullaMcsMax64qamLowSERANK2HR='28',
                     ullaMcsMax64qamRANK1HR='28', ullaMcsMax64qamRANK2HR='28')],
         dist_name=_NRCELLname,
         parameter='puschHrLaConfig'),
    dict(value=[dict(ullaMcsMax64qamLowSERANK1HR='28', ullaMcsMax64qamLowSERANK2HR='28',
                     ullaMcsMax64qamRANK1HR='28', ullaMcsMax64qamRANK2HR='28')],
         dist_name=_NRCELL2name,
         parameter='puschHrLaConfig'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='true', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value=['ca_Fr1Tdd_Any_Sa', 'ca_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Nsa', 'ca_Fdd_Fr1Tdd_Sa',
                'ca_Fr1Tdd_Fdd_Sa'], dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUlCgType2'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actUlCgType2'),
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]
PARAM_8246_recover_delete_gnb1_K_16 = [
    dict(dist_name=_NRREL1namegnb1, parameter='sCellAdditionMethod'),
    dict(dist_name=_NRREL1namegnb1, parameter='sCellOperationalMode'),
    dict(dist_name=_NRDRB10name, parameter='nrDrbUlCgDN'),
    dict(dist_name=_NRDRB12name, parameter='nrDrbUlCgDN'),
]

PARAM_8246_gnb1_K_018 = [
    dict(value='bufferBased', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='true', dist_name=_NRBTSDUname, parameter='actNonBfAndBfCa'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='ms1280', dist_name=_NRCELLname, parameter='sCellDeactivationTimerGNB'),
    dict(value='10000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutageTbsThresh'),
    dict(value='20000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverTbsThresh'),
    dict(value='true', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value='blind', dist_name=_NRREL21namegnb1, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL21namegnb1, parameter='sCellOperationalMode'),
    dict(value=['ca_Fr1Tdd_Any_Sa', 'ca_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Nsa', 'ca_Fdd_Fr1Tdd_Sa',
                'ca_Fr1Tdd_Fdd_Sa'], dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_recover_gnb1_K_018 = [
    dict(value='blind', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
    dict(value='false', dist_name=_NRBTSDUname, parameter='actNonBfAndBfCa'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='infinity', dist_name=_NRCELLname, parameter='sCellDeactivationTimerGNB'),
    dict(value='500', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutageTbsThresh'),
    dict(value='4000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverTbsThresh'),
    dict(value='true', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
    dict(value=['ca_Fr1Tdd_Any_Sa', 'ca_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Nsa', 'ca_Fdd_Fr1Tdd_Sa',
                'ca_Fr1Tdd_Fdd_Sa'], dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]
PARAM_8246_recover_delete_gnb1_K_018 = [
    dict(dist_name=_NRREL21namegnb1, parameter='sCellAdditionMethod'),
    dict(dist_name=_NRREL21namegnb1, parameter='sCellOperationalMode'),
]

# PARAM_8246_gnb1_K_018_348 = [
#     dict(value='locked', dist_name=_LTECELL48040name, parameter='administrativeState'),
#     dict(value='locked', dist_name=_LTECELL48045name, parameter='administrativeState'),
#     dict(value='Locked', dist_name=_NRCELL701name, parameter='administrativeState'),
#     dict(value='bufferBased', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
#     dict(value='true', dist_name=_NRBTSDUname, parameter='actNonBfAndBfCa'),
#     dict(value='false', dist_name=_NRCELL400name, parameter='actDl256Qam'),
#     dict(value='false', dist_name=_NRCELL400name, parameter='actUl256Qam'),
#     dict(value='false', dist_name=_NRCELL700name, parameter='actUl256Qam'),
#     dict(value='false', dist_name=_NRCELL700name, parameter='actDl256Qam'),
#     dict(value='false', dist_name=_NRCELL400name, parameter='actDlLaDynBlerTarget'),
#     dict(value='false', dist_name=_NRCELL700name, parameter='actDlLaDynBlerTarget'),
#     # dict(value='ms1280', dist_name=_NRCELL700name, parameter='sCellDeactivationTimerGNB'),
#     dict(value='10000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutageTbsThresh'),
#     dict(value='20000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverTbsThresh'),
#     dict(value='true', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
#     dict(value='blind', dist_name=_NRREL400_2namegnb1, parameter='sCellAdditionMethod'),
#     dict(value='dlOnly', dist_name=_NRREL400_2namegnb1, parameter='sCellOperationalMode'),
#     dict(value=['ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fdd', 'ca_Fdd_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Any_Sa', 'ca_Fdd_Any_Sa',
#                 'ca_Fr1Tdd_Fdd_Nsa', 'ca_Fr1Tdd_Fdd_Sa', 'ca_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Sa_WithUl'],
#          dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
#     dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
#          parameter='cipherPrefL'),
#     dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
#          parameter='integrityProtPrefL')
# ]

PARAM_8246_gnb1_K_018_348 = [
    dict(value='TypeB', dist_name=_NRCELL400name, parameter='puschMappingType'),
    dict(value='disabled', dist_name=_NRBTSname, parameter='actSCellReleaseForInactiveSCell'),
    dict(value='disabled', dist_name=_NRBTSname, parameter='actBufferBasedSCellAddition'),
    dict(value='4', dist_name=_NRCELL400name, parameter='maxNumScellsDlFr1'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actLAForHiReliab'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actLAForHiReliab'),
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
    dict(value='blind', dist_name=_NRREL400_2namegnb1, parameter='sCellAdditionMethod'),
    dict(value='dlAndUl', dist_name=_NRREL400_2namegnb1, parameter='sCellOperationalMode'),
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
    dict(value='false', dist_name=_NRCELL400name, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actDlLaDynBlerTarget'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actDlLaDynBlerTarget'),
    #  K18
    dict(value='15000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutageTbsThresh'),
    dict(value='20000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverTbsThresh'),
    # disable CB008247
    dict(value='false', dist_name=_NRDLMUMIMO_1_700, parameter='actMuAwareTdSch'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actDlSrsBm'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actUlSrsBm'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actSrsUlBeamFallbackByRetrx'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actSrsBeamFallbackByRetrx'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actPdschBeamPowerBalance'),
    # dict(value='false', dist_name=_NRCELL700name, parameter='actDlSrsSubbandBm'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actDlSrsForCA'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actDlRankProbing'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actDlMuMimoEnh'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actCsirsBeamPowerBalance'),
]

# PARAM_8246_recover_gnb1_K_018_348 = [
#     dict(value='unlocked', dist_name=_LTECELL48040name, parameter='administrativeState'),
#     dict(value='unlocked', dist_name=_LTECELL48045name, parameter='administrativeState'),
#     dict(value='Unlocked', dist_name=_NRCELL701name, parameter='administrativeState'),
#     dict(value='bufferBased', dist_name=_NRBTSname, parameter='sCellActivationMethod'),
#     dict(value='false', dist_name=_NRBTSDUname, parameter='actNonBfAndBfCa'),
#     dict(value='true', dist_name=_NRCELL400name, parameter='actDl256Qam'),
#     dict(value='true', dist_name=_NRCELL400name, parameter='actUl256Qam'),
#     dict(value='true', dist_name=_NRCELL700name, parameter='actUl256Qam'),
#     dict(value='true', dist_name=_NRCELL700name, parameter='actDl256Qam'),
#     dict(value='true', dist_name=_NRCELL400name, parameter='actDlLaDynBlerTarget'),
#     dict(value='true', dist_name=_NRCELL700name, parameter='actDlLaDynBlerTarget'),
#     # dict(value='infinity', dist_name=_NRCELL700name, parameter='sCellDeactivationTimerGNB'),
#     dict(value='500', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutageTbsThresh'),
#     dict(value='4000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverTbsThresh'),
#     dict(value='true', dist_name=_NRBTSDUname, parameter='actConnectedModeMobilityCA'),
#     dict(value=['ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fdd', 'ca_Fdd_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Any_Sa', 'ca_Fdd_Any_Sa',
#                 'ca_Fr1Tdd_Fdd_Nsa', 'ca_Fr1Tdd_Fdd_Sa', 'ca_Fr1Tdd_Nsa', 'ca_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Sa_WithUl'],
#          dist_name=_NRBTSDUname, parameter='carrierAggregationSupportList'),
#     dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
#          parameter='cipherPrefL'),
#     dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
#          parameter='integrityProtPrefL')
# ]
# PARAM_8246_recover_delete_gnb1_K_018_348 = [
#     dict(dist_name=_NRREL400_2namegnb1, parameter='sCellAdditionMethod'),
#     dict(dist_name=_NRREL400_2namegnb1, parameter='sCellOperationalMode'),
# ]

PARAM_8246_recover_gnb1_K_018_348 = [
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
    dict(value='true', dist_name=_NRCELL400name, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actDlLaDynBlerTarget'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actDlLaDynBlerTarget'),
    dict(value='500', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutageTbsThresh'),
    dict(value='4000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverTbsThresh'),
    # enable CB008247
    dict(value='true', dist_name=_NRDLMUMIMO_1_700, parameter='actMuAwareTdSch'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actDlSrsBm'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actUlSrsBm'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actSrsUlBeamFallbackByRetrx'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actSrsBeamFallbackByRetrx'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actPdschBeamPowerBalance'),
    # dict(value='true', dist_name=_NRCELL700name, parameter='actDlSrsSubbandBm'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actDlSrsForCA'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actDlRankProbing'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actDlMuMimoEnh'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actCsirsBeamPowerBalance'),
]

PARAM_8246_recover_delete_gnb1_K_018_348 = [
    dict(dist_name=_NRCELL400name, parameter='maxNumScellsDlFr1'),
    dict(dist_name=_NRREL400_2namegnb1, parameter='sCellAdditionMethod'),
    dict(dist_name=_NRREL400_2namegnb1, parameter='sCellOperationalMode'),
    dict(dist_name=_NRCELL700name, parameter='increasePUSCHPrepTimeULCA'),
    dict(dist_name=_NRCELL700name, parameter='maxNumOfUlCaUeParallelTx'),
]

PARAM_8246_gnb1_K_019 = [
    dict(value='false', dist_name=_NRCELLname, parameter='actRel16DmrsForPusch'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUlDftSOfdm'),
    dict(value=_NRPDCCHHRLA_1, dist_name=_NRDRB16name, parameter='nrPdcchHRLaDN'),
    dict(value=_NRPDSCHHRLA_1, dist_name=_NRDRB16name, parameter='nrPdschHRLaDN'),
    dict(value=_NRPUSCHHRLA_1, dist_name=_NRDRB16name, parameter='nrPuschHRLaDN'),
    dict(value='30000', dist_name=_NRDRB16name, parameter='maxDataRateGbrDl'),
    dict(value='30000', dist_name=_NRDRB16name, parameter='maxDataRateGbrUl'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_recover_gnb1_K_019 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actRel16DmrsForPusch'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlDftSOfdm'),
    dict(value='1000', dist_name=_NRDRB16name, parameter='maxDataRateGbrDl'),
    dict(value='1000', dist_name=_NRDRB16name, parameter='maxDataRateGbrUl'),
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]
PARAM_8246_recover_gnb1_K_019_24R2 = [
    dict(value='false', dist_name=_NRCELLname, parameter='actRel16DmrsForPusch'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlDftSOfdm'),
    dict(value='1000', dist_name=_NRDRB16name, parameter='maxDataRateGbrDl'),
    dict(value='1000', dist_name=_NRDRB16name, parameter='maxDataRateGbrUl'),
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_recover_delete_gnb1_K_019 = [
    dict(dist_name=_NRDRB16name, parameter='nrPdcchHRLaDN'),
    dict(dist_name=_NRDRB16name, parameter='nrPdschHRLaDN'),
    dict(dist_name=_NRDRB16name, parameter='nrPuschHRLaDN'),
]

PARAM_8246_gnb1_L_006_online = [
    dict(value='false', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='false', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='false', dist_name=_NRBTSname, parameter='actNormVCFallbackEnh'),
    dict(value=['disabled'], dist_name=_NRBTSname, parameter='actVoiceFallbackDuringHOPrep'),
    # {'dist_name': _NRBTSname, 'parameter': 'actVoiceFallbackDuringHOPrep', 'value':
    #     ['disabled']},
]

PARAM_8246_delete_gnb1_L_006 = [
    dict(dist_name=_NRDRB12name, p_name='nrPdcchHRLaDN'),
    dict(dist_name=_NRDRB12name, p_name='nrPdschHRLaDN'),
    dict(dist_name=_NRDRB12name, p_name='nrPuschHRLaDN')

]

PARAM_8246_gnb1_L_006 = [
    # dict(value='false', dist_name=_NRBTSname, p_name='actRedirect'),
    # dict(value='false', dist_name=_NRBTSname, p_name='actNormVCFallback'),
    # dict(value='false', dist_name=_NRBTSname, p_name='actNormVCFallbackEnh'),
    dict(value='false', dist_name=_NRCELLname, p_name='actRel16DmrsForPusch'),
    dict(value='true', dist_name=_NRBTSname, p_name='actDrbPreemption'),
    dict(value='20', dist_name=_NRBTSname, p_name='maxNumOfPreemptions'),
    dict(value='120', dist_name=_NRBTSDUname, p_name='numOfDrbsReservForTempUse'),

    dict(value='30000', dist_name=_NRDRB16name, p_name='maxDataRateGbrDl'),
    dict(value='30000', dist_name=_NRDRB16name, p_name='maxDataRateGbrUl'),
    dict(value='true', dist_name=_NRCELL2name, p_name='actNonVoNRGbrService'),
    dict(value='GBRService', dist_name=_NRCELL2name, p_name='actGBRAdmissionControl'),
    dict(value='10', dist_name=_NRCELL2name, p_name='maxGBRTrafficLimit'),

    dict(value='static', dist_name=_BWP_PROFILE_54, p_name='alSelection'),
    dict(value='AL4', dist_name=_BWP_PROFILE_54, p_name='dciDedicatedAggregationLevelHR'),

    dict(value=f'{_NRBTSname}/NRPDCCHHRLA-1', dist_name=_NRDRB16name, p_name='nrPdcchHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPDSCHHRLA-1', dist_name=_NRDRB16name, p_name='nrPdschHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPUSCHHRLA-1', dist_name=_NRDRB16name, p_name='nrPuschHRLaDN'),

    dict(value='true', dist_name=_NRCELL2name, p_name='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL2name, p_name='actDlMuMimo'),
    # dict(value=['none'], dist_name=_NRDU, parameter='carrierAggregationSupportList'),
    dict(value='false', dist_name=_NRCELLname, p_name='actUlDftSOfdm'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcs'),
]

LIST_TO_MODIFY_GNB1_L006 = [
    dict(dist_name=_NRBTSname, list_name='cipherPrefL',
         elements=[dict(p_name='nea0', value='9', index=0),

                   dict(p_name='nea1_128', value='0', index=0),

                   dict(p_name='nea2_128', value='0', index=0),

                   dict(p_name='nea3_128', value='0', index=0)]),

    dict(dist_name=_NRBTSname, list_name='integrityProtPrefL',
         elements=[dict(p_name='nia0', value='0', index=0),

                   dict(p_name='nia1_128', value='9', index=0),

                   dict(p_name='nia2_128', value='0', index=0),

                   dict(p_name='nia3_128', value='0', index=0)]),
]

Trunk_PARAMETERS_TO_DELETE_GNB1_L006 = [
    dict(dist_name=_NRCELL2name, list_name='cellBwpList'),
    dict(dist_name=_NRDRB12name, p_name='nrPdcchHRLaDN'),
    dict(dist_name=_NRDRB12name, p_name='nrPdschHRLaDN'),
    dict(dist_name=_NRDRB12name, p_name='nrPuschHRLaDN')
]

Trunk_PARAM_8246_gnb1_L_006 = [
    # dict(value='false', dist_name=_NRBTSname, p_name='actRedirect'),
    # dict(value='false', dist_name=_NRBTSname, p_name='actNormVCFallback'),
    # dict(value='false', dist_name=_NRBTSname, p_name='actNormVCFallbackEnh'),
    dict(value='false', dist_name=_NRCELLname, p_name='actRel16DmrsForPusch'),
    dict(value='true', dist_name=_NRBTSname, p_name='actDrbPreemption'),
    dict(value='20', dist_name=_NRBTSname, p_name='maxNumOfPreemptions'),
    dict(value='120', dist_name=_NRBTSDUname, p_name='numOfDrbsReservForTempUse'),

    dict(value='30000', dist_name=_NRDRB16name, p_name='maxDataRateGbrDl'),
    dict(value='30000', dist_name=_NRDRB16name, p_name='maxDataRateGbrUl'),
    dict(value='true', dist_name=_NRCELL2name, p_name='actNonVoNRGbrService'),
    dict(value='GBRService', dist_name=_NRCELL2name, p_name='actGBRAdmissionControl'),
    dict(value='10', dist_name=_NRCELL2name, p_name='maxGBRTrafficLimit'),

    dict(value='static', dist_name=_BWP_PROFILE_54, p_name='alSelection'),
    dict(value='AL4', dist_name=_BWP_PROFILE_54, p_name='dciDedicatedAggregationLevelHR'),

    dict(value=f'{_NRBTSname}/NRPDCCHHRLA-1', dist_name=_NRDRB16name, p_name='nrPdcchHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPDSCHHRLA-1', dist_name=_NRDRB16name, p_name='nrPdschHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPUSCHHRLA-1', dist_name=_NRDRB16name, p_name='nrPuschHRLaDN'),

    dict(value='true', dist_name=_NRCELL2name, p_name='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL2name, p_name='actDlMuMimo'),
    # dict(value=['none'], dist_name=_NRDU, parameter='carrierAggregationSupportList'),
    dict(value='false', dist_name=_NRCELLname, p_name='actUlDftSOfdm'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcs'),
    dict(value='false', dist_name=_NRCELL2name, p_name='actPowerSavingBWP'),
    dict(value='false', dist_name=_NRCELL2name, p_name='actInitialBWPFlexibility'),
]

Trunk_LIST_TO_ADD_GNB1_L006 = [
    dict(
        dist_name=_NRCELL2name,
        list_name='cellBwpList',
        elements=dict(
            bwpDN=_BWP_PROFILE_5,
            cellBwpId='0',
            pdcchResourcePreference='peakRate',
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false')
    ),
    dict(
        dist_name=_NRCELL2name,
        list_name='cellBwpList',
        elements=dict(
            bwpDN=_BWP_PROFILE_054,
            cellBwpId='1',
            pdcchResourcePreference='peakRate',
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='true',
            actUpperThrAckNackHrFiltering='true')
    ),
]

Trunk_LIST_TO_MODIFY_GNB1_L006 = [
    dict(dist_name=_NRBTSname, list_name='cipherPrefL',
         elements=[dict(p_name='nea0', value='9', index=0),

                   dict(p_name='nea1_128', value='0', index=0),

                   dict(p_name='nea2_128', value='0', index=0),

                   dict(p_name='nea3_128', value='0', index=0)]),

    dict(dist_name=_NRBTSname, list_name='integrityProtPrefL',
         elements=[dict(p_name='nia0', value='0', index=0),

                   dict(p_name='nia1_128', value='9', index=0),

                   dict(p_name='nia2_128', value='0', index=0),

                   dict(p_name='nia3_128', value='0', index=0)]),
]

PARAM_8246_recover_gnb1_L_006 = [
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    # dict(value='true', dist_name=_NRBTSname, p_name='actNormVCFallbackEnh'),
    dict(value=['disabled'], dist_name=_NRBTSname, parameter='actVoiceFallbackDuringHOPrep'),
    dict(value='false', dist_name=_NRBTSname, parameter='actDrbPreemption'),
    dict(value='1000', dist_name=_NRDRB16name, parameter='maxDataRateGbrDl'),
    dict(value='1000', dist_name=_NRDRB16name, parameter='maxDataRateGbrUl'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actNonVoNRGbrService'),
    dict(value='GBRService', dist_name=_NRCELL2name, parameter='actGBRAdmissionControl'),

    dict(value='dynamic', dist_name=_BWP_PROFILE_54, parameter='alSelection'),
    dict(value='AL4', dist_name=_BWP_PROFILE_54, parameter='dciDedicatedAggregationLevelHR'),

    dict(value=f'{_NRBTSname}/NRPDCCHHRLA-1', dist_name=_NRDRB12name, parameter='nrPdcchHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPDSCHHRLA-1', dist_name=_NRDRB12name, parameter='nrPdschHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPUSCHHRLA-1', dist_name=_NRDRB12name, parameter='nrPuschHRLaDN'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDlMuMimo'),
    # dict(value=['none'], dist_name=_NRDU, parameter='carrierAggregationSupportList'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlDftSOfdm'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcs'),
]

PARAM_8246_recover_delete_gnb1_L_006 = [
    dict(value='20', dist_name=_NRBTSname, parameter='maxNumOfPreemptions'),
    dict(value='120', dist_name=_NRBTSDUname, parameter='numOfDrbsReservForTempUse'),
    dict(value='10', dist_name=_NRCELL2name, parameter='maxGBRTrafficLimit'),
    dict(value=f'{_NRBTSname}/NRPDCCHHRLA-1', dist_name=_NRDRB16name, parameter='nrPdcchHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPDSCHHRLA-1', dist_name=_NRDRB16name, parameter='nrPdschHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPUSCHHRLA-1', dist_name=_NRDRB16name, parameter='nrPuschHRLaDN')

]

LIST_TO_ADD_GNB1_L005 = [
    dict(
        dist_name=_NRCELL2name,
        list_name='cellBwpList',
        elements=dict(
            bwpDN=_BWP_PROFILE_087,
            cellBwpId='0',
            pdcchResourcePreference='peakRate',
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false')
    ),
    dict(
        dist_name=_NRCELL2name,
        list_name='cellBwpList',
        elements=dict(
            bwpDN=_BWP_PROFILE_088,
            cellBwpId='1',
            pdcchResourcePreference='peakRate',
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='true',
            actUpperThrAckNackHrFiltering='true')
    ),
    dict(
        dist_name=_NRCELL2name,
        list_name='cellBwpList',
        elements=dict(
            bwpDN=_BWP_PROFILE_089,
            cellBwpId='2',
            pdcchResourcePreference='peakRate',
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='true',
            actUpperThrAckNackHrFiltering='true')
    )
]

LIST_TO_MODIFY_GNB1_L005 = [
    dict(dist_name=_NRBTSname, list_name='cipherPrefL',
         elements=[dict(p_name='nea0', value='9', index=0),

                   dict(p_name='nea1_128', value='0', index=0),

                   dict(p_name='nea2_128', value='0', index=0),

                   dict(p_name='nea3_128', value='0', index=0)]),

    dict(dist_name=_NRBTSname, list_name='integrityProtPrefL',
         elements=[dict(p_name='nia0', value='0', index=0),

                   dict(p_name='nia1_128', value='9', index=0),

                   dict(p_name='nia2_128', value='0', index=0),

                   dict(p_name='nia3_128', value='0', index=0)]),

    # dict(dist_name=_NRBTSname, list_name='carrierAggregationSupportList',
    #      elements=[dict(value='0', index=0)])
]

PARAMETERS_TO_DELETE_GNB1_L005 = [
    dict(dist_name=_NRCELL2name, list_name='cellBwpList')
]

PARAM_8246_gnb1_L_005 = [
    dict(value='false', dist_name=_NRCELLname, p_name='actRel16DmrsForPusch'),
    dict(value='true', dist_name=_NRCELL2name, p_name='actPowerSavingBWP'),
    # dict(value=[dict(bwpDN=_BWP_PROFILE_087, cellBwpId='0'),
    #             dict(bwpDN=_BWP_PROFILE_087, cellBwpId='1')],
    #      dist_name=_NRCELL2name, parameter='cellBwpList'),
    dict(value='46', dist_name=_NRCELL2name, p_name='msg1FrequencyStart'),
    dict(value='true', dist_name=_NRCELL2name, p_name='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL2name, p_name='actDlMuMimo'),
    # dict(value='false', dist_name=_NRCELLname, p_name='actUlDftSOfdm'),
    dict(value='true', dist_name=_NRCELL2name, p_name='actDlOptMcsSelection'),
    dict(value='true', dist_name=_NRCELL2name, p_name='actUlOptMcsSelection'),
]

LIST_TO_MODIFY_GNB1_L005_348 = [
    dict(dist_name=_NRBTSname, list_name='cipherPrefL',
         elements=[dict(p_name='nea0', value='9', index=0),

                   dict(p_name='nea1_128', value='0', index=0),

                   dict(p_name='nea2_128', value='0', index=0),

                   dict(p_name='nea3_128', value='0', index=0)]),

    dict(dist_name=_NRBTSname, list_name='integrityProtPrefL',
         elements=[dict(p_name='nia0', value='0', index=0),

                   dict(p_name='nia1_128', value='9', index=0),

                   dict(p_name='nia2_128', value='0', index=0),

                   dict(p_name='nia3_128', value='0', index=0)]),
]

PARAM_8246_gnb1_L_005_348 = [
    dict(value='Locked', dist_name=_NRCELL701name, p_name='administrativeState'),
    # dict(value='false', dist_name=_NRCELL700name, p_name='actUl256Qam'),
    # dict(value='false', dist_name=_NRCELL700name, p_name='actDl256Qam'),
    # dict(value='false', dist_name=_NRCELL700name, p_name='actDlLaDynBlerTarget'),
    # dict(value='false', dist_name=_NRCELL700name, p_name='actUlCgType2'),
    # dict(value='false', dist_name=_NRCELL700name, p_name='actUlDftSOfdm'),
    # dict(value='false', dist_name=_NRCELL700name, p_name='actRel16DmrsForPucchF3'),
    # dict(value='false', dist_name=_NRCELL700name, p_name='actRel16DmrsForPusch'),
    # dict(value='false', dist_name=_NRCELL700name, p_name='actUlTransPreEnhHo'),
]

PARAM_8246_gnb1_L_010 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actAdaptiveUlBlerTarget'),
    dict(value=[dict(ullaBlerTargetLowSinr='20', ullaBlerTargetMcs0='15', ullaBlerTargetSinrThreshold='100')],
         dist_name=_NRCELLname, parameter='adaptiveUlBlerTarget'),
    dict(value='10000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutageTbsThresh'),
    dict(value='20000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverTbsThresh'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDlMuMimo'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUlDftSOfdm')
]

PARAM_8246_recover_gnb1_L_010 = [
    dict(value='false', dist_name=_NRCELLname, parameter='actAdaptiveUlBlerTarget'),
    dict(value=[dict(ullaBlerTargetLowSinr='20', ullaBlerTargetMcs0='10', ullaBlerTargetSinrThreshold='100')],
         dist_name=_NRCELLname, parameter='adaptiveUlBlerTarget'),
    dict(value='500', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutageTbsThresh'),
    dict(value='4000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverTbsThresh'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDlMuMimo'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUlDftSOfdm')
]

PARAM_8246_gnb1_J_002 = [
    dict(value='static', dist_name=_BWP_PROFILE_54, parameter='alSelection'),
    dict(value='60', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutagePercentage'),
    dict(value='8000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutageTbsThresh'),
    dict(value='30', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverPeriod'),
    dict(value='50', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverPercentage'),
    dict(value='12000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverTbsThresh'),
    dict(value=[dict(ulTransPrecodeOffSinrThresh='200', ulTransPrecodeOffSinrThrRedCap='200',
                     ulTransPrecodeOnSinrThresh='100', ulTransPrecodeOnSinrThrRedCap='-100',
                     ulTransPrecodePi2Bpsk='false', ulTransPrePi2BpskPwrBoost='false')],
         dist_name=_NRCELLname, parameter='ulTransPrecodeCtl'),
    dict(value=f'{_NRBTSname}/NRPDCCHHRLA-1', dist_name=_NRDRB13name, parameter='nrPdcchHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPDSCHHRLA-1', dist_name=_NRDRB13name, parameter='nrPdschHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPUSCHHRLA-1', dist_name=_NRDRB13name, parameter='nrPuschHRLaDN'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlDftSOfdm'),

    dict(value='false', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),

    dict(value='false', dist_name=_NRCELL2name, parameter='actDlMuMimo'),
    # dict(value=['none'], dist_name=_NRDU, parameter='carrierAggregationSupportList'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_delete_gnb1_J_002 = [
    dict(value=f'{_NRBTSname}/NRPDCCHHRLA-1', dist_name=_NRDRB12name, parameter='nrPdcchHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPDSCHHRLA-1', dist_name=_NRDRB12name, parameter='nrPdschHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPUSCHHRLA-1', dist_name=_NRDRB12name, parameter='nrPuschHRLaDN')

]

PARAM_8246_recover_gnb1_J_002 = [
    dict(value='dynamic', dist_name=_BWP_PROFILE_54, parameter='alSelection'),
    dict(value='50', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutagePercentage'),
    dict(value='500', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutageTbsThresh'),
    dict(value='30', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverPeriod'),
    dict(value='60', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverPercentage'),
    dict(value='4000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverTbsThresh'),
    dict(value=[dict(ulTransPrecodeOffSinrThresh='200', ulTransPrecodeOffSinrThrRedCap='200',
                     ulTransPrecodeOnSinrThresh='-100', ulTransPrecodeOnSinrThrRedCap='-100',
                     ulTransPrecodePi2Bpsk='false', ulTransPrePi2BpskPwrBoost='false')],
         dist_name=_NRCELLname, parameter='ulTransPrecodeCtl'),
    dict(value=f'{_NRBTSname}/NRPDCCHHRLA-1', dist_name=_NRDRB12name, parameter='nrPdcchHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPDSCHHRLA-1', dist_name=_NRDRB12name, parameter='nrPdschHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPUSCHHRLA-1', dist_name=_NRDRB12name, parameter='nrPuschHRLaDN'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlDftSOfdm'),

    dict(value='true', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDlMuMimo'),

    # dict(value=['none'], dist_name=_NRDU, parameter='carrierAggregationSupportList'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_recover_delete_gnb1_J_002 = [
    dict(value=f'{_NRBTSname}/NRPDCCHHRLA-1', dist_name=_NRDRB13name, parameter='nrPdcchHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPDSCHHRLA-1', dist_name=_NRDRB13name, parameter='nrPdschHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPUSCHHRLA-1', dist_name=_NRDRB13name, parameter='nrPuschHRLaDN')

]

PARAM_8246_gnb1_J_003_382 = [
    # dict(value='true', dist_name=_NRCELLname, parameter='actAdaptiveUlBlerTarget'),
    dict(value='static', dist_name=_BWP_PROFILE_54, parameter='alSelection'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlDftSOfdm'),
    dict(value='1000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutageTbsThresh64qam'),
    dict(value='7000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverTbsThresh64qam'),
    dict(value=[dict(ulTransPrecodeOffSinrThresh='35', ulTransPrecodeOffSinrThrRedCap='35',
                     ulTransPrecodeOnSinrThresh='15', ulTransPrecodeOnSinrThrRedCap='15',
                     ulTransPrecodePi2Bpsk='false', ulTransPrePi2BpskPwrBoost='false')],
         dist_name=_NRCELLname, parameter='ulTransPrecodeCtl'),

    dict(value='false', dist_name=_NRCELL2name, parameter='actDlMuMimo'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_gnb1_J_003_367 = [
    # dict(value='true', dist_name=_NRCELLname, parameter='actAdaptiveUlBlerTarget'),
    dict(value='static', dist_name=_BWP_PROFILE_54, parameter='alSelection'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlDftSOfdm'),
    dict(value='3000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutageTbsThresh64qam'),
    dict(value='18000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverTbsThresh64qam'),
    dict(value=[dict(ulTransPrecodeOffSinrThresh='35', ulTransPrecodeOffSinrThrRedCap='35',
                     ulTransPrecodeOnSinrThresh='15', ulTransPrecodeOnSinrThrRedCap='15',
                     ulTransPrecodePi2Bpsk='false', ulTransPrePi2BpskPwrBoost='false')],
         dist_name=_NRCELLname, parameter='ulTransPrecodeCtl'),

    dict(value='false', dist_name=_NRCELL2name, parameter='actDlMuMimo'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_gnb1_J_003_343 = [
    # dict(value='true', dist_name=_NRCELLname, parameter='actAdaptiveUlBlerTarget'),
    dict(value='static', dist_name=_BWP_PROFILE_54, parameter='alSelection'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlDftSOfdm'),
    dict(value='1000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutageTbsThresh64qam'),
    dict(value='7000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverTbsThresh64qam'),
    dict(value=[dict(ulTransPrecodeOffSinrThresh='35', ulTransPrecodeOffSinrThrRedCap='35',
                     ulTransPrecodeOnSinrThresh='15', ulTransPrecodeOnSinrThrRedCap='15',
                     ulTransPrecodePi2Bpsk='false', ulTransPrePi2BpskPwrBoost='false')],
         dist_name=_NRCELLname, parameter='ulTransPrecodeCtl'),

    dict(value='false', dist_name=_NRCELL2name, parameter='actDlMuMimo'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_recover_gnb1_J_003 = [
    # dict(value='false', dist_name=_NRCELLname, parameter='actAdaptiveUlBlerTarget'),
    dict(value='dynamic', dist_name=_BWP_PROFILE_54, parameter='alSelection'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlDftSOfdm'),
    dict(value='1000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutageTbsThresh64qam'),
    dict(value='7000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverTbsThresh64qam'),
    dict(value=[dict(ulTransPrecodeOffSinrThresh='35', ulTransPrecodeOffSinrThrRedCap='35',
                     ulTransPrecodeOnSinrThresh='15', ulTransPrecodeOnSinrThrRedCap='15',
                     ulTransPrecodePi2Bpsk='false', ulTransPrePi2BpskPwrBoost='false')],
         dist_name=_NRCELLname, parameter='ulTransPrecodeCtl'),

    dict(value='false', dist_name=_NRCELL2name, parameter='actDlMuMimo'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_gnb1_J_005 = [
    # dict(value='true', dist_name=_NRCELLname, parameter='actAdaptiveUlBlerTarget'),
    dict(value='Locked', dist_name=_SERVEDAMF, parameter='administrativeState'),
    dict(value='static', dist_name=_BWP_PROFILE_54, parameter='alSelection'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlDftSOfdm'),
    dict(value='1000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutageTbsThresh64qam'),
    dict(value='7000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverTbsThresh64qam'),
    dict(value=[dict(ulTransPrecodeOffSinrThresh='100', ulTransPrecodeOffSinrThrRedCap='200',
                     ulTransPrecodeOnSinrThresh='50', ulTransPrecodeOnSinrThrRedCap='-100',
                     ulTransPrecodePi2Bpsk='false', ulTransPrePi2BpskPwrBoost='false')],
         dist_name=_NRCELLname, parameter='ulTransPrecodeCtl'),
    dict(value=f'{_NRBTSname}/NRPDCCHHRLA-1', dist_name=_NRDRB4name, parameter='nrPdcchHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPDSCHHRLA-1', dist_name=_NRDRB4name, parameter='nrPdschHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPUSCHHRLA-1', dist_name=_NRDRB4name, parameter='nrPuschHRLaDN'),

    dict(value='false', dist_name=_NRCELL2name, parameter='actDlMuMimo'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_recover_gnb1_J_005 = [
    # dict(value='false', dist_name=_NRCELLname, parameter='actAdaptiveUlBlerTarget'),
    dict(value='Unlocked', dist_name=_SERVEDAMF, parameter='administrativeState'),
    dict(value='dynamic', dist_name=_BWP_PROFILE_54, parameter='alSelection'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlDftSOfdm'),
    dict(value='1000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutageTbsThresh64qam'),
    dict(value='7000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverTbsThresh64qam'),
    dict(value=[dict(ulTransPrecodeOffSinrThresh='200', ulTransPrecodeOffSinrThrRedCap='200',
                     ulTransPrecodeOnSinrThresh='-100', ulTransPrecodeOnSinrThrRedCap='-100',
                     ulTransPrecodePi2Bpsk='false', ulTransPrePi2BpskPwrBoost='false')],
         dist_name=_NRCELLname, parameter='ulTransPrecodeCtl'),
    dict(value=f'{_NRBTSname}/NRPDCCHHRLA-1', dist_name=_NRDRB12name, parameter='nrPdcchHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPDSCHHRLA-1', dist_name=_NRDRB12name, parameter='nrPdschHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPUSCHHRLA-1', dist_name=_NRDRB12name, parameter='nrPuschHRLaDN'),

    dict(value='false', dist_name=_NRCELL2name, parameter='actDlMuMimo'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_delete_gnb1_J_005 = [
    dict(value=f'{_NRBTSname}/NRPDCCHHRLA-1', dist_name=_NRDRB12name, parameter='nrPdcchHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPDSCHHRLA-1', dist_name=_NRDRB12name, parameter='nrPdschHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPUSCHHRLA-1', dist_name=_NRDRB12name, parameter='nrPuschHRLaDN')

]

PARAM_8246_recover_delete_gnb1_J_005 = [
    dict(value=f'{_NRBTSname}/NRPDCCHHRLA-1', dist_name=_NRDRB4name, parameter='nrPdcchHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPDSCHHRLA-1', dist_name=_NRDRB4name, parameter='nrPdschHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPUSCHHRLA-1', dist_name=_NRDRB4name, parameter='nrPuschHRLaDN')

]

PARAM_8246_enb1_J_005 = [
    dict(value=_MME_IP, dist_name=_LNMME_0, parameter='ipAddrPrim'),
]

PARAM_8246_recover_enb1_J_005 = [
    dict(value=_initial_MME_IP, dist_name=_LNMME_0, parameter='ipAddrPrim'),
]

PARAM_8246_gnb1_J_006 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actUlCgType2'),
    dict(value=f'{_NRBTSname}/NRULCG_PROFILE-1', dist_name=_NRDRB12name, parameter='nrDrbUlCgDN'),
    # dict(value=f'{_NRBTSname}/NRPDCCHHRLA-1', dist_name=_NRDRB10name, parameter='nrPdcchHRLaDN'),
    # dict(value=f'{_NRBTSname}/NRPDSCHHRLA-1', dist_name=_NRDRB10name, parameter='nrPdschHRLaDN'),
    # dict(value=f'{_NRBTSname}/NRPUSCHHRLA-1', dist_name=_NRDRB10name, parameter='nrPuschHRLaDN'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_recover_gnb1_J_006 = [
    dict(value='false', dist_name=_NRCELLname, parameter='actUlCgType2'),
    # dict(value=f'{_NRBTSname}/NRPDCCHHRLA-1', dist_name=_NRDRB12name, parameter='nrPdcchHRLaDN'),
    # dict(value=f'{_NRBTSname}/NRPDSCHHRLA-1', dist_name=_NRDRB12name, parameter='nrPdschHRLaDN'),
    # dict(value=f'{_NRBTSname}/NRPUSCHHRLA-1', dist_name=_NRDRB12name, parameter='nrPuschHRLaDN'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

# PARAM_8246_delete_gnb1_J_006 = [
#     dict(value=f'{_NRBTSname}/NRPDCCHHRLA-1', dist_name=_NRDRB12name, parameter='nrPdcchHRLaDN'),
#     dict(value=f'{_NRBTSname}/NRPDSCHHRLA-1', dist_name=_NRDRB12name, parameter='nrPdschHRLaDN'),
#     dict(value=f'{_NRBTSname}/NRPUSCHHRLA-1', dist_name=_NRDRB12name, parameter='nrPuschHRLaDN')
#
# ]


PARAM_8246_recover_delete_gnb1_J_006 = [
    dict(value=f'{_NRBTSname}/NRULCG_PROFILE-1', dist_name=_NRDRB12name, parameter='nrDrbUlCgDN'),
    # dict(value=f'{_NRBTSname}/NRPDCCHHRLA-1', dist_name=_NRDRB10name, parameter='nrPdcchHRLaDN'),
    # dict(value=f'{_NRBTSname}/NRPDSCHHRLA-1', dist_name=_NRDRB10name, parameter='nrPdschHRLaDN'),
    # dict(value=f'{_NRBTSname}/NRPUSCHHRLA-1', dist_name=_NRDRB10name, parameter='nrPuschHRLaDN')

]

PARAM_8246_gnb1_J_009 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actUlCgType2'),
    dict(value=f'{_NRBTSname}/NRULCG_PROFILE-1', dist_name=_NRDRB12name, parameter='nrDrbUlCgDN'),
    dict(value=f'{_NRBTSname}/NRPDCCHHRLA-1', dist_name=_NRDRB10name, parameter='nrPdcchHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPDSCHHRLA-1', dist_name=_NRDRB10name, parameter='nrPdschHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPUSCHHRLA-1', dist_name=_NRDRB10name, parameter='nrPuschHRLaDN'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_recover_gnb1_J_009 = [
    dict(value='false', dist_name=_NRCELLname, parameter='actUlCgType2'),
    dict(value=f'{_NRBTSname}/NRPDCCHHRLA-1', dist_name=_NRDRB12name, parameter='nrPdcchHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPDSCHHRLA-1', dist_name=_NRDRB12name, parameter='nrPdschHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPUSCHHRLA-1', dist_name=_NRDRB12name, parameter='nrPuschHRLaDN'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_delete_gnb1_J_009 = [
    dict(value=f'{_NRBTSname}/NRPDCCHHRLA-1', dist_name=_NRDRB12name, parameter='nrPdcchHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPDSCHHRLA-1', dist_name=_NRDRB12name, parameter='nrPdschHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPUSCHHRLA-1', dist_name=_NRDRB12name, parameter='nrPuschHRLaDN')

]

PARAM_8246_recover_delete_gnb1_J_009 = [
    dict(value=f'{_NRBTSname}/NRULCG_PROFILE-1', dist_name=_NRDRB12name, parameter='nrDrbUlCgDN'),
    dict(value=f'{_NRBTSname}/NRPDCCHHRLA-1', dist_name=_NRDRB10name, parameter='nrPdcchHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPDSCHHRLA-1', dist_name=_NRDRB10name, parameter='nrPdschHRLaDN'),
    dict(value=f'{_NRBTSname}/NRPUSCHHRLA-1', dist_name=_NRDRB10name, parameter='nrPuschHRLaDN')

]

PARAM_8246_gnb1_Q_002 = [
    dict(value='false', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='10', dist_name=_NRBTSname, parameter='srbInactivityTimerSA'),
    dict(value='10', dist_name=_NRBTSname, parameter='drbInactivityTimerSA'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_recover_gnb1_Q_002 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='60', dist_name=_NRBTSname, parameter='srbInactivityTimerSA'),
    dict(value='600', dist_name=_NRBTSname, parameter='drbInactivityTimerSA'),
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_gnb1_R_005 = [
    dict(value='false', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDtxOptimizedScheduler'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDtxOptimizedScheduler'),
    dict(value='false', dist_name=_NRCELLname, parameter='actEnhDtxOptimizedScheduler'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actEnhDtxOptimizedScheduler'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='10000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutageTbsThresh'),
    dict(value='20000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverTbsThresh'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_recover_gnb1_R_005 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDtxOptimizedScheduler'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDtxOptimizedScheduler'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhDtxOptimizedScheduler'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actEnhDtxOptimizedScheduler'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='500', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutageTbsThresh'),
    dict(value='4000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverTbsThresh'),
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_gnb1_R_007 = [
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_recover_gnb1_R_007 = [
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_gnb1_I_006_1 = [
    dict(value=[dict(dllaCqiOffsetHR='0', dllaDeltaCqiMaxHR='150', dllaDeltaCqiMinHR='-150',
                     dllaDeltaCqiStepdownHR='500', dllaIniDeltaCqiHR='-30', dllaIniMcsHR='3',
                     dllaMcsMax64qamLowSERANK1HR='28',
                     dllaMcsMax64qamLowSERANK2HR='28', dllaMcsMax64qamLowSERANK3HR='28',
                     dllaMcsMax64qamLowSERANK4HR='28',
                     dllaMcsMax64qamRANK1HR='15', dllaMcsMax64qamRANK2HR='15', dllaMcsMax64qamRANK3HR='28',
                     dllaMcsMax64qamRANK4HR='28')],
         dist_name=_NRCELL2name, parameter='pdschHrLaConfig'),
    dict(value=[dict(iniDeltaSinrHR='-50', ullaDeltaSinrMaxHR='150', ullaDeltaSinrMinHR='-300',
                     ullaDeltaSinrStepdownHR='2000', ullaIniMcsHR='0', ullaMcsMax64qamLowSERANK1HR='28',
                     ullaMcsMax64qamLowSERANK2HR='28', ullaMcsMax64qamRANK1HR='15', ullaMcsMax64qamRANK2HR='15',
                     ullaSinrOffsetHR='0', )],
         dist_name=_NRCELL2name, parameter='puschHrLaConfig'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_gnb1_I_006_2 = [
    dict(value=[dict(dllaCqiOffsetHR='0', dllaDeltaCqiMaxHR='150', dllaDeltaCqiMinHR='-150',
                     dllaDeltaCqiStepdownHR='500', dllaIniDeltaCqiHR='-30', dllaIniMcsHR='3',
                     dllaMcsMax64qamLowSERANK1HR='28',
                     dllaMcsMax64qamLowSERANK2HR='28', dllaMcsMax64qamLowSERANK3HR='28',
                     dllaMcsMax64qamLowSERANK4HR='28',
                     dllaMcsMax64qamRANK1HR='28', dllaMcsMax64qamRANK2HR='28', dllaMcsMax64qamRANK3HR='28',
                     dllaMcsMax64qamRANK4HR='28')],
         dist_name=_NRCELL2name, parameter='pdschHrLaConfig'),
]

PARAM_8246_gnb1_I_006_3 = [
    dict(value=[dict(iniDeltaSinrHR='-50', ullaDeltaSinrMaxHR='150', ullaDeltaSinrMinHR='-300',
                     ullaDeltaSinrStepdownHR='2000', ullaIniMcsHR='0', ullaMcsMax64qamLowSERANK1HR='28',
                     ullaMcsMax64qamLowSERANK2HR='28', ullaMcsMax64qamRANK1HR='28', ullaMcsMax64qamRANK2HR='28',
                     ullaSinrOffsetHR='0', )],
         dist_name=_NRCELL2name, parameter='puschHrLaConfig'),
]

PARAM_8246_recover_gnb1_I_006 = [
    dict(value=[dict(dllaCqiOffsetHR='0', dllaDeltaCqiMaxHR='150', dllaDeltaCqiMinHR='-150',
                     dllaDeltaCqiStepdownHR='500', dllaIniDeltaCqiHR='-30', dllaIniMcsHR='3',
                     dllaMcsMax64qamLowSERANK1HR='28',
                     dllaMcsMax64qamLowSERANK2HR='28', dllaMcsMax64qamLowSERANK3HR='28',
                     dllaMcsMax64qamLowSERANK4HR='28',
                     dllaMcsMax64qamRANK1HR='28', dllaMcsMax64qamRANK2HR='28', dllaMcsMax64qamRANK3HR='28',
                     dllaMcsMax64qamRANK4HR='28')],
         dist_name=_NRCELL2name, parameter='pdschHrLaConfig'),
    dict(value=[dict(iniDeltaSinrHR='-50', ullaDeltaSinrMaxHR='150', ullaDeltaSinrMinHR='-300',
                     ullaDeltaSinrStepdownHR='2000', ullaIniMcsHR='0', ullaMcsMax64qamLowSERANK1HR='28',
                     ullaMcsMax64qamLowSERANK2HR='28', ullaMcsMax64qamRANK1HR='28', ullaMcsMax64qamRANK2HR='28',
                     ullaSinrOffsetHR='0', )],
         dist_name=_NRCELL2name, parameter='puschHrLaConfig'),
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_gnb1_PR856608_348 = [
    dict(value='Locked', dist_name=_NRCELL701name, parameter='administrativeState'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actDlSrsSubbandBm'),
    dict(value='true', dist_name=_NRCELL701name, parameter='actDlSrsSubbandBm'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actHighSpeedCell'),
    dict(value='false', dist_name=_NRCELL701name, parameter='actHighSpeedCell'),
    dict(value='No additional DMRS', dist_name=_NRCELL700name, parameter='dlDMRSAdditionalPosition'),
    dict(value='No additional DMRS', dist_name=_NRCELL701name, parameter='dlDMRSAdditionalPosition'),
    dict(value='No additional DMRS', dist_name=_NRCELL700name, parameter='ulDMRSAdditionalPosition'),
    dict(value='No additional DMRS', dist_name=_NRCELL701name, parameter='ulDMRSAdditionalPosition'),
    dict(value='RestrictedTypeA', dist_name=_NRCELL700name, parameter='prachSequenceType'),
    dict(value='RestrictedTypeA', dist_name=_NRCELL701name, parameter='prachSequenceType'),
    dict(value=[dict(channelStabilityHysteresis='10', channelStabilityThreshold='30', dlBufferHysteresis='30000',
                     dlBufferThreshold='0', enableSbSrsVolatilityCheck='false', maxWbSbSwitch='10',
                     numWbSrsConfigSample='10', numWbSrsReleaseSample='10', prbRatioHysteresis='15',
                     prbRatioThreshold='20', prbSampleHighLowPercentage='60', rankHysteresis='1', rankThreshold='3',
                     rlqBadPercentage='50', rlqGoodPercentage='20', seHysteresis='50', seThreshold='41',
                     sortingMetric='DL Spectral Efficiency', wbSrsConfigProhibitTimer='100', wbSrsPowerHysteresis='50',
                     wbSrsPowerThreshold='-1010', wbSrsReleaseProhibitTimer='1000')], dist_name=_NRCELL700name,
         parameter='wbSbSrsSwitch'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_recover_gnb1_PR856608_348 = [
    dict(value='Unlocked', dist_name=_NRCELL701name, parameter='administrativeState'),
    dict(value='false', dist_name=_NRCELL700name, parameter='actDlSrsSubbandBm'),
    dict(value='false', dist_name=_NRCELL701name, parameter='actDlSrsSubbandBm'),
    dict(value='true', dist_name=_NRCELL700name, parameter='actHighSpeedCell'),
    dict(value='true', dist_name=_NRCELL701name, parameter='actHighSpeedCell'),
    dict(value='Two additional DMRS', dist_name=_NRCELL700name, parameter='dlDMRSAdditionalPosition'),
    dict(value='Two additional DMRS', dist_name=_NRCELL701name, parameter='dlDMRSAdditionalPosition'),
    dict(value='Two additional DMRS', dist_name=_NRCELL700name, parameter='ulDMRSAdditionalPosition'),
    dict(value='Two additional DMRS', dist_name=_NRCELL701name, parameter='ulDMRSAdditionalPosition'),
    dict(value='RestrictedTypeB', dist_name=_NRCELL701name, parameter='prachSequenceType'),
    dict(value='RestrictedTypeB', dist_name=_NRCELL701name, parameter='prachSequenceType'),
    dict(value=[dict(channelStabilityHysteresis='10', channelStabilityThreshold='30', dlBufferHysteresis='30000',
                     dlBufferThreshold='0', enableSbSrsVolatilityCheck='false', maxWbSbSwitch='10',
                     numWbSrsConfigSample='10', numWbSrsReleaseSample='10', prbRatioHysteresis='15',
                     prbRatioThreshold='20', prbSampleHighLowPercentage='60', rankHysteresis='1', rankThreshold='3',
                     rlqBadPercentage='50', rlqGoodPercentage='20', seHysteresis='50', seThreshold='91',
                     sortingMetric='DL Spectral Efficiency', wbSrsConfigProhibitTimer='100', wbSrsPowerHysteresis='50',
                     wbSrsPowerThreshold='-1010', wbSrsReleaseProhibitTimer='1000')], dist_name=_NRCELL700name,
         parameter='wbSbSrsSwitch'),
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_gnb1_O_004 = [
    dict(value='enabled', dist_name=_NRCELL2name, parameter='dlMcsDowngradeForHr'),
    dict(value='enabled', dist_name=_NRCELL2name, parameter='ulMcsDowngradeForHr'),
    dict(value='false', dist_name=_NRCELL2name, parameter='scalingStepdownHREnabled'),
    # dict(value='0.5', dist_name=_NRCELL2name, parameter='dllaDeltaCqiStepdownHR'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actMcsPrbReductionFdmUl'),
    dict(value='0', dist_name=_NRCELL2name, parameter='ulMcsDowngradeMaxReduction'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDtxOptimizedScheduler'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDtxOptimizedScheduler'),
    dict(value='false', dist_name=_NRCELLname, parameter='actEnhDtxOptimizedScheduler'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actEnhDtxOptimizedScheduler'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='10000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutageTbsThresh'),
    dict(value='20000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverTbsThresh'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]
PARAM_8246_gnb1_O_004_348 = [
    dict(value='locked', dist_name=_LTECELL48040name, parameter='administrativeState'),
    dict(value='locked', dist_name=_LTECELL48045name, parameter='administrativeState'),
    dict(value='enhanced', dist_name=_NRCELL400name, parameter='dlMcsDowngradeForHr'),
    dict(value='enhanced', dist_name=_NRCELL400name, parameter='ulMcsDowngradeForHr'),
    dict(value='false', dist_name=_NRCELL400name, parameter='scalingStepdownHREnabled'),
    # dict(value='0.5', dist_name=_NRCELL400name, parameter='dllaDeltaCqiStepdownHR'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actMcsPrbReductionFdmUl'),
    dict(value='0', dist_name=_NRCELL400name, parameter='ulMcsDowngradeMaxReduction'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actDtxOptimizedScheduler'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actEnhDtxOptimizedScheduler'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actDlLaDynBlerTarget'),
    dict(value='10000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutageTbsThresh'),
    dict(value='20000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverTbsThresh'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_gnb1_O_004_383 = [
    dict(value='enabled', dist_name=_NRCELL2name, parameter='dlMcsDowngradeForHr'),
    dict(value='enabled', dist_name=_NRCELL2name, parameter='ulMcsDowngradeForHr'),
    dict(value='false', dist_name=_NRCELL2name, parameter='scalingStepdownHREnabled'),
    # dict(value='0.5', dist_name=_NRCELL2name, parameter='dllaDeltaCqiStepdownHR'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actMcsPrbReductionFdmUl'),
    dict(value='0', dist_name=_NRCELL2name, parameter='ulMcsDowngradeMaxReduction'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDtxOptimizedScheduler'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDtxOptimizedScheduler'),
    dict(value='false', dist_name=_NRCELLname, parameter='actEnhDtxOptimizedScheduler'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actEnhDtxOptimizedScheduler'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='10000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutageTbsThresh'),
    dict(value='20000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverTbsThresh'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_gnb1_O_004_2 = [
    dict(value='disabled', dist_name=_NRCELL2name, parameter='dlMcsDowngradeForHr'),
    dict(value='disabled', dist_name=_NRCELL2name, parameter='ulMcsDowngradeForHr'),
]
PARAM_8246_gnb1_O_004_2_348 = [
    dict(value='disabled', dist_name=_NRCELL400name, parameter='dlMcsDowngradeForHr'),
    dict(value='disabled', dist_name=_NRCELL400name, parameter='ulMcsDowngradeForHr'),
]
PARAM_8246_gnb1_O_004_2_383 = [
    dict(value='disabled', dist_name=_NRCELL2name, parameter='dlMcsDowngradeForHr'),
    dict(value='disabled', dist_name=_NRCELL2name, parameter='ulMcsDowngradeForHr'),
]

PARAM_8246_recover_gnb1_O_004 = [
    dict(value='disabled', dist_name=_NRCELL2name, parameter='dlMcsDowngradeForHr'),
    dict(value='disabled', dist_name=_NRCELL2name, parameter='ulMcsDowngradeForHr'),
    dict(value='true', dist_name=_NRCELL2name, parameter='scalingStepdownHREnabled'),
    # dict(value='0.5', dist_name=_NRCELL2name, parameter='dllaDeltaCqiStepdownHR'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actMcsPrbReductionFdmUl'),
    dict(value='4', dist_name=_NRCELL2name, parameter='ulMcsDowngradeMaxReduction'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDtxOptimizedScheduler'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDtxOptimizedScheduler'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhDtxOptimizedScheduler'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actEnhDtxOptimizedScheduler'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='500', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutageTbsThresh'),
    dict(value='4000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverTbsThresh'),
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]
PARAM_8246_recover_gnb1_O_004_348 = [
    dict(value='unlocked', dist_name=_LTECELL48040name, parameter='administrativeState'),
    dict(value='unlocked', dist_name=_LTECELL48045name, parameter='administrativeState'),
    dict(value='enhanced', dist_name=_NRCELL400name, parameter='dlMcsDowngradeForHr'),
    dict(value='enhanced', dist_name=_NRCELL400name, parameter='ulMcsDowngradeForHr'),
    dict(value='false', dist_name=_NRCELL400name, parameter='scalingStepdownHREnabled'),
    # dict(value='0.5', dist_name=_NRCELL400name, parameter='dllaDeltaCqiStepdownHR'),
    dict(value='false', dist_name=_NRCELL400name, parameter='actMcsPrbReductionFdmUl'),
    dict(value='0', dist_name=_NRCELL400name, parameter='ulMcsDowngradeMaxReduction'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actDtxOptimizedScheduler'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actEnhDtxOptimizedScheduler'),
    dict(value='true', dist_name=_NRCELL400name, parameter='actDlLaDynBlerTarget'),
    dict(value='500', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutageTbsThresh'),
    dict(value='4000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverTbsThresh'),
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]
PARAM_8246_recover_gnb1_O_004_383 = [
    dict(value='disabled', dist_name=_NRCELL2name, parameter='dlMcsDowngradeForHr'),
    dict(value='disabled', dist_name=_NRCELL2name, parameter='ulMcsDowngradeForHr'),
    dict(value='true', dist_name=_NRCELL2name, parameter='scalingStepdownHREnabled'),
    # dict(value='0.5', dist_name=_NRCELL2name, parameter='dllaDeltaCqiStepdownHR'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actMcsPrbReductionFdmUl'),
    dict(value='4', dist_name=_NRCELL2name, parameter='ulMcsDowngradeMaxReduction'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUl256Qam'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDtxOptimizedScheduler'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDtxOptimizedScheduler'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhDtxOptimizedScheduler'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actEnhDtxOptimizedScheduler'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlLaDynBlerTarget'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDlLaDynBlerTarget'),
    dict(value='500', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerOutageTbsThresh'),
    dict(value='4000', dist_name=_NRPUSCHHRLA_1, parameter='ulHRBlerRecoverTbsThresh'),
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_gnb1_O_001 = [
    dict(value='disabled', dist_name=_NRCELL2name, parameter='dlMcsDowngradeForHr'),
    dict(value='false', dist_name=_NRCELL2name, parameter='scalingStepdownHREnabled'),
    dict(value=[dict(dllaCqiOffsetHR='0', dllaDeltaCqiMaxHR='150', dllaDeltaCqiMinHR='-150',
                     dllaDeltaCqiStepdownHR='2000', dllaIniDeltaCqiHR='-30', dllaIniMcsHR='3',
                     dllaMcsMax64qamLowSERANK1HR='28', dllaMcsMax64qamLowSERANK2HR='28',
                     dllaMcsMax64qamLowSERANK3HR='28', dllaMcsMax64qamLowSERANK4HR='28', dllaMcsMax64qamRANK1HR='28',
                     dllaMcsMax64qamRANK2HR='28', dllaMcsMax64qamRANK3HR='28', dllaMcsMax64qamRANK4HR='28')],
         dist_name=_NRCELL2name, parameter='pdschHrLaConfig'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_recover_gnb1_O_001 = [
    dict(value='disabled', dist_name=_NRCELL2name, parameter='dlMcsDowngradeForHr'),
    dict(value='true', dist_name=_NRCELL2name, parameter='scalingStepdownHREnabled'),
    dict(value=[dict(dllaCqiOffsetHR='0', dllaDeltaCqiMaxHR='150', dllaDeltaCqiMinHR='-150',
                     dllaDeltaCqiStepdownHR='500', dllaIniDeltaCqiHR='-30', dllaIniMcsHR='3',
                     dllaMcsMax64qamLowSERANK1HR='28', dllaMcsMax64qamLowSERANK2HR='28',
                     dllaMcsMax64qamLowSERANK3HR='28', dllaMcsMax64qamLowSERANK4HR='28', dllaMcsMax64qamRANK1HR='28',
                     dllaMcsMax64qamRANK2HR='28', dllaMcsMax64qamRANK3HR='28', dllaMcsMax64qamRANK4HR='28')],
         dist_name=_NRCELL2name, parameter='pdschHrLaConfig'),
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8246_gnb1_O_001_2 = [
    dict(value='enabled', dist_name=_NRCELL2name, parameter='dlMcsDowngradeForHr'),
]

PARAM_8246_gnb1_O_001_3 = [
    dict(value='enhanced', dist_name=_NRCELL2name, parameter='dlMcsDowngradeForHr'),
]

# _mcc = str(tl.core.mcc)
# _mnc = str(tl.core.mnc)
_ho_path1 = 'BTS/CELLS/NRCELL-1/NNGCC'
_ho_path2 = 'BTS/CELLS/NRCELL-1/NRPMQAP-1/NGCCQ'
_ho_path3 = 'BTS/CELLS/NRCELL-1/NX2CC'
_ho_path4 = 'BTS/CELLS/NRCELL-1/NRPMQAP-1/X2CCQ'
_ho_path5 = 'BTS/CELLS/NRCELL-1/RSADU'
_ho_path6 = 'BTS/CELLS/NRCELL-1/RSACU'
_ho_path12 = 'BTS/CELLS/NRCELL-2/NNGCC'
_ho_path22 = 'BTS/CELLS/NRCELL-2/NRPMQAP-1/NGCCQ'
_ho_path32 = 'BTS/CELLS/NRCELL-2/NX2CC'
_ho_path42 = 'BTS/CELLS/NRCELL-2/NRPMQAP-1/X2CCQ'
_ho_path52 = 'BTS/CELLS/NRCELL-2/RSADU'
_ho_path53 = 'BTS/CELLS/NRCELL-2/RSACU'
_ho_path54 = 'BTS/CELLS/NRCELL-2/NRRCC'
_ho_path55 = 'BTS/CELLS/NRCELL-1/NRRCC'
_ho_path56 = 'BTS/CELLS/NRCELL-1/NRMOP'

SA_UE_CTX_REL_PREEM = {'gnb_id': 1, 'dic_path': _ho_path12, 'counter_id': 'M55125C11501'}
SA_UE_CTX_REL_PREEM_REDIR = {'gnb_id': 1, 'dic_path': _ho_path12, 'counter_id': 'M55125C11502'}
NG_FLOW_REL_GNB_PREEM = {'gnb_id': 1, 'dic_path': _ho_path12, 'counter_id': 'M55125C11504'}
NG_FLOW_REL_GNB_PREEM_RE = {'gnb_id': 1, 'dic_path': _ho_path12, 'counter_id': 'M55125C11506'}
NG_FLOW_REL_GNB_PREEM_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path12, 'counter_id': 'M55125C11505'}
NG_FLOW_REL_GNB_PREEM_RE_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path12, 'counter_id': 'M55125C11507'}
NG_FLOW_REL_GNB_PREEM_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path22, 'counter_id': 'M55163C01001'}
NG_FLOW_REL_GNB_PREEM_RE_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path22, 'counter_id': 'M55163C01002'}

SA_UE_CTX_REL_PREEM_1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C11501'}
SA_UE_CTX_REL_PREEM_REDIR_1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C11502'}
NG_FLOW_REL_GNB_PREEM_1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C11504'}
NG_FLOW_REL_GNB_PREEM_RE_1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C11506'}
NG_FLOW_REL_GNB_PREEM_5QI1_1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C11505'}
NG_FLOW_REL_GNB_PREEM_RE_5QI1_1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C11507'}
NG_FLOW_REL_GNB_PREEM_PMQAP_1 = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C01001'}
NG_FLOW_REL_GNB_PREEM_RE_PMQAP_1 = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C01002'}

NSA_UE_CTX_REL_PREEM = {'gnb_id': 1, 'dic_path': _ho_path12, 'counter_id': 'M55125C11503'}
NX2CC_RAB_REL_PREEM_SGNB = {'gnb_id': 1, 'dic_path': _ho_path32, 'counter_id': 'M55112C07001'}
NX2CC_RAB_REL_PREEM_SGNB_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path42, 'counter_id': 'M55162C00501'}

PEAK_NUM_UE_CTX_TEMP_POOL = {'gnb_id': 1, 'dic_path': _ho_path52, 'counter_id': 'M55139C05001'}
PEAK_NUM_UE_CTX_TEMP_POOL_1 = {'gnb_id': 1, 'dic_path': _ho_path5, 'counter_id': 'M55139C05001'}

PEAK_NUM_UE_CTX_TEMP_POOL = {'gnb_id': 1, 'dic_path': _ho_path52, 'counter_id': 'M55139C05001'}
NSA_UE_CTX_REL_PREEM = {'gnb_id': 1, 'dic_path': _ho_path12, 'counter_id': 'M55125C11503'}
NX2CC_RAB_REL_PREEM_SGNB = {'gnb_id': 1, 'dic_path': _ho_path32, 'counter_id': 'M55112C07001'}
NX2CC_RAB_REL_PREEM_SGNB_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path42, 'counter_id': 'M55162C00501'}
SGNB_SA_CU_HO_ADMISSION_REQ = {'gnb_id': 1, 'dic_path': _ho_path53, 'counter_id': 'M55138C00023'}

NRRCC_RRC_RELEASE_REDIR_NR = {'gnb_id': 1, 'dic_path': _ho_path54, 'counter_id': 'M55124C01501'}

SA_UE_CTX_REL_PREEM_REDIR_D010 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C11502'}
NG_FLOW_REL_GNB_PREEM_RE_D010 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C11506'}
NG_FLOW_REL_GNB_PREEM_RE_5QI1_D010 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C11507'}
NG_FLOW_REL_GNB_PREEM_RE_PMQAP_D010 = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C01002'}
NRRCC_RRC_RELEASE_REDIR_NR_D010 = {'gnb_id': 1, 'dic_path': _ho_path55, 'counter_id': 'M55124C01501'}

NG_FLOW_STP_ATT_INC_HO = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09013'}
NG_FLOW_STP_SUC_INC_HO = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09014'}
NG_FLOW_REL_IANR_SUC_HO = {'gnb_id': 1, 'dic_path': _ho_path12, 'counter_id': 'M55125C09015'}
NG_FLOW_REL_IANR_SUC_HO_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path12, 'counter_id': 'M55125C09508'}
NG_FLOW_REL_PART_HO = {'gnb_id': 1, 'dic_path': _ho_path12, 'counter_id': 'M55125C10504'}
NG_FLOW_REL_IANR_SUC_HO_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path22, 'counter_id': 'M55163C00515'}
NG_FLOW_REL_PART_HO_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path22, 'counter_id': 'M55163C02001'}
SA_PART_ADMISSION = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55138C02001'}
NG_FLOW_STP_ATT_INC_HO_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09524'}
NG_FLOW_STP_SUC_INC_HO_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09525'}
NG_FLOW_STP_ATT_INC_HO_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00513'}
NG_FLOW_STP_SUC_INC_HO_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00514'}

# 710###
NRMOP_SA_PROFILE_SELECTED_01 = {'gnb_id': 2, 'dic_path': _ho_path56, 'counter_id': 'M55157C00033'}

AMOUNT_OF_CELLS = 1
# #8246_D008_HR#
# HR Value is 0
CB008246_D_008_HR_traffic_check_kpi_names_value_zero = [
    "12_PDSCH_4TX_RI_PM1",
    "13_PDSCH_4TX_RANK_PMI",
    "14_Init_BLER_BR_LOWSE_DL_PDSCH_tx",
    "18_Resid_BLER_BR_DL_PDSCH_tx",
    "24_PDSCH_RANK3_LOWSE_MCS",
    "25_PDSCH_RANK4_LOWSE_MCS"
]

# HR value is above 0
CB008246_D_008_HR_traffic_check_kpi_names_larger_zero = [
    "3_PDSCH_INITX_LOWSE_MCS",
    "11_PDSCH_2TX_RI_PM1",
    "19_PDSCH_SUCC_INI_LOWSE_MCS",
    "20_PDSCH_SUCC_ANY_LOWSE_MCS",
    "22_PDSCH_RANK1_LOWSE_MCS",
    "26_PDSCH_INI_VOL_LOWSE_MCS",
    "27_PDSCH_INIRE_VOL_LOWSE_MCS"
]

# HR value is greater_than_or_equal_specfied 0
CB008246_D_008_HR_traffic_check_kpi_names_greater_than_or_equal_specfied = [
    "21_PDSCH_UNSUCC_LOWSE_MCS"
]

# HR The specified value
CB008246_D_008_HR_traffic_check_kpi_names_less_specified_value = [
    "1_Init_BLER_HR_LOWSE_DL_PDSCH"
]

CB008246_D_008_HR_traffic_check_kpi_names_less_specified_value2 = [
    "4_PDSCH_SUCC_INI_64TBL_MCS",
    "5_PDSCH_SUCC_ANY_64TBL_MCS",
    "6_PDSCH_UNSUCC_64TBL_MCS",
    "7_PDSCH_RANK1_64TBL_MCS",
    "8_PDSCH_RANK2_64TBL_MCS",
    "9_PDSCH_RANK3_64TBL_MCS",
    "10_PDSCH_RANK4_64TBL_MCS",
    "15_PDSCH_INIRE_VOL_64TBL_MCS",
    "16_PDSCH_INI_VOL_64TBL_MCS",
    "28_PDSCH_INITX_64TBL_MCS"
]

# #8246_D008_BR#
# BR Value is 0
CB008246_D_008_BR_traffic_check_kpi_names_value_zero = [
    "1_Init_BLER_HR_LOWSE_DL_PDSCH",
    "12_PDSCH_4TX_RI_PM1",
    "13_PDSCH_4TX_RANK_PMI",
    "17_Resid_BLER_HR_DL_PDSCH_tx",
    "24_PDSCH_RANK3_LOWSE_MCS",
    "25_PDSCH_RANK4_LOWSE_MCS"
]

# BR value is above 0
CB008246_D_008_BR_traffic_check_kpi_names_larger_zero = [
    "3_PDSCH_INITX_LOWSE_MCS",
    "11_PDSCH_2TX_RI_PM1",
    "19_PDSCH_SUCC_INI_LOWSE_MCS",
    "20_PDSCH_SUCC_ANY_LOWSE_MCS",
    "22_PDSCH_RANK1_LOWSE_MCS",
    "26_PDSCH_INI_VOL_LOWSE_MCS",
    "27_PDSCH_INIRE_VOL_LOWSE_MCS"
]

# BR value is greater_than_or_equal_specfied 0
CB008246_D_008_BR_traffic_check_kpi_names_greater_than_or_equal_specfied = [
    "21_PDSCH_UNSUCC_LOWSE_MCS"
]

# BR The specified value
CB008246_D_008_BR_traffic_check_kpi_names_less_specified_value = [
    "14_Init_BLER_BR_LOWSE_DL_PDSCH_tx",
    "18_Resid_BLER_BR_DL_PDSCH_tx"
]

CB008246_D_008_BR_traffic_check_kpi_names_less_specified_value2 = [
    "4_PDSCH_SUCC_INI_64TBL_MCS",
    "5_PDSCH_SUCC_ANY_64TBL_MCS",
    "6_PDSCH_UNSUCC_64TBL_MCS",
    "7_PDSCH_RANK1_64TBL_MCS",
    "8_PDSCH_RANK2_64TBL_MCS",
    "9_PDSCH_RANK3_64TBL_MCS",
    "10_PDSCH_RANK4_64TBL_MCS",
    "15_PDSCH_INIRE_VOL_64TBL_MCS",
    "16_PDSCH_INI_VOL_64TBL_MCS",
    "28_PDSCH_INITX_64TBL_MCS"
]

# #8246_D006_HR#
# HR Value is 0
CB008246_D_006_HR_traffic_check_kpi_names_value_zero = [
    "4_PDSCH_SUCC_INI_64TBL_MCS",
    "5_PDSCH_SUCC_ANY_64TBL_MCS",
    "6_PDSCH_UNSUCC_64TBL_MCS",
    "7_PDSCH_RANK1_64TBL_MCS",
    "8_PDSCH_RANK2_64TBL_MCS",
    "9_PDSCH_RANK3_64TBL_MCS",
    "10_PDSCH_RANK4_64TBL_MCS",
    "14_Init_BLER_BR_LOWSE_DL_PDSCH_tx",
    "15_PDSCH_INIRE_VOL_64TBL_MCS",
    "16_PDSCH_INI_VOL_64TBL_MCS",
    "17_Resid_BLER_HR_DL_PDSCH_tx",
    "18_Resid_BLER_BR_DL_PDSCH_tx",
    "24_PDSCH_RANK3_LOWSE_MCS",
    "25_PDSCH_RANK4_LOWSE_MCS",
    "28_PDSCH_INITX_64TBL_MCS"
]

CB008246_D_006_HR_traffic_check_kpi_names_value_zero_348_383 = [
    "4_PDSCH_SUCC_INI_64TBL_MCS",
    "5_PDSCH_SUCC_ANY_64TBL_MCS",
    "6_PDSCH_UNSUCC_64TBL_MCS",
    "7_PDSCH_RANK1_64TBL_MCS",
    "8_PDSCH_RANK2_64TBL_MCS",
    "9_PDSCH_RANK3_64TBL_MCS",
    "10_PDSCH_RANK4_64TBL_MCS",
    "14_Init_BLER_BR_LOWSE_DL_PDSCH_tx",
    "15_PDSCH_INIRE_VOL_64TBL_MCS",
    "16_PDSCH_INI_VOL_64TBL_MCS",
    "18_Resid_BLER_BR_DL_PDSCH_tx",
    "28_PDSCH_INITX_64TBL_MCS"
]

# HR value is above 0
CB008246_D_006_HR_traffic_check_kpi_names_larger_zero = [
    "3_PDSCH_INITX_LOWSE_MCS",
    "11_PDSCH_2TX_RI_PM1",
    "12_PDSCH_4TX_RI_PM1",
    "13_PDSCH_4TX_RANK_PMI",
    "19_PDSCH_SUCC_INI_LOWSE_MCS",
    "20_PDSCH_SUCC_ANY_LOWSE_MCS",
    "22_PDSCH_RANK1_LOWSE_MCS",
    "25_PDSCH_RANK4_LOWSE_MCS",
    "26_PDSCH_INI_VOL_LOWSE_MCS",
    "27_PDSCH_INIRE_VOL_LOWSE_MCS"
]

SUM_CB008246_D_006_HR_traffic_348_383 = [
    "22_PDSCH_RANK1_LOWSE_MCS",
    "24_PDSCH_RANK3_LOWSE_MCS",
    "25_PDSCH_RANK4_LOWSE_MCS",
]

CB008246_K_ALL_HR_348_383_01 = SUM_CB008246_D_006_HR_traffic_348_383[0]
CB008246_K_ALL_HR_348_383_02 = SUM_CB008246_D_006_HR_traffic_348_383[1]
CB008246_K_ALL_HR_348_383_03 = SUM_CB008246_D_006_HR_traffic_348_383[2]

CB008246_D_006_HR_traffic_check_kpi_names_larger_zero_348_383 = [
    "3_PDSCH_INITX_LOWSE_MCS",
    # "11_PDSCH_2TX_RI_PM1",
    "12_PDSCH_4TX_RI_PM1",
    "13_PDSCH_4TX_RANK_PMI",
    "19_PDSCH_SUCC_INI_LOWSE_MCS",
    "20_PDSCH_SUCC_ANY_LOWSE_MCS",
    "26_PDSCH_INI_VOL_LOWSE_MCS",
    "27_PDSCH_INIRE_VOL_LOWSE_MCS"
]

# HR value is greater_than_or_equal_specfied 0
CB008246_D_006_HR_traffic_check_kpi_names_greater_than_or_equal_specfied = [
    "21_PDSCH_UNSUCC_LOWSE_MCS"
]

# HR The specified value
CB008246_D_006_HR_traffic_check_kpi_names_less_specified_value = [
    "1_Init_BLER_HR_LOWSE_DL_PDSCH"
]

# #8246_D006_BR#
# BR Value is 0
CB008246_D_006_BR_traffic_check_kpi_names_value_zero = [
    "1_Init_BLER_HR_LOWSE_DL_PDSCH",
    "4_PDSCH_SUCC_INI_64TBL_MCS",
    "5_PDSCH_SUCC_ANY_64TBL_MCS",
    "6_PDSCH_UNSUCC_64TBL_MCS",
    "7_PDSCH_RANK1_64TBL_MCS",
    "8_PDSCH_RANK2_64TBL_MCS",
    "9_PDSCH_RANK3_64TBL_MCS",
    "10_PDSCH_RANK4_64TBL_MCS",
    "12_PDSCH_4TX_RI_PM1",
    "13_PDSCH_4TX_RANK_PMI",
    "15_PDSCH_INIRE_VOL_64TBL_MCS",
    "16_PDSCH_INI_VOL_64TBL_MCS",
    "17_Resid_BLER_HR_DL_PDSCH_tx",
    "24_PDSCH_RANK3_LOWSE_MCS",
    "25_PDSCH_RANK4_LOWSE_MCS",
    "28_PDSCH_INITX_64TBL_MCS"
]

# BR value is above 0
CB008246_D_006_BR_traffic_check_kpi_names_larger_zero = [
    "3_PDSCH_INITX_LOWSE_MCS",
    "11_PDSCH_2TX_RI_PM1",
    "19_PDSCH_SUCC_INI_LOWSE_MCS",
    "20_PDSCH_SUCC_ANY_LOWSE_MCS",
    "22_PDSCH_RANK1_LOWSE_MCS",
    "26_PDSCH_INI_VOL_LOWSE_MCS",
    "27_PDSCH_INIRE_VOL_LOWSE_MCS"
]

# BR value is greater_than_or_equal_specfied 0
CB008246_D_006_BR_traffic_check_kpi_names_greater_than_or_equal_specfied = [
    "21_PDSCH_UNSUCC_LOWSE_MCS"
]

# BR The specified value
CB008246_D_006_BR_traffic_check_kpi_names_less_specified_value = [
    "14_Init_BLER_BR_LOWSE_DL_PDSCH_tx",
    "18_Resid_BLER_BR_DL_PDSCH_tx"
]

# #####HR traffic check#####
# Less than the specified value
CB008246_E_006_HR_traffic_check_kpi_names_less_specified_value = ["8246_HRDRB_UL_BLER"]
CB008246_E_006_HR_traffic_check_kpi_names_less_specified_value2 = [
    "PUSCH_CP_INITX_64TBL_MCS",
    "PUSCH_CP_UNSUCC_64TBL_MCS",
    "PUSCH_CP_SUCC_INI_64TBL_MCS",
    "PUSCH_CP_SUCC_ANY_64TBL_MCS",
    "PUSCH_CP_RANK1_64TBL_MCS",
    "PUSCH_CP_RANK2_64TBL_MCS",
    # "PUSCH_CP_INI_VOL_64TBL_MCS",
    # "PUSCH_CP_INIRE_VOL_64TBL_MCS"
]
# As long as the formula holds
CB008246_E_006_HR_traffic_check_kpi_names_formula_established = [
    "PUSCH_INITX_LOWSE_HRD_PRFL1", "PUSCH_SUCC_ANY_LOWSE_HRD_PRFL1", "PUSCH_UNSUCC_LOWSE_HRD_PRFL1",
    "PUSCH_INITX_LOWSE_HRD_PRFL2", "PUSCH_SUCC_ANY_LOWSE_HRD_PRFL2", "PUSCH_UNSUCC_LOWSE_HRD_PRFL2",
    "8246_SUM_PUSCH_CP_INI_LowSE_MCS", "8246_SUM_PUSCH_CP_SUCC_ANY_LOWSE_MCS",
    "8246_SUM_PUSCH_CP_UNSUCC_LOWSE_MCS", "8246_SUM_PUSCH_CP_RANK1_LOWSE_MCS", "8246_SUM_PUSCH_CP_RANK2_LOWSE_MCS",
    "UE_SINR_PUSCH_R1_LEVEL", "UE_SINR_PUSCH_R2_LEVEL", "NR_5064a", "NR_106a"
]
E_006_HR_value_0 = CB008246_E_006_HR_traffic_check_kpi_names_formula_established[0]
E_006_HR_value_1 = CB008246_E_006_HR_traffic_check_kpi_names_formula_established[1]
E_006_HR_value_2 = CB008246_E_006_HR_traffic_check_kpi_names_formula_established[2]
E_006_HR_value_3 = CB008246_E_006_HR_traffic_check_kpi_names_formula_established[3]
E_006_HR_value_4 = CB008246_E_006_HR_traffic_check_kpi_names_formula_established[4]
E_006_HR_value_5 = CB008246_E_006_HR_traffic_check_kpi_names_formula_established[5]
E_006_HR_value_6 = CB008246_E_006_HR_traffic_check_kpi_names_formula_established[6]
E_006_HR_value_7 = CB008246_E_006_HR_traffic_check_kpi_names_formula_established[7]
E_006_HR_value_8 = CB008246_E_006_HR_traffic_check_kpi_names_formula_established[8]
E_006_HR_value_9 = CB008246_E_006_HR_traffic_check_kpi_names_formula_established[9]
E_006_HR_value_10 = CB008246_E_006_HR_traffic_check_kpi_names_formula_established[10]
E_006_HR_value_11 = CB008246_E_006_HR_traffic_check_kpi_names_formula_established[11]
E_006_HR_value_12 = CB008246_E_006_HR_traffic_check_kpi_names_formula_established[12]
E_006_HR_value_13 = CB008246_E_006_HR_traffic_check_kpi_names_formula_established[13]
E_006_HR_value_14 = CB008246_E_006_HR_traffic_check_kpi_names_formula_established[14]
# Value is 0
CB008246_E_006_HR_traffic_check_kpi_names_value_zero = [
    "PUSCH_INITX_LOWSE_BRDRB",
    "PUSCH_SUCC_INI_LOWSE_BRDRB",
    "PUSCH_SUCC_ANY_LOWSE_BRDRB",
    "PUSCH_UNSUCC_LOWSE_BRDRB",
]
# As long as there is value
CB008246_E_006_HR_traffic_check_kpi_names_larger_zero = [
    "8246_SUM_PUSCH_CP_INI_LowSE_MCS",
    "8246_SUM_PUSCH_CP_SUCC_INI_LOWSE_MCS",
    "8246_SUM_PUSCH_CP_SUCC_ANY_LOWSE_MCS",
    "8246_SUM_PUSCH_CP_INI_VOL_LOWSE_MCS",
    "8246_SUM_PUSCH_CP_INRE_VOL_LOWSE_MCS",
    # "PUSCH_CP_RANK1_RANK2_PMI",
    # "PUSCH_CP_2TX_RI_01_02",
    "DATA_SLOT_PUSCH",
    "DATA_SLOT_PUSCH_TIME",
    "PUSCH_OFDM_SYMBOLS",
    "PUSCH_OFDM_SYMBOLS_TIME",
    "PRB_USED_PUSCH",
    "PRB_AVAIL_PUSCH",
    "UL_MAC_SDU_VOL_DTCH",
    "ACC_UE_UL_DRB_DATA"
]

# #####BR traffic check#####
# Less than the specified value
CB008246_E_006_BR_traffic_check_kpi_names_less_specified_value = ["8246_BRDRB_UL_bler"]
CB008246_E_006_BR_traffic_check_kpi_names_less_specified_value2 = [
    "PUSCH_CP_INITX_64TBL_MCS",
    "PUSCH_CP_UNSUCC_64TBL_MCS",
    "PUSCH_CP_SUCC_INI_64TBL_MCS",
    "PUSCH_CP_SUCC_ANY_64TBL_MCS",
    "PUSCH_CP_RANK1_64TBL_MCS",
    "PUSCH_CP_RANK2_64TBL_MCS",
    "PUSCH_CP_INI_VOL_64TBL_MCS",
    "PUSCH_CP_INIRE_VOL_64TBL_MCS"
]
# As long as the formula holds
CB008246_E_006_BR_traffic_check_kpi_names_formula_established = [
    "PUSCH_INITX_LOWSE_BRDRB", "PUSCH_SUCC_ANY_LOWSE_BRDRB", "PUSCH_UNSUCC_LOWSE_BRDRB",
    "8246_SUM_PUSCH_CP_INI_LowSE_MCS", "8246_SUM_PUSCH_CP_SUCC_ANY_LOWSE_MCS",
    "8246_SUM_PUSCH_CP_UNSUCC_LOWSE_MCS", "8246_SUM_PUSCH_CP_RANK1_LOWSE_MCS", "8246_SUM_PUSCH_CP_RANK2_LOWSE_MCS",
    "UE_SINR_PUSCH_R1_LEVEL", "UE_SINR_PUSCH_R2_LEVEL", "NR_5064a", "NR_106a"
]
E_006_BR_value_0 = CB008246_E_006_BR_traffic_check_kpi_names_formula_established[0]
E_006_BR_value_1 = CB008246_E_006_BR_traffic_check_kpi_names_formula_established[1]
E_006_BR_value_2 = CB008246_E_006_BR_traffic_check_kpi_names_formula_established[2]
E_006_BR_value_3 = CB008246_E_006_BR_traffic_check_kpi_names_formula_established[3]
E_006_BR_value_4 = CB008246_E_006_BR_traffic_check_kpi_names_formula_established[4]
E_006_BR_value_5 = CB008246_E_006_BR_traffic_check_kpi_names_formula_established[5]
E_006_BR_value_6 = CB008246_E_006_BR_traffic_check_kpi_names_formula_established[6]
E_006_BR_value_7 = CB008246_E_006_BR_traffic_check_kpi_names_formula_established[7]
E_006_BR_value_8 = CB008246_E_006_BR_traffic_check_kpi_names_formula_established[8]
E_006_BR_value_9 = CB008246_E_006_BR_traffic_check_kpi_names_formula_established[9]
E_006_BR_value_10 = CB008246_E_006_BR_traffic_check_kpi_names_formula_established[10]
E_006_BR_value_11 = CB008246_E_006_BR_traffic_check_kpi_names_formula_established[11]
# Value is 0
CB008246_E_006_BR_traffic_check_kpi_names_value_zero = [
    "PUSCH_INITX_LOWSE_HRD_PRFL1",
    "PUSCH_SUCC_INI_LOWSE_HRD_PRFL1",
    "PUSCH_INITX_LOWSE_HRD_PRFL2",
    "PUSCH_SUCC_ANY_LOWSE_HRD_PRFL1",
    "PUSCH_UNSUCC_LOWSE_HRD_PRFL1",
    "PUSCH_SUCC_INI_LOWSE_HRD_PRFL2",
    "PUSCH_SUCC_ANY_LOWSE_HRD_PRFL2",
    "PUSCH_UNSUCC_LOWSE_HRD_PRFL2"
]
# As long as there is value
CB008246_E_006_BR_traffic_check_kpi_names_larger_zero = [
    "8246_SUM_PUSCH_CP_INI_LowSE_MCS", "8246_SUM_PUSCH_CP_SUCC_INI_LOWSE_MCS", "8246_SUM_PUSCH_CP_SUCC_ANY_LOWSE_MCS",
    "8246_SUM_PUSCH_CP_INI_VOL_LOWSE_MCS", "8246_SUM_PUSCH_CP_INRE_VOL_LOWSE_MCS", "PUSCH_CP_RANK1_RANK2_PMI",
    "PUSCH_CP_2TX_RI_01_02", "DATA_SLOT_PUSCH", "DATA_SLOT_PUSCH_TIME", "PUSCH_OFDM_SYMBOLS",
    "PUSCH_OFDM_SYMBOLS_TIME", "PRB_USED_PUSCH", "PRB_AVAIL_PUSCH", "UL_MAC_SDU_VOL_DTCH", "ACC_UE_UL_DRB_DATA"
]

# #####HR BR switch check#####
# As long as the formula holds
CB008246_E_006_HR_BR_switch_check_kpi_names_formula_established = [
    "PUSCH_INITX_LOWSE_BRDRB", "PUSCH_INITX_LOWSE_HRD_PRFL1", "PUSCH_INITX_LOWSE_HRD_PRFL2",
]

# 8246_H06
CB008246_H_006_HR_AL2_check_kpi_names_larger_zero = [
    "UL_GRANT_HR_AL2_CBWP1", "DL_GRANT_HR_AL2_CBWP1"
]
CB008246_H_006_HR_AL4_check_kpi_names_larger_zero = [
    "UL_GRANT_HR_AL4_CBWP1", "DL_GRANT_HR_AL4_CBWP1"
]
CB008246_H_006_HR_AL8_check_kpi_names_larger_zero = [
    "UL_GRANT_HR_AL8_CBWP1", "DL_GRANT_HR_AL8_CBWP1"
]
CB008246_H_006_HR_AL_check_kpi_names_larger_zero = [
    "UL_GRANT_HR_AL2_AL4_AL8_CBWP1", "DL_GRANT_HR_AL2_AL4_AL8_CBWP1"
]
CB008246_H_006_BR_AL_check_kpi_names_larger_zero = [
    "UL_GRANT_AL_CBWP1", "DL_GRANT_AL_CBWP1"
]
CB008246_H_006_HR_AL_common_check_kpi_names_larger_zero = [
    "SI_GRANT_CBWP1", "UESSS_DCI0_1_CCE_ALLOC_CBWP1",
    "UESSS_DCI0_1_CCE_AVAIL_CBWP1", "UESSS_DCI1_1_CCE_ALLOC_CBWP1", "UESSS_DCI1_1_CCE_AVAIL_CBWP1",
    "SLT_UL_GRANT_CAPABILITY_CBWP1", "SLT_DL_GRANT_CAPABILITY_CBWP1", "DL_SLT_SYMB_ALLOC_CBWP1",
    "AL_USED_PDCCH", "DATA_SLOT_PDSCH_TIME", "DATA_SLOT_PUSCH_TIME", "ACC_UE_DL_DRB_DATA", "ACC_UE_UL_DRB_DATA"
]

# CNI-144608
CNI_144608_check_kpi_names = [
    "TMO_MAGENTA_1012a", "TMO_MAGENTA_1014a", "TMO_MAGENTA_1013a", "TMO_MAGENTA_1015a"
]

# 8246_I07
CB008246_I_007_HR_traffic_check_kpi_names_less_specified_value = ["8246_HRDRB_UL_BLER"]

CB008246_I_007_HR_traffic_check_kpi_names_formula_established = [
    "PUSCH_INITX_64TBL_HRD_PRFL1", "PUSCH_SUCC_ANY_64TBL_HRD_PRFL1", "PUSCH_UNSUCC_64TBL_HRD_PRFL1",
    "PUSCH_INITX_64TBL_HRD_PRFL2", "PUSCH_SUCC_ANY_64TBL_HRD_PRFL2", "PUSCH_UNSUCC_64TBL_HRD_PRFL2",
    "PUSCH_CP_UNSUCC_64TBL_MCS_00_31", "PUSCH_CP_INITX_64TBL_MCS_00_28", "PUSCH_CP_SUCC_ANY_64TBL_MCS_00_31",
    "PUSCH_CP_RANK1_64TBL_MCS_00_28", "PUSCH_CP_RANK2_64TBL_MCS_00_28"
]
I_007_HR_value_0 = CB008246_I_007_HR_traffic_check_kpi_names_formula_established[0]
I_007_HR_value_1 = CB008246_I_007_HR_traffic_check_kpi_names_formula_established[1]
I_007_HR_value_2 = CB008246_I_007_HR_traffic_check_kpi_names_formula_established[2]
I_007_HR_value_3 = CB008246_I_007_HR_traffic_check_kpi_names_formula_established[3]
I_007_HR_value_4 = CB008246_I_007_HR_traffic_check_kpi_names_formula_established[4]
I_007_HR_value_5 = CB008246_I_007_HR_traffic_check_kpi_names_formula_established[5]
I_007_HR_value_6 = CB008246_I_007_HR_traffic_check_kpi_names_formula_established[6]
I_007_HR_value_7 = CB008246_I_007_HR_traffic_check_kpi_names_formula_established[7]
I_007_HR_value_8 = CB008246_I_007_HR_traffic_check_kpi_names_formula_established[8]
I_007_HR_value_9 = CB008246_I_007_HR_traffic_check_kpi_names_formula_established[9]
I_007_HR_value_10 = CB008246_I_007_HR_traffic_check_kpi_names_formula_established[10]
# Value is 0
CB008246_I_007_HR_traffic_check_kpi_names_value_zero = [
    "PUSCH_INITX_64TBL_HRD_PRFL2", "PUSCH_SUCC_INI_64TBL_HRD_PRFL2", "PUSCH_SUCC_ANY_64TBL_HRD_PRFL2",
    "PUSCH_UNSUCC_64TBL_HRD_PRFL2", "PUSCH_INITX_LOWSE_BRDRB", "PUSCH_SUCC_INI_LOWSE_BRDRB",
    "PUSCH_SUCC_ANY_LOWSE_BRDRB", "PUSCH_UNSUCC_LOWSE_BRDRB", "PUSCH_INITX_LOWSE_HRD_PRFL1",
    "PUSCH_SUCC_INI_LOWSE_HRD_PRFL1", "PUSCH_INITX_LOWSE_HRD_PRFL2", "PUSCH_SUCC_ANY_LOWSE_HRD_PRFL1",
    "PUSCH_UNSUCC_LOWSE_HRD_PRFL1", "PUSCH_SUCC_INI_LOWSE_HRD_PRFL2", "PUSCH_SUCC_ANY_LOWSE_HRD_PRFL2",
    "PUSCH_UNSUCC_LOWSE_HRD_PRFL2", "PUSCH_CP_INI_LOWSE_MCS_00_28", "PUSCH_CP_SUCC_ANY_LOWSE_MCS_00_31",
    "PUSCH_CP_UNSUCC_LOWSE_MCS_00_31", "PUSCH_CP_SUCC_INI_LOWSE_MCS_00_28", "PUSCH_CP_RANK1_LOWSE_MCS_00_31",
    "PUSCH_CP_RANK2_LOWSE_MCS_00_31", "PUSCH_CP_INI_VOL_LOWSE_MCS_00_28", "PUSCH_CP_INRE_VOL_LOWSE_MCS_00_31"
]
CB008246_I_007_HR_traffic_check_kpi_names_larger_zero = [
    "PUSCH_INITX_64TBL_HRD_PRFL1", "PUSCH_SUCC_INI_64TBL_HRD_PRFL1", "PUSCH_SUCC_ANY_64TBL_HRD_PRFL1",
    "PUSCH_CP_INITX_64TBL_MCS_00_28", "PUSCH_CP_SUCC_INI_64TBL_MCS_00_28", "PUSCH_CP_SUCC_ANY_64TBL_MCS_00_31",
    "PUSCH_CP_INI_VOL_64TBL_MCS00_28", "PUSCH_CP_INIRE_VOL_64TBL_MCS00_31"
]

CB008246_I_007_BR_traffic_check_kpi_names_less_specified_value = ["8246_BRDRB_UL_bler"]
CB008246_I_007_BR_traffic_check_kpi_names_formula_established = [
    "PUSCH_INITX_64TBL_BR", "PUSCH_SUCC_ANY_64TBL_BR", "PUSCH_UNSUCC_64TBL_BR",
    "PUSCH_CP_UNSUCC_64TBL_MCS_00_31", "PUSCH_CP_INITX_64TBL_MCS_00_28", "PUSCH_CP_SUCC_ANY_64TBL_MCS_00_31",
    "PUSCH_CP_RANK1_64TBL_MCS_00_28", "PUSCH_CP_RANK2_64TBL_MCS_00_28"
]
I_007_BR_value_0 = CB008246_I_007_BR_traffic_check_kpi_names_formula_established[0]
I_007_BR_value_1 = CB008246_I_007_BR_traffic_check_kpi_names_formula_established[1]
I_007_BR_value_2 = CB008246_I_007_BR_traffic_check_kpi_names_formula_established[2]
I_007_BR_value_3 = CB008246_I_007_BR_traffic_check_kpi_names_formula_established[3]
I_007_BR_value_4 = CB008246_I_007_BR_traffic_check_kpi_names_formula_established[4]
I_007_BR_value_5 = CB008246_I_007_BR_traffic_check_kpi_names_formula_established[5]
I_007_BR_value_6 = CB008246_I_007_BR_traffic_check_kpi_names_formula_established[6]
I_007_BR_value_7 = CB008246_I_007_BR_traffic_check_kpi_names_formula_established[7]
# Value is 0
CB008246_I_007_BR_traffic_check_kpi_names_value_zero = [
    "PUSCH_INITX_LOWSE_BRDRB", "PUSCH_SUCC_INI_LOWSE_BRDRB", "PUSCH_SUCC_ANY_LOWSE_BRDRB",
    "PUSCH_UNSUCC_LOWSE_BRDRB", "PUSCH_INITX_LOWSE_HRD_PRFL1", "PUSCH_SUCC_INI_LOWSE_HRD_PRFL1",
    "PUSCH_INITX_LOWSE_HRD_PRFL2", "PUSCH_SUCC_ANY_LOWSE_HRD_PRFL1", 'PUSCH_UNSUCC_LOWSE_HRD_PRFL1',
    "PUSCH_SUCC_INI_LOWSE_HRD_PRFL2", "PUSCH_SUCC_ANY_LOWSE_HRD_PRFL2", "PUSCH_UNSUCC_LOWSE_HRD_PRFL2",
    "PUSCH_CP_INI_LOWSE_MCS_00_28", "PUSCH_CP_SUCC_ANY_LOWSE_MCS_00_31", "PUSCH_CP_UNSUCC_LOWSE_MCS_00_31",
    "PUSCH_CP_SUCC_INI_LOWSE_MCS_00_28", "PUSCH_CP_RANK1_LOWSE_MCS_00_31", "PUSCH_CP_RANK2_LOWSE_MCS_00_31",
    "PUSCH_CP_INI_VOL_LOWSE_MCS_00_28", "PUSCH_CP_INRE_VOL_LOWSE_MCS_00_31"
]
# As long as there is value
CB008246_I_007_BR_traffic_check_kpi_names_larger_zero = [
    "PUSCH_INITX_64TBL_BR", "PUSCH_SUCC_INI_64TBL_BR", "PUSCH_SUCC_ANY_64TBL_BR", "PUSCH_CP_INITX_64TBL_MCS_00_28",
    "PUSCH_CP_SUCC_INI_64TBL_MCS_00_28", "PUSCH_CP_SUCC_ANY_64TBL_MCS_00_31", "PUSCH_CP_INI_VOL_64TBL_MCS00_28",
    "PUSCH_CP_INIRE_VOL_64TBL_MCS00_31"
]

# 8246-P
CB008246_P_003_HR_traffic_check_kpi_names_value_zero = [
    "4_PDSCH_SUCC_INI_64TBL_MCS",
    "5_PDSCH_SUCC_ANY_64TBL_MCS",
    "6_PDSCH_UNSUCC_64TBL_MCS",
    "8_PDSCH_RANK2_64TBL_MCS",
    "9_PDSCH_RANK3_64TBL_MCS",
    "10_PDSCH_RANK4_64TBL_MCS",
    "12_PDSCH_4TX_RI_PM1",
    "13_PDSCH_4TX_RANK_PMI",
    "14_Init_BLER_BR_LOWSE_DL_PDSCH_tx",
    "18_Resid_BLER_BR_DL_PDSCH_tx",
    "24_PDSCH_RANK3_LOWSE_MCS",
    "25_PDSCH_RANK4_LOWSE_MCS",
    "28_PDSCH_INITX_64TBL_MCS"
]

CB008246_P_003_HR_traffic_check_kpi_names_value_zero_02 = [
    "6_PDSCH_UNSUCC_64TBL_MCS",
    "7_PDSCH_RANK1_64TBL_MCS",
    "9_PDSCH_RANK3_64TBL_MCS",
    "10_PDSCH_RANK4_64TBL_MCS",
    "12_PDSCH_4TX_RI_PM1",
    "13_PDSCH_4TX_RANK_PMI",
    "14_Init_BLER_BR_LOWSE_DL_PDSCH_tx",
    "16_PDSCH_INI_VOL_64TBL_MCS",
    "18_Resid_BLER_BR_DL_PDSCH_tx",
    "24_PDSCH_RANK3_LOWSE_MCS",
    "25_PDSCH_RANK4_LOWSE_MCS",
]

CB008246_P_003_UL_HR_traffic_check_kpi_names_value_zero = []

CB008246_P_003_HR_traffic_check_kpi_names_less_specified_value = []

CB008246_P_003_HR_traffic_check_kpi_names_less_specified_value2 = [
    "PUSCH_CP_INITX_64TBL_MCS",
    "PUSCH_CP_UNSUCC_64TBL_MCS",
    "PUSCH_CP_SUCC_INI_64TBL_MCS",
    "PUSCH_CP_SUCC_ANY_64TBL_MCS",
    "PUSCH_CP_RANK1_64TBL_MCS",
    "PUSCH_CP_RANK2_64TBL_MCS",
]

CB008246_P_009_HR_traffic_check_kpi_names_value_zero = [
    "4_PDSCH_SUCC_INI_64TBL_MCS",
    "5_PDSCH_SUCC_ANY_64TBL_MCS",
    "6_PDSCH_UNSUCC_64TBL_MCS",
    "8_PDSCH_RANK2_64TBL_MCS",
    "9_PDSCH_RANK3_64TBL_MCS",
    "10_PDSCH_RANK4_64TBL_MCS",
    "12_PDSCH_4TX_RI_PM1",
    "13_PDSCH_4TX_RANK_PMI",
    "14_Init_BLER_BR_LOWSE_DL_PDSCH_tx",
    "18_Resid_BLER_BR_DL_PDSCH_tx",
    "24_PDSCH_RANK3_LOWSE_MCS",
    "25_PDSCH_RANK4_LOWSE_MCS",
    "28_PDSCH_INITX_64TBL_MCS"
]

CB008246_P_009_HR_traffic_check_kpi_names_larger_zero = [
    "8246_SUM_PUSCH_CP_INI_LowSE_MCS", "8246_SUM_PUSCH_CP_SUCC_INI_LOWSE_MCS", "8246_SUM_PUSCH_CP_SUCC_ANY_LOWSE_MCS",
    "8246_SUM_PUSCH_CP_INI_VOL_LOWSE_MCS", "8246_SUM_PUSCH_CP_INRE_VOL_LOWSE_MCS",
    "DATA_SLOT_PUSCH", "DATA_SLOT_PUSCH_TIME", "PUSCH_OFDM_SYMBOLS",
    "PUSCH_OFDM_SYMBOLS_TIME", "PRB_USED_PUSCH", "PRB_AVAIL_PUSCH", "UL_MAC_SDU_VOL_DTCH", "ACC_UE_UL_DRB_DATA"
]

# 8246-K
CB008246_K_04_HR_DRB_setup = [
    "HRDRB_TRIGG_REL_SCELL_ATT_SA",
    "HRDRB_TRIGG_REL_SCELL_SUC_SA",
    "DL_RRC_FSCELL_REL_ATT_SA",
    "DL_RRC_FSCELL_REL_SUC_SA",
    "DL_RRC_FEXTSCELL_REL_ATT_SA",
    "DL_RRC_FEXTSCELL_REL_SUC_SA",
]

CB008246_K_04_HR_GBR_non_GBR_setup_not_incremented_in_PCEL = [
    "A2MEAS_REL1DLSCELL_ATT_SA", "A2MEAS_REL1DLSCELL_SUCC_SA",
    "A2MEAS_REL1DLSCELL_ATT_NSA", "A2MEAS_REL1DLSCELL_SUCC_NSA", "A2MEAS_REL1ULSCELL_ATT_SA",
    "A2MEAS_REL1ULSCELL_SUCC_SA", "INA_PRO_REL_SCELL_ATT_SA", "INA_PRO_REL_SCELL_SUC_SA",
    "INA_OVHT_REL_SCELL_ATT_SA", "INA_OVHT_REL_SCELL_SUC_SA", "BAD_RLQ_REL_SCELL_ATT_SA",
    "BAD_RLQ_REL_SCELL_SUC_SA", "INA_PRO_REL_SCELL_ATT_NSA", "INA_PRO_REL_SCELL_SUC_NSA",
    "BAD_RLQ_REL_SCELL_ATT_NSA", "BAD_RLQ_REL_SCELL_SUC_NSA"
]

CB008246_K_04_scell_release = [
    "DL_RRC_1SCELL_REL_ATT_SA",
    "DL_RRC_1SCELL_REL_SUC_SA",
    "DL_RRC_1EXTSCELL_REL_ATT_SA",
    "DL_RRC_1EXTSCELL_REL_SUC_SA",
]

CB008246_K_legacy_DL_traffic_check_kpi_names_value_zero = [
    "1_HR_LOWSE_DL_PDSCH",
    "2_PDSCH_INITX_LOWSE_MCS",
    "3_BR_LOWSE_DL_PDSCH",
    "4_PDSCH_SUCC_INI_LOWSE_MCS",
    "5_PDSCH_SUCC_ANY_LOWSE_MCS",
    "6_PDSCH_UNSUCC_LOWSE_MCS",
    "7_PDSCH_RANK1_LOWSE_MCS",
    "8_PDSCH_RANK3_LOWSE_MCS",
    "9_PDSCH_RANK4_LOWSE_MCS",
    "10_PDSCH_INI_VOL_LOWSE_MCS",
    "11_PDSCH_INIRE_VOL_LOWSE_MCS",
]

CB008246_K_legacy_DL_traffic_check_kpi_names_larger_zero = [
    "12_PDSCH_INITX_64TBL_MCS",
    "13_PDSCH_SUCC_INI_64TBL_MCS",
    "14_PDSCH_SUCC_ANY_64TBL_MCS",
    "20_WB_CQI_64TBL_CQI",
    "22_PDSCH_INIRE_VOL_64TBL_MCS",
]

CB008246_K_legacy_DL_traffic_check_kpi_names_formula_established = [
    "16_PDSCH_RANK1_64TBL_MCS",
    "17_PDSCH_RANK2_64TBL_MCS",
    "18_PDSCH_RANK3_64TBL_MCS",
    "19_PDSCH_RANK4_64TBL_MCS",
    "24_PDSCH_INITX_64TBL_BR"
]
K_legacy_00 = CB008246_K_legacy_DL_traffic_check_kpi_names_formula_established[0]
K_legacy_01 = CB008246_K_legacy_DL_traffic_check_kpi_names_formula_established[1]
K_legacy_02 = CB008246_K_legacy_DL_traffic_check_kpi_names_formula_established[2]
K_legacy_03 = CB008246_K_legacy_DL_traffic_check_kpi_names_formula_established[3]
K_legacy_04 = CB008246_K_legacy_DL_traffic_check_kpi_names_formula_established[4]

CB008246_K_legacy_DL_traffic_check_kpi_names_less_specified_value = [
    "23_Init_BLER_legacy_DL_PDSCH"
]

CB008246_K_011_scell_release_check_kpi_names_value = [
    "HRDRB_TRIGG_REL_SCELL_ATT_NSA",
    "HRDRB_TRIGG_REL_SCELL_SUC_NSA",
    "DL_RRC_1SCELL_REL_ATT_NSA",
    "DL_RRC_1SCELL_REL_SUC_NSA",
]

CB008246_K_011_HR_traffic_check_kpi_names_value_zero = [
    "4_PDSCH_SUCC_INI_64TBL_MCS",
    "5_PDSCH_SUCC_ANY_64TBL_MCS",
    "6_PDSCH_UNSUCC_64TBL_MCS",
    "7_PDSCH_RANK1_64TBL_MCS",
    "8_PDSCH_RANK2_64TBL_MCS",
    "9_PDSCH_RANK3_64TBL_MCS",
    "10_PDSCH_RANK4_64TBL_MCS",
    "11_PDSCH_2TX_RI_PM1",
    "14_Init_BLER_BR_LOWSE_DL_PDSCH_tx",
    "15_PDSCH_INIRE_VOL_64TBL_MCS",
    "16_PDSCH_INI_VOL_64TBL_MCS",
    "18_Resid_BLER_BR_DL_PDSCH_tx",
    "22_PDSCH_RANK1_LOWSE_MCS",
    "24_PDSCH_RANK3_LOWSE_MCS",
    "28_PDSCH_INITX_64TBL_MCS"
]

CB008246_K_011_HR_traffic_check_kpi_names_larger_zero = [
    "3_PDSCH_INITX_LOWSE_MCS",
    "19_PDSCH_SUCC_INI_LOWSE_MCS",
    "20_PDSCH_SUCC_ANY_LOWSE_MCS",
    "25_PDSCH_RANK4_LOWSE_MCS",
    "26_PDSCH_INI_VOL_LOWSE_MCS",
    "27_PDSCH_INIRE_VOL_LOWSE_MCS"
]

CB008246_K_011_HR_traffic_check_kpi_names_less_specified_value = [
    "1_Init_BLER_HR_LOWSE_DL_PDSCH"
]

CB008246_K_011_HR_traffic_check_kpi_names_greater_than_or_equal_specfied = [
    "21_PDSCH_UNSUCC_LOWSE_MCS"
]

CB008246_K_018_HR_traffic_check_kpi_names_value_zero = [
    "PUSCH_INITX_64TBL_HRD_PRFL1", "PUSCH_SUCC_INI_64TBL_HRD_PRFL1", "PUSCH_UNSUCC_64TBL_HRD_PRFL1",
    "PUSCH_CP_UNSUCC_64TBL_MCS_00_31", "PUSCH_CP_INITX_64TBL_MCS_00_28", "PUSCH_CP_SUCC_ANY_64TBL_MCS_00_31",
    "PUSCH_CP_RANK1_64TBL_MCS_00_28", "PUSCH_CP_RANK2_64TBL_MCS_00_28",
    "PUSCH_INITX_64TBL_HRD_PRFL2", "PUSCH_SUCC_INI_64TBL_HRD_PRFL2", "PUSCH_SUCC_ANY_64TBL_HRD_PRFL2",
    "PUSCH_UNSUCC_64TBL_HRD_PRFL2", "PUSCH_INITX_LOWSE_BRDRB", "PUSCH_SUCC_INI_LOWSE_BRDRB",
    "PUSCH_SUCC_ANY_LOWSE_BRDRB", "PUSCH_UNSUCC_LOWSE_BRDRB", "PUSCH_INITX_LOWSE_HRD_PRFL1",
    "PUSCH_SUCC_INI_LOWSE_HRD_PRFL1", "PUSCH_INITX_LOWSE_HRD_PRFL2", "PUSCH_SUCC_ANY_LOWSE_HRD_PRFL1",
    "PUSCH_UNSUCC_LOWSE_HRD_PRFL1", "PUSCH_SUCC_INI_LOWSE_HRD_PRFL2", "PUSCH_SUCC_ANY_LOWSE_HRD_PRFL2",
    "PUSCH_UNSUCC_LOWSE_HRD_PRFL2", "PUSCH_CP_INI_LOWSE_MCS_00_28", "PUSCH_CP_SUCC_ANY_LOWSE_MCS_00_31",
    "PUSCH_CP_UNSUCC_LOWSE_MCS_00_31", "PUSCH_CP_SUCC_INI_LOWSE_MCS_00_28", "PUSCH_CP_RANK1_LOWSE_MCS_00_31",
    "PUSCH_CP_RANK2_LOWSE_MCS_00_31", "PUSCH_CP_INI_VOL_LOWSE_MCS_00_28", "PUSCH_CP_INRE_VOL_LOWSE_MCS_00_31"
]

CB008246_K_018_HR_traffic_check_kpi_names_larger_zero = [
    "PUSCH_DFT_INI_64TBL_MCS_00_27", "PUSCH_DFT_SUCC_INI_64TBL_MCS00_27", "PUSCH_DFT_SUCC_ANY_64TBL_MCS00_31"
]

CB008246_Q_legacy_DL_traffic_check_kpi_names_larger_zero_cell = [
    "NRRCC_RRC_RESUME_REQUEST1",
    "NRRCC_RRC_RESUME_SUCC",
    "NRD_RRC_RESUME_REQUEST1",
    "NRD_RRC_RESUME_SUCC",
    "NRDU_F1AP_UECTX_STPREQ_REC_CEL",
    "NRDU_F1AP_UECTX_STPRESP_CELL",
    "NF1CC_UECTXT_STP_REQSENT",
    "NF1CC_UECTXT_STP_RESPRECD",
    "NG_FLOW_RESUME_RRC_INACT_CONN"
]

CB008246_Q_legacy_DL_traffic_check_kpi_names_larger_zero_bts = [
    "NE1US_CTXT_MOD_REQ_RECD",
    "NE1US_CTXT_MOD_RSP_SENT",
]
