*** Settings ***
Documentation
...   author: Valentin Marian
...   maintainer: valentin.marian@nokia.com

Resource    ../../../test_resources/SBTS_SBTS__STATE__RMOD_fan_temp_control_profiles_CB010874.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
${POWER_ON_FLAG}    ${True}
${SCOUT_TL_NAME}    10_18_UTESRANRFSMTNRL76_1
${CNI_127210_ENABLED}    ${True}

&{IGNORED_ALARM}  alarmId=7115  faultId=1932

*** Test Cases ***
[1]SBTS_SBTS__STATE__RMOD_fan_temp_control_profiles_CB010874
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__rmod_fan_temp_control_profiles_cb010874_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    1
    ...    AND    Set Test Variable    ${RMOD_CLIMATE_CONTROL_PROFILING_LIST}    Linear,Optimized Cooling,Low Noise
    ...    AND    Set Test Variable    ${CB010874_EXEMPTED_RMOD_SERIAL_NUMBER_LIST}    1M144161121
    ...    AND    Set Test Variable    ${RM_SERIAL_NUMBER_LIST}     ALL
#    ...    AND    Set Test Variable    ${CB010874_EXEMPTED_RMOD_SERIAL_NUMBER_LIST}
#    ...    BL2027G1ATV,K9181741636,BL2247W2NYW,BL2247W2NZD,BL2247W2NVS,K9224913889,L1210107218
    ...    AND    Append To List  ${MASTER_IGNORED_ALARMS_CNI_127210}  ${IGNORED_ALARM}
    ...    AND    Append To List  ${SLAVE_IGNORED_ALARMS_CNI_127210}  ${IGNORED_ALARM}

    ...    AND    SBTS_SBTS__STATE__RMOD_fan_temp_control_profiles_CB010874.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__RMOD_fan_temp_control_profiles_CB010874
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__RMOD_fan_temp_control_profiles_CB010874
    TC__SBTS_SBTS__STATE__RMOD_fan_temp_control_profiles_CB010874
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__RMOD_fan_temp_control_profiles_CB010874.TC Teardown
    ...    AND    Restore Resource Search Order