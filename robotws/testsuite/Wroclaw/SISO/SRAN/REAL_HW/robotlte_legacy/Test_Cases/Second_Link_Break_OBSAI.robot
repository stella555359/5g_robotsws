# robocop: off
*** Settings ***
Documentation
...  Author:  izabela.wencel@nokia.com
...  Maintainer:  izabela.wencel@nokia.com

Resource  ../tc_scenarios.robot
Resource  ../variables.robot
Resource  ../site_operations.robot
Resource  ../hran_ta/resources/ca_Recovery_link_break.robot
Resource  ../hran_ta/SiSo_SM_RU_Primary_link_break.robot
Resource  ./fh_reset.robot
Resource  ./link_break_resources.robot
Library  ../../../resources/ims2_parser.py

*** Variables ***
&{CB007779_DATA_DOWN}=  &{EMPTY}       # The user (tester) should provide the data for the test in the format RMOD_SN=OS_IP:1-x,2-x,3-x,4-x,5-x,6-x
                                       # where RMOD_SN means serial number of the tested RMOD, OS_IP means optical switch ip and
                                       # 1-x,2-x,3-x,4-x,5-x,6-x stands for optical switch setting (bank-port_out) which breaks data link

*** Keywords ***
Secondary Link Break For OBSAI RMOD
    [Documentation]
    ...  [CASE LINK]:https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-41243
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Operational BTS with OBSAI/CPRI radio connected to the BTS with two links:
    ...  primary to BBMOD and secondary to BBMOD via FHS. All 4 RATs are deployed.
    ...  To perform link break test supports Leoni optical switch.
    ...  The test waits for the 1815 FID to appear to perform link reconnection.
    ...  Mandatory variable in the test suite to perform the test:
    ...
    ...  **Input Parameters:**
    ...
    ...  +--------------------------------------------------------------------------+
    ...  | Parameter             | Man. | Description                               |
    ...  +=======================+======+===========================================+
    ...  | CB007779_DATA_DOWN    | Yes  | RMOD_SN=OS_IP:1-x,2-x,3-x,4-x,5-x,6-x     |
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
    ...  message=Secondary Link Break For OBSAI RMOD: @{CFG.active_bts_list} will be executed
    ...  style=ONGOING
    Common Test Setup
    Secondary Link Break
    [Teardown]  Run Keywords
    ...  Run Keyword And Ignore Error  Optical Reconfiguration Tested Configuration   ${cfg.configuration_name}
    ...  AND  Common Test Teardown


Secondary Link Break
    Precondition For Secondary Link Break
    Step 1. Perform Secondary Link Break
    Step 2. Check BTS State Secondary Link Down
    Step 3. Perform Secondary Link Reconnection
    Step 4. Check BTS State Secondary Link Up

Precondition For Secondary Link Break
    Logging With Timestamp
    ...  message=Precondition For Secondary Link Break
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Checking preconditions for CNI-127210
    ...  style=ONGOING
    Preconditions For CNI-127210
    ${release}=  admin.Get Sw Release Name  connection=${bts_id}
    ${proper_sw}=  Run Keyword If  "${release}"=="SBTS24R3" and ${PRECOND_FOR_CNI}
    ...  Check If Current Build Is Newer Than  SBTS24R3_ENB_0000_000779_000000  alias=${bts_id}
    ...  ELSE IF  "${release}"=="SBTS25R1" and ${PRECOND_FOR_CNI}
    ...  Check If Current Build Is Newer Than  SBTS25R1_ENB_0000_000130_000000  alias=${bts_id}
    ...  ELSE IF  ${PRECOND_FOR_CNI}
    ...  Check If Current Build Is Newer Than  SBTS25R2_ENB_9999_241203_000015  alias=${bts_id} 
    Run keyword If  ${proper_sw}  Set Test Variable  ${PRECOND_FOR_CNI}  False
    Logging With Timestamp
    ...  message=Getting variables RMOD_SN, OS_SETTING, BTS_ID
    ...  style=ONGOING
    @{rmod_sn_link_down_list}=  Get Dictionary Keys  ${CB007779_DATA_DOWN}
    Set Test Variable  ${RMOD_SN_LINK_DOWN}  ${rmod_sn_link_down_list[0]}
    @{os_set_link_down}=  Get Dictionary Values  ${CB007779_DATA_DOWN}
    Set Test Variable  @{OS_SET_LINK_DOWN}  @{os_set_link_down}
    Set Test Variable  ${BTS_ID}  ${cfg['active_bts_list'][0]}
    Get RMOD, BBMOD, FHS, CABLINKS distNames
    Get Cells' distNames
    Get a list of All Items  ${OS_SET_LINK_DOWN}
    Logging With Timestamp
    ...  message=Getting variables RMOD_SN, OS_SETTING, BTS_ID done.
    ...  style=DONE

Step 1. Perform Secondary Link Break
    Logging With Timestamp
    ...  message=Step 1. Perform Secondary Link Break
    ...  style=STEP
    ...  frame=${TRUE}
    &{all_cablinks_before_break}=  Create Cablinks Dictionary With Distnames And LinkMode
    Set Start Timestamp In IMS For CNI-127210
    Check Linkmode Of Chosen Cablink  ${all_cablinks_before_break}  ${CABLINK_SECOND_DN}  Secondary
    Optical Switch Set Configuration Remove  ${OS_SET_LINK_DOWN}
    ${second_disabled}=  Run Keyword and Return Status  Wait Until Keyword Succeeds  120  30
    ...  Check Cablink State  ${CABLINK_SECOND_DN}  (?i)Disabled  (?i)Not installed  ${BTS_ID}
    Run Keyword If  ${second_disabled}  Log To Console  Secondary cablink disabled  ELSE
    ...  Fail  Secondary cabling NOT disabled. Check optical switch configuration.

Step 2. Check BTS State Secondary Link Down
    Logging With Timestamp
    ...  message=Step 2. Check BTS State Secondary Link Down
    ...  style=STEP
    ...  frame=${TRUE}
    ${prim_enabled}=  Run Keyword and Return Status
    ...  Wait Until Keyword Succeeds  120  30
    ...  Check Cablink State  ${CABLINK_PRIM_DN}  (?i)Enabled  (?i)Online  ${BTS_ID}
    Run Keyword If  ${prim_enabled}  Log To Console  Primary cablink enabled  ELSE
    ...  Fail  Primary cabling NOT enabled. Check optical switch configuration.
    Verify Cells On BBMOD via FHS  ${cells_on_tested_fhs}  Disabled  Degraded
    Verify Cells On direct BBMOD  ${cells_on_tested_bbmod}  Enabled  Degraded
    Wait Until Keyword Succeeds  30  10  Verify RU Power Remove Insert State  ${BTS_ID}  ${RMOD_UNDER_TEST_DN}  Insert  10 sec
    Log  ${\n}Waiting for 1815 to appear......  console=True
    ${fid_1815_minor_expected}  Run Keyword If  ${PRECOND_FOR_CNI}  Run Keyword And Return Status
    ...  Check Active Fault In IMS For CNI-127210  fault_id=1815  severity=Minor
    ...  ELSE  Run Keyword And Return Status  Assert Alarm Active
    ...  faultId=1815, severity=Minor, alarmingResource=${CABLINK_SECOND_DN}
    ...  timeout=180  connection=${BTS_ID}
    ${fid_1815_critical_expected}=  Run Keyword And Return Status  Assert Alarm Active
    ...  faultId=1815, severity=Critical, alarmingResource=${CABLINK_SECOND_DN}
    ...  timeout=180  connection=${BTS_ID}
    Run Keyword If  ${fid_1815_critical_expected}  Run Keywords
    ...  Log  FID 1815 Critical appeared. Continuing to step 3 - reconnecting the link.  console=True
    ...  AND  Add Allowed Alarm  faultId=1815, severity=Critical, alarmingObjectIds[0].internal=${CABLINK_SECOND_DN}
    ...  connection=${BTS_ID}
    ...  AND  Set Test Variable  ${1815_severity}  Critical
    Run Keyword If  ${fid_1815_minor_expected}  Run Keywords
    ...  Log  FID 1815 Minor appeared. Continuing to step 3 - reconnecting the link.  console=True
    ...  AND  Add Allowed Alarm  faultId=1815, severity=Minor, alarmingObjectIds[0].internal=${CABLINK_SECOND_DN}
    ...  connection=${BTS_ID}
    ...  AND  Set Test Variable  ${1815_severity}  Minor
    Run Keyword If  '${1815_severity}'=='Minor'  Add Allowed 1868 Alarm
    ${second_disabled}=  Run Keyword and Return Status  Wait Until Keyword Succeeds  120  30
    ...  Check Cablink State  ${CABLINK_SECOND_DN}  (?i)Disabled  (?i)Not installed  ${BTS_ID}
    Run Keyword If  ${second_disabled}  Log To Console  Secondary cablink disabled  ELSE
    ...  Fail  Secondary cabling NOT disabled. Check optical switch configuration.
    Wait Until Keyword Succeeds  60  20  Verify RU Power Remove Insert State  ${BTS_ID}  ${RMOD_UNDER_TEST_DN}  Insert  10 sec

Step 3. Perform Secondary Link Reconnection
    Logging With Timestamp
    ...  message=Step 3. Perform Secondary Link Reconnection
    ...  style=STEP
    ...  frame=${TRUE}
    Log To Console  ${CABLINK_SECOND_DN}
    Optical Reconfiguration Tested Configuration   ${cfg.configuration_name}
    Sleep  60
    ${all_cablinks_before_reconnection}=  Create Cablinks Dictionary With Distnames And LinkMode
    Check Linkmode Of Chosen Cablink  ${all_cablinks_before_reconnection}  ${CABLINK_SECOND_DN}  Secondary
    ${second_enabled}=  Run Keyword and Return Status  Wait Until Keyword Succeeds  120  30
    ...  Check Cablink State  ${CABLINK_SECOND_DN}  (?i)Enabled  (?i)Online  ${BTS_ID}
    Run Keyword If  ${second_enabled}  Log To Console  Secondary Cablink Enabled  ELSE
    ...  Fail  Secondary cabling NOT enabled. Check optical switch configuration

Step 4. Check BTS State Secondary Link Up
    Logging With Timestamp
    ...  message=Step 4. Check BTS State Secondary Link Up
    ...  style=STEP
    ...  frame=${TRUE}
    Verify Cells On BBMOD via FHS  ${cells_on_tested_fhs}  Disabled  Off line
    Wait Until Keyword Succeeds
    ...  60
    ...  20
    ...  Verify RU Power Remove Insert State
    ...  ${BTS_ID}
    ...  ${RMOD_UNDER_TEST_DN}
    ...  Insert
    ...  10 sec
    Verify RU Power Remove Insert Alarms  ${BTS_ID}  ${RMOD_SN_LINK_DOWN}  ${RMOD_UNDER_TEST_DN}  Insert  10 sec
    Verify RU Power Remove Insert Cells State
    ...  ${cfg}
    ...  ${BTS_ID}
    ...  ${RMOD_SN_LINK_DOWN}
    ...  ${RMOD_UNDER_TEST_DN}
    ...  Insert
    ...  10 sec
    Verify BTS State  ${BTS_ID}
    Collect Infomodel Log From Current Session  ${cfg.test_logs_path}/InfoModel_rmod_${BTS_ID}.ims2
    ...  connection=${BTS_ID}
    ${mock_affected_items_list}=  Create List
    Check availabilityStatus For Affected And Not Affected Items  ${mock_affected_items_list}  ${NOT_AFFECTED_ITEMS}
    ...  ${cfg.test_logs_path}/InfoModel_rmod_${BTS_ID}.ims2

Verify Cells On BBMOD via FHS
    [Arguments]  ${cells_on_tested_fhs}  ${operational_state}  ${not_availability_status}
    FOR  ${cell_on_tested_fhs}  IN  @{cells_on_tested_fhs}
      ${lncel_type}=  Run Keyword And Return Status  Should Match Regexp  '${cell_on_tested_fhs}'  .*LNCEL.*
      ${nrcelL_type}=  Run Keyword And Return Status  Should Match Regexp  '${cell_on_tested_fhs}'  .*NRCELL.*
      ${cell_type}=  Set Variable If
      ...  ${lncel_type}==True  LNCEL
      ...  ${nrcelL_type}==True  NRCEL
      Verify Cell State For Link Break  ${cell_on_tested_fhs}  ${cell_type}  ${operational_state}  ${not_availability_status}
    END
    Log  Cells on BBMOD via FHS are in the expected state.  console=True

Verify Cells On direct BBMOD
    [Arguments]  ${cells_on_tested_bbmod}  ${operational_state}  ${not_availability_status}
    FOR  ${cell_on_tested_bbmod}  IN  @{cells_on_tested_bbmod}
      ${lncel_type}=  Run Keyword And Return Status  Should Match Regexp  '${cell_on_tested_bbmod}'  .*LNCEL.*
      ${wncel_type}=  Run Keyword And Return Status  Should Match Regexp  '${cell_on_tested_bbmod}'  .*WNCEL.*
      ${gncel_type}=  Run Keyword And Return Status  Should Match Regexp  '${cell_on_tested_bbmod}'  .*GNCEL.*
      ${cell_type}=  Set Variable If
      ...  ${lncel_type}==True  LNCEL
      ...  ${wncel_type}==True  WNCEL
      ...  ${gncel_type}==True  GNCEL
      Verify Cell State For Link Break  ${cell_on_tested_bbmod}  ${cell_type}  ${operational_state}  ${not_availability_status}
    END
    Log  Cells on direct BBMOD are in the expected state.  console=True

Add Allowed 1868 Alarm
    FOR  ${cell_affected_dn}  IN  @{CELLS_AFFECTED_DN}
      admin.Add Allowed Alarm
      ...  faultId=1868, severity=Critical, alarmingObjectIds[0].internal=${cell_affected_dn}
      ...  connection=${BTS_ID}
    END
