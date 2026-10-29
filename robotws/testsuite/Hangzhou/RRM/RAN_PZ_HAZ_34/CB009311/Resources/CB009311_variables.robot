*** Settings ***
Documentation    This is about common variables used for 9311 feature.

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
${NSA_SA}  NSA
@{carrierAggregationSupportList_With_T_F}     ca_Fr1Tdd_Fdd_Nsa    ca_Fdd_Fr1Tdd_Nsa

${EXP_UL_F20M}     70
${EXP_DL_F20M}     200
${EXP_UL_T60M}    35
${EXP_DL_T60M}    500
${DL_TPUT_IPERF}         1500M
${UL_TPUT_IPERF}         200M

${TPUT_AVG_PERCENT_COMMON}    0.7
${TPUT_MIN_PERCENT_COMMON}    0.5

${TPUT_AVG_PERCENT_PEAK}    0.95
${TPUT_MIN_PERCENT_PEAK}    0.85

${BIP_ITF_ASIB}    eths

${TIMER_FOR_MODIFY_VIA_API}    5min
${TIMER_FOR_CELL_ON_AIR}       8min
