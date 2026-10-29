*** Settings ***
Documentation     author: Kusuma S
...               contact: kusuma.s@nokia.com
...               Description: This testcase to test the 6G with different bandwidth

Resource    6G_mix_bandwidth_keywords.robot

*** Variables ***
${6G_L3call_testsuite}    ${CURDIR}/../../../QT/L3call_6G.robot
${TEST_VARIABLES_6G}    SEPARATOR=${SPACE}
...    -v Auto_NIDD_Update_Flag:True -v collect_cpu_data_flag:True -v ENABLE_CRASH_DETECTION:True
${1208_80mhz}    ${CURDIR}/Configs/1208_2CC_frameformat_80mhz
${1116_60mhz}    ${CURDIR}/Configs/1116_3ms_2CC_frameformat_60mhz
${1208_40mhz}    ${CURDIR}/Configs/1208_2CC_frameformat_40mhz

*** Test Cases ***
Validate 6G L3 call with 80MHZ bandwidth
    [Tags]    AP_P1    TC_1
    [Setup]    Test Setup With Bandwidth Config Update    custom_config=${1208_80mhz}
    Set Test Variable    ${topology}    CLOUD_5G_I_E_AP_E_SA_FS_ECPRI_CMWV_TDD_6G
    Set Test Variable    ${component_carrier}    2
    ${TEST_VARIABLES_6G}    CATENATE    SEPARATOR=${SPACE}
    ...    -v Auto_NIDD_Update_Flag:True -v collect_cpu_data_flag:True -v ENABLE_CRASH_DETECTION:True
    ...    -v MTp_6G_TDD_SA_dl:1400 -v MTp_6G_TDD_SA_ul:130
    Set Test Variable    ${TEST_VARIABLES_6G}
    Perform L3 call and check status    ${topology}    ${component_carrier}    ${6G_L3call_testsuite}
    ...    verification=@{verification_list_6g}    variable_section=${TEST_VARIABLES_6G}
    Run And Return Rc And Output
    ...    cp ${OUTPUT_DIR}/${topology}_L3_call.html ${OUTPUT_DIR}/../${topology}_L3_call_80MHZ_log.html

Validate 6G L3 call with 60MHZ bandwidth
    [Tags]    AP_P1    TC_2
    [Setup]    Test Setup With Bandwidth Config Update    custom_config=${1116_60mhz}
    Set Test Variable    ${topology}    CLOUD_5G_I_E_AP_E_SA_FS_ECPRI_CMWV_TDD_6G
    Set Test Variable    ${component_carrier}    2
    ${TEST_VARIABLES_6G}    CATENATE    SEPARATOR=${SPACE}
    ...    -v Auto_NIDD_Update_Flag:True -v collect_cpu_data_flag:True -v ENABLE_CRASH_DETECTION:True
    ...    -v MTp_6G_TDD_SA_dl:1400 -v MTp_6G_TDD_SA_ul:90
    Perform L3 call and check status    ${topology}    ${component_carrier}    ${6G_L3call_testsuite}
    ...    verification=@{verification_list_6g}    variable_section=${TEST_VARIABLES_6G}
    Run And Return Rc And Output
    ...    cp ${OUTPUT_DIR}/${topology}_L3_call.html ${OUTPUT_DIR}/../${topology}_L3_call_60MHZ_log.html

Validate 6G L3 call with 40MHZ bandwidth
    [Tags]    AP_P1    TC_3
    [Setup]    Test Setup With Bandwidth Config Update    custom_config=${1208_40mhz}
    Set Test Variable    ${topology}    CLOUD_5G_I_E_AP_E_SA_FS_ECPRI_CMWV_TDD_6G
    Set Test Variable    ${component_carrier}    2
    ${TEST_VARIABLES_6G}    CATENATE    SEPARATOR=${SPACE}
    ...    -v Auto_NIDD_Update_Flag:True -v collect_cpu_data_flag:True -v ENABLE_CRASH_DETECTION:True
    ...    -v MTp_6G_TDD_SA_dl:1000 -v MTp_6G_TDD_SA_ul:65
    Perform L3 call and check status    ${topology}    ${component_carrier}    ${6G_L3call_testsuite}
    ...    verification=@{verification_list_6g}    variable_section=${TEST_VARIABLES_6G}
    Run And Return Rc And Output
    ...    cp ${OUTPUT_DIR}/${topology}_L3_call.html ${OUTPUT_DIR}/../${topology}_L3_call_40MHZ_log.html
