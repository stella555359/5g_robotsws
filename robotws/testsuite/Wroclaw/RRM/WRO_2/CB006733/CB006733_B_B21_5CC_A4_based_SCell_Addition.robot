*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_LPQ_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia
...              :authors: Marcin Holowinski
...              :contact: Marcin.Holowinski@nokia.com


Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     taf/ul/ettf/main.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/traffic.robot
Resource     ../keywords/L3_Call.robot
Resource    ../keywords/tshark_verifying.robot
Resource     ./verify_ta_messaging/verify_PrivateMessage.robot
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
...            AND             Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_xml_CB006733_BB8.xml
...            AND             With Gnb Configuration    commissioning=${scfc}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             With Simulator Configuration    config=${BASIC_SETUP}
...            AND             Wait For Next Full Pm Interval
...            AND             Create SA Aliases    ue_id=${UE_ID}    gNB_id=2

Test Setup

Test Teardown    Run Keywords    Stop Capturing    alias=${UU_ALIAS}
...              AND    Teardown Tshark    alias=${UU_ALIAS}


*** Variables ***
${LOGS_COMPRESSION}=  ${True}
${LOGGING_POLICY}=    FULL_POLICY
${BASIC_SETUP}=       ${CURDIR}/config/wts_6733_B_B21.cfg
${scfc}=              full_scfc_CB006733_B_B21.xml
${LOCAL_MOID}=    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
${UE_ID}=    3
${SOURCE_CELL_ID}=    3
${GNB_ID}=    2
${capabilityRequestFilter_hex_n25_n66_n71_n41_n77_n38}=    '0x802C0188083011A014404C804A'
${A4_add}=        (nr-rrc.criticalExtensions == 0) && (nr-rrc.measIdToAddModList == 2) && (nr-rrc.gapUE == 1)
${A4_remove}=     (nr-rrc.criticalExtensions == 0) && (nr-rrc.measIdToRemoveList == 2) && (nr-rrc.gapUE == 0)
${REMOVE_MEAS_ID_AND_MEAS_GAP_BEFORE_SCELL_ADDITION}=    (nr-rrc.measIdToRemoveList == 4) && (nr-rrc.gapUE == 0)
${4_SCELL_ADD}=    nr-rrc.eventId == 1 && nr-rrc.sCellToAddModList == 4
${PCI_OF_4_Scell_ADD}=    nr-rrc.physCellId == 51 && nr-rrc.physCellId == 54 && nr-rrc.physCellId == 55 && nr-rrc.physCellId == 56

*** Test Cases ***
CB006733-B_B21_5CC_A4-based_SCell_Addition
    ${UU_ALIAS}=    Start Tshark For Uu Interface    capture_filter=less 1400
    Expect A4 Meas Configuration After UE Attach    alias=attach_UE${UE_ID}
    Attach UE And Establish PDU Session    ue_id=${UE_ID}    cell_id=${SOURCE_CELL_ID}    enb_id=2   pdu_id=3    gw_id=3
    Trigger A4 Measurement For 4 Scell Candidates
    Trigger Scell Addition By High Data Traffic    ue_id=${UE_ID}
    Deregister UE    ue_id=${UE_ID}
    Verify Flow Of A4 Configurations And Downlink Buffer Status Private Messages And Scell Addition    uu_alias=${UU_ALIAS}
    Verify Pm Counter For 5CC Configuration    local_moid=${LOCAL_MOID}

*** Keywords ***
Trigger Scell Addition By High Data Traffic
    [Arguments]    ${ue_id}
    Start Data Traffic    ue_id=${UE_ID}
    Sleep    10    Time For Scell Addition

Trigger A4 Measurement For 4 Scell Candidates
    Trigger A4 Measurement    ue_id=${UE_ID}     meas_id=1    phycell_id=51
    Trigger A4 Measurement    ue_id=${UE_ID}     meas_id=2    phycell_id=54
    Trigger A4 Measurement    ue_id=${UE_ID}     meas_id=3    phycell_id=55
    Trigger A4 Measurement    ue_id=${UE_ID}     meas_id=4    phycell_id=56

Expect A4 Meas Configuration After UE Attach
    [Arguments]    ${alias}=attach_UE${UE_ID}
    ${A4_AND_MEAS_GAP_CONFIG} =    Catenate
    ...    (measObjectToAddModList is present) and (length(measObjectToAddModList) eq 4) and
    ...    (reportConfigToAddModList is present) and (length(reportConfigToAddModList) eq 1) and (eventId contains (eventA4 is present)) and
    ...    (measIdToAddModList is present) and (length(measIdToAddModList) eq 4) and
    ...    (measGapConfig is present) and (gapUE contains (setup is present))
    Expect Message Flow
    ...    UE${UE_ID}:NR-RRC_RRCReconfiguration
    ...    UE${UE_ID}:NR-RRC_RRCReconfigurationComplete
    ...    UE${UE_ID}:NR-RRC_RRCReconfiguration (${A4_AND_MEAS_GAP_CONFIG})
    ...    UE${UE_ID}:NR-RRC_RRCReconfigurationComplete
    ...    alias=${alias}   overall_timeout=20
    Set 5 expected PrivateMessages for A4 Measurement Trigger for UE3 and gNB2

Trigger A4 Measurement
    [Arguments]    ${ue_id}    ${meas_id}    ${phycell_id}
     Execute Egate Command    cmd=ue_measurement_send_nr event=A4 phycell_id\=${phycell_id} nrsrp_nr=95 id\=${ue_id} meas_id\=${meas_id}
     Sleep    1    Stability and simplyfication of manual logs analysis

Verify Flow Of A4 Configurations And Downlink Buffer Status Private Messages And Scell Addition
    [Arguments]    ${uu_alias}
    Flow occurred as expected    alias=attach_UE${UE_ID}
    Verify that PrivateMessage_1 of 5 is BufferMonitoringNotification for gNB2
    Verify that PrivateMessage_2 of 5 is BufferMonitoringNotification for gNB2
    Verify that PrivateMessage_3 of 5 is BufferMonitoringNotification for gNB2
    Verify that PrivateMessage_4 of 5 is BufferMonitoringNotification for gNB2
    Verify that PrivateMessage_5 of 5 is BufferCriterionNotification for gNB2
    Verify Tshark For Single Message    alias=${uu_alias}
    ...   packet_filter=${REMOVE_MEAS_ID_AND_MEAS_GAP_BEFORE_SCELL_ADDITION}
    Verify Tshark For Single Message    alias=${uu_alias}
    ...   packet_filter=${4_SCELL_ADD} && ${PCI_OF_4_Scell_ADD}

Verify Pm Counter For 5CC Configuration
    [Arguments]    ${local_moid}
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Any Counters In File
        ...    M55118C00031    +4    A4_SCELL_ADDED_SA
        ...    local_moid=${local_moid}
        ...    file_path=${pm_counter_file}
    Verify Any Counters In File
        ...    M55118C00030    >0    A4_MEASUR_ACT_SCELL_ADD_SA
        ...    local_moid=${local_moid}
        ...    file_path=${pm_counter_file}

Deregister UE
    [Arguments]    ${ue_id}
    Execute Egate Command    cmd=ue_deregister id=${ue_id} ue_deregister_type=switch_off


