*** Settings ***
Documentation
    ...  Temporary solution for COMPA snapshot

Resource  ../../common_resources/ca_CIT_general.robot


*** Keywords ***
TC__COMPA__FDSW_Snapshot
    [Documentation]
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 05.07.2019 - https://jira3.int.net.nokia.com/browse/TAT-16796 - [EDITORIAL] Check and change TC names .robot file in ~/SWM and ~/COMPA
    ...  - 14.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24111 - Migrate from hran_ssh to taf.transport.ssh
    ...  - 09.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29214 - Watchdog disabled
    ...  - 26.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29441 - Fix for Snapshot download
    ...
    [Timeout]  15m

    Set Tags  COMPA-LOGS  AUTHOR-jacek.mnich@nokia.com  MAINTAINER-iasmin.tomici@nokia.com  PHASE-CRT  PHASE-COMPA  SW-FDSW

    TC Preconditions
    Step1: Collect Snapshot


TC Preconditions
    Log  Verify SSH connection  console=true
    Setup Hran Compa  ssh_user=${SMOD1['USERNAME']}  ssh_password=${SMOD1['PASSWORD']}
    Run Keyword And Ignore Error
    ...  Verify SSH Connection And Enable If Necessary


Step1: Collect Snapshot
    Log Step Header  Step1: Collect Snapshot
    Log  Collecting Snapshot via ssh  console=true
    ${save_status}  Save Snapshot
    IF  ${save_status}
    ...  Log  Snapshot was saved!  console=true
    ...  ELSE
    ...  Fail  Could not save snapshot
    ${download_status}  Download Snapshot
    IF  ${download_status}
    ...  Log  Snapshot was downloaded!  console=true
    ...  ELSE
    ...  Fail  Could not download snapshot


Enable Ssh Via FTM Page
    Log  Trying to enable ssh via FTM page  console=true
    ${status}  Enable_SSH_by_TRS
    Log  Enable ssh via FTM page status: ${status}  console=true


Save Snapshot
    Log  Saving snapshot  console=true
    Connect To SMOD  ${OAM_BTS_IP}
    ${save_status}  Run Keyword And Return Status
    ...  ssh.Execute  nc localhost 15007 <<<"log -a -z /ffs/run/trs_data/db/snapshot.zip" 2>/dev/null

    [Return]  ${save_status}


Download Snapshot
    Log  Getting snapshot  console=true
    SSHLibrary.Open Connection  ${OAM_BTS_IP}
    SSHLibrary.Login  toor4nsn  oZPS0POrRieRtu
    ${download_status}  Run Keyword And Return Status
    ...  SSHLibrary.Get File  /ffs/run/trs_data/db/snapshot.zip  ${BTS_FILES}/SNAPSHOT_files/
    SSHLibrary.Close Connection

    [Return]  ${download_status}


TC Setup
    Set Test Variable  ${DISABLE_WATCHDOG}  ${TRUE}
    Common Test Setup  admin_launch=${FALSE}  infomodel_launch=${FALSE}  modules_check=${FALSE}  cells_check=${FALSE}  alarms_check=${FALSE}


TC Teardown
    Common Test Teardown  collect_snapshot=never
