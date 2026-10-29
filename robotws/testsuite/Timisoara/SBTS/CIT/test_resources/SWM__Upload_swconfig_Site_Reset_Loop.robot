*** Settings ***
Documentation
    ...  Automated test for performing sw config upload, a given number of site resets and again at the end sw config upload operation

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${SWCONFIG_PATH}  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1688/swconfigs/swconfig_HWF/swconfig.txt  #Given path
${RESTORE_TIMEOUT}  10  # Time need to restor BTS after reset, default value 10 min
${BTS_STATUS_TIMEOUT}  20  # Time for BTS recovery after power off/on
${SITE_RESET_LOOPS}  5   # Number of Site reset loops

*** Keywords ***
TC__SWM__Upload_swconfig_Site_Reset_Loop
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28379
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 28.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28379

    Set Tags  CA-STATE  OWNER-mihail.steta@nokia.com  AUTHOR-iasmin.tomici@nokia.com  MAINTAINER-iasmin.tomici@nokia.com  PHASE-CRT

    Step 1: Input Swconfig Via Sftp
    Step 2: Power Off BTS
    Step 3: Power On BTS
    Step 4: Check If BTS Is Stable
    Step 5: Site Reset Loop
    Step 6: Input Swconfig Via Sftp
    Step 7: Power Off BTS
    Step 8: Power On BTS
    Step 9: Check If BTS Is Stable


Step 1: Input Swconfig Via Sftp
    Log  Step1: Input Swconfig Via Sftp  console=true
    ssh.Connect To  ${OAM_BTS_IP}  ${SMOD1['USERNAME']}  ${SMOD1['PASSWORD']}  alias=pc_connection
    ssh.Upload File  ${SWCONFIG_PATH}  //ffs/run/swconfig.txt  connection=pc_connection
    ssh.Disconnect  connection=pc_connection
    ${status}  Run Keyword And Return Status
    ...  Variable Should Exist  ${PC_IP2}
    Run Keyword If  ${status}
    ...  Upload Swconfig On Secondary Core

Step 2: Power Off BTS
    Log  Step2: Power off BTS  console=true
    FOR  ${distname}  IN  @{INTERFACES}
        Pdu BTS Interface Off  ${distname}
        Log  Interface ${distname} turned off  console=true
        Sleep  1
    END

Step 3: Power On BTS
    Log  Step3: Power on BTS  console=true
    FOR  ${distname}  IN  @{INTERFACES}
        Pdu BTS Interface On  ${distname}
        Log  Interface ${distname} turned on  console=true
        Sleep  1
    END

Step 4: Check If BTS Is Stable
    Log  Step4: Check If BTS Is Stable  console=true
    ${ping_regain_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Reachable  hostname=${OAM_BTS_IP}  timeout=600
    Run Keyword If  ${ping_regain_status}==${False}
    ...  Fail  Ping has not been regained within timeout
    Wait Until Keyword Succeeds  ${BTS_STATUS_TIMEOUT} min  30 s
    ...  Check BTS Status If Commissioned

Step 5: Site Reset Loop
    FOR  ${i}  IN RANGE  0  ${SITE_RESET_LOOPS}
        Log  SBTS Site reset ${i}  console=true
        Log  BTS is reset now.  console=true
        Reset Site  600
        Log  SBTS is restored\nCheck BTS and Cells states after reset\nWait ${RESTORE_TIMEOUT} mins for the states to be as expected  console=true
        Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT} min  15 s
        ...  Admin Check All Required State
        ${list_of_active_alarms}  Admin Check Active Alarms TAF  collect_snapshot=${True}
        ${length}  Get Length  ${list_of_active_alarms}
        Run Keyword If  ${length}>0
        ...  Set Test Restriction  Active alarms exist: ${list_of_active_alarms}
    END

Step 6: Input Swconfig Via Sftp
    Log  Step6: Input Swconfig Via Sftp  console=true
    ssh.Connect To  ${OAM_BTS_IP}  ${SMOD1['USERNAME']}  ${SMOD1['PASSWORD']}  alias=pc_connection
    ssh.Upload File  ${SWCONFIG_PATH}  //ffs/run/swconfig.txt  connection=pc_connection
    ssh.Disconnect  connection=pc_connection
    ${status}  Run Keyword And Return Status
    ...  Variable Should Exist  ${PC_IP2}
    Run Keyword If  ${status}
    ...  Upload Swconfig On Secondary Core

Step 7: Power Off BTS
    Log  Step7: Power off BTS  console=true
    FOR  ${distname}  IN  @{INTERFACES}
        Pdu BTS Interface Off  ${distname}
        Log  Interface ${distname} turned off  console=true
        Sleep  1
    END

Step 8: Power On BTS
    Log  Step8: Power on BTS  console=true
    FOR  ${distname}  IN  @{INTERFACES}
        Pdu BTS Interface On  ${distname}
        Log  Interface ${distname} turned on  console=true
        Sleep  1
    END

Step 9: Check If BTS Is Stable
    Log  Step9: Check If BTS Is Stable  console=true
    ${ping_regain_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Reachable  hostname=${OAM_BTS_IP}  timeout=600
    Run Keyword If  ${ping_regain_status}==${False}
    ...  Fail  Ping has not been regained within timeout
    Wait Until Keyword Succeeds  ${BTS_STATUS_TIMEOUT} min  30 s
    ...  Check BTS Status If Commissioned


Upload Swconfig On Secondary Core
    Log  Upload swconfig on secondary core  console=true
    ${vm_password}  Run  sudo cat /etc/ute/vncpasswd
    ssh.Connect To  hostname=${PC_IP2}  username=ute  password=${vm_password}  alias=sc_vm
    ssh.Connect To  hostname=192.168.255.119  username=${SMOD1['USERNAME']}  password=${SMOD1['PASSWORD']}  alias=sc_connection  proxy=sc_vm
    ssh.Upload File  ${SWCONFIG_PATH}  //ffs/run/swconfig.txt  connection=sc_connection
    ssh.Disconnect  connection=sc_connection

Check BTS Status If Commissioned
    Log  Check BTS Status If Commissioned  console=true
    ${bts_state_is_correct}  ${bts_current_status}  Verify BTS ProceduralState  (?i)NotCommissioned
    Run Keyword If  ${bts_state_is_correct}
    ...  Log  BTS is not commissioned. Will not check states any further.  console=true
    ...  ELSE
    ...  Admin Check All States

Admin Check All States
    Assert All Cells Are In Expected State
    Verify System Modules States
    Verify Radio Modules States


TC Setup
    Common Test Setup  tc_name=SWM__Upload_swconfig_Site_Reset_Loop

TC Teardown
    Common Test Teardown
