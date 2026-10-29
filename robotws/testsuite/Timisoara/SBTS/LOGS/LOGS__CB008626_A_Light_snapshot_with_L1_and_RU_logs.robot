*** Settings ***
Documentation
    ...    KW sets diagSnapDestination to lss and configures "lssConfig" object.
    ...    Check there is triggered the FID-4694 for ABIO
    ...    checking if FID-4694 was raised (max time for waiting is 30 sec)
    ...    login to lss server and check if snapshot is present
    ...     if yes zip directory to snapshot.zip file after that download zip file to local disk
Library    SSHLibrary
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Resource    ../resources/verdicts.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    ../resources/bts_states.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${SNAPSHOT_COLLECTION_TIMEOUT}    2700

${LSS_SERVER_IP}    10.5.20.200
${LSS_SERVER_PASS}  zO&n1W*ktp7!
${LSS_SERVER_USER}  coam
${LSS_SERVER_PORT}  22
${BTS_ip}           192.168.255.129
${BTS_login}        toor4nsn
${BTS_password}     oZPS0POrRieRtu
${FSP_ID}           asp-1b
${SSH_COMMAND_BBMOD1}      ssh -tt toor4nsn@asp-1b
${KNOWN_WARNING}    Are you sure you want to continue connecting
${PASSWORD_PROMPT}  password:
${DSP_CRASH_CMD1}    devmem 0x864000820048 32 0x10


*** Keywords ***
TC__LOGS__CB008626_A_Light_snapshot_with_L1_and_RU_logs
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25493
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Refactored from the test /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/cOAM/CB008626.
    ...  The purpose of this test is check if snapshot is properly collected on LLS server after triggert FID-4694.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 09.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25493 - Initial TAT creation
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/SBTS/...
    ...  /LOGS__03_CB008626_A_Light_snapshot_with_L1_and_RU_logs.png
    ...

    Set Tags    CA-LOGS    AUTHOR-rafal.sytyk@nokia.com    MAINTAINER-marcin.berkowski@nokia.com
    ...       GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CIT    SW-SBTS23    FEATURE-CB008626

    Step 1: Change snapshot destination for LSS
    Step 2: Trigger Fault 4694 for ABIO
    Step 3: Check if FID-4694 was raised
    Step 4: Check If Snapshot Collected On LSS

Step 1: Change snapshot destination for LSS
    [Documentation]
    ...  KW sets diagSnapDestination to lss and configures "lssConfig" object.

    Log    Step 1: Change snapshot destination for LSS    console=${True}
    Set Test Variable     ${actDefaultFaultSnapTriggers_true}    ${False}
    ${btsid}   bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}
    ${TRBLCADM_CONF}=
    ...    Query Infomodel  query=get object /MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-${BTS_ID}/MNL_A-*/MNLENT_A-*/TRBLCADM_A-*
    Run Keyword If    '${TRBLCADM_CONF.actDefaultFaultSnapTriggers}' == '${False}'
    ...    Run Keywords
    ...    coam.Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    parameter=actDefaultFaultSnapTriggers  operation=update  value=true  skip_parameter_relation_errors=True
    ...    AND    Set Test Variable     ${actDefaultFaultSnapTriggers_true}    ${True}
    ...    ELSE   Set Test Variable     ${actDefaultFaultSnapTriggers_true}    ${True}
    pm_logs_general.Set Snapshot Destination To    LSS

Step 2: Trigger Fault 4694 for ABIO
    [Documentation]
    ...    In this step there is triggered the FID-4694 for ABIO

    Log    Step 2: Trigger Fault 4694    console=${True}
    Log    execute commands via ssh (devmem 0x864000820048 32 0x10)    console=${True}
    Open SSH And Execute Command    ${BTS_ip}    ${BTS_login}    ${BTS_password}    ${SSH_COMMAND_BBMOD1}    ${DSP_CRASH_CMD1}

Step 3: Check if FID-4694 was raised
    [Documentation]  This KW is checking if FID-4694 was raised (max time for waiting is 30 sec)

    Log    Step 3: Check if FID-4694 was raised    console=${True}
    Set Test Variable    ${FID-4694_was_raised}    ${False}
    Wait Until Keyword Succeeds    30s    1s    coam.Assert Alarm Active    faultId=4694
    Set Test Variable    ${FID-4694_was_raised}    ${True}

Step 4: Check If Snapshot Collected On LSS
    [Documentation]
    ...  In KW test login to lss server and check if snapshot is present
    ...  if yes zip directory to snapshot.zip file after that download zip file to local disk

    Log  \nStep 4: Chceck if snapshot is on LSS  console=${True}

    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}
    ${SW}  coam.Get Sw Version
    ${snapshot_name}  Set Variable  Snapshot_MRBTS-${bts_id}_*_${SW}_*
    Set Test Variable  ${snapshot_name}

    Check If Snapshot Is Collected
    Log  Open SSH Connection to lss server  console=${true}
    SSHLibrary.Open Connection                          ${LSS_SERVER_IP}
    ${ssh_status}  Run Keyword And Return Status
    ...  SSHLibrary.Login                               ${LSS_SERVER_USER}    ${LSS_SERVER_PASS}
    Run Keyword If  ${ssh_status}
    ...  Log  Opening SSH session to lss server succeeded   console=${true}
    ...  ELSE
    ...  verdicts.Set Test Failed  TC failed - Open SSH connection to lss server failure.  ${TRUE}
    Sleep    3s

    ${snapshot_location_on_lss}  SSHLibrary.Execute Command  find / -type d -name "${snapshot_name}" -cmin -15 2>/dev/null
    ${snapshot_file_name_on_lss}    Fetch From Right    ${snapshot_location_on_lss}    /
    ${isEmpty}  Get length  ${snapshot_location_on_lss}
    Log  ${isEmpty}
    Run Keyword If  ${isEmpty}==0
    ...  verdicts.Set Test Failed  snapshot was`t found on lss server.  ${TRUE}
    ...  ELSE  Log  Snapshot was found on lss server.   console=${true}
    Sleep  3s
    SSHLibrary.Execute Command  zip -r ${snapshot_name}.zip ${snapshot_location_on_lss}
    Sleep  60s
    Run  sshpass -p '${LSS_SERVER_PASS}' scp ${LSS_SERVER_USER}@${LSS_SERVER_IP}:/home/coam/${snapshot_name}.zip ${BTS_Files}
    Sleep  60s
    SSHLibrary.Execute Command  rm -r /home/coam/${snapshot_file_name_on_lss}
    Log  ${snapshot_file_name_on_lss} was removed from LSS server
    Sleep  1s
    SSHLibrary.Execute Command  rm /home/coam/${snapshot_name}.zip
    Log  ${snapshot_name}.zip was removed from LSS server
    ${path_to_snapshot_from_lss}  Set Variable  ${BTS_Files}/${snapshot_name}.zip
    OperatingSystem.File Should Exist  ${BTS_Files}/${snapshot_name}.zip
    Log  Snapshot was downloaded to local disk   console=${true}
    Set Test Variable  ${path_to_snapshot_from_lss}
    SSHLibrary.Close Connection

Check If Snapshot Is Collected
    [Documentation]
    ...  In this KW it is checked if snapshot is triggered by syslog substring and collection is finished.

    Log  Check If Snapshot Is Collected  console=${True}
    ${snapshot_triggering_status}  Query Infomodel  check //TECHREP_L-*/SNAPSHOT-* is [originator=Internal,stateInfo.usageState=Active]
    ...  timeout=60  allow_negative_result=True
    Run Keyword If  ${snapshot_triggering_status}
    ...  Log  Snapshot was triggered (by FID-4694)  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Snapshot was not triggered (by FID-4694).  ${TRUE}

    Log  Wait max ${SNAPSHOT_COLLECTION_TIMEOUT} seconds for snapshot to collect.  console=${True}
    Sleep  60s
    ${time_0}=   Get Time
    ${conv_time_0}=   Convert Date    ${time_0}    epoch
    Set Test Variable  ${conv_time_0}
    ${snapshot_collection_status}  Query Infomodel  none //TECHREP_L-*/SNAPSHOT-* is [originator=Internal]
    ...  timeout=${SNAPSHOT_COLLECTION_TIMEOUT}  allow_negative_result=True
    Run Keyword If  ${snapshot_collection_status}
    ...  Log  Snapshot collection finished.  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Snapshot collection not finished in ${SNAPSHOT_COLLECTION_TIMEOUT} seconds.  ${TRUE}

Open SSH And Execute Command
    [Arguments]    ${BTS_ip}    ${BTS_login}    ${BTS_password}    ${SSH_COMMAND_BBMOD1}    ${DSP_CRASH_CMD1}

    Log To Console    === Start SSH connexion to ${BTS_ip} ===
    SSHLibrary.Open Connection    ${BTS_ip}    port=22    timeout=10s
    SSHLibrary.Login    ${BTS_login}    ${BTS_password}

    SSHLibrary.Write    ${SSH_COMMAND_BBMOD1}

    # A?teapta mesajul de confirmare la prima conectare
    ${result}=    Run Keyword And Ignore Error    SSHLibrary.Read Until    Are you sure you want to continue connecting
    ${status}=    Set Variable    ${result[0]}
    ${output}=    Set Variable    ${result[1]}
    ${need_confirm}=    Evaluate    'Are you sure' in """${output}"""
    Run Keyword If    ${need_confirm}    SSHLibrary.Write    yes

    # Dupa confirmare, a?teapta promptul de parola
    ${pw_result}=    Run Keyword And Ignore Error    SSHLibrary.Read Until    password:
    ${pw_status}=    Set Variable    ${pw_result[0]}
    ${pw_output}=    Set Variable    ${pw_result[1]}
    ${need_password}=    Evaluate    'password' in """${pw_output}"""
    Run Keyword If    ${need_password}    SSHLibrary.Write    ${BTS_password}

    Sleep    2s
    Log To Console    Command is: ${DSP_CRASH_CMD1}
    SSHLibrary.Write    ${DSP_CRASH_CMD1}

    Sleep    2s
    ${resp}=    SSHLibrary.Read    delay=2s
    Log    ${resp}
    SSHLibrary.Close Connection
    Log To Console    === Conexion SSH closed ===

Custom Test Teardown
    Run Keyword If  ${FID-4694_was_raised}    Run Keywords
    ...    Log    Custom Test Teardown    console=${True}
    #Reset site to clear FID-4694
    ...    AND    coam.Reset Site  600
    ...    AND    Wait Until Keyword Succeeds  20m  30s  pm_logs_general.Check All Modules And All Cells Working States

    Run Keyword If    ${actDefaultFaultSnapTriggers_true}    Run Keywords
    ...    Log    Change actDefaultFaultSnapTriggers to false   console=${True}
    ...    AND    coam.Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    parameter=actDefaultFaultSnapTriggers  operation=update  value=false  skip_parameter_relation_errors=True



TC Setup
    Common Test Setup
    #Sleep    1s

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Custom Test Teardown
    ...    AND    Common Test Teardown

Read Until Warning Or Password
    ${output}=    SSHLibrary.Read Until    :
    Run Keyword If    """${KNOWN_WARNING} in ${output}"""    SSHLibrary.Write    yes
    [Return]    ${output}
