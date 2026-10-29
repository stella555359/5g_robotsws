*** Settings ***
Documentation    This is about common variables used for 8830 feature.

*** Variables ***
# WA: dummy value for ${testline_name}, only for pipeline use.
${testline_name}    7_5_UTE5G402T255
${IS_LOG_CAPTURED_CASE_LEVEL}                       ${True}
${MRBTS_ID}                                         ${tl.gnbs[0].instance_id}
${NRBTS_ID}                                         ${tl.gnbs[0].global_bts_id}
${DN_MRBTS}                                         MRBTS-${MRBTS_ID}
${DN_NRBTS}                                         ${DN_MRBTS}/NRBTS-${NRBTS_ID}
${DN_NRDU1}                                         ${DN_NRBTS}/NRDU-1
${SWCONFIG_DEFAULT_FILE_PATH}         /home/ute/Projects/mmw1_config/${testline_name}/swconfig/swconfig_MMW1_TL${MRBTS_ID}.txt
${SCF_DEFAULT_FILE_PATH}              /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${MRBTS_ID}.xml

${NSA_SA}  SA

${PCELL_ID}    ${1}

@{carrierAggregationSupportList_T_F_UL_DL}  ca_Fr1Tdd_Fdd_Sa_WithUl  ca_Fr1Tdd_Fdd_Sa  ca_Fdd_Fr1Tdd_Sa

${EXP_DL_T100M_4x4_256QAM_1070_255_DMRSTYPE1}    1332

${EXP_DL_T100M_4x4_256QAM_1070_255_DMRSTYPE2}    1400

${EXP_DL_T100M_4x4_64QAM_1070_255_DMRSTYPE1}    800

${EXP_UL_T100M_2x2_64QAM_1070}    125

${DL_TPUT_IPERF}         1500M
${UL_TPUT_IPERF}         200M
${DL_TPUT_HR_IPERF}         1550M

${TPUT_AVG_PERCENT_COMMON}    0.7
${TPUT_MIN_PERCENT_COMMON}    0.5

${TPUT_AVG_PERCENT_PEAK}    0.95
${TPUT_MIN_PERCENT_PEAK}    0.85

${BIP_ITF_ASIB}    eths

${TIMER_FOR_MODIFY_VIA_API}    5min
${TIMER_FOR_CELL_ON_AIR}       8min

