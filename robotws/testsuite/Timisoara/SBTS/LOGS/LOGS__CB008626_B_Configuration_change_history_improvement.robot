*** Settings ***
Documentation
    ...  CB008626_B_Configuration_change_history_improvement
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    SeleniumLibrary
Resource    ../resources/verdicts.robot
Resource    ../resources/BTS_log_level.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    ../resources/bts_states.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    ../resources/ssh_utils.robot

*** Variables ***
${DASHBOARD_SIDEBAR_OPTIONS}  //*[@id="main-view"]/div/div[1]/div[1]/product-bar/otx-product-bar/div/div[1]/div[3]/div/a/span
${OPERATIONS_HISTORY}  //*[@id="laf-component"]/div/ul/li[3]/a/span
${ACTIVE_SCFs_EXIST}    //*[contains(text(),"activated SCFs exist in BTS")]
${number_of_SCFs}  successfully activated SCFs exist in BTS

*** Keywords ***
TC__LOGS__CB008626_B_Configuration_change_history_improvement
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25493
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Refactored from the test /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/cOAM/CB008626
    ...  Step 1: Configuration Change
    ...  Step 2: Check in WebEM if performed in step 1 changes are present in Operations History
    ...  Step 3: Restore Configuration Change
    ...  Step 4: Check in WebEM number of latest successfully activated SCFs exist in BTS
    ...  Step 5: Collect Snapshot and check number of json files
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 09.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25493 - Initial creation
    ...  - 13.07.2023 - https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/merge_requests/76058 - Merge request
    ...  - 06.10.2023 - Added NRBTS_ID variable, its not the same as MRBTS_ID
    ...  - 13.10.2023 - Changed mechanism of finding and extracting planfiles.tar from snapshot.
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/raw/master/testsuite/SBTS/
    ...  LOGS__CB008626_B_Configuration_change_history_improvement.png
    ...

    Set Tags    CA-LOGS    AUTHOR-rafal.sytyk@nokia.com    MAINTAINER-marcin.berkowski@nokia.com
    ...        GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CIT    SW-SBTS23    FEATURE-CB008626

    Step 0: Precondition
    Step 1: Configuration Change
    Step 2: Check in WebEM if performed in step 1 changes are present in Operations History
    Step 3: Restore Configuration Change
    Step 4: Check in WebEM number of latest successfully activated SCFs exist in BTS
    Step 5: Collect Snapshot and check number of json files


Step 0: Precondition
    [Documentation]
    ...    In this step there are needed values defined

    Log    \nStep 0: Precondition   console=${True}
    ${vm_ip}  ssh_utils.Get VM Ip
    Set Test Variable    ${VM_IP}    ${vm_ip}
    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable    ${BTS_ID}    ${bts_id}

    Run Keyword If   ${btsid} == 10832  Run Keywords
    ...    Set Test Variable    ${chBw}    20
    ...    AND  Set Test Variable    ${cellid}    1
    ...    ELSE  Run Keywords
    ...    Set Test Variable    ${chBw}    80
    ...    AND  Set Test Variable    ${cellid}    1

    ${btsInfo}=  coam.Get Bts Info
    Set Test Variable  ${NRBTS_ID}  ${btsInfo['nrBtsId']}
    ${cell_NR_list}=    coam.Get Ids For All    NRCEL   timeout=120
    ${list_with_NRcell_number_id}=    Create list
    FOR  ${nr_cell}  IN  @{cell_NR_list}
         ${NR_cell_number}    Fetch From Right  ${nr_cell}  -
         Append To List    ${list_with_NRcell_number_id}    ${NR_cell_number}
    END
    Set Test Variable    @{list_with_NRcell_number_id}
    Set Test Variable    ${1_CELL_5G}    ${list_with_NRcell_number_id}[${cellid}]
    Run Keyword If   ${btsid} == 10832  Run Keywords
    ...    Set Test Variable
    ...    ${operations_history_changes1}  { "targetDN": "MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${1_CELL_5G}", "isDeleted": false, "parameters"
    ...    AND  Set Test Variable
    ...    ${operations_history_changes2}  : { "arpPrioEmergencyCall": 2, "chBw": ${chBw}, "gscnOrSsPbchArfcn": 2 }
    ...    ELSE  Run Keywords
    ...    Set Test Variable
    ...    ${operations_history_changes1}  { "targetDN": "MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${1_CELL_5G}", "isDeleted": false, "parameters"
    ...    AND  Set Test Variable
    ...    ${operations_history_changes2}  : { "arpPrioEmergencyCall": 2 }
    Set Test Variable    ${Configuration_Change}      ${False}

    ${pass_1}=  Run  sudo cat /etc/ute/vncpasswd
    Set Test Variable    ${VM_PASSWORD}    ${pass_1}


Step 1: Configuration Change
    [Documentation]
    ...    In this step there is performed delta configuration

    Log    \nStep 1: Configuration Change   console=${True}
    Configuration Change   ${BTS_ID}
    Set Test Variable    ${Configuration_Change}    ${True}
    Wait Until Keyword Succeeds  20m  30s  pm_logs_general.Check All Modules And All Cells Working States


Step 2: Check in WebEM if performed in step 1 changes are present in Operations History
    [Documentation]
    ...    In this step there is checked in WebEM if performed in step 1 changes are present in Operations History

    Log    \nStep 2: Check in WebEM if performed in step 1 changes are present in Operations History    console=${True}
    Log    Open WebEM in browser    console=${True}
    BTS_log_level.WebEM Login
    Log    Wait Element Visible And Click ${DASHBOARD_SIDEBAR_OPTIONS}    console=${True}
#    Wait Element Visible And Click  ${DASHBOARD_SIDEBAR_OPTIONS}
    Wait Element Visible And Click  xpath=//*[@id="main-view"]/div/div[1]/div[1]/product-bar/otx-product-bar/div/div[1]/div[3]/div/a/span
    Log    Wait Element Visible And Click ${OPERATIONS_HISTORY}   console=${True}
#    Wait Element Visible And Click  ${OPERATIONS_HISTORY}
    Wait Element Visible And Click    xpath=//*[@id="laf-component"]/div/ul/li[3]/a/span

    Wait Until Element Is Visible   //*[contains(text(),"targetDN")]    20s
    Sleep    10s
    ${changes}=     Get Text    //*[contains(text(),"targetDN")]
    Should Contain    ${changes}  ${operations_history_changes1}${operations_history_changes2}
    Log    Close Browser    console=${True}
    SeleniumLibrary.Close Browser

Step 3: Restore Configuration Change
    [Documentation]
    ...    In this step is restored delta confoguration

    Log    \nStep 3: Restore Configuration Change   console=${True}
    Log    Restore Configuration Change and wait for OnAir   console=${True}
    Restore Configuration Change   ${BTS_ID}
    Set Test Variable    ${Configuration_Change}    ${False}
    Wait Until Keyword Succeeds  20m  30s  pm_logs_general.Check All Modules And All Cells Working States
    Log    Configuration Change and wait for OnAir   console=${True}
    Configuration Change   ${BTS_ID}
    Set Test Variable    ${Configuration_Change}    ${True}
    Wait Until Keyword Succeeds  20m  30s  pm_logs_general.Check All Modules And All Cells Working States

Step 4: Check in WebEM number of latest successfully activated SCFs exist in BTS
    [Documentation]
    ...    In this step there is checked in WebEM number of latest successfully activated SCFs exist in BTS

    Log    \nStep 4: Check in WebEM number of latest successfully activated SCFs exist in BTS   console=${True}
    Log    Open WebEM in browser    console=${True}
    BTS_log_level.WebEM Login
    Log    Wait Element Visible And Click ${DASHBOARD_SIDEBAR_OPTIONS}    console=${True}
    Wait Element Visible And Click  ${DASHBOARD_SIDEBAR_OPTIONS}
    Log    Wait Element Visible And Click ${OPERATIONS_HISTORY}    console=${True}
    Wait Element Visible And Click  ${OPERATIONS_HISTORY}
    Wait Until Element Is Visible   ${ACTIVE_SCFs_EXIST}    20s
    Sleep    10s
    ${validate_SCF}=    Get Text    ${ACTIVE_SCFs_EXIST}
    Log    validate_SCF: ${validate_SCF}    console=${True}
    Should Contain      ${validate_SCF}     ${number_of_SCFs}
    @{num_of_plan_files}=        split string    ${validate_SCF}      ${SPACE}
    ${number_of_webem_planfiles}   Convert To Integer   ${num_of_plan_files}[1]
    Set Test Variable    ${number_of_webem_planfiles}
    Log    Number of webem planfiles: ${number_of_webem_planfiles}    console=${True}
    Log    Close Browser    console=${True}
    SeleniumLibrary.Close Browser

Step 5: Collect Snapshot and check number of json files
    [Documentation]
    ...    In this step there is collected Snapshot and checked if number of json is the same as the number checked in step 4

    Log    \nStep 5: Collect Snapshot and check number of scf_*.json.gz files   console=${True}
    Log    Start snapshot collecting    console=${True}
    ${snapshot_status}    Run Keyword And Return Status
    ...    coam.Collect Snapshot    ${BTS Files}/Snapshot.zip  timeout=${SNAPSHOT_TIMEOUT}
    Run Keyword If    ${snapshot_status}
    ...    Log    Collecting snapshot via admin succeeded    console=${True}
    ...    ELSE
    ...    verdicts.Set Test Failed  TC failed - Collecting snapshot using admin has failed.  ${TRUE}

    ${extracted_file}   Find And Extract Planfiles   ${BTS Files}/Snapshot.zip
    ${number_of_snapshot_planfiles}   OperatingSystem.Count Files In Directory   ${BTS_Files}/planfiles
    Log    Checking if number of plan files: ${number_of_snapshot_planfiles} is the same as checked in step 4: ${number_of_webem_planfiles}
    ...    console=${True}
    Should Be Equal     ${number_of_snapshot_planfiles}    ${number_of_webem_planfiles}

Find And Extract Planfiles
    [Documentation]
    ...  This KW searches for planfiles in Snapshot and extracts it for further verification.
    ...  |  Parameters     | Man. |  Description         |
    ...  |  snapshot_path  | Yes  |  path to Snapshot    |
    ...
    ...  *RETURN*
    ...  |  Parameters      |  Description           |
    ...  |  extracted_file  |  Path to extracted 1011_planfiles.tar |

    [Arguments]   ${snapshot_path}
    Log   Find and extract 1011_planfiles.tar   console=${True}
    ${snapshot_dict}   snapshot.Get Data From Snapshot   ${snapshot_path}
    FOR   ${key}   IN   @{snapshot_dict.keys()}
          ${MATCHES}   Get Regexp Matches   ${snapshot_dict["${key}"][0]}   .*_1011_planfiles.tar
          Run Keyword If   ${MATCHES}   Run Keywords
          ...   Log   1011_planfiles: ${MATCHES[0]} found   console=${True}
          ...   AND   Set Test Variable   ${MATCHES}   ${MATCHES}
          ...   AND   Exit For Loop
    END
    ${extracted_file}   Extract Log File   ${snapshot_path}   ${MATCHES[0]}
    Run Keyword Unless   ${MATCHES}   Fail   1011_planfiles.tar not found
    [Return]   ${extracted_file}

Extract Log File
    [Documentation]
    ...  Keyword used to extract specified file from snapshot.
    ...  |  Parameters               | Man. |  Description         |
    ...  |  snapshot_path            | Yes  |  path to Snapshot    |
    ...  |  path_to_extracting_file  | Yes  |  path to Snapshot    |
    ...  *RETURN*
    ...  |  Parameters           |  Description           |
    ...  |  extracted_file_path  |  Path to extracted planfiles |

    [Arguments]   ${snapshot_path}   ${path_to_extracting_file}
    Log   Start extracting planfiles for further analysis   console=${True}
    unpacking.Unpack Archive Content To Directory   ${snapshot_path}   ${BTS_Files}/snapshot_unpacked
    ${tar_from_extract}   Get Regexp Matches   ${path_to_extracting_file}   [\\w.]+
    ${log_to_extract}   Replace String Using Regexp   ${tar_from_extract[0]}   (.tar)   ${EMPTY}
    unpacking.Unpack Archive Content To Directory
    ...   ${BTS_Files}/snapshot_unpacked/${tar_from_extract[0]}   ${BTS_Files}/snapshot_unpacked${log_to_extract}
    unpacking.Unpack Archive Content To Directory
    ...   ${BTS_Files}/snapshot_unpacked${log_to_extract}/${tar_from_extract[1]}   ${BTS_Files}/planfiles

Wait Element Visible And Click
    [Arguments]    ${locator}   ${time_out}=20s
    Wait Until Element Is Visible   ${locator}  ${time_out}
    wait until keyword succeeds   20s  2s  click element   ${locator}

Configuration Change
    [Documentation]
    ...    In this KW there is performed delta configuration changes for 3 parameters
    [Arguments]    ${btsid}
    ${delta_changes}    Set Variable    delta_changes
    coam.Create Delta    ${delta_changes}

    Run Keyword If   ${btsid} == 10832  Run Keywords
    ...    coam.Append Parameter Update To Delta  MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${1_CELL_5G}  gscnOrSsPbchArfcn  2  ${delta_changes}
    ...    AND   coam.Append Parameter Update To Delta  MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${1_CELL_5G}  chBw  20MHz  ${delta_changes}
    ...    AND   coam.Append Parameter Update To Delta
    ...    MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${1_CELL_5G}  arpPrioEmergencyCall  2  ${delta_changes}

    ...    ELSE   Run Keywords
#    ...    # coam.Append Parameter Update To Delta  MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${1_CELL_5G}  gscnOrSsPbchArfcn  2  ${delta_changes}
#    ...    # AND   coam.Append Parameter Update To Delta  MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${1_CELL_5G}  chBw  80MHz  ${delta_changes}
    ...    sleep    1s
    ...    AND    coam.Append Parameter Update To Delta
    ...    MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${1_CELL_5G}  arpPrioEmergencyCall  2  ${delta_changes}



    coam.Get Delta  ${delta_changes}
    coam.Save Delta  ${BTS Files}/changes.json  ${delta_changes}
    coam.Perform Delta Recommissioning    delta_file=${BTS Files}/changes.json    skip_parameter_relation_errors=${True}

Restore Configuration Change
    [Documentation]
    ...    In this KW there is performed delta configuration back for 3 parameters to oryginal values
    [Arguments]    ${btsid}

    ${delta_back}    Set Variable    delta_back
    coam.Create Delta    ${delta_back}

    Run Keyword If   ${btsid} == 10832  Run Keywords
    ...    coam.Append Parameter Update To Delta  MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${1_CELL_5G}  gscnOrSsPbchArfcn  1  ${delta_back}
    ...    AND   coam.Append Parameter Update To Delta  MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${1_CELL_5G}  chBw  90MHz  ${delta_back}
    ...    AND   coam.Append Parameter Update To Delta  MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${1_CELL_5G}  arpPrioEmergencyCall  1  ${delta_back}
    ...    ELSE  Run Keywords

    ...    sleep    1s
#    ...    #coam.Append Parameter Update To Delta  MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${1_CELL_5G}  gscnOrSsPbchArfcn  6501  ${delta_back}
#    ...    #AND   coam.Append Parameter Update To Delta  MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${1_CELL_5G}  chBw  100MHz  ${delta_back}
    ...    AND   coam.Append Parameter Update To Delta  MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${1_CELL_5G}  arpPrioEmergencyCall  6  ${delta_back}


    coam.Get Delta  ${delta_back}
    coam.Save Delta  ${BTS Files}/back.json  ${delta_back}
    coam.Perform Delta Recommissioning    delta_file=${BTS Files}/back.json    skip_parameter_relation_errors=${True}

Custom Test Teardown
    Run Keyword If  ${Configuration_Change}    Run Keywords
    ...    Log    Custom Test Teardown    console=${True}
    ...    AND    Restore Configuration Change    ${btsid}
    ...    AND    Wait Until Keyword Succeeds  20m  30s  pm_logs_general.Check All Modules And All Cells Working States

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Custom Test Teardown
    ...    AND    Common Test Teardown
