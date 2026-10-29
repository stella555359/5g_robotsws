*** Settings ***
Documentation
...            author:        Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com,
...                           Marcin Duplaga, marcin.duplaga@nokia.com,
...                           Jakub Rutyna, jakub.rutyna@nokia.com,
...                           Paulina Karpf Matoga, paulina.karpf_matoga@nokia.com
...            maintainer:    Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com
...                           Marcin Duplaga, marcin.duplaga@nokia.com,
...                           Jakub Rutyna, jakub.rutyna@nokia.com,
...                           Paulina Karpf Matoga, paulina.karpf_matoga@nokia.com

Library    taf.ccs.aashell   WITH NAME    cli
Resource    ./../resources/KRK/krk3_common/main_cls.robot

*** Variables ***
&{RAD_HEXs}                     rdOverloadHighThreshold=0x89006f
...                             rdOverloadIndicationThreshold=0x590226
...                             rdDelayRrcOvlCountermeasures=0x890070
...                             rdKeepOverloadDuration=0x590221
...                             rdOverloadIndicationDurationThreshold=0x590227
...                             rdOverloadRejectionLowerMessageQueuingTime=0x5901FA
...                             rdOverloadRejectionUpperMessageQueuingTime=0x5901FB
...                             rdOverloadTriggeringMessageNumber=0x5901FC

*** Keywords ***
Enter Overload State on gNB-DU
    Log to Console    Entering overload state on gNB-DU
    Change RnD Flags By aaShell
    ...    ${RAD_HEXs['rdOverloadRejectionLowerMessageQueuingTime']}    1
    ...    ${RAD_HEXs['rdOverloadRejectionUpperMessageQueuingTime']}    2
    ...    ${RAD_HEXs['rdOverloadTriggeringMessageNumber']}    1
    ...    ${RAD_HEXs['rdOverloadIndicationThreshold']}    0
    ...    ${RAD_HEXs['rdKeepOverloadDuration']}    3000
    ...    ${RAD_HEXs['rdOverloadIndicationDurationThreshold']}    200

Exit Overload State on gNB-DU
    Log to Console    Exiting overload state on gNB-DU
    Change RnD Flags By aaShell
    ...    ${RAD_HEXs['rdOverloadRejectionLowerMessageQueuingTime']}    100000
    ...    ${RAD_HEXs['rdOverloadRejectionUpperMessageQueuingTime']}    125000
    ...    ${RAD_HEXs['rdOverloadTriggeringMessageNumber']}    30
    ...    ${RAD_HEXs['rdOverloadIndicationThreshold']}    100
    ...    ${RAD_HEXs['rdKeepOverloadDuration']}    3000
    ...    ${RAD_HEXs['rdOverloadIndicationDurationThreshold']}    200

Enter Overload State on gNB-CU
    Log to Console    Entering overload state on gNB-CU
    Change RnD Flags By aaShell    ${RAD_HEXs['rdOverloadHighThreshold']}    0

Exit Overload State on gNB-CU
    Log to Console    Exiting overload state on gNB-CU
    Change RnD Flags By aaShell    ${RAD_HEXs['rdOverloadHighThreshold']}    100

Change RnD Flags By aaShell
    [Arguments]    @{args}    ${is_permanent}=no
    cli.create_aashell_cli    name=aashell
    cli.setup    aashell
    cli.change_rad_params    aashell    ${args}    ${is_permanent}
    Sleep  10s    Wait for r&d param application
    [Teardown]    cli.teardown   aashell

Enable gNB Overload Protection Feature
    Change NIDD Parameter Online    dist=MRBTS-1/NRBTS-1    param=gnbOvlProtMode    value=classical

Disable gNB Overload Protection Feature
    Change NIDD Parameter Online    dist=MRBTS-1/NRBTS-1    param=gnbOvlProtMode    value=disabled

Switch actEmergencyCall Value To ${value} On Cell-${cell_id}
	${value}    Convert To Lower Case    ${value}
    Change NIDD Parameter Online    dist=MRBTS-1/NRBTS-1/NRCELL-${cell_id}    param=actEmergencyCall    value=${value}

Get Start Time For PCAP Verification
    ${start_time}    Get Current Date    result_format=epoch
    [Return]    ${start_time}

Verify Current Number of F1AP DU Overload Exit Messages
    [Arguments]    ${start_time}    ${count}    ${pcap_filepath}=${TEST_tcpdump_gnb_path}
    ${f1apGNBDUStatusIndication_filter}    Catenate    frame.time_epoch > ${start_time} and f1ap.GNBDUStatusIndication_element
    Verify Message Count in PCAP    pcap_filepath=${pcap_filepath}
    ...    filter=${f1apGNBDUStatusIndication_filter} && f1ap.GNBDUOverloadInformation == 0    count=>1
    Verify Message Count in PCAP    pcap_filepath=${pcap_filepath}
    ...    filter=${f1apGNBDUStatusIndication_filter} && f1ap.GNBDUOverloadInformation == 1    count=${count}

Verify Entry and Exit of DU Overload State in PCAP
    [Arguments]    ${pcap_filepath}    ${start_time}=0
    ${entry_filter}    Catenate
    ...    frame.time_epoch > ${start_time} &&
    ...    f1ap.procedureCode == 24 && f1ap.GNBDUOverloadInformation == 0
    ${exit_filter}    Catenate
    ...    frame.time_epoch > ${start_time} &&
    ...    f1ap.procedureCode == 24 && f1ap.GNBDUOverloadInformation == 1
    Verify Message Count in PCAP    pcap_filepath=${pcap_filepath}
    ...    filter=${entry_filter}    count=>1
    Verify Message Count in PCAP    pcap_filepath=${pcap_filepath}
    ...    filter=${exit_filter}    count=1

Verify NetworkAccessRateReduction Indicating Overload State In PCAP
    [Arguments]    ${start_time}    ${pcap_filepath}=${TEST_tcpdump_gnb_path}
    Verify NetworkAccessRateReduction Indicating State In PCAP    start_time=${start_time}    expected_uACReductionIndication=100
    ...    unexpected_uACReductionIndication=0    pcap_filepath=${pcap_filepath}

Verify NetworkAccessRateReduction Indicating Normal Operation State In PCAP
    [Arguments]    ${start_time}    ${pcap_filepath}=${TEST_tcpdump_gnb_path}
    Verify NetworkAccessRateReduction Indicating State In PCAP    start_time=${start_time}    expected_uACReductionIndication=0
    ...    pcap_filepath=${pcap_filepath}

Verify NetworkAccessRateReduction Indicating State In PCAP
    [Arguments]    ${start_time}    ${expected_uACReductionIndication}    ${unexpected_uACReductionIndication}=${None}
    ...            ${pcap_filepath}=${TEST_tcpdump_gnb_path}
    ${f1apNetworkReduction_filter}    Catenate    frame.time_epoch > ${start_time} and f1ap.NetworkAccessRateReduction_element
    Verify Message Count in PCAP    pcap_filepath=${pcap_filepath}
    ...    filter=${f1apNetworkReduction_filter} && f1ap.uACReductionIndication == ${expected_uACReductionIndication}
    ...    count=>0
    Run Keyword If  "${unexpected_uACReductionIndication}" != "${None}"    Verify Message Count in PCAP    pcap_filepath=${pcap_filepath}
    ...    filter=${f1apNetworkReduction_filter} && f1ap.uACReductionIndication == ${unexpected_uACReductionIndication}
    ...    count=0

Verify gNB Sends XNAP HandoverPreparationFailure With Misc Cause Control Processing Overload
    [Arguments]    ${start_time}    ${pcap_filepath}=${TEST_tcpdump_gnb_path}
    Verify Message Count in PCAP    pcap_filepath=${pcap_filepath}
    ...    filter=frame.time_epoch > ${start_time} and xnap.HandoverPreparationFailure_element && xnap.misc == control-processing-overload
    ...    count=1

Verify gNB Sends F1AP UEContextModificationRefuse With Misc Cause Control Processing Overload
    [Arguments]    ${start_time}    ${pcap_filepath}=${TEST_tcpdump_gnb_path}
    Verify Message Count in PCAP    pcap_filepath=${pcap_filepath}
    ...    filter=frame.time_epoch > ${start_time} and f1ap.UEContextModificationRefuse_element && f1ap.misc == control-processing-overload
    ...    count=1

Perform NSA LTE Bearer Addition
    [Arguments]       ${ue_id}    ${bearer_id}    ${pass_regexp}=Bearer.*created    &{kwargs}
    ${cmd}    Set Variable    bearer_add ue=${ue_id} id=${bearer_id} filter=${bearer_id} precedence=${bearer_id}
    ${log_msg}    Set Variable    Adding LTE Bearer-${bearer_id} to NSA UE-${ue_id}
    Execute Egate Command Ext    cmd=${cmd}    pass_regexp=${pass_regexp}    log_msg=${log_msg}    &{kwargs}

Perform NSA DC Bearer Addition
    [Arguments]    ${ue_id}    ${bearer_id}    ${cause}=RN_resource_optimisation
    ...    ${pass_regexp}=Successfully reconfigured dual connectivity
    ...    ${should_contain}=SgNBModificationRequestAcknowledge    &{kwargs}
    ${cmd}    Set Variable    ue_dc_modify_enb ue=${ue_id} bearer_to_add=${bearer_id} by=enb cause=${cause} type=split_scg
    ${log_msg}    Set Variable    Adding DC Bearer-${bearer_id} to NSA UE-${ue_id}
    Execute Egate Command Ext    cmd=${cmd}    pass_regexp=${pass_regexp}    log_msg=${log_msg}
    ...    should_contain=${should_contain}    &{kwargs}

Verify UE Location
    [Arguments]    ${ue_id}    ${node_id}    ${cell_id}
    ${cmd}    Set Variable    ue_disp id=${ue_id} type=cell
    ${pass_regexp}    Set Variable    ---.*====.*---.*====
    @{should_contain}    Create List    enb\\s+${node_id}    cell\\s+${cell_id}
    ${log_msg}    Set Variable    Verifying location of UE-${ue_id} in Cell ${node_id}.${cell_id}
    Execute Egate Command Ext    cmd=${cmd}    pass_regexp=${pass_regexp}    log_msg=${log_msg}
    ...    should_contain=${should_contain}

Prepare UE History Information
    [Arguments]    ${ue_id}
    ${reset_history}     Set Variable    ue_history_information_list id=1 action=reset
    ${ue_history}        Set Variable
    ...    ue_history_information_list_add_ngran id=1 gnb_id=3 cell_type=large nrcgi=311:489|0x01 time_ue_stayed_in_cell=98
    ${commit_history}    Set Variable    ue_history_information_list id=1 action=commit
    ${assign_history}    Set Variable    ue_enb_param id=${ue_id} ue_history_list=1
    ${log_msg}    Set Variable    Adding History Information to UE-${ue_id}
    Execute Egate Command Ext    cmd=${reset_history};${ue_history};${commit_history};${assign_history}
    ...    log_msg=${log_msg}

Prepare UE To Emergency Call
    [Arguments]    ${ue_id}
    ${log_msg}    Set Variable    Prepare UE-${ue_id} To Emergency Call
    Execute Egate Command Ext    cmd=ue_nr_rrc_setup_param id=${ue_id} establishment_cause=emergency
    Update UE Parameters    ue_id=${ue_id}    establishment_cause=emergency    nr_usage_setting=voice_centric
    Execute Egate Command Ext    cmd=qosflow_modify qos_flow=2 priority=1
    Execute Egate Command Ext    cmd=qosflow_modify qos_flow=2 ue=${ue_id} default=on

Trigger RRC Inactive State
    [Arguments]    ${ue_id}=1    ${pdu}=1
    Execute Egate Command Ext    cmd=set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    Execute Egate Command Ext    cmd=ue_pdu_session_setup ue=${ue_id} pdu=${pdu}    pass_regexp=UE${ue_id}: Is INACTIVE

Trigger RRCResumeRequest1
    [Arguments]    ${ue_id}=1    ${gnb}=2    ${cell}=1    ${cause}=emergency    ${should_contain}=@{Empty}
    ...    ${pass_regexp}=UE${ue_id}: UE performed resume procedure
    Execute Egate Command Ext
    ...    cmd=ue_nr_rrc_resume_request_param id=${ue_id} gnb=${gnb} cell=${cell} msg=resume_request_1 cause=${cause}
    ${cause_validate}    Replace String    ${cause}    _    -
    @{should_contain_ext}    Create List    resumeCause ${cause_validate}    @{should_contain}
    Execute Egate Command Ext
    ...    cmd=ue_nr_rrc_resume id=${ue_id}
    ...    pass_regexp=${pass_regexp}    should_contain=${should_contain_ext}

Set and Attach Beamcontrol Test Mode
    [Arguments]       ${ue_id}
    Log to Console    Setting Beamcontrol Test Mode
    ${beam_control_prf_1}    Set Variable
    ...    beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50
    ${beam_control_prf_2}    Set Variable
    ...    beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120
    ${test_mode_attach}    Set Variable
    ...    ue_testmode_set_nr id=${ue_id} testmode=beam_control action=activate profile_id=1 beamaction=attach
    Execute Egate Command Ext    cmd=${beam_control_prf_1}
    Execute Egate Command Ext    cmd=${beam_control_prf_2}
    Execute Egate Command Ext    cmd=${test_mode_attach}
    Sleep      5s    Wait for command to execute

Verify UE Has No Configuration For A4 Measurement
    [Arguments]       ${ue_id}
    ${cmd}    Set Variable    ue_meas_cfg_disp id=${ue_id}
    ${out}    Execute Egate Command Ext    cmd=${cmd}    pass_regexp=NR MEASUREMENT IDENTITIES.*---.*===
    Should Not Match Regexp    ${out}    NR\\s+EventA4
    ...    msg=Unexpected A4 measurement configuration at UE-${ue_id}

Perform Beam Change with RRC
    [Arguments]       ${ue_id}    ${profile_id}    ${pass_regexp}=rrcReconfigurationComplete    &{kwargs}
    Execute Egate Command Ext
    ...    cmd=ue_testmode_set_nr id=${ue_id} testmode=beam_control action=activate profile_id=${profile_id} beamaction=switch scell=0
    ...    pass_regexp=${pass_regexp}    &{kwargs}

Remove Beamcontrol Test Mode
    Log to Console    Removing Beamcontrol Test Mode
    Execute Egate Command Ext    cmd=beam_control_testmode_nr    profile_id=1    delete=1
    Sleep    5s    Wait for command to execute

Add Second ENB Cell to WTS Config
    [Arguments]    ${wts_delta}    ${wts_out}    ${wts_in}=/opt/wts/latest/basic_setup.cfg
    Insert Delta into WTS Config    wts_delta=${wts_delta}    wts_out=${wts_out}    wts_in=${wts_in}
    ...    after_line=set_cell id=1 enb=1

Add Extra NSA Bearer
    [Arguments]    ${wts_delta}    ${wts_out}    ${wts_in}=/opt/wts/latest/basic_setup.cfg
    Insert Delta into WTS Config    wts_delta=${wts_delta}    wts_out=${wts_out}    wts_in=${wts_in}
    ...    after_line=set_bearer id=2 ue=101

Add Extra UE Caps
    [Arguments]    ${wts_delta}    ${wts_out}    ${wts_in}=/opt/wts/latest/basic_setup.cfg
    Insert Delta into WTS Config    wts_delta=${wts_delta}    wts_out=${wts_out}    wts_in=${wts_in}
    ...    after_line=uec_param id=1

Insert Delta into WTS Config
    [Arguments]    ${wts_delta}    ${after_line}    ${wts_out}    ${wts_in}=/opt/wts/latest/basic_setup.cfg
    #--------- Param check -----------------------------------------------------------------------------------------
    File Should Exist    ${wts_in}
    File Should Exist    ${wts_delta}
    #---------------------------------------------------------------------------------------------------------------
    ${delta_content}    Get File    ${wts_delta}
    @{lines}    Split To Lines    ${delta_content}
    wtscfg.load_wts_cfg    ${wts_in}
    ${previous_line}    Set Variable    ${after_line}
    FOR    ${line}    IN    @{lines}
      wtscfg.insert    ${line}    after    ${previous_line}
      ${previous_line}    Set Variable    ${line}
    END
    Create File    ${wts_out}    ${Empty}
    wtscfg.save_wts_cfg    ${wts_out}
