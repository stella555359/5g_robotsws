*** Settings ***
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     ../resources/node_id_verificator.py
Library     DateTime
Library     OperatingSystem
Resource    ../resources/unpacking.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${SNAPSHOT_TIMEOUT}      600

*** Keywords ***
TC__LOGS__CNI-90327_AaTrblServer_configuration_formalization
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26731
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test case verifies if log files from each units (Common, Capacity, Core) have correctly assigned NodeIDs.
    ...  Verification is performed in accordance with SIC addressing (SICAD) scheme described in RPREQ_8838
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  - 17.01.2024 - Initial creation
    ...
    Set Tags   CA-LOGS    AUTHOR-damian.kotula@nokia.com    MAINTAINER-damian.kotula@nokia.com
    ...    GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CRT    SW-SBTS24R2    FEATURE-CNI90327


    Step 0: Preconditions
    Step 1: Verify Node Ids Of Snapshot Files

Step 0: Preconditions
    [Documentation]
    ...  In this step necessary test variables are set.

    Log  \nStep 0: Preconditions  console=${True}
    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable   ${BTS_ID}   BTS${bts_id}
    Create TL configuration dict with positions

Step 1: Verify Node Ids Of Snapshot Files
    [Documentation]
    ...  In this step snapshot is collected and snapshot_filelist is extracted. NodeIDs of all log files having them assigned in file names are
    ...  verified against SIC addressing (SICAD) scheme described in RPREQ_8838.

    Log  \nStep 1: Verify NodeIDs Of Snapshot Files  console=${True}
    Collect And Extract Snapshot
    node_id_verificator.run_node_id_verification  ${BTS_ID}  ${board_positions}  ${snapshot_filelist}  ${BTS_Files}
    Verify Result Files


Create TL configuration dict with positions
    [Documentation]
    ...  This KW creates a dictionary with smods/bbmods and their positions in rack.

    ${BBmod_objects}  coam.get_managed_objects  BBMOD_R
    ${Smod_objects}  coam.get_managed_objects  SMOD_R
    ${board_positions}  Create Dictionary
    FOR  ${bbmod}  IN  @{BBmod_objects}
        ${board_name}  Fetch From Left  ${bbmod["parameters"]["productName"]}  ${None}
        Set To Dictionary  ${board_positions}  ${bbmod["parameters"]["horizontalPosition"]}${bbmod["parameters"]["verticalPosition"]}  ${board_name}
    END
    FOR  ${smod}  IN  @{Smod_objects}
        ${board_name}  Fetch From Left  ${smod["parameters"]["productName"]}  ${None}
        Set To Dictionary  ${board_positions}  ${smod["parameters"]["horizontalPosition"]}0  ${board_name}
    END
    Set Test Variable  ${board_positions}
    Log  Node IDs will be verified for configuration: ${board_positions}  console=${True}

Collect And Extract Snapshot
    [Documentation]
    ...  This keyword collects snapshot (full coverage), monitors collection status and unpacks snapshot to get snapshot_file_list.

    Log  Collecting Snapshot  console=${True}
    ${timestamp}  Get Time
    ${timestamp}  Replace String Using Regexp  ${timestamp}  (${SPACE}|:|-)  _
    ${log_status}  Run Keyword And Ignore Error  coam.Collect Snapshot  ${BTS_Files}/snapshot_${timestamp}.zip  timeout=${SNAPSHOT_TIMEOUT}
    Run Keyword If  '${log_status[0]}'=='FAIL'
    ...   Fail  Collecting snapshot failed
    ...   ELSE
    ...   Log  Full snapshot is successfully collected  console=${True}
    unpacking.Unpack Archive Content To Directory  ${BTS_Files}/snapshot_${timestamp}.zip  ${BTS_Files}/snapshot_${timestamp}
    OperatingSystem.Copy File  ${BTS_Files}/snapshot_${timestamp}/snapshot_file_list.txt  ${BTS_Files}
    Set Test Variable  ${snapshot_filelist}  ${BTS_Files}/snapshot_file_list.txt
    OperatingSystem.Remove Directory  ${BTS_Files}/snapshot_${timestamp}  recursive=${True}

Verify Result Files
    [Documentation]
    ...  This keyword verifies if log files from each system and baseband modules have correctly assigned NodeIDs.
    ...  Number of log files from each module is compared to number of files with correct NodeIDs after verification.
    ...  It is also checked if result file with not allowed NodeIDs is empty.

    ${items}  Get Dictionary Items  ${board_positions}
    FOR  ${position}  ${board}  IN  @{items}
       ${number_of_log_files}  node_id_verificator.count_files_from_board  ${BTS_Files}/files_from_position_${position}.json
       ${logs_with_verified_node_ids}  OperatingSystem.Get File  ${BTS_Files}/allowed_node_ids_${board}_${position}.txt
       ${number_of_correct_node_ids}  Get Line Count  ${logs_with_verified_node_ids}

       Log  ${board} in position ${position} - ${number_of_log_files} log files found, of which ${number_of_correct_node_ids} have correct Node IDs
       ...  console=${True}

       Run Keyword And Continue On Failure  Should Be Equal  ${number_of_log_files}  ${number_of_correct_node_ids}
       Run Keyword And Continue On Failure  OperatingSystem.File Should Be Empty  ${BTS_Files}/not_allowed_node_ids_${board}_${position}.txt
       Run Keyword And Continue On Failure  OperatingSystem.File Should Not Exist  ${BTS_Files}/other_files_${board}_${position}.txt
    END


TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    Run Keyword If Test Failed  Log  Not Allowed/Not Expected NodeIDs found. Check manually result logs in folder BTSfiles.  console=${True}
    ...    AND  interface.Common step trigger
    ...    AND  Setup Scout And Send Configuration
    ...    AND  Common Test Teardown
