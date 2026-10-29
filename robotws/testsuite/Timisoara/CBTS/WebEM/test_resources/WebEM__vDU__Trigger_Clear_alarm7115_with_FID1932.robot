*** Settings ***
Documentation
    ...  This TC is created to trigger alarm with FID 1932 on Radio Module fans.
    ...  Connection to chosen Radio Module is opened.
    ...  Three parameters values in fans.json file are changed: fanDetectionPeriod, fanTestPeriod and fanTestRpmMin.
    ...  Reset operation is performed on chosen Radio Module.
    ...  After reboot, when Radio Module is back on air, alarm with FID 1932 appears on Radio Module fans.
    ...  Alarm fields are verified for every fan.
    ...  fans.json file is deleted from Radio Module an reset operation is performed again.
    ...  Alarm is verified to be present in alarm history page.

Resource  ../resources/vdu_WebEM_general.robot
Resource  ../../common_resources/vdu_frame.robot


*** Variables ***
${RMOD_TYPE}  ${EMPTY}  #RMOD product name
${DC}  ${TRUE}  #Configuration type
${ALARM_TIMEOUT}  300s  # Timeout for alarm to appear.
${RECOVERY_TIMEOUT}  900s  # Timeout for RMOD to recover after reset.


*** Keywords ***
TC__WebEM__vDU__Trigger_Clear_alarm7115_with_FID1932
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25027
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  23.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25027 - Initial TAT creation
    ...  25.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29713 - Adapt TC to work from 26R1 onwards and with new rmod connection method.
    ...  09.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29831 - Change method of connecting to RMOD and retrieving pod and container name
    ...  ******************

    Set Tags  CA-WebEM  OWNER-lucian.ivanescu@nokia.com  MAINTAINER-anna.benzar@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  FEATURE-CB009275

    Step0: TC Preconditions
    Step1: Disconnect FAN Module From Radio Module Unit
    Step2: Check Alarm With FID 1932 To Be Visible On Every FAN
    Step3: Reconnect FAN Module From Radio Module Unit
    Step4: Check Alarm With FID 1932 To Be Cleared From Every FAN


Step0: TC Preconditions
    Log  \nStep0: TC preconditions.  console=true

    Should Not Be Empty  ${RMOD_TYPE}  msg=Please provide RMOD_TYPE(e.g. AEHC)
    Perform vDU Reset
    Wait Until Element Is Visible  //*[@id="Close"]/button  300s
    Click Element  //*[@id="Close"]/button
    ${test_start_time}  Get Current Date  UTC  result_format=%d.%m.%Y %H:%M:%S
    Change Specific Parameter For VDU  actRadioFanFailureEarlyNotif  true  MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1
    Change Specific Parameter For VDU  actSshToRU  false  MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ${FAULT_1932}  Create Dictionary  fault_id=1932
    ...                               fault_name=No module fan detected
    ...                               alarm_id=7115
    ...                               alarm_name=BASE STATION INFORMATION
    ...                               severity=regex"Minor|minor"
    ${rmods}  vdu.Get Rmods Status
    ${all_rmods_ips}  Get All RMODs IPs from vDU
    FOR  ${current_rmod}  IN  @{rmods}
         IF  '${current_rmod}[product_name]' == '${RMOD_TYPE}'
             ${active_sw_build}  Split String  ${current_rmod}[active_sw_build]  .
             ${rmod_user}  ${rmod_password}  Get User And Password For RMOD  ${active_sw_build}[1]  ${current_rmod}[product_name]
             ${rmod_ip}  Get Ip For RMOD  ${current_rmod}[serial_number]  ${rmod_user}  ${rmod_password}  ${all_rmods_ips}  dc=${DC}
             ${rmod}  Create Dictionary   serial_number=${current_rmod}[serial_number]
             ...                          id=${current_rmod}[id]
             ...                          ip=${rmod_ip}
             ...                          user=${rmod_user}
             ...                          password=${rmod_password}
             Set Test Variable  ${RMOD}
             BREAK
         END
    END
    Should Not Be Empty  ${RMOD}  msg=Could not retrieve information for RMOD - ${RMOD_TYPE}.
    Log  Chosen RMOD information: ${RMOD}
    ${rmod_fans}  Get RMOD FANs  ${RMOD}[id]
    Set Test Variable  ${RMOD_FANS}
    Set Test Variable  ${FAULT_1932}
    Set Test Variable  ${TEST_START_TIME}


Step1: Disconnect FAN Module From Radio Module Unit
    Log  \nStep1: Disconnect FAN module from Radio Module unit.  console=true

    Open SSH Connection To Specific RMOD  ${RMOD}[ip]  ${RMOD}[user]  ${RMOD}[password]  ${RMOD}[serial_number]  dc=${DC}
    Log  Decode and modify fans.json file...  console=true
    Execute Create Command On RMOD
    Execute Fetch Command On RMOD
    Edit fans.Json File To Activate Fault 1932
    Execute Store Command On RMOD
    Log  Create, fetch, edit and store operations successfully done.  console=true
    Log  Reboot RMOD...  console=true
    SSHLibrary.Write  sudo pssreboot swwd
    SSHLibrary.Read Until Prompt
    Verify RMOD And Cells Status After Reboot

    [Teardown]  SSHLibrary.Close Connection


Step2: Check Alarm With FID 1932 To Be Visible On Every FAN
    Log  \nStep2: Check alarm with FID 1932 to be visible on every FAN.  console=true

    Click Element  ${VDU_ALARMS_FROM_SITE_VIEW}
    FOR  ${fan}  IN  @{RMOD_FANS}
        Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  30s
        ...  Verify Alarm Fields In Active Alarms List  ${TEST_START_TIME}
        ...                                             ${FAULT_1932}[alarm_id]
        ...                                             ${FAULT_1932}[alarm_name]
        ...                                             ${FAULT_1932}[fault_id]
        ...                                             ${FAULT_1932}[fault_name]
        ...                                             MRBTS-${VDU_MRBTS_ID}/EQM_R-1/APEQM_R-1/RMOD_R-${RMOD}[id]/${fan}
    END
    Log  Alarm ${FAULT_1932} is active in WebEM on RMOD-${RMOD}[id] with serial number: ${RMOD}[serial_number] and FANS: ${RMOD_FANS}. [OK]
    ...  console=true


Step3: Reconnect FAN Module From Radio Module Unit
    Log  \nStep3: Reconnect FAN module from Radio Module unit.  console=true

    Open SSH Connection To Specific RMOD  ${RMOD}[ip]  ${RMOD}[user]  ${RMOD}[password]  ${RMOD}[serial_number]  dc=${DC}
    Log  Modify fans.json file...  console=true
    Execute Create Command On RMOD
    Execute Delete Command On RMOD
    Execute Terminate Command On RMOD
    Log  Create, delete and terminate operation successfully done.  console=true
    Log  Reboot RMOD...  console=true
    SSHLibrary.Write  sudo pssreboot swwd
    SSHLibrary.Read Until Prompt
    Verify RMOD And Cells Status After Reboot

    [Teardown]  SSHLibrary.Close Connection


Step4: Check Alarm With FID 1932 To Be Cleared From Every FAN
    Log  \nStep4: Check alarm with FID 1932 to be cleared from every FAN.  console=true

    Click Element  ${VDU_ALARMS_FROM_SITE_VIEW}
    Wait Until Element Is Clicked  //*[@id="/alarm/historical"]/span
    Wait Until Element Is Clicked  //*[@id="appeared-header"]
    ${aria_sort}  Get Element Attribute  //*[@id="appeared-header"]  aria-sort
    Should Be Equal As Strings  ${aria_sort}  descending  Alarms are not sorted in descending order, after click on "Appeared GMT+0000" header. [NOK]
    FOR  ${fan}  IN  @{RMOD_FANS}
        Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  30s
        ...  Verify Alarm Fields In Historical Alarms List  ${TEST_START_TIME}
        ...                                                 ${FAULT_1932}[alarm_id]
        ...                                                 ${FAULT_1932}[alarm_name]
        ...                                                 ${FAULT_1932}[fault_id]
        ...                                                 ${FAULT_1932}[fault_name]
        ...                                                 MRBTS-${VDU_MRBTS_ID}/EQM_R-1/APEQM_R-1/RMOD_R-${RMOD}[id]/${fan}
    END
    Log  Alarm ${FAULT_1932} was cleared from RMOD-${RMOD}[id] with serial number: ${RMOD}[serial_number] and FANS: ${RMOD_FANS}. [OK]
    ...  console=true


Execute Create Command On RMOD
    SSHLibrary.Write  echo $'/ action create ConfigAccess /CI/ConfigAccess_Module /module' | frmonShellClient localhost 2000
    ${create_command_output}  SSHLibrary.Read Until Prompt
    Should Contain  ${create_command_output}  done ok  "create" command not executed correctly. [NOK]


Execute Fetch Command On RMOD
    SSHLibrary.Write  echo $'/CI/ConfigAccess_Module action fetch DECODED "fans.bin" "/ram/fans.json"' | frmonShellClient localhost 2000
    ${fetch_command_output}  SSHLibrary.Read Until Prompt
    Should Contain  ${fetch_command_output}  done ok  "fetch" command not executed correctly. [NOK]


Execute Store Command On RMOD
    SSHLibrary.Write  echo $'/CI/ConfigAccess_Module action store PERMANENT DECODED "fans.bin" "/ram/fans.json"' | frmonShellClient localhost 2000
    ${store_command_output}  SSHLibrary.Read Until Prompt
    Should Contain  ${store_command_output}  done ok  "store" command not executed correctly. [NOK]


Execute Delete Command On RMOD
    SSHLibrary.Write  echo $'/CI/ConfigAccess_Module action delete "fans.bin"' | frmonShellClient localhost 2000
    ${delete_command_output}  SSHLibrary.Read Until Prompt
    Should Contain  ${delete_command_output}  done ok  "delete" command not executed correctly. [NOK]


Execute Terminate Command On RMOD
    SSHLibrary.Write  echo $'/CI/ConfigAccess_Module action terminate' | frmonShellClient localhost 2000
    ${terminate_command_output}  SSHLibrary.Read Until Prompt
    Should Contain  ${terminate_command_output}  done ok  "terminate" command not executed correctly. [NOK]


Edit Fans.Json File To Activate Fault 1932
    SSHLibrary.Write  cp /ram/fans.json /home/serviceuser
    SSHLibrary.Read Until Prompt
    ${first_sed_command}  Catenate  SEPARATOR=  sudo sed -i -E ':a;N;$!ba;s/"fanDetectionPeriod": [0-9]*,  /"fanDetectionPeriod": 60000,/g' fans.json
    ${second_sed_command}  Catenate  SEPARATOR=  sudo sed -i -E ':a;N;$!ba;s/"fanTestPeriod": [0-9]*,  /"fanTestPeriod": 30000,/g' fans.json
    ${third_sed_command}  Catenate  SEPARATOR=  sudo sed -i -E ':a;N;$!ba;s/"fanTestRpmMin": [0-9]*,  /"fanTestRpmMin": 2100,/g' fans.json
    SSHLibrary.Write  ${first_sed_command}
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  ${second_sed_command}
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  ${third_sed_command}
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  sudo cp fans.json /ram/fans.json
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  cd /ram
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  ls -l | grep fans.json
    ${ls_output}  SSHLibrary.Read Until Prompt
    Should Contain  ${ls_output}  root  fans.json user is not root. [NOK]
    SSHLibrary.Write  sudo chown rfsw:rfsw fans.json
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  ls -l | grep fans.json
    ${ls_output}  SSHLibrary.Read Until Prompt
    Should Contain  ${ls_output}  rfsw  fans.json user is not rfsw. [NOK]


Get RMOD FANs
    [Arguments]  ${rmod_id}

    ${fans_list}  Create List
    Wait Until Element Is Clicked  ${VDU_SITE_VIEW}
    Log  Site View is open![OK]  console=true
    Wait Until Element Is Clicked  //*[contains(text(), 'RMOD-${rmod_id}')]
    Wait Until Element Is Clicked  //*[@id="open-detail-panel-button"]/span[1]
    ${no_of_fans}  SeleniumLibrary.Get Element Count  //div[contains(text(),'FAN_R')]
    FOR  ${fan}  IN RANGE  1  ${no_of_fans} + 1
        ${fan_locator}  Catenate  //*[contains(@class, 'p-element cem-details-component-section-content section-content ng-star-inserted')]
        ...  /div/p-accordiontab[${fan}]/div/div/a/div
        ${fan_text}  Get Text  ${fan_locator}
        Append To List  ${fans_list}  ${fan_text}
    END
    Should Not Be Empty  ${fans_list}  No FANs found on RMOD with id: ${rmod_id}. [NOK]

    [Return]  ${fans_list}


Verify RMOD And Cells Status After Reboot
    Wait Until Keyword Succeeds  300s  10s  Verify RMOD Parameter By RMOD Id  ${RMOD}[id]  operational_state  ${DISABLED}
    Log  RMOD-${RMOD}[id] with serial number: ${RMOD}[serial_number] is Disabled! [OK]  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s  Verify RMOD Parameter By RMOD Id  ${RMOD}[id]  operational_state  ${ENABLED}
    Log  RMOD-${RMOD}[id] with serial number: ${RMOD}[serial_number] is back Online!  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s  Check All Cells From VDU  availability_status=${ONLINE}
    ...                                                                              operational_state=${ENABLED}
    Log  Cells are Online and Enabled! [OK]  console=true


TC Setup
    Common VDU Setup
    VDU WebEM Setup
    Modify Resource Search Order  WebEM__vDU__Trigger_Clear_alarm7115_with_FID1932


TC Teardown
    Change Specific Parameter For VDU  actRadioFanFailureEarlyNotif  false  MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1
    VDU WebEM Teardown
    Common VDU Teardown
