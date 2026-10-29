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
Resource     CB011081_Robustness_variables.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Library      ta_messaging
Library      taf.ul.ettf.setups
Library      ta5g_ue_measurements
Library      ta5g_ue_mobility
Library      ta5g_testline_management
Library      ta5g_pm_counters
Library      ta5g_iphy
Library      ../CB012559/multi_UE_handling.py
Variables    ta5g_global_var
Variables    CB011081_messaging_filters.py
Variables    logging_policy.py


Suite Setup    Run Keywords    Remove And Replace File    new_file=${new_file}    target_path=${target_path}
...            AND             Log to console    Full scfc commissioning with iphy.xml upload
...            AND             Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_booloo_bb2.xml
...            AND             With Gnb Configuration    commissioning=full_scfc_CB011081_robustness.xml
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             Check Radios Availability
...            AND             Create GNB Alias   gNB_id=${GNB_ID}
...            AND             Create Alias For UEs    ue_id_start=1    ue_id_stop=29
...            AND             With Simulator Configuration    config=${CURDIR}/config/wts_booloo_robustness.cfg
...            AND             Wait For Next Full Pm Interval

Test Teardown    Run Keywords    Release Multiple UEs Without Confirmation    number_of_ues=26
...              AND    Add Scout Data Info To Testcase


*** Test Cases ***
CB011081-BB2_Robustness_Multiple_UEs_Call_Setup_for_3F+3T_4F+2T_CA_together_with_legacy_CA_act_deact_feature
    Attach UE And Expect Establish CA    ue_id=${UE1_2CC}    gnb_id=${GNB_ID}    cell_id=${PCELL_ID}
    ...    cc_nr_cell_identitiy=@{2CC_NR_CELL_IDENTITIY_UE1}    cc_scell_physcell_id=@{2CC_SCELL_PHYSCELL_ID_UE1}    num_of_reportConfigId=1

    Attach UE And Expect Establish CA    ue_id=${UE2_2CC}    gnb_id=${GNB_ID}    cell_id=${PCELL_ID}
    ...    cc_nr_cell_identitiy=@{2CC_NR_CELL_IDENTITIY_UE2}    cc_scell_physcell_id=@{2CC_SCELL_PHYSCELL_ID_UE2}    num_of_reportConfigId=1

    Attach UE And Expect Establish CA    ue_id=${UE3_3CC}    gnb_id=${GNB_ID}    cell_id=${PCELL_ID}
    ...    cc_nr_cell_identitiy=@{3CC_NR_CELL_IDENTITIY_UE3}    cc_scell_physcell_id=@{3CC_SCELL_PHYSCELL_ID_UE3}    num_of_reportConfigId=2

    Attach UE And Expect Establish CA    ue_id=${UE4_3CC}    gnb_id=${GNB_ID}    cell_id=${PCELL_ID}
    ...    cc_nr_cell_identitiy=@{3CC_NR_CELL_IDENTITIY_UE4}    cc_scell_physcell_id=@{3CC_SCELL_PHYSCELL_ID_UE4}    num_of_reportConfigId=2

    Attach UE And Expect Establish CA    ue_id=${UE5_4CC}    gnb_id=${GNB_ID}    cell_id=${PCELL_ID}
    ...    cc_nr_cell_identitiy=@{4CC_NR_CELL_IDENTITIY_UE5}    cc_scell_physcell_id=@{4CC_SCELL_PHYSCELL_ID_UE5}    num_of_reportConfigId=3

    Attach UE And Expect Establish CA    ue_id=${UE6_4CC}    gnb_id=${GNB_ID}    cell_id=${PCELL_ID}
    ...    cc_nr_cell_identitiy=@{4CC_NR_CELL_IDENTITIY_UE6}    cc_scell_physcell_id=@{4CC_SCELL_PHYSCELL_ID_UE6}    num_of_reportConfigId=3

    Attach UE And Expect Establish CA    ue_id=${UE7_3CC}    gnb_id=${GNB_ID}    cell_id=${PCELL_ID}
    ...    cc_nr_cell_identitiy=@{3CC_NR_CELL_IDENTITIY_UE7}    cc_scell_physcell_id=@{3CC_SCELL_PHYSCELL_ID_UE7}    num_of_reportConfigId=3

    Attach UE And Expect Establish CA    ue_id=${UE8_3CC}    gnb_id=${GNB_ID}    cell_id=${PCELL_ID}
    ...    cc_nr_cell_identitiy=@{3CC_NR_CELL_IDENTITIY_UE8}    cc_scell_physcell_id=@{3CC_SCELL_PHYSCELL_ID_UE8}    num_of_reportConfigId=3

    Attach UE And Expect Establish CA    ue_id=${UE9_3CC}    gnb_id=${GNB_ID}    cell_id=${PCELL_ID}
    ...    cc_nr_cell_identitiy=@{3CC_NR_CELL_IDENTITIY_UE9}    cc_scell_physcell_id=@{3CC_SCELL_PHYSCELL_ID_UE9}    num_of_reportConfigId=4

    Attach UE And Expect Establish CA    ue_id=${UE10_3CC}    gnb_id=${GNB_ID}    cell_id=${PCELL_ID}
    ...    cc_nr_cell_identitiy=@{3CC_NR_CELL_IDENTITIY_UE10}    cc_scell_physcell_id=@{3CC_SCELL_PHYSCELL_ID_UE10}    num_of_reportConfigId=4

    Attach UE And Expect Establish CA    ue_id=${UE11_4CC}    gnb_id=${GNB_ID}    cell_id=${PCELL_ID}
    ...    cc_nr_cell_identitiy=@{4CC_NR_CELL_IDENTITIY_UE11}    cc_scell_physcell_id=@{4CC_SCELL_PHYSCELL_ID_UE11}    num_of_reportConfigId=6

    Attach UE And Expect Establish CA    ue_id=${UE12_4CC}    gnb_id=${GNB_ID}    cell_id=${PCELL_ID}
    ...    cc_nr_cell_identitiy=@{4CC_NR_CELL_IDENTITIY_UE12}    cc_scell_physcell_id=@{4CC_SCELL_PHYSCELL_ID_UE12}    num_of_reportConfigId=6

    Attach UE And Expect Establish CA    ue_id=${UE13_4CC}    gnb_id=${GNB_ID}    cell_id=${PCELL_ID}
    ...    cc_nr_cell_identitiy=@{4CC_NR_CELL_IDENTITIY_UE13}    cc_scell_physcell_id=@{4CC_SCELL_PHYSCELL_ID_UE13}    num_of_reportConfigId=5

    Attach UE And Expect Establish CA    ue_id=${UE14_4CC}    gnb_id=${GNB_ID}    cell_id=${PCELL_ID}
    ...    cc_nr_cell_identitiy=@{4CC_NR_CELL_IDENTITIY_UE14}    cc_scell_physcell_id=@{4CC_SCELL_PHYSCELL_ID_UE14}    num_of_reportConfigId=5

    Attach UE And Expect Establish CA    ue_id=${UE15_4CC}    gnb_id=${GNB_ID}    cell_id=${PCELL_ID}
    ...    cc_nr_cell_identitiy=@{4CC_NR_CELL_IDENTITIY_UE15}    cc_scell_physcell_id=@{4CC_SCELL_PHYSCELL_ID_UE15}    num_of_reportConfigId=4

    Attach UE And Expect Establish CA    ue_id=${UE16_4CC}    gnb_id=${GNB_ID}    cell_id=${PCELL_ID}
    ...    cc_nr_cell_identitiy=@{4CC_NR_CELL_IDENTITIY_UE16}    cc_scell_physcell_id=@{4CC_SCELL_PHYSCELL_ID_UE16}    num_of_reportConfigId=4

    Attach UE And Expect Establish CA    ue_id=${UE17_5CC}    gnb_id=${GNB_ID}    cell_id=${PCELL_ID}
    ...    cc_nr_cell_identitiy=@{5CC_NR_CELL_IDENTITIY_UE17}    cc_scell_physcell_id=@{5CC_SCELL_PHYSCELL_ID_UE17}    num_of_reportConfigId=6

    Attach UE And Expect Establish CA    ue_id=${UE18_5CC}    gnb_id=${GNB_ID}    cell_id=${PCELL_ID}
    ...    cc_nr_cell_identitiy=@{5CC_NR_CELL_IDENTITIY_UE18}    cc_scell_physcell_id=@{5CC_SCELL_PHYSCELL_ID_UE18}    num_of_reportConfigId=6

    Attach UE And Expect Establish CA    ue_id=${UE19_5CC}    gnb_id=${GNB_ID}    cell_id=${PCELL_ID}
    ...    cc_nr_cell_identitiy=@{5CC_NR_CELL_IDENTITIY_UE19}    cc_scell_physcell_id=@{5CC_SCELL_PHYSCELL_ID_UE19}    num_of_reportConfigId=7

    Attach UE And Expect Establish CA    ue_id=${UE20_5CC}    gnb_id=${GNB_ID}    cell_id=${PCELL_ID}
    ...    cc_nr_cell_identitiy=@{5CC_NR_CELL_IDENTITIY_UE20}    cc_scell_physcell_id=@{5CC_SCELL_PHYSCELL_ID_UE20}    num_of_reportConfigId=7

    Attach UE And Expect Establish CA    ue_id=${UE21_6CC}    gnb_id=${GNB_ID}    cell_id=${PCELL_ID}
    ...    cc_nr_cell_identitiy=@{6CC_NR_CELL_IDENTITIY_UE21}    cc_scell_physcell_id=@{6CC_SCELL_PHYSCELL_ID_UE21}    num_of_reportConfigId=8

    Attach UE And Expect Establish CA    ue_id=${UE22_6CC}    gnb_id=${GNB_ID}    cell_id=${PCELL_ID}
    ...    cc_nr_cell_identitiy=@{6CC_NR_CELL_IDENTITIY_UE22}    cc_scell_physcell_id=@{6CC_SCELL_PHYSCELL_ID_UE22}    num_of_reportConfigId=8

    Attach UE And Expect Establish CA    ue_id=${UE23_6CC}    gnb_id=${GNB_ID}    cell_id=${PCELL_ID}
    ...    cc_nr_cell_identitiy=@{6CC_NR_CELL_IDENTITIY_UE23}    cc_scell_physcell_id=@{6CC_SCELL_PHYSCELL_ID_UE23}    num_of_reportConfigId=7

    Attach UE And Expect Establish CA    ue_id=${UE24_6CC}    gnb_id=${GNB_ID}    cell_id=${PCELL_ID}
    ...    cc_nr_cell_identitiy=@{6CC_NR_CELL_IDENTITIY_UE24}    cc_scell_physcell_id=@{6CC_SCELL_PHYSCELL_ID_UE24}    num_of_reportConfigId=7

    Deactivate Feature CB011081    scfc_filename=delta_maxNumScellsDlFr1_eq_4_cell_2.json

    Attach UE And Expect Establish CA    ue_id=${UE25_6CC}    gnb_id=${GNB_ID}    cell_id=${PCELL_ID}
    ...    cc_nr_cell_identitiy=@{5CC_NR_CELL_IDENTITIY_UE25}    cc_scell_physcell_id=@{5CC_SCELL_PHYSCELL_ID_UE25}    num_of_reportConfigId=6

    Activate Feature CB011081    scfc_filename=delta_maxNumScellsDlFr1_eq_5_cell_2.json

    Attach UE And Expect Establish CA    ue_id=${UE26_6CC}    gnb_id=${GNB_ID}    cell_id=${PCELL_ID}
    ...    cc_nr_cell_identitiy=@{6CC_NR_CELL_IDENTITIY_UE26}    cc_scell_physcell_id=@{6CC_SCELL_PHYSCELL_ID_UE26}    num_of_reportConfigId=7

    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File

    Verify Pm Counters With Varius Value
    ...    counter_id_list=@{COUNTER_IDS_UE_PCELL_CONF_SCELL_DL_SA}
    ...    counter_name_list=@{COUNTER_NAMES_UE_PCELL_CONF_SCELL_DL_SA}
    ...    local_moid=${LOCAL_MOID_PCELL}
    ...    pm_counter_file=${pm_counter_file}
    ...    condition=@{EXPECTED_VALUES_UE_PCELL_CONF_SCELL_DL_SA}

    Verify Pm Counters With Varius Value
    ...    counter_id_list=@{COUNTER_IDS_GNB_SCELL_ADMI_REQ_SA}
    ...    counter_name_list=@{COUNTER_NAMES_GNB_SCELL_ADMI_REQ_SA}
    ...    local_moid=${LOCAL_MOID_PCELL}
    ...    pm_counter_file=${pm_counter_file}
    ...    condition=@{EXPECTED_VALUES_GNB_SCELL_ADMI_REQ_SA}

    Verify Pm Counters With Varius Value
    ...    counter_id_list=@{COUNTER_IDS_GNB_SCELL_ADMI_SUCC_SA}
    ...    counter_name_list=@{COUNTER_NAMES_GNB_SCELL_ADMI_SUCC_SA}
    ...    local_moid=${LOCAL_MOID_PCELL}
    ...    pm_counter_file=${pm_counter_file}
    ...    condition=@{EXPECTED_VALUES_GNB_SCELL_ADMI_SUCC_SA}

*** Keywords ***
Attach UE And Expect Establish CA
    [Arguments]    ${ue_id}    ${gnb_id}    ${cell_id}    ${cc_nr_cell_identitiy}    ${cc_scell_physcell_id}    ${num_of_reportConfigId}
    Expect SCell ToBeSetupMod And ToAddModList    ue_id=${ue_id}    gnb_id=${gnb_id}
    Attach UE And Expect Establishing PDU Session   ue_id=${ue_id}    cell_id=${cell_id}
    ...    gnb_id=${gnb_id}   pdu_id=${PDU_ID}    gw_id=${GW_ID}
    Verify SCell Addition Messages For CC    ue_id=${ue_id}    cc_nr_cell_identitiy=@{cc_nr_cell_identitiy}
    ...    cc_scell_physcell_id=@{cc_scell_physcell_id}      num_of_reportConfigId=${num_of_reportConfigId}
    Start Specific Data DL Traffic In Kbps    ue_id=${ue_id}    pdu_id=${PDU_ID}    kbps_per_trf_id=1    first_trf_id=1    last_trf_id=3

Verify Scell Addition Messages For 5CC Instead Of 6CC
    [Arguments]    ${ue_id}    ${cc_nr_cell_identitiy}    ${cc_scell_physcell_id}    ${num_of_reportConfigId}
    Verify SCell Addition Messages For CC    ue_id=${ue_id}    cc_nr_cell_identitiy=@{cc_nr_cell_identitiy}
    ...    cc_scell_physcell_id=@{cc_scell_physcell_id}    num_of_reportConfigId=${num_of_reportConfigId}

Remove And Replace File
    [Arguments]    ${new_file}    ${target_path}
    Log  \n==== Replace file to solve the problem with dissecting nr-rrc packets with ute-wireshark 4.4.7 ====  console=True
    # Ensure the new file exists
    File Should Exist    ${new_file}

    # Remove the target file if it exists
    Run Keyword And Ignore Error    Remove File    ${target_path}

    # Copy the new file to the target location
    Copy File    ${new_file}    ${target_path}
