*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_TDD    SBTS00
    ...    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Documentation    :copyright: Nokia
...              :authors: Dominik Rejman
...              :contact: dominik.rejman@nokia.com


Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Resource     CB007517_keywords.robot
Resource     ../keywords/logging.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/ue_measurements.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Library      ta5g_delta
Library      ta_messaging
Library      taf.ul.ettf.setups
Library      taf.ul.ettf.retry_context
Library      taf.ul.ettf.measurements
Library      setup_with_reboot.py
Variables    CB007517_messaging_filters.py
Library      ta5g_iphy


Test Setup     Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_xml_7517.xml
...            AND             Set Custom SCTP RTO Min Time
...            AND             With Gnb Configuration    commissioning=${scfc}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             With Simulator Configuration    config=${BASIC_SETUP}
...            AND    Attach UE In NSA Mode With DRX And Verify Success    ue_id=${UE_ID}    cell_id=${CELL_ID}    physcell_id=${PHYSCELL_ID}

Test Teardown     Detach UE    ue_id=${UE_ID}


*** Variables ***
${BASIC_SETUP}=       ${CURDIR}/config/wts_7517_B14.cfg
${scfc}=              CB007517-A-B14.xml
${A4RETRYTIMER_LENGTH}=    20
${A4SUPERVISIONTIMER_LENGTH}=    10
${UE_ID}=                 1
${CELL_ID}=               1
${GNB_ID}=                2
${PHYSCELL_ID}=           50
${EVENT_TYPE_A4}=         EventA4
${EVENT_TYPE_A2}=         EventA2
&{EVENT_PARAMS_A4}=       Threshold=RSRP 50
&{EVENT_PARAMS_A2}=       Threshold=RSRP 34
@{FREQUENCY_A4}=          518599
@{SOURCE_PSCELL_FREQ}=    636576
@{TARGET_PSCELL_FREQ}=    645312


*** Test Cases ***
CB007517-A_PSCell_Change_Procedure_On_Receipt_Of_A4_Measurement_Report_With_A4_Configured_In_The_Target_PSCell
    Add Scout Data Info To Testcase
    Verify A2 Measurement Was Configured During SgNB Addition
    Enable MeNB Coordinated Measurement Gaps Setup
    Set UE To Send A4 Measurement Reports Periodically
    Expect PSCell Change With MeNB Coordinated Measurement Gaps Release And DRX Setup Message Flow
    ...    ue_id=${UE_ID}    gNB_id=${GNB_ID}    timer_length=${A4RETRYTIMER_LENGTH}
    Verify A4 Measurement Setup With MeNB Coordinated Measurement Gaps Setup On Source Cell    ue_id=${UE_ID}    gNB_id=${GNB_ID}
    ...    timer_length=${A4RETRYTIMER_LENGTH}    alias_name=A4_conf_source
    Check PSCell Change With MeNB Coordinated Measurement Gaps Release And DRX Setup Message Flow    ue_id=${UE_ID}
    Verify A4 Measurement Setup With MeNB Coordinated Measurement Gaps Setup On Target Cell    ue_id=${UE_ID}    gNB_id=${GNB_ID}
    ...    timer_length=${A4RETRYTIMER_LENGTH}    alias_name=A4_conf_target


*** Keywords ***
Attach UE In NSA Mode With DRX And Verify Success
    [Arguments]    ${ue_id}    ${cell_id}    ${physcell_id}    ${gNB_id}=2
    Create SANSA Aliases    ue_id=${ue_id}
    Expect LTE RRC Flow For UE    ue_id=${ue_id}
    Attach UE To Enb    ue_id=${ue_id}    optional_parameters=profile=1
    Check If LTE RRC Messages Flow Occured    ue_id=${ue_id}
    Expect ENDC Flow For UE    ue_id=${ue_id}    gNB_id=${gNB_id}
    Expect DRX Setup Message Flow    ue_id=${ue_id}    gNB_id=${gNB_id}
    Start Gnb Addition Procedure    ue=${ue_id}    target_gnb=${gNB_id}    target_cells=${cell_id}    bearer=2    dc_type=split_scg
               ...                  pass_regexp=Proxy \\(eNB ${gNB_id} cell ${cell_id}\\) reported successful RA
    Check If ENDC Messages Flow Occured    ue_id=${ue_id}
    Verify SgNBAddition Messages Flow Content For UE    ue_id=${ue_id}    physcell_id=${physcell_id}
    Check DRX Setup Message Flow F1AP    ue_id=${ue_id}
    Check DRX Setup Message Flow X2AP    ue_id=${ue_id}

Expect DRX Setup Message Flow
    [Arguments]    ${ue_id}    ${gNB_id}    ${timeout}=15
    Expect Message Flow
    ...    gNB${gNB_id}:F1AP_UEContextModificationRequest (DRXCycle is present) as ContextModReq
    ...    gNB${gNB_id}:F1AP_UEContextModificationResponse (drx-Config is present) as ContextModResp
    ...    gNB${gNB_id}:F1AP_UEContextModificationRequest (GNB-DUConfigurationQuery is present) as ContextModReq2
    ...    gNB${gNB_id}:F1AP_UEContextModificationResponse (drx-Config is present) as ContextModResp2
    ...    alias=DRXSetup_F1AP_UE${ue_id}
    ...    overall_timeout=${timeout}
    Expect Message Flow
    ...    gNB${gNB_id}:X2AP_SgNBModificationRequired (drx-Config is present) as SgnbModRequired
    ...    gNB${gNB_id}:X2AP_SgNBModificationConfirm (rrcReconfigurationComplete is present) as SgnbModConf
    ...    alias=DRXSetup_X2AP_UE${ue_id}
    ...    overall_timeout=${timeout}

Check DRX Setup Message Flow F1AP
    [Arguments]    ${ue_id}
    ${alias_name}=    Set Variable    DRXSetup_F1AP_UE${ue_id}
    Flow Occurred As Expected   alias=${alias_name}
    Verify That Message Fulfills Query
    ...    ${DRX_setup_in_UEContextModReq_B14}   message_alias=ContextModReq    flow_alias=${alias_name}
    Verify That Message Fulfills Query
    ...    ${DRX_setup_in_UEContextModResp_B14}   message_alias=ContextModResp    flow_alias=${alias_name}
    Verify That Message Fulfills Query
    ...    ${DRX_setup_in_UEContextModResp_B14}   message_alias=ContextModResp2    flow_alias=${alias_name}

Check DRX Setup Message Flow X2AP
    [Arguments]    ${ue_id}
    ${alias_name}=    Set Variable    DRXSetup_X2AP_UE${ue_id}
    Flow Occurred As Expected   alias=${alias_name}
    Verify That Message Fulfills Query
    ...    ${DRX_setup_in_SgNBModificationRequired_B14}   message_alias=SgnbModRequired    flow_alias=${alias_name}
    Verify That Message Fulfills Query
    ...    ${RRCReconfCmp_in_SgnbModConf}   message_alias=SgnbModConf    flow_alias=${alias_name}

Verify A2 Measurement Was Configured During SgNB Addition
    Verify Measurement Configuration During SgNB Addition    ue_id=${UE_ID}    filter=${A2_measurement_configuration_in_SgNBAddReqAck_B14}
    Verify Measurements Are Configured At UE
    ...    ue_id=${UE_ID}    event_type=${EVENT_TYPE_A2}    event_params=${EVENT_PARAMS_A2}    frequencies=${SOURCE_PSCELL_FREQ}

Enable MeNB Coordinated Measurement Gaps Setup
    Execute Egate Command    cmd=ue_enb_param id=1 measurement_gap=gp4:13 mgta=ms0 gap_purpose=perUE gap_trigger=gnb_triggered
    Execute Egate Command    cmd=enb_endc_param id=1 allowed_bc_list_mrdc=disable

Set UE To Send A4 Measurement Reports Periodically
    Schedule For Nr Ue      ue_id=1         delay=1000     periodicity=1000
        Measurement         meas_id=2       event=A4       srsrp_nr=15 srsrq_nr=20 ssinr_nr=25 srs_result=10:50:55:60
            With Physical Cell              phycell_id=51  nrsrp_nr=40  nrsrq_nr=50
    Delay Till Nr Rrc Reconfiguration

Expect PSCell Change With MeNB Coordinated Measurement Gaps Release And DRX Setup Message Flow
    [Arguments]    ${ue_id}    ${gNB_id}    ${timer_length}
    ${margin}=    Set Variable    10
    ${timeout}=    Evaluate    ${timer_length}+${margin}
    Expect Message Flow
    ...    gNB${gNB_id}:X2AP_RRCTransfer (uENRMeasurements is present) as MeasReport
    ...    gNB${gNB_id}:X2AP_SgNBModificationRequired (SgNBtoMeNBContainer is present) as SgnbModRequired_PSCellChange
    ...    gNB${gNB_id}:X2AP_SgNBModificationConfirm (rrcReconfigurationComplete is present) as SgnbModConf_PSCellChange
    ...    gNB${gNB_id}:X2AP_SgNBModificationRequired (cg-Config is present and measConfigSN is not present) as SgnbModRequired_measgaprelease
    ...    gNB${gNB_id}:X2AP_SgNBModificationRequest (measConfigMN is present) as SgnbModRequest_measgaprelease
    ...    gNB${gNB_id}:X2AP_SgNBModificationRequestAcknowledge (SgNBtoMeNBContainer is not present) as SgnbModReqAck_measgaprelease
    ...    gNB${gNB_id}:X2AP_SgNBModificationConfirm (meNBtoSgNBContainer is not present) as SgnbModConf_measgaprelease
    ...    gNB${gNB_id}:X2AP_SgNBModificationRequired (drx-Config is present) as SgnbModRequired_DRXsetup
    ...    gNB${gNB_id}:X2AP_SgNBModificationConfirm (rrcReconfigurationComplete is present) as SgnbModConf_DRXsetup
    ...    alias=PSCellChange_X2AP_UE${ue_id}
    ...    overall_timeout=${timeout}
    Expect Message Flow
    ...    gNB${gNB_id}:F1AP_UEContextModificationRequest (nRCellIdentity is present) as ContextModReq_PSCellChange
    ...    gNB${gNB_id}:F1AP_UEContextModificationResponse (cellGroupConfig is present) as ContextModResp_PSCellChange
    ...    gNB${gNB_id}:F1AP_UEContextModificationRequest (RRCReconfigurationCompleteIndicator is present) as ContextModReq_RRCReconfComplete
    ...    gNB${gNB_id}:F1AP_UEContextModificationResponse as ContextModResp_RRCReconfComplete
    ...    gNB${gNB_id}:F1AP_UEContextModificationRequest (measGapConfig is present) as ContextModReq_measgaprelease
    ...    gNB${gNB_id}:F1AP_UEContextModificationResponse (DUtoCURRCInformation is present) as ContextModResp_measgaprelease
    ...    gNB${gNB_id}:F1AP_UEContextModificationRequest (DRXCycle is present) as ContextModReq_DRXsetup
    ...    gNB${gNB_id}:F1AP_UEContextModificationResponse (drx-Config is present) as ContextModResp_DRXsetup
    ...    gNB${gNB_id}:F1AP_UEContextModificationRequest (GNB-DUConfigurationQuery is present) as ContextModReq_DRXsetup2
    ...    gNB${gNB_id}:F1AP_UEContextModificationResponse (drx-Config is present) as ContextModResp_DRXSetup2
    ...    alias=PSCellChange_F1AP_UE${ue_id}
    ...    overall_timeout=${timeout}
    Expect Message Flow
    ...    UE${ue_id}:RRC_RRCConnectionReconfiguration (measGapConfig contains (release is present)) as RRCReconfiguration
    ...    UE${ue_id}:RRC_RRCConnectionReconfigurationComplete as RRCReconfigurationComplete
    ...    alias=PSCellChange_NR-RRC_UE${ue_id}
    ...    overall_timeout=${timeout}

Check PSCell Change With MeNB Coordinated Measurement Gaps Release And DRX Setup Message Flow
    [Arguments]    ${ue_id}
    Flow Occurred As Expected   alias=PSCellChange_F1AP_UE${ue_id}
    Flow Occurred As Expected   alias=PSCellChange_X2AP_UE${ue_id}
    Flow Occurred As Expected   alias=PSCellChange_NR-RRC_UE${ue_id}
    Verify That Message Fulfills Query
    ...    ${measurement_report_in_UEContextModReq_B14}    message_alias=ContextModReq_PSCellChange    flow_alias=PSCellChange_F1AP_UE${ue_id}
    Verify That Message Fulfills Query
    ...    ${measurements_reconfiguration_in_SgNBModRequired}    message_alias=SgnbModRequired_PSCellChange
    ...    flow_alias=PSCellChange_X2AP_UE${ue_id}
    Verify That Message Fulfills Query
    ...    ${RRCReconfCmp_in_SgnbModConf}    message_alias=SgnbModConf_PSCellChange    flow_alias=PSCellChange_X2AP_UE${ue_id}
    Verify That Message Fulfills Query
    ...    ${MeNB_coordinated_meas_gap_release}    message_alias=SgnbModRequest_measgaprelease    flow_alias=PSCellChange_X2AP_UE${ue_id}
    Verify That Message Fulfills Query
    ...    ${MeNB_coordinated_meas_gap_rel_in_UEContextModReq}    message_alias=ContextModReq_measgaprelease
    ...    flow_alias=PSCellChange_F1AP_UE${ue_id}
    Verify That Message Fulfills Query
    ...    ${DRX_setup_in_UEContextModReq_B14}   message_alias=ContextModReq_DRXsetup    flow_alias=PSCellChange_F1AP_UE${ue_id}
    Verify That Message Fulfills Query
    ...    ${DRX_setup_in_UEContextModResp_B14}   message_alias=ContextModResp_DRXsetup    flow_alias=PSCellChange_F1AP_UE${ue_id}
    Verify That Message Fulfills Query
    ...    ${DRX_setup_in_SgNBModificationRequired_B14}   message_alias=SgnbModRequired_DRXsetup    flow_alias=PSCellChange_X2AP_UE${ue_id}
    Verify That Message Fulfills Query
    ...    ${RRCReconfCmp_in_SgnbModConf}   message_alias=SgnbModConf_DRXsetup    flow_alias=PSCellChange_X2AP_UE${ue_id}
    Verify That Message Fulfills Query
    ...    ${DRX_setup_in_UEContextModResp_B14}   message_alias=ContextModResp_DRXSetup2    flow_alias=PSCellChange_F1AP_UE${ue_id}
    Verify Measurements Are Configured At UE
    ...    ue_id=${UE_ID}    event_type=${EVENT_TYPE_A2}    event_params=${EVENT_PARAMS_A2}    frequencies=${TARGET_PSCELL_FREQ}

Verify A4 Measurement Setup With MeNB Coordinated Measurement Gaps Setup On Source Cell
    [Arguments]    ${ue_id}    ${gNB_id}    ${timer_length}    ${alias_name}
    Expect A4 Measurement Setup With MeNB Coordinated Measurement Gaps Setup And DRX Release Flow
    ...    ue_id=${ue_id}    gNB_id=${gNB_id}    timer_length=${timer_length}    alias_name=${alias_name}
    Check A4 Measurement Setup With MeNB Coordinated Measurement Gaps Setup And DRX Release Flow   ue_id=${ue_id}    alias_name=${alias_name}
    Verify That Message Fulfills Query
    ...    ${MeNB_coordinated_meas_gap_setup_in_SgNBModRequired_source_cell}    message_alias=SgnbModRequired
    ...    flow_alias=${alias_name}_X2AP_UE${ue_id}
    Verify That Message Fulfills Query
    ...    ${MeNB_coordinated_meas_gap_setup_in_SgNBModRequest}    message_alias=SgnbModRequest    flow_alias=${alias_name}_X2AP_UE${ue_id}
    Verify That Message Fulfills Query
    ...    ${MeNB_coordinated_meas_gap_setup_and_DRX_rel_in_UEContextModReq}    message_alias=ContextModReq
    ...    flow_alias=${alias_name}_F1AP_UE${ue_id}
    Verify That Message Fulfills Query
    ...    ${DRX_release_in_UEContextModResp}    message_alias=ContextModResp    flow_alias=${alias_name}_F1AP_UE${ue_id}
    Verify That Message Fulfills Query
    ...    ${A4_measurements_configuration_in_SgNBModReqAck_on_source_cell}    message_alias=SgnbModReqAck
    ...    flow_alias=${alias_name}_X2AP_UE${ue_id}
    Verify That Message Fulfills Query
    ...    ${RRC_meas_gap_setup_B14}    message_alias=RRCReconfiguration    flow_alias=${alias_name}_NR-RRC_UE${ue_id}
    Verify That Message Fulfills Query
    ...    ${RRCReconfCmp_in_SgnbModConf}    message_alias=SgnbModConf    flow_alias=${alias_name}_X2AP_UE${ue_id}
    Verify That Message Fulfills Query
    ...    ${UEContextModReq_after_gaps_setup_and_DRX_release}    message_alias=ContextModReq_DRXsetup2    flow_alias=${alias_name}_F1AP_UE${ue_id}

Verify A4 Measurement Setup With MeNB Coordinated Measurement Gaps Setup On Target Cell
    [Arguments]    ${ue_id}    ${gNB_id}    ${timer_length}    ${alias_name}
    Expect A4 Measurement Setup With MeNB Coordinated Measurement Gaps Setup And DRX Release Flow
    ...    ue_id=${ue_id}    gNB_id=${gNB_id}    timer_length=${timer_length}    alias_name=${alias_name}
    Check A4 Measurement Setup With MeNB Coordinated Measurement Gaps Setup And DRX Release Flow   ue_id=${ue_id}    alias_name=${alias_name}
    Verify That Message Fulfills Query
    ...    ${MeNB_coordinated_meas_gap_setup_in_SgNBModRequired_target_cell}    message_alias=SgnbModRequired
    ...    flow_alias=${alias_name}_X2AP_UE${ue_id}
    Verify That Message Fulfills Query
    ...    ${MeNB_coordinated_meas_gap_setup_in_SgNBModRequest}    message_alias=SgnbModRequest    flow_alias=${alias_name}_X2AP_UE${ue_id}
    Verify That Message Fulfills Query
    ...    ${MeNB_coordinated_meas_gap_setup_and_DRX_rel_in_UEContextModReq}    message_alias=ContextModReq
    ...    flow_alias=${alias_name}_F1AP_UE${ue_id}
    Verify That Message Fulfills Query
    ...    ${DRX_release_in_UEContextModResp}    message_alias=ContextModResp    flow_alias=${alias_name}_F1AP_UE${ue_id}
    Verify That Message Fulfills Query
    ...    ${A4_measurements_configuration_in_SgNBModReqAck_on_target_cell}    message_alias=SgnbModReqAck
    ...    flow_alias=${alias_name}_X2AP_UE${ue_id}
    Verify That Message Fulfills Query
    ...    ${RRC_meas_gap_setup_B14}    message_alias=RRCReconfiguration    flow_alias=${alias_name}_NR-RRC_UE${ue_id}
    Verify That Message Fulfills Query
    ...    ${RRCReconfCmp_in_SgnbModConf}    message_alias=SgnbModConf    flow_alias=${alias_name}_X2AP_UE${ue_id}
    Verify That Message Fulfills Query
    ...    ${UEContextModReq_after_gaps_setup_and_DRX_release}    message_alias=ContextModReq_DRXsetup2    flow_alias=${alias_name}_F1AP_UE${ue_id}
    Verify Measurements Are Configured At UE
    ...    ue_id=${UE_ID}    event_type=${EVENT_TYPE_A4}    event_params=${EVENT_PARAMS_A4}    frequencies=${FREQUENCY_A4}

Expect A4 Measurement Setup With MeNB Coordinated Measurement Gaps Setup And DRX Release Flow
    [Arguments]    ${ue_id}    ${gNB_id}    ${timer_length}    ${alias_name}
    ${margin}=    Set Variable    5    # Safety margin for parsing messages etc., equal to tDCoverall
    ${timeout}=    Evaluate    ${timer_length}+${margin}
    Expect Message Flow
    ...    gNB${gNB_id}:X2AP_SgNBModificationRequired (measConfigSN is present) as SgnbModRequired
    ...    gNB${gNB_id}:X2AP_SgNBModificationRequest (measConfigMN is present) as SgnbModRequest
    ...    gNB${gNB_id}:X2AP_SgNBModificationRequestAcknowledge (SgNBtoMeNBContainer is present) as SgnbModReqAck
    ...    gNB${gNB_id}:X2AP_SgNBModificationConfirm (rrcReconfigurationComplete is present) as SgnbModConf
    ...    alias=${alias_name}_X2AP_UE${ue_id}
    ...    overall_timeout=${timeout}
    Expect Message Flow
    ...    gNB${gNB_id}:F1AP_UEContextModificationRequest (measGapConfig is present and DRXConfigurationIndicator is present) as ContextModReq
    ...    gNB${gNB_id}:F1AP_UEContextModificationResponse (drx-Config is present) as ContextModResp
    ...    gNB${gNB_id}:F1AP_UEContextModificationRequest (GNB-DUConfigurationQuery is present) as ContextModReq_DRXsetup2
    ...    gNB${gNB_id}:F1AP_UEContextModificationResponse (drx-Config is not present) as ContextModResp_DRXSetup2
    ...    alias=${alias_name}_F1AP_UE${ue_id}
    ...    overall_timeout=${timeout}
    Expect Message Flow
    ...    UE${ue_id}:RRC_RRCConnectionReconfiguration (gapOffset is present) as RRCReconfiguration
    ...    UE${ue_id}:RRC_RRCConnectionReconfigurationComplete as RRCReconfigurationComplete
    ...    alias=${alias_name}_NR-RRC_UE${ue_id}
    ...    overall_timeout=${timeout}

Check A4 Measurement Setup With MeNB Coordinated Measurement Gaps Setup And DRX Release Flow
    [Arguments]    ${ue_id}    ${alias_name}
    Flow Occurred As Expected   alias=${alias_name}_X2AP_UE${ue_id}
    Flow Occurred As Expected   alias=${alias_name}_F1AP_UE${ue_id}
    Flow Occurred As Expected   alias=${alias_name}_NR-RRC_UE${ue_id}
