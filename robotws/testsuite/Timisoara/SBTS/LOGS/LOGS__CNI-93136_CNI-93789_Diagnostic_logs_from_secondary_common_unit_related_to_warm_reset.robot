*** Settings ***
Documentation  Test Case CNI-93136_CNI-93789_Diagnostic_logs_from_secondary_common_unit_related_to_warm_reset
Library    OperatingSystem
Library    String
Library    taf.ul.verify_snapshot   WITH NAME  snapshot
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Resource    ../resources/unpacking.robot
Resource    ../resources/verdicts.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/ssh_utils.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot


*** Variables ***
${SNAPSHOT_TIMEOUT}       600
${SSHusername}            toor4nsn
${SSHpassword}            oZPS0POrRieRtu
${dir_path_esm}           /ffs/run/logs/lfs/reset
${pattern}                ^[a-zA-Z0-9-]+\.tar$
@{mandatory_files_ASIL}   linux_logs.tar  fct_tmp.tar  log_collection_status.log  2230_basic_logs.tar  2330_basic_logs.tar
@{mandatory_files_ASIB}   linux_logs.tar  fct_tmp.tar  log_collection_status.log
...    riomemfs-logdump-2351-dump.tar  riomemfs-logdump-2361-dump.tar  riomemfs-logdump-2231-dump.tar  riomemfs-logdump-2431-dump.tar
...    riomemfs-logdump-2241-dump.tar  riomemfs-logdump-2441-dump.tar  riomemfs-logdump-2251-dump.tar  riomemfs-logdump-2451-dump.tar
...    riomemfs-logdump-2261-dump.tar  riomemfs-logdump-2461-dump.tar  riomemfs-logdump-2331-dump.tar  riomemfs-logdump-2341-dump.tar
${ESM_connection}
${MSM_connection}

*** Keywords ***
TC__LOGS__CNI-93136_CNI-93789_Diagnostic_logs_from_secondary_common_unit_related_to_warm_reset
    [Documentation]
    ...    [CASE LINK]:
    ...    https://jiradc.ext.net.nokia.com/browse/TAT-25487
    ...    ******************
    ...    Basic information
    ...    ******************
    ...    Test case created to verify if snapshot collected from dual core, after breaking connection to secondary core
    ...    and awarm reset,
    ...    contains logs from secondary core.
    ...    Test has 2 scenarios - for SMOD productName=ASIL and ASIB.
    ...    * ASIL scenario *
    ...    linux_logs.tar, fct_tmp.tar, log_collection_status.log, 2230_basic_logs.xz, 2330_basic_logs.xz
    ...    * ASIB scenario *
    ...    linux_logs.tar, fct_tmp.tar, log_collection_status.log, riomemfs-logdump-2351-dump.tar, riomemfs-logdump-2361-dump.tar,
    ...    riomemfs-logdump-2231-dump.tar, riomemfs-logdump-2431-dump.tar, riomemfs-logdump-2241-dump.tar, riomemfs-logdump-2441-dump.tar,
    ...    riomemfs-logdump-2251-dump.tar, riomemfs-logdump-2451-dump.tar, riomemfs-logdump-2261-dump.tar, riomemfs-logdump-2461-dump.tar,
    ...    riomemfs-logdump-2331-dump.tar,riomemfs-logdump-2341-dump.tar
    ...    (amount of those log files depends on how many BBMODs productName=ASIA are on secondary core side)
    ...    *******************
    ...    History of changes
    ...    *******************
    ...    - 24.05.2023 - Initial TC creation
    ...    - 30.06.2023 - Updates according to review comments
    ...    *******************
    ...    Test case flowchart
    ...    https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/SBTS/
    ...    LOGS__CNI-93136_CNI-93789_Diagnostic_logs_from_secondary_common_unit_related_to_warm_reset.png
    ...    *******************

    Set Tags    CA-LOGS    OWNER-mateusz.majkusiak@nokia.com    AUTHOR-mateusz.majkusiak@nokia.com    MAINTAINER-mateusz.majkusiak@nokia.com
    ...    GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CRT    SW-SBTS23R4    FEATURE-CNI93136    FEATURE-CNI93789

    Step 0: Preconditions
    Step 1: Break connection between MSM and ESM and check if fault 4352 is raised
    Step 2: Check if warm reset path is created on extention and check files presence under this path
    Step 3: Collect Snapshot
    Step 4: Check If Files From ESM Are Present In Snapshot

Step 0: Preconditions
    [Documentation]
    ...    In this step parameter actDefaultFaultSnapTriggers is set to false, to do not trigger snapshot on fault.
    ...    Also parameter actSecCoreBackplaneReset is set to enableWarmOnly. SMOD variant on ESM will be checked as well during this step.
    [Arguments]    ${cmd}=ddal -s ddal_boot_set_reset_loop_count 0
    Log    Step 0: Preconditions  console=${True}
    ${bts_connection}=    coam.connect_to
    ${bts_id}    bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}
    ${TRBLCADM_CONF}=
    ...    Query Infomodel  query=get object /MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-${BTS_ID}/MNL_A-*/MNLENT_A-*/TRBLCADM_A-*
    Set Test Variable    ${actDefaultFaultSnapTriggers}    ${TRBLCADM_CONF.actDefaultFaultSnapTriggers}
    ${FEATCADM_CONF}=
    ...    Query Infomodel  query=get object /MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-${BTS_ID}/MNL_A-*/MNLENT_A-*/FEATCADM_A-*
    Set Test Variable    ${actSecCoreBackplaneReset}    ${FEATCADM_CONF.actSecCoreBackplaneReset}
    Run Keyword If    '${actDefaultFaultSnapTriggers}' == '${True}'
    ...    Run Keywords
    ...    coam.Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    parameter=actDefaultFaultSnapTriggers  operation=update  value=false  skip_parameter_relation_errors=True
    ...    AND  Log    Parameter actDefaultFaultSnapTriggers changed from true to false  console=true
    Run Keyword If    '${actSecCoreBackplaneReset}' == 'enableAll' or '${actSecCoreBackplaneReset}' == 'disableAll'
    ...    Run Keywords
    ...    coam.Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    parameter=actSecCoreBackplaneReset  operation=update  value=enableWarmOnly  skip_parameter_relation_errors=True
    ...    AND  Log    Parameter actSecCoreBackplaneReset changed from enableAll or disableAll to enableWarmOnly  console=${True}
    Log    Changing value of ddal -s ddal_boot_get_reset_loop_count to 0  console=${True}
    ${VM_MSM_PASSWORD}   ${VM_ESM_PASSWORD}    ssh_utils.Get VM passwords
    Set Test Variable    ${VM_ESM_PASSWORD}
    Set Test Variable    ${VM_MSM_PASSWORD}
    Establish SSH Connection To ESM BTS
    ssh.Execute    command=${cmd}  connection=${ESM_connection}
    ssh.Disconnect    ${ESM_connection}
    ${SMOD_variant}=    pm_logs_general.Get SMOD variant
    Set Test Variable    ${SMOD_variant}

Step 1: Break connection between MSM and ESM and check if fault 4352 is raised
    [Documentation]
    ...    In this step conection between MSM and ESM is broken to trigger FID:4352 and warm reset on ESM as a recovery action.
    Run Keyword If    "${SMOD_variant[0]}" == "ASIL"  Run Keywords
    ...    Log    MSM SMOD is recognized as ASIL, continue part for ASIL
    ...    AND    Break connection between cores for ${SMOD_variant[0]} scenario
    ...    ELSE   Run Keywords
    ...    Log    MSM SMOD is recognized as ASIB, continue part for ASIB
    ...    AND    Get BBMODs From ESM Using IM And Count riomemfs-logdump Files
    ...    AND    Break connection between cores for ${SMOD_variant[0]} scenario

Step 2: Check if warm reset path is created on extention and check files presence under this path
    [Documentation]
    ...    This step waits until BTS status will be onAir without unexpected alarms and checks
    ...    if path: /ffs/run/logs/lfs/reset is created on ESM and proper files are added into that directory.
    [Arguments]    ${files_from_path}=${None}
    Log    Step 2: Check if warm reset path is created on extention and check files under this path  console=${True}
    ${file_list_command}  Set Variable  ls /ffs/run/logs/lfs/reset
    Wait Until Keyword Succeeds    20m  30s  Check All Modules And All Cells Working States
    Wait Until Keyword Succeeds    15min    30s    coam.Assert alarm inactive    faultId=6327, severity=Major
    Wait Until Keyword Succeeds    1min    30s    coam.Assert alarm inactive    faultId=7300, severity=Major
    Wait Until Keyword Succeeds    1min    30s    coam.Assert alarm inactive    faultId=7319, severity=Major
    Check Unexpected Alarms  skip_fault=61524,61649,4654,4655,61652,4681,4592,6450
    Establish SSH Connection To ESM BTS
    ${files_from_path}=    ssh.Execute  command=${file_list_command}  connection=${ESM_connection}
    ssh.Disconnect    ${ESM_connection}
    Set Test Variable    ${files_from_path}
    @{list_files_from_path}=    Split String  ${files_from_path}
    Set Test Variable    @{list_files_from_path}
    Run Keyword If    "${SMOD_variant[0]}" == "ASIL"  Run Keywords
    ...    Log    Check mandatory files for ASIL
    ...    AND    List Should Contain Sub List  ${list_files_from_path}  ${mandatory_files_ASIL}
    ...    ELSE   Run Keywords    Log    Check mandatory files for ASIB
    ...    AND    Check And Count riomemfs Files In Path /ffs/run/logs/lfs/reset
    ...    AND    List Should Contain Sub List  ${list_files_from_path}  ${mandatory_files_ASIB}
    Log    Path ${dir_path_esm} exists and contain files: ${list_files_from_path}  console=${True}

    [Return]    @{list_files_from_path}

Step 3: Collect Snapshot
    [Documentation]
    ...    This step triggers Snapshot file collection and checks if unexpected alarms was raised during collection
    Log    Step 3: Collect Snapshot    console=${True}
    @{time}=    Get Time  year month day hour min
    Log    Snapshot is preparing and collecting  console=${True}
    ${snapshot_status}    Run Keyword And Return Status
    ...    coam.Collect Snapshot  ${BTS Files}/snapshot_${time[0]}_${time[1]}_${time[2]}_${time[3]}_${time[4]}.zip  timeout=${SNAPSHOT_TIMEOUT}
    Check Unexpected Alarms    skip_fault=61524,61649,4654,4655,61652,4681,4592,6450
    Run Keyword If    ${snapshot_status}
    ...    Collecting Snapshot Succeeded  ${time}
    ...    ELSE  verdicts.Set Test Failed  TC failed - Collecting snapshot using admin has failed.  ${True}

Step 4: Check If Files From ESM Are Present In Snapshot
    [Documentation]
    ...    This step looks for number of part which contain BTS${BTS_ID}_2011_linux_logs with files from ESM /ffs/run/logs/lfs/reset path.
    ...    After that checks if the Snapshot has the correct files content
    [Arguments]    ${snapshot_files_list_command}=ls ${BTS_Files}/ex/ex2/ex3/ffs/run/logs/lfs/reset
    Log    Step 4: Check If Files From ESM Are Present In Snapshot  console=${True}
    ${zip_part}    ${linux_logs_name_with_bracket}  Linux Logs For ESM Check
    ${zip_part_no2}    Get Substring  ${zip_part}  19  21
    ${zip_part_number}    Fetch From Left  ${zip_part_no2}  .
    ${linux_logs_name}    Convert To String  ${linux_logs_name_with_bracket[0]}
    ${SNAPSHOT_LOCATION}    Set Variable  ${BTS_Files}
    unpacking.Unpack Archive Content To Directory  ${path_to_snapshot}  ${SNAPSHOT_LOCATION}/ex
    unpacking.Unpack Archive Content To Directory  ${SNAPSHOT_LOCATION}/ex/BTS${BTS_ID}_2011_part_${zip_part_number}.zip  ${SNAPSHOT_LOCATION}/ex/ex2
    unpacking.Unpack Archive Content To Directory  ${SNAPSHOT_LOCATION}/ex/ex2/${linux_logs_name}  ${SNAPSHOT_LOCATION}/ex/ex2/ex3
    ${linux_logs_name_without_gz}    Fetch From Left  ${linux_logs_name}  .
    ${unpacked_linux_logs_files}    Set Variable  ${SNAPSHOT_LOCATION}/ex/ex2/ex3/${linux_logs_name_without_gz}
    ${VMM_connection}=    ssh.Connect To  hostname=${PC_IP1}  username=${VM_username}  password=${VM_MSM_PASSWORD}
    ${snapshot_files_from_path}=    ssh.Execute  ${snapshot_files_list_command}  connection=${VMM_connection}
    @{list_files_from_snapshot}=    Split String  ${snapshot_files_from_path}
    Set Test Variable    @{list_files_from_snapshot}
    Log    Snapshot contain files: ${list_files_from_snapshot}  console=${True}
    Run Keyword If   '${SMOD_variant[0]}'=='ASIB'
    ...    Count riomemfs-logdump Logs From ABIAs on ESM Side And Compare Amounts On Both Snapshot And ESM Path: ${dir_path_esm}
    ...    ELSE    Run Keywords
    ...    Log    Check if file lists from snapshot and the patrh: ${dir_path_esm} are equal  console=${True}
    ...    AND    Lists Should Be Equal  ${list_files_from_path}  ${list_files_from_snapshot}

Establish SSH Connection To ESM BTS
    [Documentation]
    ...    This KW establishes SSH connection to secondary core SMOD
    ${VME_connection}=    ssh.Connect To  hostname=${PC_IP2}  username=${VM_username}  password=${VM_ESM_PASSWORD}
    ${ESM_connection}=    ssh.Connect To  hostname=${esm_ip}  username=${SSHusername}  password=${SSHpassword}  proxy=${VME_connection}
    Set Test Variable    ${ESM_connection}

Establish SSH Connection To MSM BTS
    [Documentation]
    ...    This KW establishes SSH connection to primary core SMOD
    ${VMM_connection}=    ssh.Connect To  hostname=${PC_IP1}  username=${VM_username}  password=${VM_MSM_PASSWORD}
    ${MSM_connection}=    ssh.Connect To  hostname=${msm_ip}  username=${SSHusername}  password=${SSHpassword}  proxy=${VMM_connection}
    Set Test Variable    ${MSM_connection}

Get BBMODs From ESM Using IM And Count riomemfs-logdump Files
    [Documentation]
    ...    This KW takes amount of BBMODs from secondary core using IM and counts amount of riomemfs-logdump files to be collected
    ${BBMOD_list_from_ESM}    Create List
    FOR  ${id}  IN RANGE  1  4
        ${BBMOD_from_ESM}=    Query Infomodel  query=get object /MRBTS-1/RAT-1/BTS_L-4/EQM_L-1/CABINET_L-1/BBMOD_L-${id}
        Run Keyword If    '${BBMOD_from_ESM["productName"][0:4]}'=='ABIA'  Append To List  ${BBMOD_list_from_ESM}
        ...    ${BBMOD_from_ESM["productName"][0:4]}
    END
    ${counted_BBMODs}    Count Values In List  ${BBMOD_list_from_ESM}  value=ABIA
    ${counted_amount_riomemfs_logs}    Evaluate  ${counted_BBMODs}*4
    Set Test Variable    ${counted_amount_riomemfs_logs}

    [Return]    ${counted_amount_riomemfs_logs}

Break connection between cores for ASIB scenario
    [Arguments]
    ...    ${cmd}=watch -n0 "ddal -s ddal_rio_switch_port_disable 0x1000 12"
    ...    ${cmd2}=kill -9 $( ps -ef |grep 'watch -n0 ddal -s ddal_rio_switch_port_disable 0x1000 12' |sort -k 5 -n |head -n 1 |awk '{print $2}' )
    ...    ${faultName_4352}=BTS secondary core warm reset via subrack backplane autonomous reset as recovery action
    Log    Step 1: Break Connection Between Master and Extension and check if fault 4352 is raised  console=${True}
    Log    Connection between MSM and ESM is broken, wait for first 4352 FID  console=${True}
    Establish SSH Connection To MSM BTS
    ssh.Send Command    command=${cmd}  connection=${MSM_connection}  get_pty=${True}
    Wait Until Keyword Succeeds    2x  60s  Check If Fault Is In Active Raw Alarm  4352  EFaultId_NoConnectionToBtsExtensionUnitAl
    Log    First FID 4352 is presented  console=${True}
    Wait Until Keyword Succeeds    15m  500ms  Check If Expected Alarm Occurred  ${faultName_4352}
    Log    Second FID(Warning) 4352 is presented  console=${True}
    Log    Connection between MSM and ESM is recovered, wait until BTS will be onAir state  console=${True}
    Log    Kill the process blocked connection between ESM and MSM  console=${True}
    ssh.Send Command    command=${cmd2}  connection=${MSM_connection}  get_pty=${True}
    ssh.Disconnect    ${MSM_connection}

Break connection between cores for ASIL scenario
    [Arguments]
    ...    ${cmd}=ip -6 route add fd5f:4268:2387:a881:40:43ff:fe80:1000/128 dev lo
    ...    ${cmd2}=ip -6 route del fd5f:4268:2387:a881:40:43ff:fe80:1000/128
    ...    ${faultName_4352}=BTS secondary core warm reset via subrack backplane autonomous reset as recovery action
    Log    Step 1: Break Connection Between Master and Extension and check if fault 4352 is raised  console=${True}
    Log    Connection between MSM and ESM is broken, wait for first 4352 FID  console=${True}
    Set Test Variable    ${VM_MSM_PASSWORD}
    Establish SSH connection to MSM BTS
    ssh.Execute    command=${cmd}  connection=${MSM_connection}
    Wait Until Keyword Succeeds    7x  30s  Check If Fault Is In Active Raw Alarm  4352  EFaultId_NoConnectionToBtsExtensionUnitAl
    Log    First FID 4352 is presented  console=${True}
    Wait Until Keyword Succeeds    15m  1s  Check If Expected Alarm Occurred  ${faultName_4352}
    Log    Second FID(Warning) 4352 is presented  console=${True}
    Log    Connection between MSM and ESM is recovered, wait until BTS will be onAir state  console=${True}
    ssh.Execute    command=${cmd2}  connection=${MSM_connection}
    ssh.Disconnect  ${MSM_connection}

Check And Count riomemfs Files In Path /ffs/run/logs/lfs/reset
    [Documentation]
    ...    This KW check and count riomemfs files in path: ${dir_path_esm}
    ${riomemfs_files_from_path}    Create List
    FOR  ${riomemfs_logs}  IN  @{list_files_from_path}
        ${match_status}    Run Keyword And Return Status  Should Match Regexp  ${riomemfs_logs}  ${pattern}
        Run Keyword If    ${match_status}  Append To List  ${riomemfs_files_from_path}  ${riomemfs_logs}
        ...    ELSE    Log    File not matches the pattern, continue checking   console=${True}
    END
    ${counted_riomemfs_from_path}    Get Match Count  ${riomemfs_files_from_path}  regexp=${pattern}
    Set Test Variable    ${counted_riomemfs_from_path}

Collecting Snapshot Succeeded
    [Documentation]
    ...    This KW sets variable to create a snapshot name
    [Arguments]    ${time}
    Log    Collecting snapshot via admin succeeded  console=${True}
    Set Test Variable    ${path_to_snapshot}  ${BTS Files}/snapshot_${time[0]}_${time[1]}_${time[2]}_${time[3]}_${time[4]}.zip

Check If Fault Is In Active Raw Alarm
    [Documentation]
    ...    This KW checks if FID:4352 is in active raw alarm history file
    [Arguments]    ${fault_id}  ${EFaultId}
    ${RawAlarms}=    coam.Get Raw Alarm History File
    ${RawAlamrsActive}=    Fetch From Left  ${RawAlarms}  Inactive faults
    Should contain    ${RawAlamrsActive}  (${fault_id})
    Should contain    ${RawAlamrsActive}  ${EFaultId}

Check If Expected Alarm Occurred
    [Documentation]
    ...    This KW downloads list of active alarms and checks if expected fault is on the list.
    [Arguments]    ${expected_fault_name}
    ${active_alarms}    coam.Get Active Alarms  severity=warning
    ${active_fault_names}    Get Fault Names From Active Alarms  ${active_alarms}
    Should Contain    ${active_fault_names}  ${expected_fault_name}

Get Fault Names From Active Alarms
    [Documentation]
    ...    This KW creates a list of fault names from list of active alarms.
    [Arguments]    ${active_alarms}
    ${fault_names}    Create List
    FOR  ${alarm}  IN  @{active_alarms}
        ${fault_name}    Get From Dictionary  ${alarm}  faultName
        Append To list    ${fault_names}  ${fault_name}
    END

    [Return]    ${fault_names}

Linux Logs For ESM Check
    [Documentation]
    ...    This KW checks if snapshot contain BTS${BTS_ID}_2011_linux_logs.tar file
    [Arguments]    ${linux_log_name}=BTS${BTS_ID}_2011_linux_logs.tar
    ${bts_id}    bts_states.Get BTS ID
    Set Test Variable      ${BTS_ID}  ${bts_id}
    ${data_snapshot}  snapshot.Get Data From Snapshot  ${path_to_snapshot}
    ${part_no}    Set Variable  ${False}
    ${temp}    Create List
    FOR  ${log_file}  IN  @{data_snapshot.keys()}
        Append to List    ${temp}  ${log_file}
        ${linux_logs_zip_file}    Get Matches  ${temp}  ${linux_log_name}
        Remove From List    ${temp}  0
        ${linux_logs_zip_file_len}    Get Length  ${linux_logs_zip_file}
        Exit For Loop If    ${linux_logs_zip_file_len}>0
    END

    [Return]    ${data_snapshot["${log_file}"][0]}    ${linux_logs_zip_file}

Count riomemfs-logdump Logs From ABIAs on ESM Side And Compare Amounts On Both Snapshot And ESM Path: ${dir_path_esm}
    [Documentation]
    ...    This KW compares if snapshot and ${dir_path_esm} path from secondary core have the same amount of riomemfs-logdump files
    ${ABIA_logs_list}    Create List
    FOR  ${ABIA_logs}  IN  @{list_files_from_snapshot}
        ${match_status}    Run Keyword And Return Status  Should Match Regexp  ${ABIA_logs}  ${pattern}
        Run Keyword If    ${match_status}  Append To List  ${ABIA_logs_list}  ${ABIA_logs}
    END
    ${counted_ABIA_logs}    Get Match Count  ${ABIA_logs_list}  regexp=${pattern}
    ${status}    Evaluate  '${counted_amount_riomemfs_logs}'=='${counted_ABIA_logs}'=='${counted_riomemfs_from_path}'
    Should Be True    ${status}
    Log    Check if file lists from snapshot and the path: ${dir_path_esm} are equal  console=${True}
    Lists Should Be Equal  ${list_files_from_path}  ${list_files_from_snapshot}

Custom Test Teardown
    Log    Custom Test Teardown  console=${True}
    Log    Restore parameters to value before test execution  console=${True}
    Run Keywords
    ...    coam.Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    parameter=actDefaultFaultSnapTriggers  operation=update  value=${actDefaultFaultSnapTriggers}
    ...    skip_parameter_relation_errors=True
    ...    AND    coam.Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    parameter=actSecCoreBackplaneReset  operation=update  value=${actSecCoreBackplaneReset}
    ...    skip_parameter_relation_errors=True

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Custom Test Teardown
    ...    AND    Common Test Teardown
    ...    AND    ssh.Reset Cache
