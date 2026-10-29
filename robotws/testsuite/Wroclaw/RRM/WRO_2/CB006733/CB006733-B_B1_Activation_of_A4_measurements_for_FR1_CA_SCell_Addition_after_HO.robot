*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia
...              :authors: Blanka Gozdek (B_B1), Lukasz Klimowicz (C_B28)
...              :contact: blanka.gozdek@nokia.com, lukasz.klimowicz@nokia.com


Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/traffic.robot
Resource     ../keywords/L3_Call.robot
Resource    ../keywords/tshark_verifying.robot
Resource     ./verify_ta_messaging/verify_UEContextModification.robot
Resource     ta_messaging/flow.robot
Resource     Keywords_CB006733.robot
Library      ta5g_tshark
Library      ta_messaging
Library      taf.ul.ettf.retry_context
Library      taf.ul.ettf.setups
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_pm_counters
Variables    CB006733_messaging_filters.py
Variables    logging_policy.py
Library      ./verify_ta_messaging/CB006733.py

Suite Setup    Run Keywords    Log to console    Full scfc commissioning with iphy.xml upload
...            AND             Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_xml_6733.xml
...            AND             With Gnb Configuration    commissioning=${scfc}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             With Simulator Configuration    config=${BASIC_SETUP}
...            AND             Wait For Next Full Pm Interval


*** Variables ***
${LOGS_COMPRESSION}=    ${True}
${LOGGING_POLICY}=    FULL_POLICY
${BASIC_SETUP}=       ${CURDIR}/config/wts_6733_basic.cfg
${scfc}=              full_scfc_CB006733_B_B1.xml
${GNB_ID}=            2
${PCELL_ID}=          4  #Cell 4
${PHYSCELL_ID}=       54  #Cell 4
${TARGET_PHYSCELL_ID}=    51  #Cell 1
${UE_ID}=             4
${PDU_4}=             4
${GW_ID_4}=           4
${COUNTER_ID}=    M55118C00030
${COUNTER_NAME}=    A4_MEASUR_ACT_SCELL_ADD_SA
${LOCAL_MOID}=    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
${supervision_timer_fr1} =    9
${a4_retry_timer} =    1
${nrsrp_nr} =          100
${COUNTER_ID_CA-INCOMPATIBLE_DRB_ADDED}=    M55125C00040
${COUNTER_NAME_CA-INCOMPATIBLE_DRB_ADDED}=    SCELL_ADDN_PREVENT_DRB_PRFL_CA

*** Test Cases ***
CB006733-B_B1_HO_Activate_A4_measurements_for_FR1_CA_SCell_Addition_after_intra-gNB_intra-DU_Handover__excluding_intra-DU_intra-Cell_handover
    Attach UE And Verify Establishing PDU Session With Following A2 Measurement Trigger For HO    ue_id=${UE_ID}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}    pdu_id=${PDU_4}    gw_id=${GW_ID_4}    supervision_timer=${supervision_timer_fr1}

    Verify A2 Measurement Configuration Before HO    ue_id=${UE_ID}
    Verify If UE4 Measurement Report For HO Is Expected A2 Measurement
    Verify If UE4 RRCReconfiguration 2 Of 2 Contains A2 Deconfiguration And A1 A3 A5 Configuration Before HO

    Perform HO To Target Cell For UE    ue_id=${UE_ID}    gnb_id=${GNB_ID}    phycell_id=${TARGET_PHYSCELL_ID}    nrsrp_nr=${nrsrp_nr}

    Verify If UE4 Measurement Report For HO Is Expected A3 Measurement
    Verify If UE4 RRCReconfiguration 1 Of 2 Contains A2 A3 A5 Deconfiguration And MeasGapConfig Release After HO
    Verify if UE4 RRCReconfiguration 2 of 2 contains A4 configuration after HO
    Verify that UEContextModificationRequest_3 of 4 contains measConfig with A4 configuration after HO for gNB2
    Verify that UEContextModificationResponse_3 of 4 contains measGapConfig for gNB2
    Verify Pm Counters 6733    ue_id=${UE_ID}    counter_id=${COUNTER_ID}    counter_name=${COUNTER_NAME}    local_moid=${LOCAL_MOID}
    [Teardown]    Release UE    ue_id=${UE_ID}    pdu_id=${PDU_4}

CB006733-C_B28_HO_RRC_Re-estab_RRC_Resume_CB009059_interaction_-_No_A4_measurements_activation_if_no_CA_eligible_DRB_or_CA_incompatible_DRB_is_setup
    Activate Feature CB009059 With FR1 CA Incompatible DRB    delta_scfc=delta_9059_activation_with_FR1_CA_incompatible_DRB.json
    Wait For Next Full Pm Interval
    Attach UE And Verify Establishing PDU Session With Following A2 Measurement Trigger For HO    ue_id=${UE_ID}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}    pdu_id=${PDU_4}    gw_id=${GW_ID_4}    supervision_timer=${supervision_timer_fr1}
    Verify ICS Configured FiveQI And PDU Session    ue_id=${UE_ID}
    Verify A2 Measurement Configuration Before HO    ue_id=${UE_ID}
    Verify If UE4 Measurement Report For HO Is Expected A2 Measurement
    Verify If UE4 RRCReconfiguration 2 Of 2 Contains A2 Deconfiguration And A1 A3 A5 Configuration Before HO

    Set 2 Expected RRC Reconfiguration Req And Comp Messages For Unwanted UE4 A4 Meas Configuration And 20s Timeout
    Perform HO To Target Cell For UE    ue_id=${UE_ID}    gnb_id=${GNB_ID}    phycell_id=${TARGET_PHYSCELL_ID}    nrsrp_nr=${nrsrp_nr}
    ...    expected_A4_configuration=${FALSE}
    Verify That Occured Less Than 2 RRC Reconfiguration Request And Complete After HO For UE4 And 20s Timeout

    Verify If UE4 Measurement Report For HO Is Expected A3 Measurement
    Verify That UEContextModificationRequest_1 Of 2 Contains MeasConfig With A1 A3 A5 Removal After HO For gNB2
    Verify That UEContextModificationResponse_1 Of 2 Contains ReconfWithSync To ID 51 Cell For GNB2
    Verify If UE4 RRCReconfiguration 1 Of 1 Contains A2 A3 A5 Deconfiguration And MeasGapConfig Release After HO
    Verify If UE4 RRCReconfiguration 1 of 1 Contains ReconfigurationWithSync To ID 51 Cell

    Verify Pm Counters 6733    ue_id=${UE_ID}    counter_id=${COUNTER_ID_CA-INCOMPATIBLE_DRB_ADDED}
    ...    counter_name=${COUNTER_NAME_CA-INCOMPATIBLE_DRB_ADDED}    local_moid=${LOCAL_MOID}    condition=1

    [Teardown]    Run Keywords    Release UE    ue_id=${UE_ID}    pdu_id=${PDU_4}
        ...            AND        Apply Rollback Delta Configuration    rollback_delta_scfc=delta_rollback_9059_activation.json
