*** Settings ***
Documentation    This is about common variables used for CB008178 feature.

*** Variables ***
${testline_name}    7_5_UTE5G402T2133
${NSA_SA}          SA

${MRBTS_ID_GNB0}        ${tl.gnbs[0].instance_id}

${TCE_IP_ADDR}          10.57.241.82
${TCE_PORT}             49148

${TIMER_FOR_MODIFY_VIA_API}    5min
${TIMER_FOR_CELL_ON_AIR}       8min

#L3 call and tput releation settings
${UL_TPUT}         200M
${UL_NSA_TPUT}       200M

${CUSTOMIZED_LOG_NAME}    TL_tput_check

${DURATION_OF_TPUT_SEND}   3000   #5minutes
${DURATION_OF_TPUT_CHECK}  300   # 5 minutes

