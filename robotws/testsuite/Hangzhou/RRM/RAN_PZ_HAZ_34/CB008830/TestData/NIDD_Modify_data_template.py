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
            "value":"1200"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"actUlClosedLoopPwrCtrl",
            "value":"disabled"}},
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
            "p_name":"pMaxNROwnCell",
            "value":"23"}}
]
'''

SCF_MODIFY_TEMPLATE_TDD_CELLS = '''
[
    {{
            "dist_name":"{dist_name}",
            "p_name":"csiReportPeriodicity",
            "value":"slots320"}}
]
'''

SCF_MODIFY_TEMPLATE_T100M_1070 = '''
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
            "p_name":"ssPbchBlockPower",
            "value":"10"}},
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

SCF_MODIFY_TEMPLATE_T60M_1070 = '''
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
            "value":"false"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"actPowerSavingBWP",
            "value":"false"}}
]
'''
