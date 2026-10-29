*** Settings ***
Force Tags    CRT    RAN_5G    CLOUD_5G_I_BOO_AP_LOO

Documentation    :copyright: Nokia
...              :authors: Palina Krasnova
...              :contact: palina.krasnova@nokia.com
...              This Test Suite contains the test cases for CB008224, CB009854, CB005934, CB006733, CB011117

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Resource     ../../feature_resources/CB008224/CB008224-D-B2_2_IWK_with_CB007114_BB_Pooling_of_no_reserved_of_PUCCH_and_PUSCH.robot
Resource     ../../feature_resources/CB009854/CB009854-AB-B4a_Large_dedicated_BWP_configuration_for_FDD_SCell_of_UE_configured_with_5CC_DL_CA.robot
Resource     ../../feature_resources/CB009854/CB009854-AB-B9a_UE_configured_with_5CC_DL_CA_interaction_with_DSS.robot
Resource     ../../feature_resources/CB005934/CB005934-SR-A-B10_Single_UE_Call-SCell_Change_based_on_A1-PCell_measurement_from_4CC_to_2CC.robot
Resource     ../../feature_resources/CB005934/CB005934-SR-B-B1_Multiple_UEs_Call-Setup_4CC_FDD_DL_CA.robot
Resource     ../../feature_resources/CB005934/CB005934-SR-B-B6a_Multi_UE_Call-SCell_Change_based_on_A1-PCell_measurement_from_3CC_to_4CC.robot
Resource     ../../feature_resources/CB006733/CB006733-A_B4_Deactivation_of_A4_measurements_for_SCell_addition.robot
Resource     ../../feature_resources/CB006733/CB006733-B_B17_SCell_Change_not_triggered_when_mixed_A1-based_and_A4-based_SCells_are_configured.robot
Resource     ../../feature_resources/CB006733/CB006733-B_B20_Interaction_with_gNB_overload_5GC000281.robot
Resource     ../../feature_resources/CB006733/CB006733-B_B22_CB007517_interaction_UE_not_CA_capable_or_CA_Capable.robot
Resource     ../../feature_resources/CB006733/CB006733-B_B23_CB008696_interaction_-_Deactivation_of_A4_measurements_for_FR1_CA_SCell_Addition.robot
Resource     ../../feature_resources/CB006733/CB006733-C_B30_PDU_Session_Release_CB009059_interaction_A4_measurement_activation.robot
Resource     ../../feature_resources/CB006733/CB006733-C_B31_PDU_Session_Modify_CB009059_interaction_Activation_of_A4_measurements.robot
Resource     ../../feature_resources/CB011117/CB011117_A_2a_intra-gnb_intra-freq_HO_with_subbandBF_single_UE.robot
Library      OperatingSystem
Library      Process
Library      ta5g_testline_management
Library      ta5g_cell_operations
Library      ta5g_iphy
Library      ta5g_tshark
Library      ta5g_enb
Variables    testsuite/Wroclaw/RRM/VRF_WRO2_T023/resources/airphone/logging_policy.py

Suite Setup    Run Keyword    Backup And Modify Swconfig File    parameters_list=@{ENABLE_CPLANE_DEBUG_LOGS}

Suite Teardown     Stop Default Processes And Gather Logs And Compress Logs    teardown_egate_instances=False    additional_logs=False

*** Variables ***
${LOGS_COMPRESSION}=    ${True}
${LOGGING_POLICY}=      NO_TRAFFIC_POLICY_PER_TC

@{DEACT_FLAGS_LIST}=       ${CB007208}
@{OVERLOAD_FLAGS_LIST}=    ${0x89008e}    ${CB007208}
${CB007208}=    0x890073=0    # Disabled CB007208
${0x89008e}=    0x89008E=0    # rdPreventOverloadActivationBeforeUeTresholdIsReached

@{INTER_GNB_FLAGS_LIST}=    ${rdActInterGnbCaWithSrsForSbBf}    ${rdComponentBitMapProfile}
${rdActInterGnbCaWithSrsForSbBf}=    0x590287=1    # rdActInterGnbCaWithSrsForSbBf
${rdComponentBitMapProfile}=         0x5808FF=2    # Activate profile: 1 - All events in tti

${cb008224_iphy}=          ${CURDIR}/config/cb008224_new_iphy.xml
${cb008224_scfc}=          cb008224_7114_Full_Config.xml
${cb008224_wts_config}=    ${CURDIR}/config/cb008224_wts_SDL_on_Cell5_n66.cfg

${cb009854_ab_b4a_iphy}=          ${CURDIR}/config/cb009854_AB_B4A_iphy_xml.xml
${cb009854_ab_b4a_scfc}=          cb009854_AB-B4a.xml
${cb009854_ab_b4a_wts_config}=    ${CURDIR}/config/cb009854_AB_B4A_wts.cfg

${cb009854_ab_b9a_iphy}=          ${CURDIR}/config/cb009854_AB_B9_iphy.xml
${cb009854_ab_b9a_scfc}=          cb009854_AB_B9_DSS.xml
${cb009854_ab_b9a_wts_config}=    ${CURDIR}/config/cb009854_AB_B9_wts_DSS.cfg

${cb005934_iphy}=          ${CURDIR}/config/cb005934_iphy_AP_LOO_AHFII_AHFIB_AEQE_AHFII_gnb_ABIO_4FDD_2TDD.xml
${cb005934_a_b10_scfc}=    cb005934_a_b10_SCF.xml
${cb005934_b_b1_scfc}=     cb005934_b_b1_scf_gNB_BOO_4FDD_n25_30_15MHz_n66_40MHz_n71_20MHz_2TDD_n41_40MHz_n77_80MHz.xml
${cb005934_b_b6_scfc}=     cb005934_B_B6a_3CC_to_4CC_change.xml
${cb005934_wts_config}=    ${CURDIR}/config/cb005934_wts_4cells_4FDD_n25_30_15MHz_n66_40MHz_n71_20MHz_2TDD_n41_40MHz_n77_80MHz.cfg

${cb006733_iphy}=                ${CURDIR}/config/cb006733_iphy_xml.xml
${cb006733_a_b4_scfc}=           cb006733_A_B4.xml
${cb006733_b_b17_scfc}=          cb006733_B_B17.xml
${cb006733_b_b20_scfc}=          cb006733_B_B20_overload.xml
${cb006733_b_b22_scfc}=          cb006733_B_B22.xml
${cb006733_b_b23_scfc}=          cb006733_b_b23_scfc.xml
${cb006733_c_b30_scfc}=          cb006733_C_B30.xml
${cb006733_c_b31_scfc}=          cb006733_C_B31.xml
${cb006733_a_b4_wts_config}=     ${CURDIR}/config/cb006733_a_b4_wts.cfg
${cb006733_b_b17_wts_config}=    ${CURDIR}/config/cb006733_BB17_wts.cfg
${cb006733_b_b20_wts_config}=    ${CURDIR}/config/cb006733_B_B20_wts.cfg
${cb006733_b_b22_wts_config}=    ${CURDIR}/config/cb006733_B_B22_wts.cfg
${cb006733_b_b23_wts_config}=    ${CURDIR}/config/cb006733_B_B23_wts.cfg
${cb006733_c_b30_wts_config}=    ${CURDIR}/config/cb006733_C_B30_wts.cfg
${cb006733_c_b31_wts_config}=    ${CURDIR}/config/cb006733_C_B31_wts.cfg

${cb011117_iphy}=          ${CURDIR}/config/cb011117_iphy_aqql_2TDD_2FDD_Subbeam.xml
${cb011117_scfc}=          cb011117_Full_Configuration_scf_intra_gNB_intra_freq_HO_pass.xml
${cb011117_wts_config}=    ${CURDIR}/config/cb011117_wts_2TDD_2FDD_intra_gNB_intra_freq_HO.lua


*** Test Cases ***
CB008224-D-B2_2_IWK_with_CB007114_BB_Pooling_of_no_reserved_of_PUCCH_and_PUSCH_Sched_UEs_for_SDL_Cell_with_load_metric
    [Documentation]    :copyright: Nokia
    ...                :authors: Mateusz Kuropka
    ...                :contact: mateusz.kuropka@nokia.com

    [Setup]    Run Keywords    Update And Put Iphy Xml    input_filepath=${cb008224_iphy}    AND
    ...                        Find Scfc And Fix And Send Full Commissioning    scfc_filename=${cb008224_scfc}    AND
    ...                        Wait For Testline Icmp Echo Replies And Ssh Services    AND
    ...                        Start Vm Ethernet Interfaces    AND
    ...                        Check Radios Availability    AND
    ...                        Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                        Reach Onair Without Confirmation    lua_cfg=${cb008224_wts_config}    AND
    ...                        Wait For Next Full Pm Interval

    TC__CB008224-D-B2_2_IWK_with_CB007114_BB_Pooling_of_no_reserved_of_PUCCH_and_PUSCH_Sched_UEs_for_SDL_Cell_with_load_metric

    [Teardown]    Run Keywords    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                           Collect Additional Debug Files For Failed Testcase Or Testsuite    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                           Teardown Egate    AND
    ...                           Stop Vm Ethernet Interfaces    AND
    ...                           Add Scout Data Info To Testcase

CB009854-AB-B4a_Large_dedicated_BWP_configuration_for_FDD_SCell_of_UE_configured_with_5CC_DL_CA_due_to_UE_full_bandwidth_support
    [Documentation]    :copyright: Nokia
    ...                :authors: Krystian Kozlowski, Vira Solomashenko
    ...                :contact: krystian.kozlowski@nokia.com, vira.solomashenko@nokia.com

    [Setup]    Run Keywords    Update And Put Iphy Xml    input_filepath=${cb009854_ab_b4a_iphy}    AND
    ...                        Find Scfc And Fix And Send Full Commissioning    scfc_filename=${cb009854_ab_b4a_scfc}    AND
    ...                        Wait For Testline Icmp Echo Replies And Ssh Services    AND
    ...                        Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                        Check Radios Availability    AND
    ...                        Reach Onair    lua_cfg=${cb009854_ab_b4a_wts_config}

    TC__CB009854-AB-B4a_Large_dedicated_BWP_configuration_for_FDD_SCell_of_UE_configured_with_5CC_DL_CA_due_to_UE_full_bandwidth_support

    [Teardown]    Run Keywords    Teardown Egate    AND
    ...                           Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                           Collect Additional Debug Files For Failed Testcase Or Testsuite    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                           Add Scout Data Info To Testcase

CB009854-AB-B9a_UE_configured_with_5CC_DL_CA_with_2_FDD_and_3_TDD_serving_cell_is_not_configured_with_2CC_UL_CA_due_to_interaction_with_DSS
    [Documentation]    :copyright: Nokia
    ...                :authors: Krystian Kozlowski, Vira Solomashenko
    ...                :contact: krystian.kozlowski@nokia.com, vira.solomashenko@nokia.com

    [Setup]   Run Keywords    Update And Put Iphy Xml    input_filepath=${cb009854_ab_b9a_iphy}    AND
    ...                       Find Scfc And Fix And Send Full Commissioning    scfc_filename=${cb009854_ab_b9a_scfc}    AND
    ...                       Wait For Testline Icmp Echo Replies And Ssh Services    AND
    ...                       Start Vm Ethernet Interfaces For DSS    AND
    ...                       Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                       Check Radios Availability    AND
    ...                       Reach Onair Without Confirmation    lua_cfg=${cb009854_ab_b9a_wts_config}    AND
    ...                       Wait For All Cells To Be Enabled    timeout=600    AND
    ...                       Activate And Check If Xp Link is active    AND
    ...                       BuiltIn.Sleep    60s    Wait for Xp Link to stabilize    AND
    ...                       Setup Additional Configuration

    TC__CB009854-AB-B9a_UE_configured_with_5CC_DL_CA_with_2_FDD_and_3_TDD_serving_cell_is_not_configured_with_2CC_UL_CA_due_to_interaction_with_DSS

    [Teardown]    Run Keywords    Teardown Egate    AND
    ...                           Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                           Collect Additional Debug Files For Failed Testcase Or Testsuite    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                           Add Scout Data Info To Testcase

CB005934-SR-A-B10_Single_UE_Call-SCell_Change_based_on_A1-PCell_measurement_for_SA_UE_from_4CC_F-F-F-F_CA_to_2CC_F-T_CA
    [Documentation]    :copyright: Nokia
    ...                :authors: Vira Solomashenko
    ...                :contact: vira.solomashenko@nokia.com

    [Setup]    Run Keywords   Update And Put Iphy Xml    input_filepath=${cb005934_iphy}    AND
    ...                       Find Scfc And Fix And Send Full Commissioning    scfc_filename=${cb005934_a_b10_scfc}    AND
    ...                       Wait For Testline Icmp Echo Replies And Ssh Services    AND
    ...                       Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                       Check Radios Availability    AND
    ...                       Reach Onair    lua_cfg=${cb005934_wts_config}    AND
    ...                       Wait For Next Full Pm Interval

    TC__CB005934-SR-A-B10_Single_UE_Call-SCell_Change_based_on_A1-PCell_measurement_for_SA_UE_from_4CC_F-F-F-F_CA_to_2CC_F-T_CA

    [Teardown]    Run Keywords    Teardown Egate    AND
    ...                           Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                           Collect Additional Debug Files For Failed Testcase Or Testsuite    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                           Add Scout Data Info To Testcase

CB005934-SR-B-B1_Multiple_UEs_Call-Setup_4CC_FDD_DL_CA
    [Documentation]    :copyright: Nokia
    ...                :authors: Palina Krasnova
    ...                :contact: palina.krasnova@nokia.com

    [Setup]    Run Keywords    Update And Put Iphy Xml    input_filepath=${cb005934_iphy}    AND
    ...                        Find Scfc And Fix And Send Full Commissioning    scfc_filename=${cb005934_b_b1_scfc}    AND
    ...                        Wait For Testline Icmp Echo Replies And Ssh Services    AND
    ...                        Check Radios Availability    AND
    ...                        Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                        Reach Onair    lua_cfg=${cb005934_wts_config}

    TC__CB005934-SR-B-B1_Multiple_UEs_Call-Setup_4CC_FDD_DL_CA

    [Teardown]    Run Keywords    Teardown Egate    AND
    ...                           Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                           Collect Additional Debug Files For Failed Testcase Or Testsuite    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                           Add Scout Data Info To Testcase

CB005934-SR-B-B6a_Multi_UE_Call-SCell_Change_based_on_A1-PCell_measurement_for_SA_UE_from_3CC_F-T-T_CA_to_4CC_F-F-F-F_CA
    [Documentation]    :copyright: Nokia
    ...                :authors: Jakub Magier
    ...                :contact: jakub.magier@nokia.com

    [Setup]    Run Keywords    Update And Put Iphy Xml    input_filepath=${cb005934_iphy}    AND
    ...                        Find Scfc And Fix And Send Full Commissioning    scfc_filename=${cb005934_b_b6_scfc}    AND
    ...                        Wait For Testline Icmp Echo Replies And Ssh Services    AND
    ...                        Check Radios Availability    AND
    ...                        Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                        Reach Onair    lua_cfg=${cb005934_wts_config}    AND
    ...                        Wait For Next Full Pm Interval

    TC__CB005934-SR-B-B6a_Multi_UE_Call-SCell_Change_based_on_A1-PCell_measurement_for_SA_UE_from_3CC_F-T-T_CA_to_4CC_F-F-F-F_CA

    [Teardown]    Run Keywords    Teardown Egate    AND
    ...                           Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                           Collect Additional Debug Files For Failed Testcase Or Testsuite    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                           Add Scout Data Info To Testcase

CB006733-A_B4_Deactivation_of_A4_measurements_for_SCell_addition_after_A4_supervision_timer_expiry_and_reactivation_upon_A4_retry_timer_expiry
    [Documentation]    :copyright: Nokia
    ...                :authors: Mateusz Kuropka
    ...                :contact: mateusz.kuropka@nokia.com

    [Setup]    Run Keywords    Backup And Modify Swconfig File    parameters_list=@{DEACT_FLAGS_LIST}    AND
    ...                        Update And Put Iphy Xml    input_filepath=${cb006733_iphy}    AND
    ...                        Find Scfc And Fix And Send Full Commissioning    scfc_filename=${cb006733_a_b4_scfc}    AND
    ...                        Wait For Testline Icmp Echo Replies And Ssh Services    AND
    ...                        Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                        Check Radios Availability    AND
    ...                        Reach Onair    lua_cfg=${cb006733_a_b4_wts_config}

    TC__CB006733-A_B4_Deactivation_of_A4_measurements_for_SCell_addition_after_A4_supervision_timer_expiry_and_reactivation

    [Teardown]    Run Keywords    Teardown Egate    AND
    ...                           Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                           Collect Additional Debug Files For Failed Testcase Or Testsuite    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                           Add Scout Data Info To Testcase

CB006733-B_B23_CB008696_interaction_-_Deactivation_of_A4_measurements_for_FR1_CA_SCell_Addition_on_UE_Inactivity_timer_expiration
    [Documentation]    :copyright: Nokia
    ...                :authors: Sebastian Sliwakowski
    ...                :contact: sebastian.sliwakowski@nokia.com

    [Setup]    Run Keywords    Update And Put Iphy Xml    input_filepath=${cb006733_iphy}    AND
    ...                        Find Scfc And Fix And Send Full Commissioning    scfc_filename=${cb006733_b_b23_scfc}    AND
    ...                        Wait For Testline Icmp Echo Replies And Ssh Services    AND
    ...                        Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                        Check Radios Availability    AND
    ...                        Reach Onair    lua_cfg=${cb006733_b_b23_wts_config}

    TC__CB006733-B_B23_CB008696_interaction_-_Deactivation_of_A4_measurements_for_FR1_CA_SCell_Addition_on_UE_Inactivity_timer_expiration

    [Teardown]    Run Keywords    Teardown Egate    AND
    ...                           Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                           Collect Additional Debug Files For Failed Testcase Or Testsuite    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                           Add Scout Data Info To Testcase

CB006733-C_B30_PDU_Session_Release_CB009059_interaction_A4_measurement_activation_for_FR1_CA_SCell_Addition_upon_last_CA_incompatible_DRB_release
    [Documentation]    :copyright: Nokia
    ...                :authors: Palina Krasnova
    ...                :contact: palina.krasnova@nokia.com

    [Setup]    Run Keywords    Update And Put Iphy Xml    input_filepath=${cb006733_iphy}    AND
    ...                        Find Scfc And Fix And Send Full Commissioning    scfc_filename=${cb006733_c_b30_scfc}    AND
    ...                        Wait For Testline Icmp Echo Replies And Ssh Services    AND
    ...                        Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                        Check Radios Availability    AND
    ...                        Reach Onair    lua_cfg=${cb006733_c_b30_wts_config}

    TC__CB006733-C_B30_PDU_Session_Release_CB009059_interaction_A4_measurement_activation_for_FR1_CA_SCell_Addition

    [Teardown]    Run Keywords    Teardown Egate    AND
    ...                           Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                           Collect Additional Debug Files For Failed Testcase Or Testsuite    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                           Add Scout Data Info To Testcase

CB006733-C_B31_PDU_Session_Modify_CB009059_interaction_Activation_of_A4_measurements_for_FR1_CA_SCell_Addition_for_UE_with_CA_eligible_DRB_setup
    [Documentation]    :copyright: Nokia
    ...                :authors: Jakub Magier
    ...                :contact: jakub.magier@nokia.com

    [Setup]    Run Keywords    Update And Put Iphy Xml    input_filepath=${cb006733_iphy}    AND
    ...                        Find Scfc And Fix And Send Full Commissioning    scfc_filename=${cb006733_c_b31_scfc}    AND
    ...                        Wait For Testline Icmp Echo Replies And Ssh Services    AND
    ...                        Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                        Check Radios Availability    AND
    ...                        Reach Onair    lua_cfg=${cb006733_c_b31_wts_config}

    TC__CB006733-C_B31_PDU_Session_Modify_CB009059_interaction_Activation_of_A4_measurements_for_FR1_CA_SCell_Addition

    [Teardown]    Run Keywords    Teardown Egate    AND
    ...                           Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                           Collect Additional Debug Files For Failed Testcase Or Testsuite    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                           Add Scout Data Info To Testcase

CB011117_A#2a_intra-gnb_intra-freq_HO_with_subbandBF_single_UE
    [Documentation]    :copyright: Nokia
    ...                :authors: Mateusz Kuropka
    ...                :contact: mateusz.kuropka@nokia.com

    [Setup]    Run Keywords    Install BSR package    AND
    ...                        Backup And Modify Swconfig File    parameters_list=@{INTER_GNB_FLAGS_LIST}    AND
    ...                        Update And Put Iphy Xml    input_filepath=${cb011117_iphy}    AND
    ...                        Find Scfc And Fix And Send Full Commissioning    scfc_filename=${cb011117_scfc}    AND
    ...                        Wait For Testline Icmp Echo Replies And Ssh Services    AND
    ...                        Modify SCTP Timeout    AND
    ...                        Check Radios Availability    AND
    ...                        Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                        Reach Onair    lua_cfg=${cb011117_wts_config}

    TC__CB011117_A_2a_intra-gnb_intra-freq_HO_with_subbandBF_single_UE

    [Teardown]    Run Keywords    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                           Stop Tcpdump On Remote Interface    AND
    ...                           Collect Additional Debug Files For Failed Testcase Or Testsuite    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                           Teardown Egate    AND
    ...                           Add Scout Data Info To Testcase

CB006733-B_B17_SCell_Change_not_triggered_when_mixed_A1-based_and_A4-based_SCells_are_configured
    [Documentation]    :copyright: Nokia
    ...                :authors: Jakub Magier
    ...                :contact: jakub.magier@nokia.com

    [Setup]    Run Keywords    Extended SupervisionTimer    20    AND
    ...                        Backup And Modify Swconfig File    parameters_list=@{DEACT_FLAGS_LIST}    AND
    ...                        Update And Put Iphy Xml    input_filepath=${cb006733_iphy}    AND
    ...                        Find Scfc And Fix And Send Full Commissioning    scfc_filename=${cb006733_b_b17_scfc}    AND
    ...                        Wait For Testline Icmp Echo Replies And Ssh Services    AND
    ...                        Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                        Check Radios Availability    AND
    ...                        Reach Onair    lua_cfg=${cb006733_b_b17_wts_config}    AND
    ...                        Setup Tshark With Nokia F1AP Plugin

    TC__CB006733-B_B17_SCell_Change_not_triggered_when_mixed_A1-based_and_A4-based_SCells_are_configured

    [Teardown]    Run Keywords    Teardown Egate    AND
    ...                           Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                           Collect Additional Debug Files For Failed Testcase Or Testsuite    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                           Add Scout Data Info To Testcase

CB006733-B_B22_CB007517_interaction_UE_not_CA_capable_or_CA_Capable_but_not_possible_to_configure_with_CA
    [Documentation]    :copyright: Nokia
    ...                :authors: Jakub Magier
    ...                :contact: jakub.magier@nokia.com

    [Setup]    Run Keywords    Extended SupervisionTimer    20    AND
    ...                        Update And Put Iphy Xml    input_filepath=${cb006733_iphy}    AND
    ...                        Find Scfc And Fix And Send Full Commissioning    scfc_filename=${cb006733_b_b22_scfc}    AND
    ...                        Wait For Testline Icmp Echo Replies And Ssh Services    AND
    ...                        Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                        Check Radios Availability    AND
    ...                        Reach Onair    lua_cfg=${cb006733_b_b22_wts_config}

    TC__CB006733-B_B22_CB007517_interaction_UE_not_CA_capable_or_CA_Capable_but_not_possible_to_configure_with_CA

    [Teardown]    Run Keywords    Teardown Egate    AND
    ...                           Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                           Collect Additional Debug Files For Failed Testcase Or Testsuite    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                           Add Scout Data Info To Testcase

CB006733-B_B20_Interaction_with_gNB_overload_5GC000281
    [Documentation]    :copyright: Nokia
    ...                :authors: Mateusz Kuropka
    ...                :contact: mateusz.kuropka@nokia.com

    [Setup]    Run Keywords    Backup And Modify Swconfig File    parameters_list=@{OVERLOAD_FLAGS_LIST}    AND
    ...                        Extended SupervisionTimer    120    AND
    ...                        Update And Put Iphy Xml    input_filepath=${cb006733_iphy}    AND
    ...                        Find Scfc And Fix And Send Full Commissioning    scfc_filename=${cb006733_b_b20_scfc}    AND
    ...                        Wait For Testline Icmp Echo Replies And Ssh Services    AND
    ...                        Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                        Check Radios Availability    AND
    ...                        Reach Onair    lua_cfg=${cb006733_b_b20_wts_config}    AND
    ...                        Setup Tshark With Nokia F1AP Plugin

    TC__CB006733-B_B20_Interaction_with_gNB_overload_5GC000281

    [Teardown]    Run Keywords    Teardown Egate    AND
    ...                           Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                           Collect Additional Debug Files For Failed Testcase Or Testsuite    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                           Add Scout Data Info To Testcase
