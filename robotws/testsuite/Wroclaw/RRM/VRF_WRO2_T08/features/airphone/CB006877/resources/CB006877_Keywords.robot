*** Settings ***

Documentation    :copyright: Nokia

Resource     ../../../../../resources/airphone/5G_SW_WRO_Keywords.robot
Library      ta5g_testline_management
Library      ta5g_tshark
Library      ta5g_ue_measurements
Library      ta5g_pm_counters
Library      ta5g_iphy
Library      ta5g_enb
Library      ./CB006877_Keywords.py

*** Keywords ***
Create Message Flow Checks Aliases
    [Arguments]     ${sa_ue_amount}    ${nsa_ue_amount}    ${sa_ue_first_id}    ${nsa_ue_first_id}
    ...             ${gNB_id}=2    ${gNB_IP}=10.0.1.2    ${eNB_id}=""    ${eNB_IP}=10.0.1.137
    Enable UE Capture On Simulated Enb    enable=${True}
    Create GNB Device With Alias 'gNB${gNB_id}' Identified By ip=${gNB_IP}
    Create Ue Aliases In Loop    sa_ue_amount=${sa_ue_amount}       nsa_ue_amount=${nsa_ue_amount}
    ...                          sa_ue_first_id=${sa_ue_first_id}   nsa_ue_first_id=${nsa_ue_first_id}
    Enable Internal Mirroring For Alias    gNB${gNB_id}
    Create ENB Device With Alias 'eNB${eNB_id}' Identified By ip=${eNB_IP}

Expect Sa Ue Attach Messages Flow
    [Arguments]    ${ue_id}    ${gNB_id}=2
    ${T3410}=      Set Variable    15  # 3GPP TS 24.301
    ${margin}=     Set Variable    50
    # There are two T3410 timers in keyword Attach UE And Establish PDU Session
    ${timeout}=    Evaluate     ${T3410}*2+${margin}
    Expect Message Flow
    ...    UE${ue_id}:NR-RRC_RRCSetupRequest as RRCSetupRequest
    ...    UE${ue_id}:NR-RRC_RRCSetup as RRCSetup
    ...    UE${ue_id}:NR-RRC_RRCSetupComplete as RRCSetupComplete
    ...    gNB${gNB_id}:NGAP_InitialUEMessage as InitialUEMessage
    ...    alias=SA_Attach_UE${ue_id}   overall_timeout=${timeout}

Expect PDU Messages Flow
    [Arguments]    ${ue_id}    ${gNB_id}=2
    ${T3410}=      Set Variable    15  # 3GPP TS 24.301
    ${margin}=     Set Variable    50
    # There are two T3410 timers in keyword Attach UE And Establish PDU Session
    ${timeout}=    Evaluate     ${T3410}*2+${margin}
    Expect Message Flow
    ...    gNB${gNB_id}:NGAP_InitialContextSetupRequest as InitialContextSetupRequest
    ...    gNB${gNB_id}:NGAP_UERadioCapabilityInfoIndication as UERadioCapabilityInfoIndication
    ...    gNB${gNB_id}:F1AP_UEContextSetupRequest as UEContextSetupRequest
    ...    gNB${gNB_id}:F1AP_UEContextSetupResponse as UEContextSetupResponse
    ...    UE${ue_id}:NR-RRC_UECapabilityEnquiry as UECapabilityEnquiry
    ...    UE${ue_id}:NR-RRC_UECapabilityInformation as UECapabilityInformation
    ...    UE${ue_id}:NR-RRC_RRCReconfiguration as RRCReconfiguration
    ...    UE${ue_id}:NR-RRC_RRCReconfigurationComplete as RRCReconfigurationComplete
    ...    gNB${gNB_id}:NGAP_InitialContextSetupResponse as InitialContextSetupResponse
    ...    alias=Established_PDU_UE${ue_id}   overall_timeout=${timeout}

Expect ENDC Flow For gNB
    [Arguments]    ${gNB_id}=2
    ${tDCOverall}=    Set Variable    5  # MRBTS.NRBTS.tDCoverall default value of 5000ms
    ${margin}=        Set Variable    50
    ${timeout}=       Evaluate     ${tDCOverall}+${margin}
    Expect Message flow
    ...    gNB${gNB_id}:X2AP_SgNBAdditionRequest (MeNBtoSgNBContainer is present) as SgnbAddReq
    ...    gNB${gNB_id}:F1AP_UEContextSetupRequest as ContextSetupReq
    ...    gNB${gNB_id}:F1AP_UEContextSetupResponse as ContextSetupResp
    ...    gNB${gNB_id}:X2AP_SgNBAdditionRequestAcknowledge (SgNBtoMeNBContainer is present) as SgnbAddReqAck_1
    ...    gNB${gNB_id}:X2AP_SgNBAdditionRequestAcknowledge (SgNBtoMeNBContainer is present) as SgnbAddReqAck_2
    ...    gNB${gNB_id}:X2AP_SgNBAdditionRequestAcknowledge (SgNBtoMeNBContainer is present) as SgnbAddReqAck_3
    ...    gNB${gNB_id}:X2AP_SgNBAdditionRequestAcknowledge (SgNBtoMeNBContainer is present) as SgnbAddReqAck_4
    ...    gNB${gNB_id}:X2AP_SgNBReconfigurationComplete (success-SgNBReconfComp is present) as SgnbReconfCmp
    ...    gNB${gNB_id}:X2AP_SNStatusTransfer
    ...    alias=EN-DC_gNB${gNB_id}
    ...    overall_timeout=${timeout}

Check If Sa Ue Attach Messages Flow Occured
    [Arguments]    ${ue_alias}
    Flow Occurred As Expected    alias=SA_Attach_UE${ue_alias}

Check If PDU Messages Flow Occured
    [Arguments]    ${ue_alias}
    Flow Occurred As Expected    alias=Established_PDU_UE${ue_alias}

Check If Nsa Ue Attach Messages Flow Occured
    Flow Occurred As Expected    alias=LTE-RRC_UE1
    Flow Occurred As Expected    alias=LTE-RRC_UE2
    Flow Occurred As Expected    alias=LTE-RRC_UE3
    Flow Occurred As Expected    alias=LTE-RRC_UE4

Check If ENDC Flow Occured For gNB${gNB_id}
    Flow Occurred As Expected    alias=EN-DC_gNB${gNB_id}

Check If ENDC Flow Occured For Specific UE
    [Arguments]    ${ue_id}
    Flow Occurred As Expected    alias=EN-DC_UE${ue_id}

Change RD Parameters In Swconfig File
    @{6877_rd_params}=    Create List
    ...    0x5901A6=1     # rdPCsiPoolHkfPeriod_min
    ...    0x5901A7=4     # rdHkfMinPCsiResPerSlot
    ...    0x5901A8=20    # rdHkfMinPCsiRepPeriod
    ...    0x59023E=50    # rdHkfPCsiPoolMaxRCUsFactorFDD
    ...    0x5901A9=80    # rdHkfPCsiPoolMaxRCUsFactor
    Backup And Modify Swconfig File    parameters_list=${6877_rd_params}

Attach UE To Enb And Gnb
    [Arguments]    ${ue_id}=1    ${target_cells}=1
    Execute Egate Command
    ...    cmd=ue_enb_param id=${ue_id} drx_config=off measurement_gap=gp0:10 gap_trigger=gnb_triggered
    ...    mgta=ms0dot50 gap_purpose=perUE
    Attach Ue To Enb    ue_id=${ue_id}    optional_parameters=profile=1
    Start Gnb Addition Procedure    ue=${ue_id}    target_gnb=2    target_cells=${target_cells}    bearer=2
    ...    dc_type=split_scg    pass_regexp=Proxy \\(eNB 2 cell ${target_cells}\\) reported successful RA

Compare PRB Values Before And After Housekeeping Function Between UEs
    [Arguments]    ${starting_PRB_before_HKF}    ${starting_PRB_after_HKF}
    ...            ${secondHopPRB_before_HKF}    ${secondHopPRB_after_HKF}
    ...            ${ue_id_first}                ${ue_id_second}
    ${check_starting_PRB}=    Should Be Equal    ${starting_PRB_before_HKF}    ${starting_PRB_after_HKF}
    IF    ${check_starting_PRB} == ${True}
    ...    Log To Console    Starting PRB of UE${ue_id_second} after HKF is the same as in UE${ue_id_first}
    ${check_secondHOP_PRB}=    Should Be Equal    ${secondHopPRB_before_HKF}    ${secondHopPRB_after_HKF}
    IF    ${check_secondHOP_PRB} == ${True}
    ...    Log To Console    SecondHOP PRB of UE${ue_id_second} after HKF is the same as in UE${ue_id_first}

Send A1 Event For S-Cell Addition
    [Arguments]    ${ue_id}    ${pcell_id}    ${scellTechnology}=FDD    ${srsrp}=127    ${srsrq}=127    ${ssinr}=127
    Send Ue Measurement Nr Event A1 Scell Addition With Aligned Meas Id
    ...    ue_id=${ue_id}    pcell_id=${pcell_id}    scellTechnology=${scellTechnology}    srsrp_nr=${srsrp}
    ...    srsrq_nr=${srsrq}    ssinr_nr=${ssinr}
    Sleep    3 seconds    reason=ensure A1 event for S-Cell Addition is sent

Send A2 Event For Handover
    [Arguments]    ${ue_id}=1    ${pcell_id}=1    ${srsrp}=1    ${srsrq}=1    ${ssinr}=1
    ...            ${pass_regexp}=message c1 : rrcReconfigurationComplete
    Send Ue Measurement Nr Event A2 Handover With Aligned Meas Id
    ...    ue_id=${ue_id}
    ...    pcell_id=${pcell_id}
    ...    srsrp_nr=${srsrp}
    ...    srsrq_nr=${srsrq}
    ...    ssinr_nr=${ssinr}
    ...    pass_regexp=${pass_regexp}
    Sleep    3 seconds    reason=ensure A2 event for HO is sent

Send A5 Event To Trigger Handover
    [Arguments]    ${carrier_freq}    ${pass_regexp}    ${ue_id}=1   ${srsrq_nr}=1    ${srsrp_nr}=1    ${ssinr_nr}=1
    ...            ${phycell_id}=2    ${nrsrq_nr}=122    ${nrsrp_nr}=122    ${nsinr_nr}=122    ${timeout}=30
    Send Ue Measurement Nr Event A5 With Aligned Meas Id    ue_id=${ue_id}    carrier_freq=${carrier_freq}
    ...                              pass_regexp=${pass_regexp}    srsrq_nr=${srsrq_nr}    srsrp_nr=${srsrp_nr}
    ...                              ssinr_nr=${ssinr_nr}    phycell_id=${phycell_id}    nrsrq_nr=${nrsrq_nr}
    ...                              nrsrp_nr=${nrsrp_nr}    nsinr_nr=${nsinr_nr}    timeout=${timeout}

Verify Tcp Messages For Subcase
    [Arguments]    ${packet_filter}    ${subcase_name}    ${number_of_messages}=1    ${pcap_file_path}=subcase    ${timeout}=16
    ...            ${relation_symbol}= ==    ${alias}=tcpdump_subcase    ${continue_on_failure}=${True}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    ...    pass_criteria=${relation_symbol}${number_of_messages}
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}
    ...    subcase=${subcase_name}

Wait For HKF Period
    Sleep    60 seconds    reason=HKF period
