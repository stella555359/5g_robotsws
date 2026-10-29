*** Settings ***
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     taf.ul.verify_snapshot   WITH NAME  snapshot
Library     DateTime
Resource    ../resources/unpacking.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${SNAPSHOT_EXTRACTED}    ${False}
${ACTIVATED_SCF_PATH}    /tmp/uri/ActivatedScf.xml

*** Keywords ***
TC__LOGS_CB010545_AdminCLI_snapshot_Full_coverage
    [Documentation]
    ...  [CASE LINK]:
    ...  https://jiradc.ext.net.nokia.com/browse/TAT-27109
    ...  *****************
    ...  Author: Mateusz Majkusiak
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  This test case verifies if ActivatedScf.xml file is present in snapshot archive. Should be placed in
    ...  BTS<BTS_ID>_1011_OAM_CM_SNAPSHOT.tar.xz archive in /tmp/uri directory inside.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2024-03-05 - TC created. TAT-27109
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/SBTS/
    ...  LOGS_CB010545_AdminCLI_snapshot_Full_coverage.png
    ...  *******************

    Set Tags    CA-LOGS    AUTHOR-mateusz.majkusiak@nokia.com    MAINTAINER-mateusz.majkusiak@nokia.com    GROUP_IN_CHARGE-WRO_6_Vrf
    ...   PHASE-CRT   PHASE-CRT SW-SBTS24R2

    Step 0: Preparation
    Step 1: Collect snapshot
    Step 2: Extract and verify ActivatedScf.xml presence in snapshot

Step 0: Preparation
    [Documentation]
    ...   This step get the BTS id and assign to variable

    Log   Step 0: Preconditions  console=${True}
    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}

Step 1: Collect snapshot
    [Documentation]
    ...   In this step snapshot is downloaded

    Log    Step 1: Collect snapshot   console=${True}
    Collect Snapshot

Step 2: Extract and verify ActivatedScf.xml presence in snapshot
     [Documentation]
    ...   In this step snapshot is extracted and verified if ActivatedScf.xml is present inside

    Log    Step 2: Extract and verify ActivatedScf.xml presence in snapshot   console=${True}
    ${oam_cm_snapshot_from_snapshot}    Find And Extract OAM_CM_SNAPSHOT.tar.xz archive in snapshot    ${path_to_snapshot}

Collect Snapshot
    [Documentation]
    ...  This keyword collects snapshot (full coverage), monitors collection status and sets path to snapshot as variable.
    Log   Collecting Snapshot   console=${True}

    ${timestamp}   Get time
    ${timestamp}   Replace String Using Regexp   ${timestamp}   (${SPACE}|:|-)  _
    Set Test Variable   ${timestamp}
    ${log_status}   Run Keyword And Ignore Error   coam.Collect snapshot   ${BTS_Files}/snapshot_${timestamp}.zip
    ...    detailed_output=True    timeout=1800
    Run Keyword If   '${log_status[0]}'=='FAIL'
    ...    Fail   Collecting snapshot failed
    ...    ELSE
    ...    Log   Full snapshot is successfully collected   console=${True}
    Set Test Variable   ${path_to_snapshot}   ${BTS_Files}/snapshot_${timestamp}.zip

Extract Log File
    [Documentation]
    ...  Keyword used to extract specified file from snapshot.
    ...  |  Parameters               | Man. |  Description         |
    ...  |  snapshot_path            | Yes  |  path to Snapshot    |
    ...  |  path_to_extracting_file  | Yes  |  path in Snapshot    |

    [Arguments]   ${snapshot_path}   ${path_to_extracting_file}
    Log   Start extracting BTS${BTS_ID}_1011_OAM_CM_SNAPSHOT.tar.xz directory for further analysis   console=${True}
    Run Keyword Unless   ${SNAPSHOT_EXTRACTED}
    ...   unpacking.Unpack Archive Content To Directory   ${snapshot_path}   ${BTS_Files}/snapshot_${timestamp}
    Set Test Variable   ${SNAPSHOT_EXTRACTED}   ${True}
    ${list_from_extract}    Split String    ${path_to_extracting_file[0]}    /
    ${log_to_extract}   Replace String Using Regexp   ${list_from_extract[0]}   (.zip)   ${EMPTY}
    unpacking.Unpack Archive Content To Directory
    ...   ${BTS_Files}/snapshot_${timestamp}/${list_from_extract[0]}  ${BTS_Files}/snapshot_${timestamp}/${log_to_extract}
    ${unzipped_log_name}   Replace String Using Regexp   ${list_from_extract[1]}   (.xz)   ${EMPTY}
    ${unzipped_untar_log_name}   Replace String Using Regexp   ${list_from_extract[1]}   (.tar.xz)   ${EMPTY}
    unpacking.Unpack Archive Content To Directory
    ...   ${BTS_Files}/snapshot_${timestamp}/${log_to_extract}/${list_from_extract[1]}  ${BTS_Files}/${unzipped_untar_log_name}
    unpacking.Unpack Archive Content To Directory
    ...    ${BTS_Files}/${unzipped_untar_log_name}/${unzipped_log_name}  ${BTS_Files}/${unzipped_untar_log_name}/ActivatedScf_path
    Set Test Variable   ${extracted_file_path}    ${BTS_Files}/${unzipped_untar_log_name}/ActivatedScf_path
    ${file_exists}    BuiltIn.Run Keyword And Return Status    OperatingSystem.File Should Exist
    ...    ${extracted_file_path}${ACTIVATED_SCF_PATH}
    Run Keyword If   '${file_exists}'=='True'
    ...    Log   File ActivatedScf.xml exists!  console=${True}
    ...    ELSE
    ...    Fail   File ActivatedScf.xml does not exist!

Find And Extract OAM_CM_SNAPSHOT.tar.xz archive in snapshot
    [Documentation]
    ...  This KW searches for BTS${BTS_ID}_1011_OAM_CM_SNAPSHOT.tar.xz directory in Snapshot and extracts it for further verification.
    ...  |  Parameters     | Man. |  Description         |
    ...  |  snapshot_path  | Yes  |  path to Snapshot    |

    [Arguments]   ${snapshot_path}
    Log   Find and extract BTS${BTS_ID}_1011_OAM_CM_SNAPSHOT.tar.xz archive   console=${True}
    ${snapshot_dict}   snapshot.Get Data From Snapshot   ${snapshot_path}
    FOR   ${key}   IN   @{snapshot_dict.keys()}
          ${MATCHES}   Get Regexp Matches   ${snapshot_dict["${key}"][0]}   .*BTS${BTS_ID}_1011_OAM_CM_SNAPSHOT.tar.xz
          Run Keyword If   ${MATCHES}   Run Keywords
          ...   Log   BTS${BTS_ID}_1011_OAM_CM_SNAPSHOT.tar.xz directory: ${MATCHES[0]} found   console=${True}
          ...   AND   Set Test Variable   ${MATCHES}   ${MATCHES}
          ...   AND   Exit For Loop
    END
    ${extracted_file}   Extract Log File   ${snapshot_path}   ${MATCHES}
    Run Keyword Unless   ${MATCHES}   Fail   BTS${BTS_ID}_OAM_CM_SNAPSHOT.tar.xz file not found

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...  interface.Common step trigger
    ...  AND   Setup Scout And Send Configuration
    ...  AND   Common Test Teardown

