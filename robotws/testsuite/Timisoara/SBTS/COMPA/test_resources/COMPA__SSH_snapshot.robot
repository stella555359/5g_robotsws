*** Settings ***
Documentation
    ...  Temporary solution for COMPA snapshot

Resource  ../../common_resources/ca_CIT_general.robot


*** Keywords ***
TC__COMPA__SSH_snapshot
    [Documentation]
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 05.07.2019 - https://jira3.int.net.nokia.com/browse/TAT-16796 - [EDITORIAL] Check and change TC names .robot file in ~/SWM and ~/COMPA
    ...  - 24.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17985 - Changes name of TC in *** Test Cases *** to 'COMPA__SSH_snapshot'
    ...  - 14.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24111 - Migrate from hran_ssh to taf.transport.ssh
    ...  - 09.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29214 - Watchdog disabled
    ...

    Set Tags  CA-COMPA  CA-LOGS  AUTHOR-jacek.mnich@nokia.com  MAINTAINER-wojciech.sikora@nokia.com  PHASE-CRT  SW-SBTS17  SW-SBTS18  SW-SBTS19
    ...  SW-LTE  SW-WBTS  SW-FDSW

    TC Preconditions
    Step1: Collect Snapshot


TC Preconditions
    Log  Verify SSH connection  console=true
    Setup Hran Compa  ssh_user=${SMOD1['USERNAME']}  ssh_password=${SMOD1['PASSWORD']}
    ${is_ssh_enable}  Check If SSH Is Enabled
    Run Keyword If  ${is_ssh_enable}
    ...  Log  Ssh is enabled!  console=true
    ...  ELSE
    ...  Enable Ssh Via FTM Page


Step1: Collect Snapshot
    Log Step Header  Step1: Collect Snapshot
    Log  Collecting Snapshot via ssh  console=true
    ${ssh_snapshot}  Run Keyword And Return Status
    ...  Collect Snapshot Via SSH  ${BTS_FILES}  ${SMOD1['TRS_IP']}
    Run Keyword If  ${ssh_snapshot}
    ...  Log  Snapshot was collected!  console=true
    ...  ELSE
    ...  Set Test Norun  Couldn't collect snapshot via ssh
    Collect Extended TRS Logs


Enable Ssh Via FTM Page
    Log  Trying to enable ssh via FTM page  console=true
    ${status}  Enable_SSH_by_TRS
    Log  Enable ssh via FTM page status: ${status}  console=true


TC Setup
    Set Test Variable  ${DISABLE_WATCHDOG}  ${TRUE}
    Common Test Setup  admin_launch=${FALSE}  infomodel_launch=${FALSE}  modules_check=${FALSE}  cells_check=${FALSE}  alarms_check=${FALSE}
    ...  tc_name=COMPA__SSH_snapshot


TC Teardown
    Common Test Teardown
