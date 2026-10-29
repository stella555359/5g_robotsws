*** Settings ***
Documentation    Suite description
...    Author:        izabela.wencel@nokia.com
...    Maintainer:    izabela.wencel@nokia.com

Resource  ../tc_scenarios.robot
Resource  ../hran_ta/resources/ca_Recovery_link_break.robot
Resource  ../Test_Cases/link_break_resources.robot

*** Variables ***
@{rmod_fid10_alarm_resource}=  7116 BASE STATION SERVICE PROBLEM
@{fault_1815_alarm_resource}=  7116 BASE STATION SERVICE PROBLEM

*** Keywords ***
Primary Link Break 7447 Not Supported
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-47971
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test case verifies behaviour of the BTS while primary link is broken
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
    ...  &\{tested_cablinks_xxxxx\} this should be provided in Variables section of the TS
    ...  and also provided next to testcase preconditions, eg.:
    ...
    ...  [xxxxx][1.0] Automated_SiSo_some_test_case_name
    ...    [Setup]  Testcase Basic Precondition  CN=xxxx  N=x  IP_SWITCH=xx.xx.xx.xx  tested_cablinks=&{tested_cablinks_xxx}  long_fiber=z.z.z-z.z.z
    ...
    ...  x.x.x, y.y.y, z.z.z stand for Calient ports - first value for each link is its port in.
    ...
    Common Test Setup
    Preconditions For Primary Link Break 7447 Not Supported
    Step 1. Change Optical Link For Primary Link Break 7447 Not Supported
    Step 2. Check States For Primary Link Break 7447 Not Supported
    Run Keyword If  ${RUN_STEP3}==True  Run Keywords
    ...  Step 3. Change Back Optical Link For Primary Link Break 7447 Not Supported
    ...  AND  Step 4. Check States Again For Primary Link Break 7447 Not Supported
    ...  ELSE  Log  Step 3 & 4 skipped due to changed synchronization link.  console=True
    [Teardown]  Run Keywords
    ...  Run Keyword And Ignore Error  Recovery For Link Break With Changed Time Delay 7447 Not Supported  ${TESTED_CABLINKS_OS_PORT}  ${IP_SWITCH}
    ...  AND  Recovery From 4685 Critical
    ...  AND  Common Test Teardown

Preconditions For Primary Link Break 7447 Not Supported
    Logging With Timestamp
    ...  message=Preconditions For Primary Link Break 7447 Not Supported
    ...  style=STEP
    ...  frame=${TRUE}
    Preparing Variables To Test Link Break With Changed Time Delay CB007447 Not Supported
    Checking Parameters For CB013082 Link Break
    Set Test Variable  ${TESTED_CELL_DN}  ${CELLS_ON_PRIM}
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

Step 1. Change Optical Link For Primary Link Break 7447 Not Supported
    Logging With Timestamp
    ...  message=Step 1. Change Optical Link For Primary Link Break 7447 Not Supported
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
    ...  message=Check Whether Synchro Link Now The Same As Preconditions
    ...  style=ONGOING
    ${status_same}=  Check Whether Synchro Link Now The Same As Preconditions
    Run Keyword If  ${status_same}==True  Log  Linkmode as expected. Continue.  console=True
    Logging With Timestamp
    ...  message=Changing Calient settings to connect longer link
    ...  style=ONGOING
    ${all_calient_ports}  ${link_port_out}  ${long_port_in}  ${long_port_out}=
    ...  Change Optical Connection To Longer For Link Break With Changed Link Length  ${PRIM_PORT_IN}  ${LONG_FIBER}  ${IP_SWITCH}
    Set Test Variable  ${LINK_PORT_OUT}  ${link_port_out}
    Set Test Variable  ${LONG_PORT_IN}  ${long_port_in}
    Set Test Variable  ${LONG_PORT_OUT}  ${long_port_out}
    Logging With Timestamp
    ...  message=Checking cablinks states
    ...  style=ONGOING
    Check Cablink State  ${PRIMARY_CABLINK_DN_LIST}  (?i)Enabled  (?i)On Air  ${BTS_ID}
    Check Cablink State  ${SECONDARY_CABLINK_DN_LIST}  (?i)Enabled  (?i)Degraded  ${BTS_ID}

Step 2. Check States For Primary Link Break 7447 Not Supported
    Logging With Timestamp
    ...  message=Step 2. Check States For Primary Link Break 7447 Not Supported
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Waiting for affected cells to fail
    ...  style=ONGOING
    Wait For Affected Cells To Change State  (?i)Disabled  ${TESTED_CELL_DN}
    Logging With Timestamp
    ...  message=Waiting for allowed 1815 to appear
    ...  style=ONGOING
    ${fault_1815_unique_attr}=  FM Await For Fault
    ...  faultId=1815, alarmId=7116, severity=Major, alarmingObjectIds[0].internal=${PRIMARY_CABLINK_DN_LIST[0]}
    ...  ${BTS_ID}
    ...  ${fault_1815_alarm_resource}
    ...  35
    ${status_same}=  Check Whether Synchro Link Now The Same As Preconditions
    Logging With Timestamp
    ...  message=Waiting for RMOD to reset
    ...  style=ONGOING
    ${rmod_enabled}=  Run Keyword And Return Status  Assert  RMOD  ${TESTED_RMOD_DN}
    ...  operationalState=regex"(?i)Disabled", availabilityStatus=regex"(?i)not installed"  timeout=180  connection=${BTS_ID}
    ${rmod_fid10_status}  ${rmod_fid10_unique_attr}=  Run Keyword And Ignore Error  FM Await For Fault
    ...  faultId=10, alarmId=7116, severity=Critical, alarmingObjectIds[0].internal=${TESTED_RMOD_DN}
    ...  ${BTS_ID}
    ...  ${rmod_fid10_alarm_resource}
    ...  240
    Logging With Timestamp
    ...  message=Waiting for RMOD to get back on air
    ...  style=ONGOING
    ${rmod_disabled}=  Run Keyword And Return Status  Assert  RMOD  ${TESTED_RMOD_DN}
    ...  operationalState=regex"(?i)Enabled"  timeout=600  connection=${BTS_ID}
    ${rmod_offline}=  Run Keyword And Return Status  Assert No  RMOD
    ...  operationalState=regex"(?i)Disabled", availabilityStatus=regex"(?i)off line"  timeout=180  connection=${BTS_ID}
    Run Keyword And Continue On Failure
    ...  Run Keyword If  '${rmod_enabled}'=='True' and '${rmod_fid10_status}'=='PASS' and '${rmod_disabled}'=='True' and '${rmod_offline}'=='True'
    ...  Log  RMOD ${TESTED_RMOD_DN} reset according to plan.  console=True
    ...  ELSE  Log  RMOD ${TESTED_RMOD_DN} DID NOT reset according to plan. Plese, investigate.  console=True
    Wait For Affected Cells To Change State  (?i)Enabled  ${TESTED_CELL_DN}
    Logging With Timestamp
    ...  message=Collecting infomodel log from current session
    ...  style=ONGOING
    Collect Infomodel Log From Current Session  ${cfg.test_logs_path}/InfoModel_rmod_${BTS_ID}.ims2  connection=${BTS_ID}
    Check availabilityStatus For Affected And Not Affected Items  ${AFFECTED_ITEMS}  ${NOT_AFFECTED_CELLS_DN}
    ...  ${cfg.test_logs_path}/InfoModel_rmod_${BTS_ID}.ims2
    ${status_same}=  Check Whether Synchro Link Now The Same As Preconditions
    Run Keyword If  ${status_same}==True  Set Test Variable  ${RUN_STEP3}  True
    ...  ELSE  Set Test Variable  ${RUN_STEP3}  False

Step 3. Change Back Optical Link For Primary Link Break 7447 Not Supported
    Logging With Timestamp
    ...  message=Step 3. Change Back Optical Link For Primary Link Break 7447 Not Supported
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Changing Calient settings back to shorter link
    ...  style=ONGOING
    Change Optical Connection To Shorter For Link Break With Changed Link Length
    ...  long_link_break_duration=0
    ...  link_port_in=${PRIM_PORT_IN}
    ...  long_port_in=${LONG_PORT_IN}
    ...  all_calient_ports=${ALL_CALIENT_PORTS}
    ...  switch_ip=${IP_SWITCH}
    Logging With Timestamp
    ...  message=Checking cablinks states
    ...  style=ONGOING
    Check Cablink State  ${PRIMARY_CABLINK_DN_LIST}  (?i)Enabled  (?i)On Air  ${BTS_ID}
    Check Cablink State  ${SECONDARY_CABLINK_DN_LIST}  (?i)Enabled  (?i)Degraded  ${BTS_ID}

Step 4. Check States Again For Primary Link Break 7447 Not Supported
    Logging With Timestamp
    ...  message=Step 4. Check States Again For Primary Link Break 7447 Not Supported
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Waiting for affected cells to fail
    ...  style=ONGOING
    Wait For Affected Cells To Change State  (?i)Disabled  ${TESTED_CELL_DN}
    Logging With Timestamp
    ...  message=Waiting for allowed 1815 to appear
    ...  style=ONGOING
    ${fault_1815_unique_attr}=  FM Await For Fault
    ...  faultId=1815, alarmId=7116, severity=Major, alarmingObjectIds[0].internal=${PRIMARY_CABLINK_DN_LIST[0]}
    ...  ${BTS_ID}
    ...  ${fault_1815_alarm_resource}
    ...  35
    Logging With Timestamp
    ...  message=Check Whether Synchro Link Now The Same As Preconditions
    ...  style=ONGOING
    ${status_same}=  Check Whether Synchro Link Now The Same As Preconditions
    Logging With Timestamp
    ...  message=Waiting for RMOD to reset
    ...  style=ONGOING
    ${rmod_enabled}=  Run Keyword And Return Status  Assert  RMOD  ${TESTED_RMOD_DN}
    ...  operationalState=regex"(?i)Disabled", availabilityStatus=regex"(?i)not installed"  timeout=180  connection=${BTS_ID}
    ${rmod_fid10_status}  ${rmod_fid10_unique_attr}=  Run Keyword And Ignore Error  FM Await For Fault
    ...  faultId=10, alarmId=7116, severity=Critical, alarmingObjectIds[0].internal=${TESTED_RMOD_DN}
    ...  ${BTS_ID}
    ...  ${rmod_fid10_alarm_resource}
    ...  240
    Logging With Timestamp
    ...  message=Waiting for RMOD to get back on air
    ...  style=ONGOING
    ${rmod_disabled}=  Run Keyword And Return Status  Assert  RMOD  ${TESTED_RMOD_DN}
    ...  operationalState=regex"(?i)Enabled"  timeout=600  connection=${BTS_ID}
    ${rmod_offline}=  Run Keyword And Return Status  Assert No  RMOD
    ...  operationalState=regex"(?i)Disabled", availabilityStatus=regex"(?i)off line"  timeout=180  connection=${BTS_ID}
    Run Keyword And Continue On Failure
    ...  Run Keyword If  '${rmod_enabled}'=='True' and '${rmod_fid10_status}'=='True' and '${rmod_disabled}'=='True' and '${rmod_offline}'=='True'
    ...  Log  RMOD ${TESTED_RMOD_DN} reset according to plan.  console=True
    ...  ELSE  Log  RMOD ${TESTED_RMOD_DN} DID NOT reset according to plan. Plese, investigate.  console=True
    Wait For Affected Cells To Change State  (?i)Enabled  ${TESTED_CELL_DN}
    Collect Infomodel Log From Current Session  ${cfg.test_logs_path}/InfoModel_rmod_2_${BTS_ID}.ims2  connection=${BTS_ID}
    @{affected_items_list}=   Create List  ${TESTED_CELL_DN}
    Check availabilityStatus For Affected And Not Affected Items  ${AFFECTED_ITEMS}  ${NOT_AFFECTED_CELLS_DN}
    ...  ${cfg.test_logs_path}/InfoModel_rmod_2_${BTS_ID}.ims2
