*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
...    CLOUD_5G_I_LPQ_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD


Documentation    :copyright: Nokia
...              :authors: Kamil Dabkowski
...              :contact: kamil.dabkowski@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/L3_Call.robot
Resource     ../keywords/ue_measurements.robot
Resource     ../CB009854/CB009854_keywords.robot
Resource     Keywords_CB011081.robot
Resource     CB011081_AB16_variables.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Library      ta_messaging
Library      taf.ul.ettf.setups
Library      ta5g_testline_management
Library      ta5g_egate
Library      ta5g_iphy
Library      ta5g_pm_counters
Library      ta5g_ue_mobility
Variables    ../CB009854/CB009854_messaging_filters.py
Variables    CB011081_messaging_filters.py
Variables    logging_policy.py


Suite Setup    Run Keywords    Remove And Replace File    new_file=${new_file}    target_path=${target_path}
...            AND             Log to console    Full scfc commissioning with iphy.xml upload
...            AND             Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_lpq.xml
...            AND             With Gnb Configuration    commissioning=full_scf_CB011081_AB16.xml
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Check Radios Availability
...            AND             Create GNB Alias   gNB_id=${GNB_ID}
...            AND             Create UE Alias    alias=UE3    ue_id=3    id_type=wts_5g
...            AND             With Simulator Configuration    config=${CURDIR}/config/wts_lpq_AB16.cfg
...            AND             Wait For Next Full Pm Interval

*** Test Cases ***
CB011081-AB16_Single_UE_full_mobility_support_for_UE_on_FDD_PCell_which_has_TDD_FR1_and_FDD_SCells_configured_for_SA_call_outgoing_UE
    Expect SCell ToBeSetupMod And ToAddModList    ue_id=${UE_ID}    gnb_id=${GNB_ID}
    Attach UE And Expect Establishing PDU Session   ue_id=${UE_ID}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}   pdu_id=${PDU_PCELL_1}    gw_id=${GW_ID}
    Verify SCell Addition Messages For CC    ue_id=${UE_ID}    cc_nr_cell_identitiy=@{6CC_NR_CELL_IDENTITIY}
    ...    cc_scell_physcell_id=@{6CC_SCELL_PHYSCELL_ID}      num_of_reportConfigId=8
    Verify Measurements Are Configured At UE    ue_id=${UE_ID}    event_type=${EVENT_TYPE_A2}
    ...    event_params=${A2_RSRP_34}    frequencies=${FREQUENCIES_A2}
    Trigger A2 Measurement For Measurements Reconfiguration
    ...    ue_id=${UE_ID}    overall_timeout=${OVERALL_TIMEOUT}
    Verify 6CC FFFTTT Measurement Configuration and Meas Gap Setup After A2    ue_id=${UE_ID}
    Trigger A3 Measurement For Intra-gNB Intra-DU Inter Frequency HO
    ...    meas_id=${A3_MEAS_ID}    ue_id=${UE_ID}    gNB_id=${GNB_ID}    overall_timeout=${OVERALL_TIMEOUT}
    Verify Meas Gap Release    ue_id=${UE_ID}
    Verify 6CC SCells Release and Handover Preparation    ue_id=${UE_ID}
#    Verify Handover Performance From Cell3 to Cell1    ue_id=${UE_ID}
    Verify SCell Addition Messages For CC After HO
    ...    ${UE_ID}    ${6CC_NR_CELL_IDENTITIY_AFTER_HO}    ${6CC_SCELL_PHYSCELL_ID_AFTER_HO}

    Verify Counters for AB16
    Keywords_CB011081.Release UE    ue_id=${UE_ID}    pdu_id=${PDU_PCELL_1}

    [Teardown]    Add Scout Data Info To Testcase

*** Keywords ***
Verify Counters for AB16
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Pm Counters    counter_id_list=${COUNTER_IDs_PCELL}    counter_name_list=${COUNTER_NAMEs_PCELL}
    ...    local_moid=${LOCAL_MOID_PCELL}    pm_counter_file=${pm_counter_file}    condition=1
    FOR    ${CURRENT_MOID}    IN    @{SOURCE_AND_TARGET_PCELLS_MOID}
        Verify Pm Counters    counter_id_list=${SAMPLE_COUNTERS_ID}    counter_name_list=${SAMPLE_COUNTERS_NAME}
    ...    local_moid=${CURRENT_MOID}    pm_counter_file=${pm_counter_file}    condition=>0
    END
    Verify Pm Counters    counter_id_list=${SAMPLE_COUNTERS_DL_ID}    counter_name_list=${SAMPLE_COUNTERS_DL_NAME}
    ...    local_moid=${CURRENT_MOID}    pm_counter_file=${pm_counter_file}    condition=>0
    Verify Pm Counters    counter_id_list=${SAMPLE_COUNTERS_UL_ID}    counter_name_list=${SAMPLE_COUNTERS_UL_NAME}
    ...    local_moid=${LOCAL_MOID_SCELL_7}    pm_counter_file=${pm_counter_file}    condition=>0

Remove And Replace File
    [Arguments]    ${new_file}    ${target_path}
    Log  \n==== Replace file to solve the problem with dissecting nr-rrc packets with ute-wireshark 4.4.7 ====  console=True
    # Ensure the new file exists
    File Should Exist    ${new_file}

    # Remove the target file if it exists
    Run Keyword And Ignore Error    Remove File    ${target_path}

    # Copy the new file to the target location
    Copy File    ${new_file}    ${target_path}
