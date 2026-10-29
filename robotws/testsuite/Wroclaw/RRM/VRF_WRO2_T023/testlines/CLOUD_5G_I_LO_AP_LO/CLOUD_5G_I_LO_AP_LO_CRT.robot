*** Settings ***
Force Tags    CRT    RAN_5G    CLOUD_5G_I_LO_AP_LO

Documentation    :copyright: Nokia
...              :authors: Palina Krasnova
...              :contact: palina.krasnova@nokia.com
...              This Test Suite contains the test cases for 5GC000705, CB008696-A, CB009205-B, CB013728-A

Resource     ../../../resources/airphone/5G_SW_WRO_Keywords.robot
Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Resource     ../../feature_resources/5GC000705/5GC000705-NGAP_HANDOVER_FAILURE_target_cell_barred.robot
Resource     ../../feature_resources/CB008696/CB008696-A_UE_candidate_percentage_check_is_not_passed.robot
Resource     ../../feature_resources/CB009205/CB009205-B_B1_A1_measurement_for_steering_UE_to_preferred_NR_layer_configuration_during_ICS.robot
Library      ta5g_cell_operations
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_enb
Variables    testsuite/Wroclaw/RRM/VRF_WRO2_T023/resources/airphone/logging_policy.py

Suite Setup    Run Keyword    Backup And Modify Swconfig File    parameters_list=@{ENABLE_CPLANE_DEBUG_LOGS}

Suite Teardown     Stop Default Processes And Gather Logs And Compress Logs    teardown_egate_instances=False    additional_logs=False

*** Variables ***
${LOGS_COMPRESSION}=    ${True}
${LOGGING_POLICY}=      FULL_POLICY_PER_TC

${5GC000705_iphy}=          ${CURDIR}/config/5GC000705_iphy_1AEQE_1c.xml
${5GC000705_scfc}=          5G000705_full_scfc_ho_failure_target_cell_barred.xml
${5GC000705_wts_config}=    ${CURDIR}/config/5G000705_egate_1c_1Ue.lua

${cb008696_iphy}=          ${CURDIR}/config/cb008696_B_iphy.xml
${cb008696_scfc}=          cb008696_full_scfc.xml
${cb008696_wts_config}=    ${CURDIR}/config/cb008696_egate_2c_1ue.cfg

${cb009205_iphy}=          ${CURDIR}/config/cb009205_iphy_1AEQE_1c.xml
${cb009205_scfc}=          cb009205_B_B1_full_config.xml
${cb009205_wts_config}=    ${CURDIR}/config/cb009205_egate_1c_1Ue.lua


*** Test Cases ***
5GC000705-NGAP_HANDOVER_FAILURE_target_cell_barred
    [Documentation]    :copyright: Nokia
    ...                :authors: Krystian Kozlowski, Vira Solomashenko
    ...                :contact: krystian.kozlowski@nokia.com, vira.solomashenko@nokia.com

    [Setup]    Run Keywords    Update And Put Iphy Xml    input_filepath=${5GC000705_iphy}    AND
    ...                        Find Scfc And Fix And Send Full Commissioning    scfc_filename=${5GC000705_scfc}    AND
    ...                        Wait For Testline Icmp Echo Replies And Ssh Services    AND
    ...                        Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                        Check Radios Availability    AND
    ...                        Start Vm Ethernet Interfaces    AND
    ...                        Reach Onair Without Confirmation    lua_cfg=${5GC000705_wts_config}

    TC__5GC000705-NGAP_HANDOVER_FAILURE_target_cell_barred

    [Teardown]    Run Keywords    Teardown Egate    AND
    ...                           Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                           Collect Additional Debug Files For Failed Testcase Or Testsuite    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                           Add Scout Data Info To Testcase

CB008696-A_UE_candidate_percentage_check_is_not_passed
    [Documentation]    :copyright: Nokia
    ...                :authors: Mateusz Kuropka
    ...                :contact: mateusz.kuropka@nokia.com

    [Setup]    Run Keywords    Update And Put Iphy Xml    input_filepath=${cb008696_iphy}    AND
    ...                        Find Scfc And Fix And Send Full Commissioning    scfc_filename=${cb008696_scfc}    AND
    ...                        Wait For Testline Icmp Echo Replies And Ssh Services    AND
    ...                        Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                        Reach Onair    lua_cfg=${cb008696_wts_config}

    TC__CB008696-A_UE_candidate_percentage_check_is_not_passed

    [Teardown]    Run Keywords    Teardown Egate    AND
    ...                           Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                           Collect Additional Debug Files For Failed Testcase Or Testsuite    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                           Add Scout Data Info To Testcase

CB009205-B_B1_A1_measurement_for_steering_UE_to_preferred_NR_layer_configuration_during_ICS_(RSRQ_case)
    [Documentation]    :copyright: Nokia
    ...                :authors: Jakub Magier
    ...                :contact: jakub.magier@nokia.com

    [Tags]    CD_MN_RAN    QCP_RAN_VRF    QC_44422

    [Setup]    Run Keywords    Update And Put Iphy Xml    input_filepath=${cb009205_iphy}    AND
    ...                        Find Scfc And Fix And Send Full Commissioning    scfc_filename=${cb009205_scfc}    AND
    ...                        Wait For Testline Icmp Echo Replies And Ssh Services    AND
    ...                        Start Default Logging
    ...                        output_dirpath=${OUTPUT_DIR}/CB009205_B_B1_A1_measurement_for_steering_UE_to_preferred_NR_layer_configuration    AND
    ...                        Reach Onair    lua_cfg=${cb009205_wts_config}

    TC__CB009205-B_B1_A1_measurement_for_steering_UE_to_preferred_NR_layer_configuration_during_ICS_(RSRQ_case)

    [Teardown]    Run Keywords    Deregister Ue    ue_id=1    AND
    ...                           Teardown Egate    AND
    ...                           Stop Default Logging
    ...                           output_dirpath=${OUTPUT_DIR}/CB009205_B_B1_A1_measurement_for_steering_UE_to_preferred_NR_layer_configuration    AND
    ...                           Collect Additional Debug Files For Failed Testcase Or Testsuite
    ...                           output_dirpath=${OUTPUT_DIR}/CB009205_B_B1_A1_measurement_for_steering_UE_to_preferred_NR_layer_configuration    AND
    ...                           Add Scout Data Info To Testcase
