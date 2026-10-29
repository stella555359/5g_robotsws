*** Settings ***
Library     OperatingSystem
Library     String
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     ../resources/connection.py
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot


*** Variables ***
${LSS_HOST}  10.5.20.200
${LSS_USER}  coam
${LSS_PASSWORD}  zO&n1W*ktp7!
${METADATA_PRINT_DETECT_61652}  Trigger:AUTOMATICTriggerType:61652-OnfaultdetectionNumberofOccurrences:
${METADATA_PRINT_CANCEL_61652}  Trigger:AUTOMATICTriggerType:61652-OnfaultcancellationNumberofOccurrences:
${EXISTING_KEYWORD}  Blackbox
${NOT_EXISTING_KEYWORD}  8kjl78654as245wsa21

*** Keywords ***
TC__LOGS__CB008626_FullWithoutRFLogs_Snapshot_With_Filter_Keywords
    [Documentation]
    ...  [CASE LINK]:
    ...  https://jiradc.ext.net.nokia.com/browse/TAT-25022
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Test case created to verify snapshot content with coverage "Full without RF logs", filtered by existing filter keyword
    ...  and not existing filter keyowrd.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 23.03.2023 - Damian Kotula - Test rewritten based on BOAM ET test -
    ...                 CB008626-C-02_manully_configure_a_fault_with_snapshotFilterkeywords_to_check_snapshot_content
    ...  - 17.05.2023 - Iuliia Taupeka: TAT-25384 - list_name= param added to KW AppendComplexItemToDelta
    ...  - 06.06.2023 - Damian Kotula - TAT-25485 - Added KW: 'Clear LSS From Previous Snapshots'
    ...  *******************
    ...  Test case flowchart  https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/SBTS/
    ...                       LOGS__CB008626_FullWithoutRFLogs_Snapshot_With_Filter_Keywords.png
    ...  *******************

    Set Tags    CA-LOGS    OWNER-iuliia.taupeka@nokia.com    AUTHOR-damian.kotula@nokia.com    MAINTAINER-damian.kotula@nokia.com
    ...   GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CRT    SW-SBTS23R2    FEATURE-CB008626

    Step 0: Preconditions
    Step 1: Trigger Snapshot With Not Existing Filter Keyword And Verify Its Content
    Step 2: Trigger Snapshot With Existing Filter Keyword And Verify Its Content

Step 0: Preconditions
    [Documentation]
    ...  In this step current scf is saved, it will be recomissioned after test end.
    ...  Fault 61652 is cancelled to not trigger snapshot right after faultSnapshotTriggers recomissioning.
    ...  Delta with two faultSnapshotTriggers for fault 61652 is prepared and recomissioned.

    Log  \nStep 0: Preconditions  console=${True}
    ${btsInfo}=  coam.Get Bts Info
    Set Test Variable  ${BTS_ID}  ${btsInfo['mrbtsID']}
    Set Test Variable  ${BTS_NAME}  ${btsInfo['name']}
    Set Test Variable  ${SW_Version}  ${bts_info["swInfo"]["swVersion"]}
    Set Test Variable  ${TRBL_MNLENT_DISTNAME}  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    Clear LSS From Previous Snapshots
    coam.Get Current Scf File  ${BTS Files}  Initial_scf.xml  export_type=configuration
    Cancel Fault 61652
    Create Fault Snapshot Triggers
    Set Snapshot Destination To  LSS

Step 1: Trigger Snapshot With Not Existing Filter Keyword And Verify Its Content
    [Documentation]
    ...  In this step snapshot without RF logs is triggered by fault 61652 detection with not existing filter keyword.
    ...  Metadata file and Snapshot file list are verified.
    ...  It is checked if snapshot doesn't contain other than expected files.
    ...  Number of files containing filter keyword should be 0, as files containing that keyword shouldn't exist.

    Log  \nStep 1: Trigger Snapshot With Not Existing Filter Keyword And Verify Its Content  console=${True}
    Trigger Fault 61652
    Validate Snapshot Metadata  ${METADATA_PRINT_DETECT_61652}
    ${number_of_filtered_keyword_files}  ${number_of_other_than_expected_files_in_list}  Validate Snapshot_file_list  ${NOT_EXISTING_KEYWORD}
    Should Be True  ${number_of_filtered_keyword_files}==0
    Should Be True  ${number_of_other_than_expected_files_in_list}==0
    Download Snapshot And Delete It From LSS

Step 2: Trigger Snapshot With Existing Filter Keyword And Verify Its Content
    [Documentation]
    ...  In this step snapshot without RF logs is triggered by fault 61652 cancelation with existing filter keyword.
    ...  Metadata file and Snapshot file list are verified.
    ...  It is checked if snapshot doesn't contain other than expected files.
    ...  Number of files containing filter keyword should be ditterent than 0, as filter keyword contains mandatory file name.

    Log  \nStep 2: Trigger Snapshot With Existing Filter Keyword And Verify Its Content  console=${True}
    Cancel Fault 61652
    Validate Snapshot Metadata  ${METADATA_PRINT_CANCEL_61652}
    ${number_of_filtered_keyword_files}  ${number_of_other_than_expected_files_in_list}  Validate Snapshot_file_list  ${EXISTING_KEYWORD}
    Should Be True  ${number_of_filtered_keyword_files}!=0
    Should Be True  ${number_of_other_than_expected_files_in_list}==0
    Download Snapshot And Delete It From LSS

Clear LSS From Previous Snapshots
    [Documentation]
    ...  This KW deletes snapshots that might have been sent to lss by previous tests, so they don't interrupt the test.
    ...  Only snapshots that were sent from bts that runs the test, and are from the same sw_version are deleted.

    connection.Connect  ${LSS_HOST}  ${LSS_USER}  ${LSS_PASSWORD}
    ${found_snapshots}  Execute Shell Command  ls /home/${LSS_USER} |grep Snapshot_MRBTS-${BTS_ID}_${BTS_NAME}_${SW_Version}_
    ${found_snapshots_list}  Split To Lines  ${found_snapshots}
    FOR  ${snapshot}  IN  @{found_snapshots_list}
        Execute Shell Command  rm -r /home/${LSS_USER}/${snapshot}
    END
    Disconnectt

Create Fault Snapshot Triggers
    [Documentation]
    ...  In this KW delta with two faultSnapshotTriggers is prepared and recomissioned.
    ...  First is triggering FullWithoutRFLogs snapshot on fault 61652 detection with not existing filter keyword.
    ...  Second is triggering FullWithoutRFLogs snapshot on fault 61652 cancelation with existing filter keyword.

    ${delta_id}  Set Variable  61652_triggers
    coam.Create Delta  ${delta_id}

    ${dict_fault_61652_detection}  Create Dictionary  faultNumber=61652
    ...  triggerType=onFaultDetection  snapshotCoverageLevel=FullWithoutRFLogs  snapshotFilterKeywords=${NOT_EXISTING_KEYWORD}
    ${dict_fault_61652_cancelllation}  Create Dictionary  faultNumber=61652
    ...  triggerType=onFaultCancellation  snapshotCoverageLevel=FullWithoutRFLogs  snapshotFilterKeywords=${EXISTING_KEYWORD}

    Log  \nAdding faultSnapshotTriggers list for fault 61652 to configuration.  console=${True}
    coam.Append Complex Item To Delta
    ...  ${TRBL_MNLENT_DISTNAME}  list_name=faultSnapshotTriggers  &{dict_fault_61652_detection}  delta_id=${delta_id}
    coam.Append Complex Item To Delta
    ...  ${TRBL_MNLENT_DISTNAME}  list_name=faultSnapshotTriggers  &{dict_fault_61652_cancelllation}  delta_id=${delta_id}
    coam.Get Delta  ${delta_id}
    coam.Save Delta  ${BTS Files}/fault_triggers_delta.json  ${delta_id}
    coam.Perform Delta Recommissioning  ${BTS Files}/fault_triggers_delta.json  skip_parameter_relation_errors=${True}

Trigger Fault 61652
    [Documentation]
    ...  In this KW Parameter actServicePortState is changed to true, which triggers fault 61652.

    coam.Perform Parameter Recommissioning
    ...  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1  parameter=actServicePortState  value=true  operation=update
    ...  skip_parameter_relation_errors=${True}  should_activate=${True}  timeout=180

Cancel Fault 61652
    [Documentation]
    ...  In this KW Parameter actServicePortState is changed to false, which cancels fault 61652.

    coam.Perform Parameter Recommissioning
    ...  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1  parameter=actServicePortState  value=false  operation=update
    ...  skip_parameter_relation_errors=${True}  should_activate=${True}  timeout=180

Validate Snapshot Metadata
    [Documentation]
    ...  This KW checks if metadata print contains expected snapshot trigger reason and trigger type.
    ...  Number of files listed in metadata is checked against snapshot content.
    [Arguments]  ${METADATA_PRINT}

    ${actual_metadata_print}  Validate Snapshot Files Count
    ${actual_metadata_print}  Replace String  ${actual_metadata_print}  ${SPACE}  ${EMPTY}
    ${actual_metadata_print}  Strip String  ${actual_metadata_print}
    Should Contain  ${actual_metadata_print}  ${METADATA_PRINT}

Validate Snapshot Files Count
    [Documentation]
    ...  This KW checks if number of files containing "part" in filename, listed in metadata.txt equals to number of "part" files in snapshot.
    ...  It's used to determine if all snapshot files are downloaded to LSS.

    connection.Connect  ${LSS_HOST}  ${LSS_USER}  ${LSS_PASSWORD}
    ${metadata_filename}  ${snapshot_filename}  Wait Until Keyword Succeeds  5min  10s  Check If Metadata File Exist
    ${file_count_in_metadata}  Execute Shell Command  cat /home/${LSS_USER}/${snapshot_filename}/${metadata_filename} |grep part |wc -l
    ${file_count_in_snapshot}  Execute Shell Command  ls /home/${LSS_USER}/${snapshot_filename} |grep part |wc -l
    Should Be Equal  ${file_count_in_metadata}  ${file_count_in_snapshot}
    ${actual_metadata_print}  Execute Shell Command  head -1 /home/${LSS_USER}/${snapshot_filename}/${metadata_filename} | tail -1
    Disconnectt
    [Return]  ${actual_metadata_print}

Check If Metadata File Exist
    [Documentation]
    ...  This KW checks if metadata.txt file is present in snapshot on LSS.

    ${snapshot_filename}  Execute Shell Command  ls /home/${LSS_USER} |grep Snapshot_MRBTS-${BTS_ID}_${BTS_NAME}_${SW_Version}_
    ${snapshot_filename}  Strip String  ${snapshot_filename}
    ${metadata_filename}  Execute Shell Command  ls /home/${LSS_USER}/${snapshot_filename}|grep metadata.txt
    ${metadata_filename}  Strip String  ${metadata_filename}
    Should Contain  ${metadata_filename}  metadata.txt
    [Return]  ${metadata_filename}  ${snapshot_filename}

Validate Snapshot_file_list
    [Documentation]
    ...  This KW checks snapshot_file_list.txt and returns variable with number of files containing Filter Keyword
    ...  and variable with number of files other than expected to find.
    [Arguments]  ${snapshotFilterKeywords}=${EMPTY}

    connection.Connect  ${LSS_HOST}  ${LSS_USER}  ${LSS_PASSWORD}
    ${snapshot_filename}  Wait Until Keyword Succeeds  3min  10s  Check If Snapshot_file_list Exist
    ${number_of_filtered_keyword_files}  Execute Shell Command
    ...  cat /home/${LSS_USER}/${snapshot_filename}/snapshot_file_list.txt |grep ${snapshotFilterKeywords}|wc -l
    ${names_of_filtered_keyword_files}  Execute Shell Command
    ...  cat /home/${LSS_USER}/${snapshot_filename}/snapshot_file_list.txt |grep ${snapshotFilterKeywords}
    ${command}  Catenate  cat /home/${LSS_USER}/${snapshot_filename}/snapshot_file_list.txt |grep -v ${snapshotFilterKeywords}
    ...  |grep -v snapshot_metadata |grep -v LogCollectionSummary |grep -v metadata |grep -v .zip: |grep -v ims2 |grep BTS* |wc -l
    ${number_of_other_than_expected_files_in_list}  Execute Shell Command  ${command}
    Disconnectt
    [Return]  ${number_of_filtered_keyword_files}  ${number_of_other_than_expected_files_in_list}

Check If Snapshot_file_list Exist
    [Documentation]
    ...  This KW checks if snapshot_file_list.txt is present in snapshot on LSS.

    ${snapshot_filename}  Execute Shell Command  ls /home/${LSS_USER} |grep Snapshot_MRBTS-${BTS_ID}_${BTS_NAME}_${SW_Version}_
    ${snapshot_filename}  Strip String  ${snapshot_filename}
    ${snapshot_file_list_name}  Execute Shell Command  ls /home/${LSS_USER}/${snapshot_filename}|grep snapshot_file_list.txt
    ${snapshot_file_list}  Strip String  ${snapshot_file_list_name}
    Should Be True  '${snapshot_file_list}'=='snapshot_file_list.txt'
    [Return]  ${snapshot_filename}

Download Snapshot And Delete It From LSS
    [Documentation]
    ...  In This KW snapshot from lss is zipped, copied to VM log file location and deleted from lss.

    connection.Connect  ${LSS_HOST}  ${LSS_USER}  ${LSS_PASSWORD}
    ${snapshot_filename}  Execute Shell Command  ls /home/${LSS_USER} |grep Snapshot_MRBTS-${BTS_ID}_${BTS_NAME}_${SW_Version}_
    Execute Shell Command  zip -r ${snapshot_filename}.zip ${snapshot_filename}
    Sleep  1min
    Run  sshpass -p '${LSS_PASSWORD}' scp ${LSS_USER}@${LSS_HOST}:/home/${LSS_USER}/${snapshot_filename}.zip ${BTS_Files}
    Wait Until Keyword Succeeds  3min  10s  OperatingSystem.File Should Exist  ${BTS_Files}/${snapshot_filename}.zip
    Execute Shell Command  rm -r /home/${LSS_USER}/${snapshot_filename}.zip
    Execute Shell Command  rm -r /home/${LSS_USER}/${snapshot_filename}
    Disconnectt

Custom Test Teardown
    coam.Perform Commissioning  scf_file=${BTS Files}/Initial_scf.xml  skip_parameter_relation_errors=${True}  should_activate=${True}
    Wait Until Keyword Succeeds  20m  1m  Check All Modules And All Cells Working States

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...  Custom Test Teardown
    ...  AND  interface.Common step trigger
    ...  AND  Setup Scout And Send Configuration
    ...  AND  Common Test Teardown
