*** Settings ***
Documentation
    ...  The purpose of this test case is to check system critical event logs contents collected via M-Plane remote access method.
    ...  Connect to SBTS via M-Plane remote access method. WebEM is started. SBTS is in commissioned state.
    ...  Trigger SCREL using WebEM GUI BTS EM GUI button. Set SCREL collection settings as: Save location: "Local", Press Collect SCREL.
    ...  SCREL is successfully created and saved.
    ...  Checks if SCREL snapshot with desired content properly generated and "BinaryTracing_FRI_AlarmHistory_*.bro.xz" existing in Snapshot.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__System_Critical_Log_contents_via_MPlane
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28212
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28212 - Initial TAT creation
    ...  12.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30367 - Add timeout for Wait Until Created kw
    ...  16.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30397 - Change the SCREL file name
    ...  29.01.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30450 - Snapshot is downloaded with a different name for a version higher than 26R2

    Set Tags  CA-WebEM  OWNER-marius.stanescu@nokia.com  AUTHOR-cristina.adam@nokia.com  MAINTAINER-cristina.adam@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS24  FEATURE-CNI-107641

    Step1: Navigate To Snapshot Collection
    Step2: Collect System Critical Event Logs
    Step3: Check Output Of SCREL Snapshot


Step1: Navigate To Snapshot Collection
    Log  \nStep1: Navigate To Snapshot Collection  console=true
    Open Snapshot Collection


Step2: Collect System Critical Event Logs
    Log  \nStep2: Collect System Critical Event Logs  console=true
    Wait Until Element Is Clicked  //*[contains(text(), 'System critical event logs (SCREL)')]  60
    Log  Complete save location with local...  console=true
    Click Element  xpath://*[contains(text(), "Local")]
    Log  Save location was completed successfully!  console=true
    ${sbts_name}  Get Text  ${SBTS_NAME_XPATH}
    IF  '${ENB_BRANCH}' >= 'SBTS26R2'
        ${sbts_name}  Replace String  ${sbts_name}  ${SPACE}  _
    END
    Set Test Variable  ${SBTS_NAME}
    Remove File  /home/ute/Downloads/Snapshot_MRBTS-${BTS_ID}_${SBTS_NAME}_${ACTIVE_SW_VERSION}_*.zip
    Log  Collecting SCREL snapshot will be performed...  console=true
    Wait Until Element Is Clicked  //*[contains(@a-text, 'Collect SCREL')]  60
    Wait Until Element Is Visible  //*[contains(text(), "Collection completed")]  300
    Log  'Collection completed' text is visible!  console=true
    Wait Until Created  /home/ute/Downloads/SCREL_MRBTS-${BTS_ID}_${SBTS_NAME}_${ACTIVE_SW_VERSION}_*.zip  timeout=150s
    Move File  /home/ute/Downloads/SCREL_MRBTS-${BTS_ID}_${SBTS_NAME}_${ACTIVE_SW_VERSION}_*.zip
    ...  ${BTS_FILES}/SCREL_MRBTS-${BTS_ID}_${SBTS_NAME}_${ACTIVE_SW_VERSION}_snapshot.zip


Step3: Check Output Of SCREL Snapshot
    Log  \nStep3: Check Output Of SCREL Snapshot  console=true
    Unzip  ${BTS_FILES}/SCREL_MRBTS-${BTS_ID}_${SBTS_NAME}_${ACTIVE_SW_VERSION}_snapshot.zip  ${BTS_FILES}/screl_snapshot_dir/
    ${snapshot_file_list}  OperatingSystem.Get file  ${BTS_FILES}/screl_snapshot_dir/snapshot_file_list.txt
    ${matches}  Get Regexp Matches  ${snapshot_file_list}  BTS.*BinaryTracing_FRI_AlarmHistory_[0-9a-z]+.bro.xz
    IF  ${matches}
        Log  \nExist files with name BinaryTracing_FRI_AlarmHistory_ in snapshot  console=true
    ELSE
        Fail  Files with name BinaryTracing_FRI_AlarmHistory_ not exist in snapshot.[NOK]
    END
    ${list_of_directories}  OperatingSystem.List Directory  ${BTS_FILES}/screl_snapshot_dir/  pattern=BTS*.zip
    FOR  ${file}  IN  @{matches}
      ${parent_file}  Get Parent Directory Of File  ${list_of_directories}  ${file}
      IF  '${parent_file}'!='${None}'
          Log  \n${file} found in ${parent_file}  console=true
      ELSE
          Fail  File ${file} not found in snapshot.[NOK]
      END
    END


Get Parent Directory Of File
    [Arguments]  ${list_of_directories}  ${file}

    FOR  ${directory}  IN  @{list_of_directories}
        ${directory_name}  Fetch From Left  ${directory}  .zip
        Unzip  ${BTS_FILES}/screl_snapshot_dir/${directory}  ${BTS_FILES}/screl_snapshot_dir/${directory_name}_dir
        ${directory_content}  OperatingSystem.List Directory  ${BTS_FILES}/screl_snapshot_dir/${directory_name}_dir
        Remove Directory  ${BTS_FILES}/screl_snapshot_dir/${directory_name}_dir  true
        ${status}  Run Keyword And Return Status
        ...  List Should Contain Value  ${directory_content}  ${file}
        IF  ${status}  RETURN  ${directory_name}
    END


TC Setup
    Common Test Setup
    WebEM Setup


TC Teardown
    WebEM Teardown
    Common Test Teardown
