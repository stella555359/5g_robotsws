*** Settings ***
Documentation    The purpose of the test case is to verify that Memory ECC error monitoring service is used so that the data of Memory ECC error
...    can be controlled and reported to the user. Uncorrectable (double-bit) Memory ECC errors can be reported to the user,
...    according to the configured threshold. The timer used to handle the decrease of the dynamic counters by one (-1) as "leaky-bucket" algorithm
...    must remain active after reset with the same target date/time.

Resource    ../resources/unpacking.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/pdu.robot
Resource    ../resources/pm_logs_general.robot
Resource    ../resources/pm_logs_frame.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource   ../resources/ping_utils.robot
Library    OperatingSystem
Library    DateTime
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    taf.ul.verify_snapshot   WITH NAME  snapshot

*** Variables ***
${cmd_Update_swconfig}    echo '0x20169 = 1 # set ERadHwapi_EccUeDynamicCountTimerInHours to 1 hour' >> /ffs/run/swconfig.txt
${cmd_Fault_248}    timestamp=\$(date -u +\"%Y-%m-%dT%H:%M:%S.%6NZ\"); echo \" \${timestamp} ==SIMULATED DATA== EDAC MC1721491200: 0 UE \
...    DMC1 DUMMY-EDAC-TEST-MSG-INJECT on ( page:0x0 offset:0x0 grain:1 - NO)\" >> /var/log/edaclog/edac

*** Keywords ***
TC__LOGS__CNI_124706_TC_02_Memory_ECC_error_monitoring_service

    Step 0: Preconditions
    Step 1: Raise UE ECC error 248 and check UE ECC dynamic counter
    Step 2: Wait for 1h
    Step 3: Check that UE ECC dynamic counter decrease by one (-1) after 1 hour


Step 0: Preconditions
    [Documentation]
    ...   In this step test case connects to BTS

    Log    \nStep 0: Preconditions    console=${True}
    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}
    set test variable  ${destination_dir}  ${BTS Files}/
    set test variable  ${TEST_LOG_DIR}  ${BTS Files}/
    SSH.Connect To      hostname=192.168.255.129    username=toor4nsn   password=oZPS0POrRieRtu     alias=connection_gnb
    Log    \nSuccesfully connected to the BTS    console=${True}
    Sleep   2
    SSH.Send command    command=${cmd_Update_swconfig}     connection=connection_gnb
    Sleep   5s
    Log  Perform BTS site reset  console=yes
    coam.Reset Site  600
    Wait Until Keyword Succeeds  20m  2m  pm_logs_general.Check All Modules And All Cells Working States
    Log  All modules reached working state  console=yes

Step 1: Raise UE ECC error 248 and check UE ECC dynamic counter
    [Documentation]
    ...   In this step we Raise UE ECC error 248

    Log    \nStep 1: Raise UE ECC error 248 and check UE ECC dynamic counter   console=${True}
    SSH.Connect To      hostname=192.168.255.129    username=toor4nsn   password=oZPS0POrRieRtu     alias=connection_gnb
    Log    \nSuccesfully connected to the BTS    console=${True}
    Sleep   2
    SSH.Send command    command=${cmd_Fault_248}      connection=connection_gnb
	Sleep	10s

	run keyword if  '${BTS_ID}'=='10827'    Set Test Variable    ${custom}    blackbox_ecc_ue_DH220472566_A
    run keyword if  '${BTS_ID}'=='10829'    Set Test Variable    ${custom}    blackbox_ecc_ue_L1234202750_A
    run keyword if  '${BTS_ID}'=='10836'    Set Test Variable    ${custom}    blackbox_ecc_ue_L1243401270_A

	set Test Variable  ${blackbox_ecc_ue_file}  ${custom}

	Get File from SMOD1    /ffs/run/logs/lifetimedata/${blackbox_ecc_ue_file}
	Analyze Initial blackbox log file

Step 2: Wait for 1h
    [Documentation]
    ...   In this step we wait for 1 hour
    Log    \nStep 2: Wait for 1h  console=${True}
    Sleep    60min

Step 3: Check that UE ECC dynamic counter decrease by one (-1) after 1 hour
   [Documentation]
    ...   In this step we check that UE ECC dynamic counter decrease by one (-1) after 1 hour
    Log    \nStep 3: Check that UE ECC dynamic counter decrease by one (-1) after 1 hour   console=${True}
	SSH.Connect To      hostname=192.168.255.129    username=toor4nsn   password=oZPS0POrRieRtu     alias=connection_gnb
    Log    \nSuccesfully connected to the BTS    console=${True}
    Sleep   2
    SSH.Send command    command=${cmd_Fault_248}      connection=connection_gnb
	Sleep   10s
    Get File from SMOD1    /ffs/run/logs/lifetimedata/${blackbox_ecc_ue_file}
	Analyze blackbox log file after 1h

Perform Site Reset to clear Fault 248
    [Documentation]
    ...   In this step we perform Site Reset to clear Fault 248
    coam.Reset Site  600
    Wait Until Keyword Succeeds  20m  2m  pm_logs_general.Check All Modules And All Cells Working States
    Log  All modules reached working state  console=yes

Get File from SMOD1
    [Arguments]    ${file_path}
    [Documentation]
    ...    In this KW file is downloaded to BTS files from the path on BTS given in Argument.
    Log    Collecting ${file_path}    console=${True}
    ${exit_code}    ${output}=    Run And Return Rc And Output
    ...    sshpass -p '${SMOD1['PASSWORD']}' scp -r ${SMOD1['USERNAME']}@${SMOD1['IP']}:${file_path} ${BTS Files}
    Run Keyword If    ${exit_code}!=0
    ...    verdicts.Set Test Restriction  Could not get ${file_path}. File may not exist.

Analyze Initial blackbox log file
    [Documentation]
    ...  Keyword used to analyze blackbox ecc ue log. It is checked if UE ECC dynamic counter is incremented.

    ${ue_dynamic_counters}  OperatingSystem.get file  ${BTS Files}/${blackbox_ecc_ue_file}  encoding_errors=ignore
    ${number_of_entries}  Get Lines Containing String  ${ue_dynamic_counters}  UeDynamicCounter
    ${entries_list}    Split To Lines    ${number_of_entries}

    ${valid_counter}  Set Variable  None
    ${valid_value}  Set Variable  0

    FOR  ${entry}  IN  @{entries_list}
        ${match}=  Run Keyword And Ignore Error    Should contain    ${entry}    UeDynamicCounter
        IF  '${match[0]}' == 'PASS'
            ${counter_value_string}=    String.Fetch From Right   ${entry}   :
            ${counter_value_int}=    Convert To Integer    ${counter_value_string}
            IF    ${counter_value_int} > 0
                ${valid_counter}=    String.Fetch From Left   ${entry}   :
                ${valid_value}  Set Variable  ${counter_value_int}
                Exit For Loop
            END
        END
    END

	set Test Variable   ${initial_counter_label}   ${valid_counter}
    set Test Variable   ${initial_counter_value}   ${valid_value}

    Run Keyword If  '${valid_counter}' != 'None'
    ...    Log  Found valid UeDynamicCounter: ${valid_counter} with value: ${valid_value}    console=${True}
    ...  ELSE  verdicts.Set Test Failed  No valid UeDynamicCounter was found.  ${TRUE}

Analyze blackbox log file after 1h
    [Documentation]
    ...  Keyword used to analyze blackbox ecc ue log after 1h. It is checked if UE ECC dynamic counter is decremented after 1h.

    ${ue_dynamic_counters}  OperatingSystem.get file  ${BTS Files}/${blackbox_ecc_ue_file}  encoding_errors=ignore
    ${number_of_entries}  Get Lines Containing String  ${ue_dynamic_counters}  ${initial_counter_label}
    ${entries_list}    Split To Lines    ${number_of_entries}

    FOR  ${entry}  IN  @{entries_list}
        ${match}=  Run Keyword And Ignore Error    Should contain    ${entry}    ${initial_counter_label}
        IF  '${match[0]}' == 'PASS'
            ${counter_value_after_1h_string}=    String.Fetch From Right   ${entry}   :
            ${counter_value_after_1h_int}=    Convert To Integer    ${counter_value_after_1h_string}
            Exit For Loop
        END
    END

    set Test Variable   ${valid_value_after_1h}   ${counter_value_after_1h_int}

    Run Keyword If  ${initial_counter_value} == ${valid_value_after_1h}
    ...    Log  UeDynamicCounter value is decremented    console=${True}
    ...  ELSE  verdicts.Set Test Failed  UeDynamicCounter value is NOT decremented.  ${TRUE}


Disconnect from BTS
    [Documentation]
    ...   In this step test cases disconnects from BTS

    Log    \nTerminating connection with BTS   console=${True}
    Sleep   2
    SSH.Disconnect      connection=connection_gnb

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    Disconnect from BTS
    ...    AND    Perform Site Reset to clear Fault 248
    ...    AND    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown
