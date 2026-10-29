*** Settings ***
Documentation    This is about common variables used for 6137 feature.

*** Variables ***
# WA: dummy value for ${testline_name}, only for pipeline use.
${testline_name}    7_5_UTE5G402T254
${CA_GROUP_TYPE}    T+F
${IS_LOG_CAPTURED_CASE_LEVEL}                       ${True}
${MRBTS_ID}                                         ${tl.gnbs[0].instance_id}
${NRBTS_ID}                                         ${tl.gnbs[0].global_bts_id}
${DN_MRBTS}                                         MRBTS-${MRBTS_ID}
${DN_NRBTS}                                         ${DN_MRBTS}/NRBTS-${NRBTS_ID}
${DN_NRDU1}                                         ${DN_NRBTS}/NRDU-1
${SWCONFIG_DEFAULT_FILE_PATH}         /home/ute/Projects/mmw1_config/${testline_name}/swconfig/swconfig_MMW1_TL${MRBTS_ID}.txt
${SCF_DEFAULT_FILE_PATH}              /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${MRBTS_ID}.xml

${NSA_SA}  SA
@{carrierAggregationSupportList_T_F_UL_DL}  ca_Fr1Tdd_Fdd_Sa_WithUl  ca_Fr1Tdd_Fdd_Sa  ca_Fdd_Fr1Tdd_Sa
...  ca_Fr1Tdd_Any_Sa  ca_Fr1Tdd_Sa

@{carrierAggregationSupportList_T_F_UL_DL_pcell_change}  ca_Fr1Tdd_Fdd_Sa_WithUl  ca_Fr1Tdd_Fdd_Sa  ca_Fdd_Fr1Tdd_Sa
...  ca_Fr1Tdd_Any_Sa  ca_Fr1Tdd_Sa    ca_Fdd_Fr1Tdd_Sa_WithUl    ca_Fdd_Fdd    ca_Fdd_Any_Sa

#@{carrierAggregationSupportList_F_T_NO_UL}    ca_Fr1Tdd_Fdd_Sa    ca_Fdd_Fr1Tdd_Sa    ca_Fdd_Fr1Tdd_Nsa  ca_Fdd_Any_Sa  ca_Fdd_Fdd
#@{carrierAggregationSupportList_F_T_NO_ULDL}    ca_Fr1Tdd_Fdd_Sa    ca_Fdd_Any_Sa  ca_Fdd_Fdd
${DL_TO_UL_CONTRIBUTION_RATIO}    50    # Should be 101 when no UL CA, otherwise PDL error exists
${A1_THRESHOLD_SCELL_ADD_SSB_RSRP}  70
${A1_THRESHOLD_SCELL_ADD_SSB_RSRP_FDD}  65
${A2_THRESHOLD_SCELL_REL_SSB_RSRP}  65


${A1_THRESHOLD_PCELL_SWITCH_SSB_RSRP}    75
${A2_THRESHOLD_PCELL_SWITCH_SSB_RSRP}    50

${PA_A1_BASED_PCELL_SWTICH}    ${0}
${PA_A2_BASED_PCELL_SWTICH}    ${40}
${PA_TDD_100M_signal_better_after_SWTICH}    ${0}
${PA_TDD_100M_signal_bad_before_SWITCH}    ${40}

${A1_HYS_SCELL_ADD_SSB_RSRP}    0
${A1_THRES_SCELL_ADD_SSB_RSRP_TDD}    70
${A1_THRES_SCELL_ADD_SSB_RSRP_FDD}    65
${A1_TIME_TO_TRIGGER_SCELL_ADD_SSB_RSRP}   320ms

${A2_HYS_SCELL_REL_SSB_RSRP}    0
#${A2_THRES_SCELL_REL_SSB_RSRP}    60
${A2_TIME_TO_TRIGGER_SCELL_REL_SSB_RSRP}    2560ms

#
#${A1_THRESHOLD_PCELL_SWITCH_SSB_RSRP}   78
#${A2_THRESHOLD_PCELL_SWITCH_SSB_RSRP}   76
#${PCELL_TDD_DL_TRAFFIC_SMALL}  100
${SCELL_BAD_RLQ_COUNT}    90
${SCELL_CHANNEL_ESTIMATION_PERIOD}     2000
#

${EXP_DL_F20M_2x2_256QAM}     216

# veriables are for 1070 peak case, the expected throughputs are set based on test line.
${EXP_DL_F20M_2x2_256QAM_1170}     216
${EXP_DL_F20M_2x2_256QAM_10152}     218
${EXP_DL_F20M_2x2_256QAM_255}     219

${EXP_DL_F10M_2x2_256QAM_1170}    97
${EXP_DL_F10M_2x2_256QAM_10152}    98.9
${EXP_DL_F10M_2x2_256QAM_255}    107

${EXP_DL_T100M_4x4_256QAM_1070_1170}    1332
${EXP_DL_T100M_4x4_256QAM_1070_10152}    1332
${EXP_DL_T100M_4x4_256QAM_1070_255}    1332

${EXP_DL_T60M_4x4_256QAM_1070_1170}    784
${EXP_DL_T60M_4x4_256QAM_1070_10152}    783
${EXP_DL_T60M_4x4_256QAM_1070_255}    783

${EXP_UL_T100M_2x2_64QAM_1070_1170}    122.4
${EXP_UL_T100M_2x2_64QAM_1070_10152}    124
${EXP_UL_T100M_2x2_64QAM_1070_255}    127

${EXP_UL_F20M_2x2_64QAM_1070_1170}     48.5
${EXP_UL_F20M_2x2_64QAM_1070_10152}     48.8
${EXP_UL_F20M_2x2_64QAM_1070_255}     49.2


${EXP_UL_T100M_2x2_64QAM_1070_ENABLE_8311_1170}    245
${EXP_UL_T100M_2x2_64QAM_1070_ENABLE_8311_10152}    249
${EXP_UL_T100M_2x2_64QAM_1070_ENABLE_8311_255}    249

${EXP_DL_T100M_4x4_256QAM_1070_ENABLE_8830_1170}    1419
${EXP_DL_T100M_4x4_256QAM_1070_ENABLE_8830_10152}    1419
${EXP_DL_T100M_4x4_256QAM_1070_ENABLE_8830_255}    1419

${EXP_DL_T60M_4x4_256QAM_1070_ENABLE_8830_1170}     832
${EXP_DL_T60M_4x4_256QAM_1070_ENABLE_8830_10152}     832
${EXP_DL_T60M_4x4_256QAM_1070_ENABLE_8830_255}     832


# variables for none peak case
${EXP_DL_F20M_2x2_256QAM_POOL_PA_BAD}     50
${EXP_UL_F20M_2x2_64QAM_1116}     57

${EXP_DL_F10M_2x2_256QAM}    97
${EXP_DL_T100M_4x4_256QAM_1116}    1400
${EXP_UL_T100M_2x2_64QAM_1116}    76
${EXP_UL_T100M_2x2_64QAM_1116_NO_ULCA}    150

${EXP_DL_T60M_4x4_256QAM_1116}    860
${EXP_DL_T60M_2x2_256QAM_1116}    460
${EXP_DL_T60M_2x2_256QAM_1070}    420

${EXP_DL_F20M_2x2_256QAM_6137}    210
${EXP_DL_F10M_2x2_256QAM_6137}    97
${EXP_DL_T100M_4x4_256QAM_1116_6137}   1200
${EXP_DL_T60M_4x4_256QAM_6137}    840
${EXP_UL_F20M_2x2_64QAM_6137}    73
${EXP_UL_T100M_2x2_64QAM_1116_6137}    45


${DL_TPUT_IPERF}         2700M
${UL_TPUT_IPERF}         200M

#Buffer base Related
${BufferBase_DL_TRAFFIC_SMALL}  100
${BufferBase_DL_TRAFFIC_Big}      ${DL_TPUT_IPERF}
${BufferBase_UL_TRAFFIC_SMALL}  40
${BufferBase_UL_TRAFFIC_Big}      ${UL_TPUT_IPERF}


${TPUT_AVG_PERCENT_COMMON}    0.7
${TPUT_MIN_PERCENT_COMMON}    0.5

${TPUT_AVG_PERCENT_PEAK}    0.95
${TPUT_MIN_PERCENT_PEAK}    0.85

${BIP_ITF_ASIB}    eths

${TIMER_FOR_MODIFY_VIA_API}    5min
${TIMER_FOR_CELL_ON_AIR}       8min

${ININUMSCELLSTOACTIVATE}    1
