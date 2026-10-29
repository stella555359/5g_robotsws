*** Settings ***
Documentation   Test for CNI-94033_System_runtime_log_Error_prints_from_Dual_Core

Library    OperatingSystem
Library    DateTime
Library    Collections
Library    String
Library    taf.ul.verify_snapshot  WITH NAME  snapshot
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    taf.transport.ssh    WITH NAME    ssh
Library    ../resources/print_extractor.py
Resource    ../resources/bts_states.robot
Resource    ../resources/ssh_utils.robot
Resource    ../resources/pdu.robot
Resource    ../resources/verdicts.robot
Resource    ../resources/unpacking.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${STARTUP_TIMEOUT}        20
${SNAPSHOT_TIMEOUT}       1200
${MSM_OFF}                ${False}
${actDefaultFaultSnapTriggers_changed}  ${False}

*** Keywords ***
TC__LOGS__CNI-94033_System_runtime_log_Error_prints_from_Dual_Core
    [Documentation]
    ...  [CASE LINK]:
    ...  https://jiradc.ext.net.nokia.com/browse/TAT-25409
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Test case created to verify if VIP/ERR prints are handled independently by primary and secondary system modules.
    ...  Each system module should take care of own VIP/ERR prints and save them to own SYSTEM level log files in the same subrack.
    ...  This test verifies if VIP/ERR prints are saved to appropriate log files by ESM when MSM is disconnected, and if they are saved
    ...  independently by each SMOD when BTS is synchronized and onAir.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 24.05.2023 - TAT-25409 Initial Creation - Damian Kotula
    ...
    ...  *******************
    ...  Test case flowchart
    ...  https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/raw/master/testsuite/SBTS/
    ...  LOGS__CNI-94033_System_runtime_log_Error_prints_from_Dual_Core.png
    ...  *******************

    Set Tags    CA-LOGS    AUTHOR-damian.kotula@nokia.com    MAINTAINER-damian.kotula@nokia.com
    ...   GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CRT    SW-SBTS23R3    FEATURE-CNI-94033

    Step 0: Preconditions
    Step 1: Turn OFF MSM And Collect Snapshot from ESM
    Step 2: Turn ON MSM And Collect Snapshot
    Step 3: Check If VIP/ERR Prints Were Logged Independently By Each SMOD

Step 0: Preconditions
    [Documentation]
    ...  In this step it is checked if configuration in dualcore and parameter actDefaultFaultSnapTriggers is set to false,
    ...  so it doesn't trigger snapshot after connection between cores will be broken.

    Log  \nStep 0: Preconditions  console=${True}
    ${Test_start_time}=  Get Current Timestamp
    Set Test Variable  ${Test_start_time}
    ${is_it_dualcore}=  Run Keyword And Return Status  Variable Should Exist  ${SMOD2}
    Run Keyword If  ${is_it_dualcore}!=${True}  verdicts.Set Test Failed  This TC is only for dualcore configurations  ${True}
    Disable actDefaultFaultSnapTriggers

Step 1: Turn OFF MSM And Collect Snapshot from ESM
    [Documentation]
    ...  In this step primary core is powered off from EPC, which will trigger VIP/ERR prints and cause first ESM reset.
    ...  After ESM recovery, snapshot is collected to trigger VIP prints.

    Log  \nStep 1: Turn OFF MSM And Collect Snapshot from ESM  console=${True}
    Turn OFF MSM
    Sleep  1m
    ${is_ESM_pingable}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  10 min  10 sec  Check ping on ESM
    Run Keyword If  ${is_ESM_pingable}
    ...  log  ESM is pingable, waiting additional 5 min for ESM to fully recover before collecting snapshot  console=${True}
    ${ESM_ping_time}=  Get Current Timestamp
    Set Test Variable  ${ESM_ping_time}
    Sleep  7m
    Setup Admin on ESM
    Collect Snapshot from ESM

Step 2: Turn ON MSM And Collect Snapshot
    [Documentation]
    ...  In this step primary core is powered on from EPC, which will cause second ESM reset.
    ...  After BTS recovery, snapshot is collected to trigger VIP prints.

    Log  \nStep 2: Turn ON MSM And Collect Snapshot  console=${True}
    #${MSM_ON_time}=  Get Current Timestamp
    #Set Test Variable  ${MSM_ON_time}
    Turn ON MSM and wait for OnAir
    ${MSM_ON_time}=  Get Current Timestamp
    Set Test Variable  ${MSM_ON_time}
    @{time}=  Get Time  year month day hour min
    ${snapshot_status}=  Run Keyword And Return Status
    ...  coam.Collect Snapshot  ${BTS Files}/snapshot_${time[0]}_${time[1]}_${time[2]}_${time[3]}_${time[4]}.zip  timeout=${SNAPSHOT_TIMEOUT}
    Run Keyword If  ${snapshot_status}  Run Keywords
    ...  Log  Collecting snapshot succeeded  console=${True}
    ...  AND  Set Test Variable  ${path_to_snapshot}  ${BTS Files}/snapshot_${time[0]}_${time[1]}_${time[2]}_${time[3]}_${time[4]}.zip
    ...  ELSE  verdicts.Set Test Failed  Collecting snapshot has failed  ${True}
    ${MSM_Snapshot_end_time}=  Get Current Timestamp
    Set Test Variable  ${MSM_Snapshot_end_time}

Step 3: Check If VIP/ERR Prints Were Logged Independently By Each SMOD
    [Documentation]
    ...  In this step runtime logs and post mortem logs are checked for VIP/ERR prints.
    ...  Each system module should handle its own VIP/ERR prints and save them to own SYSTEM level log files in the same subrack.

    Log  \nStep 3: Check If VIP/ERR Prints Were Logged Independently By Each SMOD  console=${True}
    Unpack Snapshot
    ${1011_runtime_log_file_path}=  Find And Unpack File   BTS${BTS_ID}_1011_runtime.zip
    ${2011_runtime_log_file_path}=  Find And Unpack File   BTS${BTS_ID}_2011_runtime.zip
    ${2011_pm_1_log_file_path}=  Find And Unpack File   BTS${BTS_ID}_2011_pm_1_syslog.zip
    ${2011_pm_2_log_file_path}=  Find And Unpack File   BTS${BTS_ID}_2011_pm_2_syslog.zip

    Log  \nChecking VIP/ERR prints from 2011_pm_2_syslog.zip  console=${True}
    Log  \nShould contain ESM logs from test start until first ESM reset (MSM disconnection and ESM reset logs):  console=${True}
    ${SMOD_print_count}  ${BBMod_print_count}  Check VIP/ERR prints
    ...  ${2011_pm_2_log_file_path}  ${BTS Files}/2011_PM_2_filtered_prints.txt  ${Test_start_time}  ${ESM_ping_time}
    Should Not Be Equal As Integers  ${SMOD_print_count}  0
    Should Not Be Equal As Integers  ${BBMod_print_count}  0

    Log  \nChecking VIP/ERR prints from 2011_pm_1_syslog.zip  console=${True}
    Log  \nShould contain ESM logs from period when cores when disconnected (Snapshot collection from ESM logs):  console=${True}
    ${SMOD_print_count}  ${BBMod_print_count}  Check VIP/ERR prints
    ...  ${2011_pm_1_log_file_path}  ${BTS Files}/2011_PM_1_filtered_prints.txt  ${ESM_ping_time}  ${MSM_ON_time}
    Should Not Be Equal As Integers  ${SMOD_print_count}  0
    Should Not Be Equal As Integers  ${BBMod_print_count}  0

    Log  \nChecking VIP/ERR prints from 1011_runtime.zip  console=${True}
    Log  \nShould contain MSM logs from period between BTS recovery and end of snapshot collection from MSM:  console=${True}
    ${SMOD_print_count}  ${BBMod_print_count}  Check VIP/ERR prints
    ...  ${1011_runtime_log_file_path}  ${BTS Files}/1011_runtime_filtered_prints.txt  ${MSM_ON_time}  ${MSM_Snapshot_end_time}
    Should Not Be Equal As Integers  ${SMOD_print_count}  0
    Should Not Be Equal As Integers  ${BBMod_print_count}  0

    Log  \nChecking VIP/ERR prints from 2011_runtime.zip  console=${True}
    Log  \nShould contain ESM logs from period between BTS recovery and end of snapshot collection from MSM:  console=${True}
    ${SMOD_print_count}  ${BBMod_print_count}  Check VIP/ERR prints
    ...  ${2011_runtime_log_file_path}  ${BTS Files}/2011_runtime_filtered_prints.txt  ${MSM_ON_time}  ${MSM_Snapshot_end_time}
    Should Not Be Equal As Integers  ${SMOD_print_count}  0
    Should Not Be Equal As Integers  ${BBMod_print_count}  0

    Check Additional AaSysInfo Files

Unpack Snapshot
    [Documentation]
    ...  This keyword is used to unpack snapshot.
    ${Unpacked_snapshot_path}=  Set Variable  ${BTS Files}/Unpacked_Snapshot
    Set Test Variable  ${UNPACKED_SNAPSHOT_PATH}
    unpacking.Unpack Archive Content To Directory  ${path_to_snapshot}  ${UNPACKED_SNAPSHOT_PATH}
    ${Snapshot_dictionary}=  snapshot.Get Data From Snapshot  ${path_to_snapshot}
    Set Test Variable  ${SNAPSHOT_DICTIONARY}

Find And Unpack File
    [Documentation]
    ...  This keyword is used to find specified file in snapshot and unpack it until runtime_SYSTEM.log
    ...  Works only for Runtime and PostMortem files.
    ...  Filename to unpack is needed as argument. Path to unpacked file is returned from keyword.
    [Arguments]  ${filename}

    ${file_entry_from_snapshot_dictionary}=  Set Variable  ${SNAPSHOT_DICTIONARY}[${filename}]
    ${file_container_and_file_name}=  collections.Get From List  ${file_entry_from_snapshot_dictionary}  0
    ${file_container_name}=  string.Fetch From Left  ${file_container_and_file_name}  /

    unpacking.Unpack Archive Content To Directory  ${UNPACKED_SNAPSHOT_PATH}/${File_container_name}
    ...  ${UNPACKED_SNAPSHOT_PATH}/${File_container_name}_unpacked
    unpacking.Unpack Archive Content To Directory  ${UNPACKED_SNAPSHOT_PATH}/${File_container_name}_unpacked/${filename}
    ...  ${UNPACKED_SNAPSHOT_PATH}/${filename}_unzipped
    unpacking.Unpack Archive Content To Directory  ${UNPACKED_SNAPSHOT_PATH}/${filename}_unzipped/runtime_SYSTEM.log.xz
    ...  ${UNPACKED_SNAPSHOT_PATH}/${filename}_unpacked
    ${log_file_path}=  Set Variable  ${UNPACKED_SNAPSHOT_PATH}/${filename}_unpacked/runtime_SYSTEM.log
    [Return]  ${log_file_path}

Check VIP/ERR prints
    [Documentation]
    ...  This keyword extracts VIP/ERR prints from a specified period within a given log file and saves it to a new file.
    ...  It also counts number of VIP/ERR prints and number of prints by SMOD and BBmods.
    [Arguments]  ${log_file}  ${output_file}  ${start_time}  ${end_time}

    print_extractor.Extract Lines  ${log_file}  ${output_file}  ${start_time}  ${end_time}
    OperatingSystem.File Should Not Be Empty  ${output_file}

    ${filtered_file}=  OperatingSystem.Get File  ${output_file}
    ${line_count}=  string.Get Line Count  ${filtered_file}
    Run Keyword If  '${line_count}' != '0'  log  \nFile contains VIP/ERR prints from defined period!  console=${True}
    ${ERR_prints}=  string.Get Lines Containing String  ${filtered_file}  ERR/
    ${VIP_prints}=  string.Get Lines Containing String  ${filtered_file}  VIP/
    ${ERR_print_count}=  string.Get Line Count  ${ERR_prints}
    ${VIP_print_count}=  string.Get Line Count  ${VIP_prints}
    Log  \nNumber of lines with VIP/ERR prints: ${line_count} \nVIP prints: ${VIP_print_count} \nERR prints: ${ERR_print_count}  console=${True}
    ${SMOD_prints}=  string.Get Lines Matching Pattern  ${filtered_file}  * FCT-?011-*
    ${BBMod_prints}=  string.Get Lines Matching Pattern  ${filtered_file}  * ?SP-???D-*
    ${SMOD_print_count}=  string.Get Line Count  ${SMOD_prints}
    ${BBMod_print_count}=  string.Get Line Count  ${BBMod_prints}
    Log  \nNumber of SMOD prints: ${SMOD_print_count} \nNumber of BBmod prints: ${BBMod_print_count}  console=${True}
    [Return]  ${SMOD_print_count}  ${BBMod_print_count}

Check Additional AaSysInfo Files
    [Documentation]
    ...  This keyword is used to check if additional AaSysInfo files (SYSTEM level log prints with particular featureId)
    ...  were saved to post mortem logs when connection between cores were broken.

    ${pm_filename}=  Set Variable  BTS${BTS_ID}_2011_pm_2_syslog.zip
    unpacking.Unpack Archive Content To Directory  ${UNPACKED_SNAPSHOT_PATH}/${pm_filename}_unzipped/runtime_SYSTEM_AaSNTP_NTPD.log.xz  ${BTS Files}
    OperatingSystem.File Should Exist  ${BTS Files}/runtime_SYSTEM_AaSNTP_NTPD.log
    unpacking.Unpack Archive Content To Directory  ${UNPACKED_SNAPSHOT_PATH}/${pm_filename}_unzipped/runtime_SYSTEM_AaSysInfoL1.log.xz  ${BTS Files}
    OperatingSystem.File Should Exist  ${BTS Files}/runtime_SYSTEM_AaSysInfoL1.log
    unpacking.Unpack Archive Content To Directory  ${UNPACKED_SNAPSHOT_PATH}/${pm_filename}_unzipped/runtime_SYSTEM_AaSysInfoMcu.log.xz  ${BTS Files}
    OperatingSystem.File Should Exist  ${BTS Files}/runtime_SYSTEM_AaSysInfoMcu.log
    unpacking.Unpack Archive Content To Directory  ${UNPACKED_SNAPSHOT_PATH}/${pm_filename}_unzipped/runtime_SYSTEM_AaSysInfoRt.log.xz  ${BTS Files}
    OperatingSystem.File Should Exist  ${BTS Files}/runtime_SYSTEM_AaSysInfoRt.log

Disable actDefaultFaultSnapTriggers
    [Documentation]
    ...  This KW checks if actDefaultFaultSnapTriggers = false, if not, sets it to false.
    ${bts_id}=  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}
    ${TRBLCADM_CONF}=  Query Infomodel
    ...  query=get object /MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-${BTS_ID}/MNL_A-*/MNLENT_A-*/TRBLCADM_A-*
    Run Keyword If  '${TRBLCADM_CONF.actDefaultFaultSnapTriggers}' == '${True}'
    ...  Run Keywords
    ...  coam.Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1  parameter=actDefaultFaultSnapTriggers
    ...  operation=update  value=false  skip_parameter_relation_errors=True
    ...  AND  Set Test Variable  ${actDefaultFaultSnapTriggers_changed}  ${True}
    ...  AND  Log  Parameter actDefaultFaultSnapTriggers changed from true to false  console=${True}

Turn OFF MSM
    [Documentation]
    ...  This keyword turns off MSM from PDU
    ${primary_smod_obj}=  Query Infomodel  get object //SMOD_R-* is [activeRole="Primary"]
    ${INTERFACE_PRIMARY_MODULE}=  Set Variable  SMOD_${primary_smod_obj.serialNumber}
    Set Test Variable  ${INTERFACE_PRIMARY_MODULE}
    pdu.Pdu BTS Interface Off  ${INTERFACE_PRIMARY_MODULE}
    Set Test Variable  ${MSM_OFF}  ${True}
    Log  \nPrimary system module powered off  console=${True}

Turn ON MSM and wait for OnAir
    [Documentation]
    ...  This keyword turns on MSM from PDU. It also checks if bts will synchronize succesfully and reach OnAir.
    pdu.Pdu BTS Interface On  ${INTERFACE_PRIMARY_MODULE}
    Set Test Variable  ${MSM_OFF}  ${False}
    Log  \nPrimary system module powered on  console=${True}
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}m  1m  pm_logs_general.Check All Modules And All Cells Working States
    Log  \nBTS is back onAir  console=${True}

Check ping on ESM
    [Documentation]
    ...  This keyword checks if ESM is pingable.
    log  Waiting for ping on ESM  console=${true}
    ${VM_MSM_PASSWORD}  ${VM_ESM_PASSWORD}  ssh_utils.Get VM passwords
    Set Test Variable  ${VM_ESM_PASSWORD}
    ${VME_ping_connection}=  ssh.Connect_To  hostname=${PC_IP2}  username=${VM_username}  password=${VM_ESM_PASSWORD}
    ${ping_output}=  ssh.Execute  command=ping -c 1 -W 10 ${esm_ip}  connection=${VME_ping_connection}
    Should contain  ${ping_output}  1 packets transmitted, 1 received

Setup Admin on ESM
    [Documentation]
    ...  This keyword creates Admin connection to ESM.
    ${ESM_Admin_connection}=  coam.Setup_Admin  bts_host=${esm_ip}  remote_host=${PC_IP2}  remote_host_username=${VM_username}
    ...  remote_host_password=${VM_ESM_PASSWORD}  alias=ESM
    Set Test Variable  ${ESM_Admin_connection}

Collect Snapshot from ESM
    [Documentation]
    ...  This keyword collects snapshot from ESM. If first attempt to collect fails, snapshot collection is repeated,
    ...  due to Note 1 in OAM_REQ_TEST_219. Max attemps=2

    Log  \nCollect Snapshot from ESM  console=${True}
    @{time}=  Get Time  year month day hour min
    FOR  ${i}  IN RANGE  2
      ${snapshot_status}=  Run Keyword And Return Status
      ...  coam.Collect_Snapshot  ${BTS Files}/ESM_snapshot_${time[0]}_${time[1]}_${time[2]}_${time[3]}_${time[4]}.zip
      ...  connection=${ESM_Admin_connection}  timeout=${SNAPSHOT_TIMEOUT}
      Run Keyword If  ${snapshot_status}  Run Keywords
      ...  Log  Collecting snapshot succeeded  console=${True}  AND  Exit For Loop
      ...  ELSE  log  \nAttempt numer: ${i} to collect Snapshot from ESM has failed. Only two attemps are allowed by OAM_REQ_TEST_219.
      ...  console=${True}
    END
    Run Keyword If  '${snapshot_status}'=='${False}'  verdicts.Set Test Failed  Collecting snapshot from ESM has failed  ${True}

Get Current Timestamp
    [Documentation]
    ...  This keyword gets current date in UTC time zone and specific format needed to compare with timestamps of log prints.
    ${timestamp}=  Get Current Date  time_zone=UTC  result_format=%Y-%m-%dT%H:%M:%S.%fZ
    [Return]  ${timestamp}

TC Setup
    Common Test Setup

Custom Test Teardown
    Run Keyword If  ${MSM_OFF}
    ...  Turn ON MSM and wait for OnAir
    Run Keyword If  ${actDefaultFaultSnapTriggers_changed}
    ...  coam.Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1  parameter=actDefaultFaultSnapTriggers
    ...  operation=update  value=true  skip_parameter_relation_errors=True

TC Teardown
    Run Keywords
    ...  interface.Common step trigger
    ...  AND  Custom Test Teardown
    ...  AND  Common Test Teardown
