*** Settings ***
Documentation
    ...  Step 1: Input Swconfig Via Sftp
    ...  Step 2: Power Off BTS
    ...  Step 3: Power On BTS
    ...  Step 4: Check If BTS Is Stable

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${SWCONFIG_PATH}  /home/ute/btsauto/swconfigs/swconfig_SBTS17/swconfig.txt  #Path to prepared swconfig.txt


*** Keywords ***
TC__SWM__Upload_swconfig
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-8137
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 24.10.2017 - https://jira3.int.net.nokia.com/browse/TAT-8137 - initial creation
    ...  - 24.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23921 - Changed connection from Ftp to Sftp
    ...  - 28.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24017 - Add ssh disconnect
    ...  - 09.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27874 - Swconfig upload on SC too
    ...  - 05.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-27969 - Add check on logs before and after Swconfig upload
    ...  - 05.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-27970 - Remove file verification and check PC_IP2 existence

    Set Tags  CA-STATE  OWNER-jacek.mnich@nokia.com  AUTHOR-jacek.mnich@nokia.com  MAINTAINER-iasmin.tomici@nokia.com  PHASE-CRT  SW-SBTS17
    ...  SW-SBTS18  SW-SBTS19

    Step 1: Input Swconfig Via Sftp
    Step 2: Power Off BTS
    Step 3: Power On BTS
    Step 4: Check If BTS Is Stable
    Step 5: Check BTS Status If Commissioned


Step 1: Input Swconfig Via Sftp
    Log  Step1: Input Swconfig Via Sftp  console=true
    Verify SSH Connection And Enable If Necessary
    ssh.Connect To  ${OAM_BTS_IP}  ${SMOD1['USERNAME']}  ${SMOD1['PASSWORD']}  alias=pc_connection
    ${sw_config}  ssh.Execute  cat /ffs/run/swconfig.txt    connection=pc_connection
    ssh.Upload File  ${SWCONFIG_PATH}  //ffs/run/swconfig.txt  connection=pc_connection
    ${sw_config}  ssh.Execute  cat //ffs/run/swconfig.txt    connection=pc_connection
    ssh.Disconnect  connection=pc_connection
    ${status}  Run Keyword And Return Status
    ...  Variable Should Exist  ${PC_IP2}
    IF  ${status}  Upload Swconfig On Secondary Core


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
    Sleep  1200s
    IF  ${ping_regain_status}==${False}
      Fail  Ping has not been regained within timeout
    ELSE
      Start Infomodel
    END


Step 5: Check BTS Status If Commissioned
    Log  Step5: Check BTS Status If Commissioned  console=true
    Wait Until Keyword Succeeds  2m  15s
    ...  Start Admin  bts_host=${OAM_BTS_IP}
    ${bts_state_is_correct}  ${bts_current_status}  Verify BTS ProceduralState  (?i)NotCommissioned
    IF  ${bts_state_is_correct}
      Log  BTS is not commissioned. Will not check states any further.  console=true
    ELSE
      Admin Check All States
    END

    ssh.Connect To  ${OAM_BTS_IP}  ${SMOD1['USERNAME']}  ${SMOD1['PASSWORD']}  alias=pc_connection
    ${sw_config}  ssh.Execute  cat /ffs/run/swconfig.txt    connection=pc_connection
    ssh.Disconnect  connection=pc_connection

    ${status}  Run Keyword And Return Status  Variable Should Exist  ${PC_IP2}
    IF  ${status} == ${FALSE}  RETURN
    ${vm_password}  Run  sudo cat /etc/ute/vncpasswd
    ssh.Connect To  hostname=${PC_IP2}  username=ute  password=${vm_password}  alias=sc_vm
    ssh.Connect To  hostname=192.168.255.119  username=${SMOD1['USERNAME']}  password=${SMOD1['PASSWORD']}  alias=sc_connection  proxy=sc_vm
    ${sw_config}  ssh.Execute  cat //ffs/run/swconfig.txt    connection=sc_connection
    ssh.Disconnect  connection=sc_connection

Upload Swconfig On Secondary Core
    Log  Upload swconfig on secondary core  console=true
    ${vm_password}  Run  sudo cat /etc/ute/vncpasswd
    ssh.Connect To  hostname=${PC_IP2}  username=ute  password=${vm_password}  alias=sc_vm
    ssh.Connect To  hostname=192.168.255.119  username=${SMOD1['USERNAME']}  password=${SMOD1['PASSWORD']}  alias=sc_connection  proxy=sc_vm
    ${sw_config}  ssh.Execute  cat //ffs/run/swconfig.txt  connection=sc_connection
    ssh.Upload File  ${SWCONFIG_PATH}  //ffs/run/swconfig.txt  connection=sc_connection
    ${sw_config}  ssh.Execute  cat //ffs/run/swconfig.txt  connection=sc_connection
    ssh.Disconnect  connection=sc_connection


Admin Check All States
    Assert All Cells Are In Expected State
    Verify System Modules States
    Verify Radio Modules States


TC Setup
    Common Test Setup  modules_check=${FALSE}  cells_check=${FALSE}  alarms_check=${FALSE}  admin_launch=${FALSE}  infomodel_launch=${FALSE}
    ...  tc_name=SWM__Upload_swconfig


TC Teardown
    Common Test Teardown  collect_snapshot=never
