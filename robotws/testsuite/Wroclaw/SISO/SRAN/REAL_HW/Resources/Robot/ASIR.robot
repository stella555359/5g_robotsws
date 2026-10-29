*** Settings ***
Documentation  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS
...  Resource file with Configuration management procedures for ASIR modules only.
...  Maintainers: przemyslaw.kempa@nokia.com
Library  OperatingSystem
Library  Collections
Library  String
Library  taf.sbts.oam.sc.rest  WITH NAME  rest
Library  taf.sbts.oam.coam.admin  WITH NAME  admin

*** Variables ***
@{ASIR_ALLOWED_FAULTS}
...  fault_id=61648, fault_name=LMP connectivity detected

*** Keywords ***
Asir Connect
  [Arguments]  ${alias}
  [Documentation]
  ...  Description:
  ...  Provide connection and authorization to ASIR Webem.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | alias                  | Yes  | BTS ID number, its identifies the connection                               |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  Author: przemyslaw.kempa@nokia.com
  ...
  ${bts_obj}=  admin.Get Parameters For All  BTS  connection=${alias}
  ${mplane_ip}=  Convert To String  ${bts_obj[0]['btsMplaneIp4V']}
  ${ip_host}=  Set Variable If  "${cfg.NODES['${alias}']['bts_alias_type']}"=="localhost"  192.168.255.129  ${mplane_ip}
  rest.Connect To  host=${ip_host}  port=3601  username=Nemuadmin  password=nemuuser

Asir Get Site Info
  [Arguments]  ${alias}
  [Documentation]
  ...  Description:
  ...  Get ASIR Webem site info.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | alias                  | Yes  | BTS ID number, its identifies the connection                               |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  Author: przemyslaw.kempa@nokia.com
  ...  Return:
  ...    {"operational_state": "onAir", "blocking_state": "unblocked"}
  ...
  Asir Connect  alias=${alias}
  ${asir_site_info}  rest.Get Site Info  connection=${alias}
  [Teardown]    rest.Disconnect
  [Return]  ${asir_site_info}

Asir Reset Configuration
  [Arguments]  ${alias}
  [Documentation]
  ...  Description:
  ...  Perform reset of actual ASIR Webem configuration.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | alias                  | Yes  | BTS ID number, its identifies the connection                               |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  Author: przemyslaw.kempa@nokia.com
  ...
  Asir Connect  alias=${alias}
  ${reset_conf_status}  rest.Reset Configuration
  Run Keyword If  "None"=="${reset_conf_status}"
  ...  Logging With Timestamp  message=Reset of actual ASIR Webem configuration finish!!!  console=${TRUE}
  [Teardown]    rest.Disconnect

Asir Perform Commissioning
  [Arguments]  ${asir_scf_path}  ${alias}
  [Documentation]
  ...  Description:
  ...  Perform full commissioning of ASIR hub (delete actual staged plan if exists).
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | asir_scf_path          | Yes  | full path to scf file -                                                    |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | alias                  | Yes  | BTS ID number, its identifies the connection                               |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  Author: przemyslaw.kempa@nokia.com
  ...
#  Run Keyword And Ignore Error  Wait Until OAM Is Ready
  Asir Connect  alias=${alias}
  ${staged_plans_info}  rest.Get Staged Plans
  Run Keyword And Ignore Error  rest.Delete Staged Plan  ${staged_plans_info[0]['id']}
  rest.Upload Plan  ${asir_scf_path}
  ${staged_plans_info}  rest.Get Staged Plans
  Run Keyword And Ignore Error  rest.Migrate Nidd  ${staged_plans_info[0]['id']}
  ${activation_scf_status}  rest.Activate Plan  ${staged_plans_info[0]['id']}
  Logging With Timestamp  message=Activation Asir Scf ${activation_scf_status}  console=${TRUE}
  [Teardown]    rest.Disconnect
  [Return]    ${activation_scf_status}

Asir Get Site Physical Info
  [Arguments]  ${alias}
  [Documentation]
  ...  Description:
  ...  Get site physical info from ASIR Webem.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | alias                  | Yes  | BTS ID number, its identifies the connection                               |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  Author: przemyslaw.kempa@nokia.com
  ...
  Asir Connect  alias=${alias}
  ${asir_site_physical_info}  rest.Get Site Physical Info
  [Teardown]    rest.Disconnect
  [Return]  ${asir_site_physical_info}

Asir Get Site Logical Info
  [Arguments]  ${alias}
  [Documentation]
  ...  Description:
  ...  Get site logical info from ASIR Webem.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | alias                  | Yes  | BTS ID number, its identifies the connection                               |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  Author: przemyslaw.kempa@nokia.com
  ...
  Asir Connect  alias=${alias}
  ${asir_site_logical_info}  rest.Get Site Logical Info
  [Teardown]    rest.Disconnect
  [Return]  ${asir_site_logical_info}

Asir Reset Unit
  [Arguments]  ${unit_dn}  ${alias}  ${timeout}=90
  [Documentation]
  ...  Description:
  ...  Perform 'reset' operation with defined ASIR Webem unit.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | unit_dn                | Yes  | Dist name of unit object                                                   |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | alias                  | Yes  | The alias of configured Admin connection                                   |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | timeout                | Yes  | Time in seconds to finish the plan operation                               |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  Author: przemyslaw.kempa@nokia.com
  ...
  Asir Connect  alias=${alias}
  Logging With Timestamp  message=${unit_dn} reset started via ASiR WebEM !!!  console=${TRUE}
  ${timeout}  Convert To Number  ${timeout}
  ${reset_status}  Run Keyword And Return Status  rest.Reset Unit  dn=${unit_dn}  timeout=${timeout}
  Run Keyword If  ${reset_status}  Log  ${unit_dn} reset finished successfully !!!  console=${TRUE}
  Run Keyword If  not ${reset_status}  Fail  ${unit_dn} reset finished with error !!!
  [Teardown]    rest.Disconnect

Asir Block Unit
  [Arguments]  ${unit_dn}  ${alias}
  [Documentation]
  ...  Description:
  ...  Perform 'block' operation with defined ASIR Webem unit.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | unit_dn                | Yes  | Dist name of unit object                                                   |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | alias                  | Yes  | The alias of configured Admin connection                                   |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  Author: przemyslaw.kempa@nokia.com
  ...
  Asir Connect  alias=${alias}
  Logging With Timestamp  message=${unit_dn} block started via ASiR WebEM !!!  console=${TRUE}
  ${block_status}  Run Keyword And Return Status  rest.Block Unit  dn=${unit_dn}
  Run Keyword If  ${block_status}  Log  ${unit_dn} block finished successfully !!!  console=${TRUE}
  Run Keyword If  not ${block_status}  Run Keyword And Continue On Failure  Fail  ${unit_dn} block finished with error !!!
  [Teardown]    rest.Disconnect

Asir Unblock Unit
  [Documentation]
  ...  Description:
  ...  Perform 'unblock' operation with defined ASIR Webem unit.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | unit_dn                | Yes  | Dist name of unit object                                                   |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | alias                  | Yes  | The alias of configured Admin connection                                   |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  Author: przemyslaw.kempa@nokia.com
  ...
  [Arguments]  ${unit_dn}  ${alias}
  Asir Connect  alias=${alias}
  Logging With Timestamp  message=${unit_dn} unblock started via ASiR WebEM !!!  console=${TRUE}
  ${unblock_status}  Run Keyword And Return Status  rest.Unblock Unit  dn=${unit_dn}
  Run Keyword If  ${unblock_status}  Logging With Timestamp  message=${unit_dn} unblock finished successfully !!!  console=${TRUE}
  Run Keyword If  not ${unblock_status}  Run Keyword And Continue On Failure  Fail  ${unit_dn} unblock finished with error !!!
  [Teardown]   rest.Disconnect

Asir Get Active Alarms
  [Arguments]  ${alias}
  [Documentation]
  ...  Description:
  ...  Get ASIR Webem active alarms info.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | alias                  | Yes  | The alias of configured Admin connection                                   |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  Author: przemyslaw.kempa@nokia.com
  ...
  Asir Connect  alias=${alias}
  ${alarms}  rest.Get Active Alarms
  [Return]  ${alarms}
  [Teardown]    rest.Disconnect

Asir Check Active Alarms
  [Arguments]  ${alias}=${cfg.primary_node_bts_id}
  [Documentation]
  ...  Description:
  ...  Get ASIR Webem active alarms info and check if only allowed allarms are visible @{ASIR_ALLOWED_FAULTS}
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | alias                  | Yes  | The alias of configured Admin connection                                   |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  Author: przemyslaw.kempa@nokia.com
  ...
  Asir Connect  alias=${alias}
  Logging With Timestamp  message=Asir Check Active Alarms Started !!!  console=${TRUE}
  ${alarms}  rest.Get Active Alarms
  ${alarms_status}  Run Keyword And Return Status  Should Be Empty  ${alarms}
  Run Keyword If  ${alarms_status}  Logging With Timestamp  message=No unexpected alarms detected in AsirWebEM !!!  console=${TRUE}
  Run Keyword If  not ${alarms_status}  Logging With Timestamp  message=ALARM/S detected in AsirWebEM  console=${TRUE}
  ${alarm_status_check}  Set Variable
  FOR  ${alarm}  IN  @{alarms}
    ${fault_id}    Get From Dictionary   ${alarm}    fault_id
    ${fault_name}    Get From Dictionary   ${alarm}    fault_name
    ${alarm_name}  Set Variable  fault_id=${fault_id}, fault_name=${fault_name}
    ${alarm_status_check}  Run Keyword And Return Status  List Should Contain Value  ${ASIR_ALLOWED_FAULTS}  ${alarm_name}
    Exit For Loop If  ${alarm_status_check}==False
  END

  Run Keyword If  not ${alarms_status}  Run Keyword If  ${alarm_status_check}
  ...  Logging With Timestamp  message=No unexpected alarms detected in AsirWebEM
  Run Keyword If  not ${alarms_status}  Run Keyword If  not ${alarm_status_check}  Run Keyword And Continue On Failure
  ...  FAIL  Unexpected ALARMS detected in AsirWebEM !!!\n${alarms}
  [Teardown]    rest.Disconnect

Asir Get All Hubmod Info
  [Arguments]  ${alias}=${cfg.primary_node_bts_id}
  [Documentation]
  ...  Description:
  ...  Provide Hubmod Info fram ASiR WebEM
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | alias                  | Yes  | The alias of configured Admin connection                                   |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Return
  ...    Return: {'HUBMOD-1': {'distname': 'ASIRMOD-1',
  ...                          'product_name': 'APHG',
  ...                          'serial_number': 'NH225300251',
  ...                          'state': {'alarmed': 'yes',
  ...                                    'blocked': 'no',
  ...                                    'state': 'operational'},
  ...                          'uid': 'c'}}
  ...
  ...  Author: przemyslaw.kempa@nokia.com
  ...
  Asir Connect  alias=${alias}
  ${site_phy_info}  rest.Get Site Physical Info
  &{hubmod_dict}  Create Dictionary
  FOR  ${index}  IN  @{site_phy_info}
    &{hubmod_dict_temp}  Create Dictionary
    ${label_exist_status}  ${hubmod_label}  Run Keyword And Ignore Error  Get From Dictionary  ${index['description']}  label
    ${hubmod_status}  Get Regexp Matches  ${hubmod_label}  HUBMOD
    ${hubmod_sn}  Run Keyword If  ${hubmod_status}  Get From List  ${index['description']['text']}  0
    ${hubmod_dn}  Run Keyword If  ${hubmod_status}  Get From List  ${index['description']['text']}  1
    ${hubmod_dn}  Run Keyword If  ${hubmod_status}  Fetch From Right  ${hubmod_dn}  :${SPACE}
    ${hubmod_sn}  Run Keyword If  ${hubmod_status}  Remove String  ${hubmod_sn}  S/N:  ${SPACE}
    ${asir_product_name}  ${hubmod_num}  Run Keyword If  ${hubmod_status}  Split String  ${hubmod_label}
    ${hubmod_num}  Run Keyword If  ${hubmod_status}  Remove String  ${hubmod_num}  (  )
    ${hubmod_uid}  Run Keyword If  ${hubmod_status}  Get From Dictionary  ${index}  uid
    ${hubmod_state}  Run Keyword If  ${hubmod_status}  Get From Dictionary  ${index}  status
    Run Keyword If  ${hubmod_status}  Set To Dictionary  ${hubmod_dict_temp}  product_name=${asir_product_name}  serial_number=${hubmod_sn}
    ...  distname=${hubmod_dn}  uid=${hubmod_uid}    state=${hubmod_state}
    Run Keyword If  ${hubmod_status}  Set To Dictionary  ${hubmod_dict}  ${hubmod_num}=${hubmod_dict_temp}
  END
  [Return]  ${hubmod_dict}
  [Teardown]    rest.Disconnect

Asir Get All Antmods Info
  [Arguments]  ${alias}=${cfg.primary_node_bts_id}
  [Documentation]
  ...  Description:
  ...  Provide Antmods Info fram ASiR WebEM
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | alias                  | Yes  | The alias of configured Admin connection                                   |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Return
  ...
  ...
  ...  *OUTPUT*
  ...    Return: {'ANTMOD-1': {'antport_distname': 'ASI-1/HUBMOD-1/ANTPORT-1',
  ...                          'cells_list_cfg': ['MRBTS-1377/NRBTS-1377/NRCELL-36708',
  ...                                             'MRBTS-1377/NRBTS-1377/NRCELL-36709'],
  ...                          'cells_list_lcrid': ['8', '9'],
  ...                          'cells_list_uid': ['14', '15'],
  ...                          'product_name': 'AWHHIQA',
  ...                          'serial_number_asir': 'NH225300251',
  ...                          'serial_number_pRRH': 'NH230800640',
  ...                          'state': {'alarmed': 'no',
  ...                                     'blocked': 'no',
  ...                                     'state': 'operational'},
  ...                          'uid': 'd'}}
  ...
  ...  Author: przemyslaw.kempa@nokia.com
  ...
  Asir Connect  alias=${alias}
  ${site_physical_info}  rest.Get Site Physical Info
  ${site_logical_info}  rest.Get Site Logical Info
  ${active_dn}  rest.Get Active Dist Names
  &{antmod_dict}  Create Dictionary
  ${hubmod_nr}  Set Variable
  &{hubmod_dict}  Create Dictionary
  ${node}  Fetch from right  ${alias}  _
  FOR  ${phy_index}  IN  @{site_physical_info}
    &{hubmod_dict_temp}  Create Dictionary
    ${label_exist_status}  ${hubmod_label}  Run Keyword And Ignore Error  Get From Dictionary  ${phy_index['description']}  label
    ${hubmod_status2}  Get Regexp Matches  ${hubmod_label}  HUBMOD
    ${hubmod_sn}  Run Keyword If  ${hubmod_status2}  Get From List  ${phy_index['description']['text']}  0
    ${hubmod_dn}  Run Keyword If  ${hubmod_status2}  Get From List  ${phy_index['description']['text']}  1
    ${hubmod_dn}  Run Keyword If  ${hubmod_status2}  Fetch From Right  ${hubmod_dn}  :${SPACE}
    ${hubmod_sn}  Run Keyword If  ${hubmod_status2}  Remove String  ${hubmod_sn}  S/N:  ${SPACE}
    ${asir_product_name}  ${hubmod_num1}  Run Keyword If  ${hubmod_status2}  Split String  ${hubmod_label}
    ${hubmod_num1}  Run Keyword If  ${hubmod_status2}  Remove String  ${hubmod_num1}  (  )
    Run Keyword If  ${hubmod_status2}  Set To Dictionary  ${hubmod_dict_temp}  product_name=${asir_product_name}  serial_number=${hubmod_sn}
    ...  distname=${hubmod_dn}
    Run Keyword If  ${hubmod_status2}  Set To Dictionary  ${hubmod_dict}  ${hubmod_num1}=${hubmod_dict_temp}
    ${hubmod_num}  Run Keyword And Ignore Error  Get From List  ${phy_index['description']['text']}  0
    ${hubmod_num}  Convert To String  ${hubmod_num}
    ${hubmod_status}  Get Regexp Matches  ${hubmod_num}  HUBMOD
    ${hubmod_num}  Run Keyword If  ${hubmod_status}  Remove String  ${hubmod_num}  (  )  PASS  '  ,  ${SPACE}
    ${hubmod_nr}  Set Variable If  ${hubmod_status}  ${hubmod_num}  ${hubmod_nr}
    &{antmod_dict_temp}  Create Dictionary
    ${antmod_label_status}  ${antmod_label}  Run Keyword And Ignore Error  Get From Dictionary  ${phy_index['description']}  label
    ${antmod_status}  Get Regexp Matches  ${antmod_label}  ANTMOD
    ${antmod_sn}  Run Keyword If  ${antmod_status}  Get From List  ${phy_index['description']['text']}  0
    ${antmod_dn}  Run Keyword If  ${antmod_status}  Get From Dictionary  ${phy_index['connections'][1]['connectors'][0]}  label
    ${antmod_product_name}  ${antmod_num}  Run Keyword If  ${antmod_status}  Split String  ${antmod_label}
    ${antmod_num}  Run Keyword If  ${antmod_status}  Remove String  ${antmod_num}  (  )
    ${antmod_state}  Run Keyword If  ${antmod_status}  Get From Dictionary  ${phy_index}  status
    Run Keyword If  ${antmod_status}  Set To Dictionary  ${antmod_dict_temp}
    ...  product_name=${antmod_product_name}  serial_number_pRRH=${antmod_sn}  antport_distname=ASI-1/${hubmod_nr}/${antmod_dn}
    ...  serial_number_asir=${hubmod_dict['${hubmod_nr}']['serial_number']}  uid=${phy_index['uid']}  state=${antmod_state}
    Run Keyword If  ${antmod_status}  Set To Dictionary  ${antmod_dict}  ${antmod_num}=${antmod_dict_temp}
  END
  ${cells_uid_lcrid_dict}  Create Dictionary
  FOR  ${log_index}  IN  @{site_logical_info}
    ${label_status}  ${label_value}  Run Keyword And Ignore Error  Get From Dictionary  ${log_index['description']}  label
    ${cell_status}  Get Regexp Matches  ${label_value}  BTS${node}
    ${cell_label}  Run Keyword If  ${cell_status}  Fetch From Right  ${label_value}  .
    Run Keyword If  ${cell_status}  Set To Dictionary  ${cells_uid_lcrid_dict}  ${log_index['uid']}=${cell_label}
  END
  ${smallcell_info}  Get Smallcell Frm  connection=${alias}
  &{asirmod_cells_webem}  Create Dictionary
  FOR  ${index}  IN  @{smallcell_info}
    ${asirmod_sn}  Get From Dictionary  ${index}  serialNumber
    ${carrier_list}  Get From Dictionary  ${index}  carrierList
    ${cells}  _Create Cells Dictionary  ${carrier_list}
    Set To Dictionary  ${asirmod_cells_webem}  ${asirmod_sn}=${cells}
  END
  ${antmod_dict_lcr}  Create Dictionary
  ${antmod_dict_uid}  Create Dictionary
  ${antmod_dict_cell_cfg_dn}  Create Dictionary
  FOR  ${log_index2}  IN  @{site_logical_info}
    ${label_status}    ${label_value}  Run Keyword And Ignore Error  Get From Dictionary  ${log_index2['description']}  label
    ${antmod_status}  Get Regexp Matches  ${label_value}  ANTMOD
    ${antmod_label}  Run Keyword If  ${antmod_status}  Fetch From Right  ${label_value}  ${SPACE}(
    ${antmod_label}  Run Keyword If  ${antmod_status}  Remove String  ${antmod_label}  )
    ${value}  Run Keyword If  ${antmod_status}  Get From Dictionary  ${log_index2['connections'][1]}  connectors
    Run Keyword If  ${antmod_status}  Remove From List  ${value}  0
    Run Keyword If  ${antmod_status}  Remove From List  ${value}  0
    ${asir_sn}  Run Keyword If  ${antmod_status}  Get From Dictionary  ${antmod_dict['${antmod_label}']}  serial_number_asir

    ${value}  ${value_uid}  ${cells_config_dn}  Run Keyword If  ${antmod_status}
    ...  _Change Cell UID To Distname  ${value}  ${active_dn}  ${cells_uid_lcrid_dict}  ${asir_sn}  ${asirmod_cells_webem}
    Run Keyword If  ${antmod_status}  Set To Dictionary  ${antmod_dict_lcr}  ${antmod_label}=${value}
    Run Keyword If  ${antmod_status}  Set To Dictionary  ${antmod_dict_uid}  ${antmod_label}=${value_uid}
    Run Keyword If  ${antmod_status}  Set To Dictionary  ${antmod_dict_cell_cfg_dn}  ${antmod_label}=${cells_config_dn}
  END
  ${antmods}  Get Dictionary Keys  ${antmod_dict}
  FOR  ${antmod}  IN  @{antmods}
    Set To Dictionary  ${antmod_dict['${antmod}']}  cells_list_lcrid=${antmod_dict_lcr['${antmod}']}
    Set To Dictionary  ${antmod_dict['${antmod}']}  cells_list_uid=${antmod_dict_uid['${antmod}']}
    Set To Dictionary  ${antmod_dict['${antmod}']}  cells_list_cfg=${antmod_dict_cell_cfg_dn['${antmod}']}
  END
  Log Dictionary  ${antmod_dict}
  [Return]  ${antmod_dict}
  [Teardown]    rest.Disconnect


_Change Cell UID To Distname
  [Arguments]  ${value}  ${active_dn}  ${cells_uid_lcrid_dict}  ${asir_sn}  ${asirmod_cells_webem}
  [Documentation]
  ...  Description:
  ...  KW used in "Asir Get All Antmods Info" for change cell UID to distname
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | value                  | Yes  | value                                                                      |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | active_dn              | Yes  | active_dn                                                                  |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | cells_uid_lcrid_dict   | Yes  | cells_uid_lcrid_dict                                                       |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | asir_sn                | Yes  | asir_sn                                                                    |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | asirmod_cells_webem    | Yes  | asirmod_cells_webem                                                        |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: przemyslaw.kempa@nokia.com
  ...
  ${active_dn}=  Set Variable    ${active_dn}
  ${cells_distname}  Create List
  ${cells_uid}  Create List
  ${cells_config_dn}  Create List
  FOR  ${index}  IN  @{value}
    ${dist_uid}  Get From Dictionary  ${index}  dst_uid
    Append To List  ${cells_distname}  ${cells_uid_lcrid_dict['${dist_uid}']}
    Append To List  ${cells_uid}  ${dist_uid}
    ${cell_config_dn}  Get From Dictionary  ${asirmod_cells_webem['${asir_sn}']}  ${cells_uid_lcrid_dict['${dist_uid}']}
    Append To List  ${cells_config_dn}  ${cell_config_dn}
  END
  [Return]  ${cells_distname}  ${cells_uid}  ${cells_config_dn}

_Create Cells Dictionary
  [Arguments]  ${carrier_list}
  [Documentation]
  ...  Description:
  ...  KW used in "Asir Get All Antmods Info" to create cells Dictionary
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | carrier_list           | Yes  | carrier_list                                                               |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: przemyslaw.kempa@nokia.com
  ...
  ${cell_lcrid_dn}  Create Dictionary
  FOR  ${index}  IN  @{carrier_list}
    ${cell_lcrid}  Get From Dictionary  ${index['id']}  internal
    ${cell_lcrid}  Fetch From Left  ${cell_lcrid}  /CHANNEL_GROUP_M
    ${cell_lcrid}  Fetch from right  ${cell_lcrid}  /CELL_M-
    ${cell_config_dn}  Get From Dictionary  ${index['id']}  configuration
    ${cell_config_dn}  Remove String Using Regexp  ${cell_config_dn}  /[TR]X.*
    Set To Dictionary  ${cell_lcrid_dn}  ${cell_lcrid}=${cell_config_dn}
  END
  [Return]  ${cell_lcrid_dn}


ASIR Check Expected States For Cells
    [Documentation]
    ...  Checking expected states for provided list with cells distname
    ...
    ...  *AUTHOR*
    ...  przemyslaw.kempa@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter        | Man.   | Default                         | Description                                   |
    ...  | cells_dn_list    | No     |                                 | List of cells Distname for assert             |
    ...  | expected_states  | No     |                                 | Expected states of cells for asserrt          |
    ...  | alias            | Yes    | alias | The alias of configured Admin connection      |
    ...
    [Arguments]  ${cells_dn_list}  ${expected_states}  ${alias}=${cfg.primary_node_bts_id}
    FOR  ${cell}  IN  @{cells_dn_list}
      ${class}=  Get Regexp Matches  ${cell}  (?i)LNCEL|NRCEL|WNCEL|GNCEL
      ${expexted_st}=  Run Keyword And Return Status  admin.Assert  ${class[0]}  ${cell}  ${expected_states}  connection=${alias}
      Run Keyword If  ${expexted_st}  Log To Console  ${cell} is in expected states !!!
      Run Keyword If  not ${expexted_st}  Run Keyword And Continue On Failure  Fail  ${cell} is NOT in expected states !!!
    END
