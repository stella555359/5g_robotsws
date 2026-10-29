*** Settings ***
Documentation  Test Case Snapshot_collection_from_dual_core_with_re_establishing
Library     taf.hw.pdu
Library     OperatingSystem
Library     SeleniumLibrary
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     taf.ul.verify_snapshot   WITH NAME  snapshot
Resource    ../resources/verdicts.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/BTS_log_level.robot
Resource    ../resources/pdu.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${DIAGNOSTIC DPDN LIST}           //*[@id="main-view"]/div/div[1]/div[1]/product-bar/otx-product-bar/div/div[1]/div[3]/a[6]
${SNAPSHOT TAB}                   //a[@href="#/diagnostic/snapshot"]
${GET SNAPSHOT}                   //ui-button[@a-text="Collect Snapshot"]
${TIMEOUT_STATUS_MESSAGES}        10


*** Keywords ***
TC__LOGS__Snapshot_collection_from_dual_core_with_re_establishing


    [Documentation]
    ...  [CASE LINK]:
    ...  https://jiradc.ext.net.nokia.com/browse/TAT-22567
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The purpose of this test case is to check scenario presented in RP001498 Support of FSMF + FSMF with SRAN configurations and RP001621
    ...  SRAN cell sets allocation on full AirScale module, where we can collect Technical Report (Snapshot)
    ...  from Secondary core after connection between primary and secondary core is broken and then re-established.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  - 2023-01-24 - https://jiradc.ext.net.nokia.com/browse/TAT-22567 - Initial creation
    ...  - 2023-03-10 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame due to migration to robotws
    ...  - 2023-04-24 - TAT-25131 - hran_snapshot analysis refactoring to taf.ul.verify_snapshot UL
    ...  - 2023-03-28 - add new status message 'Collection completed. Please check detail reasons in detail panel.'
    ...  *******************
    ...  Test case flowchart: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/SBTS/
    ...                       LOGS__Snapshot_collection_from_dual_core_with_re_establishing.png
    ...  *******************


    Set Tags      CA-LOGS    OWNER-iuliia.taupeka@nokia.com    AUTHOR-jakub.kokoszka@nokia.com    MAINTAINER-jakub.kokoszka@nokia.com
    ...    GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CRT    SW-SBTS23R1    FEATURE-RP001621_1SB_FD1

    Step 1: Preconditions
    Step 2: Power OFF on ESM when snapshot ongoing
    Step 3: Check if snapshot exist, filesize and validate snapshot

Step 1: Preconditions
    [Documentation]
    ...  In this step test prepare variables for test

    Log    \nStep 1: Preconditions    console=${True}
    ${secondary_SMOD_IM_obj}=       Get Object Secondary Smod
    ${sec_core_SMOD_SN}    Set Variable   SMOD_${secondary_SMOD_IM_obj.serialNumber}
    Set Test Variable  ${SEC_CORE_SMOD_SN}  ${sec_core_SMOD_SN}
    Run  mkdir ${BTS Files}/downloads
    Set Test Variable  ${DIR_DOWNLOADS}  ${BTS Files}/downloads
    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}
    ${ESM_file_name}    Set Variable  BTS${BTS_ID}_2011_part_1.zip
    Set Test Variable    ${ESM_FILE_NAME}    ${ESM_file_name}
    Set Test Variable    ${ESM_OFF}  ${False}

Step 2: Power OFF on ESM when snapshot ongoing
    [Documentation]
    ...  In this step test logs in to WebEm and starts snapshot collecting. When file *_2011_part_1.zip appears, ESM is powered power off.
    ...  After 180 seconds the ESM will turn on and test will wait for all modules and all cells are in working states.

    Log    \nStep 2: Power OFF on ESM when snapshot ongoing    console=${True}
    BTS_log_level.WebEM Login with the given path to download files    ${DIR_DOWNLOADS}
#    BTS_log_level.Change Screen Lock Timeout
    Collect snapshot from WebEM
    Run Keyword and Continue on Failure  WEBEM Wait Until Page Contains Element of Class and Contains Text
    ...  class=status-label  text=Sending request...  timeout=${TIMEOUT_STATUS_MESSAGES}
    Run Keyword and Ignore Error  WEBEM Wait Until Page Contains Element of Class and Contains Text
    ...  class=status-label  text=Collecting files...  timeout=${TIMEOUT_STATUS_MESSAGES}
    Log    looking ${ESM_FILE_NAME}...  console=${True}
    Wait Until Element Is Visible    xpath=//table[@class='files-table ng-scope']    timeout=120s
    Wait Until Element Is Visible    xpath=//td[text()='${ESM_FILE_NAME}']    timeout=240s
    Element Should Be Visible    xpath=//td[text()='${ESM_FILE_NAME}']
    pdu.Pdu BTS Interface Off    ${SEC_CORE_SMOD_SN}
    Log  power on ESM: ${SEC_CORE_SMOD_SN} was turned OFF  console=${True}
    Set Test Variable  ${ESM_OFF}  ${True}
#    Check if snapshot end
    Sleep    360s
    pdu.Pdu BTS Interface On    ${SEC_CORE_SMOD_SN}
    Log  power on ESM: ${SEC_CORE_SMOD_SN} was turned ON  console=${True}
    Set Test Variable  ${ESM_OFF}  ${False}
    Log  Waiting up to 20min for BTS to become on air after power on ESM was turned ON  console=${True}
    sleep    180s
    Wait Until Keyword Succeeds  20m  27s  Check All Modules And All Cells Working States


Step 3: Check if snapshot exist, filesize and validate snapshot
    [Documentation]
    ...  In this step test check if snapshot downloaded to VM disk and check file size
    ...  validate snapshot and reset bts becouse after test FID:4352 visible it could failed test runs after this TC

    Log    \nStep 3: Check if snapshot exist, filesize and validate snapshot   console=${True}
    ${snapshot_name}=    Run    ls ${DIR_DOWNLOADS} | grep .zip
    ${isEmpty}  Get length  ${snapshot_name}
    Run Keyword If  ${isEmpty}==0
    ...  verdicts.Set Test Failed  snapshot zip file does not exist.  ${TRUE}
    ...  ELSE    Log    ${snapshot_name} exist
    ${size}=     Get File Size    ${DIR_DOWNLOADS}/${snapshot_name}
    Log  Snapshot filesize= ${size}  console=${True}
    Run Keyword If    ${size}>0    Log  \n${size} bytes is >0  console=${True}
    ${Found_file_dict}    snapshot.Get Data From Snapshot    ${DIR_DOWNLOADS}/${snapshot_name}
    ${path_to_xml_spec_file}  join path  ${CURDIR}  tc_variables  snapshot_spec.xml
    snapshot.Validate Snapshot    ${Found_file_dict}    ${path_to_xml_spec_file}
    Wait Until Keyword Succeeds    15min    30s    coam.Assert alarm inactive    faultId=6327, severity=Major
    Log    test end!  console=${True}

Collect snapshot from WebEM
    [Documentation]
    ...  KW Click 'Diagnostic' Dropdown List in open browser
    ...  KW Click Navigate To 'Snapshot' Tab in open browser
    ...  KW Click Get Snapshot in open browser

    Click Element    xpath=${DIAGNOSTIC DPDN LIST}
    Run Keyword If  '${sbts version}'=='SBTS24'    Click Element    xpath=${SNAPSHOT TAB}
    Click Element    xpath=${GET SNAPSHOT}

WEBEM Wait Until Page Contains Element of Class and Contains Text
    [Documentation]
    ...  KW Wait Until Page Contains Element of Class and Contains Text

    [Arguments]  ${class}  ${text}  ${timeout}=${WEBEM_IMPLICIT_TIMEOUT}
    Log  -Looking in page for element "${text}"  console=${True}
    Wait Until Page Contains Element   xpath=//div[@class='${class}']//label[contains(text(), '${text}')]  timeout=${timeout}
    Log  +Page contains element "${text}"  console=${True}

Get Object Secondary Smod
    ${obj}=  Query Infomodel  get object //SMOD_R-* is [activeRole="Secondary"]
    [Return]  ${obj}

Check if snapshot end
    [Documentation]
    ...  KW Wait Until Page Contains Element snapshot completed or finished with errors

    Log    -Looking in page for element "Collection completed" or "Collection finished with errors"    console=${True}
    Log    ...or "Collection completed. Please check detail reasons in detail panel."    console=${True}
    Maximize Browser Window
    ${check_status1}    Run Keyword And Return Status
    ...  Wait Until Page Contains Element     xpath=//div[@class='status-label']//label[contains(text(), 'Collection completed')]    timeout=600
    ${check_status2}    Run Keyword And Return Status
    ...  Wait Until Page Contains Element  xpath=//div[@class='status-label']//label[contains(text(), 'Collection finished with errors')]  timeout=120
    ${check_status3}    Run Keyword And Return Status
    ...  Wait Until Page Contains Element
    ...  xpath=//div[@class='status-label']//label[contains(text(), 'Collection completed. Please check detail reasons in detail panel.')]
    ...  timeout=120

    Run Keyword If    '${check_status1}' == 'True' or '${check_status2}' == 'True' or '${check_status3}' == 'True'
    ...    Log  +Page contains expected element    console=${True}
    ...    ELSE    verdicts.Set Test Failed    TC failed - None of the expected elements were found!
    Sleep    120s

Custom Test Teardown
    Log  \nCustom Test Teardown  console=${True}

    Run Keyword If    ${ESM_OFF}    Run Keywords
    ...    pdu.Pdu BTS Interface On    ${SEC_CORE_SMOD_SN}
    ...    AND  Log  power on ESM: ${SEC_CORE_SMOD_SN} was turned ON  console=${True}
    ...    AND  Set Test Variable  ${CELL_ADDED}  ${False}
    ...    AND  Log  Waiting up to 20min for BTS to become on air after power on ESM was turned ON  console=${True}
    ...    AND  Sleep    180s
    ...    AND  Wait Until Keyword Succeeds  20m  27s  Check All Modules And All Cells Working States

TC Setup
    Common Test Setup


TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Custom Test Teardown
    ...    AND    Common Test Teardown
