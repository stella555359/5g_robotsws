*** Settings ***
Documentation     author: Kusuma S
...               contact: kusuma.s@nokia.com
...               Description: This testcase to test the 6G with different bandwidth

Resource    6G_mix_bandwidth_keywords.robot

*** Variables ***
${6G_L3call_testsuite}    ${CURDIR}/../../../QT/L3call_6G.robot
${TEST_VARIABLES_6G}    SEPARATOR=${SPACE}
...    -v Auto_NIDD_Update_Flag:True -v collect_cpu_data_flag:True -v ENABLE_CRASH_DETECTION:True
${1208_100_60mhz}    ${CURDIR}/Configs/1208_2CC_frameformat_100_60mhz
${1208_80_100mhz}    ${CURDIR}/Configs/1208_2CC_frameformat_80_100mhz
${1208_60_40mhz}    ${CURDIR}/Configs/1208_2CC_frameformat_60_40mhz
${1208_40_80mhz}    ${CURDIR}/Configs/1208_2CC_frameformat_40_80mhz

*** Test Cases ***
Validate 6G L3 call with 100_60mhz bandwidth
    [Tags]    AP_P1    TC_1
    [Setup]    Test Setup With Bandwidth Config Update    custom_config=${1208_100_60mhz}
    Set Test Variable    ${topology}    CLOUD_5G_I_E_AP_E_SA_FS_ECPRI_CMWV_TDD_6G
    Set Test Variable    ${component_carrier}    2
    ${TEST_VARIABLES_6G}    CATENATE    SEPARATOR=${SPACE}
    ...    -v Auto_NIDD_Update_Flag:True -v collect_cpu_data_flag:True -v ENABLE_CRASH_DETECTION:True
    ...    -v MTp_6G_TDD_SA_dl:1400 -v MTp_6G_TDD_SA_ul:180
    Perform L3 call and check status    ${topology}    ${component_carrier}    ${6G_L3call_testsuite}
    ...    verification=@{verification_list_6g}    variable_section=${TEST_VARIABLES_6G}
    Run And Return Rc And Output
    ...    cp ${OUTPUT_DIR}/${topology}_L3_call.html ${OUTPUT_DIR}/../${topology}_L3_call_100_60MHZ_log.html

Validate 6G L3 call with 80_100mhz bandwidth
    [Tags]    AP_P1    TC_2
    [Setup]    Test Setup With Bandwidth Config Update    custom_config=${1208_80_100mhz}
    Set Test Variable    ${topology}    CLOUD_5G_I_E_AP_E_SA_FS_ECPRI_CMWV_TDD_6G
    Set Test Variable    ${component_carrier}    2
    ${TEST_VARIABLES_6G}    CATENATE    SEPARATOR=${SPACE}
    ...    -v Auto_NIDD_Update_Flag:True -v collect_cpu_data_flag:True -v ENABLE_CRASH_DETECTION:True
    ...    -v MTp_6G_TDD_SA_dl:1100 -v MTp_6G_TDD_SA_ul:130
    Perform L3 call and check status    ${topology}    ${component_carrier}    ${6G_L3call_testsuite}
    ...    verification=@{verification_list_6g}    variable_section=${TEST_VARIABLES_6G}
    Run And Return Rc And Output
    ...    cp ${OUTPUT_DIR}/${topology}_L3_call.html ${OUTPUT_DIR}/../${topology}_L3_call_80_100MHZ_log.html

Validate 6G L3 call with 60_40mhz bandwidth
    [Tags]    AP_P1    TC_3
    [Setup]    Test Setup With Bandwidth Config Update    custom_config=${1208_60_40mhz}
    Set Test Variable    ${topology}    CLOUD_5G_I_E_AP_E_SA_FS_ECPRI_CMWV_TDD_6G
    Set Test Variable    ${component_carrier}    2
    ${TEST_VARIABLES_6G}    CATENATE    SEPARATOR=${SPACE}
    ...    -v Auto_NIDD_Update_Flag:True -v collect_cpu_data_flag:True -v ENABLE_CRASH_DETECTION:True
    ...    -v MTp_6G_TDD_SA_dl:1400 -v MTp_6G_TDD_SA_ul:90
    Perform L3 call and check status    ${topology}    ${component_carrier}    ${6G_L3call_testsuite}
    ...    verification=@{verification_list_6g}    variable_section=${TEST_VARIABLES_6G}
    Run And Return Rc And Output
    ...    cp ${OUTPUT_DIR}/${topology}_L3_call.html ${OUTPUT_DIR}/../${topology}_L3_call_60_40MHZ_log.html

Validate 6G L3 call with 40_80mhz bandwidth
    [Tags]    AP_P1    TC_4
    [Setup]    Test Setup With Bandwidth Config Update    custom_config=${1208_40_80mhz}
    Set Test Variable    ${topology}    CLOUD_5G_I_E_AP_E_SA_FS_ECPRI_CMWV_TDD_6G
    Set Test Variable    ${component_carrier}    2
    ${TEST_VARIABLES_6G}    CATENATE    SEPARATOR=${SPACE}
    ...    -v Auto_NIDD_Update_Flag:True -v collect_cpu_data_flag:True -v ENABLE_CRASH_DETECTION:True
    ...    -v MTp_6G_TDD_SA_dl:1400 -v MTp_6G_TDD_SA_ul:65
    Perform L3 call and check status    ${topology}    ${component_carrier}    ${6G_L3call_testsuite}
    ...    verification=@{verification_list_6g}    variable_section=${TEST_VARIABLES_6G}
    Run And Return Rc And Output
    ...    cp ${OUTPUT_DIR}/${topology}_L3_call.html ${OUTPUT_DIR}/../${topology}_L3_call_40_80MHZ_log.html