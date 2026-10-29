*** Settings ***

Documentation    :copyright: Nokia

Variables    ./CB006877_Variables.py

*** Variables ***
${RESET_TL}=                  ${FALSE}
${FULL_COMMISSIONING}=        ${TRUE}
${RESTORE_DEFAULT_CONFIG}=    ${TRUE}

${rdPCsiPoolHkfPeriod_min}=    0x5901A6

${MSG_FILTER_SA}=         ${RRC_RECONFIGURATION} && ${F1AP_DL_RRC_MESSAGE_TRANSFER} && nas-5gs
${MSG_FILTER_NSA}=        ${RRC_RECONFIGURATION} && ${X2AP_SGNB_ADDITION_REQUEST_ACKNOWLEDGE}
${MSG_FILTER_SA_HKF}=     ${RRC_RECONFIGURATION} && ${F1AP_DL_RRC_MESSAGE_TRANSFER} && !nas-5gs
${MSG_FILTER_NSA_HKF}=    ${X2AP_SGNB_MODIFICATION_REQUIRED} && nr-rrc.resourceToAddModList
