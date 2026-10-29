*** Settings ***
Documentation    Resources for CB012390 TC
Resource    ../resources/bts_states.robot
Resource    ../resources/diagnostic_check_new.robot
Resource    ../resources/infomodel.robot
Resource    ../resources/ping_utils.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     taf.ul.verify_snapshot   WITH NAME  snapshot
Library     ../resources/connection.py
Library     ../resources/bts_alarms.py
Library     ute_syslog

*** Variables ***
${load_t1}    	   		        T1
${load_t2}    	   		        T2
${jenkins_url}                  ${BUILD_PATH}
${CONFIG_FILES_REMOVED}         ${False}
${SW_UPDATE}                    ${False}

*** Keywords ***
TC__LOGS__CB010239-A_DC_triggered_by_uncommissioned_state_of_BTS_for_CP1_and_CP2_Config_file_presence_on_both_partitions

    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25766
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Purpose of this test case is to verify automatic Diagnostic Check with check point Id:
    ...  - 1 Configuration file presence on the active partition
    ...  and check point Id:2 Configuration file presence on the passive partition.
    ...  In this case missing model_5.ims2 on active and passive partition BTS will cause the alarm.
    ...  After automatic DC is triggered by uncommissioned state of BTS, fault 4681 (EFaultId_SanityCheckErrAl) is raised.
    ...  Fault is visible as minor (NOK situation for CP Id:1), despite of lower severity of alarm in case of NOK state for CP Id:2.
    ...  Content of snapshot and DC report will be checked.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************

    ...  - 16.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25766 - TC first draft created
    ...  - 06.12.2023 - TC released

    ...  *******************

    Set Tags      CA-PM  OWNER-joanna.wolnicka@nokia.com  AUTHOR-iuliia.taupeka@nokia.com  MAINTAINER-iuliia.taupeka@nokia.com
    ...           GROUP_IN_CHARGE-WRO_6_Vrf PHASE-CRT  SW-SBTS24R1  FEATURE-CB010239-A

    Step 0: Preconditions
    Step 1: Delete Configuration File From Passive Partition And Run Diagnostic Check
    Step 2: Delete File model_5_ims2 On Active Partition And Reset Site
    Step 3: Check If Alarm 4681 Is Present
    Step 4: Check Diagnostic Check CP1 And CP2 Results
    Step 5: Collect Snapshot And Find DiagnosticReport


Step 0: Preconditions
    [Documentation]
    ...  In this step diagnostic check is performed to ensure that checkpoint 2 has status OK before test start.
    ...  If CP2 result is NOK, SW is updated to T1/T2 version - to have all necessary configuration files present on passive partition.

    Log   \nStep 0: Preparation   console=${True}
    coam.Get Current SCF File
    ...    ${BTS Files}  SCF.xml  timeout=120   export_type=configuration  parameters_save_variant=actualValues
    Run  mkdir ${BTS Files}/active
    Run  mkdir ${BTS Files}/passive
    ${num_of_BBMODs_online}=  Query Infomodel  get count //BTS_L-1/EQM_L-1/CABINET_L-1/BBMOD_L-* is [stateInfo.availabilityStatus=Online]

    ${inactive_fault_status}  Run keyword and return status  Wait until keyword succeeds  120  10
    ...  coam.Assert Alarm Inactive  parameters=alarmId=7115, faultId=4681, faultName="Diagnostic Check Error"  timeout=120
    Run keyword if  ${inactive_fault_status}
    ...  Log  WebEM: Fault 4681 "Diagnostic Check Error" is inactive on BTS. [OK]  console=${True}
    ...  ELSE  Run Keywords  Log  Fault 4681 is active on BTS. SW will be changed to T1/T2
    ...  AND  Update SW to T1/T2 And Check CP2 Result

Step 1: Delete Configuration File From Passive Partition And Run Diagnostic Check
    [Documentation]
    ...   In this step "model_5.ims2" file is deleted from passive partition of Primary SMOD.
    ...   Diagnostic check is performed and result is verified to see if CP 2 status is NOK.
    ...   Presence of Fault 4681 "Diagnostic Check Error" - severity Minor is checked.

    Log   \nStep 1: Delete Configuration File And Run Diagnostic Check   console=${True}
    Backup And Delete Configuration File From Passive Partition
    diagnostic_check_new.Perform Diagnostic Check
    diagnostic_check_new.Get DC Report And Check CP Result   2   Check point failure
    ${fault_status}  Run keyword and return status  Wait until keyword succeeds  120  10
    ...  coam.Assert Alarm Active  parameters=alarmId=7115, faultId=4681, faultName="Diagnostic Check Error", severity=Minor  timeout=120
    Run keyword if  ${fault_status}
    ...  Log  WebEM: Fault 4681 "Diagnostic Check Error" is active on BTS. [OK]  console=${True}
    ...  ELSE  Set Test Failed  WebEM: Fault 4681 "Diagnostic Check Error" is not active on BTS. [NOK]

Step 2: Delete File model_5_ims2 On Active Partition And Reset Site
    Log  \nStep 2: Delete File model_5_ims2 On Active Partition And Reset Site.  console=${True}
	Log    Checking that model_ims2 file exists on BTS on active partition.    console=${True}
	SSHLibrary.Open Connection    192.168.255.129
    SSHLibrary.Login    toor4nsn    oZPS0POrRieRtu
    ${model_5_presence_active_part}    Run Keyword and Return Status    SSHLibrary.File Should Exist    /ffs/run/config/model_5.ims2
    Run Keyword Unless  ${model_5_presence_active_part}
    ...  verdicts.Set Test Failed  Fail: Check why model_5.ims is missing on BTS active partition, BTS must be commissioned to pass the test.  ${TRUE}

    Log  Copy file model_5.ims 2 to BTS_Files   console=${True}
    SSHLibrary.Get File  /rom/config/model_5.ims2  ${BTS_Files}/active/
    Log  Delete model_5.ims2 file from BTSs active partition.  console=${True}
    SSHLibrary.Execute Command    rm /rom/config/model_5.ims2
    Set Test Variable    ${CONFIG_FILES_REMOVED}    ${True}

## starting syslog
    ute_syslog.Start Syslog   alias=monitoring_syslog   ip=192.168.255.126   log_dir=${BTS_Files}/monitoring_syslog   log_name=monitoring_syslog

## reset
    SSHLibrary.Execute Command    ddal -s ddal_boot_set_reset_loop_count 0    #setting reset loop counter to 0 to avoid SW fallback
    Log    Resetting Site to reach uncommissioned state.  console=${True}
    SSHLibrary.Execute Command    ddal -s ddal_reboot_sm_site_graceful DDAL_REBOOT_SM_SHELF_SIDE_OWN
    SSHLibrary.Close Connection
    Wait Until Keyword Succeeds    3m   5s    Check If Host Is Not Pingable    192.168.255.129
    ping_utils.Wait For Target IP To Be Reachable   192.168.255.129   10
    Sleep    30s
    SSHLibrary.Open Connection    192.168.255.129
    SSHLibrary.Login    toor4nsn    oZPS0POrRieRtu
    ${DC_run_date}    SSHLibrary.Execute Command    date +"%Y-%m-%dT%H:%M:%S"
    Set Test Variable   ${DC_run_date}
    SSHLibrary.Close Connection

    Log   Waiting for diagnostic check to start   console=${True}
    Wait Until Keyword Succeeds   10m   10s   Check Expected Print In Syslog   Start runDiagnosticCheck request
    Log   Scheduled diagnostic check started!   console=${True}
    Log   Waiting for diagnostic check to finish   console=${True}
    Wait Until Keyword Succeeds   860s   10s   Check Expected Print In Syslog   change report status and reset runningOperation
    Log   Diagnostic check finished!   console=${True}
    ute_syslog.Stop Syslog   alias=monitoring_syslog

    Log  Will now verify that proceduralState of the BTS equals NotCommissioned  console=${TRUE}
    Wait Until Keyword Succeeds  1 min  20 sec  Check if BTS proceduralState is NotCommissioned
    Log  Configuration reset has passed.  console=${TRUE}

Step 3: Check If Alarm 4681 Is Present
    [Documentation]
    ...  In this step test verifies that minor fault (4681) of missing model_5.ims2 on active and passive partition is raised on BTS.
    Log  \nStep 3: Check If Alarm 4681 Is Present.    console=${True}

    ${fault_status}  Run keyword and return status  Wait until keyword succeeds  120  10
    ...  coam.Assert Alarm Active  parameters=alarmId=7115, faultId=4681, faultName="Diagnostic Check Error", severity=Minor  timeout=120
    Run keyword if  ${fault_status}
    ...  Log  WebEM: Fault 4681 "Diagnostic Check Error" is active on BTS. [OK]  console=${True}
    ...  ELSE  Set Test Failed  WebEM: Fault 4681 "Diagnostic Check Error" is not active on BTS. [NOK]

Step 4: Check Diagnostic Check CP1 And CP2 Results
    [Documentation]
    ...  In this step CP1 and CP2 results and timestamps are verified.
    Log  \nStep 4: Check Diagnostic Check CP1 And CP2 Results.  console=${True}
    diagnostic_check_new.Get DC Report And Check CP Result   1   Check point failure
    diagnostic_check_new.Get DC Report And Check CP Result   2   Check point failure

Step 5: Collect Snapshot And Find DiagnosticReport
    [Documentation]
    ...  In this step Snapshot is collected. After extraction of DiagnosticReport File CP1 and CP2 status is verified in this file (NOK expected).
    Log    \nStep 5: Collect Snapshot And Find DiagnosticReport    console=${True}
    Collect Snapshot
    ${diagnostic_report_from_snapshot}   Find And Extract DiagnosticReport File   ${path_to_snapshot}
    ${dc_report_content}   OperatingSystem.Get File   ${diagnostic_report_from_snapshot}   encoding_errors=ignore
    ${dc_report_lines}   String.Split To Lines   ${dc_report_content}   start=1

    ${CP_1_line}   Get Lines Containing String   ${dc_report_content}   Configuration file presence on the active partition
    ${CP_1_line}   Convert To String   ${CP_1_line}
    ${CP_1_status}   String.Fetch From Left   ${CP_1_line}   ,
    ${CP_2_line}   Get Lines Containing String   ${dc_report_content}   Configuration file presence on the passive partition
    ${CP_2_line}   Convert To String   ${CP_2_line}
    ${CP_2_status}   String.Fetch From Left   ${CP_2_line}   ,
    Log   Checkpoint 1 has status "${CP_1_status}" in snapshot (expected status: "Check point failure")   console=${True}
    Log   Checkpoint 2 has status "${CP_2_status}" in snapshot (expected status: "Check point failure")   console=${True}
    Should Be Equal As Strings   ${CP_1_status}   Check point failure
    Should Be Equal As Strings   ${CP_2_status}   Check point failure


Collect Snapshot
    [Documentation]
    ...  This keyword collects snapshot (full coverage), monitors collection status and sets path to snapshot as variable.
    Log   \nCollecting Snapshot   console=${True}
    ${timestamp}   Get time
    ${timestamp}   Replace String Using Regexp   ${timestamp}   (${SPACE}|:|-)  _
    Set Test Variable   ${timestamp}
    ${log_status}   Run Keyword And Ignore Error   coam.Collect snapshot   ${BTS_Files}/snapshot_${timestamp}.zip   timeout=1800
    Run Keyword If   '${log_status[0]}'=='FAIL'
    ...    Fail   Collecting snapshot failed
    ...    ELSE
    ...    Log   Full snapshot is successfully collected   console=${True}
    Set Test Variable   ${path_to_snapshot}   ${BTS_Files}/snapshot_${timestamp}.zip

Restore Config Files For Both Partitions
    [Documentation]
    ...  This KW restores model_5.ims2 file on active and passive partition, resets site to reach OnAir status of BTS.
    SSHLibrary.Open Connection    192.168.255.129
    SSHLibrary.Login    toor4nsn    oZPS0POrRieRtu
    Log    Restoring model_5.ims2 on active partition.    console=${True}
    SSHLibrary.Put File           ${BTS_Files}/active/model_5.ims2    /rom/config    mode=0640
    SSHLibrary.Execute Command    chown btssw.btssw /rom/config/model_5.ims2
    SSHLibrary.Execute Command    mount -o rw,remount /ffs/stb
    Log    Restoring model_5.ims2 on passive partition.    console=${True}
    SSHLibrary.Put File           ${BTS_Files}/passive/model_5.ims2    /ffs/stb/config    mode=0640
    SSHLibrary.Execute Command    chown btssw.btssw /ffs/stb/config/model_5.ims2
    SSHLibrary.Execute Command    ddal -s ddal_boot_set_reset_loop_count 0
    Log    Site reset is performed.    console=${True}
    coam.Reset Site  600
    SSHLibrary.Close Connection
    Set Test Variable    ${CONFIG_FILES_REMOVED}    ${False}
    Log    Wait for OnAir status.    console=${True}
    Wait Until Keyword Succeeds   20m   30s   pm_logs_general.Check All Modules And All Cells Working States

Check if BTS proceduralState is NotCommissioned
    ${BTS state}  coam.Get Mrbts State  timeout=600
    Log  BTS proceduralState is: ${BTS state}  console=${TRUE}
    Should be equal  ${BTS state}  NotCommissioned

Update SW to T1/T2 And Check CP2 Result
    [Documentation]
    ...   This keyword prepares T1/T2 build, performs SW update and checks if CP2 has status OK after SW update.
    Set Test Variable   ${destination_dir}   ${BTS Files}/
    Get SW Load And Type
    Log   Prepare different build from passive partition   console=${True}
    Prepare Different Build From Passive Partition
    Log   Update software to ${active_build_T}   console=${True}
    coam.Update Software   ${destination_dir}${active_build_T}   timeout=3600
    Set Test Variable   ${SW_UPDATE}   ${True}
    Log   Waiting For Site Reach OnAir   console=${True}
    ping_utils.Wait For Target IP To Be Reachable   192.168.255.129   10
    Wait Until Keyword Succeeds   20m   30s   pm_logs_general.Check All Modules And All Cells Working States
    Sleep   5 min
    Query Infomodel   none //URI-*/SESSION-*/RUN_FULL_DIAGNOSTIC_CHECK_IND-*/RUN_DIAGNOSTIC_CHECK_RESULT-*   timeout=500
    Query Infomodel   none //URI-*/SESSION-*/DIAGNOSTIC_CHECK_COMPLETION_MONITORING_IND-*/RESULT-*   timeout=500
    diagnostic_check_new.Perform Diagnostic Check
    diagnostic_check_new.Get DC Report And Check CP Result   2   Check point successful

Prepare Different Build From Passive Partition
    [Documentation]
    ...   This KW Prepares different build from passive partition
    ${active_build_T}   Run Keyword If   '${build_type}' != 'T1'   Prepare Build ${destination_dir} ${pre_update_enb_sw['active']} ${load_t1}
    ...   ELSE   Prepare Build ${destination_dir} ${pre_update_enb_sw['active']} ${load_t2}
    Set Test Variable   ${active_build_T}

Get SW Load And Type
    [Documentation]
    ...   This KW Get SW load and Type
    ${pre_update_enb_sw}   Get Active And Passive eNB SW Versions
    ${build_type}   Should Match Regexp   ${pre_update_enb_sw['passive']}   .{2}$
    Set Test Variable   ${pre_update_enb_sw}
    Set Test Variable   ${build_type}

Get Active And Passive eNB SW Versions
    [Documentation]
    ...   This KW Get active and passive eNB sw versions
    ${active_sw}   coam.Get Sw Version
    Log   Active SW - ${active_sw}   console=${True}
    ${passive_sw}   infomodel.Infomodel Get Passive SW Version
    Log   Passive SW - ${passive_sw}   console=${True}
    ${output}   Create Dictionary   active=${active_sw}   passive=${passive_sw}
    [Return]  ${output}

Prepare Build ${destination_dir} ${current_build} ${load_type}
    [Documentation]
    ...   This KW Prepare build T1 or T2
    ${split_build}   Split String        ${current_build}   separator=\_
    ${trunk_flag}   Get From List        ${split_build}   2
    ${version_flag}   Get From List      ${split_build}   0
    ${download_build}   Run Keyword If   '${trunk_flag}'=='9999'   Replace String   ${current_build}   ${version_flag}   SBTS00
    ...   ELSE  Set Variable   ${current_build}
    ${t0_relative_url}   Set Variable    ${download_build}_release_BTSSM_downloadable_A54.zip
    ${t1_relative_url}   Set Variable    ${download_build}_release_BTSSM_downloadable_testpackage_T1_A54.zip
    ${t2_relative_url}   Set Variable    ${download_build}_release_BTSSM_downloadable_testpackage_T2_A54.zip
    ${download_relative_url}   Run Keyword If     '${load_type}'=='T0'     Set Variable    ${t0_relative_url}
                     ...     ELSE IF          '${load_type}'=='T1'   Set Variable   ${t1_relative_url}
                     ...     ELSE IF          '${load_type}'=='T2'   Set Variable   ${t2_relative_url}
                     ...     ELSE            Fail   Unexpected load type
    ${SW}  coam.Get Sw Version
    Log    Active Sw Version: ${SW}  console=${true}
    @{SW_splited}    Split String    ${SW}    _
    ${BRANCH}=    Remove String Using Regexp  ${SW_splited[0]}  SBTS
    Run Keyword If  ${SW_splited[2]}==9999
    ...  Wget to file 	     ${jenkins_url}/SBTS00/${download_build}/${download_relative_url}  ${destination_dir}${/}${download_relative_url}
    ...  ELSE
    ...  Wget to file 	     ${jenkins_url}/SBTS${BRANCH}/${download_build}/${download_relative_url}  ${destination_dir}${/}${download_relative_url}
    [Return]   ${download_relative_url}

Wget to file
# used
	[Arguments]       ${url}              ${destination}
	${status}         ${output}=          Run and return rc and output    wget -O ${destination} ${url}
	Run keyword if    '${status}'!='0'    Log    ${output}
	Should be equal   '${status}'         '0'   msg=wget failed (exit code ${status})

Backup And Delete Configuration File From Passive Partition
    [Documentation]
    ...   This keyword downloads "model_5.ims2" file from passive partition of Primary SMOD to BTS_Files as backup
    ...   and deletes model_5.ims2 from passive partition.

    ssh_utils.Setup SMOD Connection
    ssh.Execute   mount -o rw,remount /ffs/stb
    ssh.Download File   /ffs/stb/config/model_5.ims2   ${BTS_Files}/passive/model_5.ims2
    Log   Deleting model_5.ims2 file from /ffs/stb/config/ from Primary SMOD. Original file is copied to BTS_files/passive.   console=${True}
    ssh.Execute   rm /ffs/stb/config/model_5.ims2
    Set Test Variable   ${CONFIG_FILE_DELETED_PASSIVE}   ${True}
    ssh.Disconnect


Check Expected Print In Syslog
    [Documentation]
    ...   This keyword checks if expected print is present in syslog.
    [Arguments]   ${expected_print}
    ${msg}   ute_syslog.Message Should Exist In Syslog File   regexp=${expected_print}   alias=monitoring_syslog
    [Return]   ${msg}

Create Fault List With SupplAlarmInfo
    [Arguments]    @{faultinfolist}
    ${Alarm_Fault_Info_list}    Create List    faultId=@{faultinfolist}[2]    severity=@{faultinfolist}[3]    faultName=@{faultinfolist}[4]
    ...    supplAlarmInfo=@{faultinfolist}[5]
    Set Test Variable    ${Alarm_Fault_Info_list}
    [Return]    ${Alarm_Fault_Info_list}

Find And Extract DiagnosticReport File
    [Documentation]
    ...  This KW searches for DiagnosticReport File in Snapshot and extracts it for further verification.
    ...  |  Parameters     | Man. |  Description         |
    ...  |  snapshot_path  | Yes  |  path to Snapshot    |
    ...
    ...  *RETURN*
    ...  |  Parameters      |  Description           |
    ...  |  extracted_file  |  Path to extracted DiagnosticReport File |

    [Arguments]   ${snapshot_path}
    Log   Find and extract DiagnosticReport file   console=${True}
    ${snapshot_dict}   snapshot.Get Data From Snapshot   ${snapshot_path}
    FOR   ${key}   IN   @{snapshot_dict.keys()}
          ${MATCHES}   Get Regexp Matches   ${snapshot_dict["${key}"][0]}   .*1011_DiagnosticReport.csv.xz
          Run Keyword If   ${MATCHES}   Run Keywords
          ...   Log   DiagnosticReport file: ${MATCHES[0]} found   console=${True}
          ...   AND   Set Test Variable   ${MATCHES}   ${MATCHES}
          ...   AND   Exit For Loop
    END
    ${extracted_file}   Extract Log File   ${snapshot_path}   ${MATCHES[0]}
    Run Keyword Unless   ${MATCHES}   Fail   DiagnosticReport file not found
    [Return]   ${extracted_file}

Extract Log File
    [Documentation]
    ...  Keyword used to extract specified file from snapshot.
    ...  |  Parameters               | Man. |  Description         |
    ...  |  snapshot_path            | Yes  |  path to Snapshot    |
    ...  |  path_to_extracting_file  | Yes  |  path to Snapshot    |
    ...  *RETURN*
    ...  |  Parameters           |  Description           |
    ...  |  extracted_file_path  |  Path to extracted DiagnosticReport File |

    [Arguments]   ${snapshot_path}   ${path_to_extracting_file}
    Log   Start extracting DiagnosticReport file for further analysis   console=${True}
    unpacking.Unpack Archive Content To Directory   ${snapshot_path}   ${BTS_Files}/snapshot_${timestamp}
    ${zip_from_extract}   Get Regexp Matches   ${path_to_extracting_file}   [\\w.]+
    ${log_to_extract}   Replace String Using Regexp   ${zip_from_extract[0]}   (.zip)   ${EMPTY}
    unpacking.Unpack Archive Content To Directory
    ...   ${BTS_Files}/snapshot_${timestamp}/${zip_from_extract[0]}   ${BTS_Files}/snapshot_${timestamp}${log_to_extract}
    unpacking.Unpack Archive Content To Directory
    ...   ${BTS_Files}/snapshot_${timestamp}${log_to_extract}/${zip_from_extract[1]}   ${BTS_Files}/DiagnosticReport_${timestamp}
    ${unzipped_log_name}   Replace String Using Regexp   ${zip_from_extract[1]}   (.xz)   ${EMPTY}
    ${extracted_file_path}   Set Variable   ${BTS_Files}/DiagnosticReport_${timestamp}/${unzipped_log_name}
    Run   rm ${snapshot_path}
    Run   rm -r ${BTS_Files}/snapshot_${timestamp}
    [Return]   ${extracted_file_path}

Custom Test Teardown
    Log  \nCustom Test Teardown  console=${True}
    Run Keyword If   ${CONFIG_FILES_REMOVED}    Run Keywords
    ...  ping_utils.Wait For Target IP To Be Reachable   192.168.255.129   10
    ...  AND    Sleep    30s
    ...  AND    Restore Config Files For Both Partitions
    Run Keyword If  ${SW_UPDATE}  Run Keywords
    ...  Log    Rollback Software    console=${True}
    ...  AND    coam.Rollback Software
    ...  AND    Set Test Variable   ${SW_UPDATE}  ${False}
    ...  AND    Sleep    300
    ...  AND    Wait Until Keyword Succeeds   20m   30s   pm_logs_general.Check All Modules And All Cells Working States
    ...  AND    Run  rm ${BTS Files}/${active_build_T}



TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Custom Test Teardown
    ...    AND    Common Test Teardown
