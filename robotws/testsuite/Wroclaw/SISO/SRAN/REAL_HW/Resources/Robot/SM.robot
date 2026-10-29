*** Settings ***
Documentation  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS

Library           taf.sbts.oam.coam.admin  WITH NAME  admin
#Library           Telnet
Library           taf.rnc.oms.nwi3  WITH NAME  nwi3
Library           hran_bsc

#Resource          testsuite/Wroclaw/SISO/SRAN/REAL_HW/robotlte_legacy/SiSo_L3_Call.robot
Resource          testsuite/Wroclaw/SISO/SRAN/REAL_HW/Resources/SiSo_L3_call.robot

*** Variables ***
${cells_blocked_states}=       operationalState=regex"(?i)Disabled", availabilityStatus=regex"(?i)off\\s?line", blockingState=regex"(?i)Blocked"
${cells_unblocked_states}=     operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked"
${cells_unchanged_states}=     operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked"
${cells_locked_states}=  SEPARATOR=
...  operationalState=regex"(?i)Disabled", availabilityStatus=regex"(?i)off\\s?line",
...  blockingState=regex"(?i)Unblocked", administrativeState=regex"(?i)Locked"
${cells_wcdma_locked_states}=  SEPARATOR=
...  operationalState=regex"(?i)Disabled", availabilityStatus=regex"(?i)off\\s?line",
...  blockingState=regex"(?i)Unblocked"
${cells_unlocked_states}=      operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked", administrativeState=regex"(?i)Unlocked"


*** Keywords ***
SM Block Cells On Chosen Band
    [Arguments]  ${band_name}  ${all_cells_without_guardband}  ${node_cells_dict}
    [Documentation]
    ...  KW for blocking cells on consecutive bands chosen by the tester or found on the test line

    ...    +-----------------------------+-------+-------------------------------------------------------------------------------+
    ...    | Argument                    | Man.  | Description                                                                   |
    ...    +=============================+=======+===============================================================================+
    ...    | bts_id                      | Yes   | BTS_ID used as alias                                                          |
    ...    +-----------------------------+-------+-------------------------------------------------------------------------------+
    ...    | band                        | Yes   | A band number which should be blocked                                         |
    ...    +-----------------------------+-------+-------------------------------------------------------------------------------+
    ...    | all_cells_without_guardband | Yes   | A list of cells whose states should be checked                                |
    ...    +-----------------------------+-------+-------------------------------------------------------------------------------+
    ...    | node_cells_dict             | Yes   | A dictionary node=cells required for GSM cellsm                               |
    ...    +-----------------------------+-------+-------------------------------------------------------------------------------+

    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    Logging With Timestamp
    ...  message=Blocking cells on a single band ${band_name} has been started.
    ...  logs_dir=${CFG.suite_logs_path}
    ${name}  ${band}  Split String  ${band_name}  separator=_  max_split=1
    ${cellson_band}=  Catenate  SEPARATOR=_  cellson  ${band}
    @{all_cells_without_guardband_copy}=  Copy List  ${all_cells_without_guardband}
    @{block_band_statuses}=  Create List

    ${not_empty}=  Run Keyword And Return Status  Should Not Be Empty  ${cellson_band}
    Run Keyword If  ${not_empty}==False  Logging With Timestamp
    ...  message=List ${cellson_band} empty, check configuration.
    ...  logs_dir=${CFG.suite_logs_path}
    ...  style=FAIL
    ...  AND  Fail  List ${cellson_band} empty, check configuration.

    FOR  ${cell}  IN  @{${cellson_band}}
      Log  Block cell ${cell}  console=${True}
      Continue For Loop If  '${cell}'=='None'
      ${bts_id}  ${bts_name}  ${class}  ${global_cell_id}  ${cell_r_number}=  Extract Variables From Cell Dist Name  ${cell}  ${node_cells_dict}
      ${block_status}=  Run Keyword And Return Status  admin.Block Cell
      ...  dist_name=${cell}
      ...  timeout=300
      ...  connection=${bts_id}
      Append To List  ${block_band_statuses}  ${block_status}
      Run Keyword If  ${block_status}==True
      ...  Log  Cell ${cell} has been blocked successfully.
      ...  ELSE  Fail  Cell ${cell} could not be blocked. Please, investigate the issue.
      Remove Values From List  ${all_cells_without_guardband_copy}  ${cell}
    END
    ${block_band_summary}=  Run Keyword And Return Status  List Should Not Contain Value  ${block_band_statuses}  False
    Run Keyword If  ${block_band_summary}==True  Log  Cells on band ${band} have been blocked successfully.
    ...  ELSE  Fail  Cells on band ${band} could not be blocked. Please, investigate the issue.
    Sleep  15s
    Logging With Timestamp
    ...  message=Blocking cells on single band finished - band ${band}
    ...  style=DONE
    [Return]  ${all_cells_without_guardband_copy}

SM Unblock Cells On Chosen Band
    [Arguments]  ${bts_id}  ${band_name}  ${node_cells_dict}
    Logging With Timestamp
    ...  message=Unblocking cells on a single band has been started.
    ...  logs_dir=${CFG.suite_logs_path}
    ${name}  ${band}  Split String  ${band_name}  separator=_  max_split=1
    ${cellson_band}=  Catenate  SEPARATOR=_  cellson  ${band}
    FOR  ${cell}  IN  @{${cellson_band}}
      Log  Unblock cell ${cell}  console=${True}
      Continue For Loop If  '${cell}'=='None'
      ${bts_id}  ${bts_name}  ${class}  ${global_cell_id}  ${cell_r_number}=  Extract Variables From Cell Dist Name  ${cell}  ${node_cells_dict}
      ${unblock_status}=  Run Keyword And Return Status  admin.Unblock Cell  dist_name=${cell}  timeout=300  connection=${bts_id}
      Run Keyword If  ${unblock_status}==True  Log  Cell ${cell} has been unblocked successfully.
      ...  ELSE  Fail  Cell ${cell} could not be unblocked. Please, investigate the issue.
    END
    Sleep  15s
    Logging With Timestamp
    ...  message=Unlocking cells on a single band has been finished.
    ...  style=DONE

SM Verify Whether Correct Cells Blocked
    [Arguments]  ${bts_id}  ${cells}  ${rmods_to_be_tested}  ${node_cells_dict}  ${states}=${cells_blocked_states}
    [Documentation]
    ...  KW for checking 'cells' states after procedure of blocking has been run
    ...  If guardband cells are deployed on test line 'all_cells_on_tl_copy' should be a list without guardband cells
    ...
    ...    +------------------------+-------+-----------------------------------------------------------------------------------------+
    ...    | Argument               | Man.  | Description                                                                             |
    ...    +========================+=======+=========================================================================================+
    ...    | bts_id                | Yes   | BTS_ID used as alias                                                                    |
    ...    +------------------------+-------+-----------------------------------------------------------------------------------------+
    ...    | cells                  | Yes   | A list of cells whose states should be checked                                          |
    ...    +------------------------+-------+-----------------------------------------------------------------------------------------+
    ...    | rmods_to_be_tested     | No    | A list of rmods to have power tested                                                    |
    ...    +------------------------+-------+-----------------------------------------------------------------------------------------+
    ...    | states                 | No    | Expected states as string, e.g.,                                                        |
    ...    |                        |       | "administrativeState=Unlocked, operationalState=Enabled"                                |
    ...    +------------------------+-------+--------------------------------------------------------------------------- -------------+

    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    Logging With Timestamp
    ...  message=Start verifying whether correct cells are blocked
    ...  logs_dir=${CFG.suite_logs_path}
    @{all_blocked_cells}=  Create List
    @{all_blocked_statuses}=  Create List
    @{all_fid49_statuses}=  Create List
    FOR  ${cell}  IN  @{cells}
      ${bts_id}  ${bts_name}  ${class}  ${global_cell_id}  ${cell_r_number}=  Extract Variables From Cell Dist Name  ${cell}  ${node_cells_dict}
      ${block_status}=  Run Keyword And Return Status
      ...  admin.Assert
      ...  class_name=${class}
      ...  id=${cell}
      ...  parameters=${states}
      ...  timeout=20
      ...  connection=${bts_id}
      Append To List  ${all_blocked_statuses}  ${block_status}
      ${rat}  Set Variable If  '${class}'=='GNCEL'  gsm
      ...  '${class}'=='WNCEL'  wcdma
      ...  '${class}'=='LNCEL'  lte
      ...  '${class}'=='NRCEL'  nr
      ${cell_config_dn}=  Set Variable  ${node_rat_cells_dict['${bts_id}']['${rat}']['${cell}']['cell_config_dn']}
      ${fault49_status}=  Run Keyword And Return Status  admin.Assert Alarm Active
#      ...  parameters=faultId=49, alarmingObjectIds[0].internal=${cell}, severity=Critical, alarmId=7102
      ...  parameters=faultId=49, alarmingObjectIds[0].configuration=${cell_config_dn}, severity=Critical, alarmId=7102
      ...  timeout=60
      ...  connection=${bts_id}
      Append To List  ${all_fid49_statuses}  ${fault49_status}
      Run Keyword If  '${block_status}'=='True'
      ...  Log  Cell ${cell} blocked  console=True
      ...  ELSE  Fail  Cell ${cell} NOT blocked
      Run Keyword If  '${fault49_status}'=='True'
      ...  Log  Fault 49 is active for ${cell}  console=True
      ...  ELSE  Fail  Fault 49 is NOT active for ${cell}
      ${type}=  Evaluate  type($cell)
      ${cell}=  Run Keyword If  "${type}"=="<class 'str'>"  Create List  ${cell}
      ${all_blocked_cells}=  Combine Lists  ${all_blocked_cells}  ${cell}
    END
    ${block_pass}=  Run Keyword And Return Status  List Should Not Contain Value  ${all_blocked_statuses}  FAIL
    ${fid49_pass}=  Run Keyword And Return Status  List Should Not Contain Value  ${all_fid49_statuses}  FAIL
    Run Keyword If  ${block_pass}==True  Run Keywords
    ...  Add Allowed Alarm  faultId=49, severity=Critical, alarmId=7102  connection=${bts_id}  AND
    ...  Logging With Timestamp
    ...  message=All cells have been blocked successfully.
    ...  ELSE  Fail  Some cells have not been blocked. Please, investigate the issue.
    ...  style=DONE
    Run Keyword If  ${fid49_pass}==True
    ...  Logging With Timestamp
    ...  message=All cells have fault 49 active.
    ...  ELSE  Fail  Some cells do not have fault 49 active. Please, investigate the issue.
    ...  style=DONE
    Logging With Timestamp
    ...  message=Verifying Power Of The Carriers.
    ...  style=ONGOING
    ${no_power_check_to_test}=  Run Keyword And Return Status
    ...  List Should Contain Value  ${RMODS_CHOSEN_FOR_POWER}  no_power_check
    Run Keyword If  ${no_power_check_to_test}==False  SM Verify Power Of The Carriers  ${rmods_to_be_tested}
    Logging With Timestamp
    ...  message=Verifying Power Of The Carriers finished.
    ...  style=DONE
    Logging With Timestamp
    ...  message=KPI#17a calculation start.
    ...  style=ONGOING
    FOR  ${bts_id}  IN  @{CFG.active_bts_list}
      admin.Collect Infomodel Log From Current Session
      ...  connection=${bts_id}
      ...  target_file_name=${TEST_LOGS_PATH}BTSFiles/${bts_id}/ims_kpi17a.ims2
      ...  timeout=120
    END
    FOR  ${cell}  IN  @{cells}
      ${bts_id}  ${bts_name}  ${class}  ${global_cell_id}  ${cell_r_number}=  Extract Variables From Cell Dist Name  ${cell}  ${node_cells_dict}
      ${kpi17a}=  Run Keyword And Continue On Failure  kpi.Calculate Kpi17a
      ...  ims_file_path=${TEST_LOGS_PATH}BTSFiles/${bts_id}/ims_kpi17a.ims2
      ...  dist_name=${cell}
      ${kpi_collected}=    Run Keyword If  '${class}'!='GNCEL' and '${class}'!='WNCEL'
      ...  Set Variable  True
    END
    ${status}=  Run Keyword And Return Status  Variable Should Exist  ${kpi_collected}
    Run Keyword If  ${status}==True  Run Keyword If  '${kpi_collected}'=='True'  Evaluate Deltas Of KPIs  kpi17a  80.1
    kpi.Clear Results
    Logging With Timestamp
    ...  message=KPI 17a calculation finished.
    ...  style=DONE
    [Return]  ${all_blocked_cells}

SM Verify Whether Correct Cells Unchanged
    [Arguments]  ${bts_id}  ${all_unchanged_cells}  ${rmods_to_be_tested}  ${node_cells_dict}  ${states}=${cells_unchanged_states}
    [Documentation]
    ...  KW for checking 'cells' states after procedure of blocking has been run
    ...  If guardband cells are deployed on test line 'all_cells_on_tl_copy' should be a list without guardband cells
    ...
    ...    +------------------------+-------+-----------------------------------------------------------------------------------------+
    ...    | Argument               | Man.  | Description                                                                             |
    ...    +========================+=======+=========================================================================================+
    ...    | bts_id                | Yes   | BTS_ID used as alias                                                                    |
    ...    +------------------------+-------+-----------------------------------------------------------------------------------------+
    ...    | all_unchanged_cells    | Yes   | A list of cells whose states should be checked                                          |
    ...    +------------------------+-------+-----------------------------------------------------------------------------------------+
    ...    | states                 | No    | Expected states as string, e.g.,                                                        |
    ...    |                        |       | "administrativeState=Unlocked, operationalState=Enabled"                                |
    ...    +------------------------+-------+--------------------------------------------------------------------------- -------------+

    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    FOR  ${cell}  IN  @{all_unchanged_cells}
      ${bts_id}  ${bts_name}  ${class}  ${global_cell_id}  ${cell_r_number}=  Extract Variables From Cell Dist Name  ${cell}  ${node_cells_dict}
      ${status}  ${result}=  Run Keyword And Ignore Error
      ...  admin.Assert
      ...  class_name=${class}
      ...  id=${cell}
      ...  parameters=${states}
      ...  timeout=20
      ...  connection=${bts_id}
      ${avail_status_not_exists}=  Run Keyword And Return Status
      ...  Should Not Contain  ${result}  availabilityStatus
      ${fault49_status}  ${faults_list}=  Run Keyword And Ignore Error  admin.Assert Alarm Inactive
      ...  parameters=faultId=49, alarmingObjectIds[0].internal=${cell}, severity=Critical, alarmId=7102
      ...  timeout=60
      ...  connection=${bts_id}
      Run Keyword If  ${avail_status_not_exists}==True  Log  availabilityStatus of ${cell} On Air (-)  console=True
      Run Keyword If
      ...  '${status}'=='FAIL' or ${avail_status_not_exists}==False or '${fault49_status}'=='FAIL'
      ...  Fail  Unexpected state(s) of ${cell}
    END
    ${no_power_check_to_test}=  Run Keyword And Return Status
    ...  List Should Contain Value  ${RMODS_CHOSEN_FOR_POWER}  no_power_check
    Run Keyword If  ${no_power_check_to_test}==False  SM Verify Power Of The Carriers  ${rmods_to_be_tested}

SM Verify Alarm And KPI
    [Arguments]  ${bts_id}  ${cells}
    [Documentation]
    ...  KW for checking 'cells' states after procedure of blocking has been run
    ...  If guardband cells are deployed on test line 'all_cells_on_tl_copy' should be a list without guardband cells
    ...
    ...    +------------------------+-------+-----------------------------------------------------------------------------------------+
    ...    | Argument               | Man.  | Description                                                                             |
    ...    +========================+=======+=========================================================================================+
    ...    | bts_id                 | Yes   | BTS_ID used as alias                                                                    |
    ...    +------------------------+-------+-----------------------------------------------------------------------------------------+
    ...    | cells                  | Yes   | A list of cells whose states should be checked                                          |
    ...    +------------------------+-------+-----------------------------------------------------------------------------------------+

    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    FOR  ${cell}  IN  @{cells}
      ${fault49_status}  ${faults_list}=  Run Keyword And Ignore Error  admin.Assert Alarm Inactive
      ...  parameters=faultId=49, alarmingObjectIds[0].internal=${cell}, severity=Critical, alarmId=7102
      ...  timeout=60
      ...  connection=${bts_id}
      Run Keyword If
      ...  '${fault49_status}'=='FAIL'
      ...  Fail  Unexpected state(s) of ${cell}
    END
    Logging With Timestamp
    ...  message=KPI#17b calculation start.
    ...  style=ONGOING
    FOR  ${bts_id}  IN  @{CFG.active_bts_list}
      admin.Collect Infomodel Log From Current Session
      ...  connection=${bts_id}
      ...  target_file_name=${TEST_LOGS_PATH}BTSFiles/${bts_id}/ims_kpi17b.ims2
      ...  timeout=120
    END
    FOR  ${cell}  IN  @{cells}
      ${bts_id}  ${bts_name}  ${class}  ${global_cell_id}  ${cell_r_number}=  Extract Variables From Cell Dist Name  ${cell}  ${node_cells_dict}
      ${kpi17b}=  Run Keyword And Continue On Failure  kpi.Calculate Kpi17b
      ...  ims_file_path=${TEST_LOGS_PATH}BTSFiles/${bts_id}/ims_kpi17b.ims2
      ...  dist_name=${cell}
      ${kpi_collected}=    Run Keyword If  '${class}'!='GNCEL' and '${class}'!='WNCEL'
      ...  Set Variable  True
    END
    ${status}=  Run Keyword And Return Status  Variable Should Exist  ${kpi_collected}
    Run Keyword If  ${status}==True  Run Keyword If  '${kpi_collected}'=='True'  Evaluate Deltas Of KPIs  kpi17b  80.1
    kpi.Clear Results
    Logging With Timestamp
    ...  message=KPI#17b calculation finished.
    ...  style=DONE

SM Block Cells On Chosen RAT
    [Arguments]  ${bts_list}  ${rat}  ${all_cells_without_guardband}
    Logging With Timestamp
    ...  message=Blocking cells on a single RAT ${rat} has been started.
    ...  logs_dir=${CFG.suite_logs_path}
    @{all_cells_without_guardband_copy}=  Copy List  ${all_cells_without_guardband}
    FOR  ${bts_id}  IN  @{bts_list}
      ${block_status}=  Run Keyword And Return Status  admin.Block All Cells  ${rat}
      ...  timeout=300
      ...  connection=${bts_id}
      ${all_cells_without_guardband_copy}=  Run Keyword If  '${block_status}'=='True'
      ...  Remove Rat Cells From Unchanged  ${rat}  ${all_cells_without_guardband_copy}
      Run Keyword If  '${block_status}'=='False'
      ...  Fail  Cells on RAT ${rat} have NOT been blocked.
    END
    Logging With Timestamp
    ...  message=Blocking cells on single RAT finished - RAT ${rat}
    ...  style=DONE
    [Return]  ${all_cells_without_guardband_copy}

SM Unblock Cells On Chosen RAT
    [Arguments]  ${bts_list}  ${rat}
    Logging With Timestamp
    ...  message=Unblocking cells on a single RAT ${rat} has been started.
    ...  logs_dir=${CFG.suite_logs_path}
    FOR  ${bts_id}  IN  @{bts_list}
      ${unblock_status}=  Run Keyword And Return Status  admin.Unblock All Cells
      ...  ${rat}
      ...  timeout=300
      ...  connection=${bts_id}
      Run Keyword If  '${unblock_status}'=='False'
      ...  Fail  Cells on RAT ${rat} NOT unblocked.
    END
    Logging With Timestamp
    ...  message=Unblocking cells on single RAT finished - RAT ${rat}
    ...  style=DONE

SM Lock Cells On Chosen RAT
    [Arguments]  ${bts_list}  ${rat}  ${all_cells_without_guardband}  ${node_rat_cells_dict}
    Logging With Timestamp
    ...  message=Locking cells on a single RAT ${rat} has been started.
    ...  logs_dir=${CFG.suite_logs_path}
    @{all_cells_without_guardband_copy}=  Copy List  ${all_cells_without_guardband}
    FOR  ${bts_id}  IN  @{bts_list}
      ${gsm_lock_status}=  Run Keyword If  '${rat}'=='GSM'  SM Lock GSM Cells  ${bts_id}  ${node_rat_cells_dict}
      ...  ELSE  Set Variable  False
      ${lock_status}=  Run Keyword And Return Status  Run Keyword If  '${rat}'=='WCDMA'
      ...  SM Lock WCDMA Cells
      ...  ${bts_id}
      ...  ${node_rat_cells_dict}
      ...  ELSE  admin.Lock
      ...  technology=${rat}
      ...  timeout=300
      ...  connection=${bts_id}
      ${all_cells_without_guardband_copy}=  Run Keyword If  ${gsm_lock_status}==True or ${lock_status}==True
      ...  Remove Rat Cells From Unchanged  ${rat}  ${all_cells_without_guardband}
      Run Keyword If  ${gsm_lock_status}==True or ${lock_status}==True
      ...  Log   Cells on RAT ${rat} have been locked.  console=True
      ...  ELSE  Fail  Cells on RAT ${rat} have NOT been locked. Please investigate.
    END
    Logging With Timestamp
    ...  message=Locking cells on single RAT finished - RAT ${rat}
    ...  style=DONE
    [Return]  ${all_cells_without_guardband_copy}

SM Unlock Cells On Chosen RAT
    [Arguments]  ${bts_list}  ${rat}  ${node_rat_cells_dict}
    Log  Unlock all cells on single RAT ${rat}  console=${True}
    FOR  ${bts_id}  IN  @{bts_list}
      ${gsm_unlock_status}=  Run Keyword If  '${rat}'=='GSM'  SM Unlock GSM Cells  ${bts_id}  ${node_rat_cells_dict}
      ...  ELSE  Set Variable  False
      ${unlock_status}=  Run Keyword And Return Status  Run Keyword If  '${rat}'=='WCDMA'
      ...  SM Unlock WCDMA Cells
      ...  ${bts_id}
      ...  ${node_rat_cells_dict}
      ...  ELSE  admin.Unlock  technology=${rat}  timeout=300  connection=${bts_id}
      Run Keyword If  ${gsm_unlock_status}==True or ${unlock_status}==True
      ...  Log   Cells on RAT ${rat} have been locked.  console=True
      ...  ELSE  Fail  Cells on RAT ${rat} NOT unlocked. Please investigate.
    END
    Logging With Timestamp
    ...  message=Unlocking cells on single RAT finished - RAT ${rat}
    ...  style=DONE

SM Recovery Unblock Cells On Chosen RAT
    [Arguments]  ${bts_id}  ${rats}
    FOR  ${rat}  IN  @{rats}
      Log  Unblock all cells on single RAT ${rat}  console=${True}
      ${block_status}=  Run keyword and return status  admin.Unblock All Cells  ${rat}  timeout=300  connection=${bts_id}
    END

SM Recovery Unlock Cells On Chosen RAT
    [Arguments]  ${bts_id}  ${rats}  ${node_rat_cells_dict}
    FOR  ${rat}  IN  @{rats}
      Log  Unlock all cells on single RAT ${rat}  console=${True}
      ${unlock_status}=  Run Keyword And Return Status  Run Keyword If  '${rat}'=='GSM'  SM Unlock GSM Cells  ${bts_id}  ${node_rat_cells_dict}
      ...  ELSE  admin.Unlock  technology=${rat}  timeout=300  connection=${bts_id}
    END

SM Lock Cells On Chosen Band
    [Arguments]  ${bts_id}  ${band_name}  ${all_cells_without_guardband}  ${node_cells_dict}  ${node_rat_cells_dict}
    [Documentation]
    ...  KW for locking cells on consecutive bands chosen by the tester or found on the test line
    ...

    ...    +-----------------------------+-------+-------------------------------------------------------------------------------+
    ...    | Argument                    | Man.  | Description                                                                   |
    ...    +=============================+=======+===============================================================================+
    ...    | bts_id                     | Yes   | BTS_ID used as alias                                                          |
    ...    +-----------------------------+-------+-------------------------------------------------------------------------------+
    ...    | band                        | Yes   | A band number which should be blocked                                         |
    ...    +-----------------------------+-------+-------------------------------------------------------------------------------+
    ...    | all_cells_without_guardband | Yes   | A list of cells whose states should be checked                                |
    ...    +-----------------------------+-------+-------------------------------------------------------------------------------+
    ...    | node_cells_dict             | Yes   | A dictionary node=cells required for GSM cellsm                               |
    ...    +-----------------------------+-------+-------------------------------------------------------------------------------+

    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    Logging With Timestamp
    ...  message=Locking cells on a single band ${band_name} has been started.
    ...  logs_dir=${CFG.suite_logs_path}
    ${name}  ${band}  Split String  ${band_name}  separator=_  max_split=1
    ${band}  Set Variable If  "${name}"=="wcdma"  wcdma_${band}  ${band}
    ${cellson_band}=  Catenate  SEPARATOR=_  cellson  ${band}
    @{all_cells_without_guardband_copy}=  Copy List  ${all_cells_without_guardband}
    @{lock_band_statuses}=  Create List
    FOR  ${cell}  IN  @{${cellson_band}}
      Log  Lock cell ${cell}  console=${True}
      Continue For Loop If  '${cell}'=='None'
      ${bts_id}  ${bts_name}  ${class}  ${global_cell_id}  ${cell_r_number}=  Extract Variables From Cell Dist Name  ${cell}  ${node_cells_dict}
      ${gsm_lock_status}=  Run Keyword If  '${class}'=='GNCEL'  SM Lock GSM Cells    ${bts_id}  ${node_rat_cells_dict}
      ...  ELSE  Set Variable  False
      ${lock_status}=  Run Keyword And Return Status  Run Keyword If  '${class}'=='WNCEL'
      ...  SM Lock WCDMA Cells
      ...  ${bts_id}
      ...  ${node_rat_cells_dict}
      ...  ELSE  admin.Lock
      ...  dist_name=${cell}
      ...  timeout=300
      ...  connection=${bts_id}
      Append To List  ${lock_band_statuses}  ${lock_status}
      Run Keyword If  ${gsm_lock_status}==True or ${lock_status}==True
      ...  Log  Cell ${cell} has been locked successfully.
      ...  ELSE  Fail  Cell ${cell} could not be locked. Please, investigate the issue.
      Remove Values From List  ${all_cells_without_guardband_copy}  ${cell}
    END
    ${lock_band_summary}=  Run Keyword And Return Status  List Should Not Contain Value  ${lock_band_statuses}  False
    Run Keyword If  ${lock_band_summary}==True  Log  Cells on band ${band} have been locked successfully.
    ...  ELSE  Fail  Cells on band ${band} could not be locked. Please, investigate the issue
    Sleep  15s
    Logging With Timestamp
    ...  message=Locking cells on band ${band} finished.
    ...  style=DONE
    [Return]  ${all_cells_without_guardband_copy}

SM Unlock Cells On Chosen Band
  [Arguments]  ${bts_id}  ${band_name}  ${node_cells_dict}  ${node_rat_cells_dict}
  Logging With Timestamp
  ...  message=Unlocking cells on a single band ${band_name} has started.
  ...  logs_dir=${CFG.suite_logs_path}
  ${name}  ${band}  Split String  ${band_name}  separator=_  max_split=1
  ${cellson_band}=  Catenate  SEPARATOR=_  cellson  ${band}
  FOR  ${cell}  IN  @{${cellson_band}}
    Log  Unlock cell ${cell}  console=${True}
    Continue For Loop If  '${cell}'=='None'
    ${bts_id}  ${bts_name}  ${class}  ${global_cell_id}  ${cell_r_number}=  Extract Variables From Cell Dist Name  ${cell}  ${node_cells_dict}
    ${gsm_unlock_status}=  Run Keyword If  '${class}'=='GNCEL'  SM Unlock GSM Cells  ${bts_id}  ${node_rat_cells_dict}
    ...  ELSE  Set Variable  False
    ${unlock_status}=  Run Keyword And Return Status  Run Keyword If  '${class}'=='WNCEL'
    ...  SM Unlock WCDMA Cells
    ...  ${bts_id}
    ...  ${node_rat_cells_dict}
    ...  ELSE  admin.Unlock
    ...  dist_name=${cell}  timeout=300  connection=${bts_id}
    Run Keyword If  ${gsm_unlock_status}==True or ${unlock_status}==True
    ...  Log  Cell ${cell} has been unlocked successfully.
    ...  ELSE  Fail  Cell ${cell} could not be unlocked. Please, investigate the issue.
  END
  Sleep  15s
  Logging With Timestamp
  ...  message=Unlocking cells on a single band has finished.
  ...  style=DONE

SM Verify Whether Correct Cells Locked
    [Arguments]  ${bts_id}  ${cells}  ${rmods_to_be_tested}  ${node_cells_dict}  ${states}=${cells_locked_states}
    [Documentation]
    ...  KW for checking 'cells' states after procedure of locking has been run
    ...  If guardband cells are deployed on test line 'all_cells_on_tl_copy' should be a list without guardband cells
    ...
    ...    +------------------------+-------+-----------------------------------------------------------------------------------------+
    ...    | Argument               | Man.  | Description                                                                             |
    ...    +========================+=======+=========================================================================================+
    ...    | bts_id                | Yes   | BTS_ID used as alias                                                                    |
    ...    +------------------------+-------+-----------------------------------------------------------------------------------------+
    ...    | cells                  | Yes   | A list of cells whose states should be checked                                          |
    ...    +------------------------+-------+-----------------------------------------------------------------------------------------+
    ...    | states                 | No    | Expected states as string, e.g.,                                                        |
    ...    |                        |       | "administrativeState=Unlocked, operationalState=Enabled"                                |
    ...    +------------------------+-------+--------------------------------------------------------------------------- -------------+

    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    Logging With Timestamp
    ...  message=Start verifying whether correct cells are locked
    ...  logs_dir=${CFG.suite_logs_path}
    @{all_locked_cells}=  Create List
    @{all_locked_statuses}=  Create List
    FOR  ${cell}  IN  @{cells}
      ${bts_id}  ${bts_name}  ${class}  ${global_cell_id}  ${cell_r_number}=  Extract Variables From Cell Dist Name  ${cell}  ${node_cells_dict}
      ${lock_status}=  Run Keyword If  '${class}'!='WNCEL'  Run Keyword And Return Status
      ...  admin.Assert
      ...  class_name=${class}
      ...  id=${cell}
      ...  parameters=${states}
      ...  timeout=20
      ...  connection=${bts_id}
      ...  ELSE
      ...  Run Keyword And Return Status
      ...  admin.Assert
      ...  class_name=${class}
      ...  id=${cell}
      ...  parameters=${cells_wcdma_locked_states}
      ...  timeout=20
      ...  connection=${bts_id}
      Append To List  ${all_locked_statuses}  ${lock_status}
      Run Keyword If  '${lock_status}'=='True'
      ...  Log  Cell ${cell} locked  console=True
      ...  ELSE  Fail  Cell ${cell} NOT locked
      ${type}=  Evaluate  type($cell)
      ${cell}=  Run Keyword If  "${type}"=="<class 'str'>"  Create List  ${cell}
      ${all_locked_cells}=  Combine Lists  ${all_locked_cells}  ${cell}
    END
    ${lock_pass}=  Run Keyword And Return Status  List Should Not Contain Value  ${all_locked_statuses}  FAIL
    Run Keyword If  ${lock_pass}==True
    ...  Logging With Timestamp
    ...  message=All cells have been locked successfully.
    ...  ELSE  Fail  Some cells have not been locked. Please, investigate the issue.
    ...  style=DONE
    Logging With Timestamp
    ...  message=Verifying Power Of The Carriers.
    ...  style=ONGOING
    ${no_power_check_to_test}=  Run Keyword And Return Status
    ...  List Should Contain Value  ${RMODS_CHOSEN_FOR_POWER}  no_power_check
    Run Keyword If  ${no_power_check_to_test}==False  SM Verify Power Of The Carriers  ${rmods_to_be_tested}
    Logging With Timestamp
    ...  message=Verifying Power Of The Carriers finished.
    ...  style=DONE
    Logging With Timestamp
    ...  message=KPI 16a calculation start.
    ...  style=ONGOING
    FOR  ${bts_id}  IN  @{CFG.active_bts_list}
      admin.Collect Infomodel Log From Current Session
      ...  connection=${bts_id}
      ...  target_file_name=${TEST_LOGS_PATH}BTSFiles/${bts_id}/ims_kpi16a.ims2
      ...  timeout=120
    END
    FOR  ${cell}  IN  @{cells}
      ${bts_id}  ${bts_name}  ${class}  ${global_cell_id}  ${cell_r_number}=  Extract Variables From Cell Dist Name  ${cell}  ${node_cells_dict}
      ${kpi16a}=  Run Keyword If  '${class}'!='GNCEL' and '${class}'!='WNCEL'
      ...  Run Keyword And Continue On Failure  kpi.Calculate Kpi16a
      ...  ims_file_path=${TEST_LOGS_PATH}BTSFiles/${bts_id}/ims_kpi16a.ims2
      ...  global_cell_id=${global_cell_id}
      ${kpi_collected}=    Run Keyword If  '${class}'!='GNCEL' and '${class}'!='WNCEL'
      ...  Set Variable  True
    END
    ${status}=  Run Keyword And Return Status  Variable Should Exist  ${kpi_collected}
    Run Keyword If  ${status}==True and '${kpi_collected}'=='True'  Evaluate Deltas Of KPIs  kpi16a  80.1
    kpi.Clear Results
    Logging With Timestamp
    ...  message=KPI 16a calculation finished.
    ...  style=DONE
    [Return]  ${all_locked_cells}

Evaluate Deltas Of KPIs
    [Arguments]  ${kpi_name}  ${kpi_max_value}
    ${all_deltas}=  kpi.Get All Deltas  ${kpi_name}
    ${max_value}=  Convert To Number  ${kpi_max_value}
    ${all_deltas_status}=  Create List
    FOR  ${delta}  IN  @{all_deltas}
      ${status}=  Evaluate  ${delta} < ${max_value}
      Append To List  ${all_deltas_status}  ${status}
    END
    ${delta_above}=  Run Keyword And Return Status  List Should Not Contain Value  ${all_deltas_status}  False
    Run Keyword If  ${delta_above}==True
    ...  Log  KPI ${kpi_name} for all locked cells below threshold.  console=True
    ...  ELSE  Fail  KPI ${kpi_name} for some locked cells above threshold. Please investigate.

SM Verify Whether Correct Cells Unlocked
    [Arguments]  ${bts_id}  ${cells}  ${rmods_to_be_tested}  ${states}=${cells_unlocked_states}
    FOR  ${cell}  IN  @{cells}
      ${bts_id}  ${bts_name}  ${class}  ${global_cell_id}  ${cell_r_number}=  Extract Variables From Cell Dist Name  ${cell}  ${node_cells_dict}
      ${status}  ${result}=  Run Keyword And Ignore Error
      ...  admin.Assert
      ...  class_name=${class}
      ...  id=${cell}
      ...  parameters=${states}
      ...  timeout=20
      ...  connection=${bts_id}
      ${avail_status_not_exists}=  Run Keyword And Return Status
      ...  Should Not Contain  ${result}  availabilityStatus
      Run Keyword If  ${avail_status_not_exists}==True  Log  availabilityStatus of ${cell} On Air (-)  console=True
      Run Keyword If
      ...  '${status}'=='FAIL' or ${avail_status_not_exists}==False
      ...  Fail  Unexpected state(s) of ${cell}
    END
    FOR  ${bts_id}  IN  @{CFG.active_bts_list}
      admin.Collect Infomodel Log From Current Session
      ...  connection=${bts_id}
      ...  target_file_name=${TEST_LOGS_PATH}BTSFiles/${bts_id}/ims_kpi16b.ims2
      ...  timeout=120

      ${kpi16b}=  Run Keyword And Continue On Failure  kpi.Calculate Kpis
      ...  kpi_names=kpi16b
      ...  ims_file_path=${TEST_LOGS_PATH}BTSFiles/${bts}/ims_kpi.ims2
      ${kpi16b_test}=  kpi.Get All Deltas  kpi_name=kpi16b

    END
    FOR  ${cell}  IN  @{cells}
      ${bts_id}  ${bts_name}  ${class}  ${global_cell_id}  ${cell_r_number}=  Extract Variables From Cell Dist Name  ${cell}  ${node_cells_dict}
      ${kpi16b}=  Run Keyword If  '${class}'!='GNCEL' and '${class}'!='WNCEL'
      ...  Run Keyword And Continue On Failure  kpi.Calculate Kpi16b
      ...  ims_file_path=${TEST_LOGS_PATH}BTSFiles/${bts_id}/ims_kpi16b.ims2
      ...  global_cell_id=${cell_number}
      ${kpi_collected}=    Run Keyword If  '${class}'!='GNCEL' and '${class}'!='WNCEL'
      ...  Set Variable  True
    END
    ${status}=  Run Keyword And Return Status  Variable Should Exist  ${kpi_collected}
    Run Keyword If  ${status}==True  Run Keyword If  '${kpi_collected}'=='True'  Evaluate Deltas Of KPIs  kpi16b  80.1
    kpi.Clear Results
    Logging With Timestamp
    ...  message=KPI 16b calculation finished.
    ...  style=DONE
    ${no_power_check_to_test}=  Run Keyword And Return Status
    ...  List Should Contain Value  ${RMODS_CHOSEN_FOR_POWER}  no_power_check
    Run Keyword If  ${no_power_check_to_test}==False  SM Verify Power Of The Carriers  ${rmods_to_be_tested}

SM Verify Power Of The Carriers
    [Arguments]  ${rmods_to_be_tested}
    @{tx_rx}=  Create List  TX  RX
    FOR  ${rmod}  IN  @{rmods_to_be_tested}
      FOR  ${dir}  IN  @{tx_rx}
        ${carriers_power}   radio.Get Carriers Power
        ...  ru_serial_number=${rmod}
        ...  direction=${dir}
        ...  print_table=True
        ...  print_table=True
        ...  return_antennas=True
      END
    END

SM Check FMCADM Parameters
    FOR  ${bts_id}  IN  @{CFG.active_bts_list}
      ${fmcadm_parameter}=  admin.Get Parameter By Distname  MRBTS-${bts_id}/MNL-1/MNLENT-1/FMCADM-1  connection=${bts_id}
      Run Keyword If  "${fmcadm_parameter[0]['parameters']['actCategoryAlarms']}"=="True"
      ...  Log  actCategoryAlarms activated.  console=${TRUE}
      ...  ELSE  Fail  Mandatory parameter actCategoryAlarms not activated, test failed. Please, prepare the SCF file.
    END

SM Check FEATGADM Parameters
    FOR  ${bts_id}  IN  @{CFG.active_bts_list}
      ${featgadm_parameter}=  admin.Get Parameter By Distname  MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1/FEATGADM-1  connection=${bts_id}
      Run Keyword If  "${featgadm_parameter[0]['parameters']['actIpV4BasedPktAbTrs']}"=="True"
      ...  Log  actIpV4BasedPktAbTrs activated.  console=${TRUE}
      ...  ELSE  Fail  Mandatory parameter actIpV4BasedPktAbTrs not activated, test failed. Please, prepare the SCF file.
    END

SM Lock WCDMA Cells
    [Arguments]  ${bts_id}  ${node_rat_cells_dict}
    ${wcdma_cells}=  Get From Dictionary  ${node_rat_cells_dict['${bts_id}']}  wcdma
    FOR  ${cell}  IN  @{wcdma_cells}
      ${rnc_id}=  Get From Dictionary  ${node_rat_cells_dict['${bts_id}']['wcdma']['${cell}']}  rnc_id
      ${oms_ip}=  Get From Dictionary  ${node_rat_cells_dict['${bts_id}']['wcdma']['${cell}']}  oms_ip
      ${status}=  Run Keyword And Return Status  nwi3.Setup nwi3  ${rnc_id}  ${oms_ip}
      SiSo_L3_Call.SiSo Get Wbts Id  ${bts_id}
      ${cell_num}=  Fetch From Right  ${cell}  marker=-
      ${admin_cell_state_before}=  nwi3.Get Wcel Parameter  ${WBTS_ID}  ${cell_num}  AdminCellState
      Run Keyword If  ${admin_cell_state_before}==1  Log  Cell unlocked - locking may be started.  console=True
      ...  ELSE  Fail  Cell already locked - locking may NOT be started, investigate further.
      ${status}=  Run Keyword And Return Status  nwi3.Set Wcel Parameters  ${WBTS_ID}  ${cell_num}  AdminCellState=0
      Sleep  90
      ${admin_cell_state_after}=  nwi3.Get Wcel Parameter  ${WBTS_ID}  ${cell_num}  AdminCellState
      Run Keyword If  ${admin_cell_state_after}==0  Log  Cell locked - locking finished.  console=True
      ...  ELSE  Fail  Cell NOT locked - investigate further.
    END

SM Unlock WCDMA Cells
    [Arguments]  ${bts_id}  ${node_rat_cells_dict}
    ${wcdma_cells}=  Get From Dictionary  ${node_rat_cells_dict['${bts_id}']}  wcdma
    FOR  ${cell}  IN  @{wcdma_cells}
      ${rnc_id}=  Get From Dictionary  ${node_rat_cells_dict['${bts_id}']['wcdma']['${cell}']}  rnc_id
      ${oms_ip}=  Get From Dictionary  ${node_rat_cells_dict['${bts_id}']['wcdma']['${cell}']}  oms_ip
      ${status}=  Run Keyword And Return Status  nwi3.Setup nwi3  ${rnc_id}  ${oms_ip}
      SiSo_L3_call.SiSo Get Wbts Id  ${bts_id}
      ${cell_num}=  Fetch From Right  ${cell}  marker=-
      ${admin_cell_state_before}=  nwi3.Get Wcel Parameter  ${WBTS_ID}  ${cell_num}  AdminCellState
      Run Keyword If  ${admin_cell_state_before}==0  Log  Cell locked - unlocking started.  console=True
      ...  ELSE  Fail  Cell NOT locked - investigate further.
      ${status}=  Run Keyword And Return Status  nwi3.Set Wcel Parameters  ${WBTS_ID}  ${cell_num}  AdminCellState=1
      Sleep  90
      ${admin_cell_state_after}=  nwi3.Get Wcel Parameter  ${WBTS_ID}  ${cell_num}  AdminCellState
      Run Keyword If  ${admin_cell_state_after}==1  Log  Cell unlocked - unlocking finished.  console=True
      ...  ELSE  Fail  Cell NOT unlocked - investigate further.
    END

Find Bts Id For Cell
   [Arguments]  ${node_cells_dict}  ${cell}
   FOR  ${node}  IN  @{node_cells_dict}
     ${values}=  Get From Dictionary  ${node_cells_dict}  ${node}
     ${status}=  Run Keyword And Return Status  List Should Contain Value  ${values}  ${cell}
     ${node}=  Run Keyword If  '${status}'=='True'  Return From Keyword  ${node}
   END

Find Bts Id For Cell Name
   [Arguments]  ${node_cells_dict}  ${cell_name}
   FOR  ${node}  IN  @{node_cells_dict}
     ${values}=  Get From Dictionary  ${node_cells_dict}  ${node}
     FOR  ${value}  IN  @{values}
       ${status}=  Run Keyword And Return Status  Should Match Regexp  ${value}  .*${cell_name}.*
       ${node}=  Run Keyword If  '${status}'=='True'  Return From Keyword  ${node}
     END
   END

Remove Rat Cells From Unchanged
   [Arguments]  ${rat}  ${all_cells_without_guardband}
   FOR  ${cell}  IN  @{all_cells_without_guardband}
      ${bts_id}  ${bts_name}  ${class}  ${global_cell_id}  ${cell_r_number}=  Extract Variables From Cell Dist Name  ${cell}  ${node_cells_dict}
      ${cell_rat}=  Set Variable If  '${class}'=='NRCEL'  NR
      ...  '${class}'=='LNCEL'  LTE
      ...  '${class}'=='WNCEL'  WCDMA
      ...  '${class}'=='GNCEL'  GSM
      Run Keyword If  '${cell_rat}'=='${rat}'  Remove Values From List  ${all_cells_without_guardband}  ${cell}
   END
   [Return]  ${all_cells_without_guardband}

SM Lock GSM Cells
    [Arguments]    ${bts_id}  ${node_rat_cells_dict}
    SM Check FEATGADM Parameters
    FOR  ${cell}  IN   @{node_rat_cells_dict['${bts_id}']['gsm']}
        ${bsc_ip}=  Get From Dictionary  ${node_rat_cells_dict['${bts_id}']['gsm']['${cell}']}  bsc_ip
        ${bsc_user}=  Get From Dictionary  ${node_rat_cells_dict['${bts_id}']['gsm']['${cell}']}  bsc_user
        ${bsc_password}=  Get From Dictionary  ${node_rat_cells_dict['${bts_id}']['gsm']['${cell}']}  bsc_password
        ${bcf_id}=  Get From Dictionary  ${node_rat_cells_dict['${bts_id}']['gsm']['${cell}']}  bcf_id
        Exit For Loop
    END
    hran_bsc.BSC Connection
    ...  host=${bsc_ip}
#    ...  username=${bsc_user}
#    ...  password=${bsc_password}
    hran_bsc.BSC Login
    ...  username=${bsc_user}
    ...  password=${bsc_password}
    ...  login_prompt='ENTER USERNAME <'
    ...  password_prompt='ENTER PASSWORD <'
    hran_bsc.Lock All TRXs
    ...  bcf_id=${bcf_id}
    hran_bsc.Read Until
    ...  expected_result='<'
    Sleep  90s
    hran_bsc.Close Connection
    ${gsm_lock_status}=  Set Variable  True
    [Return]  ${gsm_lock_status}


SM Unlock GSM Cells
    [Arguments]    ${bts_id}  ${node_rat_cells_dict}
    SM Check FEATGADM Parameters
    FOR  ${cell}  IN   @{node_rat_cells_dict['${bts_id}']['gsm']}
        ${bsc_ip}=  Get From Dictionary  ${node_rat_cells_dict['${bts_id}']['gsm']['${cell}']}  bsc_ip
        ${bsc_user}=  Get From Dictionary  ${node_rat_cells_dict['${bts_id}']['gsm']['${cell}']}  bsc_user
        ${bsc_password}=  Get From Dictionary  ${node_rat_cells_dict['${bts_id}']['gsm']['${cell}']}  bsc_password
        ${bcf_id}=  Get From Dictionary  ${node_rat_cells_dict['${bts_id}']['gsm']['${cell}']}  bcf_id
        Exit For Loop
    END
    hran_bsc.BSC Connection
    ...  host=${bsc_ip}
#    ...  username=${bsc_user}
#    ...  password=${bsc_password}
    hran_bsc.BSC Login
    ...  username=${bsc_user}
    ...  password=${bsc_password}
    ...  login_prompt='ENTER USERNAME <'
    ...  password_prompt='ENTER PASSWORD <'
    hran_bsc.Unlock All TRXs
    ...  bcf_id=${bcf_id}
    hran_bsc.Read Until
    ...  expected_result='<'
    Sleep  90s
    hran_bsc.Close Connection
    ${gsm_unlock_status}=  Set Variable  True
    [Return]  ${gsm_unlock_status}
#
#    [Arguments]  ${bcfId}=1450  ${gsmBtsId}=1451  ${bsc_ip}=10.42.28.126
#    telnet.Open Connection  host=${bsc_ip}  port=23  prompt= <
#    telnet.Login  PZUSER  pzpassword  login_prompt=ENTER USERNAME <  password_prompt=ENTER PASSWORD <
#    ${status}=  Run Keyword And Return Status  sshLibrary.Read Until  <
#    telnet.Write  ZEEI:BCF=${bcfId};
#    ${status}=  Run Keyword And Return Status  telnet.Read Until  <
#    telnet.Write  ZEQS:BTS=${gsmBtsId}:U;
#    ${status}=  Run Keyword And Return Status  telnet.Read Until  <
#    Sleep  120
#    telnet.Close Connection
#    ${gsm_unlock_status}=  Set Variable  True
#    [Return]  ${gsm_unlock_status}

SM Select Cells To Be Blocked Or Locked By Band
    [Arguments]  ${iot_bands}  ${all_cells_info}  ${chosen_bands}  ${bands_on_tl_list}
    ${chosen_bands_exist}=  Run Keyword And Return Status  Variable Should Exist  ${chosen_bands}
    ${chosen_bands_not_empty}=  Run Keyword And Return Status  Should Not Be Empty  ${chosen_bands}
    ${no_bands_to_test}=  Run Keyword And Return Status  Run Keyword If  ${chosen_bands_not_empty}
    ...  List Should Contain Value  ${chosen_bands}  no_bands
    ${chosen_bands_in_tl}=  Run Keyword And Return Status  Run Keyword If  ${chosen_bands_not_empty}
    ...  List Should Contain Sub List  ${bands_on_tl_list}  ${chosen_bands}
    ${no_bands_list}=  Create List
    ${tested_bands}=  Set Variable If
    ...  ${chosen_bands_exist}==False  ${bands_on_tl_list}
    ...  ${chosen_bands_exist}==True and ${no_bands_to_test}==True  ${no_bands_list}
    ...  ${chosen_bands_exist}==True and ${chosen_bands_in_tl}==True  ${chosen_bands}
    ...  ${chosen_bands_exist}==True and ${chosen_bands_in_tl}==False  ${bands_on_tl_list}

    ${status}=  Run Keyword And Return Status  Should Not Be Equal  ${tested_bands}  ${no_bands_list}
    ${tested_bands}=  Run Keyword If  ${status}==True
    ...  Remove IoT Bands From The Tested Bands List  ${tested_bands}  ${iot_bands}
    ${tested_bands}=  Run Keyword If  ${status}==True  Create Lists Of Cells On The Tested Bands  ${tested_bands}  ${all_cells_info}
    ...  ELSE  Set Variable  ${no_bands_list}
    [Return]  ${tested_bands}

Remove IoT Bands From The Tested Bands List
    [Arguments]  ${tested_bands}  ${iot_band}
    FOR  ${iot_band}  IN  @{iot_bands}
      Remove Values From List  ${tested_bands}  ${iot_band}
    END
    [Return]  ${tested_bands}

Create Lists Of Cells On The Tested Bands
    [Arguments]  ${tested_bands}  ${all_cells_info}
    FOR  ${band_name}  IN  @{tested_bands}
      ${name}  ${band}  Split String  ${band_name}  separator=_  max_split=1
      ${cellson_band}=  Catenate  SEPARATOR=_  cellson  ${band}
      @{cells_list}=  Create List
      FOR  ${cell}  IN  @{all_cells_info}
        ${nr_status}  ${nr_cell}=   Run Keyword And Ignore Error
        ...  Set Variable If  '${cell['band']}'=='${band}'  ${cell['id']['internal']}
        ${lte_status}  ${lte_cell}=   Run Keyword And Ignore Error
        ...  Set Variable If  '${cell['bandNumber']}'=='${band}'  ${cell['id']['internal']}
        ${wcdma_status}  ${wcdma_cell}=   Run Keyword And Ignore Error
        ...  Set Variable If  '${cell['downlinkChannelBandwidth']}'=='${band}'  ${cell['id']['internal']}
        ${gsm_status}  ${gsm_cell}=   Run Keyword And Ignore Error
        ...  Set Variable If  '${cell['gsmBand']}'=='${band}'  ${cell['id']['internal']}
        Run Keyword And Ignore Error  Run Keyword If  '${nr_status}'=='PASS' and '${nr_cell}'!='None'
        ...  Append To List  ${cells_list}  ${nr_cell}
        Run Keyword And Ignore Error  Run Keyword If  '${lte_status}'=='PASS' and '${lte_cell}'!='None'
        ...  Append To List  ${cells_list}  ${lte_cell}
        Run Keyword And Ignore Error  Run Keyword If  '${wcdma_status}'=='PASS' and '${wcdma_cell}'!='None'
        ...  Append To List  ${cells_list}  ${wcdma_cell}
        Run Keyword And Ignore Error  Run Keyword If  '${gsm_status}'=='PASS' and '${gsm_cell}'!='None'
        ...  Append To List  ${cells_list}  ${gsm_cell}
      END
      ${cells_list}=  Remove Duplicates  ${cells_list}
      Remove Values From List  ${cells_list}  None
      Set Test Variable  ${${cellson_band}}  ${cells_list}
    END
    [Return]  ${tested_bands}

SM Get BTS_ID For Block Or Lock Cells On Single RAT
    [Arguments]  ${cells_on_rat}
    @{bts_list}=  Create List
    FOR  ${cell}  IN  @{cells_on_rat}
      ${bts_id}  ${bts_name}  ${class}  ${global_cell_id}  ${cell_r_number}=  Extract Variables From Cell Dist Name  ${cell}  ${node_cells_dict}
      Append To List  ${bts_list}  ${bts_id}
    END
    ${bts_list}=  Remove Duplicates  ${bts_list}
    [Return]  ${bts_list}

SM Calculate Counters For LTE And NR
    [Arguments]   ${bts_id}  ${rats_on_tl}  ${cell_mcc_mnc_dict}  ${node_cells_dict}
    ${nr_exists}=  Run Keyword And Return Status  List Should Contain Value  ${rats_on_tl}  NR
    ${lte_exists}=  Run Keyword And Return Status  List Should Contain Value  ${rats_on_tl}  LTE
    Run Keyword If  ${nr_exists}==True  Check Counters For NR  ${bts_id}
    Run Keyword If  ${lte_exists}==True  Check Counters For LTE  ${bts_id}  ${cell_mcc_mnc_dict}  ${node_cells_dict}

Check Counters For NR
    [Arguments]   ${bts_id}
    ${status}  ${counters_5G_M55601C01001}=  Run Keyword And Ignore Error  admin.Get Pm Counters  M55601C01001  timeout=120s  connection=${bts_id}

    ${status}  ${counters_5G_M55601C01002}=  Run Keyword And Ignore Error  admin.Get Pm Counters  M55601C01002  timeout=120s  connection=${bts_id}

    ${status}  ${counters_5G_M55601C01003}=  Run Keyword And Ignore Error  admin.Get Pm Counters  M55601C01003  timeout=120s  connection=${bts_id}
    Run Keyword If  '${status}'!='FAIL'  Should Be Equal As Integers  ${counters_5G_M55601C01003}  0

    ${status}  ${counters_5G_M55601C01004}=  Run Keyword And Ignore Error  admin.Get Pm Counters  M55601C01004  timeout=120s  connection=${bts_id}
    Run Keyword If  '${status}'!='FAIL'  Should Be Equal As Integers  ${counters_5G_M55601C01004}  0
    ...  ELSE  Log  Counter M55601C01004 not collected or not even 0. Please investigate the issue.  level=WARN

    ${status}  ${counters_5G_M55601C00001}=  Run Keyword And Ignore Error  admin.Get Pm Counters  M55601C00001  timeout=120s  connection=${bts_id}
    ${status}  ${counters_5G_M55601C00002}=  Run Keyword And Ignore Error  admin.Get Pm Counters  M55601C00002  timeout=120s  connection=${bts_id}
    ${status}  ${counters_5G_M55601C00003}=  Run Keyword And Ignore Error  admin.Get Pm Counters  M55601C00003  timeout=120s  connection=${bts_id}

Check Counters For LTE
    [Arguments]   ${bts_id}  ${cell_mcc_mnc_dict}  ${node_cells_dict}
    ${status}  ${counters_4G_M8020C1}=  Run Keyword And Ignore Error  admin.Get Pm Counters  M8020C1  timeout=120s  connection=${bts_id}

    ${status}  ${counters_4G_M8020C2}=  Run Keyword And Ignore Error  admin.Get Pm Counters  M8020C2  timeout=120s  connection=${bts_id}
    FOR  ${cell}  IN  @{CELLS_LTE}
      ${bts_id}  ${bts_name}  ${class}  ${global_cell_id}  ${cell_r_number}=  Extract Variables From Cell Dist Name  ${cell}  ${node_cells_dict}
      ${mcc}=  Set Variable  ${cell_mcc_mnc_dict['${cell}'][0]}
      ${mnc}=  Set Variable  ${cell_mcc_mnc_dict['${cell}'][1]}
      ${path_part1}=  Set Variable  ['BTS']['MRBTS-${bts_id}']['${bts_name}-${bts_id}']['${class}-${global_cell_id}']
      ${path_part2}=  Set Variable  ['MCC-${mcc}']['MNC-0${mnc}']['LTE_Cell_Avail']['M8020C2']
      ${values}  Get Dictionary Values  ${counters_4G_M8020C2${path_part1}${path_part2}}
      ${sum_of_counter_values}=  Set Variable  0
      FOR  ${value}  IN  @{values}
        ${sum_of_counter_values}  Evaluate  ${sum_of_counter_values}+${value}
      END
      Run Keyword And Ignore Error  Log To Console  ${sum_of_counter_values}
      ${M8020C2_status}=  Run Keyword And Return Status
      ...  Run Keyword If  '${status}'!='FAIL'  Should Be Equal As Integers  ${counters_4G_M8020C2}  0
      Run Keyword If  ${M8020C2_status}==True
      ...  Log   M8020C2 counter is equal to 0 for cell ${cell}  console=True
      ...  ELSE  Fail  M8020C2 counter is NOT equal to 0 for cell ${cell}. Please investigate.
    END

    ${status}  ${counters_4G_M8020C3}=  Run Keyword And Ignore Error  admin.Get Pm Counters  M8020C3  timeout=120s  connection=${bts_id}
    ${status}  ${counters_4G_M8020C4}=  Run Keyword And Ignore Error  admin.Get Pm Counters  M8020C4  timeout=120s  connection=${bts_id}

    ${status}  ${counters_4G_M8020C5}=  Run Keyword And Ignore Error  admin.Get Pm Counters  M8020C5  timeout=120s  connection=${bts_id}
    Run Keyword And Ignore Error  Run Keyword If  '${status}'!='FAIL'  Should Be Equal As Integers  ${counters_4G_M8020C5}  0

    ${status}  ${counters_4G_M8020C6}=  Run Keyword And Ignore Error  admin.Get Pm Counters  M8020C6  timeout=120s  connection=${bts_id}
