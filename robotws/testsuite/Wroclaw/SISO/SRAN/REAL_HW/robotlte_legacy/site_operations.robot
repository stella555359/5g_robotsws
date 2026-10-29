# robocop: off
*** Settings ***
Documentation  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS

Resource    ../Resources/Setup/setup_and_teardown.robot
#Resource  ./common_setup.robot
#Resource  ./site_verifications.robot
Resource  ./variables.robot
Resource  ./site_verifications.robot


Library  BuiltIn
Library  Collections
Library  String
Library  robot.libraries.DateTime
Library  taf.sbts.oam.coam.admin    WITH NAME    admin
Library  ute_admin_infomodel    WITH NAME    admin_im
Library    taf.ul.alarms_watchdog.interface.alarms_watchdog                     WITH NAME    awd
Library    taf.rfrl.common_resources.python.ims2_alarms.IMS2AlarmVerifier       WITH NAME    iav

*** Keywords ***
Execute Cell Block Unblock On Every Node
  Set Tags     AUTHOR-piotr.korczynski@nokia.com  MAINTAINER-piotr.korczynskia@nokia.com
  Common Test Setup
  Logging With Timestamp
  ...  message=Execute Recommissioning On Every Node on list : @{CFG.active_bts_list} will be executed
  ...  style=ONGOING
  FOR  ${bts}  IN  @{CFG.active_bts_list}
    Perform Cell Block Unblock On Every Cell  ${cfg}  ${bts}
  END

  [Teardown]    Common Test Teardown

Perform Cell Block Unblock On Every Cell
  [Arguments]  ${cfg}  ${node}
  Log  \nCell Block Unblock Admin procedure on Every cell on BTS_ID=${node} started  console=True
  Perform Cell Block Unblock Procedure  ${cfg}  ${node}  LNCEL
  Perform Cell Block Unblock Procedure  ${cfg}  ${node}  GNCEL
  Perform Cell Block Unblock Procedure  ${cfg}  ${node}  WNCEL
  Perform Cell Block Unblock Procedure  ${cfg}  ${node}  NRCEL

Perform Cell Block Unblock Procedure
  [Arguments]  ${cfg}  ${node}  ${technology}  ${timeout}=120 sec
  ${kpi_list}=  Create List  kpi17a  kpi17b
  ${configuration_cell_list}=  Get Dictionary Keys  ${cfg.NODES['${node}']['${technology}']}
  ${private_cell_list_status}=  Run Keyword And Return Status  Variable Should Exist  ${CELL_LIST}
  ${cell_new_list}=  Run Keyword If  ${private_cell_list_status}
  ...  Evaluate  [cell for cell in ${configuration_cell_list} if cell in ${CELL_LIST}]
  ${cell_new_list}=  Set Variable If  ${private_cell_list_status}  ${cell_new_list}  ${configuration_cell_list}

  FOR  ${cell}  IN  @{cell_new_list}
    Run Keyword If
    ...  '${technology}' == 'LNCEL'
    ...  Continue For Loop If
    ...  '${technology}' == 'LNCEL' and 'band' in '${cfg.NODES['${node}']['${technology}']['${cell}']['scf_type']}'
    Logging Additional Admin Session Start
  ...  logs_dir_path=${TEST_LOGS_DIR_PATH}
  ...  timeout=${timeout}
  ...  connection=${cell}
  ...  bts_id=${node}
    ${dist_name}=  Get From Dictionary  ${cfg.NODES['${node}']['${technology}']['${cell}']}  scf_dist_name
    ${dist_name}=  Convert To String  ${dist_name}
    Perform Cell Block  ${node}  ${cell}  ${technology}  ${timeout}
    Verify Cell State  ${node}  ${cell}  ${dist_name}  Blocked  ${technology}  ${timeout}
    Verify Cell Alarms  ${node}  ${cell}  ${technology}  Blocked
    Perform Cell Unblock  ${node}  ${cell}  ${technology}  ${timeout}
    Verify Cell State  ${node}  ${cell}  ${dist_name}  Unblocked  ${technology}  ${timeout}
    Verify Cell Alarms  ${node}  ${cell}  ${technology}  Unblocked
    Store KPI Value  kpi_names=${kpi_list}  prefix=${cell}
#    Run Keyword If  '${KEYWORD STATUS}' != 'PASS'  Perform Cell Unblock  ${node}  ${cell}  ${technology}  ${timeout}
  END

Perform Cell Block
  [Arguments]  ${node}  ${cell}  ${technology}  ${timeout}
  Log  \nCell Block Admin procedure ${cell} started  console=True
  ${dist_name}=  Get From Dictionary  ${cfg.NODES['${node}']['${technology}']['${cell}']}  scf_dist_name
  ${dist_name}=  Convert To String  ${dist_name}
  ${rat_type}=  Set Variable If  '${technology}' == 'LNCEL'  LTE
  ...  '${technology}' == 'GNCEL'  GSM
  ...  '${technology}' == 'WNCEL'  WCDMA
  ...  '${technology}' == 'NRCEL'  NR
  ${cell_id}=  admin.Get Cell Id By Configuration Id  ${rat_type}  ${cell}  ${timeout}  alias=${node}
  ${status}=  Run Keyword And Return Status  Run Keyword If  '5G' not in '${cfg.NODES['${node}']['software_active']}'
  ...  Run Keyword And Continue On Failure  admin.Block Cell  dist_name=${cell_id}  timeout=${timeout}  connection=${node}
  ...  ELSE  Run Keyword And Continue On Failure  admin.Lock  dist_name=${cell_id}  timeout=${timeout}  alias=${node}
  [Teardown]  Log  \nCell Block/Lock Admin procedure ${cell} started. Status = ${status}  console=True

Perform Cell Unblock
  [Arguments]  ${node}  ${cell}  ${technology}  ${timeout}
  Log  \nCell Unblock Admin procedure ${cell} started  console=True
  ${dist_name}=  Get From Dictionary  ${cfg.NODES['${node}']['${technology}']['${cell}']}  scf_dist_name
  ${dist_name}=  Convert To String  ${dist_name}
  ${rat_type}=  Set Variable If  '${technology}' == 'LNCEL'  LTE
  ...  '${technology}' == 'GNCEL'  GSM
  ...  '${technology}' == 'WNCEL'  WCDMA
  ...  '${technology}' == 'NRCEL'  NR
  ${cell_id}=  admin.Get Cell Id By Configuration Id  ${rat_type}  ${cell}  ${timeout}  alias=${node}

  ${status}=  Run Keyword And Return Status  Run Keyword If  '5G' not in '${cfg.NODES['${node}']['software_active']}'
  ...  Run Keyword And Continue On Failure  admin.Unblock Cell  dist_name=${cell_id}  timeout=${timeout}  connection=${node}
  ...  ELSE  Run Keyword And Continue On Failure  admin.Unlock  dist_name=${cell_id}  timeout=${timeout}  alias=${node}
  [Teardown]  Log  \nCell Unblock/Unlocked Admin procedure ${cell} started. Status = ${status}  console=True

Verify Cell State
  [Arguments]  ${node}  ${cell}  ${dist_name}  ${state}  ${technology}  ${timeout}
#  ${cell_list_rviev}=  Get Cell list  ${timeout}  alias=${node}
  ${rat_type}=  Set Variable If  '${technology}' == 'LNCEL'  LTE
  ...  '${technology}' == 'GNCEL'  GSM
  ...  '${technology}' == 'WNCEL'  WCDMA
  ...  '${technology}' == 'NRCEL'  NR
  ${cell_id}=  admin.Get Cell Id By Configuration Id  ${rat_type}  ${cell}  ${timeout}  alias=${node}
  ${availability_state}=  Set Variable If
  ...  "${state}" == "Blocked" or "${state}" == "Locked"
  ...  regex"Offline|off line"
  ...  regex"None|Online"
  ${procedural_state}=  Set Variable If  "${state}" == "Blocked"  Validated  OnAirDone
  ${administrative_state}=  Set Variable If  "${state}" == "Blocked"  Locked  Unlocked
  Log  \nCell State Check Admin procedure started  console=True
  ${status}=  Run Keyword And Continue On Failure
  ...  Run Keyword If
  ...  '5G' not in '${cfg.NODES['${node}']['software_active']}' and ('${technology}' == 'LNCEL' or '${technology}' == 'NRCEL')
  ...  Run Keyword And Continue On Failure
  ...  admin.Assert
  ...  class_name=${technology}
  ...  id=${cell_id}
  ...  parameters=blockingState=${state}
  ...  timeout=${timeout}
  ...  alias=${node}
  ...  ELSE IF
  ...  '5G' not in '${cfg.NODES['${node}']['software_active']}'
  ...  Run Keyword And Continue On Failure
  ...  admin.Assert
  ...  class_name=${technology}
  ...  id=${cell_id}
  ...  parameters=blockingState=${state}
  ...  timeout=${timeout}
  ...  alias=${node}
  ...  ELSE
  ...  Run Keyword And Continue On Failure
  ...  admin.Assert
  ...  class_name=${technology}
  ...  id=${cell_id}
  ...  parameters=administrativeState=${administrative_state}
  ...  timeout=${timeout}
  ...  alias=${node}
  ${availabilityStatus}=  Run Keyword If
  ...  "${state}" == "Blocked" or "${state}" == "Locked"
  ...  Run Keyword And Continue On Failure
  ...  admin.Assert
  ...  class_name=${technology}
  ...  id=${cell_id}
  ...  parameters=availabilityStatus=regex"(?i)degraded|dependency|failed|off\\s?line|None"
  ...  timeout=${timeout}
  ...  alias=${node}
  ...  ELSE
  ...  Run Keyword And Continue On Failure
  ...  admin.Assert No
  ...  class_name=${technology}
  ...  parameters=availabilityStatus=regex"(?i)degraded|dependency|failed|off\\s?line|None", id=${cell_id}
  ...  search_for_iot_cells=${True}
  ...  timeout=${timeout}
  ...  alias=${node}

Verify Cell Alarms
  [Arguments]  ${node}  ${cell}  ${technology}  ${state}
  ${new_distname}    Check If Current Build Is Newer Than    SBTS25R3_ENB_9999_250228_000011  alias=${node}
  ${rat_type}=  Set Variable If  '${technology}' == 'LNCEL'  LTE
  ...  '${technology}' == 'GNCEL'  GSM
  ...  '${technology}' == 'WNCEL'  WCDMA
  ...  '${technology}' == 'NRCEL'  NR
  FOR  ${alarm}  IN  @{GLO_ADMIN_ALLOWED_ALARMS}
    admin.Add Allowed Alarm  ${alarm}  alias=${node}
  END
  ${rat_lower}=  Convert To Lower Case  ${rat_type}
  ${cells_info}=  admin.Get Cells Info  cell_type=${rat_lower}  timeout=60  connection=${node}
  Run Keyword If  '5G' not in '${cfg.NODES['${node}']['software_active']}'
  ...  admin.Add Allowed Alarm  faultId=49, severity=Critical  alias=${node}
  admin.Get Alarms  alias=${node}
  FOR  ${cell_info}  IN  @{cells_info}
    ${config_cell_id}=  Set Variable  ${cell_info['id']['configuration']}
    ${global_cell_id}=  Fetch From Right  ${config_cell_id}  marker=-
    Continue For Loop If  '${global_cell_id}'!='${cell}'
    RETURN  ${config_cell_id}
  END
  IF  not ${new_distname}
      ${alarm_state_status}=  Run Keyword And Continue On Failure
      ...  Run Keyword If  '${state}' == 'Blocked' and '5G' not in '${cfg.NODES['${node}']['software_active']}'
      ...  admin.Assert Alarm Active  faultId=49, severity=Critical, alarmingResource=${config_cell_id}  alias=${node}
      ...  ELSE IF  '${state}' != 'Blocked' and '${technology}' != 'NRCEL'
      ...  admin.Assert Alarm Inactive  faultId=49, severity=Critical, alarmingResource=${config_cell_id}  alias=${node}
  ELSE
      ${cell_id}=  admin.Get Cell Id By Configuration Id  ${rat_type}  ${cell}  20 sec  alias=${node}
      IF  '${rat_type}' == 'NR'
        ${cells_info}  Get Cells Info  cell_type=nr  timeout=60  connection=${node}  detailed_output=False
        FOR  ${nr_cell}  IN  @{cells_info}
            IF  '${nr_cell['globalCellId']}' != '${cell}'
                Continue For Loop
            END
            ${cell_config_dn}  Set Variable  ${nr_cell['id']['configuration']}
        END
      END
      IF  '${state}' == 'Blocked' and '5G' not in '${cfg.NODES['${node}']['software_active']}' and '${rat_type}' == 'NR'
        ${alarm_state_status}=  Run Keyword And Continue On Failure
        ...  admin.Assert Alarm Active  faultId=49, severity=Critical  alias=${node}
        ${alarm_info}    admin.Assert Alarm Active  faultId=49, severity=Critical  alias=${node}
        FOR  ${alarm}    IN    @{alarm_info}
            ${faultId}  Get From Dictionary  ${alarm}  faultId
            Continue For Loop If  '${faultId}'!='49'
            ${alarm_dn_configuration}  Set Variable  ${alarm['alarmingObjectIds'][0]['configuration']}
            IF    '${alarm_dn_configuration}' == '${cell_config_dn}'
              admin.Add Allowed Alarm  faultId=49, severity=Critical  alias=${node}
            ELSE
                Run Keyword And Continue On Failure    Fail    msg= Alarm 49 not detected!
            END
        END
      END
      IF  '${state}' == 'Blocked' and '5G' not in '${cfg.NODES['${node}']['software_active']}' and '${rat_type}' != 'NR'
        ${alarm_state_status}=  Run Keyword And Continue On Failure
        ...    admin.Assert Alarm Active  faultId=49, severity=Critical, alarmingResource=${cell_id}  alias=${node}
      END
      IF  '${state}' != 'Blocked' and '${technology}' != 'NRCEL'
            ${alarm_state_status}=  Run Keyword And Continue On Failure
            ...  admin.Assert Alarm Inactive  faultId=49, severity=Critical, alarmingResource=${cell_id}  alias=${node}
      END
      ${exists}  Run Keyword And Return Status  Variable Should Exist  ${alarm_state_status}
      IF  not ${exists}
        ${alarm_state_status}  Set Variable  None
      END
  END
  Run Keyword If  not ${alarm_state_status} and '5G' not in '${cfg.NODES['${node}']['software_active']}'
  ...  Log  \nFault ID:49 NOT detected !!!  console=True
  ...  ELSE IF  '5G' not in '${cfg.NODES['${node}']['software_active']}' == 'NRCEL'
  ...  Log  \nFault ID:49 state = ${state} : correct  console=True
  ${alarm_unexpected_status}=  Run Keyword And Continue On Failure  admin.Assert No Unexpected Active Alarms  alias=${node}
  Run Keyword If  "${alarm_unexpected_status}" == "${EMPTY}"
  ...  Log  \nList of unexpected alarms detected:${\n}${alarm_unexpected_status}  console=True
  ...  ELSE  Log  \nNo unexpected alarms detected  console=True
  Run Keyword And Continue On Failure  admin.Assert No Unexpected Historical Alarms  alias=${node}

Execute RU Block Unblock On Every Node
  Set Tags     AUTHOR-piotr.korczynski@nokia.com  MAINTAINER-piotr.korczynskia@nokia.com
  Common Test Setup  tools_to_setup=syslog_ADMIN
  Logging With Timestamp
  ...  message=Execute RU Block Unblock On Every Node on list : @{CFG.active_bts_list} will be executed
  ...  style=ONGOING
  ${rf_list}=  Get Dictionary Keys  ${cfg.RF_INFO}
  ${RF_status}=  Run Keyword And Return Status  Variable Should Exist  ${CUSTOM_RADIO_UNIT_LIST}
  ${rf_list}=  Set Variable If  ${RF_status}  ${CUSTOM_RADIO_UNIT_LIST}  ${rf_list}
  FOR  ${ru_sn}  IN  @{rf_list}
    Run Keyword And Continue On Failure  Perform RU Block Unblock  ${ru_sn}  ${cfg}
  END
  [Teardown]    Common Test Teardown

Perform RU Block Unblock
  [Arguments]  ${ru_sn}  ${cfg}
  ${ru_bts_id}  ${ru_dist_name}=  Get RU Node Data  ${ru_sn}
  Perform RU Block  ${ru_bts_id}  ${ru_sn}  ${ru_dist_name}  90 sec
  Verify RU Block Unblock State  ${ru_bts_id}  ${ru_dist_name}  Blocked  90 sec
  Verify RU Block Unblock Cells State  ${cfg}  ${ru_bts_id}  ${ru_sn}  ${ru_dist_name}  Blocked  90 sec
  Verify RU Block Unblock Alarms  ${ru_bts_id}  ${ru_sn}  ${ru_dist_name}  Blocked  90 sec
  Perform RU Unblock  ${ru_bts_id}  ${ru_sn}  ${ru_dist_name}  360 sec
  Verify RU Block Unblock State  ${ru_bts_id}  ${ru_dist_name}  Unblocked  360 sec
  Verify RU Block Unblock Cells State  ${cfg}  ${ru_bts_id}  ${ru_sn}  ${ru_dist_name}  Unblocked  360 sec
  Verify All Cells OnAir  ${ru_bts_id}
  Verify RU Block Unblock Alarms  ${ru_bts_id}  ${ru_sn}  ${ru_dist_name}  Unblocked  360 sec
  [Teardown]  Run Keywords
  ...  Verify RU Block Unblock Alarms  ${ru_bts_id}  ${ru_sn}  ${ru_dist_name}  Unblocked  360 sec
  ...  AND  Run Keyword If  '${KEYWORD STATUS}' != 'PASS'  Perform RU Unblock  ${ru_bts_id}  ${ru_sn}  ${ru_dist_name}  360 sec

Perform RU Block
  [Arguments]  ${bts_id}  ${ru_sn}  ${dist_name}  ${timeout}
  Log  \nRU ${ru_sn} Block Admin procedure started  console=True
  ${dist_name}=  Convert To String  ${dist_name}
  ${ru_bts_id}=  Get From Dictionary  ${cfg.RF_INFO['${ru_sn}']}  scf_btsid_primary
  ${status}=  Run Keyword And Return Status
  ...  Run Keyword And Continue On Failure
  ...  admin.Lock
  ...  dist_name=${dist_name}
  ...  timeout=${timeout}
  ...  alias=${bts_id}
  [Teardown]  Log  \nRU ${ru_sn} Block Admin procedure finished. Status = ${status}  console=True

Perform RU Unblock
  [Arguments]  ${bts_id}  ${ru_sn}  ${dist_name}  ${timeout}
  Log  \nRU ${ru_sn} Unblock Admin procedure started  console=True
  ${dist_name}=  Convert To String  ${dist_name}
  ${ru_bts_id}=  Get From Dictionary  ${cfg.RF_INFO['${ru_sn}']}  scf_btsid_primary
  ${status}=  Run Keyword And Return Status
  ...  Run Keyword And Continue On Failure
  ...  admin.Unlock
  ...  dist_name=${dist_name}
  ...  timeout=${timeout}
  ...  alias=${bts_id}
  [Teardown]  Log  \nRU ${ru_sn} Unblock Admin procedure finished. Status = ${status}  console=True

Verify RU Block Unblock State
  [Arguments]  ${bts_id}  ${dist_name}  ${state}  ${timeout}
#  ${cell_id}=  Get Id For Current  RMOD  ${cell}  ${timeout}  alias=${node}
  ${asirmod_status}=  Run Keyword And Return Status  Should Match Regexp  ${ru_dist_name}  ASIRMOD
  ${class}=  Set Variable If  ${asirmod_status}  ASIRMOD  RMOD
  Log  \nRU State Check Admin procedure started  console=True
  ${status}=  Run Keyword And Return Status
  ...  Run Keyword If
  ...  '5G' not in '${cfg.NODES['${bts_id}']['software_active']}' and "${state}" == "Blocked"
  ...  Run Keyword And Continue On Failure
  ...  admin.Assert
  ...  ${class}
  ...  ${dist_name}
  ...  blockingState=Blocked
  ...  timeout=${timeout}
  ...  alias=${bts_id}
  ...  ELSE IF
  ...  '5G' not in '${cfg.NODES['${bts_id}']['software_active']}' and "${state}" == "Unblocked"
  ...  Run Keyword And Continue On Failure
  ...  admin.Assert
  ...  class_name=${class}
  ...  id=${dist_name}
  ...  blockingState=Unblocked
  ...  timeout=${timeout}
  ...  alias=${bts_id}
  ...  ELSE IF
  ...  "${state}" == "Blocked"
  ...  Run Keyword And Continue On Failure
  ...  admin.Assert
  ...  class_name=${class}
  ...  id=${dist_name}
  ...  administrativeState=Locked
  ...  timeout=${timeout}
  ...  alias=${bts_id}
  ...  ELSE
  ...  Run Keyword And Continue On Failure
  ...  admin.Assert
  ...  class_name=${class}
  ...  id=${dist_name}
  ...  administrativeState=Unlocked
  ...  timeout=${timeout}
  ...  alias=${bts_id}
  ${ru_status}=  admin.Get Parameters For  ${class}  ${dist_name}  timeout=${timeout}  alias=${bts_id}

Get RU Node Data
  [Arguments]  ${ru_sn}
  ${ru_bts_id}=  Get From Dictionary  ${cfg.RF_INFO['${ru_sn}']}  scf_btsid_primary
  ${ru_dist_name}=  Get From Dictionary  ${cfg.RF_INFO['${ru_sn}']}  scf_dist_name_primary
  ${bts_info}=  Admin Get BTS Info Into Dictionary  ${ru_bts_id}
  ${asirmod_status}=  Run Keyword And Return Status  Should Match Regexp  ${ru_dist_name}  ASIRMOD
  ${class}=  Set Variable If  ${asirmod_status}  asirmod  rmod
  ${ru_info}=  Get From Dictionary  ${bts_info['radioModules']}  ${class}
  FOR  ${ru}  IN  @{ru_info}
    ${ru_dist_name}=  Set Variable If  "${ru['serialNumber']}" == "${ru_sn}"  ${ru['id']['internal']}
    Exit For Loop If  "${ru['serialNumber']}" == "${ru_sn}"
  END
  [Return]  ${ru_bts_id}  ${ru_dist_name}

Get RU Node Product Code
  [Arguments]  ${ru_sn}
  ${ru_bts_id}=  Get From Dictionary  ${cfg.RF_INFO['${ru_sn}']}  scf_btsid_primary
  ${ru_dist_name}=  Get From Dictionary  ${cfg.RF_INFO['${ru_sn}']}  scf_dist_name_primary
  ${bts_info}=  Admin Get BTS Info Into Dictionary  ${ru_bts_id}
  ${ru_info}=  Get From Dictionary  ${bts_info['radioModules']}  rmod
  FOR  ${ru}  IN  @{ru_info}
    ${ru_product_code}=  Set Variable If  "${ru['serialNumber']}" == "${ru_sn}"  ${ru['productCode']}
    Exit For Loop If  "${ru['serialNumber']}" == "${ru_sn}"
  END
  [Return]  ${ru_bts_id}  ${ru_product_code}

Verify RU Block Unblock Cells State
  [Arguments]  ${cfg}  ${ru_bts_id}  ${ru_sn}  ${ru_dist_name}  ${state}  ${timeout}
  Log  \nRU Related Cells State Check Admin procedure started  console=True
  ${ru_cell_dict}=  Create Affected Cell List RF Lock Unlock  ${ru_sn}
  Verify RU Affected Cells  ${ru_bts_id}  ${ru_cell_dict}  ${state}  ${timeout}
  Verify RU Not Affected Cells  ${cfg}  ${ru_bts_id}  ${ru_sn}  ${ru_cell_dict}  ${state}  ${timeout}

Verify RU Power Remove Insert Cells State
  [Arguments]  ${cfg}  ${ru_bts_id}  ${ru_sn}  ${ru_dist_name}  ${state}  ${timeout}
  Log  \nRU Related Cells State Check Admin procedure started  console=True
  ${ru_cell_dict}=  Create Affected Cell List RF Hot Remove Insert  ${ru_sn}
  Verify RU Affected Cells  ${ru_bts_id}  ${ru_cell_dict}  ${state}  ${timeout}
  Verify RU Not Affected Cells  ${cfg}  ${ru_bts_id}  ${ru_sn}  ${ru_cell_dict}  ${state}  ${timeout}

Verify RU Affected Cells
  [Arguments]  ${node}  ${ru_cell_affected_dict}  ${state}  ${timeout}
  ${gncell_list_ru_affected}=  Get From Dictionary  ${ru_cell_affected_dict}  gncelid
  ${wncell_list_ru_affected}=  Get From Dictionary  ${ru_cell_affected_dict}  wncelid
  ${lncell_list_ru_affected}=  Get From Dictionary  ${ru_cell_affected_dict}  lncelid
  ${nrcell_list_ru_affected}=  Get From Dictionary  ${ru_cell_affected_dict}  nrcelid
  ${gncell_list_ru_affected}=  Run Keyword If  ${gncell_list_ru_affected}==None
  ...  Create List  @{EMPTY}
  ...  ELSE  Set Variable  ${gncell_list_ru_affected}
  ${wncell_list_ru_affected}=  Run Keyword If  ${wncell_list_ru_affected}==None
  ...  Create List  @{EMPTY}
  ...  ELSE  Set Variable  ${wncell_list_ru_affected}
  ${lncell_list_ru_affected}=  Run Keyword If  ${lncell_list_ru_affected}==None
  ...  Create List  @{EMPTY}
  ...  ELSE  Set Variable  ${lncell_list_ru_affected}
  ${nrcell_list_ru_affected}=  Run Keyword If  ${nrcell_list_ru_affected}==None
  ...  Create List  @{EMPTY}
  ...  ELSE  Set Variable  ${nrcell_list_ru_affected}
  FOR  ${cell_id}  IN  @{gncell_list_ru_affected}
    Verify RU Cell  ${node}  ${cell_id}  ${state}  GNCEL  ${timeout}
  END
  FOR  ${cell_id}  IN  @{wncell_list_ru_affected}
    Verify RU Cell  ${node}  ${cell_id}  ${state}  WNCEL  ${timeout}
  END
  FOR  ${cell_id}  IN  @{lncell_list_ru_affected}
    Verify RU Cell  ${node}  ${cell_id}  ${state}  LNCEL  ${timeout}
  END
  FOR  ${cell_id}  IN  @{nrcell_list_ru_affected}
    Verify RU Cell  ${node}  ${cell_id}  ${state}  NRCEL  ${timeout}
  END

Verify RU Not Affected Cells
  [Arguments]  ${cfg}  ${node}  ${ru_sn}  ${ru_cell_affected_dict}  ${state}  ${timeout}
  ${not_affected_gncell_list}=  Create List
  ${not_affected_wncell_list}=  Create List
  ${not_affected_lncell_list}=  Create List
  ${not_affected_nrcell_list}=  Create List
#  FOR  ${node_id}  IN  @{cfg.active_bts_list}
  ${gncell_tmp_list}=  Get Dictionary Keys  ${cfg.NODES['${node}']['GNCEL']}
  ${wncell_tmp_list}=  Get Dictionary Keys  ${cfg.NODES['${node}']['WNCEL']}
  ${lncell_tmp_list}=  Get Dictionary Keys  ${cfg.NODES['${node}']['LNCEL']}
  ${nrcell_tmp_list}=  Get Dictionary Keys  ${cfg.NODES['${node}']['NRCEL']}
  Append To List  ${not_affected_gncell_list}  @{gncell_tmp_list}
  Append To List  ${not_affected_wncell_list}  @{wncell_tmp_list}
  Append To List  ${not_affected_lncell_list}  @{lncell_tmp_list}
  Append To List  ${not_affected_nrcell_list}  @{nrcell_tmp_list}
#  END
  Run Keyword If  ${ru_cell_affected_dict['gncelid']}!=None
  ...  Remove Values From List  ${not_affected_gncell_list}  @{ru_cell_affected_dict['gncelid']}
  Run Keyword If  ${ru_cell_affected_dict['wncelid']}!=None
  ...  Remove Values From List  ${not_affected_wncell_list}  @{ru_cell_affected_dict['wncelid']}
  Run Keyword If  ${ru_cell_affected_dict['lncelid']}!=None
  ...  Remove Values From List  ${not_affected_lncell_list}  @{ru_cell_affected_dict['lncelid']}
  Run Keyword If  ${ru_cell_affected_dict['nrcelid']}!=None
  ...  Remove Values From List  ${not_affected_nrcell_list}  @{ru_cell_affected_dict['nrcelid']}
  ${not_affected_ru_cell_dict}=  Create Dictionary
  ...  gncelid=${not_affected_gncell_list}
  ...  wncelid=${not_affected_wncell_list}
  ...  lncelid=${not_affected_lncell_list}
  ...  nrcelid=${not_affected_nrcell_list}
  Verify RU Affected Cells  ${node}  ${not_affected_ru_cell_dict}  Unblocked  ${timeout}

Verify RU Cell
  [Arguments]  ${node}  ${cell}  ${state}  ${technology}  ${timeout}
  ${rat_type}=  Set Variable If  '${technology}' == 'LNCEL'  LTE
  ...  '${technology}' == 'GNCEL'  GSM
  ...  '${technology}' == 'WNCEL'  WCDMA
  ...  '${technology}' == 'NRCEL'  NR
  ${cell_id}=  Get Cell Id By Configuration Id  ${rat_type}  ${cell}  ${timeout}  alias=${node}
  ${cell_is_shared}=  Get From Dictionary  ${cfg.NODES['${node}']['${technology}']['${cell}']}  scf_cell_2T2R_shared
  ${action_state}=  Set Variable If
  ...  ("${state}" == "Blocked" or "${state}" == "Locked" or "${state}" == "Remove")
  ...  Disable
  ...  Enable
  ${operational_state}=  Set Variable If  "${action_state}" == "Disable" and not ${cell_is_shared}
  ...  regex"(?i)Disabled"
  ...  regex"(?i)Enabled"
  ${availablity_status}=  Set Variable If  "${action_state}" == "Disable"
  ...  regex"(?i)degraded|dependency|failed|off\\s?line"
  ...  ${null}
  ${procedural_state}=  Set Variable If  "${state}" == "Blocked"  regex"(?i)Validated"  regex"(?i)OnAirDone"
  Log  \nCell "${cell}" State on node = "${node}" Check Admin procedure started  console=True
  ${parameters}=  Set Variable If  ("${state}" == "Blocked" or "${state}" == "Locked" or "${state}" == "Remove")
  ...  availabilityStatus=${availablity_status}
  ...  operationalState=${operational_state}
  ${status}=  Run Keyword And Continue On Failure  Run Keyword If  '${technology}' == 'LNCEL'
  ...  Run Keyword And Continue On Failure  admin.Assert
  ...  ${technology}
  ...  ${cell_id}
  ...  parameters=${parameters}
  ...  timeout=${timeout}
  ...  alias=${node}
  ...  ELSE IF  '${technology}' != 'NRCEL'  Run Keyword And Continue On Failure  admin.Assert
  ...  ${technology}
  ...  ${cell_id}
  ...  parameters=${parameters}
  ...  timeout=${timeout}
  ...  alias=${node}
  ...  ELSE IF  '${technology}' == 'NRCEL'  Run Keyword And Continue On Failure  admin.Assert
  ...  ${technology}
  ...  ${cell_id}
  ...  parameters=${parameters}
  ...  timeout=${timeout}
  ...  alias=${node}
  ${availabilityStatus}=  Run Keyword If  "${action_state}" == "Enable"  Run Keyword And Continue On Failure  admin.Assert No
  ...  class_name=${technology}
  ...  parameters=availabilityStatus=regex"(?i)degraded|dependency|failed|off\\s?line|None", id=${cell_id}
  ...  search_for_iot_cells=${True}
  ...  timeout=${timeout}
  ...  alias=${node}

Create Affected Cell List RF Hot Remove Insert
  [Arguments]  ${ru_sn}
  ${gncell_list}=  Get From Dictionary  ${cfg.RF_INFO['${ru_sn}']['GNCEL']}  scf_cellid_primary
  ${wncell_list}=  Get From Dictionary  ${cfg.RF_INFO['${ru_sn}']['WNCEL']}  scf_cellid_primary
  ${lncell_list}=  Get From Dictionary  ${cfg.RF_INFO['${ru_sn}']['LNCEL']}  scf_cellid_primary
  ${nrcelid_list}=  Get From Dictionary  ${cfg.RF_INFO['${ru_sn}']['NRCEL']}  scf_cellid_primary
  ${ru_cell_list}=  Create List
  Run Keyword If  "${gncell_list}" != "None"  Append To List  ${ru_cell_list}  @{gncell_list}
  Run Keyword If  "${wncell_list}" != "None"  Append To List  ${ru_cell_list}  @{wncell_list}
  Run Keyword If  "${lncell_list}" != "None"  Append To List  ${ru_cell_list}  @{lncell_list}
  Run Keyword If  "${nrcelid_list}" != "None"  Append To List  ${ru_cell_list}  @{nrcelid_list}
  ${rim_affected_list}=  Create RIM Affected Units  ${ru_sn}
  ${fr_affected_list}=  Create List  @{cfg.RF_INFO['${ru_sn}']['scf_chain_fr_affected_list']}
  Append To List  ${fr_affected_list}  @{rim_affected_list}
  FOR  ${ru_id}  IN  @{fr_affected_list}
    ${gncell_list_id}=  Get From Dictionary  ${cfg.RF_INFO['${ru_id}']['GNCEL']}  scf_cellid_primary
    ${wncell_list_id}=  Get From Dictionary  ${cfg.RF_INFO['${ru_id}']['WNCEL']}  scf_cellid_primary
    ${lncell_list_id}=  Get From Dictionary  ${cfg.RF_INFO['${ru_id}']['LNCEL']}  scf_cellid_primary
    ${nrcelid_list_id}=  Get From Dictionary  ${cfg.RF_INFO['${ru_id}']['NRCEL']}  scf_cellid_primary
    ${ru_cell_list_id}=  Create List
    Run Keyword If  "${gncell_list_id}" != "None"  Append To List  ${gncell_list}  @{gncell_list_id}
    Run Keyword If  "${wncell_list_id}" != "None"  Append To List  ${wncell_list}  @{wncell_list_id}
    Run Keyword If  "${lncell_list_id}" != "None"  Append To List  ${lncell_list}  @{lncell_list_id}
    Run Keyword If  "${nrcelid_list_id}" != "None"  Append To List  ${nrcelid_list}  @{nrcelid_list_id}
  END
  ${gncell_list}=  Run Keyword If  "${gncell_list}" != "None"  Remove Duplicates  ${gncell_list}
  ${wncell_list}=  Run Keyword If  "${wncell_list}" != "None"  Remove Duplicates  ${wncell_list}
  ${lncell_list}=  Run Keyword If  "${lncell_list}" != "None"  Remove Duplicates  ${lncell_list}
  ${nrcelid_list}=  Run Keyword If  "${nrcelid_list}" != "None"  Remove Duplicates  ${nrcelid_list}
  ${ru_cell_affected_dict}=  Create Dictionary  gncelid=${gncell_list}
  ...  wncelid=${wncell_list}
  ...  lncelid=${lncell_list}
  ...  nrcelid=${nrcelid_list}
  [Return]  ${ru_cell_affected_dict}

Create Affected Cell List RF Lock Unlock
  [Arguments]  ${ru_sn}
  ${gncell_list}=  Get From Dictionary  ${cfg.RF_INFO['${ru_sn}']['GNCEL']}  scf_cellid_primary
  ${wncell_list}=  Get From Dictionary  ${cfg.RF_INFO['${ru_sn}']['WNCEL']}  scf_cellid_primary
  ${lncell_list}=  Get From Dictionary  ${cfg.RF_INFO['${ru_sn}']['LNCEL']}  scf_cellid_primary
  ${nrcelid_list}=  Get From Dictionary  ${cfg.RF_INFO['${ru_sn}']['NRCEL']}  scf_cellid_primary
  ${ru_cell_list}=  Create List
  Run Keyword If  "${gncell_list}" != "None"  Append To List  ${ru_cell_list}  @{gncell_list}
  Run Keyword If  "${wncell_list}" != "None"  Append To List  ${ru_cell_list}  @{wncell_list}
  Run Keyword If  "${lncell_list}" != "None"  Append To List  ${ru_cell_list}  @{lncell_list}
  Run Keyword If  "${nrcelid_list}" != "None"  Append To List  ${ru_cell_list}  @{nrcelid_list}
  ${ru_cell_affected_dict}=  Create Dictionary  gncelid=${gncell_list}
  ...  wncelid=${wncell_list}
  ...  lncelid=${lncell_list}
  ...  nrcelid=${nrcelid_list}
  [Return]  ${ru_cell_affected_dict}

Verify RU Block Unblock Alarms
  [Arguments]  ${ru_bts_id}  ${ru_sn}  ${ru_dist_name}  ${state}  ${timeout}
#  Clear Allowed Alarms List  alias=${ru_bts_id}
#  Start Historical Alarm Tracker  alias=${ru_bts_id}
  ${gncell_ru_sn_list}=  Get From Dictionary  ${cfg.RF_INFO['${ru_sn}']['GNCEL']}  scf_cellid_primary
  ${gncell_all_ru_list}=  Get Dictionary Keys  ${cfg.NODES['${ru_bts_id}']['GNCEL']}
  ${gncell_faulty_cell}=  Set Variable If  ${gncell_all_ru_list}==${gncell_ru_sn_list}  all
  ...  "None"=="${gncell_ru_sn_list}"  None
  ...  ${gncell_ru_sn_list}
  ${wncell_ru_sn_list}=  Get From Dictionary  ${cfg.RF_INFO['${ru_sn}']['WNCEL']}  scf_cellid_primary
  ${wncell_all_ru_list}=  Get Dictionary Keys  ${cfg.NODES['${ru_bts_id}']['WNCEL']}
  ${wncell_faulty_cell}=  Set Variable If  ${wncell_all_ru_list}==${wncell_ru_sn_list}  all
  ...  "None"=="${wncell_ru_sn_list}"  None
  ...  ${wncell_ru_sn_list}
  ${lncell_ru_sn_list}=  Get From Dictionary  ${cfg.RF_INFO['${ru_sn}']['LNCEL']}  scf_cellid_primary
  ${lncell_all_ru_list}=  Get Dictionary Keys  ${cfg.NODES['${ru_bts_id}']['LNCEL']}
  ${lncell_faulty_cell}=  Set Variable If  ${lncell_all_ru_list}==${lncell_ru_sn_list}  all
  ...  "None"=="${lncell_ru_sn_list}"  None
  ...  ${gncell_ru_sn_list}
  ${nrcell_ru_sn_list}=  Get From Dictionary  ${cfg.RF_INFO['${ru_sn}']['NRCEL']}  scf_cellid_primary
  ${nrcell_all_ru_list}=  Get Dictionary Keys  ${cfg.NODES['${ru_bts_id}']['NRCEL']}
  ${nrcell_faulty_cell}=  Set Variable If  ${nrcell_all_ru_list}==${nrcell_ru_sn_list}  all
  ...  "None"=="${nrcell_ru_sn_list}"  None
  ...  ${gncell_ru_sn_list}

#  ${rat_type}=  Set Variable If  '${technology}' == 'LNCEL'  LTE
#  ...  '${technology}' == 'GNCEL'  GSM
#  ...  '${technology}' == 'WNCEL'  WCDMA
#  ...  '${technology}' == 'NRCEL'  NR

  FOR  ${alarm}  IN  @{GLO_ADMIN_ALLOWED_ALARMS}
    admin.Add Allowed Alarm  ${alarm}  alias=${ru_bts_id}
  END
  ${alarm_attribute_value_gsm}=  Run Keyword If
  ...  "${gncell_faulty_cell}" != "None"
  ...  Catenate
  ...  GSM:
  ...  ${gncell_faulty_cell}
  ${alarm_attribute_value_lte}=  Run Keyword If
  ...  "${wncell_faulty_cell}" != "None"
  ...  Catenate
  ...  WCDMA:
  ...  ${wncell_faulty_cell}
  ${alarm_attribute_value_wcdma}=  Run Keyword If
  ...  "${lncell_faulty_cell}" != "None"
  ...  Catenate
  ...  LTE:
  ...  ${lncell_faulty_cell}
  ${alarm_attribute_value_5G}=  Run Keyword If  "${nrcell_faulty_cell}" != "None"  Catenate  NR:  ${nrcell_faulty_cell}
  ${alarm_attribute_value_all}=  Catenate
  ...  SEPARATOR=;
  ...  ${alarm_attribute_value_gsm}
  ...  ${alarm_attribute_value_lte}
  ...  ${alarm_attribute_value_wcdma}
  ...  ${alarm_attribute_value_5G}
#  Remove Values From List  ${alarm_attribute_value_all}  None
#  admin.Add Allowed Alarm  faultId=48, severity=Critical, alarmingResource=${alarm_attribute_value_all}  alias=${ru_bts_id}
#  Run Keyword If
#  ...  '5G' not in '${cfg.NODES['${ru_bts_id}']['software_active']}'    #and not ${cfg.NODES['${ru_bts_id}'].branch_revision}
#  ...  admin.Add Allowed Alarm
#  ...  faultId=48, severity=Critical
#  ...  alias=${ru_bts_id}
#  Get Active Alarms  alias=${ru_bts_id}
  admin.Get Alarms  alias=${ru_bts_id}
  # , alarmingResource=${alarm_attribute_value_all}
  # , alarmingResource=${alarm_attribute_value_all}
#  ${alarm_state_status}=  Run Keyword If
#  ...  '5G' not in '${cfg.NODES['${ru_bts_id}']['software_active']}'     #and not ${cfg.NODES['${ru_bts_id}'].branch_revision}
#  ...  Run Keyword And Continue On Failure
#  ...  Run Keyword If
#  ...  '${state}' == 'Blocked'
#  ...  admin.Assert Alarm Active
#  ...  faultId=48, severity=Critical
#  ...  timeout=${timeout}
#  ...  alias=${ru_bts_id}
#  ...  ELSE
#  ...  admin.Assert Alarm Inactive
#  ...  faultId=48, severity=Critical
#  ...  timeout=${timeout}
#  ...  alias=${ru_bts_id}
  ${alarm_unexpected_status}=  Run Keyword And Continue On Failure
  ...  Wait Until Keyword Succeeds  30 sec  2 sec  admin.Assert No Unexpected Active Alarms  alias=${ru_bts_id}
  Run Keyword If  "${alarm_unexpected_status}" == "${EMPTY}"
  ...  Log  \nList of unexpected alarms detected:${\n}${alarm_unexpected_status}  console=True
  ...  ELSE  Log  \nNo unexpected alarms detected  console=True
  Run Keyword And Continue On Failure  admin.Assert No Unexpected Historical Alarms  alias=${ru_bts_id}

Execute RU Power Hot Remove Insert On Every Node
  Set Tags   AUTHOR-piotr.korczynski@nokia.com  MAINTAINER-piotr.korczynskia@nokia.com
  Common Test Setup  tools_to_setup=syslog_ADMIN
  Logging With Timestamp
  ...  message=Execute RU Power Hot Remove Insert On Every Node on list : @{CFG.active_bts_list} will be executed
  ...  style=ONGOING
  ${rf_list}=  Get Dictionary Keys  ${cfg.RF_INFO}
  ${RF_status}=  Run Keyword And Return Status  Variable Should Exist  ${CUSTOM_RADIO_UNIT_LIST}
  ${rf_list}=  Set Variable If  ${RF_status}  ${CUSTOM_RADIO_UNIT_LIST}  ${rf_list}
  FOR  ${ru_sn}  IN  @{rf_list}
    Perform RU Power Hot Remove Insert  ${ru_sn}  ${cfg}
  END
  [Teardown]    Common Test Teardown

Perform RU Power Hot Remove Insert
  [Arguments]  ${ru_sn}  ${cfg}
  ${ru_bts_id}  ${ru_dist_name}=  Get RU Node Data  ${ru_sn}
  ${ru_startup_time_status}=  Run Keyword And Return Status  Variable Should Exist    ${RU_STARTUP_TIME}
  ${ru_startup_time}=  Set Variable If   ${ru_startup_time_status}   ${RU_STARTUP_TIME}  ${FR_AVAILABILITY_TIMEOUT}
  ${ACTIVE_STARTUP_VERDICT}=  Set Variable If   ${ru_startup_time_status}   ${True}  ${False}
  Set Test Variable    ${RU_STARTUP_TIME}  ${ru_startup_time}
  Set Test Variable    ${ACTIVE_STARTUP_VERDICT}  ${ru_startup_time}
  Perform RU Power Remove  ${ru_sn}  ${FAULT_10_TIMEOUT} sec
  Verify RU Power Remove Insert State  ${ru_bts_id}  ${ru_dist_name}  Remove  ${FAULT_10_TIMEOUT} sec
  Verify RU Power Remove Insert State For Affected RUs  ${ru_bts_id}  ${ru_sn}  Remove  ${FAULT_10_TIMEOUT} sec
  Verify RU Power Remove Insert Cells State
  ...  ${cfg}
  ...  ${ru_bts_id}
  ...  ${ru_sn}
  ...  ${ru_dist_name}
  ...  Remove
  ...  ${FAULT_10_TIMEOUT} sec
  Verify RU Power Remove Insert Alarms  ${ru_bts_id}  ${ru_sn}  ${ru_dist_name}  Remove  ${FAULT_10_TIMEOUT} sec
  Sleep  20 sec
  ${ru_startup_start_date}=  Perform RU Power Insert  ${ru_sn}  ${FR_AVAILABILITY_TIMEOUT} sec
  ${ru_startup_end_date}=  Verify RU Power Remove Insert State
  ...  ${ru_bts_id}
  ...  ${ru_dist_name}
  ...  Insert
  ...  ${FR_AVAILABILITY_TIMEOUT} sec
  Verify RU Power Remove Insert State For Affected RUs  ${ru_bts_id}  ${ru_sn}  Insert  ${FR_AVAILABILITY_TIMEOUT} sec
  Verify RU Power Remove Insert Cells State
  ...  ${cfg}
  ...  ${ru_bts_id}
  ...  ${ru_sn}
  ...  ${ru_dist_name}
  ...  Insert
  ...  ${FR_AVAILABILITY_TIMEOUT} sec
  Verify RU Power Remove Insert Alarms  ${ru_bts_id}  ${ru_sn}  ${ru_dist_name}  Insert  ${FR_AVAILABILITY_TIMEOUT} sec
  ${ru_startup_status}  ${time_diff}=  Verify RU Startup Time
  ...  Power  ${cfg}  ${ru_bts_id}  ${ru_startup_start_date}  ${ru_startup_end_date}
#  Run Keyword If  not ${ru_startup_status}  FAIL
  ${CUSTOM_RU_STABILITY_BREAK_status}=  Run Keyword And Return Status  Variable Should Exist  ${CUSTOM_RU_STABILITY_BREAK}
  ${rf_list}=  Return From Keyword If   not ${CUSTOM_RU_STABILITY_BREAK_status}
  Logging With Timestamp
  ...  message=Execute Custom Break to avoid instability on fiber cablink - sleep for: ${CUSTOM_RU_STABILITY_BREAK}
  ...  style=ONGOING
  Sleep  ${CUSTOM_RU_STABILITY_BREAK}
  [Teardown]  Run Keyword If  '${KEYWORD STATUS}' != 'PASS'  Perform RU Power Insert  ${ru_sn}  ${FR_AVAILABILITY_TIMEOUT} sec

Perform RU Power Remove
  [Arguments]  ${ru_sn}  ${timeout}
  Log  \nRU ${ru_sn} Power Remove procedure started  console=True
  ${tmp_list}=  Create List  ${ru_sn}
  ${timestamp}=  Get Current Date  UTC
  ${status}=  Run Keyword And Return Status  PDU Switch OFF Device Lists
  ...  ${tmp_list}
  ${ru_bts_id}  ${ru_dist_name}=  Get RU Node Data  ${ru_sn}
  ${timestamp_in_epoch}=  Convert Date  date=${timestamp}
  ...  date_format=%Y-%m-%d %H:%M:%S.%f
  ...  result_format=epoch
  &{link_break_event_dict}=  Create Dictionary  ru_sn=${ru_sn}
  ...  ru_dist_name=${ru_dist_name}
  ...  timestamp=${timestamp_in_epoch}
  Append To List  ${EXPECTED_LINK_BREAK_LIST}  ${link_break_event_dict}
  [Teardown]  Log  \nRU ${ru_sn} Power Remove procedure finished. Status = ${status}  console=True

Perform RU Power Insert
  [Arguments]  ${ru_sn}  ${timeout}
  Log  \nRU ${ru_sn} Power Insert procedure started  console=True
  ${tmp_list}=  Create List  ${ru_sn}
  ${status}=  Run Keyword And Return Status  PDU Switch On Device Lists
  ...  ${tmp_list}
  ${date}=  Run Keyword If  ${status}
  ...  Get Current Date  UTC
  ...  ELSE  Set Variable  {0}
  Set Test Variable  ${ru_startup_start_date}  ${date}
  [Teardown]  Log  \nRU ${ru_sn} Power Insert procedure finished. Status = ${status}  console=True
  [Return]  ${ru_startup_start_date}

Verify RU Power Remove Insert Alarms
  [Arguments]  ${ru_bts_id}  ${ru_sn}  ${ru_dist_name}  ${state}  ${timeout}
  [Timeout]  360 sec
#  Clear Allowed Alarms List  alias=${ru_bts_id}
  Preconditions For CNI-127210
  ${release}  admin.Get Sw Release Name  connection=${ru_bts_id}
  ${proper_sw}  Run Keyword If  "${release}"=="SBTS24R3" and ${PRECOND_FOR_CNI}
  ...  Check If Current Build Is Newer Than  SBTS24R3_ENB_0000_000602_000000  alias=${ru_bts_id}
  ...  ELSE IF  ${PRECOND_FOR_CNI}
  ...  Check If Current Build Is Newer Than  SBTS25R1_ENB_9999_240929_000023  alias=${ru_bts_id}
  Run keyword If   ${proper_sw}  Set Test Variable  ${PRECOND_FOR_CNI}  False
  ${ru_cell_dict}=  Create Affected Cell List RF Hot Remove Insert  ${ru_sn}
#  Start Historical Alarm Tracker  alias=${ru_bts_id}
  ${gncell_ru_sn_list}=  Get From Dictionary  ${cfg.RF_INFO['${ru_sn}']['GNCEL']}  scf_cellid_primary
  ${affected_gncell_ru_sn_list}=  Get From Dictionary  ${ru_cell_dict}  gncelid
  ${gncell_ru_sn_list}=  Run Keyword If  "${affected_gncell_ru_sn_list}" != "None"
  ...  Combine Lists  ${gncell_ru_sn_list}  ${affected_gncell_ru_sn_list}
  Run Keyword And Ignore Error  Remove Duplicates  ${gncell_ru_sn_list}
  ${gncell_all_ru_list}=  Get Dictionary Keys  ${cfg.NODES['${ru_bts_id}']['GNCEL']}
  ${gncell_faulty_cell}=  Set Variable If  ${gncell_all_ru_list}==${gncell_ru_sn_list}  all
  ...  "None"=="${gncell_ru_sn_list}"  None
  ...  ${gncell_ru_sn_list}
  ${wncell_ru_sn_list}=  Get From Dictionary  ${cfg.RF_INFO['${ru_sn}']['WNCEL']}  scf_cellid_primary
  ${affected_wncell_ru_sn_list}=  Get From Dictionary  ${ru_cell_dict}  wncelid
  ${wncell_ru_sn_list}=  Run Keyword If  "${affected_wncell_ru_sn_list}" != "None"
  ...  Combine Lists  ${affected_wncell_ru_sn_list}  ${wncell_ru_sn_list}
  Run Keyword And Ignore Error  Remove Duplicates  ${wncell_ru_sn_list}
  ${wncell_all_ru_list}=  Get Dictionary Keys  ${cfg.NODES['${ru_bts_id}']['WNCEL']}
  ${wncell_faulty_cell}=  Set Variable If  ${wncell_all_ru_list}==${wncell_ru_sn_list}  all
  ...  "None"=="${wncell_ru_sn_list}"  None
  ...  ${wncell_ru_sn_list}
  ${lncell_ru_sn_list}=  Get From Dictionary  ${cfg.RF_INFO['${ru_sn}']['LNCEL']}  scf_cellid_primary
  ${affected_lncell_ru_sn_list}=  Get From Dictionary  ${ru_cell_dict}  lncelid
  ${lncell_ru_sn_list}=  Run Keyword If  "${affected_lncell_ru_sn_list}" != "None"
  ...  Combine Lists  ${lncell_ru_sn_list}  ${affected_lncell_ru_sn_list}
  Run Keyword And Ignore Error  Remove Duplicates  ${lncell_ru_sn_list}
  ${lncell_all_ru_list}=  Get Dictionary Keys  ${cfg.NODES['${ru_bts_id}']['LNCEL']}
  ${lncell_faulty_cell}=  Set Variable If  ${lncell_all_ru_list}==${lncell_ru_sn_list}  all
  ...  "None"=="${lncell_ru_sn_list}"  None
  ...  ${lncell_ru_sn_list}
  ${nrcell_ru_sn_list}=  Get From Dictionary  ${cfg.RF_INFO['${ru_sn}']['NRCEL']}  scf_cellid_primary
  ${affected_nrcell_ru_sn_list}=  Get From Dictionary  ${ru_cell_dict}  nrcelid
  ${nrcell_ru_sn_list}=  Run Keyword If  "${affected_nrcell_ru_sn_list}" != "None"
  ...  Combine Lists  ${nrcell_ru_sn_list}  ${affected_nrcell_ru_sn_list}
  Run Keyword And Ignore Error  Remove Duplicates  ${nrcell_ru_sn_list}
  ${nrcell_all_ru_list}=  Get Dictionary Keys  ${cfg.NODES['${ru_bts_id}']['NRCEL']}
  ${nrcell_faulty_cell}=  Set Variable If  ${nrcell_all_ru_list}==${nrcell_ru_sn_list}  all
  ...  "None"=="${nrcell_ru_sn_list}"  None
  ...  ${nrcell_ru_sn_list}
  ${specific_alarm}=  Run Keyword And Return Status  Variable Should Exist  ${specific_alarm_detalis}
  Run Keyword If  ${specific_alarm}  Remove Values From List  ${GLO_ADMIN_ALLOWED_ALARMS}  ${specific_alarm_detalis}
  FOR  ${alarm}  IN  @{GLO_ADMIN_ALLOWED_ALARMS}
    admin.Add Allowed Alarm  ${alarm}  alias=${ru_bts_id}
  END
  ${alarm_attribute_value_gsm}=  Run Keyword If
  ...  "${gncell_faulty_cell}" != "None"
  ...  Catenate
  ...  GSM:
  ...  ${gncell_faulty_cell}
  ${alarm_attribute_value_lte}=  Run Keyword If
  ...  "${wncell_faulty_cell}" != "None"
  ...  Catenate
  ...  WCDMA:
  ...  ${wncell_faulty_cell}
  ${alarm_attribute_value_wcdma}=  Run Keyword If
  ...  "${lncell_faulty_cell}" != "None"
  ...  Catenate
  ...  LTE:
  ...  ${lncell_faulty_cell}
  ${alarm_attribute_value_5G}=  Run Keyword If  "${nrcell_faulty_cell}" != "None"  Catenate  NR:  ${nrcell_faulty_cell}
  ${alarm_attribute_value_all}=  Catenate
  ...  SEPARATOR=;
  ...  ${alarm_attribute_value_gsm}
  ...  ${alarm_attribute_value_lte}
  ...  ${alarm_attribute_value_wcdma}
  ...  ${alarm_attribute_value_5G}

  ${object_1}=  Evaluate  "${gncell_faulty_cell}" == "None" and "${wncell_faulty_cell}" == "None"
  ${object_2}=  Evaluate  "${lncell_faulty_cell}" == "None" and "${nrcell_faulty_cell}" == "None"
  ${alarm_severity}=  Evaluate  ${object_1} and ${object_2}
  ${lncell_is_shared}=  Run Keyword If  "${lncell_ru_sn_list}" != "None"  Check Affected Cells Sharing Status
  ...  ${ru_bts_id}
  ...  ${lncell_ru_sn_list}
  ...  LNCEL
  ${nrcell_is_shared}=  Run Keyword If  "${nrcell_ru_sn_list}" != "None"  Check Affected Cells Sharing Status
  ...  ${ru_bts_id}
  ...  ${nrcell_ru_sn_list}
  ...  NRCEL
  ${cell_is_shared}=  Set Variable If  ${lncell_is_shared}  True
  ...  ${nrcell_is_shared}  True
  ...  False
  ${alarm_severity}=  Set Variable If
  ...  ${alarm_severity}  Minor
  ...  ${cell_is_shared}  Major
  ...  Critical
  ${has_chain_rf_child}=  Evaluate  len(@{CFG["RF_INFO"]["${ru_sn}"]["scf_chain_fr_affected_list"]}) > 0
  Run Keyword If  '${state}' == 'Remove'  admin.Add Allowed Alarm  faultId=10  alias=${ru_bts_id}
  ${4003_lte_alarm_list}=    Run Keyword If    ${lncell_is_shared} and not ${has_chain_rf_child} and not ${PRECOND_FOR_CNI}
  ...    Create Alarm 4003 List    ${ru_bts_id}    ${lncell_ru_sn_list}     LTE
  ${4003_nr_alarm_list}=    Run Keyword If    ${nrcell_is_shared} and not ${has_chain_rf_child} and not ${PRECOND_FOR_CNI}
  ...    Create Alarm 4003 List    ${ru_bts_id}    ${nrcell_ru_sn_list}     NR
  ${alarm_list}=    Create List    faultId=10
  ${alarm_list}=    Run Keyword If    ${lncell_is_shared} and not ${PRECOND_FOR_CNI}
   ...    Collections.Combine Lists   ${4003_lte_alarm_list}  ${alarm_list}
   ...    ELSE    Set Variable    ${alarm_list}
  ${alarm_list}=    Run Keyword If    ${nrcell_is_shared} and not ${has_chain_rf_child} and not ${PRECOND_FOR_CNI}
   ...    Collections.Combine Lists   ${4003_nr_alarm_list}  ${alarm_list}
   ...    ELSE    Set Variable    ${alarm_list}
#  Get Active Alarms  alias=${ru_bts_id}
  admin.Get Alarms  alias=${ru_bts_id}
  ${specific_alarm_state_status}=  Run Keyword And Return Status
  ...  Run Keyword If  '${state}' == 'Remove' and ${specific_alarm}
  ...  admin.Assert Alarm Active  ${specific_alarm_detalis}
  ...  timeout=10
  ...  alias=${ru_bts_id}
  Run Keyword If
  ...  '${state}' == 'Remove' and ${specific_alarm}
  ...  Run Keywords
  ...  Log
  ...  \nRU Specific alarm status ${specific_alarm_state_status}
  ...  console=True
  ...  AND
  ...  Append To File
  ...  ${cfg.test_logs_path}/report_short.txt
  ...  \nRepetition no: ${ITERATION} state is: ${specific_alarm_state_status}
  ${alarm_state_status}=  Run Keyword And Continue On Failure
  ...  Run Keyword If  '${state}' == 'Remove'
  ...  Check Mandatory Alarm Active List  ${ru_bts_id}  ${alarm_list}  ${timeout}
  ...  ELSE  Check Mandatory Alarm InActive List  ${ru_bts_id}  ${alarm_list}  ${timeout}
  ${alarm_unexpected_status}=  Run Keyword And Continue On Failure
  ...  Wait Until Keyword Succeeds  30 sec  2 sec  admin.Assert No Unexpected Active Alarms  alias=${ru_bts_id}
  Run Keyword If  "${alarm_unexpected_status}" == "${EMPTY}"
  ...  Log  \nList of unexpected alarms detected:${\n}${alarm_unexpected_status}  console=True
  ...  ELSE  Log  \nNo unexpected alarms detected  console=True
  ${unexpected_historical_alarms_list}=  admin.Get Unexpected Historical Alarms  connection=${ru_bts_id}
  Run Keyword If  ${unexpected_historical_alarms_list} is not None
  ...  Check For Alarm 4589  ${ru_bts_id}  ${ru_sn}  ${unexpected_historical_alarms_list}
  Run Keyword And Continue On Failure  Check For Alarm 1815  ru_bts_id=${ru_bts_id}
  Run Keyword And Continue On Failure  admin.Assert No Unexpected Historical Alarms  alias=${ru_bts_id}

Check for Alarm 4589
  [Arguments]  ${ru_bts_id}  ${ru_sn}  ${unexpected_historical_alarms_list}
  [Documentation]  The keyword will check if proper HW has the fault. The time of disapperances can differ in webem
  ...  in case of bigger configurations. Minimum time is 30 seconds.
  FOR  ${alarm}  IN  @{unexpected_historical_alarms_list}
    ${hw_release_bool}=  Run Keyword And Return Status
    ...  Evaluate  re.search(r'\\d+\\.\\d+\|d+', '${cfg.RF_INFO['${ru_sn}']['scf_release_code']}').group(0)  re
    ${hw_release}=  Run Keyword If  ${hw_release_bool}==True
    ...  Evaluate  re.search(r'\\d+\\.\\d+\|d+', '${cfg.RF_INFO['${ru_sn}']['scf_release_code']}').group(0)  re
    IF  ${hw_release_bool} == True and ${hw_release} < 5.1
      ${is_other}  Set Variable  ${cfg.RF_INFO['${ru_sn}']['scf_release_code']}
      IF  '${is_other}' == '5GRU5.0'
        Set Test Variable  ${hw_release_bool}  False
      END
    END
    Run Keyword If  ${hw_release_bool}==True  Exit For Loop If  ${hw_release}<5.1
    ${hw_release_string}=  Set Variable If  ${hw_release_bool}==False  ${cfg.RF_INFO['${ru_sn}']['scf_release_code']}
    Continue For Loop If  '${hw_release_string}' in $FID4589_RELEASE_LESS_THAN_5_1_STRING_LIST
    Run Keyword And Continue On Failure
    ...  Run Keyword If
    ...  ${hw_release_bool}==False and '${hw_release_string}' not in $FID4589_RELEASE_STRING_LIST
    ...  Run Keyword
    ...  Fail
    ...  Check HW release code if not implemented in KW or synchronization (check if time skip exists in IMS when fault 4589 is active).
    ${faultId}=  Get From Dictionary  dictionary=${alarm}
    ...  key=faultId
    Continue For Loop If  ${faultId}!=4589
    ${fid_4589_severity}=  Set Variable  False
    ${hw_correct}=  Set Variable  False
    Log  FID4589: Checking severity
    ${severity}=  Get From Dictionary  dictionary=${alarm}
    ...  key=severity
    ${fid_4589_severity}=  Run Keyword If  ${alarm['severity']}==Warning
    ...  Set Variable  ${True}
    ...  ELSE  Set Variable  ${False}
    Continue For Loop If  ${fid_4589_severity}==${False}
    ${hw_correct}=  Run Keyword If  '${alarm['serialNo']}'=='${ru_sn}'
    ...  Set Variable  ${True}
    ...  ELSE  Set Variable  ${False}
    Continue For Loop If  ${hw_correct}==${False}
    ${disappear_alarm_time}=  Get From Dictionary  dictionary=${alarm}  key=disappearTime
    ${disappear_alarm_time_str}=  Convert To String  ${disappear_alarm_time}
    ${disappear_alarm_time_split}=  Get Substring  string=${disappear_alarm_time_str}  start=6  end= -3
    ${disappear_alarm_time_split_int}=  Convert To Integer  ${disappear_alarm_time_split}
    ${event_date_alarm}=  Get From Dictionary  dictionary=${alarm}  key=eventTime
    ${event_date_alarm_str}=  Convert To String  ${event_date_alarm}
    ${event_date_alarm_split}=  Get Substring  string=${event_date_alarm_str}  start=6  end= -3
    ${event_date_alarm_split_int}=  Convert To Integer  ${event_date_alarm_split}
    ${diff}=  Run Keyword And Continue On Failure
    ...  Evaluate  ${disappear_alarm_time_split_int} - ${event_date_alarm_split_int} <= ${FID_4589_DISAPPEAR_TIMEOUT}
    Run Keyword If  ${fid_4589_severity}==True and ${hw_correct}==True and ${diff}==True
    ...  admin.Add Allowed Alarm  faultId=4589, distName=${alarm}[distName]  alias=${ru_bts_id}
  END

Verify FID 4589
  [Arguments]  ${node}
  ${rf_list}=  Get Dictionary Keys  ${cfg.RF_INFO}
  FOR  ${ru_sn}  IN  @{rf_list}
    Run Keyword And Continue On Failure
    ...  admin.Assert Alarm Inactive  faultId=4589, severity=Warning  alias=${node}  timeout=${FID_4589_DISAPPEAR_TIMEOUT}
    ${unexpected_historical_alarms_list}=  admin.Get Unexpected Historical Alarms  connection=${node}
    Run Keyword If  ${unexpected_historical_alarms_list} is not None
    ...  Check For Alarm 4589  ${node}  ${ru_sn}  ${unexpected_historical_alarms_list}
  END
  ${unexpected_historical_alarms_list}=  admin.Get Unexpected Historical Alarms  connection=${node}
  ${4589_not_present}=  Set Variable  ${True}
  ${4589_not_present}=  Run Keyword If  ${unexpected_historical_alarms_list} is not None
  ...  Verify FID 4589 in historical alarms  ${unexpected_historical_alarms_list}  ${4589_not_present}
  ${4589_not_in}=  Set Variable If  ${4589_not_present}!= ${False}  ${True}
  Run Keyword If  ${4589_not_in}  Append To List  ${GLO_ADMIN_ALLOWED_ALARMS}  faultId=4589, severity=Warning


Verify FID 4589 in historical alarms
  [Arguments]  ${unexpected_historical_alarms_list}  ${4589_not_present}
  FOR  ${alarm}  IN  @{unexpected_historical_alarms_list}
    ${faultId}=  Get From Dictionary  dictionary=${alarm}  key=faultId
    ${4589_not_present}=  Set Variable If  ${faultId}==4589  ${False}
    Run Keyword And Continue On Failure
    ...  Run Keyword If
    ...  ${faultId}==4589
    ...  Fail
    ...  Check HW release code if not implemented in KW or synchronization (check if time skip exists in IMS when fault 4589 is active).
  END
  [Return]  ${4589_not_present}

Check For Alarm 1815
  [Documentation]
  ...  Gets list of unexpected historical alarms frim BTS.
  ...  If there is FID1815 on the list further reasoning is triggered.
  ...
  ...  |  **Author:**  dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com
  ...
  ...  **Input Parameters:**
  ...
  ...  +--------------+------+--------------------------------------------------+
  ...  | Parameter  | Man. | Description  |
  ...  +==============+======+==================================================+
  ...  | ru_bts_id  | Yes  | BTS ID used for infomodel connection  |
  ...  +--------------+------+--------------------------------------------------+
  [Arguments]  ${ru_bts_id}

  ${unexpected_historical_alarms_list}=  admin.Get Unexpected Historical Alarms  connection=${ru_bts_id}
  Run Keyword If  $unexpected_historical_alarms_list is not None
  ...  Analyze Unexpected Historical Alarms  unexpected_historical_alarms_list=${unexpected_historical_alarms_list}
  ...  ru_bts_id=${ru_bts_id}

Analyze Unexpected Historical Alarms
  [Documentation]
  ...  Analyzes unexpected historical alarms list to determine based on FID if given alarm should undergo
  ...  further analysis and potentially become allowed occurence
  ...
  ...  |  **Author:**  dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com
  ...
  ...  **Input Parameters:**
  ...
  ...  +-----------------------------------+------+--------------------------------------+
  ...  | Parameter  | Man. | Description  |
  ...  +===================================+======+======================================+
  ...  | unexpected_historical_alarms_list | Yes  | list of unexpected historical alarms |
  ...  +-----------------------------------+------+--------------------------------------+
  ...  | ru_bts_id  | Yes  | BTS ID used for infomodel connection |
  ...  +-----------------------------------+------+--------------------------------------+
  [Arguments]  ${unexpected_historical_alarms_list}  ${ru_bts_id}

  ${bts_info}=  Admin Get BTS Info Into Dictionary  ${ru_bts_id}
  FOR  ${alarm}  IN  @{unexpected_historical_alarms_list}
    ${fid_1815_is_expected}=  Set Variable  ${TRUE}
    ${faultId}=  Get From Dictionary  dictionary=${alarm}
    ...  key=faultId
    ${fid_1815_is_expected}=  Run Keyword If  ${faultId}!=1815
    ...  Set Variable  ${FALSE}
    ...  ELSE  Check If FID1815 Is Expected  alarm=${alarm}
    ...  ru_bts_id=${ru_bts_id}
    ...  bts_info=${bts_info}
    ...  fid_1815_is_expected=${fid_1815_is_expected}
    Run Keyword If  ${fid_1815_is_expected} == ${TRUE}
    ...  admin.Add Allowed Alarm  distName=${alarm}[distName]  connection=${ru_bts_id}
  END

Check If FID1815 Is Expected
  [Documentation]
  ...  Analyzes given FID1815 entry from unexpected historical alarm list to determined if it should be
  ...  expected under given circumstances
  ...
  ...  |  **Author:**  dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com
  ...
  ...  **Input Parameters:**
  ...
  ...  +----------------------+------+------------------------------------------------------+
  ...  | Parameter  | Man. | Description  |
  ...  +======================+======+======================================================+
  ...  | alarm  | Yes  | single unexpected historical alarm list entry  |
  ...  +----------------------+------+------------------------------------------------------+
  ...  | ru_bts_id  | Yes  | BTS ID used for infomodel connection  |
  ...  +----------------------+------+------------------------------------------------------+
  ...  | bts_info  | Yes  | dictionary containing infomodel objects informations |
  ...  +----------------------+------+------------------------------------------------------+
  ...  | fid_1815_is_expected | Yes  | variable for storing analysis verdict  |
  ...  +----------------------+------+------------------------------------------------------+
  ...
  ...  **Return parameters**
  ...
  ...  +----------------------+-------------------------------------------+
  ...  | Parameter  | Description  |
  ...  +======================+===========================================+
  ...  | fid_1815_is_expected | variable for storing analysis verdict  |
  ...  +----------------------+-------------------------------------------+
  [Arguments]  ${alarm}  ${ru_bts_id}  ${bts_info}  ${fid_1815_is_expected}

  Log  FID1815: Checking severity
  ${severity}=  Get From Dictionary  dictionary=${alarm}
  ...  key=severity
  ${fid_1815_is_expected}=  Run Keyword If  $severity not in $FID1815_ALLOWED_SEVERITY_LIST
  ...  Set Variable  ${FALSE}
  ...  ELSE  Set Variable  ${fid_1815_is_expected}
  Log  FID1815: Checking cablink protocol type
  ${notifier}=  Get From Dictionary  dictionary=${alarm}
  ...  key=notifier
  ${notifier}=  Fetch From Right  string=${notifier}
  ...  marker=]${SPACE}
  ${cables_info}=  Get From Dictionary  dictionary=${bts_info}
  ...  key=cables
  FOR  ${cable}  IN  @{cables_info}
    ${alarming_resource}=  Set Variable If  "${cable['id']['runtime']}" == "${notifier}"
    ...  ${cable['id']['internal']}
    Exit For Loop If  "${cable['id']['internal']}" == "${alarming_resource}"
  END
  ${cablink_parameters}=  admin.Get Parameters For  class_name=CABLINK
  ...  id_num=${alarming_resource}
  ...  alias=${ru_bts_id}
  ${fid_1815_is_expected}=  Run Keyword If  '${cablink_parameters}[cablinkType]'!='CPRILink'
  ...  Set Variable  ${FALSE}
  ...  ELSE  Set Variable  ${fid_1815_is_expected}
  Log  FID1815: Checking HW model
  ${first_endpoint_class_name}=  Fetch From Right  string=${cablink_parameters}[firstEndpointDN]
  ...  marker=/
  ${first_endpoint_class_name}=  Fetch From Left  string=${first_endpoint_class_name}
  ...  marker=_
  ${first_endpoint_parameters}=  admin.Get Parameters For  ${first_endpoint_class_name}
  ...  ${cablink_parameters}[firstEndpointDN]
  ...  alias=${ru_bts_id}
  ${fid_1815_is_expected}=  Run Keyword If  $first_endpoint_parameters['productName'] not in $FID1815_ALLOWED_HW_LIST
  ...  Set Variable  ${FALSE}
  ...  ELSE  Set Variable  ${fid_1815_is_expected}
  ${second_endpoint_class_name}=  Fetch From Right  string=${cablink_parameters}[secondEndpointDN]
  ...  marker=/
  ${second_endpoint_class_name}=  Fetch From Left  string=${second_endpoint_class_name}
  ...  marker=_
  ${second_endpoint_parameters}=  admin.Get Parameters For  ${second_endpoint_class_name}
  ...  ${cablink_parameters}[secondEndpointDN]
  ...  alias=${ru_bts_id}
  ${fid_1815_is_expected}=  Run Keyword If  $second_endpoint_parameters['productName'] not in $FID1815_ALLOWED_HW_LIST
  ...  Set Variable  ${FALSE}
  ...  ELSE  Set Variable  ${fid_1815_is_expected}
  Log  FID1815: Checking expected linkbreak events
  ${observation_time_in_epoch}=  Format Timestamp To Epoch  timestamp_to_format=${alarm}[btsObservationTime]
  @{affected_hw_list}=  Create List  ${cablink_parameters}[firstEndpointDN]
  ...  ${cablink_parameters}[secondEndpointDN]
  ${is_expected_linkbreak_event}=  Set Variable  ${FALSE}
  FOR  ${link_brake_event}  IN  @{EXPECTED_LINK_BREAK_LIST}
    ${event_in_timewindow}=  Evaluate
    ...  ${link_brake_event}[timestamp] <= ${observation_time_in_epoch} <= (${link_brake_event}[timestamp] + ${FID1815_TIMEOUT})
    ${event_HW_matches_expected}=  Run Keyword And Return Status
    ...  List Should Contain Value  ${affected_hw_list}
    ...  ${link_brake_event}[ru_dist_name]
    ${is_expected_linkbreak_event}=  Set Variable If  ${event_in_timewindow} and ${event_HW_matches_expected}
    ...  ${TRUE}
  END
  ${fid_1815_is_expected}=  Run Keyword If  ${is_expected_linkbreak_event} == ${FALSE}
  ...  Set Variable  ${FALSE}
  ...  ELSE  Set Variable  ${fid_1815_is_expected}
  [Return]  ${fid_1815_is_expected}

Format Timestamp To Epoch
  [Documentation]
  ...  Converts timestamp in format as recived in historical alarm json list to epoch time adjusted to UTC
  ...
  ...  |  **Author:**  dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com
  ...
  ...  **Input Parameters:**
  ...
  ...  +----------------------+------+------------------------------------+
  ...  | Parameter  | Man. | Description  |
  ...  +======================+======+====================================+
  ...  | timestamp_to_format | Yes  | timestamp to be formated  |
  ...  +---------------------+------+-------------------------------------+
  ...
  ...  **Return parameters**
  ...
  ...  +---------------------+-------------------------------------------+
  ...  | Parameter  | Description  |
  ...  +=====================+===========================================+
  ...  | timestamp_in_epoch  | input timestamp formated to epoch in UTC |
  ...  +---------------------+------------------------------------------+
  [Arguments]  ${timestamp_to_format}

  ${timestamp}=  Get Substring  string=${timestamp_to_format}  start=0  end=-5
  ${timezone}=  Get Substring  string=${timestamp_to_format}  start=-5
  ${timezone_sign}=  Get Substring  string=${timezone}  start=0  end=1
  ${timezone_hours}=  Get Substring  string=${timezone}  start=1  end=3
  ${timezone_hours}=  Set Variable  ${timezone_sign}${timezone_hours}
  ${timezone_hours}=  Convert To Integer  item=${timezone_hours}  base=10
  ${timezone_minutes}=  Get Substring  string=${timezone}  start=-2
  ${timezone_minutes}=  Set Variable  ${timezone_sign}${timezone_minutes}
  ${timezone_minutes}=  Convert To Integer  item=${timezone_minutes}  base=10
  ${timestamp_in_epoch}=  Convert Date  date=${timestamp}  date_format=%Y%m%d%H%M%S.%f  result_format=epoch
  ${timestamp_in_epoch}=  Evaluate  ${timestamp_in_epoch}-(3600*${timezone_hours})-(60*${timezone_minutes})
  [Return]  ${timestamp_in_epoch}

Check Mandatory Alarm Active List
  [Arguments]  ${ru_bts_id}  ${alarm_list}  ${timeout}
  FOR  ${alarm}  IN  @{alarm_list}
    Run Keyword And Continue On Failure
    ...  admin.Assert Alarm Active  ${alarm}
    ...  timeout=${timeout}
    ...  alias=${ru_bts_id}
  END

Check Mandatory Alarm InActive List
  [Arguments]  ${ru_bts_id}  ${alarm_list}  ${timeout}
  FOR  ${alarm}  IN  @{alarm_list}
    Run Keyword And Continue On Failure
    ...  admin.Assert Alarm Inactive  ${alarm}
    ...  timeout=${timeout}
    ...  alias=${ru_bts_id}
  END

Check Affected Cells Sharing Status
  [Arguments]  ${ru_bts_id}  ${cell_ru_sn_list}  ${cell_type}
  ${share_type}=  Set Variable If  '${cell_type}'=='LNCEL'  scf_cell_2T2R_shared  scf_cell_ru_shared
  ${cell_ru_sn_list}=  Convert Item To Single Element List  ${cell_ru_sn_list}
  ${cell_ru_sn_list}=  Remove Duplicates  ${cell_ru_sn_list}
  FOR  ${cell_id}  IN  @{cell_ru_sn_list}
    ${cell_is_shared}=  Get From Dictionary  ${cfg.NODES['${ru_bts_id}']['${cell_type}']['${cell_id}']}  ${share_type}
    Exit For Loop If  ${cell_is_shared}
  END
  [Return]  ${cell_is_shared}

Create Alarm 4003 List
  [Arguments]  ${ru_bts_id}  ${ru_sn_list}  ${cell_type}
  ${ru_sn_list}=  Convert Item To Single Element List  ${ru_sn_list}
  ${ru_sn_list}=  Remove Duplicates  ${ru_sn_list}
  ${alarm_list}=  Create List
  FOR  ${cell_id}  IN  @{ru_sn_list}
    ${cell_id}=  Get Cell Id By Configuration Id  ${cell_type}  ${cell_id}  30  alias=${ru_bts_id}
    ${impactedCellsList}=  create list  ${cell_id}
    Append To List  ${alarm_list}  faultId=4003, impactedCellsList=${impactedCellsList}
  END
  admin.Add Allowed Alarm    faultId=4003, severity=Minor  alias=${ru_bts_id}
  [Return]  ${alarm_list}

Verify RU Power Remove Insert State
  [Arguments]  ${bts_id}  ${dist_name}  ${state}  ${timeout}
  Log  \nRU State Check Admin procedure started  console=True
  ${asirmod_status}=  Run Keyword And Return Status  Should Match Regexp  ${dist_name}  ASIRMOD
  ${class}=  Set Variable If  ${asirmod_status}  ASIRMOD  RMOD
  ${status}=  Run Keyword If  "${state}" == "Remove"
  ...  Run Keyword And Continue On Failure  admin.Assert
  ...  ${class}
  ...  ${dist_name}
  ...  operationalState=regex"(?i)Disabled", availabilityStatus=regex"(?i)off\\s?line|not\\s?installed|failed"
  ...  timeout=${timeout}
  ...  alias=${bts_id}
  ...  ELSE  Run Keyword And Continue On Failure  admin.Assert
  ...  ${class}
  ...  ${dist_name}
  ...  operationalState=regex"(?i)Enabled"
  ...  timeout=${timeout}
  ...  alias=${bts_id}
  ${date}=  Run Keyword If  ${status}
  ...  Get Current Date  UTC
  ...  ELSE  Set Variable  {0}
  Set Test Variable  ${ru_startup_end_date}  ${date}
  ${ru_status}=  admin.Get Parameters For  ${class}  ${dist_name}  timeout=${timeout}  alias=${bts_id}
  [Return]  ${ru_startup_end_date}

Verify RU Power Remove Insert State For Affected RUs
  [Arguments]  ${bts_id}  ${ru_sn}  ${state}  ${timeout}
  ${rim_affected_list}=  Create RIM Affected Units  ${ru_sn}
  ${fr_affected_list}=  Create List  @{cfg.RF_INFO['${ru_sn}']['scf_chain_fr_affected_list']}
#  ${status}=  Evaluate  type(${rim_affected_list})
#  ${rim_status}=  Set Variable If  '${status}' != 'list'  ${False}  ${True}
  Append To List  ${fr_affected_list}  @{rim_affected_list}
  FOR  ${ru_id}  IN  @{fr_affected_list}
    ${ru_id_dist_name}=  Get From Dictionary  ${cfg.RF_INFO['${ru_sn}']}  scf_dist_name_primary
    ${asirmod_status}=  Run Keyword And Return Status  Should Match Regexp  ${ru_id_dist_name}  ASIRMOD
    ${class}=  Set Variable If  ${asirmod_status}  ASIRMOD  RMOD
    ${ru_bts_id}  ${ru_id_dist_name}=  Get RU Node Data  ${ru_id}
    ${status}=  Run Keyword And Return Status  Run Keyword If  "${state}" == "Remove"
    ...  Run Keyword And Continue On Failure  admin.Assert
    ...  ${class}
    ...  ${ru_id_dist_name}
    ...  operationalState=regex"(?i)Disabled", availabilityStatus=regex"(?i)off\\s?line|not\\s?installed"
    ...  timeout=${timeout}
    ...  alias=${bts_id}
    ...  ELSE  Run Keyword And Continue On Failure  admin.Assert
    ...  ${class}
    ...  ${ru_id_dist_name}
    ...  operationalState=regex"(?i)Enabled"
    ...  timeout=${timeout}
    ...  alias=${bts_id}
  END

Create RIM Affected Units
  [Arguments]  ${ru_sn}

  ${rim_affected_list}=  Create List

  ${bts_id}=  Get From Dictionary  ${cfg.RF_INFO['${ru_sn}']}  scf_btsid_primary

  ${tl_status}=  Run Keyword And Return Status    Variable Should Exist    ${TL}
  ${object}=  Run Keyword If    ${tl_status}  Find Init Object Using Attribute Value  ${TL}  ${ru_sn}
  ${object_status}=  Run Keyword And Return Status    Should Be True    ${object}
  ${model}  ${version}  ${pdu_ip}  ${pdu_port}=  Run Keyword If  not ${object_status}  Create PDU Description  ${serial_number}
  ${pdu_port}=  Set Variable If  not ${object_status}  ${pdu_port}  ${object.pdu_port.port_no}
  ${version}=   Set Variable If  not ${version}   default    ${object.pdu_port.version}
  ${model}=   Set Variable If  not ${model}   default    ${object.pdu_port.model}

  FOR  ${serial_number}  IN  @{cfg.NODES['${bts_id}']['scf_hw_fr_list']}
    ${tl_status}=  Run Keyword And Return Status    Variable Should Exist    ${TL}
    ${object}=  Run Keyword If    ${tl_status}  Find Init Object Using Attribute Value  ${TL}  ${serial_number}
    ${object_status}=  Run Keyword And Return Status    Should Be True    ${object}
    ${model}  ${version}  ${ip_addr}  ${port}=  Run Keyword If  not ${object_status}  Create PDU Description  ${serial_number}
    ${pdu_port}=  Set Variable If  not ${object_status}  ${pdu_port}  ${object.pdu_port.port_no}

    Run Keyword If
    ...  ("${ip_addr}" == "${pdu_ip}" and "${port}" == "${pdu_port}")
    ...  Append To List  ${rim_affected_list}  ${serial_number}
  END
  Remove Values From List  ${rim_affected_list}  ${ru_sn}
  [Return]  ${rim_affected_list}

Verify RU Startup Time
  [Arguments]  ${startup_type}  ${cfg}  ${ru_bts_id}  ${ru_startup_start_date}  ${ru_startup_end_date}
  ${time_diff}=  Run Keyword And Continue On Failure
  ...  Subtract Date From Date
  ...  ${ru_startup_end_date}
  ...  ${ru_startup_start_date}
  ${ru_startup_status}=  Set Variable If  ${RU_STARTUP_TIME} > ${time_diff}  True  False
  Run Keyword And Continue On Failure
  ...  Run Keyword If
  ...  "${ru_startup_status}" == "False" and ${ACTIVE_STARTUP_VERDICT}
  ...  Run Keywords
  ...  Logging With Timestamp
  ...  Specified RF startup time (${time_diff} second) was exceeded. Expected time= ${RU_STARTUP_TIME}
  ...  console=yes
  ...  AND
  ...  Run Keyword And Continue On Failure
  ...  Fail
  ...  Specified startup time (${RU_STARTUP_TIME} second) was exceeded.
  ...  ELSE
  ...  Logging With Timestamp
  ...  Specified RF startup time (${time_diff} second). Expected time= ${RU_STARTUP_TIME}
  ...  console=yes
#  Run keyword if  ${out_bts_startup_time} > ${SPECIFIED_STARTUP_TIME}  Fail  Specified startup time
#  Log  \nRU startup time = ${time_diff} seconds  console=True
  [Return]  ${ru_startup_status}  ${time_diff}


Power Reset On Node
  Set Tags     AUTHOR-piotr.korczynski@nokia.com  MAINTAINER-piotr.korczynskia@nokia.com
  Common Test Setup
  Logging With Timestamp
  ...  message=Power Reset On Node on list : @{CFG.active_bts_list} will be executed
  ...  style=ONGOING
  FOR  ${bts}  IN  @{CFG.active_bts_list}
    Execute Power Reset On Node  ${test_logs_path}  ${bts}
    Verify BTS State  ${bts}  ${CONFIGURATION_STARTUP_TIMEOUT}
    Verify Power Reset Startup Parameters  ${test_logs_path}  ${bts}
    Verify FID 4589  ${bts}
    Wait Until Keyword Succeeds  120 sec  5 sec  Verify Unexpected And Historical Alarms  alias=${bts}
    Verify Reset Site Historical Alarms  alias=${bts}
  END
  [Teardown]    Common Test Teardown

Execute Power Reset On Node
  [Arguments]  ${test_logs_path}  ${node}
  Log  \nPower Reset on bts_id node=${node} started  console=True
  PDU Switch OFF Device Lists
  ...  ${cfg.NODES['${node}']['scf_hw_sm_list']}
  PDU Switch OFF Device Lists
  ...  ${cfg.NODES['${node}']['scf_hw_fr_list']}
  Sleep  20 sec
  PDU Switch ON Device Lists
  ...  ${cfg.NODES['${node}']['scf_hw_sm_list']}
  ${power_start_timestamp}=  Get Current Date  UTC
  Set Test Variable  ${power_start_timestamp}  ${power_start_timestamp}
  PDU Switch ON Device Lists
  ...  ${cfg.NODES['${node}']['scf_hw_fr_list']}
  Log  Power Reset on bts_id node=${node} finished  console=True
  CM BTS Admin Not Available  ${node}  120
  STATE.STATE BTS Address Is NOT Pingable  bts_id=${node}
  Sleep  120 sec
  Wait Until Keyword Succeeds  240 sec  20 sec  admin.Reset Admin  connection=${node}
#  Logging Session Multinode Restart
#  ...  logs_dir=${test_logs_path}
  Sleep  60 sec
  [Teardown]  Run Keyword If  '${KEYWORD STATUS}'!='PASS'  Run Keywords
  ...  PDU Switch ON Device Lists
  ...  ${cfg.NODES['${node}']['scf_hw_sm_list']}
  ...  AND
  ...  PDU Switch ON Device Lists
  ...  ${cfg.NODES['${node}']['scf_hw_fr_list']}


BB Reset On Every Node
  Set Tags     AUTHOR-piotr.korczynski@nokia.com  MAINTAINER-piotr.korczynskia@nokia.com
  Common Test Setup
  Logging With Timestamp
  ...  message=Execute Recommissioning On Every Node on list : @{CFG.active_bts_list} will be executed
  ...  style=ONGOING
  FOR  ${bts}  IN  @{CFG.active_bts_list}
    Perform BB Reset Procedure  ${cfg}  ${bts}
  END
  [Teardown]    Common Test Teardown

Execute BB Reset On Every Node
  [Arguments]  ${cfg}
  FOR  ${bts_id}  IN  @{cfg.active_bts_list}
    Perform BB Reset Procedure  ${cfg}  ${bts_id}
  END

Perform BB Reset Procedure
  [Arguments]  ${cfg}  ${bts_id}  ${timeout}=500 sec
  ${private_bb_list_status}=  Run Keyword And Return Status  Variable Should Exist  ${BB_LIST}
  ${bb_new_list}=  Set Variable If  ${private_bb_list_status}  ${BB_LIST}  ${cfg.NODES['${bts_id}']['scf_hw_bbmod_list']}
  ${bb_parameters_list}=  admin.Get Parameters For All  BBMOD  alias=${bts_id}
  FOR  ${bb}  IN  @{bb_new_list}
    Perform BB Reset  ${bts_id}  ${bb}  ${bb_parameters_list}  ${timeout}
    Verify BTS State  ${bts_id}  ${timeout}
    Verify HW Node state  ${cfg}  ${bts_id}
    Verify Unexpected And Historical Alarms  alias=${bts_id}
  END

Perform BB Reset
  [Arguments]  ${bts_id}  ${bb}  ${bb_parameters_list}  ${timeout}=30 sec
  Log  \nBB ${bb} Reset Admin procedure started  console=True
  FOR  ${key}  IN  @{bb_parameters_list}
    ${dist_name}=  Set Variable  ${key.id}
    Exit For Loop If  '${bb}'=='${key.serialNumber}'
  END
  ${status}=  Run Keyword And Continue On Failure  admin.Reset Unit
  ...  dist_name=${dist_name}
  ...  reset_type=Warm
  ...  timeout=${timeout}
  ...  detailed_output=True
  ...  alias=${bts_id}
  [Teardown]  Log  \nBB ${bb} Reset Admin procedure finished. Status = ${status}  console=True

Execute BB Pool Reset On Every Node
  Set Tags     AUTHOR-piotr.korczynski@nokia.com  MAINTAINER-piotr.korczynskia@nokia.com
  Common Test Setup
  Logging With Timestamp
  ...  message=Execute Recommissioning On Every Node on list : @{CFG.active_bts_list} will be executed
  ...  style=ONGOING
  FOR  ${bts}  IN  @{CFG.active_bts_list}
    Perform BB Pool Reset Procedure  ${cfg}  ${bts}
  END
  [Teardown]    Common Test Teardown

Perform BB Pool Reset Procedure
  [Arguments]  ${cfg}  ${bts_id}  ${timeout}=900 sec
  ${query}=  admin_im.Query Infomodel
  ...  query=get list //MRBTS_R-*/MNL_CONF_M-*/MNLENT_CONF_M-*/BBADM_R-*/BBPOOL_R-*
  ...  timeout=120
  ...  alias=${bts_id}
  ${pool_id_list}=  create list
  FOR  ${item}  IN  @{query}
    ${pool}=  Get From Dictionary  ${item}  dist_name
    ${query}=  Run Keyword And Return Status  admin_im.Query Infomodel
    ...  query=check ${pool} is [bbPoolCellsList!=empty]
    ...  timeout=5
    ...  alias=${bts_id}
    Continue For Loop If  not ${query}
    ${_}  ${pool_id}=  Split String From Right  ${pool}  -  max_split=1
    Append To List
    ...  ${pool_id_list}
    ...  MRBTS-${bts_id}/MNL-${cfg.NODES['${bts_id}']['scf_active_node']}/MNLENT-1/BBADM-1/BBPOOL-${pool_id}
  END
  FOR  ${bb}  IN  @{pool_id_list}
    Logging With Timestamp
    ...  \nBB Pool ${bb} Reset Loop started  console=True
    ${bbpool_reset_status}=  Run Keyword And Continue On Failure
    ...  admin_im.Query Infomodel
    ...  query=none /HWRESETREQ_A-*
    ...  timeout=${timeout}
    ...  alias=${bts_id}
    ${bbpool_reset_status}=  Run Keyword And Continue On Failure
    ...  admin_im.Query Infomodel
    ...  query=none /MRBTS-1/RAT-1/URI-1/SESSION-*/PLAN_ACTIVATE_IND-*
    ...  timeout=${timeout}
    ...  alias=${bts_id}
    Perform BB Pool Reset  ${bts_id}  ${bb}  ${timeout}
    ${bbpool_reset_status}=  Run Keyword And Continue On Failure
    ...  admin_im.Query Infomodel
    ...  query=none /MRBTS-1/RAT-1/URI-1/SESSION-*/PLAN_VALIDATE_IND-*
    ...  timeout=${timeout}
    ...  alias=${bts_id}
    Verify BTS State  ${bts_id}  ${timeout}
    Verify HW Node state  ${cfg}  ${bts_id}
    Verify Unexpected And Historical Alarms  alias=${bts_id}
    Logging With Timestamp
    ...  \nBB Pool ${bb} Reset Loop finished  console=True
  END

Perform BB Pool Reset
  [Arguments]  ${bts_id}  ${bb}  ${timeout}=30 sec
  Logging With Timestamp
  ...  \nBB Pool ${bb} Reset Admin procedure started  console=True
  ${bb_pool_tmp_list}=  create list  ${bb}
  Sleep  40 sec
  ${status}=  Run Keyword And Continue On Failure  Reset bbpool
  ...  bbpool_array=${bb_pool_tmp_list}
  ...  timeout=${timeout}
  ...  alias=${bts_id}
  Logging With Timestamp
  ...  \nBB Pool ${bb} Reset Admin procedure finished, status = ${status}  console=True

Static Power Saving For ABIO And ASOE On Every Node
  ${node_list}=  Get Dictionary Keys  ${cfg.NODES}
  Log To Console  Validating HW and SCF parameters on every node...
  FOR  ${node}  IN  @{node_list}
    # Step 1: Validate HW. Only ABIO and ASOF allowed
    ${detected_hw}=  Check HW For Static Power Saving  ${node}
    Log To Console  ${detected_hw} has been detected on node ${node}
    # Step 1a: Validate if actPowerMeter is true and mtBtsEnergyMonitoring, mtSBTSSmEnergyMonitoring, mtSBTSRfmEnergyMonitoring are 15min
    # Step 2: Check if both Power Groups on LOKI A are allocated
    # Step 2a (optional): RMOD should be commissioned on LOKI A FH. No RMOD on LOKI B FH Ports
    Check SCF For Static Power Saving  node=${node}  pwr_grp_2_enabled=${True}
  END
  FOR  ${node}  IN  @{node_list}
    # Step 3 (QC1): Measure average power consumption with BTS counters
    Log To Console  First measurement (power saving off)
    ${avg_m1_M40002C0}  ${avg_m1_M40004C0}=  Measure Average Of M40002C0 and M40004C0  node=${node}  delay=45min

    # Step 4 (QC2): Remove enough cells to make IQ forwarding redundant (recommissioning to minimal SCF)
    ${actual_scf_name}=  Get From Dictionary  ${cfg}  CN
    ${actual_scf_path}=  Get From Dictionary  ${cfg.NODES['${node}']}  scf_file_path
    # ${recommissioning_scf_name}=  Get From Dictionary  ${cfg}  PowerSavingSCF
    ${recommissioning_scf_name}=  Set Variable  ${actual_scf_name}_PowerSaving
    ${recommissioning_scf_path}=  Replace String Using Regexp
    ...  ${cfg.NODES['${node}']['scf_file_path']}  ${actual_scf_name}  ${recommissioning_scf_name}
    Recommissioning Node From File  node=${node}  path=${recommissioning_scf_path}  refresh_cfg=${True}
    Verify BTS State  ${node}
    Verify Alarms  alias=${node}
    # Step 5 (QC3): Perform site reset and wait for OnAir. Optional PWR GRP should be disabled (check POWERGROUP_R-2.operationalState == disabled)
    Check SCF For Static Power Saving  node=${node}  pwr_grp_2_enabled=${False}

    # Step 6 (QC4): Measure average power consumption with BTS counters
    Log To Console  Second measurement (power saving on)
    ${avg_m2_M40002C0}  ${avg_m2_M40004C0}=  Measure Average Of M40002C0 and M40004C0  node=${node}  delay=45min

    # Step 7 (QC5): Compare both measurements. M2 < M1
    Log To Console
    ...  Comparing first measurement (M1:${avg_m1_M40002C0}) of M40002C0 with second one (M2:${avg_m2_M40002C0}). M1 should be higher than M2
    Should Be True
    ...  ${avg_m1_M40002C0} > ${avg_m2_M40002C0}
    ...  First measurement of PM Counter M40002C0 should be higher than second one
    Log To Console
    ...  Comparing first measurement (M:1${avg_m1_M40004C0}) of M40004C0 with second one (M2:${avg_m2_M40004C0}). M1 should be higher than M2
    Should Be True
    ...  ${avg_m1_M40004C0} > ${avg_m2_M40004C0}
    ...  First measurement of PM Counter M40004C0 should be higher than second one
  END
  [Teardown]  Remove From Dictionary  ${cfg}  conf_name

Check HW For Static Power Saving
  [Arguments]  ${node}
  ${allowed_smod_list}=  Create List  ASOE AirScale Core  ASOF AirScale Core
  ${allowed_bbmod_list}=  Create List  ABIO AirScale Capacity  # How about ABIN AirScale Capacity?
  ${hw_info}=  admin.Get Detected HW Info  connection=${node}
  FOR  ${smod_info}  IN  @{hw_info["systemModules"]}
    Return From Keyword If  '${smod_info["productName"]}' in ${allowed_smod_list}  ${smod_info["productName"]}
  END
  FOR  ${bbmod_info}  IN  @{hw_info["basebandModules"]}
    Return From Keyword If  '${bbmod_info["productName"]}' in ${allowed_bbmod_list}  ${bbmod_info["productName"]}
  END
  Fail  Neither ASOE/ASOF nor ABIO has been detected on ${node}!

Check SCF For Static Power Saving
  [Arguments]  ${node}  ${pwr_grp_2_enabled}
  ${current_scf}=  admin.Get SCF  export_type=configurationAndRuntimeObjects  connection=${node}
  # Checking if actPowerMeter==true, mtBtsEnergyMonitoring==15min, mtSBTSSmEnergyMonitoring==15min, mtSBTSRfmEnergyMonitoring==15min
  ${actPowerMeter}=  Get Element Text  ${current_scf}
  ...  xpath=//managedObject[contains (@class,'FEATCADM')]/p[@name='actPowerMeter']
  ${mtBtsEnergyMonitoring}=  Get Element Text  ${current_scf}
  ...  xpath=//managedObject[contains (@class,'PMMNL')]/p[@name='mtBtsEnergyMonitoring']
  ${mtSBTSSmEnergyMonitoring}=  Get Element Text  ${current_scf}
  ...  xpath=//managedObject[contains (@class,'PMMNL')]/p[@name='mtSBTSSmEnergyMonitoring']
  ${mtSBTSRfmEnergyMonitoring}=  Get Element Text  ${current_scf}
  ...  xpath=//managedObject[contains (@class,'PMMNL')]/p[@name='mtSBTSRfmEnergyMonitoring']
  ${eval_1}=  Evaluate  '${actPowerMeter}'=='true' and '${mtBtsEnergyMonitoring}'=='15min'
  ${eval_2}=  Evaluate  '${mtSBTSSmEnergyMonitoring}'=='15min' and '${mtSBTSRfmEnergyMonitoring}'=='15min'

  ${object_1}=  Set Variable  At least one parameter on node ${node} is not set up correctly\nShould be:
  ${object_2}=  Set Variable
  ...  actPowerMeter==true, mtBtsEnergyMonitoring==15min, mtSBTSSmEnergyMonitoring==15min, mtSBTSRfmEnergyMonitoring==15min
  ${object_sum}=  Set Variable  ${object_1} ${object_2}
  Run Keyword If
  ...  ${eval_1} and ${eval_2}
  ...  Log To Console
  ...  Parameters actPowerMeter, mtBtsEnergyMonitoring, mtSBTSSmEnergyMonitoring, mtSBTSRfmEnergyMonitoring on node ${node} are set up correctly
  ...  ELSE
  ...  Fail
  ...  ${object_sum}
  # Checking state of POWERGROUP_R-2.operationalState (depends on parameter)
  ${powergroup_r2_value}=  Get Element Text
  ...  ${current_scf}
  ...  xpath=//managedObject[contains (@class,'POWERGROUP_R')][contains (@distName, 'POWERGROUP_R-2')]/p[@name='operationalState']
  Run Keyword If
  ...  ('${pwr_grp_2_enabled}' and '${powergroup_r2_value}'=='enabled') or ('not ${pwr_grp_2_enabled}' and '${powergroup_r2_value}'=='disabled')
  ...  Log To Console
  ...  POWERGROUP_R-2.operationalState on node ${node} is set up correctly
  ...  ELSE
  ...  Fail
  ...  Parameter POWERGROUP_R-2.operationalState on node ${node} is not set up correctly
  # TODO: Check if RMOD commissioned to Loki A and no RMOD commissioned on LOKI B FH Ports

Measure Average Of M40002C0 and M40004C0
  [Arguments]  ${node}  ${delay}
  Log to Console  Sleeping ${delay} to collect PM Counters...
  Sleep  ${delay}
  Log To Console  Receiving M40002C0 and M40004C0 PM Counters...
  ${raw_measurement}=  Get Pm Counters  M40002C0,M40004C0  timeout=100s  alias=${node}
  ${all_M40002C0}=  Run Keyword If  "${RELEASE}" == "SBTS24R1"
  ...  Get From Dictionary  ${raw_measurement["BTS"]["BTS"]["MRBTS-${node}"]["SBTS_Energy_Consumption"]}  M40002C0
  ...  ELSE  Get From Dictionary  ${raw_measurement["BTS"]["MRBTS-${node}"]["SBTS_Energy_Consumption"]}  M40002C0
  ${all_M40004C0}=  Run Keyword If
  ...  "${RELEASE}" == "SBTS24R1"
  ...  Get From Dictionary
  ...  ${raw_measurement["BTS"]["SMOD"]["SMOD-1"]["CABINET-1"]["SBTS_SM_Energy_Monitoring"]}
  ...  M40004C0
  ...  ELSE
  ...  Get From Dictionary
  ...  ${raw_measurement["BTS"]["MRBTS-${node}"]["EQM-1"]["APEQM-1"]["CABINET-1"]["SMOD-1"]["SBTS_SM_Energy_Monitoring"]}
  ...  M40004C0

  ${len_M40002C0}=  Get Length  ${all_M40002C0}
  ${avg_M40002C0}=  Evaluate  sum(${all_M40002C0}.values()) / ${len_M40002C0}
  Log To Console  Average of last ${len_M40002C0} M40002C0 PM Counters equals ${avg_M40002C0}
  ${len_M40004C0}=  Get Length  ${all_M40004C0}
  ${avg_M40004C0}=  Evaluate  sum(${all_M40004C0}.values()) / ${len_M40004C0}
  Log To Console  Average of last ${len_M40004C0} M40004C0 PM Counters equals ${avg_M40004C0}
  [Return]  ${avg_M40002C0}  ${avg_M40004C0}

Recommissioning Node From File
  [Arguments]  ${node}  ${path}  ${skip_parameter_relation_errors}=${True}  ${refresh_cfg}=${False}
  Log To Console  Waiting for BTS to be ready for recommissioning...
  Run Keyword And Ignore Error  admin.Wait Sw Update Possible
  ...  bts_ready=True
  ...  readiness_timeout=900
  ...  timeout=1000
  ...  connection=${node}
  Log To Console  Performing recommissioning on node ${node} to ${path}...
  ${recommissioning_status}=  Perform Commissioning  scf_file=${path}
  ...  skip_parameter_relation_errors=${skip_parameter_relation_errors}
  ...  should_activate=True
  ...  timeout=${CONFIGURATION_STARTUP_TIMEOUT}
  ...  alias=${node}
  Log To Console  Waiting for BTS to be ready after recommissioning...
  Run Keyword And Ignore Error  Wait Sw Update Possible
  ...  bts_ready=True
  ...  readiness_timeout=900
  ...  timeout=1000
  ...  connection=${node}


Recommissioning Node From File On Every Node
  ${node_list}=  Get Dictionary Keys  ${cfg.NODES}
  FOR  ${node}  IN  @{node_list}
    Recommissioning Node From File  node=${node}  path=${cfg.NODES['${node}']['scf_file_path']}
  END

Extract Bts Id
  [Arguments]  ${fhs_runtime_dn}
  ${fhs_runtime_dn_str}=  Convert To String  ${fhs_runtime_dn}
  ${mrbts_id}=  Fetch From Left  ${fhs_runtime_dn_str}  marker=/
  ${bts_id}=  Fetch From Right  ${mrbts_id}  marker=-
  [Return]  ${bts_id}

Execute FHS Link Hot Remove Insert On Every Node
  Run keyword  Collect FHS Link List
  ${fhs_sn_alt_conf_list}=  Create List
  ${fhs_alt_conf_list}=  Create List
  ${fhs_sn_alt_conf_list}=  Get Dictionary Keys  ${optical_switch_alt_conf}
  ${fhs_alt_conf_list}=  Get Dictionary Values  ${optical_switch_alt_conf}
  FOR  ${fhs_sn_alt_conf}  IN  @{fhs_sn_alt_conf_list}
    Perform FHS Link Hot Remove Insert  ${fhs_sn_alt_conf}  ${fhs_alt_conf_list}
    Verify Multi BTS State
    Verify Alarms On All Nodes
  END


Perform FHS Link Hot Remove Insert
  [Arguments]  ${fhs_sn_alt_conf}  ${fhs_alt_conf_list}
  FOR  ${fhs_alt_conf}  IN  ${fhs_alt_conf_list}
    ${fhs_runtime_dn}  ${fhs_distname_int}=  Find FHS SN Relation with FHS  ${fhs_sn_alt_conf}
    ${mrbts_id}=  Extract Bts Id  ${fhs_runtime_dn}
    Run Keyword And Ignore Error    Append To List    ${CUSTOM_ADDITIONAL_ALLOWED_FAULTS.common}   faultId=10
    Set Test Variable    ${CUSTOM_ADDITIONAL_ALLOWED_FAULTS}
    Find RMOD Relation with FHS Link  ${mrbts_id}  ${fhs_sn_alt_conf}

    Optical Switch Set Configuration Remove  ${fhs_alt_conf}
    Verify FHS Link Remove Insert State  ${mrbts_id}  ${fhs_distname_int}  Remove  ${FAULT_10_TIMEOUT}
    Verify FHS Link Remove Insert Alarms  ${mrbts_id}  ${fhs_sn_alt_conf}  Remove  ${FAULT_10_TIMEOUT} sec
    Verify Affected RU Power Remove  ${mrbts_id}  ${RMOD_AFFECTED_DN_SN}

    Optical Reconfiguration Tested Configuration   ${cfg.configuration_name}
    Verify FHS Link Remove Insert State  ${mrbts_id}  ${fhs_distname_int}  Insert  ${FR_AVAILABILITY_TIMEOUT} sec
    Verify FHS Link Remove Insert Alarms  ${mrbts_id}  ${fhs_sn_alt_conf}  Insert  ${FR_AVAILABILITY_TIMEOUT} sec
  END

Verify Affected RU Power Remove
  [Arguments]  ${mrbts_id}  ${RMOD_AFFECTED_DN_SN}
  FOR  ${rmod_affected_dn}  IN  @{RMOD_AFFECTED_DN_SN.keys()}
    Verify RU Power Remove Insert State  ${mrbts_id}  ${rmod_affected_dn}  Remove  ${FAULT_10_TIMEOUT} sec
    Verify RU Power Remove Insert State For Affected RUs
    ...  ${mrbts_id}  ${RMOD_AFFECTED_DN_SN['${rmod_affected_dn}']}  Remove  ${FAULT_10_TIMEOUT} sec

    ${ru_cell_dict}=  Create Affected Cell List RF Hot Remove Insert  ${RMOD_AFFECTED_DN_SN['${rmod_affected_dn}']}
    Verify RU Affected Cells  ${mrbts_id}  ${ru_cell_dict}  Remove  ${FAULT_10_TIMEOUT} sec
    Verify RU Power Remove Insert Alarms
    ...  ${mrbts_id}
    ...  ${RMOD_AFFECTED_DN_SN['${rmod_affected_dn}']}
    ...  ${rmod_affected_dn}
    ...  Remove
    ...  ${FAULT_10_TIMEOUT} sec
  END

Verify FHS Link Remove Insert State
  [Arguments]  ${mrbts_id}  ${fhs_distname}  ${state}  ${timeout}
  Log  \nFHS State Check Admin procedure started  console=True
  ${status}=  Run Keyword If  "${state}" == "Remove"
  ...  Run Keyword And Continue On Failure  admin.Assert
  ...  FHS
  ...  ${fhs_distname}
  ...  operationalState=regex"(?i)Disabled", availabilityStatus=regex"(?i)off\\s?line|not\\s?installed"
  ...  timeout=${timeout}
  ...  alias=${mrbts_id}
  ...  ELSE  Run Keyword And Continue On Failure
  ...  admin.Assert  FHS  ${fhs_distname}  operationalState=regex"(?i)Enabled"  timeout=${timeout}  alias=${mrbts_id}
  [Return]  ${status}

Verify FHS Link Remove Insert Alarms
  [Arguments]  ${mrbts_id}  ${fhs_sn_alt_conf}  ${state}  ${timeout}
  [Timeout]  360 sec

  ${specific_alarm}=  Run Keyword And Return Status  Variable Should Exist  ${specific_alarm_detalis}
  Run Keyword If  ${specific_alarm}  Remove Values From List  ${GLO_ADMIN_ALLOWED_ALARMS}  ${specific_alarm_detalis}
  FOR  ${alarm}  IN  @{GLO_ADMIN_ALLOWED_ALARMS}
    admin.Add Allowed Alarm  ${alarm}  alias=${mrbts_id}
  END

  ${alarm_severity}=  Set Variable  Critical
  Run Keyword If  '${state}' == 'Remove'  admin.Add Allowed Alarm  faultId=10, severity=${alarm_severity}  alias=${mrbts_id}
  ${alarm_list}=  Create List  faultId=10, severity=${alarm_severity}

  admin.Get Alarms  alias=${mrbts_id}
  ${specific_alarm_state_status}=  Run Keyword And Return Status
  ...  Run Keyword If  '${state}' == 'Remove' and ${specific_alarm}
  ...  admin.Assert Alarm Active  ${specific_alarm_detalis}
  ...  timeout=10
  ...  alias=${mrbts_id}
  Run Keyword If
  ...  '${state}' == 'Remove' and ${specific_alarm}
  ...  Run Keywords
  ...  Log
  ...  \nFHS Specific alarm status ${specific_alarm_state_status}
  ...  console=True
  ...  AND
  ...  Append To File
  ...  ${cfg.test_logs_path}/report_short.txt
  ...  \nRepetition no: ${ITERATION} state is: ${specific_alarm_state_status}
  ${alarm_state_status}=  Run Keyword And Continue On Failure
  ...  Run Keyword If  '${state}' == 'Remove'
  ...  Check Mandatory Alarm Active List  ${mrbts_id}  ${alarm_list}  ${timeout}
  ...  ELSE  Check Mandatory Alarm InActive List  ${mrbts_id}  ${alarm_list}  ${timeout}
  ${alarm_unexpected_status}=  Run Keyword And Continue On Failure
  ...  admin.Assert No Unexpected Active Alarms
  ...  alias=${mrbts_id}
  Run Keyword If  "${alarm_unexpected_status}" == "${EMPTY}"
  ...  Log  \nList of unexpected alarms detected:${\n}${alarm_unexpected_status}  console=True
  ...  ELSE  Log  \nNo unexpected alarms detected  console=True
  ${unexpected_historical_alarms_list}=  Get Unexpected Historical Alarms  connection=${mrbts_id}
  Collect FHS Link List
  &{rmod_affected_dn_sn}=  Find RMOD Relation with FHS Link  ${mrbts_id}  ${fhs_sn_alt_conf}
  FOR  ${ru_sn}  IN  @{rmod_affected_dn_sn.values()}
    Run Keyword If  ${unexpected_historical_alarms_list} is not None
    ...  Check for Alarm 4589  ${ru_bts_id}  ${ru_sn}  ${unexpected_historical_alarms_list}
  END

Find RMOD Relation with FHS Link
  [Arguments]  ${mrbts_id}  ${fhs_sn_alt_conf}
  FOR  ${fhs}  IN  @{ALL_FHS_LIST}
    Continue For Loop If  "${fhs_sn_alt_conf}"!="${fhs['serialNumber']}"
    ${SFP_links}=  Get SFP links  connection=${mrbts_id}
    ${rmod_affected_dn_sn}=  Prepare Connections List FHS Link  ${mrbts_id}  ${fhs['serialNumber']}
  END

Find FHS SN Relation with FHS
  [Arguments]  ${fhs_sn_alt_conf}
  FOR  ${fhs}  IN  @{ALL_FHS_LIST}
    Continue For Loop If  "${fhs_sn_alt_conf}"!="${fhs['serialNumber']}"
    ${fhs_runtime_dn}=  Set Variable  ${fhs['id']['runtime']}
    ${fhs_distname_int}=  Set Variable  ${fhs['id']['internal']}
  END
  Should Not Be Empty  ${fhs_runtime_dn}  Failed SN in&{OPTICAL_SWITCH_ALT_CONF}
  [Return]  ${fhs_runtime_dn}  ${fhs_distname_int}

Collect FHS Link List
  ${all_fhs_list}=  Create List
  FOR  ${bts_id}  IN  @{cfg.NODES.keys()}
    ${fhs_list}=  Get Fhs List  timeout=1200  connection=${bts_id}
    ${all_fhs_list}=  Combine Lists  ${all_fhs_list}  ${fhs_list}
  END
  Set Test Variable  ${ALL_FHS_LIST}  ${all_fhs_list}

Prepare Connections List FHS Link
  [Arguments]  ${mrbts_id}  ${fhs_sn_alt_conf}
  ${sfp_links}=  Get Sfp Links  connection=${mrbts_id}
  ${rmod_affected_dn_sn}=  Find RMOD Relations FHS Link  ${sfp_links}  ${fhs_sn_alt_conf}
  [Return]  ${rmod_affected_dn_sn}

Find RMOD Relations FHS Link
  [Arguments]  ${sfp_links}  ${fhs_sn_alt_conf}
  &{rmod_affected_dn_sn}=  Create Dictionary
  Set Test Variable  ${RMOD_AFFECTED_DN_SN}  ${rmod_affected_dn_sn}
  FOR  ${link}  IN  @{sfp_links['connected']}
    Continue For Loop If  "${fhs_sn_alt_conf}"!="${link['parent']['destination']['parameters']['serialNumber']}"
    Set To Dictionary
    ...  ${rmod_affected_dn_sn}
    ...  ${link['parent']['source']['distName']}=${link['parent']['source']['parameters']['serialNumber']}
  END
  [Return]  ${rmod_affected_dn_sn}

New Setup Admin Start
  [Arguments]  ${logs_dir}  ${alias}
  ${bts_id_list}=  Get Dictionary Keys  ${cfg.NODES}
  FOR  ${bts_id}  IN  @{bts_id_list}
    ${bts_sm}=  Get From Dictionary  ${cfg.NODES['${bts_id}']}  primary_sm
    ${bts_type}=  Get From Dictionary  ${cfg.NODES['${bts_id}']}  bts_alias_type
    Run Keyword If  '${bts_type}' == 'localhost'
    ...  Logging Start  ${logs_dir}  alias=${alias}
    ...  ELSE  Logging Start  ${logs_dir}  host_ip=${host_ip}  alias=${alias}
  END

Store KPI Value
  [Arguments]  ${kpi_names}  ${prefix}
  Sleep  5s
  admin.Collect Infomodel Log From Current Session
  ...  target_file_name=${TEST_LOGS_DIR_PATH}/IM_infomodel_kpi_cell_${prefix}.ims2
  ...  timeout=300  leave_disconnect_logs=True  alias=${prefix}

    ${kpi_results}  Calculate Kpis  kpi_names=${kpi_names}
    ...  ims_file_path=${TEST_LOGS_DIR_PATH}/IM_infomodel_kpi_cell_${prefix}.ims2
    FOR  ${kpi_param}  IN  @{kpi_names}
        ${kpi}=  Get All Deltas  kpi_name=${kpi_param}
        ${kpi_value}=  Run Keyword And Continue On Failure  Set Variable  ${kpi[-1]}
        Append To File  ${TEST_LOGS_DIR_PATH}/kpi_values.txt    cell_${prefix}:\n${kpi_param} - ${kpi_value}\n
    END
    [Teardown]  admin.Teardown Admin  connection=${prefix}

Preconditions For CNI-127210
       [Documentation]
    ...  KW checks if SW build has proper release and package number. KW checks value parameter act_category_alarms in SCF.
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com

    Set Test Variable    ${bts_id}    ${cfg.primary_node_bts_id}
    admin.Get Current Scf File  local_dir_path=${cfg.test_logs_path}/  file_name=scf_alias_${bts_id}.xml  timeout=30  connection=${bts_id}
    ${parameter}  Evaluate Xpath  ${cfg.test_logs_path}/scf_alias_${bts_id}.xml
    ...  string(.//managedObject[contains(@distName, "FMCADM")]/p[@name="actCategoryAlarms"])
    Remove File  ${cfg.test_logs_path}//scf_alias_${bts_id}.xml
    ${release}  admin.Get Sw Release Name  connection=${bts_id}
    ${proper_sw}  Run Keyword If  "${release}"=="SBTS24R3"
    ...  Check If 24R3 Build Is Proper For CNI-127210  SBTS24R3_ENB_0000_000241_000000  alias=${bts_id}
    ...  ELSE  Check If Current Build Is Newer Than  SBTS25R1_ENB_9999_240926_000004  alias=${bts_id}
    ${act_category_alarms}  Set Variable If  "${parameter}"=="true"  True  False
    ${precond_for_cni}  Set Variable If  ${proper_sw} and ${act_category_alarms}  True  False
    Set Test Variable  ${PRECOND_FOR_CNI}

Check If 24R3 Build Is Proper For CNI-127210
    [Arguments]    ${build}    ${alias}=default
    [Documentation]
    ...  KW checks if given 24R3 build is valid for CNI-127210
    ...  Builds SBTS24R3_ENB_0000_000425_0000XX are TMO branch
    ...  Starting from build SBTS24R3_ENB_0000_000425_0000XX CNI-127210 was reverted
    ...  Starting from build SBTS24R3_ENB_0000_000241_000000 CNI-127210 was implemented
    ...
    ...  | **Author:** anna.maciejewska@nokia.com
    ...  | **Maintainer:** anna.maciejewska@nokia.com

    ${current_sw}  Get Software Release  Active    only_release=False    alias=${alias}
    ${current_sw}  Get Regexp Matches  ${current_sw}  \\d+
    ${curr}    Evaluate    [int(number) for number in ${current_sw}]

    ${arg_sw_number}    Get Regexp Matches  ${build}  \\d+
    ${arg}    Evaluate    [int(number) for number in ${arg_sw_number}]
    Return From Keyword If  ${curr}[3]>=425 and ${curr}[4]>=74   ${FALSE}
    ${verdict}    Set Variable If
    ...    ${curr}[0]>=${arg}[0] and ${curr}[1]>=${arg}[1] and ${curr}[3]>=${arg}[3]
    ...    ${TRUE}
    ...    ${FALSE}

    Run Keyword If  not ${verdict}
    ...  Return From Keyword  ${verdict}
    ...  ELSE
    ...  Return From Keyword If  ${curr}[3]!=${arg}[3]  ${verdict}

    ${verdict}  Set Variable If  ${curr}[4]>${arg}[4]  ${TRUE}  ${FALSE}

    [Return]    ${verdict}

Set Start Timestamp In IMS For CNI-127210
    [Documentation]
    ...  KW Set Start Timestamp In IMS.
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com

    Run Keyword If  ${PRECOND_FOR_CNI}  iav.Set Start Timestamp

Check Active Fault In IMS For CNI-127210
    [Arguments]  ${fault_id}  ${severity}
    [Documentation]
    ...  KW checks if fault is active in IMS.
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com

    Run Keyword If  ${PRECOND_FOR_CNI}  iav.Set End Timestamp
    ${wanted_alarm}  Run Keyword If  ${PRECOND_FOR_CNI}
    ...  awd.create_alarm  fault_id=${fault_id}  severity=${severity}
    Run Keyword If  ${PRECOND_FOR_CNI}  admin.Collect Im Snapshot
    ...  target_file_name=${cfg.test_logs_path}/IMS_1.ims2
    ...  connection=${bts_id}
    ${alarm_dist_name}  Run Keyword If  ${PRECOND_FOR_CNI}
    ...  Run Keyword And Continue On Failure  iav.Verify Alarm Was Set  alarm=${wanted_alarm}  ims_file_path=${cfg.test_logs_path}/IMS_1.ims2
    Run Keyword If  ${PRECOND_FOR_CNI}  Remove File  ${cfg.test_logs_path}/IMS_1.ims2
    Run Keyword If  ${PRECOND_FOR_CNI}  Set Test Variable  ${ALARM_DISTNAME}  ${alarm_dist_name}

Check Removed Active Fault In IMS For CNI-127210
    [Documentation]
    ...  KW checks if active fault was removed in IMS.
    ...
    ...  | **Author:** lukasz.wystup@nokia.com
    ...  | **Maintainer:** lukasz.wystup@nokia.com
    Run Keyword If  ${PRECOND_FOR_CNI}  iav.Set End Timestamp
    Run Keyword If  ${PRECOND_FOR_CNI}  admin.Collect Im Snapshot
    ...  target_file_name=${cfg.test_logs_path}/IMS_2.ims2
    ...  connection=${bts_id}
    Run Keyword If  ${PRECOND_FOR_CNI}
    ...  Run Keyword And Continue On Failure
    ...  iav.Verify Alarm Was Removed  alarm_dist_name=${ALARM_DISTNAME['dist_name']}  ims_file_path=${cfg.test_logs_path}/IMS_2.ims2
    Run Keyword If  ${PRECOND_FOR_CNI}  Remove File  ${cfg.test_logs_path}/IMS_2.ims2

#Legacy TC Add Additional Alarms
#  [Arguments]    ${bts_id}
#  ${additioanl_legacy_alarm_list}=  Get From Dictionary    ${GLOBAL_ALLOWED_FAULTS}   common
#  FOR  ${alarm}  IN  @{additioanl_legacy_alarm_list}
#    admin.add allowed alarm    parameters=${alarm}  connection=${bts_id}
#  END
#  ${additional_fault_exist}=  Run Keyword And Return Status  Should Not Be Empty  ${CUSTOM_ADDITIONAL_ALLOWED_FAULTS}
#  Return From Keyword If  ${additional_fault_exist}==${FALSE}
#  FOR  ${alarm}  IN  @{CUSTOM_ADDITIONAL_ALLOWED_FAULTS.common}
#    admin.add allowed alarm    parameters=${alarm}  connection=${bts_id}
#  END
