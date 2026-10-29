*** Settings ***
Documentation  Admin actions
...    Author: slawomir.jastrzebski@nokia.com
...    Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    String
Library    Collections
Library    taf.sbts.oam.coam.admin    WITH NAME    admin

*** Keywords ***
#BTS
Admin BTS Procedural State Should Be
    [Arguments]  ${state_value}  ${timeout}=10  ${admin_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword checks value of BTS procedural state.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | state_value            | Yes  | Value of expected procedural state.                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Waiting time for BTS expected procedural state.                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | admin_connection       |  No  | Admin connection object or if used, string name alias.                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    admin.Assert Every
    ...  class_name=BTS
    ...  parameters=proceduralState=regex"(?i)${state_value}"
    ...  timeout=${timeout}
    ...  connection=${admin_connection}

#Cells
Admin Check Cells State When BTS OnAir
    [Arguments]  ${timeout}=10  ${admin_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword verifies the condition of the cells when BTS is in "OnAir" state.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | timeout                |  No  | Waiting time for cells expected states.                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | admin_connection       |  No  | Admin connection object or if used, string name alias.                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${cell_list}=  admin.Get Cell List
    ...  timeout=120
    ...  connection=${admin_connection}
    ${gsm_cells_count}=  Get Length  item=${cell_list['cells']['gsm']}
    ${wcdma_cells_count}=  Get Length  item=${cell_list['cells']['wcdma']}
    ${lte_cells_count}=  Get Length  item=${cell_list['cells']['lte']}
    ${nr_cells_count}=  Get Length  item=${cell_list['cells']['nr']}
    ${gsm_administrativeState}=  Set Variable  administrativeState=regex"(?i)unlocked"
    ${gsm_operationalState}=  Set Variable  operationalState=regex"(?i)Enabled"
    Run Keyword If  ${gsm_cells_count}>0  Run Keyword And Continue On Failure
    ...  admin.Assert Every
    ...  class_name=GNCEL
    ...  parameters=${gsm_administrativeState},${gsm_operationalState}
    ...  timeout=${timeout}
    ...  connection=${admin_connection}
    ${wcdma_operationalState}=  Set Variable  operationalState=regex"(?i)Enabled"
    Run Keyword If  ${wcdma_cells_count}>0  Run Keyword And Continue On Failure
    ...  admin.Assert Every
    ...  class_name=WNCEL
    ...  parameters=${wcdma_operationalState}
    ...  timeout=${timeout}
    ...  connection=${admin_connection}
    ${lte_proceduralStatus}=  Set Variable  proceduralState=regex"(?i)OnAirDone"
    ${lte_administrativeState}=  Set Variable  administrativeState=regex"(?i)unlocked"
    ${lte_operationalState}=  Set Variable  operationalState=regex"(?i)Enabled"
    Run Keyword If  ${lte_cells_count}>0  Run Keyword And Continue On Failure
    ...  admin.Assert Every
    ...  class_name=LNCEL
    ...  parameters=${lte_proceduralStatus},${lte_administrativeState},${lte_operationalState}
    ...  search_for_iot_cells=${False}
    ...  timeout=${timeout}
    ...  connection=${admin_connection}
    ${nr_proceduralStatus}=  Set Variable  proceduralStatus=regex"(?i)configured"
    ${nr_administrativeState}=  Set Variable  administrativeState=regex"(?i)unlocked"
    ${nr_operationalState}=  Set Variable  operationalState=regex"(?i)Enabled"
    Run Keyword If  ${nr_cells_count}>0  Run Keyword And Continue On Failure
    ...  admin.Assert Every
    ...  class_name=NRCEL
    ...  parameters=${nr_proceduralStatus},${nr_administrativeState},${nr_operationalState}
    ...  timeout=${timeout}
    ...  connection=${admin_connection}

BTS SCFC And Admin Cells Count Should Match
    [Arguments]  ${scfc_file_path}  ${admin_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword checks if count of cells specified in SCFC file matches to the count of cells configured in Admin.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | admin_connection       |  No  | Admin connection object or if used, string name alias.                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

   ${gsm_cells_count_scfc}=  SCFC Get Cells Count Based On Class
    ...  scfc_file_path=${scfc_file_path}  cell_class=com.nokia.srbts.gsm:GNCEL
   ${wcdma_cells_count_scfc}=  SCFC Get Cells Count Based On Class
    ...  scfc_file_path=${scfc_file_path}  cell_class=com.nokia.srbts.wcdma:WNCEL
    ${lte_cells_count_scfc}=  SCFC Get Cells Count Based On Class
    ...  scfc_file_path=${scfc_file_path}  cell_class=NOKLTE:LNCEL
    ${nr_cells_count_scfc}=  SCFC Get Cells Count Based On Class
    ...  scfc_file_path=${scfc_file_path}  cell_class=com.nokia.srbts.nrbts:NRCELL
    ${cell_list}=  admin.Get Cell List
    ...  timeout=120
    ...  connection=${admin_connection}
    ${gsm_cells_count_admin}=  Get Length  ${cell_list['cells']['gsm']}
    Should Be Equal As Integers  ${gsm_cells_count_scfc}  ${gsm_cells_count_admin}
    ${wcdma_cells_count_admin}=  Get Length  ${cell_list['cells']['wcdma']}
    Should Be Equal As Integers  ${wcdma_cells_count_scfc}  ${wcdma_cells_count_admin}
    ${lte_cells_count_admin}=  Get Length  ${cell_list['cells']['lte']}
    Should Be Equal As Integers  ${lte_cells_count_scfc}  ${lte_cells_count_admin}
    ${nr_cells_count_admin}=  Get Length  ${cell_list['cells']['nr']}
    Should Be Equal As Integers  ${nr_cells_count_scfc}  ${nr_cells_count_admin}

#Radio modules
BTS Get Radio Modules Serial Number And Ids
    [Arguments]  ${admin_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword returns a dictionary of serial numbers
    ...  and configuration and internal ids of radio modules.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | admin_connection       |  No  | Admin connection object or if used, string name alias.                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${rmod_sn_conf_id_dict}=  Create Dictionary
    ${rmod_sn_internal_id_dict}=  Create Dictionary
    ${bts_info}=  admin.Get Bts Info
    ...  timeout=240
    ...  connection=${admin_connection}
    FOR  ${rmod_element}  IN  @{bts_info['radioModules']['rmod']}
      Set To Dictionary  ${rmod_sn_conf_id_dict}  ${rmod_element['serialNumber']}=${rmod_element['id']['configuration']}
      Set To Dictionary  ${rmod_sn_internal_id_dict}  ${rmod_element['serialNumber']}=${rmod_element['id']['internal']}
    END
    [Return]  ${rmod_sn_conf_id_dict}  ${rmod_sn_internal_id_dict}

BTS Get Radio Modules Serial Number And Cells Ids
    [Arguments]  ${admin_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword returns a dictionary of radio module serial numbers and rat cell ids of radio module.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | admin_connection       |  No  | Admin connection object or if used, string name alias.                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  Dictionary of radio module serial numbers and rat cell ids.
    ...  Example output:
    ...  {'CUS001004C7': {'NR': [], 'LNCEL': ['11', '12'], 'WNCEL': [], 'GNCEL': []}}
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${rmod_nrcel_id_list}=  Create List
    ${rmod_lncel_id_list}=  Create List
    ${rmod_wncel_id_list}=  Create List
    ${rmod_gncel_id_list}=  Create List
    ${rat_cell_id_dict}=  Create Dictionary
    ${rmod_sn_cell_id_dict}=  Create Dictionary
    ${bts_info}=  admin.Get Bts Info
    ...  timeout=240
    ...  connection=${admin_connection}
    FOR  ${rmod_element}  IN  @{bts_info['radioModules']['rmod']}
      FOR  ${carrier_element}  IN  @{rmod_element['carrierList']}
        ${rmod_nrcel_id}=  Get Regexp Matches  ${carrier_element['id']['configuration']}  NRCEL-(\\d+)  1
        Run Keyword If  ${rmod_nrcel_id}!=@{EMPTY}
        ...  Append To List  ${rmod_nrcel_id_list}  ${rmod_nrcel_id[0]}
        ${rmod_lncel_id}=  Get Regexp Matches  ${carrier_element['id']['configuration']}  LNCEL-(\\d+)  1
        Run Keyword If  ${rmod_lncel_id}!=@{EMPTY}
        ...  Append To List  ${rmod_lncel_id_list}  ${rmod_lncel_id[0]}
        ${rmod_wncel_id}=  Get Regexp Matches  ${carrier_element['id']['configuration']}  WNCEL-(\\d+)  1
        Run Keyword If  ${rmod_wncel_id}!=@{EMPTY}
        ...  Append To List  ${rmod_wncel_id_list}  ${rmod_wncel_id[0]}
        ${rmod_gncel_id}=  Get Regexp Matches  ${carrier_element['id']['configuration']}  GNCEL-(\\d+)  1
        Run Keyword If  ${rmod_gncel_id}!=@{EMPTY}
        ...  Append To List  ${rmod_gncel_id_list}  ${rmod_gncel_id[0]}
      END
      ${rmod_nrcel_id_list}=  Remove Duplicates  ${rmod_nrcel_id_list}
      ${rmod_lncel_id_list}=  Remove Duplicates  ${rmod_lncel_id_list}
      ${rmod_wncel_id_list}=  Remove Duplicates  ${rmod_wncel_id_list}
      ${rmod_gncel_id_list}=  Remove Duplicates  ${rmod_gncel_id_list}
      Set To Dictionary  ${rat_cell_id_dict}  NR=${rmod_nrcel_id_list}  LNCEL=${rmod_lncel_id_list}
      ...  WNCEL=${rmod_wncel_id_list}  GNCEL=${rmod_gncel_id_list}
      Set To Dictionary  ${rmod_sn_cell_id_dict}  ${rmod_element['serialNumber']}=${rat_cell_id_dict}
      ${rat_cell_id_dict}=  Create Dictionary
      ${rmod_nrcel_id_list}=  Create List
      ${rmod_lncel_id_list}=  Create List
      ${rmod_wncel_id_list}=  Create List
      ${rmod_gncel_id_list}=  Create List
    END
    [Return]  ${rmod_sn_cell_id_dict}

Admin Check Radio Modules State When BTS OnAir
    [Arguments]  ${timeout}=10  ${admin_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword verifies the condition of the radio modules when BTS is in "OnAir" state.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | timeout                |  No  | Waiting time for cells expected states.                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | admin_connection       |  No  | Admin connection object or if used, string name alias.                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    ${radio_administrativeState}=  Set Variable  administrativeState=regex"(?i)unlocked"
    ${radio_operationalState}=  Set Variable  operationalState=regex"(?i)Enabled"
    ${radio_availabilityStatus}=  Set Variable  availabilityStatus=regex"(?i)degraded"
    admin.Assert Every
    ...  class_name=RMOD
    ...  parameters=${radio_administrativeState}, ${radio_operationalState}
    ...  timeout=${timeout}
    ...  connection=${admin_connection}
    admin.Assert No
    ...  class_name=RMOD
    ...  parameters=${radio_availabilityStatus}
    ...  timeout=${timeout}
    ...  connection=${admin_connection}
