*** Settings ***
Documentation
    ...  Check Swconfig File presence on Master and Secondary Core

Resource  ../../common_resources/ca_CIT_general.robot


*** Keywords ***
TC__SWM__Check_swconfig_file_presence
    [Documentation]
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 02.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-27885 - Initial creation
    ...  - 09.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30480 - Check if swconfig contains flag: 0x10041

    Set Tags  CA-STATE  OWNER-daniel.cozma@nokia.com  AUTHOR-iasmin.tomici@nokia.com  PHASE-CRT

    Step 1: Check Swconfig file


Step 1: Check Swconfig file
    Log  Step1: Check Swconfig file  console=true
    ssh.Connect To  ${OAM_BTS_IP}  ${SMOD1['USERNAME']}  ${SMOD1['PASSWORD']}  alias=pc_connection
    Log  Check Swconfig on Master.  console=true
    ${sw_config_files}  ssh.Execute  ls -l /ffs/*/swconfig.txt  connection=pc_connection
    ${sw_config}  ssh.Execute  cat //ffs/run/swconfig.txt  connection=pc_connection
    ${flag_sw_config}  ssh.Execute  cat /ffs/run/swconfig.txt | grep 0x10041  connection=pc_connection
    ${status}  Run Keyword And Return Status  Should Not Be Empty  ${flag_sw_config}
    IF  ${status}
        Log  Swconfig on Master: ${sw_config}  console=true
    ELSE
        Fail  Swconfig file doesn't exist or does not contain flag 0x10041. [NOK]
    END
    ${status}  Run Keyword And Return Status  Variable Should Exist  ${PC_IP2}
    IF  ${status}  Check Swconfig On Secondary Core

    [Teardown]  ssh.Disconnect  connection=pc_connection


Check Swconfig On Secondary Core
    Log  Check Swconfig on Secondary Core.  console=true
    ${vm_password}  Run  sudo cat /etc/ute/vncpasswd
    ssh.Connect To  hostname=${PC_IP2}  username=ute  password=${vm_password}  alias=sc_vm
    ssh.Connect To  hostname=192.168.255.119  username=${SMOD1['USERNAME']}  password=${SMOD1['PASSWORD']}  alias=sc_connection  proxy=sc_vm
    ${sw_config_files}  ssh.Execute  ls -l /ffs/*/swconfig.txt    connection=sc_connection
    ${sw_config}  ssh.Execute  cat //ffs/run/swconfig.txt    connection=sc_connection
    ${flag_sw_config}  ssh.Execute  cat /ffs/run/swconfig.txt | grep 0x10041    connection=sc_connection
    ${status}  Run Keyword And Return Status  Should Not Be Empty  ${flag_sw_config}
    IF  ${status}
        Log  Swconfig on Secondary: ${sw_config}  console=true
    ELSE
        Fail  Swconfig file doesn't exist or does not contain flag 0x10041. [NOK]
    END

    [Teardown]  Run Keywords  ssh.Disconnect  connection=sc_connection  AND  ssh.Disconnect  connection=sc_vm


TC Setup
    Common Test Setup  modules_check=${FALSE}  cells_check=${FALSE}  alarms_check=${FALSE}  admin_launch=${FALSE}  infomodel_launch=${FALSE}


TC Teardown
    Common Test Teardown  collect_snapshot=never
