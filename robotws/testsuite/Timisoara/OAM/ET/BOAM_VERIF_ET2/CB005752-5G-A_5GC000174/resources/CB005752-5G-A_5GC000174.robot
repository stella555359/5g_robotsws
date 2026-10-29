*** Settings ***
Documentation
...    Author: Andreea Zaharia
...    Maintainer: Andreea Zaharia
...    Test Description: Software management

Library    SSHLibrary
#Library    ute_fault
Library    String
Library    ute_async
Library    collections
Library    XML  lxml=True
Library    Process

Library        Telnet
Library        OperatingSystem

Resource    ../../resources/admin.robot
Resource   ../../resources/admin_infomodel.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot
Resource    ../../resources/selenium.robot
Resource    ../../resources/fault_trigger.robot
Resource    ../resources/keyword.robot

*** Variables ***
${SSH_CREDENTIALS}    ute
${BTS_PASSWORD}       oZPS0POrRieRtu
${4G_IP}              10.0.2.2
${5G_IP}              10.0.2.1
${PROMPT}             :~$
${PROMPT_ENB}         :~ >
${OUT_ADMIN_BTS_PARAMETERS}

${SW_DESTINATION}     /home/ute
${URL_5G}=    https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release
${DOWNLOAD_HOST}        https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release
${jenkins_url}          http://files.ute.nsn-rdnet.net/builds/enb/base/
${TRUNK_VERSION}        SBTS23R2

${WebEM IP}                             https://192.168.255.1:3600
${CUSTOMER_LOGIN}=                      Nemuadmin
${CUSTOMER_PASSWORD}=                   nemuuser
${INPUT_NAME_FIELD}=                    userName
${INPUT_PASSWORD_FIELD}=                password
${LOGIN_BUTTON}=                        //ui-button[@a-text="Login"]
${CONFIRM_BUTTON}=                      //ui-button[@a-text="Confirm"]
${SWM_MGMNT_SAVE_SW_UPDATE_REP_BTN}     //ui-button[@a-text="Save SW Update Report"]
${SWM_MGMNT_SAVE_SW_HISTORY_REP_BTN}    //ui-button[@a-text="Save SW History Report"]
${SWM_PATH}=   /MRBTS-1/RAT-1/SWM-1
${scf_path}   /home/ute
${scf_name}   Configuration_backup.xml
${swDownloadInfo.result}=  Aborted
#${main_package_txt}=    SBTS00_ENB_9999_210602_000006_release_BTSSM_downloadable_testpackage_T2.txt



*** Keywords ***
CB005752-5G-A-_5GC000174_Configuration_backup
    log to console   Configuration backup
    Check If BTS Is Not In Uncommissioned State
    Check if RMOD is in availabilityStatus Online
    Run keyword and continue on failure   ADMIN INFOMODEL Check If BTS Is OnAir
    ADMIN Collect Scf   local_dir_path=${scf_path}    file_name=${scf_name}
    Sleep   60
    Check If BTS Is Not In Uncommissioned State

CB005752-5G-A-_5GC000174_Activation_for_pre-downloaded_SW
    log to console   Activation for pre downloaded SW
    Wait Until Keyword Succeeds  300s  10s  ADMIN INFOMODEL Check If BTS Is OnAir
#    Check If BTS Is Not In Uncommissioned State
    log to console  Check sw builds before sw update
    Get active and passive sw versions before sw update
    ADMIN Update Software Without Activation
    ...            sw_package=${SW_DESTINATION}/${T1_package}
    ...            timeout=1000
    log to console  Check sw builds after sw update without activation
    Get active and passive sw versions after sw update without activation
    Check if sw after sw update is the same
    ...     post_update_sw=${post1_update_active_sw}  target_sw=${pre_update_active_sw}
    ADMIN Update Software With Activation
    ...            sw_package=${SW_DESTINATION}/${T1_package}
    ...            timeout=600
    log to console  sw activation ongoing - BTS reset
    Sleep   120
    Wait Until Keyword Succeeds  300s  10s  Check If BTS Is Not In Uncommissioned State
    Wait Until Keyword Succeeds  300s  10s  Check if RMOD is in availabilityStatus Online
    Restart Wts for OnAir
    log to console  Check sw builds after sw update with activation
#    PREPOST Create List Of Bts Parameters
    Get active and passive sw versions after sw update with activation
    run keyword and continue on failure  Check if sw after sw update is the same
    ...     post_update_sw=${post1_update_active_sw}  target_sw=${post2_update_passive_sw}
    run keyword and continue on failure  Check if sw after sw update is the same
    ...     post_update_sw=${post2_update_active_sw}  target_sw=${post2_update_active_sw}
#    Wait For OnAir

CB005752-5G-A-_5GC000174_Software_rollback
    log to console   SW rollback
    Check If BTS Is Not In Uncommissioned State
    Check if RMOD is in availabilityStatus Online
    Wait Until Keyword Succeeds  300s  10s  ADMIN INFOMODEL Check If BTS Is OnAir
    Prepare build for SWR
    Get active and passive sw versions before rollback
    Software_Rollback
    Sleep  120
    Wait Until Keyword Succeeds  300s  10s  Check If BTS Is Not In Uncommissioned State
    Wait Until Keyword Succeeds  300s  10s  Check if RMOD is in availabilityStatus Online
    Restart Wts for OnAir
#    Wait For OnAir
#    PREPOST Create List Of Bts Parameters

 CB005752-5G-A-_5GC000174_Software_download_reject
    log to console   SW download reject
    Check If BTS Is Not In Uncommissioned State
    Check if RMOD is in availabilityStatus Online
    Wait Until Keyword Succeeds  300s  10s  ADMIN INFOMODEL Check If BTS Is OnAir
    Get active and passive sw versions before sw update
    Remove TargetBD file to make SW update fail
    ${upload_error}=   Run Keyword And Expect Error    *   ADMIN Update Software With Activation
    ...     sw_package=${OUTPUT_DIR}/${main_package}
    ...     timeout=600
    Sleep  60
    Get active and passive sw versions after sw update
    run keyword and continue on failure  Check if sw after sw update is the same
    ...     post_update_sw=${pre_update_active_sw}  target_sw=${post_update_active_sw}
    Sleep  120
    Wait Until Keyword Succeeds  300s  10s  Check If BTS Is Not In Uncommissioned State
    Wait Until Keyword Succeeds  300s  10s  Check if RMOD is in availabilityStatus Online

CB005752-5G-A-_5GC000174_Robustness_Stop_software_download
    log to console   Stop SW download in loop
    Check If BTS Is Not In Uncommissioned State
    ADMIN INFOMODEL Check If BTS Is OnAir
    FOR    ${0}    IN RANGE    ${5}
       Get active and passive sw versions before sw update
       SW update and cancel
       Get active and passive sw versions after sw update
       run keyword and continue on failure  Check if sw after sw update is the same
       ...     post_update_sw=${post_update_active_sw}  target_sw=${pre_update_active_sw}
#    \   ADMIN INFOMODEL Check If BTS Is OnAir
    END
    Sleep  120

CB005752-5G-A-_5GC000174_Save_SW_history_report
    log to console   Save SW history report
    Wait Until Keyword Succeeds  300s  10s  ADMIN INFOMODEL Check If BTS Is OnAir
    SELENIUM Prepare Enviroment
    Login To Web Element Manager
    Go To Software Management Tab
    SELENIUM Save SW History Report
    Sleep   60
    SELENIUM Teardown Enviroment

CB005752-5G-A-_5GC000174_Save_SW_update_report
    log to console   Save SW update report
    Wait Until Keyword Succeeds  300s  10s  ADMIN INFOMODEL Check If BTS Is OnAir
    SELENIUM Prepare Enviroment
    Login To Web Element Manager
    Go To Software Management Tab
    SELENIUM Save SW Update Report
    Sleep   60
    SELENIUM Teardown Enviroment







Wait For OnAir
    [Documentation]
    ...    to check if cOAM BTS is in OnAir
    [Arguments]    ${timeout}=15 min
    wait until keyword succeeds    ${timeout}
    ...                            30s
    ...                            ADMIN INFOMODEL Check If BTS Is OnAir

Get active and passive sw versions before sw update
	PREPOST Create List Of Bts Parameters
    PREPOST Get Active And Passive Software Versions
    log to console   active sw: ${OUT_ACTIVE_SW}
    log to console   passive sw: ${OUT_PASSIVE_SW}
    ${pre_update_active_sw}=   Set variable   ${OUT_ACTIVE_SW}
    ${pre_update_passive_sw}=   Set variable   ${OUT_PASSIVE_SW}
	set test variable      ${pre_update_active_sw}
	set test variable	   ${pre_update_passive_sw}


Software_Rollback
    log to console  SW Rollback
    ${output}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/run/
    should contain  ${output}  	TargetBD_${pre_rollback_active_sw}.xml
    ${output}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/stb/
    should contain  ${output}  	TargetBD_${pre_rollback_passive_sw}.xml
    ADMIN Rollback Software
    SYSTEM Wait Till Gnb Will Not Be Pingable For A Given Period
    SYSTEM Wait Till Gnb Will Be Pingable For A Given Period
    Sleep  180
    Get active and passive sw versions after rollback
    ${output}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/run/
    should contain  ${output}  	TargetBD_${post_rollback_active_sw}.xml
    ${output}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/stb/
    should contain  ${output}  	TargetBD_${post_rollback_passive_sw}.xml
    Sleep  10

Get active and passive sw versions after sw update
    PREPOST Create List Of Bts Parameters
    PREPOST Get Active And Passive Software Versions
    log to console   active sw: ${OUT_ACTIVE_SW}
    log to console   passive sw: ${OUT_PASSIVE_SW}
    ${post_update_active_sw}=   Set variable   ${OUT_ACTIVE_SW}
    ${post_update_passive_sw}=   Set variable   ${OUT_PASSIVE_SW}
	set test variable      ${post_update_active_sw}
	set test variable	   ${post_update_passive_sw}

Get active and passive sw versions after sw update without activation
    PREPOST Create List Of Bts Parameters
    PREPOST Get Active And Passive Software Versions
    log to console   active sw: ${OUT_ACTIVE_SW}
    log to console   passive sw: ${OUT_PASSIVE_SW}
    ${post1_update_active_sw}=   Set variable   ${OUT_ACTIVE_SW}
    ${post1_update_passive_sw}=   Set variable   ${OUT_PASSIVE_SW}
	set test variable      ${post1_update_active_sw}
	set test variable	   ${post1_update_passive_sw}

Get active and passive sw versions after sw update with activation
    PREPOST Create List Of Bts Parameters
    PREPOST Get Active And Passive Software Versions
    log to console   active sw: ${OUT_ACTIVE_SW}
    log to console   passive sw: ${OUT_PASSIVE_SW}
    ${post2_update_active_sw}=   Set variable   ${OUT_ACTIVE_SW}
    ${post2_update_passive_sw}=   Set variable   ${OUT_PASSIVE_SW}
	set test variable      ${post2_update_active_sw}
	set test variable	   ${post2_update_passive_sw}

Check if sw after sw update is the same
    [Arguments]  ${post_update_sw}  ${target_sw}
    Log To Console  Check if SW ${post_update_sw} is the same with ${target_sw}
    Should Be True  '${post_update_sw}' == '${target_sw}'
    ...  msg=Post update SW doesn't match target Sw.

SW update and cancel
    ${CLI_INTERFACE}                               Get Library Instance    taf.sbts.oam.coam.admin
    ADMIN Connect To                               admin_alias=ADMIN_SW_Update_in_background
    keyword.IM SWM usageState Should Be Idle - Slave    admin_alias=ADMIN_SW_Update_in_background
    Sleep  10
    ${output_task_abort_in_background}   taf.sbts.oam.coam.admin.run_keyword_in_background
    ...     interface=${CLI_INTERFACE}
    ...     name=update_software
    ...     sw_package=${SW_DESTINATION}/${T2_package}
    ...     should_activate=${TRUE}
    ...     connection=ADMIN_SW_Update_in_background
    # process: download
    Sleep  10
    IM Wait Until SWM usageState Should Be Busy    retry=10 min    retry_interval=2 sec
    ADMIN SW Update Abort
    Sleep  60

    [Teardown]    ADMIN Teardown    admin_alias=ADMIN_SW_Update_in_background

Remove TargetBD file to make SW update fail
    ${ACTIVE_SOFTWARE}=    Replace String Using Regexp    ${OUT_ACTIVE_SW}    ^5G20[A-Za-z0-9]*\_?    5G20_
    ${ACTIVE_SOFTWARE}=    Get Substring    ${ACTIVE_SOFTWARE}    26    31
    ${ACTIVE_SOFTWARE_NUMBER}=    Get Substring    ${ACTIVE_SOFTWARE}    26    31
#    ${sw_package_T1}=    Convert To String    ${SW_DESTINATION}/AirScale-0.800.${ACTIVE_SOFTWARE_NUMBER}T1_edit_HC.zip
#    ${sw_package}=    Convert To String    ${SW_DESTINATION}/AirScale-0.800.${ACTIVE_SOFTWARE_NUMBER}_edit_HC.zip
    Run     unzip -o ${SW_DESTINATION}/${main_package} -d /tmp
    Run     ls -ltr /tmp/bts_sw/TargetBD*.xml
    Run     rm -rf /tmp/bts_sw/TargetBD*.xml
    Run     zip -r ${OUTPUT_DIR}/${main_package} /tmp/bts_sw
    Remove Directory     /tmp/bts_sw   recursive=True

Get active and passive sw versions before rollback
	PREPOST Create List Of Bts Parameters
    PREPOST Get Active And Passive Software Versions
    log to console   active sw: ${OUT_ACTIVE_SW}
    log to console   passive sw: ${OUT_PASSIVE_SW}
    ${pre_rollback_active_sw}=   Set variable   ${OUT_ACTIVE_SW}
    ${pre_rollback_passive_sw}=   Set variable   ${OUT_PASSIVE_SW}
	set test variable      ${pre_rollback_active_sw}
	set test variable	   ${pre_rollback_passive_sw}

Get active and passive sw versions after rollback
    PREPOST Create List Of Bts Parameters
    PREPOST Get Active And Passive Software Versions
    log to console   active sw: ${OUT_ACTIVE_SW}
    log to console   passive sw: ${OUT_PASSIVE_SW}
    ${post_rollback_active_sw}=   Set variable   ${OUT_ACTIVE_SW}
    ${post_rollback_passive_sw}=   Set variable   ${OUT_PASSIVE_SW}
	set test variable      ${post_rollback_active_sw}
	set test variable	   ${post_rollback_passive_sw}

Prepare build for SWR
    Set Suite Variable    ${active_software}    ${OUT_ACTIVE_SW}
    ${split_build}=    Split string       ${active_software}    separator=\_
    ${trunk_flag}=     Get from list       ${split_build}     2
    ${version_flag}=   Get from list       ${split_build}     0
    ${download_build}=    Run keyword if    '${trunk_flag}'=='0000'    Set Variable   ${active_software}
    ...   ELSE IF   '${version_flag}'=='${TRUNK_VERSION}'    Replace String    ${active_software}    ${TRUNK_VERSION}    SBTS00
	...   ELSE   	Set Variable   ${active_software}
    Set Suite Variable    ${main_package}    ${download_build}_release_BTSSM_downloadable.zip
    Set Suite Variable    ${T1_package}    ${download_build}_release_BTSSM_downloadable_testpackage_T1.zip
    Set Suite Variable    ${T2_package}    ${download_build}_release_BTSSM_downloadable_testpackage_T2.zip
    ADMIN Update Software With Activation
    ...            sw_package=${SW_DESTINATION}/${T1_package}
    ...            timeout=600
    log to console  sw activation ongoing - BTS reset
    Sleep   300
    Wait Until Keyword Succeeds  300s  10s  Check If BTS Is Not In Uncommissioned State
    Wait Until Keyword Succeeds  300s  10s  Check if RMOD is in availabilityStatus Online
    Restart Wts for OnAir

Login To Web Element Manager
    [Arguments]    #${browser_url}=${WEBEM_IP}
    ...            ${webem_username}=${USERNAME}
    ...            ${webem_password}=${PASSWORD}
    #...            ${browser_type}=chrome
    #...            ${browser_alias}=browser
    Set Selenium Implicit Wait    5
    Open Browser
    SELENIUM Input Text in Visible Element
    ...    locator=${WELCOME_SCREEN_USERNAME_INPUT_SBTS}
    ...    text=${webem_username}
    Input Text
    ...    locator=${WELCOME_SCREEN_PASS_INPUT_SBTS}
    ...    text=${webem_password}
    Click Element
    ...    locator=${WELCOME_SCREEN_LOGIN_BTN_SBTS}
    SELENIUM Pop Confirm
    Run Keyword And Ignore Error    SELENIUM Click Visible Element   locator=//ui-button[@a-text="Close"]
    Run Keyword And Ignore Error    SELENIUM Click Visible Element   locator=//div[contains(text(), "STARTED")]
    Run Keyword And Ignore Error    SELENIUM Click Visible Element   locator=//div[contains(text(), "SUCCEEDED")]

Open Browser
    ${chrome options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${chrome options}    add_argument    --ignore-certificate-errors
    Call Method    ${chrome options}    add_argument    --start-maximized
    Create Webdriver    Chrome    chrome_options=${chrome options}
    Goto    https://192.168.255.129
    Sleep    10 secs

Go To Software Management Tab
    Wait Until Element Is Visible
    ...    locator=//div[@aria-describedby="admin.navigationBar.software.TITLE"]
    ...    timeout=10
    Run Keyword And Ignore Error
    ...    Wait Until Element Is Not Visible
    ...    locator=//div[@class="notifyjs-corner"]//div
    ...    timeout=60
    Click Element
    ...    locator=//div[@aria-describedby="admin.navigationBar.software.TITLE"]
    Wait Until Element Is Visible
    ...    locator=//span[contains(text(),'Software Management')]
    ...    timeout=5
    Mouse Over
    ...    locator=//span[contains(text(),'Software Management')]
    Wait Until Element Is Visible
    ...    locator=//span[contains(text(),'Software Update')]
    ...    timeout=5
    Click Element
    ...    locator=//span[contains(text(),'Software Update')]


SELENIUM Save SW Update Report
        SELENIUM Click Visible Element
    ...    locator=${SWM_MGMNT_SAVE_SW_UPDATE_REP_BTN}

SELENIUM Save SW History Report
        SELENIUM Click Visible Element
    ...    locator=${SWM_MGMNT_SAVE_SW_HISTORY_REP_BTN}


Check if RMOD is in availabilityStatus Online
    #[Arguments]      ${timeout}=60s
    ${status1}   Run Keyword And Return Status   ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-1
    ...      value=Online
    Run Keyword Unless   ${status1}   ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-1
    ...      value=None
    ${status2}   Run Keyword And Return Status   ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-2
    ...      value=Online
    Run Keyword Unless   ${status2}   ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-2
    ...      value=None

Restart Wts for OnAir
    Reach onAir Teardown
    ute_wts_runner.Start UTE WTS
    X2 Connection
