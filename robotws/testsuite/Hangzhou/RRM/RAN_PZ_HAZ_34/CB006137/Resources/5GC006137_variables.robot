*** Settings ***
Documentation    This is about common variables used for 6137 feature.

*** Variables ***
# WA: dummy value for ${testline_name}, only for pipeline use.
${testline_name}    7_5_UTE5G402T255
${CA_GROUP_TYPE}    F+T
${IS_LOG_CAPTURED_CASE_LEVEL}                       ${True}
${MRBTS_ID}                                         ${tl.gnbs[0].instance_id}
${NRBTS_ID}                                         ${tl.gnbs[0].global_bts_id}
${DN_MRBTS}                                         MRBTS-${MRBTS_ID}
${DN_NRBTS}                                         ${DN_MRBTS}/NRBTS-${NRBTS_ID}
${DN_NRDU1}                                         ${DN_NRBTS}/NRDU-1
${SWCONFIG_DEFAULT_FILE_PATH}         /home/ute/Projects/mmw1_config/${testline_name}/swconfig/swconfig_MMW1_TL${MRBTS_ID}.txt
${SCF_DEFAULT_FILE_PATH}              /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${MRBTS_ID}.xml

${NSA_SA}  SA
@{carrierAggregationSupportList_F_T_UL_DL}  ca_Fdd_Fr1Tdd_Sa_WithUl  ca_Fr1Tdd_Fdd_Sa  ca_Fdd_Fr1Tdd_Sa  ca_Fdd_Fr1Tdd_Nsa  ca_Fdd_Any_Sa  ca_Fdd_Fdd
@{carrierAggregationSupportList_F_T_NO_UL}    ca_Fr1Tdd_Fdd_Sa    ca_Fdd_Fr1Tdd_Sa    ca_Fdd_Fr1Tdd_Nsa  ca_Fdd_Any_Sa  ca_Fdd_Fdd
@{carrierAggregationSupportList_F_T_NO_ULDL}    ca_Fr1Tdd_Fdd_Sa    ca_Fdd_Any_Sa  ca_Fdd_Fdd
${DL_TO_UL_CONTRIBUTION_RATIO}    50    # Should be 101 when no UL CA, otherwise PDL error exists
${A1_THRESHOLD_SCELL_ADD_SSB_RSRP}  75
${A1_THRESHOLD_SCELL_ADD_SSB_RSRP_FDD}  65
${A2_THRESHOLD_SCELL_REL_SSB_RSRP}  65

#
#${A1_THRESHOLD_PCELL_SWITCH_SSB_RSRP}   78
#${A2_THRESHOLD_PCELL_SWITCH_SSB_RSRP}   76
#${PCELL_TDD_DL_TRAFFIC_SMALL}  100
#${SCELL_BAD_RLQ_COUNT}    90
#${SCELL_CHANNEL_ESTIMATION_PERIOD}     2000

${EXP_DL_T20M_2x2_256QAM}     200
${EXP_DL_F20M_2x2_256QAM_POOL}     210
${EXP_DL_F20M_2x2_256QAM_POOL_PA_BAD}     50

${EXP_UL_F20M_2x2_64QAM_PA_BAD}  40
${EXP_DL_F10M_2x2_256QAM_POOL}    92

${EXP_DL_T100M_4x4_256QAM_1070}    1309

${EXP_UL_T100M_2x2_64QAM_1070}    120

${EXP_DL_T60M_2x2_256QAM_1070}    415
${DL_TPUT_IPERF_1070}         2050M
${DL_TPUT_IPERF}         2700M
${UL_TPUT_IPERF}         250M

#Buffer base Related
${BufferBase_DL_TRAFFIC_SMALL}  100
${BufferBase_DL_TRAFFIC_Big}      ${DL_TPUT_IPERF}
${BufferBase_UL_TRAFFIC_SMALL}  40
${BufferBase_UL_TRAFFIC_Big}      ${UL_TPUT_IPERF}


${TPUT_AVG_PERCENT_COMMON}    0.7
${TPUT_MIN_PERCENT_COMMON}    0.5

# This is only only in case CB006137_C_US_B27_01, peak case standard is 0.98 for CB006137-AB_01_US01
${TPUT_AVG_PERCENT_PEAK}    0.95
${TPUT_MIN_PERCENT_PEAK}    0.85

${BIP_ITF_ASIB}    eths

${TIMER_FOR_MODIFY_VIA_API}    5min
${TIMER_FOR_CELL_ON_AIR}       8min

${ULTRANSPRECODEOFFSINRTHRESH}    200
${ULTRANSPRECODEONSINRTHRESH}     150

${SCELL_BAD_RLQ_COUNT}    90
${SCELL_CHANNEL_ESTIMATION_PERIOD}     2000
