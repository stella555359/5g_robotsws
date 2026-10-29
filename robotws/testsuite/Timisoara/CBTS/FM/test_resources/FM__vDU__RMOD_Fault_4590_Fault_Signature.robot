*** Settings ***
Documentation
    ...  This TC is created to verify that the fault signature fields are populated in the alarm raised
    ...  for fault ID 4590 on radio AEQP.
    ...  Connect to vDU via ssh connection.
    ...  Connect to pod and interrogate IPs to find the correct RU and connect to it via ssh.
    ...  Find and crash the eventcollector process on the RU.
    ...  RMOD recovery reset is triggered. Alarm 7115 is reported in WebEM.
    ...  Check that fault 4590 is reported in WebEM and fault signature fields are updated correctly
    ...  according to OM_GEN_SFS_FM.3055

Resource  ../../common_resources/vdu_frame.robot
Resource  ../../common_resources/vdu_general.robot
Resource  ../../common_resources/cbts_general.robot
Resource  ../../common_resources/M2M_Interface.robot


*** Variables ***
${RMOD_TYPE}  ${EMPTY}  #RMOD product name
${DC}  ${TRUE}  #Configuration type
${RECOVERY_TIMEOUT}  900s  # Timeout for CBTS to be onAir


*** Keywords ***
TC__FM__vDU__RMOD_Fault_4590_Fault_Signature
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25212
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  07.04.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25212 - Initial TAT creation
    ...  30.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28026 - Add check for 4241-4247 faults in Raw Fault History.
    ...  21.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28778 - Fix crash method and adapt test to DC platforms.
    ...  09.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29831 - Change method of connecting to RMOD and retrieving pod and container name

    Set Tags  CA-FM  OWNER-mircea.vladulescu@nokia.com  MAINTAINER-victor.banicioiu@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT
    ...  SW-SBTS23  FEATURE-CB007823


    Step 1: TC Preconditions
    Step 2: Connect To RF
    Step 3: Crash Eventcollector Process
    Step 4: Check Alarm 7115 Is Raised In WebEM
    Step 5: Check Fault 4590 And Fault Signature Fields Using M2M Interface
    Step 6: Check RMOD Is Recovered
    Step 7: Verify Raw Alarm History file
    Step 8: Check RMOD Is Recovered


Step 1: TC Preconditions
    Log  \nStep 1: TC Preconditions  console=true

    Should Not Be Empty  ${RMOD_TYPE}  msg=Please provide RMOD product name.
    ${date_time_raw}  Get Current Date  exclude_millis=True
    ${date_raw}  Fetch From Left  ${date_time_raw}  ${SPACE}
    ${start_time_raw}  Fetch From Right  ${date_time_raw}  ${SPACE}
    Set Test Variable  ${DATE_RAW}
    Set Test Variable  ${START_TIME_RAW}
    ${rmods}  vdu.Get Rmods Status
    ${all_rmods_ips}  Get All RMODs IPs from vDU
    FOR  ${current_rmod}  IN  @{rmods}
         IF  '${current_rmod}[product_name]' == '${RMOD_TYPE}'
             ${active_sw_build}  Split String  ${current_rmod}[active_sw_build]  .
             ${rmod_user}  ${rmod_password}  Get User And Password For RMOD  ${active_sw_build}[1]  ${current_rmod}[product_name]
             ${rmod_ip}  Get Ip For RMOD  ${current_rmod}[serial_number]  ${rmod_user}  ${rmod_password}  ${all_rmods_ips}  dc=${DC}
             ${rmod}  Create Dictionary   serial_number=${current_rmod}[serial_number]
             ...                          id=${current_rmod}[id]
             ...                          ip=${rmod_ip}
             ...                          user=${rmod_user}
             ...                          password=${rmod_password}
             Set Test Variable  ${RMOD}
             BREAK
         END
    END
    Should Not Be Empty  ${RMOD}  msg=Could not retrieve information for RMOD - ${RMOD_TYPE}.
    Log  Chosen RMOD information: ${RMOD}
    ${expected_faults}  Create Dictionary  4241=Unexpected Radio Reset Cause SwFailure
    ...                                    4242=Unexpected Radio Reset Cause Unknown
    ...                                    4243=Unexpected Radio Reset Cause Management
    ...                                    4244=Unexpected Radio Reset Cause Watchdog
    ...                                    4246=Radio Reset Cause PowerOn
    ...                                    4247=Radio Reset Cause Management
    Set Test Variable  ${EXPECTED_FAULTS}


Step 2: Connect To RF
    Log  \nStep 2: Connect to RF  console=true
    Open SSH Connection To Specific RMOD  ${RMOD}[ip]  ${RMOD}[user]  ${RMOD}[password]  ${RMOD}[serial_number]  dc=${DC}


Step 3: Crash Eventcollector Process
    Log  \nStep 3: Crash eventcollector process  console=true

    Write  ps | grep eventcollector
    Sleep  2s  Wait for output
    ${output}  Read
    ${processes}  Get Lines Containing String  ${output}  {eventcollector
    Should Not Be Empty  ${processes}  Error: "The process id for the eventcollector process was not found" [NOK]
    ${process_id}  Split String  ${processes}
    Write  sudo kill -11 ${process_id}[0]
    Sleep  15s  Wait to disconnect
    ${output}  Read
    ${status}  Run Keyword And Return Status  Should Contain  ${output}  closed by remote host
    IF  ${status}  Log  Successfuly killed eventcollector process.  console=true
    ${timestamp}  Get Current Date  exclude_millis=true
    Set Test Variable  ${FAULT_TIMESTAMP}  ${timestamp}


Step 4: Check Alarm 7115 Is Raised In WebEM
    Log  \nStep 4: Check alarm 7115 is raised in WebEM  console=true

    Wait Until Keyword Succeeds  5m  10s  Verify RMODs Parameter From VDU  operational_state  disabled
    Log  RMOD recovery reset is started.  console=true
    Sleep  200s  Wait for alarm 7115 to be raised
    ${alarms_output}  Vdu Get Historical Alarms  sorted_by=appearTime  sort_order=desc  filter_by_text=7115
    IF  ${alarms_output}[total]==0  Fail  Error: "No alarm 7115 was found in alarm history" [NOK].
    ${alarms_list}  Set Variable  ${alarms_output}[alarms]
    ${appear_timestamp}  Set Variable  ${EMPTY}
    FOR  ${alarm}  IN  @{alarms_list}
         ${fault_status}  Run Keyword And Return Status  Should Be Equal As Strings  4590  ${alarm}[fault_id]
         ${last_alarm}  Replace String  ${alarm}[appear_time]  T  ${SPACE}
         ${last_alarm}  Fetch From Left  ${last_alarm}  .
         IF  not(${fault_status} and '${last_alarm}' > '${FAULT_TIMESTAMP}')  CONTINUE
         Set Test Variable  ${APPEAR_TIMESTAMP}  ${alarm}[appear_time]
         BREAK
    END
    Should Not Be Empty  ${APPEAR_TIMESTAMP}  Error: "Alarm with fault id: 4590 not found in historical alarms list" [NOK].


Step 5: Check Fault 4590 And Fault Signature Fields Using M2M Interface
    Log  \nStep 5: Check fault 4590 and fault signature fields using M2M interface  console=true

    ${url}  Catenate  SEPARATOR=  "https://${VDU_OAM_IP}/api/licensed/v2/alarms/historical?
    ...  pageNumber=1&itemsPerPage=5&sortedBy=appearTime&sortOrder=desc&filterByText=4590"
    ${hist_alarms_output}  Run M2M Command  GET  ${url}  Bearer  ${TOKEN}
    ${output}  Remove M2M Output Noise  ${hist_alarms_output}
    ${output}  Fetch From Right  ${output}  {\n\t"alarms" :
    ${output}  Fetch From Left  ${output}  ,\n\t"total" :
    ${alarms_list}  Evaluate  json.loads('''${output}''')  json
    Should Be Equal As Strings  ${alarms_list}[0][appearTime]  ${APPEAR_TIMESTAMP}
    ...  Error: "The selected fault 4590 entry is not the same as the one selected for alarm 7115" [NOK].
    Check Fault Signature Fields  ${alarms_list}[0][faultSignature]


Step ${index}: Check RMOD Is Recovered
    Log  \nStep ${index}: Check RMOD is recovered  console=true

    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s  Verify RMODs Parameter From VDU  operational_state  ${ENABLED}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s  Verify RMODs Parameter From VDU  administrative_state  ${UNLOCKED}
    Log  RMOD successfully recovered.  console=true
    Wait Until Keyword Succeeds  900s  10s  Check All Cells From VDU  operational_state=${ENABLED}
    Log  All cells are back online.  console=true


Step 7: Verify Raw Alarm History file
    Log  \nStep 7: Verify Raw Alarm History file.  console=true

    Open SSH Connection To Specific RMOD  ${RMOD}[ip]  ${RMOD}[user]  ${RMOD}[password]  ${RMOD}[serial_number]  dc=${DC}
    SSHLibrary.Set Client Configuration  prompt=REGEXP:(~#|\\$|\\n\\$)
    SSHLibrary.Write  echo $'/ action create ResetControl /rc /module' | frmonShellClient 127.0.0.1 2000
    ${create_command_output}  SSHLibrary.Read Until Prompt
    Should Contain  ${create_command_output}  done ok  "create" command not executed correctly. [NOK]
    SSHLibrary.Write  echo $'/rc get supported_reset_causes' | frmonShellClient 127.0.0.1 2000
    ${get_command_output}  SSHLibrary.Read Until Prompt
    Should Contain  ${get_command_output}  done ok  "get" command not executed correctly. [NOK]
    SSHLibrary.Write  echo $'/rc action commit_reset 1' | frmonShellClient 127.0.0.1 2000
    SSHLibrary.Set Client Configuration  prompt=REGEXP:(bash.*\\$)  timeout=80s
    ${commit_command_output}  SSHLibrary.Read Until Prompt
    Should Contain  ${commit_command_output}  done ok  "commit" command not executed correctly. [NOK]
    Sleep  30s  Wait for RawFaultHistory to be generated.
    SSHLibrary.Write  cd /mnt/services/SS_OAM/OAMFM/rawFaultHistory
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  ls -la
    ${ls_output}  SSHLibrary.Read Until Prompt
    Should Contain  ${ls_output}  rawFaultHistory  rawFaultHistory file not generated. [NOK]
    SSHLibrary.Write  cat rawFaultHistory
    ${file_content}  SSHLibrary.Read Until Prompt
    FOR  ${fault_id}  IN  @{EXPECTED_FAULTS.keys()}
         ${fault_status}  Run Keyword And Return Status  Verify Fault In RawFaultHistory File  ${file_content}
         ...                                                                                   ${fault_id}
         ...                                                                                   ${EXPECTED_FAULTS}[${fault_id}]
         ...                                                                                   ${DATE_RAW}
         ...                                                                                   ${START_TIME_RAW}
         IF  not ${fault_status}  CONTINUE
         Log  Fault with id: ${fault_id} and fault name: ${EXPECTED_FAULTS}[${fault_id}] reported in "rawFaultHistory". [OK]  console=true
         Wait Until Keyword Succeeds  5m  10s  Verify RMODs Parameter From VDU  operational_state  disabled
         RETURN
    END
    Fail  No fault from ${EXPECTED_FAULTS} list reported in "rawFaultHistory" file on current date, after ${START_TIME_RAW}. [NOK]


Extract Working IP
    [Arguments]  ${line}

    ${ip}  Get Regexp Matches  ${line}  192\.168\.254\.[0-9]{1,3}
    Set Test Variable  ${RF_IP}  ${ip}[0]


Check Fault Signature Fields
    [Documentation]  This keyword is used to evaluate the fault signature fields of an alarm output obtained
    ...  from the alarm history. The keyword checks that the mandatory fields are present and they adhere
    ...  to OM_GEN_SFS_FM.3055 convention.
    ...  Arguments are:
    ...  ${alarm} - represents one of the alarms obtained from alarm history, in the form of a dictionary
    ...  The keyword will fail if any of the mandatory fields is non-existent or if its value do not adhere
    ...  to the OM_GEN_SFS_FM.3055 convention.
    [Arguments]  ${alarm}

    @{category}  Create List  OAM_RESET  ASSERT  EXCEPTION  TIMEOUT  POWER_OFF  SW_FAILURE  HW_FAILURE  UNKNOWN
    @{scope}  Create List  Site  Board  Partial  DSP group  BBPOOL  RFM  ESM  GSM RAT  WCDMA RAT  LTE RAT  NR RAT  SoC
    ${status}  Run Keyword And Return Status
    ...  List Should Contain Value  ${category}  ${alarm}[category]
    IF  ${status}
        Log  'Category' field in fault signature is correctly displayed.  console=true
    ELSE
        Fail  Error: "Category field in fault signature is not displayed correctly" [NOK].
    END
    ${status}  Run Keyword And Return Status
    ...  Should Be Equal  ${alarm}[loadName]  ${VDU_ACTIVE_SW_VERSION}
    IF  ${status}
        Log  'loadName' field in fault signature is correctly displayed.  console=true
    ELSE
        Fail  Error: "loadName field in fault signature is not displayed correctly" [NOK].
    END
    ${status}  Run Keyword And Return Status
    ...  Should Match Regexp  ${alarm}[component]  [A-Za-z0-9]*
    IF  ${status}
        Log  'Component' field in fault signature is correctly displayed.  console=true
    ELSE
        Fail  Error: "Component field in fault signature is not displayed correctly" [NOK].
    END
    ${status}  Run Keyword And Return Status
    ...  List Should Contain Value  ${scope}  ${alarm}[scope]
    IF  ${status}
        Log  'Scope' field in fault signature is correctly displayed.  console=true
    ELSE
        Fail  Error: "Scope field in fault signature is not displayed correctly" [NOK].
    END


TC Setup
    Common VDU Setup
    Modify Resource Search Order  FM__vDU__RMOD_Fault_4590_Fault_Signature
    Login Using M2M Interface  ${VDU_OAM_IP}


TC Teardown
    Close All Connections
    Logout Using M2M Interface  ${VDU_OAM_IP}
    Common VDU Teardown
