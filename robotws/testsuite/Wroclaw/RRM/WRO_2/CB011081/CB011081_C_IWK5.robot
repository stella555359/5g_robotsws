*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia
...              :authors: Kamil Dabkowski
...              :contact: kamil.dabkowski@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/traffic.robot
Resource     ../keywords/L3_Call.robot
Resource     ../keywords/ue_measurements.robot
Resource     Keywords_CB011081.robot
Resource     CB011081_C_IWK5_variables.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Library      ta5g_enb
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
...            AND             Backup And Modify Swconfig File    parameters_list=@{SWCONFIG_FLAGS_LIST}
...            AND             Log to console    Full scfc commissioning with iphy.xml upload
...            AND             Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_booloo_iwk5.xml
...            AND             With Gnb Configuration    commissioning=full_scf_CB011081_IWK5.xml
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             Check Radios Availability
...            AND             Create GNB Alias   gNB_id=${GNB_ID}
...            AND             Create UE Alias    alias=UE3    ue_id=3    id_type=wts_5g
...            AND             Create UE Alias    alias=UE30    ue_id=30    id_type=wts_5g
...            AND             Create UE Alias    alias=UE31    ue_id=31    id_type=wts_5g
...            AND             With Simulator Configuration    config=${CURDIR}/config/wts_booloo_iwk5.cfg
...            AND             Wait For Next Full Pm Interval

*** Test Cases ***
USCB011081-CIWK5_FDD_PCell_6CC_DL_CA_interworking_with_three_dedicated_BWPs
    Expect SCell ToBeSetupMod And ToAddModList    ue_id=${UE1_ID}    gnb_id=${GNB_ID}
    Attach UE And Expect Establishing PDU Session   ue_id=${UE1_ID}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}   pdu_id=${PDU1_ID}    gw_id=${GW_ID}
    Verify SCell Addition Messages For CC    ue_id=${UE1_ID}    cc_nr_cell_identitiy=@{6CC_NR_CELL_IDENTITIY}
    ...    cc_scell_physcell_id=@{6CC_SCELL_PHYSCELL_ID}      num_of_reportConfigId=8
    Verify BWPs for UE    ${UE1_ID}    ${UE1_carrierBandwidth_values}    ${UE1_locationAndBandwidth_values}
    Start Specific Data DL Traffic    ue_id=${UE1_ID}    pdu_id=${PDU1_ID}    mbps_per_trf_id=30    first_trf_id=1    last_trf_id=5

    Expect SCell ToBeSetupMod And ToAddModList    ue_id=${UE2_ID}    gnb_id=${GNB_ID}
    Attach UE And Expect Establishing PDU Session   ue_id=${UE2_ID}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}   pdu_id=${PDU2_ID}    gw_id=${GW_ID}
    Verify SCell Addition Messages For CC    ue_id=${UE2_ID}    cc_nr_cell_identitiy=@{6CC_NR_CELL_IDENTITIY}
    ...    cc_scell_physcell_id=@{6CC_SCELL_PHYSCELL_ID}      num_of_reportConfigId=8
    Verify BWPs for UE    ${UE2_ID}    ${UE2_carrierBandwidth_values}    ${UE2_locationAndBandwidth_values}
    Start Specific Data DL Traffic    ue_id=${UE2_ID}    pdu_id=${PDU2_ID}    mbps_per_trf_id=30    first_trf_id=1    last_trf_id=5

    Expect SCell ToBeSetupMod And ToAddModList    ue_id=${UE3_ID}    gnb_id=${GNB_ID}
    Attach UE And Expect Establishing PDU Session   ue_id=${UE3_ID}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}   pdu_id=${PDU3_ID}    gw_id=${GW_ID}
    Verify SCell Addition Messages For CC    ue_id=${UE3_ID}    cc_nr_cell_identitiy=@{6CC_NR_CELL_IDENTITIY}
    ...    cc_scell_physcell_id=@{6CC_SCELL_PHYSCELL_ID}      num_of_reportConfigId=8
    Verify BWPs for UE    ${UE3_ID}    ${UE3_carrierBandwidth_values}    ${UE3_locationAndBandwidth_values}
    Start Specific Data DL Traffic    ue_id=${UE3_ID}    pdu_id=${PDU3_ID}    mbps_per_trf_id=30    first_trf_id=1    last_trf_id=5

    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Pm Counters    counter_id_list=${COUNTER_IDs_PCELL}    counter_name_list=${COUNTER_NAMEs_PCELL}
    ...    local_moid=${LOCAL_MOID_PCELL}    pm_counter_file=${pm_counter_file}    condition=3

   FOR    ${CURRENT_MOID}    IN    @{SCELLs_DL_MOID}
       Verify Pm Counters    counter_id_list=${BWP3_COUNTER_ID_FOR_SCELLs}    counter_name_list=${BWP3_COUNTER_NAME_FOR_SCELLs}
   ...    local_moid=${CURRENT_MOID}    pm_counter_file=${pm_counter_file}    condition=1
       Verify Pm Counters    counter_id_list=${BWP2_COUNTER_ID_FOR_SCELLs}    counter_name_list=${BWP2_COUNTER_NAME_FOR_SCELLs}
   ...    local_moid=${CURRENT_MOID}    pm_counter_file=${pm_counter_file}    condition=1
       Verify Pm Counters    counter_id_list=${BWP1_COUNTER_ID_FOR_SCELLs}    counter_name_list=${BWP1_COUNTER_NAME_FOR_SCELLs}
   ...    local_moid=${CURRENT_MOID}    pm_counter_file=${pm_counter_file}    condition=1
   END

   Release UE    ue_id=${UE1_ID}    pdu_id=${PDU1_ID}
   Release UE    ue_id=${UE2_ID}    pdu_id=${PDU2_ID}
   Release UE    ue_id=${UE3_ID}    pdu_id=${PDU3_ID}

   [Teardown]    Add Scout Data Info To Testcase


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
