*** Settings ***
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     taf.transport.ssh  WITH NAME  ssh
Library     taf.ul.verify_snapshot   WITH NAME  snapshot
Library     DateTime
Resource    ../resources/unpacking.robot
Resource    ../resources/ssh_utils.robot
Resource    ../resources/ping_utils.robot
Resource    ../resources/diagnostic_check.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${CONFIG_FILE_DELETED}   ${False}
${SNAPSHOT_EXTRACTED}    ${False}
${SW_UPDATE}             ${False}
${load_t1}               T1
${load_t2}               T2
${jenkins_url}           ${BUILD_PATH}

*** Keywords ***
TC__LOGS__CB010239-A_DC_from_WebEM_Remote_Tool_command_CP2_Configuration_file_presence_on_the_pasive_partition
    [Documentation]
    ...  [CASE LINK]:
    ...  https://jiradc.ext.net.nokia.com/browse/TAT-25768
    ...  *****************
    ...  Author: Damian Kotula
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  This test case verifies Diagnostic Check from WebEM CLI with check point Id:2 Configuration file presence on the passive partition.
    ...  In this case lack of file model_5.ims2 on passive partition BTS will cause the alarm. After DC is triggered by user in WebEM Remote tool,
    ...  fault 4681 (EFaultId_SanityCheckErrAl) is raised on BTS. Fault is visible as transient (30 sec) and then is cleared.
    ...  Afterwards file model_5.ims2 is restored on passive partition and second DC (also from WebEM CLI) will return OK results for CP2.
    ...  Content of snapshot and DC report will be checked.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2023-10-05 - TC created. TAT-25768
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/SBTS/
    ...  LOGS__CB010239-A_DC_from_WebEM_Remote_Tool_command_CP2_Configuration_file_presence_on_the_pasive_partition.png
    ...  *******************

    Set Tags    CA-LOGS    AUTHOR-damian.kotula@nokia.com    MAINTAINER-damian.kotula@nokia.com    GROUP_IN_CHARGE-WRO_6_Vrf
    ...   PHASE-CRT   PHASE-CRT SW-SBTS23R4

    Step 0: Preparation
    Step 1: Delete Configuration File And Run Diagnostic Check
    Step 2: Verify Checkpoint 2 Result In Snapshot
    Step 3: Restore Configuration File And Run Diagnostic Check


Step 0: Preparation
    [Documentation]
    ...   In this step diagnostic check is performed to ensure that checkpoint 2 has status OK before test start.
    ...   If CP2 result is NOK, SW is updated to T1/T2 version - to have all necessary configuration files present on passive partition.

    Log   \nStep 0: Preparation   console=${True}
    Log   Checking configuration file presence on passive partition before test start. If result is NOK, SW will be updated.   console=${True}
    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}
    Query Infomodel   none //URI-*/SESSION-*/RUN_FULL_DIAGNOSTIC_CHECK_IND-*/RUN_DIAGNOSTIC_CHECK_RESULT-*   timeout=860
    Query Infomodel   none //URI-*/SESSION-*/DIAGNOSTIC_CHECK_COMPLETION_MONITORING_IND-*/RESULT-*   timeout=860
    diagnostic_check.Perform Diagnostic Check
    ${CP2_status_before_test}   Run Keyword And Return Status   diagnostic_check.Get DC Report And Check CP Result   2   OK
    Run Keyword Unless   ${CP2_status_before_test}   Update SW to T1/T2 And Check CP2 Result


Step 1: Delete Configuration File And Run Diagnostic Check
    [Documentation]
    ...   In this step "model_5.ims2" file is deleted from passive partition of Primary SMOD.
    ...   Diagnostic check is performed and result is verified to see if CP 2 status is NOK.
    ...   Presence of Fault 4681 "Diagnostic Check Error" - severity Minor is checked.

    Log   \nStep 1: Delete Configuration File And Run Diagnostic Check   console=${True}
    Backup And Delete Configuration File From Passive Partition
    diagnostic_check.Perform Diagnostic Check
    diagnostic_check.Get DC Report And Check CP Result   2   NOK
    diagnostic_check.Check Alarm 4681   Active   Minor

Step 2: Verify Checkpoint 2 Result In Snapshot
    [Documentation]
    ...   In this step snapshot is downloaded, DiagnosticReport is extracted and result of checkpoint 2 is verified.

    Log   \nStep 2: Verify Checkpoint 2 Result In Snapshot   console=${True}
    Collect Snapshot
    ${diagnostic_report_from_snapshot}   Find And Extract DiagnosticReport File   ${path_to_snapshot}
    Verify Checkpoint Result In Snapshot   ${diagnostic_report_from_snapshot}

Step 3: Restore Configuration File And Run Diagnostic Check
    [Documentation]
    ...   In this step original "model_5.ims2" file is restored to passive partition of SMOD1.
    ...   Diagnostic check is performed and result is verified to see if CP 2 status is OK.

    Log   \nStep 3: Restore Configuration File And Run Diagnostic Check   console=${True}
    Restore Configuration File On Passive Partition
    diagnostic_check.Perform Diagnostic Check
    diagnostic_check.Get DC Report And Check CP Result   2   OK
    diagnostic_check.Check Alarm 4681   Inactive   Minor


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
    Query Infomodel   none //URI-*/SESSION-*/RUN_FULL_DIAGNOSTIC_CHECK_IND-*/RUN_DIAGNOSTIC_CHECK_RESULT-*   timeout=860
    Query Infomodel   none //URI-*/SESSION-*/DIAGNOSTIC_CHECK_COMPLETION_MONITORING_IND-*/RESULT-*   timeout=860
    diagnostic_check.Perform Diagnostic Check
    diagnostic_check.Get DC Report And Check CP Result   2   OK

Backup And Delete Configuration File From Passive Partition
    [Documentation]
    ...   This keyword downloads "model_5.ims2" file from passive partition of Primary SMOD to BTS_Files as backup
    ...   and deletes model_5.ims2 from passive partition.

    ssh_utils.Setup SMOD Connection
    ssh.Execute   mount -o rw,remount /ffs/stb
    ssh.Download File   /ffs/stb/config/model_5.ims2   ${BTS_Files}/model_5.ims2
    Log   Deleting model_5.ims2 file from /ffs/stb/config/ on Primary SMOD. Original file is copied to BTS_files.   console=${True}
    ssh.Execute   rm /ffs/stb/config/model_5.ims2
    Set Test Variable   ${CONFIG_FILE_DELETED}   ${True}
    ssh.Disconnect

Restore Configuration File On Passive Partition
    [Documentation]
    ...   This keyword uploads original "model_5.ims2" file from BTS_Files to passive partition of Primary SMOD

    ssh_utils.Setup SMOD Connection
    ssh.Execute   mount -o rw,remount /ffs/stb
    Log   File model_5.ims2 will be restored on BTS   console=${True}
    ssh.Upload File   ${BTS_Files}/model_5.ims2   /ffs/stb/config/model_5.ims2
    ssh.Execute   chown btssw.btssw /ffs/stb/config/model_5.ims2
    ssh.Execute   chmod 640 /ffs/stb/config/model_5.ims2
    Set Test Variable   ${CONFIG_FILE_DELETED}   ${False}
    ssh.Disconnect

Collect Snapshot
    [Documentation]
    ...  This keyword collects snapshot (full coverage), monitors collection status and sets path to snapshot as variable.
    Log   Collecting Snapshot   console=${True}
    ${timestamp}   Get time
    ${timestamp}   Replace String Using Regexp   ${timestamp}   (${SPACE}|:|-)  _
    Set Test Variable   ${timestamp}
    ${log_status}   Run Keyword And Ignore Error   coam.Collect snapshot   ${BTS_Files}/snapshot_${timestamp}.zip   timeout=1800
    Run Keyword If   '${log_status[0]}'=='FAIL'
    ...    Fail   Collecting snapshot failed
    ...    ELSE
    ...    Log   Full snapshot is successfully collected   console=${True}
    Set Test Variable   ${path_to_snapshot}   ${BTS_Files}/snapshot_${timestamp}.zip

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
          ${MATCHES}   Get Regexp Matches   ${snapshot_dict["${key}"][0]}   .*BTS${BTS_ID}_.011_DiagnosticReport.csv.xz
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
    Run Keyword Unless   ${SNAPSHOT_EXTRACTED}
    ...   unpacking.Unpack Archive Content To Directory   ${snapshot_path}   ${BTS_Files}/snapshot_${timestamp}
    Set Test Variable   ${SNAPSHOT_EXTRACTED}   ${TRUE}
    ${zip_from_extract}   Get Regexp Matches   ${path_to_extracting_file}   [\\w.]+
    ${log_to_extract}   Replace String Using Regexp   ${zip_from_extract[0]}   (.zip)   ${EMPTY}
    unpacking.Unpack Archive Content To Directory
    ...   ${BTS_Files}/snapshot_${timestamp}/${zip_from_extract[0]}   ${BTS_Files}/snapshot_${timestamp}${log_to_extract}
    unpacking.Unpack Archive Content To Directory
    ...   ${BTS_Files}/snapshot_${timestamp}${log_to_extract}/${zip_from_extract[1]}   ${BTS_Files}/DiagnosticReport
    ${unzipped_log_name}   Replace String Using Regexp   ${zip_from_extract[1]}   (.xz)   ${EMPTY}
    ${extracted_file_path}   Set Variable   ${BTS_Files}/DiagnosticReport/${unzipped_log_name}
    [Return]   ${extracted_file_path}

Verify Checkpoint Result In Snapshot
    [Documentation]
    ...  Keyword used to check if checkpoint 2 of diagnostic report has status 'NOK' in snapshot.
    [Arguments]   ${extracted_file_path}

    Log   Checking result of checkpoint 2 in snapshot    console=${True}
    ${CP_2_line}   OperatingSystem.Grep File   ${extracted_file_path}   Configuration file presence on the passive partition
    ${CP_2_status}   String.Fetch From Right   ${CP_2_line}   ,
    Should Be Equal As Strings   ${CP_2_status}   NOK
    Log   Checkpoint 2 has status "${CP_2_status}" in snapshot (expected status: "NOK")   console=${True}


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

Wget To File
    [Arguments]   ${url}   ${destination}
    ${status}   ${output}   Run And Return Rc And Output   wget -O ${destination} ${url}
    Run Keyword If   '${status}'!='0'   Log   ${output}
    Should Be Equal   '${status}'   '0'   msg=wget failed (exit code ${status})


Custom Test Teardown

    Run Keyword If   ${CONFIG_FILE_DELETED}
    ...  Restore Configuration File On Passive Partition
    Run Keyword If   ${SW_UPDATE}   Run Keywords
    ...  Log    Rollback Software   console=${True}
    ...  AND    Wait Until Keyword Succeeds   20m   5m   coam.Rollback Software
    ...  AND    Set Test Variable   ${SW_UPDATE}  ${False}
    ...  AND    Sleep    300
    ...  AND    Run   rm ${BTS Files}/${active_build_T}
    ...  AND    Wait Until Keyword Succeeds   20m   30s   pm_logs_general.Check All Modules And All Cells Working States


TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...  interface.Common step trigger
    ...  AND   Setup Scout And Send Configuration
    ...  AND   Custom Test Teardown
    ...  AND   Common Test Teardown
