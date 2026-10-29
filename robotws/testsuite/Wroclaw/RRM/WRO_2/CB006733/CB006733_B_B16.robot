*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia
...              :authors: Marek Kocela
...              :contact: marek.kocela@nokia.com


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
Library      ta5g_iphy
Library      ta5g_egate
Library      ta5g_pm_counters
Variables    CB006733_messaging_filters.py
Variables    logging_policy.py
Library      ./verify_ta_messaging/CB006733.py

Suite Setup    Run Keywords    Log to console    Full scfc commissioning with iphy.xml upload
...            AND             Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_xml_6733_b_b11.xml
...            AND             With Gnb Configuration    commissioning=${scfc}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             With Simulator Configuration    config=${BASIC_SETUP}
...            AND             Create SA Aliases    ue_id=${UE_ID}    gNB_id=${GNB_ID}

*** Variables ***
${LOGS_COMPRESSION}=  ${True}
${LOGGING_POLICY}=    NO_TRAFFIC_LOGS_POLICY
${BASIC_SETUP}=       ${CURDIR}/config/wts_6733_basic.cfg
${scfc}=              full_scfc_CB006733_B_B16.xml

${UE_ID}=    4
${SOURCE_CELL_ID}=    4
${GNB_ID}=    2
${PDU_ID}=    3
${GW_ID}=    3

${nRCellIdentity_1}=    '0b000000000000000000000100000000000001'
${nRCellIdentity_2}=    '0b000000000000000000000100000000000010'
${scell_physcellid_1}=    51
${scell_physcellid_2}=    52

@{COUNTER_IDs}=    M55118C00030    M55118C00031    M55118C00032
@{COUNTER_NAMEs}=    A4_MEASUR_ACT_SCELL_ADD_SA    A4_SCELL_ADDED_SA    A1_SCELL_ADDED_SA
${LOCAL_MOID}=          PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4

*** Test Cases ***
CB006733-B_B16_Mixing_A1-based_and_A4-based_SCell_Candidates_for_FR1_CA_SCell_Addition
    Set Message Flow Expectations Private Messages And SCell Addition   ue_id=${UE_ID}    gnb_id=${GNB_ID}
    Attach UE And Establish PDU Session    ue_id=${UE_ID}    cell_id=${SOURCE_CELL_ID}    enb_id=2    pdu_id=${PDU_ID}    gw_id=${GW_ID}
    Trigger A1 And A4 Measurements For Two Different SCells    ue_id=${UE_ID}
    Start 400 MBPS Data DL Traffic    ue_id=${UE_ID}   pdu_id=${PDU_ID}
    Verify that all 3 expected PrivateMessages occured UE gNB2 and 15 s timeout
    Stop All Data Traffics    ue_id=${UE_ID}
    Release UE    ue_id=${UE_ID}    pdu_id=${PDU_ID}
    Verify that PrivateMessage_1 of 3 is BufferMonitoringNotification for gNB2
    Verify that PrivateMessage_2 of 3 is BufferMonitoringNotification for gNB2
    Verify that PrivateMessage_3 of 3 is BufferCriterionNotification for gNB2
    Verify SCell Addition Messages For Two Different SCells    ue_id=${UE_ID}    nRCellIdentity_1=${nRCellIdentity_1}
    ...    nRCellIdentity_2=${nRCellIdentity_2}    scell_physcellid_1=${scell_physcellid_1}    scell_physcellid_2=${scell_physcellid_2}
    Verify Pm Counters BB13    ue_id=${UE_ID}    counter_id_list=${COUNTER_IDs}    counter_name_list=${COUNTER_NAMEs}
    ...    local_moid=${LOCAL_MOID}    condition=1

