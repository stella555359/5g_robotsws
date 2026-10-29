*** Settings ***
Documentation    This is about common variables used for 2329 feature.

*** Variables ***
# WA: dummy value for ${testline_name}, only for pipeline use.
${testline_name}    7_5_UTE5G402T255
${CA_GROUP_TYPE}    T+F
${IS_LOG_CAPTURED_CASE_LEVEL}                       ${True}

${NSA_SA}  SA
@{carrierAggregationSupportList_With_T_F}     ca_Fr1Tdd_Fdd_Sa    ca_Fdd_Fr1Tdd_Sa    ca_Fdd_Fr1Tdd_Nsa
@{carrierAggregationSupportList_without_T_F}    ca_Fdd_Fr1Tdd_Sa    ca_Fdd_Fr1Tdd_Nsa
${A1_THRESHOLD_SCELL_ADD_SSB_RSRP}  75
${A2_THRESHOLD_SCELL_REL_SSB_RSRP}  65

${A1_THRESHOLD_PCELL_SWITCH_SSB_RSRP}   78
${A2_THRESHOLD_PCELL_SWITCH_SSB_RSRP}   76
${PCELL_TDD_DL_TRAFFIC_SMALL}  100
${SCELL_BAD_RLQ_COUNT}    90
${SCELL_CHANNEL_ESTIMATION_PERIOD}     2000


${PCELL_EXP_DL}    1200
${PCELL_EXP_UL}    100
${SCELL_EXP_DL}    150
${SCELL_EXP_UL}    30
${DL_TPUT}         1800M
${UL_TPUT}         200M

${BIP_ITF_ASIB}    eths
