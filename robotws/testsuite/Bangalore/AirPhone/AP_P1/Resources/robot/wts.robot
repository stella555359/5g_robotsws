*** Settings ***
Documentation    This contains basic wts related keywords which are needed to run the Airphone TC.
...              :author Ashok Santhanam

Library    String
Library    ute_wtssim
Library    OperatingSystem
Library    ../Python/bearer_utilities.py   WITH NAME   bearer_utilities
Resource   ../Variables/Common_Variables.robot

*** Variables ***
${NOKIA_PASS}              oZPS0POrRieRtu
${MAX_PACKET_LOST}    50    # should in percentage
${egate_console_log}    /opt/wts/latest/egate_console.log

*** Keywords ***
Start and configure WTS
    [Arguments]    ${wts_cfg_path}=${SETUP_CFG_PATH}    ${edaemon_port}=${EDAEMON_PORT}    ${egate_port}=${EGATE_PORT}
    ${WTS_ACTIVE}    Run keyword and return status    Start WTS Applications    cfg_file=${wts_cfg_path}
    ...    edaemon_ports=${edaemon_port}    egate_port=${egate_port}    timeout=300
    Set Suite Variable   ${WTS_ACTIVE}
    Ensure Egate state

Ensure Egate state
    Wait Until Keyword Succeeds
    ...    120sec
    ...    15sec
    ...    Execute Egate Command    state_sim_disp    pass_regexp=The state is ACTIVE   timeout=15

Set WTS Default Log Level
    [Documentation]    To change sim debug log level via egate command
    [Arguments]    ${level}=4
    Execute Egate Command    cmd=sim_debug_log level=${level}    timeout=2s

Establish X2 link
    [Arguments]   ${enb_id}   ${gnb_id}
    Execute Egate Command    enb_x2_link_up enb\=${enb_id} target\=${gnb_id}    pass_regexp=is up      timeout=300

Ensure cell setup completed
    [Arguments]   ${AP_IP}    ${cells}=${NUMBER_OF_CELLS}
    FOR    ${cell_id}   IN RANGE    ${cells}
        ${cell_setup_string}=    Catenate    Cell Setup completed     for \\[CELL_ID:${cell_id + 1}\\]
        ${rc}=    Run and return rc
        ...       sshpass -p ${NOKIA_PASS} ssh toor4nsn@${AP_IP} 'grep -i "${cell_setup_string}" /tmp/startup_l3.log'
        Should be Equal as Integers     ${rc}    0    msg=Cell Setup Failed for cell:${cell_id}.
    END

Ensure UE SIB Decoding Is Successful
    [Arguments]    ${cells}=${NUMBER_OF_CELLS}
    Execute Egate Command    cmd=sim_log_set flush    timeout=1s
    FOR    ${cell_id}   IN RANGE   ${cells}
        ${sib_decoding_string}=    Catenate    cell ${cell_id + 1}:     SystemInformationBlockType1
        ${rc}    ${output}    Run And Return Rc And Output    grep -i "${sib_decoding_string}" /opt/wts/latest/egate_console.log
        Should be Equal as Integers     ${rc}    0    msg=UE SIB Decoding Verification has Failed for cell:${cell_id}.
    END

Ensure UE attach passed
    [Arguments]   ${AP_IP}
    ${rc}=    Run and return rc
    ...       sshpass -p ${NOKIA_PASS} ssh toor4nsn@${AP_IP} 'grep -i "Sm User Ue Connection Established Ind message status OK" /tmp/startup_l3.log'
    Should be Equal as Integers     ${rc}     0


Verify if average DL is correct
    [Arguments]   ${bearer}   ${ue_id}   ${limit}    ${dc_cell_group}=scg
    ${out}=    Execute Egate Command and wait for data    bearer_stats id\=${bearer} ue\=${ue_id} dir\=dl dc_cell_group\=${dc_cell_group}
    Create File       ${OUTPUT_DIR}/dl_${bearer}.txt    ${out}
    ${average_dl}=      Run    cat ${OUTPUT_DIR}/dl_${bearer}.txt | grep -m 1 'Average data rate' | awk '{print $4}'

    ${current_date}=    Get Current Date
    Log    ${current_date} : AVG DL : ${average_dl}    WARN

    Should Be True    ${average_dl} > ${limit}
    [Return]    ${average_dl}

Verify if average UL is correct
    [Arguments]   ${bearer}   ${ue_id}   ${limit}    ${dc_cell_group}=mcg
    ${out}=    Execute Egate Command and wait for data    bearer_stats id\=${bearer} ue\=${ue_id} dir\=ul dc_cell_group\=${dc_cell_group}
    Create File       ${OUTPUT_DIR}/ul_${bearer}.txt    ${out}
    ${average_ul}=      Run    cat ${OUTPUT_DIR}/ul_${bearer}.txt | grep -m 1 'Average data rate' | awk '{print $4}'

    ${current_date}=    Get Current Date
    Log    ${current_date} : AVG UL : ${average_ul}    WARN

    Should Be True    ${average_ul} > ${limit}
    [Return]    ${average_ul}

Add Bearer
    [Arguments]   ${ue_id}   ${bearer_id}   ${filter}=0
    ...           ${precedence}=0   ${pass_regexp}=created   ${timeout}=30
    Execute Egate Command    bearer_add ue\=${ue_id} id\=${bearer_id} filter\=${filter} precedence\=${precedence}
    ...                      pass_regexp=${pass_regexp}   timeout=${timeout}
    [Return]

SGNB Addition For Bearer
   [Arguments]    ${ue_id}   ${target_gnb}   ${target_cells}   ${bearer}   ${type}=split_scg
   ...            ${pass_regexp}=reported successful RA
   ${output}    Execute Egate Command
   ...    ue_dc_enb_start ue\=${ue_id} target_gnb\=${target_gnb} target_cells\=${target_cells} bearer\=${bearer} type\=${type}
   ...    pass_regexp=${pass_regexp}
   [Return]    ${output}

UE Attach
   [Arguments]   ${ue_id}   ${profile_id}   ${pass_regexp}=UE IS ACTIVE    ${timeout}=30
   Execute Egate Command    ue_attach id\=${ue_id} profile\=${profile_id}    pass_regexp=${pass_regexp}    timeout=${timeout}

Start Uplink Data Transfer
    [Documentation]     Start data transfer in the uplink
    ...                 Modified Date: 09-06-2020
    ...                 Last Modified by: merin.varghe@nokia.com
   [Arguments]   ${bearer}   ${ue_id}   ${speed}=${DEFAULT_DATARATE}
   Execute Egate Command    trf_data_start id\=${bearer} ue\=${ue_id} dir\=ul mbps\=${speed}
   [Return]

Start Downlink Data Transfer
    [Documentation]     Start data transfer in the downlink
    ...                 Modified Date: 09-06-2020
    ...                 Last Modified by: merin.varghe@nokia.com
   [Arguments]   ${bearer}   ${ue_id}   ${speed}=${DEFAULT_DATARATE}
   Execute Egate Command    trf_data_start id\=${bearer} ue\=${ue_id} dir\=dl mbps\=${speed}
   [Return]

Check average data transfer
    [Documentation]     Check average data transfer in the uplink and downlink
    ...                 Modified Date: 09-06-2020
    ...                 Last Modified by: merin.varghe@nokia.com
    [Arguments]   ${bearer}   ${ue_id}  ${speed}=${DEFAULT_DATARATE}   ${dl_dc_cell_group}=scg   ${ul_dc_cell_group}=mcg
    ${limit}=   Get Throughput Limit   ${speed}
    Verify if average DL is correct   bearer=${bearer}   ue_id=${ue_id}   limit=${limit}
    ...                               dc_cell_group=${dl_dc_cell_group}
    Verify if average UL is correct   bearer=${bearer}   ue_id=${ue_id}   limit=${limit}
    ...                               dc_cell_group=${ul_dc_cell_group}

Get Throughput Limit
    [Documentation]     Get Throughput Limit
    ...                 Modified Date: 09-06-2020
    ...                 Last Modified by: merin.varghe@nokia.com
    [Arguments]   ${speed}=${DEFAULT_DATARATE}
    ${limit}=   bearer_utilities.get_throughput_limit_bits_with_deviation   speed=${speed}
    [Return]    ${limit}

UE Detach
   [Arguments]   ${ue_id}   ${pass_regexp}=detached
   Execute Egate Command     ue_detach id\=${ue_id}    pass_regexp=${pass_regexp}

Release ENDC Bearer
   [Arguments]   ${ue_id}   ${bearer}   ${cause}=RN_action_desirable_for_radio_reasons
   ...           ${pass_regexp}=Successfully reconfigured dual connectivity   ${timeout}=10
   Execute Egate Command     enb_ue_dc_release ue\=${ue_id} bearer\=${bearer} by\=enb cause\=${cause}
   ...                       pass_regexp=${pass_regexp}   timeout=${timeout}
   sleep    10s    reason=sleep introduced as a solution for enb crash occuring post ENDC cmd

Stop All Data Transfer
   [Arguments]   ${ue_id}   ${bearer}
   Stop UL data transfer   ${ue_id}   ${bearer}
   Stop DL data transfer   ${ue_id}   ${bearer}
   [Return]

Modify ENDC Add Bearer
   [Arguments]   ${ue_id}   ${bearer}   ${cause}=RN_CauseRadioNetwork_unspecified
   ...           ${pass_regexp}=Successfully reconfigured dual connectivity
   Execute Egate Command And Wait For Data    enb_ue_dc_modify ue\=${ue_id} bearer_to_add\=${bearer} by\=enb cause\=${cause} type\=split_scg
   ...    pass_regexp=${pass_regexp}
   [Return]

Modify ENDC Release Bearer
   [Arguments]   ${ue_id}   ${bearer}   ${cause}=RN_CauseRadioNetwork_unspecified
   Execute Egate Command    enb_ue_dc_modify ue\=${ue_id} bearer_to_release\=${bearer} by\=enb cause\=${cause} type\=split_scg
   [Return]

Start WTS And Extablish X2 Link
   Start WTS With Configuration
   Establish X2 link And Wait For Cell Setup

Establish X2 link And Wait For Cell Setup
    Establish X2 link   enb_id=1   gnb_id=${GNB_ID}
    Sleep    15sec
    Check if cell setup completed

Check if cell setup completed
    Wait Until Keyword Succeeds    180sec    15sec    Ensure cell setup completed   ${AP_IP}

Verify if attach passed
    Wait Until Keyword Succeeds    60sec    5sec    Ensure UE attach passed   ${AP_IP}

Start Data Transfer And Verify Throughput
    [Documentation]     Start data transfer in the uplink and downlink and check throughput
    ...                 Modified Date: 09-06-2020
    ...                 Last Modified by: merin.varghe@nokia.com
    [Arguments]   ${bearer}   ${ue_id}   ${speed}=${DEFAULT_DATARATE}   ${timeout}=${DEFAULT_DATATIMEOUT}   ${dl_dc_cell_group}=scg
    ...           ${ul_dc_cell_group}=mcg
    Start Uplink Data Transfer   ${bearer}   ${ue_id}   ${speed}
    Start Downlink Data Transfer   ${bearer}   ${ue_id}   ${speed}
    Sleep   ${timeout}
    Check average data transfer   ${bearer}   ${ue_id}   ${speed}   ${dl_dc_cell_group}
    ...                           ${ul_dc_cell_group}

Start WTS With Configuration
    Start and configure WTS   ${SETUP_CFG_PATH}

Start Uplink Data Transfer and verify throughput
    [Documentation]     Start data transfer in the uplink and check throughput
    ...                 Modified Date: 09-06-2020
    ...                 Last Modified by: merin.varghe@nokia.com
    [Arguments]   ${bearer}   ${ue_id}   ${speed}=${DEFAULT_DATARATE}   ${timeout}=${DEFAULT_DATATIMEOUT}
    wts.Start Uplink Data Transfer   ${bearer}   ${ue_id}   ${speed}
    Sleep   ${timeout}
    ${limit}=   Get Throughput Limit   ${speed}
    Verify if average UL is correct   bearer=${bearer}   ue_id=${ue_id}   limit=${limit}

Start Downlink Data Transfer and verify throughput
    [Documentation]     Start data transfer in the downlink and check throughput
    ...                 Modified Date: 09-06-2020
    ...                 Last Modified by: merin.varghe@nokia.com
    [Arguments]   ${bearer}   ${ue_id}   ${speed}=${DEFAULT_DATARATE}   ${timeout}=${DEFAULT_DATATIMEOUT}
    wts.Start Downlink Data Transfer   ${bearer}   ${ue_id}   ${speed}
    Sleep   ${timeout}
    ${limit}=   Get Throughput Limit   ${speed}
    Verify if average DL is correct   bearer=${bearer}   ue_id=${ue_id}   limit=${limit}

Stop UL data transfer
   [Arguments]   ${ue_id}   ${bearer}
   Execute Egate Command   trf_data_stop ue\=${ue_id} id\=${bearer} dir\=ul

Stop DL data transfer
   [Arguments]   ${ue_id}   ${bearer}
   Execute Egate Command   trf_data_stop ue\=${ue_id} id\=${bearer} dir\=dl

Get Packets Sent And Received
    [Arguments]   ${bearer}   ${ue_id}   ${dc_cell_group}
    ${out}=    Execute Egate Command and wait for data    bearer_stats id\=${bearer} ue\=${ue_id} dc_cell_group\=${dc_cell_group}
    Create File    ${OUTPUT_DIR}/bearer_stats_${dc_cell_group}.txt    ${out}
    ${total_pkts_sent}=   Run    cat ${OUTPUT_DIR}/bearer_stats_${dc_cell_group}.txt | grep -i 'Total packets sent' | awk '{print $4}' | head -1
    ${total_pkts_received}=   Run
    ...                       cat ${OUTPUT_DIR}/bearer_stats_${dc_cell_group}.txt | grep -i 'Total packets received' | awk '{print $4}' | tail -1
    [Return]    ${total_pkts_sent}    ${total_pkts_received}

Start EGATE Logs
    Execute Egate Command    cmd=sim_log_set max_file_num=1    timeout=1s
    Execute Egate Command    cmd=sim_log_set log_to_file=off    timeout=1s
    Execute Egate Command    cmd=sim_log_set log_to_file=on    timeout=1s
    Execute Egate Command    cmd=info    timeout=1s

Attach UE and Data Transfer
    [Arguments]    ${ue_id}=1    ${profile_id}=1
    UE Attach    ue_id=${ue_id}    profile_id=${profile_id}
    Start Traffic Uplink And Downlink

Start Traffic Uplink And Downlink
    [Documentation]     Start data transfer in the uplink and downlink
    ...                 Modified Date: 09-06-2020
    ...                 Last Modified by: merin.varghe@nokia.com
    [Arguments]    ${ue_id}=1    ${bearer}=2    ${speed}=${DEFAULT_DATARATE}   ${timeout}=${DEFAULT_DATATIMEOUT}
    Start Uplink Data Transfer    ${bearer}    ${ue_id}    ${speed}
    Start Downlink Data Transfer    ${bearer}    ${ue_id}    ${speed}
    Sleep   ${timeout}

Add Bearer and start traffic
    [Arguments]    ${ue}=1    ${bearer}=3    ${timeout}=${DEFAULT_DATATIMEOUT}
    Add Bearer    ue_id=${ue}    bearer_id=${bearer}    filter=${bearer}    precedence=${bearer}
    Start Traffic Uplink And Downlink    bearer=${bearer}    timeout=${timeout}

Get UE bearers
    [Arguments]    ${ue_id}=1
    Execute Egate Command and wait for data    cmd=bearer_disp ue=${ue_id} at=enb

Get Bearer Stats
    [Arguments]    ${ue_id}=1    ${bearer}=2    ${dir}=dl    ${dc_cell_group}=mcg
    ${out}    Execute Egate Command and wait for data    cmd=bearer_stats ue=${ue_id} id=${bearer} dir=${dir} dc_cell_group=${dc_cell_group}
    [Return]    ${out}

Modify ENB Sim Parameters Online
    [Arguments]    ${enb}=1    ${x2_sctp_nodelay}=on
    Execute Egate Command    cmd=enb_param id=${enb} x2_sctp_nodelay=${x2_sctp_nodelay}    timeout=1s
    Execute Egate Command    cmd=enb_param id=${enb}    timeout=1s

Modify ENB dual Connectivity Parameters
    [Arguments]    ${enb}=1    &{kwargs}
    ${mandatory_args}    Set variable    id=${enb}
    ${final_args}    Set Final args list    ${mandatory_args}    &{kwargs}
    Execute Egate Command    cmd=enb_endc_param ${final_args}    timeout=1s

Trigger MENB Failure Scenario
    [Arguments]    ${enb}=1    ${menb_failure_scenario}=no_menb_failure_scenario
    Execute Egate Command    cmd=enb_endc_param id=${enb} menb_failure_scenario=${menb_failure_scenario}    timeout=1s
    Execute Egate Command    cmd=enb_endc_param id=${enb}    timeout=1s

Trigger MENB Forced Scenario
    [Arguments]    ${ue}=1    ${menb_forced_scenario}=none
    Execute Egate Command    cmd=ue_sgnb_mod_param id=${ue} menb_forced_scenario=${menb_forced_scenario}    timeout=1s
    Execute Egate Command    cmd=ue_sgnb_mod_param id=${ue}    timeout=1s

Trigger Abnormal Scenario
    [Arguments]    ${ue}=1    ${abnormal_scenario}=disable
    Execute Egate Command    cmd=ue_sgnb_mod_param id=${ue} abnormal_scenario=${abnormal_scenario}    timeout=1s
    Execute Egate Command    cmd=ue_sgnb_mod_param id=${ue}    timeout=1s

Configure RRC Reconfig Param Rules
    [Arguments]    ${ue}=1    ${rrc_delay}=0
    Execute Egate Command    cmd=ue_rrc_reconf_param id=${ue} if_contains=any action=none delay=${rrc_delay}    timeout=1s
    Execute Egate Command    cmd=ue_rrc_reconf_param id=${ue}    timeout=1s
    Execute Egate Command    cmd=ue_rrc_reconf_param id=${ue} if_contains=any action=none delay=${rrc_delay}    timeout=1s

Verify Packet Loss
    [Arguments]    ${ue}=1    ${bearer}=2    ${direction}=dl    ${dc_cell_group}=mcg
    ${bearer_stats}=    Get Bearer Stats    ue_id=${ue}    bearer=${bearer}    dir=${direction}    dc_cell_group=${dc_cell_group}
    ${match}    ${packet_lost}=    Should Match Regexp    ${bearer_stats}    Total packets lost +(\\d+) +\\r
    Should Be True    ${packet_lost} < ${MAX_PACKET_LOST}

Collect EGATE Logs
    [Documentation]    This keyword is used to collect egate_console.log from the /opt/wts/latest/ folder
    ...                This is collected in the Test Log Folder
    ...                Modified Date: 01-Jun-2020
    ...                Last Modified by: gopalakrishnan.n@nokia.com
    ${test_log_path}    log_store.get_test_log_folder
    Execute Egate Command    cmd=sim_log_set flush    timeout=1s
    Run Keyword And Ignore Error    Copy File    ${WTS_INSTALL_PATH}/egate_console.log    ${test_log_path}

Stop Traffic
    [Arguments]    ${ue}=1
    Execute Egate Command and wait for data    cmd=trf_data_stop ue=${ue}    pass_regexp=Traffic was stopped

Modify ENDC Bearer Update Bit Rate
    [Arguments]   ${ue_id}   ${bearer}   ${throughput}   ${cause}=RN_improve_user_bit_rate
    ...           ${pass_regexp}=Successfully reconfigured dual connectivity
    Execute Egate Command    enb_ue_dc_modify ue\=${ue_id} bearer_to_modify\=${bearer} by\=enb cause\=${cause} ambr\=${throughput}
    ...                      pass_regexp=${pass_regexp}

Stop Sim
    Execute Egate Command   stop_sim

Update Enb Param with X2AP ID Extension
    [Arguments]   ${ue_id}   ${extension}
    Execute Egate Command    enb_param ue\=${ue_id} extend_enb_ue_x2ap_id\=${extension}

Trigger Radio Link Failure
    [Arguments]    ${ue_id}    ${failure_reason}    ${target}    ${pass_regexp}
    Execute Egate Command    ue_dc_rlf ue\=${ue_id} failure_type\=${failure_reason} at\=${target}
    ...                      pass_regexp=${pass_regexp}

Check And Kill Simulator Process
    [Documentation]    This keyword is used to check status of sim_enb process and kill the process if it is still running
    ...                This can be used in scenarios where process does not get terminated even though teardown has been done
    ...                Modified Date: 02-Jun-2020
    ...                Last Modified by: ramya.2.k@nokia.com
    Wait For Process Teardown
    ${rc}    ${op}    Run And Return Rc And Output     pgrep sim_enb
    Run Keyword If    "${op}"!="${EMPTY}"    Kill Simulator Process    ${op}
    ${rc}    ${op}    Run And Return Rc And Output     pgrep sim_upf
    Run Keyword If    "${op}"!="${EMPTY}"    Kill Simulator Process for upf    ${op}

Kill Simulator Process
    [Arguments]    ${pid}
    Run And Return Rc And Output    sudo kill -9 ${pid}
    Log    Killed sim_enb process manually !    WARN

Wait For Process Teardown
    Sleep    3s

Activate UE Test Mode
    [Arguments]    ${testmode}    ${ue_id}=1    ${profile_index}=0
    Execute Egate Command    cmd=ue_testmode_set id=${ue_id} testmode=${testmode} action=activate profile_index=${profile_index}

Activate Forced DTX Test Mode
    [Arguments]    ${ue_id}=1    ${profile_index}=0
    Activate UE Test Mode    testmode=forced_dtx    ue_id=${ue_id}    profile_index=${profile_index}

Activate PHR Override Test Mode
    [Arguments]    ${ue_id}=1    ${profile_index}=0
    Activate UE Test Mode    testmode=phr_override    ue_id=${ue_id}    profile_index=${profile_index}

Form egate command args
    [Arguments]    &{kwargs}
    ${items}=    Get Dictionary items    ${kwargs}    sort_keys=False
    ${cmd_args}    Set Variable    ${EMPTY}
    FOR    ${key}    ${value}    IN    @{items}
        ${cmd_args}=    Catenate    SEPARATOR=${SPACE}    ${cmd_args}    ${key}=${value}
    END
    [Return]    ${cmd_args}

Set Final args list
    [Arguments]    ${mandatory_args}    &{kwargs}
    ${optional_args}    Run Keyword If    "${kwargs}" != "${EMPTY}"
    ...    Form egate command args    &{kwargs}    ELSE    Set Variable    ${EMPTY}
    ${final_args}    Run Keyword If    "${optional_args}" != "${EMPTY}"    Catenate
    ...    SEPARATOR=${SPACE}    ${mandatory_args}    ${optional_args}    ELSE
    ...    Set Variable    ${mandatory_args}
    [Return]    ${final_args}

Ensure UE Register Is Successful
    [Arguments]    ${ue_id}    &{kwargs}
    ${mandatory_args}    Set variable    id=${ue_id}
    ${final_args}    Set Final args list    ${mandatory_args}    &{kwargs}
    Execute Egate Command And Wait For Data    cmd=ue_register ${final_args}    timeout=180s
    ...    pass_regexp=.*REGISTRATION COMPLETE.*

Ensure Set PDU Param Is Successful
    [Arguments]    ${ue_id}    ${pdu_id}    &{kwargs}
    ${mandatory_args}    Catenate    SEPARATOR=${SPACE}    ue=${ue_id}    pdu=${pdu_id}
    ${final_args}    Set Final args list    ${mandatory_args}    &{kwargs}
    Execute Egate Command    cmd=set_pdu_param ${final_args}

Ensure UE PDU Session Setup Is Successful
    [Arguments]    ${ue_id}    ${pdu_id}    ${gw_id}    ${pass_regexp}=Initial Context Setup Successful    &{kwargs}
    ${mandatory_args}    Catenate    SEPARATOR=${SPACE}    pdu=${pdu_id}    ue=${ue_id}    gw=${gw_id}
    ${final_args}    Set Final args list    ${mandatory_args}    &{kwargs}
    ${output}    Execute Egate Command and wait for data    cmd=ue_pdu_session_setup ${final_args}
    ...    timeout=180s    pass_regexp=${pass_regexp}
    [Return]    ${output}

Start Traffic
    [Arguments]    ${ue_id}    ${dir}    &{kwargs}
    ${mandatory_args}    Catenate    SEPARATOR=${SPACE}    ue=${ue_id}    dir=${dir}
    ${final_args}    Set Final args list    ${mandatory_args}    &{kwargs}
    Execute Egate Command    cmd=trf_data_start ${final_args}

Start Traffic With Regex Check
    [Arguments]    ${ue_id}    ${dir}    ${pass_regex}    ${timeout}=280s    &{kwargs}
    ${mandatory_args}    Catenate    SEPARATOR=${SPACE}    ue=${ue_id}    dir=${dir}
    ${final_args}    Set Final args list    ${mandatory_args}    &{kwargs}
    Execute Egate Command And Wait For Data    cmd=trf_data_start ${final_args}   timeout=${timeout}
    ...    pass_regexp=${pass_regex}

Stop UE Traffic
    [Arguments]    ${ue_id}    &{kwargs}
    ${mandatory_args}    Set variable    ue=${ue_id}
    ${final_args}    Set Final args list    ${mandatory_args}    &{kwargs}
    Execute Egate Command    cmd=trf_data_stop ${final_args}

Stop UE Traffic With Regex Check
    [Arguments]    ${ue_id}    ${pass_regex}    &{kwargs}
    ${mandatory_args}    Set variable    ue=${ue_id}
    ${final_args}    Set Final args list    ${mandatory_args}    &{kwargs}
    Execute Egate Command And Wait For Data    cmd=trf_data_stop ${final_args}   timeout=10s    pass_regexp=${pass_regex}

Capture UE Stats
    [Arguments]    ${ue_id}    &{kwargs}
    ${mandatory_args}    Set variable    id=${ue_id}
    ${final_args}    Set Final args list    ${mandatory_args}    &{kwargs}
    ${ue_stats_output}    Execute Egate Command and wait for data    cmd=ue_stats_nr ${final_args}
    ...    pass_regexp=Throughput
    [Return]    ${ue_stats_output}

Capture UE Stats for L4S
    [Arguments]    ${ue_id}    &{kwargs}
    ${mandatory_args}=    Create Dictionary    id=${ue_id}
    ${all_args}=    Merge Dictionaries    ${mandatory_args}    &{kwargs}
    ${final_args}=    Convert Dict To CLI Args    ${all_args}
    ${ue_stats_output}=    Execute Egate Command and wait for data
    ...    cmd=ue_stats_nr ${final_args}
    ...    pass_regexp=Throughput
    [Return]    ${ue_stats_output}

Merge Dictionaries
    [Arguments]    ${dict1}    &{dict2}
    ${result}=    Copy Dictionary    ${dict1}
    FOR    ${key}    ${value}    IN    &{dict2}
        Set To Dictionary    ${result}    ${key}=${value}
    END
    [Return]    ${result}

Convert Dict To CLI Args
    [Arguments]    ${dict}
    ${args}=    Create List
    FOR    ${key}    ${value}    IN    &{dict}
        ${pair}=    Set Variable    ${key}=${value}
        Append To List    ${args}    ${pair}
    END
    ${arg_string}=    Catenate    SEPARATOR=${SPACE}    @{args}
    [Return]    ${arg_string}

Ensure UE PDU Session Release Is Successful
    [Arguments]    ${ue_id}    ${pdu_id}    ${pass_regexp}=rrcReconfigurationComplete    &{kwargs}
    ${mandatory_args}    Catenate    SEPARATOR=${SPACE}    pdu=${pdu_id}    ue=${ue_id}
    ${final_args}    Set Final args list    ${mandatory_args}    &{kwargs}
    Execute Egate Command and wait for data    cmd=ue_pdu_session_release ${final_args}
    ...   timeout=10s    pass_regexp=${pass_regexp}

Ensure UE Deregister Is Successful
    [Arguments]    ${ue_id}    ${pass_regexp}=UE Context Release Complete    &{kwargs}
    ${mandatory_args}    Set variable    id=${ue_id}
    ${final_args}    Set Final args list    ${mandatory_args}    &{kwargs}
    Execute Egate Command and wait for data    cmd=ue_deregister ${final_args}
    ...    pass_regexp=${pass_regexp}

Ensure NG Link is Up
    [Arguments]    ${amf_id}=1    ${gnb_id}=2    ${type}=link_info
    Wait Until Keyword Succeeds    360s    60s    Execute Egate Command and wait for data    cmd=amf_disp id=${amf_id} type=${type} gnb=${gnb_id}
    ...    timeout=60s    pass_regexp=NG primary peer address.*up

Ensure Address Distribution Is Successful
    Execute Egate Command    cmd=sim_log_set flush    timeout=1s
    ${rc}=    Run and return rc    grep -i "Address Distribution is complete" ${egate_console_log}
    Should be Equal as Integers     ${rc}    0    msg=Address Distribution is complete message did not appear.

Capture Bearer Stats
    [Arguments]    ${ue_id}    &{kwargs}
    ${mandatory_args}    Set variable    ue=${ue_id}
    ${final_args}    Set Final args list    ${mandatory_args}    &{kwargs}
    ${bearer_stats_output}    Execute Egate Command and wait for data    cmd=bearer_stats ${final_args}
    ...    pass_regexp=L3 stats for internal traffic
    [Return]    ${bearer_stats_output}

Ensure Scell Activation Is Successful
    ${activation_message}=    Set Variable    SCellIndex [[\:digit\:]]* activated successfully
    ${rc}=    Run and return rc    grep -i "${activation_message}" /opt/wts/latest/egate_console.log
    Run Keyword And Ignore Error    Should be Equal as Integers     ${rc}    0    msg=SCell activation failed.
    Run and return rc    grep -i "SCellIndex \.* activated successfully" /opt/wts/latest/egate_console.log

Egate console log verification
    [Arguments]    ${pattern}
    ${rc}    ${output}=    Run and Return RC and Output    grep -i "${pattern}" ${egate_console_log}
    Should be Equal as Integers     ${rc}    0    msg=${pattern} not found in egate_console.log
    run keyword if    ${rc} == 0    log to console    ${output}

Check Egate Log With Message and count
    [Arguments]     ${msg_regexp}    ${count}=1
    Execute Egate Command    cmd=sim_log_set flush    timeout=1s
    ${content}    OperatingSystem.Get File    path=${egate_console_log}
    ${match_list}     String.Get Lines Matching Regexp    ${content}    ${msg_regexp}    partial_match=true
    ${repeat_count}    Get Count    ${match_list}    ${msg_regexp}
    Should Be True    ${repeat_count}>=${count}

Ensure Scell Deactivation Is Successful
    ${deactivation_message}=    Set Variable    SCellIndex [[\:digit\:]]* deactivated successfully
    ${rc}=    Run and return rc    grep -i "${deactivation_message}" /opt/wts/latest/egate_console.log
    Run Keyword And Ignore Error    Should be Equal as Integers     ${rc}    0    msg=SCell deactivation failed.
    Run and return rc    grep -i "SCellIndex \.* deactivated successfully" /opt/wts/latest/egate_console.log

Get Measurement Configuration
    [Arguments]    ${ue_id}    &{kwargs}
    Execute Egate Command    cmd=sim_log_set flush    timeout=1s
    ${mandatory_args}    Set variable    id=${ue_id}
    ${final_args}    Set Final args list    ${mandatory_args}    &{kwargs}
    ${output}    Execute Egate Command And Wait For Data    cmd=ue_meas_cfg_disp ${final_args}    timeout=10s
    ...    pass_regexp=UE${ue_id}${SPACE}NR${SPACE}MEASUREMENT${SPACE}IDENTITIES
    [Return]    ${output}

Send Ue Measurements
    [Arguments]    ${ue_id}    ${meas_id}    ${pass_regexp}=measurementReport    &{kwargs}
    ${mandatory_args}    Catenate    SEPARATOR=${SPACE}    id=${ue_id}    meas_id=${meas_id}
    ${final_args}    Set Final args list    ${mandatory_args}    &{kwargs}
    ${output}    Execute Egate Command And Wait For Data    cmd=ue_measurement_send_nr ${final_args}    timeout=10s
    ...    pass_regexp=${pass_regexp}
    [Return]    ${output}

dlrlcdrop nr testmode profile creation
    [Arguments]    ${profile_id}    &{kwargs}
    ${mandatory_args}    Set variable    profile_id=${profile_id}
    ${final_args}    Set Final args list    ${mandatory_args}    &{kwargs}
    Execute Egate Command    cmd=dlrlcdrop_testmode_nr ${final_args}    timeout=10s

Update CSI Override parameters
    [Arguments]    ${profile_id}    &{kwargs}
    ${mandatory_args}    Set variable    profile_id=${profile_id}
    ${final_args}    Set Final args list    ${mandatory_args}    &{kwargs}
    Execute Egate Command    cmd=csi_override_testmode_nr ${final_args}    timeout=10s

Associate UE to testmode
    [Arguments]    ${id}    ${testmode}    ${profile_id}    ${pass_regex}=${EMPTY}    &{kwargs}
    ${mandatory_args}    Catenate    SEPARATOR=${SPACE}    profile_id=${profile_id}    id=${id}    testmode=${testmode}
    ${final_args}    Set Final args list    ${mandatory_args}    &{kwargs}
    Run Keyword If    "${pass_regex}"=="${EMPTY}"
    ...    Execute Egate Command    cmd=ue_testmode_set_nr ${final_args}    timeout=10s
    ...    ELSE    Execute Egate Command And Wait For Data    cmd=ue_testmode_set_nr ${final_args}    timeout=120s
    ...    pass_regexp=${pass_regex}

Create SRS Beam profile mode
    [Arguments]    ${profile_id}    &{kwargs}
    ${mandatory_args}    Catenate    SEPARATOR=${SPACE}    profile_id=${profile_id}
    ${final_args}    Set Final args list    ${mandatory_args}    &{kwargs}
    Execute Egate Command    cmd=ue_srs_beam_pos_nr ${final_args}    timeout=5s

Create UL mimo SRS Beam profile mode
    [Arguments]    ${profile_id}    &{kwargs}
    ${mandatory_args}    Catenate    SEPARATOR=${SPACE}    profile_id=${profile_id}
    ${final_args}    Set Final args list    ${mandatory_args}    &{kwargs}
    Execute Egate Command    cmd=ul_mimo_srs_beam_pos_nr ${final_args}    timeout=5s

Create Beam Control profile mode
    [Arguments]    ${profile_id}    &{kwargs}
    ${mandatory_args}    Catenate    SEPARATOR=${SPACE}    profile_id=${profile_id}
    ${final_args}    Set Final args list    ${mandatory_args}    &{kwargs}
    Execute Egate Command    cmd=beam_control_testmode_nr ${final_args}    timeout=5s

Add NGRAN item to UE History Information list
    [Arguments]    ${id}    ${cell_type}    ${nrcgi}    ${gnb_id}    &{kwargs}
    ${mandatory_args}    Catenate    SEPARATOR=${SPACE}    id=${id}     cell_type=${cell_type}    nrcgi=${nrcgi}     gnb_id=${gnb_id}
    ${final_args}    Set Final args list    ${mandatory_args}    &{kwargs}
    Execute Egate Command    cmd=ue_history_information_list_add_ngran ${final_args}    timeout=10s

Update UE History Information lists
    [Arguments]    ${id}    ${action}
    Execute Egate Command    cmd=ue_history_information_list id\=${id} action\=${action}    timeout=10s

Update UE parameters for eNB
    [Arguments]    ${id}    &{kwargs}
    ${mandatory_args}    Catenate    SEPARATOR=${SPACE}    id=${id}
    ${final_args}    Set Final args list    ${mandatory_args}    &{kwargs}
    Execute Egate Command    cmd=ue_enb_param ${final_args}

Kill Simulator Process for upf
    [Arguments]    ${pid}
    Run And Return Rc And Output    sudo kill -6 ${pid}
    Log    Killed sim_upf process manually !    WARN

Trigger eNB initiated inter-rat handover to 5g
    [Arguments]    ${ue_id}    ${target_gnb}    ${target_cell}    ${plmn}    ${pass_regexp}    &{kwargs}
    ${mandatory_args}    Catenate    SEPARATOR=${SPACE}    ue=${ue_id}    target_gnb=${target_gnb}     target_cell=${target_cell}
    ...     plmn=${plmn}
    ${final_args}    Set Final args list    ${mandatory_args}    &{kwargs}
    ${output}    Execute Egate Command And Wait For Data    cmd=gnb_trigger_inter_rat_handover_to_5g ${final_args}    timeout=10s
    ...    pass_regexp=${pass_regexp}
    [Return]    ${output}

Check And Kill admin API Process
    [Documentation]    This keyword is used to check status of admin api process and kill the process if it is still running
    ...                Modified Date: 30-Dec-2022
    ...                Last Modified by: merin.varghese@nokia.com
    ${rc}    ${op}    Run And Return Rc And Output     ps -aef | grep -i admin | grep -v grep
    ${status}    Run Keyword And Return Status    Should Not Be Empty    ${op}
    Run Keyword If    ${status}     Run And Return Rc And Output    sudo pkill node

Configure Initial Allowed Bc List Mrdc During Sgnb Addition
    [Arguments]    ${ue_id}    ${modified_bc_list}
    Execute Egate Command
    ...    cmd=ue_enb_endc_param id=${ue_id} allowed_bc_list_mrdc=${modified_bc_list}
    Sleep    5s

Configure Allowed Bc List Mrdc For Sgnb Modification Request
    [Arguments]    ${ue_id}    ${modified_bc_list}    ${modified_bc_list_1}
    ${allowed_bc_list}=    Set Variable    ${modified_bc_list}|${modified_bc_list_1}
    Execute Egate Command
    ...    cmd=ue_sgnb_mod_param id=${ue_id} allowed_bc_list_mrdc=${allowed_bc_list} exclude_sgnb_security_key=yes exclude_plmn=true
    Sleep    5s

Configure Allowed Additional Parameter For Sgnb Modification Request
    [Arguments]    ${ue_id}    ${uec_nr}    ${uec_eutra_nr}
    Execute Egate Command
    ...    cmd=ue_sgnb_mod_addl_param id=${ue_id} include_ue_capabilities=yes ue_nr_capabilities=${uec_nr} ue_eutra_nr_capabilities=${uec_eutra_nr}
    Sleep    5s

Start Sgnb Modification
    [Arguments]    ${ue_id}    ${cause}    ${pass_regexp}=Successfully reconfigured dual connectivity
    Execute Egate Command
    ...    cmd=enb_ue_dc_modify ue=${ue_id} cause=${cause} by=enb
    ...    pass_regexp=${pass_regexp}

Modify Handover Preparation procedure parameters at GNB
    [Arguments]   ${gnb_id}
	Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id=${gnb_id} action=force_failure cause=o_and_M_intervention

Reset Handover Preparation procedure parameters at GNB
    [Arguments]   ${gnb_id}
	Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id=${gnb_id} reset

Generate Remote Interference
    [Arguments]    ${RI_PWR}    ${profile_id}=7
    Execute Egate Command
    ...    cmd=remote_interference_testmode_nr profile_id\=${profile_id} start_symbol_position\=0 num_of_symbols\=32 noise_power_values\=${RI_PWR}
    Sleep    5s
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr testmode\=remote_interference gnb\=2 cell_id\=2 profile_id\=${profile_id} action\=activate

Activate BLER testmode
    ${cmd} =    Catenate    adv_bler_testmode_nr profile_id=1 target_bler_profile_id=1 target_bler=100,90,80,60,40,20,15,10,5,2,1,0.5,0,0,0
    ...                     target_mcs=15 p_target_bler_profile_id=1
    Execute Egate Command    cmd=${cmd}
    Execute Egate Command    cmd=ue_testmode_set_nr id=1 testmode=adv_bler profile_id=1 action=activate
	Execute Egate Command    cmd=bler_testmode_nr profile_id=2 dl_bler=80
	Execute Egate Command    cmd=ue_testmode_set_nr id=1 testmode=bler action=activate profile_id=2

Deactivate BLER testmode
    Execute Egate Command    cmd=ue_testmode_set_nr id=1 testmode=adv_bler profile_id=1 action=deactivate
    Execute Egate Command    cmd=ue_testmode_set_nr id=1 testmode=bler action=deactivate profile_id=2
