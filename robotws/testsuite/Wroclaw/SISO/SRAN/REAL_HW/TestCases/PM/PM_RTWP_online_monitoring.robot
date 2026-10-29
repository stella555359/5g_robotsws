*** Settings ***
Documentation
  ...  AUTHOR-przemyslaw.kempa@nokia.com  MAINTAINER-przemyslaw.kempa@nokia.com
  ...  [CASE LINK]: https://rep-portal.ext.net.nokia.com/details/qc-case/
  ...
  ...  *****************
  ...  Basic information
  ...  *****************
  ...  Antenna Line Online Monitoring provide a way to monitor the antenna line through WebEM
  ...  by updating the interval of reading Rx RTWP antenna measurements.
  ...  RTWP - Received Total Wideband Power - indicates signal power in uplink with interferences for LTE (also NR and WCDMA) technology.
  ...  The purpose of the test is to check if Antenna Line Online Monitoring provides correct values of RTWP for NR or LTE cells.
  ...
  ...    +-----------------------------+-------+-------------------------------------------------------------------------------+
  ...    | Parameters                  | Man.  | Description                                                                   |
  ...    +=============================+=======+===============================================================================+
  ...    | RTWP_MEASURING_TIME         | No    | RTWP measuring time in seconds, default value -> 60                           |
  ...    +-----------------------------+-------+-------------------------------------------------------------------------------+
  ...    | RTWP_min                    | No    | min RTWP value default value -> -110                                          |
  ...    +-----------------------------+-------+-------------------------------------------------------------------------------+
  ...    | RTWP_max                    | No    | max RTWP value default value -> -85                                           |
  ...    +-----------------------------+-------+-------------------------------------------------------------------------------+
  ...    | RMOD_SN_LIST                | No    | List of serial number RMODs to test if list is empty all will be tested       |
  ...    +-----------------------------+-------+-------------------------------------------------------------------------------+
  ...
  ...
  ...  ******************
  ...  History of changes
  ...  ******************
  ...
  ...

Resource  ./../../Resources/Setup/setup_and_teardown.robot
Resource  ./../../Resources/Robot/PM.robot

*** Variables ***
${RTWP_MEASURING_TIME}  60
${RTWP_min}             -110
${RTWP_max}             -85
@{RMOD_SN_LIST}

*** Keywords ***
TC__PM_RTWP_online_monitoring
    Set Tags  AUTHOR-przemyslaw.kempa@nokia.com  MAINTAINER-przemyslaw.kempa@nokia.com
    Common Test Setup
    Logging With Timestamp
    ...  message=PM_RTWP_online_monitoring will be executed
    ...  style=ONGOING
    Step 1: Preparing Variables For RTWP Online Monitoring
    Step 2: Check RTWP in IDLE state
    Step 3: Check RTWP RMOD Lock
    Step 4: Check RTWP RMOD UnLock
    Step 5: Check RTWP When LTE&NR Cell Blocked
    Step 6: Check RTWP When LTE&NR Cell Unblocked
    [Teardown]  Common Test Teardown


Step 1: Preparing Variables For RTWP Online Monitoring
    [Documentation]
    ...  Description:
    ...  Preaparing Variable to perform test
    ...
    ...  Author: przemyslaw.kempa@nokia.com
    ...  Maintainer: przemyslaw.kempa@nokia.com

    Logging With Timestamp
    ...  message=Step 1: Preparing Variables For RTWP Online Monitoring
    ...  style=STEP
    ...  frame=${TRUE}
    Set Test Variable  ${BTS_ID}  ${CFG['primary_node_bts_id']}
    IF  "@{RMOD_SN_LIST}"=="@{EMPTY}"
      Set Test Variable  ${RMOD_SN_LIST}  ${CFG['NODES']['${BTS_ID}']['scf_hw_fr_list']}
      ${antl_r_list}  Get ANTL_R distNames list Of Tested RMODS
    ELSE
      List Should Contain Sub List  ${CFG['NODES']['${BTS_ID}']['scf_hw_fr_list']}  ${RMOD_SN_LIST}  msg=Provided RMOD SN list is NOT valid.
      ${antl_r_list}  Get ANTL_R distNames list Of Tested RMODS
    END
    Set Test Variable  ${ATL_R_LIST}  ${antl_r_list}
    Logging With Timestamp
    ...  message=Collect Antenaline list finished successfully !!!
    @{no_rtwp_cells_list_rmods_locked}  Create List
    @{no_rtwp_cells_list_cells_blocked}  Create List
    @{no_rtwp_cells_dn_list_cells_blocked}  Create List
    ${iot_cells}  Get IoT IB, GB nrGB LNCEL ids
    FOR  ${rmod_sn}  IN  @{RMOD_SN_LIST}
      ${lncels_id}  Get From Dictionary  ${cfg['RF_INFO']['${rmod_sn}']['LNCEL']}  scf_cellid_primary
      IF  "${lncels_id}"!="None"
      &{lncel_band_dict}  Create Dictionary
        FOR  ${lncel_id}  IN  @{lncels_id}
          ${not_iot_cell}  Run Keyword And Return Status  List Should Not Contain Value  ${iot_cells}  LNCEL-${lncel_id}
          IF  ${not_iot_cell}
            Append To List  ${no_rtwp_cells_list_rmods_locked}  LNCEL-${lncel_id}
            ${band_number}  Get From Dictionary  ${CFG['NODES']['${BTS_ID}']['LNCEL']['${lncel_id}']}  scf_band
            ${band_number}  Convert To String  ${band_number}
            ${lte_band_key_exist}  Run Keyword And Return Status
            ...  Dictionary Should Not Contain Key  ${lncel_band_dict}  ${band_number}
            IF  ${lte_band_key_exist}
              Set To Dictionary  ${lncel_band_dict}  ${band_number}=${CFG['NODES']['${BTS_ID}']['LNCEL']['${lncel_id}']['scf_dist_name']}
              Append To List  ${no_rtwp_cells_list_cells_blocked}  LNCEL-${lncel_id}
              Append To List  ${no_rtwp_cells_dn_list_cells_blocked}  ${CFG['NODES']['${BTS_ID}']['LNCEL']['${lncel_id}']['scf_dist_name']}
            END
          END
        END
      END
      ${nrcels_id}  Get From Dictionary  ${cfg['RF_INFO']['${rmod_sn}']['NRCEL']}  scf_cellid_primary
      IF  "${nrcels_id}"!="None"
      &{nrcel_band_dict}  Create Dictionary
        FOR  ${nrcel_id}  IN  @{nrcels_id}
          Append To List  ${no_rtwp_cells_list_rmods_locked}  NRCELL-${nrcel_id}
          ${band_number}  Get From Dictionary  ${CFG['NODES']['${BTS_ID}']['NRCEL']['${nrcel_id}']}  scf_band
          ${band_number}  Convert To String  ${band_number}
          ${nr_band_key_exist}  Run Keyword And Return Status
          ...  Dictionary Should Not Contain Key  ${nrcel_band_dict}  ${band_number}
          IF  ${nr_band_key_exist}
            Set To Dictionary  ${nrcel_band_dict}  ${band_number}=${CFG['NODES']['${BTS_ID}']['NRCEL']['${nrcel_id}']['scf_dist_name']}
            Append To List  ${no_rtwp_cells_list_cells_blocked}  NRCELL-${nrcel_id}
            Append To List  ${no_rtwp_cells_dn_list_cells_blocked}  ${CFG['NODES']['${BTS_ID}']['NRCEL']['${nrcel_id}']['scf_dist_name']}
          END
        END
      END
    END
    Append To List  ${no_rtwp_cells_list_rmods_locked}  @{iot_cells}
    Append To List  ${no_rtwp_cells_list_cells_blocked}  @{iot_cells}
    Set Test Variable  ${IOT_CELLS}  ${iot_cells}
    Set Test Variable  ${NO_RTWP_CELLS_LIST_RMODS_LOCKED}  ${no_rtwp_cells_list_rmods_locked}
    Set Test Variable  ${NO_RTWP_CELLS_LIST_CELLS_BLOCKED}  ${no_rtwp_cells_list_cells_blocked}
    Set Test Variable  ${NO_RTWP_CELLS_DN_LIST_CELLS_BLOCKED}  ${no_rtwp_cells_dn_list_cells_blocked}

Step 2: Check RTWP in IDLE state
    [Documentation]
    ...  Description:
    ...  Collect Antenaline monitoring and check proper RTWP value
    ...
    ...  Author: przemyslaw.kempa@nokia.com
    ...  Maintainer: przemyslaw.kempa@nokia.com

    Logging With Timestamp
    ...  message=Step 2: Check RTWP in IDLE state
    ...  style=STEP
    ...  frame=${TRUE}
    Collect And Check RTWP  log_path_name=${cfg.test_logs_path}/rtwp_idle.json  excluded_cells=${IOT_CELLS}

Step 3: Check RTWP RMOD Lock
    [Documentation]
    ...  Description:
    ...  Start collecting Antenaline monitoring, lock RMODs collect Antenaline monitoring and check proper RTWP value
    ...  Unlock RMODs
    ...
    ...  Author: przemyslaw.kempa@nokia.com
    ...  Maintainer: przemyslaw.kempa@nokia.com

    Logging With Timestamp
    ...  message=Step 3: Check RTWP RMOD Lock
    ...  style=STEP
    ...  frame=${TRUE}
    Collect And Check RTWP
    ...  log_path_name=${cfg.test_logs_path}/rtwp_rmod_lock.json
    ...  excluded_cells=${NO_RTWP_CELLS_LIST_RMODS_LOCKED}
    ...  rmod_lock=${TRUE}
    Sleep  15s  message=Stabilizing RMOD before RTWP check.

Step 4: Check RTWP RMOD UnLock
    [Documentation]
    ...  Description:
    ...  Collect Antenaline monitoring after RMOD unlock and check proper RTWP value
    ...
    ...  Author: przemyslaw.kempa@nokia.com
    ...  Maintainer: przemyslaw.kempa@nokia.com

    Logging With Timestamp
    ...  message=Step 4: Check RTWP RMOD UnLock
    ...  style=STEP
    ...  frame=${TRUE}
    Collect And Check RTWP  log_path_name=${cfg.test_logs_path}/rtwp_rmod_unlock.json  excluded_cells=${IOT_CELLS}

Step 5: Check RTWP When LTE&NR Cell Blocked
    [Documentation]
    ...  Description:
    ...  Block cells -> one cels from each band on RMOD. Collect Antenaline monitoring and check proper RTWP value.
    ...  Unblock cells
    ...
    ...  Author: przemyslaw.kempa@nokia.com
    ...  Maintainer: przemyslaw.kempa@nokia.com

    Logging With Timestamp
    ...  message=Step 5: Check RTWP When LTE&NR Cell Blocked
    ...  style=STEP
    ...  frame=${TRUE}
    FOR  ${cell}  IN  @{NO_RTWP_CELLS_DN_LIST_CELLS_BLOCKED}
      ${block_status}=  Run Keyword And Return Status  admin.Block Cell
      ...  dist_name=${cell}
      ...  timeout=300
      ...  connection=${BTS_ID}
      IF  ${block_status}
        Logging With Timestamp
        ...  message=Cell ${cell} blocked succesfully
        ...  style=DONE
      ELSE
        Logging With Timestamp
        ...  message=Cell ${cell} blocked finish with ERROR !!!
        ...  style=FAIL
        Run Keyword And Continue On Failure  Fail  Cell ${cell} blocked finish with ERROR !!!
      END
      Run Keyword And Continue On Failure  FM Await For Fault
      ...  fault_attr=faultId=49, severity=Critical, alarmingObjectIds[0].configuration=regex"^${cell}$"
      ...  node_id=${BTS_ID}
      ...  alarm_resource=${FAULT_49}
      ...  timeout=30
    END
    Collect And Check RTWP  log_path_name=${cfg.test_logs_path}/rtwp_cell_blocked.json  excluded_cells=${NO_RTWP_CELLS_LIST_CELLS_BLOCKED}
    FOR  ${cell}  IN  @{NO_RTWP_CELLS_DN_LIST_CELLS_BLOCKED}
      ${block_status}=  Run Keyword And Return Status  admin.Unblock Cell
      ...  dist_name=${cell}
      ...  timeout=300
      ...  connection=${BTS_ID}
      IF  ${block_status}
        Logging With Timestamp
        ...  message=Cell ${cell} unblocked succesfully
        ...  style=DONE
      ELSE
        Logging With Timestamp
        ...  message=Cell ${cell} unblocked finish with ERROR !!!
        ...  style=FAIL
        Run Keyword And Continue On Failure  Fail  Cell ${cell} unblocked finish with ERROR !!!
      END
      Run Keyword And Continue On Failure  FM Await For Fault Cleared
      ...  fault_attr=faultId=49, severity=Critical, alarmingObjectIds[0].configuration=${cell}
      ...  timeout=120
      ...  node_id=${BTS_ID}
    END
    STATE Verify Multi Node State

Step 6: Check RTWP When LTE&NR Cell Unblocked
    [Documentation]
    ...  Description:
    ...  Collect Antenaline monitoring after cells unblock and check proper RTWP value
    ...
    ...  Author: przemyslaw.kempa@nokia.com
    ...  Maintainer: przemyslaw.kempa@nokia.com

    Logging With Timestamp
    ...  message=Step 6: Check RTWP When LTE&NR Cell Unblocked
    ...  style=STEP
    ...  frame=${TRUE}
    Collect And Check RTWP  log_path_name=${cfg.test_logs_path}/rtwp_cell_unblocked.json  excluded_cells=${IOT_CELLS}


Get IoT IB, GB nrGB LNCEL ids
    ${L_cells_list}  Get Cells Info  lte  connection=${BTS_ID}
    ${iot_cell_id_list}  Create list
    FOR  ${cell}  IN  @{L_cells_list}
      ${is_iot}  Run Keyword And Return Status  Should be equal as strings  ${cell["technology"]}  NB-IoT-FDD
      ${cell_id}  Fetch From Right  ${cell["id"]["configuration"]}  /
      Run Keyword If  ${is_iot}  Append To List  ${iot_cell_id_list}  ${cell_id}
    END
    [Return]  ${iot_cell_id_list}

Get ANTL_R distNames list Of Tested RMODS
    ${tested_antl_r_list}  Create List
    ${rm_info}  admin.Get FRM  connection=${BTS_ID}
    ${rm_antenaUsageInfo_truncated}  Evaluate
    ...  [single_rm_info["antenaUsageInfo"] for single_rm_info in ${rm_info} if single_rm_info["serialNumber"] in ${RMOD_SN_LIST}]
    FOR  ${single_rm_info}  IN  @{rm_antenaUsageInfo_truncated}
      ${rm_antl_r_list}  Evaluate  [ant["id"]["internal"] for ant in ${single_rm_info}]
      Append To List  ${tested_antl_r_list}  @{rm_antl_r_list}
    END
    [Return]  ${tested_antl_r_list}

Collect And Check RTWP
    [Arguments]  ${log_path_name}=${cfg.test_logs_path}/output.json  ${excluded_cells}=${EMPTY}  ${rmod_lock}=${FALSE}
    Logging With Timestamp
    ...  message=Start ANTL Online Monitoring !!!
    admin.Start ANTL Online Monitoring  ${ATL_R_LIST}  connection=${BTS_ID}
    IF  ${rmod_lock}
      FOR  ${rmod_sn}  IN  @{RMOD_SN_LIST}
        Logging With Timestamp
        ...  message=RMOD ${rmod_sn} locking started ...
        ...  style=ONGOING
        ${lock_status}=  Run Keyword And Return Status
        ...  Run Keyword And Continue On Failure
        ...  admin.Lock
        ...  dist_name=${cfg['RF_INFO']['${rmod_sn}']['scf_dist_name_primary']}
        ...  timeout=120
        ...  alias=${BTS_ID}
        IF  ${lock_status}
          Logging With Timestamp
          ...  message=RMOD ${rmod_sn} locked succesfully
          ...  style=DONE
        ELSE
          Logging With Timestamp
          ...  message=RMOD ${rmod_sn} locked finish with ERROR !!!
          ...  style=FAIL
          Run Keyword And Continue On Failure  Fail  RMOD ${rmod_sn} locked finish with ERROR !!!
        END
      END
    END
    Logging With Timestamp
    ...  message=Wait ${RTWP_MEASURING_TIME}s for collecting RTWP.
    Sleep  ${RTWP_MEASURING_TIME}
    admin.Stop ANTL Online Monitoring  ${log_path_name}  connection=${BTS_ID}
    Logging With Timestamp
    ...  message=Stop ANTL Online Monitoring !!!
    IF  ${rmod_lock}
      FOR  ${rmod_sn}  IN  @{RMOD_SN_LIST}
        Logging With Timestamp
        ...  message=RMOD ${rmod_sn} unlocking started ...
        ...  style=ONGOING
        ${lock_status}=  Run Keyword And Return Status
        ...  Run Keyword And Continue On Failure
        ...  admin.Unlock
        ...  dist_name=${cfg['RF_INFO']['${rmod_sn}']['scf_dist_name_primary']}
        ...  timeout=120
        ...  alias=${BTS_ID}
        IF  ${lock_status}
          Logging With Timestamp
          ...  message=RMOD ${rmod_sn} unlocked succesfully
          ...  style=DONE
        ELSE
          Logging With Timestamp
          ...  message=RMOD ${rmod_sn} unlocked finish with ERROR !!!
          ...  style=FAIL
          Run Keyword And Continue On Failure  Fail  RMOD ${rmod_sn} unlocked finish with ERROR !!!
        END
      END
      Wait Until Keyword Succeeds  3x  60  STATE Verify Multi Node State
    END
    ${json}  OperatingSystem.Get File  ${log_path_name}  encoding_errors=replace
    ${json}  Evaluate  json.loads('''${json}''')  json
    ${is_rtwp}  Run Keyword and return status  Dictionary Should Contain Key  ${json}  RTWP
    IF  ${is_rtwp}
      Logging With Timestamp
      ...  message=RTWP measurments visible in collected file !!!
      ${rtwp}  Get from Dictionary  ${json}  RTWP
    ELSE
      Logging With Timestamp
      ...  message=RTWP measurments NOT visible in collected file !!!
      ...  style=ERROR
      Fail  RTWP measurments NOT visible in collected file -> ${log_path_name}
    END
    ${rtwp_dict}  Create Dictionary
    ${no_rtwp_dict}  Create Dictionary
    FOR  ${rmod}  IN  @{rtwp}
      ${rmod_key}  Get From Dictionary  ${rmod}  name
      FOR  ${antl}  IN  @{rmod["antennaLines"]}
        ${antl_key}  Get From Dictionary  ${antl}  name
        ${cell_dict}  Create Dictionary
        ${excluded_cell_dict}  Create Dictionary
        ${cell_keys}  Get Dictionary Keys  ${antl["measureDatas"]}
        FOR  ${cell_key}  IN  @{cell_keys}
          ${cell_key_name}  Fetch From Left  ${cell_key}  (
          ${excluded_cells_status}  Run Keyword And Return Status  List Should Contain Value  ${excluded_cells}  ${cell_key_name}
          ${values_list}  Get Dictionary Values  ${antl["measureDatas"]["${cell_key}"]}
          IF  ${excluded_cells_status}
            IF  ${rmod_lock}
              ${time}  Convert Time  ${RTWP_MEASURING_TIME}
              ${intervals}  Evaluate  int(${time}/10)
              ${values_list}  Set Variable  @{values_list}[-${intervals}:]
            END
            Set To Dictionary  ${excluded_cell_dict}  ${rmod_key}_${antl_key}_${cell_key}=${values_list}
          ELSE
            Set To Dictionary  ${cell_dict}  ${rmod_key}_${antl_key}_${cell_key}=${values_list}
          END
        END
        ${cell_keys2}  Get Dictionary Keys  ${cell_dict}
        FOR  ${cell_key2}  IN  @{cell_keys2}
          Set To Dictionary  ${rtwp_dict}  ${cell_key2}=${cell_dict["${cell_key2}"]}
        END
        ${excluded_cell_keys2}  Get Dictionary Keys  ${excluded_cell_dict}
        FOR  ${excluded_cell_key2}  IN  @{excluded_cell_keys2}
          Set To Dictionary  ${no_rtwp_dict}  ${excluded_cell_key2}=${excluded_cell_dict["${excluded_cell_key2}"]}
        END
      END
    END
    Logging With Timestamp
    ...  message=Checking if RTWP measurments are in range.
    ...  style=INFO
    ${rtwp_keys}  Get Dictionary Keys  ${rtwp_dict}
    FOR  ${rtwp_key}  IN  @{rtwp_keys}
      FOR  ${rtwp_value}  IN  @{rtwp_dict["${rtwp_key}"]}
        ${rtwp_value}  Convert To Number  ${rtwp_value}
        ${rtwp_result}  Evaluate  ${RTWP_min} <= ${rtwp_value} <= ${RTWP_max}
        IF  ${rtwp_result}
          Logging With Timestamp
          ...  message=RTWP value for ${rtwp_key} is in range -> ${RTWP_min} <= ${rtwp_value} <= ${RTWP_max} !
          ...  style=PASS
        ELSE
          Logging With Timestamp
          ...  message=RTWP value for ${rtwp_key} is out of range -> ${RTWP_min} <= ${rtwp_value} <= ${RTWP_max} !
          ...  style=ERROR
          Run Keyword And Continue On Failure  Fail  RTWP value for ${rtwp_key} is out of range -> ${RTWP_min} <= ${rtwp_value} <= ${RTWP_max} !
        END
      END
    END
    Logging With Timestamp
    ...  message=Checking if RTWP measurments NOT visible for exluded cells.
    ...  style=INFO
    ${no_rtwp_keys}  Get Dictionary Keys  ${no_rtwp_dict}
    FOR  ${no_rtwp_key}  IN  @{no_rtwp_keys}
      FOR  ${no_rtwp_value}  IN  @{no_rtwp_dict["${no_rtwp_key}"]}
        IF  "${no_rtwp_value}"=="-"
          Logging With Timestamp
          ...  message=RTWP for ${no_rtwp_key} has expected no value -> ${no_rtwp_value} !
          ...  style=PASS
        ELSE
          Logging With Timestamp
          ...  message=RTWP for ${no_rtwp_key} has NOT expected value -> ${no_rtwp_value} insted of "-" !
          ...  style=ERROR
          Run Keyword And Continue On Failure  Fail  RTWP for ${no_rtwp_key} has NOT expected value -> ${no_rtwp_value} insted of "-" !
        END
      END
    END