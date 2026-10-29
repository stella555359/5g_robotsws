*** Settings ***
Documentation  ECC Errors
Library     ../resources/extractor.py
Library     SSHLibrary
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     taf.ul.verify_snapshot   WITH NAME  snapshot
Library     taf.transport.ssh  WITH NAME  ssh
Library     DateTime
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/verdicts.robot
Resource    ../resources/unpacking.robot
Resource    ../resources/diagnostic_check.robot
Resource    ../resources/ping_utils.robot


*** Variables ***
${BTS_ip}           192.168.255.129
${BTS_login}        toor4nsn
${BTS_password}     oZPS0POrRieRtu
${TRIGGER_FID_247}    for i in {1..10}; do
...    echo "iteration $i";
...    echo "$(date -u +"%Y-%m-%dT%H:%M:%S.%6NZ")==SIMULATED DATA== SystemAddress:666 DMC1 EDAC MC0: 0 CE DUMMY-EDAC-TEST-MSG-INJECT on
...    ( page:0x1 offset:0x2 grain:0 syndrome:0x0) channel:666" >> /var/log/edaclog/edac;
...    sleep 3;
...    done
#${TRIGGER_FID_248_250}    echo "$(date -u +"%Y-%m-%dT%H:%M:%S.%6NZ")==SIMULATED DATA== EDAC MC1721491200: 0 UE DMC1
#...    DUMMY-EDAC-TEST-MSG-INJECT on ( page:0x0 offset:0x0 grain:1 - NO)" >> /var/log/edaclog/edac
${TRIGGER_FID_248_250}    for i in {1..5}; do
...    echo "iteration $i";
...    echo "$(date -u +"%Y-%m-%dT%H:%M:%S.%6NZ")==SIMULATED DATA== EDAC MC1721491200: 0 UE DMC1
...    DUMMY-EDAC-TEST-MSG-INJECT on ( page:0x0 offset:0x0 grain:1 - NO)" >> /var/log/edaclog/edac;
...    sleep 3;
...    done
#${TRIGGER_FID_250}    echo "$(date -u +"%Y-%m-%dT%H:%M:%S.%6NZ")==SIMULATED DATA== UE controller 13 channel:1 bitno 15" >> /var/log/edaclog/edac
#${FSP_ID}      fsp-2-5a

*** Keywords ***
Trigger FID:247 on BBMOD
    [Documentation]
    ...    This step provides to trigger fault 247 on BBMOD, with its position in rack given as argument
    [Arguments]    ${FSP_ID}

    Log    \nStep 1: Send fault 247. Trigger FID:247  console=${True}
    SSHLibrary.Open Connection    ${BTS_ip}
    SSHLibrary.Login    ${BTS_login}    ${BTS_password}
    SSHLibrary.Write    > /user/${BTS_login}/.ssh/known_hosts
    SSHLibrary.Write    cat /user/${BTS_login}/.ssh/known_hosts
    Sleep    3s
    SSHLibrary.Read
    SSHLibrary.Write    ssh ${BTS_login}@${FSP_ID}
    Sleep    3s
    ${output}=    SSHLibrary.Read
    Run Keyword If    "Are you sure you want to continue connecting" in """${output}"""
    ...    Run Keywords    SSHLibrary.Write    yes    AND    Sleep    3s
    ${output}=    SSHLibrary.Read
    Run Keyword If    "Password:" in """${output}"""
    ...    Run Keywords    SSHLibrary.Write    ${BTS_password}    AND    Sleep    5s
    Sleep    5s
    SSHLibrary.Write    ${TRIGGER_FID_247}
    Sleep    30s
    SSHLibrary.Close Connection

Trigger FID:247 on SMOD
    [Documentation]
    ...    This step provides to trigger fault 247 on SMOD

    Log    \nStep 1: Send fault 247. Trigger FID:247  console=${True}
    SSHLibrary.Open Connection    ${BTS_ip}
    SSHLibrary.Login    ${BTS_login}    ${BTS_password}
    Sleep    5s
    SSHLibrary.Write    ${TRIGGER_FID_247}
    Sleep    30s
    SSHLibrary.Close Connection

Trigger FID:248 on SMOD
    [Documentation]
    ...    This step provides to trigger faults 248 and 250 on SMOD

    Log    \nStep 1: Send faults 248 and 250. Trigger FID:248 and 250  console=${True}
    SSHLibrary.Open Connection    ${BTS_ip}
    SSHLibrary.Login    ${BTS_login}    ${BTS_password}
    Sleep    5s
    SSHLibrary.Write    ${TRIGGER_FID_248_250}
    Sleep    30s
    SSHLibrary.Close Connection

Trigger FID:248 on BBMOD
    [Documentation]
    ...    This step provides to trigger faults 248 and 250 on SMOD
    [Arguments]    ${FSP_ID}

    Log    \nStep 1: Send faults 248 and 250. Trigger FID:248 and 250  console=${True}
    SSHLibrary.Open Connection    ${BTS_ip}
    SSHLibrary.Login    ${BTS_login}    ${BTS_password}
    SSHLibrary.Write    > /user/${BTS_login}/.ssh/known_hosts
    SSHLibrary.Write    cat /user/${BTS_login}/.ssh/known_hosts
    Sleep    3s
    SSHLibrary.Read
    SSHLibrary.Write    ssh ${BTS_login}@${FSP_ID}
    Sleep    3s
    ${output}=    SSHLibrary.Read
    Run Keyword If    "Are you sure you want to continue connecting" in """${output}"""
    ...    Run Keywords    SSHLibrary.Write    yes    AND    Sleep    3s
    ${output}=    SSHLibrary.Read
    Run Keyword If    "Password:" in """${output}"""
    ...    Run Keywords    SSHLibrary.Write    ${BTS_password}    AND    Sleep    5s
    Sleep    5s
    SSHLibrary.Write    ${TRIGGER_FID_248_250}
    Sleep    30s
#    SSHLibrary.Write    ${TRIGGER_FID_250}
#    Sleep    30s
    SSHLibrary.Close Connection

Clear FID from BTS
    [Documentation]
    ...    This step provides to clear fault from BTS
    [Arguments]    ${fid}    ${board_pos}    ${SMOD_side}

    ${board_index}    Evaluate    ${board_pos} + 1
    ${int_SENDER}    Set Variable    1
    ${hex_RECEIVER}    Set Variable    0x${SMOD_side}0111202
    ${int_RECEIVER}    Evaluate    int(${hex_RECEIVER})
    ${SIC_MESSAGE_ID}    Set Variable    9236
    ${board_pos}=    Convert To Integer    ${board_pos}
    ${hex_PAYLOAD}=    Run keyword If    ${board_pos} >= 1
    ...  Set Variable    0x${SMOD_side}${board_index}3D
    ...  ELSE
    ...  Set Variable    0x${SMOD_side}011
    ${int_PAYLOAD}    Evaluate    int(${hex_PAYLOAD})
    Log    \nClear FID:${fid} from BTS  console=${True}
    ${clear_faultParams}=  Create List  0  ${int_PAYLOAD}  2  0  0  0  0  0  0  0  0  0  0  0  0  0
    ${clear_fault}=  Run keyword and return status  send_fault_ind_msg  ${int_SENDER}  ${int_RECEIVER}  ${fid}  0  fault_params=@{clear_faultParams}
    ...  sic_message_id=${SIC_MESSAGE_ID}
    ${FID_247_active}=    Run keyword if  ${clear_fault} and '${fid}' == '247'  Set Suite Variable  ${False}
    ${FID_248_active}=    Run keyword if  ${clear_fault} and '${fid}' == '248'  Set Suite Variable  ${False}
    ${FID_250_active}=    Run keyword if  ${clear_fault} and '${fid}' == '250'  Set Suite Variable  ${False}
    Run keyword if  ${clear_fault}
    ...  Log  Fault ${fid} is cleared. [OK]  console=${True}
    ...  ELSE
    ...  Fail  msg=Fault ${fid} is not cleared. [NOK]

Check FID in WebEm
    [Documentation]
    ...    Check if fault is available in WebEm
    [Arguments]    ${fid}

    Log    \nCheck FID:${fid} in WebEm    console=${True}
    Log  Wait up to 1 min in order to check if alarm ${fid} raised.  console=${True}
    ${expected_fault}=  Create Dictionary  faultId=${fid}
    ${expected_fault}=  Create List  ${expected_fault}
    ${status}=  Run keyword and return status  Wait Until Keyword Succeeds  1 min  10 sec
    ...  bts_states.Check Active Alarms  print_alarms=${False}  expected_patterns=${expected_fault}
    Run keyword unless  ${status}  Fail  Fault ${fid} was not received.
    Log  Fault ${fid} is reported  console=${True}
    ${FID_247_active}=    Run keyword If    '${fid}' == '247'
    ...  Set Suite Variable  ${True}
    ${FID_248_active}=    Run keyword If    '${fid}' == '248'
    ...  Set Suite Variable  ${True}
    ${FID_250_active}=    Run keyword If    '${fid}' == '250'
    ...  Set Suite Variable  ${True}
    ${BTS_timestamp}    Get BTS Timestamp
    Set Test Variable    ${BTS_timestamp}

Prepare TL for FID:247 alarm triggering
    ping_utils.Wait For Target IP To Be Reachable    192.168.255.129    5
    Sleep    30s
    SSHLibrary.Open Connection    ${BTS_ip}
    SSHLibrary.Login    ${BTS_login}    ${BTS_password}
    SSHLibrary.Write    (echo 'rad -a @HWRHwCtrlSExe';sleep 0.5;exit) | telnet 127.0.0.1 15007 |grep -i 0x20166
    Sleep    5s
    ${cmd_output}  SSHLibrary.Read
    ${cmd_output} =    Replace String    ${cmd_output}    \r    ${EMPTY}
    ${cmd_output} =    Replace String    ${cmd_output}    \n    ${EMPTY}
    ${cmd_output} =    Strip String    ${cmd_output}
    Run Keyword If    "0x1" not in "${cmd_output}"    SSHLibrary.Write
    ...    echo '0x20166=0x1 # set ERadHwapi_EccCeDynamicCountThreshold to test CE ECC error' >> /ffs/run/swconfig.txt
    Run Keyword If    "0x1" not in "${cmd_output}"    Run Keywords
    ...    Log   Perform BTS site reset  console=yes
    ...    AND   coam.Reset Site  600
    ...    AND   Wait Until Keyword Succeeds  20m  2m  pm_logs_general.Check All Modules And All Cells Working States
    ...    AND   Log  All modules reached working state  console=yes

Get ECC CE file from BBMOD
    [Arguments]    ${FSP_ID}
    [Documentation]
    ...    In this KW file is downloaded to BTS files from the path on BTS given in Argument.
    SSHLibrary.Open Connection    ${BTS_ip}
    SSHLibrary.Login    ${BTS_login}    ${BTS_password}
    SSHLibrary.Write    rm /tmp/ecc_ce_to_check
    SSHLibrary.Write    > /user/${BTS_login}/.ssh/known_hosts
    SSHLibrary.Write    cat /user/${BTS_login}/.ssh/known_hosts
    Sleep    3s
    SSHLibrary.Read
#    SSHLibrary.Write    cat /tmp/ecc_ce_* > /tmp/ecc_ce_to_check
    SSHLibrary.Write    scp -r ${BTS_login}@${FSP_ID}:"/tmp/ecc_ce_*" /tmp/ecc_ce_to_check
    Sleep    3s
    ${output}=    SSHLibrary.Read
    Run Keyword If    "Are you sure you want to continue connecting" in """${output}"""
    ...    Run Keywords    SSHLibrary.Write    yes    AND    Sleep    5s
    ${output}=    SSHLibrary.Read
    Run Keyword If    "Password:" in """${output}"""
    ...    Run Keywords    SSHLibrary.Write    ${BTS_password}    AND    Sleep    5s
    SSHLibrary.Read
    SSHLibrary.Close Connection
    ${exit_code}    ${output}=    Run And Return Rc And Output
    ...    sshpass -p '${BTS_password}' scp -r ${BTS_login}@${BTS_ip}:/tmp/ecc_ce_to_check ${BTS Files}
    Run Keyword If    ${exit_code}!=0
    ...    verdicts.Set Test Restriction  Could not get blackbox_ecc_ce file. File may not exist.

Get ECC CE file from SMOD
    [Documentation]
    ...    In this KW file is downloaded to BTS files from the path on BTS given in Argument.
    SSHLibrary.Open Connection    ${BTS_ip}
    SSHLibrary.Login    ${BTS_login}    ${BTS_password}
    SSHLibrary.Write    rm /tmp/ecc_ce_to_check
    ${output}    SSHLibrary.Execute Command    cat /tmp/ecc_ce_* > /tmp/ecc_ce_to_check
    SSHLibrary.Close Connection
    ${exit_code}    ${output}=    Run And Return Rc And Output
    ...    sshpass -p '${BTS_password}' scp -r ${BTS_login}@${BTS_ip}:/tmp/ecc_ce_to_check ${BTS Files}
    Run Keyword If    ${exit_code}!=0
    ...    verdicts.Set Test Restriction  Could not get blackbox_ecc_ce file. File may not exist.

Clean up ECC UE files from SMOD
    [Documentation]
    ...    In this KW ECC UE and Blackbox ECC UE files from SMOD are cleaned up. BTS Site Reset is performed in order to apply the changes.
    SSHLibrary.Open Connection    ${BTS_ip}
    SSHLibrary.Login    ${BTS_login}    ${BTS_password}
    SSHLibrary.Execute Command    rm /ram/ecc_ue_*
    SSHLibrary.Execute Command    rm /ffs/run/logs/lifetimedata/blackbox_ecc_ue_*
    SSHLibrary.Close Connection
    Log   Perform BTS site reset  console=yes
    coam.Reset Site  600
    Wait Until Keyword Succeeds  20m  2m  pm_logs_general.Check All Modules And All Cells Working States
    Log  All modules reached working state  console=yes
    Wait Until Keyword Succeeds    1min    10s    coam.Assert alarm inactive    faultId=4681, severity=Minor
    Log  Fault 4681 is cleared in WebEm  console=${True}

Clean up ECC UE files from BBMOD
    [Documentation]
    ...    In this KW ECC UE and Blackbox ECC UE files from BBMOD are cleaned up. BBMOD Reset is performed in order to apply the changes.
    [Arguments]    ${FSP_ID}    ${BBMOD_pos}

    SSHLibrary.Open Connection    ${BTS_ip}
    SSHLibrary.Login    ${BTS_login}    ${BTS_password}
    SSHLibrary.Write    > /user/${BTS_login}/.ssh/known_hosts
    SSHLibrary.Write    cat /user/${BTS_login}/.ssh/known_hosts
    Sleep    3s
    SSHLibrary.Read
    SSHLibrary.Write    ssh ${BTS_login}@${FSP_ID}
    Sleep    3s
    ${output}=    SSHLibrary.Read
    Run Keyword If    "Are you sure you want to continue connecting" in """${output}"""
    ...    Run Keywords    SSHLibrary.Write    yes    AND    Sleep    3s
    ${output}=    SSHLibrary.Read
    Run Keyword If    "Password:" in """${output}"""
    ...    Run Keywords    SSHLibrary.Write    ${BTS_password}    AND    Sleep    5s
    Sleep    5s
    SSHLibrary.Write    rm /ram/ecc_ue_*
    Sleep    3s
    SSHLibrary.Read
    SSHLibrary.Write    rm /ram/lifedataFsp/blackbox_ecc_ue_*
    Sleep    3s
    SSHLibrary.Read
    SSHLibrary.Close Connection
    Perform BBMOD reset    BBMOD_pos=${BBMOD_pos}
    Wait Until Keyword Succeeds  20m  2m  pm_logs_general.Check All Modules And All Cells Working States
    Log  All modules reached working state  console=yes
    Wait Until Keyword Succeeds    1min    10s    coam.Assert alarm inactive    faultId=4681, severity=Minor
    Log  Fault 4681 is cleared in WebEm  console=${True}

Get ECC UE file from SMOD
    [Documentation]
    ...    In this KW file is downloaded to BTS files from the path on BTS given in Argument.
    SSHLibrary.Open Connection    ${BTS_ip}
    SSHLibrary.Login    ${BTS_login}    ${BTS_password}
    SSHLibrary.Write    rm /tmp/ecc_ue_to_check
    ${output}    SSHLibrary.Execute Command    cat /tmp/ecc_ue_* > /tmp/ecc_ue_to_check
    SSHLibrary.Close Connection
    ${exit_code}    ${output}=    Run And Return Rc And Output
    ...    sshpass -p '${BTS_password}' scp -r ${BTS_login}@${BTS_ip}:/tmp/ecc_ue_to_check ${BTS Files}
    Run Keyword If    ${exit_code}!=0
    ...    verdicts.Set Test Restriction  Could not get blackbox_ecc_ue file. File may not exist.

Get ECC UE file from BBMOD
    [Arguments]    ${FSP_ID}
    [Documentation]
    ...    In this KW file is downloaded to BTS files from the path on BTS given in Argument.
    SSHLibrary.Open Connection    ${BTS_ip}
    SSHLibrary.Login    ${BTS_login}    ${BTS_password}
    SSHLibrary.Write    rm /tmp/ecc_ue_to_check
    SSHLibrary.Write    > /user/${BTS_login}/.ssh/known_hosts
    SSHLibrary.Write    cat /user/${BTS_login}/.ssh/known_hosts
    Sleep    3s
    SSHLibrary.Read
#    SSHLibrary.Write    cat /tmp/ecc_ue_* > /tmp/ecc_ue_to_check
    SSHLibrary.Write    scp -r ${BTS_login}@${FSP_ID}:"/tmp/ecc_ue_*" /tmp/ecc_ue_to_check
    Sleep    3s
    ${output}=    SSHLibrary.Read
    Run Keyword If    "Are you sure you want to continue connecting" in """${output}"""
    ...    Run Keywords    SSHLibrary.Write    yes    AND    Sleep    5s
    ${output}=    SSHLibrary.Read
    Run Keyword If    "Password:" in """${output}"""
    ...    Run Keywords    SSHLibrary.Write    ${BTS_password}    AND    Sleep    5s
    SSHLibrary.Read
    SSHLibrary.Close Connection
    ${exit_code}    ${output}=    Run And Return Rc And Output
    ...    sshpass -p '${BTS_password}' scp -r ${BTS_login}@${BTS_ip}:/tmp/ecc_ue_to_check ${BTS Files}
    Run Keyword If    ${exit_code}!=0
    ...    verdicts.Set Test Restriction  Could not get blackbox_ecc_ue file. File may not exist.

Analyze Initial blackbox ECC CE file
    [Documentation]
    ...  Keyword used to analyze blackbox ecc ce log. Initial CE ECC total counter value is checked.

    ${ecc_ce_total_counter}  OperatingSystem.get file  ${BTS Files}/ecc_ce_to_check  encoding_errors=ignore
    ${number_of_entries}  Get Lines Containing String  ${ecc_ce_total_counter}  ECC CE counter (total nbr of corrected errors since created)
    ${entries_list}    Split To Lines    ${number_of_entries}

    ${valid_counter}  Set Variable  None
    ${counter_value_int}  Set Variable  0

    ${match}=  Run Keyword And Ignore Error    Should contain    ${entries_list}[0]    ECC CE counter (total nbr of corrected errors since created)
    IF  '${match[0]}' == 'PASS'
        ${counter_value_string}=    String.Fetch From Right   ${entries_list}[0]   :
        ${counter_value_int}=    Convert To Integer    ${counter_value_string}
        ${valid_counter}=    String.Fetch From Left   ${entries_list}[0]   :
    END

	set Test Variable   ${initial_counter_label}   ${valid_counter}
    set Test Variable   ${initial_counter_value}   ${counter_value_int}

    Run Keyword If  '${valid_counter}' != 'None'
    ...    Log  Found valid ECC CE counter: ${valid_counter} with value: ${counter_value_int}    console=${True}
    ...  ELSE  verdicts.Set Test Failed  No valid ECC CE counter was found.  ${TRUE}

Analyze Initial blackbox ECC UE file
    [Documentation]
    ...  Keyword used to analyze blackbox ecc ue log. Initial UE ECC total counter value is checked.

    ${ecc_ue_total_counter}  OperatingSystem.get file  ${BTS Files}/ecc_ue_to_check  encoding_errors=ignore
    ${number_of_entries}  Get Lines Containing String  ${ecc_ue_total_counter}  ECC UE counter (total nbr of uncorrected errors since created)
    ${entries_list}    Split To Lines    ${number_of_entries}

    ${valid_counter}  Set Variable  None
    ${counter_value_int}  Set Variable  0

    ${match}=  Run Keyword And Ignore Error    Should contain    ${entries_list}[0]    ECC UE counter (total nbr of uncorrected errors since created)
    IF  '${match[0]}' == 'PASS'
        ${counter_value_string}=    String.Fetch From Right   ${entries_list}[0]   :
        ${counter_value_int}=    Convert To Integer    ${counter_value_string}
        ${valid_counter}=    String.Fetch From Left   ${entries_list}[0]   :
    END

	set Test Variable   ${initial_counter_label}   ${valid_counter}
    set Test Variable   ${initial_counter_value}   ${counter_value_int}

    Run Keyword If  '${valid_counter}' != 'None'
    ...    Log  Found valid ECC UE counter: ${valid_counter} with value: ${counter_value_int}    console=${True}
    ...  ELSE  verdicts.Set Test Failed  No valid ECC UE counter was found.  ${TRUE}

Analyze blackbox ECC CE file after FID:247 triggering
    [Documentation]
    ...  Keyword used to analyze blackbox ecc ce log. It is checked if CE ECC total counter is correctly incremented.

    ${ecc_ce_total_counter}  OperatingSystem.get file  ${BTS Files}/ecc_ce_to_check  encoding_errors=ignore
    ${number_of_entries}  Get Lines Containing String  ${ecc_ce_total_counter}  ${initial_counter_label}
    ${entries_list}    Split To Lines    ${number_of_entries}

    ${valid_counter}  Set Variable  None

    ${match}=  Run Keyword And Ignore Error    Should contain    ${entries_list}[0]    ${initial_counter_label}
    IF  '${match[0]}' == 'PASS'
        ${counter_value_after_FID_247_triggering_string}=    String.Fetch From Right   ${entries_list}[0]   :
        ${counter_value_after_FID_247_triggering_int}=    Convert To Integer    ${counter_value_after_FID_247_triggering_string}
    END

    ${expected_value}    Evaluate    ${initial_counter_value} + 10

	Run Keyword If  ${counter_value_after_FID_247_triggering_int} == ${expected_value}
    ...    Log  ECC CE counter value is properly incremented    console=${True}
    ...  ELSE  verdicts.Set Test Failed  ECC CE counter value is NOT properly incremented.Please check the logs!  ${TRUE}

Analyze blackbox ECC UE file after FID:248 triggering
    [Documentation]
    ...  Keyword used to analyze blackbox ecc ue log. It is checked if UE ECC total counter is correctly incremented.

    ${ecc_ue_total_counter}  OperatingSystem.get file  ${BTS Files}/ecc_ue_to_check  encoding_errors=ignore
    ${number_of_entries}  Get Lines Containing String  ${ecc_ue_total_counter}  ${initial_counter_label}
    ${entries_list}    Split To Lines    ${number_of_entries}

    ${valid_counter}  Set Variable  None

    ${match}=  Run Keyword And Ignore Error    Should contain    ${entries_list}[0]    ${initial_counter_label}
    IF  '${match[0]}' == 'PASS'
        ${counter_value_after_FID_248_250_triggering_string}=    String.Fetch From Right   ${entries_list}[0]   :
        ${counter_value_after_FID_248_250_triggering_int}=    Convert To Integer    ${counter_value_after_FID_248_250_triggering_string}
    END

    ${expected_value}    Evaluate    ${initial_counter_value} + 5

	Run Keyword If  ${counter_value_after_FID_248_250_triggering_int} == ${expected_value}
    ...    Log  ECC UE counter value is properly incremented    console=${True}
    ...  ELSE  verdicts.Set Test Failed  ECC UE counter value is NOT properly incremented.Please check the logs!  ${TRUE}

#Analyze blackbox ECC UE file after FID:248 and 250 triggering on BBMOD
#    [Documentation]
#    ...  Keyword used to analyze blackbox ecc ue log. It is checked if UE ECC total counter is correctly incremented.
#
#    ${ecc_ue_total_counter}  OperatingSystem.get file  ${BTS Files}/ecc_ue_to_check  encoding_errors=ignore
#    ${number_of_entries}  Get Lines Containing String  ${ecc_ue_total_counter}  ${initial_counter_label}
#    ${entries_list}    Split To Lines    ${number_of_entries}
#
#    ${valid_counter}  Set Variable  None
#
#    ${match}=  Run Keyword And Ignore Error    Should contain    ${entries_list}[0]    ${initial_counter_label}
#    IF  '${match[0]}' == 'PASS'
#        ${counter_value_after_FID_248_250_triggering_string}=    String.Fetch From Right   ${entries_list}[0]   :
#        ${counter_value_after_FID_248_250_triggering_int}=    Convert To Integer    ${counter_value_after_FID_248_250_triggering_string}
#    END
#
#    ${expected_value}    Evaluate    ${initial_counter_value} + 2
#
#	Run Keyword If  ${counter_value_after_FID_248_250_triggering_int} == ${expected_value}
#    ...    Log  ECC UE counter value is properly incremented    console=${True}
#    ...  ELSE  verdicts.Set Test Failed  ECC UE counter value is NOT properly incremented.Please check the logs!  ${TRUE}

Get BTS Timestamp
    SSHLibrary.Open Connection    ${BTS_ip}
    SSHLibrary.Login    ${BTS_login}    ${BTS_password}
    SSHLibrary.Write    date +"%Y-%m-%dT%H:%M:%S"
    Sleep    10s
    ${cmd_output}  SSHLibrary.Read
    ${cmd_output}    Get Line    ${cmd_output}    0
    SSHLibrary.Close Connection
    [Return]  ${cmd_output}

Snapshot Collection
    [Documentation]    In this step the snapshot is collected, and the path to this downloaded snapshot is stored in a variable.
    Log    \nCollect Snapshot    console=${TRUE}
    ${path_to_snap_1}    ecc_errors.Collect Snapshot
    Set Test Variable    ${path_to_snap_1}

Collect Snapshot
    [Documentation]    Downloads full snapshot from BTS and returns the path of saved snapshot on VM.

    Log  Collecting snapshot...    console=${TRUE}
    ${timestamp}    Get time
    ${timestamp}    replace String Using Regexp    ${timestamp}    (${SPACE}|:|-)  _
    Set Test Variable  ${timestamp}
    ${log_status}  Run Keyword And Ignore Error  coam.Collect snapshot  ${BTS_Files}/snapshot_${timestamp}.zip  coverage=Minor
    ...    timeout=${SNAPSHOT_TIMEOUT}
    Run Keyword If    '${log_status[0]}'=='FAIL'
    ...    Fail    Collecting snapshot failed
    ...    ELSE    Log    Snapshot has been successfully downloaded    console=${TRUE}
    Set Test Variable    ${path_to_snapshot}    ${BTS_Files}/snapshot_${timestamp}.zip
    [Return]    ${path_to_Snapshot}

Extract blackbox ECC file from Snapshot
    [Documentation]    In this step the blackbox ECC file is found and extracted from the snapshot

    [Arguments]    ${board_pos}    ${ecc_type}
    Log    \nExtract blackbox ECC ${ecc_type} file from Snapshot    console=${TRUE}
    Locate blackbox ECC File In Snapshot And Extract It    ${path_to_snap_1}    ${board_pos}    ${ecc_type}

Locate blackbox ECC File In Snapshot And Extract It
   [Documentation]    Find the blackbox ECC file in snapshot and extracts it. Takes the path to snapshot as argument and returns
   ...    the path to the extracted blackbox ECC file.

   [Arguments]    ${snapshot_path}    ${board_pos}    ${ecc_type}
   Log  Looking for blackbox ECC ${ecc_type} file in snapshot  console=${True}
   ${snapshot_dict}   snapshot.Get Data From Snapshot  ${snapshot_path}
   ${board_pos}=    Convert To Integer    ${board_pos}
   Run Keyword If    ${board_pos} >= 1
   ...    Get Core SN from BBMODs    ${board_pos}
   ...    ELSE    Get Core SN from SMOD
   ${board_index}    Evaluate    ${board_pos} + 1

   FOR    ${key}    IN    @{snapshot_dict.keys()}
       ${blackbox_file}    get regexp matches    ${snapshot_dict["${key}"][0]}
       ...    \.+BTS${BTS_ID}_(1|2)${board_index}\[A-Z0-9]\[A-Z0-9]_blackbox_ecc_${ecc_type}_${coreHwBoardSerialNumber}_A\.xz
       Exit For Loop If    ${blackbox_file}
   END

   Run Keyword If    ${blackbox_file}    ecc_errors.Extract blackbox ECC file    ${snapshot_path}    ${blackbox_file[0]}    ${ecc_type}
   ...    ELSE    Fail    blackbox_ecc_${ecc_type}_${coreHwBoardSerialNumber}_A.xz file not found

Get Core SN from BBMODs
    [Arguments]    ${BBMOD_pos}=1
    ${bbmods_distnames}  coam.Get Ids For All  BBMOD
    ${lenght}=   Get Length    ${bbmods_distnames}
    Set Test Variable    ${nr_bbmods}    ${lenght}
    ${coreHwBoardSerialNumber}  Set Variable  None

    ${i}    Evaluate    1
    FOR  ${bbmod_single_distname}  IN  @{bbmods_distnames}
        Run Keyword If    '${i}'=='${BBMOD_pos}'     Run Keywords
        ...  Get coreHwBoardSerialNumber from BBMOD    i=${i}
        ...  AND  Exit For Loop
        ${i}          Set Variable    ${i + 1}
    END

Get Core SN from SMOD
    ${coreHwBoardSerialNumber}  Set Variable  None
    Get coreHwBoardSerialNumber from SMOD    1

Extract blackbox ECC file
    [Documentation]    Extracts the desired file from snapshot and sets the variable path_to_log_file.

    [Arguments]    ${path_to_snapshot}    ${file_to_extract}    ${ecc_type}
    unpacking.Unpack Archive Content To Directory    ${path_to_snapshot}    ${BTS_Files}/snapshot_${timestamp}
    ${zip_from_extract}    Get Regexp Matches    ${file_to_extract}    [\\w.]+
    ${log_to_extract}    Replace String Using Regexp    ${zip_from_extract[0]}    (.xz)    ${EMPTY}
    unpacking.Unpack Archive Content To Directory
    ...  ${BTS_Files}/snapshot_${timestamp}/${zip_from_extract[0]}    ${BTS_Files}/snapshot_${timestamp}${log_to_extract}
    unpacking.Unpack Archive Content To Directory
    ...  ${BTS_Files}/snapshot_${timestamp}${log_to_extract}/${zip_from_extract[1]}    ${BTS_Files}/blackbox_ecc_${ecc_type}/${timestamp}

    Set Test Variable  ${path_to_BBOX_file_from_Snapshot}  ${BTS_Files}/blackbox_ecc_${ecc_type}/${timestamp}

Get coreHwBoardSerialNumber from BBMOD
    [Arguments]    ${i}

    ${bbmod_obj}  Query Infomodel  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/EQM_R-*/APEQM_R-*/CABINET_R-*/BBMOD_R-${i}
    Set Test Variable    ${coreHwBoardSerialNumber}    ${bbmod_obj['coreHwBoardSerialNumber']}

Get coreHwBoardSerialNumber from SMOD
    [Arguments]    ${i}

    ${smod_obj}  Query Infomodel  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/EQM_R-*/APEQM_R-*/CABINET_R-*/SMOD_R-${i}
    Set Test Variable    ${coreHwBoardSerialNumber}    ${smod_obj['coreHwBoardSerialNumber']}

Check If blackbox ECC file Content from Snapshot is correct
    [Documentation]    The content of blackbox ECC file from Snapshot is compared and checked with last extracted blackbox ECC file from BTS.

    [Arguments]    ${ecc_type}
    Log    \nCompare and check blackbox ECC file from Snapshot with last extracted blackbox ECC file from BTS    console=${TRUE}
    ${blackbox_content_snapshot}    Run    command=cat ${path_to_BBOX_file_from_Snapshot}/$(ls ${path_to_BBOX_file_from_Snapshot})
    ${blackbox_content}    Run    command=cat ${BTS Files}/ecc_${ecc_type}_to_check
    Should Be Equal As Strings   ${blackbox_content_snapshot}    ${blackbox_content}

Perform BBMOD reset
    [Arguments]   ${BBMOD_pos}

    ${BBMOD_object}  Query Infomodel  get list //BBMOD_R-${BBMOD_pos}  allow_negative_result=True
    Run Keyword Unless  ${BBMOD_object}
    ...    verdicts.Set Test Failed  Distinguished Name was not found for given BBMOD!  ${TRUE}
    Set Test Variable    ${BBMOD_object_dist_name}    ${BBMOD_object[0]['dist_name']}

    Log  Perform BBMOD Reset  console=True
    coam.Reset_unit  dist_name=${BBMOD_object_dist_name}  reset_type=Warm  timeout=300
