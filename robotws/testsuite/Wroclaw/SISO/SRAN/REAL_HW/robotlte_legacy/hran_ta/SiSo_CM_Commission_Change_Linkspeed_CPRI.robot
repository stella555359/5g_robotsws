*** Settings ***
Library     taf.hw.optical_switch  WITH NAME  optical_switch

*** Variables ***
@{ABIP_ABIQ}  Cpri7  Auto
@{ABIN_ABINL_ABIO_ABIOL}  Cpri5  Cpri7  Auto
@{ABIA}  Cpri2  Cpri3  Cpri5  Cpri6  Cpri7  Auto
&{CABLINK_LINKSPEED_VALUE}  ABIA=@{ABIA}  ABIP=@{ABIP_ABIQ}  ABIQ=@{ABIP_ABIQ}  ABIN=@{ABIN_ABINL_ABIO_ABIOL}  ABINL=@{ABIN_ABINL_ABIO_ABIOL}
...  ABIO=@{ABIN_ABINL_ABIO_ABIOL}  ABIOL=@{ABIN_ABINL_ABIO_ABIOL}
${SISO_L3_CALL}  False

*** Keywords ***
TC_SiSo_CM_Commission_Change_Linkspeed_CPRI
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The purpose of this test case is to verify if the BTS works as expected after modifying link speed for CPRI.
    ...  We can provide S/N of tested RF or will be chosen one randomly.
    ...  Optional variable in cfg to perform test
    ...  e.g.
    ...  RF=EA203457019
    ...
    ...
    ...
    ...  *** Test Variable For L3 Call ***
    ...  ${SISO_L3_CALL}  False  #default value for L3 call is False, set test variable as True to perform test with L3 call
    ...  ${CELLS_YAML_PATH}  #mandatory path for ue_config.yaml if ${SISO_L3_CALL} is True
    ...
    ...  *****************
    ...  History of change
    ...  *****************
    ...
    Common Test Setup
    Logging With Timestamp
    ...  message=TC_SiSo_CM_Commission_Change_Linkspeed_CPRI will be executed
    ...  style=ONGOING
    Set Tags	CA-CM  AUTHOR-przemyslaw.kempa@nokia.com  MAINTAINER-przemyslaw.kempa@nokia.com
    ...		GROUP_IN_CHARGE- MN RAN Pz 4 WRO 8  PHASE-CRT  FEATURE-CNI-102820
    Precondition. Commission Change Linkspeed CPRI
    Step 1. Perform Change Value Of CABLINK linkSpeed
    Step 2. Checking Expected States After CABLINK linkSpeed Change
    Step 3. Perform L3 Call After CABLINK linkSpeed Change
    Step 4. Perform Change Value Of CABLINK linkSpeed To Previous Value
    Step 5. Perform L3 Call After CABLINK linkSpeed Change To Previous Value
  [Teardown]    Common Test Teardown

Precondition. Commission Change Linkspeed CPRI
    Log  === Precondition. Commission Change Linkspeed CPRI ===  console=${TRUE}
    Set Test Variable  ${BTS_ID}  ${cfg['active_bts_list'][0]}
    Create Dict With CPRI Rmods
    Choose RMOD To CPRI LinkSpeed Change
    Preparing Cells List For CABLINK linkSpeed Change
    Check BBMOD Connected To RMOD

Step 1. Perform Change Value Of CABLINK linkSpeed
    Log  === Step 1. Perform Change Value Of CABLINK linkSpeed ===  console=${TRUE}
    Get Current SCF File  ${cfg['test_logs_path']}  SCF_Precondition.xml  connection=${BTS_ID}
    ${class_name}  Set Variable  com.nokia.srbts.eqm:CABLINK
    &{scf_cablink_linkspeed_value_dict}  Create Dictionary
    FOR  ${cablink}  IN  @{TESTED_CABLINK_LIST}
      ${scf_cablink_linkspeed_value}  Check Scf Parameter Value  com.nokia.srbts.eqm:CABLINK  MRBTS-${BTS_ID}/EQM-1/HWTOP-1/${cablink}
      ...  linkSpeed  ${cfg['test_logs_path']}/SCF_Precondition.xml
      Set To Dictionary  ${scf_cablink_linkspeed_value_dict}  ${cablink}=${scf_cablink_linkspeed_value}
    END
    Create Delta  delta_id=1
    ${curent_likspeed_value}  Set Variable  ${EMPTY}
    ${current_bbmod}  Set Variable  ${EMPTY}
    FOR  ${cablink}  IN  @{TESTED_CABLINK_LIST}
      ${linkspeed_value_exist}  Run Keyword And Return Status  Should Not Be Empty  ${scf_cablink_linkspeed_value_dict['${cablink}']}
      ${linkspeed_value}  Get From Dictionary  ${CABLINK_LINKSPEED_VALUE}  ${AFFECTED_CABLINK_WITH_BBMOD['${cablink}']}
      Run Keyword If  ${linkspeed_value_exist}  Remove Values From List  ${linkspeed_value}  ${scf_cablink_linkspeed_value_dict['${cablink}']}
      ${count_linkspeed_value}  Get Length  ${linkspeed_value}
      ${linkspeed_value_index}  Evaluate  random.randint(0, ${count_linkspeed_value}-1)  modules=random
      ${choosen_likspeed_value}  Set Variable If  "${current_bbmod}"=="${AFFECTED_CABLINK_WITH_BBMOD['${cablink}']}"  ${curent_likspeed_value}
      ...  ${linkspeed_value[${linkspeed_value_index}]}
      ${curent_likspeed_value}  Set Variable  ${linkspeed_value[${linkspeed_value_index}]}
      ${current_bbmod}  Set Variable  ${AFFECTED_CABLINK_WITH_BBMOD['${cablink}']}
      Append Parameter Update To Delta  dist_name=MRBTS-${BTS_ID}/EQM-1/HWTOP-1/${cablink}  parameter=linkSpeed
      ...  value=${choosen_likspeed_value}  delta_id=1
    END
    Save Delta  target_file_name=${cfg['test_logs_path']}/delta.json  delta_id=1
    Log  Recommissionig started !!!  console=${TRUE}
    Perform Delta Recommissioning  delta_file=${cfg['test_logs_path']}/delta.json  connection=${BTS_ID}
    Log  Recommissioning Of Linkspeed Change Done.  console=${TRUE}
    Sleep  2 min  Waiting For BTS Stabilize After Reset

Step 2. Checking Expected States After CABLINK linkSpeed Change
    Log  === Step 2. Checking Expected States After CABLINK linkSpeed Change ===  console=${TRUE}
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  15 min  10 sec  Verify Mrbts State  ${BTS_ID}  OnAir
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  5 min  10 sec
    ...  Check If Provided Cells Are onAir  cells=${NOT_AFFECTED_CELLS_DISTNAME}  connection=${BTS_ID}
    @{affected_cell_dn_onair}  Create List  @{AFFECTED_CELLS_DISTNAME}
    Set Test Variable  ${affected_cell_dn_onair}  ${AFFECTED_CELL_DN_ONAIR}
    ${fault_1868_exist}  Run Keyword And Return Status  Assert Alarm Active  faultId=1868  timeout=120  connection=${BTS_ID}
    Run Keyword If  ${fault_1868_exist}  Check Affected Cells States And Alarms After LinkSpeed Change
    ...  ELSE  Run Keywords  Verify Multi BTS State  AND
    ...  Verify Alarms On All Nodes

Step 3. Perform L3 Call After CABLINK linkSpeed Change
    Log  === Step 3. Perform L3 Call After CABLINK linkSpeed Change ===  console=${TRUE}
    Run Keyword If  ${SISO_L3_CALL}  Run Keywords  Perform L3 Call For Provided Cells  ${AFFECTED_CELL_DN_ONAIR}  ${cfg['test_logs_path']}  AND
    ...  Sleep  1 min  Waiting For BTS Stabilize After Call
    ...  ELSE  Log  L3 Call skipped  console=${TRUE}

Step 4. Perform Change Value Of CABLINK linkSpeed To Previous Value
    Log  === Step 4. Perform Change Value Of CABLINK linkSpeed To Previous Value ===  console=${TRUE}
    Log  Recommissionig started !!!  console=${TRUE}
    Perform Commissioning  ${BTS_ID}  ${cfg['test_logs_path']}/SCF_Precondition.xml  connection=${BTS_ID}
    Log  Recommissioning Of Linkspeed Change Done.  console=${TRUE}
    Sleep  2 min
    Verify Multi BTS State
    Verify Alarms On All Nodes

Step 5. Perform L3 Call After CABLINK linkSpeed Change To Previous Value
    Log  === Step 5. Perform L3 Call After CABLINK linkSpeed Change To Previous Value ===  console=${TRUE}
    Run Keyword If  ${SISO_L3_CALL}  Perform L3 Call For Provided Cells  ${AFFECTED_CELLS_DISTNAME}  ${cfg['test_logs_path']}
    ...  ELSE  Log  L3 Call skipped  console=${TRUE}

Create Dict With CPRI Rmods
    ${all_cablinks}  Create Cablinks Dictionary With Distnames And LinkMode
    Set Test Variable  ${all_cablinks}  ${All_CABLINKS}
    ${cpri_rmods}  Create Dictionary
    FOR  ${cablink}  IN  @{all_cablinks}
      ${status_cpri}  Run Keyword And Return Status  Should Match Regexp  ${all_cablinks['${cablink}']['linkSpeed']}  Cpri
      @{cablink_list}  Run Keyword If  ${status_cpri}  Create List
      &{rmod_dict}  Run Keyword If  ${status_cpri}  Create Dictionary
      ${rmod_key_exist}  Run Keyword If  ${status_cpri}  Run Keyword And Return Status
      ...  Dictionary Should Contain Key  ${cpri_rmods}  ${all_cablinks['${cablink}']['rmod']}
      Run Keyword If  ${rmod_key_exist}  Append To List  ${cpri_rmods['${all_cablinks['${cablink}']['rmod']}']['cablinks']}  ${cablink}
      Run Keyword If  ${status_cpri} and not ${rmod_key_exist}  Run Keywords
      ...  Append To List  ${cablink_list}  ${cablink}  AND
      ...  Set To Dictionary  ${rmod_dict}  cablinks=${cablink_list}  AND
      ...  Set To Dictionary  ${rmod_dict}  linkSpeed=${all_cablinks['${cablink}']['linkSpeed']}  AND
      ...  Set To Dictionary  ${cpri_rmods}  ${all_cablinks['${cablink}']['rmod']}=${rmod_dict}
    END
    FOR  ${rmod_dn}  IN  @{cpri_rmods}
      ${radio_parameters}  Get Parameters For  RMOD  ${rmod_dn}  connection=${BTS_ID}
      ${rmod_sn}  Get From Dictionary  ${radio_parameters}  serialNumber
      Set To Dictionary  ${cpri_rmods['${rmod_dn}']}  serialNumber=${rmod_sn}
    END
    Set Test Variable  ${cpri_rmods}  ${CPRI_RMODS}

Choose RMOD To CPRI LinkSpeed Change
    ${cpri_rmod_number}  Get Length  ${CPRI_RMODS}
    Run Keyword If  ${cpri_rmod_number}==0  Fail  NO RMOD WITH CPRI CABLINK ON TESTLINE !!!
    ${provided_rmod_exist}  Run Keyword And Return Status  Variable Should Exist  ${CUSTOM_RADIO_UNIT_LIST}
    FOR  ${rmod}  IN  @{CPRI_RMODS}
      Exit For Loop If  not ${provided_rmod_exist}
      ${provided_rmod}  Run Keyword If  "${CUSTOM_RADIO_UNIT_LIST[0]}"=="${CPRI_RMODS['${rmod}']['serialNumber']}"  Set Variable  ${rmod}
      Exit For Loop If  "${CUSTOM_RADIO_UNIT_LIST[0]}"=="${CPRI_RMODS['${rmod}']['serialNumber']}"
    END
    ${correct_provided_sn_rmod}  Run Keyword If  ${provided_rmod_exist}  Run Keyword And Return Status  Should Not Be Empty  ${provided_rmod}
    Run Keyword If  ${provided_rmod_exist} and not ${correct_provided_sn_rmod}  Fail  Provided SN RMOD not correct !!!
    ${cipri_rmods_list}  Run Keyword If  not ${provided_rmod_exist}  Get Dictionary Keys  ${CPRI_RMODS}
    ${count_cipri_rmods_list}  Run Keyword If  not ${provided_rmod_exist}  Get Length  ${cipri_rmods_list}
    ${cipri_rmod_index}  Run Keyword If  not ${provided_rmod_exist}  Evaluate  random.randint(0, ${count_cipri_rmods_list}-1)  modules=random
    ${tested_rmod}  Set Variable If  ${provided_rmod_exist}  ${provided_rmod}  ${cipri_rmods_list[${cipri_rmod_index}]}
    Set Test Variable  ${TESTED_RMOD_DN}  ${tested_rmod}
    ${tested_cablink_list}  Get From Dictionary  ${CPRI_RMODS['${TESTED_RMOD_DN}']}  cablinks
    Set Test Variable  ${tested_cablink_list}  ${TESTED_CABLINK_LIST}

Preparing Cells List For CABLINK linkSpeed Change
    ${affected_cells_distname}  Get Cell Mapping By Module Id  ${TESTED_RMOD_DN}  connection=${BTS_ID}
    Set Test Variable  ${AFFECTED_CELLS_DISTNAME}  ${affected_cells_distname}
    ${all_cells_distname}  Create All Cells Distname
    Set Test Variable  ${ALL_CELLS_DISTNAME}  ${all_cells_distname}
    ${not_affected_cells_distname}  Create List  @{ALL_CELLS_DISTNAME}
    Set Test Variable  ${NOT_AFFECTED_CELLS_DISTNAME}  ${not_affected_cells_distname}
    Remove Values From List  ${NOT_AFFECTED_CELLS_DISTNAME}  @{AFFECTED_CELLS_DISTNAME}

Check BBMOD Connected To RMOD
    &{tested_cablink_dn_cfg_dict}  Create Dictionary
    FOR  ${cablink_cfg}  IN  @{TESTED_CABLINK_LIST}
      ${cablink_distname}  Get From Dictionary  ${All_CABLINKS['${cablink_cfg}']}  internal
      Set To Dictionary  ${tested_cablink_dn_cfg_dict}  ${cablink_distname}=${cablink_cfg}
    END
    ${tested_cablink_dn_list}  Get Dictionary Keys  ${tested_cablink_dn_cfg_dict}
    ${all_cablinks_parameter}  Get Parameters For ALL  CABLINK  connection=${BTS_ID}
    &{affected_cablink_with_bbmod}  Create Dictionary
    FOR  ${cablink_dn}  IN  @{tested_cablink_dn_list}
      Set Test Variable  ${FIND_CABLINK_DN}  ${cablink_dn}
      Wait Until Keyword Succeeds  10x  2 sec  _Find BBMOD
      Set To Dictionary  ${affected_cablink_with_bbmod}  ${tested_cablink_dn_cfg_dict['${cablink_dn}']}=${FIND_CABLINK_DN}
    END
    FOR  ${cablink_cfg}  IN  @{affected_cablink_with_bbmod}
      ${bbmod_param}  Get Parameters For  BBMOD  ${affected_cablink_with_bbmod['${cablink_cfg}']}  connection=${BTS_ID}
      ${bbmod_sortname}  Fetch From Left  ${bbmod_param['productName']}  ${SPACE}
      Set To Dictionary  ${affected_cablink_with_bbmod}  ${cablink_cfg}=${bbmod_sortname}
    END
    Log Dictionary  ${affected_cablink_with_bbmod}
    Set Test Variable  ${AFFECTED_CABLINK_WITH_BBMOD}  ${affected_cablink_with_bbmod}

_Find BBMOD
    ${all_cablinks_parameter}  Get Parameters For ALL  CABLINK  connection=${BTS_ID}
    FOR  ${cablink}  IN  @{all_cablinks_parameter}
      ${firstEndpointDN}  Run Keyword If  "${FIND_CABLINK_DN}"=="${cablink['id']}"  Get From Dictionary  ${cablink}  firstEndpointDN
      Exit For Loop If  "${FIND_CABLINK_DN}"=="${cablink['id']}"
    END
    ${bbmod_status}  Run Keyword And Return Status  Should Match Regexp  ${firstEndpointDN}  BBMOD
    FOR  ${cablink}  IN  @{all_cablinks_parameter}
      Exit For Loop If  ${bbmod_status}
      ${cablink_id}  Run Keyword If  "${firstEndpointDN}"=="${cablink['secondEndpointDN']}"  Get From Dictionary  ${cablink}  id
      Exit For Loop If  "${firstEndpointDN}"=="${cablink['secondEndpointDN']}"
    END
    ${FIND_CABLINK_DN}  Set Variable If  ${bbmod_status}  ${firstEndpointDN}  ${cablink_id}
    Set Test Variable  ${FIND_CABLINK_DN}
    Run Keyword If  not ${bbmod_status}  Fail  BBMOD to which RMOD is connected was not found

Check Affected Cells States And Alarms After LinkSpeed Change
    ${all_active_alarms}  Get Active Alarms  connection=${BTS_ID}
    @{faulty_cell_dn_list}  Create List
    FOR  ${alarm}  IN  @{all_active_alarms}
      Run Keyword If  ${alarm['faultId']}==1868  Append To List  ${faulty_cell_dn_list}  ${alarm['alarmingObjectIds'][0]['internal']}
    END
    Set Test Variable  ${FAULTY_CELL_DN_LIST}  ${faulty_cell_dn_list}
    Remove Values From List  ${AFFECTED_CELL_DN_ONAIR}  @{FAULTY_CELL_DN_LIST}
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  3 min  10 sec
    ...  Check If Provided Cells Are onAir  cells=${AFFECTED_CELL_DN_ONAIR}  connection=${BTS_ID}
    Clear Allowed Alarms List  connection=${BTS_ID}
    FOR  ${alarm}  IN  @{GLO_ADMIN_ALLOWED_ALARMS}
        Add Allowed Alarm  ${alarm}  connection=${BTS_ID}
    END
    Add Allowed Alarm  faultId=1868, severity=Critical  connection=${BTS_ID}
    ${alarm_unexpected_status}  Run Keyword And Return Status  Assert No Unexpected Active Alarms  connection=${BTS_ID}
    Run Keyword If  ${alarm_unexpected_status}  Log  No Unexpected Active Alarms Visible  console=${TRUE}
    Run Keyword If  not ${alarm_unexpected_status}  Log  Unexpected Active Alarms Visible  console=${TRUE}
    Run Keyword If  not ${alarm_unexpected_status}  Run Keyword And Continue On Failure  Fail  Unexpected Active Alarms Visible
