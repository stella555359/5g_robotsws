from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Shi Ming'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'ming.shi@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].instance_id)
_global_id = str(tl.gnbs[0].global_bts_id)
_gnb_id2 = str(tl.gnbs[1].instance_id)
_MRBTSname = 'MRBTS-' + _global_id
_MRBTSname2 = 'MRBTS-' + _gnb_id2
_NRBTSname = _MRBTSname + '/NRBTS-' + _gnb_id
_NRBTSname2 = _MRBTSname2 + '/NRBTS-' + _gnb_id2
_NRCELLname = _NRBTSname + '/NRCELL-1'
# _NRCELL2name = _NRBTSname+'/NRCELL-3'
_NRCELL3name = _NRBTSname + '/NRCELL-3'
_NRCELL2name = _NRBTSname + '/NRCELL-2'
_NRCELLname2 = _NRBTSname2 + '/NRCELL-1'
_NRDRB15name = _NRBTSname + '/NRDRB-15'
_enb_id = str(tl.gnbs[0].instance_id + 10)
_LNBTSname = _MRBTSname + '/LNBTS-' + _enb_id
_LTECELLname = _LNBTSname + '/LNCEL-4'
_SERVEDAMF_1 = _NRBTSname + '/SERVEDAMF-1'
_SERVEDAMF_2 = _NRBTSname + '/SERVEDAMF-2'
_SERVEDAMF_3 = _NRBTSname + '/SERVEDAMF-3'

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

_NRRELLnamegnb1 = _NRCELLname + '/NRREL-4'
_NRRELL400_3namegnb1 = _NRCELL400name + '/NRREL-3'
_NRRELLnamegnb1_358 = _NRCELLname + '/NRREL-1'
_NRRELLnamegnb1_383 = _NRCELLname + '/NRREL-1'
PATH_TO_SCF = ''

CB008700_ciphering_algorithms_json_file = 'CB008700_ciphering_algorithms.json'
CB008700_ciphering_algorithms = [
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

CB008700_recover_ciphering_algorithms_json_file = 'CB008700_recover_ciphering_algorithms.json'
CB008700_recover_ciphering_algorithms = [
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

CB008700_ciphering_algorithms_json_file_2 = 'CB008700_ciphering_algorithms_2.json'
CB008700_ciphering_algorithms_2 = [
    {
        "distName": _NRBTSname2,
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

CB008700_recover_ciphering_algorithms_json_file_2 = 'CB008700_recover_ciphering_algorithms_2.json'
CB008700_recover_ciphering_algorithms_2 = [
    {
        "distName": _NRBTSname2,
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

PARAM_8700_B_003 = [
    dict(value='locked', dist_name=_LTECELLname, parameter='administrativeState'),
    dict(value='0', dist_name=_NRCELL2name, parameter='maxNumOfGBRBearersSA'),
    dict(value='EnhancedVoNR', dist_name=_NRCELL2name, parameter='actGBRAdmissionControl'),
    dict(value='2', dist_name=_NRCELL3name, parameter='maxNumOfNonGBRBearersSA'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

# 8200 and 7564 source cell1 M55125C09015 M55125C09508 M55163C00515 target cell3
counter_id_B003 = [
    'M55125C10504', 'M55163C02001', 'M55138C02001', 'M55125C09015', 'M55125C09508', 'M55163C00515',
    'M55125C09013', 'M55125C09014', 'M55125C09524', 'M55125C09525', 'M55163C00513', 'M55163C00514',
]

counter_dic_path_B003 = [
    'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NRPMQAP-1/NGCCQ', 'BTS/CELLS/NRCELL-3/RSACU',
    'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NRPMQAP-1/NGCCQ',
    'BTS/CELLS/NRCELL-3/NNGCC', 'BTS/CELLS/NRCELL-3/NNGCC', 'BTS/CELLS/NRCELL-3/NNGCC',
    'BTS/CELLS/NRCELL-3/NNGCC', 'BTS/CELLS/NRCELL-3/NRPMQAP-1/NGCCQ', 'BTS/CELLS/NRCELL-3/NRPMQAP-1/NGCCQ',
]
counter_dic_path_B003_trunk = [
    f'BTS/{_NRBTSname}/NRCELL-1/NNGCC', f'BTS/{_NRBTSname}/NRCELL-1/NRPMQAP-1/NGCCQ',
    f'BTS/{_NRBTSname}/NRCELL-3/RSACU',
    f'BTS/{_NRBTSname}/NRCELL-1/NNGCC', f'BTS/{_NRBTSname}/NRCELL-1/NNGCC',
    f'BTS/{_NRBTSname}/NRCELL-1/NRPMQAP-1/NGCCQ',
    f'BTS/{_NRBTSname}/NRCELL-3/NNGCC', f'BTS/{_NRBTSname}/NRCELL-3/NNGCC', f'BTS/{_NRBTSname}/NRCELL-3/NNGCC',
    f'BTS/{_NRBTSname}/NRCELL-3/NNGCC', f'BTS/{_NRBTSname}/NRCELL-3/NRPMQAP-1/NGCCQ',
    f'BTS/{_NRBTSname}/NRCELL-3/NRPMQAP-1/NGCCQ',
]

PARAM_8700_recover_B_03 = [
    dict(value='unlocked', dist_name=_LTECELLname, parameter='administrativeState'),
    dict(value='10', dist_name=_NRCELL2name, parameter='maxNumOfGBRBearersSA'),
    dict(value='EnhancedVoNR', dist_name=_NRCELL2name, parameter='actGBRAdmissionControl'),
    dict(value='550', dist_name=_NRCELL3name, parameter='maxNumOfNonGBRBearersSA'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_8700_B_005 = [
    dict(value='locked', dist_name=_LTECELLname, parameter='administrativeState'),
    dict(value='0', dist_name=_NRCELL2name, parameter='maxNumOfGBRBearersSA'),
    dict(value='EnhancedVoNR', dist_name=_NRCELL2name, parameter='actGBRAdmissionControl'),
    dict(value='0', dist_name=_NRCELL3name, parameter='maxNumOfGBRBearersSA'),
    dict(value='EnhancedVoNR', dist_name=_NRCELL3name, parameter='actGBRAdmissionControl'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_8700_recover_B_05 = [
    dict(value='unlocked', dist_name=_LTECELLname, parameter='administrativeState'),
    dict(value='10', dist_name=_NRCELL2name, parameter='maxNumOfGBRBearersSA'),
    dict(value='EnhancedVoNR', dist_name=_NRCELL2name, parameter='actGBRAdmissionControl'),
    dict(value='10', dist_name=_NRCELL3name, parameter='maxNumOfGBRBearersSA'),
    dict(value='EnhancedVoNR', dist_name=_NRCELL3name, parameter='actGBRAdmissionControl'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

counter_id_D002 = [
    'M55125C10504', 'M55163C02001',
]

counter_dic_path_D002 = [
    'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NRPMQAP-1/NGCCQ'
]
counter_dic_path_D002_trunk = [
    f'BTS/{_NRBTSname}/NRCELL-1/NNGCC', f'BTS/{_NRBTSname}/NRCELL-1/NRPMQAP-1/NGCCQ'
]

counter_id_D002_2 = [
    'M55138C02001'
]

counter_dic_path_D002_2 = [
    'BTS/CELLS/NRCELL-1/RSACU'
]
counter_dic_path_D002_2_trunk = [
    f'BTS/{_NRBTSname2}/NRCELL-1/RSACU'
]

PARAM_8700_D_002_358 = [
    dict(value='sourceAndTarget', dist_name=_NRBTSname, parameter='actIntraNrNgHo'),
    dict(value='3000', dist_name=_NRBTSname, parameter='tNgRelocExecDeltN'),
    dict(value='2000', dist_name=_NRBTSname, parameter='tNgRelocCancelN'),
    dict(value='2000', dist_name=_NRBTSname, parameter='tNgRelocOverallN'),
    dict(value='2000', dist_name=_NRBTSname, parameter='tNgRelocPrepN'),
    dict(value='XnHoNotAllowed', dist_name=_NRRELLnamegnb1_358, parameter='handoverAllowedSA'),
    dict(value='true', dist_name=_NRBTSname, parameter='actGeneralConnectivitySilver'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_8700_D_002 = [
    dict(value='locked', dist_name=_LTECELLname, parameter='administrativeState'),
    dict(value='sourceAndTarget', dist_name=_NRBTSname, parameter='actIntraNrNgHo'),
    dict(value='3000', dist_name=_NRBTSname, parameter='tNgRelocExecDeltN'),
    dict(value='2000', dist_name=_NRBTSname, parameter='tNgRelocCancelN'),
    dict(value='2000', dist_name=_NRBTSname, parameter='tNgRelocOverallN'),
    dict(value='2000', dist_name=_NRBTSname, parameter='tNgRelocPrepN'),
    dict(value='XnHoNotAllowed', dist_name=_NRRELLnamegnb1, parameter='handoverAllowedSA'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_8700_recover_D_02_358 = [
    dict(value='disabled', dist_name=_NRBTSname, parameter='actIntraNrNgHo'),
    dict(value='allowed', dist_name=_NRRELLnamegnb1_358, parameter='handoverAllowedSA'),
    dict(value='true', dist_name=_NRBTSname, parameter='actGeneralConnectivitySilver'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_DELETE_8700_D_002 = [
    dict(dist_name=_NRBTSname, parameter='tNgRelocExecDeltN'),
    dict(dist_name=_NRBTSname, parameter='tNgRelocCancelN'),
    dict(dist_name=_NRBTSname, parameter='tNgRelocOverallN'),
    dict(dist_name=_NRBTSname, parameter='tNgRelocPrepN')
]

PARAM_8700_recover_D_02 = [
    dict(value='unlocked', dist_name=_LTECELLname, parameter='administrativeState'),
    dict(value='disabled', dist_name=_NRBTSname, parameter='actIntraNrNgHo'),
    dict(value='allowed', dist_name=_NRRELLnamegnb1, parameter='handoverAllowedSA'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_8700_D_002_2 = [
    dict(value='basicTargetOnly', dist_name=_NRBTSname2, parameter='actIntraNrNgHo'),
    dict(value='3000', dist_name=_NRBTSname2, parameter='tNgRelocExecDeltN'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_8700_recover_D_02_2 = [
    dict(value='disabled', dist_name=_NRBTSname2, parameter='actIntraNrNgHo'),
    dict(value='3000', dist_name=_NRBTSname2, parameter='tNgRelocExecDeltN'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_DELETE_8700_D_02_2 = [
    dict(dist_name=_NRBTSname2, parameter='tNgRelocExecDeltN')
]

PARAM_8700_A_015_348 = [
    dict(value='locked', dist_name=_LTECELL48040name, parameter='administrativeState'),
    dict(value='locked', dist_name=_LTECELL48045name, parameter='administrativeState'),
    dict(value='Locked', dist_name=_SERVEDAMF_1, parameter='administrativeState'),
    # dict(value='Unlocked', dist_name=_SERVEDAMF_2, parameter='administrativeState'),
    dict(value='Unlocked', dist_name=_SERVEDAMF_3, parameter='administrativeState'),
    dict(value='on', dist_name=_NRCELL400name, parameter='actARPBasedAC'),
    dict(value='3', dist_name=_NRCELL400name, parameter='maxNumOfGBRBearersSA'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_8700_recover_A_015_348 = [
    dict(value='unlocked', dist_name=_LTECELL48040name, parameter='administrativeState'),
    dict(value='unlocked', dist_name=_LTECELL48045name, parameter='administrativeState'),
    dict(value='Unlocked', dist_name=_SERVEDAMF_1, parameter='administrativeState'),
    # dict(value='Locked', dist_name=_SERVEDAMF_2, parameter='administrativeState'),
    dict(value='Locked', dist_name=_SERVEDAMF_3, parameter='administrativeState'),
    dict(value='on', dist_name=_NRCELL400name, parameter='actARPBasedAC'),
    dict(value='10', dist_name=_NRCELL400name, parameter='maxNumOfGBRBearersSA'),
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
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

counter_id_EDA_03533909 = [
    'M55125C08503', 'M55163C00003', 'M55125C09005', 'M55125C09505', 'M55163C00506'
]

# CNI-150908
counter_value_EDA_03533909 = [3, 3, 0, 0, 0]
# counter_value_EDA_03533909 = [3, 3, 3, 1, 3]
counter_value_EDA_03533909_383 = [3, 0, 0, 0, 3]
# counter_value_EDA_03533909_383 = [3, 3, 3, 1, 3]

counter_dic_path_EDA_03533909 = [
    'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NRPMQAP-1/NGCCQ',
    'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NNGCC',
    'BTS/CELLS/NRCELL-1/NRPMQAP-1/NGCCQ'
]
counter_dic_path_EDA_03533909_trunk = [
    f'BTS/{_NRBTSname}/NRCELL-1/NNGCC', f'BTS/{_NRBTSname}/NRCELL-1/NRPMQAP-1/NGCCQ',
    f'BTS/{_NRBTSname}/NRCELL-1/NNGCC', f'BTS/{_NRBTSname}/NRCELL-1/NNGCC',
    f'BTS/{_NRBTSname}/NRCELL-1/NRPMQAP-1/NGCCQ'
]

counter_id_EDA_03533909_2 = [
    'M55125C08503', 'M55163C00003', 'M55125C09005', 'M55125C09505', 'M55163C00506'
]

# counter_value_EDA_03533909_2 = [3, 3, 0, 0, 0]
counter_value_EDA_03533909_2 = [0, 0, 0, 0, 0]
counter_value_EDA_03533909_2_383 = [2, 2, 0, 0, 0]

counter_dic_path_EDA_03533909_2 = [
    'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NRPMQAP-1/NGCCQ',
    'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NNGCC',
    'BTS/CELLS/NRCELL-1/NRPMQAP-1/NGCCQ'
]
counter_dic_path_EDA_03533909_2_trunk = [
    f'BTS/{_NRBTSname}/NRCELL-1/NNGCC', f'BTS/{_NRBTSname}/NRCELL-1/NRPMQAP-1/NGCCQ',
    f'BTS/{_NRBTSname}/NRCELL-1/NNGCC', f'BTS/{_NRBTSname}/NRCELL-1/NNGCC',
    f'BTS/{_NRBTSname}/NRCELL-1/NRPMQAP-1/NGCCQ'
]

PARAM_EDA_03533909 = [
    dict(value='locked', dist_name=_LTECELL48040name, parameter='administrativeState'),
    dict(value='locked', dist_name=_LTECELL48045name, parameter='administrativeState'),
    dict(value='Locked', dist_name=_NRCELL700name, parameter='administrativeState'),
    dict(value='Locked', dist_name=_NRCELL701name, parameter='administrativeState'),
    dict(value='sourceAndTarget', dist_name=_NRBTSname, parameter='actIntraNrNgHo'),
    dict(value='3000', dist_name=_NRBTSname, parameter='tNgRelocExecDeltN'),
    dict(value='2000', dist_name=_NRBTSname, parameter='tNgRelocCancelN'),
    dict(value='100', dist_name=_NRBTSname, parameter='tNgRelocOverall'),
    dict(value='10', dist_name=_NRBTSname, parameter='tNgRelocOverallN'),
    dict(value='2000', dist_name=_NRBTSname, parameter='tNgRelocPrepN'),
    dict(value='true', dist_name=_NRBTSname, parameter='suppCnPartialAdNgHo'),
    dict(value='XnHoNotAllowed', dist_name=_NRRELL400_3namegnb1, parameter='handoverAllowedSA'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_EDA_03533909_383 = [
    dict(value='locked', dist_name=_LTECELLname, parameter='administrativeState'),
    dict(value='sourceAndTarget', dist_name=_NRBTSname, parameter='actIntraNrNgHo'),
    dict(value='3000', dist_name=_NRBTSname, parameter='tNgRelocExecDeltN'),
    dict(value='2000', dist_name=_NRBTSname, parameter='tNgRelocCancelN'),
    dict(value='100', dist_name=_NRBTSname, parameter='tNgRelocOverall'),
    dict(value='10', dist_name=_NRBTSname, parameter='tNgRelocOverallN'),
    dict(value='2000', dist_name=_NRBTSname, parameter='tNgRelocPrepN'),
    dict(value='true', dist_name=_NRBTSname, parameter='suppCnPartialAdNgHo'),
    dict(value='XnHoNotAllowed', dist_name=_NRRELLnamegnb1_383, parameter='handoverAllowedSA'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_DELETE_EDA_03533909 = [
    dict(dist_name=_NRBTSname, parameter='tNgRelocExecDeltN'),
    dict(dist_name=_NRBTSname, parameter='tNgRelocCancelN'),
    dict(dist_name=_NRBTSname, parameter='tNgRelocOverallN'),
    dict(dist_name=_NRBTSname, parameter='tNgRelocPrepN'),
    dict(dist_name=_NRBTSname, parameter='suppCnPartialAdNgHo')
]

PARAM_DELETE_EDA_03533909_383 = [
    dict(dist_name=_NRBTSname, parameter='tNgRelocExecDeltN'),
    dict(dist_name=_NRBTSname, parameter='tNgRelocCancelN'),
    dict(dist_name=_NRBTSname, parameter='tNgRelocOverallN'),
    dict(dist_name=_NRBTSname, parameter='tNgRelocPrepN'),
    dict(dist_name=_NRBTSname, parameter='suppCnPartialAdNgHo')
]

PARAM_recover_EDA_03533909 = [
    dict(value='unlocked', dist_name=_LTECELL48040name, parameter='administrativeState'),
    dict(value='unlocked', dist_name=_LTECELL48045name, parameter='administrativeState'),
    dict(value='Unlocked', dist_name=_NRCELL700name, parameter='administrativeState'),
    dict(value='Unlocked', dist_name=_NRCELL701name, parameter='administrativeState'),
    dict(value='sourceAndTarget', dist_name=_NRBTSname, parameter='actIntraNrNgHo'),
    dict(value='5000', dist_name=_NRBTSname, parameter='tNgRelocOverall'),
    dict(value='allowed', dist_name=_NRRELL400_3namegnb1, parameter='handoverAllowedSA'),
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
    #      parameter='integrityProtPrefL')
]

PARAM_recover_EDA_03533909_383 = [
    dict(value='unlocked', dist_name=_LTECELLname, parameter='administrativeState'),
    dict(value='disabled', dist_name=_NRBTSname, parameter='actIntraNrNgHo'),
    dict(value='3000', dist_name=_NRBTSname, parameter='tNgRelocOverall'),
    dict(value='allowed', dist_name=_NRRELLnamegnb1_383, parameter='handoverAllowedSA'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_EDA_03533909_2 = [
    dict(value='basicTargetOnly', dist_name=_NRBTSname2, parameter='actIntraNrNgHo'),
    dict(value='3000', dist_name=_NRBTSname2, parameter='tNgRelocExecDeltN'),
    dict(value='true', dist_name=_NRBTSname2, parameter='suppCnPartialAdNgHo'),
    # dict(value='false', dist_name=_NRBTSname2, parameter='actIntraFreqHoSA'),
    # dict(value='false', dist_name=_NRBTSname2, parameter='actSaUeBasedAnrNr'),
    dict(value='false', dist_name=_NRBTSname2, parameter='actSaUeBasedInterFreqAnrNr'),
    dict(value='false', dist_name=_NRBTSname2, parameter='actInterFreqHoSA'),
    dict(value='none', dist_name=_NRBTSname2, parameter='actA1HoPrefNRLayer'),
    dict(value='none', dist_name=_NRBTSname2, parameter='actHigherPrioFreqHo'),
    # dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname2,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname2,
    #      parameter='integrityProtPrefL')
]

PARAM_recover_EDA_03533909_2 = [
    dict(value='disabled', dist_name=_NRBTSname2, parameter='actIntraNrNgHo'),
    # dict(value='true', dist_name=_NRBTSname2, parameter='actIntraFreqHoSA'),
    # dict(value='true', dist_name=_NRBTSname2, parameter='actSaUeBasedAnrNr'),
    dict(value='true', dist_name=_NRBTSname2, parameter='actSaUeBasedInterFreqAnrNr'),
    dict(value='true', dist_name=_NRBTSname2, parameter='actInterFreqHoSA'),
    dict(value='SA+NSA', dist_name=_NRBTSname2, parameter='actA1HoPrefNRLayer'),
    dict(value='SA+NSA', dist_name=_NRBTSname2, parameter='actHigherPrioFreqHo'),
    # dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname2,
    #      parameter='cipherPrefL'),
    # dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname2,
    #      parameter='integrityProtPrefL')
]

PARAM_DELETE_EDA_03533909_2 = [
    dict(dist_name=_NRBTSname2, parameter='tNgRelocExecDeltN'),
    dict(dist_name=_NRBTSname2, parameter='suppCnPartialAdNgHo'),
]

PARAM_8200_B_002 = [
    dict(value='false', dist_name=_NRCELL2name, parameter='actVoNR'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELL2name, parameter='voiceFBMode'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actCDrxVoNR'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actEmergencyCall'),
    dict(value='true', dist_name=_NRBTSname, parameter='actEmergencyFallback'),
    dict(value='40', dist_name=_NRBTSname, parameter='srbInactivityTimerSA'),
    dict(value='40', dist_name=_NRBTSname, parameter='drbInactivityTimerSA'),
    dict(value='deactivated', dist_name=_NRBTSname, parameter='rrcReestabTypeSA'),
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrxVoNR')
]
PARAM_DELETE_8200_B_002 = [
    dict(dist_name=_NRCELL2name, parameter='n310VoNR'),
    dict(dist_name=_NRCELL2name, parameter='t310VoNR')
]
PARAM_8200_recover_B_002 = [
    dict(value='true', dist_name=_NRCELL2name, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELL2name, parameter='voiceFBMode'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actEmergencyCall'),
    dict(value='true', dist_name=_NRBTSname, parameter='actEmergencyFallback'),
    dict(value='600', dist_name=_NRBTSname, parameter='srbInactivityTimerSA'),
    dict(value='600', dist_name=_NRBTSname, parameter='drbInactivityTimerSA'),
    dict(value='deactivated', dist_name=_NRBTSname, parameter='rrcReestabTypeSA'),
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrxVoNR')
]
PARAM_ADD_8200_B_002 = [
    dict(value='n10', dist_name=_NRCELL2name, parameter='n310VoNR'),
    dict(value='2000ms', dist_name=_NRCELL2name, parameter='t310VoNR')
]

PARAM_8200_B_009 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actEmergencyCall')
]
PARAM_8200_recover_B_009 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actEmergencyCall')
]

PARAM_8200_B_010_1 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall')
]
PARAM_8200_recover_B_010_1 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall')
]
PARAM_8200_B_010_2 = [
    dict(value='true', dist_name=_NRCELLname2, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname2, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRCELLname2, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRBTSname2, parameter='actNrpmqapProfiles'),
    dict(value='true', dist_name=_NRCELLname2, parameter='actEmergencyCall')
]
PARAM_8200_recover_B_010_2 = [
    dict(value='true', dist_name=_NRCELLname2, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname2, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRCELLname2, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRBTSname2, parameter='actNrpmqapProfiles'),
    dict(value='true', dist_name=_NRCELLname2, parameter='actEmergencyCall')
]

PARAM_8200_B_012 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actEmergencyCall'),
    dict(value='sameGNB', dist_name=_NRBTSname, parameter='rrcReestabTypeSA')
]
PARAM_8200_recover_B_012 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actEmergencyCall'),
    dict(value='deactivated', dist_name=_NRBTSname, parameter='rrcReestabTypeSA')
]

_mcc = str(tl.core.mcc)
_mnc = str(tl.core.mnc)
_ho_path1 = 'BTS/CELLS/NRCELL-1/NNGCC'
_ho_path2 = 'BTS/CELLS/NRCELL-1/NRPMQAP-1/NGCCQ'
_ho_path3 = 'BTS/CELLS/NRCELL-1/NRRCC'
_ho_path4 = 'BTS/CELLS/NRCELL-2/NNGCC'
_ho_path5 = 'BTS/CELLS/NRCELL-2/NRPMQAP-1/NGCCQ'
_ho_path6 = 'BTS/CELLS/NRCELL-1/NDLSQ'
NG_FLOW_SETUP_FAIL_FALLBACK = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09008'}
NG_FLOW_STP_FAIL_FALBACK_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00501'}
NG_FLOW_STP_FAIL_FALBACK_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09519'}
NR_RRC_RELEASE_REDIR_VFB_LTE = {'gnb_id': 1, 'dic_path': _ho_path3, 'counter_id': 'M55124C02501'}

NG_FLOW_REL_GNB_UE_INACTIVITY = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09004'}

NG_FLOW_SETUP_FAIL_WRONG_MSG = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09012'}
NG_FLOW_STP_FAIL_WRG_MSG_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09523'}
NG_FLOW_STP_FAIL_WRG_MSG_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00512'}

NG_FLOW_SETUP_FAIL_UNSPECIFIED = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09011'}
NG_FLOW_SETUP_FAIL_UNSPC_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00511'}
NG_FLOW_SETUP_FAIL_UNSPC_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09522'}

NG_FLOW_STP_ATT_INC_HO_5QI1_1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09524'}
NG_FLOW_STP_SUC_INC_HO_5QI1_1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09525'}
NG_FLOW_STP_ATT_INC_HO_PMQAP_1 = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00513'}
NG_FLOW_STP_SUC_INC_HO_PMQAP_1 = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00514'}
NG_FLOW_STP_ATT_INC_HO_5QI1_2 = {'gnb_id': 1, 'dic_path': _ho_path4, 'counter_id': 'M55125C09524'}
NG_FLOW_STP_SUC_INC_HO_5QI1_2 = {'gnb_id': 1, 'dic_path': _ho_path4, 'counter_id': 'M55125C09525'}
NG_FLOW_STP_ATT_INC_HO_PMQAP_2 = {'gnb_id': 1, 'dic_path': _ho_path5, 'counter_id': 'M55163C00513'}
NG_FLOW_STP_SUC_INC_HO_PMQAP_2 = {'gnb_id': 1, 'dic_path': _ho_path5, 'counter_id': 'M55163C00514'}
NG_FLOW_STP_ATT_INC_HO = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09013'}
NG_FLOW_STP_SUC_INC_HO = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09014'}

NG_FLOW_STP_ATT_INC_HO_5QI1_3 = {'gnb_id': 2, 'dic_path': _ho_path1, 'counter_id': 'M55125C09524'}
NG_FLOW_STP_SUC_INC_HO_5QI1_3 = {'gnb_id': 2, 'dic_path': _ho_path1, 'counter_id': 'M55125C09525'}
NG_FLOW_STP_ATT_INC_HO_PMQAP_3 = {'gnb_id': 2, 'dic_path': _ho_path2, 'counter_id': 'M55163C00513'}
NG_FLOW_STP_SUC_INC_HO_PMQAP_3 = {'gnb_id': 2, 'dic_path': _ho_path2, 'counter_id': 'M55163C00514'}

NG_FLOW_REL_IRAT_SUC_HO_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09509'}
NG_FLOW_REL_IRAT_SUC_HO_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00516'}

NG_FLOW_STP_ATT_RES_IADU_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00530'}
NG_FLOW_STP_ATT_RES_IADU_5QI1 = {'gnb_id': 2, 'dic_path': _ho_path1, 'counter_id': 'M55125C09531'}
NG_FLOW_STP_SUC_RES_IADU_PMQAP = {'gnb_id': 2, 'dic_path': _ho_path2, 'counter_id': 'M55163C00531'}
NG_FLOW_STP_SUC_RES_IADU_5QI1 = {'gnb_id': 2, 'dic_path': _ho_path1, 'counter_id': 'M55125C09532'}
NG_FLOW_STP_ATT_REEST_IADU = {'gnb_id': 2, 'dic_path': _ho_path1, 'counter_id': 'M55125C09023'}
NG_FLOW_STP_SUC_REEST_IADU = {'gnb_id': 2, 'dic_path': _ho_path1, 'counter_id': 'M55125C09024'}

NG_FLOW_SETUP_ATT_TOT_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09517'}
NG_FLOW_SETUP_SUCC_TOT_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09518'}
NG_FLOW_REL_AMF_NORMAL_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09512'}
NG_FLOW_REL_AMF_NORMAL_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00519'}
NG_FLOW_REL_NORMAL_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09514'}
NG_FLOW_REL_AMF_NORMAL = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09019'}

WB_CQI_64TBL_5QI1_CQI0 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C21000'}
WB_CQI_256TBL_5QI1_CQI0 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C22000'}

NG_FLOW_REL_GNB_REDIRECT = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09002'}
NG_FLOW_REL_GNB_REDIRECT_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09502'}
NG_FLOW_REL_GNB_REDIRECT_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00503'}

NG_FLOW_REL_GNB_RLF = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09003'}
NG_FLOW_REL_GNB_RLF_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09503'}
NG_FLOW_REL_GNB_RLF_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00504'}

AMOUNT_OF_CELLS = 1
