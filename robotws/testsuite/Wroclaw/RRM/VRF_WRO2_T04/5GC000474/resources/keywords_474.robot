*** Settings ***
Documentation
...   author: Pawel Zabawczuk
...   contact: pawel.k.zabawczuk@nokia.com

Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC000474/resources/specific_keywords_474.py    WITH NAME   x2_474
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/counters.py
Library     testsuite/Wroclaw/RRM/resources/cell_utility/cell_utility_backend.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/admin_api/admin_utils.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/color_log.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ue_utils.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library     taf.ul.alarms_watchdog    WITH NAME   watchdog
Library     ute_ue
Library     DateTime
Resource    ./lteemu.robot
Variables   ./x2_variables.py


*** Variables ***
${traffic_duration}     7200s
@{tput_directions}      DL  UL
${tput_dl}              300
${tput_ul}              100

${scenario_no}          0
@{counter_ids}
@{alarms}
${delta_files_path}     testsuite/Wroclaw/RRM/WRO_4/5GC000474/resources/delta_templates/


*** Keywords ***
X2_LINK_LOCK_UNLOCK
    ${scenario_alarms}   Prepare Scenario Alarms
    ...     no_x2_link
    ...     no_x2_link_for_specific_lte
    ...     x2_setup_to_gnb_failed
    ...     cell_problem_due_to_no_x2_link

    ${bts_side}   Set Variable   gNB
    Show Text on Console   [Lock x2 link on ${bts_side} side and check alarms]
    Allow Alarms Occurrence
    ...    cell_problem_due_to_no_x2_link
    ...    no_x2_link
    ...    x2_setup_to_gnb_failed         # maxTimeSctpSetup

    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   stop_tracing=NO
    ${before_lock}   check_msg_occurrence   pcap_file=${logs_path}   msg=ENDCX2SetupRequest
    Change X2 Link Status   bts=${bts_side}  action=locked

    Verify Alarms Status    ACTIVE
    ...                     ${X2_PARAMETERS}[x2LinkSupervisionTmr][value]min
    ...                     cell_problem_due_to_no_x2_link
    ...                     no_x2_link
    Verify Alarms Status    ACTIVE
    ...                     4min
    ...                     x2_setup_to_gnb_failed

    Verify 4G Attach
    Check Average Tputs

    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   stop_tracing=NO  offset=5s
    ${after_lock}   check_msg_occurrence   pcap_file=${logs_path}   msg=ENDCX2SetupRequest
    # due to PR777470
    ${msg_no}   Evaluate   ${before_lock} - ${after_lock}
    x2_474.Increase Counters   ENDC_X2_SETUP_REQUEST_RECEIVED   multiplier=${msg_no}

    Show Text on Console   [Unlock x2 link, wait for onAir and alarms clearing]
    # during unblocking on gNB side alarm could occurs until eNB establish sctp connection
    Allow Alarms Occurrence   no_x2_link_for_specific_lte
    Change X2 Link Status   bts=${bts_side}  action=unlocked
    # time when eNB retries to establish sctp connection
    Wait Until Keyword Succeeds   240  30    verify_x2_link_status   enb_id=${lnbts_id}   expected_status=available
    Wait For BTS onAir State
    Check Average Tputs

    Verify Alarms Status    CLEARED
    ...                     10s
    ...                     cell_problem_due_to_no_x2_link
    ...                     x2_setup_to_gnb_failed
    ...                     no_x2_link

    ${bts_side}   Set Variable   eNB
    Show Text on Console   [Lock x2 link on ${bts_side} side and check alarms]
    Disallow Alarms Occurrence   x2_setup_to_gnb_failed

    Change X2 Link Status   bts=${bts_side}  action=locked

    Verify Alarms Status    ACTIVE
    ...                     ${X2_PARAMETERS}[x2LinkSupervisionTmr][value]min
    ...                     cell_problem_due_to_no_x2_link
    ...                     no_x2_link_for_specific_lte
    ...                     no_x2_link

    x2_474.Increase Counters
    ...    X2_SHUTDOWN_DETECTED

    Verify 4G Attach
    Check Average Tputs

    [Teardown]   Run Keywords
    ...          Show Text on Console   [Unlock x2 link, wait for onAir and alarms clearing]
    ...    AND   Run Keyword If   '${bts_side}' == 'gNB'   Change X2 Link Status   bts=gNB  action=unlocked
    ...    AND   Run Keyword If   '${bts_side}' == 'eNB'   Change X2 Link Status   bts=eNB  action=unlocked
    ...    AND   Wait Until Keyword Succeeds   240  30    verify_x2_link_status   enb_id=${lnbts_id}   expected_status=available
    ...    AND   Wait For BTS onAir State
    ...    AND   Verify Alarms Status    CLEARED
    ...                     10s
    ...                     cell_problem_due_to_no_x2_link
    ...                     no_x2_link_for_specific_lte
    ...                     no_x2_link
    ...    AND   disallow_all_alarms_except_of   ${allowed_alarms}


X2_LINK_PARTIAL_RESET
    ${scenario_alarms}   Prepare Scenario Alarms
    ...    no_x2_link_for_specific_lte
    ...    no_x2_link
    ...    cell_blocked

    Allow Alarms Occurrence
    ...    no_x2_link_for_specific_lte
    ...    no_x2_link
    ...    cell_blocked

    Show Text on Console   [Block all NR cells and wait for alarms occurring]
    block_all_nr_cells
    ${sctp_shutdown_tmr}   Set Variable   ${X2_PARAMETERS}[shutdownNogNBCellTmr][value] ${X2_PARAMETERS}[shutdownNogNBCellTmr][unit]
    Log To Console   \n Wait for SCTP link shutdown due to no gNB cell

    BuiltIn.Sleep   ${sctp_shutdown_tmr}
    verify_x2_link_status   enb_id=${lnbts_id}  expected_status=unavailable

    x2_474.Increase Counters
    ...    X2_SHUTDOWN_NO_GNB_CELL

    Verify Alarms Status    ACTIVE
    ...                     ${X2_PARAMETERS}[x2LinkSupervisionTmr][value]min
    ...                     no_x2_link_for_specific_lte
    ...                     no_x2_link
    ...                     cell_blocked

    Verify 4G Attach
    Check Average Tputs

    [Teardown]   Run Keywords
    ...          Show Text on Console   [Unblock all NR cells and wait for alarms clearing]
    ...    AND   unblock_all_nr_cells
    ...    AND   Wait Until Keyword Succeeds   240  30    verify_x2_link_status   enb_id=${lnbts_id}   expected_status=available
    ...    AND   Wait For BTS onAir State
    ...    AND   Verify Alarms Status    CLEARED
    ...                     10s
    ...                     no_x2_link_for_specific_lte
    ...                     no_x2_link
    ...                     cell_blocked
    ...    AND   disallow_all_alarms_except_of   ${allowed_alarms}


X2_LINK_ENB_NOT_ALLOWED_NO_CELL
    Prepare Scenario Alarms
    ...     no_x2_link
    ...     no_x2_link_for_specific_lte

    Allow alarm   fault_name=${TESTED_ALARMS}[no_x2_link][fault_name]
    Allow alarm   fault_name=${TESTED_ALARMS}[no_x2_link_for_specific_lte][fault_name]

    Show Text on Console   [Locking current eNB by setting fake allowed enb_id for all NR cells]
    set_allowed_enb_for_nsa_call   enb_id=40094
    Show Text on Console   [eNB LOCKED, wait for SCTP link shutdown due to no gNB cell, check alarms and verify traffic]

    BuiltIn.Sleep   ${X2_PARAMETERS}[shutdownNogNBCellTmr][value]min
    verify_x2_link_status   eNB_id=${enb_nrbts_id}  expected_status=unavailable

    increase_counters
    ...    X2_SHUTDOWN_NO_GNB_CELL

    wait_for_active_alarms   alarms=${scenario_alarms}   timeout=${X2_PARAMETERS}[x2LinkSupervisionTmr][value] min
    Log Alarm on Console   ACTIVE    no_x2_link  no_x2_link_for_specific_lte

    Verify 4G Attach
    Check Average Tputs

    Sleep Few Minutes To Generate More x2Setupreq

    [Teardown]   Run Keywords
    ...          Show Text on Console   [Unlocking eNB in progress...]
    ...    AND   set_allowed_enb_for_nsa_call
    ...    AND   Wait For BTS onAir State
    ...    AND   wait_for_inactive_alarms   ${scenario_alarms}
    ...    AND   Log Alarm on Console   CLEARED  no_x2_link  no_x2_link_for_specific_lte
    ...    AND   disallow_all_alarms_except_of   ${allowed_alarms}
    ...    AND   Show Text on Console   [eNB UNLOCKED, gNB onAir, verify NR traffic]


X2_LINK_SHUTDOWN_NO_TRAFFIC
    ${scenario_alarms}   Prepare Scenario Alarms
    ...     max_x2_links_reached

    # added as precondition to PR749447
    Show Text on Console   [Setup next x2 link, check number of links, then set maxNumX2Links=number-1 and check alarm]
    Start LTEemu and load config file
    Setup X2AP Link successfully
    ${x2_links_number}   check_active_x2_links_number

    Log To Console   \n x2 links: ${x2_links_number}, set maxNumX2Links: ${x2_links_number-1}]

    Allow Alarms Occurrence
    ...    max_x2_links_reached

    Update Parameter   param=maxNumX2Links  value=${x2_links_number-1}

    Verify Alarms Status    ACTIVE
    ...                     10s
    ...                     max_x2_links_reached

    ${no_traffic_tmr}   Set Variable   ${X2_PARAMETERS}[shutdownNoX2TrafficTmr][value]
    Show Text on Console   [Wait ${no_traffic_tmr} hour/s for SCTP link shutdown due to no x2 traffic and setup again despite maxNumX2Links setting]

    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   stop_tracing=NO
    ${check_before}   check_msg_occurrence   pcap_file=${logs_path}   msg=SHUTDOWN_COMPLETE*  shark_filter=sctp

    BuiltIn.Sleep   ${no_traffic_tmr} hour

    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   stop_tracing=NO
    ${check_after}   check_msg_occurrence   pcap_file=${logs_path}   msg=SHUTDOWN_COMPLETE*  shark_filter=sctp
    ${sctp_shutdown}   Evaluate  ${check_after} - ${check_before}
    Should Be Equal As Integers   ${sctp_shutdown}   1

    x2_474.Increase Counters
    ...    X2_SHUTDOWN_NO_TRAFFIC

    verify_x2_link_status   enb_id=40090  expected_status=available

    Log To Console   \n SCTP connection closed and reestablished again despite maxNumX2Links reached]  # PR547774

    [Teardown]    Run Keywords
    ...          Stop LTEemu
    ...    AND   Update Parameter   param=maxNumX2Links  value=${X2_PARAMETERS}[maxNumX2Links][value]
    ...    AND   Verify Alarms Status    CLEARED
    ...                     10s
    ...                     max_x2_links_reached
    ...    AND   disallow_all_alarms_except_of   ${allowed_alarms}


# ************************************SCENARIOS WITH LTEEMU************************************

X2_LINK_ENB_CONFUSION
    Prepare Scenario Alarms
    ...     transport_layer_failure

    # added as precondition to PR747568
    Show Text on Console   [Setup x2 link from lteemu]
    Start LTEemu and load config file
    ${x2_links_number_before}   check_active_x2_links_number
    Setup X2AP Link successfully
    ${x2_links_number}   check_active_x2_links_number
    Should Be Equal As Numbers   ${x2_links_number}   ${x2_links_number_before+1}
    Allow alarm   fault_name=${TESTED_ALARMS}[transport_layer_failure][fault_name]
    Stop LTEemu
    wait_for_active_alarm   fault_name=${TESTED_ALARMS}[transport_layer_failure][fault_name]
    Log Alarm on Console   ACTIVE  transport_layer_failure
    Show Text on Console   [Wait ${X2_PARAMETERS}[x2LinkReestabTmr][value] minutes to removed LTEENB instance and clear alarm]
    wait_for_inactive_alarm   fault_name=${TESTED_ALARMS}[transport_layer_failure][fault_name]
    ...                       timeout=${X2_PARAMETERS}[x2LinkReestabTmr][value] min
    Log Alarm on Console   CLEARED  transport_layer_failure
    ${x2_links_number}   check_active_x2_links_number
    Should Be Equal As Numbers   ${x2_links_number}   ${x2_links_number_before}
    disallow_all_alarms_except_of   ${allowed_alarms}

    Show Text on Console   [Setup X2 LINK with same eNB ID, in progress...]
    Start LTEemu and load config file   cfg_filename=cfg_lteemu_enb_id_duplicated.cfg
    Setup X2AP Link Failure

    increase_counters
    ...    ENDC_X2_SETUP_FAIL_CONFUSION

    [Teardown]    Run Keywords
    ...          Stop LTEemu
    ...    AND   disallow_all_alarms_except_of   ${allowed_alarms}


X2_LINK_ENDC_CONFIGURATION_UPDATE_FAILURE
    ${response_msg}   Evaluate   random.choice(['failure', 'error_indication', 'no_rsp'])  random

    Prepare Scenario Alarms
    ...     no_x2_link_for_specific_lte

    Show Text on Console   [Setup x2 link from lteemu]
    Start LTEemu and load config file
    ${x2_links_number_before}   check_active_x2_links_number
    Setup X2AP Link successfully
    ${x2_links_number}   check_active_x2_links_number
    Should Be Equal As Numbers   ${x2_links_number}   ${x2_links_number_before+1}

    Show Text on Console   [Lock NR Cell to simulate ${response_msg} in response for ENDC Cnfiguration Update]
    Set response with error for EN-DC Configuration Update   error_message=${response_msg}

    Allow alarm   fault_name=${TESTED_ALARMS}[no_x2_link_for_specific_lte][fault_name]

    change_cell_administrative_status   action=lock   pci=50

    ${updates_time}   Evaluate   (1 + ${X2_PARAMETERS}[maxX2EnDcCfUpRetry][value]) * ${X2_PARAMETERS}[x2EnDcCfUpRspTmr][value]
    ${time_link_close}   Evaluate   ${X2_PARAMETERS}[shutdownNogNBCellTmr][value] * 60

    Show Text on Console   [Wait ${updates_time}s for all ENDCCnfigurationUpdates (${X2_PARAMETERS}[maxX2EnDcCfUpRetry][value]) and sctp link close]
    BuiltIn.Sleep   ${updates_time}s

    Set Test Variable   ${alarm_name}   ${TESTED_ALARMS}[no_x2_link_for_specific_lte][fault_name]
    Show Text on Console   [Next wait ${X2_PARAMETERS}[x2LinkSupervisionTmr][value]min for ${alarm_name} alarm activation]
    wait_for_active_alarm   fault_name=${TESTED_ALARMS}[no_x2_link_for_specific_lte][fault_name]
    ...                     timeout=${X2_PARAMETERS}[x2LinkSupervisionTmr][value] min
    Log Alarm on Console   ACTIVE  no_x2_link_for_specific_lte

    check_if_counter_update_needed
    ...    X2_SHUTDOWN_NO_GNB_CELL
    ...    ${X2_PARAMETERS}[maxX2EnDcCfUpRetry][value]
    ...    ${X2_PARAMETERS}[x2EnDcCfUpRspTmr][value]
    ...    ${X2_PARAMETERS}[shutdownNogNBCellTmr][value]

    [Teardown]   Run Keywords
    ...          Show Text on Console   [NR cell unlocking in progres...]
    ...    AND   change_cell_administrative_status   action=unlock   pci=50
    ...    AND   AdminUtils.wait_for_all_cells_on_air_state
    ...    AND   Show Text on Console   [Wait ${X2_PARAMETERS}[x2LinkReestabTmr][value] minutes to removed LTEENB instance and clear alarm]
    ...    AND   wait_for_inactive_alarm   fault_name=${TESTED_ALARMS}[no_x2_link_for_specific_lte][fault_name]
    ...                              timeout=${X2_PARAMETERS}[x2LinkReestabTmr][value] min
    ...    AND   disallow_all_alarms_except_of   ${allowed_alarms}


X2_LINK_ERROR_INDICATION_SENT_TO_LTE
    # NO NEW ALARMS
    Show Text on Console   [Error Indication received from gNB in x2SetupRequest]
    Start LTEemu and load config file   cfg_filename=cfg_lteemu_error_indication_from_gnb.cfg
    Setup X2AP Link Error Indication
    Stop LTEemu    # if not stop x2SetupRequest constantly repeated

    [Teardown]    Wait To Next PM Interval If Needed


X2_LINK_ENB_NOT_SUPPORTED
    # NO NEW ALARMS, raz fault id 7308 na eNB, mozna sie o pr pokusic
    Show Text on Console   [Set home eNB ID format, failure message received from gNB in x2SetupRequest]
    Start LTEemu and load config file   cfg_filename=cfg_lteemu_home_enb_id.cfg
    Show Text on Console   [Removing all NRRELLTE objects in progress...]
    manage_nrrellte_objects   ${delta_files_path}del_nrrellte.json
    AdminUtils.wait_for_all_cells_on_air_state
    Setup X2AP Link Failure

    increase_counters
    ...    ENDC_X2_SETUP_FAIL_NOSUP

    [Teardown]   Run Keywords
    ...          Stop LTEemu
    ...    AND   Show Text on Console   [Adding all NRRELLTE objects in progress...]
    ...    AND   manage_nrrellte_objects   ${delta_files_path}add_nrrellte.json
    ...    AND   AdminUtils.wait_for_all_cells_on_air_state


X2_LINK_MAX_NUMBER_REACHED
    Prepare Scenario Alarms
    ...     max_x2_links_reached

    ${x2_links_number}   check_active_x2_links_number

    Show Text on Console   [Set maxNumX2Links = ${x2_links_number} and try to setup next x2 link]
    Start LTEemu and load config file

    Allow alarm   fault_name=${TESTED_ALARMS}[max_x2_links_reached][fault_name]
    set_parameter_value   param=maxNumX2Links  value=${x2_links_number}
    wait_for_active_alarm   fault_name=${TESTED_ALARMS}[max_x2_links_reached][fault_name]
    Log Alarm on Console   ACTIVE  max_x2_links_reached

    Setup X2AP Link Failure

    increase_counters
    ...    ENDC_X2_SETUP_FAIL_MAX_X2
    ...    X2_SHUTDOWN_MAX_X2_LINK

    [Teardown]   Run Keywords
    ...          Show Text on Console   [Setting default maxNumX2Links in progress...]
    ...    AND   set_parameter_value   param=maxNumX2Links  value=${X2_PARAMETERS}[maxNumX2Links][value]
    ...    AND   wait_for_inactive_alarms   ${scenario_alarms}
    ...    AND   Log Alarm on Console   CLEARED  max_x2_links_reached
    ...    AND   disallow_all_alarms_except_of   ${allowed_alarms}


X2_LINK_NO_X2_SETUP_REQ_AFTER_SCTP_CONNECTED
    Show Text on Console   [Setup SCTP connection without sending of x2SetupRequest]
    Start LTEemu and load config file
    Setup SCTP Connection Only
    Show Text on Console   [SCTP Link UP, wait ${X2_PARAMETERS}[enDcX2SetupReqTmr][value] sec (enDcX2SetupReqTmr) for x2SetupRequest]
    BuiltIn.Sleep   ${X2_PARAMETERS}[enDcX2SetupReqTmr][value]s

    increase_counters
    ...    ENDC_X2_SETUP_REQUEST_NOT_RCVD

    [Teardown]   Run Keywords
    ...    Stop LTEemu


X2_LINK_MAX_PARALLEL_HANDLING_NUMBER_REACHED
    Prepare Scenario Alarms
    ...     transport_layer_failure

    ${x2_links_number_before}   check_active_x2_links_number

    Show Text on Console   [Set maxParallelIncX2Setup = ${x2_links_number_before} and try to setup more than one x2 links]
    Start LTEemu and load config file

    set_parameter_value   param=maxParallelIncX2Setup  value=1

    Setup X2AP Links Simultaneously   enbs_number=2
    ${x2_links_number}   check_active_x2_links_number
    Should Be Equal As Numbers   ${x2_links_number}   ${x2_links_number_before+1}
    Show Text on Console   [Only ONE x2 link setup successfully]

    increase_counters
    ...    X2_SHUTDOWN_DETECTED

    [Teardown]   Run Keywords
    ...          Show Text on Console   [Setting default maxParallelIncX2Setup and kill lteemu in progress...]
    ...   AND    set_parameter_value   param=maxParallelIncX2Setup  value=${X2_PARAMETERS}[maxParallelIncX2Setup][value]
    ...   AND    Allow alarm   fault_name=${TESTED_ALARMS}[transport_layer_failure][fault_name]
    ...   AND    Stop LTEemu
    ...   AND    wait_for_active_alarm   fault_name=${TESTED_ALARMS}[transport_layer_failure][fault_name]
    ...   AND    Log Alarm on Console   ACTIVE  transport_layer_failure
    ...   AND    Show Text on Console   [Wait ${X2_PARAMETERS}[x2LinkReestabTmr][value] minutes to removed LTEENB instance and clear alarm]
    ...   AND    wait_for_inactive_alarm   fault_name=${TESTED_ALARMS}[transport_layer_failure][fault_name]
    ...                       timeout=${X2_PARAMETERS}[x2LinkReestabTmr][value] min
    ...   AND    Log Alarm on Console   CLEARED  transport_layer_failure
    ...   AND    disallow_all_alarms_except_of   ${allowed_alarms}


Stop LTEemu
    Stop LTEemu processes
    x2_474.Increase Counters   X2_SHUTDOWN_DETECTED


Get BTS Configuration and Setup before Test
    Show Text on Console   [Update and next get BTS Settings]
    Update Parameter   param=x2LinkSupervisionTmr   value=1    # due to changes to default value during migration PR821611
    #${x2c_gnb_ip}  ${x2c_enb_ip}   get_x2_settings_from_scf
    get_x2_settings_from_scf
    #Set Test Variable   ${x2c_gnb_ip}
    #Set Test Variable   ${x2c_enb_ip}
    Set Test Variable   ${lnbts_id}   ${nrbts_id}
    x2_474.prepare_startup_values


Start Watching Alarms
    ${allowed_alarms}   prepare_alarms
    Set Test Variable   ${allowed_alarms}
    watchdog.Watch alarms    allowed_alarms=${allowed_alarms}   interval=5 sec


Prepare Scenario Alarms
    [Arguments]   @{alarms}
    ${scenario_alarms}   create_scenario_alarms   ${alarms}
    [Return]   ${scenario_alarms}


Allow Alarms Occurrence
    [Arguments]   @{alarms}
    FOR  ${alarm}  IN  @{alarms}
        watchdog.allow_alarm   fault_name=${TESTED_ALARMS}[${alarm}][fault_name]
    END


Disallow Alarms Occurrence
    [Arguments]   @{alarms}
    FOR  ${alarm}  IN  @{alarms}
        watchdog.disallow_alarm   fault_name=${TESTED_ALARMS}[${alarm}][fault_name]
    END


Verify Alarms Status
    [Arguments]   ${status}  ${timeout}  @{alarms}
    ${text_color}   Set Variable If   '${status}' == 'ACTIVE'   ${RED}  ${BLUE}
    ${action_prefix}   Set Variable If   '${status}' == 'ACTIVE'   ${EMPTY}  in
    FOR  ${alarm}  IN  @{alarms}
        Run Keyword If   '${status}' == 'ACTIVE'
        ...    watchdog.wait_for_active_alarm   fault_name=${TESTED_ALARMS}[${alarm}][fault_name]   timeout=${timeout}
        Run Keyword If   '${status}' == 'CLEARED'
		...    watchdog.wait_for_inactive_alarm   fault_name=${TESTED_ALARMS}[${alarm}][fault_name]   timeout=${timeout}
        Show Text on Console   ${SPACE*3}FAULT ID: ${TESTED_ALARMS}[${alarm}][fault_id] is ${status}   colour=${text_color}  show_timestamp=no
    END


Log Alarm on Console
    [Arguments]   ${status}  @{alarms}
    FOR  ${alarm}  IN  @{alarms}
        ${text_color}   Set Variable If   '${status}' == 'ACTIVE'   ${RED}  ${BLUE}
        Show Text on Console   ${SPACE*3}FAULT ID: ${TESTED_ALARMS}[${alarm}][fault_id] is ${status}   colour=${text_color}  show_timestamp=no
    END


Attach UE And Start Data Transfer In Both Directions
    [Arguments]   ${ue_alias}=UE_1
    Show Text on Console   [Attach ${ue_alias} and run traffic]
    Require Ue    ${ue_alias}  capabilities=${ue_alias}
    enable_band_config   ${ue_alias}   NSA_b2_n71
    # UE Rebooting  ${ue_alias}
    Attach Ue     ${ue_alias}
    Verify 5G NSA Attach

    ${tput_start_time}   Get Time  epoch
    Set Test Variable   ${tput_start_time}
    FOR  ${direction}  IN  @{tput_directions}
        Start Data Transfer  dt_name=DT_${direction}  ue_alias=${ue_alias}  direction=${direction}  duration=${traffic_duration}
        ...                  protocol=udp  throughput=${tput_${direction}}Mbits/sec  packet_size=1450
    END
    BuiltIn.Sleep   10s    wait traffic started and stabilized
    Check Data Transfer Is Alive   DT_DL
    Check Data Transfer Is Alive   DT_UL
    Log To Console   \n UDP traffic in both directions started
    Check Average Tputs


Sleep Few Minutes To Generate More x2Setupreq
    ${time}   Evaluate   random.randint(1,3)  random
    Show Text on Console   [Wait ${time} minutes to catch more x2SetupRequest messages initiated by LTE]
    BuiltIn.Sleep   ${time}min


Wait For BTS onAir State
    AdminUtils.wait_for_all_cells_on_air_state
    Wait Until Keyword Succeeds   30  10   Verify 5G NSA Attach


Wait To Next PM Interval If Needed
    ${check_time}   Get Time   epoch
    ${elapsed_time}    Evaluate   ${check_time} - ${pm_start_time}
    ${time_to_next_pm_interval}   Evaluate   45 - ${elapsed_time}
    Run Keyword If   ${elapsed_time} < 45   BuiltIn.Sleep   ${time_to_next_pm_interval}s


Check Average Tputs
    [Arguments]   ${period}=${30}
    Log To Console   \n Check average tput from next ${period} seconds
    Check Data Transfer Is Alive   DT_DL
    Check Data Transfer Is Alive   DT_UL
    BuiltIn.Sleep   ${period}  run traffic few second before verification

    FOR  ${direction}  IN  @{tput_directions}
        ${avg_tput}   Get Average Throughput   dt_name=DT_${direction}  from_last=${period}
        ${avg_tput}   Evaluate   ${avg_tput} / 1000
        ${avg_tput}   Evaluate   "%.2f" % ${avg_tput}
        Log To Console   ${SPACE} ${direction} TPUT: ${avg_tput} Mbits/sec
    END
