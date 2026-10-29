# *-coding=utf-8-*

# Name: Ming Shi
# Time: 2023/7/29 15:08


import os
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
CFG_DIR = os.path.dirname(os.path.abspath(__file__))
_gnb1_id = str(tl.gnbs[0].instance_id)
_gnb2_id = str(tl.gnbs[1].instance_id)
_enb_id = str(tl.gnbs[0].instance_id + 10)
_MRBTSname1 = 'MRBTS-'+_gnb1_id
_MRBTSname2 = 'MRBTS-'+_gnb2_id
_LNBTSname = _MRBTSname1+'/LNBTS-'+_enb_id
_NRBTSname1 = _MRBTSname1+'/NRBTS-'+_gnb1_id
_NRBTSname2 = _MRBTSname2+'/NRBTS-'+_gnb2_id
_CELL1_1 = _NRBTSname1+'/NRCELL-1'
_CELL2_1 = _NRBTSname2+'/NRCELL-1'
_LTECELLname = _LNBTSname+'/LNCEL-4'
_mcc = str(tl.core.mcc)
_mnc = str(tl.core.mnc)
_PMCADM1 = _MRBTSname1+'/MNL-1/MNLENT-1/PMCADM-1'
_PMCADM2 = _MRBTSname2+'/MNL-1/MNLENT-1/PMCADM-1'


SFE_TMO_Ping_Pang_Paras_348 = [
    dict(value=[dict(a3HysteresisSsbRsrp='0', a3OffsetSsbRsrp='-15', a3TimeToTriggerSsbRsrp='ms320')],
         dist_name=_CELL1_1, parameter='a3MeasSsbRsrp'),
    dict(value='5min', dist_name=_PMCADM1, parameter='reportingIntervalPm'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname1,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname1,
         parameter='integrityProtPrefL')
]

SFE_TMO_Ping_Pang_Paras_GNB2_348 = [
    dict(value=[dict(a3HysteresisSsbRsrp='0', a3OffsetSsbRsrp='-15', a3TimeToTriggerSsbRsrp='ms480')],
         dist_name=_CELL2_1, parameter='a3MeasSsbRsrp'),
    dict(value='5min', dist_name=_PMCADM2, parameter='reportingIntervalPm'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname2,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname2,
         parameter='integrityProtPrefL')
]

SFE_TMO_Ping_Pang_Paras_Recover_348 = [
    dict(value=[dict(a3HysteresisSsbRsrp='0', a3OffsetSsbRsrp='2', a3TimeToTriggerSsbRsrp='ms320')],
         dist_name=_CELL1_1, parameter='a3MeasSsbRsrp'),
    dict(value='60min', dist_name=_PMCADM1, parameter='reportingIntervalPm'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname1,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname1,
         parameter='integrityProtPrefL')
]

SFE_TMO_Ping_Pang_Paras_GNB2_Recover_348 = [
    dict(value=[dict(a3HysteresisSsbRsrp='0', a3OffsetSsbRsrp='3', a3TimeToTriggerSsbRsrp='ms480')],
         dist_name=_CELL2_1, parameter='a3MeasSsbRsrp'),
    dict(value='60min', dist_name=_PMCADM2, parameter='reportingIntervalPm'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname2,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname2,
         parameter='integrityProtPrefL')
]


SFE_TMO_Ping_Pang_Paras_358 = [
    dict(value=[dict(a3HysteresisSsbRsrp='0', a3OffsetSsbRsrp='-15', a3TimeToTriggerSsbRsrp='ms320')],
         dist_name=_CELL1_1, parameter='a3MeasSsbRsrp'),
    dict(value='5min', dist_name=_PMCADM1, parameter='reportingIntervalPm'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname1,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname1,
         parameter='integrityProtPrefL')
]

SFE_TMO_Ping_Pang_Paras_GNB2_358 = [
    dict(value=[dict(a3HysteresisSsbRsrp='0', a3OffsetSsbRsrp='-15', a3TimeToTriggerSsbRsrp='ms480')],
         dist_name=_CELL2_1, parameter='a3MeasSsbRsrp'),
    dict(value='5min', dist_name=_PMCADM2, parameter='reportingIntervalPm'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname2,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname2,
         parameter='integrityProtPrefL')
]

SFE_TMO_Ping_Pang_Paras_Recover_358 = [
    dict(value=[dict(a3HysteresisSsbRsrp='0', a3OffsetSsbRsrp='2', a3TimeToTriggerSsbRsrp='ms320')],
         dist_name=_CELL1_1, parameter='a3MeasSsbRsrp'),
    dict(value='60min', dist_name=_PMCADM1, parameter='reportingIntervalPm'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname1,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname1,
         parameter='integrityProtPrefL')
]

SFE_TMO_Ping_Pang_Paras_GNB2_Recover_358 = [
    dict(value=[dict(a3HysteresisSsbRsrp='0', a3OffsetSsbRsrp='3', a3TimeToTriggerSsbRsrp='ms480')],
         dist_name=_CELL2_1, parameter='a3MeasSsbRsrp'),
    dict(value='60min', dist_name=_PMCADM2, parameter='reportingIntervalPm'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname2,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname2,
         parameter='integrityProtPrefL')
]


SFE_TMO_Ping_Pang_Paras_383 = [
    dict(value='locked', dist_name=_LTECELLname, parameter='administrativeState'),
    dict(value=[dict(a3HysteresisSsbRsrp='0', a3OffsetSsbRsrp='-15', a3TimeToTriggerSsbRsrp='ms320')],
         dist_name=_CELL1_1, parameter='a3MeasSsbRsrp'),
    dict(value='5min', dist_name=_PMCADM1, parameter='reportingIntervalPm'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname1,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname1,
         parameter='integrityProtPrefL')
]

SFE_TMO_Ping_Pang_Paras_GNB2_383 = [
    dict(value=[dict(a3HysteresisSsbRsrp='1', a3OffsetSsbRsrp='-15', a3TimeToTriggerSsbRsrp='ms128')],
         dist_name=_CELL2_1, parameter='a3MeasSsbRsrp'),
    dict(value='5min', dist_name=_PMCADM2, parameter='reportingIntervalPm'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname2,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname2,
         parameter='integrityProtPrefL')
]

SFE_TMO_Ping_Pang_Paras_Recover_383 = [
    dict(value='unlocked', dist_name=_LTECELLname, parameter='administrativeState'),
    dict(value=[dict(a3HysteresisSsbRsrp='0', a3OffsetSsbRsrp='2', a3TimeToTriggerSsbRsrp='ms320')],
         dist_name=_CELL1_1, parameter='a3MeasSsbRsrp'),
    dict(value='60min', dist_name=_PMCADM1, parameter='reportingIntervalPm'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname1,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname1,
         parameter='integrityProtPrefL')
]

SFE_TMO_Ping_Pang_Paras_GNB2_Recover_383 = [
    dict(value=[dict(a3HysteresisSsbRsrp='1', a3OffsetSsbRsrp='4', a3TimeToTriggerSsbRsrp='ms128')],
         dist_name=_CELL2_1, parameter='a3MeasSsbRsrp'),
    dict(value='60min', dist_name=_PMCADM2, parameter='reportingIntervalPm'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname2,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname2,
         parameter='integrityProtPrefL')
]


SFE_TMO_ping_pang_kpi_name = [
    "5G_Xn_outgoing_handover_preparation_cancelation_ratio",
    "5G_SA_Xn_based_Inter-gNB_HO_Cancel_ratio_on_the_target_cell",
    "5G_SA_Xn_based_Inter-gNB_HO_preparation_failure_ratio_on_the_target_cell_due_to_admission_control_reasons",
    "5G_SA_Xn_based_Inter-gNB_HO_preparation_failure_ratio_on_the_target_cell_due_to_other_reasons",
    "5G_SA_Xn_based_inter-gNB_intra-frequency_HO_execution_attempts_per_PLMN",
    "5G_SA_Xn_based_Inter-gNB_intra-frequency_HO_execution_success_ratio_per_PLMN",
    "5G_SA_intra-frequency_Xn_based_inter-gNB_handover_execution_success_ratio_per_PLMN",
    "Number_of_outgoing_Handover_Cancel_sent_to_Target_gNB",
    "Number_of_outgoing_HANDOVER_CANCEL_messages_received_by_the_target_gNB"
]
SFE_TMO_ping_pang_kpi_id = [
    "NR_669a",
    "NR_5498a",
    "NR_5494a",
    "NR_5497a",
    "NR_5203a",
    "NR_5204a",
    "NR_5183b",
    "XN_HO_CANCEL_SENT",
    "XN_HO_CANCEL_RECEIVED",
    "SUCC_OG_INTER_GNB_HO_SA_PLMN"
]
