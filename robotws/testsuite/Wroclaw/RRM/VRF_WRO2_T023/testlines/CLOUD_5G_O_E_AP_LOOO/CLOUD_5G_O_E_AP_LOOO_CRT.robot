*** Settings ***
Force Tags    CRT    RAN_5G    CLOUD_5G_O_E_AP_LOOO

Documentation    :copyright: Nokia
...              :authors: Wojciech Peciak, Jakub Magier
...              :contact: wojciech.peciak@nokia.com, jakub.magier@nokia.com
...              This Test Suite contains the test cases for CB013025

Resource     ${CB013025_B_IWK1_TEST_PATH}
Resource     ${CB013025_A_IWK1_TEST_PATH}
Resource     ../../feature_resources/CB013025/CB013025_CVR_Monitoring_PCMD_content_related_to_AoA_reporting_for_both_PMI_and_SRS_beams.robot
Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T023/resources/airphone/gnb.robot
Library      ta5g_delta
Library      ta5g_cell_operations
Library      ta5g_setups_and_teardowns
Library      ta5g_iphy
Library      ta5g_enb
Variables    testsuite/Wroclaw/RRM/VRF_WRO2_T023/resources/airphone/logging_policy.py


Suite Setup    Run Keywords    Install Bsr Package For AQQJ
...                     AND    Backup And Modify Swconfig File    parameters_list=@{ENABLE_CPLANE_DEBUG_LOGS}
...                     AND    Reset Testline And Wait For Rmods

Suite Teardown     Stop Default Processes And Gather Logs And Compress Logs    teardown_egate_instances=False    additional_logs=False

*** Variables ***
${LOGS_COMPRESSION}=              ${True}
${LOGGING_POLICY}=                NO_TRAFFIC_POLICY_PER_TC

${CB013025_B_IWK1_TEST_PATH}=     SEPARATOR=
...  ../../feature_resources/CB013025/
...  CB013025_B_IWK1_Interaction_between_MBA_and_SBA_functionality_for_DoA_and_AoA_reporting_different_Trace_Recording_Session_types.robot
${CB013025_B_IWK1_DELTA}=               cb013025_b_iwk1_delta.json
${TL_VARIANT_DEFAULT_WTS_CONFIG}=       /opt/iphy/latest/basic_setup.cfg    #Expected TL variant is SA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO_5_2
${CB013025_CVR_DELTA}=                  cb013025_cvr_delta.json

${CB013025_A_IWK1_TEST_PATH}=     SEPARATOR=
...  ../../feature_resources/CB013025/
...  CB013025_A_IWK1_Interaction_with_Carrier_Aggregation_Monitoring_PCMD_content_related_to_DoA_reporting_for_PCell_and_SCells.robot
${CB013025_A_IWK1_DELTA}=         cb013025_a_iwk1_delta.json
${CB013025_A_IWK1_WTS_CONFIG}=    ${CURDIR}/config/basic_setup_a_iwk1.cfg
${CB013025_A_IWK1_IPHY_CONFIG}=   ${CURDIR}/config/iphy_a_iwk1.xml
${CB013025_INITIAL_IPHY_CONFIG}=  SEPARATOR=
...  /home/ute/testline_init_results/execution/configs/topology_configs/node_1/SA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO_5_2/iphy.xml


*** Test Cases ***
CB013025_B_IWK1_Interaction_between_MBA_and_SBA_functionality_for_DoA_and_AoA_reporting_different_Trace_Recording_Session_types
    [Documentation]    :copyright: Nokia
    ...                :authors: Wojciech Peciak
    ...                :contact: wojciech.peciak@nokia.com

    [Setup]    Run Keywords
    ...                               Set TC Logs Path Variable
    ...                        AND    Save Initial SCF And Apply Delta
    ...                                 delta=${CB013025_B_IWK1_DELTA}
    ...                        AND    Wait For Testline Icmp Echo Replies And Ssh Services
    ...                        AND    Start Vm Ethernet Interfaces
    ...                        AND    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...                        AND    Reach Onair Without Confirmation
    ...                                 lua_cfg=${TL_VARIANT_DEFAULT_WTS_CONFIG}
    ...                                 check_edaemon_port=${True}
    ...                                 x2_link_start=${False}
    ...                        AND    Wait For All Cells To Be Enabled
    ...                                 timeout=600
    ...                        AND    Start Listening On TCE Port
    ...                        AND    Start Tshark For TCE Msgs And Store Alias

    TC__CB013025_B_IWK1_Interaction_between_MBA_and_SBA_functionality_for_DoA_and_AoA_reporting_different_Trace_Recording_Session_types

    [Teardown]    Run Keywords
    ...                                  Teardown Egate And Collect Logs
    ...                                     logs_dirpath=${TC_LOGS_PATH}
    ...                           AND    Stop Tshark    alias=${TCE_ALIAS}
    ...                           AND    Stop Listening On TCE Port
    ...                           AND    Stop Vm Ethernet Interfaces
    ...                           AND    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...                           AND    Collect Additional Debug Files For Failed Testcase Or Testsuite    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...                           AND    Roll Delta Back
    ...                                     initial_scf_filename=${INITIAL_SCFC_PATH}
    ...                                     delta_scf_filename=${CB013025_B_IWK1_DELTA}
    ...                           AND    Add Scout Data Info To Testcase

CB013025_A_IWK1_Interaction_with_Carrier_Aggregation_Monitoring_PCMD_content_related_to_DoA_reporting_for_PCell_and_SCells
    [Documentation]    :copyright: Nokia
    ...                :authors: Jakub Magier
    ...                :contact: jakub.magier@nokia.com

    [Setup]    Run Keywords
    ...                               Update And Put Iphy Xml
    ...                                 input_filepath=${CB013025_A_IWK1_IPHY_CONFIG}
    ...                        AND    Set TC Logs Path Variable
    ...                        AND    Save Initial SCF And Apply Delta
    ...                                 delta=${CB013025_A_IWK1_DELTA}
    ...                        AND    Wait For Testline Icmp Echo Replies And Ssh Services
    ...                        AND    Start Vm Ethernet Interfaces
    ...                        AND    Reset Testline And Wait For Rmods
    ...                        AND    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...                        AND    Reach Onair Without Confirmation
    ...                                 lua_cfg=${CB013025_A_IWK1_WTS_CONFIG}
    ...                                 check_edaemon_port=${True}
    ...                                 x2_link_start=${False}
    ...                        AND    Wait For All Cells To Be Enabled
    ...                                 timeout=600
    ...                        AND    Start Listening On TCE Port
    ...                        AND    Start Tshark For TCE Msgs And Store Alias

    TC__CB013025_A_IWK1_Interaction_with_Carrier_Aggregation_Monitoring_PCMD_content_related_to_DoA_reporting_for_PCell_and_SCells

    [Teardown]    Run Keywords
    ...                                  Teardown Egate And Collect Logs
    ...                                     logs_dirpath=${TC_LOGS_PATH}
    ...                           AND    Stop Tshark    alias=${TCE_ALIAS}
    ...                           AND    Stop Listening On TCE Port
    ...                           AND    Stop Vm Ethernet Interfaces
    ...                           AND    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...                           AND    Collect Additional Debug Files For Failed Testcase Or Testsuite    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...                           AND    Update And Put Iphy Xml
    ...                                    input_filepath=${CB013025_INITIAL_IPHY_CONFIG}
    ...                           AND    Roll Delta Back
    ...                                     initial_scf_filename=${INITIAL_SCFC_PATH}
    ...                                     delta_scf_filename=${CB013025_A_IWK1_DELTA}
    ...                           AND    Reset Testline And Wait For Rmods
    ...                           AND    Add Scout Data Info To Testcase

CB013025_CVR_Monitoring_PCMD_content_related_to_AoA_reporting_for_both_PMI_and_SRS_beams
    [Documentation]    :copyright: Nokia
    ...                :authors: Wojciech Peciak
    ...                :contact: wojciech.peciak@nokia.com

    [Setup]    Run Keywords
    ...                               Set Test Variable    ${CELL_ID}           1
    ...                        AND    Set Test Variable    ${UE_ID}             1
    ...                        AND    Set Test Variable    ${RANK_INDICATOR}    3
    ...                        AND    Set TC Logs Path Variable
    ...                        AND    Save Initial SCF And Apply Delta
    ...                                 delta=${CB013025_CVR_DELTA}
    ...                        AND    Wait For Testline Icmp Echo Replies And Ssh Services
    ...                        AND    Start Vm Ethernet Interfaces
    ...                        AND    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...                        AND    Reach Onair Without Confirmation
    ...                                 lua_cfg=${TL_VARIANT_DEFAULT_WTS_CONFIG}
    ...                                 check_edaemon_port=${True}
    ...                                 x2_link_start=${False}
    ...                        AND    Wait For All Cells To Be Enabled
    ...                                 timeout=600
    ...                        AND    Start Listening On TCE Port
    ...                        AND    Start Tshark For TCE Msgs And Store Alias

    TC__CB013025_CVR_Monitoring_PCMD_content_related_to_AoA_reporting_for_both_PMI_and_SRS_beams

    [Teardown]    Run Keywords
    ...                                  Teardown Egate And Collect Logs
    ...                                     logs_dirpath=${TC_LOGS_PATH}
    ...                           AND    Stop Tshark    alias=${TCE_ALIAS}
    ...                           AND    Stop Listening On TCE Port
    ...                           AND    Stop Vm Ethernet Interfaces
    ...                           AND    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...                           AND    Collect Additional Debug Files For Failed Testcase Or Testsuite    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...                           AND    Roll Delta Back
    ...                                     initial_scf_filename=${INITIAL_SCFC_PATH}
    ...                                     delta_scf_filename=${CB013025_CVR_DELTA}
    ...                           AND    Add Scout Data Info To Testcase
