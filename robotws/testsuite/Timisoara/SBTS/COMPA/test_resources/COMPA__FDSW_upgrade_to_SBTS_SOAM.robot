*** Settings ***
Documentation
    ...  TC for SW download and activation FDSW to SBTS17

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${SWCONFIG_PATH}  /home/ute/btsauto/swconfigs/swconfig.txt
${TARGET_SW_DIR}  /home/ute/btsauto/TARGET_SW  # Directory in which TC should look for sw package.
# If not given, '/home/ute/btsauto/TARGET_SW' shall be used
${TARGET_SW_NAME}  ${None}  # SW package name. If not given, TC will choose newest package in a directory.
${ADMIN_SETUP_TIMEOUT}  900  # Timeout for admin setup since reset start
${RM_DETECTION_TIMEOUT}  20 min  # Timeout for all connected RMs detection (in minutes)
${UPGRADE_TIMEOUT_ASYNC}  2000  # [sec] how long should we wait for upgrade results
${IP_SBTS}  192.168.255.129
${PORT}  443
${USERNAME}  Nemuadmin
${PASSWORD}  nemuuser


*** Keywords ***
TC__COMPA__FDSW_upgrade_to_SBTS_SOAM
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-4831
    ...
    ...  **Request ID:** TAT-4849
    ...  *********************
    ...  3. History of changes
    ...  *********************
    ...  - 14.02.2017 - initial creation
    ...  - 01.03.2018 - name changed
    ...  - 20.03.2018 - TAT-8949
    ...  - 19.12.2018 - TAT-8883
    ...  - 21.01.2019 - TAT-14069
    ...  - 21.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15130 - Added RMs detecting prcedure
    ...  - 05.07.2019 - https://jira3.int.net.nokia.com/browse/TAT-16765 - change RMOD detection method after update (!=NotInstalled)
    ...  - 24.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17943 - Moves KW:'Check if all radio modules are available' to ca_swm_general.robot
    ...  - 03.12.2019 - https://jira3.int.net.nokia.com/browse/TAT-17857 - Add support for Rescue Console ( >=FDSW18SP)
    ...  - 03.12.2019 - https://jira3.int.net.nokia.com/browse/TAT-18458 - Fix problem with uploading swconfig.txt
    ...  - 11.12.2019 - https://jira3.int.net.nokia.com/browse/TAT-18544 - Add option to enable SSH via Rescue Console in hran_compa.
    ...  - 24.01.2020 - https://jira3.int.net.nokia.com/browse/TAT-18870 - Remove KW:Sleep to fix problem with uploading swconfig.txt
    ...  - 01.07.2020 - https://jira3.int.net.nokia.com/browse/TAT-19713 - Increase timeout for taf.fdsw.rc software update keyword
    ...  - 14.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24111 - Migrate from hran_ssh to taf.transport.ssh
    ...  - 08.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24252 - Remove ute_btssm library and check FDSW version
    ...  - 23.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29099 - Watchdog disabled
    ...
    ...  **********************
    ...  4. Test case flowchart
    ...  **********************
    ...  .. image:: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/FDSW_upgrade_to_SBTS17_TAT_4857.png

    Set Tags  CA-COMPA  PHASE-COMPA  OWNER-daniel.cozma@nokia.com  AUTHOR-jacek.mnich@nokia.com  MAINTAINER-iasmin.tomici@nokia.com  SW-SBTS17
    ...  SW-SBTS18  SW-SBTS18  FEATURE-RP000912

    Step1: Prechecks
    Step2: SW Upgrade
    Step3: Postchecks


Step1: Prechecks
    Log Step Header  Step1: Prechecks
    Setup Hran Compa  ssh_user=${SMOD1['USERNAME']}  ssh_password=${SMOD1['PASSWORD']}
    Enable SSH Via Rescue Console
    Run Local Linux Command  ssh-keygen -f "/home/ute/.ssh/known_hosts" -R ${SMOD1['TRS_IP']}
    Log  Will now create path to SW package  console=true
    ${target_sw_path}  Get SW File For SWDL  ${TARGET_SW_DIR}  ${TARGET_SW_NAME}
    Run Keyword If  '${target_sw_path}'== ${None}
    ...  Fail  SW package could not have been be chosen. Fill the parameters.
    Set Test Variable  ${TARGET_SW_PATH}  ${target_sw_path}
    Log  Chosen software package is: ${TARGET_SW_PATH}  console=true
    ${sw_release_name}  hran_file_operations.Get TargetBD Node Attribute Value  softwareReleaseVersion  ${TARGET_SW_PATH}
    Set Test Variable  ${SW_RELEASE_NAME}  ${sw_release_name}


Step2: SW Upgrade
    Log Step Header  Step2: SW upgrade
    ${active_partition_id}  ${passive_partition_id}  Get Active And Passive Partitions Ids
    Set Test Variable  ${PASSIVE_PARTITION_ID}  ${passive_partition_id}
    Log  Will now read Active and passive_sw versions, present at BTS.  console=true
    ${active_sw}  ${passive_sw}  Get Active And Passive SW Version From Rescue Console
    Set Tags  SW_BEFORE_UPGRADE_active-${active_sw}
    Set Tags  SW_BEFORE_UPGRADE_passive-${passive_sw}
    Set Test Variable  ${ACTIVE_SW}
    Log  Will now verify if chosen package is already present on BTS.  console=true
    Check If Sw Already Present  ${ACTIVE_SW}  ${passive_sw}  ${SW_RELEASE_NAME}
    Log  Package not present. Will continue the test.  console=true
    Sleep  100
    Log To Console With Time  Will now perform SW upgrade in async
    ${sw_update_time}  Get Time
    Set Test Variable  ${SW_UPDATE_TIME}
    Connect To Rescue Console  name=rc_swr
    Start Async  taf.fdsw.rc  Software update  sw_slot_id=${PASSIVE_PARTITION_ID}  sw_pkg_path=${TARGET_SW_PATH}  timeout=3600  activate=${TRUE}
    ...  connection=rc_swr
    ${swconfig_updated}  Run Keyword And Return Status
    ...  Run Keyword If  '${SWCONFIG_PATH}'!='${None}'
    ...  Input Swconfig
    Run Keyword If  '${swconfig_updated}'=='${FALSE}'
    ...  Set Test Restriction  swconfig update failed
    Log  Wait for upgrade to finish  console=true
    ${sw_update_files}  Wait For Async Result  timeout=${UPGRADE_TIMEOUT_ASYNC}
    Wait Until BTS Up After Reset  ${ADMIN_SETUP_TIMEOUT}
    Run Keyword If  ${ADMIN_STARTED}
    ...  Log  Admin started!  console=true
    ...  ELSE
    ...  Run Keywords
    ...  Set Test Failed  Admin setup failed
    ...  AND
    ...  Check If Target Is Stable  ${SMOD1['TRS_IP']}  max_downtime=600

    [Teardown]  Stop Async


Step3: Postchecks
    Log Step Header  Step3: Postchecks
    Log  Will now try to collect active alarms via admin.  console=true
    sbts_admin.Admin Check Active Alarms TAF
    Start Infomodel Connection
    Run Keyword If  ${INFOMODEL_STARTED}
    ...  Print Active And Passive SW Version
    Start SCF Parser Or Set Restriction  UNIVERSAL
    Run Keyword If  ${SCF_PARSER_STARTED}
    ...  Run Keywords
    ...  Log  Will now verify that all expected RMODs detected  console=true
    ...  AND
    ...  Wait Until Keyword Succeeds  ${RM_DETECTION_TIMEOUT}  20 sec
    ...  Check If All Radio Modules Are Available


Input Swconfig
    Log  Input swconfig when activation starts  console=true
    ${fdsw_version}  Run Keyword And Return Status
    ...  Should Contain  ${ACTIVE_SW}  FDSW1.2
    Log  Wait until new /ffs/stb/TargetBD*.xml is created  console=true
    Wait Until Keyword Succeeds  30 min  5 sec
    ...  Check If TargetBD Is Already Copied
    Log  Wait until /ffs/stb/config is deleted  console=true
    Run Keyword If  not ${fdsw_version}
    ...  Wait Until Keyword Succeeds  30 min  1 sec
    ...  Check If Config Folder Is Already Deleted
    Wait Until Keyword Succeeds  15 min  1 sec
    ...  Check If Config Folder Is Already Created
    Log  Upload swconfig from ${SWCONFIG_PATH}  console=true
    Run Remote Linux Command  cat /proc/self/mounts | grep ffs/fs
    Run Remote Linux Command  mount -o rw,remount /ffs/fs${PASSIVE_PARTITION_ID}
    Upload File To SMOD Via SSH  ${SWCONFIG_PATH}  /ffs/fs${PASSIVE_PARTITION_ID}


Check If Sw Already Present
    [Arguments]  ${active_sw}  ${passive_sw}  ${sw_release_name}

    ${target_is_active}  Run Keyword And Return Status
    ...  Should Match Regexp  ${sw_release_name}.xml  .*${active_sw}
    Run Keyword If  ${target_is_active}
    ...  Fail  Target SW is the same as the active_sw
    ${target_is_passive_1}  Run Keyword And Return Status
    ...  Should Contain  ${sw_release_name}  ${passive_sw}
    ${target_is_passive_2}  Run Keyword And Return Status
    ...  Should Contain  ${passive_sw}  ${sw_release_name}
    Run Keyword If  ${target_is_passive_1} and ${target_is_passive_2}
    ...  Set Test Restriction  Target SW is the same as the passive_sw


Wait Until BTS Up After Reset
    [Arguments]  ${timeout}=900 s
    [Timeout]  ${timeout}

    Set Test Variable  ${PING_REGAINED_TIME}  ${False}
    FOR  ${attempt}  IN RANGE  1  100000
        ${state_check_status}  BTS Up Check
        Run Keyword If  ${state_check_status}
        ...  Return From Keyword  ${TRUE}
    END


Continous Ping Check
    Log  Will now check if bts ping is stable (360s)  console=true
    ${stable_ping_check}  Run Keyword And Return Status
    ...  Check If Target Is Stable  ip=${SMOD1['TRS_IP']}  min_uptime=360  timeout=360

    Return From Keyword If  ${stable_ping_check}  ${TRUE}

    [Return]  ${False}


Upload File To SMOD Via SSH
    [Arguments]  ${source_file_path}  ${destination_directory}

    Run Local Linux Command
    ...  sshpass -p "${SMOD1['PASSWORD']}" scp -r ${source_file_path} ${SMOD1['USERNAME']}@${SMOD1['TRS_IP']}:${destination_directory}
    Run Remote Linux Command  ls -l ${destination_directory}


Check If TargetBD Is Already Copied
    ${release_regexp}  Should Match Regexp  ${SW_RELEASE_NAME}  _\\d{4}_\\d{6}_\\d{6}
    ${target_bd_status}  Run Remote Linux Command  find /ffs/stb/TargetBD*.xml.p7 -mmin -1
    Should Contain  ${target_bd_status}  ${release_regexp}
    Should Contain  ${target_bd_status}  /ffs/stb/TargetBD
    ${target_bd_status}  Run Remote Linux Command  find /ffs/stb/TargetBD*.xml -mmin -1
    Should Contain  ${target_bd_status}  ${release_regexp}
    Should Contain  ${target_bd_status}  /ffs/stb/TargetBD
    Should Not Contain  ${target_bd_status}  FDSW


Check If Config Folder Is Already Deleted
    ${config_status}  Run Remote Linux Command  find /ffs/stb/ -type d -name "config"
    Should Not Contain  ${config_status}  /ffs/stb/config


Check If Config Folder Is Already Created
    ${config_status}  Run Remote Linux Command  find /ffs/stb/ -type d -name "config"
    Should Contain  ${config_status}  /ffs/stb/config


TC Setup
    Set Test Variable  ${DISABLE_WATCHDOG}  ${TRUE}
    Common Test Setup  admin_launch=${FALSE}  infomodel_launch=${FALSE}  modules_check=${FALSE}  cells_check=${FALSE}  alarms_check=${FALSE}


TC Teardown
    Teardown Rescue Console  alias=rc_swr
    Common Test Teardown  collect_snapshot=never
