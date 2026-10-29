"""
Author: Ding Binmei
Documentation: This file is used to define the template for NIDD parameters
"""
import json
# ------------------------SCF----------------------------------
# For cells: SCF Modify

SCF_MODIFY_TEMPLATE_BASE_ALL_CELLS = '''
[
    {{
            "dist_name":"{dist_name}",
            "p_name":"actCDrx",
            "value":"true"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"cellDepType",
            "value":"SA+NSA"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"pucchModeSelect",
            "value":"longPucch"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"timingAdvanceOffset",
            "value":"n25600"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"actK1Opt",
            "value":"intra-gNB"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"actProactUlScheduling",
            "value":"true"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"ulSchedTimeInterval",
            "value":"150"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"ulProGrantTimer",
            "value":"1200"}}
]
'''

SCF_MODIFY_TEMPLATE_FDD_CELLS = '''
[
    {{
            "dist_name":"{dist_name}",
            "p_name":"csiReportPeriodicity",
            "value":"slots160"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"srPeriodicity",
            "value":"slots80"}}
]
'''

SCF_MODIFY_TEMPLATE_TDD_CELLS = '''
[
    {{
            "dist_name":"{dist_name}",
            "p_name":"csiReportPeriodicity",
            "value":"slots320"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"srPeriodicity",
            "value":"slots160"}}
]
'''

SCF_MODIFY_TEMPLATE_F20M = '''
[
    {{
            "dist_name":"{dist_name}/NRCELL_FDD-1",
            "p_name":"chBwDl",
            "value":"20MHz"}},
    {{
            "dist_name":"{dist_name}/NRCELL_FDD-1",
            "p_name":"chBwUl",
            "value":"20MHz"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"msg1FrequencyStart",
            "value":"11"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"bwpDN",
            "index":"0",
            "value":"{value}/BWP_PROFILE-{bwp_id_initial}"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"bwpDN",
            "index":"1",
            "value":"{value}/BWP_PROFILE-{bwp_id_dedicate}"}}
]
'''

SCF_MODIFY_TEMPLATE_F10M = '''
[
    {{
            "dist_name":"{dist_name}/NRCELL_FDD-1",
            "p_name":"chBwDl",
            "value":"10MHz"}},
    {{
            "dist_name":"{dist_name}/NRCELL_FDD-1",
            "p_name":"chBwUl",
            "value":"10MHz"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"msg1FrequencyStart",
            "value":"32"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"bwpDN",
            "index":"0",
            "value":"{value}/BWP_PROFILE-{bwp_id_initial}"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"bwpDN",
            "index":"1",
            "value":"{value}/BWP_PROFILE-{bwp_id_dedicate}"}}
]
'''

SCF_MODIFY_TEMPLATE_F10M_CONTIGUOUS = '''
[
    {{
            "dist_name":"{dist_name}/NRCELL_FDD-1",
            "p_name":"chBwDl",
            "value":"10MHz"}},
    {{
            "dist_name":"{dist_name}/NRCELL_FDD-1",
            "p_name":"chBwUl",
            "value":"10MHz"}},
    {{
            "dist_name":"{dist_name}/NRCELL_FDD-1",
            "p_name":"nrarfcnDl",
            "value":"{F2_ARFCN}"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"msg1FrequencyStart",
            "value":"32"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"bwpDN",
            "index":"0",
            "value":"{value}/BWP_PROFILE-{bwp_id_initial}"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"bwpDN",
            "index":"1",
            "value":"{value}/BWP_PROFILE-{bwp_id_dedicate}"}}
]
'''

SCF_MODIFY_TEMPLATE_T100M = '''
[
    {{
            "dist_name":"{dist_name}",
            "p_name":"chBw",
            "value":"100MHz"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"msg1FrequencyStart",
            "value":"30"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"reqMinNumPuschPrb",
            "value":"240"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"bwpDN",
            "index":"0",
            "value":"{value}/BWP_PROFILE-{bwp_id_initial}"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"bwpDN",
            "index":"1",
            "value":"{value}/BWP_PROFILE-{bwp_id_dedicate}"}}
]
'''

SCF_MODIFY_TEMPLATE_T100M_8406 = '''
[
    {{
            "dist_name":"{dist_name}",
            "p_name":"chBw",
            "value":"100MHz"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"msg1FrequencyStart",
            "value":"30"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"type0SearchSpaceConfigurationIndex",
            "value":"5"}},
    {{
            "dist_name":"{dist_name}",
            "list_name":"fPdcchMonOccsnPo",
            "value":"2"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"reqMinNumPuschPrb",
            "value":"240"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"bwpDN",
            "index":"0",
            "value":"{value}/BWP_PROFILE-{bwp_id_initial}"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"bwpDN",
            "index":"1",
            "value":"{value}/BWP_PROFILE-{bwp_id_dedicate}"}}
]
'''

SCF_MODIFY_TEMPLATE_T60M = '''
[
    {{
            "dist_name":"{dist_name}",
            "p_name":"chBw",
            "value":"60MHz"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"msg1FrequencyStart",
            "value":"0"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"reqMinNumPuschPrb",
            "value":"126"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"bwpDN",
            "index":"0",
            "value":"{value}/BWP_PROFILE-{bwp_id_initial}"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"bwpDN",
            "index":"1",
            "value":"{value}/BWP_PROFILE-{bwp_id_dedicate}"}}
]
'''

SCF_MODIFY_TEMPLATE_T60M_8406 = '''
[
    {{
            "dist_name":"{dist_name}",
            "p_name":"chBw",
            "value":"60MHz"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"msg1FrequencyStart",
            "value":"0"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"type0SearchSpaceConfigurationIndex",
            "value":"5"}},
    {{
            "dist_name":"{dist_name}",
            "list_name":"fPdcchMonOccsnPo",
            "value":"2"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"reqMinNumPuschPrb",
            "value":"126"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"bwpDN",
            "index":"0",
            "value":"{value}/BWP_PROFILE-{bwp_id_initial}"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"bwpDN",
            "index":"1",
            "value":"{value}/BWP_PROFILE-{bwp_id_dedicate}"}}
]
'''

SCF_MODIFY_TEMPLATE_FRAME_STRUCTURE_1116_0 = '''
[
    {{
            "dist_name":"{dist_name}",
            "p_name":"frameStructureType",
            "value":"tdLte"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"guardPeriodLength",
            "value":"6Symbols"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"lteToNrFrameShift",
            "value":"0ms"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"tdLteUlDlConfig",
            "value":"tdLteConfig2"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"ulDlDataSlotRatio",
            "value":"2/8"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"prachConfigurationIndex",
            "value":"97"}}
]
'''

SCF_MODIFY_TEMPLATE_FRAME_STRUCTURE_1070 = '''
[
    {{
            "dist_name":"{dist_name}",
            "p_name":"frameStructureType",
            "value":"semiStatic"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"guardPeriodLength",
            "value":"2Symbols"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"ulDlDataSlotRatio",
            "value":"3/7"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"lteToNrFrameShift",
            "value":""}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"tdLteUlDlConfig",
            "value":""}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"prachConfigurationIndex",
            "value":"98"}}
]
'''

SCF_MODIFY_TEMPLATE_FRAME_STRUCTURE_8406 = '''
[
    {{
            "dist_name":"{dist_name}",
            "p_name":"frameStructureType",
            "value":"semiStatic"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"guardPeriodLength",
            "value":"4Symbols"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"ulDlDataSlotRatio",
            "value":"4/6"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"lteToNrFrameShift",
            "value":""}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"tdLteUlDlConfig",
            "value":""}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"prachConfigurationIndex",
            "value":"97"}}
]
'''

SCF_MODIFY_TEMPLATE_DEACT_UL256QAM = '''
[
    {{
            "dist_name":"{dist_name}",
            "p_name":"actUl256Qam",
            "value":"false"}}
]
'''

SCF_MODIFY_TEMPLATE_DEACT_IWK_ALL_CELL = '''
[
    {{
            "dist_name":"{dist_name}",
            "p_name":"ueSplitPowerAdjStep",
            "value":"170"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"weightRatioOfUePwrScellVsPcell",
            "value":"WeightRatio 1"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"actEnhMultipleDedicatedBWPs",
            "value":"false"}}
]
'''

SCF_MODIFY_TEMPLATE_T20M = '''
[
    {{
            "dist_name":"{dist_name}",
            "p_name":"chBw",
            "value":"20MHz"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"msg1FrequencyStart",
            "value":"12"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"reqMinNumPuschPrb",
            "value":"41"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"type0CoresetConfigurationIndex",
            "value":"3"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"nrarfcn",
            "value":"535854"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"bwpDN",
            "index":"0",
            "value":"{value}/BWP_PROFILE-{bwp_id_initial}"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"bwpDN",
            "index":"1",
            "value":"{value}/BWP_PROFILE-{bwp_id_dedicate}"}}
]
'''

# used for scell swap case:CB006137-C_US-IWK12_01
SCF_MODIFY_INTRA_FREQUENCY_SCELL_SWAP = '''
[
    {{
            "dist_name":"{dist_name}",
            "p_name":"nrarfcn",
            "value":"526860"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"gscnOrSsPbchArfcn",
            "value":"1"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"type0CoresetConfigurationIndex",
            "value":"12"}}
]
'''

# when pooling is enabled, FDD
# NRCELL.maxNumPdschAllocationPerSlot=12
# NRCELL.maxNumPuschAllocationPerSlot=10
SCF_MODIFY_FDD_POOLING_ENABLE = '''
[
    {{
            "dist_name":"{dist_name}",
            "p_name":"maxNumPdschAllocationPerSlot",
            "value":"12"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"maxNumPuschAllocationPerSlot",
            "value":"10"}}
]
'''

# Can set to all cells, in Case C_B27_01, it is effective on Pcell, but in requirement it is asked to set to true
# For all FDD and TDD cells. But since ABIL does not support for TDD cells so only active this Function for Pcell
RESTAPI_MODIFY_actUlDftSOfdm = '''
[
    {{
        "dist_name":"{dist_name}",
        "parameter":"actUlDftSOfdm",
        "value":"{value}"
    }}
]
'''

# When enable CB008311, bellow params need to be added for all cells
RESTAPI_ADD_CB008311_PARAMS_CELLS = '''
[
    {{
        "dist_name":"{dist_name}",
        "parameter":"dlSCellConfigLevel",
        "value":"10"
    }},
    {{
        "dist_name":"{dist_name}",
        "parameter":"dlSCellConfigLevelNum",
        "value":"3"
    }},
    {{
        "dist_name":"{dist_name}",
        "parameter":"sCellInactivityReleaseTimer",
        "value":"10"
    }}
]
'''

# RRE related timer
RESTAPI_MODIFY_RRE_TIMERS = '''
[
    {{
        "dist_name":"{dist_name}",
        "parameter":"t301",
        "value":"2000ms"
    }},
    {{
        "dist_name":"{dist_name}",
        "parameter":"n310",
        "value":"n10"
    }},
    {{
        "dist_name":"{dist_name}",
        "parameter":"t310",
        "value":"2000ms"
    }},
    {{
        "dist_name":"{dist_name}",
        "parameter":"t311",
        "value":"30000ms"
    }},
    {{
        "dist_name":"{dist_name}",
        "parameter":"n311",
        "value":"n1"
    }},
    {{
        "dist_name":"{dist_name}",
        "parameter":"rlpRecCsiBsiThreshold",
        "value":"2"
    }},
        {{
        "dist_name":"{dist_name}",
        "parameter":"rlpRecDlHarqThreshold",
        "value":"5"
    }},
        {{
        "dist_name":"{dist_name}",
        "parameter":"rlpDetCsiBsiThreshold",
        "value":"10000"
    }},
        {{
        "dist_name":"{dist_name}",
        "parameter":"rlpDetDlHarqThreshold",
        "value":"35"
    }}
]
'''
