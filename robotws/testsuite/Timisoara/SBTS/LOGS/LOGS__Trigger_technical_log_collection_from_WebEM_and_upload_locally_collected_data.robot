*** Settings ***
Documentation  Test Suite for TL10835_ARO
Resource    ../resources/verdicts.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/BTS_log_level.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Library     SeleniumLibrary


*** Variables ***
${SNAPSHOT TAB}                   //a[@href="#/diagnostic/snapshot"]
${DIAGNOSTIC DPDN LIST}           //div[@aria-describedby="admin.navigationBar.diagnostic.TITLE"]
${DIAGNOSTIC DPDN LIST25R}        //*[@id="main-view"]/div/div[1]/div[1]/product-bar/otx-product-bar/div/div[1]/div[3]/a[6]
${TIMEOUT_STATUS_MESSAGES}        10
${GET SNAPSHOT}                   //ui-button[@a-text="Collect Snapshot"]
${TIMEOUT_COLLECTION_COMPLETED}   2700
${LOG_TO_SONSOLE}                 True
${METADATA_FILE_NAME}             BTS_*_metadata.txt


*** Keywords ***
TC__LOGS__Trigger_technical_log_collection_from_WebEM_and_upload_locally_collected_data
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24335
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Trigger technical log collection from WebEM and upload locally collected data
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  - 20.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24335 - Test rewritten based on BOAM ET test
    ...   [1]Trigger technical log collection from WebEM and upload locally collected data
    ...  - 03.10.2023 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame due to migration to robotws
    ...
    ...  *******************
    ...  Test case flowchart http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/
    ...  LOGS__Trigger_technical_log_collection_from_WebEM_and_upload_locally_collected_data.png
    ...

    Set Tags    CA-LOGS    OWNER-iuliia.taupeka@nokia.com    AUTHOR-Ichim.Vlad.Nicolaes@nokia.com
    ...    MAINTAINER-jakub.kokoszka@nokia.com    GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CRT    SW-SBTS23R1    FEATURE-5GC001639-RA    CB007310-5G


    Step 0: Preconditions
    Step 1: Trigger technical log collection from WebEM
    Step 2: Check snapshot


Step 0: Preconditions
    [Documentation]
    ...  In this step test prepare variables for test

    Log  \nStep 0: Preconditions  console=${True}
    Run  mkdir ${BTS Files}/results
    Run  mkdir ${BTS Files}/downloads
    Set Test Variable  ${DIR_DOWNLOADS}  ${BTS Files}/downloads
    Set Test Variable  ${DIR_RESULTS}  ${BTS Files}/results
    Set Test Variable  ${DIR_UNZIP}   ${DIR_RESULTS}
    Set Test Variable  ${BTS_PART_DIRS}  BTS*part*
    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${bts_id}
    Set Test Variable  ${SNAPSHOT_FILE_NAME_BEGINNING}  Snapshot_MRBTS-${bts_id}_
    Set Test Variable  ${SNAPSHOT_FILE_NAME}            ${SNAPSHOT_FILE_NAME_BEGINNING}*



Step 1: Trigger technical log collection from WebEM
    [Documentation]
    ...  In this step snapshot is triggered in WebEM

    Log  \nStep 1: Trigger technical log collection from WebEM and upload locally collected data  console=${True}
    Trigger technical log collection from WebEM


Step 2: Check snapshot
    [Documentation]
    ...  In this step test check snapshot
    Check Snapshot
    Run Keyword and Ignore Error  OperatingSystem.Run  rm -rf ${DIR_RESULTS}



Trigger technical log collection from WebEM
    [Documentation]
    ...  KW Trigger technical log collection from WebEM and MV to test file directory

    Run     chmod 777 ${DIR_DOWNLOADS}/*
    Run     chmod 777 ${DIR_RESULTS}/*
    BTS_log_level.WebEM Login with the given path to download files    ${DIR_DOWNLOADS}
    BTS_log_level.Change Screen Lock Timeout
    Click 'Diagnostic' Dropdown List
    Navigate To 'Snapshot' Tab
    Sleep   5
    Get Snapshot

    Run Keyword and Continue on Failure  WEBEM Wait Until Page Contains Element of Class and Contains Text
    ...  class=status-label  text=Sending request...  timeout=${TIMEOUT_STATUS_MESSAGES}
    Run Keyword and Ignore Error  WEBEM Wait Until Page Contains Element of Class and Contains Text
    ...  class=status-label  text=Collecting files...  timeout=${TIMEOUT_STATUS_MESSAGES}
    #WEBEM Wait Until Page Contains Element of Class and Contains Text
    #...  class=status-label  text=Collection  timeout=${TIMEOUT_COLLECTION_COMPLETED}
    WEBEM Page Should Not Contain Element of Class With Text
    ...  class=status-label  text=Collection couldn  loglevel=NONE
    WEBEM Wait Until Page Contains Element of Class and Contains Text
    ...  class=status-label  text=Collection completed  timeout=${TIMEOUT_COLLECTION_COMPLETED}
    Sleep  60
    ${snapshot_name}=    Run    ls ${DIR_DOWNLOADS} | grep .zip
    ${isEmpty}  Get length  ${snapshot_name}
    Run Keyword If  ${isEmpty}==0
    ...  verdicts.Set Test Failed  Snapshot zip file does not exist.  ${TRUE}
    ...  ELSE    Log    snapshot zip exist
    Set Test Variable    ${snapshot_name}
    Run                             mv ${DIR_DOWNLOADS}/${snapshot_name} ${DIR_RESULTS}
    Sleep  30

Check Snapshot
    [Documentation]
    ...  KW Check Snapshot
    Wait Until Keyword Succeeds    5x    5 minutes
    ...          Run     unzip -o ${DIR_RESULTS}/${snapshot_name} -d ${DIR_RESULTS}/snapshot
    Sleep  150
    #LTE_OPR_REQ_19022  #LTE_OPR_AC_9075
    OperatingSystem.File Should Exist  ${DIR_RESULTS}/snapshot/snapshot_file_list.txt
    #LTE_OPR_REQ_8073   #LTE_OPR_AC_3111
    ${return}    Run    find ${DIR_UNZIP}/snapshot -name ${METADATA_FILE_NAME}
    ${isEmpty}  Get length  ${return}
    Run Keyword If  ${isEmpty}==0
    ...  verdicts.Set Test Failed  File ${METADATA_FILE_NAME} not found.  ${TRUE}
    ...  ELSE  Log  File ${METADATA_FILE_NAME} found.    console=${True}

Click 'Diagnostic' Dropdown List
    [Documentation]
    ...  KW Click 'Diagnostic' Dropdown List in open browser
#    ${DIAGNOSTIC DPDN LIST}    Set Variable If    '${sbts version}'=='SBTS25'    ${DIAGNOSTIC DPDN LIST25R}
#    ...                                                ${DIAGNOSTIC DPDN LIST}
    Click Element    xpath=${DIAGNOSTIC DPDN LIST25R}

Navigate To 'Snapshot' Tab
    [Documentation]
    ...  KW Click Navigate To 'Snapshot' Tab in open browser

    Click Element    xpath=${SNAPSHOT TAB}
    Sleep   10

WEBEM Wait Until Page Contains Element of Class and Contains Text
    [Documentation]
    ...  KW Wait Until Page Contains Element of Class and Contains Text

    [Arguments]  ${class}  ${text}  ${timeout}=${WEBEM_IMPLICIT_TIMEOUT}
    Run Keyword If  ${LOG_TO_SONSOLE}  Log  -Looking in page for element "${text}"  console=${True}
    Wait Until Page Contains Element   xpath=//div[@class='${class}']//label[contains(text(), '${text}')]  timeout=${timeout}
    Run Keyword If  ${LOG_TO_SONSOLE}  Log  +Page contains element "${text}"  console=${True}

WEBEM Page Should Not Contain Element of Class With Text
    [Documentation]
    ...  KW check if Page Should Not Contain Element of Class With Text

    [Arguments]  ${class}  ${text}  ${loglevel}=NONE
    Page Should Not Contain Element  xpath=//div[@class='${class}']//label[contains(text(), '${text}')]  loglevel=${loglevel}

Get Snapshot
    [Documentation]
    ...  KW Click Get Snapshot in open browser

    Click Element    xpath=${GET SNAPSHOT}

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown
