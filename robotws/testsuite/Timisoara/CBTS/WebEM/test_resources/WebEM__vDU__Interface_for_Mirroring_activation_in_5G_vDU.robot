*** Settings ***
Documentation
    ...  The purpose of this test case is to activating the L1-L2 egress Ingress data or L2Hi-L2Lo egress ingress data collection.
    ...  The user opens the WebEm and enters the configuration menu for the mirroring.
    ...  The below parameters shall be possible to be configured from the WebEm:
    ...  - Select the interface to be monitored. L1-L2 Egress and Ingress OR L2 Hi-L2 Lo Egress and Ingress
    ...  - Cell Id: It shall be possible to select from 1 to 8 cells for collecting the mirrored data.
    ...  - Destination: Local.
    ...  - User configures the Mirroring Time.
    ...  - User clicks start mirroring.
    ...  Check parameters in 'Interface Mirroring Overview Status' to be Interface:L1-L2/L2Hi-L2Lo, Cell ID:Same Cells that are configured,
    ...  Mirroring Mode:Store locally and Status:active(succeeded).
    ...  After Mirroring Time, interface mirroring is stopped.
    ...  User checks output of mirroring logs contain MRBTS.*.pcap.gz file.

Resource  ../resources/vdu_WebEM_general.robot
Resource  ../../common_resources/vdu_frame.robot


*** Keywords ***
TC__WebEM__vDU__Interface_for_Mirroring_activation_in_5G_vDU
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28286
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 02.12.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28286 - Initial TAT creation

    Set Tags  CA-WebEM  OWNER-nicolae-marcel.caragel@nokia.com@nokia.com  AUTHOR-cristina.adam@nokia.com  MAINTAINER-cristina.adam@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  FEATURE-CB009095

    Step1: Open Interface Mirroring And Start Mirroring Test With L1-L2
    Step2: Collect Logs And Check Output Of Mirroring Logs
    Step3: Start Mirroring Test With L2Hi-L2Lo
    Step4: Collect Logs And Check Output Of Mirroring Logs


Step1: Open Interface Mirroring And Start Mirroring Test With L1-L2
    Log  \nStep1: Open Interface Mirroring And Start Mirroring Test With L1-L2  console=true
    Wait Until Keyword Succeeds  120  5
    ...  Mouse Over  //*[contains(@data-menu-header, "Diagnostic")]
    Wait Until Keyword Succeeds  120  5
    ...  Mouse Over  //*[contains(@class, 'p-menuitem-text') and contains(text(), 'Interface Mirroring')]
    Click Element  //*[contains(@class, 'p-menuitem-text') and contains(text(), 'Interface Mirroring')]
    Start Interface Mirroring Test With L1-L2
    Check Interface Mirroring Overview Status  L1-L2
    Sleep  11s  msg=Wait stop interface mirroring


Step${index}: Collect Logs And Check Output Of Mirroring Logs
    Log  \nStep${index}: Collect Logs And Check Output Of Mirroring Logs  console=true
    Remove File  /home/ute/Downloads/mirroringLogs_*.*zip
    Wait Until Element Is Clicked  //span[contains(text(), "Collect Logs")]  120
    Wait Until Element Is Visible  //span[contains(text(), "Success")]  300
    Log  \nCollect Logs  console=true
    Wait Until Created  /home/ute/Downloads/mirroringLogs_*.zip  timeout=120s
    Move File  /home/ute/Downloads/mirroringLogs_*.zip  ${TEST_RESULTS_DIR}/mirroringLogs_${index}.zip
    Unzip  ${TEST_RESULTS_DIR}/mirroringLogs_${index}.zip  ${TEST_RESULTS_DIR}/mirroringLogs_dir/
    ${snapshot_file_list}  OperatingSystem.Get file  ${TEST_RESULTS_DIR}/mirroringLogs_dir/snapshot_file_list.txt
    ${matches}  Get Regexp Matches  ${snapshot_file_list}  MRBTS.*.pcap.gz
    Run Keyword If  ${matches}
    ...  Log  \nExist files with name MRBTS.*.pcap.gz in snapshot  console=true
    ...  ELSE
    ...  Fail  Files with name MRBTS.*.pcap.gz not exist in snapshot.[NOK]
    Remove Directory  ${TEST_RESULTS_DIR}/mirroringLogs_dir  true


Step3: Start Mirroring Test With L2Hi-L2Lo
    Log  \nStep3: Start Mirroring Test With L2Hi-L2Lo  console=true
    Wait Until Element Is Clicked
    ...  //*[@id="laf-component"]/blocks-interface-mirroring/div/div[1]/div/p-panel/div/div[2]/div/form/ot-field[1]/div/div/p-dropdown  120
    Wait Until Element Is Clicked  //*[contains(text(), "L2Hi-L2Lo")]  120
    Wait Until Element Is Clicked  ${START_BUTTON}  120
    Wait Until Element Is Visible  //*[contains(text(), "Start interface mirroring test success")]  120
    Check Interface Mirroring Overview Status  L2Hi-L2Lo
    Sleep  11s  msg=Wait for stop interface mirroring


Start Interface Mirroring Test With L1-L2
    Wait Until Element Is Clicked
    ...  //*[@id="laf-component"]/blocks-interface-mirroring/div/div[1]/div/p-panel/div/div[2]/div/form/ot-field[1]/div/div/p-dropdown  120
    Wait Until Element Is Clicked  //*[contains(text(), "L1-L2")]  120
    Wait Until Element Is Clicked  //*[contains(text(), "Select Max 8 cells")]  120
    ${select_cell}  Catenate  SEPARATOR=  //*[@id="laf-component"]/blocks-interface-mirroring/div/div[1]/div/p-panel/div/div[2]/div/form/div/div
    ...  /ot-field[2]/p-multiselect
    Wait Until Element Is Clicked  ${select_cell}  120
    ${cell_xpath}  Catenate  SEPARATOR=  //*[@id="laf-component"]/blocks-interface-mirroring/div/div[1]/div/p-panel/div/div[2]/div/form/div/div
    ...  /ot-field[2]/p-multiselect/div/div[4]/div[2]/ul/p-multiselectitem/li
    Wait Until Element Is Clicked  ${cell_xpath}  120
    ${cell_text}  Get Text  ${cell_xpath}
    ${CELL_NAME}  Fetch From Left  ${cell_text}  ${SPACE}(
    Set Test Variable  ${CELL_NAME}
    ${mirroring_time}  Catenate  SEPARATOR=  //*[@id="laf-component"]/blocks-interface-mirroring/div/div[1]/div/p-panel/div/div[2]/div/form/
    ...  ot-field[3]/div[1]/ot-input-number/span/input
    Input Text  ${mirroring_time}  11
    ${START_BUTTON}  Catenate  SEPARATOR=  //*[@id="laf-component"]/blocks-interface-mirroring/div/div[1]/div/p-panel/div/div[2]/div/div[1]/
    ...  cem-operation-button/div/div/p-button[1]/button/span
    Set Test Variable  ${START_BUTTON}
    Wait Until Element Is Clicked  ${START_BUTTON}  120
    Wait Until Element Is Visible  //*[contains(text(), "Start interface mirroring test success")]  120


Check Interface Mirroring Overview Status
    [Arguments]  ${interface}

    ${interface_text}  Get Text  //*[@id="interface-mirroring-configuration-table"]/div/div/table/tbody/tr/td[1]
    Should Contain  ${interface_text}  ${interface}
    ${cells_text}  Get Text  //*[@id="interface-mirroring-configuration-table"]/div/div/table/tbody/tr/td[2]
    Should Contain  ${cells_text}  ${CELL_NAME}
    ${destination_text}  Get Text  //*[@id="interface-mirroring-configuration-table"]/div/div/table/tbody/tr/td[3]
    Should Contain  ${destination_text}  local
    ${status_text}  Get Text  //*[@id="interface-mirroring-configuration-table"]/div/div/table/tbody/tr/td[5]
    Should Contain  ${status_text}  active(succeeded)


TC Setup
    Common VDU Setup
    VDU WebEM Setup
    Modify Resource Search Order  WebEM__vDU__Interface_for_Mirroring_activation_in_5G_vDU


TC Teardown
    Remove Directory  ${TEST_RESULTS_DIR}/mirroringLogs_dir  true
    VDU WebEM Teardown
    Common VDU Teardown
