*** Settings ***
Documentation
    ...  This test case is created to check the performing of NR RAT Reset after the change of parameters  chBwDl and chBwUl.
    ...  Checking states of all cells and get NR cells list.
    ...  Get initial values for parameters chBwDl and chBwUl.
    ...  Perform changing parameters chBwDl and chBwUl.
    ...  Checking if NR RAT Reset is performed, NR cells should be disabled, cells on other RATS should be Enabled
    ...  and NR cells should be Enabled again.
    ...  Finally,  the initial values for parameters chBwDl and chBwUl are restored and SBTS should be OnAir.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${TESTED_NRCELL_ID}  1  #Tested nrcell id
${VALUE_BANDWIDTH}  15MHz  #The new bandwidth value for tested nrcell
${DISABLED_CELLS_TIMEOUT}  1200s  #Timeout for cells to be disabled
${ENABLED_CELLS_TIMEOUT}  1200s  #Timeout for cells to be enabled


*** Keywords ***
TC__WebEM__5G_Delta_plan_activation_for_parameters
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21617
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 20.07.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21617 - Initial TAT creation
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring
    ...  - 25.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28789 - Add nrcell id as a global variable

    Set Tags  CA-WebEM  OWNER-cristina.antoci@nokia.com  AUTHOR-cosmina.rebenciuc@nokia.com  MAINTAINER-cosmina.rebenciuc@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS21B

    Step1: Verify Cells On SBTS
    Step2: Change Parameters ChBwDl And ChBwUl
    Step3: Check NR RAT Reset


Step1: Verify Cells On SBTS
    Log  Step1: Verify cells on SBTS  console=true
    Maximize Browser Window
    Check All Cells From WebEM


Step2: Change Parameters ChBwDl And ChBwUl
    Log  Step2: Change parameters chBwDl and chBwUl  console=true
    ${nrbts_object}  Query Infomodel  get object /MRBTS-1/RAT-1/NRTS-1/NRBTS_L-*
    ${nrbts_id}  Fetch From Right  ${nrbts_object}[dist_name]  /NRBTS_L-
    Set Test Variable  ${NRBTS_ID}  ${nrbts_id}
    ${initial_value_ch_bw_dl}  Get Parameter Value From Infomodel  chBwDl
    ${initial_value_ch_bw_ul}  Get Parameter Value From Infomodel  chBwUl
    Set Test Variable  ${INITIAL_VALUE}  ${initial_value_ch_bw_dl}
    ${status}  Run Keyword And Return Status
    ...  Should Not Be Equal  ${initial_value_ch_bw_dl}  ${VALUE_BANDWIDTH}
    Run Keyword If  ${status}
    ...  Perform Delta Recommissioning With NRCELL_FDD Object  ${VALUE_BANDWIDTH}
    ...  ELSE
    ...  Fail  msg=Values are equal, please provide another value from: 10,15,20.


Step3: Check NR RAT Reset
    Log  Step3: Check NR RAT Reset  console=true
    Sleep  10s
    Performing NR RAT Reset And Checking Cells Status


Perform Delta Recommissioning With NRCELL_FDD Object
    [Arguments]  ${value}

    Log  Delta with NRCELL_FDD object recommisiong is performing.  console=true
    ${delta_id}  Set Variable  1
    ${new_values}  Create Dictionary  chBwDl=${value}  chBwUl=${value}
    Create Delta  ${delta_id}
    Append Managed Object To Delta  MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${TESTED_NRCELL_ID}/NRCELL_FDD-1  update  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${TESTED_NRCELL_ID}/NRCELL_FDD-1
    ...  chBwDl  ${new_values}[chBwDl]  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${TESTED_NRCELL_ID}/NRCELL_FDD-1
    ...  chBwUl  ${new_values}[chBwUl]  ${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS_FILES}/delta.json  delta_id=${delta_id}
    Perform Delta Recommissioning  ${BTS_FILES}/delta.json  skip_parameter_relation_errors=true
    Remove Delta  ${delta_id}


Get Parameter Value From Infomodel
    [Documentation]
    ...  This KW is created to check what value has parameter.
    [Arguments]  ${im_parameter}

    ${parametr_name}  Convert To String  ${im_parameter}
    ${np_id}  Get NP Id
    ${command_text}  Catenate  SEPARATOR=  /MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1/NP-${np_id}/SCF-1/MRBTS_A-${BTS_ID}
    ...  /NRBTS_A-${NRBTS_ID}/NRCELL_A-${TESTED_NRCELL_ID}/NRCELL_FDD_A-1
    ${parameter_object}  Query Infomodel  get object ${command_text}
    ${parameter_object_value_string}  Convert To String  ${parameter_object.${parametr_name}}

    [Return]  ${parameter_object_value_string}


Get NP Id
    ${np_object}  Query Infomodel  get object /MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1/NP-*
    ${np_dist_name}  Set Variable  ${np_object}[dist_name]
    ${np_id}  Fetch From Right  ${np_dist_name}  /NP-

    [Return]  ${np_id}


Performing NR RAT Reset And Checking Cells Status
    Log  Verify NR RAT Reset and cells status  console=true
    Wait Until Keyword Succeeds  ${DISABLED_CELLS_TIMEOUT}  10s
    ...  Check NR Cells Operational State To Be Disabled|disabled
    Log  NR RAT Reset is performed.  console=true
    Verify States For Cells In Unaffected RATs  NR
    Log  Waiting for cells to be enabled.  console=true
    Wait Until Keyword Succeeds  ${ENABLED_CELLS_TIMEOUT}  10s
    ...  Check NR Cells Operational State To Be Enabled|enabled
    Log  Cells are enabled again.  console=true


Check NR Cells Operational State To Be ${state}
    ${cells_status}  Get States For Cells In RAT  NR
    FOR  ${cell}  IN  @{cells_status.keys()}
        Should Match Regexp  ${cells_status}[${cell}][Operational state]  ${state}
    END


Restore Initial Values For ChBwDl And ChBwUl
    Log  Initial values will be restored.  console=true
    Perform Delta Recommissioning With NRCELL_FDD Object  ${INITIAL_VALUE}
    Performing NR RAT Reset And Checking Cells Status
    Log  Initial values are restored and SBTS is OnAir.  console=true


TC Setup
    Common Test Setup  tc_name=WebEM__5G_Delta_plan_activation_for_parameters
    WebEM Setup


TC Teardown
    Restore Initial Values For ChBwDl And ChBwUl
    WebEM Teardown
    Common Test Teardown
