*** Settings ***
Documentation
    ...  The purpose of this test case is to activation of event based IQ capture and L1-L2 interface mirroring in parallel for Cloud gNB.
    ...  This user scenario details the process to activate L1-L2 mirroring in parallel with event triggered IQ sample for NR.
    ...  User configures IQ event based trace collection parameters in WebEm.
    ...  User configures the cells to be traced in the IQ trace collection window.
    ...  User starts event based IQ capture in WebEM.
    ...  User starts L1-L2 mirroring in parallel to event based IQ sample by pressing the “Start parallel L1-L2 Mirroring” button.
    ...  Check parameters in 'Interface Mirroring Overview Status' to be Interface:L1-L2, Cell ID:Same Cells that are configured for collecting event
    ...  based IQ samples, Mirroring Mode:Store locally and Status:active(succeeded).
    ...  Stop and Clear IQ event sample collection manually from WebEM.
    ...  The IQ samples and L1-L2 logs are collected in parallel.
    ...  User checks output of mirroring logs contain MRBTS.*.pcap.gz file.


Resource  ../resources/vdu_WebEM_general.robot
Resource  ../../common_resources/vdu_frame.robot


*** Keywords ***
TC__WebEM__vDU__Activation_of_Event_Based_IQ_capture_and_L1_L2_interface_mirroring_in_parallel_for_Cloud_gNB
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28285
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 26.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28285 - Initial TAT creation

    Set Tags  CA-WebEM  OWNER-nicolae-marcel.caragel@nokia.com@nokia.com  AUTHOR-cristina.adam@nokia.com  MAINTAINER-cristina.adam@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  FEATURE-CB009095

    Step1: Open User Plane Traces And Enable L1 IQ Capture
    Step2: Select Cells And Apply Configuration
    Step3: Start Parallel L1-L2 Mirroring
    Step4: Open Interface Mirroring And Stop Interface Mirroring
    Step5: Collect Logs And Check Output Of Mirroring Logs


Step1: Open User Plane Traces And Enable L1 IQ Capture
    Log  \nStep1: Open User Plane Traces And Enable L1 IQ Capture  console=true
    Wait Until Keyword Succeeds  120  5
    ...  Mouse Over  //*[contains(@data-menu-header, "Diagnostic")]
    Wait Until Keyword Succeeds  120  5
    ...  Mouse Over  //*[contains(@class, 'p-menuitem-text') and contains(text(), 'User Plane Traces')]
    Click Element  //*[contains(@class, 'p-menuitem-text') and contains(text(), 'User Plane Traces')]
    Wait Until Element Is Clicked  //*[contains(@class, 'p-menuitem-text') and contains(text(), 'User Plane Traces - L1 IQ Capture')]  120
    Wait Until Element Is Clicked  //*[contains(@class, 'cem-block-panel-content')]/form/ot-field[1]/p-checkbox  120
    Wait Until Element Is Visible  //*[contains(text(), "Please configure suspicious events")]  60
    Log  \nEnable capture on event  console=true


Step2: Select Cells And Apply Configuration
    Log  \nStep2: Select Cells And Apply Configuration  console=true
    Wait Until Element Is Clicked  //*[contains(@class, 'cem-block-panel-content')]/form/fieldset/ot-field[1]/div/div  120
    Wait Until Element Is Clicked  xpath:/html/body/div[2]/div[2]/ul/p-multiselectitem/li  120
    ${cell_text}  Get Text  xpath:/html/body/div[2]/div[2]/ul/p-multiselectitem/li
    ${CELL_NAME}  Fetch From Left  ${cell_text}  :Subcell
    ${CELL_NAME}  Fetch From Right  ${CELL_NAME}  ]
    Set Test Variable  ${CELL_NAME}
    Wait Until Element Is Clicked  //*[contains(@class, 'cem-block-panel-content')]/form/fieldset/ot-field[1]/div/div  120
    Wait Until Element Is Clicked  //*[contains(@class, 'cem-block-panel-content')]/form/fieldset/ot-field[2]/div/div  120
    Wait Until Element Is Clicked  xpath:/html/body/div[2]/div[2]/ul/p-multiselectitem/li  120
    Wait Until Element Is Clicked  //*[contains(text(), "Apply Configuration")]  120
    Wait Until Element Is Visible  //*[contains(text(), "Success")]  60
    Log  \nCell selected and button 'Apply Configuration' is press  console=true


Step3: Start Parallel L1-L2 Mirroring
    Log  \nStep3: Start Parallel L1-L2 Mirroring  console=true
    Wait Until Element Is Clicked
    ...  //*[contains(@class, 'cem-block-panel-content')]/form/div/p-panel/div/div[2]/div/cem-operation-button/div/div/p-button/button  120
    Wait Until Element Is Visible  //*[contains(text(), "Start parallel L1-L2 mirroring test success")]  60
    Log  \nStart parallel L1-L2 mirroring test success  console=true


Step4: Open Interface Mirroring And Stop Interface Mirroring
    Log  \nStep4: Open Interface Mirroring And Stop Interface Mirroring  console=true
    Wait Until Keyword Succeeds  120  5
    ...  Mouse Over  //*[contains(@data-menu-header, "Diagnostic")]
    Wait Until Keyword Succeeds  120  5
    ...  Mouse Over  //*[contains(@class, 'p-menuitem-text') and contains(text(), 'Interface Mirroring')]
    Click Element  //*[contains(@class, 'p-menuitem-text') and contains(text(), 'Interface Mirroring')]
    Check Interface Mirroring Overview Status
    ${stop_button}  Catenate  SEPARATOR=  //*[@id="laf-component"]/blocks-interface-mirroring/div/div[1]/div/p-panel/div/div[2]/div/div[1]/
    ...  cem-operation-button/div/div/p-button[2]
    Wait Until Element Is Clicked  ${stop_button}  120
    Wait Until Element Is Visible  //*[contains(text(), "Stop interface mirroring test success")]  120
    Log  \nStop interface mirroring test success  console=true


Step5: Collect Logs And Check Output Of Mirroring Logs
    Log  \nStep5: Collect Logs And Check Output Of Mirroring Logs  console=true
    Remove File  /home/ute/Downloads/mirroringLogs_*.*zip
    Wait Until Element Is Clicked  //*[contains(text(), "Collect Logs")]  120
    Wait Until Element Is Visible  //*[contains(text(), "Success")]  300
    Log  \nCollect Logs  console=true
    Wait Until Created  /home/ute/Downloads/mirroringLogs_*.zip
    Move File  /home/ute/Downloads/mirroringLogs_*.zip  ${TEST_RESULTS_DIR}/mirroringLogs.zip
    Unzip  ${TEST_RESULTS_DIR}/mirroringLogs.zip  ${TEST_RESULTS_DIR}/mirroringLogs_dir/
    ${snapshot_file_list}  OperatingSystem.Get file  ${TEST_RESULTS_DIR}/mirroringLogs_dir/snapshot_file_list.txt
    ${matches}  Get Regexp Matches  ${snapshot_file_list}  MRBTS.*.pcap.gz
    Run Keyword If  ${matches}
    ...  Log  \nExist files with name MRBTS.*.pcap.gz in snapshot  console=true
    ...  ELSE
    ...  Fail  Files with name MRBTS.*.pcap.gz not exist in snapshot.[NOK]


Check Interface Mirroring Overview Status
    ${interface_text}  Get Text  //*[@id="interface-mirroring-configuration-table"]/div/div/table/tbody/tr/td[1]
    Should Contain  ${interface_text}  L1-L2
    ${cells_text}  Get Text  //*[@id="interface-mirroring-configuration-table"]/div/div/table/tbody/tr/td[2]
    Should Contain  ${cells_text}  ${CELL_NAME}
    ${destination_text}  Get Text  //*[@id="interface-mirroring-configuration-table"]/div/div/table/tbody/tr/td[3]
    Should Contain  ${destination_text}  local
    ${status_text}  Get Text  //*[@id="interface-mirroring-configuration-table"]/div/div/table/tbody/tr/td[5]
    Should Contain  ${status_text}  active(succeeded)


TC Setup
    Common VDU Setup
    VDU WebEM Setup
    Modify Resource Search Order  WebEM__vDU__Activation_of_Event_Based_IQ_capture_and_L1_L2_interface_mirroring_in_parallel_for_Cloud_gNB


TC Teardown
    Remove Directory  ${TEST_RESULTS_DIR}/mirroringLogs_dir  true
    VDU WebEM Teardown
    Common VDU Teardown
