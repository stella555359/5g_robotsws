*** Settings ***
Documentation
...    Author: Roxana Craciun (roxana.craciun@nokia.com)
...    Maintainer: Roxana Craciun (roxana.craciun@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:CB005958-5G
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/CB005958-5G/general.robot

Library        String
Library        Telnet
Library        OperatingSystem
Library        Process
Library        BuiltIn
#Library        Selenium2Library
Library        DateTime
#Library        system
#Library        SSHLibrary
Library        taf.transport.ssh    WITH NAME    SSH

Library     XML    use_lxml=True

Resource    ../../resources/admin.robot
Resource    ../../resources/selenium.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot
Resource    ../../resources/fault_trigger.robot


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


${TIMEOUT_STATUS_MESSAGES}       10
${TIMEOUT_COLLECTION_COMPLETED}  1000
${DIR_DOWNLOADS}                 /home/ute/Downloads
${DIR_RESULTS}                   /home/ute/results
${DIR_UNZIP}                     ${DIR_RESULTS}
${SNAPSHOT_FILE_NAME_BEGINNING}  Snapshot_MRBTS-1_
${SNAPSHOT_FILE_NAME}            ${SNAPSHOT_FILE_NAME_BEGINNING}*.zip
${METADATA_FILE_NAME}            BTS1_*_metadata.txt
${BTS_PART_DIRS}                 BTS*part*
${FileNumber}           		 15
${keyword}=                      5G
${rmod_id}=                      0
${dist_name}=                    MRBTS-1/NRBTS-1/NRCELL-1
@{log_file_names}                FileList_SWDownload_Start.xz  FileList_SWDownload_End.xz

${delta_file_reportingIntervalPm_5min}=          ${CURDIR}/../resources/PM_interval_5min.json

${delta_file_initial_config}=                    ${CURDIR}/../resources/initial_config.json

${delta_file_actAperCsi_true}=                   ${CURDIR}/../resources/actAperCsi_true.json
${delta_file_actAperCsi_false}=                  ${CURDIR}/../resources/actAperCsi_false.json

*** Keywords ***

Test_new version
        log to console  delta commissioning
        sleep  60
        ADMIN Perform Delta Recommissioning                 delta_file=${delta_file_reportingIntervalPm_5min}
        ...                                                 skip_parameter_relation_errors=True
        Sleep   10
#        wait for right period of 5min
        Remove PM files from ENB
        Clear PM file from tmp

        log to console  Lock/Unlock cell
        ADMIN Lock Cell   ${dist_name}
#        sleep  15
        ADMIN Unlock Cell   ${dist_name}

        Wait to nearest 5 min measurement period

        sleep  60

        log to console   get PM files
        SYSTEM Download File From Server
        ...    password=oZPS0POrRieRtu
        ...    user=toor4nsn
        ...    server_IP=192.168.255.129
        ...    file_path=/ram
        ...    file_name=PM.BTS-1.*.*.*.*.gz
        ...    current_path=/tmp
        ...    current_name=

        Verify PM counters M55601C01 values

M55601C01001 - NR_CELL_PLAN_UNAVAIL_SAMPLES_WebEM

        log to console  delta commissioning
        sleep  60
        ADMIN Perform Delta Recommissioning                 delta_file=${delta_file_reportingIntervalPm_5min}
        ...                                                 skip_parameter_relation_errors=True
#        Sleep   10
        Wait to nearest 5 min measurement period
        sleep   60
        Remove PM files from ENB
        Clear PM file from tmp

        log to console  Lock/Unlock cell
        ADMIN Lock Cell   ${dist_name}
        sleep  15
        ADMIN Unlock Cell   ${dist_name}
        Wait to nearest 5 min measurement period
        sleep  60
        log to console   get PM files
        SYSTEM Download File From Server
        ...    password=oZPS0POrRieRtu
        ...    user=toor4nsn
        ...    server_IP=192.168.255.129
        ...    file_path=/ram
        ...    file_name=PM.BTS-1.*.*.*.*.gz
        ...    current_path=/tmp
        ...    current_name=

        Verify PM counters M55601C01001 values

M55601C01002- NR_CELL_PLAN_UNAVAIL_CHNG_TO_WebEM
        log to console  delta commissioning
        sleep  60
        ADMIN Perform Delta Recommissioning                 delta_file=${delta_file_reportingIntervalPm_5min}
        ...                                                 skip_parameter_relation_errors=True
#        Sleep   10
        Wait to nearest 5 min measurement period
        sleep   60
        Remove PM files from ENB
        Clear PM file from tmp

        SELENIUM Prepare Enviroment
        Login To Web Element Manager

        log to console  Lock/Unlock RMOD
        SELENIUM Lock RMOD   ${rmod_id}
        Sleep  15
        SELENIUM Unlock RMOD   ${rmod_id}

        Wait to nearest 5 min measurement period
        sleep  60
        log to console   get PM files
        SYSTEM Download File From Server
        ...    password=oZPS0POrRieRtu
        ...    user=toor4nsn
        ...    server_IP=192.168.255.129
        ...    file_path=/ram
        ...    file_name=PM.BTS-1.*.*.*.*.gz
        ...    current_path=/tmp
        ...    current_name=

        Verify PM counters M55601C01002 values

Robustness_testing Check if value of NR_CELL_PLAN_UNAVAIL_CHNG_TO is incremented
        log to console  delta commissioning

#        sleep  60
        Wait to nearest 5 min measurement period
        sleep   60
        Remove PM files from ENB
        Clear PM file from tmp

        :FOR    ${i}    IN RANGE    5
        \  ADMIN Perform Delta Recommissioning                 delta_file=${delta_file_actAperCsi_true}
        ...                                                    skip_parameter_relation_errors=True
        \  sleep    15
        \  ADMIN Perform Delta Recommissioning                 delta_file=${delta_file_actAperCsi_false}
        ...                                                    skip_parameter_relation_errors=True
        \  sleep   15

        Wait to nearest 5 min measurement period
        sleep  60
        log to console   get PM files
        SYSTEM Download File From Server
        ...    password=oZPS0POrRieRtu
        ...    user=toor4nsn
        ...    server_IP=192.168.255.129
        ...    file_path=/ram
        ...    file_name=PM.BTS-1.*.*.*.*.gz
        ...    current_path=/tmp
        ...    current_name=

        Verify PM counters M55601C01002 values


Remove PM files from ENB
        SYSTEM Execute Command On gNB
        ...    command=rm /ram/PM.BTS-1.*.*.*.xml.gz
        SYSTEM Execute Command On gNB
        ...    command=rm /ram/PM.BTS-1.*.*.*.raw.gz

Clear PM file from tmp
    Run  rm -f /tmp/PM.BTS-1.*.*.ANY.xml.gz
    Run  rm -f /tmp/PM.BTS-1.*.*.ANY.raw.gz
    Run  rm -f /tmp/PM_file.xml

Wait to nearest 5 min measurement period
	Log To Console  Wait to nearest measurement period
	Wait Until Keyword Succeeds  6 min  1 min  wait for right period of 5min

wait to nearest 15 min measurement period
	Log To Console  Wait to nearest measurement period
	Wait Until Keyword Succeeds  16 min  1 min  wait for right period of 15min

wait for right period of 15min
	${list}=    Create List  00  15  30  45
	${actualTime}=   Get Current Date  result_format=%M   time_zone=UTC
	${actualHour}=   Get Current Date  result_format=%H   time_zone=UTC
	${date}=  		   Get Current Date  result_format=%Y-%m-%d   time_zone=UTC
	${actualEpoch}= 	Convert Date	${date} ${actualHour}:${actualTime}:00.000	epoch
	List Should Contain Value	${list}  ${actualTime}
	Log  ${actualTime}
	Set Global Variable    ${actualTime}
	Set Global Variable    ${actualHour}
	Set Global Variable    ${actualEpoch}


wait for right period of 5min
	${list}=    Create List  00  05  10  15  20  25  30  35  40  45  50  55
	${actualTime}=   Get Current Date  result_format=%M   time_zone=UTC
	${actualHour}=   Get Current Date  result_format=%H   time_zone=UTC
	${date}=  		   Get Current Date  result_format=%Y-%m-%d   time_zone=UTC
	${actualEpoch}= 	Convert Date	${date} ${actualHour}:${actualTime}:00.000	epoch
	List Should Contain Value	${list}  ${actualTime}
	Log  ${actualTime}40
	Set Global Variable    ${actualTime}
	Set Global Variable    ${actualHour}
	Set Global Variable    ${actualEpoch}

Verify PM counters M55601C01 values
    ${PM_Files}=   Run  ls /tmp/PM.BTS-1.*.*.*.xml.* | sort -r
    ${list_of_PM_files}=   Split string    ${PM_files}    separator=\
    log to console   ${list_of_PM_files}
    ${first_PM_file}=  Get From List  ${list_of_PM_files}  0
    ${PM_File_unzipped}=   Run  gunzip ${first_PM_file}
    Run  mv /tmp/PM.BTS-1.*.xml /tmp/PM_file.xml

    log to console   M55601C01001 - NR_CELL_PLAN_UNAVAIL_SAMPLES_WebEM
     ${XML}=   Parse XML   /tmp/PM_file.xml
    ${values}=   Get Elements Texts  ${XML}   PMSetup/PMMOResult/NE-WBTS_1.0[@measurementType="NCAV"]/M55601C01001
    Should be true   @{values}[0]>0 or @{values}[1]>0
    ...  msg=wrong counter value

    log to console   M55601C01002- NR_CELL_PLAN_UNAVAIL_CHNG_TO_WebEM
     ${XML}=   Parse XML   /tmp/PM_file.xml
    ${values}=   Get Elements Texts  ${XML}   PMSetup/PMMOResult/NE-WBTS_1.0[@measurementType="NCAV"]/M55601C01002
    Should be true   @{values}[0]>0 or @{values}[1]>0
    ...  msg=wrong counter value

    log to console   M55601C01003- NR_CELL_UNPLAN_UNAVAIL_SAMPLES_WebEM
     ${XML}=   Parse XML   /tmp/PM_file.xml
    ${values}=   Get Elements Texts  ${XML}   PMSetup/PMMOResult/NE-WBTS_1.0[@measurementType="NCAV"]/M55601C01003
    Should be true   @{values}[0]!=300 and @{values}[1]!=300
    ...  msg=wrong counter value

    log to console   M55601C01004
     ${XML}=   Parse XML   /tmp/PM_file.xml
    ${values}=   Get Elements Texts  ${XML}   PMSetup/PMMOResult/NE-WBTS_1.0[@measurementType="NCAV"]/M55601C01004
    Should be true   @{values}[0]>0 or @{values}[1]>0
    ...  msg=wrong counter value

Verify PM counters M55601C01001 values

    ${PM_Files}=   Run  ls /tmp/PM.BTS-1.*.*.*.xml.* | sort -r
    ${list_of_PM_files}=   Split string    ${PM_files}    separator=\
    log to console   ${list_of_PM_files}
    ${first_PM_file}=  Get From List  ${list_of_PM_files}  0
    ${PM_File_unzipped}=   Run  gunzip ${first_PM_file}
    Run  mv /tmp/PM.BTS-1.*.xml /tmp/PM_file.xml

    ${XML}=   Parse XML   /tmp/PM_file.xml
    ${values}=   Get Elements Texts  ${XML}   PMSetup/PMMOResult/NE-WBTS_1.0[@measurementType="NCAV"]/M55601C01001
    Should be true  @{values}[0]>0 or @{values}[1]>0
    ...  msg=wrong counter value

#    ${value}=   Get Elements Texts  ${XML}   PMSetup/PMMOResult/NE-WBTS_1.0[@measurementType="ETHIF_stats"]/M51300C1



Verify PM counters M55601C01002 values

    ${PM_Files}=   Run  ls /tmp/PM.BTS-1.*.*.*.xml.* | sort -r
    ${list_of_PM_files}=   Split string    ${PM_files}    separator=\
    log to console   ${list_of_PM_files}
    ${first_PM_file}=  Get From List  ${list_of_PM_files}  0
    ${PM_File_unzipped}=   Run  gunzip ${first_PM_file}
    Run  mv /tmp/PM.BTS-1.*.xml /tmp/PM_file.xml

    ${XML}=   Parse XML   /tmp/PM_file.xml
    ${values}=   Get Elements Texts   ${XML}   PMSetup/PMMOResult/NE-WBTS_1.0[@measurementType="NCAV"]/M55601C01002
    Should be true   @{values}[0]>0 or @{values}[1]>0
    ...  msg=wrong counter value

Verify PM counters M55601C01003 and M55601C01004 values

    ${PM_Files}=   Run  ls /tmp/PM.BTS-1.*.*.*.xml.* | sort -r
    ${list_of_PM_files}=   Split string    ${PM_files}    separator=\
    log to console   ${list_of_PM_files}
    ${first_PM_file}=  Get From List  ${list_of_PM_files}  0
    ${PM_File_unzipped}=   Run  gunzip ${first_PM_file}
    Run  mv /tmp/PM.BTS-1.*.xml /tmp/PM_file.xml

    ${XML}=   Parse XML   /tmp/PM_file.xml
    ${values}=   Get Elements Texts  ${XML}   PMSetup/PMMOResult/NE-WBTS_1.0[@measurementType="NCAV"]/M55601C01003
    Should be true   @{values}[0]>0 or @{values}[1]>0
    ...  msg=wrong counter value

    ${values}=   Get Elements Texts  ${XML}   PMSetup/PMMOResult/NE-WBTS_1.0[@measurementType="NCAV"]/M55601C01004
    Should be true   @{values}[0]>0 or @{values}[1]>0
    ...  msg=wrong counter value

Get Raw PM File From BTS
    SSH.connect_to    hostname=192.168.255.129    username=toor4nsn    password=oZPS0POrRieRtu    alias=eNB
    ${raw_counters_list}=    SSH.execute    ls /tmp/ | grep PM\.BTS.*\.raw\.gz | sort -r    connection=eNB
    ${last_raw_counter}=    String.Get Line    ${raw_counters_list}    0
    SSH.Download File   /ram/${last_raw_counter}    /tmp/${last_raw_counter}    connection=eNB
    run keyword and ignore error    SSH.disconnect    connection=eNB
    Run    gzip -d /tmp/${last_raw_counter}
    ${raw_counter_unzipped}=    String.Fetch From Left    ${last_raw_counter}    .gz
    [Return]    /tmp/${raw_counter_unzipped}

Wait to hour change
    [Documentation]
    ...   Author: Tomasz Pietruszkiewicz
	${list} =	Create List	00
	${actualTime}=   Get Current Date  result_format=%M   time_zone=UTC
	${actualHour}=   Get Current Date  result_format=%H   time_zone=UTC
	List Should Contain Value	${list}  ${actualTime}
	Log  ${actualTime}
	Set Global Variable    ${actualTime}
	Set Global Variable    ${actualHour}

Login To Web Element Manager
    [Arguments]    ${browser_url}=${WEBEM_IP}
    ...            ${webem_username}=${USERNAME}
    ...            ${webem_password}=${PASSWORD}
    ...            ${browser_type}=chrome
    ...            ${browser_alias}=browser
    Set Selenium Implicit Wait    5
    Open Browser
    Branch or Trunk
    Run Keyword If  '${branch}' == '5G21A'  Run Keyword  Login Credentials 5G21A
    ...         ELSE  Run Keyword  Login Credentials SBTS
    SELENIUM Pop Confirm
    Run Keyword And Ignore Error    SELENIUM Click Visible Element   locator=//ui-button[@a-text="Close"]
    Run Keyword And Ignore Error    SELENIUM Click Visible Element   locator=//div[contains(text(), "STARTED")]
    Run Keyword And Ignore Error    SELENIUM Click Visible Element   locator=//div[contains(text(), "SUCCEEDED")]


Open Browser
    ${chrome options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${chrome options}    add_argument    --ignore-certificate-errors
    Call Method    ${chrome options}    add_argument    --window-size\=1900,1200
    Call Method    ${chrome options}    add_argument    --headless
    Call Method    ${chrome options}    add_argument    --no-sandbox
    Create Webdriver    Chrome    chrome_options=${chrome options}
    Goto    https://192.168.255.129
    Sleep    10 secs

Login Credentials SBTS
    [Arguments]    ${webem_username}=${USERNAME}
    ...            ${webem_password}=${PASSWORD}
    Input Text        id=login-username    ${webem_username}
    Input Password    id=login-password    ${webem_password}
    Run Keyword If  '${branch}' == 'SBTS22R2'
    ...     Click Button   locator=//button[@class="ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only"]
    ...     ELSE      Click Button    locator=//button[@class="p-ripple p-element p-button p-component"]


Login Credentials 5G21A
    [Arguments]    ${webem_username}=${USERNAME}
    ...            ${webem_password}=${PASSWORD}
    SELENIUM Input Text in Visible Element
    ...    locator=${WELCOME_SCREEN_USERNAME_INPUT}
    ...    text=${webem_username}
    Input Text
    ...    locator=${WELCOME_SCREEN_PASS_INPUT}
    ...    text=${webem_password}
    Click Element
    ...    locator=${WELCOME_SCREEN_LOGIN_BTN}


Branch or Trunk
    @{sw_version}=  Split String  ${out_active_sw}  separator=\_
    ${branch}=  Set Variable  @{sw_version}[0]
    Set Global Variable  ${branch}

Go To BTS Counter Tab
    Wait Until Page Contains Element    locator=//div[@aria-describedby="admin.navigationBar.performance.TITLE"]
    Sleep  5s
    Click Element    locator=//div[@aria-describedby="admin.navigationBar.performance.TITLE"]
    Click Element    locator=//span[text()="Performance Management"]



Download Export Table
    Wait Until Element Is Visible    locator=//ui-button[@a-title='Export Table']//button
    ...                              timeout=15
    Click Button    locator=//ui-button[@a-title='Export Table']//button
    Sleep  1



