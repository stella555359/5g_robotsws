*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia
...              :authors: Lukasz Klimowicz
...              :contact: lukasz.klimowicz@nokia.com


Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/traffic.robot
Resource     ../keywords/L3_Call.robot
Resource    ../keywords/tshark_verifying.robot
Resource     ./verify_ta_messaging/verify_UEContextModification.robot
Resource     ./verify_ta_messaging/verify_PrivateMessage.robot
Resource     ta_messaging/flow.robot
Resource     Keywords_CB006733.robot
Library      ta5g_tshark
Library      ta_messaging
Library      taf.ul.ettf.retry_context
Library      taf.ul.ettf.setups
Library      ta5g_testline_management
Library      ta5g_delta
Library      ta5g_iphy
Library      ta5g_pm_counters
Library      DateTime
Variables    CB006733_messaging_filters.py
Variables    logging_policy.py
Library      ./verify_ta_messaging/CB006733.py

Suite Setup    Run Keywords    Log to console    Full scfc commissioning with iphy.xml upload
...            AND             Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_xml_6733_B_B13.xml
...            AND             With Gnb Configuration    commissioning=${scfc}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             With Simulator Configuration    config=${BASIC_SETUP}
...            AND             Wait For Next Full Pm Interval


*** Variables ***
${LOGS_COMPRESSION}=    ${True}
${LOGGING_POLICY}=    FULL_POLICY
${BASIC_SETUP}=       ${CURDIR}/config/wts_6733_BB13.cfg
${scfc}=              scfc_CB006733_B_B13.xml
${GNB_ID}=            2
${PCELL_ID}=          4  #Cell 4
${PHYSCELL_ID}=       54  #Cell 4
${UE_ID}=             4
${PDU_4}=             4
${GW_ID_4}=           4
@{COUNTER_IDs}=    M55118C00030    M55118C10501    M55118C10502
@{COUNTER_NAMEs}=    A4_MEASUR_ACT_SCELL_ADD_SA    SCELL_SWAP_1_ATT_SA    SCELL_SWAP_1_SUCC_SA
${LOCAL_MOID}=    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4
@{cells_after_PSCell_change} =    0    2

*** Test Cases ***
CB006733-B_B13_CB008290_interaction_prefer_SCell_Candidate_with_better_radio_conditions_during_FR1_CA_SCell_Addition
    Attach UE And Verify Establishing PDU Session With following A4 Measurement Trigger    ue_id=${UE_ID}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}    pdu_id=${PDU_4}    gw_id=${GW_ID_4}

    Set Message Flow Expectations for BB13 UE Buffer Trigger And SCell Addition    ue_id=${UE_ID}    gnb_id=${GNB_ID}
    Start High DL non-GBR Data Traffic    ue_id=${UE_ID}   pdu_id=${PDU_4}    trf_level=130
    Check Message Flow Expectations for BB13 UE Buffer Trigger And SCell Addition    ue_id=${UE_ID}    gnb_id=${GNB_ID}

    Wait For Traffic to stabilize    inactive_timer=4
    Verify That Throughput Is Reached On All SCells    ue_id=${UE_ID}    num_of_scells=1    expected_throughput=5Mbps
    Stop Data Traffic    ue_id=${UE_ID}   pdu_id=${PDU_4}

    Verify if BB13 UE${UE_ID} RRCReconfiguration 1 of 2 contains A4 measurements deconfiguration and measConfig release
    Verify that PrivateMessage_1 of 1 is BufferCriterionNotification for gNB${GNB_ID}
    Verify that UEContextModificationRequest_3 of 5 contains Scell Addition Cells for gNB${GNB_ID}
    Verify that UEContextModificationResponse_3 of 5 contains Scell Addition Cells for gNB${GNB_ID}
    Verify if UE${UE_ID} RRCReconfiguration 2 of 2 contains A2 Scell Release A6 SCell swap and SCell configuration

    Set Message Flow Expectations for BB13 SCell Swap    ue_id=${UE_ID}    gnb_id=${GNB_ID}
    Trigger A6 Measurement For SCell Swap
    ...    ue_id=${ue_id}     meas_id=7    srsrp_nr=70    scell_id=1   scell_rsrp=20
    ...    phycell_id_target=52     nrsrp_nr_target=95
    Check Message Flow Expectations for BB13 SCell Swap   ue_id=${UE_ID}    gnb_id=${GNB_ID}

    Verify if UE${UE_ID} Measurement Report is expected A6 measurement for BB13
    Verify that UEContextModificationRequest_1 of 3 contains Scell Swap Messages for gNB${GNB_ID}
    Verify that UEContextModificationResponse_1 of 3 contains Scell Swap Messages for gNB${GNB_ID}
    Verify if UE${UE_ID} RRCReconfiguration 1 of 1 contains Scell Swap Messages

    Start High DL non-GBR Data Traffic    ue_id=${UE_ID}   pdu_id=${PDU_4}    trf_level=130    trf_id_1=4    trf_id_2=5    trf_id_3=6
    Wait For Traffic to stabilize    inactive_timer=4
    Verify That Throughput Is Reached On Specific Cells    ue_id=${UE_ID}    cells_list=${cells_after_PSCell_change}    expected_throughput=10Mbps
    Stop Data Traffic    ue_id=${UE_ID}   pdu_id=${PDU_4}
    Verify Pm Counters BB13    ue_id=${UE_ID}    counter_id_list=${COUNTER_IDs}    counter_name_list=${COUNTER_NAMEs}
    ...    local_moid=${LOCAL_MOID}    condition=1
    [Teardown]    Release UE    ue_id=${UE_ID}    pdu_id=${PDU_4}
