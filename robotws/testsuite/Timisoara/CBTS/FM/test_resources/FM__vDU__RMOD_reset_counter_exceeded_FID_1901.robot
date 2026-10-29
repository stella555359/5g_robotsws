*** Settings ***
Documentation
    ...  This TC is created to check alarms after changing the name of a file on the given RMOD.
    ...  The connections on the RMOD pod and on the RMOD are opened.
    ...  Fault 1901 is triggered after the name of one file on the RMOD is changed and reset RMOD is performed.
    ...  Alarms are checked in WebEM and Netact.
    ...  Fault "Radio autonomous reset as recovery action" should be visible 3 times.
    ...  Fault "RF Module critical file not found" should remain active on WebEM.
    ...  Fault signature of "Radio autonomous reset as recovery action" is checked on WebEM and Netact.
    ...  Fault "RF Module critical file not found" is checked on WebEM and Netact.
    ...  The connection to vCU is opened.
    ...  Fault 7104 and fault 7300 are checked in vCU. These should be visible on active alarms.
    ...  The additional info on these alarms is checked and will be written on a warning log level.
    ...  In the end, recovery action on RMOD is performed - that one name file on the RMOD will be changed to the initial one
    ...  and reset RMOD is performed.
    ...  All RMODs and cells are on air.

Resource  ../../common_resources/vdu_frame.robot
Resource  ../../common_resources/vcu_frame.robot
Resource  ../../common_resources/vdu_general.robot


*** Variables ***
${RMOD_PRODUCT_NAME}  AHFII  # Product name of the RMOD
${RMOD_USER}  rfsw  # Username used to login to RMOD from pod
${RMOD_PASSWORD}  0q/7SXKjF2AlAba+yisrCxQiKz1PRJJ0IVDZuh/sOaA=  # Password used to login to RMOD from pod
${EXPECTED_FAULT_ID_FIRST}  1901  # Expected first fault id that will be checked by test
${EXPECTED_FAULT_NAME_FIRST}  Radio autonomous reset as recovery action  # Expected first fault name that will be checked by test
${EXPECTED_ALARM_ID_SECOND}  7111  # Expected second alarm id that will be checked by test
${EXPECTED_ALARM_NAME_SECOND}  BASE STATION SOFTWARE MANAGEMENT PROBLEM  # Expected second alarm name that will be checked by test
${EXPECTED_FAULT_ID_SECOND}  1901  # Expected second fault id that will be checked by test
${EXPECTED_FAULT_NAME_SECOND}  RF Module critical file not found  # Expected second fault name that will be checked by test
${SEVERITY_SECOND}  critical  # Expected second severity that will be checked by test
${EXPECTED_ALARM_ID_THIRD}  7114  # Expected third alarm id that will be checked by test
${EXPECTED_ALARM_NAME_THIRD}  CELL SERVICE PROBLEM  # Expected third alarm name that will be checked by test
${EXPECTED_FAULT_ID_THIRD}  7104  # Expected third fault id that will be checked by test
${EXPECTED_FAULT_NAME_THIRD}  Matching ServedCell not found over F1-C  # Expected third fault name that will be checked by test
${SEVERITY_THIRD}  critical  # Expected third severity that will be checked by test
${EXPECTED_ALARM_ID_FOURTH}  7107  # Expected fourth alarm id that will be checked by test
${EXPECTED_ALARM_NAME_FOURTH}  BASE STATION CONNECTIVITY PROBLEM  # Expected fourth alarm name that will be checked by test
${EXPECTED_FAULT_ID_FOURTH}  7300  # Expected fourth fault id that will be checked by test
${EXPECTED_FAULT_NAME_FOURTH}  No X2 link available  # Expected fourth fault name that will be checked by test
${SEVERITY_FOURTH}  major  # Expected fourth severity that will be checked by test
${RECOVERY_TIMEOUT}  1200  # Recovery timeout
${ALARM_TIMEOUT}  1200  # Alarm timeout
${NETACT_IP_CMWAS}  ${EMPTY}  # CMWAS IP
${CATEGORY}  SW_FAILURE  # Expected category that will be checked by test
${SCOPE}  RFM  # Expected scope that will be checked by test


*** Keywords ***
TC__FM__vDU__RMOD_reset_counter_exceeded_FID_1901
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26998
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 29.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26998 - Initial TAT creation
    ...  - 30.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28026 - Add check for 4241-4247 faults in Raw Fault History.

    Set Tags  CA-FM  OWNER-catalin.botezatu@nokia.com  AUTHOR-cosmina.rebenciuc@nokia.com  MAINTAINER-cosmina.rebenciuc@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS24  FEATURE-CB008782

    Step1: Connect To RMOD Pod And Set Preconditions
    Step2: Trigger Fault 1901
    Step3: Check Alarms In WebEM And Netact
    Step4: Connect To VCU
    Step5: Check Alarms In VCU
    Step6: RMOD Recovery Action
    Step7: Disconnect From Netact And VCU
    Step8: Verify Raw Alarm History file


Step1: Connect To RMOD Pod And Set Preconditions
    Log  \nStep1: Connect to RMOD pod and set preconditions  console=true
    Change Specific Parameter For VDU  actFaultSignature  true  MRBTS-1234/MNL-1/MNLENT-1/FEATCADM-1
    ${rmod_ips}  Get All ECPRI RMODs Ips From RMODs Dedicated Pod  ${RMOD_USER}
    ${rmods_statuses}  vdu.Get Rmods Status
    FOR  ${rmod_statuses}  IN  @{rmods_statuses}
        Run Keyword If  '${rmod_statuses}[product_name]'=='${RMOD_PRODUCT_NAME}'
        ...  Run Keywords
        ...  Set Test Variable  ${RMOD_SN}  ${rmod_statuses}[serial_number]
        ...  AND
        ...  Set Test Variable  ${RMOD_ID}  ${rmod_statuses}[id]
    END
    ${rmod_ip}  Get ECPRI RMOD Ip By Serial Number  ${RMOD_SN}  ${RMOD_USER}  ${RMOD_PASSWORD}  ${rmod_ips}
    Set Test Variable  ${RMOD_IP}  ${rmod_ip}
    Open SSH Connection To ECPRI RMOD  ${RMOD_IP}  ${RMOD_USER}  ${RMOD_PASSWORD}
    ${date}  Get Current Date  result_format=datetime
    Set Test Variable  ${START_TIME}  ${date}
    ${date_netact}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME_NETACT}  ${date_netact}
    Log  Connect to Netact  console=true
    ${name}  Fetch From Right  ${VDU_MRBTS_NAME}  5g
    Set Test Variable  ${NAME_VDU}  ${name}
    netact.Add Node  cmwas  ${NETACT_IP_CMWAS}  ${NETACT_USERNAME}  ${NETACT_PASSWORD}
    ${netact_web_url}  netact.Detect Web Url
    Set Test Variable  ${NETACT_WEB_URL}  ${netact_web_url}
    netact.Add Web Url  ${NETACT_WEB_URL}  ${NETACT_USERNAME}  ${NETACT_PASSWORD}
    Set Test Variable  ${MRBTS_DN}  PLMN-PLMN/MRBTS-${VDU_MRBTS_ID}-${NAME_VDU}
    Set Test Variable  ${EXTRA_INFO}  (.*LTE:[0-9]+.*,)?.*NR:[0-9]+.*
    ${date_time_raw}  Get Current Date  exclude_millis=True
    ${date_raw}  Fetch From Left  ${date_time_raw}  ${SPACE}
    ${start_time_raw}  Fetch From Right  ${date_time_raw}  ${SPACE}
    Set Test Variable  ${DATE_RAW}
    Set Test Variable  ${START_TIME_RAW}
    ${expected_faults}  Create Dictionary  4241=Unexpected Radio Reset Cause SwFailure
    ...                                    4242=Unexpected Radio Reset Cause Unknown
    ...                                    4243=Unexpected Radio Reset Cause Management
    ...                                    4244=Unexpected Radio Reset Cause Watchdog
    ...                                    4246=Radio Reset Cause PowerOn
    ...                                    4247=Radio Reset Cause Management
    Set Test Variable  ${EXPECTED_FAULTS}


Step2: Trigger Fault 1901
    Log  \nStep2: Trigger fault 1901  console=true
    SSHLibrary.Set Client Configuration  prompt=$
    SSHLibrary.Write  sudo mount -o remount rw /mnt/factory
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  cd /mnt/factory/configs/unit
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  sudo mv /mnt/factory/configs/unit/calibration_dlpath1.bin /mnt/factory/configs/unit/temp_filename
    SSHLibrary.Read Until Prompt
    Log  Fault 1901 was sent.  console=true
    ${rmods_id_list}  Create List
    Append To List  ${rmods_id_list}  ${RMOD_ID}
    Set Test Variable  ${RMOD_LIST}  ${rmods_id_list}
    ${reset_status}  vdu.Reset Rmods  ${RMOD_LIST}
    Wait Until Keyword Succeeds  180s  10s
    ...  Verify RMOD Parameter By RMOD Id  ${RMOD_ID}  operational_state  ${DISABLED}
    Log  RMOD is disabled. [OK]  console=true


Step3: Check Alarms In WebEM And Netact
    Log  \nStep3: Check alarms in WebEM and Netact  console=true
    Verify RF Module Alarm In WebEM And Netact
    Verify Radio Autonomous Alarm In Webem And Netact


Step4: Connect To VCU
    Log  \nStep4: Connect to vCU  console=true
    Set Test Variable  ${VCU_OAM_IP}  ${VCU_CONNECTION_DETAILS}[IP_ADDRESS]
    Connect To VCU  host=${VCU_OAM_IP}


Step5: Check Alarms In VCU
    Log  \nStep5: Check alarms in vCU  console=true
    Log  Verify "${EXPECTED_FAULT_NAME_THIRD}" alarm if is active in WebEM.  console=true
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  30
    ...  Check If Fault Is Visible In VCU WebEM  ${EXPECTED_ALARM_ID_THIRD}
    ...  ${EXPECTED_ALARM_NAME_THIRD}
    ...  ${EXPECTED_FAULT_ID_THIRD}
    ...  ${EXPECTED_FAULT_NAME_THIRD}
    ...  ${SEVERITY_THIRD}
    ${status_info}  Run Keyword And Return Status
    ...  Should Contain  ${ALARM_INFO}[additional_info]  affected_cells=NR:unknown
    Run Keyword If  ${status} and ${status_info}
    ...  Log  Additional information for alarm with fault name "${EXPECTED_FAULT_NAME_THIRD}" is "affected_cells=NR:unknown".  WARN  console=true
    Log  Verify "${EXPECTED_FAULT_NAME_FOURTH}" alarm if is active in WebEM.  console=true
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  30
    ...  Check If Fault Is Visible In VCU WebEM  ${EXPECTED_ALARM_ID_FOURTH}
    ...  ${EXPECTED_ALARM_NAME_FOURTH}
    ...  ${EXPECTED_FAULT_ID_FOURTH}
    ...  ${EXPECTED_FAULT_NAME_FOURTH}
    ...  ${SEVERITY_FOURTH}
    ${status_info}  Run Keyword And Return Status
    ...  Should Contain  ${ALARM_INFO}[additional_info]  affected_cells=NR:unknown
    Run Keyword If  ${status} and ${status_info}
    ...  Log  Additional information for alarm with fault name "${EXPECTED_FAULT_NAME_FOURTH}" is "affected_cells=NR:unknown".  WARN  console=true


Step6: RMOD Recovery Action
    Log  \nStep6: RMOD recovery action  console=true
    Recovery Action


Step7: Disconnect From Netact And VCU
    Log  \nStep7: Disconnect from Netact and vCU  console=true
    netact.Delete Node  cmwas
    vcu.Disconnect


Step8: Verify Raw Alarm History file
    Log  \nStep8: Verify Raw Alarm History file  console=true
    Open SSH Connection To ECPRI RMOD  ${RMOD_IP}  ${RMOD_USER}  ${RMOD_PASSWORD}
    SSHLibrary.Set Client Configuration  prompt=REGEXP:(~#|\\$|\\n\\$)
    SSHLibrary.Write  echo $'/ action create ResetControl /rc /module' | frmonShellClient 127.0.0.1 2000
    ${create_command_output}  SSHLibrary.Read Until Prompt
    Should Contain  ${create_command_output}  done ok  "create" command not executed correctly. [NOK]
    SSHLibrary.Write  echo $'/rc get supported_reset_causes' | frmonShellClient 127.0.0.1 2000
    ${get_command_output}  SSHLibrary.Read Until Prompt
    Should Contain  ${get_command_output}  done ok  "get" command not executed correctly. [NOK]
    SSHLibrary.Write  echo $'/rc action commit_reset 1' | frmonShellClient 127.0.0.1 2000
    SSHLibrary.Set Client Configuration  prompt=REGEXP:(^#|bash.*\\$)  timeout=80s
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
         Continue For Loop If  not(${fault_status})
         Log  Fault with id: ${fault_id} and fault name: ${EXPECTED_FAULTS}[${fault_id}] reported in "rawFaultHistory". [OK]  console=true
         Return From Keyword
    END
    Fail  No fault from ${EXPECTED_FAULTS} list reported in "rawFaultHistory" file on current date, after ${START_TIME_RAW}. [NOK]


Verify RF Module Alarm In WebEM And Netact
    Log  Verify "${EXPECTED_FAULT_NAME_SECOND}" alarm if is active in WebEM.  console=true
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  30
    ...  Check If Fault Is Visible In VDU WebEM  ${EXPECTED_ALARM_ID_SECOND}
    ...  ${EXPECTED_ALARM_NAME_SECOND}
    ...  ${EXPECTED_FAULT_ID_SECOND}
    ...  ${EXPECTED_FAULT_NAME_SECOND}
    ...  ${SEVERITY_SECOND}
    ${netact_alarms}  netact.Get Alarms  dist_name=${MRBTS_DN}
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault  ${EXPECTED_FAULT_ID_SECOND}
    ...  ${EXPECTED_FAULT_NAME_SECOND}
    ...  ${EXPECTED_ALARM_ID_SECOND}
    ...  ${EXPECTED_ALARM_NAME_SECOND}
    ...  ${SEVERITY_SECOND}
    Log  Fault ${EXPECTED_FAULT_ID_SECOND} "${EXPECTED_FAULT_NAME_SECOND}" is reported in NetAct. [OK]  console=true


Verify Radio Autonomous Alarm In Webem And Netact
    Log  \nAlarms "${EXPECTED_FAULT_NAME_FIRST}" will be checked in Alarm History and should appear 3 times.  console=true
    ${no_of_alarms}  Set Variable  0
    ${historical_alarms}  vdu.Vdu Get Historical Alarms  sorted_by=appearTime  sort_order=desc  timeout=120s
    ${alarms}  Get From Dictionary  ${historical_alarms}  alarms
    FOR  ${alarm}  IN  @{alarms}
        ${alarm_time}  Replace String  ${alarm}[appear_time]  T  ${SPACE}
        ${time}  Fetch From Left  ${alarm_time}  +
        ${status_first_fault_name}  Run Keyword And Return Status
        ...  Should Contain  ${alarm}[fault_name]  ${EXPECTED_FAULT_NAME_FIRST}
        ${no_of_alarms}  Run Keyword If  '${time}' > '${START_TIME}' and ${status_first_fault_name}
        ...  Evaluate  ${no_of_alarms} + 1
        ...  ELSE
        ...  Continue For Loop
    END
    Run Keyword If  ${no_of_alarms} == 3
    ...  Log  "${EXPECTED_FAULT_NAME_FIRST}" is visible in alarms history in WebEM for ${no_of_alarms} times. [OK]  console=true
    ...  ELSE
    ...  Fail  "${EXPECTED_FAULT_NAME_FIRST}" is not visible in alarms history in WebEM.
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Fault Signature Of Alarm In WebEM  ${EXPECTED_FAULT_NAME_FIRST}
    ...  ${CATEGORY}
    ...  ${VDU_ACTIVE_SW_VERSION}
    ...  ${SCOPE}
    ...  ${RMOD_SN}
    ...  ${EXTRA_INFO}
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Fault Signature Of Alarm In Netact  ${EXPECTED_FAULT_ID_FIRST}
    ...  ${START_TIME_NETACT}
    ...  ${CATEGORY}
    ...  ${SCOPE}
    ...  ${VDU_ACTIVE_SW_VERSION}
    ...  ${RMOD_SN}
    ...  ${EXTRA_INFO}
    Log  Fault ${EXPECTED_FAULT_ID_FIRST} "${EXPECTED_FAULT_NAME_FIRST}" is reported & cleared from NetAct.  console=true


Recovery Action
    Log  RMOD recovery action will be performed.  console=true
    Open SSH Connection To ECPRI RMOD  ${RMOD_IP}  ${RMOD_USER}  ${RMOD_PASSWORD}
    SSHLibrary.Set Client Configuration  prompt=$
    SSHLibrary.Write  sudo mount -o remount rw /mnt/factory
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  cd /mnt/factory/configs/unit
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  sudo mv /mnt/factory/configs/unit/temp_filename /mnt/factory/configs/unit/calibration_dlpath1.bin
    SSHLibrary.Read Until Prompt
    ${reset_status}  vdu.Reset Rmods  ${RMOD_LIST}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Verify RMOD Parameter By RMOD Id  ${RMOD_ID}  availability_status  ${ONLINE}
    Log  RMOD is Online. [OK]  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Check All Cells From VDU  availability_status=${ONLINE}  operational_state=${ENABLED}
    Log  Cells are Online and Enabled. [OK]  console=true
    Log  Reset RMOD was done successfully. [OK]  console=true


TC Setup
    Common VDU Setup
    Modify Resource Search Order  FM__vDU__RMOD_reset_counter_exceeded_FID_1901


TC Teardown
    Run Keyword If Test Failed
    ...  Recovery Action
    Close All Connections
    Common VDU Teardown
