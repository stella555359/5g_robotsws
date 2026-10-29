from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
PROGRAM = BuiltIn().get_variable_value("${PROGRAM}")
TCE_IP_ADDR = BuiltIn().get_variable_value("${TCE_IP_ADDR}")
TCE_PORT = BuiltIn().get_variable_value("${TCE_PORT}")

DN_MRBTS = "MRBTS-" + str(tl.gnbs[0].instance_id)
DN_NRBTS = DN_MRBTS + "/NRBTS-" + str(tl.gnbs[0].global_bts_id)

TDD_CELL_ID = 1
TDD_CELL_ID_GNB1 = 1

TDD_CELL_ID_LIST = [TDD_CELL_ID]
CELL_LIST_GNB0 = [TDD_CELL_ID]
CELL_LIST_GNB1 = [TDD_CELL_ID_GNB1]

DN_TDDCELL = DN_NRBTS + "/NRCELL-%s" % TDD_CELL_ID
DN_MRBTS_GNB1 = "MRBTS-" + str(tl.gnbs[1].instance_id)
DN_NRBTS_GNB1 = DN_MRBTS_GNB1 + "/NRBTS-" + str(tl.gnbs[1].global_bts_id)
DN_TDDCELL_GNB1 = DN_NRBTS_GNB1 + "/NRCELL-" + str(TDD_CELL_ID_GNB1)

# add begin by 10437-jx
TCEADM = DN_MRBTS + '/MNL-1/TCEADM-1'
TCE = TCEADM + '/TCE-1'
NRMTRACECU = DN_NRBTS + '/NRCTRLTS-1/NRMTRACECU-1'
NRMTRACEDU = DN_NRBTS + '/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1'
# add end

PARAMS_TO_MODIFY_PAGING_VICTIM = BuiltIn().get_variable_value('${PARAMS_TO_MODIFY_PAGING_VICTIM}')
PARAMS_TO_MODIFY_PAGING_AGGRESSOR = BuiltIn().get_variable_value('${PARAMS_TO_MODIFY_PAGING_AGGRESSOR}')
PARAMS_TO_MODIFY_PAGING_VICTIM = [] if PARAMS_TO_MODIFY_PAGING_VICTIM is None \
    else PARAMS_TO_MODIFY_PAGING_VICTIM
PARAMS_TO_MODIFY_PAGING_AGGRESSOR = [] if PARAMS_TO_MODIFY_PAGING_AGGRESSOR is None \
    else PARAMS_TO_MODIFY_PAGING_AGGRESSOR

STR_1116_3MS_4GP_100MHZ = BuiltIn().get_variable_value("${STR_1116_3MS_4GP_100MHZ}")
STR_1116_0MS_6GP_60MHZ = BuiltIn().get_variable_value("${STR_1116_0MS_6GP_60MHZ}")
STR_1208_2GP_40MHZ = BuiltIn().get_variable_value("${STR_1208_2GP_40MHZ}")
STR_1070_2GP_80MHZ = BuiltIn().get_variable_value("${STR_1070_2GP_80MHZ}")

RS_TRANS_TRIGGER = BuiltIn().get_variable_value("${RS_TRANS_TRIGGER}")
RS_TRANS_TRIGGER_AGGRESSOR = BuiltIn().get_variable_value("${RS_TRANS_TRIGGER_AGGRESSOR}")
DL_MUTE_SLOTS_SPECIAL = BuiltIn().get_variable_value("${DL_MUTE_SLOTS_SPECIAL}")
DL_MUTE_SLOTS_SPECIAL_PRECEDING = BuiltIn().get_variable_value(
    "${DL_MUTE_SLOTS_SPECIAL_PRECEDING}"
)
DL_MUTE_SLOTS_1st_PRECEDING = BuiltIn().get_variable_value(
    "${DL_MUTE_SLOTS_1st_PRECEDING}"
)

MITIGATION_SCHEME_DL_UL = BuiltIn().get_variable_value("${MITIGATION_SCHEME_DL_UL}")
MITIGATION_SCHEME_DL_ONLY = BuiltIn().get_variable_value("${MITIGATION_SCHEME_DL_ONLY}")
MITIGATION_SCHEME_UL_ONLY = BuiltIn().get_variable_value("${MITIGATION_SCHEME_UL_ONLY}")
MITIGATION_SCHEME_NO_MITIGATION = BuiltIn().get_variable_value(
    "${MITIGATION_SCHEME_NO_MITIGATION}"
)

NEAR_ONLY = BuiltIn().get_variable_value("${NEAR_ONLY}")
NEAR_FAR_1 = BuiltIn().get_variable_value("${NEAR_FAR_1}")
NEAR_FAR_2 = BuiltIn().get_variable_value("${NEAR_FAR_2}")
RI_THRES_BASE = BuiltIn().get_variable_value("${RI_THRES_BASE}")

START_RB_FOR_RS_100MHZ = ["30", "126"]
START_RB_FOR_RS_80MHZ = ["20", "68"]
START_RB_FOR_RS_60MHZ = ["30", "78"]
START_RB_FOR_RS_40MHZ = ["5"]

NUM_RIMRS1_SETID_1116_0MS_6GP = "131072 setIDs" if PROGRAM >= "23R4" else "1048576 setIDs"
NUM_RIMRS1_SETID_1116_3MS_4GP = "65536 setIDs" if PROGRAM > "24R1" else "1048576 setIDs"
NUM_RIMRS1_SETID_1070 = "524288 setIDs" if PROGRAM >= "23R4" else "1048576 setIDs"
NUM_RIMRS1_SETID_1028 = "262144 setIDs" if PROGRAM >= "23R4" else "1048576 setIDs"

NEAR_FAR_FOR_CNI102746 = NEAR_FAR_2 if PROGRAM >= "23R4" else NEAR_ONLY
MANUAL_FRAME_TIMING_FOR_CNI102746 = 11790000 if PROGRAM >= "23R4" else 5360000
# no pdsch scheduled on Special slot when GP=6, so 4+14+5=23
# 20250210: pdcch scheduled on Special slot symbol0 when targetTotalLoadSectorBeam=100, so 4+14+6=24
UL_RI_SYMBOLS_CNI102746 = 24

DEFAULT_RS_DETECTION_DURATION_WO_RI = BuiltIn().get_variable_value("${DEFAULT_RS_DETECTION_DURATION_WO_RI}")
MIN_RS_DETECTION_DURATION_WO_RI = BuiltIn().get_variable_value("${MIN_RS_DETECTION_DURATION_WO_RI}")

DL_MUTE_SLOT_1116_6GP = DL_MUTE_SLOTS_1st_PRECEDING if PROGRAM >= "24R3" else DL_MUTE_SLOTS_SPECIAL_PRECEDING

RI_WINDOW = 1 if PROGRAM >= "24R3" else 5
RI_TIMEOUT = '3min' if PROGRAM >= "24R3" else '10min'


# get common parameters for modify when commission
def get_scf_modify_common_parameters(dn_nrbts, dn_mrbts, dn_cell):
    modify_scf_common = [
        dict(value="true", dist_name=dn_nrbts, p_name="actEnhancedLinkAdaptation"),
        dict(value="true", dist_name=dn_nrbts, p_name="actFdmScheduling"),
        dict(value="false", dist_name=dn_nrbts, p_name="actCarrierAggregation"),
        # dict(
        #     value="4x4 or 4x2 Closed Loop Spatial Multiplexing",
        #     dist_name=dn_cell,
        #     p_name="dlMimoMode",
        # ),
        dict(value="true", dist_name=dn_cell, p_name="actPdschAtSsbSlots"),
        dict(value="longPucch", dist_name=dn_cell, p_name="pucchModeSelect"),
        dict(value="true", dist_name=dn_cell, p_name="actBeamforming"),
        dict(value="false", dist_name=dn_cell, p_name="actDlMuMimo"),
        # dict(value="false", dist_name=dn_cell, p_name="actUlMuMimo"),
        dict(value="19", dist_name=dn_cell, p_name="reqMinNumPuschPrb"),
        dict(value="true", dist_name=dn_cell, p_name="actPrachMultiplexing"),
        dict(value="19", dist_name=dn_cell, p_name="msg1FrequencyStart"),
        dict(value="qpsk_4psk", dist_name=dn_cell, p_name="pucchF3ModulationScheme"),
        dict(value="zeroDot15", dist_name=dn_cell, p_name="pucchF3MaxCodeRate"),
        dict(value="slots160", dist_name=dn_cell, p_name="srPeriodicity"),
        dict(
            value="slots320",
            dist_name=dn_cell,
            p_name="csiReportPeriodicity",
            list_name="periodicCsiAcquisition",
        ),
        dict(
            value="-108",
            dist_name=dn_cell,
            p_name="p0NominalPucchF1F3",
            list_name="ulPowerControlCommon",
        ),
        dict(
            value="0",
            dist_name=dn_cell,
            p_name="pucchF3DeltaF",
            list_name="ulPowerControlCommon",
        ),
        dict(
            value="-10",
            dist_name=dn_cell,
            p_name="pucchF1DeltaF",
            list_name="ulPowerControlCommon",
        ),
        dict(value="true", dist_name=dn_cell, p_name="actUlSrsBm"),
        dict(value="true", dist_name=dn_cell, p_name="actDlSrsBm"),
        dict(dist_name=dn_nrbts, p_name="nea0", value="9"),
        dict(dist_name=dn_nrbts, p_name="nea1_128", value="0"),
        dict(dist_name=dn_nrbts, p_name="nea2_128", value="0"),
        dict(dist_name=dn_nrbts, p_name="nea3_128", value="0"),
        dict(value="true", dist_name=dn_cell, p_name="actAperCsi"),
        dict(
            value="5min",
            dist_name=dn_mrbts + "/MNL-1/MNLENT-1/PMCADM-1",
            p_name="reportingIntervalPm",
        ),
        dict(
            value="5min",
            dist_name=dn_nrbts + "/NRPMRNL-1",
            p_name="miNrCellUtilization",
        ),
    ]

    miNrRim = [
        dict(
            value="5min",
            dist_name=dn_nrbts + "/NRPMRNL-1",
            p_name="miNrRim",
        ),
    ]

    modify_scf_common = modify_scf_common + miNrRim if PROGRAM > '24R1' else modify_scf_common
    return modify_scf_common


# get 6991 related parameters for modify when commission
def get_scf_modify_6991_for_specific_frame_bw(
    dn_nrbts, dn_mrbts, dn_cell, config_6991, is_aggressor
):
    modify_paging = []
    if is_aggressor:
        modify_paging = PARAMS_TO_MODIFY_PAGING_AGGRESSOR
        modify_target_load = [
            dict(value=0, dist_name=dn_cell, p_name="targetTotalLoad"),
            dict(value=0, dist_name=dn_cell, p_name="targetTotalLoadSectorBeam"),
            dict(value='PDSCH+PDCCH+TRS+SSB', dist_name=dn_cell, p_name="actConfDlInterferenceGen"),
            dict(value=28, dist_name=dn_cell, p_name="mcsIndexForArtificialLoad"),
            dict(value='enhanced', dist_name=dn_cell, p_name="actDlRbgRandomization"),
        ]
        modify_scf_6991 = modify_target_load + __get_scf_modify_6991_parameters(
            dn_nrbts,
            dn_mrbts,
            dn_cell,
            config_6991.get("frameStructureBW"),
            config_6991.get("nrRimMitigationScheme"),
            config_6991.get("numRsType1SetId"),
            config_6991.get("numRbForRs"),
            config_6991.get("repetitionRsType1"),
            config_6991.get("rsPattern1Period"),
            # config_6991.get("rsPattern2Period"),
            config_6991.get("rsSetIdAggressor"),
            config_6991.get("manualFrameTimingAdjustmentAggressor"),
            config_6991.get("nrRiMonitorDownhillEndSymbol"),
            config_6991.get("near_far"),
            RS_TRANS_TRIGGER_AGGRESSOR,
            RI_THRES_BASE,
            config_6991.get("maxRsDetectDurationWithoutRi")
        )
    else:
        modify_paging = PARAMS_TO_MODIFY_PAGING_VICTIM
        modify_target_load = [
            dict(value=0, dist_name=dn_cell, p_name="targetTotalLoad"),
        ]
        modify_scf_6991 = modify_target_load + __get_scf_modify_6991_parameters(
            dn_nrbts,
            dn_mrbts,
            dn_cell,
            config_6991.get("frameStructureBW"),
            config_6991.get("nrRimMitigationScheme"),
            config_6991.get("numRsType1SetId"),
            config_6991.get("numRbForRs"),
            config_6991.get("repetitionRsType1"),
            config_6991.get("rsPattern1Period"),
            # config_6991.get("rsPattern2Period"),
            config_6991.get("rsSetId"),
            config_6991.get("manualFrameTimingAdjustment"),
            config_6991.get("nrRiMonitorDownhillEndSymbol"),
            config_6991.get("near_far"),
            RS_TRANS_TRIGGER,
            RI_THRES_BASE,
            config_6991.get("maxRsDetectDurationWithoutRi")
        )
    return modify_paging + modify_scf_6991


def __get_scf_modify_6991_parameters(
    dn_nrbts,
    dn_mrbts,
    dn_cell,
    frame_structure_bw,
    nr_rim_mitigation_scheme,
    num_rs_type1_setid,
    num_rb_for_rs,
    repetition_rs_type1,
    rs_pattern1_period,
    rs_setid,
    manual_frame_timing_adjustment,
    nrRiMonitorDownhillEndSymbol,
    near_far,
    rs_trans_trigger,
    ri_thres_base,
    max_rs_detect_duration_without_Ri
):
    modify_scf_6991_common = [
        dict(value="true", dist_name=dn_cell, p_name="actDynUlResAlloc"),
        dict(value="framework-0", dist_name=dn_cell, p_name="actNrRim"),
        dict(
            value=nrRiMonitorDownhillEndSymbol,
            dist_name=dn_cell + "/NRRIM_PROFILE-1",
            p_name="nrRiMonitorDownhillEndSymbol",
        ),
        dict(
            value="0",
            dist_name=dn_cell + "/NRRIM_PROFILE-1",
            p_name="nrRiMonitorDownhillStartSymbol",
        ),
        dict(
            value=ri_thres_base, dist_name=dn_cell + "/NRRIM_PROFILE-1", p_name="nrRiThresBase"
        ),
        dict(
            value="3",
            dist_name=dn_cell + "/NRRIM_PROFILE-1",
            p_name="nrRiThresDropHeight",
        ),
        dict(
            value="50",
            dist_name=dn_cell + "/NRRIM_PROFILE-1",
            p_name="nrRiThresDurationRatio",
        ),
        dict(
            value="dB4",
            dist_name=dn_cell + "/NRRIM_PROFILE-1",
            p_name="nrRimPowerRampingStep",
        ),
        dict(
            value="2dB",
            dist_name=dn_cell + "/NRRIM_PROFILE-1",
            p_name="nrRimRarTpcCommand",
        ),
        dict(
            value="0",
            dist_name=dn_cell + "/NRRIM_PROFILE-1",
            p_name="rsPowerOffset"
        ),
        dict(
            value="2147483647",
            dist_name=dn_cell + "/NRRIM_PROFILE-1",
            p_name="factorRsSequence"
        ),
        dict(
            value="2147483647",
            dist_name=dn_cell + "/NRRIM_PROFILE-1",
            p_name="offsetRsSequence"
        ),
        dict(
            value=RI_WINDOW,
            dist_name=dn_cell + "/NRRIM_PROFILE-1",
            p_name="nrRiMonitorWindow"
        ),
        dict(
            value=rs_trans_trigger,
            dist_name=dn_cell + "/NRRIM_PROFILE-1",
            p_name="rsTransTrigger"
        ),
    ]

    modify_scf_6991_rs = [
        dict(
            value=rs_pattern1_period,
            dist_name=dn_cell + "/NRRIM_PROFILE-1",
            p_name="rsPattern1Period",
        ),
        dict(
            value=num_rb_for_rs,
            dist_name=dn_cell + "/NRRIM_PROFILE-1",
            p_name="numRbForRs",
        ),
        dict(
            value=num_rs_type1_setid,
            dist_name=dn_cell + "/NRRIM_PROFILE-1",
            p_name="numRsType1SetId",
        ),
        dict(
            value=repetition_rs_type1,
            dist_name=dn_cell + "/NRRIM_PROFILE-1",
            p_name="repetitionRsType1",
        ),
        dict(
            value=nr_rim_mitigation_scheme,
            dist_name=dn_cell + "/NRRIM_PROFILE-1",
            p_name="nrRimMitigationScheme",
        ),
        dict(
            value=manual_frame_timing_adjustment,
            dist_name=dn_mrbts + "/MNL-1/MNLENT-1/SYNC-1",
            p_name="manualFrameTimingAdjustment",
        ),
        dict(
            value=near_far,
            dist_name=dn_cell + "/NRRIM_PROFILE-1",
            p_name="rsNearFarConfig",
        ),
        dict(value=rs_setid, dist_name=dn_cell + "/NRRIM_PROFILE-1", p_name="rsSetId")
    ]

    modify_bwp_1116_3ms_4gp_100mhz = [
        dict(value="19", dist_name=dn_cell, p_name="msg1FrequencyStart"),
        dict(value="63", dist_name=dn_cell, p_name="cSRS"),
        dict(value="98", dist_name=dn_cell, p_name="prachConfigurationIndex"),
        dict(value="tdLte", dist_name=dn_cell, p_name="frameStructureType"),
        dict(value="3ms", dist_name=dn_cell, p_name="lteToNrFrameShift"),
        dict(value="4Symbols", dist_name=dn_cell, p_name="guardPeriodLength"),
        dict(value="tdLteConfig2", dist_name=dn_cell, p_name="tdLteUlDlConfig"),
        dict(value="", dist_name=dn_cell, p_name="ulDlDataSlotRatio"),
        dict(value="100MHz", dist_name=dn_cell, p_name="chBw"),
        dict(
            value=dn_nrbts + "/BWP_PROFILE-7",
            dist_name=dn_cell,
            p_name="bwpDN",
            index="0",
        ),
        dict(
            value=dn_nrbts + "/BWP_PROFILE-77",
            dist_name=dn_cell,
            p_name="bwpDN",
            index="1",
        ),
    ]

    modify_bwp_1116_0ms_6gp_60mhz = [
        dict(value="0", dist_name=dn_cell, p_name="msg1FrequencyStart"),
        dict(value="42", dist_name=dn_cell, p_name="cSRS"),
        dict(value="96", dist_name=dn_cell, p_name="prachConfigurationIndex"),
        dict(value="tdLte", dist_name=dn_cell, p_name="frameStructureType"),
        dict(value="6Symbols", dist_name=dn_cell, p_name="guardPeriodLength"),
        dict(value="0ms", dist_name=dn_cell, p_name="lteToNrFrameShift"),
        dict(value="tdLteConfig2", dist_name=dn_cell, p_name="tdLteUlDlConfig"),
        dict(value="", dist_name=dn_cell, p_name="ulDlDataSlotRatio"),
        dict(value="60MHz", dist_name=dn_cell, p_name="chBw"),
        dict(
            value=dn_nrbts + "/BWP_PROFILE-8",
            dist_name=dn_cell,
            p_name="bwpDN",
            index="0",
        ),
        dict(
            value=dn_nrbts + "/BWP_PROFILE-73",
            dist_name=dn_cell,
            p_name="bwpDN",
            index="1",
        ),
    ]

    modify_bwp_1208_2gp_40mhz = [
        dict(value="19", dist_name=dn_cell, p_name="msg1FrequencyStart"),
        dict(value="25", dist_name=dn_cell, p_name="cSRS"),
        dict(value="92", dist_name=dn_cell, p_name="prachConfigurationIndex"),
        dict(value="semiStatic", dist_name=dn_cell, p_name="frameStructureType"),
        dict(value="2Symbols", dist_name=dn_cell, p_name="guardPeriodLength"),
        dict(value="", dist_name=dn_cell, p_name="lteToNrFrameShift"),
        dict(value="tdLteConfig2", dist_name=dn_cell, p_name="tdLteUlDlConfig"),
        dict(value="1/4", dist_name=dn_cell, p_name="ulDlDataSlotRatio"),
        dict(value="40MHz", dist_name=dn_cell, p_name="chBw"),
        dict(
            value=dn_nrbts + "/BWP_PROFILE-5",
            dist_name=dn_cell,
            p_name="bwpDN",
            index="0",
        ),
        dict(
            value=dn_nrbts + "/BWP_PROFILE-51",
            dist_name=dn_cell,
            p_name="bwpDN",
            index="1",
        ),
    ]

    modify_bwp_1070_2gp_80mhz = [
        dict(value="19", dist_name=dn_cell, p_name="msg1FrequencyStart"),
        dict(value="25", dist_name=dn_cell, p_name="cSRS"),
        dict(value="92", dist_name=dn_cell, p_name="prachConfigurationIndex"),
        dict(value="semiStatic", dist_name=dn_cell, p_name="frameStructureType"),
        dict(value="2Symbols", dist_name=dn_cell, p_name="guardPeriodLength"),
        dict(value="", dist_name=dn_cell, p_name="lteToNrFrameShift"),
        dict(value="tdLteConfig2", dist_name=dn_cell, p_name="tdLteUlDlConfig"),
        dict(value="3/7", dist_name=dn_cell, p_name="ulDlDataSlotRatio"),
        dict(value="80MHz", dist_name=dn_cell, p_name="chBw"),
        dict(
            value=dn_nrbts + "/BWP_PROFILE-6",
            dist_name=dn_cell,
            p_name="bwpDN",
            index="0",
        ),
        dict(
            value=dn_nrbts + "/BWP_PROFILE-65",
            dist_name=dn_cell,
            p_name="bwpDN",
            index="1",
        ),
    ]

    rimrs_detection_wo_ri = []
    if PROGRAM > "23R4":
        rimrs_detection_wo_ri = [
            dict(
                value=max_rs_detect_duration_without_Ri,
                dist_name=dn_cell + "/NRRIM_PROFILE-1",
                p_name="maxRsDetectDurationWithoutRi",
            ),
        ]

    modify_scf_default = modify_scf_6991_common + modify_scf_6991_rs + rimrs_detection_wo_ri
    if frame_structure_bw == STR_1116_3MS_4GP_100MHZ:
        modify_scf_default = modify_scf_default + modify_bwp_1116_3ms_4gp_100mhz
    elif frame_structure_bw == STR_1116_0MS_6GP_60MHZ:
        modify_scf_default = modify_scf_default + modify_bwp_1116_0ms_6gp_60mhz
    elif frame_structure_bw == STR_1208_2GP_40MHZ:
        modify_scf_default = modify_scf_default + modify_bwp_1208_2gp_40mhz
    elif frame_structure_bw == STR_1070_2GP_80MHZ:
        modify_scf_default = modify_scf_default + modify_bwp_1070_2gp_80mhz
    return modify_scf_default


MODIFY_SCF_BASE = get_scf_modify_common_parameters(DN_NRBTS, DN_MRBTS, DN_TDDCELL)
MODIFY_SCF_BASE_AGGRESSOR = get_scf_modify_common_parameters(
    DN_NRBTS_GNB1, DN_MRBTS_GNB1, DN_TDDCELL_GNB1
)

MODIFY_SCF_NRRIM_24R3 = [
    dict(
        value="enabled",
        dist_name=DN_TDDCELL + "/NRRIM_PROFILE-1",
        p_name="rsSetIdDisplayInFault")
 ]

# need to set true for 1116 framestructure
ACT_PDSCHSchSplSlot = [
    dict(value='true', dist_name=DN_TDDCELL, p_name="actEnhancedPDSCHSchSplSlot"),
]
DISABLE_PDSCHSchSplSlot = [
    dict(value='false', dist_name=DN_TDDCELL, p_name="actEnhancedPDSCHSchSplSlot"),
]
ACT_PDSCHSchSplSlot_AGGRESSOR = [
    dict(value='true', dist_name=DN_TDDCELL_GNB1, p_name="actEnhancedPDSCHSchSplSlot"),
]
DISABLE_PDSCHSchSplSlot_AGGRESSOR = [
    dict(value='false', dist_name=DN_TDDCELL_GNB1, p_name="actEnhancedPDSCHSchSplSlot"),
]

PARAMS_TO_ADD_TRACE_CU_ACTIVE_PCMD = [
    dict(dist_name=DN_NRBTS, p_name='actPCMDReport', value='true'),
    dict(dist_name=NRMTRACECU, version="NRBTSCL24R1_2322_110", class_name="com.nokia.srbts.nrbts:NRMTRACECU"),
    dict(dist_name=NRMTRACECU, p_name='actCellTraceReportingCU', value='false'),
    dict(dist_name=NRMTRACECU, p_name='actPCMDReporting', value='false'),
    dict(dist_name=NRMTRACECU, p_name='cellMaxActiveUEsTraced', value='100'),
    dict(dist_name=NRMTRACECU, p_name='jobType', value='TraceOnly'),
    dict(dist_name=NRMTRACECU, p_name='nrTceIdentifier', value='1'),
    dict(dist_name=NRMTRACECU, p_name='scope', value='specificResources'),
    dict(dist_name=NRMTRACECU, p_name='traceNGAPSetting', value='none'),
    dict(dist_name=NRMTRACECU, p_name='traceNRRRCSetting', value='none'),
    dict(dist_name=NRMTRACECU, p_name='traceE1Setting', value='none'),
    dict(dist_name=NRMTRACECU, p_name='traceF1Setting', value='none'),
    dict(dist_name=NRMTRACECU, p_name='traceX2Setting', value='none'),
    dict(dist_name=NRMTRACECU, p_name='traceXNSetting', value='none'),
    dict(dist_name=NRMTRACECU, list_name='nrRanTraceReference',
         elements={"mcc": "310", "mnc": "260", "mncLength": "3", "traceId": "1"}),
    dict(dist_name=NRMTRACECU + '/NRRESOURCECU-1', version="NRBTSCL24R1_2322_110",
         class_name="com.nokia.srbts.nrbts:NRRESOURCECU"),
    dict(dist_name=NRMTRACECU + '/NRRESOURCECU-1', p_name='resourceDN', value=DN_TDDCELL),
    dict(dist_name=NRMTRACECU + '/NRRESOURCECU-1', p_name='typeNrCu', value='cell'),
]

PARAMS_TO_ADD_TRACE_DU_ACTIVE_PCMD_RIREPORT = [
    dict(dist_name=NRMTRACEDU, version="NRBTSCL24R1_2322_110", class_name="com.nokia.srbts.nrbts:NRMTRACEDU"),
    dict(dist_name=NRMTRACEDU, p_name='actPCMDReporting', value='false'),
    dict(dist_name=NRMTRACEDU, p_name='actRIReporting', value='true'),
    dict(dist_name=NRMTRACEDU, p_name='cellMaxActiveUEsTraced', value='100'),
    dict(dist_name=NRMTRACEDU, p_name='jobType', value='TraceOnly'),
    dict(dist_name=NRMTRACEDU, p_name='nrTceIdentifier', value='1'),
    dict(dist_name=NRMTRACEDU, p_name='riReportInterval', value='s5'),
    dict(dist_name=NRMTRACEDU, p_name='scope', value='allResources'),
    dict(dist_name=NRMTRACEDU, list_name='nrRanTraceReference',
         elements={"mcc": "310", "mnc": "260", "mncLength": "3", "traceId": "1"}),
]

PARAMS_TO_ADD_NRMTRACEDU_25R3 = [
    dict(dist_name=NRMTRACEDU, p_name='tracePCMDCoordinateSystem', value='DoA'),
    dict(dist_name=NRMTRACEDU, list_name='tracePCMDSetting',
         elements={"RI Slope Measurement", "RIM-RS Monitoring", "RIM-RS Transmission"}),
]

PARAMS_TO_ADD_NRMTRACEDU_26R1 = [
    dict(dist_name=NRMTRACEDU, list_name='tracePCMDSetting',
         elements={"RI Slope Measurement", "RIM-RS Monitoring", "RIM-RS Transmission"}),
]

PARAMS_TO_ADD_TCE_1 = [
    dict(dist_name=TCE, version="MNL24R1_2322_100", class_name="com.nokia.srbts.mnl:TCE"),
    dict(dist_name=TCE, p_name='certTypeForTlsAuth', value='RSA'),
    dict(dist_name=TCE, p_name='tceIdentifier', value='1'),
    dict(dist_name=TCE, p_name='tceIpAddress', value=TCE_IP_ADDR),
    dict(dist_name=TCE, p_name='tcePortNumber', value=TCE_PORT),
    dict(dist_name=TCE, p_name='tlsEnabled', value='false'),
]


PARAMS_TO_DELETE_NRMTRACECU_1 = [
    dict(dist_name=NRMTRACECU),

]

PARAMS_TO_DELETE_NRMTRACEDU_1 = [
    dict(dist_name=NRMTRACEDU),
]

PARAMS_TO_DELETE_TCE_1 = [
    dict(dist_name=TCE),
]

PARAMS_TO_DELETE_PCMD = PARAMS_TO_DELETE_NRMTRACECU_1 + PARAMS_TO_DELETE_NRMTRACEDU_1 + PARAMS_TO_DELETE_TCE_1
PARAMS_TO_ADD_PCMD = PARAMS_TO_ADD_TRACE_CU_ACTIVE_PCMD + PARAMS_TO_ADD_TRACE_DU_ACTIVE_PCMD_RIREPORT + \
                     PARAMS_TO_ADD_TCE_1
if PROGRAM == '25R3':
    PARAMS_TO_ADD_PCMD = PARAMS_TO_ADD_PCMD + PARAMS_TO_ADD_NRMTRACEDU_25R3
elif PROGRAM >= '26R1':
    PARAMS_TO_ADD_PCMD = PARAMS_TO_ADD_PCMD + PARAMS_TO_ADD_NRMTRACEDU_26R1
