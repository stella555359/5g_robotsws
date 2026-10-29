*** Settings ***
Documentation
    ...  This TC checks VDU timezone and datetime format.
    ...  In the beginning TC is connecting to VCU to get its timezone. VDU timezone should match
    ...  VCU timezone. Then timezone and datetime format for the first entry of Operations History table
    ...  should be as expected.
    ...  A diagram for PM counters is created by selecting one counter and timezone should appear near Counters-PM text.
    ...  The first entry for the diagram should have the expected datetime format.
    ...  Then VDU cell is blocked to have at least one active alarm. Timezone and datetime format is checked
    ...  for the first entry in Active alarms and Historical Alarms tables. In Fault Toggling History page
    ...  timezone is checked.
    ...  In Operations History page timezone should appear near Start time and Finished time texts.
    ...  In Operator Certificates page timezone should appear near Valid to and Valid from texts.
    ...  VDU timezone from Site properties should match VCU timezone.
    ...  VDU timezone is modified by enabling local PC timezone which should be different from VCU timezone.
    ...  After this modification, VDU timezone from Site properties should remain unchanged.
    ...  Several tables should have the new timezone. TC is checking Operation History and Active Alarms pages.
    ...  In the final step TC is using M2M interface to get active alarms. Fault 49 Cell blocked is checked.
    ...  In the end, VDU cell is unblocked and TC waits until cell is reaching onAir state.

Resource  ../../common_resources/vdu_frame.robot
Resource  ../../common_resources/vcu_frame.robot
Resource  ../../common_resources/M2M_Interface.robot
Resource  ../resources/vdu_WebEM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  900s  # Timeout for CBTS to be onAir


*** Keywords ***
TC__WebEM__vDU__Timezone_Update_info_on_WebEM
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25086
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  29.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25086 - Initial TAT creation
    ...  ******************

    Set Tags  CA-WebEM  OWNER-marius.stanescu@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  FEATURE-CB009444  FEATURE-CB006420  PHASE-CRT

    Step0: TC Preconditions
    Step1: Login WebEM And Check Common Time Format
    Step2: Check The WebEM Counters Widgets
    Step3: Check Alarms Tables
    Step4: Check Operations History
    Step5: Check Operator Certificates
    Step6: Check WebEM Timezone From Site Properties
    Step7: Check Local PC Timezone Can Be Turned On/off
    Step8: Turn On PC Timezone
    Step9: Check That Timezone From Site Properties Is Not Changed
    Step10: Check Active Alarms Through M2M Interface


Step0: TC Preconditions
    Connect To VCU  host=${VCU_CONNECTION_DETAILS}[IP_ADDRESS]
    ${vcu_state}  vcu.Get Cu State
    Set Test Variable  ${VCU_TIMEZONE}  ${vcu_state}[time_zone]
    ${vdu_cell}  vdu.Get Vdu Cell Id
    ${cell_id}  Get Dictionary Keys  ${vdu_cell}[0]
    ${cell_id}  Fetch From Right  ${cell_id}[0]  -
    Set Test Variable  ${CELL_ID}
    Wait Until Element Is Clicked  ${VDU_OPTIONS_MENU}  5  1
    Click Element  //span[contains(text(),'Settings')]
    Wait Until Page Contains Element  //ui-webem-panel/div/div[2]/div/div/div[10]/p-inputswitch/div/div/input  5s
    ${aria-checked}  Get Element Attribute  //ui-webem-panel/div/div[2]/div/div/div[10]/p-inputswitch/div/div/input  aria-checked
    Run Keyword If  '${aria-checked}'!='false'
    ...  Click Element  //ui-webem-panel/div/div[2]/div/div/div[10]/p-inputswitch/div/span

    [Teardown]  vcu.Disconnect


Step1: Login WebEM And Check Common Time Format
    Log  \nStep1: Login WebEM and check common time format  console=true
    Wait Until Element Is Clicked  ${VDU_SITE_VIEW}  5  1
    Click Element  //span[contains(text(),'Site Properties')]
    Element Text Should Be  //*[contains(text(),'GMT+')]  ${VCU_TIMEZONE}  VDU timezone doesn't match VCU timezone.
    Wait Until Element Is Clicked  ${VDU_OPTIONS_MENU}  5  1
    Click Element  //*[contains(text(), 'Operations History')]
    Wait Until Element Is Visible  //*[@role='columnheader']  5s
    Element Text Should Be  //*[@role='columnheader']  Start time ${VCU_TIMEZONE}
    ...  Start time ${VCU_TIMEZONE} is not visible on Operation history page.
    ${first_datetime}  Get Text  //tbody[@class='p-element p-datatable-tbody']/tr[@tabindex='0']/td[4]
    Should Match Regexp  ${first_datetime}  [0-9]{2}\.[0-9]{2}\.[0-9]{4} [0-9]{2}:[0-9]{2}:[0-9]{2}


Step2: Check The WebEM Counters Widgets
    Log  \nStep2: Check the WebEM Counters widgets  console=true
    Click Element  ${VDU_DASHBOARD}
    Wait Until Element Is Visible  //dashboard-counters  5s
    ${pm_counters_options_first_element}  Get WebElement  //p-button[@title="Select counters"]
    Click Element  ${pm_counters_options_first_element}
    Wait Until Element Is Visible  //*[contains(text(), 'VLANIF')]  5s
    Click Element  //*[contains(text(), 'VLANIF')]
    Click Element  //*[contains(text(), 'VLAN statistics (VLAN_stats)')]
    Click Element  //*[contains(text(), 'M51302C1 (VlanEthIfInFrames)')]
    ${first_vlanif_element}  Get WebElement  //*[contains(@title, 'VLANIF-1')]
    Click Element  ${first_vlanif_element}
    Click Element  //span[contains(text(), 'OK')]
    Wait Until Element Is Visible  //*[contains(text(), 'Counters - PM ${VCU_TIMEZONE}')]  10s  Counters - PM ${VCU_TIMEZONE} is not visible.

    ${pm_counters_redirect_first_element}  Get WebElement  //dashboard-counters//p-button[@title='Redirect to view']
    Click Element  ${pm_counters_redirect_first_element}
    ${first_datetime}  Get Text  //tbody[@class='p-element p-datatable-tbody']/tr[1]/td[1]
    ${first_datetime_splitted}  Split String  ${first_datetime}  ${SPACE}
    Should Match Regexp  ${first_datetime_splitted}[0]${SPACE}${first_datetime_splitted}[1]  [0-9]{2}\.[0-9]{2}\.[0-9]{4} [0-9]{2}:[0-9]{2}:[0-9]{2}
    Should Be Equal As Strings  ${first_datetime_splitted}[2]  ${VCU_TIMEZONE}


Step3: Check Alarms Tables
    Log  \nStep3: Check alarms tables  console=true
    vdu.Block Cell  ${CELL_ID}
    Wait Until Keyword Succeeds  300s  10s
    ...  Check The Specific Cell From VDU  ${CELL_ID}  operational_state=${DISABLED}  blocking_state=${BLOCKED}

    Click Element  ${VDU_ALARMS_FROM_SITE_VIEW}
    Element Text Should Be  //th[@id="appeared-header"]  Appeared ${VCU_TIMEZONE}  Appeared ${VCU_TIMEZONE} is not visible in Active alarms page.
    ${first_active_alarm_time}  Get Text  //tr[contains(@id, "ALARM_")]/td[2]
    Should Match Regexp  ${first_active_alarm_time}  [0-9]{2}\.[0-9]{2}\.[0-9]{4} [0-9]{2}:[0-9]{2}:[0-9]{2}
    ...  ${first_active_alarm_time} doesn't match the expected time format in Active alarms page.
    Click Element  //span[contains(text(), 'Historical Alarms')]
    Element Text Should Be  //th[@id="appeared-header"]  Appeared ${VCU_TIMEZONE}  Appeared ${VCU_TIMEZONE} is not visible in Historical alarms page.
    ${first_historical_alarm_time}  Get Text  //tr[contains(@id, "ALARM_")]/td[2]
    Should Match Regexp  ${first_historical_alarm_time}  [0-9]{2}\.[0-9]{2}\.[0-9]{4} [0-9]{2}:[0-9]{2}:[0-9]{2}
    ...  ${first_historical_alarm_time} doesn't match the expected time format in Historical alarms page.
    Click Element  //span[contains(text(), 'Fault Toggling History')]
    Element Text Should Be  //th[@data-header="Appeared"]  Appeared ${VCU_TIMEZONE}
    ...  Appeared ${VCU_TIMEZONE} is not visible in Fault toggling history page.


Step4: Check Operations History
    Log  \nStep4: Check Operations History  console=true
    Wait Until Element Is Clicked  ${VDU_OPTIONS_MENU}  5  1
    Click Element  //*[contains(text(), 'Operations History')]
    Wait Until Element Is Visible  //th[contains(text(),'Start time ${VCU_TIMEZONE}')]  5s  Start time ${VCU_TIMEZONE} is not visible.
    Element Should Be Visible  //th[contains(text(),'Finished time ${VCU_TIMEZONE}')]  Finished time ${VCU_TIMEZONE} is not visible.


Step5: Check Operator Certificates
    Log  \nStep5: Check Operator Certificates  console=true
    Open Operator Certificates
    Wait Until Keyword Succeeds  10s  2s
    ...  Element Should Be Visible  //th[contains(text(),'Valid from ${VCU_TIMEZONE}')]
    ...  Valid from ${VCU_TIMEZONE} is not visible on Operator Certificates page.
    Element Should Be Visible  //th[contains(text(),'Valid to ${VCU_TIMEZONE}')]
    ...  Valid to ${VCU_TIMEZONE} is not visible on Operator Certificates page.


Step6: Check WebEM Timezone From Site Properties
    Log  \nStep6: Check WebEM timezone from Site properties  console=true
    Wait Until Element Is Clicked  ${VDU_SITE_VIEW}  5  1
    Click Element  //span[contains(text(),'Site Properties')]
    Element Text Should Be  //*[contains(text(),'GMT+')]  ${VCU_TIMEZONE}  VDU timezone doesn't match VCU timezone.


Step7: Check Local PC Timezone Can Be Turned On/off
    Log  \nStep7: Check local PC timezone can be turned on/off  console=true
    Wait Until Element Is Clicked  ${VDU_OPTIONS_MENU}  5  1
    Click Element  //span[contains(text(),'Settings')]
    Wait Until Element Is Visible  //span[@class="p-menuitem-text ng-star-inserted" and text()="Settings"]  5s
    ...  Custom Settings didn't change to Settings.
    Element Should Be Enabled  //ui-webem-panel/div/div[2]/div/div/div[10]/p-inputswitch/div/span


Step8: Turn On PC Timezone
    Log  \nStep8: Turn on PC timezone  console=true
    ${aria-checked}  Get Element Attribute  //ui-webem-panel/div/div[2]/div/div/div[10]/p-inputswitch/div/div/input  aria-checked
    Run Keyword If  '${aria-checked}'!='true'
    ...  Click Element  //ui-webem-panel/div/div[2]/div/div/div[10]/p-inputswitch/div/span


Step9: Check That Timezone From Site Properties Is Not Changed
    Log  \nStep9: Check that timezone from Site properties is not changed  console=true
    Wait Until Element Is Clicked  ${VDU_SITE_VIEW}  5  1
    Click Element  //span[contains(text(),'Site Properties')]
    Element Text Should Be  //*[contains(text(),'GMT+')]  ${VCU_TIMEZONE}  VDU timezone doesn't match VCU timezone.

    Wait Until Element Is Clicked  ${VDU_OPTIONS_MENU}  5  1
    Click Element  //*[contains(text(), 'Operations History')]
    Wait Until Element Is Visible  //th[contains(text(),'Start time')]  5s
    ${start_time_text}  Get Text  //th[contains(text(),'Start time')]
    ${new_timezone}  Fetch From Right  ${start_time_text}  ${SPACE}
    Should Not Be Equal As Strings  ${new_timezone}  ${VCU_TIMEZONE}
    Click Element  ${VDU_ALARMS_FROM_SITE_VIEW}
    Element Text Should Be  //th[@id="appeared-header"]  Appeared ${new_timezone}  Appeared ${new_timezone} is not visible in Active alarms page.
    Click Element  ${VDU_DASHBOARD}


Step10: Check Active Alarms Through M2M Interface
    Log  \nStep10: Check active alarms through M2M interface  console=true
    Login Using M2M Interface  ${VDU_OAM_IP}
    ${url}  Catenate  SEPARATOR=  "https://${VDU_OAM_IP}/api/licensed/v1/alarms/active?pageNumber=1&
    ...  itemsPerPage=15&sortedBy=appearTime&sortOrder=desc&filterByText=49"
    ${active_alarms}  Run M2M Command  GET  ${url}  Bearer  ${TOKEN}
    ${alarms_list}  Change M2M Output To List Of Alarm Dicts  ${active_alarms}
    ${fault_49_parameters}  Create Dictionary  faultName=Cell blocked  alarmId=7102  alarmName=BASE STATION RESOURCE BLOCKED BY USER
    Verify Alarm Output Parameters  ${alarms_list}[0]  ${fault_49_parameters}
    vdu.Unblock Cell  ${CELL_ID}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Check The Specific Cell From VDU  ${CELL_ID}  operational_state=${ENABLED}  blocking_state=${UNBLOCKED}

    [Teardown]  Logout Using M2M Interface  ${VDU_OAM_IP}


TC Setup
    Common VDU Setup
    VDU WebEM Setup
    Modify Resource Search Order  WebEM__vDU__Timezone_Update_info_on_WebEM


TC Teardown
    Run Keyword If Test Failed
    ...  Run Keywords
    ...  vdu.Unblock Cell  ${CELL_ID}
    ...  AND
    ...  Wait Until Keyword Succeeds  300s  10s
    ...  Check The Specific Cell From VDU  ${CELL_ID}  operational_state=${ENABLED}  blocking_state=${UNBLOCKED}
    VDU WebEM Teardown
    Common VDU Teardown
