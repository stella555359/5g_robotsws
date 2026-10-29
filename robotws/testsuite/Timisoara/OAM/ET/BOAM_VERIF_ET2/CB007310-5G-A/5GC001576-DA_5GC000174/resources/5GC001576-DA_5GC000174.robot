*** Settings ***
Documentation
...    Author: Izabela Muntean
...    Maintainer: Izabela Muntean
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

Resource    ../../../resources/admin.robot
Resource    ../../../resources/admin_infomodel.robot
Resource    ../../../resources/pretest_posttest.robot
Resource    ../../../resources/system.robot
Resource    ../../../resources/selenium.robot
Resource    ../../../resources/fault_trigger.robot
Resource    ./keyword.robot

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

*** Keywords ***
5GC001576-DA_Activation_for_pre-downloaded_SW
    log to console   Activation for pre downloaded SW
    keyword.Check If BTS Is Not In Uncommissioned State
    # TODO  Check Bts Side
    Get active and passive sw versions before sw update
    ADMIN Update Software With Activation
    ...            sw_package=${SW_DESTINATION}/${main_package}
    ...            timeout=600
    Sleep  90
    Get active and passive sw versions after sw update
    run keyword and continue on failure  Check if sw after sw update is the same
    ...     post_update_sw=${post_update_active_sw}  target_sw=${pre_update_active_sw}
    Sleep   90
    keyword.Check If BTS Is Not In Uncommissioned State

5GC001576-DA_Configuration_backup
    log to console   Configuration backup
    keyword.Check If BTS Is Not In Uncommissioned State
    ADMIN Collect Scf   local_dir_path=${scf_path}    file_name=${scf_name}
    Sleep   60
    keyword.Check If BTS Is Not In Uncommissioned State

5GC001576-DA_Software_download_reject
    log to console   SW download reject
    keyword.Check If BTS Is Not In Uncommissioned State
    Get active and passive sw versions before sw update
    Remove TargetBD file to make SW update fail
    ${upload_error}=   Run Keyword And Expect Error    *   ADMIN Update Software With Activation
    ...     sw_package=${OUTPUT_DIR}/${main_package}
    ...     timeout=600
    Sleep  60
    Get active and passive sw versions after sw update
    run keyword and continue on failure  Check if sw after sw update is the same
    ...     post_update_sw=${post_update_active_sw}  target_sw=${pre_update_active_sw}
    keyword.Check If BTS Is Not In Uncommissioned State

5GC001576-DA_Stop_software_download
    log to console   Stop SW download
    keyword.Check If BTS Is Not In Uncommissioned State
    Get active and passive sw versions before sw update
    SW update and cancel
    Sleep  30
    Get active and passive sw versions after sw update
    run keyword and continue on failure  Check if sw after sw update is the same
    ...     post_update_sw=${post_update_active_sw}  target_sw=${pre_update_active_sw}

5GC001576-DA_Save_SW_history_report
    log to console   Save SW history report
    Get Software Release
    SELENIUM Prepare Enviroment
    Login To Web Element Manager
    Go To Software Management Tab
    SELENIUM Save SW History Report
    Sleep   60
    SELENIUM Teardown Enviroment

5GC001576-DA_Save_SW_update_report
    log to console   Save SW update report
    Get Software Release
    SELENIUM Prepare Enviroment
    Login To Web Element Manager
    Go To Software Management Tab
    SELENIUM Save SW Update Report
    Sleep   60
    SELENIUM Teardown Enviroment

5GC001576-DA_Software_rollback
    log to console   SW rollback
    keyword.Check If BTS Is Not In Uncommissioned State
    Get active and passive sw versions before sw update
    log to console   SW Update to Testpackage  console=yes
    ADMIN Update Software With Activation
    ...    sw_package=${SW_DESTINATION}/${T1_package}
    ...    timeout=2000
    Sleep  800
    keyword.Check If BTS Is Not In Uncommissioned State
    Get active and passive sw versions before rollback
    Software_Rollback
    keyword.Check If BTS Is Not In Uncommissioned State

#......................................................................
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
    Sleep  400
    Get active and passive sw versions after rollback
    ${output}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/run/
    should contain  ${output}  	TargetBD_${post_rollback_active_sw}.xml
    ${output}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/stb/
    should contain  ${output}  	TargetBD_${post_rollback_passive_sw}.xml
    Sleep  180

Get active and passive sw versions after sw update
   # PREPOST Create List Of Bts Parameters
    PREPOST Get Active And Passive Software Versions
    log to console   active sw: ${OUT_ACTIVE_SW}
    log to console   passive sw: ${OUT_PASSIVE_SW}
    ${post_update_active_sw}=   Set variable   ${OUT_ACTIVE_SW}
    ${post_update_passive_sw}=   Set variable   ${OUT_PASSIVE_SW}
	set test variable      ${post_update_active_sw}
	set test variable	   ${post_update_passive_sw}

Check if sw after sw update is the same
    [Arguments]  ${post_update_sw}  ${target_sw}
    Log To Console  Check if SW ${post_update_sw} is the same with ${target_sw}
    Should Be True  '${post_update_sw}' == '${target_sw}'
    ...  msg=Post update SW doesn't match target Sw.

SW update and cancel
    ${CLI_INTERFACE}                               Get Library Instance    taf.sbts.oam.coam.admin
    ADMIN Connect To                               admin_alias=ADMIN_SW_Update_in_background
#    keyword.IM SWM usageState Should Be Idle - Slave    admin_alias=ADMIN_SW_Update_in_background
    Sleep  5
    ${output_task_abort_in_background}   taf.sbts.oam.coam.admin.run_keyword_in_background
    ...     interface=${CLI_INTERFACE}
    ...     name=update_software
    ...     sw_package=${SW_DESTINATION}/${T2_package}
    ...     should_activate=${TRUE}
    ...     connection=ADMIN_SW_Update_in_background
    # process: download
    IM Wait Until SWM usageState Should Be Busy    retry=5 min    retry_interval=10 sec
    Sleep  10
    ADMIN SW Update Abort

Remove TargetBD file to make SW update fail
    ${ACTIVE_SOFTWARE}=    Replace String Using Regexp    ${OUT_ACTIVE_SW}    ^5G20[A-Za-z0-9]*\_?    5G20_
    ${ACTIVE_SOFTWARE}=    Get Substring    ${ACTIVE_SOFTWARE}    0    28
    ${ACTIVE_SOFTWARE_NUMBER}=    Get Substring    ${ACTIVE_SOFTWARE}    23    28
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

Login To Web Element Manager
    [Arguments]    ${browser_url}=${WEBEM_IP}
    ...            ${webem_username}=${USERNAME}
    ...            ${webem_password}=${PASSWORD}
    ...            ${browser_type}=chrome
    ...            ${browser_alias}=browser
    Set Selenium Implicit Wait    5
    Open Browser
    Login Credentials SBTS
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

Login Credentials SBTS
    [Arguments]    ${webem_username}=${USERNAME}
    ...            ${webem_password}=${PASSWORD}
    Input Text        id=login-username    ${webem_username}
    Input Password    id=login-password    ${webem_password}
    Run keyword If      '${sw_release}' == 'SBTS22R2'
    ...       Click Button      locator=//button[@class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"]
    ...       ELSE
    ...       Click Button      locator=//button[@class="p-ripple p-element p-button p-component"]


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

UTE TL Preparation
    [Documentation]     Keyword used for setting up local 5G TLs to onAir state, as UTE reserve it only to sw_upload state
    #TO DO:             Add Check for onAir State. For cases when the Suite is run more than one time
    PREPOST Setup Admin
    ADMIN Change R&D Port Status    status=True
    @{status}   Run Keyword and Ignore Error    ADMIN Check BTS onair
    Run Keyword If  '@{status}[0]' == 'FAIL'   Run Keyword  5GC001576-DA_5GC000174.Configured_SwDownload_SwUpdate_OnAir
    ...     ELSE    Log To Console  --- BTS already onAir ---
    ADMIN Teardown Admin

Configured_SwDownload_SwUpdate_OnAir
    ADMIN Check BTS Not Commisioned
    Get TL Hostname
    Get Software Release
    ADMIN Perform Commissioning
    ...     scf_file=/home/ute/MN/UTE/robotws/custom-config/Timisoara/${tl_hostname}/${sw_release}/${tl_hostname}_SCF.xml
    ${configured}   Run Keyword and Return Status    BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Check BTS Configured
    Run Keyword If  '${configured}' == 'True'  Sleep  180
    Run Keyword Unless   ${configured}   Run Keywords   admin.ADMIN Reset Site
    ...    AND     BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Check BTS Configured
    ...    AND     Sleep  180
    Log To Console  Fault ID23 Checking...
    ${result}   Run Keyword and Return Status    ADMIN Check If Alarm Is Active  fault_id=23
    BuiltIn.Run Keyword If  '${result}' == 'True'   Run Keywords   Log To Console  Fault ID23 found. Start RF Software Update
    ...     AND     ADMIN Download And Update Current Software
    ...     ELSE    Log To Console  Fault ID23 not found.
    ${onair}   Run Keyword and Return Status    BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Wait Until BTS OnAir
    Run Keyword Unless   ${onair}   Run Keywords   admin.ADMIN Reset Site
    ...    AND     BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Wait Until BTS OnAir

