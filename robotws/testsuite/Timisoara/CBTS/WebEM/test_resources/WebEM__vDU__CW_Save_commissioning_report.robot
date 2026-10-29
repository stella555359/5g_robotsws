*** Settings ***
Documentation
    ...  Open Commissioning Wizard menu and verify if the page is fully loaded.
    ...  Create plan and activate the plan.
    ...  Wait until all cells are onAir.
    ...  Save report and check the commissioning report content.
    ...  Check the files from saved zip.
    ...  Change btsName into 11575VDU_% and activate the plan.
    ...  Save Report And Check The Commissioning Report Content With btsName 11575VDU_%.
    ...  Check The Files From Saved Zip With btsName 11575VDU_%.
    ...  Load Initial Configuration.

Library  ../../common_resources/python_resources/extract.py
Resource  ../resources/vdu_WebEM_general.robot
Resource  ../../common_resources/vdu_frame.robot


*** Variables ***
${RECOVERY_TIMEOUT}  900  # Time for CBTS to recover


*** Keywords ***
TC__WebEM__vDU__CW_Save_commissioning_report
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26781
    ...
    ...  ******************
    ...  - 07.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26781 - Initial TAT creation
    ...  - 26.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28926 - btsName set with special character % and verify saved files name

    Set Tags  CA-WebEM  OWNER-giorgia.toth@nokia.com  AUTHOR-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf  SW-vDUCNF24  FEATURE-CB005866-E

    Step1: Open Commissioning Wizard
    Step2: Create Plan And Activate The Plan
    Step3: Save Report And Check The Commissioning Report Content With btsName ${VDU_MRBTS_NAME}
    Step4: Check The Files From Saved Zip With btsName ${VDU_MRBTS_NAME}
    Step5: Change btsName And Activate The Plan
    Step6: Save Report And Check The Commissioning Report Content With btsName 11575VDU_%
    Step7: Check The Files From Saved Zip With btsName 11575VDU_%
    Step8: Load Initial Configuration


Step1: Open Commissioning Wizard
    Log  \nStep1: Open Commissioning Wizard  console=true
    Open Commissioning Wizard


Step2: Create Plan And Activate The Plan
    Log  \nStep2: Create plan and activate the plan  console=true
    Create Duplicate Plan For CBTS
    Log  Duplicate plan from current plan was performed!  console=true
    Sleep  30s  Time for plan to be updated!
    Validate And Activate Plan For Unified CBTS
    Log  Waiting for cells to be back Enabled and Online  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Check All Cells From VDU  operational_state=${ENABLED}  availability_status=${ONLINE}
    Log  Cells are back Enabled and Online![OK]  console=true


Step${index}: Save Report And Check The Commissioning Report Content With btsName ${bts_name_value}
    Log  \nStep${index}: Save report and check the commissioning report content with btsName ${bts_name_value}  console=true
    Verify Commissioning Report  ${bts_name_value}
    Wait Until Element Is Clicked  //*[@id="commissioningReportDialog"]/p-dialog/div/div/div[3]/ot-footer/div/p-button[1]/button/span
    ${date_for_zip}  Get Current Date  result_format=%Y%m%d
    Set Test Variable  ${DATE_FOR_ZIP}
    Wait Until Created  /home/ute/Downloads/vDU_Commissioning_Report_MRBTS-${VDU_MRBTS_ID}_${bts_name_value}_${DATE_FOR_ZIP}-*.zip  timeout=120s
    Move File  /home/ute/Downloads/vDU_Commissioning_Report_MRBTS-${VDU_MRBTS_ID}_${bts_name_value}_${DATE_FOR_ZIP}-*.zip
    ...  ${TEST_RESULTS_DIR}/vDU_Commissioning_Report_MRBTS-${VDU_MRBTS_ID}_${bts_name_value}_${DATE_FOR_ZIP}.zip
    Log  The report was saved in location ${TEST_RESULTS_DIR}/vDU_Commissioning_Report_MRBTS-${VDU_MRBTS_ID}_${bts_name_value}_${DATE_FOR_ZIP}.zip
    ...  console=true
    Wait Until Element Is Clicked  //*[@id="commissioningReportDialog"]/p-dialog/div/div/div[3]/ot-footer/div/p-button[2]/button/span


Step${index}: Check The Files From Saved Zip With btsName ${bts_name_value}
    Log  \nStep${index}: Check the files from saved zip with btsName ${bts_name_value}  console=true
    Unzip  ${TEST_RESULTS_DIR}/vDU_Commissioning_Report_MRBTS-${VDU_MRBTS_ID}_${bts_name_value}_${DATE_FOR_ZIP}.zip  ${TEST_RESULTS_DIR}/Report_files
    OperatingSystem.File Should Exist
    ...  ${TEST_RESULTS_DIR}/Report_files/SCF.xml
    Log  SCF.xml exist in Report_files folder![OK]  console=true
    OperatingSystem.File Should Exist  ${TEST_RESULTS_DIR}/Report_files/Parameter_consistency_data.csv
    Log  Parameter consistency data csv exist in Report_files folder![OK]  console=true
    OperatingSystem.File Should Exist  ${TEST_RESULTS_DIR}/Report_files/Report_data.txt
    Log  Report data txt exist in Report_files folder![OK]  console=true
    Verify Report Files  ${bts_name_value}


Step5: Change btsName And Activate The Plan
    Log  \nStep5: Change btsName And Activate The Plan  console=true
    Create Duplicate Plan For CBTS
    Log  Duplicate plan from current plan was performed!  console=true
    Sleep  30s  Time for plan to be updated!
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'General Site Settings')]
    ${bts_name_path}  Catenate  SEPARATOR=  //*[contains(@class, "step-content")]/blocks-steps-general-site-setting/div/div[1]/p-panel/div/div[2]/div
    ...  /cem-parameter-editor-table/div/p-treetable/div/div[1]/div/div/table/tbody/tr[1]/td[2]
    ...  /cem-parameter-input/cem-string-input/ot-field/div/input
    ${initial_name_value}  Get Value  ${bts_name_path}
    Wait Until Keyword Succeeds  30s  2s
    ...  Input Text  ${bts_name_path}  11575VDU_%
    Sleep  3s  Time for parameter to be changed.
    ${changed_name_value}  Get Value  ${bts_name_path}
    Should Be Equal  ${changed_name_value}  11575VDU_%
    Log  BTS name was changed with value 11575VDU_%, initial value was ${initial_name_value}!  console=true
    Save Plan From Commissioning Wizard
    Validate And Activate Plan For Unified CBTS
    Log  Waiting for cells to be back Enabled and Online  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Check All Cells From VDU  operational_state=${ENABLED}  availability_status=${ONLINE}
    Log  Cells are back Enabled and Online![OK]  console=true


Step8: Load Initial Configuration
    Log  \nStep8: Load Initial Configuration  console=true
    Load Initial SCF And Verify VDU To Be onAir


Load Initial SCF And Verify VDU To Be onAir
    vdu.Perform Commissioning  ${VDU_SCF_PATH}
    Wait Until Element Is Visible  //*[@id="Close"]/button  300s
    Click Element  //*[@id="Close"]/button
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Verify RMODs Parameter From VDU  operational_state  ${ENABLED}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Verify RMODs Parameter From VDU  availability_status  ${ONLINE}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Verify RMODs Parameter From VDU  administrative_state  ${UNLOCKED}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Check All Cells From VDU  operational_state=${ENABLED}  availability_status=${ONLINE}  administrative_state=${UNLOCKED}
    Log  All services are operational after valid SCF actvation. [OK]  console=true


Verify Commissioning Report
    [Arguments]  ${bts_name_parameter}

    ${date_for_report}  Get Current Date  result_format=%d.%m.%Y
    Set Test Variable  ${DATE_FOR_REPORT}
    Wait Until Element Is Clicked  //*[@icon="mdi mdi-file-document"]/button
    Log  Save report button is pushed!  console=true
    Log  Verify Commissioning Report  console=true
    ${activation_time}  Get Text  //*[contains(@class, "p-accordion p-component")]/p-accordiontab[1]/div/div[2]/div/div[1]/span
    Should Start With  ${activation_time}  ${DATE_FOR_REPORT}  ${DATE_FOR_REPORT} is not visible in Commissioning Report![NOK]
    Log  ${DATE_FOR_REPORT} is visible in Commissioning Report![OK]  console=true
    ${user}  Get Text  //*[contains(@class, "p-accordion p-component")]/p-accordiontab[1]/div/div[2]/div/div[2]/span
    Should Be Equal  ${user}  Nemuadmin  Nemuadmin is not visible as user in Commissioning Report![NOK]
    Log  ${user} is visible as user in Commissioning Report![OK]  console=true
    ${bts_name}  Get Text  //*[contains(@class, "p-accordion p-component")]/p-accordiontab[1]/div/div[2]/div/div[5]/span
    Should Be Equal  ${bts_name}  ${bts_name_parameter}  ${bts_name_parameter} is not visible as vDU name in Commissioning Report![NOK]
    Log  ${bts_name} is visible as vDU name in Commissioning Report![OK]  console=true
    ${validation_result}  Get Text  //*[@id="laf-component"]/p-accordion/div/p-accordiontab[3]/div/div[2]/div/div/span
    Should Be Equal  ${validation_result}  success  success is not visible as vDU validation result in Commissioning Report![NOK]
    Log  ${validation_result} is visible as vDU validation result in Commissioning Report![OK]  console=true
    ${activation_result}  Get Text  //*[@id="laf-component"]/p-accordion/div/p-accordiontab[4]/div/div[2]/div/div/span
    Should Be Equal  ${activation_result}  success  success is not visible as vDU activation result in Commissioning Report![NOK]
    Log  ${activation_result} is visible as vDU activation result in Commissioning Report![OK]  console=true


Verify Report Files
    [Arguments]  ${bts_name_parameter}

    OperatingSystem.File Should Not Be Empty
    ...  ${TEST_RESULTS_DIR}/Report_files/SCF.xml
    Log  SCF file is not empty![OK]  console=true
    OperatingSystem.File Should Not Be Empty  ${TEST_RESULTS_DIR}/Report_files/Parameter_consistency_data.csv
    Log  Parameter consistency data csv is not empty![OK]  console=true
    ${report_content}  OperatingSystem.Get File  ${TEST_RESULTS_DIR}/Report_files/Report_data.txt
    Should Not Be Empty  ${report_content}  Report data file is empty![NOK]
    ${content_list}  Create List  Nemuadmin  ${DATE_FOR_REPORT}  Full commissioning  ${bts_name_parameter}  BTS validation result: success
    ...  BTS activation result: success  WebEM validation warnings  WebEM activation warnings/errors
    FOR  ${string_content}  IN  @{content_list}
        Should Contain  ${report_content}  ${string_content}  ${string_content} is not visible in report data file![NOK]
        Log  ${string_content} is visible in report data file![OK]  console=true
    END


TC Setup
    Common VDU Setup
    VDU WebEM Setup
    Modify Resource Search Order  WebEM__vDU__CW_Save_commissioning_report


TC Teardown
    Run Keyword If Test Failed
    ...  Load Initial SCF And Verify VDU To Be onAir
    VDU WebEM Teardown
    Common VDU Teardown
