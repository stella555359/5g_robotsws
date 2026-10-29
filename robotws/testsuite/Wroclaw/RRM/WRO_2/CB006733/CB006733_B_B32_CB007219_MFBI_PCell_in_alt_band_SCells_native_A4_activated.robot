*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia
...              :authors: Marek Kocela
...              :contact: marek.kocela@nokia.com


Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     taf/ul/ettf/main.robot
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
...            AND             Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_xml_6733_b_b11.xml
...            AND             With Gnb Configuration    commissioning=${scfc}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             With Simulator Configuration    config=${BASIC_SETUP}
...            AND             Activate feature CB007219 actMfbiNrCaSupportFr1
...            AND             Wait For Next Full Pm Interval
...            AND             Create SA Aliases    ue_id=${UE_ID}    gNB_id=2

Test Teardown    Execute Egate Command    cmd=ue_deregister id=${UE_ID} ue_deregister_type=switch_off

*** Variables ***
${LOGS_COMPRESSION}=  ${True}
${LOGGING_POLICY}=    NO_TRAFFIC_LOGS_POLICY
${BASIC_SETUP}=       ${CURDIR}/config/wts_6733_b_b11.cfg
${scfc}=              full_scfc_CB006733_B_B11.xml
${LOCAL_MOID}=    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4
${UE_ID}=    4
${SOURCE_CELL_ID}=    4
${GNB_ID}=    2
${PDU_ID}=    1
${GW_ID}=    1
${capabilityRequestFilter_hex_n25_n66_n71_n41_n77_n38}=    '0x802C0188083011A014404C804A'
${A4_add}=        (nr-rrc.criticalExtensions == 0) && (nr-rrc.measIdToAddModList == 2) && (nr-rrc.gapUE == 1)
${A4_remove}=     (nr-rrc.criticalExtensions == 0) && (nr-rrc.measIdToRemoveList == 2) && (nr-rrc.gapUE == 0)

*** Test Cases ***
CB006733_B_B32_CB007219_MFBI_PCell_in_alt_band_SCells_native_A4_activated
    Expect A4 Meas Configuration After UE Attach    alias=attach_UE${UE_ID}
    Attach UE And Establish PDU Session    ue_id=${UE_ID}    cell_id=4    enb_id=2   pdu_id=3    gw_id=3
    Flow occurred as expected    alias=attach_UE${UE_ID}
    Check Number Of A4 Reconfigurations
    Verify Pm Counter For Number Of A4 Measurements Activations    local_moid=${LOCAL_MOID}

*** Keywords ***
Check Number Of A4 Reconfigurations
    [Arguments]    ${amount_of_a4_reconf}=32   ${allowed_diff}=5
    ${UU_ALIAS}=    Start Tshark For Uu Interface
    Sleep    60    Time to gather info about A4 measurement configuraiton and deconfiguration
    Stop Capturing    alias=${UU_ALIAS}
    ${count_a4_add}    Get Packets Count   alias=${UU_ALIAS}    packet_filter=${A4_add}
    ${count_a4_rm}    Get Packets Count   alias=${UU_ALIAS}    packet_filter=${A4_remove}
    Teardown Tshark    alias=${UU_ALIAS}
    Should Be True    ${${amount_of_a4_reconf}-${allowed_diff}} <= ${count_a4_add} <= ${${amount_of_a4_reconf}+${allowed_diff}}
    Should Be True    ${${amount_of_a4_reconf}-${allowed_diff}} <= ${count_a4_rm} <= ${${amount_of_a4_reconf}+${allowed_diff}}

Expect A4 Meas Configuration After UE Attach
    [Arguments]    ${alias}=attach_UE${UE_ID}
    ${A4_AND_MEAS_GAP_CONFIG} =    Catenate
    ...    (measObjectToAddModList is present) and (length(measObjectToAddModList) eq 2) and
    ...    (reportConfigToAddModList is present) and (length(reportConfigToAddModList) eq 2) and (eventId contains (eventA4 is present)) and
    ...    (measIdToAddModList is present) and (length(measIdToAddModList) eq 2) and
    ...    (measGapConfig is present) and (gapUE contains (setup is present))
    Expect Message Flow
    ...    UE${UE_ID}:NR-RRC_RRCReconfiguration (freqBandIndicatorNR eq 38)
    ...    UE${UE_ID}:NR-RRC_RRCReconfigurationComplete
    ...    UE${UE_ID}:NR-RRC_RRCReconfiguration (${A4_AND_MEAS_GAP_CONFIG})
    ...    UE${UE_ID}:NR-RRC_RRCReconfigurationComplete
    ...    alias=${alias}   overall_timeout=20

Activate feature CB007219 actMfbiNrCaSupportFr1
    Find Scfc And Send Delta Commissioning Retrying After Errors    scfc_filename=delta_actMfbiNrCaSupportFr1_CB007219_true.json
