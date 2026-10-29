*** Settings ***
Documentation    Keywords for feature CB010751

Resource    ../../resources/common_keywords.robot
#Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB008225/resources/keywords_8225.robot
Library     ./specific_keywords_10751.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/counters.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cell_utilities.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/attenuators.py
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB010751/resources/variables.py


*** Variables ***
@{redcap_ue_ids}              1  2  3  4  5
@{no_redcap_ue_ids}           11  12  13
@{send_ue_asst_inf_ue_ids}    1  3  5
${ue_inact_occurrence}        ${0}
${serving_cell}               1
@{resume_by_pdu_del_ue_ids}
@{resume_by_dl_tput_ue_ids}
@{suspend_methods}            UE_Asst_Inf  Time
@{resume_methods}             DL  VoNR  PDU_del
@{counter_ids}
${allowed_diff}               3 # percents


*** Keywords ***
Precondition to Test
    @{all_ue_ids}   Evaluate   @{redcap_ue_ids} + @{no_redcap_ue_ids}
    Set Test Variable   ${all_ue_ids}
    ${all_ue}   Get Length   ${all_ue_ids}
    Set Test Variable   ${all_ue}
    ${redcap_ue}   Get Length   ${redcap_ue_ids}
    Set Test Variable   ${redcap_ue}
    ${no_redcap_ue}   Get Length   ${no_redcap_ue_ids}
    Set Test Variable   ${no_redcap_ue}
    FOR  ${id}  IN  @{all_ue_ids}
        Set Test Variable   ${ue_${id}_inact_occurrence}   ${0}
        Set Test Variable   ${ue${id}_inactive_time}   ${0}
    END
    ${cells}   cell_utilities.get_cells_identifiers   identifier=globalCellId
    Set Test Variable   ${cells}


Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request
    [Arguments]   ${amf_id}=1   ${plmn_id}=311:489   ${tac_id}=200
    ${command} =  catenate  SEPARATOR=
    ...           amf_ue_ics_param id=${amf_id} core_network_assistance_info=on
    ...           \ ue_identity_index_value=1 ue_specific_drx=64
    ...           \ periodic_registration_update_timer=1:10min plmn_id=${plmn_id} tac_id=${tac_id}
    Execute Egate Command   cmd=${command}


Detach UEs
    FOR  ${id}  IN  @{all_ue_ids}
        Execute Egate Command   cmd=ue_deregister id=${id} ue_deregister_type=switch_off
    END


Attach UEs
    Show Text on Console   [Attach UEs and setup 2 PDU Sessions, one default and second one for VoNR]
    FOR  ${id}  IN  @{all_ue_ids}
        Execute Egate Command   cmd=set_pdu_param ue=${id} pdu=1 trf_type=internal
        Execute Egate Command   cmd=set_pdu_param ue=${id} pdu=2 trf_type=internal
        Attach UE   ue_id=${id}
        Establish PDU Session   ue_id=${id}  pdu_id=1  gw_id=1
    END
    Execute Egate Command   cmd=qosflow_modify qos_flow=2 default=on
    FOR  ${id}  IN  @{all_ue_ids}
        Establish PDU Session   ue_id=${id}  pdu_id=2  gw_id=1
    END


Wait UEs move to INACTIVE state
    Show Text on Console   [Send UE Assistance Iformation for few Redcap UEs]
    FOR  ${id}  IN  @{send_ue_asst_inf_ue_ids}
        Execute Egate Command   cmd=ue_assistance_send_nr ue_id=${id} PreferredRRCState=inactive   pass_regexp=UE${id}: Is INACTIVE
        Start Time UE in INACTIVE   ue_id=${id}
        Log to console   UE:${id} INACTIVE
    END
    Show Text on Console   [Wait ${timers}[srbInactivityTimerSA] seconds rest of UEs move to INACTIVE state]
    BuiltIn.Sleep   ${timers}[srbInactivityTimerSA]s

    @{rest_ue_ids}   Copy List  ${all_ue_ids}
    Remove Values From List   ${rest_ue_ids}   1
    FOR  ${id}  IN  @{rest_ue_ids}
        Start Time UE in INACTIVE   ue_id=${id}
        # Log to console   UE:${id} INACTIVE
    END


Verify UEs moved to INACTIVE state
    Set Test Variable   ${ue_inact_occurrence}  ${ue_inact_occurrence+${all_ue}}
    # Run Keyword And Continue On Failure   verify_egate_content   expected_pattern=UE.*: Is INACTIVE  occurrence=${ue_inact_occurrence}
    # Log to console   \n ALL UEs INACTIVE
    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   offset=5s  stop_tracing=NO
    verify_inactive_state_for_all_ues   expected_occurrence=${ue_inact_occurrence}   pcap_file=${logs_path}
    Log to console   \n ALL UEs INACTIVE


Resume to CONNECTED state
    Show Text on Console   [Resume UEs to CONNECTED state]
    FOR  ${id}  IN  @{all_ue_ids}
        ${resume}   Evaluate   random.choice(@{resume_methods})  random
        Run Keyword If   '${resume}' == 'PDU_del'   Delete PDU Session and Verify UE state   ue_id=${id}
        Run Keyword If   '${resume}' == 'DL'   Start Downlink Traffic and Verify UE state   ue_id=${id}
        Run Keyword If   '${resume}' == 'VoNR'   Simulate VoNR   ue_id=${id}
    END


Delete PDU Session and Verify UE state
    [Arguments]   ${ue_id}
    Log To Console   \n Resume UE:${ue_id} by deleting PDU Session
    Release PDU Session   ue_id=${ue_id}
    Verify UE State   ue_id=${ue_id}  expected_state=ACTIVE
    Log To Console   UE:${ue_id} ACTIVE
    Stop Time UE in INACTIVE   ue_id=${ue_id}
    # Append To List   ${resume_by_pdu_del_ue_ids}  ${ue_id}
    # Set Test Variable   @{resume_by_pdu_del_ue_ids}
    Start Time UE in INACTIVE   ue_id=${ue_id}  inact_timer=${30}


Start Downlink Traffic and Verify UE state
    [Arguments]   ${ue_id}
    Log To Console   \n Resume UE:${ue_id} by starting DL traffic
    Execute Egate Command   cmd=trf_data_start ue=${ue_id} pdu=1 dir=dl mbps=1   pass_regexp=rrcResumeRequest1.*resumeCause mt-Access
    BuiltIn.Sleep   1s
    Verify UE State   ue_id=${ue_id}  expected_state=ACTIVE
    Log To Console   UE:${ue_id} ACTIVE
    Stop Time UE in INACTIVE   ue_id=${ue_id}
    Append To List   ${resume_by_dl_tput_ue_ids}  ${ue_id}
    Set Test Variable   @{resume_by_dl_tput_ue_ids}


Simulate VoNR
    [Arguments]   ${ue_id}
    Log To Console   \n Resume UE:${ue_id} by starting VoNR
    Execute Egate Command   cmd=ue_pdu_session_modify ue=${ue_id} pdu=2 qosflows_to_add=3 by=amf   pass_regexp=Added QosFlow with QFI:2 fiveQI:1
    Verify UE State   ue_id=${ue_id}  expected_state=ACTIVE
    Log To Console   UE:${ue_id} ACTIVE
    Stop Time UE in INACTIVE   ue_id=${ue_id}
    Execute Egate Command   cmd=ue_pdu_session_modify ue=${ue_id} pdu=2 qosflows_to_del=3 by=amf
    ...                          pass_regexp=Ue ${ue_id} PduId 2 Removed FiveQi:Qfi mapping fiveQi 1 qfi 2
    Start Time UE in INACTIVE   ue_id=${ue_id}  inact_timer=${30}


Stop Tput and Verify All UEs moved to INACTIVE state
    Show Text on Console   [Stop data traffic and wait ALL UEs move to INACTIVE state]
    FOR  ${id}  IN  @{resume_by_dl_tput_ue_ids}
        Execute Egate Command   cmd=trf_data_stop ue=${id} pdu=1 dir=dl   pass_regexp=UE ${id}: DL Traffic was stopped
        Start Time UE in INACTIVE   ue_id=${id}  inact_timer=${30}
    END
    BuiltIn.Sleep   ${timers}[srbInactivityTimerSA]s
    Set Test Variable   ${ue_inact_occurrence}  ${ue_inact_occurrence+${all_ue}}
    #Run Keyword And Continue On Failure   verify_egate_content   expected_pattern=UE.*: Is INACTIVE  occurrence=${ue_inact_occurrence}
    Log to console   \n ALL UEs INACTIVE


Wait RNA Update
    Show Text on Console   [Wait ${timers}[t380] for RAN Area Update procedure]
    BuiltIn.Sleep   ${timers}[t380]
    # Sleep   5s   t380 Guard - fixed value
    # Set Test Variable   ${rna_upd_occurrence}  ${0}
    FOR  ${id}  IN  @{all_ue_ids}
        # Set Test Variable   ${rna_upd_occurrence}   ${rna_upd_occurrence+1}
        # Run Keyword And Continue On Failure   verify_egate_content   expected_pattern=resumeCause rna-Update   occurrence=${rna_upd_occurrence}
        Log To Console   RNA Update procedure done successfully for UE:${id}
        Verify UE State   ue_id=${id}  expected_state=UE_INACTIVE
        Log To Console   UE:${id} INACTIVE \n
    END


Wait UEs RRC Inactive Timer Reached
    Set Test Variable   ${t380_temp}  ${timers}[t380]
    ${sleep}   Evaluate   ${timers}[maxUeRrcInactTime] - ${t380_temp[:-3]}
    Show Text on Console   [Wait ${sleep} minute/s to reach maxUeRrcInactTime timeout]
    BuiltIn.Sleep   ${sleep} min
    FOR  ${id}  IN  @{all_ue_ids}
        Verify UE State   ue_id=${id}  expected_state=UE_INACTIVE
        Log To Console   \n UE:${id} UE_INACTIVE
        Stop Time UE in INACTIVE   ue_id=${id}
    END
    FOR  ${id}  IN  @{all_ue_ids}
        Execute Egate Command   cmd=ue_deregister id=${id} ue_deregister_type=switch_off   pass_regexp=UE${id}: detached
    END


Start Time UE in INACTIVE
    [Arguments]   ${ue_id}   ${inact_timer}=${0}
    ${time}   Get Time   epoch
    Set Test Variable   ${start_ue${ue_id}_inact}   ${time+${inact_timer}}


Stop Time UE in INACTIVE
    [Arguments]   ${ue_id}
    ${time}   Get Time   epoch
    ${inactive_time}   Evaluate   ${time} - ${start_ue${ue_id}_inact}
    ${sum_inact_time}   Evaluate   ${ue${ue_id}_inactive_time} + ${inactive_time}
    Set Test Variable   ${ue${ue_id}_inactive_time}   ${sum_inact_time}


Calculate Inactive Time for All Redcap UEs
    Set Test Variable   ${inact_time_for_redcap_ues}    ${0}
    FOR  ${id}  IN  @{redcap_ue_ids}
        ${inact_time_for_redcap_ues}   Evaluate   ${inact_time_for_redcap_ues} + ${ue${id}_inactive_time}
        Set Test Variable   ${inact_time_for_redcap_ues}
    END
    Log To Console   \n All Redcap UEs were ${inact_time_for_redcap_ues}s in INACTIVE state \n


Collect Counters And Verify Them
    [Arguments]   ${start_time}  ${stop_time}  ${log_path}  ${serving_cell}
    Show Text on Console   [Counters collecting and verifying in progress... can take few minutes]
    ${pm_intervals_number}   Calculate PM Intervals Number   ${start_time}  ${stop_time}
    Set Test Variable   ${pm_intervals_number}
    ${PM_COUNTERS}   increase_counters_based_on_msgs_in_pcap_file    ${serving_cell}  ${log_path}
    Set Test Variable   ${PM_COUNTERS}
    Collect Counters   n_last=${pm_intervals_number}
    @{counter_ids}   Prepare Counter IDs To Check
    ${counter_values}   Get Sum Of N Last Counter Values   ${pm_intervals_number}  @{counter_ids}
    Verify PM Counters   ${counter_values}


Prepare Counter IDs To Check
    ${counters}   Get Dictionary Keys   ${PM_COUNTERS}
    Set Test Variable   ${counters}
    FOR   ${ne_abbr}  IN   @{counters}
        Append To List  ${counter_ids}   ${PM_COUNTERS}[${ne_abbr}][PI_ID]
    END
    [Return]   ${counter_ids}


Verify PM Counters
    [Arguments]   ${counter_values}
    Log To Console   \n PM Counters verified correctly:
    FOR  ${ne_abbr}  IN  @{counters}
        Set Test Variable   ${pi_id}   ${PM_COUNTERS}[${ne_abbr}][PI_ID]
        ${type}   Evaluate   type(${PM_COUNTERS}[${ne_abbr}][value]).__name__
        Run Keyword If   '${type}' == 'int'
        ...     Verify Global Counter   ${ne_abbr}  ${pi_id}  ${counter_values}
        ...   ELSE
        ...     Verify Counter per Cell   ${ne_abbr}  ${pi_id}   ${counter_values}
    END


Verify Global Counter
    [Arguments]   ${ne_abbr}  ${pi_id}  ${counter_values}
    Set Test Variable   ${expected_value}   ${PM_COUNTERS}[${ne_abbr}][value]
    Set Test Variable   ${counter_path}     ${PM_COUNTERS}[${ne_abbr}][counter_path]
    Set Test Variable   ${measured_value}   ${counter_values}[${pi_id}][${counter_path}]

    Run Keyword And Continue On Failure   Should Be Equal As Integers   ${expected_value}  ${measured_value}
    ...    \n ${ne_abbr} counter is not correct, \n expected: ${expected_value}, \n current: ${measured_value}
    ...    values=False

    Run Keyword If   '${expected_value}' == '${measured_value}'
    ...    Log To Console   ${SPACE} ${ne_abbr} counter value: ${expected_value}


Verify Counter per Cell
    [Arguments]   ${ne_abbr}  ${pi_id}  ${counter_values}
    FOR  ${cell}  IN  @{cells}
        Set Test Variable   ${expected_value}   ${PM_COUNTERS}[${ne_abbr}][value][${cell}]
        Set Test Variable   ${measured_value}   ${counter_values}[${pi_id}][${cell}]

        Run Keyword If   '${ne_abbr}' == 'AVG_SA_REDCAP_RRC_INA_NOM' and '${cell}' == '${serving_cell}'
        ...     Verify Inactivity Time for Redcap UEs   ${ne_abbr}  ${expected_value}  ${measured_value}
        ...   ELSE
        ...     Verify Counters   ${cell}  ${ne_abbr}  ${expected_value}  ${measured_value}
    END

Verify Counters
    [Arguments]   ${cell}  ${ne_abbr}  ${expected_value}  ${measured_value}
    Run Keyword And Continue On Failure   Should Be Equal As Integers   ${expected_value}  ${measured_value}
    ...    \n ${ne_abbr} (NRCELL-${cell}) counter is not correct, \n expected: ${expected_value}, \n current: ${measured_value}
    ...    values=False
    Run Keyword If   '${expected_value}' == '${measured_value}'
    ...    Log To Console   ${SPACE} ${ne_abbr} (NRCELL-${cell}) counter value: ${expected_value}


Verify Inactivity Time for Redcap UEs
    [Arguments]   ${ne_abbr}  ${expected_value}  ${measured_value}
    ${time_diff}   Evaluate   abs(${expected_value-${measured_value}} / ${expected_value} * 100)
    Run Keyword And Continue On Failure   Should Be True   ${time_diff} < ${allowed_diff}
    ...    \n ${ne_abbr} (NRCELL-${serving_cell}) counter is not correct, \n expected: ${expected_value}, \n current: ${measured_value}
    Run Keyword If   ${time_diff} < 1
    ...    Log To Console   ${SPACE} ${ne_abbr} (NRCELL-${serving_cell}) counter value:\n expected: ${expected_value},\n current: ${measured_value}
