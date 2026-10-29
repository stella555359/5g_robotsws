from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Shi Ming'
__email__ = 'ming.shi@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_enb_id = str(tl.enbs[0].instance_id)
_gnb_id = str(tl.gnbs[0].instance_id)
_global_id = str(tl.gnbs[0].global_bts_id)
_MRBTSname = 'MRBTS-' + _global_id
_MRBTSname_enb = 'MRBTS-' + _global_id
_NRBTSname = _MRBTSname + '/NRBTS-' + _gnb_id
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
_NRCELL600name = _NRBTSname + '/NRCELL-600'
_NRCELL601name = _NRBTSname + '/NRCELL-601'
_NRCELL700name = _NRBTSname + '/NRCELL-700'
_NRCELL701name = _NRBTSname + '/NRCELL-701'
_NRBTSDUname = _NRBTSname + '/NRDU-9999'
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
_NRREL21namegnb1 = _NRCELL2name + '/NRREL-1'
_SERVEDAMF = _NRBTSname + '/SERVEDAMF-1'
_NRCELL1_FDD1 = _NRCELLname + '/NRCELL_FDD-1'
_NRCELL2_FDD1 = _NRCELL2name + '/NRCELL_FDD-1'
_NRCELL400_FDD1 = _NRCELL400name + '/NRCELL_FDD-1'
_BWP_PROFILE_0 = _NRBTSname + '/BWP_PROFILE-0'
_BWP_PROFILE_7 = _NRBTSname + '/BWP_PROFILE-7'
_BWP_PROFILE_8 = _NRBTSname + '/BWP_PROFILE-8'
_NRULCG_PROFILE_2 = _NRBTSname + '/NRULCG_PROFILE-2'
_NRDRB_13 = _NRBTSname + '/NRDRB-13'
_NRPMRNL = _NRBTSname + '/NRPMRNL-1'
_NRDLMUMIMO_1_700 = _NRCELL700name + '/NRDLMUMIMO-1'
_NRDRB_MAC_2 = _NRBTSname + '/NRDRB_MAC-2'
_BWP_PROFILE_1 = _NRBTSname + '/BWP_PROFILE-1'
_BWP_PROFILE_11 = _NRBTSname + '/BWP_PROFILE-11'
_BWP_PROFILE_111 = _NRBTSname + '/BWP_PROFILE-111'
_BWP_PROFILE_1111 = _NRBTSname + '/BWP_PROFILE-1111'
_BWP_PROFILE_2 = _NRBTSname + '/BWP_PROFILE-2'
_BWP_PROFILE_21 = _NRBTSname + '/BWP_PROFILE-21'
_BWP_PROFILE_31 = _NRBTSname + '/BWP_PROFILE-31'
_BWP_PROFILE_78 = _NRBTSname + '/BWP_PROFILE-78'
_BWP_PROFILE_251 = _NRBTSname + '/BWP_PROFILE-251'
_BWP_PROFILE_252 = _NRBTSname + '/BWP_PROFILE-252'
_BWP_PROFILE_253 = _NRBTSname + '/BWP_PROFILE-253'
_BWP_PROFILE_42 = _NRBTSname + '/BWP_PROFILE-42'
_BWP_PROFILE_172 = _NRBTSname + '/BWP_PROFILE-172'
_BWP_PROFILE_182 = _NRBTSname + '/BWP_PROFILE-182'

NRCELL400name = _NRBTSname + '/NRCELL-400'
NRCELL600name = _NRBTSname + '/NRCELL-600'
NRCELL700name = _NRBTSname + '/NRCELL-700'
NRCELL701name = _NRBTSname + '/NRCELL-701'

PARAMETERS_CB008148_A_B01_TC002_JSON_FILE = 'PARAMETERS_CB008148_A_B01_TC002_JSON_FILE.json'
PARAMETERS_CB008148_A_B01_TC002 = [
    {
        "distName": _NRCELL601name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "value": "Locked",
                "operation": "update"
            }
        ]
    },
    {
        "distName": _NRCELL600name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actUlTransPreUsageEnh",
                "value": ["Msg3_TPOn"],
                "operation": "update"
            },
            {
                "parameterName": "actSmallestRRCSetup",  # cell reset
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "ueConnectionEstablishmentMode",
                "value": "useInitialBwp",
                "operation": "update"
            },
            {
                "parameterName": "ulTransPrecodeCtl",
                "value": [
                    dict(ulTpOffOnTriggerSpeedThresh='100',
                         ulTpOnOffTriggerSpeedThresh='100',
                         ulTransPrecodeOffSinrThresh='95',
                         ulTransPrecodeOffSinrThrRedCap='35',
                         ulTransPrecodeOnSinrThresh='65',
                         ulTransPrecodeOnSinrThrRedCap='15',
                         ulTransPrecodePi2Bpsk='true',
                         ulTransPrePi2BpskPwrBoost='false')
                ],
                "operation": "update"
            },
            {
                "parameterName": "cellBwpList",
                "value": [
                    dict(actPdcchCceFragmentControl='false',
                         actUpperThrAckNackFiltering='false',
                         actUpperThrAckNackHrFiltering='false',
                         bwpDN=_BWP_PROFILE_2,
                         cellBwpId='0',
                         pdcchResourcePreference='peakRate'),
                    dict(actPdcchCceFragmentControl='false',
                         actUpperThrAckNackFiltering='true',
                         actUpperThrAckNackHrFiltering='true',
                         bwpDN=_BWP_PROFILE_21,
                         cellBwpId='1',
                         pdcchResourcePreference='peakRate'),
                    dict(actPdcchCceFragmentControl='false',
                         actUpperThrAckNackFiltering='true',
                         actUpperThrAckNackHrFiltering='true',
                         bwpDN=_BWP_PROFILE_31,
                         cellBwpId='2',
                         pdcchResourcePreference='peakRate'),
                    dict(actPdcchCceFragmentControl='false',
                         actUpperThrAckNackFiltering='true',
                         actUpperThrAckNackHrFiltering='true',
                         bwpDN=_BWP_PROFILE_78,
                         cellBwpId='3',
                         pdcchResourcePreference='peakRate'),
                ],
                "operation": "update"
            },
        ]
    },
    {
        "distName": _NRBTSname,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actEnhRrcReconfUlPrbRandom",
                "operation": "update",
                "value": 'false'
            },
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

PARAMETERS_RECOVER_CB008148_A_B01_TC002_JSON_FILE = 'PARAMETERS_RECOVER_CB008148_A_B01_TC002_JSON_FILE.json'
PARAMETERS_RECOVER_CB008148_A_B01_TC002 = [
    {
        "distName": _NRCELL601name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "value": "Unlocked",
                "operation": "update"
            }
        ]
    },
    {
        "distName": _NRCELL600name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actUlTransPreUsageEnh",
                "value": ["disabled"],
                "operation": "update"
            },
            {
                "parameterName": "actSmallestRRCSetup",  # cell reset
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "ueConnectionEstablishmentMode",
                "value": "useDedicatedBwp",
                "operation": "update"
            },
            {
                "parameterName": "ulTransPrecodeCtl",
                "value": [
                    dict(ulTpOffOnTriggerSpeedThresh='100',
                         ulTpOnOffTriggerSpeedThresh='100',
                         ulTransPrecodeOffSinrThresh='35',
                         ulTransPrecodeOffSinrThrRedCap='35',
                         ulTransPrecodeOnSinrThresh='15',
                         ulTransPrecodeOnSinrThrRedCap='15',
                         ulTransPrecodePi2Bpsk='true',
                         ulTransPrePi2BpskPwrBoost='false')
                ],
                "operation": "update"
            },
            {
                "parameterName": "cellBwpList",
                "value": [
                    dict(actPdcchCceFragmentControl='false',
                         actUpperThrAckNackFiltering='false',
                         actUpperThrAckNackHrFiltering='false',
                         bwpDN=_BWP_PROFILE_1,
                         cellBwpId='0',
                         pdcchResourcePreference='peakRate'),
                    dict(actPdcchCceFragmentControl='false',
                         actUpperThrAckNackFiltering='true',
                         actUpperThrAckNackHrFiltering='true',
                         bwpDN=_BWP_PROFILE_11,
                         cellBwpId='1',
                         pdcchResourcePreference='peakRate'),
                    dict(actPdcchCceFragmentControl='false',
                         actUpperThrAckNackFiltering='true',
                         actUpperThrAckNackHrFiltering='true',
                         bwpDN=_BWP_PROFILE_111,
                         cellBwpId='2',
                         pdcchResourcePreference='peakRate'),
                    dict(actPdcchCceFragmentControl='false',
                         actUpperThrAckNackFiltering='true',
                         actUpperThrAckNackHrFiltering='true',
                         bwpDN=_BWP_PROFILE_1111,
                         cellBwpId='3',
                         pdcchResourcePreference='peakRate'),
                ],
                "operation": "update"
            },
        ]
    },
    {
        "distName": _NRBTSname,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actEnhRrcReconfUlPrbRandom",
                "operation": "update",
                "value": 'true'
            },
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

CB008148_A_B01_TC002_CELLS = [NRCELL600name]
CB008148_A_B01_TC002_CELLS_STATUS = [['disabled'], ['enabled']]

PARAMETERS_CB008148_A_B01_TC004_JSON_FILE = 'PARAMETERS_CB008148_A_B01_TC004_JSON_FILE.json'
PARAMETERS_CB008148_A_B01_TC004 = [
    {
        "distName": _LTECELL48040name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "value": "locked",
                "operation": "update"
            }
        ]
    },
    {
        "distName": _LTECELL48045name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "value": "locked",
                "operation": "update"
            }
        ]
    },
    {
        "distName": _NRCELL601name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "value": "Locked",
                "operation": "update"
            }
        ]
    },
    {
        "distName": _NRCELL400name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actUlTransPreUsageEnh",
                "value": ["Msg3_TPOn"],
                "operation": "update"
            },
            {
                "parameterName": "actSmallestRRCSetup",  # cell reset
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "ueConnectionEstablishmentMode",
                "value": "useInitialBwp",
                "operation": "update"
            },
            {
                "parameterName": "ulTransPrecodeCtl",
                "value": [
                    dict(ulSlotAggOffTotPwrThresh='15',
                         ulSlotAggOnTotPwrThresh='12',
                         ulTpOffOnTriggerSpeedThresh='100',
                         ulTpOnOffTriggerSpeedThresh='100',
                         ulTransPrecodeOffSinrThresh='35',
                         ulTransPrecodeOffSinrThrRedCap='35',
                         ulTransPrecodeOnSinrThresh='15',
                         ulTransPrecodeOnSinrThrRedCap='15',
                         ulTransPrecodePi2Bpsk='true',
                         ulTransPrePi2BpskPwrBoost='false')
                ],
                "operation": "update"
            },
            {
                "parameterName": "cellBwpList",
                "value": [
                    dict(actPdcchCceFragmentControl='false',
                         actUpperThrAckNackFiltering='false',
                         actUpperThrAckNackHrFiltering='false',
                         bwpDN=_BWP_PROFILE_42,
                         cellBwpId='0',
                         pdcchResourcePreference='peakRate'),
                    dict(actPdcchCceFragmentControl='false',
                         actUpperThrAckNackFiltering='true',
                         actUpperThrAckNackHrFiltering='true',
                         bwpDN=_BWP_PROFILE_172,
                         cellBwpId='1',
                         pdcchResourcePreference='peakRate'),
                    dict(actPdcchCceFragmentControl='false',
                         actUpperThrAckNackFiltering='true',
                         actUpperThrAckNackHrFiltering='true',
                         bwpDN=_BWP_PROFILE_182,
                         cellBwpId='2',
                         pdcchResourcePreference='peakRate'),
                ],
                "operation": "update"
            },
        ]
    },
    {
        "distName": _NRCELL600name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actUlTransPreUsageEnh",
                "value": ["Dci00_TPOn"],
                "operation": "update"
            },
            {
                "parameterName": "actSmallestRRCSetup",  # cell reset
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "ueConnectionEstablishmentMode",
                "value": "useDedicatedBwp",
                "operation": "update"
            },
            {
                "parameterName": "ulTransPrecodeCtl",
                "value": [
                    dict(ulTpOffOnTriggerSpeedThresh='100',
                         ulTpOnOffTriggerSpeedThresh='100',
                         ulTransPrecodeOffSinrThresh='35',
                         ulTransPrecodeOffSinrThrRedCap='35',
                         ulTransPrecodeOnSinrThresh='15',
                         ulTransPrecodeOnSinrThrRedCap='15',
                         ulTransPrecodePi2Bpsk='true',
                         ulTransPrePi2BpskPwrBoost='false')
                ],
                "operation": "update"
            },
        ]
    },
    {
        "distName": _NRBTSname,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actEnhRrcReconfUlPrbRandom",
                "operation": "update",
                "value": 'true'
            },
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

PARAMETERS_RECOVER_CB008148_A_B01_TC004_JSON_FILE = 'PARAMETERS_RECOVER_CB008148_A_B01_TC004_JSON_FILE.json'
PARAMETERS_RECOVER_CB008148_A_B01_TC004 = [
    {
        "distName": _LTECELL48040name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "value": "unlocked",
                "operation": "update"
            }
        ]
    },
    {
        "distName": _LTECELL48045name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "value": "unlocked",
                "operation": "update"
            }
        ]
    },
    {
        "distName": _NRCELL601name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "value": "Unlocked",
                "operation": "update"
            }
        ]
    },
    {
        "distName": _NRCELL400name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actUlTransPreUsageEnh",
                "value": ["disabled"],
                "operation": "update"
            },
            {
                "parameterName": "actSmallestRRCSetup",  # cell reset
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "ueConnectionEstablishmentMode",
                "value": "useDedicatedBwp",
                "operation": "update"
            },
            {
                "parameterName": "ulTransPrecodeCtl",
                "value": [
                    dict(ulSlotAggOffTotPwrThresh='15',
                         ulSlotAggOnTotPwrThresh='12',
                         ulTpOffOnTriggerSpeedThresh='100',
                         ulTpOnOffTriggerSpeedThresh='100',
                         ulTransPrecodeOffSinrThresh='35',
                         ulTransPrecodeOffSinrThrRedCap='35',
                         ulTransPrecodeOnSinrThresh='15',
                         ulTransPrecodeOnSinrThrRedCap='15',
                         ulTransPrecodePi2Bpsk='true',
                         ulTransPrePi2BpskPwrBoost='false')
                ],
                "operation": "update"
            },
            {
                "parameterName": "cellBwpList",
                "value": [
                    dict(actPdcchCceFragmentControl='false',
                         actUpperThrAckNackFiltering='false',
                         actUpperThrAckNackHrFiltering='false',
                         bwpDN=_BWP_PROFILE_251,
                         cellBwpId='0',
                         pdcchResourcePreference='peakRate'),
                    dict(actPdcchCceFragmentControl='false',
                         actUpperThrAckNackFiltering='true',
                         actUpperThrAckNackHrFiltering='true',
                         bwpDN=_BWP_PROFILE_252,
                         cellBwpId='1',
                         pdcchResourcePreference='peakRate'),
                    dict(actPdcchCceFragmentControl='false',
                         actUpperThrAckNackFiltering='true',
                         actUpperThrAckNackHrFiltering='true',
                         bwpDN=_BWP_PROFILE_253,
                         cellBwpId='2',
                         pdcchResourcePreference='peakRate'),
                ],
                "operation": "update"
            },
        ]
    },
    {
        "distName": _NRCELL600name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actUlTransPreUsageEnh",
                "value": ["disabled"],
                "operation": "update"
            },
            {
                "parameterName": "actSmallestRRCSetup",  # cell reset
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "ueConnectionEstablishmentMode",
                "value": "useDedicatedBwp",
                "operation": "update"
            },
            {
                "parameterName": "ulTransPrecodeCtl",
                "value": [
                    dict(ulTpOffOnTriggerSpeedThresh='100',
                         ulTpOnOffTriggerSpeedThresh='100',
                         ulTransPrecodeOffSinrThresh='35',
                         ulTransPrecodeOffSinrThrRedCap='35',
                         ulTransPrecodeOnSinrThresh='15',
                         ulTransPrecodeOnSinrThrRedCap='15',
                         ulTransPrecodePi2Bpsk='true',
                         ulTransPrePi2BpskPwrBoost='false')
                ],
                "operation": "update"
            },
        ]
    },
    {
        "distName": _NRBTSname,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actEnhRrcReconfUlPrbRandom",
                "operation": "update",
                "value": 'true'
            },
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

CB008148_A_B01_TC004_CELLS = [NRCELL400name, NRCELL600name]
CB008148_A_B01_TC004_CELLS_STATUS = [['disabled', 'enabled'], ['enabled', 'enabled']]

PARAMETERS_CB008148_A_B02_TC013_JSON_FILE = 'PARAMETERS_CB008148_A_B02_TC013_JSON_FILE.json'
PARAMETERS_CB008148_A_B02_TC013 = [
    {
        "distName": _NRCELL601name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "value": "Locked",
                "operation": "update"
            }
        ]
    },
    {
        "distName": _NRCELL600name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actUlTransPreUsageEnh",
                "value": ["Dci00_TPOn"],
                "operation": "update"
            },
            {
                "parameterName": "actSmallestRRCSetup",  # cell reset
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "ueConnectionEstablishmentMode",
                "value": "useDedicatedBwp",
                "operation": "update"
            },
            {
                "parameterName": "ulTransPrecodeCtl",
                "value": [
                    dict(ulTpOffOnTriggerSpeedThresh='100',
                         ulTpOnOffTriggerSpeedThresh='100',
                         ulTransPrecodeOffSinrThresh='95',
                         ulTransPrecodeOffSinrThrRedCap='35',
                         ulTransPrecodeOnSinrThresh='65',
                         ulTransPrecodeOnSinrThrRedCap='15',
                         ulTransPrecodePi2Bpsk='true',
                         ulTransPrePi2BpskPwrBoost='false')
                ],
                "operation": "update"
            },
        ]
    },
    {
        "distName": _NRBTSname,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actEnhRrcReconfUlPrbRandom",
                "operation": "update",
                "value": 'false'
            },
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

PARAMETERS_RECOVER_CB008148_A_B02_TC013_JSON_FILE = 'PARAMETERS_RECOVER_CB008148_A_B02_TC013_JSON_FILE.json'
PARAMETERS_RECOVER_CB008148_A_B02_TC013 = [
    {
        "distName": _NRCELL601name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "value": "Unlocked",
                "operation": "update"
            }
        ]
    },
    {
        "distName": _NRCELL600name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actUlTransPreUsageEnh",
                "value": ["disabled"],
                "operation": "update"
            },
            {
                "parameterName": "actSmallestRRCSetup",  # cell reset
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "ueConnectionEstablishmentMode",
                "value": "useDedicatedBwp",
                "operation": "update"
            },
            {
                "parameterName": "ulTransPrecodeCtl",
                "value": [
                    dict(ulTpOffOnTriggerSpeedThresh='100',
                         ulTpOnOffTriggerSpeedThresh='100',
                         ulTransPrecodeOffSinrThresh='35',
                         ulTransPrecodeOffSinrThrRedCap='35',
                         ulTransPrecodeOnSinrThresh='15',
                         ulTransPrecodeOnSinrThrRedCap='15',
                         ulTransPrecodePi2Bpsk='true',
                         ulTransPrePi2BpskPwrBoost='false')
                ],
                "operation": "update"
            },
        ]
    },
    {
        "distName": _NRBTSname,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actEnhRrcReconfUlPrbRandom",
                "operation": "update",
                "value": 'true'
            },
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

CB008148_A_B02_TC013_CELLS = [NRCELL600name]
CB008148_A_B02_TC013_CELLS_STATUS = [['disabled'], ['enabled']]

# PA
RU_PA_info = [
    {
        'att_ipaddr': tl.attenuator[0].ip_addr,
        'ports': [tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no,
                  tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no,
                  tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no,
                  tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no]},
    {
        'att_ipaddr': tl.attenuator[0].ip_addr,
        'ports': [tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no,
                  tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no,
                  tl.gnbs[0].dus[0].rus[1].attenuation_ports[2].port_no,
                  tl.gnbs[0].dus[0].rus[1].attenuation_ports[3].port_no]},
    {
        'att_ipaddr': tl.attenuator[0].ip_addr,
        'ports': [tl.gnbs[0].dus[0].rus[2].attenuation_ports[0].port_no,
                  tl.gnbs[0].dus[0].rus[2].attenuation_ports[1].port_no,
                  tl.gnbs[0].dus[0].rus[2].attenuation_ports[2].port_no,
                  tl.gnbs[0].dus[0].rus[2].attenuation_ports[3].port_no]},
    {
        'att_ipaddr': tl.attenuator[0].ip_addr,
        'ports': [tl.gnbs[0].dus[0].rus[3].attenuation_ports[0].port_no,
                  tl.gnbs[0].dus[0].rus[3].attenuation_ports[1].port_no,
                  tl.gnbs[0].dus[0].rus[3].attenuation_ports[2].port_no,
                  tl.gnbs[0].dus[0].rus[3].attenuation_ports[3].port_no]},
    {
        'att_ipaddr': tl.attenuator[1].ip_addr,
        'ports': [tl.gnbs[0].dus[0].rus[4].attenuation_ports[0].port_no,
                  tl.gnbs[0].dus[0].rus[4].attenuation_ports[1].port_no,
                  tl.gnbs[0].dus[0].rus[4].attenuation_ports[2].port_no,
                  tl.gnbs[0].dus[0].rus[4].attenuation_ports[3].port_no]},
    # {
    #     'att_ipaddr': tl.attenuator[2].ip_addr,
    #     'ports': [tl.gnbs[0].dus[0].rus[5].attenuation_ports[0].port_no,
    #               tl.gnbs[0].dus[0].rus[5].attenuation_ports[1].port_no,
    #               tl.gnbs[0].dus[0].rus[5].attenuation_ports[2].port_no,
    #               tl.gnbs[0].dus[0].rus[5].attenuation_ports[3].port_no]}
]

A_B01_TC002 = {
    'ues_index': [0],
    'ues_ul_throughput': [200000],
    'ues_ul_tput_target': [20],
    'cell_initial_values': [10, 10, 10, 10],
    'start_value': 10,
    'end_value': 60,
    'step': 5,
    'index': 4,
    'pa_interval_time': '0.5',
    'tti_nr_phy_cell_ids': 600,
    'log_path': '/opt/workspace/CRT/Master/Case_Logs',
    'tti_field': ["ulFdSchedData.dciFormat", "ulFdSchedData.puschTPstate"]
}
A_B01_TC004 = {
    'ues_index': [0],
    'ues_dl_throughput': ['180M'],
    'ues_dl_tput_target': [144],
    'ues_ul_throughput': [200000],
    'ues_ul_tput_target': [20],
    'cell_initial_values': [30, 30, 30, 30],
    'target_cell_initial_values': [10, 10, 10, 10],
    'start_value': 10,
    'end_value': 50,
    'step': 2,
    'source_ho_index': 0,
    'target_ho_index': 4,
    'pa_interval_time': '1',
    'ho_times': 3,
    'reestablish_source_initial_value': 10,
    'reestablish_target_initial_value': 10,
    'reestablish_source_index': 4,
    'reestablish_target_index': 0,
    'reestablish_pa_interval_time': '5',
    'reestablish_times': 3,
}
A_B02_TC013 = {
    'ues_index': [0],
    'ues_ul_throughput': [200000],
    'ues_ul_tput_target': [20],
    'cell_initial_values': [10, 10, 10, 10],
    'start_value': 10,
    'end_value': 60,
    'step': 5,
    'index': 4,
    'pa_interval_time': '0.5',
    'tti_nr_phy_cell_ids': 600,
    'log_path': '/opt/workspace/CRT/Master/Case_Logs',
    'tti_field': ["ulFdSchedData.dciFormat", "ulFdSchedData.puschTPstate"]
}
