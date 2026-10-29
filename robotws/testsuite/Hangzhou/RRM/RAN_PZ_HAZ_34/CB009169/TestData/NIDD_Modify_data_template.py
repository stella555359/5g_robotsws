from robot.libraries.BuiltIn import BuiltIn
import json

# ${PROGRAM}: is get via method: gnb_classical_hangzhou.Get program version based on stream version
program = BuiltIn().get_variable_value("${PROGRAM}")
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

if program in ['23R3', '23R4', '24R1', '24R2']:
    SCF_MODIFY_TEMPLATE_FDD_CELLS = '''
    [
        {{
                "dist_name":"{dist_name}",
                "p_name":"csiReportPeriodicity",
                "value":"slots160"}},
        {{
                "dist_name":"{dist_name}",
                "p_name":"srPeriodicity",
                "value":"slots20"}},
         {{
                "dist_name":"{dist_name}",
                "p_name":"lteNrDssMode",
                "value":"none"}}
    ]
    '''
else:
    SCF_MODIFY_TEMPLATE_FDD_CELLS = '''
    [
        {{
                "dist_name":"{dist_name}",
                "p_name":"csiReportPeriodicity",
                "value":"slots80"}},
        {{
                "dist_name":"{dist_name}",
                "p_name":"srPeriodicity",
                "value":"slots20"}},
        {{
                "dist_name":"{dist_name}",
                "p_name":"lteNrDssMode",
                "value":"none"}},
        {{
                "dist_name":"{dist_name}",
                "p_name":"preferredVoNrSrPeriod",
                "value":"slots20"}}
    ]
    '''

if program in ['23R3', '23R4', '24R1', '24R2']:
    SCF_MODIFY_TEMPLATE_TDD_CELLS = '''
        [
            {{
                    "dist_name":"{dist_name}",
                    "p_name":"csiReportPeriodicity",
                    "value":"slots320"}},
            {{
                    "dist_name":"{dist_name}",
                    "p_name":"srPeriodicity",
                    "value":"slots20"}}
        ]
        '''
else:
    SCF_MODIFY_TEMPLATE_TDD_CELLS = '''
    [
        {{
                "dist_name":"{dist_name}",
                "p_name":"csiReportPeriodicity",
                "value":"slots320"}},
        {{
                "dist_name":"{dist_name}",
                "p_name":"srPeriodicity",
                "value":"slots40"}},
        {{
                "dist_name":"{dist_name}",
                "p_name":"preferredVoNrSrPeriod",
                "value":"slots40"}}
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
            "p_name":"ssPbchBlockPower",
            "value":"6"}},
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

SCF_MODIFY_TEMPLATE_T100M_1116 = '''
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

SCF_MODIFY_TEMPLATE_T60M_1116 = '''
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
