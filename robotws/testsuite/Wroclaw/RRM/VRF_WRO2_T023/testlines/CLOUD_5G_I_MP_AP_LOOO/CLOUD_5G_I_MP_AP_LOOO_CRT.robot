*** Settings ***
Force Tags    CRT    RAN_5G    CLOUD_5G_I_MP_AP_LOOO

Documentation    :copyright: Nokia
...              :authors: Palina Krasnova
...              :contact: palina.krasnova@nokia.com
...              This Test Suite contains the test cases for CNI-125229

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Resource     ../../feature_resources/CNI125229/CNI-125229_B_20_slots_NDM_SRS_periodicity_is_supported_for_SRS_configuration.robot
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_enb
Variables    testsuite/Wroclaw/RRM/VRF_WRO2_T023/resources/airphone/logging_policy.py

Suite Setup    Run Keyword    Backup And Modify Swconfig File    parameters_list=@{ENABLE_CPLANE_DEBUG_LOGS}

Suite Teardown     Stop Default Processes And Gather Logs And Compress Logs    teardown_egate_instances=False    additional_logs=False

*** Variables ***
${LOGS_COMPRESSION}=    ${True}
${LOGGING_POLICY}=      NO_TRAFFIC_POLICY_PER_TC

${cni125229_iphy}=          ${CURDIR}/config/cni125229_iphy.xml
${cni125229_scfc}=          cni125229_scf_TDD_ecpri_SA_NSA_50Mhz.xml
${cni125229_wts_config}=    ${CURDIR}/config/cni125229_singleAP_sansa_2_AP_12cell_SA_NSA_t2r4_n2.lua


*** Test Cases ***
CNI-125229_B_20_slots_NDM_SRS_periodicity_is_supported_for_SRS_configuration_for_SB_BF_for_2_UEs_in_12cell
    [Documentation]    :copyright: Nokia
    ...                :authors: Palina Krasnova
    ...                :contact: palina.krasnova@nokia.com
    ...                Test for 12 cells/ABIP with allowSlowPrbPoolingStatNdmSrs = FALSE

    [Setup]    Run Keywords    Configure Eth3 And Eth4 Interfaces    AND
    ...                        Install Bsr Package For AQQL    AND
    ...                        Update And Put Iphy Xml    input_filepath=${cni125229_iphy}    AND
    ...                        Find Scfc And Fix And Send Full Commissioning    scfc_filename=${cni125229_scfc}    AND
    ...                        Wait For Testline Icmp Echo Replies And Ssh Services    AND
    ...                        Wait For Gnb Environment Stabilization    AND
    ...                        Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                        Configure Wts Environment    lua_cfg=${cni125229_wts_config}

    TC__CNI-125229_B_20_slots_NDM_SRS_periodicity_is_supported_for_SRS_configuration_for_SB_BF_for_2_UEs_in_12cell

    [Teardown]    Run Keywords    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                           Collect Additional Debug Files For Failed Testcase Or Testsuite    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                           Teardown Egate    AND
    ...                           Add Scout Data Info To Testcase
