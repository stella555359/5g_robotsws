*** Settings ***

Documentation    Keywords for CB008053.

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/L3_Call.robot
Resource     ../keywords/ue_measurements.robot
Resource    ../keywords/tshark_verifying.robot
Resource     CB008053_keywords.robot
Resource     ../keywords/traffic.robot
Library      ta_messaging
Library      taf.ul.ettf.setups
Library      taf.ul.ettf.retry_context
Library      ta5g_ue_measurements
Library      ta5g_testline_management
Library      ta5g_delta
Library      ta5g_egate
Library      ta5g_iphy
Library      ta5g_pm_counters
Library      ta5g_ue_mobility
Library      ute_wtssim
Variables    CB008053_messaging_filters.py
Variables    logging_policy.py


*** Variables ***
${REBOOT}=    ${True}  # Switch to true to reboot before 1st test iteration, useful when running multiple tests on the same testline
${LOGS_COMPRESSION}=    ${True}
${LOGGING_POLICY}=    FULL_POLICY  # Can be set to FULL_POLICY_WITH_EMIL to capture Emil logs during retests
${BASIC_SETUP}=       ${CURDIR}/config/basic_setup.cfg
${scfc_1}=    CB008053-A-B5a.xml
${SCFC_2}=    CB008053-B_B2_scfc.xml
${scfc_3}=              CB008053-D-B1a.xml
${FULL_SCFC}=     CB008053-D-B2b.xml
${UE_CAPABILITY_FILE}=       /home/ute/test_repository/testsuite/Wroclaw/RRM/WRO_2/CB008053/config/ue_capabilities_8053_D.cfg
${UE_ID}=                  40
${PCELL_ID}=               4
${PCELL_ID_2}=             3
${TDD_PCELL_ID}=           4
${UE_TDD_PCELL_1}=         4
${FDD_PCELL_ID}=           1
${UE_TDD_PCELL_2}=         40
${UE_TDD_PCELL_3}=         41
${Trigger_CA_Meas_ID}=    1
${UE_FDD_PCELL_1}=         10
${UE_FDD_PCELL_1_1}=       1
${UE_FDD_PCELL_2}=         10
${SCELL_ID_1}=             5
${SCELL_ID_2}=             6
${GNB_ID}=                 2
${PHYSCELL_ID}=            54
${PHYSCELL_ID_2}=          53
${PDU_PCELL_1}=            1
${PDU_FDD_PCELL_1}=        1
${PDU_TDD_PCELL_1}=        4
${GW_ID}=                  1
${A2_cmd}=
...    id=${UE_ID} meas_id=6 event=A2 srsrp_nr=5 srsrq_nr=5
...    scell=1 scell_rsrp=90 scell_rsrq=90
...    scell=2 scell_rsrp=34 scell_rsrq=10
...    scell=3 scell_rsrp=34 scell_rsrq=10
${SCELL_ADD_A1_MEAS_ID}=    1
${SCELL_CHANGE_A1_MEAS_ID}=    4
${A1_FOR_SCELL_ADDITION}=    EventA1
&{A1_RSRP_50}=    Threshold=RSRP 50
@{FREQUENCIES_A1}=    392410

*** Keywords ***
Verify A1 Measurement Configuration
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${A1_measurements_configuration_in_RRCReconfiguration_B5}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=Established_PDU_NR_RRC_UE${ue_id}

Trigger A1 Based SCell Addition With 4CC TFTT
    [Arguments]    ${ue_id}    ${gNB_id}
    Expect SCell Addition Messages Flow    ${ue_id}    ${gNB_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=2 event=A1 srsrp_nr=90
    Check If SCell Addition Messages Flow Occured    ${ue_id}

Verify 4CC TFTT SCell Addition Message Contents
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_TTTF_4CC_CA_in_UE_CON_MOD_REQ}
    ...  message_alias=UEContextModificationRequest
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_TTTF_4CC_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify 4CC TFTT Common SCell Addition Message Contents    ue_id=${ue_id}

Verify 4CC TFTT Common SCell Addition Message Contents
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${PUCCH_config_for_4CC_TFTT_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${CSI_meas_config_in_4CC_UE_CON_MOD_RESP_PCell_Change}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${meas_config_in_RRC_Reconf_TFTT_B5}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=SCellAddition_UE${ue_id}

Trigger PCell Change
    [Arguments]    ${ue_id}    ${gNB_id}    ${A2_cmd}
    Wait For Next Full Pm Interval
    Expect PCell Change messages flow    ${ue_id}    ${gNB_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr ${A2_cmd}
    Check if PCell Change messages flow occured    ${ue_id}

Verify Successful PCell Change And SCells Release
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${HO_PREP_in_UE_CON_MOD_REQ_B5}
    ...  message_alias=UEContextModificationRequest
    ...  flow_alias=PCellChange_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${CSI_meas_config_in_UE_CON_MOD_RESP_RELEASE_B5}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=PCellChange_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${meas_config_in_RRC_Reconf_FTTT_B5}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=PCellChange_UE${ue_id}

Trigger A1 Measurement To Verify CA Successful
    [Arguments]    ${ue_id}    ${gNB_id}
    Expect SCell Addition Messages Flow    ${ue_id}    ${gNB_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=7 event=A1 srsrp_nr=90
    Check If SCell Addition Messages Flow Occured    ${ue_id}

Trigger A1 Based SCell Addition With 3CC FFF
    [Arguments]    ${ue_id}    ${gNB_id}
    Expect SCell Addition Messages Flow    ue_id=${ue_id}    gNB_id=${gNB_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${SCELL_ADD_A1_MEAS_ID} event=A1 srsrp_nr=70
    Check If SCell Addition Messages Flow Occured    ue_id=${ue_id}

Verify Successful CA
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_4CC_FTTT_CA_in_UE_CON_MOD_REQ_B5}
    ...  message_alias=UEContextModificationRequest
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_4CC_FTTT_CA_in_UE_CON_MOD_RESP_B5}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}

Verify 4CC CA Counters
    [Arguments]    ${scell_1}    ${scell_2}    ${scell_3}    ${pcell}
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55118C11009    >0    UE_SCELL_3_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${scell_1}
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...    M55118C11009    >0    UE_SCELL_3_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${scell_2}
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...    M55118C11009    >0    UE_SCELL_3_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${scell_3}
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...    M55118C09501    >0    UE_PCELL_3_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${pcell}
    ...    file_path=${pm_counter_file}

Verify 3CC FFF A1 Based SCell Addition Message Contents
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_3CC_FFF_CA_in_UE_CON_MOD_REQ}
    ...  message_alias=UEContextModificationRequest
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_3CC_FFF_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${PUCCH_config_for_3CC_FFF_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${CSI_meas_config_in_3CC_FFF_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${measurements_config_for_FFF_3CC_CA_in_RRC_Reconfiguration}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=SCellAddition_UE${ue_id}

Trigger SCell Change to 4CC FTTT At UE
    [Arguments]    ${ue_id}    ${gNB_id}
    Wait For Next Full Pm Interval
    Expect SCell Change messages flow    ue_id=${ue_id}    gNB_id=${gNB_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${SCELL_CHANGE_A1_MEAS_ID} event=A1 srsrp_nr=90
    Check if SCell Change messages flow occured    ue_id=${ue_id}

Verify 4CC FTTT A1 Based SCell Change Message Contents
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_and_removed_SCells_for_4CC_FTTT_CA_in_UE_CON_MOD_REQ}
    ...  message_alias=UEContextModificationRequest
    ...  flow_alias=SCellChange_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_4CC_FTTT_SCell_Change_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellChange_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${PUCCH_config_for_4CC_FTTT_CA_in_UE_CON_MOD_RESP_SCell_Change}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellChange_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${CSI_meas_config_in_4CC_FTTT_UE_CON_MOD_RESP_SCell_Change}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellChange_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${measurements_config_for_FTTT_4CC_CA_in_RRC_Reconfiguration}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=SCellChange_UE${ue_id}

Verify 4CC CA Counters For FDD_PCELL
    [Arguments]    ${cell_id}
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55138C03001    1    GNB_SCELL_3_ADMI_REQ_SA
    ...    M55138C03002    1    GNB_SCELL_3_ADMI_SUCC_SA
    ...    M55139C03001    1    GNB_DU_SCELL_3_ADMI_REQ_SA
    ...    M55139C03002    1    GNB_DU_SCELL_3_ADMI_SUCC_SA
    ...    M55118C06506    1    SCELL_CHANGE_ATT_SA
    ...    M55118C06507    1    SCELL_CHANGE_SUCC_SA
    ...    M55118C09501    >0    UE_PCELL_3_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${cell_id}
    ...    file_path=${pm_counter_file}

Expect PCell Change messages flow
    [Arguments]    ${ue_id}    ${gNB_id}=2    ${overall_timeout}=60
    Expect message flow
    ...    gNB${gNB_id}:F1AP_UEContextModificationRequest (SCell-ToBeRemoved-List is present) as UEContextModificationRequest
    ...    gNB${gNB_id}:F1AP_UEContextModificationResponse (sCellToReleaseList is present) as UEContextModificationResponse
    ...    UE${UE_ID}:NR-RRC_RRCReconfiguration (sCellToReleaseList is present) as RRCReconfiguration
    ...    UE${UE_ID}:NR-RRC_RRCReconfigurationComplete as RRCReconfigurationComplete
    ...    gNB${gNB_id}:F1AP_UEContextModificationRequest as UEContextModificationRequest_2nd
    ...    gNB${gNB_id}:F1AP_UEContextModificationResponse as UEContextModificationResponse_2nd
    ...    alias=PCellChange_UE${ue_id}
    ...    overall_timeout=${overall_timeout}

Reboot Testline
    [Arguments]    ${reboot}=${True}
    Run Keyword If    ${reboot}    Trigger Site Reset
    Wait For Testline ICMP Echo Replies And SSH Services
    Set Suite Variable    $REBOOT    ${True}

Configure UE1 UE2 UE3 capabilities
    [Arguments]    ${ue_capability_file}
    Execute Egate Command    cmd=ue_param id=${UE_TDD_PCELL_1} ue_nr_capabilities=mobiletype1_nr_capability capability_file=${ue_capability_file}
    ...    fail_regexp=Unable to locate File
    Execute Egate Command    cmd=ue_param id=${UE_TDD_PCELL_2} ue_nr_capabilities=mobiletype2_nr_capability capability_file=${ue_capability_file}
    ...    fail_regexp=Unable to locate File
    Execute Egate Command    cmd=ue_param id=${UE_TDD_PCELL_3} ue_nr_capabilities=mobiletype3_nr_capability capability_file=${ue_capability_file}
    ...    fail_regexp=Unable to locate File

Attach Ue And Verify Establishing PDU Session With A1 Measurement Verification
    [Arguments]    ${ue_id}    ${cell_id}    ${gnb_id}=2    ${pdu_id}=1    ${gw_id}=1
    Log To Console	UE${ue_id} attach, establishing PDU session and A1 measurement setup verification.
    Create UE Alias    alias=UE${ue_id}    ue_id=${ue_id}    id_type=wts_5g
    Expect UE Attach Messages Flow     ue_id=${ue_id}    gNB_id=${gnb_id}
    Expect PDU Messages Flow     ue_id=${ue_id}    gNB_id=${gnb_id}
    Expect A1 Measurement Configuration And DL UL RRCMessageTransfer Messages Flow    ue_id=${ue_id}    gNB_id=${gnb_id}
    BuiltIn.sleep    3
    Attach UE And Establish PDU Session    ue_id=${ue_id}    cell_id=${cell_id}    enb_id=${gnb_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Check If UE Attach Messages Flow Occurred     ue_id=${ue_id}
    Check If PDU Messages Flow Occurred     ue_id=${ue_id}
    Check If A1 Measurement Configuration And DL UL RRCMessageTransfer Messages Flow Occurred    ue_id=${ue_id}
    Verify A1 Measurement Configuration For PCell    ue_id=${ue_id}

Verify A1 Measurement Configuration For PCell
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${A1_measurement_configuration_for_PCell_TDD_DB1a}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=DL_UL_RRCMessageTransfer_with_A1_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${PDU_Session_ID_check_for_PCell_TDD_DB1a}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=DL_UL_RRCMessageTransfer_with_A1_UE${ue_id}

Expect A1 Measurement Configuration And DL UL RRCMessageTransfer Messages Flow
    [Arguments]     ${ue_id}    ${gNB_id}=2
    ${T3410}=    Set Variable    15  # 3GPP TS 24.301
    ${margin}=    Set Variable    2  # if anything the fail should be in Attach UE And Establish PDU Session keyword,
                                     # not in message capturing/veryfing part
    ${timeout}=    Evaluate     ${T3410}*2+${margin}  # There are two T3410 timers in keyword Attach UE And Establish PDU Session
    Expect Message Flow
    ...    gNB${gNB_id}:F1AP_DLRRCMessageTransfer as DLRRCMessageTransfer
    ...    gNB${gNB_id}:F1AP_ULRRCMessageTransfer as ULRRCMessageTransfer
    ...    UE${ue_id}:NR-RRC_RRCReconfiguration (measConfig is present) as RRCReconfiguration
    ...    UE${ue_id}:NR-RRC_RRCReconfigurationComplete as RRCReconfigurationComplete
    ...    gNB${gNB_id}:NGAP_InitialContextSetupResponse as InitialContextSetupResponse
    ...    alias=DL_UL_RRCMessageTransfer_with_A1_UE${ue_id}   overall_timeout=${timeout}

Check If A1 Measurement Configuration And DL UL RRCMessageTransfer Messages Flow Occurred
    [Arguments]     ${ue_id}
    Flow Occurred As Expected    alias=DL_UL_RRCMessageTransfer_with_A1_UE${ue_id}


Trigger A1 Based CA
    [Arguments]    ${ue_id}    ${gnb_id}    ${meas_id}
    Log To Console	Triggering A1 measurement for SCell addition from UE${ue_id}
    Expect A1 Based SCell Addition Messages Flow    ue_id=${ue_id}    gNB_id=${gnb_id}
    Trigger CA With A1 Measurement    UE_Id=${ue_id}    Meas_Id=${meas_id}
    Check A1 Based SCell Addition Messages Flow Occured    ue_id=${ue_id}

Expect A1 Based SCell Addition Messages Flow
    [Arguments]     ${ue_id}    ${gNB_id}=2
    Expect Message Flow
    ...    gNB${gNB_id}:F1AP_ULRRCMessageTransfer as ULRRCMessageTransfer_measurement
    ...    UE${UE_ID}:NR-RRC_MeasurementReport as measurementReport_A1
    ...    gNB${gNB_id}:F1AP_UEContextModificationRequest (SCell-ToBeSetupMod-List is present) as UEContextModificationRequest
    ...    gNB${gNB_id}:F1AP_UEContextModificationResponse (sCellToAddModList is present) as UEContextModificationResponse
    ...    gNB${gNB_id}:F1AP_UEContextModificationRequest (RRCReconfigurationCompleteIndicator eq "true") as UEContextModificationRequest_2nd
    ...    gNB${gNB_id}:F1AP_UEContextModificationResponse as UEContextModificationResponse_2nd
    ...    gNB${gNB_id}:F1AP_UEContextModificationRequest (GNB-DUConfigurationQuery eq "true") as UEContextModificationRequest_3rd
    ...    gNB${gNB_id}:F1AP_UEContextModificationResponse (cellGroupConfig is present) as UEContextModificationResponse_3rd
    ...    UE${UE_ID}:NR-RRC_RRCReconfiguration (sCellToAddModList is present) as RRCReconfiguration
    ...    UE${UE_ID}:NR-RRC_RRCReconfigurationComplete as RRCReconfigurationComplete
    ...    alias=SCellAddition_UE${ue_id}   overall_timeout=60

Verify 4CC TTTF A1 Based SCell Addition For Ue1
    [Arguments]    ${ue_id}
    Verify A1 Measurement SCell Addition Trigger    ue_id=${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_4CC_TTTF_DB1a_UE1_CA_in_UE_CON_MOD_REQ}
    ...  message_alias=UEContextModificationRequest
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_4CC_TTTF_DB1a_UE1_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify A1 Measurement For SCell Addition Removal    ue_id=${ue_id}
    Verify That Message Fulfills Query
    ...  ${PUCCH_config_for_4CC_TTTF_DB1a_UE1_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${CSI_meas_config_for_4CC_TTTF_DB1a_UE1_CA_BF_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}

Verify A1 Measurement SCell Addition Trigger
    [Arguments]     ${ue_id}
    Verify That Message Fulfills Query
    ...  ${measurementReport_in_UL_DCCH_Message_for_PCell_TDD_DB1a}
    ...  message_alias=measurementReport_A1
    ...  flow_alias=SCellAddition_UE${ue_id}

Verify A1 Measurement For SCell Addition Removal
    [Arguments]     ${ue_id}
    Verify That Message Fulfills Query
    ...  ${A1_measurement_report_removal_DB1a_PCell_TDD}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=SCellAddition_UE${ue_id}

Verify Traffic Is Scheduled On All Cells
    [Arguments]    ${ue_id}   ${pdu_id}   ${num_of_scells}
    Start Large Data Traffic    ue_id=${ue_id}    pdu_id=${pdu_id}
    Sleep    30s    Wait for traffic to stabilize
    Verify That Traffic Is Scheduled On All SCells    ue_id=${ue_id}    num_of_scells=${num_of_scells}
    Verify That Throughput Is Reached On All SCells    ue_id=${ue_id}    num_of_scells=${num_of_scells}    expected_throughput=10Mbps
    Stop DL and UL traffic on PDU for UE    ue_id=${ue_id}    pdu_id=${pdu_id}

Start Large Data Traffic
    [Arguments]    ${ue_id}   ${pdu_id}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=1 dir=dl mbps=150
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=2 dir=dl mbps=150
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=3 dir=dl mbps=150
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=4 dir=dl mbps=150

Verify 4CC TTFF A1 Based SCell Addition For Ue2
    [Arguments]    ${ue_id}
    Verify A1 Measurement SCell Addition Trigger    ue_id=${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_4CC_TTFF_DB1a_UE2_CA_in_UE_CON_MOD_REQ}
    ...  message_alias=UEContextModificationRequest
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_4CC_TTFF_DB1a_UE2_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify A1 Measurement For SCell Addition Removal    ue_id=${ue_id}
    Verify That Message Fulfills Query
    ...  ${PUCCH_config_for_4CC_TTFF_DB1a_UE2_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${CSI_meas_config_for_4CC_TTFF_DB1a_UE2_CA_BF_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}

Verify 2CC TT A1 Based SCell Addition For Ue3
    [Arguments]    ${ue_id}
    Verify A1 Measurement SCell Addition Trigger    ue_id=${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_2CC_TT_DB1a_UE3_CA_in_UE_CON_MOD_REQ}
    ...  message_alias=UEContextModificationRequest
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_2CC_TT_DB1a_UE3_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify A1 Measurement For SCell Addition Removal    ue_id=${ue_id}
    Verify That Message Fulfills Query
    ...  ${PUCCH_config_for_2CC_TT_DB1a_UE3_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${CSI_meas_config_for_2CC_TT_DB1a_UE3_CA_BF_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}

Verify 4CC And 2CC CA Counters
    [Arguments]    ${pcell_id}    ${scell_id_ue3}
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55118C09501    >1    UE_PCELL_3_CONF_SCELL_DL_SA
    ...    M55118C09502    2    RRC_RECONF_ADD3DLSCELL_SUCC_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${pcell_id}
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...    M55118C05507    >1    UE_PCELL_1_CONF_SCELL_DL_SA
    ...    M55118C05506    1    RRC_RECONF_ADD1DLSCELL_SUCC_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${pcell_id}
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...    M55118C05508    >1    UE_SCELL_1_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${scell_id_ue3}
    ...    file_path=${pm_counter_file}
Check A1 Based SCell Addition Messages Flow Occured
    [Arguments]     ${ue_id}
    Flow Occurred As Expected    alias=SCellAddition_UE${ue_id}

Check if PCell Change messages flow occured
    [Arguments]     ${ue_id}
    Flow occurred as expected  alias=PCellChange_UE${ue_id}

Release UE
    [Arguments]    ${ue_id}    ${pdu_id}
    Release PDU session    ue_id=${ue_id}    pdu_id=${pdu_id}
    Deregister UE    ue_id=${ue_id}
