*** Settings ***
Resource    ../tc_scenarios.robot

Library     resources/siso_velocity_communicator.py

*** Variables ***
${SISO_L3_CALL}          False

*** Keywords ***
TC_SiSo_REC_Cross-Cabling_between_TheSameRadio
  [Documentation]
  ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FPB-931694
  ...  *****************
  ...  Basic information
  ...  *****************
  ...  The purpose of this test case is to verify if the BTS works as expected after cross cabling operation.
  ...  RMOD is connected to the same BBMOD with two optical link.
  ...
  ...  Mandatory variable in cfg to perform test
  ...  e.g.
  ...  RF=EA203457019  velocity_reservation_id=8c95d2cd-8d34-4f11-aada-dc3200335665
  ...
  ...  *** Test Variable For L3 Call ***
  ...  ${SISO_L3_CALL}             False  #default value for L3 call is False, set test variable as True to perform test with L3 call
  ...  ${CELLS_YAML_PATH}                 #mandatory path for ue_config.yaml if ${SISO_L3_CALL} is True
  ...
  ...  *****************
  ...  History of change
  ...  *****************
  ...

  Set Tags	CA-CM    AUTHOR-przemyslaw.kempa@nokia.com    MAINTAINER-przemyslaw.kempa@nokia.com
  ...		    GROUP_IN_CHARGE- MN RAN Pz 4 WRO 8     PHASE-CRT  FEATURE-CNI-102820
  Common Test Setup
  Logging With Timestamp
  ...  message=TC_SiSo_REC_Cross-Cabling_between_TheSameRadio will be executed
  ...  style=ONGOING
  Precondition. Cross-Cabling between TheSameRadio
  Step 1. Perform L3 Call before Cross-Cabling TheSameRadio
  Step 2. Exchange The Optical Connection For The Selected Radio
  Step 3. Perform L3 Call after Cross-Cabling TheSameRadio
  Step 4. Recover To Initial Optical Connection After Cross-Cabling TheSameRadio
  [Teardown]    Common Test Teardown


Precondition. Cross-Cabling between TheSameRadio
    Log  === Precondition. SiSo_REC_Cross-Cabling_between_TheSameRadio ===  console=${TRUE}

    Preparing Variables For Cross-Cabling TheSameRadio

Step 1. Perform L3 Call before Cross-Cabling TheSameRadio
    Log  === Step 1. Perform L3 Call before Cross-Cabling TheSameRadio ===  console=${TRUE}
    Run Keyword If  ${SISO_L3_CALL}  Perform L3 Call For Provided Cells  ${AFFECTED_CELLS_DISTNAME}  ${cfg['test_logs_path']}
    ...  ELSE  Log  L3 Call skipped  console=${TRUE}

Step 2. Exchange The Optical Connection For The Selected Radio
    Log  === Step 2. Exchange The Optical Connection For The Selected Radio ===  console=${TRUE}
    Perform Cross Connection Between TheSameRadio
    Verify Multi BTS State
    Checking Active Alarm After Cross-Cabling TheSameRadio
    Checking availabilityStatus In Infomodel After Cross-Cabling TheSameRadio

Step 3. Perform L3 Call after Cross-Cabling TheSameRadio
    Log  === Step 3. Perform L3 Call after Cross-Cabling TheSameRadio ===  console=${TRUE}
    Run Keyword If  ${SISO_L3_CALL}  Perform L3 Call For Provided Cells  ${AFFECTED_CELLS_DISTNAME}  ${cfg['test_logs_path']}
    ...  ELSE  Log  L3 Call skipped  console=${TRUE}

Step 4. Recover To Initial Optical Connection After Cross-Cabling TheSameRadio
    Log  === Step 4. Recover To Initial Optical Connection After Cross-Cabling TheSameRadio ===  console=${TRUE}
    Recovery Optical Connection After Cross-Cabling TheSameRadio
    Verify Multi BTS State
    Checking Active Alarm After Cross-Cabling TheSameRadio
    Checking Historical Alarm After Cross-Cabling TheSameRadio
    Checking availabilityStatus In Infomodel After Cross-Cabling TheSameRadio

Preparing Variables For Cross-Cabling TheSameRadio
    Set Test Variable  ${BTS_ID}  ${cfg['active_bts_list'][0]}
    ${provided_rmod_exist}  Run Keyword And Return Status  Variable Should Exist  ${CUSTOM_RADIO_UNIT_LIST}
    Run Keyword If  not ${provided_rmod_exist}  Fail  Please provide serial number of tested RMOD !!!
    ${count_rmod_list}  Get Length  ${CUSTOM_RADIO_UNIT_LIST}
    Run Keyword If  "${count_rmod_list}"=="1"  Log  Tested RMOD -> ${CUSTOM_RADIO_UNIT_LIST[0]}  console=${TRUE}
    Run Keyword If  not "${count_rmod_list}"=="1"  Fail  Incorrect number of RMOD, it should be only one.
    ${all_rmods}  Get Parameters For All  RMOD  connection=${BTS_ID}
    FOR  ${rmod}  IN  @{all_rmods}
      ${tested_rmod_dn}  Run Keyword If  "${rmod['serialNumber']}"=="${CUSTOM_RADIO_UNIT_LIST[0]}"  Set Variable  ${rmod['id']}
      Exit For Loop If  "${rmod['serialNumber']}"=="${CUSTOM_RADIO_UNIT_LIST[0]}"
    END
    Log  ${tested_rmod_dn}
    Set Test Variable  ${TESTED_RMOD_DN}  ${tested_rmod_dn}
    Set Test Variable  ${TESTED_RMOD_SN}  ${CUSTOM_RADIO_UNIT_LIST[0]}
    ${affected_cells_distname}  admin.Get Cell Mapping By Module Id  ${TESTED_RMOD_DN}  connection=${BTS_ID}
    Set Test Variable  ${AFFECTED_CELLS_DISTNAME}  ${affected_cells_distname}
    ${all_cells_distname}  Create All Cells Distname
    Set Test Variable  ${ALL_CELLS_DISTNAME}  ${all_cells_distname}
    ${not_affected_cells_distname}  Create List  @{ALL_CELLS_DISTNAME}
    Set Test Variable  ${NOT_AFFECTED_CELLS_DISTNAME}  ${not_affected_cells_distname}
    Remove Values From List  ${NOT_AFFECTED_CELLS_DISTNAME}  @{AFFECTED_CELLS_DISTNAME}
    ${bts_info}=  Get Bts Info  connection=${BTS_ID}
    ${cablink_list}=  Set Variable  ${bts_info['cables']}
    ${all_bbmods}  Get Parameters For All  BBMOD  connection=${BTS_ID}
    &{bbmod_dn_sn}  Create Dictionary
    FOR  ${bbmod}  IN  @{all_bbmods}
      Set To Dictionary  ${bbmod_dn_sn}  ${bbmod['id']}=${bbmod['serialNumber']}
    END
    &{tested_rmod_connections}  Create Dictionary
    FOR  ${cablink}  IN  @{cablink_list}
      ${firstEndPointId}  Get From Dictionary  ${cablink['firstEndPointId']}  internal
      ${firstEndPointId_dn}	 ${firstEndPointId_port}	 Split String From Right	 ${firstEndPointId} 	/ 	1
      ${secondEndPointId}  Get From Dictionary  ${cablink['secondEndPointId']}  internal
      ${secondEndPointId_dn}	 ${secondEndPointId_port}	 Split String From Right	 ${secondEndPointId} 	/ 	1
      ${secondEndPointId_port}  Remove String  ${secondEndPointId_port}  _IF
      Run Keyword If  "${secondEndPointId_dn}"=="${tested_rmod_dn}"  Set To Dictionary  ${tested_rmod_connections}
      ...  ${bbmod_dn_sn['${firstEndPointId_dn}']}_${firstEndPointId_port}=${CUSTOM_RADIO_UNIT_LIST[0]}_${secondEndPointId_port}
    END
    ${velocity_hw}  Velocity Get Device Name With Serial From Reservation  ${cfg['velocity_reservation_id']}
    ${velocity_connection}  Velocity Get Connection Between Devices From Reservation  ${cfg['velocity_reservation_id']}
    Log  ${velocity_hw}
    Log  ${velocity_connection}
    Log  ${tested_rmod_connections}
    &{tested_connection_velo_hwname}  Create Dictionary
    FOR  ${connection}  IN  @{tested_rmod_connections}
      ${bbmod_sn}  ${bbmod_port}  Split String  ${connection}  _
      ${velo_bbmod_name}  Find Velocity Hardware Name Using Serial Number  ${bbmod_sn}  ${velocity_hw}
      ${rmod_sn}  ${rmod_port}  Split String  ${tested_rmod_connections['${connection}']}  _
      ${velo_rmod_name}  Find Velocity Hardware Name Using Serial Number  ${rmod_sn}  ${velocity_hw}
      Set To Dictionary  ${tested_connection_velo_hwname}  ${velo_bbmod_name}_${bbmod_port}=${velo_rmod_name}_${rmod_port}
    END
    Log  ${tested_connection_velo_hwname}
    &{velocity_tested_connection}  Create Dictionary
    Set Test Variable  ${VELOCITY_TESTED_CONNECTION}  ${velocity_tested_connection}
    FOR  ${connection}  IN  @{tested_connection_velo_hwname}
      ${connection_key}  ${connection_value}  Find Velocity Connection  ${connection}  ${tested_connection_velo_hwname['${connection}']}
      ...  ${velocity_connection}
      Set To Dictionary  ${VELOCITY_TESTED_CONNECTION}  ${connection_key}=${connection_value}
    END
    Log  ${VELOCITY_TESTED_CONNECTION}
    ${items_velo_connection}  Get Dictionary Items  ${VELOCITY_TESTED_CONNECTION}
    ${connection_number}  Get Length  ${items_velo_connection}
    Run Keyword If  "${connection_number}"!="4"  Fail  Incorrect Velocity connection to test -> ${VELOCITY_TESTED_CONNECTION}

Perform Cross Connection Between TheSameRadio
    ${bbmod_first_con}  Get Dictionary Keys  ${VELOCITY_TESTED_CONNECTION}
    ${first_device1_name}  ${first_port1_name}  Split String  ${bbmod_first_con[0]}  _  1
    ${sec_device1_name}  ${sec_port1_name}  Split String  ${VELOCITY_TESTED_CONNECTION['${bbmod_first_con[0]}']}  _  1
    ${first_device2_name}  ${first_port2_name}  Split String  ${bbmod_first_con[1]}  _  1
    ${sec_device2_name}  ${sec_port2_name}  Split String  ${VELOCITY_TESTED_CONNECTION['${bbmod_first_con[1]}']}  _  1
    Log  Removing connection between ${bbmod_first_con[0]} and ${VELOCITY_TESTED_CONNECTION['${bbmod_first_con[0]}']}  console=TRUE
    ${del_connection1_status}  Run Keyword And Return Status  Velocity Delete Connection Between Devices  ${cfg['velocity_reservation_id']}
    ...  ${first_device1_name}  ${first_port1_name}  ${sec_device1_name}  ${sec_port1_name}
    Run Keyword If  ${del_connection1_status}  Log  Completed  console=TRUE
    Run Keyword If  not ${del_connection1_status}  Run Keyword And Continue On Failure  FAIL
    ...  Removing connection between ${bbmod_first_con[0]} and ${VELOCITY_TESTED_CONNECTION['${bbmod_first_con[0]}']} finish with error!!!
    Log  Removing connection between ${bbmod_first_con[1]} and ${VELOCITY_TESTED_CONNECTION['${bbmod_first_con[1]}']}  console=TRUE
    ${del_connection2_status}  Run Keyword And Return Status  Velocity Delete Connection Between Devices  ${cfg['velocity_reservation_id']}
    ...  ${first_device2_name}  ${first_port2_name}  ${sec_device2_name}  ${sec_port2_name}
    Run Keyword If  ${del_connection2_status}  Log  Completed  console=TRUE
    Run Keyword If  not ${del_connection2_status}  Run Keyword And Continue On Failure  FAIL
    ...  Removing connection between ${bbmod_first_con[1]} and ${VELOCITY_TESTED_CONNECTION['${bbmod_first_con[1]}']} finish with error!!!
    ${rmod_status}  Run Keyword And Return Status  Assert  RMOD  ${TESTED_RMOD_DN}  operationalState=regex"(?i)disabled"  timeout=30
    ...  connection=${BTS_ID}
    Run Keyword If  ${rmod_status}  Log  operationalState for RMOD-${TESTED_RMOD_SN} change to disabled.  console=${TRUE}
    ${fault_10_status}  Run Keyword And Return Status  Assert Alarm Active  faultId=10, severity=Critical, serialNo=${TESTED_RMOD_SN}  timeout=20s
    ...  connection=${BTS_ID}
    Run Keyword If  ${fault_10_status}  Log  Expected fault 10 for RMOD-${TESTED_RMOD_SN} appeared.  console=${TRUE}
    Log  Creating connection between ${bbmod_first_con[0]} and ${VELOCITY_TESTED_CONNECTION['${bbmod_first_con[1]}']}  console=TRUE
    ${create_connection1_status}  Run Keyword And Return Status  Velocity Create Connection Between Devices  ${cfg['velocity_reservation_id']}
    ...  ${first_device1_name}  ${first_port1_name}  ${sec_device2_name}  ${sec_port2_name}
    Run Keyword If  ${create_connection1_status}  Log  Completed  console=TRUE
    Run Keyword If  not ${create_connection1_status}  Run Keyword And Continue On Failure  FAIL
    ...  Creating connection between ${bbmod_first_con[0]} and ${VELOCITY_TESTED_CONNECTION['${bbmod_first_con[1]}']} finish with error!!!
    Log  Creating connection between ${bbmod_first_con[1]} and ${VELOCITY_TESTED_CONNECTION['${bbmod_first_con[0]}']}  console=TRUE
    ${create_connection2_status}  Run Keyword And Return Status  Velocity Create Connection Between Devices  ${cfg['velocity_reservation_id']}
    ...  ${first_device2_name}  ${first_port2_name}  ${sec_device1_name}  ${sec_port1_name}
    Run Keyword If  ${create_connection2_status}  Log  Completed  console=TRUE
    Run Keyword If  not ${create_connection2_status}  Run Keyword And Continue On Failure  FAIL
    ...  Creating connection between ${bbmod_first_con[1]} and ${VELOCITY_TESTED_CONNECTION['${bbmod_first_con[0]}']} finish with error!!!

Recovery Optical Connection After Cross-Cabling TheSameRadio
    Log  Recovery Optical Connection After Cross-Cabling TheSameRadio  console=True
    ${bbmod_first_con}  Get Dictionary Keys  ${VELOCITY_TESTED_CONNECTION}
    ${first_device1_name}  ${first_port1_name}  Split String  ${bbmod_first_con[0]}  _  1
    ${sec_device1_name}  ${sec_port1_name}  Split String  ${VELOCITY_TESTED_CONNECTION['${bbmod_first_con[0]}']}  _  1
    ${first_device2_name}  ${first_port2_name}  Split String  ${bbmod_first_con[1]}  _  1
    ${sec_device2_name}  ${sec_port2_name}  Split String  ${VELOCITY_TESTED_CONNECTION['${bbmod_first_con[1]}']}  _  1
    Log  Removing connection between ${bbmod_first_con[0]} and ${VELOCITY_TESTED_CONNECTION['${bbmod_first_con[1]}']}  console=TRUE
    ${first_del_connection_status}  Run Keyword And Return Status  Velocity Delete Connection Between Devices  ${cfg['velocity_reservation_id']}
    ...  ${first_device1_name}  ${first_port1_name}  ${sec_device2_name}  ${sec_port2_name}
    Run Keyword If  ${first_del_connection_status}  Log  Completed  console=TRUE
    Log  Removing connection between ${bbmod_first_con[1]} and ${VELOCITY_TESTED_CONNECTION['${bbmod_first_con[0]}']}  console=TRUE
    ${sec_del_connection_status}  Run Keyword And Return Status  Velocity Delete Connection Between Devices  ${cfg['velocity_reservation_id']}
    ...  ${first_device2_name}  ${first_port2_name}  ${sec_device1_name}  ${sec_port1_name}
    Run Keyword If  ${sec_del_connection_status}  Log  Completed  console=TRUE
    Log  Creating connection between ${bbmod_first_con[0]} and ${VELOCITY_TESTED_CONNECTION['${bbmod_first_con[0]}']}  console=TRUE
    ${first_create_connection_status}  Run Keyword And Return Status  Velocity Create Connection Between Devices  ${cfg['velocity_reservation_id']}
    ...  ${first_device1_name}  ${first_port1_name}  ${sec_device1_name}  ${sec_port1_name}
    Run Keyword If  ${first_create_connection_status}  Log  Completed  console=TRUE
    Log  Creating connection between ${bbmod_first_con[1]} and ${VELOCITY_TESTED_CONNECTION['${bbmod_first_con[1]}']}  console=TRUE
    ${sec_create_connection_status}  Run Keyword And Return Status  Velocity Create Connection Between Devices  ${cfg['velocity_reservation_id']}
    ...  ${first_device2_name}  ${first_port2_name}  ${sec_device2_name}  ${sec_port2_name}
    Run Keyword If  ${sec_create_connection_status}  Log  Completed  console=TRUE

Checking Historical Alarm After Cross-Cabling TheSameRadio
    Clear Allowed Alarms List  connection=${BTS_ID}
    FOR  ${alarm}  IN  @{GLO_ADMIN_ALLOWED_ALARMS}
      Add Allowed Alarm  ${alarm}  connection=${BTS_ID}
    END
    Add Allowed Alarm  faultId=1815  connection=${BTS_ID}
    Add Allowed Alarm  faultId=10, serialNo=${TESTED_RMOD_SN}  connection=${BTS_ID}
    ${alarm_unexpected_status}  Run Keyword And Return Status  Assert No Unexpected Historical Alarms  connection=${BTS_ID}
    Run Keyword If  ${alarm_unexpected_status}  Log  No Unexpected Historical Alarms Visible  console=${TRUE}
    Run Keyword If  not ${alarm_unexpected_status}  Log  Unexpected Historical Alarms Visible  console=${TRUE}
    Run Keyword If  not ${alarm_unexpected_status}  Run Keyword And Continue On Failure  Fail  Unexpected Historical Alarms Visible

Checking Active Alarm After Cross-Cabling TheSameRadio
    Clear Allowed Alarms List  connection=${BTS_ID}
    FOR  ${alarm}  IN  @{GLO_ADMIN_ALLOWED_ALARMS}
      Add Allowed Alarm  ${alarm}  connection=${BTS_ID}
    END
    ${alarm_unexpected_status}  Run Keyword And Return Status  Assert No Unexpected Active Alarms  connection=${BTS_ID}
    Run Keyword If  ${alarm_unexpected_status}  Log  No Unexpected Historical Alarms Visible  console=${TRUE}
    Run Keyword If  not ${alarm_unexpected_status}  Log  Unexpected Historical Alarms Visible  console=${TRUE}
    Run Keyword If  not ${alarm_unexpected_status}  Run Keyword And Continue On Failure  Fail  Unexpected Historical Alarms Visible

Checking availabilityStatus In Infomodel After Cross-Cabling TheSameRadio
    Collect Infomodel Log From Current Session  ${cfg['test_logs_path']}/InfoModel_Cross-Cabling_TheSameRadio.ims2  connection=${BTS_ID}
    ${affected_cells_status}  Checking If availabilityStatus Change For Provided Cells In ims2  ${AFFECTED_CELLS_DISTNAME}
    ...  ims2_log_path=${cfg['test_logs_path']}/InfoModel_Cross-Cabling_TheSameRadio.ims2
    ${final_affected_cells_status}  Run Keyword And Return Status  Dictionary Should Not Contain Value  ${affected_cells_status}  FAIL
    Run Keyword And Continue On Failure  Run Keyword If  not ${final_affected_cells_status}
    ...  Fail  FAIL!!! Affected Cells don't changed availabilityStatus after changed optical connections.
    ${not_affected_cells_status}  Checking If availabilityStatus Change For Provided Cells In ims2  ${NOT_AFFECTED_CELLS_DISTNAME}
    ...  ims2_log_path=${cfg['test_logs_path']}/InfoModel_Cross-Cabling_TheSameRadio.ims2
    ${final_not_affected_cells_status}  Run Keyword And Return Status  Dictionary Should Not Contain Value  ${not_affected_cells_status}  PASS
    Run Keyword And Continue On Failure  Run Keyword If  not ${final_not_affected_cells_status}
    ...  Fail  FAIL!!! Not affected Cells changed availabilityStatus after changed optical connections.


