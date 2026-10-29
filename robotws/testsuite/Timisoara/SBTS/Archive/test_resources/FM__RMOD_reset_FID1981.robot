*** Settings ***
Resource    ../../common_resources/ca_FM_general.robot

*** Variables ***
${RMOD_SCORPIO}                                                                         # RMOD product name. This should be from Scorpio family
${RMOD_MASTER_AMBER}                                                                    # RMOD product name. This should be from MASTER,AMBER families
# Only one variable for RMOD should be completed.
${RMOD_USERNAME}                     rfsw                                               # Log in credential for ssh connection to radio module
${RMOD_PASSWORD_SSH_MASTER_AMBER}    gSDBExyEbO33komYWL6iPrtSaYc5XimHAGrsJ/K8+AY=       # Log in credential for ssh connection to MASTER, AMBER RMOD
${RMOD_PASSWORD_SSH_SCORPIO}         5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=       # Log in credential for ssh connection to SCORPIO RMOD
${EXPECTED_FAULT_ID}                 1981                                               # Expected fault id that will be checked by test
${EXPECTED_FAULT_NAME}               Radio autonomous reset as recovery action          # Expected fault name that will be checked by test
${EXPECTED_ALARM_ID}                 7101                                               # Expected alarm id that will be checked by test
${EXPECTED_ALARM_NAME}               BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION    # Expected alarm name that will be checked by test
${SEVERITY}                          Warning                                            # Expected severity that will be checked by test
${EXPECTED_FAULT_NAME_SECOND}        FR module reset requested                          # Expected fault name that will be checked by test
${EXPECTED_ALARM_ID_SECOND}          7116                                               # Expected alarm id that will be checked by test
${EXPECTED_ALARM_NAME_SECOND}        BASE STATION SERVICE PROBLEM                       # Expected alarm name that will be checked by test
${SEVERITY_SECOND}                   Critical                                           # Expected severity that will be checked by test
${STARTUP_TIMEOUT}                   1500                                               # Timeout for SBTS to be onAIR
${RMOD_TIMEOUT}                      900                                                # Timeout for RMOD to be disabled and enabled
${ALARM_TIMEOUT}                     600                                                # Timeout for alarms to appear


*** Keywords ***
TC__FM__RMOD_reset_FID1981
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-23830
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This TC is created to trigger fault 1981 on the given RMOD from MASTER, AMBER, Scorpio families.
    ...  Site reset is performed and all cells are onAir. actFaultSignature value is changed to true.
    ...  Then the connection to primary core is opened to get information about the given RMOD.
    ...  After, fault 1981 should be sent for 4 times.
    ...  Radio autonomous reset alarm should be reported for the first three times in WebEM and Netact.
    ...  FR module reset alarm should be reported for the fourth time in WebEM and Netact.
    ...  Fault signature fields for the Radio autonomous reset alarm should be populated correctly.
    ...  Recovery action is performed and all alarms are cleared, all modules and cells should be onAir.
    ...  actFaultSignature value is changed to false and all connections are closed.
    ...
    ...  *****************
    ...  History of changes
    ...  *****************
    ...  - 28.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23830 - Initial TAT creation
    ...  - 12.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25370 - Remove BTS_L_ID
    ...  - 31.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25478 - Update FM testcases for actFaultSignature
    ...  - 26.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25598 - Test fails when checking extra_info field from fault signature
    ...  - 15.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25658 - Create new resources for NetAct and ONAP KWs
    ...  - 22.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26639 - Fix EXPECTED_FAULT_ID should be a string
    ...  ******************

    Set Tags    CA-FM    OWNER-mircea.vladulescu@nokia.com    AUTHOR-cosmina.rebenciuc@nokia.com
    ...    MAINTAINER-cosmina.rebenciuc@nokia.com    GROUP_IN_CHARGE-TIM_4_Vrf    PHASE-CRT    SW-SBTS22
    ...    FEATURE-CB007273

    Step0: Set initial variables
    Step1: Perform site reset and change actFaultSignature
    Step2: Trigger fault on RMOD
    Step3: RMOD recovery action

Step0: Set initial variables
    Log  Step0: Set initial variables  console=true
    ${status_rmod_scorpio}=  Run keyword and return status  Should Not Be Empty  ${RMOD_SCORPIO}
    ${status_rmod_master_amber}=  Run keyword and return status  Should Not Be Empty  ${RMOD_MASTER_AMBER}
    Run Keyword If  '${status_rmod_scorpio}'=='${status_rmod_master_amber}'
    ...  Fail  Only one variable with RMOD type should be completed.
    Run Keyword If  ${status_rmod_scorpio}
    ...  Run keywords  Set Test Variable  ${RMOD_TYPE}  ${RMOD_SCORPIO}  AND
    ...  Set Test Variable  ${RMOD_PASSWORD}  ${RMOD_PASSWORD_SSH_SCORPIO}
    ...  ELSE
    ...  Run keywords  Set Test Variable  ${RMOD_TYPE}  ${RMOD_MASTER_AMBER}  AND
    ...  Set Test Variable  ${RMOD_PASSWORD}  ${RMOD_PASSWORD_SSH_MASTER_AMBER}
    Remove ssh keys
    Get RMOD info from ssh

Step1: Perform site reset and change actFaultSignature
    Log  Step1: Perform site reset and change actFaultSignature  console=true
    Perform site reset
    Set actFaultSignature value  true

Step2: Trigger fault on RMOD
    Log  Step2: Trigger fault on RMOD  console=true
    FOR  ${loop}  IN RANGE  4
      Remove ssh keys
      Open SSH connection and execute command
      ...  Send fault 1981  ${STORED_ROLE}  ${RMOD_SIDE}  ${RMOD_IP}  ${RMOD_USERNAME}  ${RMOD_PASSWORD}
      Run keyword if  ${loop}==3
      ...  Verify FR module reset alarm in Webem and NetAct
      ...  ELSE
      ...  Verify Radio autonomous reset alarm on WebEM and Netact and faultSignature
    END

Get RMOD info from ssh
    [Documentation]  This KW is created to connect to primary core, verify if RMOD type exists on SBTS and
    ...  get information about the given RMOD.
    Open connection to primary core
    SShLibrary.Write  cat /rom/config/FRIps.txt
    SSHLibrary.Set Client Configuration  prompt=>
    ${list_rmods}=  SSHLibrary.Read Until Prompt
    ${status}=  Run keyword and return status  Should Contain  ${list_rmods}  ${RMOD_TYPE}
    Run keyword if  ${status}
    ...  Get ip, serial number and extra info for rmod  ${list_rmods}
    ...  ELSE
    ...  Fail  ${RMOD_TYPE} is not on SBTS.
    SSHLibrary.Close connection

Send fault 1981
    SSHLibrary.Write  sudo touch /mnt/runtime/runtime_config.txt
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  echo '/ action create ConfigAccess /CI/ConfigAccess_Module /module' | frmonShellClient 127.0.0.1 2000
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write
    ...  echo '/CI/ConfigAccess_Module action fetch DECODED "syscon_node0.bin" "/tmp/syscon_node0.json"' | frmonShellClient 127.0.0.1 2000
    ${output_command}=  SSHLibrary.Read Until Prompt
    ${status}=  Run keyword and return status  Should contain  ${output_command}  done ok
    Run keyword unless  ${status}
    ...  Fail  Message is not ok.
    SSHLibrary.Write  cd /tmp
    SSHLibrary.Read Until Prompt
    ${command_text}=  Catenate  SEPARATOR=  sed${SPACE}-i${SPACE}-E${SPACE}':a;N;$!ba;s/"library":${SPACE}"libl1low-syscom-proxy.so.1.0.0",.*
    ...  "faultId":${SPACE}0/
    ...  "library":${SPACE}"libl1low-syscom-proxy.so.1.0.0",\\n\\t
    ...  "serviceId":${SPACE}"l1lsyscomproxy::master",\\n\\t
    ...  "address":${SPACE}0,\\n\\t
    ...  "startup_timeout_sec":${SPACE}1200,\\n\\t
    ...  "keepAlivePeriod_sec":${SPACE}120,\\n\\t
    ...  "deployment_type":${SPACE}"StandaloneProcess",\\n\\t
    ...  "initConfig":${SPACE}"",\\n\\t
    ...  "recoveryAction":${SPACE}"SendFault",\\n\\t
    ...  "noOfRecoveries":${SPACE}3,\\n\\t
    ...  "faultId":${SPACE}1295/g' syscon_node0.json
    SSHLibrary.Write  ${command_text}
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write
    ...  echo '/CI/ConfigAccess_Module action fetch PERMANENT DECODED "syscon_node0.bin" "/tmp/syscon_node0.json"' | frmonShellClient 127.0.0.1 2000
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  reboot
    SSHLibrary.Read Until Prompt
    Log  Check RMOD status to be disabled  console=true
    Wait until keyword succeeds  ${RMOD_TIMEOUT}  10  Assert Any  RMOD  operationalState=${Disabled_}
    Log  Check RMOD status to be enabled  console=true
    Wait until keyword succeeds  ${RMOD_TIMEOUT}  10  Assert Every  RMOD  operationalState=${Enabled_}
    Get RMOD IP after reboot  ${RMOD_SN}
    SSHLibrary.Close all connections
    Remove ssh keys
    Sleep  30s  Wait to connect to RMOD.
    Open SSH connection and execute command
    ...  Kill process  ${STORED_ROLE}  ${RMOD_SIDE}  ${RMOD_IP}  ${RMOD_USERNAME}  ${RMOD_PASSWORD}

Kill process
    SSHLibrary.Write  ps | grep libl1low-syscom-proxy.so.1.0.0
    ${process_info}=  SSHLibrary.Read Until Prompt
    ${list_process}=  Split String  ${process_info}  ${SPACE}
    ${pid}=  Set Variable  ${list_process}[1]
    SSHLibrary.Write  kill -11 ${pid}
    SSHLibrary.Read Until Prompt
    SSHLibrary.Close all connections

Verify Radio autonomous reset alarm on WebEM and Netact and faultSignature
    Log  Verify Radio autonomous reset alarm on WebEM and Netact and faultSignature  console=true
    Check alarm in WebEm and NetAct and fault signature in NetAct
    Sleep  120s  Wait for all alarms to appear in historical alarms.
    Log  Check modules and cells to be onAIR  console=true
    Wait until keyword succeeds  ${RMOD_TIMEOUT}  20  Check modules and cells

Check alarm in WebEm and NetAct and fault signature in NetAct
    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    Verify Radio autonomous reset alarm in Webem and NetAct
    Log  \nChecking fault signature for alarm ${EXPECTED_FAULT_ID} in NetAct.  console=True
    ${fault_netact}  Run keyword and return status  Wait until keyword succeeds  300  10s
    ...  Check fault signature field of alarm in NA for specific fault signature  ${EXPECTED_FAULT_ID}
    ...                                                                           ${RMOD_SN}
    ...                                                                           ${CATEGORY}
    ...                                                                           ${SCOPE}
    ...                                                                           ${EXTRA_INFO}
    ...                                                                           ${ACTIVE_SW}
    ...                                                                           ${start_time}
    Run keyword if  ${fault_netact}
    ...  Log  Alarm ${EXPECTED_FAULT_ID} - ${EXPECTED_FAULT_NAME} - fault signature reported ok in NetAct.  console=true
    ...  ELSE
    ...  Fail  Alarm ${EXPECTED_FAULT_ID} - ${EXPECTED_FAULT_NAME} - fault signature not reported ok in NetAct - [NOK]

Verify Radio autonomous reset alarm in Webem and NetAct
    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    ${alarm_parameters}  Catenate    SEPARATOR=${SPACE}  faultId=${EXPECTED_FAULT_ID},
    ...                                                  faultName="${EXPECTED_FAULT_NAME}",
    ...                                                  alarmId=${EXPECTED_ALARM_ID},
    ...                                                  alarmName="${EXPECTED_ALARM_NAME}"
    ${alarm_webem}  Run keyword and return status  Assert Alarm Active  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}
    Run keyword if  ${alarm_webem}
    ...  Log  Fault ${EXPECTED_FAULT_ID} - ${EXPECTED_FAULT_NAME} - reported in Webem.  console=true
    ...  ELSE
    ...  Fail  Alarm ${EXPECTED_FAULT_ID} - ${EXPECTED_FAULT_NAME} - not reported in WebEm - [NOK]
    ${alarm_netact}  Run keyword and return status  Wait until keyword succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check additional information for given alarm and fault in NA cleared alarms  ${EXPECTED_FAULT_ID}
    ...                                                                               ${EXPECTED_FAULT_NAME}
    ...                                                                               ${EXPECTED_ALARM_ID}
    ...                                                                               ${EXPECTED_ALARM_NAME}
    ...                                                                               ${SEVERITY}
    ...                                                                               ${start_time}
    Run keyword if  ${alarm_netact}
    ...  Log  Fault ${EXPECTED_FAULT_ID} - ${EXPECTED_FAULT_NAME} - reported & cleared from NetAct.  console=true
    ...  ELSE
    ...  Fail  Fault ${EXPECTED_FAULT_ID} - ${EXPECTED_FAULT_NAME} - not reported in NetAct - [NOK]

Verify FR module reset alarm in Webem and NetAct
    ${alarm_parameters}  Catenate    SEPARATOR=${SPACE}  faultId=${EXPECTED_FAULT_ID},
    ...                                                  faultName="${EXPECTED_FAULT_NAME_SECOND}",
    ...                                                  alarmId=${EXPECTED_ALARM_ID_SECOND},
    ...                                                  alarmName="${EXPECTED_ALARM_NAME_SECOND}"
    ${alarm_webem}  Run keyword and return status  Assert Alarm Active  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}
    Run keyword if  ${alarm_webem}
    ...  Log  Fault ${EXPECTED_FAULT_ID} - ${EXPECTED_FAULT_NAME_SECOND} - reported in WebEm.  console=true
    ...  ELSE
    ...  Fail  Fault ${EXPECTED_FAULT_ID} - ${EXPECTED_FAULT_NAME_SECOND} - not reported in WebEm - [NOK]
    ${alarm_netact}  Run keyword and return status  Wait until keyword succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check additional information for given alarm and fault  ${EXPECTED_FAULT_ID}
    ...                                                          ${EXPECTED_FAULT_NAME_SECOND}
    ...                                                          ${EXPECTED_ALARM_ID_SECOND}
    ...                                                          ${EXPECTED_ALARM_NAME_SECOND}
    ...                                                          ${SEVERITY_SECOND}
    Run keyword if  ${alarm_netact}
    ...  Log  Fault ${EXPECTED_FAULT_ID} - ${EXPECTED_FAULT_NAME_SECOND} - reported in NetAct.  console=true
    ...  ELSE
    ...  Fail  Fault ${EXPECTED_FAULT_ID} - ${EXPECTED_FAULT_NAME_SECOND} - not reported in NetAct - [NOK]

Step3: RMOD recovery action
    Log  Step3: RMOD recovery action  console=true
    ${current_date}=  Get current date  result_format=%Y%m%d
    ${rmod_sn_list}  Create list  ${RMOD_SN}
    Check fault signature of alarm in WebEM for all RMODs
    ...  ${EXPECTED_FAULT_ID}  ${SEVERITY}  ${rmod_sn_list}  1
    ...  ${CATEGORY}  ${SCOPE}  ${EXTRA_INFO}  ${ACTIVE_SW}  ${current_date}
    Remove ssh keys
    Open SSH connection and execute command
    ...  Send recovery command  ${STORED_ROLE}  ${RMOD_SIDE}  ${RMOD_IP}  ${RMOD_USERNAME}  ${RMOD_PASSWORD}
    ${status}  Run keyword and return status  Wait until keyword succeeds  ${RMOD_TIMEOUT}  20  Check modules and cells
    Run keyword if  ${status}
    ...  Log  SBTS is on air, all services are operational.  console=true
    ...  ELSE
    ...  Fail  Site didn't manage to reach on air state

Send recovery command
    Log  Sending recovery command and closing connection.  console=true
    SSHLibrary.Write  rm /mnt/runtime/runtime_config.txt
    SSHLibrary.Read until prompt
    SSHLibrary.Write  reboot
    SSHLibrary.Read until prompt
    SSHLibrary.Close all connections

Get RMOD IP after reboot
    [Documentation]  This KW is created to connect to primary core and get the IP of the RMOD after rebooting it.
    [Arguments]  ${RMOD_SN}
    Open connection to primary core
    SSHLibrary.Write  cat /rom/config/FRIps.txt
    SSHLibrary.Set Client Configuration  prompt=>
    ${list_rmods_after_reboot}=  SSHLibrary.Read Until Prompt
    ${lines_containing_RMOD_SN}=  Get Lines Containing String  ${list_rmods_after_reboot}  ${RMOD_SN}
    ${splitted_line}=  Split String  ${lines_containing_RMOD_SN}  ;
    Set Test Variable  ${RMOD_IP_AFTER_REBOOT}  ${splitted_line}[2]

Get ip, serial number and extra info for rmod
    [Arguments]  ${rmods}
    ${lines_containing_RMOD}=  Get Lines Containing String  ${rmods}  ${RMOD_TYPE}
    ${length_string}=  Get line count  ${lines_containing_RMOD}
    ${line_number}=  Evaluate  random.randint(0,${length_string}-1)   random
    ${line}=  Get line  ${lines_containing_RMOD}  ${line_number}
    ${splitted_line}=  Split String  ${line}  ;
    ${bbmod_l}=  Fetch from right  ${splitted_line}[0]  /
    ${bts_dn}=  Fetch from left  ${splitted_line}[0]  /EQM_L
    ${storedRole}  Get storedRole from MODULE_L  ${splitted_line}[0]
    ${bts_hwapiDomainId}=  coam.Get parameters  ${bts_dn}  hwapiDomainId
    ${active_SW}=  coam.Get sw version
    Set test variable  ${RMOD_SIDE}    ${bts_hwapiDomainId}[hwapiDomainId]
    Set test variable  ${STORED_ROLE}  ${storedRole}
    Set test variable  ${ACTIVE_SW}    ${active_SW}
    Set test variable  ${CATEGORY}     SW_FAILURE
    Set test variable  ${SCOPE}        RFM
    Set test variable  ${EXTRA_INFO}   faulty_cells=.*NR:[0-9]+.*
    Set Test Variable  ${BBMOD_L}  ${bbmod_l}
    Set Test Variable  ${RMOD_IP}  ${splitted_line}[2]
    Set Test Variable  ${RMOD_SN}  ${splitted_line}[3]

Return to initial configuration
    [Arguments]  ${operation}  ${stored_role}  ${rmod_side}  ${rmod_ip}  ${rmod_username}  ${rmod_password}
    Log  Test failed. Trying to recover services.  console=true
    Remove ssh keys
    Open SSH connection and execute command  ${operation}  ${stored_role}  ${rmod_side}  ${rmod_ip}
    ...  ${rmod_username}  ${rmod_password}
    Log  Check RMOD status to be disabled  console=true
    Wait until keyword succeeds  ${RMOD_TIMEOUT}  10  Assert Any  RMOD  operationalState=${Disabled_}
    Log  Check modules and cells to be OnAIR  console=true
    Wait Until Keyword Succeeds  ${RMOD_TIMEOUT}  10  Check modules and cells

TC Setup
    Common Test Setup
    Setup Netact

TC Teardown
    Run keyword if test failed  Return to initial configuration  Send recovery command  ${STORED_ROLE}  ${RMOD_SIDE}
    ...  ${RMOD_IP}  ${RMOD_USERNAME}  ${RMOD_PASSWORD}
    Teardown Netact
    Common Test Teardown
