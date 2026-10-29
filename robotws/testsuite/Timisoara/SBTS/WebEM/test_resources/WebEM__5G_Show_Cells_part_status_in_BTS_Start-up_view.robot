*** Settings ***
Documentation
    ...  This test case is created to show cells part status in BTS Start-up view for 5G.
    ...  Verify if 5G cells exist.
    ...  Verify if all cells on SBTS are working.
    ...  Check BTS Start-up view for NR cells onAir to be Succeded.
    ...  Block on 5G cells will be performed.
    ...  Check NR cells blocking state to be Blocked and check BTS Start-up view for NR cells onAir to be Ongoing.
    ...  Unblock on 5G RAT will be performed.
    ...  Check NR cells blocking state to be Unlocked and check BTS Start-up view for NR cells onAir to be Succeded.
    ...  Lock RMOD with 5G cells will be performed.
    ...  Check NR cells availability status to be Dependency and check BTS Start-up view for NR cells onAir to be Ongoing.
    ...  Unlock RMOD with 5G cells will be performed.
    ...  Check NR cells availability status to be Online and check BTS Start-up view for NR cells onAir to be Succeded.
    ...  Reset RMOD with 5G cells will be performed.
    ...  Check NR cells availability status to be Failed and check BTS Start-up view for NR cells to be Failed.
    ...  Delete 5G RAT and check BTS Start-up view for NR cells to be N/A.
    ...  Restore 5G RAT and verify cells on SBTS to be Online.Check BTS Start-up view for NR Cells to be Succeeded.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${SCF_LWG}  ${EMPTY}  # Mandatory(path to SCF without 5G, eg. /home/ute/testline_configuration/10_18_UTESRANCLOUD1745/node1/SCF_LWG.xml)


*** Keywords ***
TC__WebEM__5G_Show_Cells_part_status_in_BTS_Start-up_view
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21410
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 27.05.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21410 - Initial TAT creation
    ...  - 14.09.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21880 - Update testcase
    ...  - 20.10.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22067 - Adapt WebEM TCs for CNI-61110
    ...  - 01.04.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22893 - Update Tx Channels position in Details tab
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  - 15.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24316 - Refactor WebEM TCs and resources to use KWs from ca_SBTS_general
    ...  - 10.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25214 - SCF path was changed
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring
    ...  - 08.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29529 - Navigation Menu has changed with software larger than 25R3

    Set Tags  CA-WebEM  OWNER-emina.stefanovici@nokia.com  AUTHOR-andreea.burtic@nokia.com; andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS21B  FEATURE-5GC001752

    Step1: Verify Cells On SBTS
    Step2: Check BTS Start-up View For 5G Cells OnAir
    Step3: Block 5G Cell And Check BTS Start-up View
    Step4: Lock RMOD With 5G Cells And Check BTS Start-up View
    Step5: Reset RMOD With 5G Cells And Check BTS Start-up View
    Step6: Delete 5G RAT And Check BTS Start-up View
    Step7: Restore 5G RAT And Verify Cells On SBTS


Step1: Verify Cells On SBTS
    ${status_scf}  Run Keyword And Return Status
    ...  Should Not Be Empty  ${SCF_LWG}
    IF  ${status_scf}
        Log  Path to SCF is provided, test should continue![OK]  console=true
    ELSE
        Fail  Please provide path to SCF without NR![NOK]
    END
    Log  Step1: Verify if 5G cells exist and SBTS is onAir  console=true
    IF  ${SCF_COUNT_NR}
        Log  NR cells exist!  console=true
    ELSE
        Fail  NR cells does not exist!
    END
    Check All Cells From WebEM


Step2: Check BTS Start-up View For 5G Cells OnAir
    Log  Step2: Check BTS Start-up view for 5G cells onAir  console=true
    BTS Start-up View For NR Cells  Succeeded


Step3: Block 5G Cell And Check BTS Start-up View
    Log  Step3: Block 5G cell and check BTS Start-up view  console=true
    Log  Blocking 5G cell is ongoing  console=true
    Block Cells  NR
    Wait Until Keyword Succeeds  600s  10s
    ...  Check NR Cells Blocking State To Be Blocked
    BTS Start-up View For NR Cells  Ongoing
    Log  Unblocking 5G cell is ongoing  console=true
    Unblock Cells  NR
    Wait Until Keyword Succeeds  600s  10s
    ...  Check NR Cells Blocking State To Be Unblocked
    Wait Until Keyword Succeeds  600s  10s
    ...  Check NR Cells Availability Status To Be Online|-
    BTS Start-up View For NR Cells  Succeeded


Step4: Lock RMOD With 5G Cells And Check BTS Start-up View
    Log  Step4: Lock RMOD with 5G cells and check BTS Start-up view  console=true
    ${rmod_list}  Get RMODS On NR Cells
    Set Xpath For RMODs With 5G Cells  ${RMODS_XPATH}  ${rmod_list}
    ${rmod_index}  Set Variable  0
    FOR  ${rmod_xpath}  IN  @{5_G_RMODS_XPATH}
        Log  Lock ${rmod_list}[${rmod_index}]  console=true
        Lock Module  ${rmod_xpath}
        ${rmod_index}  Evaluate  ${rmod_index}+1
    END
    Wait Until Keyword Succeeds  600  10
    ...  Check NR Cells Availability Status To Be Dependency|dependency
    BTS Start-up View For NR Cells  Ongoing
    ${rmod_index}  Set Variable  0
    FOR  ${rmod_xpath}  IN  @{5_G_RMODS_XPATH}
        Log  Unlock ${rmod_list}[${rmod_index}]  console=true
        Unlock Module  ${rmod_xpath}
        ${rmod_index}  Evaluate  ${rmod_index}+1
    END
    Wait Until Keyword Succeeds  600  10
    ...  Check NR Cells Availability Status To Be Online|-
    BTS Start-up View For NR Cells  Succeeded


Step5: Reset RMOD With 5G Cells And Check BTS Start-up View
    Log  Step5: Reset RMOD with 5G cells and check BTS Start-up view  console=true
    ${rmod_list}  Get RMODS On NR Cells
    ${rmod_index}  Set Variable  0
    FOR  ${rmod_xpath}  IN  @{5_G_RMODS_XPATH}
        Log  Reset ${rmod_list}[${rmod_index}]  console=true
        Reset RMOD  ${rmod_xpath}
        Sleep  15s
        ${rmod_index}  Evaluate  ${rmod_index}+1
    END
    Wait Until Keyword Succeeds  600  10
    ...  Check NR Cells Availability Status To Be Failed|failed
    BTS Start-up View For NR Cells  Failed
    Wait Until Keyword Succeeds  600  10
    ...  Check NR Cells Availability Status To Be Online|-
    BTS Start-up View For NR Cells  Succeeded


Step6: Delete 5G RAT And Check BTS Start-up View
    Log  Step6: Delete 5G RAT and check BTS Start-up view  console=true
    ${rat_changed}  Run Keyword And Return Status
    ...  Admin Get Bts_id And Perform Commissioning  ${SCF_LWG}
    IF  ${rat_changed}==${FALSE}
        Set Test Failed  Loading Scf without 5G is failed.[NOK]
        RETURN
    END
    Close BTS Start-up View
    Wait Until Keyword Succeeds  600s  10s
    ...  Check LTE,WCDMA,GSM Cells  ${ENABLED}
    Sleep  20s
    BTS Start-up View For NR Cells  N/A


Step7: Restore 5G RAT And Verify Cells On SBTS
    Log  Step7: Restore 5G RAT and verify cells on SBTS  console=true
    Admin Get Bts_id And Perform Commissioning  ${COMMISSIONING_PATH}
    Close BTS Start-up View
    Wait Until Keyword Succeeds  800s  10s
    ...  Check All Cells
    Sleep  20s
    BTS Start-up View For NR Cells  Succeeded


Check NR Cells Blocking State To Be ${state}
    ${cells_status}  Get States For Cells In RAT  NR
    FOR  ${cell}  IN  @{cells_status.keys()}
        Should Be Equal  ${cells_status}[${cell}][Blocking state]  ${state}
    END


Check NR Cells Availability Status To Be ${state}
    ${cells_status}  Get States For Cells In RAT  NR
    FOR  ${cell}  IN  @{cells_status.keys()}
        Should Match Regexp  ${cells_status}[${cell}][Availability status]  ${state}
    END


BTS Start-up View For NR Cells
    [Arguments]  ${5g_status}

    Open BTS Start-up View pop-up
    ${status_text}  Catenate  SEPARATOR=  xpath:/html/body/div[1]/div/div/ui-modal-renderer/bts-status-modal/ui-modal
    ...  /div/div/div[2]/div/ui-body/div/div[4]/div/div[4]/div[1]/span
    ${5_g_rat_status}  Get Text  ${status_text}
    IF  '${5_g_rat_status}'=='${5_g_status}'
        Log  5G Cells status in BTS start-up view is ${5_g_rat_status} (as expected)!  console=true
    ELSE
        Fail  5G Cells status in BTS start-up view is ${5_g_rat_status} (not as expected)!
    END
    ${button}  Catenate  SEPARATOR=  xpath:/html/body/div[1]/div/div/ui-modal-renderer/bts-status-modal/ui-modal
    ...  /div/div/div[3]/div/ui-footer/div/ui-button/button
    Click Element  ${button}
    IF  '${ENB_BRANCH}' < 'SBTS25R3'
        Run Keyword And Ignore Error  Click Element  //*[contains(@class, 'p-menuitem-text') and contains(text(), 'Status')]
    END
    IF  '${GUI_VERSION}' == 'new' and '${ENB_BRANCH}' < 'SBTS25R3'  Open/Close Menus Tab


Check LTE,WCDMA,GSM Cells
    [Arguments]  ${operational_state}

    IF  ${SCF_COUNT_WCDMA}  Assert Every  WNCEL  operationalState=${operational_state}  timeout=60
    IF  ${SCF_COUNT_LTE}  Assert Every  LNCEL  operationalState=${operational_state}  timeout=60
    IF  ${SCF_COUNT_GSM}  Assert Every  GNCEL  operationalState=${operational_state}  timeout=60


Set Xpath For RMODs With 5G Cells
    [Arguments]  ${grid_block_xpath}  ${rmods_list}

    ${5_g_rmods_xpath}  Create List
    Set Test Variable  ${5_G_RMODS_XPATH}
    FOR  ${grid_path}  IN  @{grid_block_xpath}
        ${rmod_index}  Get Text  ${grid_path}/div/div[3]/div[2]/div[2]
        ${rmod_status}  Run Keyword And Return Status
        ...  List Should Contain Value  ${rmods_list}  ${rmod_index}
        IF  ${rmod_status}  Append To List  ${5_G_RMODS_XPATH}  ${grid_path}
    END


Get RMODS On NR Cells
    ${rmods_list}  Create List
    ${rmods_on_nr_cells}  Create List
    ${table_position_mapping}  Create Dictionary  NR=7
    ${table_position}  Set Variable  ${table_position_mapping}[NR]
    ${table_size}  SeleniumLibrary.Get Element Count  class:trx-table-body
    ${rat_table_lines}  Set Variable  ${table_size}
    FOR  ${element}  IN  @{NR_CELLS_XPATH}
        Click Element  ${element}
        ${rmod_table_list}  TX Channels Table  ${table_position}  ${rat_table_lines}
        Append To List  ${rmods_on_nr_cells}  @{rmod_table_list}
    END
    ${rmods_list}  Remove Duplicates  ${rmods_on_nr_cells}

    [Return]  ${rmods_list}


TX Channels Table
    [Arguments]  ${table_index}  ${rat_table_size}

    ${rmods_name}  Create List
    ${position}  Set Variable  4
    ${table_text}  Catenate  SEPARATOR=  //*[contains(@class, "details-panel-container")]/wf-panel/wf-panel-section
    ...  /div/div/details-panel-content/div/hardware-details/div/div/div[1]/div/div/div[3]/div/div[${table_index}]
    ${status}  Get Text  ${table_text}
    ${status_regex}  Run Keyword And Return Status
    ...  Should Match Regexp  ${status}  ^TX Channels
    ${table_index}  Set Variable If  ${status_regex}==${FALSE}  ${${table_index}+1}  ${table_index}
    ${position}  Set Variable If  ${status_regex}==${FALSE}  ${${position}-1}  ${position}
    Click Element  xpath=//*[contains(@index, 'tabsContainer.info.id')]
    FOR  ${table_line}  IN RANGE  1  ${rat_table_size}+1
        ${table_text}  Catenate  SEPARATOR=  //*[contains(@class, "details-panel-container")]/wf-panel
        ...  /wf-panel-section/div/div/details-panel-content/div/hardware-details/div/div/div[1]/div/div/div[3]/div/
        ...  div[${table_index}]/div/div/div/ui-table/div/ng-transclude/table/tbody/tr[${table_line}]/td[${position}]
        ${state}  Get Text  ${table_text}
        ${rmod_value}  Fetch From Left  ${state}  /
        Append To List  ${rmods_name}  ${rmod_value}
    END

    [Return]  ${rmods_name}


Reset RMOD
    [Arguments]  ${rmod_xpath}

    Click Element  ${rmod_xpath}
    ${reset}  Catenate  SEPARATOR=  //*[contains(@class, "details-panel-container")]/wf-panel/wf-panel-section
    ...  /div/div/details-panel-content/div/hardware-details/div/div/div[1]/div/div/div[2]/div[2]/actions-buttons/span[1]/ui-button/button
    Wait Until Element Is Enabled  ${reset}  600
    Click Element  ${reset}
    Click Element  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[1]/button


TC Setup
    Common Test Setup  tc_name=WebEM__5G_Show_Cells_part_status_in_BTS_Startup_view
    WebEM Setup


TC Teardown
    WebEM Teardown
    Common Test Teardown
