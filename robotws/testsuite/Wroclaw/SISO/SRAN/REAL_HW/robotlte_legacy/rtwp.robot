*** Settings ***
Documentation  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS

Resource    ../Resources/Setup/setup_and_teardown.robot
Resource  ./common_setup.robot
Resource  ./site_operations.robot
Resource  ./site_verifications.robot
Resource  ./variables.robot


Library  BuiltIn
Library  Collections
Library  String
Library  robot.libraries.DateTime
Library  taf.sbts.oam.coam.admin    WITH NAME    admin
Library  ute_admin_infomodel    WITH NAME    admin_im

*** Keywords ***
Step 1: Site reset and wait for onAir
  [Arguments]  ${alias}=${cfg.primary_node_bts_id}
  Log  BTS reset will be triggered  console=${TRUE}
  Reset Site  connection=${alias}  wait_for_reconnection=${TRUE}  detailed_output=${TRUE}
  Verify Multi BTS State
  ${BTS_stability_time_exist_in_cfg}  Run keyword and return status  Variable should exist  ${BTS_stability_time}
  ${BTS_stability_time}  Set variable if  ${BTS_stability_time_exist_in_cfg}  ${BTS_stability_time}  15 min
  ${RTWP_min_exist_in_cfg}  Run keyword and return status  Variable should exist  ${RTWP_min}
  Run keyword if  not ${RTWP_min_exist_in_cfg}  Set to dictionary  ${cfg}  RTWP_min  -110
  ${RTWP_max_exist_in_cfg}  Run keyword and return status  Variable should exist  ${RTWP_max}
  Run keyword If  not ${RTWP_max_exist_in_cfg}  Set to dictionary  ${cfg}  RTWP_max  -70
  Log  Wait to BTS stability  console=${TRUE}
  Sleep  ${BTS_stability_time}  Wait to BTS stability

Step 2: Check RTWP
  [Arguments]  ${RTWP_measuring_time}  ${alias}=${cfg.primary_node_bts_id}
  ${RTWP_measuring_time_exist_in_cfg}  Run keyword and return status  Variable should exist  ${RTWP_measuring_time}
  ${RTWP_measuring_time}  Set variable if
  ...  ${RTWP_measuring_time_exist_in_cfg}
  ...  ${RTWP_measuring_time}
  ...  ${RTWP_measuring_time}
  Log  Will check RTWP value for ${RTWP_measuring_time} seconds  console=${TRUE}
  Check RTWP value  ${RTWP_measuring_time}  alias=${alias}

Get ANTL_R distNames list
  [Arguments]  ${alias}=${cfg.primary_node_bts_id}
  ${antl_list}  Create list
  ${cells_dict}  Get cell list  connection=${alias}
  ${lte_cells}  Get from dictionary  ${cells_dict["cells"]}  lte
  ${wcdma_cells}  Get from dictionary  ${cells_dict["cells"]}  wcdma
  ${lw_cells}  Combine lists  ${lte_cells}  ${wcdma_cells}
  Should not be empty  ${lw_cells}  There is no LTE or WCDMA cells in configuration!
  FOR  ${cell}  IN  @{lw_cells}
    ${is_iot}  Run keyword and return status  Should contain  ${cell["technology"]}  NB-IoT-FDD
    Continue for loop if  ${is_iot}
    ${carrier_list}  Get from dictionary  ${cell}  carrierList
    ${antl_distNames}  _Get ANTL distNames  ${carrier_list}
    ${antl_list}  Combine lists  ${antl_list}  ${antl_distNames}
  END
  ${antl_list}  Remove duplicates  ${antl_list}
  [Return]  ${antl_list}

_Get ANTL distNames
  [Arguments]  ${carrier_list}
  ${antl_list}  Create list
  FOR  ${carrier}  IN  @{carrier_list}
    ${is_phyant}  Run keyword and return status  Should contain  ${carrier["antennaLineId"]["internal"]}  PHYANT
    Continue for loop if  ${is_phyant}
    Append to list  ${antl_list}  ${carrier["antennaLineId"]["internal"]}
  END
  [Return]  ${antl_list}

Check RTWP value
  [Arguments]  ${RTWP_measuring_time}  ${alias}=${cfg.primary_node_bts_id}
  ${antl_r_list}  Get ANTL_R distNames list  ${alias}
  ${custom_radio_unit_list_status}  Run keyword and return status  Variable should exist  ${CUSTOM_RADIO_UNIT_LIST}
  ${tested_ru_list}=  Set Variable If  ${custom_radio_unit_list_status}
  ...  ${CUSTOM_RADIO_UNIT_LIST}  ${cfg.NODES['${alias}']['scf_hw_fr_list']}
  ${antl_r_list}  Get Only ANTL_R distNames list Of Tested RMs  ${tested_ru_list}  ${alias}
  Log  Collecting RTWP data ...  console=${TRUE}
  Start ANTL online monitoring  ${antl_r_list}  connection=${alias}
  Sleep  ${RTWP_measuring_time}
  Log  Wait for RTWP data generation for ${RTWP_measuring_time} seconds ...  console=${TRUE}
  Stop ANTL online monitoring  ${cfg.test_logs_path}/output.json  connection=${alias}
  OperatingSystem.File Should Exist  ${cfg.test_logs_path}/output.json
  ${json}  OperatingSystem.Get File  ${cfg.test_logs_path}/output.json  encoding_errors=replace
  ${json}  Evaluate  json.loads('''${json}''')  json
  ${is_lte}  Run keyword and return status  Dictionary should contain key  ${json}  RTWP_L
  ${rtwp_l}  Run keyword if  ${is_lte}  Get from dictionary  ${json}  RTWP_L
  ...  ELSE  Create dictionary
  ${is_rtwp}  Run keyword and return status  Dictionary should contain key  ${json}  RTWP
  ${rtwp_rtwp}  Run keyword if  ${is_rtwp}  Get from dictionary  ${json}  RTWP
  ...  ELSE  Create dictionary
  ${is_wcdma}  Run keyword and return status  Dictionary should contain key  ${json}  RTWP_W
  ${rtwp_w}  Run keyword if  ${is_wcdma}  Get from dictionary  ${json}  RTWP_W
  ...  ELSE  Create dictionary
  ${iot_cells}  Get IoT LNCEL ids  alias=${alias}
  ${l_rtwp_dict}  Create RTWP dictionary  ${rtwp_l}  ${iot_cells}
  ${w_rtwp_dict}  Create RTWP dictionary  ${rtwp_w}
  ${rtwp_rtwp_dict}  Create RTWP dictionary  ${rtwp_rtwp}  ${iot_cells}
  ${l_rtwp_dict_not_empty}  Run keyword and return status  Should not be empty  ${l_rtwp_dict}
  Run keyword if  ${l_rtwp_dict_not_empty}  Check RTWP values for  ${l_rtwp_dict}
  ${w_rtwp_dict_not_empty}  Run keyword and return status  Should not be empty  ${w_rtwp_dict}
  Run keyword if  ${w_rtwp_dict_not_empty}  Check RTWP values for  ${w_rtwp_dict}
  ${rtwp_rtwp_dict_not_empty}  Run keyword and return status  Should not be empty  ${rtwp_rtwp_dict}
  Run keyword if  ${rtwp_rtwp_dict_not_empty}  Check RTWP values for  ${rtwp_rtwp_dict}
  Run keyword If
  ...  not (${l_rtwp_dict_not_empty} or ${w_rtwp_dict_not_empty} or ${rtwp_rtwp_dict_not_empty})
  ...  Fail
  ...  There is no RTWP data!

Create RTWP dictionary
  [Arguments]  ${rtwp_rmod_list}  ${excluded_cells}=${EMPTY}
  Set test variable  ${EXCLUDED_CELLS}  ${excluded_cells}
  ${rtwp_dict}  Create dictionary
  FOR  ${rmod}  IN  @{rtwp_rmod_list}
    ${key}  Get from dictionary  ${rmod}  name
    ${antl_dict}  _Create ANTL dictionary  ${rmod["antennaLines"]}  ${key}
    ${rtwp_dict}  Combine dictionary  ${rtwp_dict}  ${antl_dict}
  END
  [Return]  ${rtwp_dict}

_Create ANTL dictionary
  [Arguments]  ${antl_list}  ${parent_key}
  ${antl_dict}  Create dictionary
  FOR  ${antl}  IN  @{antl_list}
    ${key}  Get from dictionary  ${antl}  name
    ${cell_dict}  _Create cell dictionary  ${antl["measureDatas"]}  ${parent_key}_${key}
    ${antl_dict}  Combine dictionary  ${antl_dict}  ${cell_dict}
  END
  [Return]  ${antl_dict}

_Create cell dictionary
  [Arguments]  ${cells_dict}  ${parent_key}
  ${cell_dict}  Create dictionary
  ${keys}  Get dictionary keys  ${cells_dict}
  FOR  ${key}  IN  @{keys}
    ${is_iot}  Run keyword and return status  List should contain value  ${EXCLUDED_CELLS}  ${key}
    Continue for loop if  ${is_iot}
    ${values_list}  Get dictionary values  ${cells_dict["${key}"]}
    Set to dictionary  ${cell_dict}  ${parent_key}_${key}=${values_list}
  END
  [Return]  ${cell_dict}

Combine dictionary
  [Arguments]  ${dict1}  ${dict2}
  ${keys2}  Get dictionary keys  ${dict2}
  FOR  ${key2}  IN  @{keys2}
    Set to dictionary  ${dict1}  ${key2}=${dict2["${key2}"]}
  END
  [Return]  ${dict1}

Check RTWP values for
  [Arguments]  ${rtwp_dict}
  ${keys}  Get dictionary keys  ${rtwp_dict}
  FOR  ${key}  IN  @{keys}
    _Check correct RTWP value  ${rtwp_dict["${key}"]}
  END

_Check correct RTWP value
  [Arguments]  ${values_list}
  FOR  ${value}  IN  @{values_list}
    ${value}  Convert to number  ${value}
    ${result}  Evaluate  ${RTWP_min} < ${value} < ${RTWP_max}
    Run keyword if  not ${result}  Fail  Some RTWP value is out of range!
  END

Get non IoT LNCEL ids
  [Arguments]  ${alias}=${cfg.primary_node_bts_id}
  ${L_cells_list}  Get parameters for all  LNCEL  alias=${alias}
  ${l_cell_id_list}  Create list
  FOR  ${cell}  IN  @{cells_list}
    ${is_not_iot}  Run keyword and return status
    ...  Should not be equal as strings
    ...  ${L_cells_list["technology"]}
    ...  NB-IoT-FDD
    ${cell_id}  Fetch from right  ${L_cells_list["id"]["configuration"]}  /
    Run keyword if  ${is_not_iot}  Append to list  ${l_cell_id_list}  ${cell_id}
  END
  [Return]  ${l_cell_id_list}

Get IoT LNCEL ids
  [Arguments]  ${alias}=${cfg.primary_node_bts_id}
  ${L_cells_list}  Get cells info  lte  connection=${alias}
  ${iot_cell_id_list}  Create list
  FOR  ${cell}  IN  @{L_cells_list}
    ${is_iot}  Run keyword and return status  Should be equal as strings  ${cell["technology"]}  NB-IoT-FDD
    ${cell_id}  Fetch from right  ${cell["id"]["configuration"]}  /
    Run keyword if  ${is_iot}  Append to list  ${iot_cell_id_list}  ${cell_id}
  END
  [Return]  ${iot_cell_id_list}

Get Only ANTL_R distNames list Of Tested RMs
  [Arguments]  ${rm_sn_list}  ${alias}=${cfg.primary_node_bts_id}
  ${tested_antl_r_list}  Create List
  ${rm_info}  Get FRM  connection=${alias}
  ${rm_antenaUsageInfo_truncated}  Evaluate
  ...  [single_rm_info["antenaUsageInfo"] for single_rm_info in ${rm_info} if single_rm_info["serialNumber"] in ${rm_sn_list}]
  Get Length  ${rm_antenaUsageInfo_truncated}
  FOR  ${single_rm_info}  IN  @{rm_antenaUsageInfo_truncated}
    ${rm_antl_r_list}  Evaluate  [ant["id"]["internal"] for ant in ${single_rm_info}]
    Append To List  ${tested_antl_r_list}  @{rm_antl_r_list}
  END
  [Return]  ${tested_antl_r_list}
