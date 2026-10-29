*** Settings ***
Force Tags    CRT    RAN_5G    CLOUD_5G_I_LOO_AP_LOOO

Documentation    :copyright: Nokia
...              :authors: Jakub Magier
...              :contact: jakub.magier@nokia.com
...              This Test Suite contains the test case for CB013728-A

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Resource     ../../feature_resources/CB013728/CB013728_A_01_Online_modification_of_actProactGrantsUlLteOnlyMode_parameter.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T023/resources/airphone/gnb.robot
Library      ta5g_cell_operations
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_enb
Library      ta5g_delta
Library      ta5g_setups_and_teardowns
Variables    testsuite/Wroclaw/RRM/VRF_WRO2_T023/resources/airphone/logging_policy.py

Suite Setup    Run Keyword     Backup And Modify Swconfig File    parameters_list=@{ENABLE_CPLANE_DEBUG_LOGS}

Suite Teardown     Stop Default Processes And Gather Logs And Compress Logs    teardown_egate_instances=False    additional_logs=False

*** Variables ***
${LOGS_COMPRESSION}=    ${True}
${LOGGING_POLICY}=      FULL_POLICY_PER_TC

${cb013728_wts_config}=    /opt/iphy/latest/basic_setup.cfg
${cb013728_delta}=         cb013728_delta.json


*** Test Cases ***
CB013728_A#01_Online_modification_of_actProactGrantsUlLteOnlyMode_parameter
    [Documentation]    :copyright: Nokia
    ...                :authors: Jakub Magier
    ...                :contact: jakub.magier@nokia.com

    [Setup]    Run Keywords    Save Initial SCF And Apply Delta
    ...                          delta=${cb013728_delta}
    ...                        AND    Wait For Testline Icmp Echo Replies And Ssh Services
    ...                        AND    Start Vm Ethernet Interfaces
    ...                        AND    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...                        AND    Reach Onair Without Confirmation
    ...                                 lua_cfg=${cb013728_wts_config}
    ...                                 check_edaemon_port=${True}
    ...                                 x2_link_start=${False}
    ...                        AND    Set eNB params
    ...                        AND    Wait For All Cells To Be Enabled    timeout=600

    TC__CB013728_A_01_Online_modification_of_actProactGrantsUlLteOnlyMode_parameter

    [Teardown]    Run Keywords    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...                           AND    Collect Additional Debug Files For Failed Testcase Or Testsuite    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...                           AND    Detach UE  ue_id=101
    ...                           AND    Teardown Egate
    ...                           AND    Roll Delta Back
    ...                                     initial_scf_filename=${INITIAL_SCFC_PATH}
    ...                                     delta_scf_filename=${cb013728_delta}
    ...                           AND    Add Scout Data Info To Testcase
