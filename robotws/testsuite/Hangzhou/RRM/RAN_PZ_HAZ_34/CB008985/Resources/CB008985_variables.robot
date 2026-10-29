*** Settings ***
Documentation    This is about common variables used for 8985 feature.

*** Variables ***
# WA: dummy value for ${testline_name}, only for pipeline use.
${IS_LOG_CAPTURED_CASE_LEVEL}    ${True}

${TIMER_FOR_MODIFY_VIA_API}    5min
${TIMER_FOR_CELL_ON_AIR}       8min

@{carrierAggregationSupportList_T_T}    ca_Fr1Tdd_Sa    ca_Fr1Tdd_Nsa

#L3 call and tput releation settings
${UL_TPUT}         200M
${UL_NSA_TPUT}       200M

${CUSTOMIZED_LOG_NAME}    TL_tput_check

${DURATION_OF_TPUT_SEND}   3000s   #5minutes
${DURATION_OF_TPUT_CHECK}  300s   # 5 minutes
${DURATION_OF_TPUT_SUBCELL_SWITCH_SEND}   480s
${DURATION_OF_SUBCELL_SWITCH_TPUT_CHECK}    120
