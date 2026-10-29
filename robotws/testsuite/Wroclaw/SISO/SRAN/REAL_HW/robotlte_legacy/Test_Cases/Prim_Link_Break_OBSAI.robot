# robocop: off
*** Settings ***
Documentation
...  Author:  izabela.wencel@nokia.com
...  Maintainer:  izabela.wencel@nokia.com

Resource  ../tc_scenarios.robot
Resource  ../variables.robot
Resource  ../site_operations.robot
Resource  ../hran_ta/resources/ca_Recovery_link_break.robot
Resource  ./fh_reset.robot
Resource  ./link_break_resources.robot
Library  ../../../resources/ims2_parser.py

*** Variables ***
&{CB007779_DATA_DOWN}=  &{EMPTY}       # The user (tester) should provide the data for the test in the format RMOD_SN=OS_IP:1-x,2-x,3-x,4-x,5-x,6-x
                                       # where RMOD_SN means serial number of the tested RMOD, OS_IP means optical switch ip and
                                       # 1-x,2-x,3-x,4-x,5-x,6-x stands for optical switch setting (bank-port_out) which breaks synchronization link
*** Keywords ***


Primary Link Break For OBSAI RMOD
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-38456
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The purpose of this automated test case is to check and verify whether the configuration
    ...  behaves in the expected way when the primary link is broken.
    ...  Operational BTS with OBSAI radio connected to the BTS with two cablinks:
    ...  primary to BBMOD (ABIA) and secondary to BBMOD (ABIO) via FHS.
    ...  5G is deployed on ABIO, 4G, 3G, and 2G are deployed on ABIA.
    ...  To perform link break test supports optical switch.
    ...  The test waits for the FID 2002 to appear to perform link reconnection.
    ...  Cells must be deployed on the rario for FID 2002 to be Critical.
    ...  With multiple repetitions FID 4309 and 4310 (Connection Unstable) may apear,
    ...  if yes the time between repetitions should be extended so that the counter could reset.
    ...  The counters are RP301_PORTCONF_L.unsynchronized6GbLinkRateCounter and
    ...  RP301_PORTCONF_L.unsynchronized3GbLinkRateCounter
    ...
    ...  **Input Parameters:**
    ...
    ...  +--------------------------------------------------------------------------+
    ...  | Parameter             | Man. | Description                               |
    ...  +=======================+======+===========================================+
    ...  | CB007779_SYNC_DOWN    | Yes  | RMOD_SN=OS_IP:1-x,2-x,3-x,4-x,5-x,6-x     |
    ...  +-----------------------+------+-------------------------------------------+
    ...  meaning serial number of the tested OBSAI RMOD, and optical switch ip and setting.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  2024-12-06  Updates for robotws - izabela.wencel@nokia.com

    Set Tags  CA-CM  AUTHOR-izabela.wencel@nokia.com  MAINTAINER-izabela.wencel@nokia.com
    ...  GROUP_IN_CHARGE-MN RAN Pz 4 WRO 2  PHASE-CRT  FEATURE-CB007779
    Logging With Timestamp
    ...  message=Primary Link Break For OBSAI RMOD: @{CFG.active_bts_list} will be executed
    ...  style=ONGOING
    Common Test Setup
    Primary Link Break For OBSAI
    [Teardown]  Run Keywords
    ...  Run Keyword And Ignore Error  Optical Reconfiguration Tested Configuration   ${cfg.configuration_name}
    ...  AND  Common Test Teardown

Primary Link Break For OBSAI
    Precondition For Primary Link Break OBSAI
    ${BTS_timestamp}=  SSH Get BTS timestamp  ${BTS_ID}
    Step 1. Perform Primary Link Break
    Step 2. Check BTS State Primary Link Down
    Step 3. Perform Primary Link Reconnection
    Step 4. Check BTS State Primary Link Up  ${BTS_timestamp}

Precondition For Primary Link Break OBSAI
    Logging With Timestamp
    ...  message=Precondition For Primary Link Break OBSAI
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Get variables RMOD_SN, OS_SETTING, BTS_ID
    ...  style=ONGOING
    @{rmod_sn_link_down_list}=  Get Dictionary Keys  ${CB007779_SYNC_DOWN}
    Set Test Variable  ${RMOD_SN_LINK_DOWN}  ${rmod_sn_link_down_list[0]}
    @{os_set_link_down}=  Get Dictionary Values  ${CB007779_SYNC_DOWN}
    Set Test Variable  ${BTS_ID}  ${cfg['active_bts_list'][0]}
    Get RMOD, BBMOD, FHS, CABLINKS distNames
    Get Cells' distNames
    Get A List Of All Items  ${os_set_link_down}
    Get 2002 Alarming Resource  ${bbmod_smod_under_test}  #${SFP_LINKS}

Step 1. Perform Primary Link Break
    Logging With Timestamp
    ...  message=Step 1. Perform Primary Link Break
    ...  style=STEP
    ...  frame=${TRUE}
    @{rmod_sn_alt_conf_list}=  Create List
    @{rmod_alt_conf_list}=  Create List
    @{rmod_sn_alt_conf_list}=  Get Dictionary Keys  ${CB007779_SYNC_DOWN}
    @{rmod_alt_conf_list}=  Get Dictionary Values  ${CB007779_SYNC_DOWN}
    ${rmod_alt_conf}=  Set Variable  ${rmod_alt_conf_list[0]}
    ${all_cablinks_before_break}=  Create Cablinks Dictionary With Distnames And LinkMode
    Check Linkmode Of Chosen Cablink  ${all_cablinks_before_break}  ${CABLINK_PRIM_DN}  Primary
    Optical Switch Set Configuration Remove  ${rmod_alt_conf_list}
    Sleep  10  Optical switch reconfigured. Waiting for the link to change states.
    ${prim_disabled}=  Run Keyword and Return Status  Wait Until Keyword Succeeds  120  30
    ...  Check Cablink State  ${CABLINK_PRIM_DN}  (?i)Disabled  (?i)Not installed  ${BTS_ID}
    Run Keyword If  ${prim_disabled}  Log To Console  Primary Cablink Disabled  ELSE
    ...  Fail  Primary cabling NOT disabled. Check optical switch configuration

Step 2. Check BTS State Primary Link Down
   Logging With Timestamp
    ...  message=Step 2. Check BTS State Link Down
    ...  style=STEP
    ...  frame=${TRUE}

    Verify RU Power Remove Insert Cells State
    ...  ${cfg}
    ...  ${BTS_ID}
    ...  ${RMOD_SN_LINK_DOWN}
    ...  ${RMOD_UNDER_TEST_DN}
    ...  Remove
    ...  10 sec
    Verify RU Power Remove Insert State  ${BTS_ID}  ${RMOD_UNDER_TEST_DN}  Remove  10 sec
    Verify RU Power Remove Insert Alarms  ${BTS_ID}  ${RMOD_SN_LINK_DOWN}  ${RMOD_UNDER_TEST_DN}  Remove  10 sec
    Wait Until Keyword Succeeds
    ...  180
    ...  30
    ...  Verify RU Power Remove Insert State
    ...  ${BTS_ID}
    ...  ${RMOD_UNDER_TEST_DN}
    ...  Insert
    ...  10 sec

    Logging With Timestamp
    ...  message=Waiting for 2002 to appear...
    ...  style=ONGOING

    ${fid_2002_expected}=  Run Keyword And Return Status
    ...  admin.Assert Alarm Active
    ...  faultId=2002, severity=Critical, alarmingResource=regex".*${lane}.*"
    ...  timeout=360
    ...  connection=${BTS_ID}
    ${alarms}=  admin.Get Active Alarms  severity=Critical  connection=${BTS_ID}  timeout=30
    ${alarming_object}=  Get Lane  ${alarms}  ${lane}
    Run Keyword If
    ...  ${fid_2002_expected}==False
    ...  Fail
    ...  FID 2002 has not appeared. Test failed. If cells not deployed might be Minor.
    ...  ELSE
    ...  Run Keywords
    ...  admin.Add Allowed Alarm
    ...  faultId=2002, severity=Critical,
    ...  alarmingObjectIds[0].internal=${alarming_object}
    ...  connection=${BTS_ID}
    ...  AND
    ...  Log
    ...  FID 2002 appeared. Continuing to step 3 - reconnecting the link.
    ...  console=True
    Verify BBMOD Cells Are OnAir  ${cells_on_tested_fhs}  Enabled  Degraded
    Verify BBMOD Cells Are OnAir  ${cells_on_tested_bbmod}  Disabled  Not installed


Step 3. Perform Primary Link Reconnection
    Logging With Timestamp
    ...  message=Step 3. Perform Primary Link Reconnection
    ...  style=STEP
    ...  frame=${TRUE}
    Log  ${CABLINK_SECOND_DN}  console=True
    ${all_cablinks_before_reconnection}=  Create Cablinks Dictionary With Distnames And LinkMode
    Check Linkmode Of Chosen Cablink  ${all_cablinks_before_reconnection}  ${CABLINK_SECOND_DN}  Primary
    Optical Reconfiguration Tested Configuration   ${cfg.configuration_name}
    Sleep  60  Optical switch reconfigured. Waiting for the RMOD to change states.

Step 4. Check BTS State Primary Link Up
    [Arguments]  ${BTS_timestamp}
    Logging With Timestamp
    ...  message=Step 4. Check BTS State Link Up
    ...  style=STEP
    ...  frame=${TRUE}
    Verify RU Power Remove Insert Cells State
    ...  ${cfg}
    ...  ${BTS_ID}
    ...  ${RMOD_SN_LINK_DOWN}
    ...  ${RMOD_UNDER_TEST_DN}
    ...  Remove
    ...  10 sec
    Verify RU Power Remove Insert State  ${BTS_ID}  ${RMOD_UNDER_TEST_DN}  Remove  10 sec

    Sleep  60s
    ${fault_list}  Create List  faultId=1868, severity=Critical, ${BTS_ID}
    FM Find History Fault And Add To Allowed
    ...  ${fault_list}
    ...  ${BTS_timestamp}
    ...  ${BTS_ID}

    Verify RU Power Remove Insert Alarms  ${BTS_ID}  ${RMOD_SN_LINK_DOWN}  ${RMOD_UNDER_TEST_DN}  Remove  10 sec
    ${prim_enabled}=  Run Keyword and Return Status  Wait Until Keyword Succeeds  250  30
    ...  Check Cablink State  ${CABLINK_PRIM_DN}  (?i)Enabled  (?i)Online  ${BTS_ID}
    ${all_cablinks_before_reconnection}=  Create Cablinks Dictionary With Distnames And LinkMode  # od Przemka
    Check Linkmode Of Chosen Cablink  ${all_cablinks_before_reconnection}  ${CABLINK_PRIM_DN}  Primary
    Run Keyword If  ${prim_enabled}  Log To Console  Primary Cablink Enabled  ELSE  Run Keywords
    ...  Log To Console  Primary cabling disabled
    ...  AND  Fail  Primary link did not recover. Test Failed.
    ${RMOD_enabled}=  Run Keyword And Return Status
    ...  admin.Assert
    ...  RMOD
    ...  ${RMOD_UNDER_TEST_DN}
    ...  operationalState=regex"(?i)Enabled", availabilityStatus=regex"(?i)Online"
    ...  timeout=60
    ...  connection=${BTS_ID}
    Log  RMOD under test enabled ${RMOD_enabled}  console=True



    Verify RU Power Remove Insert State  ${BTS_ID}  ${RMOD_UNDER_TEST_DN}  Insert  10 sec
    Verify RU Power Remove Insert Alarms  ${BTS_ID}  ${RMOD_SN_LINK_DOWN}  ${RMOD_UNDER_TEST_DN}  Insert  10 sec
    Verify RU Power Remove Insert Cells State
    ...  ${cfg}
    ...  ${BTS_ID}
    ...  ${RMOD_SN_LINK_DOWN}
    ...  ${RMOD_UNDER_TEST_DN}
    ...  Insert
    ...  10 sec
    Verify BTS State  ${BTS_ID}
    admin.Collect Infomodel Log From Current Session  ${cfg.test_logs_path}/InfoModel_rmod_${BTS_ID}.ims2
    ...  connection=${BTS_ID}
    @{mock_affected_items_list}=  Create List
    Check availabilityStatus For Affected And Not Affected Items  ${mock_affected_items_list}  ${NOT_AFFECTED_ITEMS}
    ...  ${cfg.test_logs_path}/InfoModel_rmod_${BTS_ID}.ims2

Get Lane
    [Arguments]  ${alarms}  ${lane}
    @{alarming_objects}=  Create List
    FOR  ${alarm}  IN  @{alarms}
      ${status}=  Run Keyword And Return Status
      ...  Should Match Regexp  ${alarm['alarmingObjectIds'][0]['internal']}  .*${lane}.*
      Run Keyword If  ${status}==True
      ...  Append To List  ${alarming_objects}  ${alarm['alarmingObjectIds'][0]['internal']}
    END
    [Return]  ${alarming_objects[0]}

Get 2002 Alarming Resource
    [Arguments]  ${bbmod_smod_under_test}
    @{link_destination_sfp}=  Create List
    FOR  ${link}  IN  @{SFP_LINKS['connected']}
      ${status_bbmod}=  Run Keyword And Return Status  Should Be Equal
      ...  '${bbmod_smod_under_test[0]}'  '${link['parent']['destination']['distName']}'
      Continue For Loop If  ${status_bbmod}==False
      ${status_rmod}=  Run Keyword And Return Status  Run Keyword If  ${status_bbmod}==True  Should Be Equal
      ...  '${RMOD_UNDER_TEST_DN}'  '${link['parent']['source']['distName']}'
      Continue For Loop If  ${status_rmod}==False
      Append To List  ${link_destination_sfp}  ${link['destination']}
    END
    ${beginning}  ${sfp_sfp}=  Split String From Right  ${link_destination_sfp[0]}  /  1
    ${sfp_bbmod}=  Fetch From Right  string=${beginning}  marker=/
    ${lane}=  Catenate  SEPARATOR=/  ${sfp_bbmod}  ${sfp_sfp}
    Set Test Variable  ${LANE}  ${lane}

Verify BBMOD Cells Are OnAir
    [Documentation]
    ...  availability_status is not returned when it is OnAir (-) so we need to verify whether it is not opposite or not found
    [Arguments]  ${cells_on_tested_bbmod}  ${operational_state}  ${availability_status}
    FOR  ${cell_on_tested_bbmod}  IN  @{cells_on_tested_bbmod}
      ${nrcel_type}=  Run Keyword And Return Status  Should Match Regexp  '${cell_on_tested_bbmod}'  .*NRCELL.*
      ${lncel_type}=  Run Keyword And Return Status  Should Match Regexp  '${cell_on_tested_bbmod}'  .*LNCEL.*
      ${wncel_type}=  Run Keyword And Return Status  Should Match Regexp  '${cell_on_tested_bbmod}'  .*WNCEL.*
      ${gncel_type}=  Run Keyword And Return Status  Should Match Regexp  '${cell_on_tested_bbmod}'  .*GNCEL.*
      ${cell_type}=  Set Variable If
      ...  ${nrcel_type}==True  NRCEL
      ...  ${lncel_type}==True  LNCEL
      ...  ${wncel_type}==True  WNCEL
      ...  ${gncel_type}==True  GNCEL
      Verify Cell State For Link Break  ${cell_on_tested_bbmod}  ${cell_type}  ${operational_state}  ${availability_status}
    END
