*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_LPQ_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia
...              :authors: Marcin Holowinski
...              :contact: Marcin.Holowinski@nokia.com


Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     taf/ul/ettf/main.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/logging.robot
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
...            AND             Enable C-Plane Debug Logs       with_reboot=${FALSE}
...            AND             Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_xml_CB006733_BB8.xml
...            AND             With Gnb Configuration    commissioning=full_scfc_CB006733_BB8.xml
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             With Simulator Configuration    config=${CURDIR}/config/wts_CB006733_BB8.cfg

Test Teardown    Execute Egate Command    cmd=ue_deregister id=${ue_id} ue_deregister_type=switch_off

*** Variables ***
${LOGS_COMPRESSION}=    ${True}
${LOGGING_POLICY}=    FULL_POLICY
${BASIC_SETUP}=       ${CURDIR}/config/wts_6733_basic.cfg
${scfc}=              full_scfc_CB006733_B_B1.xml
${GNB_ID}=            2
${PCELL_ID}=          4
${PHYSCELL_ID}=       54
${UE_ID}=             4
${A4_MEASUR_ACT_SCELL_ADD_SA}=    M55118C00030
${COUNTER_NAME}=    A4_MEASUR_ACT_SCELL_ADD_SA
${LOCAL_MOID}=    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4
${A4_add}=        (nr-rrc.criticalExtensions == 0) && (nr-rrc.measIdToAddModList == 6) && (nr-rrc.gapUE == 1)
${A4_remove}=     (nr-rrc.criticalExtensions == 0) && (nr-rrc.measIdToRemoveList == 6) && (nr-rrc.gapUE == 0)

*** Test Cases ***
CB006733-B_B8_RRC_Resume_procedure_triggers_A4_measurement_for_FR1_CA_SCell_Addition_activation

    Prepare UE Configuration
    Attach UE And Establish PDU Session    ue_id=${ue_id}    cell_id=4    enb_id=2   pdu_id=3    gw_id=3
    Wait For UE Iactivity Release And Check If Suspend Config Is Present
    Wait For Next Full Pm Interval    # Counter verification should be done after RRC Resume
    Resume UE Connection And Check If A4 Aeasurement Is Configured For UE
    Check Number Of A4 Reconfigurations
    Verify Pm Counter For Number Of A4 Measurements Activations    local_moid=${LOCAL_MOID}

*** Keywords ***
Prepare UE Configuration
    Create SA Aliases    ue_id=${ue_id}    gNB_id=2
    Configure Resume From Inactvity For UE

Configure Resume From Inactvity For UE
    [Arguments]    ${ue_id}=4
    ${cmd} =    Catenate
    ...    amf_ue_ics_param id=1 ue=${ue_id} core_network_assistance_info=on
    ...    ue_identity_index_value=4 ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=100
    Execute Egate Command    cmd=${cmd}
    Execute Egate Command    cmd=ue_nr_rrc_resume_request_param id=${ue_id} gnb=2 cell=4 msg=resume_request_1 cause=mo_Signalling

Check Number Of A4 Reconfigurations
    [Arguments]    ${amount_of_a4_reconf}=12   ${allowed_diff}=2
    ${UU_ALIAS}=    Start Tshark For Uu Interface
    Sleep    60    Time to gather info about A4 measurement configuraiton and deconfiguration
    Stop Capturing    alias=${UU_ALIAS}
    ${count_a4_add}    Get Packets Count   alias=${UU_ALIAS}    packet_filter=${A4_add}
    ${count_a4_rm}    Get Packets Count   alias=${UU_ALIAS}    packet_filter=${A4_remove}
    Teardown Tshark    alias=${UU_ALIAS}
    Should Be True    ${${amount_of_a4_reconf}-${allowed_diff}} <= ${count_a4_add} <= ${${amount_of_a4_reconf}+${allowed_diff}}
    Should Be True    ${${amount_of_a4_reconf}-${allowed_diff}} <= ${count_a4_rm} <= ${${amount_of_a4_reconf}+${allowed_diff}}

Wait For UE Iactivity Release And Check If Suspend Config Is Present
    Expect Message Flow
    ...    UE${ue_id}:NR-RRC_RRCRelease (suspendConfig is present)
    ...    alias=release_UE${ue_id}   overall_timeout=125
    Flow occurred as expected    alias=release_UE${ue_id}

Resume UE Connection And Check If A4 Aeasurement Is Configured For UE
    ${A4_AND_MEAS_GAP_CONFIG} =    Catenate
    ...    (measObjectToAddModList is present) and (length(measObjectToAddModList) eq 5) and
    ...    (reportConfigToAddModList is present) and (length(reportConfigToAddModList) eq 2) and (eventId contains (eventA4 is present)) and
    ...    (measIdToAddModList is present) and (length(measIdToAddModList) eq 6) and
    ...    (measGapConfig is present) and (gapUE contains (setup is present))
    Expect Message Flow
    ...    UE${ue_id}:NR-RRC_RRCResume
    ...    UE${ue_id}:NR-RRC_RRCResumeComplete
    ...    UE${UE_ID}:NR-RRC_RRCReconfiguration (${A4_AND_MEAS_GAP_CONFIG})
    ...    UE${UE_ID}:NR-RRC_RRCReconfigurationComplete
    ...    alias=resume_UE${ue_id}   overall_timeout=10
    Execute Egate Command    cmd=trf_data_start ue=4 pdu=3 trf_id=1 dir=dl mbps=50
    Flow occurred as expected    alias=resume_UE${ue_id}

