"""
Author: Lingxue Cui For CB012219 CB008985
Documentation: This file is used to define the template for NIDD parameters
"""

CU_SCF_MODIFY_CA_Mandatory_PARAMETERS = '''
[
    {{
            "dist_name":"{cu_nrdu_dist_name}",
            "p_name":"actInterNumerologyCa",
            "value":"true"}},
    {{
            "dist_name":"{cu_nrdu_dist_name}",
            "p_name":"actNonBfAndBfCa",
            "value":"true"}},
    {{
            "dist_name":"{cu_nrdu_dist_name}",
            "p_name":"flexibleCAMode",
            "value":"NumberCellAmount"}},
    {{
            "dist_name":"{cu_nrdu_dist_name}",
            "p_name":"actConnectedModeMobilityCA",
            "value":"true"}},
    {{
            "dist_name":"{cu_nrbts_dist_name}",
            "p_name":"actBufferBasedSCellAddition",
            "value":"oneShot_Dl_Fr1"}},
    {{
            "dist_name":"{cu_nrbts_dist_name}",
            "p_name":"actSCellReleaseForInactiveSCell",
            "value":"timer_based_Fr1"}},
    {{
            "dist_name":"{cu_nrbts_dist_name}",
            "p_name":"drbInactivityTimerSA",
            "value":"7200"}},
    {{
            "dist_name":"{cu_nrbts_dist_name}",
            "p_name":"actSCellReleaseBadSCellRlq",
            "value":"disabled"}},
    {{
            "dist_name":"{cu_nrbts_dist_name}",
            "p_name":"actBcsCheck",
            "value":"disabled"}}
]
'''

CU_MODIFY_SCF_NRBTS_IWK = '''
[
    {{
        "dist_name": "{cu_nrbts_dist_name}",
        "p_name": "actMultipleDedicatedBWPs",
        "value": "false"}},
    {{
        "dist_name": "{cu_nrbts_dist_name}",
        "p_name": "actSliceAwareScheduler",
        "value": "false"}},
    {{
        "dist_name": "{cu_nrbts_dist_name}",
        "p_name": "actOverheatingAssistance",
        "value": "false"}},
    {{
        "dist_name": "{cu_nrbts_dist_name}",
        "p_name": "actConnRrcPooling",
        "value": "true"}},
    {{
        "dist_name": "{cu_nrbts_dist_name}",
        "p_name": "actHighestEstNrTputBcSel",
        "value": "true"}},
    {{
        "dist_name": "{cu_nrbts_dist_name}",
        "p_name": "actE2CA",
        "value": "false"}}
]
'''

CU_MODIFY_SCF_ALL_CELLS = '''
[
    {{
            "dist_name":"{dist_name}",
            "p_name":"actCDrx",
            "value":"true"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"actEnhMultipleDedicatedBWPs",
            "value":"false"}}
]
'''


DU_MODIFY_SCF_NRBTS_IWK = '''
[
    {{
            "dist_name":"{du_nrbts_dist_name}",
            "p_name":"actSlowPrbPooling",
            "value":"true"}},
    {{
            "dist_name":"{du_nrbts_dist_name}",
            "p_name":"actSlowPrbPoolingFddFr1Enh",
            "value":"true"}},
    {{
            "dist_name":"{du_nrbts_dist_name}",
            "p_name":"actScheUePooling",
            "value":"true"}},
    {{
            "dist_name":"{du_nrbts_dist_name}",
            "p_name":"actConnRrcPooling",
            "value":"true"}},
    {{
            "dist_name":"{du_nrbts_dist_name}",
            "p_name":"actMultipleDedicatedBWPs",
            "value":"false"}},
    {{
            "dist_name":"{du_nrbts_dist_name}",
            "p_name":"actSliceAwareScheduler",
            "value":"false"}},
    {{
            "dist_name":"{du_nrbts_dist_name}",
            "p_name":"actOverheatingAssistance",
            "value":"false"}},
    {{
            "dist_name":"{du_nrbts_dist_name}",
            "p_name":"actHighestEstNrTputBcSel",
            "value":"true"}},
    {{
            "dist_name":"{du_nrbts_dist_name}",
            "p_name":"sCellDeactivationBadRlqCount",
            "value":"0"}},
    {{
            "dist_name":"{du_nrbts_dist_name}",
            "p_name":"actBufferBasedSCellAddition",
            "value":"oneShot_Dl_Fr1"}},
    {{
            "dist_name":"{du_nrbts_dist_name}",
            "p_name":"actSCellReleaseForInactiveSCell",
            "value":"timer_based_Fr1"}},
    {{
            "dist_name":"{du_nrbts_dist_name}",
            "p_name":"actSCellReleaseBadSCellRlq",
            "value":"disabled"}},
    {{
            "dist_name":"{du_nrbts_dist_name}",
            "p_name":"sCellActivationMethod",
            "value":"bufferBased"}},
    {{
            "dist_name":"{du_nrdu_dist_name}",
            "p_name":"actInterNumerologyCa",
            "value":"true"}},
    {{
            "dist_name":"{du_nrdu_dist_name}",
            "p_name":"actNonBfAndBfCa",
            "value":"true"}},
    {{
            "dist_name":"{du_nrdu_dist_name}",
            "p_name":"flexibleCAMode",
            "value":"NumberCellAmount"}},
    {{
            "dist_name":"{du_nrdu_dist_name}",
            "p_name":"actConnectedModeMobilityCA",
            "value":"true"}},
    {{
            "dist_name":"{du_nrbts_dist_name}",
            "p_name":"actBbPoolTddFr1",
            "value":"true"}},
    {{
            "dist_name":"{du_nrbts_dist_name}",
            "p_name":"actBbPoolTddFr1AlgEnh",
            "value":"true"}},
    {{
            "dist_name":"{du_nrbts_dist_name}",
            "p_name":"actBbPoolTddFr1Enh",
            "value":"true"}},
    {{
            "dist_name":"{du_nrbts_dist_name}",
            "p_name":"actBbPoolExtensionTddFr1",
            "value":"true"}}
]
'''

DU_MODIFY_SCF_CELL = '''
[
    {{
            "dist_name":"{dist_name}",
            "p_name":"actCDrx",
            "value":"true"}},
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
            "p_name":"actUl256Qam",
            "value":"false"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"sCellDeactivationTimerGNB",
            "value":"ms1280"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"maxNumPdschAllocationPerSlot",
            "value":"8"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"maxNumPuschAllocationPerSlot",
            "value":"8"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"csiReportPeriodicity",
            "value":"slots320"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"srPeriodicity",
            "value":"slots160"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"dlDmrsType",
            "value":"Type2"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"dlSCellConfigLevel",
            "value":"10"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"dlSCellConfigLevelNum",
            "value":"3"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"sCellInactivityReleaseTimer",
            "value":"10"}}
]
'''
