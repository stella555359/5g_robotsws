*** Settings ***
Documentation
...    Author: Sergiu Alecu (sergiu.alecu@nokia.com)
...    Maintainer: Sergiu Alecu (sergiu.alecu@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:5GC000470-E-a_5GC001639-RA
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/5GC000470-E-a_5GC001639-RA/general.robot

Library        String
Library        Telnet
Library        OperatingSystem
Library        Process
#Library        Selenium2Library


Resource    ../../resources/admin.robot
Resource    ../../resources/selenium.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot


*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True

${CONFIRM_BUTTON}=                      //ui-button[@a-text="Confirm"]
${CUSTOMER_LOGIN}=                      developer
${CUSTOMER_PASSWORD}=                   $developer#
${WebEM IP}                             https://192.168.255.1:3600
${INPUT_NAME_FIELD}=                    userName
${INPUT_PASSWORD_FIELD}=                password
${LOGIN_BUTTON}=                        //ui-button[@a-text="Login"]

${TIMEOUT_STATUS_MESSAGES}       10
${TIMEOUT_COLLECTION_COMPLETED}  1000
${DIR_DOWNLOADS}                 /home/ute/Downloads
${DIR_RESULTS}                   /home/ute/
${DIR_UNZIP}                     ${DIR_RESULTS}
${SNAPSHOT_FILE_NAME_BEGINNING}  Snapshot_MRBTS-1_
${SNAPSHOT_FILE_NAME}            ${SNAPSHOT_FILE_NAME_BEGINNING}*.zip
${METADATA_FILE_NAME}            BTS1_*_metadata.txt
${BTS_PART_DIRS}                 BTS*part*
${FileNumber}           		 15
${keyword}=                      5G
@{log_file_names}                FileList_SWDownload_Start.xz  FileList_SWDownload_End.xz

*** Keywords ***
5GC000470-E-a_5GC001639-RA_Snapshot_collection_is_triggered_by_operator_from_WebEM
        log to console  Start 1st test

        SELENIUM Prepare Enviroment
        Login To Web Element Manager
        Collect Snapshot from WebEM
        Verify if snapshot is collected
        SELENIUM Teardown Enviroment

        log to console  End 1st test

5GC000470-E-a_5GC001639-RA_Check_that_the_WebEM_generate_a_list_file_with_the_snapshot_content
        log to console  Start 2nd test

        SELENIUM Prepare Enviroment
        Login To Web Element Manager
        Collect Snapshot from WebEM
        Check Snapshot for snapshot_file_list.txt
        SELENIUM Teardown Enviroment

        log to console  End 2nd test

5GC000470-E-a_5GC001639-RA_Check_the_BTS_is_saving_technical_report
        log to console  Start 3rd test

        SELENIUM Prepare Enviroment
        Login To Web Element Manager
        Collect Snapshot from WebEM and verify snapshot collection states
        SELENIUM Teardown Enviroment

        log to console  End 3rd test


Check Snapshot for snapshot_file_list.txt
        Verify if snapshot is collected
        Run     mv /home/ute/Downloads/Snapshot*.zip ${DIR_UNZIP}/Snapshot*.zip
	    Run     unzip -o ${DIR_UNZIP}/Snapshot*.zip -d ${DIR_UNZIP}/snapshot
        OperatingSystem.File Should Exist  ${DIR_UNZIP}/snapshot/snapshot_file_list.txt
        OperatingSystem.File Should Exist  ${DIR_UNZIP}/snapshot/${METADATA_FILE_NAME}
	    ${keyword}=  Set variable  \.zip\:
	    ${matching_lines}=    Grep file    ${DIR_UNZIP}/snapshot/snapshot_file_list.txt    ${keyword}
	    @{LIST_zips}=  Split To Lines  ${matching_lines}
	    FOR    ${index}   IN  @{LIST_zips}
	            ${zip_file}=  Strip String  string=${index}  mode=right  characters=:
	            ${dir_unzip}=  Get Substring  string=${zip_file}  start=0  end=-4
	            Run 	unzip -o ${DIR_RESULTS}/snapshot/${zip_file} -d ${DIR_RESULTS}/snapshot/${dir_unzip}
        END


Collect Snapshot from WebEM
    Go To Snapshot Tab
    SYSTEM Remove File From Directory
    ...    fileName=Snapshot_MRBTS-*
    ...    fileDirectory=/home/ute/Downloads
    SELENIUM Click Visible Element
    ...    locator=${NAVI_BAR_SNAPSHOT_BTN}
    Wait Until Element is Visible
    ...    timeout=600
    ...    locator=//label[contains(text(),'Collection completed')]
    Sleep  15s

Collect Snapshot from WebEM and verify snapshot collection states
    Go To Snapshot Tab
    SYSTEM Remove File From Directory
    ...    fileName=Snapshot_MRBTS-*
    ...    fileDirectory=/home/ute/Downloads
    SELENIUM Click Visible Element
    ...    locator=${NAVI_BAR_SNAPSHOT_BTN}
    Wait Until Element is Visible
    ...    timeout=360
    ...    locator=//label[contains(text(),'Sending request...')]
    Wait Until Element is Visible
    ...    timeout=360
    ...    locator=//label[contains(text(),'Collecting files...')]
    Wait Until Element is Visible
    ...    timeout=600
    ...    locator=//label[contains(text(),'Collection completed')]

Verify if snapshot is collected
    Wait Until Keyword Succeeds
    ...    600
    ...    10
    ...    SYSTEM Check If File Is In Directory
    ...    fileName=Snapshot_MRBTS-
    ...    fileDirectory=/home/ute/Downloads


Go To Snapshot Tab
    Sleep  15s
    SELENIUM Click Visible Element
    ...    locator=${NAVI_BAR_DIAGNOSTIC}
    SELENIUM Click Visible Element
    ...    locator=${NAVI_BAR_SNAPSHOT}

Login To Web Element Manager
    [Arguments]    ${login}=${CUSTOMER_LOGIN}
    ...            ${password}=${CUSTOMER_PASSWORD}
    Set Selenium Implicit Wait    5
    Open Browser
    Input Text    locator=${INPUT_NAME_FIELD}
    ...           text=${login}
    Input Text    locator=${INPUT_PASSWORD_FIELD}
    ...               text=${password}
    Click Element   locator=${LOGIN_BUTTON}
    Wait Until Element Is Visible    locator=${CONFIRM_BUTTON}
    ...                              timeout=40
    Click Element    locator=${CONFIRM_BUTTON}
    ${reload}=    Run Keyword And Return Status  Element Should Be Visible    locator=//button[contains(text(),'Close')]
    Run Keyword If    '${reload}' == 'True'  Run Keyword    Click Element    locator=//button[contains(text(),'Close')]
    ${plug}=    Run Keyword And Return Status    Element Should Be Visible    locator=//h4[@title="Plug and Play"]
    Run Keyword If    '${plug}' == 'True'    Run Keyword    Click Element    locator=//button[contains(text(),'Cancel')]
    Wait Until Element Is Visible
        ...    locator=//div[contains(text(), "Configured")]
        ...    timeout=60


Open Browser
    ${chrome options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${chrome options}    add_argument    --ignore-certificate-errors
    Create Webdriver    Chrome    chrome_options=${chrome options}
    Goto    https://192.168.255.129
    Sleep    10 secs



