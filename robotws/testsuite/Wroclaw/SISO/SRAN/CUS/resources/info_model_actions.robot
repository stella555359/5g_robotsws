*** Settings ***
Library    BuiltIn
Library    Collections
#Library    ute_infomodel
Library    ute_admin_infomodel

Resource    ../../resources/bts_scfc.robot

*** Variables ***
${CELL_M_NODE_PATH}=    //LNBTS_M-1/CELL_M
# Example: /MRBTS-1/RAT-1/MCTRL-4/BBTOP_M-1/MRBTS_M-1/LNBTS_M-1/CELL_M-1

*** Keywords ***
Info Model Get LNCEL Parameter Value
    [Arguments]  ${lncel_id}  ${parameter_name}  ${timeout}=10  ${alias}=default  ${bts_l_id}=*
    [Documentation]
    ...  Description:
    ...  Keyword returns the value for the given parameter name for the given lncel_id.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | lncel_id               | Yes  | LNCEL id of cell.                                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | parameter_name         | Yes  | The name of the parameter whose value is to be retrieved.                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Time to wait for possitive query result.                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alias                  |  No  | Name of execution context.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | bts_l_id               |  No  | Left (1) or right (4) side of BTS.                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${parameter_value}=  Query Infomodel
    ...  query=get object //MCTRL-${bts_l_id}${CELL_M_NODE_PATH}-*/LNCEL_M-${lncel_id}
    ...  timeout=${timeout}  alias=${alias}
    [Return]  ${parameter_value.${parameter_name}}

Info Model Verify One Carrier Over One FD-CPRI Link
    [Arguments]  ${scfc_file_path}
    [Documentation]
    ...  Description:
    ...  Keyword checks that in case of dual-sector configuration (LTE4265/LTE4305 implementation),
    ...  where two cells share the same carrier vAxCs share the same link.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${lcr_id_list}=  SCFC Create LcrId List  scfc_file_path=${scfc_file_path}
    ${lncel_id_list}=  SCFC Create LncelId List  scfc_file_path=${scfc_file_path}
    ${lncel_ids_dict}=  Info Model Get DlChBw And EarfcnDl Parameters For LNCEL List
    ...  lncel_id_list=${lncel_id_list}
    Log  \n\nCells (LNCEL) and their EarfcnDl and DlChBw: ${lncel_ids_dict}\n  console=yes
    ${lncel_id_cablinks_dict}=  Info Model Get Cells Cablinks For LcrId  lcr_id_list=${lcr_id_list}
    Log  n\Cells (LNCEL) and their cablinks: ${lncel_id_cablinks_dict}\n  console=yes
    Verify If Identical Cells Have The Same Cablink
    ...  lncel_ids_dict=${lncel_ids_dict}  lncel_id_cablinks_dict=${lncel_id_cablinks_dict}

Info Model Get DlChBw And EarfcnDl Parameters For LNCEL List
    [Arguments]  ${lncel_id_list}
    [Documentation]
    ...  Description:
    ...  Keyword returns the dictionary of earfcnDl and dlChBw parameters and their corresponding lncel_id.
    ...  Main keyword: "Info Model Verify One Carrier Over One FD-CPRI Link"
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | lncel_id_list          | Yes  | List of LNCEL id of cell.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${lncel_ids_dict}=  Create Dictionary
    FOR  ${lncel_id}  IN  @{lncel_id_list}
      ${earfcnDl}=  Info Model Get LNCEL Parameter Value  lncel_id=${lncel_id}  parameter_name=earfcnDl
      ${dlChBw}=  Info Model Get LNCEL Parameter Value  lncel_id=${lncel_id}  parameter_name=dlChBw
      ${status}=  Run Keyword And Return Status
      ...  Dictionary Should Contain Key  dictionary=${lncel_ids_dict}  key=${earfcnDl}-${dlChBw}
      ${lncel_ids}=  Run Keyword If  ${status}
      ...  Get From Dictionary  dictionary=${lncel_ids_dict}  key=${earfcnDl}-${dlChBw}
      ...  ELSE
      ...  Create List  ${lncel_id}
      Run Keyword If  ${status}
      ...  Append To List  ${lncel_ids}  ${lncel_id}
      Set To Dictionary  ${lncel_ids_dict}  ${earfcnDl}-${dlChBw}  ${lncel_ids}
    END
    [Return]  ${lncel_ids_dict}

Info Model Get Cells Cablinks For LcrId
    [Arguments]  ${lcr_id_list}
    [Documentation]
    ...  Description:
    ...  Keyword is used to create dictionary of cablink information
    ...  (which cablink is used to route cell) for all cells (lncel_id).
    ...  Main keyword: "Info Model Verify One Carrier Over One FD-CPRI Link"
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | lcr_id_list            | Yes  | List of Lcr id of cell.                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${lncel_id_cablinks_dict}=  Create Dictionary
    ${lncel_id_list}=  Info Model Get LncelId List For LcrdId List  lcr_id_list=${lcr_id_list}
    FOR  ${lcr_id}  IN  @{lcr_id_list}
      ${lcr_id_index}=  Get Index From List  ${lcr_id_list}  ${lcr_id}
      ${channels_devices_list}=  Info Model Get Cell Channel Devices List For LcrId  lcr_id=${lcr_id}
      ${lcr_id_cablink}=  Info Model Get Cell Cablinks For LcrId  channels_devices_list=${channels_devices_list}
      ${lcr_id_cablink}=  Remove Duplicates  ${lcr_id_cablink}
      ${lcr_id_cablink_number}=  Get Length  item=${lcr_id_cablink}
      Should Be Equal  ${lcr_id_cablink_number}  ${1}
      ${lcr_id_cablink_value}=  Set Variable  ${lcr_id_cablink[0]}
      ${lncel_id}=  Get From List  ${lncel_id_list}  ${lcr_id_index}
      Set To Dictionary  ${lncel_id_cablinks_dict}  ${lncel_id}  ${lcr_id_cablink_value}
    END
    [Return]  ${lncel_id_cablinks_dict}

Info Model Get Cell Cablinks For LcrId
    [Arguments]  ${channels_devices_list}
    [Documentation]
    ...  Description:
    ...  Keyword returns cablinks used by cell (lcr_id) from "channels_devices_list" list.
    ...  "channels_devices_list" is returned by "Info Model Get Cell Channel Devices List For LcrId".
    ...  Main keyword: "Info Model Verify One Carrier Over One FD-CPRI Link"
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | channels_devices_list  | Yes  | List of Lcr id of cell.                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    @{lcr_id_cablink}=  Create List
    ${channels_devices_list_number}=  Get Length  item=${channels_devices_list}
    FOR  ${channel_devices_list_index}  IN RANGE  ${channels_devices_list_number}
      ${channel_devices_list}=  Get From List  ${channels_devices_list}  ${channel_devices_list_index}
      ${deviceDN_list}=  Get From Dictionary  dictionary=${channel_devices_list}  key=deviceDNs
      ${cablink_deviceDN}=  Info Model Get Cell Channel Cablink Dist Name  deviceDN_list=${deviceDN_list}
      ${cablink_value}=  Fetch From Right  string=${cablink_deviceDN}  marker=-
      Append To List  ${lcr_id_cablink}  ${cablink_value}
    END
    [Return]  ${lcr_id_cablink}

Info Model Get Cell Channel Cablink Dist Name
    [Arguments]  ${deviceDN_list}
    [Documentation]
    ...  Description:
    ...  Returns info fodel dist name of cablink for cell (lcr_id) channel.
    ...  Argument "deviceDN_list" is given for channel contains cablink name.
    ...  Main keyword: "Info Model Verify One Carrier Over One FD-CPRI Link"
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | deviceDN_list          | Yes  | List of dist name of all devices for cell (lcr_id).                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${deviceDN_number}=  Get Length  item=${deviceDN_list}
    ${cablink_deviceDN}=  Set Variable
    FOR  ${deviceDN_index}  IN RANGE  ${deviceDN_number}
      ${deviceDN_value}=  Get From List  ${deviceDN_list}  ${deviceDN_index}
      ${DN_value}=  Get From Dictionary  dictionary=${deviceDN_value}  key=deviceDN
      ${status}=  Run Keyword And Return Status
      ...  Should Match Regexp  string=${DN_value}  pattern=CABLINK
      ${cablink_deviceDN}=  Set Variable If  ${status}  ${DN_value}  ${cablink_deviceDN}
    END
    [Return]  ${cablink_deviceDN}

Verify If Identical Cells Have The Same Cablink
    [Arguments]  ${lncel_ids_dict}  ${lncel_id_cablinks_dict}
    [Documentation]
    ...  Description:
    ...  Keyword verify if identical (lncel_id) cells have the same cablink.
    ...  Main keyword: "Info Model Verify One Carrier Over One FD-CPRI Link"
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | lncel_ids_dict         | Yes  | Dictionary of earfcnDl and dlChBw parameters and their                     |
    ...  |                        |      | corresponding lncel_id.                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lncel_id_cablinks_dict | Yes  | Dictionary of cablink information (which cablink is used to route cell)    |
    ...  |                        |      | for all cells (lncel_id).                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${lncel_id_lists}=  Get Dictionary Values  dictionary=${lncel_ids_dict}
    FOR  ${lncel_id_list}  IN  @{lncel_id_lists}
      Verify Number Of Cablinks For LNCEL
      ...  lncel_id_list=${lncel_id_list}  lncel_id_cablinks_dict=${lncel_id_cablinks_dict}
    END

Verify Number Of Cablinks For LNCEL
    [Arguments]  ${lncel_id_list}  ${lncel_id_cablinks_dict}
    [Documentation]
    ...  Description:
    ...  Keyword checks the number of cablinks for given (lncel_id) cells list
    ...  Main keyword: "Info Model Verify One Carrier Over One FD-CPRI Link"
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | lncel_id_list          | Yes  | List of LNCEL id of cell.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lncel_id_cablinks_dict | Yes  | Dictionary of cablink information (which cablink is used to route cell)    |
    ...  |                        |      | for all cells (lncel_id)                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${cablink_list}=  Create List
    FOR  ${lncel_id}  IN  @{lncel_id_list}
      ${cablink_number}=  Get From Dictionary  dictionary=${lncel_id_cablinks_dict}  key=${lncel_id}
      Append To List  ${cablink_list}  ${cablink_number}
    END
    ${cablink_list}=  Remove Duplicates  ${cablink_list}
    ${cablink_list_count}=  Get Length  item=${cablink_list}
    Should Be Equal  ${cablink_list_count}  ${1}

Info Model Get Cell Channel Devices List For LcrId
    [Arguments]  ${lcr_id}  ${timeout}=10  ${alias}=default  ${bts_l_id}=*
    [Documentation]
    ...  Description:
    ...  Keyword returns devices list for LcrId cell channel
    ...  Main keyword: "Info Model Verify One Carrier Over One FD-CPRI Link"
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | lcr_id                 | Yes  | List of Lcr id of cell.                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Time to wait for possitive query result.                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alias                  |  No  | Name of execution context.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | bts_l_id               |  No  | Left (1) or right (4) side of BTS.                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${devices_list}=  Query Infomodel
    ...  query=get list //MCTRL-${bts_l_id}${CELL_M_NODE_PATH}-${lcr_id}/CHANNEL_GROUP_M-1/CHANNEL_M-*/DEVICES_LIST-1
    ...  timeout=${timeout}  alias=${alias}
    [Return]  ${devices_list}

Info Model Get Dist Name Of
    [Arguments]  ${object_name}  ${timeout}=10  ${alias}=default
    [Documentation]
    ...  Description:
    ...  Keyword returns dist_name for given object
    ...  Main keyword: "BTS Start Data Sync With Neighbor Node"
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | object_name            | Yes  | Name of a query object.                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Time to wait for possitive query result.                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alias                  |  No  | Name of execution context.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com
    ${out_dist_name}=  Query Infomodel  get object ${object_name}
    ...  timeout=${timeout}  alias=${alias}
    [Return]  ${out_dist_name.dist_name}

Info Model Get LncelId List For LcrdId List
    [Arguments]  ${lcr_id_list}  ${bts_l_id}=*  ${timeout}=10  ${alias}=default
    [Documentation]
    ...  Description:
    ...  Keyword returns lncel id list for lcrid cells list
    ...  Main keyword: Info Model Verify One Carrier Over One FD-CPRI Link
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | lcr_id_list            | Yes  | List of Lcr id of cell.                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | bts_l_id               |  No  | Left (1) or right (4) side of BTS.                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Time to wait for possitive query result.                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alias                  |  No  | Name of execution context.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com
    ${out_lncel_id_list}=  Create List
    FOR  ${lcr_id}  IN  @{lcr_id_list}
      ${out_lncel_object}=  Query Infomodel  query=get object //LTS-${bts_l_id}/LNBTS_L-1/LNCEL_L-* is [lcrId=${lcr_id}]
      ...  timeout=${timeout}  alias=${alias}
      ${out_lncel_id}=  Fetch From Right  ${out_lncel_object.dist_name}    -
      Append To List  ${out_lncel_id_list}  ${out_lncel_id}
    END
    [Return]  ${out_lncel_id_list}
