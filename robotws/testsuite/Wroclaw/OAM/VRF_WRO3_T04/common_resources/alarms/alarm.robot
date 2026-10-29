*** Settings ***
Documentation   Keywords regarding alarms on BTS


Resource          ../admin/admin.robot
Resource          ../generic/run_if.robot
Resource          ../scout/scout_operations.robot
Library           alarm.py
Library           ../admin/admin_utils.py
Library           taf.sbts.oam.coam.admin    WITH NAME    coam_admin

*** Variables ***
&{ALLOWED_FAULTS_COMMON}=    61649=LMP access via port 443
...                          61652=R&D Service Port enabled
...                          61524=SSH Enabled
...                          61510=Automatic BTS Operator Certificate retrieval unsuccessful
...                          61618=Operator Certificate About to Expire or Expired
...                          61011=End Entity Certificate Update Time Mismatch
...                          4459=User Account has Default Password
...                          4655=Service account root access is enabled
...                          4654=Ethernet port security is disabled
...                          4122=GPS receiver alarm: not tracking satellites
...                          4125=GPS receiver alarm: position questionable
...                          4011=GPS Receiver alarm: control interface not available
...                          1898=PPS reference missing
...                          4385=PPS reference from backplane missing...
...                          4681=Sanity Check error
...                          4592=BTS booted at \### due to Power On
...                          7319=No X2 link available for a specific LTEENB
...                          7300=No X2 link available
...                          4297=NTP Server 0.0.0.0 unavailable
...                          4298=ToP reference missing
...                          61677=Wifi Repeated Authentications Failure
${ALARM_ALIAS}=      alarm
${FINAL_CHECK}=      True    #Checking BTS status and alarms. Possible settings: True, False

*** Keywords ***
Alarm Should be Active In BTS
   [Arguments]   ${fault_id}   ${connection}=${NONE}
   ${is_alarm_present}=   Is Alarm Active In Admin   ${fault_id}   ${connection}
   Should be True   ${is_alarm_present}   msg=Alarm with Fault Id ${fault_id} not present in gnb.

Alarm Should be Present in Historial Alarms
   [Arguments]   ${fault_id}   ${alias}=${ALARM_ALIAS}
   ${is_alarm_present}=   Is Alarm Present in Historical Alarms   ${fault_id}   ${alias}
   Should be True   ${is_alarm_present}   msg=Alarm with Fault ID ${fault_id} not present in historical_alarms.

Alarm Should Not Be Active in BTS
   [Arguments]   ${fault_id}   ${connection}=${NONE}
   ${is_alarm_present}=   Is Alarm Active In Admin   ${fault_id}   ${connection}
   Should Not be True   ${is_alarm_present}   msg=Alarm with Fault Id ${fault_id} present in gnb.

Check BTS Alarms
    [Arguments]  ${allowed_faults}=${ALLOWED_FAULTS}  ${expected_faults}=&{EMPTY}

    ${faults_ids}=        Get Active Alarms From BTS
    ${faults_to_delete}=  Create List

    FOR  ${expected_fault}  IN  @{expected_faults}
        ${fault}  Convert To Integer  ${expected_fault}
        List Should Contain Value     ${faults_ids}        ${fault}
        Append To List                ${faults_to_delete}  ${fault}
    END

    FOR  ${allowed_fault}  IN  @{allowed_faults}
        ${fault}  Convert To Integer  ${allowed_fault}
        Append To List                ${faults_to_delete}  ${fault}
    END

Check If Any Of Expected Faults Is Present On BTS
	[Documentation]    Keyword pass if at least one of expected faults is present on BTS.
	...				   Provided 'expected_faults_list' should contain at least 2 elements(faults).
    [Arguments]    ${expected_faults_list}    ${timeout}=10s    ${connection}=${NONE}
    ${connection}=    admin_utils.create_connection_if_not_exist
    ...               connection=${connection}
    ...               alias=${TEMP_ADMIN_CONN}

    ${list_len}=      Get Length    ${expected_faults_list}
    Run Keyword If    ${list_len}<=${1}    Fail    msg=List \@{expected_faults_list} should contain at least 2 elements!

    ${expected_faults}=    Catenate    SEPARATOR=|   @{expected_faults_list}
    Log     \nCheck For Any Of Fault from list: ${expected_faults} is Present   console=True
    Assert Alarm Active    faultId=regex"${expected_faults}"
    ...                    timeout=${timeout}
    ...                    connection=${connection}

    [Teardown]    Run Keyword And Ignore Error
    ...           admin.Disconnect from ADMIN
    ...           connection=${TEMP_ADMIN_CONN}

Check If Expected Faults Except Allowed Are Present On BTS
    [Documentation]    Keyword gets all alarms raised on BTS, fetch faultIDs for all alarms
    ...                and checks if expected faults, except allowed are visible on BTS.
    ...                If there are no any expected faults 'expected_faults_list' should not
    ...                be passed to keyword. In that case, there will be only check whether
    ...                there are no unexpected faults on BTS.
    [Arguments]    ${bts_host}=192.168.255.129
    ...            ${username}=Nemuadmin
    ...            ${password}=nemuuser
    ...            ${alias}=alarm
    ...            ${expected_faults_list}=${EMPTY}
    ...            ${allowed_faults}=${ALLOWED_FAULTS_COMMON}

    ${list_len}=      Get Length    ${expected_faults_list}
    Run Keyword If    ${list_len}==${0}    Log     \nCheck if there are no unexpected faults on BTS    console=True
    ...       ELSE    Log    \nCheck if expected faults: @{expected_faults_list} are present on BTS    console=True

    Check If Expected Faults Except Allowed Are Present    bts_host=${bts_host}
    ...                                                    username=${username}
    ...                                                    password=${password}
    ...                                                    alias=${alias}
    ...                                                    expected_faults=${expected_faults_list}
    ...                                                    allowed_faults=${allowed_faults}

Get Critical Alarm List From Admin
    [Documentation]  	 This Keyword helps in getting the list of Critical Alarms present in the system
    ...                  Creation Date: 13-11-2019
    ...                  Modified Date:
    ...                  Last Modified by: gopalakrishnan.n@nokia.com
    ...                  The Keyword takes only the admin connection alias as input and returns the Critical alarms
    ...                  present in the system
    ...                  | ${alias} | Admin Connection alias used to get the list of alarms |
    ...                  | ${critical_alarm_list} | Returned variable that has list of critical alarms |
    [Arguments]               ${alias}=${ALARM_ALIAS}
    ${alarm_list}             coam_admin.get_active_alarms     connection=${alias}
    ${critical_alarm_list}    Get Critical Alarms List    ${alarm_list}
    [Return]                  ${critical_alarm_list}

Get List of New Alarms Raised
    [Documentation]  	 This Keyword helps in getting the alarms that are not present in the first list of alarms
    ...                  Creation Date: 13-11-2019
    ...                  Modified Date:
    ...                  Last Modified by: gopalakrishnan.n@nokia.com
    ...                  The Keyword 2 arguments and returns list of alarms that are not present in the first argument
    ...                  | ${alarm_list} | The first list is base list which ideally has the alarms before test |
    ...                  | ${new_alarm_list} | The second list is the one that we have to determine how many new alarms
    ...                                        are raised. Ideally this is the collected after the test is completed |
    ...                  | ${alarm_diff} | Returned Variable which has the list of new alarms which is not present in
    ...                                    ${alarm_list} |
    [Arguments]          ${alarm_list}    ${new_alarm_list}
    ${alarm_diff}        Get New Alarms Raised    ${alarm_list}    ${new_alarm_list}
    [Return]             ${alarm_diff}

Is Alarm Active in Admin
   [Arguments]             ${fault_id}   ${connection}=${NONE}
   ${temp_conn}=           Run Keyword If  '${connection}'=='${NONE}'     admin.Connect To ADMIN
   ...    ELSE             Set Variable    ${connection}
   ${active_alarms}=       coam_admin.get_active_alarms   connection=${temp_conn}
   ${is_alarm_present}=    alarm.check_fault_in_alarm_list   ${active_alarms}   ${fault_id}
   [Teardown]              Run Keyword If    '${connection}'=='${NONE}'    admin.Disconnect from ADMIN    ${temp_conn}
   [Return]                ${is_alarm_present}

Is Alarm Present in Historical Alarms
   [Arguments]   ${fault_id}
   ${historical_alarms}=   admin.get_historical_alarms   connection=${connection}
   ${is_alarm_present}=   alarm.check_fault_in_alarm_list   ${historical_alarms}   ${fault_id}
   [Return]   ${is_alarm_present}

No Faults Except Allowed Should Be Present On BTS
    [Documentation]    Keyword gets all alarms raised on BTS, fetch faultIDs for all alarms
    ...                and checks if no unexpected faults, exept allowed are present on BTS.
    [Arguments]    ${bts_host}=192.168.255.129
    ...            ${username}=Nemuadmin
    ...            ${password}=nemuuser
    ...            ${alias}=alarm
    ...            ${allowed_faults}=${ALLOWED_FAULTS_COMMON}
    ...            ${ignored_alarming_objects}=${None}
    ...            ${active_faults}=${None}
    ${TESTLINE_NAME}=  scout_operations.Get testline name
    Run Keyword If    '${TESTLINE_NAME}'=='7_16_UTE5G281' or '${TESTLINE_NAME}'=='7_16_UTE5G280'
    ...    Run Keywords
    ...          Add Alarm To Allowed Alarms    8000    Failure in connection between BTS and 3rd party tool
    ...    AND   Add Alarm To Allowed Alarms    4291    Inter-Site CA X2 link unavailability
    ...    AND   Add Alarm To Allowed Alarms    7308    Transport layer connection failure in X2 interface
    ...    AND   Add Alarm To Allowed Alarms    7324    Maximum of X2 links reached
    ...    AND   Add Alarm To Allowed Alarms    6280    Phase error exceeds 5 us limit
    ...    AND   Add Alarm To Allowed Alarms    1934    Cooling fan has reduced from the set speed
    ...    AND   Add Alarm To Allowed Alarms    6327    Setup of X2 connectivity to gNB failed
    Run Keyword If    '${TESTLINE_NAME}'=='7_16_UTE5G278'
    ...          Add Alarm To Allowed Alarms    61675    WiFi Configuration Issue
    Log     Check If No Unexpected Faults Are Present On BTS    console=True
    Check If Expected Faults Except Allowed Are Present    bts_host=${bts_host}
    ...                                                    username=${username}
    ...                                                    password=${password}
    ...                                                    alias=${alias}
    ...                                                    allowed_faults=${allowed_faults}
    ...                                                    active_faults=${active_faults}
    ...                                                    ignored_alarming_objects=${ignored_alarming_objects}

Wait For No Connection To Radio Unit Alarm
    [Documentation]    This keyword checks if alarm 10 (No connection to radio unit) appears on BTS
    ${connection}                     Connect to ADMIN
    ...                               alias=alarm
    Wait Until Alarm Appears On BTS   fault_id=10
    ...                               timeout=1800
    [Teardown]                        Disconnect from ADMIN
    ...                               connection=alarm

Wait Until Alarm Appears On BTS
    [Documentation]  Checks if specified alarm is present on BTS and retries if it is not.
    ...              How long to retry checking is defined using `timeout` argument. If the keyword
    ...              does not succeed regardless of retries, this keyword fails.

    [Arguments]      ${fault_id}     ${timeout}=600

    Wait Until Keyword Succeeds      ${timeout} sec         10 sec
    ...                              Alarm Should be Active In BTS
    ...                              fault_id=${fault_id}

Check BTS Status After Some Time
	[Documentation]  This keyword checks if there is any difference in BTS status and alarms before and after 15 min.
	...  Keyword dedicated for Suite Teardown.
	[Arguments]      ${minutes}
    Check BTS Status After Some Time Container   ${minutes}

Check BTS Status After Some Time Container
	[Documentation]  This keyword checks if there is any difference in BTS status and alarms before and after 15 min.
	...  Keyword dedicated for Suite Teardown.
	[Arguments]      ${minutes}
	${variables}=           Get Variables
	${status_before}=   admin.Get current BTS state
	log                 \nstatus before: ${status_before}  console=True
    ${alarm_before}=    Get Active Alarms From BTS
    log                 alarm before: ${alarm_before}  console=True
    log                 sleep ${minutes}  console=True
    sleep  ${minutes}   reason=Wait for the next BTS status and alarm check
    ${status_after}=    admin.Get current BTS state
    log                 status after: ${status_after}  console=True
    ${alarm_after}=     Get Active Alarms From BTS
    log                 alarm after: ${alarm_after}  console=True
    ${status_com}=      Run Keyword And Return Status   Should Be Equal     ${status_before}  ${status_after}
    ${alarm_com}=       Run Keyword And Return Status   Should Be Equal     ${alarm_before}   ${alarm_after}
    Run Keyword If      '${status_com}'=='False' or '${alarm_com}'=='False'
    ...   alarm.error_in_log_html  ${status_com}  ${alarm_com}  ${minutes}

###################################Historical Faults Section############################################################
Check Historical Alarms
    [Documentation]    Keyword created to check if no unexpected faults occurred based on .ims2 log.
    ...                Spot check of faults can cause that some faults could not be detected.
    ...                To avoid this, faults should be checked based on ims2 log collected from whole test.
    ...                Keyword should be used in teardown.
    ...                To save .ims2 file from whole Test, there should be Connection to Admin Opened in Test Setup.
    ...                If there are expected faults, /${expected_faults} Test variable should be used
    ...                (Set Test Variable    /${expected_faults}    /${expected_faults}), because
    ...                for the purposes of this keyword expected faults become allowed.
    [Arguments]    ${file_name}=ims2_historical_alarms_file
    ...            ${alias}=historical_alarms

    coam_admin.Collect Infomodel Log From Current Session   target_file_name=${logs_path}/${file_name}.ims2
    ...                                                connection=${alias}
    ...                                                timeout=600s
    ${status}=    Run Keyword and Return Status     Variable Should Exist    ${expected_faults}
    Log     ${ALLOWED_FAULTS_TEMP}    console=false
    Run Keyword If    ${status}    Combine Lists With Allowed Faults And and Expected Faults
    ${historical_faults}=    Get All Faults From Infomodel    ${logs_path}/${file_name}.ims2
    Check If No Additional Faults Occurs    allowed_faults=${ALLOWED_FAULTS_TEMP}
    ...                                     historical_alarms=${historical_faults}

Check If No Additional Faults Occurs
    [Arguments]    ${allowed_faults}    ${historical_alarms}
    ${historical_alarms}=    Remove Duplicates    ${historical_alarms}
    Remove Values From List    ${historical_alarms}    @{allowed_faults}
    Should Be Empty    ${historical_alarms}

Combine Lists With Allowed Faults And and Expected Faults
    ${ALLOWED_FAULTS_TEMP}=    Combine Lists    ${ALLOWED_FAULTS_TEMP}    ${expected_faults}
    ${ALLOWED_FAULTS_TEMP}=    Remove Duplicates    ${ALLOWED_FAULTS_TEMP}
    Set Test Variable    ${ALLOWED_FAULTS_TEMP}    ${ALLOWED_FAULTS_TEMP}
#####################################End historical alarms sectionN#####################################################
Add Alarm To Allowed Alarms
    [Arguments]    ${key}    ${varible}
    Set To Dictionary    ${ALLOWED_FAULTS_COMMON}    ${key}=${varible}

Remove Alarm From Allowed Alarms
    [Arguments]    ${Rkey}    ${Rvarible}
    Remove From Dictionary    ${ALLOWED_FAULTS_COMMON}    ${Rkey}=${Rvarible}
