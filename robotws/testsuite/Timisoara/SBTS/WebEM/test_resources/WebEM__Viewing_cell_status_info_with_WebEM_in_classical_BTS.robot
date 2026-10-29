*** Settings ***
Documentation
    ...  This test case is created to check both barringStatus and cellBarred information is present in "status" when opening cell detailed view.
    ...  BarringStatus info is labelled as "Barring Status due to unavailability of NG links or slices" and cellBarred as "Cell Barred".
    ...  This tc running on clasical BTS with 5G cells.
    ...  One cell is choose random and check parameters in Runtime View->Site View and Runtime View->Cell.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__Viewing_cell_status_info_with_WebEM_in_classical_BTS
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28284
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28284 - Initial TAT creation
    ...  - 21.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29755 - Xpath for cells tab was changed in trunk

    Set Tags  CA-WebEM  OWNER-nicolae-marcel.caragel@nokia.com  AUTHOR-cristina.adam@nokia.com  MAINTAINER-cristina.adam@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS24  FEATURE-CB011129

    Step1: Verify Cells On SBTS
    Step2: Navigate To Site View And Check BarringStatus And CellBarred Parameters
    Step3: Navigate To Runtime View-Cell And Check BarringStatus And CellBarred Parameters


Step1: Verify Cells On SBTS
    Log  \nStep1: Verify cells on SBTS  console=true
    Log  Verify if NR cells exist  console=true
    IF  ${SCF_COUNT_NR}
        Log  NR cells exist![OK]  console=true
    ELSE
        Fail  This SBTS doesn't have 5G cells, please perform the test on an SBTS with 5G cells!
    END


Step2: Navigate To Site View And Check BarringStatus And CellBarred Parameters
    Log  \nStep2: Navigate To Site View And Check BarringStatus And CellBarred Parameters  console=true
    Go To Site View
    ${xpaths_cells}  Get Xpath List For Cells  NR
    ${nr_cell_chosen}  Evaluate  random.choice(${xpaths_cells})  random
    Wait Until Element Is Clicked  ${nr_cell_chosen}  120
    Check BarringStatus And CellBarred Parameters


Step3: Navigate To Runtime View-Cell And Check BarringStatus And CellBarred Parameters
    Log  \nStep3: Navigate To Runtime View-Cell And Check BarringStatus And CellBarred Parameters  console=true
    Go To Site View
    IF  '${ENB_BRANCH}' >= 'SBTS26R1'
        Wait Until Element Is Clicked
        ...  //*[@id="main-view"]/div/div[1]/div/div/div[1]/ng-view/wf-panel/wf-panel-section/div/div/site-runtime-views/div/ul/li[4]/a  60
    ELSE
        Wait Until Element Is Clicked
        ...  //*[@id="main-view"]/div/div[1]/div[1]/div/ng-view/wf-panel/wf-panel-section/div/div/site-runtime-views/div/ul/li[4]  60
    END
    ${nr_cell_chosen}  Get Xpath For Nr Cell
    Wait Until Element Is Clicked  ${nr_cell_chosen}  120
    Check BarringStatus And CellBarred Parameters


Check BarringStatus And CellBarred Parameters
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  30  5
    ...  Element Should Be Visible  //div[@class="details-panel-container"]/ui-button/button/i[@class="fa fa-list-ul"]
    IF  ${status}
        Wait Until Element Is Clicked  //div[@class="details-panel-container"]/ui-button/button/i[@class="fa fa-list-ul"]  60
    ELSE
        Log  \nDetails panel is open  console=true
    END
    ${barring_status_parameter}  Get Text  xpath=//div[@class="details-info-body"]/div/div[5]/div/div/div/table/tbody/tr[7]/td[1]
    Should Be Equal  ${barring_status_parameter}  Barring status due to unavailability of NG links or slices:
    Log  \nBarringStatus parameter is 'Barring status due to unavailability of NG links or slices:'  console=true
    ${cell_barred_parameter}  Get Text  xpath=//div[@class="details-info-body"]/div/div[5]/div/div/div/table/tbody/tr[8]/td[1]
    Should Be Equal  ${cell_barred_parameter}  Cell Barred:
    Log  \nCellBarred parameter is 'Cell Barred:'  console=true


Get Xpath For Nr Cell
    ${count_object}  SeleniumLibrary.Get Element Count  //*[@class="tab-pane ng-scope active"]/div[2]/div[1]/div/div/div
    FOR  ${index}  IN RANGE  1  ${count_object}+1
      ${cell_name}  Get Text  xpath=//*[@class="tab-pane ng-scope active"]/div[2]/div[1]/div/div/div[${index}]/div/div[2]/div/div[1]/span
      ${status}  Run Keyword And Return Status  Should Contain  ${cell_name}  NRCELL
      IF  ${status}  RETURN  //*[@class="tab-pane ng-scope active"]/div[2]/div[1]/div/div/div[${index}]/div
    END


TC Setup
    Common Test Setup
    WebEM Setup


TC Teardown
    WebEM Teardown
    Common Test Teardown
