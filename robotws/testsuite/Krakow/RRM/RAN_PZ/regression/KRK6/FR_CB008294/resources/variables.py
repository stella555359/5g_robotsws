from dataclasses import dataclass


@dataclass
class Counter:
    id: str
    label: str
    localmoid: str


cell_ids = [250, 251, 252, 253, 254, 255, 256, 257]

query_pdu_session_resource_setup_message = """
    PDUSessionResourceSetupItemCxtRes(
        contains(PDUSessionResourceSetupItemCxtRes),
        contains(transportLayerAddress*)
    )
"""

query_rrc_reconfiguration_with_scell_message = f"""
    rrcReconfiguration(
        contains(sCellToAddModList: 7 items),
        contains(physCellId={cell_ids[1]}),
        contains(physCellId={cell_ids[2]}),
        contains(physCellId={cell_ids[3]}),
        contains(physCellId={cell_ids[4]}),
        contains(physCellId={cell_ids[5]}),
        contains(physCellId={cell_ids[6]}),
        contains(physCellId={cell_ids[7]})
    )
"""

query_rrc_reconfiguration_with_3_consecutive_scell_message = f"""
    rrcReconfiguration(
        contains(sCellToAddModList: 3 items),
        contains(physCellId={cell_ids[1]}),
        contains(physCellId={cell_ids[2]}),
        contains(physCellId={cell_ids[3]}),
        not_contains(physCellId={cell_ids[4]}),
        not_contains(physCellId={cell_ids[5]}),
        not_contains(physCellId={cell_ids[6]}),
        not_contains(physCellId={cell_ids[7]})
    )
"""

query_rrc_reconfiguration_with_3_scell_message = f"""
    rrcReconfiguration(
        contains(sCellToAddModList: 3 items),
        contains(physCellId={cell_ids[1]}),
        contains(physCellId={cell_ids[3]}),
        contains(physCellId={cell_ids[4]}),
        not_contains(physCellId={cell_ids[2]}),
        not_contains(physCellId={cell_ids[5]}),
        not_contains(physCellId={cell_ids[6]}),
        not_contains(physCellId={cell_ids[7]})
    )
"""

query_rrc_reconfiguration_with_6_scell_message = f"""
    rrcReconfiguration(
        contains(sCellToAddModList: 4 items),
        contains(physCellId={cell_ids[1]}),
        contains(physCellId={cell_ids[4]}),
        contains(physCellId={cell_ids[5]}),
        contains(physCellId={cell_ids[7]})
    )
"""

rrc_reconf_add7dlscell_att_sa = Counter(
    id='M55118C00003',
    label='RRC_RECONF_ADD7DLSCELL_ATT_SA',
    localmoid='PLMN-PLMN/MRBTS-79050/NRBTS-79050/NRCELL-250'
)

rrc_reconf_add7dlscell_succ_sa = Counter(
    id='M55118C00006',
    label='RRC_RECONF_ADD7DLSCELL_SUCC_SA',
    localmoid='PLMN-PLMN/MRBTS-79050/NRBTS-79050/NRCELL-250'
)

###

rrc_reconf_add1ulscell_att_sa = Counter(
    id='M55118C10001',
    label='RRC_RECONF_ADD1ULSCELL_ATT_SA',
    localmoid='PLMN-PLMN/MRBTS-79050/NRBTS-79050/NRCELL-250'
)

rrc_reconf_add1ulscell_succ_sa = Counter(
    id='M55118C10002',
    label='RRC_RECONF_ADD1ULSCELL_SUCC_SA',
    localmoid='PLMN-PLMN/MRBTS-79050/NRBTS-79050/NRCELL-250'
)

# OTHERS


rrc_reconf_add3dlscell_att_sa = Counter(
    id='M55118C09503',
    label='RRC_RECONF_ADD3DLSCELL_ATT_SA',
    localmoid='PLMN-PLMN/MRBTS-79050/NRBTS-79050/NRCELL-250'
)
rrc_reconf_add3dlscell_succ_sa = Counter(
    id='M55118C09502',
    label='RRC_RECONF_ADD3DLSCELL_SUCC_SA',
    localmoid='PLMN-PLMN/MRBTS-79050/NRBTS-79050/NRCELL-250'
)

rrc_reconf_add3ulscell_att_sa = Counter(
    id='M55118C00008',
    label='RRC_RECONF_ADD3ULSCELL_ATT_SA',
    localmoid='PLMN-PLMN/MRBTS-79050/NRBTS-79050/NRCELL-250'
)
rrc_reconf_add3ulscell_succ_sa = Counter(
    id='M55118C00010',
    label='RRC_RECONF_ADD3ULSCELL_SUCC_SA',
    localmoid='PLMN-PLMN/MRBTS-79050/NRBTS-79050/NRCELL-250'
)
ue_pcell_3_conf_scell_dl_sa = Counter(
    id='M55118C09501',
    label='UE_PCELL_3_CONF_SCELL_DL_SA',
    localmoid='PLMN-PLMN/MRBTS-79050/NRBTS-79050/NRCELL-250'
)
ue_pcell_3_conf_scell_ul_sa = Counter(
    id='M55118C00012',
    label='UE_PCELL_3_CONF_SCELL_UL_SA',
    localmoid='PLMN-PLMN/MRBTS-79050/NRBTS-79050/NRCELL-250'
)
gnb_du_scell_3_admi_req_sa = Counter(
    id='M55139C03001',
    label='GNB_DU_SCELL_3_ADMI_REQ_SA',
    localmoid='PLMN-PLMN/MRBTS-79050/NRBTS-79050/NRCELL-250'
)
gnb_du_scell_3_admi_succ_sa = Counter(
    id='M55139C03002',
    label='GNB_DU_SCELL_3_ADMI_SUCC_SA',
    localmoid='PLMN-PLMN/MRBTS-79050/NRBTS-79050/NRCELL-250'
)
gnb_scell_3_admi_req_sa = Counter(
    id='M55138C03001',
    label='GNB_SCELL_3_ADMI_REQ_SA',
    localmoid='PLMN-PLMN/MRBTS-79050/NRBTS-79050/NRCELL-250'
)
gnb_scell_3_admi_succ_sa = Counter(
    id='M55138C03002',
    label='GNB_SCELL_3_ADMI_SUCC_SA',
    localmoid='PLMN-PLMN/MRBTS-79050/NRBTS-79050/NRCELL-250'
)
ue_scell_3_conf_scell_ul_sa = Counter(
    id='M55118C00017',
    label='UE_SCELL_3_CONF_SCELL_UL_SA',
    localmoid='PLMN-PLMN/MRBTS-79050/NRBTS-79050/NRCELL-251'
)
ue_scell_3_conf_scell_dl_sa = Counter(
    id='M55118C11009',
    label='UE_SCELL_3_CONF_SCELL_DL_SA',
    localmoid='PLMN-PLMN/MRBTS-79050/NRBTS-79050/NRCELL-251'
)
samples_ue_amounts = Counter(
    id='M55118C01000',
    label='SAMPLES_UE_AMOUNTS',
    localmoid='PLMN-PLMN/MRBTS-79050/NRBTS-79050/NRCELL-250'
)
ue_pscell_act_scell_dl = Counter(
    id='M55316C02000',
    label='UE_PSCELL_ACT_SCELL_DL',
    localmoid='PLMN-PLMN/MRBTS-79050/NRBTS-79050/NRCELL-250'
)
ue_pscell_act_scell_ul = Counter(
    id='M55316C02001',
    label='UE_PSCELL_ACT_SCELL_UL',
    localmoid='PLMN-PLMN/MRBTS-79050/NRBTS-79050/NRCELL-250'
)
samples_ul_ue_amounts = Counter(
    id='M55316C01002',
    label='SAMPLES_UL_UE_AMOUNTS',
    localmoid='PLMN-PLMN/MRBTS-79050/NRBTS-79050/NRCELL-250'
)
samples_dl_ue_amounts = Counter(
    id='M55316C01003',
    label='SAMPLES_DL_UE_AMOUNTS',
    localmoid='PLMN-PLMN/MRBTS-79050/NRBTS-79050/NRCELL-250'
)
nr_rlc_pdu_dl_vol_ca_pcell = Counter(
    id='M55310C20001',
    label='NR_RLC_PDU_DL_VOL_CA_PCELL',
    localmoid='PLMN-PLMN/MRBTS-79050/NRBTS-79050/NRCELL-250'
)
ul_rlc_pdu_vol_rx_pri_path = Counter(
    id='M55316C14001',
    label='UL_RLC_PDU_VOL_RX_PRI_PATH',
    localmoid='PLMN-PLMN/MRBTS-79050/NRBTS-79050/NRCELL-250'
)
ul_rlc_pdu_rx_pri_path = Counter(
    id='M55316C14003',
    label='UL_RLC_PDU_RX_PRI_PATH',
    localmoid='PLMN-PLMN/MRBTS-79050/NRBTS-79050/NRCELL-250'
)
pscell_ue_3_act_scell_dl = Counter(
    id='M55316C03003',
    label='PSCELL_UE_3_ACT_SCELL_DL',
    localmoid='PLMN-PLMN/MRBTS-79050/NRBTS-79050/NRCELL-250'
)
pscell_ue_3_act_scell_ul = Counter(
    id='M55316C04003',
    label='PSCELL_UE_3_ACT_SCELL_UL',
    localmoid='PLMN-PLMN/MRBTS-79050/NRBTS-79050/NRCELL-250'
)
max_pscell_ue_3_act_scell_dl = Counter(
    id='M55316C05003',
    label='MAX_PSCELL_UE_3_ACT_SCELL_DL',
    localmoid='PLMN-PLMN/MRBTS-79050/NRBTS-79050/NRCELL-250'
)
max_pscell_ue_3_act_scell_ul = Counter(
    id='M55316C06003',
    label='MAX_PSCELL_UE_3_ACT_SCELL_UL',
    localmoid='PLMN-PLMN/MRBTS-79050/NRBTS-79050/NRCELL-250'
)
gnb_du_scell_admi_req_sa = Counter(
    id='M55139C01001',
    label='GNB_DU_SCELL_ADMI_REQ_SA',
    localmoid='PLMN-PLMN/MRBTS-79050/NRBTS-79050/NRCELL-251'
)
gnb_du_scell_admi_succ_sa = Counter(
    id='M55139C01002',
    label='GNB_DU_SCELL_ADMI_SUCC_SA',
    localmoid='PLMN-PLMN/MRBTS-79050/NRBTS-79050/NRCELL-251'
)
scell_activations = Counter(
    id='M55316C09000',
    label='SCELL_ACTIVATIONS',
    localmoid='PLMN-PLMN/MRBTS-79050/NRBTS-79050/NRCELL-251'
)
nr_rlc_pdu_dl_vol_ca_scell = Counter(
    id='M55310C20000',
    label='NR_RLC_PDU_DL_VOL_CA_SCELL',
    localmoid='PLMN-PLMN/MRBTS-79050/NRBTS-79050/NRCELL-251'
)
ul_rlc_pdu_vol_rx_sec_path = Counter(
    id='M55316C14002',
    label='UL_RLC_PDU_VOL_RX_SEC_PATH',
    localmoid='PLMN-PLMN/MRBTS-79050/NRBTS-79050/NRCELL-251'
)
ul_rlc_pdu_rx_sec_path = Counter(
    id='M55316C14004',
    label='UL_RLC_PDU_RX_SEC_PATH',
    localmoid='PLMN-PLMN/MRBTS-79050/NRBTS-79050/NRCELL-251'
)
max_ue_pcell_3_conf_scel_dl_sa = Counter(
    id='M55156C00025',
    label='MAX_UE_PCELL_3_CONF_SCEL_DL_SA',
    localmoid='PLMN-PLMN/MRBTS-79050/NRBTS-79050/NRCELL-250'
)
max_ue_pcell_3_conf_scel_ul_sa = Counter(
    id='M55156C00022',
    label='MAX_UE_PCELL_3_CONF_SCEL_UL_SA',
    localmoid='PLMN-PLMN/MRBTS-79050/NRBTS-79050/NRCELL-250'
)

a_400_counters = [
    rrc_reconf_add3dlscell_att_sa,
    rrc_reconf_add3dlscell_succ_sa,
    rrc_reconf_add1ulscell_att_sa,
    rrc_reconf_add1ulscell_succ_sa
]

a_400_pmo_1_counters = [
    rrc_reconf_add3dlscell_att_sa,
    rrc_reconf_add3dlscell_succ_sa,
    rrc_reconf_add3ulscell_att_sa,
    rrc_reconf_add3ulscell_succ_sa,
    max_ue_pcell_3_conf_scel_dl_sa,
    max_ue_pcell_3_conf_scel_ul_sa,
    ue_pcell_3_conf_scell_dl_sa,
    ue_pcell_3_conf_scell_ul_sa,
    gnb_du_scell_3_admi_req_sa,
    gnb_du_scell_3_admi_succ_sa,
    gnb_scell_3_admi_req_sa,
    gnb_scell_3_admi_succ_sa,
    ue_scell_3_conf_scell_ul_sa,
    ue_scell_3_conf_scell_dl_sa,
    ue_pscell_act_scell_dl,
    ue_pscell_act_scell_ul,
    nr_rlc_pdu_dl_vol_ca_pcell,
    ul_rlc_pdu_vol_rx_pri_path,
    ul_rlc_pdu_rx_pri_path,
    pscell_ue_3_act_scell_dl,
    pscell_ue_3_act_scell_ul,
    max_pscell_ue_3_act_scell_dl,
    max_pscell_ue_3_act_scell_ul,
    gnb_du_scell_admi_req_sa,
    gnb_du_scell_admi_succ_sa,
    scell_activations,
    nr_rlc_pdu_dl_vol_ca_scell,
    ul_rlc_pdu_vol_rx_sec_path,
    ul_rlc_pdu_rx_sec_path,
    samples_ue_amounts,
    samples_ul_ue_amounts,
    samples_dl_ue_amounts,
]

a_000_pmo_2_counters = [
    Counter(
        id='M55316C09001',
        label='SCELL_DEACT_BUFFER_STATUS',
        localmoid=f'PLMN-PLMN/MRBTS-79050/NRBTS-79050/NRCELL-{cell_id}'
    )
    for cell_id in cell_ids[1:]
]

delta_a_000_pmo_2_activation = [
    {
        'distName': "MRBTS-79050/NRBTS-79050",
        'operation': 'update',
        'parameters': [
            {
                'operation': 'update',
                'parameterName': "sCellActivationMethod",
                'value': "bufferBased"
            },
            {
                'operation': 'update',
                'parameterName': "actCsiReportsMuxOnPucch",
                'value': "false"
            }
        ]
    },
    *[
        {
            'distName': f"MRBTS-79050/NRBTS-79050/NRCELL-{cell_id}",
            'operation': 'update',
            'parameters': [
                {
                    'operation': 'update',
                    'parameterName': "sCellDeactivationTimerGNB",
                    'value': "ms1280"
                }
            ]
        }
        for cell_id in cell_ids
    ]
]

delta_a_000_pmo_2_deactivation = [
    {
        'distName': "MRBTS-79050/NRBTS-79050",
        'operation': 'update',
        'parameters': [
            {
                'operation': 'update',
                'parameterName': "sCellActivationMethod",
                'value': "blind"
            },
            {
                'operation': 'update',
                'parameterName': "actCsiReportsMuxOnPucch",
                'value': "true"
            }
        ]
    },
    *[
        {
            'distName': f"MRBTS-79050/NRBTS-79050/NRCELL-{cell_id}",
            'operation': 'update',
            'parameters': [
                {
                    'operation': 'update',
                    'parameterName': "sCellDeactivationTimerGNB",
                    'value': "infinity"
                }
            ]
        }
        for cell_id in cell_ids
    ]
]

delta_a_400_timer_period_setup = [
    {
        'distName': "MRBTS-79050/NRBTS-79050/NRPMRNL-1",
        'operation': 'update',
        'parameters': [{'operation': 'update',
                        'parameterName': "miNrCaCu",
                        'value': "15min"}]},
    {
        'distName': "MRBTS-79050/NRBTS-79050/NRPMRNL-1",
        'operation': 'update',
        'parameters': [{'operation': 'update',
                        'parameterName': "miNrRSACU",
                        'value': "15min"}]},
    {
        'distName': "MRBTS-79050/NRBTS-79050/NRPMRNL-1",
        'operation': 'update',
        'parameters': [{'operation': 'update',
                        'parameterName': "miNrRSADU",
                        'value': "15min"}]},
    {
        'distName': "MRBTS-79050/NRBTS-79050/NRPMRNL-1",
        'operation': 'update',
        'parameters': [{'operation': 'update',
                        'parameterName': "miNrRacCu",
                        'value': "15min"}]},
    {
        'distName': "MRBTS-79050/NRBTS-79050/NRPMRNL-1",
        'operation': 'update',
        'parameters': [{'operation': 'update',
                        'parameterName': "miNrRacDu",
                        'value': "15min"}]},
    {
        'distName': "MRBTS-79050/NRBTS-79050/NRPMRNL-1",
        'operation': 'update',
        'parameters': [{'operation': 'update',
                        'parameterName': "miNrCaDu",
                        'value': "15min"}]},
    {
        'distName': "MRBTS-79050/NRBTS-79050/NRPMRNL-1",
        'operation': 'update',
        'parameters': [{'operation': 'update',
                        'parameterName': "miNrLowRlcReport",
                        'value': "15min"}]},
    {
        'distName': "MRBTS-79050/NRBTS-79050/NRPMRNL-1",
        'operation': 'update',
        'parameters': [{'operation': 'update',
                        'parameterName': "miNrHighRlcCell",
                        'value': "15min"}]},
    {
        'distName': "MRBTS-79050/MNL-1/MNLENT-1/PMCADM-1",
        'operation': 'update',
        'parameters': [{'operation': 'update',
                        'parameterName': "reportingIntervalPm",
                        'value': "15min"}]}
    ]

delta_a_400_timer_period_teardown = [
    {
        'distName': "MRBTS-79050/NRBTS-79050/NRPMRNL-1",
        'operation': 'update',
        'parameters': [{'operation': 'update',
                        'parameterName': "miNrCaCu",
                        'value': "5min"}]},
    {
        'distName': "MRBTS-79050/NRBTS-79050/NRPMRNL-1",
        'operation': 'update',
        'parameters': [{'operation': 'update',
                        'parameterName': "miNrRSACU",
                        'value': "5min"}]},
    {
        'distName': "MRBTS-79050/NRBTS-79050/NRPMRNL-1",
        'operation': 'update',
        'parameters': [{'operation': 'update',
                        'parameterName': "miNrRSADU",
                        'value': "5min"}]},
    {
        'distName': "MRBTS-79050/NRBTS-79050/NRPMRNL-1",
        'operation': 'update',
        'parameters': [{'operation': 'update',
                        'parameterName': "miNrRacCu",
                        'value': "5min"}]},
    {
        'distName': "MRBTS-79050/NRBTS-79050/NRPMRNL-1",
        'operation': 'update',
        'parameters': [{'operation': 'update',
                        'parameterName': "miNrRacDu",
                        'value': "5min"}]},
    {
        'distName': "MRBTS-79050/NRBTS-79050/NRPMRNL-1",
        'operation': 'update',
        'parameters': [{'operation': 'update',
                        'parameterName': "miNrCaDu",
                        'value': "5min"}]},
    {
        'distName': "MRBTS-79050/NRBTS-79050/NRPMRNL-1",
        'operation': 'update',
        'parameters': [{'operation': 'update',
                        'parameterName': "miNrLowRlcReport",
                        'value': "5min"}]},
    {
        'distName': "MRBTS-79050/NRBTS-79050/NRPMRNL-1",
        'operation': 'update',
        'parameters': [{'operation': 'update',
                        'parameterName': "miNrHighRlcCell",
                        'value': "5min"}]},
    {
        'distName': "MRBTS-79050/MNL-1/MNLENT-1/PMCADM-1",
        'operation': 'update',
        'parameters': [{'operation': 'update',
                        'parameterName': "reportingIntervalPm",
                        'value': "5min"}]}
    ]
