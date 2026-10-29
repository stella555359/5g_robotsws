*** Settings ***
Documentation
...    :copyright: Nokia
...    :contact: I_EXT_MN_RAN_VRF_WRO2_7_T03@internal.nsn.com

Resource        ${CURDIR}${/}suite_config_step.robot

*** Variables ***

${CONFIG_PATH}  ${CURDIR}${/}config

*** Keywords ***

Log Teardown Step
    Config Step '${CONFIG_PATH}${/}teardown_log.sh ${/}home${/}ute${/}test_results' 'Tearing down log' '0'

Suite Teardown
    Log Teardown Step
