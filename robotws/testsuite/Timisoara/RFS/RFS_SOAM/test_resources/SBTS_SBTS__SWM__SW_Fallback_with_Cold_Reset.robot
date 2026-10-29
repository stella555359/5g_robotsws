*** Settings ***
Documentation    TC__SBTS_SBTS__SWM__SW_Fallback
Variables    tc_variables/sbts_sbts__swm__sw_fallback_with_cold_reset_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}          3      # Number of repetitions, default value 3
${BTS_SW_Fallback}         BOTH   # BTS on which SW Fallback functionality will be tested. Possible values (by default BOTH):
                                  # - BOTH: action will be performed on both BTS
                                  # - BTS labelized as BTSx (x is test_pc number in init.py) (ex. BTS1)
${Target SW dir}           /home/ute/btsauto/TARGET_SW_BTS1  # path to directory with target SW zip file
${Target SW name}          None   # N+1 BTS SW name; if not given, the last modified zip file from ${Target SW dir} will be taken
${SW Update Timeout}       3000   # Timeout for SW Update; given in seconds
${FORCE_CURRENT_SW_DL}     False  # Force downlaod current reservation SW build in order to be used for SW Update, in offline running it needs
                                  # variable ENB_BUILD to be defined in argfile.txt
${Remote target SW path}   None   # Path to remote zip file which needs to be downloaded; ex: /SBTS/Trunk/SBTS00_ENB_9999_231030_000010.zip
${RFS_CUSTOM_SHARE_SW_DL}  False  # Flag to enable/disable SW package download from remote location
                                  # - SWs from share-1 can be downloaded locally. Default value is False
${RESTORE_INITIAL_BTS_SW}  False  # Specify if initial BTS SW versions should be restored at the end of the test (True) or not (False).
                                  # By default False
${BTS_MAX_WAIT_TIME}       900    # Maximum time for waiting for BTS to be OnAir; given in seconds
${BTS1_EIF_down}                        # EIF down info for BTS1
${BTS1_EIF_pass_down}                   # EIF down password for BTS1,
${BTS1_EIF_up}                          # EIF up info for BTS1
${BTS1_EIF_pass_up}                     # EIF up password for BTS1
${BTS1_EIF_Switch_IpAddress}            # EIF switch IP address for BTS1
${BTS2_EIF_down}                        # EIF down info for BTS2
${BTS2_EIF_pass_down}                   # EIF down password for BTS2
${BTS2_EIF_up}                          # EIF up info for BTS2
${BTS2_EIF_pass_up}                     # EIF up password for BTS2
${BTS2_EIF_Switch_IpAddress}            # EIF switch IP address for BTS2

*** Keywords ***
TC__SBTS_SBTS__SWM__SW_Fallback_with_Cold_Reset
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28523
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for BTS SW Fallback.
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both BTS
    ...  - get target SW for BTS SW Update
    ...  - check and set swFallbackTimer parameter value on 0 on both BTS
    ...  - test SW Fallback functionality with Cold Reset on BTS checking states and alarms
    ...  - check final state and alarms for both BTS
    ...
    ...  ***************************
    ...  History of changes
    ...  ***************************
    ...  - 17.12.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28523 - RFS_SBTS_SBTS_SWFallback_with_coldReset_with_WebEM
    ...  - 31.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28675 - SBTS_SBTS__SWM__SW_Fallback to check root cause returned
    ...  after EIF/LMP down/up
    ...  - 10.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28681 - [5G] Replace LMP unplug LABOPS scripts with VM scripts for the
    ...  SW fallback robots
    ...  - 12.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30321 - Adapt SBTS_SBTS__SWM__SW_Fallback & Fallback_with_Cold_Reset in case
    ...  of GPS receiver alarm: firmware upgrade ongoing
    ...  - 15.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30247 - Adapt SBTS_SBTS__SWM__SW_Fallback & Fallback_with_Cold_Reset for
    ...  multiple runs

    Set Tags    CA-SWM    OWNER-radu.hirsovescu@nokia.com    AUTHOR-anca.tatar@nokia.com    PHASE-QT    SW-SBTS25R2

    TC Preconditions
    Step 1: Check initial both BTS state
    Step 2: Check initial both BTS alarms
    Step 3: Get Target SW for BTS SW Update
    Step 4: Check and set swFallbackTimer parameter value on BTS
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 5: Test SW Fallback functionality with Cold Reset on BTS for iteration ${INDEX}
        Step 6: Check final both BTS state
        Step 7: Check final both BTS alarms
        Step 8: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

TC Preconditions
    ${BTS_alias_label_dict}  ${BTS_label_alias_dict}=  Get BTS alias label info dict
    Set Test Variable  ${BTS_alias_label_dict}
    Set Test Variable  ${BTS_label_alias_dict}
    ${BTS_alias_list}=  Get Dictionary Keys  ${BTS_alias_label_dict}  False
    ${BTS_label_list}=  Get Dictionary Values  ${BTS_alias_label_dict}  False
    Set Test Variable  ${BTS_alias_list}
    Set Test Variable  ${BTS_label_list}

    Run Keyword If  '${BTS_SW_Fallback}' != 'BOTH'  Check BTS list
    Log  ====================================================  console=True
    Log  BTS label selected for BTS SW Fallback: ${BTS_label_list}  console=True
    Log  BTS alias selected for BTS SW Fallback: ${BTS_alias_list}  console=True
    Log  ====================================================  console=True

Check BTS list
    ${BTS_SW_Fallback_strip}=  Replace String  ${BTS_SW_Fallback}  ${SPACE}  ${EMPTY}
    ${BTS_SW_Fallback}=  Split String  ${BTS_SW_Fallback_strip}  ,
    ${BTS_check}=  Set Variable  True
    ${BTS_invalid_label_list}=  Create List
    ${BTS_request_label_list}=  Create List
    ${BTS_request_alias_list}=  Create List

    FOR  ${item}  IN  @{BTS_SW_Fallback}
        ${BTS_check}=  Set Variable If  '${item}' not in ${BTS_label_list}  False  ${BTS_check}
        Run Keyword If  '${item}' not in ${BTS_label_list}
        ...  Append To List  ${BTS_invalid_label_list}  ${item}
        ...  ELSE
        ...  Append To List  ${BTS_request_label_list}  ${item}
    END

    Run Keyword If  '${BTS_check}' == 'False'  Run Keywords
    ...  Log Long String  Following selected BTS are not valid: ${BTS_invalid_label_list}. Please select values for test argument
    ...  \${BTS_SW_Fallback} from configured BTS: ${BTS_label_list} or let default value: BOTH  console=True
    ...  AND  Fail  Improper value for argument!

    FOR  ${item}  IN  @{BTS_request_label_list}
        ${BTS_request_alias}=  Get From Dictionary  ${BTS_label_alias_dict}  ${item}
        Append To List  ${BTS_request_alias_list}  ${BTS_request_alias}
    END

    Set Test Variable  ${BTS_label_list}  ${BTS_request_label_list}
    Set Test Variable  ${BTS_alias_list}  ${BTS_request_alias_list}

Step ${index}: Check ${when} both BTS state
    [Documentation]
    ...  SBTS state is checked according to Admin for BTS and each configured RAT

    [Timeout]  15 min
    Log  Step ${index}: Check ${when} both BTS state  console=True
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} state *****  console=True
        Admin Check BTS RAT Procedural State  alias=${alias}  timeout=600
        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  alias=${alias}
        Log  BTS ${alias} site - proceduralState: OnAir, blockingState: Unblocked  console=True
    END

Step ${index}: Check ${when} both BTS alarms
    [Documentation]
    ...  SBTS alarms are compared with values from expected, ignored and critical alarms lists. SBTS alarms are get
    ...  from admin

    [Timeout]  15 min
    Log  Step ${index}: Check ${when} both BTS alarms  console=True
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} alarms *****  console=True
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
        ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True
    END

Step ${index}: Get Target SW for BTS SW Update
    Log  Step ${index}: Get Target SW for BTS SW Update  console=True

    Run Keyword If  '${FORCE_CURRENT_SW_DL}' == 'True'  Run Keywords
    ...  Download And Set Current SW for SWDL  Target_SW_dir=${Target SW dir}
    ...  AND  Check if SW version already exists on BTS
    ...  AND  Set Test Variable  ${Target SW name}  ${Target Package Name}
    ...  AND  Return From Keyword

    ${Target SW tmp}=  Run Keyword If  not '${RFS_CUSTOM_SHARE_SW_DL}' == 'True'
    ...  Get SW file for SWDL  ${Target SW dir}  ${Target SW name}
    Run Keyword If  '${RFS_CUSTOM_SHARE_SW_DL}' == 'True'  Run Keywords
    ...  Log  SW package will be downloaded from remote server  console=True
    ...  AND  SFTP Download SW from remote server and rename  ${Remote target SW path}  Master
    ...  ELSE  Rename Software Package  ${Target SW tmp}
    Set Test Variable  ${Target SW}
    Log  Target SW for BTS SW Update: ${Target SW}  console=True
    Check if SW version already exists on BTS
    ${target_sw_path}  ${target_sw_file}=  Split Path  ${Target SW}
    ${target_sw_name}  ${ext}=  Split Extension  ${target_sw_file}
    ${qc_target_sw}=  String.Convert To Upper Case  ${target_sw_name}
    Set Test Variable  ${Target SW name}
    FOR  ${alias}  IN  @{BTS_alias_list}
        Set Qc Parameter  qc_tc_swbuild  ${qc_target_sw}; ${QC ${alias} Active SW}
    END

Step ${index}: Check and set swFallbackTimer parameter value on BTS
    [Documentation]
    ...  Check and set swFallbackTimer parameter value on BTS

    Log  Step ${index}: Check and set swFallbackTimer parameter value on BTS  console=True

    Set Test Variable  ${swFallbackTimer}  0

    FOR  ${alias}  IN  @{BTS_alias_list}
        ${BTS_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
        Log  Check swFallbackTimer parameter value on ${BTS_label}:  console=True
        ${swFallbackTimer_value}=  Get swFallbackTimer parameter value  ${alias}
        Set Test Variable  ${${alias}_swFallbackTimer_value_initial}  ${swFallbackTimer_value}
        Run Keyword If  '${swFallbackTimer_value}' == 'None'  Run Keywords
        ...  Log  Parameter swFallbackTimer value not set on ${BTS_label}. Need to set parameter swFallbackTimer = ${swFallbackTimer}.  console=True
        ...  AND  Set swFallbackTimer parameter value  ${swFallbackTimer}  update  ${alias}
        ...  ELSE IF  '${swFallbackTimer_value}' == '${swFallbackTimer}'
        ...  Log  Parameter swFallbackTimer = ${swFallbackTimer} already set on ${BTS_label}, no action needed!  console=True
        ...  ELSE  Run Keywords
        ...  Log Long String  Parameter swFallbackTimer = ${swFallbackTimer_value} on ${BTS_label}, need to set parameter
        ...  swFallbackTimer = ${swFallbackTimer}  console=True
        ...  AND  Set swFallbackTimer parameter value  ${swFallbackTimer}  update  ${alias}
    END

Step ${index}: Test SW Fallback functionality with Cold Reset on BTS for iteration ${CYCLE}
    [Documentation]
    ...  Test BTS SW Fallback functionality on BTS checking states and alarms

    Log  Step ${index}: Test SW Fallback functionality with Cold Reset on BTS for iteration ${CYCLE}  console=True

    FOR  ${alias}  IN  @{BTS_alias_list}
        ${BTS_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
        Set Test Variable  ${alias}
        Set Test Variable  ${BTS_label}
        Test BTS SW Fallback functionality with Cold Reset
    END

    Return From Keyword If  '${RESTORE_INITIAL_BTS_SW}' == 'False' and (${REPEAT_COUNTER} == 1 or ${CYCLE} == ${REPEAT_COUNTER})

    FOR  ${alias}  IN  @{BTS_alias_list}
        ${BTS_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
        Set Test Variable  ${alias}
        Set Test Variable  ${BTS_label}
        Log  ==================================================================================================  console=True
        Log  ***** Perform BTS SW Rollback and Synchronize Active and Passive SW versions on ${BTS_label} *****  console=True
        Log  ==================================================================================================  console=True
        Perform BTS SW Rollback operation
        Synchronize active and pasive SW versions
    END

Test BTS SW Fallback functionality with Cold Reset
    [Documentation]
    ...  Test BTS SW Fallback functionality with Cold Reset on BTS checking states and alarms

    Log  ======================================================================  console=True
    Log  ***** Test SW Fallback functionality with Cold Reset on ${BTS_label} *****  console=True
    Log  ======================================================================  console=True

    Log  ***** Get initial SW versions from ${BTS_label} partitions *****  console=True
    Get SW versions from BTS partitions  initial

    Log  ***** Get initial RESET info from blackbox file for ${BTS_label} *****  console=True
    Get RESET info from blackbox file  alias=${alias}  when=initial

    Log  ***** Perform BTS SW Update with download check and activation on ${BTS_label} *****  console=True
    BTS SW Update with download check and activation

    Log  ***** Perform LMP and EIF down operation on ${BTS_label} *****  console=True
    Perform LMP and EIF operation on BTS  down

    Log  ***** Perform LMP and EIF up operation on ${BTS_label} *****  console=True
    Perform LMP and EIF operation on BTS  up

    Log  ***** Get final RESET info from blackbox file for ${BTS_label} *****  console=True
    Get RESET info from blackbox file  alias=${alias}  when=final

    Log  ***** Check BTS reset behavior on ${BTS_label} based on blackbox file *****  console=True
    Check BTS Reset bevahior

    Log  ***** Get after LMP and EIF up operation SW versions from ${BTS_label} partitions *****  console=True
    Get SW versions from BTS partitions  after

    Log  ***** Check ${BTS_label} alarms after LMP and EIF up operation on ${BTS_label} *****  console=True
    Check BTS alarms after LMP and EIF up operation

    Log  ***** Perform SW Update to N+1 SW version on ${BTS_label} *****  console=True
    Activate N+1 SW version on BTS  after

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Check if SW version already exists on BTS
    FOR  ${alias}  IN  @{BTS_alias_list}
        Check if SW already exists on BTS  ${Target SW}  ${${alias} active SW}  ${${alias} passive SW}
    END

Check planned software build name
    [Arguments]  ${Target SW name}  ${alias}
    Log  Get downloaded SW build name  console=True
    ${BTS_SW_Info}=   Get software info  alias=${alias}
    ${Planned_SW}=  Get from dictionary  ${BTS_SW_Info}  Planned SW version
    Run Keyword If  '${Planned_SW}' == '${Target SW name}'
    ...  Log  Planned SW build is the same as ${Target SW name}. Download build was successful!  console=True
    ...  ELSE  Fail  Download SW build action without activation failed!

Get SW versions from BTS partitions
    [Arguments]  ${when}

    ${remote_host_ip}=  Set Variable If  '${alias}' == 'Master'  None  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]
    Run Keyword If  '${when}' == 'after'
    ...  Wait For Target To Be Reachable TAF  hostname=${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]  timeout=${BTS_MAX_WAIT_TIME}
    ...  remote_host=${remote_host_ip}

    Admin Get BTS SW Version  ${alias}
    Set Test Variable  ${${alias} ${when} active SW}  ${${alias} active SW}

    Run Keyword If  '${when}' == 'after'
    ...  Run Keyword If  '${${alias} initial active SW}' == '${${alias} after active SW}'
    ...  Log  Active SW build on ${BTS_label}, as expected!
    ...  ELSE IF  '${when}' == 'after'
    ...  Fail  Active SW build on ${BTS_label}, not as expected!

BTS SW Update with download check and activation
    Get Current Date UTC info  start
    Perform Download N+1 SW on BTS
    Activate N+1 SW version on BTS  initial

Perform Download N+1 SW on BTS
    [Documentation]
    ...  Perform Download N+1 SW version on BTS

    Log  Start Download build ${Target SW name} without activation on ${BTS_label}  console=True

    ${new_alias}=  Set Variable  downloadSession
    Start new ADMIN instance  alias=${alias}  new_alias=${new_alias}  connection_type=${connection_type_${alias}}

    Adding alarms to ignored list  ${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}  connection_alias=${alias}
    ${download_thread}=  coam.Run Keyword In Background  Update Software  sw_package=${Target SW}  should_activate=False
    ...  timeout=${SW Update Timeout}  connection=downloadSession

    ${alarms_info_response}=  Create List
    ${alarms_info_result}  ${alarms_info_response}=  Wait Until Keyword Succeeds  90 min  10 s  Check alarms while thread is running
    ...  ${download_thread}  ${alias}  ${alarms_info_response}
    Collect Keyword Result  ${download_thread}  timeout=${SW Update Timeout}

    Run Keyword And Continue On Failure  Run Keyword If  '${alarms_info_result}' == 'FAIL'
    ...  Fail  Unexpected alarms occurred during ${BTS_label} Software Download -- ${alarms_info_response}
    ...  ELSE  Log  No unexpected alarms found during ${BTS_label} Software Download  console=True

    Check planned software build name  Target SW name=${Target SW name}  alias=${alias}

    [Teardown]  Teardown Admin  alias=${new_alias}

Activate N+1 SW version on BTS
    [Documentation]
    ...  Activate N+1 SW version on BTS
    [Arguments]  ${when}

    Log  Perform SW build ${Target SW name} activation on ${BTS_label}  console=True
    coam.Update Software  sw_package=${Target SW}  should_activate=True  timeout=${SW Update Timeout}  connection=${alias}
    Log  ${BTS_label} SW Update: download finished, waiting for activation reset!  console=True

    ${remote_host_ip}=  Set Variable If  '${alias}' == 'Master'  None  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]
    Wait For Target To Be Not Reachable TAF  hostname=${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]  timeout=${BTS_MAX_WAIT_TIME}
    ...  remote_host=${remote_host_ip}

    Get Current Time  bts_initial
    Log  ${BTS_label} reset_start_time is: ${time_bts_initial}  console=True

    Run Keyword If  '${when}' == 'after'  Run Keywords
    ...  Log  ***** Check ${BTS_label} state and alarms after final ${BTS_label} SW Update *****  console=True
    ...  AND  Check final BTS state and alarms  fid_4420_check=True

Perform LMP and EIF operation on BTS
    [Documentation]
    ...  Perform LMP and EIF down or up operation on BTS
    [Arguments]  ${operation}

    ${EIF_info}=  Set Variable If
    ...  '${operation}' == 'down' and '${BTS_label}' == 'BTS1'  ${BTS1_EIF_down}
    ...  '${operation}' == 'up' and '${BTS_label}' == 'BTS1'  ${BTS1_EIF_up}
    ...  '${operation}' == 'down' and '${BTS_label}' == 'BTS2'  ${BTS2_EIF_down}
    ...  '${operation}' == 'up' and '${BTS_label}' == 'BTS2'  ${BTS2_EIF_up}
    ${EIF_pass}=  Set Variable If
    ...  '${operation}' == 'down' and '${BTS_label}' == 'BTS1'  ${BTS1_EIF_pass_down}
    ...  '${operation}' == 'up' and '${BTS_label}' == 'BTS1'  ${BTS1_EIF_pass_up}
    ...  '${operation}' == 'down' and '${BTS_label}' == 'BTS2'  ${BTS2_EIF_pass_down}
    ...  '${operation}' == 'up' and '${BTS_label}' == 'BTS2'  ${BTS2_EIF_pass_up}
    ${EIF_ip}=  Set Variable If
    ...  '${BTS_label}' == 'BTS1'  ${BTS1_EIF_Switch_IpAddress}  ${BTS2_EIF_Switch_IpAddress}

    ${BTS_secondary_core}=  Run Keyword And Return Status
    ...  Dictionary Should Contain Key  ${${alias.upper()}_EXT}  ${alias.upper()}_EXT_PC_IP_ADDRESS
    Set Test Variable  ${${alias}_BTS_secondary_core}  ${BTS_secondary_core}

    Perform EIF operation on BTS  ${operation}  ${EIF_info}  ${EIF_pass}  ${EIF_ip}
    Perform LMP operation on BTS  ${operation}  primary
    Run Keyword If  '${BTS_secondary_core}' == 'True'
    ...  Perform LMP operation on BTS  ${operation}  secondary

    Run Keyword If  '${operation}' == 'up'  Run Keywords
    ...  Log  LMP and EIF ${operation} operation on ${BTS_label} ended, wait 20 min for BTS reactivity.  console=True
    ...  AND  Sleep  20m
    ...  AND  Return From Keyword

    Log  LMP and EIF ${operation} operation on ${BTS_label} ended, wait 105 min.  console=True
    Sleep  105m

Perform EIF operation on BTS
    [Arguments]  ${operation}  ${info}  ${pass}  ${ip}

    ${command}=  Set Variable  sudo sshpass -p ${pass} ssh -tt ${info}@${ip}
    Log  Perform EIF ${operation} operation on ${BTS_label} by following command:\n ${command}  console=True
    ${output}=  Run Process  ${command}  stderr=STDOUT  shell=True
    ${status}=  Run Keyword And Return Status  Should Be Equal As Integers  ${output.rc}  0
    ${status1}=  Run Keyword And Return Status  Should Be Equal As Integers  ${output.rc}  255
    Run Keyword If  '${status}' == 'False'
    ...  Run Keyword If  '${status1}' == 'False'  Run Keywords
    ...  Log Long String  EIF ${operation} operation on ${BTS_label} could not be performed! Please verify if
    ...  ${info} command is correct!  lever=ERROR
    ...  AND
    ...  Fail  EIF ${operation} operation on ${BTS_label} could not be performed! Please verify if ${info} command is correct!
    Log  EIF ${operation} operation on ${BTS_label} ended!  console=True

Perform LMP operation on BTS
    [Arguments]  ${operation}  ${BTS_core}

    ${command}=  Run Keyword If  '${operation}' == 'down'
    ...  Create Long String
    ...  sudo iptables -F;
    ...  sudo iptables -A INPUT -i eth1 -p udp -m multiport --dports 51000,51001,51003,50011 -j ACCEPT;
    ...  sudo iptables -A INPUT -i eth1 -j DROP;
    ...  sudo iptables -A FORWARD -i eth1 -p udp -m multiport --dports 51000,51001,51003,50011 -j ACCEPT;
    ...  sudo iptables -A FORWARD -i eth1 -j DROP
    ...  ELSE IF  '${operation}' == 'up'
    ...  Set Variable  sudo service iptables restart

    Log  Perform LMP ${operation} operation on ${BTS_label} ${BTS_core} core by following command:\n ${command}  console=True

    Run Keyword if  '${alias}' == 'Master' and '${BTS_core}' == 'primary'
    ...  Execute Local Command  command=${command}
    ...  ELSE IF  '${alias}' != 'Master' and '${BTS_core}' == 'primary'
    ...  Execute Remote Command  command=${command}  index_or_alias=remote  host_ip=${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]
    ...  ssh_port=${${alias.upper()}}[${alias.upper()}_PC_SSH_PORT]  ssh_username=${${alias.upper()}}[${alias.upper()}_PC_SSH_USERNAME]
    ...  ssh_password=${${alias.upper()}}[${alias.upper()}_PC_SSH_PASSWORD]
    ...  ELSE IF  '${BTS_core}' == 'secondary'
    ...  Execute Remote Command  command=${command}  index_or_alias=remote  host_ip=${${alias.upper()}_EXT}[${alias.upper()}_EXT_PC_IP_ADDRESS]
    ...  ssh_port=${${alias.upper()}_EXT}[${alias.upper()}_EXT_PC_SSH_PORT]  ssh_username=ute  ssh_password=ute

    Log  LMP ${operation} operation on ${BTS_label} ${BTS_core} core ended!  console=True

Check BTS alarms after LMP and EIF up operation
    ${IGNORED_ALARMS_full}=  Combine Lists  ${test_alarms_list['${alias.upper()}_IGNORED_ALARMS_AFTER_FALLBACK']}
    ...  ${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
    ${FID4085_alarm_count}=  Set Variable If  ${${alias}_BTS_secondary_core}  2  1
    ${EXPECTED_ALARMS_4085_full}=  Prepare expected alarms list  ${test_alarms_list['${alias.upper()}_EXPECTED_ALARMS_4085']}  ${FID4085_alarm_count}

    Log  ${BTS_label} "SW fallback (4085)" alarm, expected number: ${FID4085_alarm_count}  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=${EXPECTED_ALARMS_4085_full}
    ...  ignored_alarms=${IGNORED_ALARMS_full}  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}
    Log  ${BTS_label} "SW fallback (4085)" alarm, found number: ${FID4085_alarm_count}, as expected!  console=True
    Log  ${BTS_label} site - expected, ignored and critical alarms checked  console=True

Check BTS Reset bevahior
    ${reset_reason_info_diff}=  Get the differences between blackbox files  ${${alias}_reset_reason_initial}  ${${alias}_reset_reason_final}

    Set Test Variable  ${cold_reset_found}  False

    FOR  ${blackbox_reason}  IN  @{reset_reason_info_diff}
        ${reason}=  Convert To String  ${blackbox_reason}
        ${reset_reason_verdict}=  Run Keyword And Return Status  Should Match Regexp  ${reason}  .*1h05min.*StartupSupervision.*
        Run Keyword If  '${reset_reason_verdict}' == 'True'  Run Keywords
        ...  Set Test Variable  ${cold_reset_found}  True
        ...  AND  Exit For Loop
    END

    Run Keyword and Continue on Failure  Run Keyword If  '${cold_reset_found}' == 'True'  Run Keywords
    ...  Log  ${BTS_label} Cold Reset was found at: ${reason}  console=True
    ...  AND  Log to console found resets in blackbox file  ${reset_reason_info_diff}
    ...  ELSE  Run Keywords
    ...  Log  ${BTS_label} Cold Reset was not found in blackbox file!  level=ERROR
    ...  AND  Log to console found resets in blackbox file  ${reset_reason_info_diff}
    ...  AND  Fail  ${BTS_label} Cold Reset was not found in blackbox file!

Log to console found resets in blackbox file
    [Arguments]    ${reset_reason_info_list}

    Log  ${BTS_label} found resets are:  console=True
    FOR  ${blackbox_reason}  IN  @{reset_reason_info_list}
        Log  ${blackbox_reason}  console=True
    END

Check final BTS state and alarms
    [Arguments]  ${fid_4420_check}=False

    ${CELL_state_enabled}=  Set Variable  operationalState=Enabled, blockingState=Unblocked
    ${remote_host_ip}=  Set Variable If  '${alias}' == 'Master'  None  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]

    Wait For Target To Be Reachable TAF  hostname=${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]  timeout=${BTS_MAX_WAIT_TIME}
    ...  remote_host=${remote_host_ip}

    Sleep  120s
    Wait Until Keyword Succeeds  3x  10s  Admin reset and Infomodel reconnect sessions  reset_req=True  alias=${alias}  infomodel_reset=False

    Log  Check ${BTS_label} status:  console=True
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${BTS_MAX_WAIT_TIME}  ${alias}
    Log  ${BTS_label} site - proceduralState: OnAir, blockingState: Unblocked  console=True
    Check cells availability status online  ${alias}  ${BTS_MAX_WAIT_TIME}
    Log  All ${BTS_label} cell(s) status:\n - ${CELL_state_enabled}  console=True

    Log  Check ${BTS_label} alarms:  console=True

    Run Keyword If  '${fid_4420_check}' == 'True'  Check if BTS faultId 4420 alarm is active

    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
    ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}
    Log  ${BTS_label} site - expected, ignored and critical alarms checked  console=True

Check if BTS faultId 4420 alarm is active
    [Documentation]
    ...  Check if BTS faultId 4420 alarm is active and wait for it to be cleared

    ${fid_4420_status}=  Run Keyword And Return Status  Assert Alarm Active  parameters=faultId=4420  timeout=120  connection=${alias}
    Run Keyword If  ${fid_4420_status}
    ...  Log Long String  ${BTS_label} "GPS receiver alarm: firmware upgrade ongoing (4420)" alarm was detected. Wait maximum 25 minutes
    ...  for alarm to be cleared.  console=True
    ...  ELSE  Return From Keyword

    ${fid_4420_status}=  Run Keyword And Return Status  Assert Alarm Inactive  parameters=faultId=4420  timeout=1500  interval=30  connection=${alias}
    Run Keyword If  ${fid_4420_status}
    ...  Log  ${BTS_label} "GPS receiver alarm: firmware upgrade ongoing (4420)" alarm was cleared, as expected!  console=True
    ...  ELSE
    ...  Log  ${BTS_label} "GPS receiver alarm: firmware upgrade ongoing (4420)" alarm was NOT cleared after 25 minutes!  level=WARN

Perform BTS SW Rollback operation
    [Documentation]
    ...  Helper keyword used to perform BTS SW Rollback operation

    Log  Perform ${BTS_label} SW Rollback  console=True
    coam.Rollback Software  connection=${alias}  timeout=${BTS_MAX_WAIT_TIME}

    ${remote_host_ip}=  Set Variable If  '${alias}' == 'Master'  None  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]
    Wait For Target To Be Not Reachable TAF  hostname=${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]  timeout=${BTS_MAX_WAIT_TIME}
    ...  remote_host=${remote_host_ip}

    Check final BTS state and alarms

Synchronize active and pasive SW versions
    [Documentation]
    ...  Helper keyword used to synchronize Active and Passive partition SW

    Sleep  5min  reason=Wait additional 5 min before synchronizing SW versions to ensure that X2 link is available
    Log  Synchronize active and pasive SW versions on ${BTS_label}  console=True
    Admin Synchronizing Active and Passive SW version  alias=${alias}  timeout=600

Recover initial settings for parameter swFallbackTimer
    [Arguments]  ${alias}

    Log  Recover initial settings for parameter swFallbackTimer on BTS ${alias}  console=True
    Run Keyword If  '${${alias}_swFallbackTimer_value_initial}' == '${swFallbackTimer}'  Return From Keyword
    ...  ELSE IF  '${${alias}_swFallbackTimer_value_initial}' == 'None'
    ...  Set swFallbackTimer parameter value  ${swFallbackTimer}  delete  ${alias}
    ...  ELSE
    ...  Set swFallbackTimer parameter value  ${${alias}_swFallbackTimer_value_initial}  update  ${alias}

Particular Teardown
    FOR  ${alias}  IN  @{BTS_alias_list}
        Run Keyword And Continue On Failure  Recover initial settings for parameter swFallbackTimer  ${alias}
    END

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}  newAlarmsFormat=${TRUE}

TC Teardown
    Common Test Teardown
