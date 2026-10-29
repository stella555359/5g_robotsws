*** Settings ***
Documentation    Keywords for feature CB008225

Resource    ../../resources/common_keywords.robot
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/counters.py   WITH NAME   wro4_pm
Library     ./specific_keywords_8225.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cell_utilities.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library     ute_ue
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/attenuators.py
Variables   ./variables.py


*** Variables ***
${tput_deviation}      10%
${tput_duration}       60
@{triggers}            DL  UL  #DL_CA
@{counter_ids}
${resume_dl}           ${0}
${resume_ul}           ${0}


*** Keywords ***
Set Variables Related to Testline
    ${tl_info}   python_functions.get_testline_name
    Log   Test run on ${tl_info}[0] testline
    Run Keyword If   '${tl_info}[0]' == 'HASTROMUTANT1'   Run Keywords
    ...     Set Test Variable   ${serving_cell}   410
    ...     AND   Set Test Variable   ${ue_alias}   ASUS
    ...   ELSE
    ...    Run Keywords
    ...     Set Test Variable   ${serving_cell}   103
    ...     AND   Set Test Variable   ${ue_alias}   UE_1
    [Return]    ${tl_info}[0]


Get timers settings from BTS
    ${timers_settings}   get_timers_value_from_scf
    ...  drbRrcInactInactivityTimerSA
    ...  srbInactivityTimerSA
    ...  drbInactivityTimerSA
    ...  maxUeRrcInactTime
    ${inactive_timer}   calculate_rrc_inactivity_timer   ${timers_settings}
    Set Test Variable   ${inactive_timer}
    ${idle_timer}   calculate_rrc_idle_timer   ${timers_settings}
    Set Test Variable   ${idle_timer}
    Set Test Variable   ${inactive_idle_timer}  ${timers_settings}[maxUeRrcInactTime]
    ${cells}   cell_utilities.get_cells_identifiers   identifier=globalCellId
    Set Test Variable   ${cells}


${action} RRC Inactive feature
    Show Text on Console   [${action[:-1]}ing RRC INACTIVE feature in progress... ]
    set_rrc_inactive_feature   action=${action.lower()}
    Show Text on Console   [RRC INACTIVE feature is ${action.upper()}D]


Attach UE and verify it
    [Arguments]   ${pci}
    Attach Ue   ${ue_alias}
    ${cell}   Verify 5G SA Attach   ${ue_alias}
    Should Be Equal As Integers   ${cell}  ${pci}


Wait Inactivity timer expired and UE moves to ${state} state
    Set Test Variable   ${state}
    Show Text on Console   [Wait ${${state}_timer} seconds to UE moves to ${state} state]
    BuiltIn.Sleep   ${${state}_timer}s
    # ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   stop_tracing=NO
    # is_ue_in_state   expected_state=${state.lower()}   pcap_file=${logs_path}
    Show Text on Console   [UE moved to ${state} state]


Start Traffic and get result
    [Arguments]   ${tput_variant}
    Show Text on Console   [Run ${tput_variant} Tput through ${tput_duration} seconds]
    ${direction}   Set Variable If   '${tput_variant}' == 'DL_CA'   DL  ${tput_variant}
    Start Data Transfer  dt_name=DT_DATA  ue_alias=${ue_alias}  direction=${direction}  duration=${tput_duration}s
    ...                  protocol=tcp  max_segment_size=1360  parallel=2
    BuiltIn.Sleep   10s  wait traffic started
    Check Data Transfer Is Alive   DT_DATA
    Run Keyword If   '${state}' == 'INACTIVE'   Verify Resume To Connected State   ${direction}
    Await Data Transfer Finish     DT_DATA

    ${avg_tput}   Get Average Throughput   dt_name=DT_DATA   tput_collection_src=control_app
    ${avg_tput}   Evaluate   ${avg_tput} / 1000
    ${avg_tput}   Evaluate   "%.2f" % ${avg_tput}
    Log To Console   \n AVERAGE ${tput_variant} Tput after going from ${state} to connected state: ${avg_tput}Mbits/sec
    [Return]   ${avg_tput}


Verify Resume To Connected State
    [Arguments]   ${direction}
    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   stop_tracing=NO
    Set Test Variable   ${resume_${direction}}    ${resume_${direction}+1}
    check_rrc_resume_msg_in_pcap_file   pcap_file=${logs_path}  direction=${direction}   msg_occurence=${resume_${direction}}


Collect Counters And Verify Them
    [Arguments]   ${start_time}  ${stop_time}  ${log_path}  ${serving_cell}
    Show Text on Console   [Counters collecting and verifying in progress... can take few minutes]
    ${pm_intervals_number}   wro4_pm.Calculate PM Intervals Number   ${start_time}  ${stop_time}
    ${filtered_trace}   filter_pcap   input_pcap=${log_path}  filter_expression=f1ap or e1ap or ngap
    ${PM_COUNTERS}   specific_keywords_8225.increase_counters_based_on_msgs_in_pcap_file    ${serving_cell}  ${filtered_trace}
    Set Test Variable   ${PM_COUNTERS}
    @{counter_ids}   Prepare Counter IDs To Check
    ${counter_values}   wro4_pm.get_sum_of_n_last_pm_counters_values   ${counter_ids}   n=${pm_intervals_number}
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
    Set Test Variable   ${measured_value}   ${counter_values}[${pi_id}]

    Run Keyword And Continue On Failure   Should Be Equal As Integers   ${expected_value}  ${measured_value}
    ...    \n ${ne_abbr} counter is not correct, \n expected: ${expected_value}, \n current: ${measured_value}
    ...    values=False

    Run Keyword If   '${expected_value}' == '${measured_value}'
    ...    Log To Console   ${SPACE} ${ne_abbr} counter value: ${expected_value}


Verify Counter per Cell
    [Arguments]   ${ne_abbr}  ${pi_id}  ${counter_values}
    FOR  ${cell}  IN  @{cells}
        Set Test Variable   ${expected_value}   ${PM_COUNTERS}[${ne_abbr}][value][${cell}]
        Set Test Variable   ${measured_value}   ${counter_values}[${pi_id}][NRCELL-${cell}]

        Run Keyword And Continue On Failure   Should Be Equal As Integers   ${expected_value}  ${measured_value}
        ...    \n ${ne_abbr} (NRCELL-${cell}) counter is not correct, \n expected: ${expected_value}, \n current: ${measured_value}
        ...    values=False

        Run Keyword If   '${expected_value}' == '${measured_value}'
        ...    Log To Console   ${SPACE} ${ne_abbr} (NRCELL-${cell}) counter value: ${expected_value}
    END


Set Max Time For Ue RRC Inactive State
    [Arguments]    ${value}=6
    Log To Console    Setting maxUeRrcInactTime to ${value}
    common_keywords.Update Parameter    maxUeRrcInactTime    ${value}
