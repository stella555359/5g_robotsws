*** Settings ***
Documentation
...    author: Dominik Wieczorek
...    contact: Dominik Wieczorek (dominik.wieczorek@nokia.com)

Library      OperatingSystem
Library      BuiltIn
Library      ./resources/keywords.py    WITH NAME    max_config
#Resource     testsuite/Wroclaw/SISO/SRAN/CUS/resources/test_cases.robot
#Resource     testsuite/Wroclaw/SISO/SRAN/CUS/resources/test_cases_loop.robot
#Resource     testsuite/Wroclaw/SISO/SRAN/CUS/resources/setup_and_teardown.robot
Resource    ./config/variables.robot

#Test Setup        CUS Setup Test Set Without Reset Configuration    ${SCFC_REFERENCE_FILE_PATH}
#Test Teardown     CUS Teardown Test Case    ${SUITE_LOGS_DIR_PATH}    ${ALLOWED_ALARMS}
#Suite Teardown    CUS Teardown Test Set


*** Variables ***
${SCFC_REFERENCE_FILE_PATH}=            ${CURDIR}/config/GNB0_SCF.xml
${SWCONFIG_FILE_PATH}=                  commissionings/Krakow/swconfig/default_swconfig.txt
${CUSINI_FILE_PATH}=                    ${CURDIR}/config/cus.ini
${EPCSIM_FILE_PATH}=                	${CURDIR}/config/epc.lua
${SKIP_TRUCK_ROLL}=			            True
${CONF_ENV_DETECTION}=			        False
${CONFIGURATION_NAME}=                  max_cells
${RECOMMISSIONING_TIMEOUT}=             1000

${SITE_RESET_COUNT}=               	    10
${RAT_RESET_COUNT}=               	    10
${BBMOD_RESET_COUNT}=               	10
${POWER_RESET_COUNT}=                   10

${collect_single_loop_logs}=            False
${GET_KPI}=                             True
${TARGET_SOFTWARE}=                     ${None}

*** Test Cases ***
SW_Activation_Downtime_KPI#2d
    [Tags]    upgrade
    Log To Console    SW_Activation_Downtime_KPI#2d

#    CUS Software Update With Kpi Calculation
#    ...             scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
#    ...             list_of_cus_ips=${LIST_OF_CUS_IPS}
#    ...             target_software=${TARGET_SOFTWARE}
#    ...             get_kpi=${GET_KPI}
#    ...             hw_configuration=${CONFIGURATION_NAME}
#    ...             allowed_alarms=${ALLOWED_ALARMS_ONAIR}

Automated_SiSo_STARTUP_CUS_Site_Reset_BTS
    [Tags]    site_reset
    Log To Console    Automated_SiSo_STARTUP_CUS_Site_Reset_BTS

#    CUS Reset Site Loop Execution
#    ...             scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
#    ...             list_of_cus_ips=${LIST_OF_CUS_IPS}
#    ...             get_kpi=${GET_KPI}
#    ...             run_count=${SITE_RESET_COUNT}
#    ...             hw_configuration=${CONFIGURATION_NAME}
#    ...             allowed_alarms=${ALLOWED_ALARMS_ONAIR}

Automated_SiSo_STARTUP_CUS_Power_Reset_BTS
    [Tags]    power_reset
    Log To Console     Automated_SiSo_STARTUP_CUS_Power_Reset_BTS

#    CUS BTS Power Reset Loop Execution
#    ...             scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
#    ...             list_of_cus_ips=${LIST_OF_CUS_IPS}
#    ...             get_kpi=${GET_KPI}
#    ...             run_count=${POWER_RESET_COUNT}
#    ...             hw_configuration=${CONFIGURATION_NAME}
#    ...             allowed_alarms=${ALLOWED_ALARMS_ONAIR}

Automated_SiSo_CM_CUS_BTS_Rat_Reset
    [Tags]    nr_rat_reset
    Log To Console    Automated_SiSo_CM_CUS_BTS_Rat_Reset

#    CUS BTS Rat Loop Execution
#    ...             scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
#    ...             list_of_cus_ips=${LIST_OF_CUS_IPS}
#    ...             rat_type=NR
#    ...             get_kpi=${GET_KPI}
#    ...             verify_changes=${False}
#    ...             run_count=${RAT_RESET_COUNT}
#    ...             hw_configuration=${CONFIGURATION_NAME}
#    ...             allowed_alarms=${ALLOWED_ALARMS_ONAIR}

Automated_SiSo_STARTUP_CUS_Baseband_Module_Reset
    [Tags]    bbmod_reset
    Log To Console    Automated_SiSo_STARTUP_CUS_Baseband_Module_Reset

    @{bbmod_sn_list}=    Create List    SELECT    L1222606859    L1230613319

#    CUS Baseband Module Reset Loop Execution
#    ...             scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
#    ...             bbmod_sn_list=${bbmod_sn_list}
#    ...             list_of_cus_ips=${LIST_OF_CUS_IPS}
#    ...             get_kpi=${GET_KPI}
#    ...             run_count=${BBMOD_RESET_COUNT}
#    ...             hw_configuration=${CONFIGURATION_NAME}
#    ...             allowed_alarms=${ALLOWED_ALARMS_ONAIR}

Automated_SiSo_CM_CUS_Delta_Recommissioning
    [Tags]    delta
#    [Setup]    Run Keywords    max_config.prepare_delta_pmax    path=${CURDIR}/config/DELTA.json
#    ...                 AND     CUS Setup Test Set Without Reset Configuration    ${SCFC_REFERENCE_FILE_PATH}
    Log To Console    Automated_SiSo_CM_CUS_Delta_Recommissioning

#    CUS Delta Recommissioning
#    ...             scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
#    ...             list_of_cus_ips=${LIST_OF_CUS_IPS}
#    ...             recommissioning_timeout=${RECOMMISSIONING_TIMEOUT}
#    ...             json_delta_file=${CURDIR}/config/DELTA.json
#    ...             get_kpi=${GET_KPI}
#    ...             hw_configuration=${CONFIGURATION_NAME}
#    ...             allowed_alarms=${ALLOWED_ALARMS_ONAIR}
#    [Teardown]    CUS Teardown Test Case    ${SUITE_LOGS_DIR_PATH}    ${ALLOWED_ALARMS}

Automated_SiSo_CM_CUS_Template_Commissioning
    [Tags]    scf
    Log To Console    Automated_SiSo_CM_CUS_Template_Commissioning

#    CUS Template Commissioning
#    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
#    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
#    ...  hw_configuration=${CONFIGURATION_NAME}
#    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}
#    ...  conf_env_detection=${CONF_ENV_DETECTION}
