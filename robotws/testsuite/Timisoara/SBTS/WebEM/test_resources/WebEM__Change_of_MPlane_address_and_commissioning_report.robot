*** Settings ***
Documentation
    ...  This test case is created to change Mplane address from Commissioning wizard.
    ...  The IP address of Mplane must not be used.
    ...  After Mplane address is changed, in Save Report window is displayed parameters: User, Date, Time, Commissioning type, NTP connection,
    ...  BTS state, BTS name, File version ID, BTS plan validation result, BTS plan activation result.
    ...  TC checks that parameters are present and have value set.
    ...  Save report and check that there are 2 files: report-data.txt, SCF.xml.
    ...  The test compares the values in the Save Report present in WebEM with those in the report-data.txt file.
    ...  Try to connect on SBTS via new MPlane IP set.
    ...  At the end load original SCF.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  900s  # Timeout for SBTS to recover
${TEMPORARY_MPLANE_IP}  ${EMPTY}  # Mandatory! Ip address that is not in use.


*** Keywords ***
TC__WebEM__Change_of_MPlane_address_and_commissioning_report
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27626
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 05.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27626 - Initial TAT creation

    Set Tags  CA-WebEM  OWNER-cristina.antoci@nokia.com  AUTHOR-cristina.adam@nokia.com  MAINTAINER-cristina.adam@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS24

    Step1: Navigate To VLAN Interfaces And Change Mplane
    Step2: Save Report And Check Parameters
    Step3: Connect On SBTS Via New MPlane Ip Set


Step1: Navigate To VLAN Interfaces And Change Mplane
    Log  \nStep1: Navigate To VLAN Interfaces and change mplane  console=true
    Should Not Be Empty  ${TEMPORARY_MPLANE_IP}  Temporary MPlane Ip must be specified, please provide it and retest.
    Navigate To VLAN Interfaces
    Change MPlane Address From Commissioning Wizard


Step2: Save Report And Check Parameters
    Log  \nStep2: Save report and check parameters  console=true
    Wait Until Element Is Clicked  //*[contains(@a-title, 'Save Report')]
    Set Parameters And Check That Are Not Empty
    Click Element  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[1]/button
    Sleep  120s  msg=Wait download commissioning report file
    Move Files And Check Report Data File


Step3: Connect On SBTS Via New MPlane Ip Set
    Log  \nStep3: Connect on SBTS via new MPlane Ip set  console=true
    Connect On New MPlane Ip


Navigate To VLAN Interfaces
    Wait Until Element Is Clicked  ${COMMISIONING_WIZARD}  120
    Click Element  //*[contains(@heading, 'Steps')]
    Click Element  //*[contains(@title, 'System Module')]
    Click Element  locator=//li[@row-key="TRANSPORT_CONFIGURATION"]
    Click Element  //*[contains(@title, 'IP Interfaces')]
    Click Element  locator=//li[@row-key="VLAN_INTERFACES"]

Change MPlane Address From Commissioning Wizard
    Click Element  //*[contains(@class, 'ng-isolate-scope vlan-table')]/div/ng-transclude/table/tbody/tr[1]/td[1]/wizard-table-cell-renderer/div
    ${ip_address_xpath}  Catenate  SEPARATOR=
    ...  xpath:/html/body/div[1]/div/div/div/common-modal/div/div/div[2]/div/modal-body/wizard-steps-modal-body/
    ...  div/div[2]/wizard-steps-center-panel/generic-step-renderer/div/div/wizard-group-renderer/div[1]/wizard-action-renderer/div/div[2]/div/
    ...  wizard-table-with-parameters-action-renderer/div/div/table/tbody/tr[5]/td/div/wizard-action-renderer/div/div[2]/div/
    ...  wizard-table-action-renderer/ui-table/div/ng-transclude/table/tbody/tr[1]/td[2]/wizard-table-cell-renderer/wizard-action-renderer/div/div[2]
    ...  /div/n-text-input/div/input
    Input Text  ${ip_address_xpath}  ${TEMPORARY_MPLANE_IP}
    Click Element
    ...  xpath:/html/body/div[1]/div/div/div/common-modal/div/div/div[3]/div/modal-footer/wizard-steps-modal-footer/div/div[2]/ui-button[1]/button
    Wait Until Element Is Clicked  //*[contains(@a-title, 'Validate Plan')]  60
    Wait Until Element Is Clicked  //*[contains(@a-title, 'Activate Plan')]  60
    Wait Until Element Is Clicked
    ...  xpath:/html/body/div[1]/div/div/ui-modal-renderer/deploy-plan-modal-component/ui-modal/div/div/div[3]/div/ui-footer/div/ui-button[1]/button
    Wait Until Element Is Visible
    ...  xpath:/html/body/div[1]/div/div/ui-modal-renderer/deploy-plan-modal-component/ui-modal/div/div/div[2]/div/ui-body/div[4]/div[2]/span[1]
    ...  timeout=60
    Wait Until Element Is Clicked
    ...  xpath:/html/body/div[1]/div/div/ui-modal-renderer/deploy-plan-modal-component/ui-modal/div/div/div[3]/div/ui-footer/div/ui-button[1]/button
    Wait Until Element Is Visible  locator=//*[contains(text(),' Operation finished successfully')]  timeout=300
    Wait Until Element Is Clicked
    ...  xpath:/html/body/div[1]/div/div/ui-modal-renderer/deploy-plan-modal-component/ui-modal/div/div/div[3]/div/ui-footer/div/ui-button[2]/button
    Log  \nMPlane Ip is changed!  console=true


Set Parameters And Check That Are Not Empty
    ${dictionary_parameters}  Create Dictionary
    Set Test Variable  ${DICTIONARY_PARAMETERS}
    ${user}  Get Text  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[2]/div/modal-body/div/table[1]/tbody/tr[3]/td[2]
    Set To Dictionary  ${DICTIONARY_PARAMETERS}  User=${user}
    Check Parameter Value And Display Message  ${user}  Username of commissioning performer
    ${date}  Get Text  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[2]/div/modal-body/div/table[1]/tbody/tr[1]/td[2]
    Set To Dictionary  ${DICTIONARY_PARAMETERS}  Date=${date}
    Check Parameter Value And Display Message  ${date}  Date of operation
    ${time}  Get Text  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[2]/div/modal-body/div/table[1]/tbody/tr[2]/td[2]
    Set To Dictionary  ${DICTIONARY_PARAMETERS}  Time=${time}
    Check Parameter Value And Display Message  ${time}  Time of operation
    ${commissioning_type}  Get Text  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[2]/div/modal-body/div/table[1]/tbody/tr[5]/td[2]
    Set To Dictionary  ${DICTIONARY_PARAMETERS}  Commissioning type=${commissioning_type}
    Check Parameter Value And Display Message  ${commissioning_type}  Commissioning type
    ${ntp_connection}  Get Text  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[2]/div/modal-body/div/table[1]/tbody/tr[4]/td[2]
    Set To Dictionary  ${DICTIONARY_PARAMETERS}  NTP connection=${ntp_connection}
    Check Parameter Value And Display Message  ${ntp_connection}  NTP connection status
    ${bts_state}  Get Text  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[2]/div/modal-body/div/table[1]/tbody/tr[6]/td[2]
    Set To Dictionary  ${DICTIONARY_PARAMETERS}  BTS state=${bts_state}
    Check Parameter Value And Display Message  ${bts_state}  BTS state
    ${bts_name}  Get Text  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[2]/div/modal-body/div/table[1]/tbody/tr[7]/td[2]
    Set To Dictionary  ${DICTIONARY_PARAMETERS}  BTS name=${bts_name}
    Check Parameter Value And Display Message  ${bts_name}  BTS name
    ${file_version_id}  Get Text  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[2]/div/modal-body/div/table[2]/tbody/tr/td[2]
    Set To Dictionary  ${DICTIONARY_PARAMETERS}  File version ID=${file_version_id}
    Check Parameter Value And Display Message  ${file_version_id}  NIDD Adaptation Versions used by WebEM
    ${bts_plan_validation}  Get Text  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[2]/div/modal-body/div/table[3]/tbody/tr/td[2]
    Set To Dictionary  ${DICTIONARY_PARAMETERS}  BTS plan validation result=${bts_plan_validation}
    Check Parameter Value And Display Message  ${bts_plan_validation}  BTS validation
    ${bts_plan_activation}  Get Text  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[2]/div/modal-body/div/table[4]/tbody/tr/td[2]
    Set To Dictionary  ${DICTIONARY_PARAMETERS}  BTS plan activation result=${bts_plan_activation}
    Check Parameter Value And Display Message  ${bts_plan_activation}  Plan activation


Check Parameter Value And Display Message
    [Arguments]  ${parameter}  ${message}

    Run Keyword If  '${parameter}'=='-' or '${parameter}'==''
    ...  Fail  ${message} is empty.[NOK]
    ...  ELSE
    ...  Log  ${message} is ${parameter}  console=true


Move Files And Check Report Data File
    ${commissioning_report_file}  Get Name Of Commissioning Report File
    Run Keyword If  '${commissioning_report_file}'=='${EMPTY}'
    ...  Fail  Commissioning report file not found.
    Unzip  /home/ute/Downloads/${commissioning_report_file}  /home/ute/Downloads/commissioning_report
    OperatingSystem.File Should Exist  /home/ute/Downloads/commissioning_report/report-data.txt
    OperatingSystem.File Should Exist  /home/ute/Downloads/commissioning_report/SCF.xml
    Move Files  /home/ute/Downloads/commissioning_report/report-data.txt  /home/ute/Downloads/commissioning_report/SCF.xml  ${BTS_FILES}
    Log  Files report-data.txt and SCF.xml are moved in ${BTS_FILES}  console=true
    OperatingSystem.Remove Directory  /home/ute/Downloads/commissioning_report  true
    OperatingSystem.Remove File  /home/ute/Downloads/${commissioning_report_file}
    ${report_data}  OperatingSystem.Get File  ${BTS_FILES}/report-data.txt
    ${content_list}  Split To Lines  ${report_data}
    FOR  ${line}  IN  @{content_list}
        @{line_list}  Split String  ${line}  :${SPACE}
        ${length}  Get Length  ${line_list}
        ${second_value}  Run Keyword If  ${length}==2
        ...  Fetch From Right  ${line_list}[1]  ${SPACE}${SPACE}
        ...  ELSE
        ...  Continue For Loop
        ${status}  Run Keyword And Return Status
        ...  Should Contain  ${second_value}  ${DICTIONARY_PARAMETERS["${line_list}[0]"]}
        Run Keyword If  ${status}
        ...  Log  Parameter ${line_list}[0] has the same value:${second_value} in WebEM and in Report data file.  console=true
        ...  ELSE
        ...  Fail  Parameter ${line_list}[0] does not have the same value in WebEM and Report data file.[NOK]
    END


Get Name Of Commissioning Report File
    ${downloads_directory}  OperatingSystem.List Directory  /home/ute/Downloads/  pattern=commissioning_report*.zip
    ${status}  Run Keyword And Return Status
    ...  Should Not Be Empty  ${downloads_directory}
    ${directory}  Set Variable If  ${status}  ${downloads_directory}[0]  ${EMPTY}

    [Return]  ${directory}


Connect On New MPlane Ip
    Go To  https://${TEMPORARY_MPLANE_IP}
    Set Window Size  ${1920}  ${1800}
    Check Private Connection
    Login SBTS
    Legal Notice
    Log  Wait until the page is loaded.  console=true
    Wait Until Element Is Visible  //*[@id="simplifiedSiteContainer"]/div/div/div[2]/div[1]/div  30s  WebElement is not fully loaded in 30 seconds.
    Log  SBTS is connected via new MPlane Ip:${TEMPORARY_MPLANE_IP}  console=true


Load Initial SCF
    Log  Loading initial SCF will be performed...  console=true
    ${commissioning_status}  Run Keyword And Return Status
    ...  coam.Perform Commissioning  bts_id=${BTS_ID}
    ...  scf_file=${COMMISSIONING_PATH}
    ...  skip_parameter_relation_errors=${TRUE}
    ...  should_activate=${TRUE}
    ...  timeout=600
    Run Keyword If  ${commissioning_status}
    ...  Log  Loading initial SCF is performed successfully.[OK]  console=true
    ...  ELSE
    ...  Fail  Loading initial SCF is failed.[NOK]
    Log  Wait for all cells to be onAir...  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Admin Check All Required State
    Close Startup View If Visible


TC Setup
    Common Test Setup  tc_name=WebEM__Change_of_MPlane_address_and_commissioning_report
    WebEM Setup


TC Teardown
    Load Initial SCF
    WebEM Teardown
    Common Test Teardown
