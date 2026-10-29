*** Settings ***
Documentation
...  Tests for CNI-106835
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library     SSHLibrary
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/ping_utils.robot
Resource    ../resources/verdicts.robot
Resource    ../resources/unpacking.robot
Library     taf.ul.verify_snapshot   WITH NAME  snapshot

*** Variables ***
${BTS_ip}              192.168.255.129
${DIR_TO_CHECK}        /ffs/run/logs/ccsdumps/0/A/dumps
${SNAPSHOT_TIMEOUT}    600                      #timeout for collect snapshot via Admin (in sec)

*** Keywords ***
TC__LOGS__CNI-106835_01_Check_behavior_after_crashes_at_start-up_with_default_value
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27308
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...
    ...  Step 0: Precondition
    ...  Step 1: Set actCoreDumpFileCollection on default value
    ...  Step 2: Reset Site
    ...  Step 3: Trigger crash during startup and check if proper files was generated
    ...  Step 4: Check if FID-6450 was raised
    ...  Step 5: Collect snapshot and check if it contain needed files
    ...
    ...  ******************
    ...  Author: Marcin Berkowski
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2024-04-08 - https://jiradc.ext.net.nokia.com/browse/TAT-27308 - Initial test creation
    ...

    Set Tags    CA-LOGS    OWNER-marcin.berkowski@nokia.com    AUTHOR-marcin.berkowski@nokia.com
    ...    MAINTAINER-marcin.berkowski@nokia.com    GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CRT    SW-SBTS24R3

    Step 0: Precondition
    Step 1: Set actCoreDumpFileCollection on default value
    Step 2: Reset Site
    Step 3: Trigger crash during startup and check if proper files was generated
    Step 4: Check if FID-6450 was raised
    Step 5: Collect snapshot and check if it contain needed files

Step 0: Precondition
    [Documentation]
    ...  In this step there is checked if the SBTS does NOT contain flags 0x10079, 0x100b7 in the swconfig.txt file

    Log    \nStep 0: Precondition (the SBTS should NOT contains flags 0x10079, 0x100b7)  console=${True}
    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}
    SSHLibrary.Open Connection  ${SMOD1['IP']}  encoding=unicode_escape
    SSHLibrary.Login  ${SMOD1['USERNAME']}  ${SMOD1['PASSWORD']}
    ${output_0}=    SSHLibrary.Execute Command    cat /ffs/run/swconfig.txt
    SSHLibrary.Close Connection
    Should Not Contain    ${output_0}    10079
    Should Not Contain    ${output_0}    100b7
    Log    The SBTS does NOT contain flags 0x10079, 0x100b7 in the swconfig.txt file [OK]    console=${True}

Step 1: Set actCoreDumpFileCollection on default value
    [Documentation]
    ...  In this step there is set the parameter actCoreDumpFileCollection on default value (true)

    Log    \nStep 1: Set actCoreDumpFileCollection on default value    console=${True}
    Change Parameter actCoreDumpFileCollection    true

Step 2: Reset Site
    [Documentation]
    ...  This step there is triggered Reset Site and checking if connection via ssh is able after reset

    Log    \nStep 2: Reset Site    console=${True}
    coam.Reset Site    600
    ping_utils.Wait For Target IP To Be Reachable    ${BTS_ip}    20
    Log    Reset site done    console=${TRUE}

Step 3: Trigger crash during startup and check if proper files was generated
    [Documentation]
    ...  In this step there is triggered crash during startup by creating a dummy process (non critical proc.)
    ...  and kill them with signal -6 (SIGABRT)
    ...  and check if files with logs was generated on proper directory

    Log    \nStep 3: Trigger crash during startup and check if proper files was generated    console=${True}

    Log    3.1) Log to SM via ssh    console=${True}
    SSHLibrary.Open Connection  ${SMOD1['IP']}  encoding=unicode_escape
    SSHLibrary.Login  ${SMOD1['USERNAME']}  ${SMOD1['PASSWORD']}

    Log    3.2) Remove all files from the directory ${DIR_TO_CHECK}    console=${True}
    ${output_2a}=    SSHLibrary.Execute Command    rm -rf ${DIR_TO_CHECK}/node_0x1011
    ${output_2b}=    SSHLibrary.Execute Command    tree ${DIR_TO_CHECK}
    Should Contain    ${output_2b}    0 directories, 0 files
    Log    The directory ${DIR_TO_CHECK} is empty [OK]   console=${True}

    Log    3.3) Create a dummy proces "DummyProcesFor_CNI-106835" and check if process was created   console=${True}
    ${output_3a}=    SSHLibrary.Start Command    bash -c "exec -a DummyProcesFor_CNI-106835 sleep 10000 &"
    Sleep    5
    ${output_3b}=    SSHLibrary.Execute Command    ps aux | grep DummyProces
    Should Contain    ${output_3b}    DummyProcesFor_CNI-106835
    Log    The DummyProcesFor_CNI-106835 was created [OK]   console=${True}

    Log    3.4) kill the "DummyProcesFor_CNI-106835" and check if was killed    console=${True}
    ${output_4a}=    SSHLibrary.Execute Command    date; pkill -f -6 DummyProcesFor_CNI-106835
    Sleep    5
    ${output_4b}=    SSHLibrary.Execute Command    ps aux | grep DummyProces
    Should Not Contain    ${output_4b}    DummyProcesFor_CNI-106835
    Log    The DummyProcesFor_CNI-106835 was killed [OK]   console=${True}

    Log    3.5) Check directory directory ${DIR_TO_CHECK}    console=${True}
    ${output_5a}=    SSHLibrary.Execute Command    tree ${DIR_TO_CHECK}
    Should Contain    ${output_5a}    2 files
    Log    The logs file in the directory ${DIR_TO_CHECK} was created [OK]   console=${True}

    ${output_5b}=    SSHLibrary.Execute Command    ls ${DIR_TO_CHECK}/node_0x1011 | grep core\.xz\.p7
    Set Suite Variable    ${file_name_to_check_in_snap}    ${output_5b}
    Log    Checking if filename convention is for file is in line with req. RPREQ_2522: ${output_5b}    console=${True}
    @{output_5b_spited}=    Split String   ${output_5b}    _
    Should Be Equal    ${output_5b_spited}[0]    0x1011
    Should Be Equal    ${output_5b_spited}[1]    sleep.coreutils
    Set Suite Variable    ${pid_in_filename}    ${output_5b_spited}[2]
    Should Contain    ${output_3b}    ${pid_in_filename}
    #checking kill signal -6 (SIGABRT):
    Should Be Equal    ${output_5b_spited}[3]   6
    @{output_5b_spited_2}=    Split String   ${output_5b_spited}[4]   .
    Set Suite Variable    ${timestamp_in_filename}    ${output_5b_spited_2}[0]

    Log    3.6) checking if timestamps is ok    console=${True}
    ${output_6}=    SSHLibrary.Execute Command    date -d'@${timestamp_in_filename}'
    Should Be Equal    ${output_6}    ${output_4a}
    Log    The timestamp: ${output_6} is the same as time of killing dummy process [OK]   console=${True}

    SSHLibrary.Close Connection

Step 4: Check if FID-6450 was raised
    [Documentation]
    ...  In this step there is checked if FID-6450 was raised

    Log    \nStep 4: Check if FID-6450 was raised    console=${True}
    Wait until keyword succeeds    6min    5 sec    Check If Expected Alarm Occurred    6450
    Log    The FID-6450 was raised [OK]    console=${True}

Check If Expected Alarm Occurred
    [Documentation]  This KW downloads list of active alarms and checks if expected fault is on the list.
    [Arguments]  ${fault_ID}
    ${active_alarms}  coam.Get Active Alarms  timeout=60
    ${active_faults_ids}  Get Fault IDs From Active Alarms  ${active_alarms}
    ${expected_fault}  Convert To Integer  ${fault_ID}
    Log    Active FIDs: ${active_faults_ids}    console=${True}
    List Should Contain Value  ${active_faults_ids}  ${expected_fault}  msg=Fail: Expected fault ${fault_ID} was not raised!

Step 5: Collect snapshot and check if it contain needed files
    [Documentation]
    ...  In this step there is collect snapshot and check if it contain needed files
    ...  additionaly there is checked if the FID-6450 was cleared after the snapshot collecting

    Log    \nStep 5: Collect snapshot and check if it contain needed files    console=${True}
    Log    Waiting for OnAir    console=${True}
    Wait Until Keyword Succeeds  20m  30s  Check All Modules And All Cells Working States
    ${snapshot_status}    Run Keyword And Return Status
    ...    coam.Collect Snapshot    ${BTS Files}/snapshot.zip  timeout=${SNAPSHOT_TIMEOUT}
    Run Keyword If    ${snapshot_status}
    ...    Collecting Snapshot Succeeded
    ...    ELSE
    ...    verdicts.Set Test Failed  TC failed - Collecting snapshot using admin has failed.  ${TRUE}

    Wait until keyword succeeds    6min    5 sec    Check If Expected Alarm Cleared    6450
    Log    The FID-6450 was cleared [OK]    console=${True}

    ${crashdumps_file_from_snapshot}   Find And Extract crashdumps File   ${path_to_snapshot}
    ${output_step5a}=    Run    ls ${crashdumps_file_from_snapshot}
    #Checking first file:
    Should Contain    ${output_step5a}    0x1011_bt-coreinfo.txt
    #Checking second file *.core.xz.p7:
    Should Contain    ${output_step5a}    ${file_name_to_check_in_snap}

Find And Extract crashdumps File
    [Documentation]
    ...  This KW searches for crashdumps File in Snapshot and extracts it for further verification.
    ...  |  Parameters     | Man. |  Description         |
    ...  |  snapshot_path  | Yes  |  path to Snapshot    |
    ...
    ...  *RETURN*
    ...  |  Parameters      |  Description           |
    ...  |  extracted_file  |  Path to extracted  File |

    [Arguments]   ${snapshot_path}
    Log   Find and extract crashdumps file   console=${True}
    ${snapshot_dict}   snapshot.Get Data From Snapshot   ${snapshot_path}
    FOR   ${key}   IN   @{snapshot_dict.keys()}
          ${MATCHES}   Get Regexp Matches   ${snapshot_dict["${key}"][0]}   .*_1011_crashdumps_0x1011_0_A.tar
          Run Keyword If   ${MATCHES}   Run Keywords
          ...   Log   The file: ${MATCHES[0]} found   console=${True}
          ...   AND   Set Test Variable   ${MATCHES}   ${MATCHES}
          ...   AND   Exit For Loop
    END
    ${extracted_file}   Extract Log File   ${snapshot_path}   ${MATCHES[0]}
    Run Keyword Unless   ${MATCHES}   Fail   crashdumps file not found
    [Return]   ${extracted_file}

Extract Log File
    [Documentation]
    ...  Keyword used to extract specified file from snapshot.
    ...  |  Parameters               | Man. |  Description         |
    ...  |  snapshot_path            | Yes  |  path to Snapshot    |
    ...  |  path_to_extracting_file  | Yes  |  path to Snapshot    |
    ...  *RETURN*
    ...  |  Parameters           |  Description           |
    ...  |  extracted_file_path  |  Path to extracted File |

    [Arguments]   ${snapshot_path}   ${path_to_extracting_file}
    Log   Start extracting file   console=${True}
    unpacking.Unpack Archive Content To Directory   ${snapshot_path}   ${BTS_Files}/snapshot
    ${zip_from_extract}   Get Regexp Matches   ${path_to_extracting_file}   [\\w.]+
    ${log_to_extract}   Replace String Using Regexp   ${zip_from_extract[0]}   (.zip)   ${EMPTY}
    unpacking.Unpack Archive Content To Directory
    ...   ${BTS_Files}/snapshot/${zip_from_extract[0]}   ${BTS_Files}/snapshot${log_to_extract}
    unpacking.Unpack Archive Content To Directory
    ...   ${BTS_Files}/snapshot${log_to_extract}/${zip_from_extract[1]}   ${BTS_Files}/crashdumps
    ${unzipped_log_name}   Replace String Using Regexp   ${zip_from_extract[1]}   (.xz)   ${EMPTY}
    ${extracted_file_path}   Set Variable   ${BTS_Files}/crashdumps
    [Return]   ${extracted_file_path}

Collecting Snapshot Succeeded
    Log    Collecting snapshot via admin succeeded [OK]    console=${True}
    Set Test Variable    ${path_to_snapshot}    ${BTS Files}/snapshot.zip

Check If Expected Alarm Cleared
    [Documentation]
    ...    This KW downloads list of active alarms and checks if expected fault is NOT on the list.
    [Arguments]  ${fault_ID}
    ${active_alarms}  coam.Get Active Alarms  timeout=60
    ${active_faults_ids}  Get Fault IDs From Active Alarms  ${active_alarms}
    ${expected_fault}  Convert To Integer  ${fault_ID}
    Log    Active FIDs: ${active_faults_ids}    console=${True}
    List Should Not Contain Value  ${active_faults_ids}  ${expected_fault}  msg=Fail: Expected fault ${fault_ID} was not cleared!

Change Parameter actCoreDumpFileCollection
    [Arguments]     ${new_value}
    coam.perform_parameter_recommissioning
    ...    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    parameter=actCoreDumpFileCollection
    ...    value=${new_value}
    ...    operation=update
    ...    skip_parameter_relation_errors=false
    ...    timeout=180
    Log    Set the parameter actCoreDumpFileCollection=${new_value} [done]    console=${True}

Get Fault IDs From Active Alarms
    [Documentation]  This KW creates a list of fault IDs from list of active alarms.
    [Arguments]  ${alarms}
    ${faults_ids}  Create List
    FOR  ${alarm}  IN  @{alarms}
      ${fault_id}  Get From Dictionary  ${alarm}  faultId
      Append To list  ${faults_ids}  ${fault_id}
    END
    [Return]  ${faults_ids}

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown
