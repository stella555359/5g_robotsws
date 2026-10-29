*** Settings ***
Documentation    Suite description
...    Author:        izabela.wencel@nokia.com
...    Maintainer:    izabela.wencel@nokia.com

Resource  ../tc_scenarios.robot
Resource  ../hran_ta/resources/ca_Recovery_link_break.robot
Resource  ../Test_Cases/link_break_resources.robot

*** Variables ***
@{fault_4685_alarm_resource}=  7101 BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
@{fault_4685_crit_alarm_resource}=  7116 BASE STATION SERVICE PROBLEM

*** Keywords ***
Secondary Link Break 7447 Not Supported
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-47971
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test case verifies behaviour of the BTS while secondary link is broken
    ...  and RU does not support CB007447 according to CB013082.
    ...
    ...  Test baseline:
    ...  - there are 2 links between the tested RU and the BTS,
    ...  - Calient optical switch MUST be connected on both links, because synchronization might switch over,
    ...  - there are two variables provided by the author of the test case:
    ...
    ...  *Input Parameters*
    ...  +-------------------------------------------------------------------------------+
    ...  | Parameter                   | Mandatory | Description                         |
    ...  +=============================+===========+=====================================+
    ...  | tested_cablinks_xxx       | Yes       | CABLINK-XX=x.x.x  CABLINK-YY=y.y.y  |
    ...  +-----------------------------+-----------+-------------------------------------+
    ...  &\{tested_cablinks_xxx\} this should be provided in Variables section of the TS
    ...  and also provided next to testcase preconditions, eg.:
    ...
    ...  [xxxxx][1.0] Automated_SiSo_some_test_case_name
    ...    [Setup]  Testcase Basic Precondition  CN=xxxx  N=x  IP_SWITCH=xx.xx.xx.xx  tested_cablinks=&{tested_cablinks_xxx}  long_fiber=z.z.z-z.z.z
    ...
    ...  x.x.x, y.y.y, z.z.z stand for Calient ports - first value for each link is its port in.
    ...
    Common Test Setup
    Preconditions For Secondary Link Break 7447 Not Supported
    Step 1. Change Optical Link For Secondary Link Break 7447 Not Supported
    Step 2. Check States For Secondary Link Break 7447 Not Supported
    Run Keyword If  ${RUN_STEP3}==True  Run Keywords
    ...  Step 3. Change Back Optical Link For Secondary Link Break 7447 Not Supported
    ...  AND  Step 4. Check States Again For Secondary Link Break 7447 Not Supported
    ...  ELSE  Log  Step 3 & 4 skipped due to changed synchronization link.  console=True
    [Teardown]  Run Keywords
    ...  Run Keyword And Ignore Error  Recovery For Link Break With Changed Time Delay 7447 Not Supported  ${TESTED_CABLINKS_OS_PORT}  ${IP_SWITCH}
    ...  AND  Recovery From 4685 Critical
    ...  AND  Common Test Teardown

Preconditions For Secondary Link Break 7447 Not Supported
    Logging With Timestamp
    ...  message=Preconditions For Secondary Link Break 7447 Not Supported
    ...  style=STEP
    ...  frame=${TRUE}
    Preparing Variables To Test Link Break With Changed Time Delay CB007447 Not Supported
    Checking Parameters For CB013082 Link Break
    Set Test Variable  ${TESTED_CELL_DN}  ${CELLS_ON_SECOND}
    ${secondary_cablink_dn_list}=  Create List  ${SECONDARY_CABLINK_DN}
    Set Test Variable  ${SECONDARY_CABLINK_DN_LIST}  ${secondary_cablink_dn_list}
    ${primary_cablink_dn_list}=  Create List  ${PRIMARY_CABLINK_DN}
    Set Test Variable  ${PRIMARY_CABLINK_DN_LIST}  ${primary_cablink_dn_list}
    ${bts_info}=  admin.Get Bts Info  connection=${BTS_ID}
    ${all_cablinks_before_break}=  Create Cablinks Dictionary With Distnames And LinkMode
    Logging With Timestamp
    ...  message=Checking cablinks states
    ...  style=ONGOING
    Check Cablink State  ${SECONDARY_CABLINK_DN_LIST}  (?i)Enabled  (?i)On Air  ${BTS_ID}
    Check Cablink State  ${PRIMARY_CABLINK_DN_LIST}  (?i)Enabled  (?i)On Air  ${BTS_ID}

Step 1. Change Optical Link For Secondary Link Break 7447 Not Supported
    Logging With Timestamp
    ...  message=Step 1. Change Optical Link For Secondary Link Break 7447 Not Supported
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Checking the OS connectivity and getting a variable for Recovery action
    ...  style=ONGOING
    ${os_status}=  Run Keyword And Return Status  Optical Switch Setup  switch_ip=${IP_SWITCH}
    Run Keyword If  ${os_status}==False  Fail  Optical switch connection not established. Chceck configuration files and OS state.
    ${all_calient_ports}  Get Optical Switch Channels
    Teardown Optical Switch
    Set Test Variable  ${ALL_CALIENT_PORTS}  ${all_calient_ports}
    Logging With Timestamp
    ...  message=Check Whether Data Link Now The Same As Preconditions
    ...  style=ONGOING
    ${status_same}=  Check Whether Data Link Now The Same As Preconditions
    Run Keyword If  ${status_same}==True  Log  Linkmode as expected. Continue.  console=True
    Logging With Timestamp
    ...  message=Changing Calient settings to connect longer link
    ...  style=ONGOING
    ${all_calient_ports}  ${link_port_out}  ${long_port_in}  ${long_port_out}=
    ...  Change Optical Connection To Longer For Link Break With Changed Link Length  ${SEC_PORT_IN}  ${LONG_FIBER}  ${IP_SWITCH}
    Set Test Variable  ${LINK_PORT_OUT}  ${link_port_out}
    Set Test Variable  ${LONG_PORT_IN}  ${long_port_in}
    Set Test Variable  ${LONG_PORT_OUT}  ${long_port_out}
    Logging With Timestamp
    ...  message=Checking cablinks states
    ...  style=ONGOING
    Check Cablink State  ${PRIMARY_CABLINK_DN_LIST}  (?i)Enabled  (?i)On Air  ${BTS_ID}
    Check Cablink State  ${SECONDARY_CABLINK_DN_LIST}  (?i)Enabled  (?i)Degraded  ${BTS_ID}

Step 2. Check States For Secondary Link Break 7447 Not Supported
    Logging With Timestamp
    ...  message=Step 2. Check States For Secondary Link Break 7447 Not Supported
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Waiting for affected cells to fail
    ...  style=ONGOING
    Wait For Affected Cells To Change State  (?i)Disabled  ${TESTED_CELL_DN}
    ${status_same}=  Check Whether Data Link Now The Same As Preconditions
    Logging With Timestamp
    ...  message=Waiting for FID 4685 to appear and reset the radio
    ...  style=ONGOING
    ${alarming_object_for_4685}=  Set Variable  ${CABLINKS_WITH_AFFECTED_CELLS_DICT['${SECONDARY_CABLINK_DN}'][0]}
    ${fault_4685_crit_second_link_status}  ${fault_4685_crit_unique_attr}=  Run Keyword And Ignore Error  FM Await For Fault
    ...  faultId=4685, alarmId=7116, severity=Critical, alarmingObjectIds[0].internal=${alarming_object_for_4685}
    ...  ${BTS_ID}
    ...  ${fault_4685_crit_alarm_resource}
    ...  10
    ${fault_4685_second_link_status}  ${fault_4685_unique_attr}=  Run Keyword And Ignore Error  FM Await For Fault
    ...  faultId=4685, alarmId=7101, severity=Warning, alarmingObjectIds[0].internal=${alarming_object_for_4685}
    ...  ${BTS_ID}
    ...  ${fault_4685_alarm_resource}
    ...  240
    Run Keyword If  '${fault_4685_crit_second_link_status}'=='PASS'  Proceed After FID 4685 Critical Appears
    Run Keyword If  '${fault_4685_second_link_status}'=='PASS'  Proceed After FID 4685 Warning Appears  ${TESTED_CELL_DN}
    Run Keyword If  '${fault_4685_crit_second_link_status}'=='FAIL' and '${fault_4685_second_link_status}'=='FAIL'
    ...  Fail  Expected fault 4685 for secondary link NOT appeared!!! test failed.
    ${status_same}=  Check Whether Data Link Now The Same As Preconditions
    Run Keyword If  ${status_same}==True  Set Test Variable  ${RUN_STEP3}  True
    ...  ELSE  Set Test Variable  ${RUN_STEP3}  False

Step 3. Change Back Optical Link For Secondary Link Break 7447 Not Supported
    Logging With Timestamp
    ...  message=Step 3. Change Back Optical Link For Secondary Link Break 7447 Not Supported
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Changing Calient settings back to shorter link
    ...  style=ONGOING
    Change Optical Connection To Shorter For Link Break With Changed Link Length
    ...  long_link_break_duration=0
    ...  link_port_in=${SEC_PORT_IN}
    ...  long_port_in=${LONG_PORT_IN}
    ...  all_calient_ports=${ALL_CALIENT_PORTS}
    ...  switch_ip=${IP_SWITCH}
    Logging With Timestamp
    ...  message=Checking cablinks states
    ...  style=ONGOING
    Check Cablink State  ${PRIMARY_CABLINK_DN_LIST}  (?i)Enabled  (?i)On Air  ${BTS_ID}
    Check Cablink State  ${SECONDARY_CABLINK_DN_LIST}  (?i)Enabled  (?i)Degraded  ${BTS_ID}

Step 4. Check States Again For Secondary Link Break 7447 Not Supported
    Logging With Timestamp
    ...  message=Step 4. Check States Again For Secondary Link Break 7447 Not Supported
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Waiting for affected cells to fail
    ...  style=ONGOING
    Wait For Affected Cells To Change State  (?i)Disabled  ${TESTED_CELL_DN}
    Logging With Timestamp
    ...  message=Check Whether Data Link Now The Same As Preconditions
    ...  style=ONGOING
    ${status_same}=  Check Whether Data Link Now The Same As Preconditions
    Logging With Timestamp
    ...  message=Waiting for FID 4685 to appear and reset the radio
    ...  style=ONGOING
    ${alarming_object_for_4685}=  Set Variable  ${CABLINKS_WITH_AFFECTED_CELLS_DICT['${SECONDARY_CABLINK_DN}'][0]}
    ${fault_4685_crit_second_link_status}  ${fault_4685_crit_unique_attr}=  Run Keyword And Ignore Error  FM Await For Fault
    ...  faultId=4685, alarmId=7116, severity=Critical, alarmingObjectIds[0].internal=${alarming_object_for_4685}
    ...  ${BTS_ID}
    ...  ${fault_4685_crit_alarm_resource}
    ...  10
    ${fault_4685_second_link_status}  ${fault_4685_unique_attr}=  Run Keyword And Ignore Error  FM Await For Fault
    ...  faultId=4685, alarmId=7101, severity=Warning, alarmingObjectIds[0].internal=${alarming_object_for_4685}
    ...  ${BTS_ID}
    ...  ${fault_4685_alarm_resource}
    ...  240
    Run Keyword If  '${fault_4685_crit_second_link_status}'=='PASS'  Proceed After FID 4685 Critical Appears
    Run Keyword If  '${fault_4685_second_link_status}'=='PASS'  Proceed After FID 4685 Warning Appears  ${TESTED_CELL_DN}
    Run Keyword If  '${fault_4685_crit_second_link_status}'=='FAIL' and '${fault_4685_second_link_status}'=='FAIL'
    ...  Fail  Expected fault 4685 for secondary link NOT appeared!!! test failed.
    Collect Infomodel Log From Current Session  ${cfg.test_logs_path}/InfoModel_rmod_2_${BTS_ID}.ims2  connection=${BTS_ID}
    @{affected_items_list}=   Create List  ${TESTED_CELL_DN}
    Check availabilityStatus For Affected And Not Affected Items  ${AFFECTED_ITEMS}  ${NOT_AFFECTED_CELLS_DN}
    ...  ${cfg.test_logs_path}/InfoModel_rmod_2_${BTS_ID}.ims2
