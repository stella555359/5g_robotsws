"""
Author: Dandan Fang For CB0100411
Documentation: This file is used to define the template for NIDD parameters
"""
import json
from robot.libraries.BuiltIn import BuiltIn
# ------------------------SCF----------------------------------
# FOR Delete
tl = BuiltIn().get_variable_value('${tl}')

SCF_PARAM_DELETE_CA_SUPPORT_LIST = '''
[
    {{
            "dist_name":"{dist_name}",
            "list_name":"carrierAggregationSupportList"}}
]
'''

# CU Only NRBTS
CU_SCF_DELETE_MAX_NUM_SCELLS_DL = '''
[
    {{
            "dist_name":"{dist_name}",
            "p_name":"maxNumScellsDlFr1"}}
]
'''

# Parameter defined for CU+DU, distname is NRDU
CU_SCF_MODIFY_CA_Mandatory_PARAMETERS = '''
[
    {{
            "dist_name":"{cu_nrdu_dn}",
            "p_name":"actInterNumerologyCa",
            "value":"true"}},
    {{
            "dist_name":"{cu_nrdu_dn}",
            "p_name":"actNonBfAndBfCa",
            "value":"true"}},
    {{
            "dist_name":"{cu_nrdu_dn}",
            "p_name":"flexibleCAMode",
            "value":"NumberCellAmount"}},
    {{
            "dist_name":"{cu_nrdu_dn}",
            "p_name":"actConnectedModeMobilityCA",
            "value":"true"}},
    {{
            "dist_name":"{cu_nrdu_dn}",
            "p_name":"dlToUlContributionRatio",
            "value":"{dl_to_ul_ratio_value}"}},
    {{
            "dist_name":"{cu_nrbts_dn}",
            "p_name":"actBufferBasedSCellAddition",
            "value":"oneShot_Dl_Fr1"}},
    {{
            "dist_name":"{cu_nrbts_dn}",
            "p_name":"actSCellReleaseForInactiveSCell",
            "value":"timer_based_Fr1"}},
    {{
            "dist_name":"{cu_nrbts_dn}",
            "p_name":"drbInactivityTimerSA",
            "value":"900"}},
    {{
            "dist_name":"{cu_nrbts_dn}",
            "p_name":"actSCellReleaseBadSCellRlq",
            "value":"disabled"}}
]
'''

# CU Set counter report period
CU_SCF_MODIFY_COUNTER_NIDD = '''
[
    {{
            "dist_name":"{cu_mrbts_distname}/MNL-1/MNLENT-1/PMCADM-1",
            "p_name":"reportingIntervalPm",
            "value":"5min"}},
    {{
            "dist_name":"{cu_nrbts_dist_name}/NRPMRNL-1",
            "p_name":"miNrCaCu",
            "value":"5min"}}
]
'''

CU_MODIFY_SCF_DISABLE_CIPHER = '''
[
    {{
        "dist_name": "{cu_nrbts_dist_name}",
        "p_name": "nea0",
        "value": "9"}},
    {{
        "dist_name": "{cu_nrbts_dist_name}",
        "p_name": "nea1_128",
        "value": "3"}},
    {{
        "dist_name": "{cu_nrbts_dist_name}",
        "p_name": "nea2_128",
        "value": "4"}},
    {{
        "dist_name": "{cu_nrbts_dist_name}",
        "p_name": "nea3_128",
        "value": "2"}}
]
'''

CU_MODIFY_SCF_NRBTS_NIDD_IWK = '''
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

if "sdx80" in str(tl.ues[0].capabilities):
    CU_SCF_ADD_FOR_MAX_SCELL_NUM = '''
    [
        {{
                "dist_name":"{dist_name}",
                "p_name":"maxNumScellsDlFr1",
                "value":"5"}}
    ]
    '''

else:
    CU_SCF_ADD_FOR_MAX_SCELL_NUM = '''
    [
        {{
                "dist_name":"{dist_name}",
                "p_name":"maxNumScellsDlFr1",
                "value":"3"}}
    ]
    '''

CU_SCF_MODIFY_TEMPLATE_DEACT_IWK_ALL_CELL = '''
[
    {{
            "dist_name":"{dist_name}",
            "p_name":"actEnhMultipleDedicatedBWPs",
            "value":"false"}}
]
'''

# DU Only NRBTS -used
DU_SCF_DELETE_NIDD_OPTIONAL_ALL_CELL = '''
[
    {{
            "dist_name":"{dist_name}",
            "p_name":"dlSCellConfigLevel"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"dlSCellConfigLevelNum"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"sCellInactivityReleaseTime"}}
]
'''

# Some testline maybe define 2 RLC_AM
DU_SCF_PARAM_ADD_ULCA_RLC = '''
[
    {{
            "dist_name":"{du_nrbts_dist_name}/NRDRB_RLC_AM-1",
            "p_name":"ulTReassemblyIBCA",
            "value":"40"}}
]
'''

# Some testline maybe define 2 RLC_AM
DU_SCF_PARAM_ADD_8311_OPTIONAL_NIDD_ALL = '''
[
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

# DU Only -- Distname is NRBTS
DU_SCF_MODIFY_COUNTER_NIDD = '''
[
    {{
            "dist_name":"{du_mrbts_distname}/MNL-1/MNLENT-1/PMCADM-1",
            "p_name":"reportingIntervalPm",
            "value":"5min"}},
    {{
            "dist_name":"{du_nrbts_dist_name}/NRPMRNL-1",
            "p_name":"miNrCaDu",
            "value":"5min"}},
    {{
            "dist_name":"{du_nrbts_dist_name}/NRPMRNL-1",
            "p_name":"miNrLowRlcReport",
            "value":"5min"}},
    {{
            "dist_name":"{du_nrbts_dist_name}/NRPMRNL-1",
            "p_name":"miNrRRCC",
            "value":"5min"}},
    {{
            "dist_name":"{du_nrbts_dist_name}/NRPMRNL-1",
            "p_name":"miNrRRCD",
            "value":"5min"}},
    {{
            "dist_name":"{du_nrbts_dist_name}/NRPMRNL-1",
            "p_name":"miNrRSADU",
            "value":"5min"}},
    {{
            "dist_name":"{du_nrbts_dist_name}/NRPMRNL-1",
            "p_name":"miNrRacDu",
            "value":"5min"}}
]
'''

DU_SCF_MODIFY_IWK_CA_Pooling_NIDD = '''
[
    {{
            "dist_name":"{du_nrbts_dn}",
            "p_name":"actSlowPrbPooling",
            "value":"true"}},
    {{
            "dist_name":"{du_nrbts_dn}",
            "p_name":"actSlowPrbPoolingFddFr1Enh",
            "value":"true"}},
    {{
            "dist_name":"{du_nrbts_dn}",
            "p_name":"actScheUePooling",
            "value":"true"}},
    {{
            "dist_name":"{du_nrbts_dn}",
            "p_name":"actConnRrcPooling",
            "value":"true"}},
    {{
            "dist_name":"{du_nrbts_dn}",
            "p_name":"actMultipleDedicatedBWPs",
            "value":"false"}},
    {{
            "dist_name":"{du_nrbts_dn}",
            "p_name":"actSliceAwareScheduler",
            "value":"false"}},
    {{
            "dist_name":"{du_nrbts_dn}",
            "p_name":"actOverheatingAssistance",
            "value":"false"}},
    {{
            "dist_name":"{du_nrbts_dn}",
            "p_name":"actHighestEstNrTputBcSel",
            "value":"true"}},
    {{
            "dist_name":"{du_nrbts_dn}",
            "p_name":"sCellDeactivationBadRlqCount",
            "value":"0"}},
    {{
            "dist_name":"{du_nrbts_dn}",
            "p_name":"actBufferBasedSCellAddition",
            "value":"oneShot_Dl_Fr1"}},
    {{
            "dist_name":"{du_nrbts_dn}",
            "p_name":"actSCellReleaseForInactiveSCell",
            "value":"timer_based_Fr1"}},
    {{
            "dist_name":"{du_nrbts_dn}",
            "p_name":"actSCellReleaseBadSCellRlq",
            "value":"disabled"}},
    {{
            "dist_name":"{du_nrbts_dn}",
            "p_name":"sCellActivationMethod",
            "value":"bufferBased"}},
    {{
            "dist_name":"{du_nrdu_dn}",
            "p_name":"actInterNumerologyCa",
            "value":"true"}},
    {{
            "dist_name":"{du_nrdu_dn}",
            "p_name":"actNonBfAndBfCa",
            "value":"true"}},
    {{
            "dist_name":"{du_nrdu_dn}",
            "p_name":"flexibleCAMode",
            "value":"NumberCellAmount"}},
    {{
            "dist_name":"{du_nrdu_dn}",
            "p_name":"actConnectedModeMobilityCA",
            "value":"true"}},
    {{
            "dist_name":"{du_nrdu_dn}",
            "p_name":"dlToUlContributionRatio",
            "value":"{dl_to_ul_ratio_value}"}},
    {{
            "dist_name":"{du_nrbts_dn}",
            "p_name":"actBbPoolTddFr1",
            "value":"true"}},
    {{
            "dist_name":"{du_nrbts_dn}",
            "p_name":"actBbPoolTddFr1AlgEnh",
            "value":"true"}},
    {{
            "dist_name":"{du_nrbts_dn}",
            "p_name":"actBbPoolTddFr1Enh",
            "value":"true"}},
    {{
            "dist_name":"{du_nrbts_dn}",
            "p_name":"actBbPoolExtensionTddFr1",
            "value":"true"}}
]
'''

# For cells: SCF Modify
SCF_MODIFY_TEMPLATE_PARAMETERS_EXIST_ON_CU_DU_ALL_CELLS = '''
[
    {{
            "dist_name":"{dist_name}",
            "p_name":"actCDrx",
            "value":"true"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"cellDepType",
            "value":"SA"}}
]
'''

DU_SCF_MODIFY_TEMPLATE_BASE_ALL_CELLS = '''
[
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
            "value":"ms1280"}}
]
'''

# FDD  slots320 need to be changed as 160, bwp need to be align
DU_SCF_MODIFY_CELL_FDD_PARAMETERS = '''
[
    {{
            "dist_name":"{dist_name}",
            "p_name":"maxNumPdschAllocationPerSlot",
            "value":"12"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"maxNumPuschAllocationPerSlot",
            "value":"10"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"csiReportPeriodicity",
            "value":"slots320"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"srPeriodicity",
            "value":"slots80"}}
]
'''

# TDD
DU_SCF_MODIFY_CELL_TDD_PARAMETERS = '''
[
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
            "value":"Type2"}}
]
'''

# Graceful shutdown NIDD
DU_SCF_MODIFY_GRACEFUL_SHUTDOWN = '''
[
    {{
            "dist_name":"{dist_name}",
            "p_name":"actGrflShdn",
            "value":"true"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"shutdownStepAmount",
            "value":"16"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"shutdownWindow",
            "value":"180"}}
]
'''

# CB009267 NIDD
DU_SCF_MODIFY_COUNTER_NIDD_9267 = '''
[
{{
    "dist_name": "{dist_name}",
    "p_name": "actCarAgPmCount",
    "value": "true"}}
]
'''

CU_SCF_MODIFY_COUNTER_NIDD_9267 = '''
[
    {{
            "dist_name":"{cu_nrbts_dist_name}/NRPMRNL-1",
            "p_name":"miNrCUCM",
            "value":"5min"}},
    {{
            "dist_name":"{cu_nrbts_dist_name}/NRPMRNL-1",
            "p_name":"miNrUeState",
            "value":"5min"}},
    {{
            "dist_name":"{cu_nrbts_dist_name}/NRPMRNL-1",
            "p_name":"miNrRacCu",
            "value":"5min"}},
    {{
            "dist_name": "{cu_nrbts_dist_name}",
            "p_name": "actCarAgPmCount",
            "value": "true"}}
]
'''
