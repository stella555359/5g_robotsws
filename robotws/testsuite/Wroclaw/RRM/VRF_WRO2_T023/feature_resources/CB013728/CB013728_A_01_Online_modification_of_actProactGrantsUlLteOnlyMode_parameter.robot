*** Settings ***
Documentation    Keywords for the CB013728

Library      ../../resources/airphone/tti_trace_keywords.py
Library      ta5g_testline_management
Library      ta5g_egate
Library      ute_wtssim
Library      ta_messaging
Library      ta5g_commissioning
Library      String
Library      ta5g_scfc_analysis
Resource     ../../resources/airphone/collectors.robot
Resource     ../../resources/airphone/gnb.robot
Variables    resources/ta_messaging_filters.py


*** Keywords ***
TC__CB013728_A_01_Online_modification_of_actProactGrantsUlLteOnlyMode_parameter
    #Attach UE, SgNB addition, testmodes set
    Create aliases  ue_id=101
    Set RLO parameters
    Set RLR parameters
    Attach LTE UE  ue_id=101
    SgNB Addition  ue_id=101

    #Check PUG scheduling
    Collect TTI Traces during 10 seconds of traffic
    Convert TTI trace pcap
    Run Keyword and Continue on Failure  Verify that UE is eligible for proactive UL grants

    #Trigger and verify RLO
    Expect RLO messages flow  ue_id=101
    Trigger RLO  ue_id=101  scell_id=8
    Check if RLO messages flow occurred  ue_id=101
    Pcap verify RLO messages content  ue_id=101  cellGroup=0  dataSplitThreshold=inf

    #Check no PUG scheduling
    Collect TTI Traces during 10 seconds of traffic
    Convert TTI trace pcap
    Run Keyword and Continue on Failure  Verify that UE is not eligible for proactive UL grants

    #Enable actProactGrantsUlLteOnlyMode and check PUG scheduling
    Set feature activation flag 'actProactGrantsUlLteOnlyMode' on NRCELL-1 to true
    Collect TTI Traces during 10 seconds of traffic
    Convert TTI trace pcap
    Run Keyword and Continue on Failure  Verify that UE is eligible for proactive UL grants

    #Disable actProactGrantsUlLteOnlyMode and check no PUG scheduling
    Set feature activation flag 'actProactGrantsUlLteOnlyMode' on NRCELL-1 to false
    Collect TTI Traces during 10 seconds of traffic
    Convert TTI trace pcap
    Run Keyword and Continue on Failure  Verify that UE is not eligible for proactive UL grants

    #Trigger and verify RLR
    Expect RLR messages flow  ue_id=101
    Trigger RLR  ue_id=101  scell_id=8
    Check if RLR messages flow occurred  ue_id=101
    Pcap verify RLR messages content  ue_id=101    cellGroup=1    dataSplitThreshold=b51200

    #Check PUG scheduling and detach UE
    Collect TTI Traces during 10 seconds of traffic
    Convert TTI trace pcap
    Run Keyword and Continue on Failure  Verify that UE is eligible for proactive UL grants

Configure VM interfaces
    Log To Console    Configure VM interfaces...
    Start default simulated SANSA interfaces

Set eNB params
    [Arguments]  ${enb_id}=1  ${gnb_id}=2
    Log to console  Set eNB params
    Execute egate command
    ...    cmd=enb_x2_link_up enb=${enb_id} target=${gnb_id}
    ...    pass_regexp=ENB-1: X2AP Link with GNB-2.*is up
    Sleep  2s

Attach LTE UE
    [Arguments]  ${ue_id}
    Log to console  ATTACH UE${ue_id}
    Execute egate command
    ...    cmd=attach_ue id=${ue_id}
    ...    pass_regexp=UE${ue_id}: === UE IS ACTIVE
    Sleep  5s

SgNB Addition
    [Arguments]  ${ue_id}  ${cell_id}=1  ${gnb_id}=2  ${bearer_id}=2  ${rrc_check}=False
    Log to console  SgNB ADDITION UE${ue_id}
    Run keyword if  '${rrc_check}'=='True'
    ...    Expect message flow
    ...    gNB${gnb_id}:X2AP_SgNBAdditionRequest as SgNBAdditionRequest
    ...    gNB${gnb_id}:X2AP_SgNBAdditionRequestAcknowledge as RRCReconfiguration
    ...    gNB${gnb_id}:X2AP_SgNBReconfigurationComplete as RRCReconfigurationComplete
    ...    alias=SgNBAddition_X2AP_UE${ue_id}  overall_timeout=10
    Run keyword if  '${rrc_check}'=='True'
    ...    Expect message flow
    ...    gNB${gnb_id}:F1AP_UEContextSetupRequest as UEContextSetupRequest
    ...    gNB${gnb_id}:F1AP_UEContextSetupResponse as UEContextSetupResponse
    ...    alias=SgNBAddition_UE${ue_id}  overall_timeout=10
    Execute egate command
    ...    cmd=ue_dc_enb_start ue=${ue_id} target_gnb=${gnb_id} target_cells=${cell_id} bearer=${bearer_id} type=split_scg
    ...    pass_regexp=UE${ue_id}: Proxy .eNB ${gnb_id} cell ${cell_id}. reported successful RA
    Run keyword if  '${rrc_check}'=='True'
    ...    Flow occurred as expected  alias=SgNBAddition_X2AP_UE${ue_id}
    Run keyword if  '${rrc_check}'=='True'
    ...    Flow occurred as expected  alias=SgNBAddition_UE${ue_id}

Detach UE
    [Arguments]  ${ue_id}    ${bearer_id}=2
    Execute egate command
    ...    cmd=enb_ue_dc_release ue=${ue_id} bearer=${bearer_id} by=enb cause=RN_CauseRadioNetwork_unspecified
    ...    pass_regexp=Successfully reconfigured dual connectivity
    Execute egate command
    ...    cmd=detach_ue id=${ue_id}
    ...    pass_regexp=UE${ue_id}: detached

Start UL Data Traffic
    [Arguments]    ${ue_id}=101    ${trf_id}=1    ${bearer_id}=2    ${duration}=10
    Execute Egate Command
    ...    cmd=trf_data_start ue=${ue_id} dir=ul trf_id=${trf_id} id=${bearer_id} mbps=10 size=500 seconds=${duration}

Set RLO parameters
    Execute Egate Command
    ...    cmd=phr_override_testmode_nr profile_id=1 phr_start=-23 phr_min=-23 phr_max=40 phr_step_size=-63 phr_period=1 pc_max=33 phr_mode=Fixed
    Execute Egate Command
    ...    cmd=ul_sinr_testmode_nr profile_id=2 sinr_target_pusch=-500
    Execute Egate Command
    ...    cmd=forced_dtx_testmode_nr profile_id=3 force_dtx_pusch=55:0
    Log to console  Setting RLO parameters...
    Sleep  2s

Set RLR parameters
    Execute Egate Command
    ...    cmd=phr_override_testmode_nr profile_id=4 phr_start=40 phr_min=40 phr_max=40 phr_step_size=-63 phr_period=1 pc_max=33 phr_mode=Fixed
    Execute Egate Command
    ...    cmd=ul_sinr_testmode_nr profile_id=5 sinr_target_pusch=0
    Log to console  Setting RLR parameters...
    Sleep  20s

Trigger RLO
    [Arguments]    ${ue_id}    ${scell_id}
    Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=${ue_id} testmode=phr_override action=activate profile_id=1 scell=${scell_id}
    Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=${ue_id} testmode=ul_sinr action=activate profile_id=2 scell=${scell_id}
    Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=${ue_id} testmode=forced_dtx action=activate profile_id=3
    Log to console  Triggering RLO...

Trigger RLR
    [Arguments]    ${ue_id}    ${scell_id}    ${bearer_id}=2
    Execute Egate Command
    ...    cmd=trf_data_start ue=${ue_id} dir=dl trf_id=2 id=${bearer_id} mbps=1 seconds=10
    Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=${ue_id} testmode=phr_override action=activate profile_id=4 scell=${scell_id}
    Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=${ue_id} testmode=ul_sinr action=activate profile_id=5 scell=${scell_id}
    Log to console  Triggering RLR...

Create aliases
    [Arguments]     ${ue_id}
    Create GNB device with alias 'gNB2' identified by ip=10.0.1.2
    Create Ue Alias  alias=UE_${ue_id}  ue_id=${ue_id}  id_type=wts_5g
    Enable internal mirroring for alias  gNB2

Expect RLO messages flow
    [Arguments]     ${ue_id}
    Expect message flow
    ...    gNB2:X2AP_SgNBModificationRequired as SgNBModificationRequired
    ...    alias=Verify_RLO${ue_id}   overall_timeout=120

Expect RLR messages flow
    [Arguments]     ${ue_id}
    Expect message flow
    ...    gNB2:X2AP_SgNBModificationRequired as SgNBModificationRequired
    ...    alias=Verify_RLR${ue_id}   overall_timeout=130

Check if RLO messages flow occurred
    [Arguments]     ${ue_id}
    Flow occurred as expected  alias=Verify_RLO${ue_id}

Check if RLR messages flow occurred
    [Arguments]     ${ue_id}
    Flow occurred as expected  alias=Verify_RLR${ue_id}

Verify moreThanOneRLC in X2AP_SgNBModificationRequired
    [Arguments]     ${ue_id}     ${cellGroup}    ${dataSplitThreshold}    ${flow_alias}=Verify_RLO
    ${query} =   String.Format String   ${moreThanOneRLC_in_X2AP_SgNBModificationRequired}   ${cellGroup}   ${dataSplitThreshold}
    Verify That Message Fulfills Query
    ...      ${query}
    ...  message_alias=SgNBModificationRequired
    ...  flow_alias=${flow_alias}${ue_id}

Pcap verify RLO messages content
    [Arguments]     ${ue_id}    ${cellGroup}   ${dataSplitThreshold}
    Verify moreThanOneRLC in X2AP_SgNBModificationRequired     ue_id=${ue_id}    cellGroup=${cellGroup}
    ...                                                        dataSplitThreshold=${dataSplitThreshold}   flow_alias=Verify_RLO

Pcap verify RLR messages content
    [Arguments]     ${ue_id}    ${cellGroup}   ${dataSplitThreshold}
    Verify moreThanOneRLC in X2AP_SgNBModificationRequired     ue_id=${ue_id}   cellGroup=${cellGroup}
    ...                                                        dataSplitThreshold=${dataSplitThreshold}   flow_alias=Verify_RLR

Collect TTI Traces during ${duration} seconds of traffic
    Log to console  Collect TTI Traces during ${duration} seconds
    Start TTI trace
    Start UL Data Traffic
    Sleep  ${duration}
    Log to console  Stop collecting TTI Traces
    Stop TTI trace

Set feature activation flag '${parameter}' on NRCell-1 to ${value}
    Perform Parameter Commissioning    parameter=${parameter}  value=${value}
    ...                                dist_name=MRBTS-1/NRBTS-1/NRCELL-1
    Sleep  10s
    Log to console  The parameter 'NRCell-${parameter}' was changed to ${value}

Verify that UE is eligible for proactive UL grants
    Verify proactive scheduling  present=True

Verify that UE is not eligible for proactive UL grants
    Verify proactive scheduling  present=False

Start Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth3:GNB3_NG_ADDR    ip_with_mask=10.0.1.3/24
    Start Vm Ethernet Interface    if_name=eth3:GNB3_XN_ADDR    ip_with_mask=10.0.1.4/24
    Start Vm Ethernet Interface    if_name=eth3:AMF_NG    ip_with_mask=10.0.1.1/24
