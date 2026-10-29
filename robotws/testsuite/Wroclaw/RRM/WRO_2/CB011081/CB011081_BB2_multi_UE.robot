*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia
...              :authors: Pawel Bicz
...              :contact: pawel.bicz@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/traffic.robot
Resource     ../keywords/L3_Call.robot
Resource     ../keywords/ue_measurements.robot
Resource     Keywords_CB011081.robot
Resource     CB011081_BB2_multi_UE_variables.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Library      ta_messaging
Library      taf.ul.ettf.setups
Library      ta5g_ue_measurements
Library      ta5g_ue_mobility
Library      ta5g_testline_management
Library      ta5g_pm_counters
Library      ta5g_iphy
Variables    ta5g_global_var
Variables    CB011081_messaging_filters.py
Variables    logging_policy.py


Suite Setup    Run Keywords    Remove And Replace File    new_file=${new_file}    target_path=${target_path}
...            AND             Log to console    Full scfc commissioning with iphy.xml upload
...            AND             Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_booloo_bb2.xml
...            AND             With Gnb Configuration    commissioning=full_scfc_CB011081_BB2.xml
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             Check Radios Availability
...            AND             Create GNB Alias   gNB_id=${GNB_ID}
...            AND             Create Alias For UEs    ue_id_start=1    ue_id_stop=29
...            AND             With Simulator Configuration    config=${CURDIR}/config/wts_booloo_bb2.cfg
...            AND             Wait For Next Full Pm Interval


Test Teardown    Add Scout Data Info To Testcase


*** Test Cases ***
USCB011081-BB2_Multiple_UEs_Call_Setup_for_3F+3T_4F+2T_CA_together_with_legacy_CA
    Expect SCell ToBeSetupMod And ToAddModList    ue_id=${UE1_2CC}    gnb_id=${GNB_ID}
    Attach UE And Expect Establishing PDU Session   ue_id=${UE1_2CC}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}   pdu_id=${PDU_ID}    gw_id=${GW_ID}
    Verify SCell Addition Messages For CC    ue_id=${UE1_2CC}    cc_nr_cell_identitiy=@{2CC_NR_CELL_IDENTITIY_UE1}
    ...    cc_scell_physcell_id=@{2CC_SCELL_PHYSCELL_ID_UE1}      num_of_reportConfigId=1
    Start Specific Data DL Traffic    ue_id=${UE1_2CC}    pdu_id=${PDU_ID}    mbps_per_trf_id=10    first_trf_id=1    last_trf_id=3

    Expect SCell ToBeSetupMod And ToAddModList    ue_id=${UE2_3CC}    gnb_id=${GNB_ID}
    Attach UE And Expect Establishing PDU Session   ue_id=${UE2_3CC}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}   pdu_id=${PDU_ID}    gw_id=${GW_ID}
    Verify SCell Addition Messages For CC    ue_id=${UE2_3CC}    cc_nr_cell_identitiy=@{3CC_NR_CELL_IDENTITIY_UE2}
    ...    cc_scell_physcell_id=@{3CC_SCELL_PHYSCELL_ID_UE2}      num_of_reportConfigId=2
    Start Specific Data DL Traffic    ue_id=${UE2_3CC}    pdu_id=${PDU_ID}    mbps_per_trf_id=10    first_trf_id=1    last_trf_id=3

    Expect SCell ToBeSetupMod And ToAddModList    ue_id=${UE3_4CC}    gnb_id=${GNB_ID}
    Attach UE And Expect Establishing PDU Session   ue_id=${UE3_4CC}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}   pdu_id=${PDU_ID}    gw_id=${GW_ID}
    Verify SCell Addition Messages For CC    ue_id=${UE3_4CC}    cc_nr_cell_identitiy=@{4CC_NR_CELL_IDENTITIY_UE3}
    ...    cc_scell_physcell_id=@{4CC_SCELL_PHYSCELL_ID_UE3}      num_of_reportConfigId=3
    Start Specific Data DL Traffic    ue_id=${UE3_4CC}    pdu_id=${PDU_ID}    mbps_per_trf_id=10    first_trf_id=1    last_trf_id=3

    Expect SCell ToBeSetupMod And ToAddModList    ue_id=${UE4_3CC}    gnb_id=${GNB_ID}
    Attach UE And Expect Establishing PDU Session   ue_id=${UE4_3CC}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}   pdu_id=${PDU_ID}    gw_id=${GW_ID}
    Verify SCell Addition Messages For CC    ue_id=${UE4_3CC}    cc_nr_cell_identitiy=@{3CC_NR_CELL_IDENTITIY_UE4}
    ...    cc_scell_physcell_id=@{3CC_SCELL_PHYSCELL_ID_UE4}      num_of_reportConfigId=3
    Start Specific Data DL Traffic    ue_id=${UE4_3CC}    pdu_id=${PDU_ID}    mbps_per_trf_id=10    first_trf_id=1    last_trf_id=3

    Expect SCell ToBeSetupMod And ToAddModList    ue_id=${UE5_3CC}    gnb_id=${GNB_ID}
    Attach UE And Expect Establishing PDU Session   ue_id=${UE5_3CC}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}   pdu_id=${PDU_ID}    gw_id=${GW_ID}
    Verify SCell Addition Messages For CC    ue_id=${UE5_3CC}    cc_nr_cell_identitiy=@{3CC_NR_CELL_IDENTITIY_UE5}
    ...    cc_scell_physcell_id=@{3CC_SCELL_PHYSCELL_ID_UE5}      num_of_reportConfigId=4
    Start Specific Data DL Traffic    ue_id=${UE5_3CC}    pdu_id=${PDU_ID}    mbps_per_trf_id=10    first_trf_id=1    last_trf_id=3

    Expect SCell ToBeSetupMod And ToAddModList    ue_id=${UE6_4CC}    gnb_id=${GNB_ID}
    Attach UE And Expect Establishing PDU Session   ue_id=${UE6_4CC}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}   pdu_id=${PDU_ID}    gw_id=${GW_ID}
    Verify SCell Addition Messages For CC    ue_id=${UE6_4CC}    cc_nr_cell_identitiy=@{4CC_NR_CELL_IDENTITIY_UE6}
    ...    cc_scell_physcell_id=@{4CC_SCELL_PHYSCELL_ID_UE6}      num_of_reportConfigId=6
    Start Specific Data DL Traffic    ue_id=${UE6_4CC}    pdu_id=${PDU_ID}    mbps_per_trf_id=10    first_trf_id=1    last_trf_id=3

    Expect SCell ToBeSetupMod And ToAddModList    ue_id=${UE7_4CC}    gnb_id=${GNB_ID}
    Attach UE And Expect Establishing PDU Session   ue_id=${UE7_4CC}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}   pdu_id=${PDU_ID}    gw_id=${GW_ID}
    Verify SCell Addition Messages For CC    ue_id=${UE7_4CC}    cc_nr_cell_identitiy=@{4CC_NR_CELL_IDENTITIY_UE7}
    ...    cc_scell_physcell_id=@{4CC_SCELL_PHYSCELL_ID_UE7}      num_of_reportConfigId=5
    Start Specific Data DL Traffic    ue_id=${UE7_4CC}    pdu_id=${PDU_ID}    mbps_per_trf_id=10    first_trf_id=1    last_trf_id=3

    Expect SCell ToBeSetupMod And ToAddModList    ue_id=${UE8_4CC}    gnb_id=${GNB_ID}
    Attach UE And Expect Establishing PDU Session   ue_id=${UE8_4CC}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}   pdu_id=${PDU_ID}    gw_id=${GW_ID}
    Verify SCell Addition Messages For CC    ue_id=${UE8_4CC}    cc_nr_cell_identitiy=@{4CC_NR_CELL_IDENTITIY_UE8}
    ...    cc_scell_physcell_id=@{4CC_SCELL_PHYSCELL_ID_UE8}      num_of_reportConfigId=4
    Start Specific Data DL Traffic    ue_id=${UE8_4CC}    pdu_id=${PDU_ID}    mbps_per_trf_id=10    first_trf_id=1    last_trf_id=3

    Expect SCell ToBeSetupMod And ToAddModList    ue_id=${UE9_5CC}    gnb_id=${GNB_ID}
    Attach UE And Expect Establishing PDU Session   ue_id=${UE9_5CC}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}   pdu_id=${PDU_ID}    gw_id=${GW_ID}
    Verify SCell Addition Messages For CC    ue_id=${UE9_5CC}    cc_nr_cell_identitiy=@{5CC_NR_CELL_IDENTITIY_UE9}
    ...    cc_scell_physcell_id=@{5CC_SCELL_PHYSCELL_ID_UE9}      num_of_reportConfigId=6
    Start Specific Data DL Traffic    ue_id=${UE9_5CC}    pdu_id=${PDU_ID}    mbps_per_trf_id=10    first_trf_id=1    last_trf_id=3

    Expect SCell ToBeSetupMod And ToAddModList    ue_id=${UE10_5CC}    gnb_id=${GNB_ID}
    Attach UE And Expect Establishing PDU Session   ue_id=${UE10_5CC}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}   pdu_id=${PDU_ID}    gw_id=${GW_ID}
    Verify SCell Addition Messages For CC    ue_id=${UE10_5CC}    cc_nr_cell_identitiy=@{5CC_NR_CELL_IDENTITIY_UE10}
    ...    cc_scell_physcell_id=@{5CC_SCELL_PHYSCELL_ID_UE10}      num_of_reportConfigId=7
    Start Specific Data DL Traffic    ue_id=${UE10_5CC}    pdu_id=${PDU_ID}    mbps_per_trf_id=10    first_trf_id=1    last_trf_id=3

    Expect SCell ToBeSetupMod And ToAddModList    ue_id=${UE11_6CC}    gnb_id=${GNB_ID}
    Attach UE And Expect Establishing PDU Session   ue_id=${UE11_6CC}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}   pdu_id=${PDU_ID}    gw_id=${GW_ID}
    Verify SCell Addition Messages For CC    ue_id=${UE11_6CC}    cc_nr_cell_identitiy=@{6CC_NR_CELL_IDENTITIY_UE11}
    ...    cc_scell_physcell_id=@{6CC_SCELL_PHYSCELL_ID_UE11}      num_of_reportConfigId=8
    Start Specific Data DL Traffic    ue_id=${UE11_6CC}    pdu_id=${PDU_ID}    mbps_per_trf_id=10    first_trf_id=1    last_trf_id=3

    Expect SCell ToBeSetupMod And ToAddModList    ue_id=${UE12_6CC}    gnb_id=${GNB_ID}
    Attach UE And Expect Establishing PDU Session   ue_id=${UE12_6CC}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}   pdu_id=${PDU_ID}    gw_id=${GW_ID}
    Verify SCell Addition Messages For CC    ue_id=${UE12_6CC}    cc_nr_cell_identitiy=@{6CC_NR_CELL_IDENTITIY_UE12}
    ...    cc_scell_physcell_id=@{6CC_SCELL_PHYSCELL_ID_UE12}      num_of_reportConfigId=7
    Start Specific Data DL Traffic    ue_id=${UE12_6CC}    pdu_id=${PDU_ID}    mbps_per_trf_id=10    first_trf_id=1    last_trf_id=3

    ${pm_counter_file_legacy}=    Get Next Unpacked Full Pm Counters File
    ${pm_counter_file_6CC}=    Get Next Unpacked Full Pm Counters File

    Verify Pm Counters With Varius Value
    ...    counter_id_list=@{COUNTER_IDS_PCELL}
    ...    counter_name_list=@{COUNTER_NAMES_PCELL}
    ...    local_moid=${LOCAL_MOID_PCELL}
    ...    pm_counter_file=${pm_counter_file_legacy}
    ...    condition=@{EXPECTED_PM_COUNTERS_VALUES}

    Verify Pm Counters With Varius Value
    ...    counter_id_list=@{COUNTER_IDS_PCELL_6CC_RELATED}
    ...    counter_name_list=@{COUNTER_NAMES_PCELL_6CC_RELATED}
    ...    local_moid=${LOCAL_MOID_PCELL}
    ...    pm_counter_file=${pm_counter_file_6CC}
    ...    condition=@{EXPECTED_PM_COUNTERS_VALUES_6CC_RELATED}

    Verify Pm Counter On SCells
    ...    counter_id=${COUNTER_UE_SCELL_1_CONF_SCELL_UL_SA}
    ...    counter_name=${COUNTER_NAME_UE_SCELL_1_CONF_SCELL_UL_SA}
    ...    local_moids=@{LOCAL_MOIDS_SCELL_M55118C10006}
    ...    pm_counter_file=${pm_counter_file_6CC}
    ...    condition=@{EXPECTED_PM_COUNTERS_VALUES_M55118C10006}

    Verify Pm Counter On SCells
    ...    counter_id=${COUNTER_UE_SCELL_5_CONF_SCELL_DL_SA}
    ...    counter_name=${COUNTER_NAME_UE_SCELL_5_CONF_SCELL_DL_SA}
    ...    local_moids=@{LOCAL_MOIDS_SCELL_M55118C00018}
    ...    pm_counter_file=${pm_counter_file_6CC}
    ...    condition=@{EXPECTED_PM_COUNTERS_VALUES_M55118C00018}


*** Keywords ***
Remove And Replace File
    [Arguments]    ${new_file}    ${target_path}
    Log  \n==== Replace file to solve the problem with dissecting nr-rrc packets with ute-wireshark 4.4.7 ====  console=True
    # Ensure the new file exists
    File Should Exist    ${new_file}

    # Remove the target file if it exists
    Run Keyword And Ignore Error    Remove File    ${target_path}

    # Copy the new file to the target location
    Copy File    ${new_file}    ${target_path}
