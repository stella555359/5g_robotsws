*** Settings ***
Documentation
...  This TC is created to raise fault 1940 on eCPRI RMOD.
...  vDU reset is performed.
...  Connection to RMOD is opened, thermometer is created and fault is sent on first made node.
...  Fault 1940/1171 is verified to be active in "fault_history_log_temp.txt" file.
...  Fault is cleared from made-node and it is verified to be inactive in "fault_history_log_temp.txt" file.


Resource  ../../common_resources/vdu_frame.robot
Resource  ../../common_resources/cbts_general.robot


*** Variables ***
${RMOD_TYPE}  ${EMPTY}  #RMOD product name
${DC}  ${TRUE}  #Configuration type
${ALARM_TIMEOUT}  300
${RECOVERY_TIMEOUT}  900s  # Timeout for CBTS to be onAir


*** Keywords ***
TC__FM__vDU_Check_Triggering_Fault_Id_1940
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28490
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  03.12.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28490 - Initial TAT creation
    ...  01.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29005 - Change from SWN to DC RMOD connection
    ...  09.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29831 - Change method of connecting to RMOD and retrieving pod and container name
    ...  ******************

    Set Tags  CA-FM  OWNER-mircea.novac@nokia.com  AUTHOR-anna.benzar@nokia.com  GROUP_IN_CHARGE-NB I&V TIM2  FEATURE-CB006992C  SW-25R2


    Step 0: TC Preconditions
    Step 1: Trigger Fault 1940 On RMOD
    Step 2: Clear Fault 1940 From RMOD


Step 0: TC Preconditions
    Log  \nStep0: TC Prerequisites.  console=true

    Should Not Be Empty  ${RMOD_TYPE}  msg=Please provide RMOD_TYPE(e.g. AEQP)
    Perform vDU Reset
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


Step 1: Trigger Fault 1940 On RMOD
    Log  \nStep 1: Trigger Fault 1940 On RMOD.  console=true

    Open SSH Connection To Specific RMOD  ${RMOD}[ip]  ${RMOD}[user]  ${RMOD}[password]  ${RMOD}[serial_number]  dc=${DC}
    Log  Send fault on first Made Node on RMOD. [OK]  console=true
    SSHLibrary.Set Client Configuration  prompt=REGEXP:(:~#|\\$)
    SSHLibrary.Write  ssh serviceuser@192.168.101.2
    ${made_node_connection}  SSHLibrary.Read Until Prompt
    Should Contain  ${made_node_connection}  Made  Not able to connect on made-node with ip: 192.168.101.2

    ${open_commands_list}  Create List
    ...  / action create ConfigAccess /CI/ConfigAccess_Module /module
    ...  /CI/ConfigAccess_Module action fetch DECODED "tempest_inst1.bin" "/var/tmp/tempest_inst1_default.json"
    Send Commands On FrmonShellClient  ${open_commands_list}

    ${create_thermometer_commands}  Create List
    ...  / action create ThermometerDevice /temp/made1/external /temp/made1/external
    ...  / action create ThermometerDevice /temp/made1/internal1 /temp/made1/internal1
    ...  / action create ThermometerDevice /temp/made1/internal2 /temp/made1/internal2
    ...  / action create ThermometerDevice /temp/made1/internal3 /temp/made1/internal3
    ...  / action create ThermometerDevice /temp/made1/internal4 /temp/made1/internal4
    ...  / action create ThermometerDevice /temp/made1/internal5 /temp/made1/internal5
    ...  / action create ThermometerDevice /temp/made1/internal6 /temp/made1/internal6
    ...  / action create ThermometerDevice /temp/made1/internal7 /temp/made1/internal7
    ...  / action create ThermometerDevice /temp/trx1_4 /temp/trx1_4
    ...  / action create ThermometerDevice /temp/trx5_8 /temp/trx5_8
    ...  / action create ThermometerDevice /temp/pa1_2 /temp/pa1_2
    ...  / action create ThermometerDevice /temp/pa3_4 /temp/pa3_4
    ...  / action create ThermometerDevice /temp/pa5_6 /temp/pa5_6
    ...  / action create ThermometerDevice /temp/pa7_8 /temp/pa7_8
    Send Commands On FrmonShellClient  ${create_thermometer_commands}

    ${send_fault_commands}  Create List
    ...  /temp/made1/external action override FAULTY
    ...  /temp/made1/internal1 action override FAULTY
    ...  /temp/made1/internal2 action override FAULTY
    ...  /temp/made1/internal3 action override FAULTY
    ...  /temp/made1/internal4 action override FAULTY
    ...  /temp/made1/internal5 action override FAULTY
    ...  /temp/made1/internal6 action override FAULTY
    ...  /temp/made1/internal7 action override FAULTY
    ...  /temp/trx1_4 action override FAULTY
    ...  /temp/trx5_8 action override FAULTY
    ...  /temp/pa1_2 action override FAULTY
    ...  /temp/pa3_4 action override FAULTY
    ...  /temp/pa5_6 action override FAULTY
    ...  /temp/pa7_8 action override FAULTY
    Send Commands On FrmonShellClient  ${send_fault_commands}
    Wait Until Keyword Succeeds  300s  10s  Verify Fault Active In "fault_history_log_temp.txt" File

    [Teardown]  SSHLibrary.Close Connection


Step 2: Clear Fault 1940 From RMOD
    Log  \nStep 2: Clear Fault 1940 From RMOD.  console=true

    Open SSH Connection To Specific RMOD  ${RMOD}[ip]  ${RMOD}[user]  ${RMOD}[password]  ${RMOD}[serial_number]  dc=${DC}
    SSHLibrary.Set Client Configuration  prompt=REGEXP:(:~#|\\$)
    SSHLibrary.Write  ssh serviceuser@192.168.101.2
    ${made_node_connection}  SSHLibrary.Read Until Prompt
    Should Contain  ${made_node_connection}  Made  Not able to connect on made-node with ip: 192.168.101.2

    ${delete_fault_commands}  Create List  /temp/made1/external action override OFF
    ...  /temp/made1/internal1 action override OFF
    ...  /temp/made1/internal2 action override OFF
    ...  /temp/made1/internal3 action override OFF
    ...  /temp/made1/internal4 action override OFF
    ...  /temp/made1/internal5 action override OFF
    ...  /temp/made1/internal6 action override OFF
    ...  /temp/made1/internal7 action override OFF
    ...  /temp/trx1_4 action override OFF
    ...  /temp/trx5_8 action override OFF
    ...  /temp/pa1_2 action override OFF
    ...  /temp/pa3_4 action override OFF
    ...  /temp/pa5_6 action override OFF
    ...  /temp/pa7_8 action override OFF
    Send Commands On FrmonShellClient  ${delete_fault_commands}
    Wait Until Keyword Succeeds  300s  10s  Verify Fault Inactive In "fault_history_log_temp.txt" File

    [Teardown]  SSHLibrary.Close Connection


Send Commands On FrmonShellClient
    [Arguments]  ${commands}

    FOR  ${command}  IN  @{commands}
        SSHLibrary.Write  echo $'${command}' | frmonShellClient 127.0.0.1 2000
        ${output}  SSHLibrary.Read Until Prompt
        Should Contain  ${output}  done ok  Command:"${command}" not executed ok. [NOK]
        Log  Command: "${command}" executed sucessfully. [OK]  console=true
    END


Verify Fault Active In "fault_history_log_temp.txt" File
    Log  Verify Fault Active In "fault_history_log_temp.txt" File.  console=true
    Open SSH Connection To Specific RMOD  ${RMOD}[ip]  ${RMOD}[user]  ${RMOD}[password]  ${RMOD}[serial_number]  dc=${DC}
    SSHLibrary.Write  cat /ram/fault_history_log_temp.txt
    ${file_output}  SSHLibrary.Read Until Prompt
    ${active_faults}  Fetch From Left  ${file_output}  InActive faults:
    ${fault_line}  Get Lines Containing String  ${active_faults}  EFaultId_TemperValueMissing (1171)
    Should Not Be Empty  ${fault_line}  Fault 1940/1171 not found in fault_history_log_temp.txt in Active faults. [NOK]
    Log  Fault 1940/1171 EFaultId_TemperValueMissing reported in fault_history_log_temp.txt file. [OK]  console=true

    [Teardown]  SSHLibrary.Close Connection


Verify Fault Inactive In "fault_history_log_temp.txt" File
    Log  Verify Fault Inactive In "fault_history_log_temp.txt" File.  console=true
    Open SSH Connection To Specific RMOD  ${RMOD}[ip]  ${RMOD}[user]  ${RMOD}[password]  ${RMOD}[serial_number]  dc=${DC}
    SSHLibrary.Write  cat /ram/fault_history_log_temp.txt
    ${file_output}  SSHLibrary.Read Until Prompt
    ${active_faults}  Fetch From Right  ${file_output}  InActive faults:
    ${fault_line}  Get Lines Containing String  ${active_faults}  EFaultId_TemperValueMissing (1171)
    Should Not Be Empty  ${fault_line}  Fault 1940/1171 not found in fault_history_log_temp.txt in Inactive faults. [NOK]

    [Teardown]  SSHLibrary.Close Connection


TC Setup
    Common VDU Setup
    Modify Resource Search Order  FM__vDU_Triggering_fault_1911_SWN


TC Teardown
    Common VDU Teardown
