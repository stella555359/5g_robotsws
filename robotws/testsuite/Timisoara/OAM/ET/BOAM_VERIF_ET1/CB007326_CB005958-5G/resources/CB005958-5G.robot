*** Settings ***
Documentation
...    Author: George Medesan (george.medesan@nokia.com)
...    Maintainer: George Medesan (george.medesan@nokia.com)
...    Group in charge: BTS_OAM_VERIF_ET1
...    References: doors
...    Feature Description:CB005958-5G
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/CB007326_CB005958-5G/general.robot

Library        String
Library        Telnet
Library        OperatingSystem
Library        Process
Library        BuiltIn
#Library        Selenium2Library
Library        DateTime
#Library        system
Library        SSHLibrary
#Library        taf.transport.ssh    WITH NAME    ssh

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
${delta_file_locked_cell}                ${CURDIR}/Delta_Configuration_scf_administrative_locked.json
${delta_file_unlocked_cell}                ${CURDIR}/Delta_Configuration_scf_administrative_unlocked.json
@{log_file_names}                FileList_SWDownload_Start.xz  FileList_SWDownload_End.xz

${delta_file_reportingIntervalPm_5min}=          ${CURDIR}/../resources/PM_interval_5min.json

${delta_file_initial_config}=                    ${CURDIR}/../resources/initial_config.json

${delta_file_actAperCsi_true}=                   ${CURDIR}/../resources/actAperCsi_true.json
${delta_file_actAperCsi_false}=                  ${CURDIR}/../resources/actAperCsi_false.json

${BRANCH}               SBTS
#${SYSTEM_IPHY_IP}=             172.22.0.2
${SYSTEM_ENB_LOCAL_IP}=        192.168.255.1
${SYSTEM_ENB_SSH_USERNAME}=    toor4nsn
${SYSTEM_ENB_SSH_PASSWORD}=    oZPS0POrRieRtu
${USERNAME_Web}=               Nemuadmin
${PASSWORD_Web}=               nemuuser
${SYSTEM_ALIAS_ASOE}=          asoe
${SYSTEM_ALIAS_PROXY}=         rmod
${SYSTEM_RMOD_LOCAL_IP}        172.22.0.2
${SYSTEM_RMOD_SSH_USERNAME}    root
${SYSTEM_RMOD_SSH_PASSWORD}    umniedziala
${SYSTEM_RMOD_SSH_PASSWORD_AEQN}     w@=EIj7P6R0bVy85OjCVa^ho&8

${host}        192.168.255.1
${port}        22
${username}    toor4nsn
${password}    oZPS0POrRieRtu
${alias}       enb

*** Keywords ***
M55601C01001-NR_CELL_PLAN_UNAVAIL_SAMPLES_WebEM
        log to console  M55601C01001-NR_CELL_PLAN_UNAVAIL_SAMPLES_WebEM
        log to console  delta commissioning
        sleep  60
        ADMIN Perform Delta Recommissioning                 delta_file=${delta_file_reportingIntervalPm_5min}
        ...                                                 skip_parameter_relation_errors=True
        Sleep   10
        Wait to nearest 5 min measurement period
        sleep   60
        Remove PM files from ENB
        Clear PM file from tmp

        log to console  Lock/Unlock cell
        ADMIN Perform Delta Recommissioning     ${delta_file_locked_cell}  True
        sleep  15
        ADMIN Perform Delta Recommissioning     ${delta_file_unlocked_cell}  True
#        ADMIN Lock Cell   ${dist_name}
#        sleep  15
#        ADMIN Unlock Cell   ${dist_name}
        wait to nearest 5 min measurement period
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

        log to console  M55601C01003-NR_CELL_UNPLAN_UNAVAIL_SAMPLES_WebEM
        log to console  Start test fault 10
        Check If BTS Is Not In Uncommissioned State
        SYSTEM Check if fault is not in active raw alarm  0010   EFaultId_NoConnectionToUnitAl
        ADMIN Check If Alarm Is Not Active  fault_id=10
        Wait to nearest 5 min measurement period
        SYSTEM Execute Command On IPHY  ddal -s ddal_reboot_graceful
        Sleep  300
        SYSTEM Check if fault is in active raw alarm  0010   EFaultId_NoConnectionToUnitAl
        ADMIN Check If Alarm Is Active  fault_id=10
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
		Verify PM counters M55601C01003 values
        Sleep  180
        admin.ADMIN Reset Site
#        SYSTEM Wait For Host Is Reachable With Ping  192.168.200.1
#        Sleep  500
#        SYSTEM Check if fault is not in active raw alarm  0010   EFaultId_NoConnectionToUnitAl
#        ADMIN Check If Alarm Is Not Active  fault_id=10
        SYSTEM Wait For Host Is Reachable With Ping  192.168.200.1
        Sleep  300
        SYSTEM Check if fault is not in active raw alarm  0010   EFaultId_NoConnectionToUnitAl
        ADMIN Check If Alarm Is Not Active  fault_id=10

M55601C01002-NR_CELL_PLAN_UNAVAIL_CHNG_TO_WebEM
        log to console  M55601C01002-NR_CELL_PLAN_UNAVAIL_CHNG_TO_WebEM
        log to console  delta commissioning
        sleep  60
        ADMIN Perform Delta Recommissioning                 delta_file=${delta_file_reportingIntervalPm_5min}
        ...                                                 skip_parameter_relation_errors=True
        Sleep   10
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
        wait to nearest 5 min measurement period
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

        log to console  Robustness_testing_Check_if_value_of_NR_CELL_PLAN_UNAVAIL_CHNG_TO_is_incremented
        Wait to nearest 5 min measurement period
        sleep  60
        Remove PM files from ENB
        Clear PM file from tmp
        FOR    ${i}    IN RANGE    5
          ADMIN Perform Delta Recommissioning                 delta_file=${delta_file_actAperCsi_true}
        ...                                                 skip_parameter_relation_errors=True
          sleep    15
          ADMIN Perform Delta Recommissioning                 delta_file=${delta_file_actAperCsi_false}
        ...                                                 skip_parameter_relation_errors=True
          sleep   15
        END
        wait to nearest 5 min measurement period
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


Robustness_testing_Check_if_value_of_NR_CELL_PLAN_UNAVAIL_CHNG_TO_is_incremented
        log to console  delta commissioning

        Wait to nearest 5 min measurement period
        sleep  60
        Remove PM files from ENB
        Clear PM file from tmp

        FOR    ${i}    IN RANGE    5
          ADMIN Perform Delta Recommissioning                 delta_file=${delta_file_actAperCsi_true}
        ...                                                 skip_parameter_relation_errors=True
          sleep    15
          ADMIN Perform Delta Recommissioning                 delta_file=${delta_file_actAperCsi_false}
        ...                                                 skip_parameter_relation_errors=True
          sleep   15
        END
        wait to nearest 5 min measurement period
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

M55601C01003-NR_CELL_UNPLAN_UNAVAIL_SAMPLES_WebEM

        log to console  delta commissioning
        sleep  60
        ADMIN Perform Delta Recommissioning                 delta_file=${delta_file_reportingIntervalPm_5min}
        ...                                                 skip_parameter_relation_errors=True
        Sleep   10
        Remove PM files from ENB
        Clear PM file from tmp

#        Check If BTS Is Not In Uncommissioned State
#        SYSTEM Check if fault is not in active raw alarm  0010   EFaultId_NoConnectionToUnitAl
#        ADMIN Check If Alarm Is Not Active  fault_id=10

#        Wait to nearest 5 min measurement period
#        SYSTEM Execute Command On IPHY  ddal -s ddal_reboot_graceful
#        SYSTEM Wait Till Iphy Will Not Be Pingable For A Given Period
#        Sleep  60
#        SYSTEM Check if fault is in active raw alarm  0010   EFaultId_NoConnectionToUnitAl
#        ADMIN Check If Alarm Is Active  fault_id=10

        log to console  Start test fault 10

        Check If BTS Is Not In Uncommissioned State
        SYSTEM Check if fault is not in active raw alarm  0010   EFaultId_NoConnectionToUnitAl
        ADMIN Check If Alarm Is Not Active  fault_id=10

        Wait to nearest 5 min measurement period
        SYSTEM Execute Command On IPHY  ddal -s ddal_reboot_graceful
#        SYSTEM Wait Till Iphy Will Not Be Pingable For A Given Period
        Sleep  240
        SYSTEM Check if fault is in active raw alarm  0010   EFaultId_NoConnectionToUnitAl
        ADMIN Check If Alarm Is Active  fault_id=10

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

		Verify PM counters M55601C01003 values

        Sleep  180
        admin.ADMIN Reset Site
#        SYSTEM Wait For Host Is Reachable With Ping  192.168.200.1
#        Sleep  500
#        SYSTEM Check if fault is not in active raw alarm  0010   EFaultId_NoConnectionToUnitAl
#        ADMIN Check If Alarm Is Not Active  fault_id=10

        SYSTEM Wait For Host Is Reachable With Ping  192.168.200.1
        Sleep  300
        SYSTEM Check if fault is not in active raw alarm  0010   EFaultId_NoConnectionToUnitAl
        ADMIN Check If Alarm Is Not Active  fault_id=10

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
	Log To Console  Wait to nearest measurement period - 5 min
	Wait Until Keyword Succeeds  6 min  1 min  wait for right period of 5min

wait to nearest 15 min measurement period
	Log To Console  Wait to nearest measurement period - 15 min
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
    ${value}=   Get Element Text  ${XML}   PMSetup/PMMOResult/NE-WBTS_1.0[@measurementType="NCAV"]/M55601C01001
    Should be true   ${value}>0
    ...  msg=wrong counter value

    log to console   M55601C01002- NR_CELL_PLAN_UNAVAIL_CHNG_TO_WebEM
     ${XML}=   Parse XML   /tmp/PM_file.xml
    ${value}=   Get Element Text  ${XML}   PMSetup/PMMOResult/NE-WBTS_1.0[@measurementType="NCAV"]/M55601C01002
    Should be true   ${value}>0
    ...  msg=wrong counter value

    log to console   M55601C01003- NR_CELL_UNPLAN_UNAVAIL_SAMPLES_WebEM
     ${XML}=   Parse XML   /tmp/PM_file.xml
    ${value}=   Get Element Text  ${XML}   PMSetup/PMMOResult/NE-WBTS_1.0[@measurementType="NCAV"]/M55601C01003
    Should be true   ${value}!=300
    ...  msg=wrong counter value

    log to console   M55601C01004
     ${XML}=   Parse XML   /tmp/PM_file.xml
    ${value}=   Get Element Text  ${XML}   PMSetup/PMMOResult/NE-WBTS_1.0[@measurementType="NCAV"]/M55601C01004
    Should be true   ${value}>0
    ...  msg=wrong counter value

Verify PM counters M55601C01001 values

    ${PM_Files}=   Run  ls /tmp/PM.BTS-1.*.*.*.xml.* | sort -r
    ${list_of_PM_files}=   Split string    ${PM_files}    separator=\
    log to console   ${list_of_PM_files}
    ${first_PM_file}=  Get From List  ${list_of_PM_files}  0
    ${PM_File_unzipped}=   Run  gunzip ${first_PM_file}
    Run  mv /tmp/PM.BTS-1.*.xml /tmp/PM_file.xml

    ${XML}=   Parse XML   /tmp/PM_file.xml
    ${values_list}=     Get Elements Texts  ${XML}   PMSetup/PMMOResult/NE-WBTS_1.0[@measurementType="NCAV"]/M55601C01001
    ${value}=   Get From List   ${values_list}  0
#    ${value}=   Get Element Text  ${XML}   PMSetup/PMMOResult/NE-WBTS_1.0[@measurementType="NCAV"]/M55601C01001
    Should be true   ${value}>0
    ...  msg=wrong counter value


Verify PM counters M55601C01002 values

    ${PM_Files}=   Run  ls /tmp/PM.BTS-1.*.*.*.xml.* | sort -r
    ${list_of_PM_files}=   Split string    ${PM_files}    separator=\
    log to console   ${list_of_PM_files}
    ${first_PM_file}=  Get From List  ${list_of_PM_files}  0
    ${PM_File_unzipped}=   Run  gunzip ${first_PM_file}
    Run  mv /tmp/PM.BTS-1.*.xml /tmp/PM_file.xml

    ${XML}=   Parse XML   /tmp/PM_file.xml
    ${values_list}=     Get Elements Texts  ${XML}   PMSetup/PMMOResult/NE-WBTS_1.0[@measurementType="NCAV"]/M55601C01002
    ${value}=   Get From List   ${values_list}  0
#    ${value}=   Get Element Text  ${XML}   PMSetup/PMMOResult/NE-WBTS_1.0[@measurementType="NCAV"]/M55601C01002
    Should be true   ${value}>0
    ...  msg=wrong counter value

Verify PM counters M55601C01003 values

    ${PM_Files}=   Run  ls /tmp/PM.BTS-1.*.*.*.xml.* | sort -r
    ${list_of_PM_files}=   Split string    ${PM_files}    separator=\
    log to console   ${list_of_PM_files}
    ${first_PM_file}=  Get From List  ${list_of_PM_files}  0
    ${PM_File_unzipped}=   Run  gunzip ${first_PM_file}
    Run  mv /tmp/PM.BTS-1.*.xml /tmp/PM_file.xml

    ${XML}=   Parse XML   /tmp/PM_file.xml
    ${values_list}=     Get Elements Texts  ${XML}   PMSetup/PMMOResult/NE-WBTS_1.0[@measurementType="NCAV"]/M55601C01003
    ${value}=   Get From List   ${values_list}  0
#    ${value}=   Get Element Text  ${XML}   PMSetup/PMMOResult/NE-WBTS_1.0[@measurementType="NCAV"]/M55601C01003
    Should be true   ${value}>0
    ...  msg=wrong counter value

Verify PM counters M55601C01004 values

    ${PM_Files}=   Run  ls /tmp/PM.BTS-1.*.*.*.xml.* | sort -r
    ${list_of_PM_files}=   Split string    ${PM_files}    separator=\
    log to console   ${list_of_PM_files}
    ${first_PM_file}=  Get From List  ${list_of_PM_files}  0
    ${PM_File_unzipped}=   Run  gunzip ${first_PM_file}
    Run  mv /tmp/PM.BTS-1.*.xml /tmp/PM_file.xml

    ${XML}=   Parse XML   /tmp/PM_file.xml
    ${values_list}=     Get Elements Texts  ${XML}   PMSetup/PMMOResult/NE-WBTS_1.0[@measurementType="NCAV"]/M55601C01004
    ${value}=   Get From List   ${values_list}  0
#    ${value}=   Get Element Text  ${XML}   PMSetup/PMMOResult/NE-WBTS_1.0[@measurementType="NCAV"]/M55601C01004
    Should be true   ${value}>0
    ...  msg=wrong counter value

Get Raw PM File From BTS
    ssh.connect_to    hostname=192.168.255.129    username=toor4nsn    password=oZPS0POrRieRtu    alias=eNB
    ${raw_counters_list}=    ssh.execute    ls /tmp/ | grep PM\.BTS.*\.raw\.gz | sort -r    connection=eNB
    ${last_raw_counter}=    String.Get Line    ${raw_counters_list}    0
    ssh.Download File   /ram/${last_raw_counter}    /tmp/${last_raw_counter}    connection=eNB
    run keyword and ignore error    ssh.disconnect    connection=eNB
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
#    [Arguments]    ${browser_url}=${WEBEM_IP}
#    ...            ${webem_username}=${USERNAME}
#    ...            ${webem_password}=${PASSWORD}
#    ...            ${browser_type}=chrome
#    ...            ${browser_alias}=browser
#    Set Selenium Implicit Wait    5
#    Open Browser
#    SELENIUM Input Text in Visible Element
#    ...    locator=${WELCOME_SCREEN_USERNAME_INPUT}
#    ...    text=${webem_username}
#    Input Text
#    ...    locator=${WELCOME_SCREEN_PASS_INPUT}
#    ...    text=${webem_password}
#    Click Element
#    ...    locator=${WELCOME_SCREEN_LOGIN_BTN_SBTS}
#    SELENIUM Pop Confirm
#    Run Keyword And Ignore Error    SELENIUM Click Visible Element   locator=//ui-button[@a-text="Close"]
#    Run Keyword And Ignore Error    SELENIUM Click Visible Element   locator=//div[contains(text(), "STARTED")]
#    Run Keyword And Ignore Error    SELENIUM Click Visible Element   locator=//div[contains(text(), "SUCCEEDED")]
#    [Arguments]    ${browser_url}=${WEBEM_IP}
#    ...            ${webem_username}=${USERNAME_Web}
#    ...            ${webem_password}=${PASSWORD_Web}
#    ...            ${browser_type}=chrome
#    ...            ${browser_alias}=browser
    Set Selenium Implicit Wait    5
    Open Browser
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
    [Arguments]    ${webem_username}=${USERNAME_Web}
    ...            ${webem_password}=${PASSWORD_Web}
    Input Text        id=login-username    ${webem_username}
    Input Password    id=login-password    ${webem_password}
    Click Button      Login


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

SYSTEM Execute Reboot On Rmod
    [Arguments]    #${command1}
#    ...            ${command2}
    ...            ${hostname_enb}=${SYSTEM_ENB_LOCAL_IP}
#    ...            ${hostname_rmod}=${SYSTEM_RMOD_LOCAL_IP}
    ...            ${username_enb}=${SYSTEM_ENB_SSH_USERNAME}
#    ...            ${username_rmod}=${SYSTEM_RMOD_SSH_USERNAME}
    ...            ${password_enb}=${SYSTEM_ENB_SSH_PASSWORD}
#    ...            ${password_rmod}=${SYSTEM_RMOD_SSH_PASSWORD_AEQN}
    ...            ${alias}=${SYSTEM_ALIAS_ASOE}
#    ...            ${proxy}=${SYSTEM_ALIAS_PROXY}
    taf.transport.ssh.connect_to
    ...    hostname=${hostname_enb}
    ...    username=${username_enb}
    ...    password=${password_enb}
    ...    alias=${alias}
    ${var}=    taf.transport.ssh.execute
    ...    command=whoami
    ...    connection=${alias}
    Log To Console   rezultat: ${var}

#    ${var1}=    taf.transport.ssh.execute
#    ...    command=lxc-attach -n 0x1018
#    ...    connection=${alias}
#    Log To Console   rezultat: ${var1}


    SSHLibrary.Write            ls -ltr
    SSHLibrary.Read Until       :~ >
    SSHLibrary.Write    lxc-attach -n 0x1018
    SSHLibrary.Read Until       FHNET00:~ >
    SSHLibrary.Write            exit
    SSHLibrary.Read Until       :~ >
#    taf.transport.ssh.connect_to
#    ...    hostname=${hostname_rmod}
#    ...    username=${username_rmod}
#    ...    password=${password_rmod}
#    ...    proxy=${alias}
#    ...    alias=${proxy}
#    taf.transport.ssh.execute
#    ...    command=${command2}
#    ...    connection=${proxy}
#    taf.transport.ssh.Disconnect
#    ...    connection=${proxy}
    taf.transport.ssh.Disconnect
    ...    connection=${alias}

Fault 10 RMOD Trigger - Reboot
    [Arguments]    ${timeout}=3 min
    [Timeout]    ${timeout}

    Log To Console    Fault 10 RMOD Trigger - Reboot
    Log To Console    \${SYSTEM_RMOD_LOCAL_IP}=${SYSTEM_RMOD_LOCAL_IP}
    SSH RMOD Connect To - proxy SMOD    ssh_alias=SSH_RMOD_fault_10    proxy=SSH_RMOD_proxy_fault_10

    ${output}    Run Keyword If    '${out_rmods_productnames_list[0]}' == 'AHPD'
    ...    taf.transport.ssh.Send Command    command=pssreboot hw    connection=SSH_RMOD_fault_10
    ...    ELSE IF                 '${out_rmods_productnames_list[0]}' == 'AHLOA'
    ...    taf.transport.ssh.Send Command    command=pssreboot hw    connection=SSH_RMOD_fault_10
    ...    ELSE IF                 '${out_rmods_productnames_list[0]}' == 'AEQN'
#    ...    taf.transport.ssh.Send Command    command=rfsw-reboot    connection=SSH_RMOD_fault_10
            Log To Console    Sunt pe AEQN
               # for some reason `Execute` is lagging with `command=rfsw-reboot`, wich is not a case for other RMODs using that reboot command
    ...    ELSE IF                 '${out_rmods_productnames_list[0]}' == 'AEUA'
    ...    taf.transport.ssh.Execute    command=rfsw-reboot    connection=SSH_RMOD_fault_10
    ...    ELSE
    ...    Fail    msg=Trigger fault 10 - Unsupported RMOD.


    Log To Console    RMOD command reboot \${output}=${output}
    SSH RMOD Disconnect - proxy SMOD    ssh_alias=SSH_RMOD_fault_10    proxy=SSH_RMOD_proxy_fault_10

    ADMIN Wait Until Fault Should Be Raised    fault_id=10    retry=2 min    retry_interval=5 sec    admin_alias=ADMIN_fault_10
    Log To Console    Fault 10 is raised (RMOD reboot) in ADMIN CLI.

    [Teardown]    SSH RMOD Disconnect - proxy SMOD - TEARDOWN    ssh_alias=SSH_RMOD_fault_10    proxy=SSH_RMOD_proxy_fault_10

SSH RMOD Connect To - proxy SMOD
    [Arguments]    ${hostname_RMOD}=${SYSTEM_RMOD_LOCAL_IP}
    ...            ${hostname_BTS}=192.168.255.1
    ...            ${username_RMOD}=${SYSTEM_RMOD_SSH_USERNAME}
    ...            ${username_BTS}=toor4nsn
    ...            ${password_RMOD}=${SYSTEM_RMOD_SSH_PASSWORD}
    ...            ${password_BTS}=oZPS0POrRieRtu
    ...            ${ssh_alias}=SSH_RMOD
    ...            ${proxy}=SSH_SMOD_proxy
    Log To Console                  SSH RMOD Connect To - proxy SMOD \${ssh_alias}=${ssh_alias} \${proxy}=${proxy}
    taf.transport.ssh.connect_to    hostname=${hostname_BTS}
    ...                             username=${username_BTS}
    ...                             password=${password_BTS}
    ...                             alias=${proxy}

    Run Keyword If                  '${out_rmods_productnames_list[0]}' == 'AEQN'
    ...                             Set Test Variable    ${password_RMOD}    root
    taf.transport.ssh.Connect To    hostname=${hostname_RMOD}
    ...                             username=${username_RMOD}
    ...                             password=${password_RMOD}
    ...                             proxy=${proxy}
    ...                             alias=${ssh_alias}


SSH RMOD Disconnect - proxy SMOD
    [Arguments]    ${ssh_alias}=SSH_RMOD
    ...            ${proxy}=SSH_SMOD_proxy
    ...            ${timeout}=1 sec
    [Timeout]      ${timeout}
    Log To Console                  SSH RMOD Disconnect - proxy SMOD \${ssh_alias}=${ssh_alias} \${proxy}=${proxy}
    taf.transport.ssh.Disconnect    connection=${ssh_alias}
    [Teardown]    taf.transport.ssh.Disconnect    connection=${proxy}


SSH RMOD Disconnect - proxy SMOD - TEARDOWN
    [Documentation]
    ...            Use as second disconnection of the same alias.
    ...            TAF SSH Disconnect is by default no allowed to fail.
    ...            This version allow to fail in recognizing alias (that is already down).
    [Arguments]    ${ssh_alias}=SSH_RMOD
    ...            ${proxy}=SSH_SMOD_proxy
    ...            ${timeout}=1 sec
    [Timeout]      ${timeout}

    Log To Console                  SSH RMOD Disconnect - proxy SMOD - TEARDOWN \${ssh_alias}=${ssh_alias} \${proxy}=${proxy}
    Run Keyword And Ignore Error    taf.transport.ssh.Disconnect    connection=${ssh_alias}
    [Teardown]    Run Keyword And Ignore Error    taf.transport.ssh.Disconnect    connection=${proxy}

SYSTEM Open SSH Connection
    [Arguments]    ${host}    ${port}    ${username}    ${password}    ${alias}
    SSHLibrary.Open Connection    host=${host}    port=${port}    timeout=300    alias=${alias}
    SSHLibrary.Login    username=${username}    password=${password}    delay=1s

SYSTEM Open SSH Connection To gnb for ASOE
    SYSTEM Open SSH Connection    host=${host}
    ...                           port=${port}
    ...                           username=${username}
    ...                           password=${password}
    ...                           alias=${alias}

Reboot on ASOE
    SYSTEM Open SSH Connection To gnb for ASOE
    SSHLibrary.Write        lxc-attach -n 0x1018
    SSHLibrary.Read Until       FHNET00:~ >
    SSHLibrary.Write    ssh 172.22.0.2
    SSHLibrary.Read Until       password:
    SSHLibrary.Write   ${SYSTEM_RMOD_SSH_PASSWORD_AEQN}
    SSHLibrary.Read Until       aeqn:
    SSHLibrary.Write    reboot
    SSHLibrary.Read Until       FHNET00:~ >

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
