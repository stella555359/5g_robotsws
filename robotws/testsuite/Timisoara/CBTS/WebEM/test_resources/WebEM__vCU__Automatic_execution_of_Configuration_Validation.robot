*** Settings ***
Documentation
    ...  This TC is created to verify Diagnostic Check on vCU in three ways.
    ...  First, Diagnostic Check is verified at the beginning of the test.
    ...  Second, Diagnostic Check is verified after SCF commissioning.
    ...  Third, Diagnostic Check is verified after site reset.

Library  ../../common_resources/python_resources/csv_resource.py
Resource  ../../common_resources/vcu_frame.robot
Resource  ../resources/vcu_WebEM_general.robot


*** Variables ***
${RESTORE_TIMEOUT}  15m  # Timeout for vDU to recover after SCF upload


*** Keywords ***
TC__WebEM__vCU__Automatic_execution_of_Configuration_Validation
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27189
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  25.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27189 - Initial TAT creation
    ...  ******************
    Set Tags  CA-WebEM  OWNER-marius.stanescu@nokia.com  AUTHOR-anna.benzar@nokia.com  MAINTAINER-anna.benzar@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf
    ...  PHASE-CRT  FEATURE-CB009129

    Step0: TC Preconditions
    Step1: Open Ssh Connection To VCU And Check Diagnostic Files
    Step2: Load SCF - Full Commissioning
    Step3: Open Ssh Connection To VCU And Check Diagnostic Files - Automatic
    Step4: Perform VCU Reset
    Step5: Open Ssh Connection To VCU And Check Diagnostic Files - Automatic


Step0: TC Preconditions
    Log  \nStep0: TC Preconditions  console=true
    ${no_of_dus}  Get Total Number Of DUs Linked To CU
    Set Test Variable  ${NO_OF_DUS}


Step1: Open Ssh Connection To VCU And Check Diagnostic Files
    Log  \nStep1: Open ssh connection to vCU and check Diagnostic files.  console=true
    Open Connection To VCU And Bring Diagnostic Files To Local Machine  ${VCU_CRAN}  oamcm  1


Step2: Load SCF - Full Commissioning
    Log  \nStep2: Load SCF - full commissioning.  console=true
    ${current_date_time}  Get Current Time For Diagnostic Check
    Set Test Variable  ${CURRENT_DATE_TIME}
    vcu.Perform Commissioning  ${VCU_SCF_PATH}
    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  10s
    ...  Verify DUs Linked To CU To Be On Air  ${NO_OF_DUS}
    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  10s
    ...  Check All Cells From VCU  administrative_state=${UNLOCKED}  operational_state=${ENABLED}
    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  10s
    ...  Verify CU X2 Links States  ${AVAILABLE}  ${UNLOCKED}
    Log  All services are operational after valid SCF actvation. [OK]  console=true


Step${index}: Open Ssh Connection To VCU And Check Diagnostic Files - ${type}
    Log  \nStep${index}: Open ssh connection to vCU and check Diagnostic files - ${type}.  console=true
    Wait Until Keyword Succeeds  300s  20s
    ...  Check DiagnosticReport Content  ${index}  ${type}


Step4: Perform VCU Reset
    Log  \nStep4: Perform vCU reset.  console=true
    ${current_date_time}  Get Current Time For Diagnostic Check
    Set Test Variable  ${CURRENT_DATE_TIME}
    vcu.Reset Cu
    ${ip_adresses}  Create List  ${VCU_OAM_IP}
    ${ping_lost_status}  Run Keyword And Return Status
    ...  ping.Wait For No Ping  ip_addresses=${ip_adresses}  timeout=120s
    Run Keyword If  ${ping_lost_status} == ${FALSE}
    ...  Fail  Ping not lost after vCU reset. [NOK]
    ${ping_regained_status}  Run Keyword And Return Status
    ...  ping.Wait For Ping  ip_addresses=${ip_adresses}  timeout=300s
    Run Keyword If  ${ping_regained_status} == ${FALSE}
    ...  Fail  Ping not regained after vCU reset. [NOK]
    Log  vCU reset is performed![OK]  console=true
    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  10s
    ...  Check VDU To Be OnAir
    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  10s
    ...  Verify CU X2 Links States  ${AVAILABLE}  ${UNLOCKED}
    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  10s
    ...  Check Cells On VDU To Be OnAir
    Log  vDU, cells and X2 Links are back on air! [OK]  console=true


Check DiagnosticReport Content
    [Arguments]  ${index}  ${type}

    Open Connection To VCU And Bring Diagnostic Files To Local Machine  ${VCU_CRAN}  oamcm  ${index}
    ${csv_content}  Return Csv File Content  ${TEST_RESULTS_DIR}/Diagnostic_Check_step_${index}/DiagnosticReport.csv
    ${first_row_status}  Run Keyword And Return Status
    ...  Verify first row in DiagnosticReport.Csv File  ${csv_content}
    ${second_row_status}  Run Keyword And Return Status
    ...  Verify second row in DiagnosticReport.Csv File  ${csv_content}  ${VCU_MRBTS_ID}  ${type}  OK  ${CURRENT_DATE_TIME}
    ${third_row_status}  Run Keyword And Return Status
    ...  Verify third row in DiagnosticReport.Csv File  ${csv_content}  ${VCU_MRBTS_ID}  ${type}  OK  ${CURRENT_DATE_TIME}
    Run Keyword If  ${first_row_status} == ${FALSE} or ${second_row_status} == ${FALSE} or ${third_row_status} == ${FALSE}
    ...  Run  rm -rf ${TEST_RESULTS_DIR}/Diagnostic_Check_step_${index}


TC Setup
    Common VCU Setup
    Modify Resource Search Order  WebEM__vCU__Automatic_execution_of_Configuration_Validation


TC Teardown
    Common VCU Teardown
